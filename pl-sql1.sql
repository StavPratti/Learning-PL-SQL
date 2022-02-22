set serveroutput on

---copy PRODUCTS table from XSALES schema

create table products as
select * from XSALES.PRODUCTS;


--- select only products that contain 'Memory' in their description
select * from products where description like '%Memory%';
select * from products where description like '%Battery%';


--- for products that contain 'Memory' in their description increase the list_price by 10% 
--- for products that contain 'Battery' in their description increase the list_price by 20% 

--- 1. create a cursor that runs through products and checks their description and list_price
declare
    product_row products%rowtype;
    CURSOR prod_cursor IS SELECT * from products;

begin
    open prod_cursor;
    loop
        fetch prod_cursor Into product_row;
        Exit When prod_cursor%NotFound;
        DBMS_OUTPUT.PUT_LINE(product_row.list_price ||'     '||product_row.description);
    End Loop;
    close prod_cursor;
end;
/

---2. check substring, ignore case
declare
    product_row products%rowtype;
    CURSOR prod_cursor IS SELECT * from products;
begin
    open prod_cursor;
    loop
        fetch prod_cursor Into product_row;
        Exit When prod_cursor%NotFound;
        if instr(lower(product_row.description),'memory')>0 then
            DBMS_OUTPUT.PUT_LINE(product_row.list_price*1.10 ||'     '||product_row.description);
        elsif instr(lower(product_row.description),'battery')>0 then
            DBMS_OUTPUT.PUT_LINE(product_row.list_price*1.20 ||'     '||product_row.description);
        end if;
    End Loop;
    close prod_cursor;
end;
/

---3. update row when needed

declare
    product_row products%rowtype;
    CURSOR prod_cursor IS SELECT * from products for update of list_price;

begin
    open prod_cursor;
    loop
       fetch prod_cursor Into product_row;
        Exit When prod_cursor%NotFound;
        if instr(lower(product_row.description),'memory')>0 then
            update products set list_price=list_price*1.1 where current of prod_cursor;
            --DBMS_OUTPUT.PUT_LINE(product_row.list_price*1.10 ||'     '||product_row.description);
        elsif instr(lower(product_row.description),'battery')>0 then
            update products set list_price=list_price*1.2 where current of prod_cursor;
            --DBMS_OUTPUT.PUT_LINE(product_row.list_price*1.20 ||'     '||product_row.description);
        end if;
    End Loop;
    close prod_cursor;
end;
/
