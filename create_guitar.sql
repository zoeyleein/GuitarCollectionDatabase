CREATE TABLESPACE GUITAR_COLLECTION DATAFILE 'GUITAR_COLLECTION.dat' SIZE 100M ONLINE;

CREATE USER group5GC IDENTIFIED BY group5password ACCOUNT UNLOCK DEFAULT TABLESPACE GUITAR_COLLECTION QUOTA 20M on GUITAR_COLLECTION;

CREATE USER testUser1 IDENTIFIED BY test1Password ACCOUNT UNLOCK
	DEFAULT TABLESPACE GUITAR_COLLECTION
	QUOTA 5M ON GUITAR_COLLECTION;

CREATE ROLE applicationAdmin2;
CREATE ROLE applicationUser2;

GRANT CONNECT, RESOURCE, CREATE VIEW, CREATE TRIGGER, CREATE PROCEDURE TO applicationAdmin2;
GRANT CONNECT, RESOURCE TO applicationUser2;

GRANT applicationAdmin2 TO group5GC;
GRANT applicationUser2 TO testUser1;

CONNECT group5GC/group5password;





CREATE TABLE employee (
  idemployee INT NOT NULL,
  PRIMARY KEY (idemployee)
);

CREATE TABLE fullname (
  idfullname INT NOT NULL,
  fullname VARCHAR(100) NOT NULL,
  PRIMARY KEY (idfullname)
);

CREATE TABLE phone (
  idphone INT NOT NULL,
  phone VARCHAR(45),
  PRIMARY KEY (idphone)
);

CREATE TABLE email (
  idemail INT NOT NULL,
  email VARCHAR(100),
  PRIMARY KEY (idemail)
);

CREATE TABLE address (
  idaddress INT NOT NULL,
  address VARCHAR(100),
  PRIMARY KEY (idaddress)
);

CREATE TABLE employee_address (
  idemployee_address INT NOT NULL,
  startdate TIMESTAMP NOT NULL,
  enddate TIMESTAMP DEFAULT NULL,
  address VARCHAR(100) not null,
  address_idaddress INT NOT NULL,
  employee_idemployee INT NOT NULL,
  PRIMARY KEY (idemployee_address)
);

CREATE TABLE employee_fullname (
  idemployee_fullname INT NOT NULL,
  startdate TIMESTAMP NOT NULL,
  enddate TIMESTAMP DEFAULT NULL,
  fullname VARCHAR(100) not null,
  fullname_idfullname INT NOT NULL,
  employee_idemployee INT NOT NULL,
  PRIMARY KEY (idemployee_fullname)
);

CREATE TABLE employee_phone (
  idemployee_phone INT NOT NULL,
  startdate TIMESTAMP NOT NULL,
  enddate TIMESTAMP DEFAULT NULL,
  phone VARCHAR(100) not null,
  phone_idphone INT NOT NULL,
  employee_idemployee INT NOT NULL,
  PRIMARY KEY (idemployee_phone)
);

CREATE TABLE employee_email (
  idemployee_email INT NOT NULL,
  startdate TIMESTAMP NOT NULL,
  enddate TIMESTAMP DEFAULT NULL,
  email_idemail INT NOT NULL,
  email VARCHAR(100) not null,
  employee_idemployee INT NOT NULL,
  PRIMARY KEY (idemployee_email)
);


CREATE OR REPLACE VIEW employee_view AS
SELECT
    employee.idemployee AS idemployee,
    employee_fullname.fullname AS fullname,
    employee_address.address AS ADDRESS,
    employee_email.email AS email,
    employee_phone.phone AS phone
FROM
    employee
LEFT JOIN
    employee_address ON employee.idemployee = employee_address.employee_idemployee AND employee_address.enddate IS NULL
LEFT JOIN
    address ON employee_address.address_idaddress = address.idaddress
LEFT JOIN
    employee_email ON employee.idemployee = employee_email.employee_idemployee AND employee_email.enddate IS NULL
LEFT JOIN
    email ON employee_email.email_idemail = email.idemail 
LEFT JOIN
    employee_fullname ON employee.idemployee = employee_fullname.employee_idemployee AND employee_fullname.enddate IS NULL
LEFT JOIN
    fullname ON employee_fullname.fullname_idfullname = fullname.idfullname
LEFT JOIN
    employee_phone ON employee.idemployee = employee_phone.employee_idemployee AND employee_phone.enddate IS NULL
LEFT JOIN
    phone ON employee_phone.phone_idphone = phone.idphone;

CREATE SEQUENCE employee_address_sequence START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE employee_email_sequence START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE employee_fullname_sequence START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE employee_phone_sequence START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE ADDRESS_sequence START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE email_sequence START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE fullname_sequence START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE phone_sequence START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE OR REPLACE TRIGGER InsertemployeeView
INSTEAD OF INSERT ON employee_VIEW
FOR EACH ROW
DECLARE
    v_employee_id NUMBER;
    v_address_id NUMBER;
    v_email_id NUMBER;
    v_fullname_id NUMBER;
    v_phone_id NUMBER;
BEGIN
    -- Insert into employee table
    INSERT INTO employee (idemployee)
    VALUES (:NEW.idemployee)
    RETURNING idemployee INTO v_employee_id;

    -- Insert into address table
    INSERT INTO address (idaddress, address)
    VALUES (ADDRESS_sequence.NEXTVAL, :NEW.ADDRESS)
    RETURNING idaddress INTO v_address_id;

    -- Insert into email table
    INSERT INTO email (idemail, email)
    VALUES (email_sequence.NEXTVAL, :NEW.email)
    RETURNING idemail INTO v_email_id;

    -- Insert into fullname table
    INSERT INTO fullname (idfullname, fullname)
    VALUES (fullname_sequence.NEXTVAL, :NEW.fullname)
    RETURNING idfullname INTO v_fullname_id;

    -- Insert into phone table
    INSERT INTO phone (idphone, phone)
    VALUES (phone_sequence.NEXTVAL, :NEW.phone)
    RETURNING idphone INTO v_phone_id;

    -- Insert into employee_ADDRESS table
    INSERT INTO employee_ADDRESS (IDemployee_ADDRESS, employee_idemployee, startdate, address_idaddress, ADDRESS)
    VALUES (ADDRESS_sequence.NEXTVAL, v_employee_id, SYSTIMESTAMP, v_address_id, :NEW.ADDRESS);

    -- Insert into employee_email table
    INSERT INTO employee_email (idemployee_email, employee_idemployee, startdate, enddate, email_idemail, email)
    VALUES (email_sequence.NEXTVAL, v_employee_id, SYSTIMESTAMP, NULL, v_email_id, :NEW.email);

    -- Insert into employee_fullname table
    INSERT INTO employee_fullname (IDemployee_fullname, employee_idemployee, startdate, enddate, fullname_idfullname, fullname)
    VALUES (fullname_sequence.NEXTVAL, v_employee_id, SYSTIMESTAMP, NULL, v_fullname_id, :NEW.fullname);

    -- Insert into employee_phone table
    INSERT INTO employee_phone (idemployee_phone, employee_idemployee, startdate, enddate, phone_idphone, phone)
    VALUES (phone_sequence.NEXTVAL, v_employee_id, SYSTIMESTAMP, NULL, v_phone_id, :NEW.phone);
END;
/
CREATE OR REPLACE TRIGGER UpdateemployeeView
INSTEAD OF UPDATE ON employee_VIEW
FOR EACH ROW
BEGIN
    -- Insert into phone table
    INSERT INTO phone (idphone, phone)
    VALUES (phone_sequence.NEXTVAL, :NEW.phone);

    UPDATE employee_phone
    SET enddate = SYSTIMESTAMP
    WHERE employee_idemployee = :NEW.idemployee AND enddate IS NULL;

    INSERT INTO employee_phone (idemployee_phone,employee_idemployee, phone_idphone, startdate, phone)
    VALUES (employee_phone_sequence.NEXTVAL,:NEW.idemployee, phone_sequence.CURRVAL, SYSTIMESTAMP, :NEW.phone);

    -- Insert into fullname table
    INSERT INTO fullname (idfullname, fullname)
    VALUES (fullname_sequence.NEXTVAL, :NEW.fullname);

    UPDATE employee_fullname
    SET enddate = SYSTIMESTAMP
    WHERE employee_idemployee = :NEW.idemployee AND enddate IS NULL;

    INSERT INTO employee_fullname (IDemployee_fullname,employee_idemployee, fullname_idfullname, startdate, fullname)
    VALUES (employee_fullname_sequence.NEXTVAL,:NEW.idemployee, fullname_sequence.CURRVAL, SYSTIMESTAMP, :NEW.fullname);

    -- Insert into email table
    INSERT INTO email (idemail, email)
    VALUES (email_sequence.NEXTVAL, :NEW.email);

    UPDATE employee_email
    SET enddate = SYSTIMESTAMP
    WHERE employee_idemployee = :NEW.idemployee AND enddate IS NULL;

    INSERT INTO employee_email (IDemployee_email,employee_idemployee, email_idemail, startdate, email)
    VALUES (employee_email_sequence.NEXTVAL,:NEW.idemployee, email_sequence.CURRVAL, SYSTIMESTAMP, :NEW.email);

    -- Insert into address table
    INSERT INTO ADDRESS (idADDRESS, ADDRESS)
    VALUES (ADDRESS_sequence.NEXTVAL, :NEW.ADDRESS);

    UPDATE employee_ADDRESS
    SET enddate = SYSTIMESTAMP
    WHERE employee_idemployee = :NEW.idemployee AND enddate IS NULL;

    INSERT INTO employee_ADDRESS (IDemployee_ADDRESS,employee_idemployee, ADDRESS_idADDRESS, startdate, ADDRESS)
    VALUES (employee_ADDRESS_sequence.NEXTVAL,:NEW.idemployee, ADDRESS_sequence.CURRVAL, SYSTIMESTAMP, :NEW.ADDRESS);
END;
/


CREATE OR REPLACE TRIGGER DeleteemployeeView
INSTEAD OF DELETE ON employee_VIEW
FOR EACH ROW
BEGIN
    UPDATE employee_ADDRESS
    SET enddate = SYSTIMESTAMP
    WHERE employee_idemployee = :OLD.idemployee AND enddate IS NULL;

    UPDATE employee_fullname
    SET enddate = SYSTIMESTAMP
    WHERE employee_idemployee = :OLD.idemployee AND enddate IS NULL;

    UPDATE employee_email
    SET enddate = SYSTIMESTAMP
    WHERE employee_idemployee = :OLD.idemployee AND enddate IS NULL;

    UPDATE employee_phone
    SET enddate = SYSTIMESTAMP
    WHERE employee_idemployee = :OLD.idemployee AND enddate IS NULL;

    DELETE FROM employee
    WHERE idemployee = :OLD.idemployee;
END;
/

CREATE TABLE manufacturer (
  idmanufacturer int NOT NULL,
  establishdate varchar(45) not NULL,
  mname varchar(45) not null,
  country varchar(45) not NULL,
  PRIMARY KEY (idmanufacturer)
);

  CREATE TABLE manufacturer_establishdate (
  idmanufacturer_establishdate int not null,
  startdate timestamp NOT NULL,
  enddate timestamp DEFAULT NULL,
  establishdate varchar(45) not null,
  manufacturer_idmanufacturer int NOT NULL,
  PRIMARY KEY (idmanufacturer_establishdate));

  CREATE TABLE manufacturer_mname (
  idmanufacturer_mname int not null,
  startdate timestamp NOT NULL,
  enddate timestamp DEFAULT NULL,
  mname varchar(45) not NULL,
  manufacturer_idmanufacturer int NOT NULL,
  PRIMARY KEY (idmanufacturer_mname));

  CREATE TABLE manufacturer_country (
  idmanufacturer_country int not null,
  startdate timestamp NOT NULL,
  enddate timestamp DEFAULT NULL,
  country varchar(45) not NULL,
  manufacturer_idmanufacturer int NOT NULL,
  PRIMARY KEY (idmanufacturer_country));


CREATE OR REPLACE VIEW manufacturer_view AS
SELECT
    manufacturer.idmanufacturer AS idmanufacturer,
    manufacturer.establishdate AS establishdate,
    manufacturer.country as country,
    manufacturer.mname as mname
FROM
    manufacturer
LEFT JOIN
    manufacturer_establishdate ON manufacturer_establishdate.manufacturer_idmanufacturer = manufacturer.idmanufacturer
LEFT JOIN
    manufacturer_mname ON manufacturer_mname.manufacturer_idmanufacturer = manufacturer.idmanufacturer
LEFT JOIN
    manufacturer_country ON manufacturer_country.manufacturer_idmanufacturer = manufacturer.idmanufacturer
WHERE
    (manufacturer_establishdate.enddate IS NULL)
AND
    (manufacturer_mname.enddate IS NULL)
AND
    (manufacturer_country.enddate IS NULL)
;



CREATE SEQUENCE establishdate_sequence
START WITH 1
INCREMENT BY 1
NOCACHE;


CREATE SEQUENCE mname_sequence
START WITH 1
INCREMENT BY 1
NOCACHE;

CREATE SEQUENCE country_sequence
START WITH 1
INCREMENT BY 1
NOCACHE;

CREATE OR REPLACE TRIGGER InsertmanufacturerView
INSTEAD OF INSERT ON manufacturer_VIEW
FOR EACH ROW
DECLARE
    v_manufacturer_id NUMBER;
BEGIN
   INSERT INTO manufacturer (idmanufacturer, mname, establishdate, country)
    VALUES (:NEW.idmanufacturer, :NEW.mname, :NEW.establishdate, :NEW.country)
    RETURNING idmanufacturer INTO v_manufacturer_id;

    INSERT INTO manufacturer_establishdate (idmanufacturer_establishdate, manufacturer_idmanufacturer, startdate, establishdate)
    VALUES (establishdate_sequence.NEXTVAL, v_manufacturer_id, SYSDATE,  :NEW.establishdate);

    INSERT INTO manufacturer_mname (idmanufacturer_mname, manufacturer_idmanufacturer, startdate, enddate, mname)
    VALUES (mname_sequence.NEXTVAL, v_manufacturer_id, SYSDATE, NULL, :NEW.mname);
  
    INSERT INTO manufacturer_country (idmanufacturer_country, manufacturer_idmanufacturer, startdate, enddate, country)
    VALUES (country_sequence.NEXTVAL, v_manufacturer_id, SYSDATE, NULL, :NEW.country);
END;
/

CREATE OR REPLACE TRIGGER UpdatemanufacturerView
INSTEAD OF UPDATE ON manufacturer_VIEW
FOR EACH ROW
BEGIN
    UPDATE manufacturer
    SET establishdate = :NEW.establishdate,
        country = :NEW.country,
        mname = :NEW.mname
    WHERE idmanufacturer = :NEW.idmanufacturer;

    UPDATE manufacturer_country
    SET enddate = SYSDATE
    WHERE manufacturer_idmanufacturer = :NEW.idmanufacturer AND enddate IS NULL;

    INSERT INTO manufacturer_country (idmanufacturer_country, manufacturer_idmanufacturer, startdate, enddate, country)
    VALUES (country_sequence.NEXTVAL, :NEW.idmanufacturer, SYSDATE, NULL, :NEW.country);

    UPDATE manufacturer_mname
    SET enddate = SYSDATE
    WHERE manufacturer_idmanufacturer = :NEW.idmanufacturer AND enddate IS NULL;

    INSERT INTO manufacturer_mname (idmanufacturer_mname, manufacturer_idmanufacturer, startdate, enddate, mname)
    VALUES (mname_sequence.NEXTVAL, :NEW.idmanufacturer, SYSDATE, NULL, :NEW.mname);

    UPDATE manufacturer_establishdate
    SET enddate = SYSDATE
    WHERE manufacturer_idmanufacturer = :NEW.idmanufacturer AND enddate IS NULL;

    INSERT INTO manufacturer_establishdate (idmanufacturer_establishdate, manufacturer_idmanufacturer, startdate, enddate, establishdate)
    VALUES (establishdate_sequence.NEXTVAL, :NEW.idmanufacturer, SYSDATE, NULL, :NEW.establishdate);
END;
/


CREATE OR REPLACE TRIGGER DeletemanufacturerView
INSTEAD OF DELETE ON manufacturer_VIEW
FOR EACH ROW
BEGIN
  
    UPDATE manufacturer_establishdate
    SET enddate = SYSDATE
    WHERE manufacturer_idmanufacturer = :OLD.idmanufacturer AND enddate IS NULL;
    
    UPDATE manufacturer_mname
    SET enddate = SYSDATE
    WHERE manufacturer_idmanufacturer = :OLD.idmanufacturer AND enddate IS NULL;
	
    UPDATE manufacturer_country
    SET enddate = SYSDATE
    WHERE manufacturer_idmanufacturer = :OLD.idmanufacturer AND enddate IS NULL;

    DELETE FROM manufacturer
    WHERE idmanufacturer = :OLD.idmanufacturer;
END;
/




 
CREATE TABLE gtype (
  idgtype int NOT NULL,
  name varchar(45) not null,
  PRIMARY KEY (idgtype)
);


  CREATE TABLE gtype_gname (
  idgtype_gname int not null,
  startdate timestamp NOT NULL,
  enddate timestamp DEFAULT NULL,
  name varchar(45),
  gtype_idgtype int NOT NULL,
  PRIMARY KEY (idgtype_gname));

CREATE OR REPLACE VIEW gtype_view AS
SELECT
    gtype.idgtype AS idgtype,
    gtype.name AS typename
FROM
    gtype
LEFT JOIN
    gtype_gname ON gtype.idgtype = gtype_gname.gtype_idgtype
WHERE
    (gtype_gname.enddate IS NULL)
;



CREATE SEQUENCE gname_sequence
START WITH 1
INCREMENT BY 1
NOCACHE;

CREATE OR REPLACE TRIGGER InsertgtypeView
INSTEAD OF INSERT ON gtype_view
FOR EACH ROW
DECLARE
    v_gtype_id NUMBER;
BEGIN
   INSERT INTO gtype (idgtype,name)
    VALUES (:NEW.idgtype,:NEW.typename)
    RETURNING idgtype INTO v_gtype_id;


    INSERT INTO gtype_gname (IDgtype_gname, gtype_idgtype, startdate ,name)
    VALUES (gname_sequence.NEXTVAL,v_gtype_id, SYSDATE,:NEW.typename);

END;
/

CREATE OR REPLACE TRIGGER UpdateGtypeView
INSTEAD OF UPDATE ON GTYPE_VIEW
FOR EACH ROW
BEGIN
 
    UPDATE Gtype
    SET name = :NEW.typename
    WHERE idgtype = :NEW.idgtype;

    UPDATE gtype_gname
    SET enddate = SYSDATE
    WHERE gtype_idgtype = :NEW.idgtype AND enddate IS NULL;

    INSERT INTO gtype_gname (idgtype_gname, gtype_idgtype, startdate, name)
    VALUES (gname_sequence.NEXTVAL, :NEW.idgtype, SYSDATE, :NEW.typename);
END;
/

CREATE OR REPLACE TRIGGER DeleteGtypeView
INSTEAD OF DELETE ON GTYPE_VIEW
FOR EACH ROW
BEGIN
  
    UPDATE gtype_gname
    SET enddate = SYSDATE
    WHERE gtype_idgtype = :OLD.idgtype AND enddate IS NULL;
    

    DELETE FROM GTYPE
    WHERE idgtype = :OLD.idgtype;
END;
/



CREATE TABLE guitar (
  idguitar INT NOT NULL,
  model_name VARCHAR(45) NOT NULL,
  manufacturer_idmanufacturer INT NOT NULL,
  price VARCHAR(45) NOT NULL,
  gtype_idgtype INT NOT NULL,
  PRIMARY KEY (idguitar),
  CONSTRAINT fk_man_idm FOREIGN KEY (manufacturer_idmanufacturer) REFERENCES manufacturer (idmanufacturer),
  CONSTRAINT fk_typ_idt FOREIGN KEY (gtype_idgtype) REFERENCES gtype (idgtype)
);

CREATE TABLE feedback (
  idfeedback INT NOT NULL,
  score VARCHAR(45) NULL,
  feedback_date TIMESTAMP NOT NULL,
  content VARCHAR(200) NOT NULL,
  guitar_idguitar INT NOT NULL,
  PRIMARY KEY (idfeedback),
  CONSTRAINT fk_gu_idg FOREIGN KEY (guitar_idguitar) REFERENCES guitar (idguitar)
);

CREATE TABLE maintenance (
  idmaintenance INT NOT NULL,
  employee_idemployee INT NOT NULL,
  guitar_idguitar INT NOT NULL,
  maintenance_time TIMESTAMP NOT NULL,
  cost VARCHAR(45) NULL,
  PRIMARY KEY (idmaintenance),
  CONSTRAINT fk_em_ide FOREIGN KEY (employee_idemployee) REFERENCES employee (idemployee),
  CONSTRAINT fk_gu_idg1 FOREIGN KEY (guitar_idguitar) REFERENCES guitar (idguitar)
);

CREATE TABLE event (
  idevent INT NOT NULL,
  ename VARCHAR(45) NULL,
  event_date TIMESTAMP NOT NULL,
  location VARCHAR(200) NOT NULL,
  guitar_idguitar INT NOT NULL,
  PRIMARY KEY (idevent),
  CONSTRAINT fk_gu_idg2 FOREIGN KEY (guitar_idguitar) REFERENCES guitar (idguitar)
);