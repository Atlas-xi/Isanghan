/*
===========================================================================

  Copyright (c) 2022 LandSandBoat Dev Teams

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see http://www.gnu.org/licenses/

===========================================================================
*/

#include "application.h"

#include "debug.h"
#include "logging.h"
#include "lua.h"
#include "settings.h"
#include "taskmgr.h"
#include "timer.h"
#include "xirand.h"

#ifdef _WIN32
#include <windows.h>
#endif

#include <csignal>

// TODO: This is a hack to allow handleSignal and other not-yet refactored code to access Application
Application* gApplication = nullptr;

namespace
{
    void handleSignal(int signal)
    {
        switch (signal)
        {
            case SIGINT:
            case SIGTERM:
            case SIGBREAK:
                gApplication->requestExit();
                std::exit(1);
                break;
            case SIGABRT:
            case SIGABRT_COMPAT:
            case SIGSEGV:
            case SIGFPE:
            case SIGILL:
#ifdef _WIN32
#ifdef _DEBUG
                // Pass the signal to the system's default handler
                std::signal(signal, SIG_DFL);
                std::raise(signal);
#endif // _DEBUG
#endif // _WIN32
                break;
#ifndef _WIN32
            case SIGXFSZ:
                // ignore and allow it to set errno to EFBIG
                ShowWarning("SIGXFSZ");
                break;
            case SIGPIPE:
                ShowWarning("SIGPIPE");
                break; // does nothing here
#endif                 // _WIN32
            default:
                ShowWarning("Unhandled signal: %d", signal);
                break;
        }
    }
} // namespace

Application::Application(std::string const& serverName, int argc, char** argv)
: serverName_(serverName)
, isRunning_(false)
, argParser_(std::make_unique<argparse::ArgumentParser>(argv[0]))
{
    // TODO: Get rid of this
    gApplication = this;

    trySetConsoleTitle();
    registerSignalHandlers();
    usercheck();
    tryIncreaseRLimits();
    tryDisableQuickEditMode();
    parseCommandLineArguments(argc, argv);
    prepareLogging();

    // TODO: How much of this interferes with the signal handler in here?
    debug::init();
    timer_init();

    lua_init();
    settings::init();

    ShowInfoFmt("=======================================================================");
    ShowInfoFmt("Begin {}-server init...", serverName);

    srand((uint32)time(nullptr));
    xirand::seed();

#ifdef ENV64BIT
    ShowInfo("64-bit environment detected");
#else
    ShowInfo("32-bit environment detected");
#endif

    consoleService_ = std::make_unique<ConsoleService>(*this);
}

Application::~Application()
{
    tryRestoreQuickEditMode();
}

void Application::trySetConsoleTitle()
{
#ifdef _WIN32
    SetConsoleTitleA(fmt::format("{}-server", serverName_).c_str());
#endif
}

void Application::registerSignalHandlers()
{
    // TODO: Replace with asio::signal_set

    std::signal(SIGTERM, &handleSignal);
    std::signal(SIGINT, &handleSignal);
    std::signal(SIGBREAK, &handleSignal);
#if !defined(_DEBUG) && defined(_WIN32) // need unhandled exceptions to debug on Windows
    std::signal(SIGABRT, &handleSignal);
    std::signal(SIGABRT_COMPAT, &handleSignal);
    std::signal(SIGSEGV, &handleSignal);
    std::signal(SIGFPE, &handleSignal);
    std::signal(SIGILL, &handleSignal);
#endif
#ifndef _WIN32
    std::signal(SIGXFSZ, &handleSignal);
    std::signal(SIGPIPE, &handleSignal);
#endif
}

void Application::usercheck()
{
    // We _need_ root/admin for Tracy to be able to collect the full suite
    // of information, so we disable this warning if Tracy is enabled.
#ifndef TRACY_ENABLE
    if (debug::isUserRoot())
    {
        ShowWarning("You are running as the root superuser or admin.");
        ShowWarning("It is unnecessary and unsafe to run with root privileges.");
        std::this_thread::sleep_for(std::chrono::seconds(5));
    }
#endif // TRACY_ENABLE
}

void Application::tryIncreaseRLimits()
{
#ifndef _WIN32
    rlimit limits{};

    uint32 newRLimit = 10240;

    // Get old limits
    if (getrlimit(RLIMIT_NOFILE, &limits) == 0)
    {
        // Increase open file limit, which includes sockets, to newRLimit. This only effects the current process and child processes
        limits.rlim_cur = newRLimit;
        if (setrlimit(RLIMIT_NOFILE, &limits) == -1)
        {
            ShowError("Failed to increase rlim_cur to %d", newRLimit);
        }
    }
#endif
}

void Application::tryDisableQuickEditMode()
{
#ifdef _WIN32
    // Disable Quick Edit Mode (Mark) in Windows Console to prevent users from accidentially
    // causing the server to freeze.
    HANDLE hInput = GetStdHandle(STD_INPUT_HANDLE);
    GetConsoleMode(hInput, &prevQuickEditMode_);
    SetConsoleMode(hInput, ENABLE_EXTENDED_FLAGS | (prevQuickEditMode_ & ~ENABLE_QUICK_EDIT_MODE));
#endif // _WIN32
}

void Application::tryRestoreQuickEditMode()
{
#ifdef _WIN32
    // Re-enable Quick Edit Mode upon Exiting if it is still disabled
    HANDLE hInput = GetStdHandle(STD_INPUT_HANDLE);
    SetConsoleMode(hInput, prevQuickEditMode_);
#endif // _WIN32
}

void Application::parseCommandLineArguments(int argc, char** argv)
{
    //
    // Defaults
    //

    argParser_->add_argument("--log");
    argParser_->add_argument("--append-date", "--append_date");

    //
    // MapServer specific args (TODO: Move these into MapServer)
    //

    if (serverName_ == "map")
    {
        argParser_->add_argument("--ip");
        argParser_->add_argument("--port");
        argParser_->add_argument("--load-all", "--load_all");
    }

    //
    // Parse
    //

    try
    {
        argParser_->parse_args(argc, argv);
    }
    catch (const std::runtime_error& err)
    {
        std::cerr << err.what() << "\n";
        std::cerr << *argParser_ << "\n";
        std::exit(1);
    }
}

void Application::prepareLogging()
{
    auto logFile    = fmt::format("log/{}-server.log", serverName_);
    bool appendDate = false;

    //
    // MapServer specific setup (TODO: Move this into MapServer)
    //

    if (serverName_ == "map")
    {
        if (auto ipArg = argParser_->present("--ip"))
        {
            logFile = *ipArg;
        }

        if (auto portArg = argParser_->present("--port"))
        {
            logFile.append(*portArg);
        }
    }

    //
    // Regular setup
    //

    if (auto logArg = argParser_->present("--log"))
    {
        logFile = *logArg;
    }

    if (argParser_->present("--append-date"))
    {
        appendDate = true;
    }

    logging::InitializeLog(serverName_, logFile, appendDate);
}

void Application::markLoaded()
{
    ShowInfoFmt("The {}-server is ready to work...", serverName_);
    ShowInfoFmt("Type 'help' for a list of available commands.");
    ShowInfoFmt("=======================================================================");
    isRunning_ = true;
}

bool Application::isRunning()
{
    return isRunning_;
}

void Application::requestExit()
{
    isRunning_ = false;
    io_context_.stop();
}

void Application::run()
{
    Application::markLoaded();

    //
    // Simple TaskManager-only main tick
    //

    duration next;
    while (isRunning_)
    {
        next = CTaskMgr::getInstance()->DoTimer(server_clock::now());
        std::this_thread::sleep_for(next);
    }
}

auto Application::ioContext() -> asio::io_context&
{
    return io_context_;
}

auto Application::argParser() -> argparse::ArgumentParser&
{
    return *argParser_;
}

auto Application::console() -> ConsoleService&
{
    return *consoleService_;
}
