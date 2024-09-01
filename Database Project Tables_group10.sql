-- Final project part 2

# 1. Create schema
DROP SCHEMA IF EXISTS final;
CREATE SCHEMA final;
USE final;


# 2. Create table
-- Table structure for table `restaurants`
CREATE TABLE IF NOT EXISTS restaurants (
  restaurant_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  building VARCHAR(255) NOT NULL,
  street VARCHAR(255) NOT NULL,
  zipcode CHAR(5) NOT NULL,
  phone VARCHAR(255) NOT NULL,
  cuisine VARCHAR(255) NOT NULL,
  open_year YEAR NOT NULL,
  capacity SMALLINT UNSIGNED NOT NULL,
  PRIMARY KEY  (restaurant_id)
);

-- Table structure for table `inspections`
CREATE TABLE IF NOT EXISTS inspections (
  inspection_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  restaurant_id INT UNSIGNED NOT NULL,
  inspection_date DATE NOT NULL,
  score TINYINT UNSIGNED NOT NULL, # "score" is the penalty for each inspection
  PRIMARY KEY (inspection_id),
  FOREIGN KEY (restaurant_id) REFERENCES restaurants (restaurant_id) ON DELETE CASCADE ON UPDATE CASCADE
)AUTO_INCREMENT = 100;

-- Table structure for table `violation_types`
CREATE TABLE IF NOT EXISTS violation_types (
  violation_code CHAR(3) NOT NULL,
  violation_description VARCHAR(255) NOT NULL,
  critical_flag VARCHAR(5) NOT NULL,
  PRIMARY KEY  (violation_code)
);

-- Table structure for table `violations`
CREATE TABLE IF NOT EXISTS violations (
  violation_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  inspection_id INT UNSIGNED NOT NULL,
  violation_code CHAR(3) NOT NULL,
  PRIMARY KEY  (violation_id),
  FOREIGN KEY (inspection_id) REFERENCES inspections (inspection_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (violation_code) REFERENCES violation_types (violation_code) ON DELETE CASCADE ON UPDATE CASCADE
)AUTO_INCREMENT = 1000;


# 3. Add triggers
-- View all triggers in the database
SHOW TRIGGERS;

-- Create trigger for table `restaurants`
DELIMITER //
CREATE TRIGGER trigger_restaurants
	BEFORE INSERT ON restaurants
	FOR EACH ROW

BEGIN
## a. All zipcodes entered must be of length 5
  IF length(NEW.zipcode) != 5 THEN
     SIGNAL SQLSTATE 'HY000'
	 SET MESSAGE_TEXT = 'Error: All zipcodes entered must be of length 5.';
  END IF;

## b. Open year can not be in the future
  IF NEW.open_year > YEAR(NOW()) THEN
	 SIGNAL SQLSTATE 'HY000'
	 SET MESSAGE_TEXT = 'Error: Invalid open year.';
  END IF;

## c. Capacity can not be larger than 1000
  IF NEW.capacity > 1000 THEN
	 SIGNAL SQLSTATE 'HY000'
	 SET MESSAGE_TEXT = 'Error: Invalid capacity.';
  END IF;

END; //
DELIMITER ;

-- Create trigger for table `inspections`
DELIMITER //
CREATE TRIGGER trigger_inspections
	BEFORE INSERT ON inspections
	FOR EACH ROW

BEGIN
## a. Inspection date can not be in the future
  IF NEW.inspection_date > NOW() THEN
	 SIGNAL SQLSTATE 'HY000'
	 SET MESSAGE_TEXT = 'Error: Invalid inspection date.';
  END IF;

END; //
DELIMITER ;

-- Create trigger for table `violation_types`
DELIMITER //
CREATE TRIGGER trigger_violation_types
	BEFORE INSERT ON violation_types
	FOR EACH ROW

BEGIN
## a. All violation_code entered must be of length 3
  IF length(NEW.violation_code) != 3 THEN
     SIGNAL SQLSTATE 'HY000'
	 SET MESSAGE_TEXT = 'Error: All violation code entered must be of length 3.';
  END IF;
  
## b. The letter in the violation code must be upper case. Rather than output an error message have MySQL correct the data entry and store the violation code entered as upper case.
  SET NEW.violation_code = UPPER(NEW.violation_code);
  
## c. The entry of the critical flag must be upper case. Rather than output an error message have MySQL correct the data entry and store the critical flag entered as upper case.
  SET NEW.critical_flag = UPPER(NEW.critical_flag);

## d. The entry of the critical flag must be in one of 'YES' or 'NO'.
  IF NEW.critical_flag  NOT IN ("YES", "NO") THEN
     SIGNAL SQLSTATE 'HY002'
     SET MESSAGE_TEXT = 'Error: Critical flag must be YES or NO.';
  END IF;
  
END; //
DELIMITER ;

SHOW TRIGGERS;


# 4. Insert data
-- Insert data into the restaurants table
INSERT INTO restaurants (name, building, street, zipcode, phone, cuisine, open_year, capacity)
VALUES
('DJ REYNOLDS PUB AND RESTAURANT', '351', 'WEST 57 STREET', '10019', '2122452912', 'Irish', '2017' , 30),
('1 EAST 66TH STREET KITCHEN', '1', 'EAST 66 STREET', '10065', '2128793900', 'American', '2016', 40),
('P & S DELI GROCERY', '730', 'COLUMBUS AVENUE', '10025', '2129323030', 'American', '2019', 20),
('ISLE OF CAPRI RESTURANT', '1028', '3 AVENUE', '10065', '2127581902', 'Italian', '2011', 50),
('SEVILLA RESTAURANT', '62', 'CHARLES STREET', '10014', '2129293189', 'Latin American', '2010', 50),
('MCSORLEYS OLD ALE HOUSE', '15', 'EAST 7 STREET', '10003', '2122542570', 'Irish', '2015', 100),
('LA GRENOUILLE', '3', 'EAST 52 STREET', '10022', '2127521495', 'French', '2011', 70),
('KEATS RESTAURANT', '842', '2 AVENUE', '10017', '2126825490', 'American', '2008', 150),
('V & T RESTAURANT', '1024', 'AMSTERDAM AVENUE', '10025', '2126668051', 'Italian', '2012', 40),
('JOE ALLEN RESTAURANT', '326', 'WEST 46 STREET', '10036', '2125816464', 'American', '2016', 50),
('SHUN LEE PALACE RESTAURANT', '155', 'EAST 55 STREET', '10022', '2123718844', 'Chinese', '2009', 120), 
('MEXICO LINDO RESTAURANT', '459', '2 AVENUE', '10010', '2126793665', 'Mexican', '2018', 100),
('GRIFFIS FACULTY CLUB', '521', 'EAST 68 STREET', '10065', '6469623939', 'American', '2009', 60), 
('CAFE RIAZOR', '245', 'WEST 16 STREET', '10011', '2127272132', 'Spanish', '2003', 50),
('HATSUHANA RESTAURANT', '17', 'EAST 48 STREET', '10017', '2123553345', 'Japanese', '2010', 60),
('HOP KEE RESTAURANT', '21', 'MOTT STREET', '10013', '2129648365', 'Chinese', '2013', 80),
('MIMIS RESTAURANT & BAR', '984', 'SECOND AVENUE', '10022', '2126884692', 'Italian', '2011', 100),
('RAOULS', '180', 'PRINCE STREET', '10012', '2129663518', 'French', '2008', 70),
('THE BROOK', '111', 'EAST 54 STREET', '10022', '2127537020', 'American', '2010', 40),
('VIAND COFFEE SHOP', '673', 'MADISON AVENUE', '10065', '2127516622', 'Greek', '2012', 100);

-- Insert data into the inspections table
INSERT INTO inspections (restaurant_id, inspection_date, score)
VALUES
(1, '2022-01-04', 12),
(1, '2023-04-23', 10),
(2, '2019-10-01', 9),
(2, '2022-05-03', 9),
(3, '2022-02-08', 17), 
(3, '2022-08-16', 12), 
(3, '2023-02-07', 12), 
(4, '2022-02-16', 10), 
(4, '2023-02-06', 7), 
(5, '2021-08-04', 27), 
(5, '2022-05-18', 19), 
(5, '2023-05-17', 12), 
(6, '2021-08-04', 13), 
(6, '2022-10-17', 22), 
(6, '2023-08-17', 12), 
(7, '2021-08-12', 13), 
(7, '2023-03-29', 12), 
(8, '2020-02-12', 5), 
(8, '2022-12-21', 17), 
(9, '2022-05-23', 8), 
(9, '2023-06-05', 5), 
(10, '2022-09-20', 12), 
(11, '2022-03-10', 31), 
(11, '2022-03-29', 12), 
(11, '2023-06-06', 11), 
(12, '2022-01-06', 23), 
(12, '2022-03-02', 12), 
(12, '2023-10-26', 13),
(13, '2022-03-07', 13), 
(13, '2023-04-25', 10), 
(14, '2022-01-05', 9), 
(14, '2023-01-25', 28), 
(14, '2023-11-15', 13), 
(15, '2022-03-24', 13), 
(15, '2023-06-26', 12);

-- Insert data into the violation_types table
INSERT INTO violation_types (violation_code, violation_description, critical_flag)
VALUES
('02B', 'Hot food item not held at or above 140 °F.', 'YES'),
('02G', 'Cold food item held above 41 °F.', 'YES'),
('02H', 'Food not cooled by an approved method.', 'YES'),
('02I', 'Food removed from cold holding or prepared from or combined with ingredients at room temperature not cooled by an approved method.', 'YES'), 
('03B', 'Shellfish not from approved source, not or improperly tagged/labeled.', 'YES'), 
('04A', 'Food Protection Certificate (FPC) not held by manager or supervisor of food operations.', 'YES'), 
('04H', 'Raw, cooked or prepared food is adulterated, contaminated, cross-contaminated, or not discarded in accordance with HACCP plan.', 'YES'), 
('04L', "Evidence of mice or live mice in establishment's food or non-food areas.", 'YES'), 
('04N', "Filth flies or food/refuse/sewage associated with (FRSA) flies or other nuisance pests in establishment's food and/or non-food areas.", 'YES'), 
('06C', 'Food not protected from potential source of contamination during storage, preparation, transportation, display or service.', 'YES'), 
('06D', 'Food contact surface not properly washed, rinsed and sanitized after each use and following any activity when contamination may have occurred.', 'YES'), 
('06E', 'Sanitized equipment or utensil, including in-use food dispensing utensil, improperly used or stored.', 'YES'), 
('06F', 'Wiping cloths not stored clean and dry, or in a sanitizing solution, between uses.', 'YES'), 
('08A', 'Establishment is not free of harborage or conditions conducive to rodents, insects or other pests.', 'NO'),
('08C', 'Pesticide use not in accordance with label or applicable laws. Prohibited chemical used/stored. Open bait station used.', 'NO'), 
('09B', 'Thawing procedures improper.', 'NO'), 
('09C', 'Food contact surface not properly maintained.', 'NO'), 
('09E', 'Wash hands sign not posted near or above hand washing sink.', 'NO'), 
('10B', 'Plumbing not properly installed or maintained; anti-siphonage or backflow prevention device not provided where required; equipment or floor not properly drained; sewage disposal system in disrepair or not functioning properly.', 'NO'), 
('10D', 'Mechanical or natural ventilation not provided, inadequate, improperly installed, in disrepair or fails to prevent and control excessive build-up of grease, heat, steam condensation, vapors, odors, smoke or fumes.', 'NO'), 
('10F', 'Non-food contact surface improperly constructed, maintained and/or not properly sealed, raised, spaced or movable to allow accessibility for cleaning on all sides, above and underneath the unit.', 'NO'), 
('10G', 'Cleaning and sanitizing of tableware, including dishes, utensils, and equipment deficient.', 'NO'), 
('10H', 'Proper sanitization not provided for utensil ware washing operation.', 'NO'), 
('10I', 'Single service item reused, improperly stored, dispensed; not used when required.', 'NO'), 
('10J', 'Hand wash sign not posted.', 'NO');

-- Insert data into the violations table
INSERT INTO violations (inspection_id, violation_code)
VALUES
(100, '06D'),
(100, '10B'),
(100, '10F'),
(101, '06C'),
(101, '06E'),
(102, '04H'),
(102, '10F'),
(103, '06D'),
(103, '10F'),
(104, '04L'),
(104, '06D'),
(104, '08A'),
(104, '10F'),
(105, '04N'),
(105, '08A'), 
(105, '09B'),
(106, '02G'), 
(106, '06D'), 
(107, '06D'),
(107, '10B'), 
(107, '10I'), 
(108, '02B'), 
(109, '02H'), 
(109, '04H'), 
(109, '04L'), 
(109, '08A'), 
(109, '10B'), 
(110, '04L'), 
(110, '06C'), 
(110, '08A'), 
(110, '08C'), 
(111, '04L'), 
(111, '08A'), 
(111, '10B'), 
(112, '04L'), 
(112, '08A'), 
(112, '10B'), 
(113, '02G'), 
(113, '04L'), 
(113, '08A'), 
(113, '08C'), 
(113, '10F'), 
(114, '04L'), 
(114, '08A'), 
(114, '10B'), 
(115, '04N'), 
(115, '08A'), 
(115, '10B'), 
(116, '06F'), 
(116, '10B'), 
(116, '10F'), 
(117, '08C'), 
(117, '10H'),
(118, '04A'),
(118, '04H'), 
(119, '06D'), 
(119, '10B'), 
(120, '10G'), 
(121, '04H'), 
(121, '10B'), 
(121, '10F'), 
(122, '02B'), 
(122, '04L'), 
(122, '08A'), 
(122, '08C'), 
(122, '10F'), 
(122, '10H'), 
(123, '04H'), 
(123, '10B'), 
(124, '06D'), 
(124, '10D'), 
(124, '10F'), 
(125, '04H'), 
(125, '04L'), 
(125, '08A'), 
(125, '08C'), 
(125, '10B'), 
(125, '10F'), 
(126, '02G'), 
(126, '06C'), 
(127, '04H'), 
(127, '06C'), 
(128, '04L'), 
(128, '08A'), 
(128, '09C'), 
(129, '02I'), 
(129, '06F'), 
(130, '04N'), 
(130, '08A'), 
(131, '03B'), 
(131, '04L'), 
(131, '08A'), 
(131, '09E'), 
(131, '10F'), 
(132, '04A'), 
(132, '10F'), 
(133, '06D'), 
(133, '09B'), 
(133, '10B'),
(133, '10F'), 
(133, '10J'), 
(134, '02B'), 
(134, '10B'), 
(134, '10F');



# 5. Check the tables
USE final;

SELECT *
FROM restaurants; -- 20 restaurants

SELECT *
FROM inspections; --  35 inspections for 15 restaurants in total, each restaurant has 1~3

SELECT *
FROM violations; -- 104 violation records in total, each inspection has 1~6

SELECT *
FROM violation_types; -- 25 violation types in total












