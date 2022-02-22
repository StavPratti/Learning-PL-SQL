drop table products;
create table products as
select * from XSALES.products;

desc products;
alter table products add(
     price_increase number(3,1)
);


select * from products where description like '%Memory%';  -- list_price*1.1
select * from products where description like '%Battery%';  -- list_price*1.2

select max(list_price) from products;
set SERVEROUTPUT ON;

DECLARE
product_info_tuple products%rowtype;
CURSOR prod_cursor is select * from products where description like '%Memory%' or description like '%Battery%'
                            for update of price_increase;
BEGIN
open prod_cursor;
loop
    fetch prod_cursor into product_info_tuple;
    exit when prod_cursor%NotFound;
    if (INSTR(lower(product_info_tuple.description), 'memory')>0) then
--        dbms_output.put_line(product_info_tuple.description);
        update products set price_increase=1.1 where current of prod_cursor;
    end if;
    if (INSTR(lower(product_info_tuple.description), 'battery')>0) then
        --dbms_output.put_line('***'||(product_info_tuple.list_price*1.2)||'***'||product_info_tuple.list_price);
        update products set price_increase=1.2 where current of prod_cursor;
    end if;
end loop;
END;
/

select replace('20.99','.',',')*1.1 from dual;

select description, get_final_price(list_price,price_increase) as final_price 
from products;

CREATE OR REPLACE function get_final_price (original_price IN VARCHAR, increase IN NUMBER)
    RETURN NUMBER
    IS 
    final_price NUMBER(7,2);
    BEGIN
        if increase>0 then
            final_price:=replace(original_price, '.', ',')*increase;
        else
            final_price:=cast(replace(original_price, '.', ',') as float);
        end if;
       return final_price;
    END;
    /


Select instr(lower('128MB Memory Card'),'memory') from dual;


Select o.customer_id, oi.cost, oi.quantity from orders o join order_items oi on o.order_id=oi.order_id;


CREATE OR REPLACE function get_total_tax(cust_id IN NUMBER)
    RETURN NUMBER
    IS 
    CURSOR orderitems_cursor is select * from products where customer_id=cust_id;
    total_tax NUMBER(7,2);
    BEGIN
        loop
            fetch prod_cursor into product_info_tuple;
            exit when prod_cursor%NotFound;

            if increase>0 then
                    INSERT INTO LUXURY_BUYS VALUES (...);
                total_tax:=total_tax+....;
            else
                total_tax:=total_tax+....;
            end if;
        end loop;
       return total_tax;
    END;
    /



CREATE OR REPLACE procedure update_final_prices (original_price IN VARCHAR, increase OUT NUMBER) 
    AS 
    final_price NUMBER(7,2);
    BEGIN
        if increase>0 then
            final_price:=replace(original_price, '.', ',')*increase;
        else
            final_price:=cast(replace(original_price, '.', ',') as float);
        end if;
        INSERT INTO ...
       --return final_price;
    END;
    /

DECLARE
    newprice NUMBER(15,2);
BEGIN
    EXECUTE update_final_prices(1000,newprice);
    DBMS_OUTPUT.PUT_LINE(newprice);
END;
/


CREATE OR REPLACE TYPE address AS OBJECT
(
street VARCHAR2(30),
city VARCHAR2(30),
num NUMBER(3), 
MEMBER FUNCTION getCity RETURN VARCHAR,
MEMBER FUNCTION relocate RETURN NUMBER, 
MEMBER FUNCTION change_city(newcity VARCHAR2) RETURN VARCHAR2
);
/
CREATE OR REPLACE TYPE BODY address AS
MEMBER FUNCTION getCity RETURN VARCHAR IS
BEGIN
    RETURN city;
END getCity;
MEMBER FUNCTION relocate RETURN NUMBER IS
BEGIN
    RETURN SELF.num+10;
END relocate;
MEMBER FUNCTION change_city(newcity VARCHAR2) RETURN VARCHAR2 IS
BEGIN 
    RETURN newcity;
END change_city;

END;
/


drop table mytest;
create table mytest(
testid NUMBER(5),
residence ADDRESS
);

select * from mytest;
INSERT INTO mytest VALUES (1, address('Omirou','Athens',9));
INSERT INTO mytest VALUES (2, address('El. Venizelou','Athens',70));

select testid, t.residence.getCity() from mytest t;
select testid, t.residence.street, t.residence.num, t.residence.getCity(), 
t.residence.relocate(), t.residence.change_city('Patras') 
from mytest t;


create type buildings_type AS TABLE OF address;
/

create table universities(
univname VARCHAR2(50),
buildings buildings_type)
NESTED TABLE buildings STORE AS buildings_type_tab;
/

INSERT INTO universities VALUES('HUA', buildings_type(address('Omirou','Athens',9),address('El. Venizelou','Athens',70)));

select * from universities;

INSERT INTO universities VALUES('HUA2', buildings_type(
select residence from mytest t
where t.residence.city='Athens'
));

select residence from mytest t
where t.residence.city='Athens';



drop table universities;
drop table mytest;
drop type buildings_type;
drop type address;
drop type employee_type;


CREATE OR REPLACE TYPE address AS OBJECT
(
street VARCHAR2(30),
city VARCHAR2(30),
num NUMBER(3)
);
/

CREATE OR REPLACE TYPE employee_type AS OBJECT
(
eid NUMBER(4),
fname VARCHAR2(50),
lname VARCHAR2(50),
salary   NUMBER(7,2),
residence ADDRESS,
CONSTRUCTOR FUNCTION employee_type(eid NUMBER, fname VARCHAR2, lname VARCHAR2, residence ADDRESS)
RETURN SELF AS RESULT
);
/


CREATE OR REPLACE TYPE BODY employee_type AS
CONSTRUCTOR FUNCTION employee_type(eid NUMBER, fname VARCHAR2, lname VARCHAR2, residence ADDRESS)
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

CREATE OR REPLACE TYPE employeelist AS TABLE OF employee_type
/


CREATE TABLE department2020(
	dname VARCHAR2(50) PRIMARY KEY,
	staff EMPLOYEELIST
) NESTED TABLE staff STORE AS staff_tab;



CREATE TABLE candidates2020(
	cand EMPLOYEELIST
) NESTED TABLE cand STORE AS cand_tab;

INSERT INTO department2020 VALUES ('IT',EMPLOYEELIST());
INSERT INTO department2020 VALUES ('HR',EMPLOYEELIST());
INSERT INTO department2020 VALUES ('Finance',EMPLOYEELIST());
INSERT INTO department2020 VALUES ('Operations',EMPLOYEELIST());

INSERT INTO candidates2020 VALUES (EMPLOYEELIST(
		EMPLOYEE_TYPE(1,'John','Doe',ADDRESS('Omirou','Tavros',9)),
		EMPLOYEE_TYPE(2,'Mary','Blue',ADDRESS('Harokopou','Kallithea',89)),
		EMPLOYEE_TYPE(3,'Bill','Brown',ADDRESS('Stadiou','Athina',80)),
		EMPLOYEE_TYPE(4,'Kate','Blanket',ADDRESS('Venizelou','Kallithea',70))
		));

CREATE OR REPLACE PROCEDURE hire(deptname VARCHAR2, emp EMPLOYEE_TYPE, salary NUMBER) AS
x EMPLOYEE_TYPE;
BEGIN
x:=EMPLOYEE_TYPE(emp.eid,emp.fname,emp.lname,emp.residence);
x.salary:=salary;
INSERT INTO TABLE (SELECT staff FROM department2020 WHERE dname=deptname) emplist VALUES (x);
DELETE FROM TABLE (SELECT cand FROM candidates2020) candlist WHERE eid=emp.eid;
END hire;
/

CREATE OR REPLACE FUNCTION getCandidateById(id NUMBER) RETURN EMPLOYEE_TYPE AS 
fn VARCHAR2(50);
ln VARCHAR2(50);
ad ADDRESS;
e EMPLOYEE_TYPE;
BEGIN
SELECT fname,lname,residence INTO fn,ln,ad FROM TABLE(SELECT cand FROM CANDIDATES2020) candlist where eid=id;
e:=EMPLOYEE_TYPE(id,fn,ln,ad);
RETURN e;
END getCandidateById;
/

DECLARE
e EMPLOYEE_TYPE;
BEGIN
SELECT getCandidateById(4) INTO e FROM DUAL;
hire('IT',e,2000);
END;
/

CREATE OR REPLACE FUNCTION getsize(deptname VARCHAR2) RETURN NUMBER AS
employees EMPLOYEELIST;
BEGIN
SELECT staff INTO employees FROM department2020 WHERE dname=deptname;
RETURN employees.COUNT;
END getsize;
/

SELECT dname,getsize(dname) from DEPARTMENT2020;