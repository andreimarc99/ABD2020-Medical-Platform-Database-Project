use ProiectDB;
GO

CREATE TABLE USERS (
	USER_ID INT NOT NULL IDENTITY(1,1),
	USERNAME VARCHAR(99) NOT NULL,
	USER_PASSWORD VARCHAR(99) NOT NULL, 
	FIRST_NAME VARCHAR(99) NOT NULL, 
	LAST_NAME VARCHAR(99) NOT NULL, 
	BIRTH_DATE DATE, 
	USER_ROLE VARCHAR(99) NOT NULL,
	PRIMARY KEY (USER_ID)
);

ALTER TABLE USERS ADD CONSTRAINT C1 CHECK (USER_ROLE = 'DOCTOR' OR USER_ROLE = 'PATIENT' OR USER_ROLE = 'CAREGIVER');
ALTER TABLE USERS ADD CONSTRAINT C2 UNIQUE (USERNAME);
ALTER TABLE USERS ADD CONSTRAINT C3 UNIQUE (USER_ID);

CREATE TABLE DOCTOR (
	ID INT NOT NULL,
	SPECIALIZATION VARCHAR(99) NOT NULL, 
	SALARY INT NOT NULL,
	FOREIGN KEY (ID) REFERENCES USERS (USER_ID),
	PRIMARY KEY (ID)
);

CREATE TABLE CAREGIVER (
	ID INT NOT NULL, 
	SALARY INT NOT NULL,
	FOREIGN KEY (ID) REFERENCES USERS (USER_ID),
	PRIMARY KEY (ID)
);

CREATE TABLE PATIENT (
	ID INT NOT NULL,
	CAREGIVER_ID INT, 
	FOREIGN KEY (ID) REFERENCES USERS (USER_ID),
	FOREIGN KEY (CAREGIVER_ID) REFERENCES CAREGIVER (ID),
	PRIMARY KEY (ID)
);

ALTER TABLE dbo.PATIENT ADD DIAGNOSE VARCHAR(99);

CREATE TABLE MEDICINE (
	ID INT NOT NULL IDENTITY(1,1),
	MED_NAME VARCHAR(99) NOT NULL,
	DOSAGE INT NOT NULL,
	PRIMARY KEY (ID)
);

ALTER TABLE MEDICINE ADD CONSTRAINT C4 UNIQUE (ID);

CREATE TABLE SIDE_EFFECT (
	ID INT NOT NULL IDENTITY(1,1),
	SIDE_EFF_NAME VARCHAR(99) NOT NULL,
	PRIMARY KEY (ID)
);

ALTER TABLE SIDE_EFFECT ADD CONSTRAINT C5 UNIQUE (ID);

CREATE TABLE MEDINCINE_SIDE_EFFECT (
	MEDICINE_ID INT NOT NULL,
	SIDE_EFFECT_ID INT NOT NULL,
	FOREIGN KEY (MEDICINE_ID) REFERENCES MEDICINE (ID),
	FOREIGN KEY (SIDE_EFFECT_ID) REFERENCES SIDE_EFFECT (ID)
);

CREATE TABLE PRESCRIPTION (
	ID INT NOT NULL IDENTITY(1,1),
	DOCTOR_ID INT NOT NULL,
	PATIENT_ID INT NOT NULL,
	PRIMARY KEY (ID),
	FOREIGN KEY (DOCTOR_ID) REFERENCES DOCTOR (ID),
	FOREIGN KEY (PATIENT_ID) REFERENCES PATIENT (ID)
);
ALTER TABLE PRESCRIPTION ADD PRESCRIPTION_START_DATE DATE NOT NULL;
ALTER TABLE PRESCRIPTION ADD PRESCRIPTION_END_DATE DATE NOT NULL;
ALTER TABLE PRESCRIPTION ADD CONSTRAINT C6 UNIQUE (ID);
ALTER TABLE PRESCRIPTION ADD CONSTRAINT C7 CHECK (DATEDIFF(s, PRESCRIPTION_START_DATE, PRESCRIPTION_END_DATE) > 0);

CREATE TABLE PRESCRIPTION_MEDICINE (
	PRESCRIPTION_ID INT NOT NULL,
	MEDICINE_ID INT NOT NULL,
	FOREIGN KEY (PRESCRIPTION_ID) REFERENCES PRESCRIPTION (ID),
	FOREIGN KEY (MEDICINE_ID) REFERENCES MEDICINE (ID)
);

INSERT INTO USERS(USERNAME, USER_PASSWORD, USER_ROLE, FIRST_NAME, LAST_NAME, BIRTH_DATE) VALUES ('caregiver', 'caregiver', 'CAREGIVER', 'Caregiver', 'Unu', '1980-10-10');
INSERT INTO CAREGIVER(ID, SALARY) VALUES (1, 3000);

INSERT INTO USERS(USERNAME, USER_PASSWORD, USER_ROLE, FIRST_NAME, LAST_NAME, BIRTH_DATE) VALUES ('pacient', 'pacient', 'PATIENT', 'Pacient', 'Unu', '1990-10-10');
INSERT INTO PATIENT(ID, CAREGIVER_ID, DIAGNOSE) VALUES (2, 1, 'Cardiac');
INSERT INTO USERS(USERNAME, USER_PASSWORD, USER_ROLE, FIRST_NAME, LAST_NAME, BIRTH_DATE) VALUES ('pacient2', 'pacient2', 'PATIENT', 'Pacient', 'Doi', '1992-10-20');
INSERT INTO PATIENT(ID, CAREGIVER_ID, DIAGNOSE) VALUES (5, 1, 'Diabet');

INSERT INTO USERS(USERNAME, USER_PASSWORD, USER_ROLE, FIRST_NAME, LAST_NAME, BIRTH_DATE) VALUES ('doctor', 'doctor', 'DOCTOR', 'Doctor', 'Unu', '1967-04-24');
INSERT INTO DOCTOR(ID, SALARY, SPECIALIZATION) VALUES(3, 10000, 'Cardiologie');

INSERT INTO MEDICINE(DOSAGE, MED_NAME) VALUES (3, 'Parasinus');
INSERT INTO MEDICINE(DOSAGE, MED_NAME) VALUES (3, 'Faringosept');
INSERT INTO MEDICINE(DOSAGE, MED_NAME) VALUES (1, 'Xanax');

INSERT INTO SIDE_EFFECT(SIDE_EFF_NAME) VALUES ('Stomach ache');
INSERT INTO SIDE_EFFECT(SIDE_EFF_NAME) VALUES ('Nausea');
INSERT INTO SIDE_EFFECT(SIDE_EFF_NAME) VALUES ('Addiction');
INSERT INTO SIDE_EFFECT(SIDE_EFF_NAME) VALUES ('No known side effects');

INSERT INTO MEDINCINE_SIDE_EFFECT(MEDICINE_ID, SIDE_EFFECT_ID) VALUES (1, 1);
INSERT INTO MEDINCINE_SIDE_EFFECT(MEDICINE_ID, SIDE_EFFECT_ID) VALUES (3, 2);
INSERT INTO MEDINCINE_SIDE_EFFECT(MEDICINE_ID, SIDE_EFFECT_ID) VALUES (3, 3);
INSERT INTO MEDINCINE_SIDE_EFFECT(MEDICINE_ID, SIDE_EFFECT_ID) VALUES (2, 4);

INSERT INTO PRESCRIPTION(PATIENT_ID, DOCTOR_ID, PRESCRIPTION_START_DATE, PRESCRIPTION_END_DATE) VALUES (2, 3, '2020-01-04', '2020-09-12');
INSERT INTO PRESCRIPTION(PATIENT_ID, DOCTOR_ID, PRESCRIPTION_START_DATE, PRESCRIPTION_END_DATE) VALUES (2, 3, '2020-01-02', '2020-01-03');
INSERT INTO PRESCRIPTION(PATIENT_ID, DOCTOR_ID, PRESCRIPTION_START_DATE, PRESCRIPTION_END_DATE) VALUES (5, 3, '2020-01-03', '2020-01-13');

INSERT INTO PRESCRIPTION_MEDICINE(MEDICINE_ID, PRESCRIPTION_ID) VALUES (1, 1);
INSERT INTO PRESCRIPTION_MEDICINE(MEDICINE_ID, PRESCRIPTION_ID) VALUES (2, 1);
INSERT INTO PRESCRIPTION_MEDICINE(MEDICINE_ID, PRESCRIPTION_ID) VALUES (2, 2);
INSERT INTO PRESCRIPTION_MEDICINE(MEDICINE_ID, PRESCRIPTION_ID) VALUES (2, 3);
INSERT INTO PRESCRIPTION_MEDICINE(MEDICINE_ID, PRESCRIPTION_ID) VALUES (1, 3);

--------------------------------------------------------------------------------------------------
-- VIEWS
--------------------------------------------------------------------------------------------------
GO
CREATE VIEW V_PACIENTI_CAREGIVERI AS
SELECT DISTINCT U.FIRST_NAME AS PRENUME_PACIENT, U.LAST_NAME AS NUME_PACIENT, U.BIRTH_DATE AS ZI_NASTERE_PACIENT, U1.FIRST_NAME AS NUME_CAREGIVER, U1.LAST_NAME AS PRENUME_CAREGIVER 
FROM (PATIENT P INNER JOIN USERS U ON P.ID = U.USER_ID INNER JOIN USERS U1 ON P.CAREGIVER_ID = U1.USER_ID)
GROUP BY U.FIRST_NAME, U.LAST_NAME, U.BIRTH_DATE, U1.FIRST_NAME, U1.LAST_NAME;

GO
SELECT * FROM V_PACIENTI_CAREGIVERI;

GO
CREATE VIEW V_CAREGIVERI_OCUPATI AS
SELECT DISTINCT U.FIRST_NAME AS PRENUME, U.LAST_NAME AS NUME, COUNT(P.CAREGIVER_ID) AS NR_PACIENTI
FROM (CAREGIVER C INNER JOIN USERS U ON C.ID = U.USER_ID INNER JOIN PATIENT P ON P.CAREGIVER_ID = C.ID)
GROUP BY U.FIRST_NAME, U.LAST_NAME
HAVING COUNT(P.CAREGIVER_ID) >= 1;

GO 
SELECT * FROM V_CAREGIVERI_OCUPATI;

GO
CREATE VIEW V_PACIENTI_CARDIACI AS
SELECT DISTINCT U.FIRST_NAME AS PRENUME, U.LAST_NAME AS NUME, U.BIRTH_DATE AS ZI_NASTERE, P.DIAGNOSE AS DIAGNOSTIC
FROM (PATIENT P INNER JOIN USERS U ON P.ID = U.USER_ID)
GROUP BY U.FIRST_NAME, U.LAST_NAME, U.BIRTH_DATE, P.DIAGNOSE
HAVING P.DIAGNOSE = 'Cardiac';

GO 
SELECT * FROM V_PACIENTI_CARDIACI;

GO
CREATE VIEW V_TRATAMENTE_INDELUNGATE AS
SELECT DISTINCT P.ID AS NR_PRESCRIPTIE, U.FIRST_NAME AS PRENUME_DOCTOR, U.LAST_NAME AS NUME_DOCTOR, U1.FIRST_NAME AS PRENUME_PACIENT, U1.LAST_NAME AS NUME_PACIENT, M.MED_NAME AS MEDICAMENT,
P.PRESCRIPTION_START_DATE AS DATA_INCEPUT_TRATAMENT, P.PRESCRIPTION_END_DATE AS DATA_SFARSIT_TRATAMENT
FROM (PRESCRIPTION P INNER JOIN PATIENT P1 ON P.PATIENT_ID = P1.ID INNER JOIN USERS U ON P1.ID = U.USER_ID INNER JOIN DOCTOR D ON P.DOCTOR_ID = D.ID INNER JOIN USERS U1 ON U1.USER_ID = D.ID 
INNER JOIN PRESCRIPTION_MEDICINE PM ON PM.PRESCRIPTION_ID = P.ID INNER JOIN MEDICINE M ON M.ID = PM.MEDICINE_ID)
GROUP BY P.ID, U.FIRST_NAME, U.LAST_NAME, U1.FIRST_NAME, U1.LAST_NAME, M.MED_NAME, P.PRESCRIPTION_START_DATE, P.PRESCRIPTION_END_DATE
HAVING DATEDIFF(day, P.PRESCRIPTION_START_DATE, P.PRESCRIPTION_END_DATE) >= 7;

GO
SELECT * FROM V_TRATAMENTE_INDELUNGATE;

GO
CREATE VIEW V_PACIENTI_CU_PRESCRIPTII AS
SELECT DISTINCT U.USER_ID, U.FIRST_NAME AS PRENUME_PACIENT, U.LAST_NAME AS NUME_PACIENT, U1.FIRST_NAME AS PRENUME_DOCTOR, U1.LAST_NAME AS NUME_DOCTOR, 
(SELECT COUNT(*) FROM PRESCRIPTION P1 WHERE P1.PATIENT_ID = U.USER_ID) AS NR_PRESCRIPTII
FROM (PATIENT P INNER JOIN USERS U ON U.USER_ID = P.ID INNER JOIN PRESCRIPTION P1 ON P1.PATIENT_ID = P.ID INNER JOIN DOCTOR D ON P1.DOCTOR_ID = D.ID INNER JOIN USERS U1 ON U1.USER_ID = D.ID)
GROUP BY U.USER_ID, U.FIRST_NAME, U.LAST_NAME, U1.FIRST_NAME, U1.LAST_NAME

GO
SELECT * FROM V_PACIENTI_CU_PRESCRIPTII;

GO
CREATE VIEW V_PRESCRIPTII_SI_NR_MEDICAMENTE AS
SELECT DISTINCT PR.ID AS NR_PRESCRIPTIE, P.FIRST_NAME AS PRENUME_PACIENT, P.LAST_NAME AS NUME_PACIENT, D.FIRST_NAME AS PRENUME_DOCTOR, D.LAST_NAME AS NUME_DOCTOR,
(SELECT COUNT(PM.MEDICINE_ID) FROM PRESCRIPTION_MEDICINE PM WHERE PM.PRESCRIPTION_ID = PR.ID) AS NR_MEDICAMENTE
FROM PRESCRIPTION PR INNER JOIN USERS P ON PR.PATIENT_ID = P.USER_ID INNER JOIN USERS D ON PR.DOCTOR_ID = D.USER_ID
GROUP BY PR.ID, P.FIRST_NAME, P.LAST_NAME, D.FIRST_NAME, D.LAST_NAME;

GO 
SELECT * FROM V_PRESCRIPTII_SI_NR_MEDICAMENTE;

--------------------------------------------------------------------------------------------------
-- USERS & PERMISSIONS
--------------------------------------------------------------------------------------------------

CREATE LOGIN DOCTOR_LOGIN WITH PASSWORD = 'doctor';
CREATE USER DOCTOR_USER FOR LOGIN DOCTOR_LOGIN;

CREATE LOGIN CAREGIVER_LOGIN WITH PASSWORD = 'caregiver';
CREATE USER CAREGIVER_USER FOR LOGIN CAREGIVER_LOGIN;

CREATE LOGIN PATIENT_LOGIN WITH PASSWORD = 'patient';
CREATE USER PATIENT_USER FOR LOGIN PATIENT_LOGIN;

GRANT SELECT, INSERT, UPDATE, DELETE ON PRESCRIPTION TO DOCTOR_USER;
GRANT SELECT, INSERT, UPDATE, DELETE ON MEDICINE TO DOCTOR_USER;
GRANT SELECT, INSERT, UPDATE, DELETE ON PRESCRIPTION_MEDICINE TO DOCTOR_USER;
GRANT SELECT, INSERT, UPDATE, DELETE ON SIDE_EFFECT TO DOCTOR_USER;
GRANT SELECT, INSERT, UPDATE, DELETE ON MEDINCINE_SIDE_EFFECT TO DOCTOR_USER;
GRANT SELECT, INSERT, UPDATE, DELETE ON PATIENT TO DOCTOR_USER;
GRANT SELECT, INSERT, UPDATE, DELETE ON CAREGIVER TO DOCTOR_USER;
GRANT SELECT, INSERT, UPDATE, DELETE ON USERS TO DOCTOR_USER;

GRANT SELECT, INSERT, UPDATE, DELETE ON PATIENT TO CAREGIVER_USER;

--------------------------------------------------------------------------------------------------
-- CRUD STORED PROCEDURES
--------------------------------------------------------------------------------------------------

-- USER CRUD PROCEDURES
-- INSERT USER
GO
CREATE PROCEDURE INSERT_USER (@USERNAME VARCHAR(99),
	@USER_PASSWORD VARCHAR(99), 
	@FIRST_NAME VARCHAR(99), 
	@LAST_NAME VARCHAR(99), 
	@BIRTH_DATE DATE, 
	@USER_ROLE VARCHAR(99))
AS 
BEGIN
	INSERT INTO USERS (USERNAME, USER_PASSWORD, FIRST_NAME, LAST_NAME, BIRTH_DATE, USER_ROLE)
	VALUES (@USERNAME, @USER_PASSWORD, @FIRST_NAME, @LAST_NAME, @BIRTH_DATE, @USER_ROLE)
END;

-- UPDATE USER
GO
CREATE PROCEDURE UPDATE_USER (@USERNAME VARCHAR(99),
	@USER_PASSWORD VARCHAR(99), 
	@FIRST_NAME VARCHAR(99), 
	@LAST_NAME VARCHAR(99), 
	@BIRTH_DATE DATE, 
	@USER_ROLE VARCHAR(99))
AS 
BEGIN
	UPDATE USERS SET USER_PASSWORD = @USER_PASSWORD, FIRST_NAME = @FIRST_NAME, LAST_NAME = @LAST_NAME, BIRTH_DATE = @BIRTH_DATE, USER_ROLE = @USER_ROLE
	WHERE USERNAME = @USERNAME;
END;

-- DELETE USER
GO
CREATE PROCEDURE DELETE_USER (@USERNAME VARCHAR(99))
AS
BEGIN
	DELETE FROM USERS WHERE USERNAME = @USERNAME
END;

-- VIEW USER BY USERNAME
GO
CREATE PROCEDURE FIND_USER_BY_USERNAME (@USERNAME VARCHAR(99))
AS
BEGIN
	IF NOT EXISTS (SELECT * FROM USERS WHERE USERNAME = @USERNAME) 
		PRINT 'User does not exist'
	ELSE 
		SELECT * FROM USERS WHERE USERNAME = @USERNAME
END;

-- PATIENT CRUD PROCEDURES
-- INSERT USER
GO
CREATE PROCEDURE INSERT_PATIENT (@ID INT,
	@CAREGIVER_ID INT,
	@DIAGNOSE INT)
AS 
BEGIN
	IF NOT EXISTS (SELECT * FROM CAREGIVER WHERE ID = @CAREGIVER_ID)
		PRINT 'Caregiver does not exist'
	ELSE IF NOT EXISTS (SELECT * FROM USERS WHERE USER_ID = @ID)
		PRINT 'Referenced user does not exist'
	ELSE
		INSERT INTO PATIENT (ID, CAREGIVER_ID, DIAGNOSE) VALUES (@ID, @CAREGIVER_ID, @DIAGNOSE)
END;

-- UPDATE PATIENT
GO
CREATE PROCEDURE UPDATE_PATIENT_INFORMATION (@ID INT,
	@USER_PASSWORD VARCHAR(99), 
	@FIRST_NAME VARCHAR(99), 
	@LAST_NAME VARCHAR(99), 
	@BIRTH_DATE DATE, 
	@USER_ROLE VARCHAR(99))
AS 
BEGIN
	UPDATE USERS SET USER_PASSWORD = @USER_PASSWORD, FIRST_NAME = @FIRST_NAME, LAST_NAME = @LAST_NAME, BIRTH_DATE = @BIRTH_DATE, USER_ROLE = @USER_ROLE WHERE USER_ID = @ID;
END;

GO
CREATE PROCEDURE UPDATE_PATIENTS_CAREGIVER (@ID INT,
	@CAREGIVER_ID INT,
	@DIAGNOSE INT)
AS
BEGIN
	UPDATE PATIENT SET CAREGIVER_ID = @CAREGIVER_ID, DIAGNOSE = @DIAGNOSE WHERE ID = @ID;
END;

-- DELETE PATIENT
GO
CREATE PROCEDURE DELETE_PATIENT (@ID INT)
AS
BEGIN
	DELETE FROM PATIENT WHERE ID = @ID
END;

-- VIEW PATIENT BY ID / USERNAME
GO
CREATE PROCEDURE FIND_PATIENT_BY_ID (@ID INT)
AS
BEGIN
	IF NOT EXISTS (SELECT * FROM PATIENT WHERE ID = @ID) 
		PRINT 'User does not exist'
	ELSE 
		SELECT * FROM PATIENT WHERE ID = @ID
END;

GO
CREATE PROCEDURE FIND_PATIENT_BY_USERNAME (@USERNAME VARCHAR(99))
AS
BEGIN
	IF NOT EXISTS (SELECT * FROM PATIENT P JOIN USERS U ON U.USER_ID = P.ID WHERE U.USERNAME = @USERNAME) 
		PRINT 'User does not exist'
	ELSE
		SELECT * FROM PATIENT P JOIN USERS U ON U.USER_ID = P.ID WHERE U.USERNAME = @USERNAME
END;

-- CAREGIVER CRUD PROCEDURES
-- INSERT USER
GO
CREATE PROCEDURE INSERT_CAREGIVER (@ID INT,
	@SALARY INT)
AS 
BEGIN
	IF NOT EXISTS (SELECT * FROM USERS WHERE USER_ID = @ID)
		PRINT 'Referenced user does not exist'
	ELSE
		INSERT INTO CAREGIVER (ID, SALARY) VALUES (@ID, @SALARY)
END;

-- UPDATE CAREGIVER
GO
CREATE PROCEDURE UPDATE_CAREGIVER_INFORMATION (@ID INT,
	@USER_PASSWORD VARCHAR(99), 
	@FIRST_NAME VARCHAR(99), 
	@LAST_NAME VARCHAR(99), 
	@BIRTH_DATE DATE, 
	@USER_ROLE VARCHAR(99))
AS 
BEGIN
	UPDATE USERS SET USER_PASSWORD = @USER_PASSWORD, FIRST_NAME = @FIRST_NAME, LAST_NAME = @LAST_NAME, BIRTH_DATE = @BIRTH_DATE, USER_ROLE = @USER_ROLE WHERE USER_ID = @ID;
END;

GO
CREATE PROCEDURE UPDATE_CAREGIVER (@ID INT,
	@SALARY INT)
AS
BEGIN
	UPDATE CAREGIVER SET SALARY = @SALARY WHERE ID = @ID;
END;

-- DELETE CAREGIVER
GO
CREATE PROCEDURE DELETE_CAREGIVER (@ID INT)
AS
BEGIN
	DELETE FROM CAREGIVER WHERE ID = @ID
END;

-- VIEW CAREGIVER BY ID / USERNAME
GO
CREATE PROCEDURE FIND_CAREGIVER_BY_ID (@ID INT)
AS
BEGIN
	IF NOT EXISTS (SELECT * FROM CAREGIVER WHERE ID = @ID) 
		PRINT 'User does not exist'
	ELSE 
		SELECT * FROM CAREGIVER WHERE ID = @ID
END;

GO
CREATE PROCEDURE FIND_CAREGIVER_BY_USERNAME (@USERNAME VARCHAR(99))
AS
BEGIN
	IF NOT EXISTS (SELECT * FROM CAREGIVER P JOIN USERS U ON U.USER_ID = P.ID WHERE U.USERNAME = @USERNAME) 
		PRINT 'User does not exist'
	ELSE
		SELECT * FROM CAREGIVER P JOIN USERS U ON U.USER_ID = P.ID WHERE U.USERNAME = @USERNAME
END;

-- DOCTOR CRUD PROCEDURES
-- INSERT DOCTOR
GO
CREATE PROCEDURE INSERT_DOCTOR (@ID INT,
	@SALARY INT,
	@SPECIALIZATION INT)
AS 
BEGIN
	IF NOT EXISTS (SELECT * FROM USERS WHERE USER_ID = @ID)
		PRINT 'Referenced user does not exist'
	ELSE
		INSERT INTO DOCTOR (ID, SALARY, SPECIALIZATION) VALUES (@ID, @SALARY, @SPECIALIZATION)
END;

-- UPDATE DOCTOR
GO
CREATE PROCEDURE UPDATE_DOCTOR_INFORMATION (@ID INT,
	@USER_PASSWORD VARCHAR(99), 
	@FIRST_NAME VARCHAR(99), 
	@LAST_NAME VARCHAR(99), 
	@BIRTH_DATE DATE, 
	@USER_ROLE VARCHAR(99))
AS 
BEGIN
	UPDATE USERS SET USER_PASSWORD = @USER_PASSWORD, FIRST_NAME = @FIRST_NAME, LAST_NAME = @LAST_NAME, BIRTH_DATE = @BIRTH_DATE, USER_ROLE = @USER_ROLE WHERE USER_ID = @ID;
END;

GO
CREATE PROCEDURE UPDATE_DOCTOR (@ID INT,
	@SALARY INT,
	@SPECIALIZATION INT)
AS
BEGIN
	UPDATE DOCTOR SET SALARY = @SALARY, SPECIALIZATION = @SPECIALIZATION WHERE ID = @ID;
END;

-- DELETE DOCTOR
GO
CREATE PROCEDURE DELETE_DOCTOR (@ID INT)
AS
BEGIN
	DELETE FROM DOCTOR WHERE ID = @ID
END;

-- VIEW DOCTOR BY ID / USERNAME
GO
CREATE PROCEDURE FIND_DOCTOR_BY_ID (@ID INT)
AS
BEGIN
	IF NOT EXISTS (SELECT * FROM DOCTOR WHERE ID = @ID) 
		PRINT 'User does not exist'
	ELSE 
		SELECT * FROM DOCTOR WHERE ID = @ID
END;

GO
CREATE PROCEDURE FIND_DOCTOR_BY_USERNAME (@USERNAME VARCHAR(99))
AS
BEGIN
	IF NOT EXISTS (SELECT * FROM DOCTOR P JOIN USERS U ON U.USER_ID = P.ID WHERE U.USERNAME = @USERNAME) 
		PRINT 'User does not exist'
	ELSE
		SELECT * FROM DOCTOR P JOIN USERS U ON U.USER_ID = P.ID WHERE U.USERNAME = @USERNAME
END;

-- MEDICINE CRUD PROCEDURES
-- INSERT MEDICINE
GO
CREATE PROCEDURE INSERT_MEDICINE (@MED_NAME VARCHAR(99),
	@DOSAGE INT)
AS 
BEGIN
	INSERT INTO MEDICINE (MED_NAME, DOSAGE) VALUES (@MED_NAME, @DOSAGE)
END;


-- UPDATE MEDICINE
GO
CREATE PROCEDURE UPDATE_MEDICINE (@ID INT,
	@MED_NAME VARCHAR(99),
	@DOSAGE INT)
AS
BEGIN
	UPDATE MEDICINE SET MED_NAME = @MED_NAME, DOSAGE = @DOSAGE WHERE ID = @ID;
END;

-- DELETE MEDICINE
GO
CREATE PROCEDURE DELETE_MEDICINE (@ID INT)
AS
BEGIN
	DELETE FROM MEDICINE WHERE ID = @ID
END;

-- VIEW MEDICINE BY ID / MED NAME
GO
CREATE PROCEDURE FIND_MEDICINE_BY_ID (@ID INT)
AS
BEGIN
	IF NOT EXISTS (SELECT * FROM MEDICINE WHERE ID = @ID) 
		PRINT 'Medicine does not exist'
	ELSE 
		SELECT * FROM MEDICINE WHERE ID = @ID
END;

GO
CREATE PROCEDURE FIND_MEDICINE_BY_MED_NAME (@MED_NAME VARCHAR(99))
AS
BEGIN
	IF NOT EXISTS (SELECT * FROM MEDICINE WHERE MED_NAME = @MED_NAME) 
		PRINT 'Medicine does not exist'
	ELSE
		SELECT * FROM MEDICINE WHERE MED_NAME = @MED_NAME
END;

-- PRESCRIPTION CRUD PROCEDURES 
-- INSERT PRESCRIPTION
GO
CREATE PROCEDURE INSERT_PRESCRIPTION (@DOCTOR_ID INT,
	@PATIENT_ID INT,
	@PRESCRIPTION_START_DATE DATE,
	@PRESCRIPTION_END_DATE DATE)
AS 
BEGIN
	INSERT INTO PRESCRIPTION(DOCTOR_ID, PATIENT_ID, PRESCRIPTION_START_DATE, PRESCRIPTION_END_DATE) 
	VALUES (@DOCTOR_ID, @PATIENT_ID, @PRESCRIPTION_START_DATE, @PRESCRIPTION_END_DATE)
END;


-- UPDATE PRESCRIPTION
GO
CREATE PROCEDURE UPDATE_PRESCRIPTION (@ID INT,
	@DOCTOR_ID INT,
	@PATIENT_ID INT,
	@PRESCRIPTION_START_DATE DATE,
	@PRESCRIPTION_END_DATE DATE)
AS
BEGIN
	UPDATE PRESCRIPTION SET DOCTOR_ID = @DOCTOR_ID, PATIENT_ID = @PATIENT_ID, PRESCRIPTION_END_DATE = @PRESCRIPTION_END_DATE, PRESCRIPTION_START_DATE = @PRESCRIPTION_START_DATE WHERE ID = @ID;
END;

-- DELETE PRESCRIPTION
GO
CREATE PROCEDURE DELETE_PRESCRIPTION (@ID INT)
AS
BEGIN
	DELETE FROM PRESCRIPTION WHERE ID = @ID
END;

-- VIEW PRESCRIPTION BY ID
GO
CREATE PROCEDURE FIND_PRESCRIPTION_BY_ID (@ID INT)
AS
BEGIN
	IF NOT EXISTS (SELECT * FROM PRESCRIPTION WHERE ID = @ID) 
		PRINT 'Prescription does not exist'
	ELSE 
		SELECT * FROM PRESCRIPTION WHERE ID = @ID
END;

-- VIEW PRESCRIPTIONS FOR CUSTOM PATIENT
GO
CREATE PROCEDURE FIND_PRESCRIPTION_BY_USER_NAME (@USERNAME VARCHAR(99))
AS
BEGIN
	IF NOT EXISTS (SELECT P.ID, P.DOCTOR_ID, P.PRESCRIPTION_START_DATE, P.PRESCRIPTION_END_DATE, M.MED_NAME FROM PRESCRIPTION P, USERS U, MEDICINE M, PRESCRIPTION_MEDICINE PM
	WHERE U.USER_ID = P.PATIENT_ID AND U.USERNAME = @USERNAME AND M.ID = PM.MEDICINE_ID AND P.ID = PM.PRESCRIPTION_ID) 
		PRINT 'Could not find prescriptions for given user'
	ELSE
		SELECT P.ID, P.DOCTOR_ID, P.PRESCRIPTION_START_DATE, P.PRESCRIPTION_END_DATE, M.MED_NAME FROM PRESCRIPTION P, USERS U, MEDICINE M, PRESCRIPTION_MEDICINE PM
		WHERE U.USER_ID = P.PATIENT_ID AND U.USERNAME = @USERNAME AND M.ID = PM.MEDICINE_ID AND P.ID = PM.PRESCRIPTION_ID
END;


--------------------------------------------------------------------------------------------------
-- INDEXES
--------------------------------------------------------------------------------------------------

CREATE NONCLUSTERED INDEX IX_USERS_USERNAME ON USERS (USERNAME);
CREATE NONCLUSTERED INDEX IX_PRESCRIPTION_PRESCRIPTIONID ON PRESCRIPTION_MEDICINE (PRESCRIPTION_ID);
CREATE NONCLUSTERED INDEX IX_MEDICINE_SIDE_EFFECT_MED_ID ON MEDINCINE_SIDE_EFFECT (MEDICINE_ID);

CREATE CLUSTERED INDEX IX_MEDICINE_SIDE_EFFECT_MED_ASCENDING ON MEDINCINE_SIDE_EFFECT (MEDICINE_ID ASC);
CREATE CLUSTERED INDEX IX_PRESCRIPTION_MEDICINE_PRESCR_ID ON PRESCRIPTION_MEDICINE (PRESCRIPTION_ID ASC);

-- INDECSII CLUSTERED DEJA EXISTA IN TABELELE OBISNUITE, DATORITA CONSTRANGERILOR DE CHEI PRIMARE DIN TABELE

--------------------------------------------------------------------------------------------------
-- TRIGGERS
--------------------------------------------------------------------------------------------------

-------------------------------------- TRIGGERE DML ----------------------------------------------
-- LA STERGEREA UNEI PRESCRIPTII DIN BAZA DE DATE, ACEASTA ESTE TRECUTA INTR-O ARHIVA (UN TABEL NOU DE HISTORY)

CREATE TABLE PRESCRIPTION_ARCHIVE (
	ID INT NOT NULL PRIMARY KEY,
	PATIENT_NAME VARCHAR(99) NOT NULL,
	DOCTOR_ID VARCHAR(99) NOT NULL,
	PRESCRIPTION_START_DATE DATE,
	PRESCRIPTION_END_DATE DATE
);

CREATE TABLE MEDICINE_ARCHIVE (
	ID INT NOT NULL,
	MED_NAME VARCHAR(99) NOT NULL,
	DOSAGE INT NOT NULL,
	PRIMARY KEY (ID)
);

CREATE TABLE PRESCRIPTION_MEDICINE_ARCHIVE (
	PRESCRIPTION_ID INT NOT NULL,
	MEDICINE_ID INT NOT NULL,
	FOREIGN KEY (PRESCRIPTION_ID) REFERENCES PRESCRIPTION_ARCHIVE (ID),
	FOREIGN KEY (MEDICINE_ID) REFERENCES MEDICINE_ARCHIVE (ID)
);

go 
CREATE trigger PRESCRIPTION_ARCHIVING ON PRESCRIPTION FOR DELETE AS 
BEGIN 
INSERT into PRESCRIPTION_ARCHIVE(ID, PATIENT_NAME, DOCTOR_ID, PRESCRIPTION_START_DATE, PRESCRIPTION_END_DATE)
Select P.ID, CONCAT(U1.FIRST_NAME, ' ', U1.LAST_NAME), CONCAT(U2.FIRST_NAME, ' ', U2.LAST_NAME), P.PRESCRIPTION_START_DATE, P.PRESCRIPTION_END_DATE 
From DELETED P JOIN PATIENT PAC ON P.PATIENT_ID = PAC.ID JOIN USERS U1 ON U1.USER_ID = PAC.ID JOIN USERS U2 ON P.DOCTOR_ID = U2.USER_ID; 

INSERT INTO MEDICINE_ARCHIVE(ID, MED_NAME, DOSAGE) 
SELECT M.ID, M.MED_NAME, M.DOSAGE FROM DELETED P JOIN PRESCRIPTION_MEDICINE PM ON PM.PRESCRIPTION_ID = P.ID JOIN MEDICINE M ON M.ID = PM.MEDICINE_ID;

INSERT INTO PRESCRIPTION_MEDICINE_ARCHIVE(PRESCRIPTION_ID, MEDICINE_ID) 
SELECT P.ID, M.ID FROM DELETED P JOIN PRESCRIPTION_MEDICINE PM ON P.ID = PM.PRESCRIPTION_ID JOIN MEDICINE M ON PM.MEDICINE_ID = M.ID;

PRINT 'TRIGGERED PRESCRIPTION ARCHIVING';
END 

-- UN PACIENT NU POATE AVEA MAI MULT DE 3 PRESCRIPTII LA UN MOMENT DAT
GO
CREATE TRIGGER T_SIMULTANEOUS_PRESCRIPTIONS ON PRESCRIPTION AFTER INSERT AS
BEGIN
	IF EXISTS ( SELECT COUNT (P.PATIENT_ID) FROM PRESCRIPTION P GROUP BY P.PATIENT_ID HAVING COUNT(P.PATIENT_ID) > 3)
	BEGIN
		PRINT 'Un pacient poate avea cel mult 3 prescriptii!'
		ROLLBACK TRANSACTION
	END
END

-- PRESCRIPTIILE IN CURS DE DESFASURARE NU POT FI STERSE
GO 
CREATE TRIGGER T_ONGOING_PRESCRIPTIONS ON PRESCRIPTION AFTER DELETE AS
BEGIN
	IF EXISTS (
		SELECT * FROM PRESCRIPTION P 
		WHERE (MONTH(P.PRESCRIPTION_START_DATE) < MONTH(GETDATE()) OR (MONTH(GETDATE()) = MONTH(P.PRESCRIPTION_START_DATE) AND DAY(GETDATE()) >= DAY(P.PRESCRIPTION_START_DATE)))
		AND (MONTH(P.PRESCRIPTION_END_DATE) > MONTH(GETDATE()) OR (MONTH(GETDATE()) = MONTH(P.PRESCRIPTION_END_DATE) AND DAY(GETDATE()) <= DAY(P.PRESCRIPTION_END_DATE)))
	)
	BEGIN
		PRINT 'Prescriptiile in curs de desfasurare nu pot fi sterse!'
		ROLLBACK TRANSACTION
	END
END

-- LA ANGAJAREA UNUI NOU DOCTOR, ACESTA PRIMESTE O MARIRE DE SALARIU DE 10%
GO
CREATE TRIGGER T_NEW_DOCTOR_RAISE ON DOCTOR AFTER INSERT AS
BEGIN
	UPDATE DOCTOR SET SALARY = DOCTOR.SALARY + DOCTOR.SALARY / 10 FROM INSERTED I WHERE DOCTOR.ID = I.ID;
	PRINT 'Salariul doctorului nou angajat a fost marit cu 10%';
END;

-------------------------------------- TRIGGERE DDL ----------------------------------------------

-- LA CREAREA UNUI NOU TABEL, SE AFISEAZA UN MESAJ DE CONFIRMARE A CREARII
GO
CREATE TRIGGER DDL_TABLE_CREATION_MSG ON DATABASE FOR CREATE_TABLE AS
BEGIN
	PRINT 'S-a creat un nou tabel';
END;

-- LA EDITAREA SAU STERGEREA UNUI TABEL, SE AFISEAZA UN MESAJ CARE NE SPUNE CA NU ESTE PERMISA ACEASTA ACTIUNE
GO
CREATE TRIGGER DDL_TABLE_MANIPULATION ON DATABASE FOR ALTER_TABLE, DROP_TABLE AS
BEGIN
	PRINT 'Nu este permisa editarea sau stergerea unei tabele!';
	ROLLBACK;
END;

-- LA CREAREA UNUI NOU TABEL IN BAZA DE DATE, SE AFISEAZA TOATE TABELELE SI DATA LOR DE CREARE
GO 
CREATE TRIGGER DDL_TABLE_CREATION ON DATABASE FOR CREATE_TABLE AS
BEGIN
	SELECT NAME, CREATE_DATE FROM SYS.TABLES
END

-- LA REDENUMIREA UNEI COLOANE/A UNUI TABEL, SE AFISEAZA UN MESAJ
GO
CREATE TRIGGER DDL_RENAME_TRIGGER ON DATABASE FOR RENAME AS
BEGIN
	PRINT 'Ati redenumit un obiect cu succes';
END;

--------------------------------------------------------------------------------------------------
-- CURSORS
--------------------------------------------------------------------------------------------------

-- CURSOR CU PRESCRIPTIILE, IMPREUNA CU NUMELE PACIENTULUI SI AL DOCTORULUI, PRECUM SI MEDICAMENTELE PRESCRISE
DECLARE CURSOR_PRESCRIPTIONS SCROLL CURSOR FOR
SELECT P.ID AS 'ID PRESCRIPTION', P.PRESCRIPTION_START_DATE AS 'START DATE', 
P.PRESCRIPTION_END_DATE AS 'END DATE', CONCAT(U1.FIRST_NAME, ' ', U1.LAST_NAME) AS 'PATIENT',
CONCAT(U2.FIRST_NAME, ' ', U2.LAST_NAME) AS 'DOCTOR', M.MED_NAME AS 'MEDICINE'
FROM PRESCRIPTION P JOIN PRESCRIPTION_MEDICINE PM ON P.ID=PM.PRESCRIPTION_ID 
JOIN MEDICINE M ON PM.MEDICINE_ID=M.ID JOIN USERS U1 ON U1.USER_ID = P.PATIENT_ID JOIN USERS U2 ON U2.USER_ID = P.DOCTOR_ID

OPEN CURSOR_PRESCRIPTIONS;

DECLARE @ID_PRESCRIPTION INT, @PRESCRIPTION_START_DATE DATE, @PRESCRIPTION_END_DATE DATE, @PATIENT VARCHAR(99), @DOCTOR VARCHAR(99), @MEDICINE VARCHAR(99)

FETCH FIRST FROM CURSOR_PRESCRIPTIONS INTO @ID_PRESCRIPTION, @PRESCRIPTION_START_DATE, @PRESCRIPTION_END_DATE, @PATIENT, @DOCTOR, @MEDICINE;

WHILE @@FETCH_STATUS=0 
BEGIN
 PRINT ('PRESCRIPTION: '+CAST(@ID_PRESCRIPTION AS VARCHAR)+'; START DATE: '+CAST(@PRESCRIPTION_START_DATE AS VARCHAR)+'; END DATE: '+CAST(@PRESCRIPTION_END_DATE AS VARCHAR)
 + '; PATIENT: '+@PATIENT+'; DOCTOR: '+@DOCTOR+'; MEDICINE: '+@MEDICINE);
 FETCH NEXT FROM CURSOR_PRESCRIPTIONS INTO @ID_PRESCRIPTION, @PRESCRIPTION_START_DATE, @PRESCRIPTION_END_DATE, @PATIENT, @DOCTOR, @MEDICINE;
END;
 
CLOSE CURSOR_PRESCRIPTIONS;
DEALLOCATE CURSOR_PRESCRIPTIONS;

-- CURSOR CU TOTI CAREGIVER-II, IMPREUNA CU PACIENTII PE CARE II AU IN GRIJA, PRECUM SI CONDITIA MEDICALA A ACESTORA
DECLARE CURSOR_CAREGIVERS SCROLL CURSOR FOR
SELECT CONCAT(U1.FIRST_NAME, ' ', U1.LAST_NAME) AS 'CAREGIVER',
CONCAT(U2.FIRST_NAME, ' ', U2.LAST_NAME) AS 'PATIENT', P.DIAGNOSE AS 'DIAGNOSE' 
FROM CAREGIVER C JOIN USERS U1 ON U1.USER_ID = C.ID JOIN PATIENT P ON P.CAREGIVER_ID = C.ID JOIN USERS U2 ON U2.USER_ID = P.ID;

OPEN CURSOR_CAREGIVERS;

DECLARE @CAREGIVER VARCHAR(99), @PATIENT_ VARCHAR(99), @DIAGNOSE VARCHAR(99)

FETCH FIRST FROM CURSOR_CAREGIVERS INTO @CAREGIVER, @PATIENT_, @DIAGNOSE;

WHILE @@FETCH_STATUS=0 
BEGIN
 PRINT ('CAREGIVER: ' + @CAREGIVER + '; PATIENT: '+ @PATIENT_ +'; DIAGNOSE: '+ @DIAGNOSE);
 FETCH NEXT FROM CURSOR_CAREGIVERS INTO @CAREGIVER, @PATIENT_, @DIAGNOSE;
END;
 
CLOSE CURSOR_CAREGIVERS;
DEALLOCATE CURSOR_CAREGIVERS;

-- CURSOR CU TOATE MEDICAMENTELE EXISTENTE IN SISTEM, IMPREUNA CU EFECTELE SECUNDARE ALE LOR
DECLARE CURSOR_MEDICINE SCROLL CURSOR FOR
SELECT M.MED_NAME AS 'MEDICINE NAME', M.DOSAGE AS 'DOSAGE', S.SIDE_EFF_NAME AS 'SIDE EFFECT'
FROM MEDICINE M JOIN MEDINCINE_SIDE_EFFECT MS ON MS.MEDICINE_ID = M.ID JOIN SIDE_EFFECT S ON MS.SIDE_EFFECT_ID = S.ID;

OPEN CURSOR_MEDICINE;

DECLARE @MEDICINE_NAME VARCHAR(99), @DOSAGE VARCHAR(99), @SIDE_EFFECT VARCHAR(99);

FETCH FIRST FROM CURSOR_MEDICINE INTO @MEDICINE_NAME, @DOSAGE, @SIDE_EFFECT;

WHILE @@FETCH_STATUS=0 
BEGIN
 PRINT ('MEDICINE: ' + @MEDICINE_NAME + '; DOSAGE: '+ @DOSAGE +'; SIDE EFFECT: '+ @SIDE_EFFECT);
 FETCH NEXT FROM CURSOR_MEDICINE INTO @MEDICINE_NAME, @DOSAGE, @SIDE_EFFECT;
END;
 
CLOSE CURSOR_MEDICINE;
DEALLOCATE CURSOR_MEDICINE;

--------------------------------------------------------------------------------------------------
-- JOBS
--------------------------------------------------------------------------------------------------
-- O PROCEDURA CARE GASESTE DOCTORII ANIVERSATI IN ZIUA ACTUALA SI II INSEREAZA IN TABELA 
-- CELEBRATED_DOCTORS SI APOI UN JOB CARE EXECUTA PROCEDURA IN FIECARE ZI LA ORA 00

CREATE TABLE CELEBRATED_DOCTORS (
	ID INT NOT NULL PRIMARY KEY, 
	SALARY INT NOT NULL, 
	SPECIALIZATION VARCHAR(99) NOT NULL,
	FOREIGN KEY (ID) REFERENCES USERS (USER_ID)
);
GO
CREATE PROCEDURE CELEB_DOCTORS AS 
INSERT INTO CELEBRATED_DOCTORS
SELECT D.ID, D.SALARY, D.SPECIALIZATION FROM DOCTOR D JOIN USERS U ON U.USER_ID = D.ID WHERE U.BIRTH_DATE = GETDATE();

GO 
EXEC dbo.sp_add_job
	@job_name = N'INSERT_CELEBRATED_DOCTOR' ;
GO
EXEC sp_add_jobstep
	@job_name = N'INSERT_CELEBRATED_DOCTOR',  
    @step_name = N'INSERT_CELEBRATED_DOCTOR1',  
    @subsystem = N'TSQL',  
    @command = N'Exec CELEB_DOCTORS',   
    @retry_attempts = 5,  
    @retry_interval = 5 ;  
GO  
EXEC dbo.sp_add_schedule  
    @schedule_name = N'RunDaily',  
    @freq_type = 4,  
    @freq_interval = 365,
    @active_start_time = 20000 ;  
GO  
EXEC sp_attach_schedule  
   @job_name = N'INSERT_CELEBRATED_DOCTOR',  
   @schedule_name = N'RunDaily';  
GO  
EXEC dbo.sp_add_jobserver  
    @job_name = N'INSERT_CELEBRATED_DOCTOR'; 

-- PROCEDURA CARE MARESTE SALARIUL DOCTORILOR CU 2% SI UN JOB CARE APELEAZA O DATA PE LUNA ACEASTA PROCEDURA
GO
CREATE PROCEDURE DOCTORS_SALARY_RAISE AS 
UPDATE DOCTOR SET SALARY = SALARY + (SALARY / 5);

GO
EXEC dbo.sp_add_job  
    @job_name = N'UpdateDocSalary' ;  
GO  
EXEC sp_add_jobstep  
    @job_name = N'UpdateDocSalary',  
    @step_name = N'UpdateDocSalary1',  
    @subsystem = N'TSQL',  
    @command = N'Exec DOCTORS_SALARY_RAISE',   
    @retry_attempts = 5,  
    @retry_interval = 5 ;  
GO  
EXEC dbo.sp_add_schedule  
    @schedule_name = N'RunMonthly',  
    @freq_type = 16, 
    @freq_interval = 1,
    @active_start_time = 20000 ;  
GO  
EXEC sp_attach_schedule  
   @job_name = N'UpdateDocSalary',  
   @schedule_name = N'RunMonthly';  
GO  
EXEC dbo.sp_add_jobserver  
    @job_name = N'UpdateDocSalary';   
GO  