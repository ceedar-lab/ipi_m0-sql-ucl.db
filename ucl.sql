/*********************************************************************************/
/*                                CONFIG SQLITE3                                 */
/*********************************************************************************/
.open ucl.db
.mode column
.header on

PRAGMA foreign_keys = ON;

/*********************************************************************************/
/*                             CREATION DES TABLES                               */
/*********************************************************************************/
.print              __   _______ __          ____  ____
.print             / /  / / ___// /         / _  \\/ __ \
.print            / /  / / /   / /         / / / / /_/_/
.print           / /__/ / /___/ /___  __  / /_/ / /_/ /
.print           \\____ /\\___ /\\____/ /_/ /____ /_____/
.print 
.print ******************* Création des tables ********************
.print
.print ** creation table country
-- COUNTRY : Table des pays. Permet de définir de quelle origine est un joueur ou un supporter, et à quel championnat appartient un club
CREATE TABLE country (
  id_country    INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  name          TEXT    NOT NULL,
  UNIQUE (name)
);

.print ** creation table stadium
-- STADIUM : Liste des stades et leur capacité. Seuls les stades des équipes présentes dans la table club sont chargés
CREATE TABLE stadium (
  id_stadium    INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  name          TEXT    NOT NULL,
  capacity      INTEGER NOT NULL,
  UNIQUE (name)
);

.print ** creation table club
-- CLUB : Le top 10 des clubs européens
CREATE TABLE club (
  id_club       INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  name          TEXT    NOT NULL UNIQUE,
  id_stadium    INTEGER NOT NULL,
  id_country    INTEGER NOT NULL,
  FOREIGN KEY (id_stadium) REFERENCES stadium (id_stadium)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  FOREIGN KEY (id_country) REFERENCES country (id_country)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  UNIQUE (name)
);

CREATE INDEX idx_club_country ON club (id_country);

.print ** creation table player
-- PLAYER : Regroupe 110 joueurs et leurs caracteristiques
-- Les joueurs sont titulaires dans leur équipe respective (liste des équipes dans la table club)
CREATE TABLE player (
  id_player     INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  name          TEXT    NOT NULL,
  stats         INTEGER NOT NULL,
  birthdate     TEXT    NOT NULL,
  price         INTEGER NOT NULL,
  salary        INTEGER NOT NULL,
  id_club       INTEGER,
  id_country    INTEGER NOT NULL,
  FOREIGN KEY (id_club) REFERENCES club (id_club)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  FOREIGN KEY (id_country) REFERENCES country (id_country)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  UNIQUE (name)
);

CREATE INDEX idx_player_club ON player (id_club);
CREATE INDEX idx_player_country ON player (id_country);

.print ** creation table position
-- POSITION : Permet de définir les positions préferées d'un joueur sur le terrain (0 si le joueur n'évolue pas à ce poste, 1 dans le cas contraire)
-- Par défaut sur 0. Valeurs à définir au cas par cas en fonction du joueur (pas d'AUTOINCREMENT)
-- G - GARDIEN
-- DD - DEFENSEUR DROIT / DC - DEFENSEUR CENTRAL / DG - DEFENSEUR GAUCHE
-- MDC - MILIEU DEFENSIF CENTRAL / MD - MILIEU DROIT / MG - MILIEU GAUCHE / MOC - MILIEU OFFENSIF CENTRAL
-- AD - AILIER DROIT / AG - AILIER GAUCHE / BU - BUTEUR / ATT - SECOND ATTAQUANT
CREATE TABLE position (
  id_player    INTEGER NOT NULL,
  G            INTEGER DEFAULT 0 CHECK (G = 1 OR G = 0),
  DD           INTEGER DEFAULT 0 CHECK (DD = 1 OR DD = 0),
  DC           INTEGER DEFAULT 0 CHECK (DC = 1 OR DC = 0),
  DG           INTEGER DEFAULT 0 CHECK (DG = 1 OR DG = 0),
  MDC          INTEGER DEFAULT 0 CHECK (MDC = 1 OR MDC = 0),
  MD           INTEGER DEFAULT 0 CHECK (MD = 1 OR MD = 0),
  MC           INTEGER DEFAULT 0 CHECK (MC = 1 OR MC = 0),
  MG           INTEGER DEFAULT 0 CHECK (MG = 1 OR MG = 0),
  MOC          INTEGER DEFAULT 0 CHECK (MOC = 1 OR MOC = 0),
  AD           INTEGER DEFAULT 0 CHECK (AD = 1 OR AD = 0),
  AG           INTEGER DEFAULT 0 CHECK (AG = 1 OR AG = 0),
  BU           INTEGER DEFAULT 0 CHECK (BU = 1 OR BU = 0),
  ATT          INTEGER DEFAULT 0 CHECK (ATT = 1 OR ATT = 0),
  FOREIGN KEY (id_player) REFERENCES player (id_player)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

.print ** creation table trophy
-- TROPHY : Liste des différentes récompenses et trophées pouvant être remportés par les clubs
CREATE TABLE trophy (
  id_trophy    INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  name         TEXT    NOT NULL,
  UNIQUE (name)
);

.print ** creation table prize_list
-- PRIZE_LIST : Table de jointure entre club et trophy permettant d'établir le palmares des clubs au cours des 10 dernières années
CREATE TABLE prize_list (
  year         INTEGER NOT NULL CHECK (length(year) = 4),
  id_trophy    INTEGER NOT NULL,
  id_club      INTEGER NOT NULL,
  FOREIGN KEY (id_trophy) REFERENCES trophy (id_trophy)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  FOREIGN KEY (id_club) REFERENCES club (id_club)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

CREATE INDEX idx_prizeList_trophy ON prize_list (id_trophy);
CREATE INDEX idx_prizeList_club ON prize_list (id_club);

.print ** creation table supporter
-- SUPPORTER : Liste des supporters et leurs infos perso
-- 200 personnes de nationalité française, de tous genres et de tous ages sont chargés dans cette table
CREATE TABLE supporter (
  id_supporter    INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  name            TEXT    NOT NULL,
  gender          TEXT    NOT NULL CHECK (gender = 'M' OR gender = 'F'),
  birthdate       TEXT    NOT NULL,
  adress          TEXT    NOT NULL,
  zip_code        TEXT    NOT NULL,
  city            TEXT    NOT NULL,
  id_country      INTEGER NOT NULL,
  FOREIGN KEY (id_country) REFERENCES country (id_country)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  UNIQUE (name)
);

CREATE INDEX idx_supporter_city ON supporter (city);
CREATE INDEX idx_supporter_zipCode ON supporter (zip_code);
CREATE INDEX idx_supporter_country ON supporter (id_country);
CREATE INDEX idx_supporter_gender ON supporter (gender);

.print ** creation table subscriber_list
-- SUBSCIBER_LIST : Table de jointure entre supporter et stadium. Permet d'établir la liste des supporters bénéficiant d'abonnements
-- Étant donnée qu'il n'y a que des supporters français dans la table supporter, tous les abonnés présents dans cette table sont abonnés au Parc des Princes
CREATE TABLE subscriber_list (
  tribune         TEXT    NOT NULL,
  id_supporter    INTEGER NOT NULL,
  id_stadium      INTEGER NOT NULL,
  FOREIGN KEY (id_supporter) REFERENCES supporter (id_supporter)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  FOREIGN KEY (id_stadium) REFERENCES stadium (id_stadium)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

CREATE INDEX idx_subscriber_stadium ON subscriber_list (id_stadium);
CREATE INDEX idx_subscriber_tribune ON subscriber_list (tribune);


/*********************************************************************************/
/*                            CHARGEMENT DES TABLES                              */
/*********************************************************************************/

.print
.print ****************** Chargement des données ******************
.print
.print ** chargement dans country
-- Remplissage de la table COUNTRY
INSERT INTO country (name) VALUES ('Albanie');
INSERT INTO country (name) VALUES ('Algérie');
INSERT INTO country (name) VALUES ('Allemagne');
INSERT INTO country (name) VALUES ('Angleterre');
INSERT INTO country (name) VALUES ('Argentine');
INSERT INTO country (name) VALUES ('Autriche');
INSERT INTO country (name) VALUES ('Belgique');
INSERT INTO country (name) VALUES ('Bosnie-Herzégovine');
INSERT INTO country (name) VALUES ('Brésil');
INSERT INTO country (name) VALUES ('Cameroun');
INSERT INTO country (name) VALUES ('Canada');
INSERT INTO country (name) VALUES ('Colombie');
INSERT INTO country (name) VALUES ('Corée du Sud');
INSERT INTO country (name) VALUES ('Costa Rica');
INSERT INTO country (name) VALUES ('Croatie');
INSERT INTO country (name) VALUES ('Côte d''Ivoire');
INSERT INTO country (name) VALUES ('Danemark');
INSERT INTO country (name) VALUES ('Ecosse');
INSERT INTO country (name) VALUES ('Egypte');
INSERT INTO country (name) VALUES ('Espagne');
INSERT INTO country (name) VALUES ('Etats-Unis');
INSERT INTO country (name) VALUES ('France');
INSERT INTO country (name) VALUES ('Ghana');
INSERT INTO country (name) VALUES ('Grèce');
INSERT INTO country (name) VALUES ('Guinée');
INSERT INTO country (name) VALUES ('Italie');
INSERT INTO country (name) VALUES ('Japon');
INSERT INTO country (name) VALUES ('Maroc');
INSERT INTO country (name) VALUES ('Mexique');
INSERT INTO country (name) VALUES ('Monténégro');
INSERT INTO country (name) VALUES ('Nigeria');
INSERT INTO country (name) VALUES ('Norvège');
INSERT INTO country (name) VALUES ('Pays de Galles');
INSERT INTO country (name) VALUES ('Pays-Bas');
INSERT INTO country (name) VALUES ('Pologne');
INSERT INTO country (name) VALUES ('Portugal');
INSERT INTO country (name) VALUES ('Rép. d''Irlande');
INSERT INTO country (name) VALUES ('Rép. dominicaine');
INSERT INTO country (name) VALUES ('Serbie');
INSERT INTO country (name) VALUES ('Slovénie');
INSERT INTO country (name) VALUES ('Suisse');
INSERT INTO country (name) VALUES ('Suède');
INSERT INTO country (name) VALUES ('Sénégal');
INSERT INTO country (name) VALUES ('Tunisie');
INSERT INTO country (name) VALUES ('Turquie');
INSERT INTO country (name) VALUES ('Ukraine');
INSERT INTO country (name) VALUES ('Uruguay');

.print ** chargement dans stadium
-- Remplissage de la table STADIUM
INSERT INTO stadium (name, capacity) VALUES ('Parc des Princes', 47929);
INSERT INTO stadium (name, capacity) VALUES ('Juventus Stadium', 41507);
INSERT INTO stadium (name, capacity) VALUES ('Allianz Arena', 75024);
INSERT INTO stadium (name, capacity) VALUES ('Anfield', 54074);
INSERT INTO stadium (name, capacity) VALUES ('Stamford Bridge', 41837);
INSERT INTO stadium (name, capacity) VALUES ('Wanda Metropolitano', 68456);
INSERT INTO stadium (name, capacity) VALUES ('Etihad Stadium', 55097);
INSERT INTO stadium (name, capacity) VALUES ('Santiago Bernabéu', 81044);
INSERT INTO stadium (name, capacity) VALUES ('Camp Nou', 99354);
INSERT INTO stadium (name, capacity) VALUES ('Tottenham Hotspur Stadium', 62303);

.print ** chargement dans club
-- Remplissage de la table CLUB
INSERT INTO club (name, id_stadium, id_country) VALUES ('Liverpool', 4, 4);
INSERT INTO club (name, id_stadium, id_country) VALUES ('Manchester City', 7, 4);
INSERT INTO club (name, id_stadium, id_country) VALUES ('Real Madrid CF', 8, 20);
INSERT INTO club (name, id_stadium, id_country) VALUES ('FC Bayern Munich', 3, 3);
INSERT INTO club (name, id_stadium, id_country) VALUES ('FC Barcelona', 9, 20);
INSERT INTO club (name, id_stadium, id_country) VALUES ('Juventus', 2, 26);
INSERT INTO club (name, id_stadium, id_country) VALUES ('Paris Saint-Germain', 1, 22);
INSERT INTO club (name, id_stadium, id_country) VALUES ('Atlético de Madrid', 6, 20);
INSERT INTO club (name, id_stadium, id_country) VALUES ('Tottenham Hotspur', 10, 4);
INSERT INTO club (name, id_stadium, id_country) VALUES ('Chelsea', 5, 4);

.print ** chargement dans player
-- Remplissage de la table PLAYER
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Alisson', 90, '1992-10-02', 102000000, 160000, 1, 9);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Trent Alexander-Arnold', 87, '1998-10-07', 114000000, 110000, 1, 4);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Joe Gomez', 83, '1997-05-23', 49500000, 95000, 1, 4);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Virgil van Dijk', 90, '1991-07-08', 113000000, 210000, 1, 34);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Andrew Robertson', 87, '1994-03-11', 90500000, 155000, 1, 18);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Fabinho', 87, '1993-10-23', 88500000, 155000, 1, 9);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Jordan Henderson', 86, '1990-06-17', 57000000, 140000, 1, 4);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Georginio Wijnaldum', 85, '1990-11-11', 52500000, 150000, 1, 34);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Roberto Firmino', 87, '1991-10-02', 81500000, 190000, 1, 9);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Mohamed Salah', 90, '1992-06-15', 120500000, 245000, 1, 19);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Sadio Mané', 90, '1992-04-10', 120500000, 245000, 1, 43);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Ederson', 88, '1993-08-17', 92000000, 195000, 2, 9);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Kyle Walker', 85, '1990-05-28', 46500000, 170000, 2, 4);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Fernandinho', 84, '1985-05-04', 11000000, 110000, 2, 9);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Aymeric Laporte', 87, '1994-05-27', 92500000, 200000, 2, 22);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Benjamin Mendy', 81, '1994-07-17', 31500000, 115000, 2, 22);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Rodri', 85, '1996-06-22', 66500000, 145000, 2, 20);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Kevin De Bruyne', 91, '1991-06-28', 129000000, 370000, 2, 7);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Bernardo Silva', 87, '1994-08-10', 95000000, 230000, 2, 36);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Riyad Mahrez', 85, '1991-02-21', 53000000, 210000, 2, 2);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Gabriel Jesus', 83, '1997-04-03', 52500000, 150000, 2, 9);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Raheem Sterling', 88, '1994-12-08', 114500000, 270000, 2, 4);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Thibaut Courtois', 89, '1992-05-11', 82000000, 250000, 3, 7);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Carvajal', 86, '1992-01-11', 61500000, 230000, 3, 20);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Raphaël Varane', 86, '1993-04-25', 72500000, 220000, 3, 22);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Sergio Ramos', 89, '1986-03-30', 33500000, 300000, 3, 20);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Ferland Mendy', 83, '1995-06-08', 49500000, 160000, 3, 22);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Casemiro', 89, '1992-02-23', 90500000, 310000, 3, 9);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Luka Modric', 87, '1985-09-09', 36500000, 260000, 3, 15);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Toni Kroos', 88, '1990-01-04', 87500000, 310000, 3, 3);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Karim Benzema', 89, '1987-12-19', 83500000, 350000, 3, 22);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Rodrygo', 79, '2001-01-09', 38000000, 90000, 3, 9);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Vinicius Jr.', 80, '2000-07-12', 50000000, 95000, 3, 9);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Manuel Neuer', 89, '1986-03-27', 17500000, 125000, 4, 3);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Benjamin Pavard', 81, '1996-03-28', 34500000, 65000, 4, 22);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Jérôme Boateng', 82, '1988-09-03', 21000000, 80000, 4, 3);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('David Alaba', 84, '1992-06-24', 36500000, 105000, 4, 6);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Alphonso Davies', 81, '2000-11-02', 53000000, 40000, 4, 11);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Joshua Kimmich', 88, '1995-02-08', 103000000, 145000, 4, 3);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Leon Goretzka', 84, '1995-02-06', 58500000, 105000, 4, 3);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Serge Gnabry', 85, '1995-07-14', 70000000, 100000, 4, 3);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Leroy Sané', 85, '1996-01-11', 81500000, 100000, 4, 3);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Thomas Müller', 86, '1989-09-13', 65500000, 130000, 4, 3);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Robert Lewandowski', 91, '1988-08-21', 111000000, 240000, 4, 35);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Marc-André ter Stegen', 90, '1992-04-30', 110000000, 260000, 5, 3);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Sergi Roberto', 83, '1992-02-07', 33000000, 175000, 5, 20);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Piqué', 86, '1987-02-02', 32500000, 220000, 5, 20);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Clément Lenglet', 85, '1995-06-17', 67000000, 190000, 5, 22);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Jordi Alba', 86, '1989-03-21', 49500000, 220000, 5, 20);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Sergio Busquets', 87, '1988-07-16', 56000000, 235000, 5, 20);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Frenkie de Jong', 85, '1997-05-12', 81000000, 190000, 5, 34);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Coutinho', 83, '1992-06-12', 36500000, 190000, 5, 9);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Antoine Griezmann', 87, '1991-03-21', 79500000, 290000, 5, 22);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Lionel Messi', 93, '1987-06-24', 103500000, 560000, 5, 5);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Ansu Fati', 76, '2002-10-31', 17000000, 23500, 5, 20);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Wojciech Szczesny', 87, '1990-04-18', 53000000, 105000, 6, 35);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Danilo', 79, '1991-07-15', 16000000, 75000, 6, 9);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Leonardo Bonucci', 85, '1987-05-01', 26000000, 110000, 6, 26);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Giorgio Chiellini', 87, '1984-08-14', 21000000, 95000, 6, 26);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Weston McKennie', 75, '1998-08-28', 12500000, 43000, 6, 21);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Adrien Rabiot', 81, '1995-04-03', 30500000, 85000, 6, 22);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Dejan Kulusevski', 77, '2000-04-25', 23000000, 55000, 6, 42);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Juan Cuadrado', 81, '1988-05-26', 18000000, 80000, 6, 12);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Aaron Ramsey', 82, '1990-12-26', 29500000, 100000, 6, 33);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Paulo Dybala', 88, '1993-11-15', 109000000, 190000, 6, 5);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Cristiano Ronaldo', 92, '1985-02-05', 63000000, 215000, 6, 36);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Keylor Navas', 87, '1986-12-15', 26000000, 110000, 7, 14);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Alessandro Florenzi', 81, '1991-03-11', 22500000, 85000, 7, 26);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Marquinhos', 85, '1994-05-14', 66000000, 115000, 7, 9);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Presnel Kimpembe', 81, '1995-08-13', 33000000, 70000, 7, 22);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Mitchel Bakker', 69, '2000-06-20', 2900000, 18500, 7, 34);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Idrissa Gueye', 84, '1989-09-26', 35500000, 105000, 7, 43);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Marco Verratti', 86, '1992-11-05', 77500000, 135000, 7, 26);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Angel Di Maria', 87, '1988-02-14', 63000000, 160000, 7, 5);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Mauro Icardi', 85, '1993-02-19', 63000000, 135000, 7, 5);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Kylian Mbappé', 90, '1998-12-20', 185500000, 160000, 7, 22);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Neymar Jr', 91, '1992-02-05', 132000000, 270000, 7, 9);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Jan Oblak', 91, '1993-01-07', 120000000, 125000, 8, 40);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Kieran Trippier', 83, '1990-09-19', 32000000, 70000, 8, 4);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Stefan Savic', 81, '1991-01-08', 24000000, 60000, 8, 30);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Felipe', 84, '1989-05-16', 29000000, 75000, 8, 9);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Renan Lodi', 81, '1998-04-08', 38500000, 49000, 8, 9);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Angel Correa', 82, '1995-03-09', 40500000, 65000, 8, 5);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Koke', 85, '1992-01-08', 54000000, 90000, 8, 20);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Saùl', 84, '1994-11-21', 55500000, 75000, 8, 20);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Yannick Carrasco', 82, '1993-09-04', 33500000, 65000, 8, 7);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Luis Suàrez', 87, '1987-01-24', 51000000, 115000, 8, 47);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Joao Félix', 81, '1999-11-10', 62500000, 50000, 8, 36);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Hugo Lloris', 87, '1986-12-26', 26000000, 125000, 9, 22);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Matt Doherty', 81, '1992-01-16', 23500000, 95000, 9, 37);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Toby Alderweireld', 85, '1989-03-02', 37000000, 130000, 9, 7);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Eric Dier', 78, '1994-01-15', 17500000, 75000, 9, 4);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Reguilon', 82, '1996-12-16', 58000000, 85000, 9, 20);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Pierre-Emile Hojbjerg', 80, '1995-08-05', 27500000, 75000, 9, 17);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Harry Winks', 79, '1996-02-02', 24500000, 70000, 9, 4);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Lucas Moura', 83, '1992-08-13', 38500000, 120000, 9, 9);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Heung Min Son', 87, '1992-07-08', 85000000, 165000, 9, 13);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Giovani Lo Celso', 82, '1996-04-09', 46000000, 95000, 9, 5);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Harry Kane', 88, '1993-07-28', 109000000, 220000, 9, 4);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Kepa', 82, '1994-10-03', 33500000, 75000, 10, 20);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Azpilicueta', 84, '1989-08-28', 36500000, 120000, 10, 20);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Andreas Christensen', 79, '1996-04-10', 24000000, 70000, 10, 17);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Kurt Zouma', 80, '1994-10-27', 25000000, 80000, 10, 22);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Marcos Alonso', 81, '1990-12-28', 22500000, 95000, 10, 20);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('N''Golo Kanté', 88, '1991-03-29', 78000000, 190000, 10, 22);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Jorginho', 83, '1991-12-20', 36500000, 125000, 10, 26);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Callum Hudson-Odoi', 74, '2000-11-07', 10000000, 40000, 10, 4);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Mason Mount', 80, '1999-01-10', 43000000, 70000, 10, 4);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Kai Havertz', 85, '1999-06-11', 121000000, 105000, 10, 3);
INSERT INTO player (name, stats, birthdate, price, salary, id_club, id_country) VALUES ('Timo Werner', 85, '1996-03-06', 74500000, 135000, 10, 3);

.print ** chargement dans position
-- Remplissage de la table POSITION
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (2, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (3, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (4, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (5, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (6, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (7, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (8, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (12, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (13, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (14, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (15, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (16, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (17, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (18, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (19, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (20, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (21, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (22, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (23, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (24, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (25, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (26, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (27, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (28, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (29, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (30, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (31, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (33, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (34, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (35, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (36, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (37, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (38, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (39, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (40, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (41, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (42, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (43, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (44, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (45, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (46, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (47, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (48, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (49, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (50, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (51, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (52, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (53, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (54, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (55, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (56, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (57, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (58, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (59, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (60, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (61, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (62, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (63, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (64, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (65, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (66, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (67, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (68, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (69, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (70, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (71, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (72, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (73, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (74, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (75, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (76, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (77, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (78, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (79, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (80, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (81, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (82, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (83, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (84, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (85, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (86, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (87, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (88, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (89, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (90, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (91, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (92, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (93, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (94, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (95, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (96, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (97, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (98, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (99, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (100, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (101, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (102, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (103, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (104, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (105, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (106, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (107, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (108, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (109, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1);
INSERT INTO position (id_player, G, DD, DC, DG, MDC, MD, MC, MG, MOC, AD, AG, BU, ATT) VALUES (110, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0);

.print ** chargement dans trophy
-- Remplissage de la table TROPHY
INSERT INTO trophy (name) VALUES ('Ligue des Champions');
INSERT INTO trophy (name) VALUES ('Ligue Europa');
INSERT INTO trophy (name) VALUES ('Championnat National');
INSERT INTO trophy (name) VALUES ('Coupe Nationale');

.print ** chargement dans prize_list
-- Remplissage de la table PRIZE_LIST
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2020, 1, 4);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2019, 1, 1);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2018, 1, 3);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2017, 1, 3);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2016, 1, 3);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2015, 1, 5);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2014, 1, 3);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2013, 1, 4);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2012, 1, 10);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2011, 1, 5);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2019, 2, 10);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2018, 2, 8);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2013, 2, 10);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2012, 2, 8);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2020, 3, 7);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2019, 3, 7);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2018, 3, 7);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2016, 3, 7);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2015, 3, 7);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2014, 3, 7);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2013, 3, 7);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2020, 3, 3);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2019, 3, 5);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2018, 3, 5);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2017, 3, 3);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2016, 3, 5);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2015, 3, 5);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2014, 3, 8);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2013, 3, 5);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2012, 3, 3);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2011, 3, 5);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2020, 3, 4);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2019, 3, 4);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2018, 3, 4);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2017, 3, 4);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2016, 3, 4);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2015, 3, 4);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2014, 3, 4);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2013, 3, 4);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2020, 3, 6);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2019, 3, 6);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2018, 3, 6);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2017, 3, 6);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2016, 3, 6);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2015, 3, 6);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2014, 3, 6);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2013, 3, 6);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2012, 3, 6);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2020, 3, 1);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2019, 3, 2);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2018, 3, 2);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2017, 3, 10);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2015, 3, 10);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2014, 3, 2);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2012, 3, 2);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2020, 4, 7);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2018, 4, 7);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2017, 4, 7);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2016, 4, 7);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2015, 4, 7);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2018, 4, 5);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2017, 4, 5);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2016, 4, 5);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2015, 4, 5);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2014, 4, 3);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2013, 4, 8);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2012, 4, 5);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2011, 4, 3);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2019, 4, 2);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2018, 4, 10);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2012, 4, 10);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2011, 4, 2);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2020, 4, 4);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2019, 4, 4);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2016, 4, 4);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2014, 4, 4);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2013, 4, 4);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2018, 4, 6);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2017, 4, 6);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2016, 4, 6);
INSERT INTO prize_list (year, id_trophy, id_club) VALUES (2015, 4, 6);

.print ** chargement dans supporter
-- Remplissage de la table SUPPORTER
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Georges Gicquel', 'M', '1961-05-17', '65 rue du Faubourg National', '13400', 'Aubagne', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Jean-Louis Duhamel', 'M', '1961-06-23', '61 rue du Château', '59640', 'Dunkerque', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Jocelyn Bacque', 'M', '1962-02-12', '76 rue de la Mare aux Carats', '12000', 'Rodez', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Aurélien Rouanet', 'M', '1963-03-08', '55 avenue du Marechal Juin', '59220', 'Denain', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Gwenaël Bousquet', 'M', '1965-11-12', '46 boulevard Albin Durand', '59190', 'Hazebrouck', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Gaylord Charpentier', 'M', '1967-02-22', '93 Rue Hubert de Lisle', '91100', 'Corbeil-essonnes', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Bernard D''Amboise', 'M', '1969-07-22', '13 Avenue des Tuileries', '69150', 'Décines-charpieu', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Fabien Seyrès', 'M', '1969-08-11', '94 Place Charles de Gaulle', '69100', 'Villeurbanne', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Paulin Millet', 'M', '1972-05-05', '87 quai Saint-Nicolas', '93400', 'Saint-ouen', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Jean-Claude Rochette', 'M', '1974-01-04', '58 rue Gustave Eiffel', '94100', 'Saint-maur-des-fossès', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Fernand Hennequin', 'M', '1975-04-15', '43 rue Clement Marot', '30900', 'Nîmes', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Luc Philippon', 'M', '1976-02-18', '71 Rue du Palais', '93000', 'Bobigny', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Maxime Courtial', 'M', '1978-04-05', '34 rue Clement Marot', '30900', 'Nîmes', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Achille Chevalier', 'M', '1978-08-30', '12 rue Ernest Renan', '93290', 'Tremblay-en-france', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Évrard Boulle', 'M', '1980-06-10', '57 rue de Penthièvre', '93370', 'Montfermeil', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Thibault Neri', 'M', '1982-01-28', '27 Rue Bonnet', '75007', 'Paris', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Étienne Génin', 'M', '1982-07-16', '2 rue Gontier-Patin', '42000', 'Saint-étienne', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Matthieu Berger', 'M', '1982-09-07', '6 Rue du Limas', '93200', 'Saint-denis', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Stéphane Delannoy', 'M', '1984-01-12', '48 rue du Fossé des Tanneurs', '38500', 'Voiron', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Maxime Cartier', 'M', '1984-08-22', '80 boulevard Albin Durand', '57070', 'Metz', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Jean-Baptiste Pomeroy', 'M', '1987-08-24', '66 rue des Chaligny', '80090', 'Amiens', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Antoine Celice', 'M', '1994-04-04', '1 rue Clement Marot', '97438', 'Sainte-marie', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Wilfried Chapelle', 'M', '1995-05-30', '48 rue de Geneve', '59650', 'Villeneuve-d''ascq', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Hugues Leavitt', 'M', '1999-03-04', '27 Boulevard de Normandie', '76620', 'Le Havre', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Denis Besnard', 'M', '1999-06-11', '89 rue des Soeurs', '01100', 'Oyonnax', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Blaise Côté', 'M', '1980-06-17', '19 rue du Paillle en queue', '57600', 'Forbach', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Bruno Bertillon', 'M', '1980-09-25', '40 Rue Hubert de Lisle', '77176', 'Savigny-le-temple', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Baudouin Mallette', 'M', '1982-07-20', '54 rue Marie de Médicis', '25200', 'Montbéliard', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Thibaut Longchambon', 'M', '1984-03-08', '30 rue Charles Corbeau', '92210', 'Saint-cloud', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Mathéo Asselineau', 'M', '1986-01-07', '40 place Stanislas', '13300', 'Salon-de-provence', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Loïc Gilson', 'M', '1986-01-21', '98 rue de la Boétie', '90000', 'Belfort', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Jean-Claude Duverger', 'M', '1988-02-29', '78 boulevard de Prague', '97610', 'Dzaoudzi', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Mathieu Baume', 'M', '1989-06-14', '73 rue Marie de Médicis', '21200', 'Beaune', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Benoît Dubost', 'M', '1989-10-03', '63 rue du Paillle en queue', '37200', 'Tours', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Denis Girault', 'M', '1989-12-11', '98 Avenue des Près', '45400', 'Fleury-les-aubrais', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Bruno Girault', 'M', '1991-04-04', '31 Rue de Strasbourg', '93800', 'Épinay-sur-seine', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Olivier Gauthier', 'M', '1993-09-14', '48 Place de la Gare', '33260', 'La Teste-de-buch', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Martial Crépin', 'M', '1994-09-09', '42 rue des Lacs', '34400', 'Lunel', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Bruno Rousselle', 'M', '1996-06-25', '29 avenue Jules Ferry', '93130', 'Noisy-le-sec', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Gaël Thibodeau', 'M', '1997-06-25', '79 rue Gouin de Beauchesne', '59200', 'Tourcoing', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Romuald Bourguignon', 'M', '1998-11-02', '55 rue de Lille', '59210', 'Coudekerque-branche', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Gwenaël Auguste', 'M', '1961-05-02', '5 Avenue Millies Lacroix', '92350', 'Le Plessis-robinson', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Moïse Garnier', 'M', '1962-05-25', '44 rue de Groussay', '75020', 'Paris', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Élisée Philidor', 'M', '1962-09-04', '96 Cours Marechal-Joffre', '52100', 'Saint-dizier', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Bruno Bourgeois', 'M', '1963-05-14', '99 Avenue des Tuileries', '33000', 'Bordeaux', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Mickaël Beaubois', 'M', '1966-07-08', '58 rue Victor Hugo', '76000', 'Rouen', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Jean-Yves Lozé', 'M', '1966-11-11', '44 Cours Marechal-Joffre', '74200', 'Thonon-les-bains', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Raoul Manoury', 'M', '1969-05-26', '84 rue Marguerite', '92000', 'Nanterre', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Zacharie Bougie', 'M', '1970-09-04', '32 rue Gouin de Beauchesne', '57000', 'Metz', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Axel Bachelet', 'M', '1976-05-14', '53 rue des Dunes', '56600', 'Lanester', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Alphonse Popelin', 'M', '1985-02-21', '92 boulevard de Prague', '80100', 'Abbeville', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Benjamin Raoult', 'M', '1993-02-09', '23 rue des Nations Unies', '94120', 'Fontenay-sous-bois', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Remi Micheaux', 'M', '1982-01-26', '26 boulevard Amiral Courbet', '95140', 'Garges-lès-gonesse', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Alexandre Joguet', 'M', '1985-04-10', '11 Boulevard de Normandie', '91270', 'Vigneux-sur-seine', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Jean Bescond', 'M', '1987-04-07', '36 rue Bonneterie', '91120', 'Palaiseau', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Remy Colbert', 'M', '1990-04-04', '74 rue des Nations Unies', '45100', 'Orléans', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Lambert Barrault', 'M', '1992-04-22', '55 rue des six frères Ruellan', '13002', 'Marseille', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Napoléon Bonhomme', 'M', '1992-07-07', '5 rue Jean Vilar', '35400', 'Saint-malo', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Raymond Grandis', 'M', '1993-02-24', '91 Avenue Millies Lacroix', '83100', 'Toulon', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Brice Barbeau', 'M', '1994-02-21', '78 Rue du Limas', '06150', 'Cannes-la-bocca', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Gabriel Darche', 'M', '1996-09-23', '98 avenue Jean Portalis', '92110', 'Clichy', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Théophile Dutoit', 'M', '1976-02-04', '60 rue Charles Corbeau', '31100', 'Toulouse', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Fabien Vigouroux', 'M', '1977-12-16', '32 Rue du Palais', '38200', 'Vienne', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Marius Galopin', 'M', '1978-05-31', '27 rue du Clair Bocage', '69008', 'Lyon', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Raphaël Beauchamp', 'M', '1979-05-03', '84 Rue Hubert de Lisle', '17300', 'Rochefort', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Gaby Boulanger', 'M', '1980-04-30', '72 Rue Roussy', '97470', 'Saint-benoît', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Roch Barrault', 'M', '1981-05-20', '29 quai Saint-Nicolas', '91350', 'Grigny', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Gaspard Baume', 'M', '1990-04-30', '32 rue Victor Hugo', '94400', 'Vitry-sur-seine', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Milo Anouilh', 'M', '1996-07-10', '61 rue Adolphe Wurtz', '97436', 'Saint-leu', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Jean-Philippe Devillers', 'M', '1997-01-17', '11 Faubourg Saint Honoré', '13002', 'Marseille', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Djeferson Longchambon', 'M', '1997-10-02', '49 rue Pierre Motte', '59300', 'Valenciennes', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Jocelyn Courtet', 'M', '1999-01-12', '21 avenue de l''Amandier', '97232', 'Le Lamentin', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Ernest Rousseau', 'M', '1990-07-18', '6 rue de l''Epeule', '62100', 'Calais', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Hugues Corriveau', 'M', '1991-06-14', '66 rue du Fossé des Tanneurs', '78280', 'Guyancourt', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Ernest Baillieu', 'M', '1992-06-19', '96 place Stanislas', '95190', 'Goussainville', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Victor Veil', 'M', '1993-04-19', '84 Place Napoléon', '94270', 'Le Kremlin-bicÊtre', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Nathanaël Jacquet', 'M', '1968-08-15', '91 rue Petite Fusterie', '75007', 'Paris', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Thierry Bassot', 'M', '1971-12-08', '45 rue Léon Dierx', '92100', 'Boulogne-billancourt', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Florentin Devereaux', 'M', '1973-02-26', '45 boulevard Aristide Briand', '88000', 'Épinal', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Émile Beauvilliers', 'M', '1973-04-02', '18 rue Sébastopol', '77380', 'Combs-la-ville', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Renaud Serre', 'M', '1973-06-19', '98 rue de Geneve', '76610', 'Le Havre', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Gaston Aveline', 'M', '1974-02-22', '8 rue Reine Elisabeth', '69120', 'Vaulx-en-velin', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Lucas Clérisseau', 'M', '1974-09-10', '63 Boulevard de Normandie', '35400', 'Saint-malo', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Évrard Trottier', 'M', '1979-08-17', '35 rue Beauvau', '69008', 'Lyon', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Silvain Courbis', 'M', '1980-11-14', '90 rue Victor Hugo', '59000', 'Lille', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Édouard Larousse', 'M', '1965-09-30', '75 rue Marie de Médicis', '75001', 'Paris', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Enzo Gaubert', 'M', '1966-11-10', '6 Place Napoléon', '78150', 'Le Chesnay', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Mathieu Gaubert', 'M', '1967-03-27', '11 rue de Penthièvre', '36000', 'Châteauroux', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Hector Édouard', 'M', '1967-10-10', '13 Avenue Millies Lacroix', '91300', 'Massy', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Pierre-Louis Adnet', 'M', '1973-04-16', '44 rue Saint Germain', '95190', 'Goussainville', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Théophile Dubois', 'M', '1974-08-26', '73 Place du Jeu de Paume', '93210', 'La Plaine-saint-denis', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Maxime Boudet', 'M', '1978-11-13', '91 rue de Lille', '76140', 'Le Petit-quevilly', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Henri Boutet', 'M', '1982-05-12', '43 rue des Dunes', '92110', 'Clichy', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Armand Bechard', 'M', '1983-06-28', '13 rue du Fossé des Tanneurs', '75004', 'Paris', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Paul Flandin', 'M', '1985-12-11', '73 Rue Marie De Médicis', '95600', 'Eaubonne', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Mathéo Carpentier', 'M', '1988-09-14', '59 rue Banaudon', '76610', 'Le Havre', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Raoul Darche', 'M', '1971-11-18', '47 avenue du Marechal Juin', '75005', 'Paris', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Mathéo Vaganay', 'M', '1976-05-13', '90 avenue de Provence', '75002', 'Paris', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Jean-Baptiste Beaulne', 'M', '1979-10-29', '98 rue Michel Ange', '91330', 'Yerres', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Matthias Trémaux', 'M', '1985-06-18', '2 rue Gustave Eiffel', '97410', 'Saint-pierre', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Fabien Bonhomme', 'M', '1993-03-02', '62 Place de la Gare', '95130', 'Franconville-la-garenne', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Florent Magnier', 'M', '1973-04-20', '73 boulevard Aristide Briand', '59100', 'Roubaix', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Maurice Beaumanoir', 'M', '1977-09-02', '18 rue du Gue Jacquet', '62300', 'Lens', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Yvon Léger', 'M', '1979-04-16', '88 Quai des Belges', '59240', 'Dunkerque', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Gaston Lortie', 'M', '1984-01-02', '39 rue Jean-Monnet', '83140', 'Six-fours-les-plages', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Killian Piaget', 'M', '1984-02-17', '32 rue de l''Aigle', '27000', 'Évreux', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Sylvain Parmentier', 'M', '1985-09-12', '90 rue Adolphe Wurtz', '94120', 'Fontenay-sous-bois', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Dylan Lucroy', 'M', '1987-06-30', '70 rue Adolphe Wurtz', '59240', 'Dunkerque', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Eugène Auclair', 'M', '1989-05-17', '78 Quai des Belges', '33500', 'Libourne', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Geoffroy Berengar', 'M', '1999-10-14', '67 rue Bonneterie', '57100', 'Thionville', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Inès Suchet', 'F', '1970-09-11', '90 Rue de Strasbourg', '93260', 'Les Lilas', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Gaëtane Benett', 'F', '1975-03-17', '61 rue Nationale', '69200', 'Vénissieux', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Brigitte Carrell', 'F', '1978-09-01', '40 Avenue Millies Lacroix', '27000', 'Évreux', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Céleste Berthelot', 'F', '1980-08-26', '29 Rue Bonnet', '92170', 'Vanves', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Clémence Vallotton', 'F', '1980-09-15', '93 rue de la Mare aux Carats', '62300', 'Lens', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Pauline Plouffe', 'F', '1984-11-27', '79 rue de la Boétie', '59280', 'Armentières', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Lisa Chardin', 'F', '1985-03-07', '22 rue Michel Ange', '59493', 'Villeneuve-d''ascq', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Vanessa Guilbert', 'F', '1985-04-09', '68 avenue Voltaire', '95000', 'Cergy', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Héloïse Coquelin', 'F', '1986-11-25', '22 rue Lenotre', '95150', 'Taverny', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Agnès Hémery', 'F', '1987-11-30', '25 avenue de Provence', '38600', 'Fontaine', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Mégane Niel', 'F', '1988-10-25', '6 boulevard Aristide Briand', '71100', 'Chalon-sur-saône', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Auriane Chabert', 'F', '1989-03-08', '58 rue Nationale', '35300', 'Fougères', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Marie-Louise Blondeau', 'F', '1989-09-07', '99 boulevard Bryas', '12100', 'Millau', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Caro Brousseau', 'F', '1989-09-29', '24 Square de la Couronne', '92200', 'Neuilly-sur-seine', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Marie-Hélène Allemand', 'F', '1996-01-11', '4 rue Gustave Eiffel', '51000', 'Châlons-en-champagne', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Anastasie Roatta', 'F', '1996-10-10', '30 rue des Nations Unies', '97180', 'Sainte-anne', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Jeanne Figuier', 'F', '1997-08-14', '44 rue Lenotre', '78150', 'Le Chesnay', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Fernande Dujardin', 'F', '1976-09-06', '59 rue Gouin de Beauchesne', '75011', 'Paris', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Émilienne Jullien', 'F', '1978-06-21', '67 rue Sébastopol', '72100', 'Le Mans', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Peggy Touchard', 'F', '1984-02-17', '79 rue Gustave Eiffel', '87000', 'Limoges', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Karine Chappelle', 'F', '1986-12-19', '49 rue Isambard', '71100', 'Chalon-sur-saône', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Léa Dufresne', 'F', '1987-07-08', '33 rue Sébastopol', '13011', 'Marseille', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Capucine Bazalgette', 'F', '1987-11-17', '43 avenue du Marechal Juin', '47000', 'Agen', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Nathalie Corriveau', 'F', '1989-04-21', '85 Quai des Belges', '21200', 'Beaune', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Claudette Dembélé', 'F', '1990-06-07', '1 rue des six frères Ruellan', '13127', 'Vitrolles', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Justine Édouard', 'F', '1992-05-25', '57 cours Jean Jaures', '75018', 'Paris', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Radegonde Passereau', 'F', '1997-05-05', '17 rue Petite Fusterie', '95160', 'Montmorency', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Leslie Prudhomme', 'F', '1997-07-09', '91 rue de l''Epeule', '13013', 'Marseille', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Capucine Bassot', 'F', '1999-10-12', '23 rue du Général Ailleret', '71100', 'Chalon-sur-saône', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Juliette Lièvremont', 'F', '2000-01-31', '78 rue Cazade', '50100', 'Cherbourg', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Giselle Blanchet', 'F', '1961-06-26', '57 avenue Jules Ferry', '75005', 'Paris', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Adrienne Devillers', 'F', '1962-03-12', '15 rue Charles Corbeau', '92140', 'Clamart', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Clémentine Bousquet', 'F', '1963-08-26', '72 Boulevard de Normandie', '95150', 'Taverny', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Adrienne Deshaies', 'F', '1965-05-25', '75 rue Cazade', '69120', 'Vaulx-en-velin', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Gisèle Leavitt', 'F', '1966-04-25', '19 rue du Paillle en queue', '77340', 'Pontault-combault', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Jocelyne Baschet', 'F', '1968-04-02', '9 rue du Faubourg National', '81100', 'Castres', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Marie-Françoise Arceneaux', 'F', '1968-12-24', '71 rue du Général Ailleret', '94100', 'Saint-maur-des-fossès', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Emma Genet', 'F', '1969-03-10', '35 boulevard d''Alsace', '26100', 'Romans-sur-isère', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Alexia Fournier', 'F', '1978-12-22', '3 rue Charles Corbeau', '92310', 'Sèvres', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Joëlle Berengar', 'F', '1981-09-25', '95 boulevard d''Alsace', '02000', 'Laon', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Clara Vernier', 'F', '1982-05-10', '49 rue du Général Ailleret', '78180', 'Montigny-le-bretonneux', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Sabrina Lefrançois', 'F', '1982-05-24', '86 rue de Lille', '69003', 'Lyon', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Ghyslaine Dufour', 'F', '1984-10-19', '92 Place Charles de Gaulle', '59100', 'Roubaix', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Claudie Bassot', 'F', '1995-12-27', '43 rue Porte d''Orange', '91000', 'Ris-orangis', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Rose Besnard', 'F', '1986-12-05', '53 rue du Faubourg National', '69009', 'Lyon', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Noëlle Lémery', 'F', '1987-06-23', '69 Boulevard de Normandie', '76600', 'Le Havre', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Théodore Sardou', 'M', '1970-05-16', '9 boulevard Albin Durand', '78000', 'Versailles', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Pierre-Louis Allais', 'M', '1975-03-29', '56 rue Isambard', '57600', 'Forbach', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Raoul Morel', 'M', '1975-05-09', '17 rue Bonneterie', '59300', 'Valenciennes', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Godefroy Blanchard', 'M', '1975-07-04', '20 rue de Raymond Poincaré', '95130', 'Franconville-la-garenne', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Dylan Bethune', 'M', '1975-09-17', '4 rue du Faubourg National', '69800', 'Saint-priest', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Aubin Vidal', 'M', '1976-01-31', '87 cours Jean Jaures', '59110', 'La Madeleine', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Charles Geffroy', 'M', '1977-09-16', '39 avenue Voltaire', '45000', 'Orléans', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Brice Appell', 'M', '1981-12-09', '56 boulevard Albin Durand', '34400', 'Lunel', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Élisée Brugière', 'M', '1982-04-25', '5 rue Pierre Motte', '75011', 'Paris', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Roch Renou', 'M', '1983-12-03', '11 boulevard Aristide Briand', '93800', 'Épinay-sur-seine', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Jean-Yves Courbet', 'M', '1985-09-20', '45 Place de la Madeleine', '15000', 'Aurillac', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Noël Haillet', 'M', '1987-01-07', '63 Place du Jeu de Paume', '31400', 'Toulouse', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('José Moineau', 'M', '1987-07-14', '48 rue Goya', '33300', 'Bordeaux', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Éric Genest', 'M', '1989-06-25', '66 Chemin Challet', '87280', 'Limoges', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Gilles Delsarte', 'M', '1989-09-04', '6 boulevard Albin Durand', '25000', 'BesanÇon', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Quentin Beaufils', 'M', '1992-06-21', '96 boulevard de la Liberation', '50000', 'Saint-lô', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Boniface LaFromboise', 'M', '1993-04-23', '61 rue Gontier-Patin', '64700', 'Maisons-alfort', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Nathan Trudeau', 'M', '1993-06-22', '16 Rue du Limas', '75009', 'Paris', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Thomas Beaubois', 'M', '1993-11-30', '62 Rue Bonnet', '80080', 'Amiens', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Gaston Prudhomme', 'M', '1995-06-19', '13 Faubourg Saint Honoré', '02100', 'Saint-quentin', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Josselin Vaillancourt', 'M', '1997-09-09', '28 Avenue des Près', '91240', 'Saint-michel-sur-orge', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Jean-François Auclair', 'M', '1977-02-24', '18 boulevard d''Alsace', '92300', 'Levallois-perret', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Maël Figuier', 'M', '1977-09-12', '39 rue de la Boétie', '93390', 'Clichy-sous-bois', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Arnaud Delafose', 'M', '1977-10-30', '89 rue Porte d''Orange', '75016', 'Paris', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Christophe Besnard', 'M', '1979-05-04', '97 rue des Dunes', '75002', 'Paris', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Fernand Delannoy', 'M', '1981-03-24', '20 avenue Jules Ferry', '92210', 'Saint-cloud', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('David Michaux', 'M', '1984-10-21', '14 rue de la République', '91700', 'Sainte-geneviève-des-bois', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Daniel Laframboise', 'M', '1987-12-10', '15 rue Léon Dierx', '78000', 'Versailles', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Léo Auvray', 'M', '1989-06-18', '92 rue Michel Ange', '91170', 'Viry-châtillon', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Francis Devereux', 'M', '1990-07-17', '53 Rue Frédéric Chopin', '94310', 'Orly', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Jean-Baptiste Thévenet', 'M', '1992-03-16', '31 Boulevard de Normandie', '93420', 'Villepinte', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Jean-Guy Toutain', 'M', '1993-06-02', '59 avenue de Provence', '93500', 'Pantin', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Tristan Bouthillier', 'M', '1997-05-26', '6 Rue Hubert de Lisle', '94310', 'Orly', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Augustin Moreau', 'M', '1997-02-13', '48 rue de la Hulotais', '75018', 'Paris', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Aaron Poullain', 'M', '1995-11-06', '95 rue Descartes', '78180', 'Montigny-le-bretonneux', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Ignace Chabert', 'M', '1997-02-26', '84 boulevard Aristide Briand', '93210', 'La Plaine-saint-denis', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Valentine Gagnon', 'F', '1998-03-06', '8 rue des Nations Unies', '92220', 'Bagneux', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Vanessa Boudet', 'F', '1977-04-02', '89 rue Léon Dierx', '95150', 'Taverny', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Marie Caillat', 'F', '1979-09-10', '24 rue Marguerite', '93290', 'Tremblay-en-france', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Clélie Couturier', 'F', '1980-05-10', '9 boulevard Amiral Courbet', '54100', 'Nancy', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Solène Saunier', 'F', '1981-08-01', '92 place de Miremont', '92230', 'Gennevilliers', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Viviane Raoult', 'F', '1985-07-08', '88 Square de la Couronne', '75014', 'Paris', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Myriam Delafosse', 'F', '1994-05-25', '50 place Stanislas', '38400', 'Saint-martin-d''hères', 22);
INSERT INTO supporter (name, gender, birthdate, adress, zip_code, city, id_country) VALUES ('Ivanna Dujardin', 'F', '1997-05-05', '38 Rue Joseph Vernet', '95200', 'Sarcelles', 22);

.print ** chargement dans subscriber_list
-- Remplissage de la table SUBSCRIBER_LIST
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Paris', 6, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Paris', 9, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Paris', 10, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Paris', 12, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Paris', 14, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Paris', 15, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Paris', 16, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Paris', 18, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Borelli', 27, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Borelli', 29, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Borelli', 36, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Borelli', 39, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Borelli', 42, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Borelli', 43, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Borelli', 48, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Paris', 52, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Paris', 53, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Paris', 54, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Paris', 55, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Paris', 61, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Paris', 67, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Auteuil', 68, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Auteuil', 74, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Auteuil', 75, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Auteuil', 76, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Auteuil', 77, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Auteuil', 78, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Auteuil', 80, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Auteuil', 86, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Borelli', 87, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Borelli', 89, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Borelli', 90, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Borelli', 91, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Borelli', 93, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Borelli', 94, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Boulogne', 95, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Boulogne', 97, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Boulogne', 98, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Boulogne', 99, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Boulogne', 100, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Boulogne', 101, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Boulogne', 107, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Boulogne', 111, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Auteuil', 114, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Auteuil', 118, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Auteuil', 119, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Auteuil', 124, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Auteuil', 127, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Auteuil', 128, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Auteuil', 129, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Boulogne', 130, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Boulogne', 131, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Boulogne', 132, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Paris', 133, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Paris', 134, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Paris', 135, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Paris', 136, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Paris', 137, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Paris', 141, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Paris', 142, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Auteuil', 143, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Auteuil', 145, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Auteuil', 147, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Boulogne', 149, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Boulogne', 151, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Boulogne', 154, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Boulogne', 157, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Boulogne', 160, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Boulogne', 165, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Boulogne', 166, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Boulogne', 167, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Auteuil', 168, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Auteuil', 169, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Auteuil', 170, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Auteuil', 171, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Auteuil', 172, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Auteuil', 173, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Boulogne', 174, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Boulogne', 177, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Boulogne', 178, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Boulogne', 179, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Borelli', 180, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Borelli', 181, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Borelli', 182, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Borelli', 183, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Borelli', 184, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Borelli', 185, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Borelli', 186, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Paris', 187, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Paris', 188, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Paris', 189, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Paris', 190, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Paris', 191, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Paris', 192, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Paris', 193, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Paris', 194, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Paris', 195, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Paris', 197, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Paris', 198, 1);
INSERT INTO subscriber_list (tribune, id_supporter, id_stadium) VALUES ('Paris', 200, 1);

.print
.print **************** Création database terminée ****************
.print

/*********************************************************************************/
/*                                   REQUETES                                    */
/*********************************************************************************/

.output request_1.txt
.print ------ TRANSPORTS EN COMMUN -------------------------------------------------------------------------------------
.print -- Vous travaillez au service commercial du Paris Saint Germain. Vous aimeriez faciliter l'accès au stade des  --
.print -- supporters vivant hors d'Ile de France.                                                                     --
.print -- Avant de mettre en place des navettes, vous décidez de contacter ces supporters pour savoir si ce service   --
.print -- les intéresse.                                                                                              --
.print -- La requête qui suit selectionne l'ensemble des abonnés du Parc des Princes qui vivent hors d'Ile de France. --
.print -----------------------------------------------------------------------------------------------------------------
.print
.print

SELECT supporter.name AS 'Prénom Nom', supporter.zip_code AS 'Code postal', supporter.city AS Ville FROM subscriber_list 
LEFT JOIN supporter on subscriber_list.id_supporter = supporter.id_supporter
WHERE 
  subscriber_list.id_stadium = 1 AND
  supporter.zip_code NOT BETWEEN '91000' AND '95999' AND
  supporter.zip_code NOT BETWEEN '77000' AND '78999' AND
  supporter.zip_code NOT LIKE '75%'
;


.output request_2.txt
.print ------ FAIR PLAY FINANCIER ----------------------------------------------------------------------------------
.print -- Dans le cadre du fair play financier, vous souhaitez établir une liste de club dont les dépenses sont à --
.print -- surveiller en priorité. Un des paramètre à prendre en compte pour cette liste est le budget alloué aux  --
.print -- salaires des joueurs. Les dépenses d'un club seront considérées comme 'à risque' si le budget salaire   --                                                               |
.print -- dépasse 2 000 000 d'euros par mois.                                                                     --
.print -- La requête qui suit établit la liste des clubs à surveiller.                                            --
.print -------------------------------------------------------------------------------------------------------------
.print
.print

SELECT club.name AS Club, SUM(player.salary) AS Salaires FROM player 
LEFT JOIN club ON club.id_club = player.id_club
GROUP BY club.name HAVING SUM(player.salary) > 2000000
;


.output request_3.txt
.print ------ PALMARES ----------------------------------------------------------------------------------------------
.print -- Vous décidez d'écrire un article sur le palmarès des 10 meilleurs clubs européens au cours des 10        --
.print -- dernières années.                                                                                        --
.print -- Seront pris en compte les victoires dans différentes compétitions : Ligue des Champions, Ligue Europa,   --
.print -- championnats respectifs et coupes nationales.                                                            --
.print -- La requête qui suit permet d'avoir un apperçu du nombre de trophées remportés par notre top 10 européen. --
.print -- NB : On remarque grâce à la jointure INNER JOIN que Tottenham est exclue de notre tableau, en effet, ce  --
.print -- club n'a rien gagné au cours des 10 dernières années.                                                    --
.print --------------------------------------------------------------------------------------------------------------
.print
.print

SELECT 
  t1.club AS Club, 
  CASE
    WHEN t1.pays = 3 AND t1.id_trophy = 4 THEN 'DFB Pokal'
    WHEN t1.pays = 4 AND t1.id_trophy = 4 THEN 'FA Cup'
    WHEN t1.pays = 20 AND t1.id_trophy = 4 THEN 'Copa Del Rey'
    WHEN t1.pays = 22 AND t1.id_trophy = 4 THEN 'Coupe de France'
    WHEN t1.pays = 26 AND t1.id_trophy = 4 THEN 'Coppa Italia'
    WHEN t1.pays = 3 AND t1.id_trophy = 3 THEN 'Bundesliga'
    WHEN t1.pays = 4 AND t1.id_trophy = 3 THEN 'Premier League'
    WHEN t1.pays = 20 AND t1.id_trophy = 3 THEN 'Liga'
    WHEN t1.pays = 22 AND t1.id_trophy = 3 THEN 'Ligue 1'
    WHEN t1.pays = 26 AND t1.id_trophy = 3 THEN 'Serie A'
    ELSE trophy.name 
  END Trophée, 
  nombre AS 'Nombre de victoires' FROM 
  (
   SELECT club.name AS club, club.id_country AS pays, prize_list.id_trophy AS id_trophy, COUNT(prize_list.id_trophy) AS nombre FROM club
   INNER JOIN prize_list ON club.id_club = prize_list.id_club
   GROUP BY club.name, prize_list.id_trophy ORDER BY club.id_club ASC
  ) t1 
  LEFT JOIN trophy ON t1.id_trophy = trophy.id_trophy
;


.output request_4.txt
.print ------ DREAM TEAM ---------------------------------------------------------------------------------------------
.print -- Le comité exécutif de l'UEFA vous à chargé d'organiser un match caritatif entre les anciennes gloires et  --
.print -- les étoiles montantes du foot européen.                                                                   --
.print -- Pour ça, on vous demande de selectionner 2 équipes de 15 joueurs : 11 titulaires + 1 remplaçant par zone  --
.print -- de jeu (attaque, milieu, défense, gardien).                                                               --
.print -- Les joueurs selectionnés doivent bien sur être les meilleurs à leur poste.                                --
.print -- Vous utiliserez la requête qui suit pour selectionner l'équipe des anciennes légendes (plus de 30 ans) et --
.print -- les étoiles montantes (moins de 30 ans) en fonction de leurs stats et de leur position sur le terrain.    --
.print ---------------------------------------------------------------------------------------------------------------
.print
.print

SELECT old.poste AS Poste, old.name AS Joueur, old.age AS Age, old.stats AS Stats, old.VERSUS, new.stats AS Stats, new.age AS Age, new.name AS Joueur, new.poste AS Poste FROM 
  (
   SELECT ROW_NUMBER() OVER (PARTITION BY row) AS id, poste, name, age, stats, VERSUS FROM
     ( 
      SELECT * FROM 
        (SELECT 'row' AS row, '1', 'ATT' AS poste, player.name AS name, strftime ('%Y', 'now') - strftime ('%Y', player.birthdate) AS age, player.stats, '<---->' AS VERSUS FROM player 
         LEFT JOIN position ON player.id_player = position.id_player
         WHERE (position.ATT = 1 OR position.BU = 1) AND age > 30 
         ORDER BY player.stats DESC LIMIT 4) 
      UNION
      SELECT * FROM 
        (SELECT 'row' AS row, '2', 'MIL', player.name AS name, strftime ('%Y', 'now') - strftime ('%Y', player.birthdate) AS age, player.stats, '<---->' FROM player 
         LEFT JOIN position ON player.id_player = position.id_player
         WHERE (position.MD = 1 OR position.MG = 1 OR position.MDC = 1 OR position.MC = 1 OR position.MOC = 1) AND age > 30 
         ORDER BY player.stats DESC LIMIT 4)
      UNION
      SELECT * FROM 
        (SELECT 'row' AS row, '3', 'DEF', player.name, strftime ('%Y', 'now') - strftime ('%Y', player.birthdate) AS age, player.stats, '<---->' FROM player 
         LEFT JOIN position ON player.id_player = position.id_player
         WHERE (position.DG = 1 OR position.DD = 1 OR position.DC = 1) AND age > 30 
         ORDER BY player.stats DESC LIMIT 5)
      UNION
      SELECT * FROM 
        (SELECT 'row' AS row, '4', 'G', player.name, strftime ('%Y', 'now') - strftime ('%Y', player.birthdate) AS age, player.stats, '<---->' FROM player 
         LEFT JOIN position ON player.id_player = position.id_player
         WHERE position.G = 1 AND age > 30 
         ORDER BY player.stats DESC LIMIT 2)
     ) 
  ) old LEFT JOIN (
   SELECT ROW_NUMBER() OVER (PARTITION BY row) AS id, poste, name, age, stats, VERSUS FROM
     ( 
      SELECT * FROM 
        (SELECT 'row' AS row, '1', 'ATT' AS poste, player.name AS name, strftime ('%Y', 'now') - strftime ('%Y', player.birthdate) AS age, player.stats, '<---->' AS VERSUS FROM player 
         LEFT JOIN position ON player.id_player = position.id_player
         WHERE (position.ATT = 1 OR position.BU = 1) AND age < 30 
         ORDER BY player.stats DESC LIMIT 4) 
      UNION
      SELECT * FROM 
        (SELECT 'row' AS row, '2', 'MIL', player.name AS name, strftime ('%Y', 'now') - strftime ('%Y', player.birthdate) AS age, player.stats, '<---->' FROM player 
         LEFT JOIN position ON player.id_player = position.id_player
         WHERE (position.MD = 1 OR position.MG = 1 OR position.MDC = 1 OR position.MC = 1 OR position.MOC = 1) AND age < 30 
         ORDER BY player.stats DESC LIMIT 4)
      UNION
      SELECT * FROM 
        (SELECT 'row' AS row, '3', 'DEF', player.name, strftime ('%Y', 'now') - strftime ('%Y', player.birthdate) AS age, player.stats, '<---->' FROM player 
         LEFT JOIN position ON player.id_player = position.id_player
         WHERE (position.DG = 1 OR position.DD = 1 OR position.DC = 1) AND age < 30 
         ORDER BY player.stats DESC LIMIT 5)
      UNION
      SELECT * FROM 
        (SELECT 'row' AS row, '4', 'G', player.name, strftime ('%Y', 'now') - strftime ('%Y', player.birthdate) AS age, player.stats, '<---->' FROM player 
         LEFT JOIN position ON player.id_player = position.id_player
         WHERE position.G = 1 AND age < 30 
         ORDER BY player.stats DESC LIMIT 2)
     )  
  ) new ON old.id = new.id
;

.output stdout
.print **************** Création requêtes terminée ****************
.print
.print ************************ FIN SCRIPT ************************
.print