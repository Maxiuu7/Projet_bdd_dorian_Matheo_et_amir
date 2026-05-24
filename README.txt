================================================================================
ALSI-BDD_DOS SANTOS_FEREOL - PROJET DE BASE DE DONNEES
================================================================================

1. INSTRUCTIONS DE LANCEMENT
--------------------------------------------------------------------------------
Le code source de l'application se trouve dans le dossier "src/".
Pour lancer l'application :
1. Assurez-vous d'avoir Python installé.
2. Installez les dépendances : pip install flask mysql-connector-python python-dotenv
3. Configurez vos accès MySQL dans le fichier "src/.env" (modifier MYSQL_PASSWORD si besoin).
4. Lancez l'application : python app.py
5. Ouvrez votre navigateur sur http://127.0.0.1:5000/


2. DESCRIPTION DU DOMAINE CHOISI
--------------------------------------------------------------------------------
Le centre de stages de pilotage propose à des personnes de prendre le volant de véhicules de sport sur des circuits professionnels, encadrés par des instructeurs spécialisés. Les clients, appelés pilotes, peuvent s'inscrire à différents stages proposés par le centre. Chaque stage se déroule sur un circuit précis, est encadré par un instructeur dédié, et met à disposition des véhicules parmi lesquels le pilote choisit celui qu'il souhaite conduire.

Le centre gère également l'ensemble de son parc automobile (entretien, disponibilité) ainsi que ses instructeurs (disponibilités, spécialités). L'objectif de la base de données est de centraliser toutes ces informations pour faciliter la gestion des inscriptions, des plannings et des ressources.


3. REGLES METIER
--------------------------------------------------------------------------------
- Un pilote peut s'inscrire à plusieurs stages, mais ne peut pas s'inscrire deux fois au même stage.
- Un stage se déroule sur un seul circuit, mais un circuit peut accueillir plusieurs stages (à des dates différentes).
- Un stage est encadré par un et un seul instructeur. Un instructeur peut encadrer plusieurs stages.
- Un véhicule appartient au centre et peut être affecté à plusieurs stages, mais il ne peut pas être affecté à deux stages se déroulant en même temps.
- Lors de son inscription à un stage, un pilote choisit un véhicule disponible parmi ceux affectés à ce stage.
- Le nombre de places d'un stage est limité par la capacité du circuit et le nombre de véhicules disponibles.
- Un stage ne peut pas se tenir si aucun instructeur ne lui est affecté.
- Un pilote doit avoir un email unique dans le système.
- Le prix d'un stage est fixé à l'avance et ne peut pas être négatif.
- Un véhicule est caractérisé par sa marque, son modèle, son année et sa puissance en chevaux.


4. DICTIONNAIRE DES DONNEES
--------------------------------------------------------------------------------
| Table        | Attribut           | Type SQL     | Contraintes                            | Description                             |
|--------------|--------------------|--------------|----------------------------------------|-----------------------------------------|
| CIRCUIT      | id_circuit         | INT          | PK, AUTO_INCREMENT                     | Identifiant unique du circuit           |
| CIRCUIT      | nom_circuit        | VARCHAR(100) | NOT NULL                               | Nom du circuit                          |
| CIRCUIT      | ville              | VARCHAR(100) | NOT NULL                               | Ville où se situe le circuit            |
| CIRCUIT      | longueur_km        | DECIMAL(5,2) | NOT NULL, CHECK (>0)                   | Longueur de la piste en km              |
| CIRCUIT      | capacite_max       | INT          | NOT NULL, CHECK (>0)                   | Capacité maximale de voitures           |
| INSTRUCTEUR  | id_instructeur     | INT          | PK, AUTO_INCREMENT                     | Identifiant unique de l'instructeur     |
| INSTRUCTEUR  | nom_instructeur    | VARCHAR(50)  | NOT NULL                               | Nom de l'instructeur                    |
| INSTRUCTEUR  | prenom_instructeur | VARCHAR(50)  | NOT NULL                               | Prénom de l'instructeur                 |
| INSTRUCTEUR  | specialite         | VARCHAR(100) | NULL                                   | Spécialité (ex: Pilotage GT)            |
| VEHICULE     | id_vehicule        | INT          | PK, AUTO_INCREMENT                     | Identifiant unique du véhicule          |
| VEHICULE     | marque             | VARCHAR(50)  | NOT NULL                               | Marque de la voiture                    |
| VEHICULE     | modele             | VARCHAR(50)  | NOT NULL                               | Modèle de la voiture                    |
| VEHICULE     | puissance_cv       | INT          | NOT NULL, CHECK (>0)                   | Puissance en chevaux                    |
| VEHICULE     | annee              | INT          | NOT NULL, CHECK (1900-2026)            | Année de fabrication du véhicule        |
| PILOTE       | id_pilote          | INT          | PK, AUTO_INCREMENT                     | Identifiant unique du pilote            |
| PILOTE       | nom_pilote         | VARCHAR(50)  | NOT NULL                               | Nom du pilote                           |
| PILOTE       | prenom_pilote      | VARCHAR(50)  | NOT NULL                               | Prénom du pilote                        |
| PILOTE       | date_naissance     | DATE         | NOT NULL                               | Date de naissance du pilote             |
| PILOTE       | niveau             | VARCHAR(20)  | NOT NULL, CHECK (debutant...)          | Niveau d'expérience du pilote           |
| PILOTE       | email              | VARCHAR(100) | UNIQUE, NOT NULL                       | Adresse email du pilote                 |
| STAGE        | id_stage           | INT          | PK, AUTO_INCREMENT                     | Identifiant unique du stage             |
| STAGE        | nom_stage          | VARCHAR(100) | NOT NULL                               | Nom du stage de pilotage                |
| STAGE        | date_debut         | DATE         | NOT NULL                               | Date de début du stage                  |
| STAGE        | duree_jours        | INT          | NOT NULL, CHECK (>0)                   | Durée du stage en jours                 |
| STAGE        | nb_places_max      | INT          | NOT NULL, CHECK (>0)                   | Nombre de places maximum                |
| STAGE        | prix               | DECIMAL(8,2) | NOT NULL, CHECK (>=0)                  | Prix d'inscription au stage             |
| STAGE        | id_circuit         | INT          | FK (CIRCUIT), NOT NULL                 | Circuit associé au stage                |
| STAGE        | id_instructeur     | INT          | FK (INSTRUCTEUR), NOT NULL             | Instructeur encadrant le stage          |
| INSCRIPTION  | id_pilote          | INT          | PK, FK (PILOTE), NOT NULL              | Pilote inscrit                          |
| INSCRIPTION  | id_stage           | INT          | PK, FK (STAGE), NOT NULL               | Stage choisi par le pilote              |
| INSCRIPTION  | id_vehicule        | INT          | PK, FK (VEHICULE), NOT NULL            | Véhicule choisi pour le stage           |
| INSCRIPTION  | date_inscription   | DATE         | NOT NULL                               | Date à laquelle l'inscription a été faite|
| INSCRIPTION  | statut             | VARCHAR(20)  | NOT NULL, CHECK (en attente...)        | Statut actuel de l'inscription          |
