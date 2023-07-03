CREATE TABLE Personne (
    id_personne SERIAL PRIMARY KEY,
    email VARCHAR(200) NOT NULL UNIQUE,
    genre VARCHAR(200),
    date_naissance DATE NOT NULL,
    mdp VARCHAR(200) NOT NULL,
    adresse VARCHAR(200) NOT NULL,
    date_creation_compte DATE NOT NULL
);
CREATE TABLE Salle_de_concert (
    id_salle_de_concert SERIAL PRIMARY KEY,
    numero_telephone VARCHAR(20) NOT NULL,
    email VARCHAR(50) NOT NULL UNIQUE
);
CREATE TABLE Artiste (
    id_artiste SERIAL PRIMARY KEY,
    email VARCHAR(50) NOT NULL UNIQUE
);
CREATE TABLE Groupe (
    id_groupe SERIAL PRIMARY KEY,
    date_creation_groupe DATE NOT NULL
);
CREATE TABLE Association (
    id_association SERIAL PRIMARY KEY,
    date_creation DATE NOT NULL
);
CREATE TABLE Utilisateur (
    id_utilisateur SERIAL PRIMARY KEY,
    id_personne INT REFERENCES Personne(id_personne) ON DELETE CASCADE,
    id_salle_de_concert INT REFERENCES Salle_de_concert(id_salle_de_concert) ON DELETE CASCADE,
    id_artiste INT REFERENCES Artiste(id_artiste) ON DELETE CASCADE,
    id_groupe INT REFERENCES Groupe(id_groupe) ON DELETE CASCADE,
    id_association INT REFERENCES Association(id_association) ON DELETE CASCADE,
    nom VARCHAR(200) NOT NULL,
    description_utilisateur VARCHAR(1000) NOT NULL,
    CONSTRAINT fk_uniques UNIQUE (
        id_personne,
        id_salle_de_concert,
        id_artiste,
        id_groupe,
        id_association
    ),
    CONSTRAINT tout_null_sauf_une CHECK (
        (
            (id_personne IS NOT NULL)::int + (id_salle_de_concert IS NOT NULL)::int + (id_artiste IS NOT NULL)::int + (id_groupe IS NOT NULL)::int + (id_association IS NOT NULL)::int
        ) = 1
    )
);
CREATE TABLE Concert (
    id_concert SERIAL PRIMARY KEY,
    heure_debut TIME NOT NULL,
    prix FLOAT NOT NULL,
    line_up VARCHAR(1000) NOT NULL,
    nb_place_dispo INT NOT NULL,
    volontaires BOOLEAN NOT NULL,
    cause_soutien VARCHAR(1000),
    espace_exterieur BOOLEAN NOT NULL,
    enfants BOOLEAN NOT NULL
);
CREATE TABLE Evenement (
    id_evenement SERIAL PRIMARY KEY,
    id_concert INT REFERENCES Concert(id_concert) ON DELETE CASCADE,
    nom_evenement VARCHAR(200) NOT NULL,
    date_evenement DATE NOT NULL,
    description_evenement VARCHAR(1000) NOT NULL,
    type_evenement VARCHAR(200) NOT NULL,
    id_utilisateur INT NOT NULL,
    CONSTRAINT fk_uniques_even UNIQUE (id_concert),
    CONSTRAINT tout_null_sauf_une CHECK (
        (
            (id_concert IS NOT NULL)::int
        ) = 1
    )
);
CREATE TABLE Archive (
    id_archive SERIAL PRIMARY KEY,
    id_concert INT UNIQUE NOT NULL,
    nb_participant INT NOT NULL,
    photos VARCHAR(1000) NOT NULL,
    videos VARCHAR(1000) NOT NULL,
    FOREIGN KEY (id_concert) REFERENCES Concert(id_concert) ON DELETE CASCADE
);
CREATE TABLE Morceau (
    id_morceau SERIAL PRIMARY KEY,
    id_album INT NOT NULL,
    id_artiste INT NOT NULL,
    nom_morceau VARCHAR(200) NOT NULL,
    date_upload DATE NOT NULL,
    duree TIME NOT NULL,
    type_morceau VARCHAR(200) NOT NULL
);
CREATE OR REPLACE FUNCTION is_valid_album_artist(id_test INT) RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM Utilisateur
        WHERE Utilisateur.id_utilisateur = id_test AND Utilisateur.id_artiste IS NOT NULL
        UNION
        SELECT 1
        FROM Utilisateur
        WHERE Utilisateur.id_utilisateur = id_test AND Utilisateur.id_groupe IS NOT NULL
    );
END;
$$ LANGUAGE plpgsql;
CREATE TABLE Album (
    id_album SERIAL PRIMARY KEY,
    id_utilisateur INT NOT NULL,
    nom_album VARCHAR(200) NOT NULL,
    date_upload DATE NOT NULL,
    duree TIME NOT NULL,
    type_album VARCHAR(200) NOT NULL,
    FOREIGN KEY (id_utilisateur) REFERENCES Utilisateur(id_utilisateur) ON DELETE CASCADE,
    CONSTRAINT check_album_artist CHECK (is_valid_album_artist(id_utilisateur))
);
-- Création de la fonction count_playlists_for_user
CREATE FUNCTION count_playlists_for_user(user_id INT) RETURNS INTEGER AS $$
DECLARE playlist_count INTEGER;
BEGIN
SELECT COUNT(*) INTO playlist_count
FROM Playlist
WHERE id_utilisateur = user_id;
RETURN playlist_count;
END;
$$ LANGUAGE plpgsql;
-- Création de la table Playlist avec la contrainte CHECK
CREATE TABLE Playlist (
    id_playlist SERIAL PRIMARY KEY,
    id_utilisateur INT NOT NULL,
    nom_playlist VARCHAR(200) NOT NULL,
    CONSTRAINT fk_playlist_utilisateur FOREIGN KEY (id_utilisateur) REFERENCES Utilisateur(id_utilisateur) ON DELETE CASCADE,
    CONSTRAINT chk_max_playlists CHECK (count_playlists_for_user(id_utilisateur) <= 10)
);
CREATE TABLE Lieu (
    id_lieu SERIAL PRIMARY KEY,
    nom_lieu VARCHAR(200) NOT NULL,
    adresse VARCHAR(200) NOT NULL,
    ville VARCHAR(200) NOT NULL,
    pays VARCHAR(200) NOT NULL
);
CREATE TABLE Annonce (
    id_utilisateur INT NOT NULL,
    id_concert INT NOT NULL,
    date_annonce DATE NOT NULL,
    PRIMARY KEY (id_utilisateur, id_concert),
    FOREIGN KEY (id_concert) REFERENCES Concert(id_concert) ON DELETE CASCADE
);
CREATE TABLE Intention (
    id_utilisateur INT NOT NULL,
    id_evenement INT NOT NULL,
    participe BOOLEAN NOT NULL,
    PRIMARY KEY (id_utilisateur, id_evenement),
    FOREIGN KEY (id_evenement) REFERENCES evenement(id_evenement) ON DELETE CASCADE
);
CREATE TABLE Followers (
    id_utilisateur1 INT NOT NULL,
    id_utilisateur2 INT NOT NULL,
    PRIMARY KEY (id_utilisateur1, id_utilisateur2),
    FOREIGN KEY (id_utilisateur1) REFERENCES Utilisateur(id_utilisateur) ON DELETE CASCADE,
    FOREIGN KEY (id_utilisateur2) REFERENCES Utilisateur(id_utilisateur) ON DELETE CASCADE
);
-- Création de la fonction check_max_morceaux
CREATE FUNCTION check_max_morceaux(playlist_id INT) RETURNS BOOLEAN AS $$
DECLARE morceaux_count INTEGER;
BEGIN
SELECT COUNT(*) INTO morceaux_count
FROM PlaylistMorceau
WHERE id_playlist = playlist_id;
RETURN morceaux_count <= 20;
END;
$$ LANGUAGE plpgsql;
-- Création de la table PlaylistMorceau avec la contrainte CHECK
CREATE TABLE PlaylistMorceau (
    id_playlist INT NOT NULL,
    id_morceau INT NOT NULL,
    PRIMARY KEY (id_playlist, id_morceau),
    CONSTRAINT fk_playlist_morceau_playlist FOREIGN KEY (id_playlist) REFERENCES Playlist(id_playlist) ON DELETE CASCADE,
    CONSTRAINT fk_playlist_morceau_morceau FOREIGN KEY (id_morceau) REFERENCES Morceau(id_morceau) ON DELETE CASCADE,
    CONSTRAINT chk_max_morceaux CHECK (check_max_morceaux(id_playlist))
);
CREATE TABLE NoteGroupe (
    id_utilisateur INT NOT NULL,
    id_groupe INT NOT NULL,
    note INT NOT NULL,
    commentaire VARCHAR(1000),
    PRIMARY KEY (id_utilisateur, id_groupe),
    FOREIGN KEY (id_groupe) REFERENCES Groupe (id_groupe) ON DELETE CASCADE
);
CREATE TABLE NoteMorceau (
    id_utilisateur INT NOT NULL,
    id_morceau INT NOT NULL,
    note INT NOT NULL,
    commentaire VARCHAR(1000),
    PRIMARY KEY (id_utilisateur, id_morceau),
    FOREIGN KEY (id_morceau) REFERENCES Morceau (id_morceau) ON DELETE CASCADE
);
CREATE TABLE NoteConcert (
    id_utilisateur INT NOT NULL,
    id_concert INT NOT NULL,
    note INT NOT NULL,
    commentaire VARCHAR(1000),
    PRIMARY KEY (id_utilisateur, id_concert),
    FOREIGN KEY (id_concert) REFERENCES Concert (id_concert) ON DELETE CASCADE
);
CREATE TABLE NoteLieu (
    id_utilisateur INT NOT NULL,
    id_lieu INT NOT NULL,
    note INT NOT NULL,
    commentaire VARCHAR(1000),
    PRIMARY KEY (id_utilisateur, id_lieu),
    FOREIGN KEY (id_lieu) REFERENCES Lieu (id_lieu) ON DELETE CASCADE
);
-- Création de la fonction check_concert_artist
CREATE FUNCTION check_concert_artist(concert_id INT, artist_id INT) RETURNS BOOLEAN AS $$
DECLARE artist_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO artist_count
    FROM Evenement e
    INNER JOIN Utilisateur u ON e.id_utilisateur = u.id_utilisateur
    WHERE e.id_concert = concert_id
        AND e.id_utilisateur = artist_id
        -- AND e.date_evenement < current_date
        AND u.id_artiste IS NOT NULL;
    RETURN artist_count > 0;
END;
$$ LANGUAGE plpgsql;

-- Création de la table NotePerformanceArtiste avec la contrainte CHECK
CREATE TABLE NotePerformanceArtiste (
    id_utilisateur INT NOT NULL,
    id_concert INT NOT NULL,
    id_artiste INT NOT NULL,
    note INT,
    commentaire VARCHAR(1000),
    PRIMARY KEY (id_utilisateur, id_concert, id_artiste),
    FOREIGN KEY (id_concert) REFERENCES Concert (id_concert) ON DELETE CASCADE,
    FOREIGN KEY (id_artiste) REFERENCES Utilisateur (id_utilisateur) ON DELETE CASCADE,
    CONSTRAINT chk_concert_artist CHECK (check_concert_artist(id_concert, id_artiste))
);
-- Création de la fonction check_concert_date
CREATE FUNCTION check_concert_groupe(concert_id INT, groupe_id INT) RETURNS BOOLEAN AS $$
DECLARE groupe_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO groupe_count
    FROM Evenement e
    NATURAL JOIN Utilisateur u
    WHERE e.id_concert = concert_id
    AND e.id_utilisateur = groupe_id
    --AND e.date_evenement < current_date
    AND u.id_groupe IS NOT NULL;
RETURN groupe_count > 0;
END;
$$ LANGUAGE plpgsql;

-- Création de la table NotePerformanceGroupe avec la contrainte CHECK
CREATE TABLE NotePerformanceGroupe (
    id_utilisateur INT NOT NULL,
    id_concert INT NOT NULL,
    id_groupe INT NOT NULL,
    note INT,
    commentaire VARCHAR(1000),
    PRIMARY KEY (id_utilisateur, id_concert, id_groupe),
    FOREIGN KEY (id_concert) REFERENCES Concert (id_concert) ON DELETE CASCADE,
    FOREIGN KEY (id_groupe) REFERENCES Utilisateur (id_utilisateur) ON DELETE CASCADE,
    CONSTRAINT chk_concert_groupe CHECK (check_concert_groupe(id_concert, id_groupe))
);
CREATE TABLE Tag_groupes (
    id_tag SERIAL PRIMARY KEY,
    id_groupe INT NOT NULL,
    FOREIGN KEY (id_groupe) REFERENCES Groupe (id_groupe) ON DELETE CASCADE
);
CREATE TABLE Tag_morceaux (
    id_tag SERIAL PRIMARY KEY,
    id_morceau INT NOT NULL,
    FOREIGN KEY (id_morceau) REFERENCES Morceau (id_morceau) ON DELETE CASCADE
);
CREATE TABLE Tag_playlists (
    id_tag SERIAL PRIMARY KEY,
    id_playlist INT NOT NULL,
    FOREIGN KEY (id_playlist) REFERENCES Playlist (id_playlist) ON DELETE CASCADE
);
CREATE TABLE Tag_concerts (
    id_tag SERIAL PRIMARY KEY,
    id_concert INT NOT NULL,
    FOREIGN KEY (id_concert) REFERENCES Concert (id_concert) ON DELETE CASCADE
);
CREATE TABLE Tag_lieux (
    id_tag SERIAL PRIMARY KEY,
    id_lieu INT NOT NULL,
    FOREIGN KEY (id_lieu) REFERENCES Lieu (id_lieu) ON DELETE CASCADE
);
CREATE TABLE GenreMusical (
    id_genre SERIAL PRIMARY KEY,
    nom_genre VARCHAR(200) NOT NULL
);
CREATE TABLE ArtisteGenreMusical (
    id_artiste INT NOT NULL,
    id_genre INT NOT NULL,
    PRIMARY KEY (id_artiste, id_genre),
    FOREIGN KEY (id_artiste) REFERENCES Artiste (id_artiste) ON DELETE CASCADE,
    FOREIGN KEY (id_genre) REFERENCES GenreMusical(id_genre) ON DELETE CASCADE
);
CREATE TABLE GroupeGenreMusical (
    id_groupe INT NOT NULL,
    id_genre INT NOT NULL,
    PRIMARY KEY (id_groupe, id_genre),
    FOREIGN KEY (id_groupe) REFERENCES Groupe(id_groupe) ON DELETE CASCADE,
    FOREIGN KEY (id_genre) REFERENCES GenreMusical(id_genre) ON DELETE CASCADE
);
CREATE TABLE AssociationGenreMusical (
    id_association INT NOT NULL,
    id_genre INT NOT NULL,
    PRIMARY KEY (id_association, id_genre),
    FOREIGN KEY (id_association) REFERENCES Association (id_association) ON DELETE CASCADE,
    FOREIGN KEY (id_genre) REFERENCES GenreMusical(id_genre) ON DELETE CASCADE
);
CREATE TABLE SousGenreMusical (
    id_sous_genre SERIAL PRIMARY KEY,
    nom_sous_genre VARCHAR(50) NOT NULL,
    id_genre INT NOT NULL,
    FOREIGN KEY (id_genre) REFERENCES GenreMusical (id_genre) ON DELETE CASCADE
);
CREATE TABLE TagGenre (
    id_tag_genre SERIAL PRIMARY KEY,
    id_genre INT NOT NULL,
    FOREIGN KEY (id_genre) REFERENCES GenreMusical (id_genre) ON DELETE CASCADE
);
CREATE TABLE TagSousGenre (
    id_tag_sous_genre SERIAL PRIMARY KEY,
    id_sous_genre INT NOT NULL,
    FOREIGN KEY (id_sous_genre) REFERENCES SousGenreMusical (id_sous_genre) ON DELETE CASCADE
);
CREATE TABLE LieuEvenement (
    id_lieu INT NOT NULL,
    id_evenement INT NOT NULL,
    PRIMARY KEY (id_lieu, id_evenement),
    FOREIGN KEY (id_lieu) REFERENCES Lieu (id_lieu) ON DELETE CASCADE,
    FOREIGN KEY (id_evenement) REFERENCES Evenement(id_evenement) ON DELETE CASCADE
);
CREATE TABLE Historique (
    historic_id SERIAL PRIMARY KEY,
    id_utilisateur INT NOT NULL,
    date_historique DATE NOT NULL,
    texte_historique VARCHAR(300) NOT NULL,
    FOREIGN KEY (id_utilisateur) REFERENCES Utilisateur (id_utilisateur) ON DELETE CASCADE
);
CREATE TABLE Tag (
    id_tag SERIAL PRIMARY KEY,
    id_tag_groupe INT REFERENCES Tag_groupes (id_tag) ON DELETE CASCADE,
    id_tag_concert INT REFERENCES Tag_concerts (id_tag) ON DELETE CASCADE,
    id_tag_morceau INT REFERENCES Tag_morceaux (id_tag) ON DELETE CASCADE,
    id_tag_playlist INT REFERENCES Tag_playlists (id_tag) ON DELETE CASCADE,
    id_tag_lieu INT REFERENCES Tag_lieux (id_tag) ON DELETE CASCADE,
    id_tag_genre INT REFERENCES TagGenre (id_tag_genre) ON DELETE CASCADE,
    id_tag_sous_genre INT REFERENCES TagSousGenre (id_tag_sous_genre) ON DELETE CASCADE,
    nom_tag VARCHAR(200) NOT NULL,
    CONSTRAINT fk_uniques_tag UNIQUE (
        id_tag_groupe,
        id_tag_concert,
        id_tag_morceau,
        id_tag_playlist,
        id_tag_lieu,
        id_tag_genre,
        id_tag_sous_genre
    ),
    CONSTRAINT tout_null_sauf_une_tag CHECK (
        (
            (id_tag_groupe IS NOT NULL)::INT + (id_tag_concert IS NOT NULL)::INT +(id_tag_morceau IS NOT NULL)::INT +(id_tag_playlist IS NOT NULL)::INT +(id_tag_lieu IS NOT NULL)::INT +(id_tag_genre IS NOT NULL)::INT +(id_tag_sous_genre IS NOT NULL)::INT
        ) = 1
    )
);

CREATE TABLE InterestUser (
    id_interest SERIAL PRIMARY KEY,
    id_utilisateur INT NOT NULL,
    id_album INT REFERENCES Album (id_album) ON DELETE CASCADE,
    id_artiste INT REFERENCES Artiste (id_artiste) ON DELETE CASCADE,
    id_concert INT REFERENCES Concert (id_concert) ON DELETE CASCADE,
    id_evenement INT REFERENCES Evenement (id_evenement) ON DELETE CASCADE,
    id_groupe INT REFERENCES Groupe (id_groupe) ON DELETE CASCADE,
    id_lieu INT REFERENCES Lieu (id_lieu) ON DELETE CASCADE,
    id_morceau INT REFERENCES Morceau (id_morceau) ON DELETE CASCADE,
    id_playlist INT REFERENCES Playlist (id_playlist) ON DELETE CASCADE,
    score FLOAT NOT NULL,
    CONSTRAINT fk_uniques_iu UNIQUE (
        id_album,
        id_artiste,
        id_concert,
        id_evenement,
        id_groupe,
        id_lieu,
        id_morceau,
        id_playlist
    ), CONSTRAINT tout_null_sauf_une_shushu CHECK (
        (
            (id_album IS NOT NULL)::INT + (id_artiste IS NOT NULL)::INT +(id_concert IS NOT NULL)::INT +(id_evenement IS NOT NULL)::INT +(id_groupe IS NOT NULL)::INT +(id_lieu IS NOT NULL)::INT +(id_morceau IS NOT NULL)::INT +(id_playlist IS NOT NULL)::INT
        ) = 1
    ), 
    FOREIGN KEY (id_utilisateur) REFERENCES Utilisateur (id_utilisateur) ON DELETE CASCADE
);

-- Remplissage de la table personne
\COPY Personne(email,genre,date_naissance,mdp,adresse,date_creation_compte) FROM ' bdd-noisebook/CSV/personne.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table salledeconcert
\COPY Salle_de_concert(numero_telephone,email) FROM ' bdd-noisebook/CSV/salle_de_concert.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table artiste
\COPY Artiste(email) FROM ' bdd-noisebook/CSV/artiste.csv' DELIMITER ',' CSV HEADER;

-- remplissage de la table groupe
\COPY Groupe(date_creation_groupe) FROM ' bdd-noisebook/CSV/groupe.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table association
\COPY Association(date_creation) FROM ' bdd-noisebook/CSV/association.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table utilisateur
\COPY Utilisateur(id_personne,id_salle_de_concert,id_artiste,id_groupe,id_association,nom,description_utilisateur) FROM ' bdd-noisebook/CSV/utilisateur.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table concert
\COPY Concert(heure_debut,prix,line_up,nb_place_dispo,volontaires,cause_soutien,espace_exterieur,enfants) FROM ' bdd-noisebook/CSV/concert.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table evenement
\COPY Evenement(id_concert,nom_evenement,date_evenement,description_evenement,type_evenement,id_utilisateur) FROM ' bdd-noisebook/CSV/evenement.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table archive
\COPY Archive(id_concert,nb_participant,photos,videos) FROM ' bdd-noisebook/CSV/archive.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table morceau
\COPY Morceau(id_album,id_artiste,nom_morceau,date_upload,duree,type_morceau) FROM ' bdd-noisebook/CSV/morceau.csv' DELIMITER ',' CSV HEADER;

\COPY Album (id_utilisateur,nom_album,date_upload,duree,type_album) FROM ' bdd-noisebook/CSV/album.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table playlist
\COPY Playlist(id_utilisateur,nom_playlist) FROM ' bdd-noisebook/CSV/playlist.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table lieu
\COPY Lieu(nom_lieu,adresse,ville,pays) FROM ' bdd-noisebook/CSV/lieu.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table annonce
\COPY Annonce(id_utilisateur,id_concert,date_annonce) FROM ' bdd-noisebook/CSV/annonce.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table followers
\COPY Followers(id_utilisateur1,id_utilisateur2) FROM ' bdd-noisebook/CSV/followers.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table intention
\COPY Intention(id_utilisateur,id_evenement,participe) FROM ' bdd-noisebook/CSV/intention.csv' DELIMITER ',' CSV HEADER;

--Remplissage de la table PlaylisteMorceau
\COPY PlaylistMorceau(id_playlist,id_morceau) FROM ' bdd-noisebook/CSV/playlistmorceau.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table noteconcert
\COPY NoteConcert(id_utilisateur,id_concert,note,commentaire) FROM ' bdd-noisebook/CSV/noteconcert.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table notegroupe
\COPY NoteGroupe(id_utilisateur,id_groupe,note,commentaire) FROM ' bdd-noisebook/CSV/notegroupe.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table notemorceau
\COPY NoteMorceau(id_utilisateur,id_morceau,note,commentaire) FROM ' bdd-noisebook/CSV/notemorceau.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table notelieu
\COPY NoteLieu(id_utilisateur,id_lieu,note,commentaire) FROM ' bdd-noisebook/CSV/notelieu.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table noteperformanceartiste
\COPY NotePerformanceArtiste(id_utilisateur,id_concert,id_artiste,note,commentaire) FROM ' bdd-noisebook/CSV/noteperformanceartiste.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table noteperformancegroupe
\COPY NotePerformanceGroupe(id_utilisateur,id_concert,id_groupe,note,commentaire) FROM ' bdd-noisebook/CSV/noteperformancegroupe.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table tagGROUPES
\COPY Tag_groupes(id_groupe) FROM ' bdd-noisebook/CSV/taggroupes.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table tagMORCEAUX
\COPY Tag_morceaux(id_morceau) FROM ' bdd-noisebook/CSV/tagmorceaux.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table tagPLAYLISTS
\COPY Tag_playlists(id_playlist) FROM ' bdd-noisebook/CSV/tagplaylists.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table tagCONCERTS
\COPY Tag_concerts(id_concert) FROM ' bdd-noisebook/CSV/tagconcerts.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table tagLIEUX
\COPY Tag_lieux(id_lieu) FROM ' bdd-noisebook/CSV/taglieux.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table genreMusical
\COPY GenreMusical(nom_genre) FROM ' bdd-noisebook/CSV/genremusical.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table artisegenremusical
\COPY ArtisteGenreMusical(id_artiste,id_genre) FROM ' bdd-noisebook/CSV/artistegenremusical.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table AssociationGenreMusical
\COPY AssociationGenreMusical(id_association,id_genre) FROM ' bdd-noisebook/CSV/associationgenremusical.csv' DELIMITER ',' CSV HEADER

-- Remplissage de la table sousGenreMusical
\COPY SousGenreMusical(nom_sous_genre,id_genre) FROM ' bdd-noisebook/CSV/sousgenremusical.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table tagGENRE
\COPY TagGenre(id_genre) FROM ' bdd-noisebook/CSV/taggenre.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table tagSOUSGENRE
\COPY TagSousGenre(id_sous_genre) FROM ' bdd-noisebook/CSV/tagsousgenre.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table lieuevenement
\COPY LieuEvenement(id_lieu,id_evenement) FROM ' bdd-noisebook/CSV/lieuevenement.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table historique
\COPY Historique(id_utilisateur,date_historique,texte_historique) FROM ' bdd-noisebook/CSV/historique.csv' DELIMITER ',' CSV HEADER

-- Remplissage de la table tag
\COPY Tag(id_tag_groupe,id_tag_concert,id_tag_morceau,id_tag_playlist,id_tag_lieu,id_tag_genre,id_tag_sous_genre,nom_tag) FROM ' bdd-noisebook/CSV/tag.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table interestUser
\COPY InterestUser(id_utilisateur, id_album, id_artiste,id_concert, id_evenement, id_groupe, id_lieu, id_morceau, id_playlist, score) FROM ' bdd-noisebook/CSV/interest.csv' DELIMITER ',' CSV HEADER;
