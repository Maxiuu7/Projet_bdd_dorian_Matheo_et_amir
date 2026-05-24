# 🎥 Script de la Vidéo de Présentation (Projet BDD)

**Durée cible :** ~10 à 12 minutes maximum.
**Intervenants :** Mathéo et Dorian.
**Consigne stricte :** Vos visages doivent apparaître au moins au début de la vidéo !

---

## 1. Introduction & Partie Conception (MCD) ⏱️ *3 à 4 minutes*

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

## 2. Modèle Physique & Intégrité des Données ⏱️ *2 à 3 minutes*

**Mathéo :** *(Partage d'écran sur MySQL Workbench - Affichage des tables)*
"Passons maintenant au modèle physique sous MySQL. Voici un aperçu de quelques tables peuplées avec notre jeu de données, comme la table `PILOTE` ou la table de relation `INSCRIPTION`."
*(Montrer rapidement un `SELECT * FROM PILOTE`)*

**Dorian :**
"Pour garantir la cohérence des données, nous avons mis en place des contraintes strictes. Par exemple, l'email d'un pilote a une contrainte `UNIQUE`, et les prix ou capacités ont des contraintes `CHECK (> 0)`.
Faisons un test en direct : je vais tenter d'insérer un pilote avec un niveau qui n'existe pas."
*(Exécuter : `INSERT INTO PILOTE (nom_pilote, prenom_pilote, date_naissance, niveau, email) VALUES ('Test', 'Test', '2000-01-01', 'novice', 'test@mail.com');`)*
"Comme vous le voyez, MySQL rejette l'insertion grâce à notre contrainte `CHECK (niveau IN ('debutant', 'intermediaire'...))`. L'intégrité est donc préservée."

**Mathéo :**
"Regardons ce qu'il se passe lors d'une suppression. Notre clé étrangère `#id_circuit` dans la table `STAGE` est configurée en `ON DELETE RESTRICT`. 
Si j'essaie de supprimer le circuit n°1 :"
*(Exécuter : `DELETE FROM CIRCUIT WHERE id_circuit = 1;`)*
"C'est bloqué ! Car des stages y sont encore associés. À l'inverse, l'inscription d'un pilote a un `ON DELETE CASCADE`. Si on supprime un pilote, tout son historique d'inscriptions disparaît proprement sans faire planter la base."

---

## 3. Démonstration SQL & Application ⏱️ *4 à 5 minutes*

**Dorian :** *(Toujours sur Workbench)*
"Avant de passer à l'interface, voici deux de nos requêtes SQL marquantes. 
La requête R6 : une jointure multiple avec agrégat pour compter le nombre total d'inscriptions par circuit."
*(Exécuter la R6 et montrer le résultat).*
"Et une requête plus complexe, la R15, qui utilise une sous-requête corrélée dans le `WHERE` pour trouver le stage le plus cher pour chaque circuit, en gérant automatiquement les ex-aequo."
*(Exécuter la R15 et expliquer brièvement).*

**Mathéo :** *(Passe sur le navigateur web : http://127.0.0.1:5000/)*
"Pour interagir avec cette base, nous avons développé une application web dynamique en **Python** avec le framework **Flask** et `mysql-connector-python`. 
Le design a été pensé pour être minimaliste, chaleureux et ergonomique."

**Dorian :**
"Sur le tableau de bord, on se connecte en temps réel à la base pour afficher des statistiques. 
Allons dans la gestion des Pilotes. Ici, on exécute un `SELECT` global. On peut filtrer par niveau dynamiquement.
Testons l'insertion : je vais ajouter un nouveau pilote."
*(Remplir le formulaire en direct et valider)*
"L'insertion `INSERT INTO` s'est faite avec succès, et le message flash le confirme. On peut voir le pilote dans la liste."

**Mathéo :**
"Si on clique sur 'Détail', l'application exécute une jointure entre `PILOTE`, `INSCRIPTION`, `STAGE` et `VEHICULE` pour afficher la fiche complète et l'historique du pilote.
Nous pouvons également modifier ce pilote (`UPDATE`) ou le supprimer (`DELETE`), ce qui déclenchera la suppression en cascade qu'on a vue tout à l'heure."
*(Montrer brièvement la modification ou la page Recherche/Stats).*

---

## 4. Conclusion & Bilan Critique ⏱️ *1 minute*

**Dorian :**
"Pour conclure, ce projet nous a permis de consolider nos acquis en modélisation et d'expérimenter la liaison entre un back-end Python et une base MySQL."

**Mathéo :**
"En prenant un peu de recul, si nous devions améliorer cette base de données, nous pourrions :
1. **Gérer les paiements** : Ajouter une entité `FACTURE` ou `PAIEMENT` pour suivre si un stage a bien été réglé.
2. **Historiser les instructeurs** : Actuellement un stage n'a qu'un instructeur. Si l'instructeur tombe malade et est remplacé, nous perdons l'information du remplacement. Créer une table d'historique de l'encadrement serait plus robuste."

**Dorian :**
"C'est la fin de notre présentation. Merci pour votre attention !"

---

## 💡 Conseils pour le tournage :
- Répétez le script 2 ou 3 fois ensemble pour vérifier le timing (vous avez droit à 12 minutes, donc prenez le temps de bien articuler, inutile de courir !).
- Préparez vos requêtes SQL dans Workbench à l'avance pour pouvoir les lancer d'un seul clic.
- Assurez-vous que le serveur Flask tourne en fond avant de démarrer l'enregistrement.
