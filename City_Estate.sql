CREATE DATABASE CityEstate;
USE CityEstate;

CREATE TABLE Citta (
    Id_citta INT PRIMARY KEY AUTO_INCREMENT,
    Nome VARCHAR(100) NOT NULL
);

CREATE TABLE Agenzia (
    Id_agenzia INT PRIMARY KEY AUTO_INCREMENT,
    Citta INT,
    Nome VARCHAR(100) NOT NULL,
    Email VARCHAR(100),
    Telefono VARCHAR(20) NOT NULL,
    CAP VARCHAR(10),
    Via VARCHAR(100),
    FOREIGN KEY (Citta)
        REFERENCES Citta(Id_citta)
);

CREATE TABLE Cliente (
    Id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    Nome VARCHAR(100) NOT NULL,
    Cognome VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE, #crée automatiquement un indexe unique :
    CAP VARCHAR(10),
    Via VARCHAR(100),
    Citta VARCHAR(100),
    Ruolo_cliente VARCHAR(50),
    CHECK ( Ruolo_cliente IN (
        'Acquirente',
        'Affittuario',
        'Venditore',
        'Locatore' )),
    Data_registrazione DATE NOT NULL
);

CREATE TABLE Telefono_cliente (
    Id_telefono INT PRIMARY KEY AUTO_INCREMENT,
    Cliente INT,
    Telefono VARCHAR(20),
    FOREIGN KEY (Cliente)
        REFERENCES Cliente(Id_cliente)
);

CREATE TABLE Dipendente (
    Id_dipendente INT PRIMARY KEY AUTO_INCREMENT,
    Agenzia INT,
    Nome VARCHAR(100) NOT NULL,
    Cognome VARCHAR(100) NOT NULL,
    Email VARCHAR(100),
    CAP VARCHAR(10),
    Via VARCHAR(100),
    Citta VARCHAR(100),
    Matricola VARCHAR(50) UNIQUE, #crée automatiquement un indexe unique
    Stipendio DECIMAL(10,2),
    Ruolo VARCHAR(50),
    CHECK (Ruolo IN ('Agente', 'Responsabile', 'Tecnico')),
    FOREIGN KEY (Agenzia)
        REFERENCES Agenzia(Id_agenzia)
);
CREATE TABLE Telefono_dipendente (
    Id_telefono INT PRIMARY KEY AUTO_INCREMENT,
    Dipendente INT,
    Telefono VARCHAR(20),
    FOREIGN KEY (Dipendente)
        REFERENCES Dipendente(id_dipendente)
);

CREATE TABLE Immobile (
    Id_immobile INT PRIMARY KEY AUTO_INCREMENT,
    Agenzia INT,
    Via VARCHAR(100),
    CAP VARCHAR(10),
    Citta VARCHAR(100),
    Superficie DECIMAL(10,2),
    Tipologia VARCHAR(50),
    CHECK ( Tipologia IN (
        'Appartamento',
        'Villa',
        'Monolocale',
        'Bilocale',
        'Trilocale',
        'Ufficio',
        'Negozio',
        'Terreno',
        'Garage' )),
    Prezzo DECIMAL(12,2),
    Stato VARCHAR(50),
    CHECK (Stato IN ('Disponibile', 'Venduto', 'Affittato')),
    FOREIGN KEY (Agenzia)
        REFERENCES Agenzia(Id_agenzia)
);

CREATE INDEX idx_immobile_citta
ON Immobile(Citta);

CREATE INDEX idx_immobile_tipologia
ON Immobile(Tipologia);


CREATE TABLE Contratto (
    id_contratto INT PRIMARY KEY AUTO_INCREMENT,
    Cliente INT,
    Immobile INT,
    Dipendente INT,
    Data_inizio DATE,
    Data_fine DATE,
    Tipo_contratto VARCHAR(50),
    Canone DECIMAL(12,2),
    Data_firma DATE,
    CHECK ( Data_inizio < Data_fine ),
    CHECK (Tipo_contratto IN ('Vendita','Affitto')),
    CHECK (Canone > 0),

    FOREIGN KEY (Cliente)
        REFERENCES Cliente(Id_cliente),
    FOREIGN KEY (Immobile)
        REFERENCES Immobile(Id_immobile),
    FOREIGN KEY (Dipendente)
        REFERENCES Dipendente(Id_dipendente)

);
CREATE TRIGGER trg_update_stato_immobile #Trigger per aggiornare lo stato dell'immobile
    AFTER INSERT
    ON Contratto
    FOR EACH ROW
BEGIN
    IF NEW.Tipo_contratto = 'Affitto' THEN
        UPDATE Immobile
        SET Stato = 'Affittato'
        WHERE Id_immobile = NEW.Immobile;
    ELSEIF NEW.Tipo_contratto = 'Vendita' THEN
        UPDATE Immobile
        SET Stato = 'Venduto'
        WHERE Id_immobile = NEW.Immobile;
    END IF;
END;

CREATE TABLE Pagamento (
    Id_pagamento INT PRIMARY KEY AUTO_INCREMENT,
    Data_pagamento DATE  ,
    Data_limite_pagamento DATE NOT NULL ,
    Importo DECIMAL(10,2) check ( Importo > 0 ),
    Metodo VARCHAR(50),
    Stato VARCHAR(50) CHECK (
    Stato IN (
        'In attesa',
        'Pagato',
        'Annullato',
        'Rifiutato',
        'Scaduto' ))
);

CREATE EVENT aggiorna_pagamenti_scaduti
    ON SCHEDULE EVERY 1 DAY
    DO
    UPDATE Pagamento
    SET Stato = 'Scaduto'
    WHERE Data_pagamento IS NULL
      AND Data_limite_pagamento < CURDATE();

CREATE TABLE Genera (
    Contratto INT,
    Pagamento INT,
    PRIMARY KEY (Contratto, Pagamento),
    FOREIGN KEY (Contratto)
        REFERENCES Contratto(Id_contratto),
    FOREIGN KEY (Pagamento)
        REFERENCES Pagamento(Id_pagamento)
);

CREATE TABLE Manutenzione (
    Id_manutenzione INT PRIMARY KEY AUTO_INCREMENT,
    Descrizione TEXT,
    Costo DECIMAL(10,2),
    Stato VARCHAR(50)
);

CREATE TABLE Richiede (
    Manutenzione INT,
    Immobile INT,
    PRIMARY KEY (Manutenzione, Immobile),
    FOREIGN KEY (Manutenzione)
        REFERENCES Manutenzione(Id_manutenzione),
    FOREIGN KEY (Immobile)
        REFERENCES Immobile(Id_immobile)
);

CREATE TABLE Esegue (
    Dipendente INT,
    Manutenzione INT,
    PRIMARY KEY (Dipendente, Manutenzione),
    FOREIGN KEY (Dipendente)
        REFERENCES Dipendente(Id_dipendente),
    FOREIGN KEY (Manutenzione)
        REFERENCES Manutenzione(Id_manutenzione)
);
show tables;


-- query........
-- Visualizzare  tutti i contratti e pagamenti di un determinato cliente

CREATE PROCEDURE Infos_cliente (IN Client_id INT(10))
BEGIN
    SELECT c.Nome,
           c.Cognome,
           co.immobile,
           co.Tipo_contratto,
           p.importo, p.Data_pagamento, p.metodo
    from Cliente c
             join Contratto co on c.Id_cliente = co.Cliente
             join Genera g on co.id_contratto = g.contratto
             join Pagamento p on p.Id_pagamento = g.Pagamento
    where c.Id_cliente = Client_id order by p.Data_pagamento desc ;
end;

-- Analizzare i pagamenti in ritardo e identificare i clienti con rischio di insolvenza

CREATE PROCEDURE Cliente_inadempiente()
BEGIN
    SELECT c.nome, c.cognome,co.id_contratto, co.immobile, p.Importo, p.Data_limite_pagamento
    FROM Cliente c
             join Contratto co on c.Id_cliente = co.Cliente
             join Genera g on co.id_contratto = g.Contratto
             join Pagamento p on p.Id_pagamento = g.Pagamento
    where p.Stato = "scaduto";
end;

CREATE PROCEDURE Importo_dovuto_by_cliente()
BEGIN
     SELECT c.Id_cliente, SUM( p.Importo) as Tot_debito
    FROM Cliente c
             join Contratto co on c.Id_cliente = co.Cliente
             join Genera g on co.id_contratto = g.Contratto
             join Pagamento p on p.Id_pagamento = g.Pagamento
    where p.Stato = "scaduto" group by c.Id_cliente;
end;

-- Operazione 3 : “Stato operativo degli immobili (disponibili, locati, in manutenzione)”
CREATE PROCEDURE Information_immobile(IN statoo VARCHAR(10))
BEGIN
    SELECT *FROM Immobile WHERE Immobile.Stato = statoo;
end;

-- Operazione 4 : “Carico di lavoro dei dipendenti (contratti e manutenzioni)

-- Esempio: Dipendente A → 12 contratti + 5 manutenzioni
CREATE PROCEDURE Information_carico_lavoro()
BEGIN
     SELECT d.id_dipendente,
       COUNT(DISTINCT c.id_contratto) AS Tot_contratti,
       COUNT(DISTINCT e.manutenzione) AS Tot_manutenzioni
FROM Dipendente d
LEFT JOIN Contratto c ON d.id_dipendente = c.Dipendente
LEFT JOIN Esegue e ON d.id_dipendente = e.Dipendente
GROUP BY d.id_dipendente;
end;

-- trigger per il terzo vincolo
CREATE TRIGGER Non_ridondanza_contratto
    BEFORE INSERT
    ON Contratto
    FOR EACH ROW
BEGIN
    IF EXISTS (SELECT *
               FROM Contratto
               WHERE Cliente = NEW.Cliente
                 AND Immobile = NEW.Immobile
                 AND Data_inizio = NEW.Data_inizio)
    THEN
        SIGNAL SQLSTATE '45003'
            SET MESSAGE_TEXT = 'Non si può aggiungere il contratto!';
    END IF;
END;

