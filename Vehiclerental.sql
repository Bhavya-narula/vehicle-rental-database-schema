-- Drop views first
DROP VIEW IF EXISTS AvailableVehicles;
DROP VIEW IF EXISTS VehicleRentalPrices;

-- Drop tables after views
DROP TABLE IF EXISTS Invoice;
DROP TABLE IF EXISTS Nominate;
DROP TABLE IF EXISTS HiredVehicle;
DROP TABLE IF EXISTS Booking;
DROP TABLE IF EXISTS Clientphone;
DROP TABLE IF EXISTS PersonalClient;
DROP TABLE IF EXISTS CompanyClient;
DROP TABLE IF EXISTS Client;
DROP TABLE IF EXISTS Depotphone;
DROP TABLE IF EXISTS Depot;
DROP TABLE IF EXISTS Records;
DROP TABLE IF EXISTS Daily_Tariff;
DROP TABLE IF EXISTS Vehicle;
DROP TABLE IF EXISTS Vehicle_Type;
DROP TABLE IF EXISTS Insurance;


-- Create the Vehicle_Type table
CREATE TABLE Vehicle_Type( 
    Make VARCHAR(8) NOT NULL,
    Model VARCHAR(8) NOT NULL,
    Doors VARCHAR(8),
    Body VARCHAR(8),
    Trim VARCHAR(8),
    Fuel VARCHAR(8),
    PRIMARY KEY (Make, Model)
);

-- Create the Vehicle table
CREATE TABLE Vehicle (
    regNum VARCHAR(7) NOT NULL,
    FleetNum VARCHAR(3) NOT NULL,
    Colour VARCHAR(20) NOT NULL,
    DepotID VARCHAR(2) NOT NULL,
    Make VARCHAR(8) NOT NULL,
    Model VARCHAR(8) NOT NULL,
    PRIMARY KEY (regNum),
    FOREIGN KEY (DepotID) REFERENCES Depot(DepotID) ON UPDATE CASCADE ON DELETE NO ACTION, 
    FOREIGN KEY (Make) REFERENCES Vehicle_Type(Make) ON UPDATE CASCADE ON DELETE NO ACTION, 
    FOREIGN KEY (Model) REFERENCES Vehicle_Type(Model)ON UPDATE CASCADE ON DELETE NO ACTION
);

-- Create the Daily_Tariff table
CREATE TABLE Daily_Tariff(
    tariffID VARCHAR(2) NOT NULL,
    Conditions VARCHAR(50) NOT NULL,
    PRIMARY KEY (tariffID)
);

-- Create the Depot table
CREATE TABLE Depot(
    DepotID VARCHAR(2) NOT NULL,
    Street VARCHAR(45) NOT NULL,
    Postcode VARCHAR(4) NOT NULL,
    email VARCHAR(24) NOT NULL,
    PRIMARY KEY (DepotID)
);

-- Create the Depotphone table
CREATE TABLE Depotphone(
    DepotID VARCHAR(2) NOT NULL,
    Phone VARCHAR(14) NOT NULL,
    PRIMARY KEY (Phone),
    FOREIGN KEY (DepotID) REFERENCES Depot(DepotID) ON UPDATE CASCADE ON DELETE NO ACTION
);

-- Create the Client table
CREATE TABLE Client(
    clientID VARCHAR(2) NOT NULL,
    street VARCHAR(45) NOT NULL,
    Postcode VARCHAR(4) NOT NULL,
    PRIMARY KEY (clientID)
);

-- Create the Clientphone table
CREATE TABLE Clientphone(
    clientID VARCHAR(2) NOT NULL,
    Phone VARCHAR(14) NOT NULL,
    PRIMARY KEY (Phone),
    FOREIGN KEY (clientID) REFERENCES Client(clientID) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Create the Booking table
CREATE TABLE Booking(
    startDate DATE NOT NULL,
    hireDays VARCHAR(2) NOT NULL,
    Colour VARCHAR(12),
    Make VARCHAR(8) NOT NULL,
    Model VARCHAR(8) NOT NULL,
    DepotID VARCHAR(2) NOT NULL,
    clientID VARCHAR(2) NOT NULL,
    PRIMARY KEY (startDate, Make, Model, clientID),
    FOREIGN KEY (DepotID) REFERENCES Depot(DepotID) ON UPDATE CASCADE ON DELETE NO ACTION,
    FOREIGN KEY (clientID) REFERENCES Client(clientID) ON UPDATE CASCADE ON DELETE NO ACTION,
    FOREIGN KEY (Make) REFERENCES Vehicle_Type(Make) ON UPDATE CASCADE ON DELETE NO ACTION,
    FOREIGN KEY (Model) REFERENCES Vehicle_Type(Model) ON UPDATE CASCADE ON DELETE NO ACTION
);

-- Create the PersonalClient table
CREATE TABLE PersonalClient(
    clientID VARCHAR(2) NOT NULL,
    fName VARCHAR(20) NOT NULL,
    lName VARCHAR(20) NOT NULL,
    title VARCHAR(8) NOT NULL,
    driversNum VARCHAR(12) NOT NULL,
    PRIMARY KEY (clientID),
    FOREIGN KEY (clientID) REFERENCES Client(clientID) ON UPDATE CASCADE ON DELETE NO ACTION
);

-- Create the CompanyClient table
CREATE TABLE CompanyClient(
    clientID VARCHAR(2) NOT NULL,
    cName VARCHAR(40) NOT NULL,
    PRIMARY KEY (clientID),
    FOREIGN KEY (clientID) REFERENCES PersonalClient(clientID) ON UPDATE CASCADE ON DELETE NO ACTION
);

-- Create the Insurance table
CREATE TABLE Insurance(
    InsuranceID VARCHAR(2) NOT NULL,
    Policy_type VARCHAR(8) NOT NULL,
    cost DECIMAL(5,2) NOT NULL,
    policyNumber VARCHAR(8) UNIQUE,
    PRIMARY KEY (InsuranceID)
);

-- Create the HiredVehicle table
CREATE TABLE HiredVehicle(
    Date DATETIME NOT NULL,
    cardType VARCHAR(2) NOT NULL,
    CardNo VARCHAR(20) NOT NULL,
    Odometer INT(10) NOT NULL,
    Days VARCHAR(2) NOT NULL,
    regNum VARCHAR(7) NOT NULL,
    DepotID VARCHAR(2) NOT NULL,
    clientID VARCHAR(2) NOT NULL,
    tariffID VARCHAR(2) NOT NULL,
    InsuranceID VARCHAR(2) NOT NULL,
    policyNumber VARCHAR(8) NOT NULL,
    returnDate DATETIME,
    PRIMARY KEY (Date, regNum),
    FOREIGN KEY (regNum) REFERENCES Vehicle(regNum) ON UPDATE CASCADE ON DELETE NO ACTION, 
    FOREIGN KEY (DepotID) REFERENCES Depot(DepotID) ON UPDATE CASCADE ON DELETE NO ACTION, 
    FOREIGN KEY (clientID) REFERENCES Client(clientID) ON UPDATE CASCADE ON DELETE NO ACTION, 
    FOREIGN KEY (tariffID) REFERENCES Daily_Tariff(tariffID) ON UPDATE CASCADE ON DELETE NO ACTION, 
    FOREIGN KEY (InsuranceID) REFERENCES Insurance(InsuranceID) ON UPDATE CASCADE ON DELETE NO ACTION
);

-- Create the Nominate table
CREATE TABLE Nominate(
    clientID VARCHAR(2) NOT NULL,
    Date DATETIME NOT NULL,
    regNum VARCHAR(7) NOT NULL,
    PRIMARY KEY (clientID, Date, regNum),
    FOREIGN KEY (clientID) REFERENCES Client(clientID) ON UPDATE CASCADE ON DELETE NO ACTION,
    FOREIGN KEY (Date,regNum) REFERENCES HiredVehicle(Date,regNum) ON UPDATE CASCADE ON DELETE NO ACTION
);

-- Create the Records table
CREATE TABLE Records(
    Make VARCHAR(8) NOT NULL,
    Model VARCHAR(8) NOT NULL,
    tariffID VARCHAR(2) NOT NULL,
    rentalPrice DECIMAL(5,2) NOT NULL,
    PRIMARY KEY (Make, Model, tariffID),
    FOREIGN KEY (Make) REFERENCES Vehicle_Type(Make) ON UPDATE CASCADE ON DELETE NO ACTION,
    FOREIGN KEY (Model) REFERENCES Vehicle_Type(Model) ON UPDATE CASCADE ON DELETE NO ACTION,
    FOREIGN KEY (tariffID) REFERENCES Daily_Tariff(tariffID) ON UPDATE CASCADE ON DELETE NO ACTION
);

-- Create the Invoice table
CREATE TABLE Invoice(
    InvoiceID VARCHAR(10) NOT NULL,
    clientID VARCHAR(2) NOT NULL,
    DepotID VARCHAR(2) NOT NULL,
    regNum VARCHAR(7) NOT NULL,
    qualityCheck VARCHAR(3) NOT NULL,
    datePaid DATE NOT NULL,
    Date DATETIME NOT NULL,
    tariffID VARCHAR(2) NOT NULL,
    finalCost DECIMAL(5,2),
    PRIMARY KEY (InvoiceID),
    FOREIGN KEY (clientID) REFERENCES Client(clientID) ON UPDATE CASCADE ON DELETE NO ACTION,
    FOREIGN KEY (regNum) REFERENCES Vehicle(regNum) ON UPDATE CASCADE ON DELETE NO ACTION,
    FOREIGN KEY (DepotID) REFERENCES Depot(DepotID) ON UPDATE CASCADE ON DELETE NO ACTION,
    FOREIGN KEY (tariffID) REFERENCES Daily_Tariff(tariffID) ON UPDATE CASCADE ON DELETE NO ACTION,
    FOREIGN KEY (Date, regNum) REFERENCES HiredVehicle(Date, regNum) ON UPDATE CASCADE ON DELETE NO ACTION
    
);

CREATE TRIGGER update_final_cost
AFTER INSERT ON Invoice
FOR EACH ROW
WHEN NEW.finalCost IS NULL  -- Trigger only when finalCost is NULL
BEGIN
    UPDATE Invoice
    SET finalCost = (
        -- Calculate finalCost: days * rentalPrice
        SELECT HV.Days * R.rentalPrice
        FROM HiredVehicle HV
        JOIN Vehicle V ON HV.regNum = V.regNum
        JOIN Records R ON V.Make = R.Make AND V.Model = R.Model
        WHERE HV.clientID = NEW.clientID
        AND HV.regNum = NEW.regNum
        AND R.tariffID = NEW.tariffID
        LIMIT 1  -- Ensure it updates only one row
    )
    WHERE Invoice.InvoiceID = NEW.InvoiceID;  -- Update the correct invoice
END;

CREATE TRIGGER prevent_double_booking
BEFORE INSERT ON Booking
FOR EACH ROW
BEGIN
    SELECT CASE
        WHEN EXISTS (
            SELECT 1 FROM Booking
            WHERE Make = NEW.Make
            AND Model = NEW.Model
            AND DepotID = NEW.DepotID
            AND startDate = NEW.startDate
        ) THEN
            RAISE(ABORT, 'This vehicle is already booked for the selected time period.')
    END;
END;

CREATE TRIGGER prevent_duplicate_company_name
BEFORE INSERT ON CompanyClient
FOR EACH ROW
BEGIN
    SELECT CASE
        WHEN EXISTS (
            SELECT 1 FROM CompanyClient
            WHERE cName = NEW.cName
        ) THEN
            RAISE(ABORT, 'This company name is already taken.')
    END;
END;




-- Insert values into Vehicle_Type
INSERT INTO Vehicle_Type (Make, Model, Doors, Body, Trim, Fuel)
VALUES 
('Toyota', 'Corolla', '4', 'Sedan', 'Standard', 'Fuel'),
('Honda', 'Civic', '4', 'Sedan', 'Sport', 'Hybrid'),
('Tesla', 'Model3', '4', 'Sedan', 'Premium', 'EV'),
('Nissan', 'Leaf', '4', 'Hatchback', 'Standard', 'EV'),
('Ford', 'Focus', '4', 'Sedan', 'Standard', 'Fuel');

-- Insert values into Depot
INSERT INTO Depot (DepotID, Street, Postcode, email)
VALUES 
('01', '123 Main St', '6000', 'mainst@example.com'),
('02', '456 Side Ave', '6001', 'sideave@example.com'),
('03', '789 Central Blvd', '6002', 'centralblvd@example.com'),
('04', '321 West Rd', '6003', 'westrd@example.com'),
('05', '654 South St', '6004', 'southst@example.com');

-- Insert values into Depotphone
INSERT INTO Depotphone (DepotID, Phone)
VALUES 
('01', '12345678901234'),
('01', '12345678905678'),
('02', '12345678903456'),
('03', '12345678907890'),
('04', '12345678912345');

-- Insert values into Client
INSERT INTO Client (clientID, street, Postcode)
VALUES 
('C1', '789 Broadway St', '6002'),
('C2', '321 West End Ave', '6003'),
('C3', '654 River St', '6004'),
('C4', '555 High St', '6001'),
('C5', '888 Park Ln', '6000');

-- Insert values into Clientphone
INSERT INTO Clientphone (clientID, Phone)
VALUES 
('C1', '98765432101234'),
('C1', '98765432104321'),
('C2', '98765432106543'),
('C3', '98765432108765'),
('C4', '98765432102345');

-- Insert values into PersonalClient
INSERT INTO PersonalClient (clientID, fName, lName, title, driversNum)
VALUES 
('C1', 'John', 'Doe', 'Mr.', 'D123456789012'),
('C2', 'Jane', 'Smith', 'Ms.', 'D987654321098'),
('C3', 'Emily', 'Johnson', 'Mrs.', 'D112233445566'),
('C4', 'Michael', 'Brown', 'Mr.', 'D223344556677'),
('C5', 'Sarah', 'Davis', 'Ms.', 'D334455667788');

-- Insert values into CompanyClient
INSERT INTO CompanyClient (clientID, cName)
VALUES 
('C2', 'ABC Corporation'),
('C3', 'XYZ Industries'),
('C4', 'Tech Solutions'),
('C5', 'Global Enterprises'),
('C1', 'Universal Trading');

-- Insert values into Vehicle
INSERT INTO Vehicle (regNum, FleetNum, Colour, DepotID, Make, Model)
VALUES 
('1ABC234', '001', 'Red', '01', 'Toyota', 'Corolla'),
('2DEF567', '002', 'Blue', '01', 'Honda', 'Civic'),
('3GHI890', '003', 'Black', '02', 'Tesla', 'Model3'),
('4JKL123', '004', 'White', '03', 'Nissan', 'Leaf'),
('5MNO456', '005', 'Silver', '04', 'Ford', 'Focus');

-- Insert values into Daily_Tariff
INSERT INTO Daily_Tariff (tariffID, Conditions)
VALUES 
('T1', 'Weekday special rate'),
('T2', 'Weekend premium rate'),
('T3', 'Holiday surcharge'),
('T4', 'Long-term rental discount'),
('T5', 'Short-term hire');

-- Insert values into Records
INSERT INTO Records (Make, Model, tariffID, rentalPrice)
VALUES 
('Toyota', 'Corolla', 'T1', 50.00),
('Honda', 'Civic', 'T2', 70.00),
('Tesla', 'Model3', 'T3', 100.00),
('Nissan', 'Leaf', 'T4', 80.00),
('Ford', 'Focus', 'T5', 60.00);

-- Insert values into Insurance
INSERT INTO Insurance (InsuranceID, Policy_type, cost, policyNumber)
VALUES 
('I1', 'Full Coverage', 20.00, 'P1234567'),
('I2', 'Third Party', 10.00, 'P2345678'),
('I3', 'Full Coverage', 25.00, 'P3456789'),
('I4', 'Comprehensive', 15.00, 'P4567890'),
('I5', 'Basic', 5.00, 'P5678901');

-- Insert values into Booking
INSERT INTO Booking (startDate, hireDays, Colour, Make, Model, DepotID, clientID)
VALUES 
('2023-10-10', '5', 'Red', 'Toyota', 'Corolla', '01', 'C1'),
('2023-10-15', '3', 'Blue', 'Honda', 'Civic', '01', 'C2'),
('2023-10-20', '7', 'Black', 'Tesla', 'Model3', '02', 'C3'),
('2023-11-01', '2', 'White', 'Nissan', 'Leaf', '03', 'C4'),
('2023-11-05', '4', 'Silver', 'Ford', 'Focus', '04', 'C5');

-- Insert values into HiredVehicle
INSERT INTO HiredVehicle (Date, cardType, CardNo, Odometer, Days, regNum, DepotID, clientID, tariffID, InsuranceID, policyNumber, returnDate)
VALUES 
('2023-10-10 09:00:00', 'VISA', '4111111111111111', '10000', '5', '1ABC234', '01', 'C1', 'T1', 'I1', 'P1234567', '2023-10-15 09:00:00'),
('2023-10-15 09:00:00', 'MAST', '5555555555554444', '20000', '3', '2DEF567', '01', 'C2', 'T2', 'I2', 'P2345678', '2023-10-18 09:00:00'),
('2023-10-20 10:00:00', 'AMEX', '378282246310005', '30000', '7', '3GHI890', '02', 'C3', 'T3', 'I3', 'P3456789', '2023-10-27 10:00:00'),
('2023-11-01 11:00:00', 'VISA', '4111111111111112', '40000', '2', '4JKL123', '03', 'C4', 'T4', 'I4', 'P4567890', '2023-11-03 11:00:00'),
('2023-11-05 12:00:00', 'MAST', '5555555555554445', '50000', '4', '5MNO456', '04', 'C5', 'T5', 'I5', 'P5678901', '2023-11-09 12:00:00');

-- Insert values into Nominate
INSERT INTO Nominate (clientID, Date, regNum)
VALUES 
('C1', '2023-10-10 09:00:00', '1ABC234'),
('C2', '2023-10-15 09:00:00', '2DEF567'),
('C3', '2023-10-20 10:00:00', '3GHI890'),
('C4', '2023-11-01 11:00:00', '4JKL123'),
('C5', '2023-11-05 12:00:00', '5MNO456');

-- Insert values into Invoice 
INSERT INTO Invoice (InvoiceID, clientID, DepotID, regNum, qualityCheck, datePaid, finalCost, Date, tariffID) 
VALUES 
('INV001', 'C1', '01', '1ABC234', 'Yes', '2023-10-15', 250.00, '2023-10-10 09:00:00', 'T1'),
('INV002', 'C2', '01', '2DEF567', 'Yes', '2023-10-18', 210.00, '2023-10-15 09:00:00', 'T2'), 
('INV003', 'C3', '02', '3GHI890', 'Yes', '2023-10-27', 700.00, '2023-10-20 10:00:00', 'T3'), 
('INV004', 'C4', '03', '4JKL123', 'Yes', '2023-11-03', 160.00, '2023-11-01 11:00:00', 'T4'), 
('INV005', 'C5', '04', '5MNO456', 'Yes', '2023-11-09', 240.00, '2023-11-05 12:00:00', 'T5');


CREATE VIEW AvailableVehicles AS
SELECT 
    v.regNum, 
    v.Make, 
    v.Model, 
    v.Colour, 
    d.DepotID, 
    d.Street AS DepotLocation
FROM 
    Vehicle v
JOIN 
    Depot d ON v.DepotID = d.DepotID
LEFT JOIN 
    HiredVehicle hv ON v.regNum = hv.regNum AND hv.returnDate IS NULL
WHERE 
    hv.regNum IS NULL;



CREATE VIEW VehicleRentalPrices AS
SELECT 
    vt.Make, 
    vt.Model, 
    dt.tariffID, 
    dt.Conditions, 
    r.rentalPrice
FROM 
    Vehicle_Type vt
JOIN 
    Records r ON vt.Make = r.Make AND vt.Model = r.Model
JOIN 
    Daily_Tariff dt ON r.tariffID = dt.tariffID;