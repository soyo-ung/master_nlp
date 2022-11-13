#!/bin/bash
# 1. Lecture des paramètres dans le fichier PARAMETRES
read DOSSIERURLS;
read fichier_tableau;
read motif;
echo "Le dossier d'URLs : $DOSSIERURLS " ;
echo "Le fichier contenant le tableau : $fichier_tableau" ;
echo "Le motif est : $motif" ;
# 2. Affichage des tableaux
cpttableau=1;
echo "<html><head></head><body>" > $fichier_tableau ;
#====== pour chacun des fichiers d'URL ========
for fichier in `ls $DOSSIERURLS`
{ # debut du premier for
    #-------------------------------------------------
    # traitement d'un fichier d'URL 
    compteur=1; # initialisation d'un compteur pour compter les URLs
    echo "<p align=\"center\"><hr color=\"blue\" width=\"80%\"/> </p>" >> $fichier_tableau ;
    echo "<table align=\"center\" border=\"1\">" >> $fichier_tableau ;
    echo "<tr><td colspan=\"11\" align=\"center\">tableau n° $cpttableau</td></tr>" >> $fichier_tableau ;
    echo "<tr><td align=\"center\"><b>N&deg;</b></td><td align=\"center\"><b>Lien</b></td><td align=\"center\"><b>CODE CURL</b><td align=\"center\"><b>statut CURL</b></td><td align=\"center\"><b>Page Aspir&eacute;e</b></td><td align=\"center\"><b>Encodage Initial</b></td><td align=\"center\"><b>DUMP initial</b></td><td align=\"center\"><b>DUMP UTF-8</b></td><td align=\"center\"><b>CONTEXTE UTF-8</b></td><td align=\"center\"><b>CONTEXTE HTML UTF-8</b></td><td align=\"center\"><b>Fq MOTIF</b></td></tr>" >> $fichier_tableau ;
	#-------------------------------------------------
	# traitement de chacun des URLs
    for line in `cat $DOSSIERURLS/$fichier`
	#-------------------------------------------------
	# pour chacune des lignes du fichier d'URL traité (une URL)...
    {
	# ==> ASPIRATION DE LA PAGE 
	echo "TELECHARGEMENT de $line vers ./PAGES-ASPIREES/$cpttableau-$compteur.html" ;
	# 1. RECUPERATION DU HEADER HTTP
	status1=$(curl -sI $line | head -n 1); 
	# 2. RECUPERATION DU CODE RETOUR HTTP ET DE LA PAGE
	status2=$(curl --silent --output ./PAGES-ASPIREES/"$cpttableau-$compteur".html --write-out "%{http_code}" $line);
	echo "STATUT CURL : $status2" ;
	#-----------------------------------------------------------------------
	# le test de la bonne reussite du telechargement est a faire par vous...
	# si ca se passe mal, inutile de faire la suite...
	 encodagePgSF=$(./PROGRAMMES/detect-encoding/detect-encoding.exe  ./PAGES-ASPIREES/$compteurtableau-$compteur.html | tr "a-z" "A-Z" | sed "s/\n//");
					echo "CAS 2.1 : Encodage initial vide. P.A présente. Encodage extrait : $encodagePgSF";
					VERIFENCODAGEDANSICONV2="";
					if [[ $encodagePgSF != "" ]]
					then
						VERIFENCODAGEDANSICONV2=$(iconv -l | egrep -io $encodagePgSF | sort -u);
					fi
					echo "CAS 2.1 : Encodage initial vide. P.A présente. Encodage extrait : $encodagePgSF. Test Iconv : <$VERIFENCODAGEDANSICONV2>";
                    if [[ $VERIFENCODAGEDANSICONV2 == "" ]]
                    then
                          # on ne fait rien
						  echo "CAS 2.1 : Pb, pas d'encodage, pas de traitement ! ";
				else
                          # on peut faire le traitement : lynx + iconv
						  echo "CAS 2.1 : Tout est OK, on peut lancer les traitements : lynx, iconv etc...";
                    fi
				else
                    # on ne fait rien
					echo "CAS 2.2 : Pas de P.A. Pas de traitement ! ";
                fi
				else
				echo "CAS 3 : Encodage initial non vide : <$encodage>";
                VERIFENCODAGEDANSICONV=$(iconv -l | egrep -io $encodage | sort -u);
				echo "CAS 3 : Encodage initial non vide. Test Iconv :<$VERIFENCODAGEDANSICONV>";
                if [[ $VERIFENCODAGEDANSICONV == "" ]]
                then
					echo "CAS 3.1 : Encodage initial non vide. Inconnu de iconv. On va essayer de l'extraire...";
                    if [ -e  ./PAGES-ASPIREES/$compteurtableau-$compteur.html ] 
                    then
						echo "CAS 3.1.1 : P.A OK : ./PAGES-ASPIREES/$compteurtableau-$compteur.html ";
						echo "CAS 3.1.1 : Encodage initial non vide. Inconnu de iconv. P.A présente.";
						# La detection est faite ici par le programme de SF : il faudra pê utiliser une autre solution sous UBUNTU (file par exemple)
                        encodagePgSF=$(./PROGRAMMES/detect-encoding/detect-encoding.exe  ./PAGES-ASPIREES/$compteurtableau-$compteur.html | tr "a-z" "A-Z" | sed "s/\n//");
						echo "CAS 3.1.1 : Encodage initial non vide. Inconnu de iconv. P.A présente. Encodage extrait : $encodagePgSF";
						VERIFENCODAGEDANSICONV3="";
						if [[ $encodagePgSF != "" ]]
						then
							VERIFENCODAGEDANSICONV3=$(iconv -l | egrep -io $encodagePgSF | sort -u);
						fi
						echo "CAS 3.1.1 : Encodage initial non vide. Inconnu de iconv. P.A présente. Encodage extrait : $encodagePgSF. Test iconv : <$VERIFENCODAGEDANSICONV3>";
                        if [[ $VERIFENCODAGEDANSICONV3 == "" ]]
                            then
                                # on ne fait rien
								echo "CAS 3.1.1.1 : Pb, pas d'encodage, pas de traitement ! ";
                            else
                                # on peut faire le traitement : lynx + iconv
								echo "CAS 3.1.1.1 : Tout est OK, on peut lancer les traitements : lynx, iconv etc... ";
                            fi
                    else
                        # on ne fait rien
						echo "CAS 3.1.2 : Pas de P.A. Pas de traitement ! ";
                    fi 
                     
                else
                    # on peut faire le traitement : lynx + iconv
					echo "CAS 3.2 : Tout est OK, on peut lancer les traitements : lynx, iconv etc... ";
                fi
            fi
		fi
    } 
	#-----------------------------------------------------------------------
	# ==> DETECTION DE L'ENCODAGE DE LA PAGE en ligne
	echo "DETECTION encodage de $line ";
	encodage=$(curl -sI $line | egrep -i "charset=" | cut -f2 -d= | tr -d "\n" | tr -d "\r" | tr "[:upper:]" "[:lower:]");
	echo "ENCODAGE $line : <$encodage>" ;
	if [[ $encodage == "utf-8" ]]
	then 
	    echo "DUMP de $line via lynx" ;
	    lynx -dump -nolist -assume_charset=$encodage -display_charset=$encodage $line > ./DUMP-TEXT/$cpttableau-$compteur.txt ; 
	    # ajouter ici l'extraction de contexte autour des mots choisis
	    egrep -i $motif ./DUMP-TEXT/$cpttableau-$compteur.txt > ./CONTEXTES/$cpttableau-$compteur.txt ; 
	    nbmotif=$(egrep -coi $motif ./DUMP-TEXT/$cpttableau-$compteur.txt);
		perl ./PROGRAMMES/minigrep/minigrepmultilingue.pl "utf-8" ./DUMP-TEXT/$cpttableau-$compteur.txt parametre-motif.txt ;
		mv resultat-extraction.html ./CONTEXTES/$cpttableau-$compteur.html ;
	    echo "ECRITURE RESULTAT dans le tableau" ;
	    echo "<tr><td align=\"center\">$compteur</td><td align=\"center\"><a href=\"$line\">lien n°$compteur</a></td><td align=\"center\">$status2</td><td align=\"center\"><small>$status1</small></td><td align=\"center\"><a href=\"../PAGES-ASPIREES/$cpttableau-$compteur.html\">P.A n° $cpttableau-$compteur</a></td><td align=\"center\">$encodage</td><td align=\"center\">-</td><td align=\"center\"><a href=\"../DUMP-TEXT/$cpttableau-$compteur.txt\">DUMP n° $cpttableau-$compteur</a></td><td align=\"center\"><a href=\"../CONTEXTES/$cpttableau-$compteur.txt\">CONTEXTE n° $cpttableau-$compteur</a></td><td align=\"center\"><a href=\"../CONTEXTES/$cpttableau-$compteur.html\">CONTEXTE n° $cpttableau-$compteur</a></td><td>$nbmotif</td></tr>" >> $fichier_tableau ;
	else
	    #------------------------------------------
	    # ATTENTION : avant de faire ce qui suit : 
	    # il faudrait s'assurer que l'encodage recupere est bien un "BON" encodage !!!!
	    # dans un premier temps on s'assure SEULEMENT que cette variable n'est pas vide
	    # et ça ne suffit pas, il faudra en faire plus
	    #------------------------------------------
	    if [[ $encodage != "" ]]
			then
				VERIFENCODAGEDANSICONV=$(iconv -l |  egrep -o "[-A-Z0-9\_\:]+" |egrep -i $encodage) ;
				#------------------------------------------
				# ici il faut s'assurer que l'encodage est bien connu de iconv !!!!
				#------------------------------------------
				if [[ $VERIFENCODAGEDANSICONV == "" ]]
					then
						#------------- On ne fait rien...   -------------------------------------------------
						echo "<tr><td align=\"center\">$compteur</td><td align=\"center\"><a href=\"$line\">lien n°$compteur</a></td><td align=\"center\">$status2</td><td><small>$status1</small></td><td align=\"center\"><a href=\"../PAGES-ASPIREES/$cpttableau-$compteur.html\">PA n° $cpttableau-$compteur</a></td><td align=\"center\">$encodage<br/>via curl<br/>inconnu de iconv</td><td align=\"center\">-</td><td align=\"center\">-</td><td>-</td><td>-</td><td>-</td></tr>" >> $fichier_tableau ;
					else
						echo "DUMP (via $encodage) de $line via lynx" ;
						lynx -dump -nolist -assume_charset=$encodage -display_charset=$encodage $line > ./DUMP-TEXT/$cpttableau-$compteur.txt ;
						iconv -f $encodage -t utf-8 ./DUMP-TEXT/$cpttableau-$compteur.txt > ./DUMP-TEXT/$cpttableau-$compteur-utf8.txt ;
						egrep -i $motif ./DUMP-TEXT/$cpttableau-$compteur-utf8.txt > ./CONTEXTES/$cpttableau-$compteur.txt ; 
						nbmotif=$(egrep -coi $motif ./DUMP-TEXT/$cpttableau-$compteur-utf8.txt);
						perl ./PROGRAMMES/minigrep/minigrepmultilingue.pl "utf-8" ./DUMP-TEXT/$cpttableau-$compteur-utf8.txt parametre-motif.txt ;
						mv resultat-extraction.html ./CONTEXTES/$cpttableau-$compteur.html ;
						echo "ECRITURE RESULTAT dans le tableau" ;
						echo "<tr><td align=\"center\">$compteur</td><td align=\"center\"><a href=\"$line\">lien n°$compteur</a></td><td align=\"center\">$status2</td><td><small>$status1</small></td><td align=\"center\"><a href=\"../PAGES-ASPIREES/$cpttableau-$compteur.html\">PA n° $cpttableau-$compteur</a></td><td align=\"center\">$encodage<br/>via curl</td><td align=\"center\"><a href=\"../DUMP-TEXT/$cpttableau-$compteur.txt\">DUMP n° $cpttableau-$compteur</a></td><td align=\"center\"><a href=\"../DUMP-TEXT/$cpttableau-$compteur-utf8.txt\">DUMP n° $cpttableau-$compteur</a></td><td><a href=\"../CONTEXTES/$cpttableau-$compteur.txt\">CONTEXTE n° $cpttableau-$compteur</a></td><td align=\"center\"><a href=\"../CONTEXTES/$cpttableau-$compteur.html\">CONTEXTE n° $cpttableau-$compteur</a></td><td>$nbmotif</td></tr>" >> $fichier_tableau ;
				fi    
			else 
				isthereacharset=$(egrep -i -o "meta(.*)?charset" ./PAGES-ASPIREES/"$cpttableau-$compteur".html);
				if [[ $isthereacharset != "" ]]
					then
						encodage=$(egrep -i -o "meta(.*)charset[^=]*?=[^\"]*?\"?[^\"]+?\"" ./PAGES-ASPIREES/$cpttableau-$compteur.html | egrep -i -o "charset[^=]*?= *?\"?[^\"]+?\"" | cut -f2 -d= | sed "s/\"//g" | sed "s/>//g" | sed "s/ //g" | sed "s/\///g" | sort -u | tr [A-Z] [a-z] );
						echo "ENCODAGE EXTRAIT DE LA PAGE ASPIREE : $encodage" ;
						if [[ $encodage == "utf-8" ]]
							then 
								echo "DUMP de $line via lynx" ;
								lynx -dump -nolist -assume_charset=$encodage -display_charset=$encodage $line > ./DUMP-TEXT/$cpttableau-$compteur.txt ; 
								egrep -i $motif ./DUMP-TEXT/$cpttableau-$compteur.txt > ./CONTEXTES/$cpttableau-$compteur.txt ; 
								nbmotif=$(egrep -coi $motif ./DUMP-TEXT/$cpttableau-$compteur.txt);
								perl ./PROGRAMMES/minigrep/minigrepmultilingue.pl "utf-8" ./DUMP-TEXT/$cpttableau-$compteur.txt parametre-motif.txt ;
								mv resultat-extraction.html ./CONTEXTES/$cpttableau-$compteur.html ;
								echo "ECRITURE RESULTAT dans le tableau" ;
								echo "<tr><td align=\"center\">$compteur</td><td align=\"center\"><a href=\"$line\">lien n°$compteur</a></td><td align=\"center\">$status2</td><td align=\"center\"><small>$status1</small></td><td align=\"center\"><a href=\"../PAGES-ASPIREES/$cpttableau-$compteur.html\">P.A n° $cpttableau-$compteur</a></td><td align=\"center\">$encodage<br/>via charset</td><td align=\"center\">-</td><td align=\"center\"><a href=\"../DUMP-TEXT/$cpttableau-$compteur.txt\">DUMP n° $cpttableau-$compteur</a></td><td align=\"center\"><a href=\"../CONTEXTES/$cpttableau-$compteur.txt\">CONTEXTE n° $cpttableau-$compteur</a></td><td align=\"center\"><a href=\"../CONTEXTES/$cpttableau-$compteur.html\">CONTEXTE n° $cpttableau-$compteur</a></td><td>$nbmotif</td></tr>" >> $fichier_tableau ;
							else
								VERIFENCODAGEDANSICONV=$(iconv -l |  egrep -o "[-A-Z0-9\_\:]+" |egrep -i $encodage) ;
								if [[ $VERIFENCODAGEDANSICONV == "" ]]
									then
										echo "<tr><td align=\"center\">$compteur</td><td align=\"center\"><a href=\"$line\">lien n°$compteur</a></td><td align=\"center\">$status2</td><td><small>$status1</small></td><td align=\"center\"><a href=\"../PAGES-ASPIREES/$cpttableau-$compteur.html\">PA n° $cpttableau-$compteur</a></td><td align=\"center\">$encodage<br/><br/>via charset<br/>inconnu de iconv</td><td align=\"center\"><a href=\"../DUMP-TEXT/$cpttableau-$compteur.txt\">DUMP n° $cpttableau-$compteur</a></td><td align=\"center\">-</td><td>-</td><td>-</td><td>-</td></tr>" >> $fichier_tableau ;
									else
										lynx -dump -nolist -assume_charset=$encodage -display_charset=$encodage $line > ./DUMP-TEXT/$cpttableau-$compteur.txt ;
										iconv -f $encodage -t utf-8 ./DUMP-TEXT/$cpttableau-$compteur.txt > ./DUMP-TEXT/$cpttableau-$compteur-utf8.txt
										egrep -i $motif ./DUMP-TEXT/$cpttableau-$compteur-utf8.txt > ./CONTEXTES/$cpttableau-$compteur.txt ; 
										nbmotif=$(egrep -coi $motif ./DUMP-TEXT/$cpttableau-$compteur-utf8.txt);
										perl ./PROGRAMMES/minigrep/minigrepmultilingue.pl "utf-8" ./DUMP-TEXT/$cpttableau-$compteur-utf8.txt parametre-motif.txt ;
										mv resultat-extraction.html ./CONTEXTES/$cpttableau-$compteur.html ;
										#-------------------------------------------------------------------------------------------------------------------------
										echo "ECRITURE RESULTAT dans le tableau" ;
										echo "<tr><td align=\"center\">$compteur</td><td align=\"center\"><a href=\"$line\">lien n°$compteur</a></td><td align=\"center\">$status2</td><td><small>$status1</small></td><td align=\"center\"><a href=\"../PAGES-ASPIREES/$cpttableau-$compteur.html\">PA n° $cpttableau-$compteur</a></td><td align=\"center\">$encodage<br/>via charset</td><td align=\"center\"><a href=\"../DUMP-TEXT/$cpttableau-$compteur.txt\">DUMP n° $cpttableau-$compteur</a></td><td align=\"center\"><a href=\"../DUMP-TEXT/$cpttableau-$compteur-utf8.txt\">DUMP n° $cpttableau-$compteur</a></td><td><a href=\"../CONTEXTES/$cpttableau-$compteur.txt\">CONTEXTE n° $cpttableau-$compteur</a></td><td align=\"center\"><a href=\"../CONTEXTES/$cpttableau-$compteur.html\">CONTEXTE n° $cpttableau-$compteur</a></td><td>$nbmotif</td></tr>" >> $fichier_tableau ;
								fi
						fi
				else
					echo "<tr><td align=\"center\">$compteur</td><td align=\"center\"><a href=\"$line\">lien n°$compteur</a></td><td align=\"center\">$status2</td><td><small>$status1</small></td><td align=\"center\"><a href=\"../PAGES-ASPIREES/$cpttableau-$compteur.html\">PA n° $cpttableau-$compteur</a></td><td align=\"center\">Aucun encodage extrait...</td><td align=\"center\">-</td><td align=\"center\">-</td><td>-</td><td>-</td><td>-</td></tr>" >> $fichier_tableau ;
				fi
	    fi
	fi
        # il faut ajouter 1 au compteur de lignes
	let "compteur=compteur+1";  # let "compteur+=1";
    }
	#----------------------------------------------------
    echo "</table>" >> $fichier_tableau ;
    let "cpttableau=cpttableau+1";
}
echo "</body></html>" >> $fichier_tableau ;
#=============================================
