-- Clear existing drops for our mobs first
DELETE FROM mob_droplist WHERE dropId IN (1085, 3352, 3353, 3354, 3355, 3356);

-- Goblin Golem (dropId 1085)
INSERT INTO mob_droplist VALUES (1085, 0, 0, 1000, 3419, 1000); -- Fiendish Tome Chapter 16 (100% drop)
INSERT INTO mob_droplist VALUES (1085, 1, 1, 1000, 16092, 200); -- Usukane Somen
INSERT INTO mob_droplist VALUES (1085, 1, 1, 1000, 16088, 200); -- Skadis Visor
INSERT INTO mob_droplist VALUES (1085, 1, 1, 1000, 16100, 200); -- Morrigans Coronal
INSERT INTO mob_droplist VALUES (1085, 1, 1, 1000, 16096, 200); -- Marduks Tiara
INSERT INTO mob_droplist VALUES (1085, 1, 1, 1000, 16084, 200); -- Ares Mask

-- Quicktrix Hexhands (3356)
INSERT INTO mob_droplist VALUES (3356, 0, 0, 1000, 3420, 1000); -- Guaranteed tome drop
INSERT INTO mob_droplist VALUES (3356, 1, 1, 1000, 16092, 200);
INSERT INTO mob_droplist VALUES (3356, 1, 1, 1000, 16088, 200);
INSERT INTO mob_droplist VALUES (3356, 1, 1, 1000, 16100, 200);
INSERT INTO mob_droplist VALUES (3356, 1, 1, 1000, 16096, 200);
INSERT INTO mob_droplist VALUES (3356, 1, 1, 1000, 16084, 200);

-- Feralox Honeylips (3353)
INSERT INTO mob_droplist VALUES (3353, 0, 0, 1000, 3421, 1000); -- Guaranteed tome drop
INSERT INTO mob_droplist VALUES (3353, 1, 1, 1000, 16092, 200);
INSERT INTO mob_droplist VALUES (3353, 1, 1, 1000, 16088, 200);
INSERT INTO mob_droplist VALUES (3353, 1, 1, 1000, 16100, 200);
INSERT INTO mob_droplist VALUES (3353, 1, 1, 1000, 16096, 200);
INSERT INTO mob_droplist VALUES (3353, 1, 1, 1000, 16084, 200);

-- Scourquix Scaleskin (3354)
INSERT INTO mob_droplist VALUES (3354, 0, 0, 1000, 3422, 1000); -- Guaranteed tome drop
INSERT INTO mob_droplist VALUES (3354, 1, 1, 1000, 16092, 200);
INSERT INTO mob_droplist VALUES (3354, 1, 1, 1000, 16088, 200);
INSERT INTO mob_droplist VALUES (3354, 1, 1, 1000, 16100, 200);
INSERT INTO mob_droplist VALUES (3354, 1, 1, 1000, 16096, 200);
INSERT INTO mob_droplist VALUES (3354, 1, 1, 1000, 16084, 200);

-- Wilywox Tenderpalm (3355)
INSERT INTO mob_droplist VALUES (3355, 0, 0, 1000, 3423, 1000); -- Guaranteed tome drop
INSERT INTO mob_droplist VALUES (3355, 1, 1, 1000, 16092, 200);
INSERT INTO mob_droplist VALUES (3355, 1, 1, 1000, 16088, 200);
INSERT INTO mob_droplist VALUES (3355, 1, 1, 1000, 16100, 200);
INSERT INTO mob_droplist VALUES (3355, 1, 1, 1000, 16096, 200);
INSERT INTO mob_droplist VALUES (3355, 1, 1, 1000, 16084, 200);

-- Arch Goblin Golem (3352) - Only drops rare helms, no tome
INSERT INTO mob_droplist VALUES (3352, 1, 1, 1000, 16116, 500); -- Valkyries Hat
INSERT INTO mob_droplist VALUES (3352, 1, 1, 1000, 16114, 500); -- Valkyries Helm
