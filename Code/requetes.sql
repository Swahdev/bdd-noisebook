-- une requête qui porte sur au moins trois tables
SELECT u.id_utilisateur,
  e.id_evenement
FROM Utilisateur u
  NATURAL JOIN Evenement e
  NATURAL JOIN Concert c
WHERE c.espace_exterieur = true
  AND e.date_evenement >= DATE '2090-10-10';
-- une ’auto jointure’ ou ’jointure réflexive’ (jointure de deux copies d’une même table)
SELECT F1.id_utilisateur1,
  F1.id_utilisateur2
FROM Followers F1
  JOIN Followers F2 ON F1.id_utilisateur1 = F2.id_utilisateur2
  AND F1.id_utilisateur2 = F2.id_utilisateur1;
-- une sous-requête corrélée
SELECT nom
FROM Utilisateur
WHERE EXISTS (
    SELECT *
    FROM Followers
    WHERE Followers.id_utilisateur1 = Utilisateur.id_utilisateur
      AND Followers.id_utilisateur2 = 2
  );
-- une sous-requête dans le FROM
SELECT *
FROM (
    SELECT nom_album,
      date_upload
    FROM Album
    WHERE type_album = 'Mixtape'
  ) AS sous_table
WHERE date_upload >= '2020-01-01';
-- une sous-requête dans le WHERE
SELECT nom_utilisateur
FROM Utilisateur
WHERE id_artiste IN (
    SELECT id_artiste
    FROM Artiste
      NATURAL JOIN ArtisteGenreMusical
      NATURAL JOIN GenreMusical
    WHERE GenreMusical.nom_genre = 'Pop'
  );
-- deux agrégats nécessitant GROUP BY et HAVING
-- les lieux où au moins un evenement a lieu apres le 10/10/2020
SELECT l.nom_lieu,
  COUNT(e.id_evenement) AS nombre_evenements
FROM Evenement e
  NATURAL JOIN LieuEvenement
  NATURAL JOIN Lieu l
WHERE date_evenement >= '2090-10-10'
GROUP BY l.nom_lieu
HAVING COUNT(e.id_evenement) > 0;
-- les groupes qui ont reçu des notes cumulatives d'au moins 30 de la part des utilisateurs
SELECT ng.id_groupe,
  SUM(ng.note) AS somme_notes,
  COUNT(*) AS nombre_utilisateurs
FROM Utilisateur AS u
  INNER JOIN NoteGroupe AS ng ON u.id_utilisateur = ng.id_utilisateur
GROUP BY ng.id_groupe
HAVING SUM(ng.note) >= 30;
-- une requête impliquant le calcul de deux agrégats (par exemple, les moyennes d’un ensemble de maximums)
SELECT COUNT(*) AS cpt_inf,
  (
    SELECT AVG(prix)
    FROM Concert
  ) AS prix_avg
FROM Concert
WHERE prix <= (
    SELECT AVG(prix) AS prix_avg
    FROM Concert
  );
-- une jointure externe (LEFT JOIN, RIGHT JOIN ou FULL JOIN)
--LEFT
SELECT u.nom
FROM Utilisateur u
  LEFT OUTER JOIN NoteConcert nc ON u.id_utilisateur = nc.id_utilisateur
GROUP BY u.nom;
--RIGHT
SELECT u.nom
FROM NoteConcert nc
  RIGHT OUTER JOIN Utilisateur u ON u.id_utilisateur = nc.id_utilisateur
GROUP BY u.nom;
--FULL
SELECT u.nom,
  nc.note
FROM Utilisateur u
  FULL OUTER JOIN NoteConcert nc ON u.id_utilisateur = nc.id_utilisateur
  AND nc.id_concert = 355
GROUP BY u.nom,
  nc.note;
-- deux requêtes équivalentes exprimant une condition de totalité, l’une avec des sous requêtes corrélées et l’autre avec de l’agrégation
SELECT *
FROM Personne
WHERE EXISTS (
    SELECT *
    FROM Utilisateur
    WHERE Utilisateur.id_personne = Personne.id_personne
      AND Personne.email LIKE '%.uk'
  );
-- avec agrégation
SELECT Personne.*
FROM Personne
  JOIN Utilisateur ON Utilisateur.id_personne = Personne.id_personne
WHERE Personne.email LIKE '%.uk'
GROUP BY Personne.id_personne
HAVING COUNT(*) > 0;
-- deux requêtes qui renverraient le même résultat si vos tables ne contenaient pas de nulls, mais
-- qui renvoient des résultats différents ici (vos données devront donc contenir quelques nulls), vous
-- proposerez également de petites modifications de vos requêtes (dans l’esprit de ce qui sera présenté
-- dans le cours sur l’information incomplète) afin qu’elles retournent le même
-- résultat
-- Compte pas NULL
SELECT id_artiste
FROM NotePerformanceArtiste
WHERE note = (
    SELECT MAX(note)
    FROM NotePerformanceArtiste
  );
-- Compte NULL
SELECT N1.id_artiste
FROM NotePerformanceArtiste N1
WHERE NOT EXISTS (
    SELECT *
    FROM NotePerformanceArtiste N2
    WHERE N2.note > N1.note
  );
-- CORRIGE
SELECT N1.id_artiste
FROM NotePerformanceArtiste N1
WHERE N1.note IS NOT NULL
  AND NOT EXISTS (
    SELECT *
    FROM NotePerformanceArtiste N2
    WHERE N2.note > N1.note
  );

-- requete recursive

WITH RECURSIVE FollowList AS (
  SELECT id_utilisateur1, id_utilisateur2
  FROM Followers
  WHERE id_utilisateur1 = 230
  UNION
  SELECT FL.id_utilisateur1, F.id_utilisateur2
  FROM FollowList FL
  JOIN Followers F ON FL.id_utilisateur2 = F.id_utilisateur1
)
SELECT U.id_utilisateur2 AS followers, P.nom
FROM FollowList U
JOIN Utilisateur P ON U.id_utilisateur2 = P.id_utilisateur;


-- requete fenetrage
SELECT
  EXTRACT(MONTH FROM e.date_evenement) AS mois,
  c.prix,
  RANK() OVER (PARTITION BY EXTRACT(MONTH FROM e.date_evenement) ORDER BY c.prix ASC) AS classement
FROM
  Evenement e
INNER JOIN
Concert c ON e.id_concert = c.id_concert
INNER JOIN
  Intention i ON e.id_evenement = i.id_evenement
WHERE
  EXTRACT(YEAR FROM e.date_evenement) >= 2023 AND EXTRACT(YEAR FROM e.date_evenement) <= 2030
ORDER BY
  EXTRACT(MONTH FROM e.date_evenement),
  classement
LIMIT 10;

-- requete recommendation

WITH RECURSIVE FriendList AS (
  SELECT id_utilisateur1, id_utilisateur2
  FROM Followers
  WHERE id_utilisateur1 = 230
  UNION
  SELECT FL.id_utilisateur1, F.id_utilisateur2
  FROM FriendList FL
  JOIN Followers F ON FL.id_utilisateur2 = F.id_utilisateur1
),
FriendSearches AS (
  SELECT H.*
  FROM Historique H
  WHERE H.id_utilisateur IN (SELECT id_utilisateur2 FROM FriendList)
)
SELECT FS.historic_id, FS.texte_historique
FROM FriendSearches FS;

-- requete recommendation

WITH RECURSIVE FriendList AS (
  SELECT id_utilisateur1, id_utilisateur2
  FROM Followers
  WHERE id_utilisateur1 = 230
  UNION
  SELECT FL.id_utilisateur1, F.id_utilisateur2
  FROM FriendList FL
  JOIN Followers F ON FL.id_utilisateur2 = F.id_utilisateur1
)
SELECT U.id_utilisateur2 AS ami, P.nom
FROM FriendList U
JOIN Utilisateur P ON U.id_utilisateur2 = P.id_utilisateur
WHERE U.id_utilisateur2 NOT IN (
  SELECT U.id_utilisateur
  FROM Utilisateur U
  JOIN Followers F ON U.id_utilisateur = F.id_utilisateur2
  WHERE F.id_utilisateur1 = 230
);