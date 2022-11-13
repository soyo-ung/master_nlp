#!/bin/bash
read dossier
dir="/Users/tank/Desktop/PROJET-MOT-SUR-LE-WEB/concat/DPfr/"  #J'ai ajusté chaque fois pour chaque fichier concerné
for fichier in `ls $dossier` ; 
do
	#obj=$(curl -sI $fichier | rev | cut -d'.' -f1 | rev );
	#ext=${fichier##*.}
	#if ext='txt'
	#then
	echo "$fichier \n" >> /Users/tank/Desktop/PROJET-MOT-SUR-LE-WEB/CONCATFILE/dumpfr.txt ;
	cat $dir$fichier >> /Users/tank/Desktop/PROJET-MOT-SUR-LE-WEB/CONCATFILE/dumpfr.txt ;
	#fi
done