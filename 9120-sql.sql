SET datestyle = 'ISO, DMY';
DROP TABLE IF EXISTS Admission;
DROP TABLE IF EXISTS Administrator;
DROP TABLE IF EXISTS Patient;
DROP TABLE IF EXISTS AdmissionType;
DROP TABLE IF EXISTS Department;
-- DROP TABLE IF EXISTS Admission;

CREATE TABLE Administrator (
    UserName VARCHAR(10) PRIMARY KEY,
    Password VARCHAR(20) NOT NULL,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(20) NOT NULL
);

INSERT INTO Administrator VALUES
('jdoe', 'Pass1234', 'John', 'Doe', 'jdoe@csh.com'),
('jsmith', 'Pass5678', 'Jane', 'Smith', 'jsmith@csh.com'),
('ajohnson', 'Passabcd', 'Alice', 'Johnson', 'ajohnson@csh.com'),
('bbrown', 'Passwxyz', 'Bob', 'Brown', 'bbrown@csh.com'),
('cdavis', 'Pass9876', 'Charlie', 'Davis', 'cdavis@csh.com'),
('ksmith', 'Pass5566', 'Karen', 'Smith', 'ksmith@csh.com');

CREATE TABLE Patient (
    PatientID VARCHAR(10) PRIMARY KEY,
    Password VARCHAR(20) NOT NULL,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Mobile VARCHAR(20) NOT NULL
);

INSERT INTO Patient VALUES
('dwilson', 'Pass5432', 'David', 'Wilson', '4455667788'),
('etylor', 'Passlmno', 'Eva', 'Taylor', '5566778899'),
('faderson', 'Passrstu', 'Frank', 'Anderson', '6677889900'),
('gthomas', 'Pass1357', 'Grace', 'Thomas', '7788990011'),
('smartinez', 'Pass2468', 'Stan', 'Martinez', '8899001122'),
('lroberts', 'Pass1122', 'Laura', 'Roberts', '9900112233');


CREATE TABLE AdmissionType (
    AdmissionTypeID SERIAL PRIMARY KEY,
    AdmissionTypeName VARCHAR(20) UNIQUE NOT NULL
);

INSERT INTO AdmissionType VALUES (1, 'Emergency');
INSERT INTO AdmissionType VALUES (2, 'Transfer');
INSERT INTO AdmissionType VALUES (3, 'Inpatient');
INSERT INTO AdmissionType VALUES (4, 'Outpatient');

CREATE TABLE Department (
    DeptId SERIAL PRIMARY Key,
    DeptName VARCHAR(20) UNIQUE not NULL
);

INSERT INTO Department VALUES (1, 'General');
INSERT INTO Department VALUES (2, 'Emergency');
INSERT INTO Department VALUES (3, 'Surgery');
INSERT INTO Department VALUES (4, 'Obstetrics');
INSERT INTO Department VALUES (5, 'Rehabilitation');
INSERT INTO Department VALUES (6, 'Paediatrics');

CREATE table Admission (
    AdmissionID SERIAL PRIMARY KEY,
    AdmissionType INTEGER NOT NULL,
    Department INTEGER NOT NULL,
	Patient VARCHAR(10) NOT NULL,
	Administrator VARCHAR(10) NOT NULL,
    Fee Decimal(7,2),
    DischargeDate Date,
    Condition VARCHAR(500),
	FOREIGN KEY(AdmissionType) REFERENCES AdmissionType,
	FOREIGN KEY(Department) REFERENCES Department,
	FOREIGN KEY(Patient) REFERENCES Patient,
	FOREIGN KEY(Administrator) REFERENCES Administrator
);

INSERT INTO Admission (AdmissionType, Department, Fee, Patient, Administrator, DischargeDate, Condition) VALUES
    (4, 1, 666.00, 'lroberts', 'jdoe', '28/02/2024', 'a red patch on my skin that looks irritated. It started small but has been spreading and feels warm to the touch'),
	(2, 1, 100.00, 'gthomas', 'jdoe', '11/09/2021', NULL),
	(1, 2, NULL, 'lroberts','jsmith', '02/09/2019', 'Admitted to the emergency department after suffering head trauma from a fall, requiring a CT scan and observation for potential concussion.'),
	(2, 3, 7688.00, 'dwilson','ajohnson', '01/12/2022', NULL),
	(2, 6, 1600.00, 'faderson', 'ajohnson', '03/09/2014', 'Child admitted to the hospital with a severe asthma attack, requiring oxygen therapy and nebulizer treatment.'),
	(4, 1, 90.00, 'gthomas', 'ksmith', '04/07/2021', 'Routine follow-up consultation to review progress after recent knee surgery, with positive recovery observed.'),
	(1, 2, 1450.00, 'smartinez', 'jsmith', NULL, 'Admitted to the emergency department with severe food poisoning, requiring IV fluids and anti-nausea medication for recovery.'),
	(4, 5, 180.95, 'dwilson', 'cdavis', '06/11/2021', 'Attended a physiotherapy session as part of an ongoing rehabilitation program following shoulder surgery.'),
	(3, 1, 2000.00, 'etylor', 'ajohnson', '10/09/2021', NULL),
	(2, 4, 8290.00, 'gthomas', 'jsmith', '01/09/2024', 'Postpartum care following a natural childbirth, including monitoring of both the mother and the newborn for potential complications.'),
	(2, 6, 1800.00, 'faderson', 'bbrown',  NULL, 'Child admitted to the paediatrics department for severe pneumonia, requiring intravenous antibiotics and respiratory therapy.'),
	(4, 1, 75.00, 'gthomas', 'bbrown', '19/11/2023', 'Routine general practitioner consultation for a follow-up after a recent bout of seasonal allergies.'),
	(3, 3, 7000.50, 'smartinez', 'jdoe', '15/10/2024', NULL),
	(1, 2, NULL, 'etylor', 'jdoe', NULL, 'I am having intense, crushing pain in my chest that feels like an elephant is sitting on it. It is spreading to my left arm and neck.');



DROP FUNCTION IF EXISTS check_login;
CREATE OR REPLACE FUNCTION check_login(check_username VARCHAR, check_password VARCHAR)
RETURNS TABLE (username VARCHAR, firstName VARCHAR, lastName VARCHAR, email VARCHAR) as $$
BEGIN
    RETURN QUERY
    SELECT a.UserName, a.FirstName, a.LastName, a.Email
    FROM Administrator as a
    WHERE LOWER(a.UserName) = LOWER(check_username) AND a.Password = check_password;
END;
$$ LANGUAGE plpgsql;


DROP FUNCTION IF EXISTS find_Admissions_By_Admin;
CREATE OR REPLACE FUNCTION find_Admissions_By_Admin(login VARCHAR)
RETURNS TABLE (AdmissionID INTEGER, AdmissionTypeName VARCHAR, DeptName VARCHAR,
dischargeDate TEXT, Fee Decimal, full_name TEXT, Condition VARCHAR) as $$
BEGIN
    RETURN QUERY
    select a.AdmissionID, at.AdmissionTypeName, d.DeptName, TO_CHAR(a.DischargeDate, 'DD-MM-YYYY') as dischargeDate, a.Fee,
            concat(p.FirstName, ' ', p.LastName) as full_name, a.Condition
	from Admission as a
	join AdmissionType as at on a.AdmissionType = at.AdmissionTypeID
	join Department as d on a.Department=d.DeptID
	join Patient as p on p.PatientID = a.Patient
	where Administrator = login
	order by case when a.DischargeDate is null then 1 else 0 end, a.DischargeDate desc,
	a.Patient, at.AdmissionTypeName desc;
END;
$$ LANGUAGE plpgsql;


DROP FUNCTION IF EXISTS find_admissions_by_criteria;
CREATE OR REPLACE FUNCTION find_admissions_by_criteria(search_string TEXT)
RETURNS TABLE (AdmissionID INTEGER, AdmissionTypeName VARCHAR, DeptName VARCHAR, dischargeDate TEXT, Fee DECIMAL, patient_name TEXT, Condition VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT a.AdmissionID, at.AdmissionTypeName, d.DeptName, TO_CHAR(a.DischargeDate, 'DD-MM-YYYY') as dischargeDate, a.Fee,
           CONCAT(p.FirstName, ' ', p.LastName) as patient_name, a.Condition
    FROM Admission AS a
    JOIN AdmissionType AS at ON a.AdmissionType = at.AdmissionTypeID
    JOIN Department AS d ON a.Department = d.DeptID
    JOIN Patient AS p ON a.Patient = p.PatientID
    WHERE (LOWER(at.AdmissionTypeName) LIKE ('%' || LOWER(search_string) || '%')
           OR LOWER(d.DeptName) LIKE ('%' || LOWER(search_string) || '%')
           OR LOWER(CONCAT(p.FirstName, ' ', p.LastName)) LIKE ('%' || LOWER(search_string) || '%')
           OR LOWER(a.Condition) LIKE ('%' || LOWER(search_string) || '%'))
    AND (a.DischargeDate > NOW() - INTERVAL '2 years' OR a.DischargeDate IS NULL)
    ORDER BY CASE WHEN a.DischargeDate IS NULL THEN 0 ELSE 1 END, a.DischargeDate ASC, patient_name ASC;
END;
$$ LANGUAGE plpgsql;


DROP FUNCTION IF EXISTS add_admission;

CREATE OR REPLACE FUNCTION add_admission(
    type VARCHAR,
    department_name VARCHAR,
    patient_id VARCHAR,
    condition VARCHAR,
    admin_username VARCHAR
) RETURNS VOID AS $$
DECLARE
    v_admission_type_id INTEGER;
    v_department_id INTEGER;
    v_patient_id VARCHAR;
BEGIN
    -- 获取 AdmissionTypeID
    SELECT AdmissionTypeID INTO v_admission_type_id
    FROM AdmissionType
    WHERE LOWER(AdmissionTypeName) = LOWER(type);

    IF v_admission_type_id IS NULL THEN
        RAISE EXCEPTION 'Admission type does not exist: %', type;
    END IF;

    SELECT DeptID INTO v_department_id
    FROM Department
    WHERE LOWER(DeptName) = LOWER(department_name);

    IF v_department_id IS NULL THEN
        RAISE EXCEPTION 'Department does not exist: %', department_name;
    END IF;

	select PatientID into v_patient_id
	from Patient
	where LOWER(PatientID) = LOWER(patient_id);

    IF v_patient_id IS NULL THEN
        RAISE EXCEPTION 'Patient does not exist: %', patient_id;
    END IF;


    INSERT INTO Admission (AdmissionType, Department, Patient, Condition, Administrator)
    VALUES (v_admission_type_id, v_department_id, v_patient_id, condition, admin_username);
END;
$$ LANGUAGE plpgsql;


DROP FUNCTION IF EXISTS update_admission;


CREATE OR REPLACE FUNCTION update_admission(
    new_admission_id INTEGER,
    new_admission_type_name VARCHAR,
    new_department_name VARCHAR,
    new_discharge_date DATE,
    new_fee DECIMAL,
    new_patient_id VARCHAR(10),
    new_condition VARCHAR(500)
) RETURNS VOID AS $$
DECLARE
    v_admission_type_id INTEGER;
    v_department_id INTEGER;
    v_patient_id VARCHAR;
BEGIN

    SELECT AdmissionTypeID INTO v_admission_type_id
    FROM AdmissionType
    WHERE LOWER(AdmissionTypeName) = LOWER(new_admission_type_name);

    IF v_admission_type_id IS NULL THEN
        RAISE EXCEPTION 'Admission type does not exist: %', new_admission_type_name;
    END IF;

    SELECT DeptId INTO v_department_id
    FROM Department
    WHERE LOWER(DeptName) = LOWER(new_department_name);

    IF v_department_id IS NULL THEN
        RAISE EXCEPTION 'Department does not exist: %', new_department_name;
    END IF;

    SELECT PatientID INTO v_patient_id
    FROM Patient
    WHERE LOWER(PatientID) = LOWER(new_patient_id);

    IF v_patient_id IS NULL THEN
        RAISE EXCEPTION 'Patient does not exist: %', new_patient_id;
    END IF;

    IF new_fee < 0 THEN
        RAISE EXCEPTION 'Fee cannot be negative: %', new_fee;
    END IF;

    UPDATE Admission
    SET AdmissionType = v_admission_type_id,
        Department = v_department_id,
        DischargeDate = CASE WHEN new_discharge_date IS NULL THEN NULL ELSE new_discharge_date END,
        Fee = CASE WHEN new_fee IS NULL THEN NULL ELSE new_fee END,
        Patient = v_patient_id, 
        Condition = CASE WHEN new_condition IS NULL THEN NULL ELSE new_condition END
    WHERE AdmissionID = new_admission_id;

END;
$$ LANGUAGE plpgsql;
