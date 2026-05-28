
-- Partie 6.1 : Script DDL (creation de la base)


-- on creer la base et on la selectionne
CREATE DATABASE IF NOT EXISTS centre_pilotage CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE centre_pilotage;

-- on suprrime les tables si elles existent deja
-- (ordre inverse des dependances pour eviter les erreurs de FK)
DROP TABLE IF EXISTS INSCRIPTION;
DROP TABLE IF EXISTS STAGE;
DROP TABLE IF EXISTS PILOTE;
DROP TABLE IF EXISTS VEHICULE;
DROP TABLE IF EXISTS INSTRUCTEUR;
DROP TABLE IF EXISTS CIRCUIT;

-- ==================== CIRCUIT ====================
CREATE TABLE CIRCUIT (
    id_circuit      INT             NOT NULL AUTO_INCREMENT,
    nom_circuit     VARCHAR(100)    NOT NULL,
    ville           VARCHAR(100)    NOT NULL,
    longueur_km     DECIMAL(5,2)    NOT NULL,
    capacite_max    INT             NOT NULL,
    CONSTRAINT pk_circuit PRIMARY KEY (id_circuit),
    CONSTRAINT chk_longueur CHECK (longueur_km > 0),
    CONSTRAINT chk_capacite CHECK (capacite_max > 0)
);

-- ==================== INSTRUCTEUR ====================
CREATE TABLE INSTRUCTEUR (
    id_instructeur      INT             NOT NULL AUTO_INCREMENT,
    nom_instructeur     VARCHAR(50)     NOT NULL,
    prenom_instructeur  VARCHAR(50)     NOT NULL,
    specialite          VARCHAR(100),
    CONSTRAINT pk_instructeur PRIMARY KEY (id_instructeur)
);

-- ==================== VEHICULE ====================
CREATE TABLE VEHICULE (
    id_vehicule     INT             NOT NULL AUTO_INCREMENT,
    marque          VARCHAR(50)     NOT NULL,
    modele          VARCHAR(50)     NOT NULL,
    puissance_cv    INT             NOT NULL,
    annee           INT             NOT NULL,
    CONSTRAINT pk_vehicule PRIMARY KEY (id_vehicule),
    CONSTRAINT chk_puissance CHECK (puissance_cv > 0),
    -- annee fixe car CURDATE() n'est pas supoprte dans les CHECK sous MySQL
    CONSTRAINT chk_annee CHECK (annee >= 1900 AND annee <= 2026)
);

-- ==================== PILOTE ====================
CREATE TABLE PILOTE (
    id_pilote       INT             NOT NULL AUTO_INCREMENT,
    nom_pilote      VARCHAR(50)     NOT NULL,
    prenom_pilote   VARCHAR(50)     NOT NULL,
    date_naissance  DATE            NOT NULL,
    niveau          VARCHAR(20)     NOT NULL,
    email           VARCHAR(100)    NOT NULL,
    CONSTRAINT pk_pilote PRIMARY KEY (id_pilote),
    CONSTRAINT uq_email UNIQUE (email),
    CONSTRAINT chk_niveau CHECK (niveau IN ('debutant', 'intermediaire', 'confirme', 'expert'))
);

-- ==================== STAGE ====================
-- depend de CIRCUIT et INSTRUCTEUR
CREATE TABLE STAGE (
    id_stage        INT             NOT NULL AUTO_INCREMENT,
    nom_stage       VARCHAR(100)    NOT NULL,
    date_debut      DATE            NOT NULL,
    duree_jours     INT             NOT NULL,
    nb_places_max   INT             NOT NULL,
    prix            DECIMAL(8,2)    NOT NULL,
    id_circuit      INT             NOT NULL,
    id_instructeur  INT             NOT NULL,
    CONSTRAINT pk_stage PRIMARY KEY (id_stage),
    -- on peut pas supprimer un circuit ou instructeur si y'a des stages dessus
    CONSTRAINT fk_stage_circuit FOREIGN KEY (id_circuit) REFERENCES CIRCUIT(id_circuit)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_stage_instructeur FOREIGN KEY (id_instructeur) REFERENCES INSTRUCTEUR(id_instructeur)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_duree CHECK (duree_jours > 0),
    CONSTRAINT chk_places CHECK (nb_places_max > 0),
    -- regle metier : le prix peut pas etre negatif
    CONSTRAINT chk_prix CHECK (prix >= 0)
);

-- ==================== INSCRIPTION ====================
-- table issue de l'association ternaire PILOTE - STAGE - VEHICULE
-- la PK composite garantit qu'un pilote choisit pas 2 vehicules pour le meme stage
CREATE TABLE INSCRIPTION (
    id_pilote       INT             NOT NULL,
    id_stage        INT             NOT NULL,
    id_vehicule     INT             NOT NULL,
    date_inscription DATE           NOT NULL,
    statut          VARCHAR(20)     NOT NULL,
    CONSTRAINT pk_inscription PRIMARY KEY (id_pilote, id_stage, id_vehicule),
    -- si un pilote ou un stage est suprrime, ses inscriptions partent avec
    CONSTRAINT fk_inscription_pilote FOREIGN KEY (id_pilote) REFERENCES PILOTE(id_pilote)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_inscription_stage FOREIGN KEY (id_stage) REFERENCES STAGE(id_stage)
        ON DELETE CASCADE ON UPDATE CASCADE,
    -- par contre on suprrime pas un vehicule s'il a des inscriptions
    CONSTRAINT fk_inscription_vehicule FOREIGN KEY (id_vehicule) REFERENCES VEHICULE(id_vehicule)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_statut CHECK (statut IN ('confirmee', 'en attente', 'annulee'))
);

-- ============================================================
-- Partie 6.3 : Jeu de données (DML)
-- ============================================================

-- ---------- CIRCUIT ----------
INSERT INTO CIRCUIT (nom_circuit, ville, longueur_km, capacite_max) VALUES
    ('Circuit Paul Ricard',     'Le Castellet',  5.84, 10),
    ('Circuit de Monaco',       'Monte-Carlo',   3.34,  6),
    ('Circuit de Spa',          'Stavelot',      7.00, 12),
    ('Circuit de Barcelone',    'Barcelone',     4.66,  8),
    ('Circuit de Silverstone',  'Silverstone',   5.89, 10);

-- ---------- INSTRUCTEUR ----------
INSERT INTO INSTRUCTEUR (nom_instructeur, prenom_instructeur, specialite) VALUES
    ('Dupont',   'Marc',    'Pilotage GT'),
    ('Lefevre',  'Sophie',  'Pilotage circuit'),
    ('Martin',   'Jules',   'Conduite sportive'),
    ('Bernard',  'Claire',  'Pilotage pluie'),
    ('Morin',    'Thomas',  'Depassement');

-- ---------- VEHICULE ----------
INSERT INTO VEHICULE (marque, modele, puissance_cv, annee) VALUES
    ('Ferrari',   '488 GT3',      670, 2021),
    ('Porsche',   '911 GT3 RS',   520, 2022),
    ('Lamborghini','Huracan GT3',  620, 2020),
    ('Ferrari',   'F488 Challenge',660, 2019),
    ('BMW',        'M4 GT4',       430, 2023),
    ('Aston Martin','Vantage GT4', 440, 2022),
    ('Mercedes',   'AMG GT3',      550, 2021),
    ('Porsche',    'Cayman GT4',   420, 2020);

-- ---------- PILOTE ----------
INSERT INTO PILOTE (nom_pilote, prenom_pilote, date_naissance, niveau, email) VALUES
    ('Dubois',    'Antoine',  '1990-03-12', 'confirme',    'antoine.dubois@mail.com'),
    ('Lemaire',   'Chloe',    '1995-07-22', 'debutant',    'chloe.lemaire@mail.com'),
    ('Garnier',   'Lucas',    '1988-11-05', 'expert',      'lucas.garnier@mail.com'),
    ('Petit',     'Emma',     '2000-01-30', 'debutant',    'emma.petit@mail.com'),
    ('Rousseau',  'Nathan',   '1993-06-14', 'intermediaire','nathan.rousseau@mail.com'),
    ('Simon',     'Laura',    '1985-09-08', 'confirme',    'laura.simon@mail.com'),
    ('Laurent',   'Hugo',     '1997-04-25', 'intermediaire','hugo.laurent@mail.com'),
    ('Mercier',   'Jade',     '1992-12-03', 'expert',      'jade.mercier@mail.com'),
    ('Bonnet',    'Theo',     '2001-08-17', 'debutant',    'theo.bonnet@mail.com'),
    ('Faure',     'Manon',    '1989-02-28', 'confirme',    'manon.faure@mail.com');

-- ---------- STAGE ----------
-- (id_circuit, id_instructeur) referent aux IDs inseres ci-dessus
INSERT INTO STAGE (nom_stage, date_debut, duree_jours, nb_places_max, prix, id_circuit, id_instructeur) VALUES
    ('Stage GT Debutant',       '2025-06-10', 2,  6,  890.00, 1, 1),
    ('Stage Monaco Prestige',   '2025-06-20', 1,  4, 1500.00, 2, 2),
    ('Stage Spa Intense',       '2025-07-05', 3,  8,  750.00, 3, 3),
    ('Stage Expert Barcelone',  '2025-07-15', 2,  6, 1100.00, 4, 4),
    ('Stage Silverstone Pro',   '2025-08-01', 3,  8,  980.00, 5, 5),
    ('Stage Pluie Paul Ricard', '2025-08-20', 1,  5,  650.00, 1, 4),
    ('Stage Depassement',       '2025-09-10', 2,  6,  820.00, 3, 5),
    ('Stage All-in Expert',     '2025-09-25', 4, 10, 1800.00, 5, 3);

-- ---------- INSCRIPTION ----------
-- chaque pilote choisit un vehicule disponible pour son stage
INSERT INTO INSCRIPTION (id_pilote, id_stage, id_vehicule, date_inscription, statut) VALUES
    (1, 1, 1, '2025-04-01', 'confirmee'),
    (2, 1, 2, '2025-04-02', 'confirmee'),
    (3, 2, 1, '2025-04-05', 'confirmee'),
    (4, 3, 3, '2025-04-10', 'en attente'),
    (5, 3, 4, '2025-04-11', 'confirmee'),
    (6, 4, 5, '2025-04-15', 'confirmee'),
    (7, 5, 6, '2025-04-20', 'confirmee'),
    (8, 5, 7, '2025-04-21', 'confirmee'),
    (9, 6, 2, '2025-05-01', 'en attente'),
    (10, 7, 8, '2025-05-05', 'confirmee'),
    (1, 8, 3, '2025-05-10', 'confirmee'),
    (3, 8, 7, '2025-05-12', 'annulee');
