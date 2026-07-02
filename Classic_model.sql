
show databases;
use classicmodels;
show tables;

-- ELENCARE TUTTI I MODELLINI IN VENDITA
select *from products;

-- MOSTRA I MODELLINI CHE COSTANO MENO DI 75$
select *from products where msrp < 75;

-- MOSTRA NOME, PREZZO DI ACQUISTO E DI VENDITA DEI MODELLINI CHE COSTANO MENO DI 75$
select productname, buyprice, msrp from products where msrp < 75 ;

-- MOSTRA TUTTI I DIPENDENTI DI NOME LESLIE
select *from employees where firstName = "Leslie";

-- MOSTRA TUTTI I DIPENDENTI IL CUI COGNOME FINISCE PER “SON”.
select *from employees where lastName like "%son" ;

-- MOSTRA TUTTI I DIPENDENTI IL CUI NOME FINISCE PER "ARRY" E DAVANTI HA UNA SOLA LETTERA
select *from employees where firstName like "_%ARRY" ;

-- MOSTRA TUTTI I PRODOTTI CHE HANNO UNA SCALA DIVISIBILE PER 10 E MINORE DI 100 (ES: 1:10, 1:20,1:30, ...)
select *from products where productScale like "1:_0";

-- MOSTRA TUTTI I DIPENDENTI IL CUI NOME INIZIA CON M E LA CUI TERZA LETTERA È UNA R
select *from employees where firstName like "M_R%";

--  MOSTRA I MODELLINI CHE COSTANO MENO DI 75 E CHE ABBIAMO COMPRATO A PIÙ DI 30
select *from products where msrp < 75 and buyprice > 30;

-- MOSTRA I MODELLINI CHE COSTANO MENO DI 75 O PIÙ DI 150
select *from products where msrp < 75 or msrp > 150;

-- MOSTRA I MODELLINI CHE COSTANO MENO DI 75 O PIÙ DI 150 E CHE COMUNQUE ABBIAMO COMPRATO A PIÙ DI 30
select *from products where msrp < 75 or msrp > 150 and buyPrice > 30;

-- MOSTRA I PAGAMENTI CON IMPORTI COMPRESI TRA 5.000 ED 8.000
select *from payments where amount between 5000 and 8000;

-- PRENDI TUTTI I DIPENDENTI IL CUI NOME INIZIA CON UNA LETTERA TRA B ED F
select *from employees where firstName like "B%" or firstName like "F";

-- MOSTRA CODICE UFFICIO, CITTÀ E NUMERO DI TELEFONO DEGLI UFFICI IN FRANCIA O AMERICA
select officeCode, city, phone, country from offices  where country = "France" or country =  "USA";
select officeCode, city, phone, country from offices  where country in ("France" , "USA");

-- MOSTRARE I MODELLINI DEL TIPO "PLANES", "SHIPS" O "CLASSIC CARS"
select *from products where productLine in ( "PLANES", "SHIPS" ,"CLASSIC CARS");

-- MOSTRA GLI ORDINI NON SPEDITI
select *from orders where shippedDate is null;

-- MOSTRA GLI ORDINI CREATI DOPO IL 30/04/2005 E NON SPEDITI
select *from orders where orderDate > "2005-04-30" and shippedDate is null;

-- MOSTRA I PREZZI DI VENDITA SENZA L’IVA (PREZZO /1.22)
select MSRP/1.22 from products;

-- MOSTRA I PRODOTTI CON UN MARGINE (PREZZOPREZZO ACQUISTO) SUPERIORE A 50
select *from products where MSRP-buyPrice > 50;

-- MOSTRA I PRODOTTI CON NOMI DI ALMENO 15 CARATTERI
select *from products where length(productName) >= 15;

-- MOSTRA I PRODOTTI ORDINATI NEL MESE DI GENNAIO
select *from orders where month(orderDate) = 1;

-- MOSTRA I MODELLINI ORDINANDOLI PER PREZZO DI VENDITA CRESCENTE
select *from products order by msrp;

-- MOSTRA I CLIENTI ORDINANDOLI PER PAESE CRESCENTE E CREDITO MASSIMO DECRESCENTE
select *from customers order by country, creditLimit desc ;

-- MOSTRA GLI ORDINI ORDINANDOLI IN BASE ALLO STATUS IN CUI SI TROVANO (IN CORSO, IN ATTESA, CANCELLATI, ECC).
select status,  count(*)from orders group by status;
select  *from orders order by field(status,"On Hold","Cancelled","In Process", "Resolved", "Disputed", "Shipped" );
select  *from orders order by status;

-- MOSTRA I PRODOTTI VENDUTI A MENO DI 100€, METTENDO IN CIMA QUELLI CON IL MARGINE PIÙ ALTO
select *from products where msrp > 100 order by MSRP-buyPrice desc;

-- MOSTRA TUTTE LE CITTÀ IN CUI SI TROVANO I MIEI CLIENTI, ORDINANDOLE ALFABETICAMENTE
select distinct city from customers order by city;

-- MOSTRA PER OGNI CLIENTE IL NOME DEL VENDITORE ASSOCIATO
select customerName, firstname venditore from employees, customers
                                         where employeeNumber = salesRepEmployeeNumber;

-- MOSTRA PER OGNI CLIENTE IL NOME DEL VENDITORE ASSOCIATO
select customerName, firstName venditore from employees inner join customers
    on employeeNumber = salesRepEmployeeNumber;

-- MOSTRA PER OGNI PRODOTTO LA DESCRIZIONE DELLA LINEA DI PRODOTTI CUI APPARTIENE
select productName, textDescription from products inner  join productlines using(productLine);
select productName, textDescription from products natural  join productlines; -- Una alternativa MA pericolose!

-- MOSTRA TUTTI GLI IMPIEGATI E LA CITTÀ IN CUI SI TROVA L’UFFICIO CUI AFFERISCONO
select firstName, lastName, city from employees inner join offices using (officeCode);
select firstName, lastName, city from employees natural join offices; -- Una alternativa MA pericolose!

-- MOSTRA TUTTI I CLIENTI; SE IL CLIENTE HA UN VENDITORE ASSOCIATO, MOSTRANE I DATI
select customerName, concat( firstName," ", lastName)  employees from customers left outer join employees
    on employeeNumber = salesRepEmployeeNumber;

-- MOSTRA TUTTI I CLIENTI ED I RELATIVI ORDINI, INCLUSI I CLIENTI CHE NON HANNO FATTO ORDINI
select customerName, orderNumber from customers left join orders
    using (customerNumber) order by  orderNumber desc;

-- MOSTRA TUTTI I CLIENTI CHE NON HANNO ORDINI
select customerName from customers left join orders
    using (customerNumber) where orderNumber is null ;

-- MOSTRA TUTTI I CLIENTI ED I RELATIVI ORDINI, INCLUSI I CLIENTI CHE NON HANNO FATTO ORDINI
select customerName, orderNumber from orders right join customers
    using (customerNumber) order by orderNumber desc ;

-- MOSTRA TUTTI I CLIENTI, IL NOME DELL’IMPIEGATO ASSOCIATO ED IL NUMERO DI TELEFONO DELL’UFFICIO
select customerName, concat(firstName, " ", lastName) employees, o.phone from employees
    inner join customers on employeeNumber = salesRepEmployeeNumber
inner join offices o on o.officeCode = employees.officeCode;

-- STAMPARE OGNI RIGA DELL’ORDINE, INDICANDO IL NOME DEL CLIENTE, NUMERO D’ORDINE ED IL NOME
-- DEL PRODOTTO ORDINATO
select customerName, orderNumber, productName from customers
    inner join orders using (customerNumber) inner join orderdetails using (orderNumber)
    inner join products using (productCode);

-- MOSTRA TUTTI I DIPENDENTI ED IL NOME DEL LORO CAPO
select e1.employeeNumber, e1.firstName, e1.lastName, e1.reportsTo  ,e2.firstName,e2.lastName
    from employees e1 left join employees e2
        on e1.reportsTo = e2.employeeNumber ;

-- MOSTRA TUTTE LE COPPIE DI CLIENTI CHE ABITANO NELLA STESSA CITTÀ
select c1.city, c1.customerName, c2.customerName from customers c1 inner join customers c2
    on c1.city = c2.city where c1.customerName <> c2.customerName;

-- MOSTRA L’IDENTIFICATIVO ED IL NOME DI TUTTI GLI IMPIEGATI E DI TUTTI I CLIENTI
select employeeNumber Id, concat(firstname, " ", lastname) Name from employees
union
select customerNumber,customerName from customers;

-- MOSTRA L’ID ED IL NOME DI TUTTI GLI IMPIEGATI E DI MOSTRA L’ID ED IL NOME DI TUTTI GLI IMPIEGATI E DI
-- TUTTI I CLIENTI, SCRIVENDO PER OGNUNO COSA SIA TUTTI I CLIENTI, SCRIVENDO PER OGNUNO COSA SIA
select employeeNumber Id, concat(firstname, " ", lastname) Name, "Impiegato" Tipo from employees
union
select customerNumber,customerName, "Cliente" Tipo  from customers;

-- MOSTRARE ID E NOME DI CLIENTI ED IMPIEGATI ORDINANDOLI PER NOME
select employeeNumber Id, concat(firstname, " ", lastname) Name, "Impiegato" Tipo from employees
union
select customerNumber,customerName, "Cliente" Tipo  from customers
order by Name;

-- MOSTRARE I PAESI IN CUI C’È UN UFFICIO O UN CLIENTE, ORDINATI PER NOME
select country Name_country, "offices" Per from offices
union
select country, "Cliente" from customers
order by Name_country;

-- MOSTRA TUTTI GLI STATI DEGLI ORDINI ESISTENTI
select status, count(*) Tot from orders group by status;

-- MOSTRA TUTTI GLI STATI DEGLI ORDINI FATTI PRIMA DEL 31/12/2003
select status , count(*) from orders where orderDate < "2003/12/31" group by status;

-- QUANTI DIPENDENTI CI SONO IN AZIENDA?
select concat( "Abbiamo ", " ",count(*), " dipendenti in azienda") risposta from employees;

-- QUANTI CAPI CI SONO IN AZIENDA?
select count(jobTitle) Num_boss from employees where jobTitle <> "Sales Rep";
select count( distinct reportsTo)  Num_boss from employees;

-- QUANTI PAGAMENTI HO RICEVUTO?
select count(amount) from payments;

-- QUANTI SOLDI HO RICEVUTO CON I PAGAMENTI?
select sum(amount) from payments;

-- QUAL È IL PREZZO MEDIO DI VENDITA DI UN PRODOTTO
select productName, round(avg(msrp),3) Mean_price from products group by productName;

-- QUAL È IL PREZZO MEDIO DI VENDITA DI UN PRODOTTO? QUALE IL MASSIMO? QUALE IL MINIMO?
select avg(msrp) Mean_price, max(MSRP) max, min(msrp) min  from products ;

-- MOSTRA GLI STATI DEGLI ORDINI E QUANTI ORDINI SI TROVANO IN CIASCUNO STATO
select status,  count(*) from orders group by status;

-- MOSTRA QUANTI PRODOTTI HO PER OGNI CATEGORIA ED IL PREZZO MEDIO DI VENDITA
select productLine, count(*), avg(msrp) from products group by productLine;

-- MOSTRARE QUANTI ORDINI HO SPEDITO OGNI GIORNO
select shippedDate, count(*) from orders group by shippedDate order by shippedDate;

-- MOSTRARE QUANTI ORDINI HO SPEDITO NEI VARI MESI (UNA RIGA PER MESE)
select month(shippedDate) month, count(*) Num_spedizione from orders
        group by month(shippedDate) having month is not null order by month(shippedDate) ;

-- MOSTRARE QUANTI ORDINI HO SPEDITO NEI VARI MESI (UNA RIGA PER MESE ED ANNO)
select month(shippedDate) month,year(shippedDate) year, count(*) Num_spedizione from orders
        group by month(shippedDate),year(shippedDate) having month is not null order by month(shippedDate),year(shippedDate) ;

-- MOSTRARE PER OGNI ORDINE: IL NOME DEL CLIENTE, LA DATA DELL’ORDINE ED IL TOTALE DELL’ORDINE
select customerName, orderDate, sum(quantityOrdered*priceEach) Tot_ordine from customers join orders
    using(customerNumber) join orderdetails
        using(orderNumber) group by customerNumber, orderDate;

-- MOSTRARE QUANTI ORDINI HA FATTO OGNI CLIENTE, METTENDO IN CIMA QUELLI PIÙ ASSIDUI
select customerName, count(*) Tot_ordine from customers join orders
    using (customerNumber) group by customerNumber order by Tot_ordine desc ;

-- MOSTRARE L’ESTRATTO CONTO DEL CLIENTE 124
 --  1. estrarre i pagamenti fatti con la relativa data
select  paymentDate, amount*-1 from payments join customers using(customerNumber)
                               where customerNumber = 124 order by paymentDate;
 -- 2. prendere i totali degli ordini del cliente
select orderDate,sum(quantityOrdered * priceEach) qt_ordered from orderdetails join orders
    using (orderNumber) join customers using (customerNumber) where customerNumber = 124 group by orderDate;

-- 3. unire i due risultati, ordinandoli per data
select  paymentDate data, amount*-1 amount, "Pagato" Stato from payments join customers using(customerNumber)
                               where customerNumber = 124
union
select orderDate,sum(quantityOrdered * priceEach) qt_ordered, "da_pagare"  from orderdetails join orders
    using (orderNumber) join customers using (customerNumber) where customerNumber = 124 group by orderDate
order by data ;

-- MOSTRARE TUTTI GLI ORDINI IL CUI TOTALE È < 10.000
select orderNumber,  sum(quantityOrdered * priceeach) tot from orderdetails join orders
    using(ordernumber) group by orderNumber having tot < 10000;

-- MOSTRARE TUTTI GLI ORDINI IL CUI TOTALE È < 10.000 E PER I QUALI VERRANNO SPEDITI PIÙ DI 100 PEZZI
select orderNumber,  sum(quantityOrdered * priceeach) tot from orderdetails join orders
    using(ordernumber) group by orderNumber having tot < 10000 and sum(quantityOrdered) > 100;

-- MOSTRARE TUTTI GLI ORDINI IL CUI TOTALE È < 10.000 E CHE NON SONO STATI SPEDITI
select orderNumber, status,  sum(quantityOrdered * priceeach) tot from orderdetails join orders
    using(ordernumber) where status <> "shipped" group by orderNumber having tot < 10000;

-- MOSTRARE PER OGNI ARTICOLO IL PREZZO DI VENDITA ED IL PREZZO DEL PRODOTTO PIÙ CARO
select productName, msrp, (select max(msrp) from products) max_price from products;

-- MOSTRARE I DATI DEL PAGAMENTO PIÙ ALTO RICEVUTO
select *from payments where amount = (select max(amount) from payments);

-- MOSTRA I PAGAMENTI SUPERIORI ALLA MEDIA
select *from payments where amount > ( select avg(amount) from payments);

-- MOSTRARE I CLIENTI CHE NON HANNO FATTO ORDINI
select customerName from customers left join orders using (customerNumber) where orderDate is null ;
select customerName from customers where customerNumber not in (select customerNumber from orders);

-- MOSTRARE IL NUMERO MASSIMO, MINIMO E MEDIO DI PEZZI INSERITI NEGLI ORDINI
select *from orderdetails;
select max(yo), min(yo), avg(yo) from  (select orderNumber, sum(quantityOrdered) yo from orders join orderdetails
    using (orderNumber) group by orderNumber) v;

-- MOSTRARE I PRODOTTI IL CUI PREZZO DI ACQUISTO È SUPERIORE ALLA MEDIA DELLA LINEA CUI AFFERISCONO
select p1.productName, p1.buyPrice from products p1 where p1.buyPrice > (select avg(p2.buyPrice) from products p2 group by p2.productLine
                                                    having p1.productLine =p2.productLine );

-- MOSTRARE I PRIMI 5 CLIENTI (CODICE CLIENTE, NOME E LIMITE DI CREDITO)
select customerNumber, customerName, creditLimit from customers limit 5;

-- MOSTRARE I 5 CLIENTI CON IL CREDITO PIÙ ELEVATO
select customerNumber, customerName, creditLimit from customers order by creditLimit desc limit 5;

-- MOSTRARE IL SECONDO PRODOTTO PIÙ COSTOSO (BUYPRICE) IN LISTINO
select productName , msrp from products order by msrp desc limit 1,1;

## AGGIUNGERE DATI
-- INSERIRE UN NUOVO UFFICIO A TRIESTE
insert into offices (officeCode, city, phone, addressLine1, addressLine2, state, country, postalCode, territory)
values (333, 'Dschang', '342452', 'toleca', 'toko', 'camer', 'cameroun', 4345, "null")

select *from offices;

## DUPLICARE L’ORDINE 10425
-- 1. creare l’ordine 10426 (a mano, tabella orders)
INSERT INTO orders
VALUES (10427, '2014-11-11',
'2014-11-30', null,
'In Process',
'Duplica 10425', 119);

-- 2. prendere tutte le righe di 10425 (orderdetails)
SELECT 10427 AS numero, productCode,
quantityordered, priceEach,
orderLineNumber
FROM orderdetails
WHERE orderNumber = 10425;

-- 3. inserire tutte queste -uple nella tabella (orderdetails)
INSERT INTO orderdetails
    SELECT 10427 AS numero, productCode,
    quantityordered, priceEach,
    orderLineNumber
    FROM orderdetails
    WHERE orderNumber=10425;

select *from orderdetails;

## MODIFICARE DATI
-- CAMBIARE INDIRIZZO EMAIL A MARY PATTERSON
update employees set email ="test2@gmail.com" where employeeNumber=1056;
select *from employees where employeeNumber=1056;

-- CAMBIARE PREZZO DI ACQUISTO E VENDITA DELLA '2001 FERRARI ENZO'
update products set MSRP=MSRP+2.5, buyPrice=buyPrice+2.5 where productName= '2001 FERRARI ENZO';
select *from products where productName='2001 FERRARI ENZO';

-- AUMENTARE DEL 5% TUTTI I PREZZI DI VENDITA
update products set MSRP = MSRP / 0.75; -- grosse ereur ici !

-- - ASSOCIARE AI CLIENTI SENZA VENDITORE L’AGENTE CON MATRICOLA PIÙ ALTA (APPENA ARRIVATO)
-- 1. individuare i clienti senza venditore
select firstName, lastName, customerName from employees right join customers on salesRepEmployeeNumber = employeeNumber ;

-- 2. trovare l’agente con matricola più alta
select firstName, lastName from employees where employeeNumber = (select max(employeeNumber) from employees) and jobTitle = "sales rep";

-- -ELIMINARE DATI
-- ELIMINARE TUTTI I CLIENTI ITALIANI
select *from customers where country="Italy";
delete from customers where country="Italy"; -- Non è consentito la cancellazione degli elementi di una tabella dovuto a
 -- l esistenza dei FK nelle altre tabelle (NB: Una soluzione sarebbe l applicazione di 'delete cascad'e)


-- CREARE UNA VARIABILE DI NOME “PIPPO”, ASSEGNARCI IL VALORE “HELLO WORD!” E MOSTRARNE IN CONTENUTO
set @pippo ="Hello world";
select @pippo;

-- SALVARE NELLA VARIABILE “PREZZO” IL PREZZO PIÙ ALTO (MSRP) PRESENTE A LISTINO E MOSTRARNE IL VALORE
set @prezzo = 0;
select max(MSRP) into @prezzo from products;
select round(@prezzo,4);

-- MOSTRARE I PRODOTTI IN CUI IL VALORE MSRP È MOSTRARE I PRODOTTI IN CUI IL VALORE MSRP È
select *from products where MSRP= @prezzo;


