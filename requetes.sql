-- R1 : liste de tous les pilotes tries par ordre alphabetique
-- entite principale = PILOTE
SELECT id_pilote, nom_pilote, prenom_pilote, niveau, email
FROM PILOTE
ORDER BY nom_pilote ASC, prenom_pilote ASC;

-- R2 : stages dont le prix est superieur a 1000 euros
-- critere numerique sur l'attribut prix
SELECT id_stage, nom_stage, date_debut, prix
FROM STAGE
WHERE prix > 1000
ORDER BY prix DESC;

-- R3 : tous les stages d'un circuit donne
-- equivalent a tous les elements d'une categorie donnee
SELECT id_stage, nom_stage, date_debut, prix
FROM STAGE
WHERE id_circuit = 1;

-- R4 : INNER JOIN entre STAGE et CIRCUIT
SELECT s.nom_stage, s.date_debut, c.nom_circuit, c.ville
FROM STAGE s
INNER JOIN CIRCUIT c ON s.id_circuit = c.id_circuit
ORDER BY s.date_debut;

-- R5 : LEFT JOIN pour garder les vehicules sans inscription
SELECT v.id_vehicule, v.marque, v.modele, i.id_pilote, i.id_stage
FROM VEHICULE v
LEFT JOIN INSCRIPTION i ON v.id_vehicule = i.id_vehicule
ORDER BY v.id_vehicule;

-- R6 : jointure de 3 tables + agregat COUNT
SELECT c.nom_circuit, COUNT(i.id_pilote) AS nb_inscriptions
FROM CIRCUIT c
LEFT JOIN STAGE s ON c.id_circuit = s.id_circuit
LEFT JOIN INSCRIPTION i ON s.id_stage = i.id_stage
GROUP BY c.id_circuit, c.nom_circuit
ORDER BY nb_inscriptions DESC;

-- R7 : GROUP BY sur instructeur + COUNT + tri descendant
SELECT ins.nom_instructeur, ins.prenom_instructeur, COUNT(s.id_stage) AS nb_stages
FROM INSTRUCTEUR ins
LEFT JOIN STAGE s ON ins.id_instructeur = s.id_instructeur
GROUP BY ins.id_instructeur, ins.nom_instructeur, ins.prenom_instructeur
ORDER BY nb_stages DESC;

-- R8 : filtre apres groupement avec HAVING
SELECT s.id_stage, s.nom_stage, COUNT(i.id_pilote) AS nb_inscrits
FROM STAGE s
INNER JOIN INSCRIPTION i ON s.id_stage = i.id_stage
GROUP BY s.id_stage, s.nom_stage
HAVING COUNT(i.id_pilote) >= 2;

-- R9 : AVG par groupe + filtre HAVING
SELECT c.nom_circuit, AVG(s.prix) AS prix_moyen
FROM CIRCUIT c
INNER JOIN STAGE s ON c.id_circuit = s.id_circuit
GROUP BY c.id_circuit, c.nom_circuit
HAVING AVG(s.prix) > 800
ORDER BY prix_moyen DESC;

-- R10 : MIN et MAX par groupe
SELECT ins.nom_instructeur, ins.prenom_instructeur,
       MIN(s.prix) AS prix_min,
       MAX(s.prix) AS prix_max
FROM INSTRUCTEUR ins
INNER JOIN STAGE s ON ins.id_instructeur = s.id_instructeur
GROUP BY ins.id_instructeur, ins.nom_instructeur, ins.prenom_instructeur;

-- R11 : sous-requete scalaire dans le WHERE
SELECT id_stage, nom_stage, prix
FROM STAGE
WHERE prix > (SELECT AVG(prix) FROM STAGE)
ORDER BY prix DESC;

-- R12 : NOT EXISTS sur la negation
-- le 2eme EXISTS garantit qu'il a bien au moins un stage
SELECT ins.id_instructeur, ins.nom_instructeur, ins.prenom_instructeur
FROM INSTRUCTEUR ins
WHERE NOT EXISTS (
    SELECT 1 FROM STAGE s
    WHERE s.id_instructeur = ins.id_instructeur
      AND s.prix <= 700
)
AND EXISTS (
    SELECT 1 FROM STAGE s WHERE s.id_instructeur = ins.id_instructeur
);

-- R13 : RANK() gere les egalites + ORDER BY multi-colonnes
SELECT p.id_pilote, p.nom_pilote, p.prenom_pilote,
       COUNT(i.id_stage) AS nb_inscriptions,
       RANK() OVER (ORDER BY COUNT(i.id_stage) DESC) AS classement
FROM PILOTE p
LEFT JOIN INSCRIPTION i ON p.id_pilote = i.id_pilote
GROUP BY p.id_pilote, p.nom_pilote, p.prenom_pilote
ORDER BY nb_inscriptions DESC, p.nom_pilote ASC;

-- R14 : COUNT DISTINCT sur id_stage
SELECT p.id_pilote, p.nom_pilote, p.prenom_pilote,
       COUNT(DISTINCT i.id_stage) AS nb_stages_differents
FROM PILOTE p
INNER JOIN INSCRIPTION i ON p.id_pilote = i.id_pilote
GROUP BY p.id_pilote, p.nom_pilote, p.prenom_pilote
HAVING COUNT(DISTINCT i.id_stage) >= 2;

-- R15 : sous-requete correlee sur le MAX du circuit
-- les ex-aequo sortent automatiquement
SELECT c.nom_circuit, s.nom_stage, s.prix
FROM CIRCUIT c
INNER JOIN STAGE s ON c.id_circuit = s.id_circuit
WHERE s.prix = (
    SELECT MAX(s2.prix)
    FROM STAGE s2
    WHERE s2.id_circuit = c.id_circuit
)
ORDER BY c.nom_circuit;
