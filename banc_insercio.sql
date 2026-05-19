-- exemple de fitxer sql per a crear una mini base de dades


-- exemple actualitzat per a obligar a treballar amb taules INNODB



insert into clients(dni,nom,cognom1,cognom2,telf,poblacio) values ('12345678L','Anna','Benet','Garcia', 977123456, 'Tarragona');
insert into clients(dni,nom,cognom1,cognom2,telf,poblacio) values ('87654321X','Pere','Beltran','Cusido', 977601212, 'Valls');
insert into clients(dni,nom,cognom1,telf,poblacio) values ('X7654321L','John','Smith', 655123456, 'Tarragona');


insert into comptes(num,dni_client,saldo) values (1234567890,'12345678L',5324.23);
insert into comptes(num,dni_client,saldo) values (0987654321,'12345678L',243.34);
insert into comptes(num,dni_client,saldo) values (1324354657,'87654321X',4768.67);
insert into comptes(num,dni_client,saldo) values (2435465768,'X7654321L',5412.23);
 
