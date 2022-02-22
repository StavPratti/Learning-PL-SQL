drop table department;
drop table candidates;
drop type employeelist;
drop type employee;
drop type address;
drop procedure hire;
drop procedure fire;
drop procedure raiseSalaries;
drop function salaryCap;
drop function getsize;
drop function getCandidateById;
drop function getEmployeeById;


CREATE OR REPLACE TYPE address AS OBJECT
(
street VARCHAR2(30),
city VARCHAR2(30),
num NUMBER(3)
);
/

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


CREATE OR REPLACE TYPE employee AS OBJECT
(
eid NUMBER(4),
fname VARCHAR2(50),
lname VARCHAR2(50),
salary   NUMBER(7,2),
residence ADDRESS,
CONSTRUCTOR FUNCTION employee(eid NUMBER, fname VARCHAR2, lname VARCHAR2, residence ADDRESS)
RETURN SELF AS RESULT
);
/

CREATE OR REPLACE TYPE BODY employee AS
CONSTRUCTOR FUNCTION employee(eid NUMBER, fname VARCHAR2, lname VARCHAR2, residence ADDRESS)
RETURN SELF AS RESULT
AS
BEGIN
SELF.eid := eid;
SELF.fname:= fname;
SELF.lname:= lname;
SELF.residence:= residence;
SELF.salary:= 0;
RETURN;
END;
END;
/


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




CREATE OR REPLACE TYPE employeelist AS TABLE OF employee
/


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



CREATE TABLE department(
	dname VARCHAR2(50) PRIMARY KEY,
	staff EMPLOYEELIST
) NESTED TABLE staff STORE AS staff_tab;



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



CREATE TABLE candidates(
	cand EMPLOYEELIST
) NESTED TABLE cand STORE AS cand_tab;


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


INSERT INTO department VALUES ('IT',EMPLOYEELIST());
INSERT INTO department VALUES ('HR',EMPLOYEELIST());
INSERT INTO department VALUES ('Finance',EMPLOYEELIST());
INSERT INTO department VALUES ('Operations',EMPLOYEELIST());


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


INSERT INTO candidates VALUES (EMPLOYEELIST(
		EMPLOYEE(1,'John','Doe',ADDRESS('Omirou','Tavros',9)),
		EMPLOYEE(2,'Mary','Blue',ADDRESS('Harokopou','Kallithea',89)),
		EMPLOYEE(3,'Bill','Brown',ADDRESS('Stadiou','Athina',80)),
		EMPLOYEE(4,'Kate','Blanket',ADDRESS('Venizelou','Kallithea',70))
		));



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



CREATE OR REPLACE PROCEDURE hire(deptname VARCHAR2, emp EMPLOYEE, salary NUMBER) AS
x EMPLOYEE;
BEGIN
x:=EMPLOYEE(emp.eid,emp.fname,emp.lname,emp.residence);
x.salary:=salary;
INSERT INTO TABLE (SELECT staff FROM department WHERE dname=deptname) emplist VALUES (x);
DELETE FROM TABLE (SELECT cand FROM candidates) candlist WHERE eid=emp.eid;
END hire;
/


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


CREATE OR REPLACE PROCEDURE fire(emp EMPLOYEE, deptname VARCHAR2) AS
x EMPLOYEE;
BEGIN
x:=EMPLOYEE(emp.eid,emp.fname,emp.lname,emp.residence);
x.salary:=0;
DELETE FROM TABLE (SELECT staff FROM department WHERE dname=deptname) WHERE eid=emp.eid;
INSERT INTO TABLE (SELECT cand FROM candidates) VALUES (x);
END fire;
/

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


CREATE OR REPLACE PROCEDURE raiseSalaries(deptname VARCHAR2, raise NUMBER) AS
BEGIN
UPDATE TABLE (SELECT staff FROM department WHERE dname=deptname) emplist SET salary=salary+raise;
END raiseSalaries;
/


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


CREATE OR REPLACE FUNCTION salaryCap(deptname VARCHAR2) RETURN NUMBER AS
salarycap NUMBER(8,2):=0;
BEGIN
SELECT sum(salary) INTO salarycap FROM TABLE (SELECT staff FROM department WHERE dname=deptname) emplist;
RETURN salarycap;
END salaryCap;
/

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


CREATE OR REPLACE FUNCTION getsize(deptname VARCHAR2) RETURN NUMBER AS
employees EMPLOYEELIST;
BEGIN
SELECT staff INTO employees FROM department WHERE dname=deptname;
RETURN employees.COUNT;
END getsize;
/


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


CREATE OR REPLACE FUNCTION getCandidateById(id NUMBER) RETURN EMPLOYEE AS 
fn VARCHAR2(50);
ln VARCHAR2(50);
ad ADDRESS;
e EMPLOYEE;
BEGIN
SELECT fname,lname,residence INTO fn,ln,ad FROM TABLE(SELECT cand FROM CANDIDATES) candlist where eid=id;
e:=EMPLOYEE(id,fn,ln,ad);
RETURN e;
END getCandidateById;
/


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


CREATE OR REPLACE FUNCTION getEmployeeById(id NUMBER, deptname VARCHAR2) RETURN EMPLOYEE AS 
fn VARCHAR2(50);
ln VARCHAR2(50);
ad ADDRESS;
e EMPLOYEE;
BEGIN
SELECT fname,lname,residence INTO fn,ln,ad FROM TABLE(SELECT staff FROM Department WHERE dname=deptname) emplist where eid=id;
e:=EMPLOYEE(id,fn,ln,ad);
RETURN e;
END getEmployeeById;
/


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


--Unnamed script: Hire 1 to 'IT'
DECLARE
e EMPLOYEE;
BEGIN
SELECT getCandidateById(1) INTO e FROM DUAL;
hire('IT',e,2000);
END;
/


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


--Unnamed script: Show department info
DECLARE
e EMPLOYEE;
CURSOR dc is SELECT dname FROM DEPARTMENT;
dn VARCHAR2(50);
BEGIN
OPEN dc;
LOOP
  FETCH dc INTO dn;
  DBMS_OUTPUT.PUT_LINE(dn||','||salaryCap(dn)||','||getsize(dn));
  EXIT WHEN dc%NOTFOUND;
END LOOP;
CLOSE dc;
END;
/


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


SELECT dname,salaryCap(dname),getsize(dname) from DEPARTMENT;


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


EXEC raiseSalaries('IT',100);


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


--Unnamed script: Fire 3 from 'IT'
DECLARE
e EMPLOYEE;
BEGIN
SELECT getEmployeeById(3,'IT') INTO e FROM DUAL;
fire(e,'IT');
END;
/

