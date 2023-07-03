-- Remplissage de la table personne
\COPY Personne(email,genre,date_naissance,mdp,adresse,date_creation_compte) FROM 'bdd-noisebook/CSV/personne.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table salledeconcert
\COPY Salle_de_concert(numero_telephone,email) FROM 'bdd-noisebook/CSV/salle_de_concert.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table artiste
\COPY Artiste(email) FROM 'bdd-noisebook/CSV/artiste.csv' DELIMITER ',' CSV HEADER;

-- remplissage de la table groupe
\COPY Groupe(date_creation_groupe) FROM 'bdd-noisebook/CSV/groupe.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table association
\COPY Association(date_creation) FROM 'bdd-noisebook/CSV/association.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table utilisateur
\COPY Utilisateur(id_personne,id_salle_de_concert,id_artiste,id_groupe,id_association,nom,description_utilisateur) FROM 'bdd-noisebook/CSV/utilisateur.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table concert
\COPY Concert(heure_debut,prix,line_up,nb_place_dispo,volontaires,cause_soutien,espace_exterieur,enfants) FROM 'bdd-noisebook/CSV/concert.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table evenement
\COPY Evenement(id_concert,nom_evenement,date_evenement,description_evenement,type_evenement,id_utilisateur) FROM 'bdd-noisebook/CSV/evenement.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table archive
\COPY Archive(id_concert,nb_participant,photos,videos) FROM 'bdd-noisebook/CSV/archive.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table morceau
\COPY Morceau(id_album,id_artiste,nom_morceau,date_upload,duree,type_morceau) FROM 'bdd-noisebook/CSV/morceau.csv' DELIMITER ',' CSV HEADER;

\COPY Album (id_utilisateur,nom_album,date_upload,duree,type_album) FROM 'bdd-noisebook/CSV/album.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table playlist
\COPY Playlist(id_utilisateur,nom_playlist) FROM 'bdd-noisebook/CSV/playlist.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table lieu
\COPY Lieu(nom_lieu,adresse,ville,pays) FROM 'bdd-noisebook/CSV/lieu.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table annonce
\COPY Annonce(id_utilisateur,id_concert,date_annonce) FROM 'bdd-noisebook/CSV/annonce.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table followers
\COPY Followers(id_utilisateur1,id_utilisateur2) FROM 'bdd-noisebook/CSV/followers.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table intention
\COPY Intention(id_utilisateur,id_evenement,participe) FROM 'bdd-noisebook/CSV/intention.csv' DELIMITER ',' CSV HEADER;

--Remplissage de la table PlaylisteMorceau
\COPY PlaylistMorceau(id_playlist,id_morceau) FROM 'bdd-noisebook/CSV/playlistmorceau.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table noteconcert
\COPY NoteConcert(id_utilisateur,id_concert,note,commentaire) FROM 'bdd-noisebook/CSV/noteconcert.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table notegroupe
\COPY NoteGroupe(id_utilisateur,id_groupe,note,commentaire) FROM 'bdd-noisebook/CSV/notegroupe.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table notemorceau
\COPY NoteMorceau(id_utilisateur,id_morceau,note,commentaire) FROM 'bdd-noisebook/CSV/notemorceau.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table notelieu
\COPY NoteLieu(id_utilisateur,id_lieu,note,commentaire) FROM 'bdd-noisebook/CSV/notelieu.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table noteperformanceartiste
\COPY NotePerformanceArtiste(id_utilisateur,id_concert,id_artiste,note,commentaire) FROM 'bdd-noisebook/CSV/noteperformanceartiste.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table noteperformancegroupe
\COPY NotePerformanceGroupe(id_utilisateur,id_concert,id_groupe,note,commentaire) FROM 'bdd-noisebook/CSV/noteperformancegroupe.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table tagGROUPES
\COPY Tag_groupes(id_groupe) FROM 'bdd-noisebook/CSV/taggroupes.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table tagMORCEAUX
\COPY Tag_morceaux(id_morceau) FROM 'bdd-noisebook/CSV/tagmorceaux.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table tagPLAYLISTS
\COPY Tag_playlists(id_playlist) FROM 'bdd-noisebook/CSV/tagplaylists.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table tagCONCERTS
\COPY Tag_concerts(id_concert) FROM 'bdd-noisebook/CSV/tagconcerts.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table tagLIEUX
\COPY Tag_lieux(id_lieu) FROM 'bdd-noisebook/CSV/taglieux.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table genreMusical
\COPY GenreMusical(nom_genre) FROM 'bdd-noisebook/CSV/genremusical.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table artisegenremusical
\COPY ArtisteGenreMusical(id_artiste,id_genre) FROM 'bdd-noisebook/CSV/artistegenremusical.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table AssociationGenreMusical
\COPY AssociationGenreMusical(id_association,id_genre) FROM 'bdd-noisebook/CSV/associationgenremusical.csv' DELIMITER ',' CSV HEADER

-- Remplissage de la table sousGenreMusical
\COPY SousGenreMusical(nom_sous_genre,id_genre) FROM 'bdd-noisebook/CSV/sousgenremusical.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table tagGENRE
\COPY TagGenre(id_genre) FROM 'bdd-noisebook/CSV/taggenre.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table tagSOUSGENRE
\COPY TagSousGenre(id_sous_genre) FROM 'bdd-noisebook/CSV/tagsousgenre.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table lieuevenement
\COPY LieuEvenement(id_lieu,id_evenement) FROM 'bdd-noisebook/CSV/lieuevenement.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table historique
\COPY Historique(id_utilisateur,date_historique,texte_historique) FROM 'bdd-noisebook/CSV/historique.csv' DELIMITER ',' CSV HEADER

-- Remplissage de la table tag
\COPY Tag(id_tag_groupe,id_tag_concert,id_tag_morceau,id_tag_playlist,id_tag_lieu,id_tag_genre,id_tag_sous_genre,nom_tag) FROM 'bdd-noisebook/CSV/tag.csv' DELIMITER ',' CSV HEADER;

-- Remplissage de la table interestUser
\COPY InterestUser(id_utilisateur, id_album, id_artiste,id_concert, id_evenement, id_groupe, id_lieu, id_morceau, id_playlist, score) FROM 'bdd-noisebook/CSV/interest.csv' DELIMITER ',' CSV HEADER;
