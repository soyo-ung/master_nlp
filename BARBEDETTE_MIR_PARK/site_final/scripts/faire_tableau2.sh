#!/bin/bash
read rep; read resultat; read motif;

echo "INPUT : le nom du fichier contenant les liens http : $rep";
echo "OUTPUT : le nom du fichier html en sortie : $resultat";
echo "Le motif est $motif";


#debut page 

echo -e "<html><head><meta charset=\"utf8\"><title>Tableau d'URLS</title></head><body>" > $resultat; #balises html 


compteurtableau=0; #compteur=0 car dès qu'on recommence un tableau, on repart de 0

rm ./CONCATENATION/*;

for fic in $(ls $rep) #pour chaque fichier du répertoire URLS
# ou : `ls $rep` 
do 
	let "compteurtableau=compteurtableau+1"; #on incrémente le compteur : un tableau pour chaque fichier
	echo "<table border=\"1\" align=\"center\">" >> $resultat; #caractéristiques du tableau
	
	compteurligne=0; 
	
	nbdump=1;
	
	#tableau final
	echo "<table width=\"100%\" align=\"center\" border=\"2\">" >> $resultat;
	echo "<tr><td align=\"center\" colspan=\"11\" bgcolor=\"black\"><span style=\"color:white\"><b>FICHIER URL : $rep/$fic | MOTIF : $motif</b> </span></td></tr>" >> $resultat;
	echo "<tr bgcolor=\"turquoise\"><td align=\"center\">N°</td><td align=\"center\">ENCODAGE</td><td align=\"center\">HTTP CODE</td><td align=\"center\">URL</td><td align=\"center\">PAGE ASPIREE</td><td align=\"center\">DUMP</td><td align=\"center\"> ENCODAGE DUMP</td><td align=\"center\">CONTEXTE EGREP</td><td align=\"center\">ENCODAGE CONTEXTE</td><td align=\"center\">CONTEXTE MINIGREP</td><td align=\"center\">FREQUENCE MOTIF</td><td align=\"center\">INDEX DUMP</td></tr>" >> $resultat;
	
	
	
	for ligne in $(cat $rep/$fic) 
	#pour chaque ligne du fichier d'urls
	#ou : for ligne in `cat $rep/$fic`
	{ 
	#ou : do
		let "compteurligne=compteurligne+1"; 
		#on incrémente le compteur de lignes
		encodage=$(curl -sIL $ligne | egrep -i "charset=" | cut -d"=" -f2 | tr "a-z" "A-Z" | tr --delete '\n' | tr --delete '\r'); #on crée une variable encodage : renvoie l'encodage en majuscules 
		#encodage=$(curl -sI $ligne | egrep -i "charset=" |cut -f2 -d= | tr -d "\n" | tr -d "\r" | tr "[:upper:]" "[:lower:]");
		echo "1.ENCODAGE extrait : <$encodage>";
		#wget $ligne -O ./PAGES_ASPIREES/$compteurtableau-$compteurligne.html; 
		http_code=$(curl -o ./PAGES_ASPIREES/$compteurtableau-$compteurligne.html -w "%{http_code}" $ligne);
		#on cherche l'url et on la met dans un fichier + on récupère le code http
		
		if [[ $encodage == "UTF-8" ]] 
		then 
			echo "EI UTF8"
			#curl $ligne > ./PAGES_ASPIREES/$compteurtableau-$compteurligne.html;
			#on stocke chaque ligne du fichier, càd les urls, dans le répertoire PAGES_ASPIREES
			lynx -dump -nolist -assume_charset="$encodage" -display_charset=$encodage $ligne > ./DUMP_TEXT/$compteurtableau-$compteurligne.txt;
			#on récupère uniquement le texte de chaque url et on l'envoie dans le répertoire DUMP_TEXT 
			egrep -i $motif ./DUMP_TEXT/$compteurtableau-$compteurligne.txt > ./CONTEXTES/$compteurtableau-$compteurligne.txt;
			nbmotif=$(egrep -coi $motif  ./DUMP_TEXT/$compteurtableau-$compteurligne.txt);
			perl ./PROGRAMMES/minigrepmultilingue/minigrepmultilingue.pl "utf-8" ./DUMP_TEXT/$compteurtableau-$compteurligne.txt ./PROGRAMMES/minigrepmultilingue/motif.txt;
			mv resultat-extraction.html ./CONTEXTES/$compteurtableau-$compteurligne.html;
			egrep -o "\w+" ./DUMP_TEXT/$compteurtableau-$compteurligne.txt | sort | uniq -c | sort -r > ./DUMP_TEXT/index-$compteurtableau-$compteurligne.txt ;
			
			
			
			
			encodagecontexte=$(file -i ./CONTEXTES/$compteurtableau-$compteurligne.txt | cut -f2 -d"=" | tr "a-z" "A-Z" | tr --delete '\n' | tr --delete '\r')
			encodagedump=$(file -i ./DUMP_TEXT/$compteurtableau-$compteurligne.txt | cut -f2 -d"=" | tr "a-z" "A-Z" | tr --delete '\n' | tr --delete '\r')
			
			if [[ $encodagecontexte == "UTF-8" ]] 
			then
				echo "<file=$nbdump>" >> ./CONCATENATION/CONCATCONTEXTES-$compteurtableau.txt ;
				cat ./CONTEXTES/$compteurtableau-$compteurligne.txt >> ./CONCATENATION/CONCATCONTEXTES-$compteurtableau.txt ;
				echo "</file>" >> ./CONCATENATION/CONCATCONTEXTES-$compteurtableau.txt ;
			fi
			if [[ $encodagedump == "UTF-8" ]]
			then
				echo "<file=$nbdump>" >> ./CONCATENATION/CONCATDUMP-$compteurtableau.txt ;
				cat ./DUMP_TEXT/$compteurtableau-$compteurligne.txt >> ./CONCATENATION/CONCATDUMP-$compteurtableau.txt ;
				echo "</file>" >> ./CONCATENATION/CONCATDUMP-$compteurtableau.txt ;
			fi
			
			echo -e "<tr><td>$compteurligne</td><td>EI :$encodage</td><td>$http_code</td><td><a href=\"$ligne\">$ligne</a></td><td><a href="../PAGES_ASPIREES/$compteurtableau-$compteurligne.html">Page aspirée $compteurtableau-$compteurligne</a></td><td><a href="../DUMP_TEXT/$compteurtableau-$compteurligne.txt">DP $compteurtableau-$compteurligne</a></td><td> Encodage Dump : $encodagedump </td><td><a href="../CONTEXTES/$compteurtableau-$compteurligne.txt"> Contextes egrep $compteurtableau-$compteurligne</a></td><td> Encodage Contexte : $encodagecontexte</td><td><a href="../CONTEXTES/$compteurtableau-$compteurligne.html"> Contextes minigrep $compteurtableau-$compteurligne</a></td><td>$nbmotif</td><td><a href="../DUMP_TEXT/index-$compteurtableau-$compteurligne.txt"> Index-$compteurtableau-$compteurligne </td></tr>" >> $resultat;
			
			let "nbdump+=1";
			

						
		else 
			echo "EI pas UTF8"
			if [[ $encodage == "" ]] 
			then 
				echo "EI VIDE"
				if [ -e ./PAGES_ASPIREES/$compteurtableau-$compteurligne.html ] 
				then 
					echo "PA OK"
					#A REMPLACER
					#encodagePG=$(./PROGRAMMES/detect-encoding/detect-encoding.exe
					#./PAGES_ASPIREES/$compteurtableau-$compteurligne.html | tr "a-z" "A-Z" | sed "s/\n//");
					encodage2=$(file -i ./PAGES_ASPIREES/$compteurtableau-$compteurligne.html | cut -f2 -d"=" | tr "a-z" "A-Z" | tr --delete '\n' | tr --delete '\r') #encodage extrait
					
					echo "2.ENCODAGE extrait : <$encodage2>";
					verifencodagedansiconv2="" 
					
					if [[ $encodage2 != "" ]] 
					then 
						echo "encodage extrait OK"
						verifencodagedansiconv2=$(iconv -l | egrep -io $encodage2 | sort -u);
					fi 
					
					if [[ $verifencodagedansiconv2 == "" ]] 
					then 
						echo "inconnu"
						#RIEN
						echo -e "<tr><td>$compteurligne</td><td>Pas utf8, vide, E inconnu</td><td>$http_code</td><td><a href=\"$ligne\">$ligne</a></td><td><a href="../PAGES_ASPIREES/$compteurtableau-$compteurligne.html">Page aspirée $compteurtableau-$compteurligne</a></td><td>Pas de dump</td><td>---</td><td>Pas de contexte egrep</td><td>---</td><td>Pas de contexte minigrep</td><td>Indisponible</tr>" >> $resultat;
						
					else 
						echo "reconnu"
						###encodage2=$(file -i ./PAGES_ASPIREES/$compteurtableau-$compteurligne.html | cut -f2 -d=)
						lynx -dump -nolist -assume_charset="$encodage2" -display_charset=$encodage2 $ligne > ./DUMP_TEXT/$compteurtableau-$compteurligne.txt;
						iconv -f $encodage2 -t UTF-8 ./DUMP_TEXT/$compteurtableau-$compteurligne.txt > ./DUMP_TEXT/$compteurtableau-$compteurligne-UTF8.txt
						encodageC=$(file -i ./DUMP_TEXT/$compteurtableau-$compteurligne-UTF8.txt | cut -f2 -d"=" | tr "a-z" "A-Z" | tr --delete '\n' | tr --delete '\r')
						egrep -i $motif ./DUMP_TEXT/$compteurtableau-$compteurligne-UTF8.txt > ./CONTEXTES/$compteurtableau-$compteurligne.txt;
						nbmotif=$(egrep -coi $motif  ./DUMP_TEXT/$compteurtableau-$compteurligne.txt);
						perl ./PROGRAMMES/minigrepmultilingue/minigrepmultilingue.pl "utf-8" ./DUMP_TEXT/$compteurtableau-$compteurligne-UTF8.txt ./PROGRAMMES/minigrepmultilingue/motif.txt;
						mv resultat-extraction.html ./CONTEXTES/$compteurtableau-$compteurligne.html;
						egrep -o "\w+" ./DUMP_TEXT/$compteurtableau-$compteurligne-UTF8.txt | sort | uniq -c | sort -r > ./DUMP_TEXT/index-$compteurtableau-$compteurligne.txt ;
						
						
						encodagecontexte=$(file -i ./CONTEXTES/$compteurtableau-$compteurligne.txt | cut -f2 -d"=" | tr "a-z" "A-Z" | tr --delete '\n' | tr --delete '\r')
						encodagedump=$(file -i ./DUMP_TEXT/$compteurtableau-$compteurligne.txt | cut -f2 -d"=" | tr "a-z" "A-Z" | tr --delete '\n' | tr --delete '\r')
			
						if [[ $encodagecontexte == "UTF-8" ]] 
						then
							echo "<file=$nbdump>" >> ./CONCATENATION/CONCATCONTEXTES-$compteurtableau.txt ;
							cat ./CONTEXTES/$compteurtableau-$compteurligne.txt >> ./CONCATENATION/CONCATCONTEXTES-$compteurtableau.txt ;
							echo "</file>" >> ./CONCATENATION/CONCATCONTEXTES-$compteurtableau.txt ;
						fi
						if [[ $encodagedump == "UTF-8" ]]
						then
							echo "<file=$nbdump>" >> ./CONCATENATION/CONCATDUMP-$compteurtableau.txt ;
							cat ./DUMP_TEXT/$compteurtableau-$compteurligne-UTF-8.txt >> ./CONCATENATION/CONCATDUMP-$compteurtableau.txt ;
							echo "</file>" >> ./CONCATENATION/CONCATDUMP-$compteurtableau.txt ;
						fi
						
						echo -e "<tr><td>$compteurligne</td><td>EI : $encodage2 - EC : $encodageC </td><td>$http_code</td><td><a href=\"$ligne\">$ligne</a></td><td><a href="../PAGES_ASPIREES/$compteurtableau-$compteurligne.html">Page aspirée $compteurtableau-$compteurligne</a></td><td><a href="../DUMP_TEXT/$compteurtableau-$compteurligne-UTF8.txt">DP $compteurtableau-$compteurligne</a></td><td>Encodage Dump : $encodagedump</td><td><a href="../CONTEXTES/$compteurtableau-$compteurligne.txt"> Contextes egrep $compteurtableau-$compteurligne</a></td><td>Encodage Contexte : $encodagecontexte</td><td><a href="../CONTEXTES/$compteurtableau-$compteurligne.html"> Contextes minigrep $compteurtableau-$compteurligne</a></td><td>$nbmotif</td><td><a href="../DUMP_TEXT/index-$compteurtableau-$compteurligne.txt"> Index-$compteurtableau-$compteurligne </td></tr>" >> $resultat;
						
						let "nbdump+=1";
					fi
				else 
				#PA n'existe pas 
					#RIEN
					echo "PA NON"
					echo -e "<tr><td>$compteurligne</td><td>PA n'existe pas</td><td></td><td><a href=\"$ligne\">$ligne</a></td><td>Pas de PA</td><td>Pas de dump</td><td>---</td><td>Pas de contexte egrep</td><td>---</td><td>Pas de contexte minigrep</td><td>Indisponible</tr>" >> $resultat;
				
				fi
			else #encodage initial pas vide
				echo "EI PAS vide"
				verifencodagedansiconv=$(iconv -l | egrep -io $encodage | sort -u) 
				if [[ $verifencodagedansiconv == "" ]] 
				then 
					echo "inconnu"
					if [ -e ./PAGES_ASPIREES/$compteurtableau-$compteurligne.html ] 
					then 
						echo "PA OK"
						encodage2=$(file -i ./PAGES_ASPIREES/$compteurtableau-$compteurligne.html | cut -f2 -d"=" | tr "a-z" "A-Z" | tr --delete '\n' | tr --delete '\r')
						echo "3.ENCODAGE extrait : <$encodage2>";
						verifencodagedansiconv3=""
						if [[ $encodage2 != "" ]] 
						then 
							echo "encodage extrait OK"
							verifencodagedansiconv3=$(iconv -l | egrep -io $encodage2 | sort -u)
						fi 
						if [[ $verifencodagedansiconv3 == "" ]] 
						then
							echo "inconnu"
							#RIEN
							echo -e "<tr><td>$compteurligne</td><td>Pas utf8, vide, E inconnu</td><td>$http_code</td><td><a href=\"$ligne\">$ligne</a></td><td><a href="../PAGES_ASPIREES/$compteurtableau-$compteurligne.html">Page aspirée $compteurtableau-$compteurligne</a></td><td>Pas de dump</td><td>---</td><td>Pas de contexte egrep</td><td>---</td><td>Pas de contexte minigrep</td><td>Indisponible</tr>" >> $resultat;
						else 
							echo "connu"
							lynx -dump -nolist -assume_charset="$encodage2" -display_charset=$encodage2 $ligne > ./DUMP_TEXT/$compteurtableau-$compteurligne.txt;
							iconv -f $encodage2 -t UTF-8 ./DUMP_TEXT/$compteurtableau-$compteurligne.txt > ./DUMP_TEXT/$compteurtableau-$compteurligne-UTF8.txt
							encodageC=$(file -i ./DUMP_TEXT/$compteurtableau-$compteurligne-UTF8.txt | cut -f2 -d"=" | tr "a-z" "A-Z" | tr --delete '\n' | tr --delete '\r')
							egrep -i $motif ./DUMP_TEXT/$compteurtableau-$compteurligne-UTF8.txt > ./CONTEXTES/$compteurtableau-$compteurligne.txt;
							nbmotif=$(egrep -coi $motif  ./DUMP_TEXT/$compteurtableau-$compteurligne.txt);
							perl ./PROGRAMMES/minigrepmultilingue/minigrepmultilingue.pl "utf-8" ./DUMP_TEXT/$compteurtableau-$compteurligne-UTF8.txt ./PROGRAMMES/minigrepmultilingue/motif.txt;
							mv resultat-extraction.html ./CONTEXTES/$compteurtableau-$compteurligne.html;
							egrep -o "\w+" ./DUMP_TEXT/$compteurtableau-$compteurligne-UTF8.txt | sort | uniq -c | sort -r > ./DUMP_TEXT/index-$compteurtableau-$compteurligne.txt ;
							
							
							encodagecontexte=$(file -i ./CONTEXTES/$compteurtableau-$compteurligne.txt | cut -f2 -d"=" | tr "a-z" "A-Z" | tr --delete '\n' | tr --delete '\r')
							encodagedump=$(file -i ./DUMP_TEXT/$compteurtableau-$compteurligne.txt | cut -f2 -d"=" | tr "a-z" "A-Z" | tr --delete '\n' | tr --delete '\r')
			
							if [[ $encodagecontexte == "UTF-8" ]] 
							then
								echo "<file=$nbdump>" >> ./CONCATENATION/CONCATCONTEXTES-$compteurtableau.txt ;
								cat ./CONTEXTES/$compteurtableau-$compteurligne.txt >> ./CONCATENATION/CONCATCONTEXTES-$compteurtableau.txt ;
								echo "</file>" >> ./CONCATENATION/CONCATCONTEXTES-$compteurtableau.txt ;
							fi
							if [[ $encodagedump == "UTF-8" ]]
							then
								echo "<file=$nbdump>" >> ./CONCATENATION/CONCATDUMP-$compteurtableau.txt ;
								cat ./DUMP_TEXT/$compteurtableau-$compteurligne-UTF-8.txt >> ./CONCATENATION/CONCATDUMP-$compteurtableau.txt ;
								echo "</file>" >> ./CONCATENATION/CONCATDUMP-$compteurtableau.txt ;
							fi
							
							echo -e "<tr><td>$compteurligne</td><td>EI : $encodage2 - EC : $encodageC </td><td>$http_code</td><td><a href=\"$ligne\">$ligne</a></td><td><a href="../PAGES_ASPIREES/$compteurtableau-$compteurligne.html">Page aspirée $compteurtableau-$compteurligne</a></td><td><a href="../DUMP_TEXT/$compteurtableau-$compteurligne-UTF8.txt">DP $compteurtableau-$compteurligne</a></td><td>Encodage Dump : $encodagedump</td><td><a href="../CONTEXTES/$compteurtableau-$compteurligne.txt"> Contextes egrep $compteurtableau-$compteurligne</a></td><td>Encodage contexte : $encodagecontexte</td><td><a href="../CONTEXTES/$compteurtableau-$compteurligne.html"> Contextes minigrep $compteurtableau-$compteurligne</a></td><td>$nbmotif</td><td><a href="../DUMP_TEXT/index-$compteurtableau-$compteurligne.txt"> Index-$compteurtableau-$compteurligne </td></tr>" >> $resultat;
							
							let "nbdump+=1";
							
						fi
						
					else 
						echo "PA NON"
						echo -e "<tr><td>$compteurligne</td><td>PA n'existe pas</td><td></td><td><a href=\"$ligne\">$ligne</a></td><td>Pas de PA</td><td>Pas de dump</td><td>---</td><td>Pas de contexte egrep</td><td>---</td><td>Pas de contexte minigrep</td><td>Indisponible</tr>" >> $resultat;
					fi
				else 
					echo "connu"
					encodage=$(file -i ./PAGES_ASPIREES/$compteurtableau-$compteurligne.html | cut -f2 -d"=" | tr "a-z" "A-Z" | tr --delete '\n' | tr --delete '\r')
					lynx -dump -nolist -assume_charset="$encodage" -display_charset=$encodage $ligne > ./DUMP_TEXT/$compteurtableau-$compteurligne.txt;
					iconv -f $encodage -t UTF-8 ./DUMP_TEXT/$compteurtableau-$compteurligne.txt > ./DUMP_TEXT/$compteurtableau-$compteurligne-UTF8.txt
					encodageC=$(file -i ./DUMP_TEXT/$compteurtableau-$compteurligne-UTF8.txt | cut -f2 -d"=" | tr "a-z" "A-Z" | tr --delete '\n' | tr --delete '\r')
					egrep -i $motif ./DUMP_TEXT/$compteurtableau-$compteurligne-UTF8.txt > ./CONTEXTES/$compteurtableau-$compteurligne.txt;
					nbmotif=$(egrep -coi $motif  ./DUMP_TEXT/$compteurtableau-$compteurligne.txt);
					perl ./PROGRAMMES/minigrepmultilingue/minigrepmultilingue.pl "utf-8" ./DUMP_TEXT/$compteurtableau-$compteurligne-UTF8.txt ./PROGRAMMES/minigrepmultilingue/motif.txt;
					mv resultat-extraction.html ./CONTEXTES/$compteurtableau-$compteurligne.html;
					egrep -o "\w+" ./DUMP_TEXT/$compteurtableau-$compteurligne-UTF8.txt | sort | uniq -c | sort -r > ./DUMP_TEXT/index-$compteurtableau-$compteurligne.txt ;
					
					
					encodagecontexte=$(file -i ./CONTEXTES/$compteurtableau-$compteurligne.txt | cut -f2 -d"=" | tr "a-z" "A-Z" | tr --delete '\n' | tr --delete '\r')
					encodagedump=$(file -i ./DUMP_TEXT/$compteurtableau-$compteurligne.txt | cut -f2 -d"=" | tr "a-z" "A-Z" | tr --delete '\n' | tr --delete '\r')
			
					if [[ $encodagecontexte == "UTF-8" ]] 
					then
						echo "<file=$nbdump>" >> ./CONCATENATION/CONCATCONTEXTES-$compteurtableau.txt ;
						cat ./CONTEXTES/$compteurtableau-$compteurligne.txt >> ./CONCATENATION/CONCATCONTEXTES-$compteurtableau.txt ;
						echo "</file>" >> ./CONCATENATION/CONCATCONTEXTES-$compteurtableau.txt ;
					fi
					if [[ $encodagedump == "UTF-8" ]]
					then
						echo "<file=$nbdump>" >> ./CONCATENATION/CONCATDUMP-$compteurtableau.txt ;
						cat ./DUMP_TEXT/$compteurtableau-$compteurligne-UTF-8.txt >> ./CONCATENATION/CONCATDUMP-$compteurtableau.txt ;
						echo "</file>" >> ./CONCATENATION/CONCATDUMP-$compteurtableau.txt ;
					fi
					
					echo -e "<tr><td>$compteurligne</td><td>EI : $encodage - EC : $encodageC </td><td>$http_code</td><td><a href=\"$ligne\">$ligne</a></td><td><a href="../PAGES_ASPIREES/$compteurtableau-$compteurligne.html">Page aspirée $compteurtableau-$compteurligne</a></td><td><a href="../DUMP_TEXT/$compteurtableau-$compteurligne-UTF8.txt">DP $compteurtableau-$compteurligne</a></td><td>Encodage Dump : $encodagedump</td><td><a href="../CONTEXTES/$compteurtableau-$compteurligne.txt"> Contextes egrep $compteurtableau-$compteurligne</a></td><td>Encodage Contexte : $encodagecontexte</td><td><a href="../CONTEXTES/$compteurtableau-$compteurligne.html"> Contextes minigrep $compteurtableau-$compteurligne</a></td><td>$nbmotif</td><td><a href="../DUMP_TEXT/index-$compteurtableau-$compteurligne.txt"> Index-$compteurtableau-$compteurligne </td></tr>" >> $resultat;
					
					let "nbdump+=1";
					
				fi
			fi
		fi
				
						
					
		
	} #ou : done
	
	egrep -o "\w+" ./CONCATENATION/CONCATDUMP-$compteurtableau.txt | sort | uniq -c | sort -r > ./CONCATENATION/indexdump-$compteurtableau.txt ;
	egrep -o "\w+" ./CONCATENATION/CONCATCONTEXTES-$compteurtableau.txt | sort | uniq -c | sort -r > ./CONCATENATION/indexcontextes-$compteurtableau.txt ;
	
	
	echo "</table>" >> $resultat;
	echo "<hr>" >> $resultat; #ajoute une ligne vide entre chaque tableau 
done

echo -e "</body></html>" >> $resultat;

#fin de la page

