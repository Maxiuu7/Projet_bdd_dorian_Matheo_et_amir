# Script de la Vidéo de Présentation (Projet BDD)

**Durée cible :** ~10 à 12 minutes maximum.
**Intervenants :** Mathéo et Dorian.
**Consigne stricte :** Vos visages doivent apparaître au moins au début de la vidéo !

---

## 1. Introduction & Partie Conception (MCD) — *3 à 4 minutes*

**[Caméra allumée sur Mathéo et Dorian]**

**Mathéo :**
"Bonjour à toutes et à tous. Je suis Mathéo Dos Santos, accompagné de Dorian Fereol. Nous allons vous présenter notre projet de Base de Données, qui porte sur la gestion d'un Centre de Stages de Pilotage automobile.
Dans ce projet, des pilotes s'inscrivent à des stages se déroulant sur des circuits spécifiques, encadrés par des instructeurs, en choisissant un véhicule du parc."

**Dorian :** *(Partage d'écran sur le schéma MCD)*
"Pour modéliser ce domaine, nous avons fait des choix de conception précis. Plutôt que de lister chaque entité, parlons du cœur de notre modèle : l'acte d'inscription. 
Nous avons choisi de créer une **association ternaire** `S'INSCRIRE` entre `PILOTE`, `STAGE` et `VEHICULE`. Pourquoi ce choix ? Car dans notre règle métier, l'inscription d'un pilote à un stage est indissociable du choix du véhicule qu'il va conduire ce jour-là. Ces trois informations forment un seul fait métier cohérent."

**Mathéo :**
"Exactement. Cette association ternaire porte d'ailleurs des attributs spécifiques : la `date_inscription` et le `statut` (confirmée, en attente). Ces informations n'appartiennent ni au pilote seul, ni au stage seul, mais bien à l'action de s'inscrire.
Concernant les associations binaires, nous avons par exemple l'association `SE_DEROULE` entre `STAGE` et `CIRCUIT` avec des cardinalités `(1,1)` côté stage, car un stage ne peut se faire que sur un seul circuit."

**Dorian :**
"Enfin, notre modèle respecte parfaitement la **Troisième Forme Normale (3FN)**. Pourquoi ? 
Premièrement, tous nos attributs sont atomiques (1FN). Deuxièmement, tous les attributs dépendent de la totalité de la clé primaire (2FN). Et troisièmement (3FN), il n'y a aucune dépendance transitive : par exemple, dans la table `CIRCUIT`, la longueur ou la capacité dépendent directement de l'identifiant du circuit, et non d'un autre attribut non-clé."

---

## 2. PARTIE DE [TON NOM] : Modèle Physique & Intégrité des Données — *2 à 3 minutes*

C'est ta partie complète ci-dessous. Lis bien les instructions entre parenthèses, elles te disent exactement quoi montrer à l'écran.

*(Tu es sur MySQL Workbench, connecté à la base `centre_pilotage`. Avant de filmer, prépare les requêtes ci-dessous dans des onglets séparés pour les lancer d'un clic.)*

---

### ETAPE 1 : Montrer le contenu de quelques tables (~30 sec)

*(Exécute ces 3 requêtes l'une après l'autre, tu peux les avoir dans le même onglet séparées par des points-virgules)*

```sql
SELECT * FROM PILOTE;
```

**Ce que tu dis :**
"Passons au modèle physique. Voici la table PILOTE, notre entité principale. On a 10 pilotes dans notre jeu de données, avec pour chacun un identifiant auto-incrémenté, un nom, un prénom, une date de naissance, un niveau parmi 4 valeurs possibles, et un email qui est unique."

*(Laisse le résultat affiché 2-3 secondes pour que la prof le voie, puis exécute la suivante)*

```sql
SELECT * FROM INSCRIPTION;
```

**Ce que tu dis :**
"Et voici la table INSCRIPTION, qui est issue de notre association ternaire. Sa clé primaire est composite : elle est formée de la combinaison de id_pilote, id_stage et id_vehicule. Ça veut dire qu'un même pilote ne peut pas choisir deux véhicules différents pour le même stage. On a aussi les attributs propres à l'inscription : la date et le statut."

*(Laisse le résultat affiché 2-3 secondes)*

---

### ETAPE 2 : Montrer que l'intégrité est préservée (contraintes CHECK et UNIQUE) (~45 sec)

**Ce que tu dis :**
"Maintenant, on va vérifier que nos contraintes d'intégrité fonctionnent bien. On a défini plusieurs contraintes CHECK et UNIQUE dans nos tables. Essayons d'insérer des données qui ne les respectent pas."

---

**Test 1 — Contrainte CHECK sur le niveau** *(Exécute cette requête)*

```sql
INSERT INTO PILOTE (nom_pilote, prenom_pilote, date_naissance, niveau, email)
VALUES ('Test', 'Test', '2000-01-01', 'novice', 'test@mail.com');
```

**Ce que tu dis :**
"Ici, j'essaie d'insérer un pilote avec le niveau 'novice'. Mais dans notre CREATE TABLE, on a défini un CHECK qui impose que le niveau soit parmi 'debutant', 'intermediaire', 'confirme' ou 'expert'. Et comme on peut le voir..."

*(Le message d'erreur rouge s'affiche dans Workbench)*

"...MySQL rejette l'insertion avec une erreur. La contrainte CHECK a bien empêché l'ajout d'une donnée invalide."

---

**Test 2 — Contrainte UNIQUE sur l'email** *(Exécute cette requête)*

```sql
INSERT INTO PILOTE (nom_pilote, prenom_pilote, date_naissance, niveau, email)
VALUES ('Dupont', 'Marie', '1995-06-15', 'debutant', 'antoine.dubois@mail.com');
```

**Ce que tu dis :**
"Deuxième test : j'essaie d'insérer un nouveau pilote, mais avec l'email 'antoine.dubois@mail.com' qui appartient déjà au pilote Dubois Antoine."

*(Le message d'erreur rouge s'affiche)*

"MySQL refuse aussi, car on a posé une contrainte UNIQUE sur la colonne email. Deux pilotes ne peuvent pas avoir la même adresse. L'intégrité des données est bien préservée."

---

### ETAPE 3 : Montrer les clés étrangères (suppression et modification) (~45 sec)

**Ce que tu dis :**
"Maintenant, voyons ce qu'il se passe quand on essaie de supprimer ou modifier un enregistrement qui est référencé par une clé étrangère. On a configuré deux comportements différents dans notre schéma : RESTRICT et CASCADE."

---

**Test 3 — ON DELETE RESTRICT (suppression bloquée)** *(Exécute cette requête)*

```sql
DELETE FROM CIRCUIT WHERE id_circuit = 1;
```

**Ce que tu dis :**
"J'essaie de supprimer le Circuit Paul Ricard, qui a l'id 1. Mais ce circuit est référencé par des stages : le Stage GT Débutant et le Stage Pluie Paul Ricard s'y déroulent. Dans notre CREATE TABLE de STAGE, la clé étrangère id_circuit est configurée en ON DELETE RESTRICT."

*(Le message d'erreur rouge s'affiche : Cannot delete or update a parent row)*

"MySQL refuse la suppression ! C'est le comportement RESTRICT : on ne peut pas supprimer un circuit tant qu'il y a des stages qui y font référence. C'est un choix métier logique, on ne veut pas perdre un circuit et laisser des stages orphelins."

---

**Test 4 — ON DELETE CASCADE (suppression en cascade)** *(Exécute ces 2 requêtes l'une après l'autre)*

D'abord, vérifie qu'il y a des inscriptions pour le pilote 1 :
```sql
SELECT * FROM INSCRIPTION WHERE id_pilote = 1;
```

**Ce que tu dis :**
"À l'inverse, regardons le comportement CASCADE. Le pilote Dubois Antoine, qui a l'id 1, a 2 inscriptions dans la table INSCRIPTION. Maintenant, si je le supprime..."

*(Exécute la suppression)*
```sql
DELETE FROM PILOTE WHERE id_pilote = 1;
```

"La suppression est acceptée. Et si je refais la même requête pour vérifier ses inscriptions..."

*(Réexécute)*
```sql
SELECT * FROM INSCRIPTION WHERE id_pilote = 1;
```

"...il n'y en a plus aucune. C'est le ON DELETE CASCADE : quand on supprime un pilote, toutes ses inscriptions sont automatiquement supprimées avec lui. C'est cohérent avec notre logique métier : si un pilote est retiré du système, ses inscriptions n'ont plus de raison d'exister."

---

**IMPORTANT — Après avoir filmé, n'oublie pas de réexécuter le script_creation.sql pour remettre les données comme avant ! Sinon le pilote Dubois Antoine sera absent pour la suite de la vidéo (partie de Mathéo sur l'appli Flask).**

---

## 3. PARTIE DE MATHEO : Démonstration SQL & Application — *4 à 5 minutes*

C'est ta partie complète ci-dessous, Mathéo. Lis bien les instructions entre parenthèses, elles te disent exactement quoi montrer à l'écran.

### ETAPE 1 : Requêtes SQL sur MySQL Workbench (~2 min)

*(Tu es sur MySQL Workbench. Avant de filmer, prépare les 3 requêtes ci-dessous dans 3 onglets séparés pour pouvoir les lancer d'un clic.)*

**Ce que tu dis :**

"Maintenant, passons à la partie SQL. Je vais exécuter quelques-unes de nos 15 requêtes directement dans MySQL Workbench pour montrer leur fonctionnement."

---

**Requête R4 — INNER JOIN** *(Clique sur l'onglet avec cette requête et exécute-la)*

```sql
SELECT s.nom_stage, s.date_debut, c.nom_circuit, c.ville
FROM STAGE s
INNER JOIN CIRCUIT c ON s.id_circuit = c.id_circuit
ORDER BY s.date_debut;
```

**Ce que tu dis :**
"Ici, c'est la requête R4. C'est une jointure interne, un INNER JOIN, entre la table STAGE et la table CIRCUIT. Le but c'est d'afficher pour chaque stage le nom du circuit et la ville où il se déroule. On fait la jointure sur la clé étrangère `id_circuit` qui est commune aux deux tables, et on trie par date de début. Comme on peut le voir dans le résultat, on a bien les 8 stages avec leurs circuits respectifs."

*(Montre le résultat quelques secondes.)*

---

**Requête R13 — RANK()** *(Clique sur l'onglet suivant et exécute-la)*

```sql
SELECT p.id_pilote, p.nom_pilote, p.prenom_pilote,
       COUNT(i.id_stage) AS nb_inscriptions,
       RANK() OVER (ORDER BY COUNT(i.id_stage) DESC) AS classement
FROM PILOTE p
LEFT JOIN INSCRIPTION i ON p.id_pilote = i.id_pilote
GROUP BY p.id_pilote, p.nom_pilote, p.prenom_pilote
ORDER BY nb_inscriptions DESC, p.nom_pilote ASC;
```

**Ce que tu dis :**
"La requête R13 est plus intéressante. C'est un classement des pilotes par nombre d'inscriptions. On fait un LEFT JOIN entre PILOTE et INSCRIPTION pour garder aussi les pilotes qui n'ont aucune inscription, ils apparaîtront avec 0. On utilise COUNT pour compter les inscriptions, GROUP BY pour regrouper par pilote, et la fonction window RANK() pour attribuer un rang. RANK gère automatiquement les ex-aequo : si deux pilotes ont le même nombre d'inscriptions, ils auront le même classement. Et en cas d'égalité, on départage par ordre alphabétique du nom grâce au ORDER BY multi-colonnes."

*(Montre le résultat, on doit voir Dubois et Garnier en tête avec 2 inscriptions chacun.)*

---

**Requête R15 — Sous-requête corrélée** *(Clique sur le dernier onglet et exécute-la)*

```sql
SELECT c.nom_circuit, s.nom_stage, s.prix
FROM CIRCUIT c
INNER JOIN STAGE s ON c.id_circuit = s.id_circuit
WHERE s.prix = (
    SELECT MAX(s2.prix)
    FROM STAGE s2
    WHERE s2.id_circuit = c.id_circuit
)
ORDER BY c.nom_circuit;
```

**Ce que tu dis :**
"Et enfin la requête R15, qui est la plus complexe. Le but c'est d'afficher, pour chaque circuit, le stage qui a le prix le plus élevé. On utilise une sous-requête corrélée dans le WHERE : pour chaque ligne du résultat principal, MySQL va aller chercher le prix maximum parmi tous les stages de ce même circuit. Si deux stages ont exactement le même prix maximum sur un circuit, ils sortent tous les deux, c'est automatique. Comme on peut le voir, chaque circuit a bien son stage le plus cher affiché."

*(Montre le résultat quelques secondes.)*

---

### ETAPE 2 : Présentation de l'application Flask (~2 min)

*(Tu passes maintenant sur ton navigateur web. Avant de filmer, assure-toi que le serveur tourne en lançant `cd src && python app.py` dans ton terminal.)*

**Ce que tu dis :**

"Maintenant je vais vous présenter notre interface utilisateur. Nous avons développé une application web en Python avec le framework Flask. Pour la connexion à la base de données, on utilise la librairie `mysql-connector-python`, et les identifiants de connexion sont stockés dans un fichier `.env` pour ne pas les coder en dur dans le code source."

---

*(Tu es sur la page d'accueil : http://127.0.0.1:5000/)*

**Ce que tu dis :**
"Voici la page d'accueil. C'est un tableau de bord qui affiche en temps réel des statistiques tirées directement de la base : le nombre de pilotes, de stages, d'inscriptions et de véhicules. Ces chiffres sont calculés à chaque chargement de page avec des requêtes SELECT COUNT."

---

*(Clique sur le lien "Pilotes" dans la barre de navigation.)*

**Ce que tu dis :**
"Ici, c'est la liste de tous les pilotes, triés par ordre alphabétique. Ça correspond à un SELECT classique sur la table PILOTE avec un ORDER BY. On peut aussi filtrer par niveau en cliquant sur les boutons en haut, par exemple si je clique sur 'Expert'..."

*(Clique sur le filtre "Expert".)*

"...on voit que la liste se met à jour et n'affiche plus que les pilotes de niveau expert. C'est un SELECT avec une clause WHERE niveau = 'expert'."

*(Reclique sur "Tous" pour revenir à la liste complète.)*

---

*(Clique sur le bouton "Ajouter un pilote".)*

**Ce que tu dis :**
"Pour l'insertion, on a un formulaire. Je vais ajouter un pilote de test en direct."

*(Remplis le formulaire avec ces valeurs :)*
- **Nom :** Martin
- **Prénom :** Paul
- **Date de naissance :** 1998-05-15
- **Niveau :** intermediaire
- **Email :** paul.martin@mail.com

*(Clique sur "Enregistrer".)*

**Ce que tu dis :**
"Quand je valide, l'application exécute un INSERT INTO PILOTE avec les valeurs du formulaire. Le message vert confirme que l'insertion a réussi, et on peut voir que 'Martin Paul' apparaît bien dans la liste."

---

*(Clique sur le bouton "Modifier" à côté de Martin Paul.)*

**Ce que tu dis :**
"Pour la mise à jour, je vais modifier le pilote qu'on vient d'ajouter. Par exemple, je vais changer son niveau de 'intermediaire' à 'confirme'."

*(Change le champ Niveau en "confirme" et clique sur "Enregistrer".)*

"L'application exécute un UPDATE PILOTE SET niveau = 'confirme' WHERE id_pilote = l'ID correspondant. Le message confirme que la modification a bien été prise en compte."

---

*(Clique sur "Détail" à côté du pilote Dubois Antoine, qui a des inscriptions.)*

**Ce que tu dis :**
"Enfin, la page de détail. Ici on voit la fiche complète du pilote Dubois Antoine, avec en dessous l'historique de toutes ses inscriptions aux stages. Pour afficher ça, l'application fait une jointure entre 4 tables : INSCRIPTION, STAGE, CIRCUIT et VEHICULE, avec des INNER JOIN. On voit pour chaque inscription le nom du stage, le circuit, la ville, le véhicule choisi et le statut."

---

*(Optionnel si tu as le temps : montre la page Recherche ou Statistiques.)*

"On a aussi une page de recherche par mot-clé qui utilise un SELECT avec des LIKE, et une page de statistiques qui réutilise la requête de classement R13 qu'on a vue tout à l'heure dans Workbench."

---

## 4. Conclusion & Bilan Critique — *1 minute*

**Dorian :**
"Pour conclure, ce projet nous a permis de consolider nos acquis en modélisation et d'expérimenter la liaison entre un back-end Python et une base MySQL."

**Mathéo :**
"En prenant un peu de recul, si nous devions améliorer cette base de données, nous pourrions :
1. Gérer les paiements : ajouter une entité FACTURE ou PAIEMENT pour suivre si un stage a bien été réglé.
2. Historiser les instructeurs : actuellement un stage n'a qu'un instructeur. Si l'instructeur tombe malade et est remplacé, nous perdons l'information du remplacement. Créer une table d'historique de l'encadrement serait plus robuste."

**Dorian :**
"C'est la fin de notre présentation. Merci pour votre attention !"

---

## Conseils pour le tournage :
- Prépare les 3 requêtes (R4, R13, R15) dans 3 onglets séparés dans Workbench AVANT de lancer l'enregistrement.
- Lance le serveur Flask (`cd src && python app.py`) AVANT de filmer.
- Répète 2 ou 3 fois pour bien caler ton timing (~2 min Workbench + ~2 min appli).
- Parle calmement, tu as 4-5 minutes pour ta partie, pas besoin de rusher.
