create table products as 
select * from  xsales.products;

desc xsales.products;
select * from products;

set serveroutput on;

declare 
    price_max products.list_price%type;
    price_min products.list_price%type;
    
begin
    
    select max(list_price), min(list_price) into price_max, price_min 
    from products;
    dbms_output.put_line('max price = ' || price_max ||', '|| 'price_min = ' || price_min);

end;
/

create table pricelog(

minPrice varchar(60),
maxPrice varchar(60),
logTime date
);

declare 
    price_max varchar(60);
    price_min varchar(60);
    
begin
    
    select max(list_price),min(list_price) 
    into price_max, price_min 
    from products;
    insert into priceLog values(price_max, price_min, sysdate);
    --dbms_output.put_line('max price = ' || price_max ||', '|| 'price_min = ' || price_min);

end;
/

select * from priceLog;
select to_number(list_price) from xsales.products; 
drop table priceLog;

declare 
    p_desc products.description%type;
    p_price products.list_price%type;
    prod_row products%rowtype;
    cursor prod_cursor is select * from products;
    
begin
    open prod_cursor;
    loop
        fetch prod_cursor into prod_row;
        exit when prod_cursor%notfound;
        if instr(prod_row.description, 'Memory') > 0 then
            DBMS_OUTPUT.put_line(prod_row.description);
            DBMS_OUTPUT.put_line(prod_row.list_price);
      /*  else
            DBMS_OUTPUT.put_line(prod_row.description); */
        end if;    
    end loop;
    close prod_cursor;
end;
/

declare 
    p_desc products.description%type;
    p_price products.list_price%type;
    prod_row products%rowtype;
    cursor prod_cursor is select * from products 
    for update of list_price;
    
begin
    open prod_cursor;
    loop
        fetch prod_cursor into prod_row;
        exit when prod_cursor%notfound;
        if instr(prod_row.description, 'Memory') > 0 then
            DBMS_OUTPUT.put_line(prod_row.description);
            DBMS_OUTPUT.put_line(prod_row.list_price);
            update products set list_price = '0'
            where current of prod_cursor;
        end if;    
    end loop;
    close prod_cursor;
end;
/

commit;
rollback;
select * from products where list_price = '0';




create or replace function setOutOfStock(subStr varchar, ofs varchar) return NUMBER as
rowsUpdated number(10) := 0;  
    prod_row products%rowtype;
    cursor prod_cursor is select * from products 
            for update of list_price;
begin 
        open prod_cursor;
    loop
        fetch prod_cursor into prod_row;
        exit when prod_cursor%notfound;
        if instr(prod_row.description, substr) > 0 then
            --DBMS_OUTPUT.put_line(prod_row.description);
            --DBMS_OUTPUT.put_line(prod_row.list_price);
            update products set list_price = ofs
                    where current of prod_cursor;
            rowsUpdated := rowsUpdated+1;
        end if;    
    end loop;
    close prod_cursor;
return rowsUpdated;
end setOutOfStock;
/

DECLARE
  a NUMBER;
BEGIN
  a:=setOutOfStock('Memory', '0');
  dbms_output.put_line(a || ' rows updated');
END;
/
commit;