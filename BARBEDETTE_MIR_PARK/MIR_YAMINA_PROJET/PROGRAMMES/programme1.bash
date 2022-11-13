#!/bin/bash
echo "Donnez le nom du fichier contenant les liens http : "; 
read fic; 
echo "Donnez le nom du fichier html où stocker ces liens : "; 
read tablo; 
echo "<html><head><title>tableau de liens</title></head><body><table border=\"1\">" > $tablo; 
# Variable i pour compter les URLs
i=1;
for nom in `cat $fic` 
{
wget -O ./PAGES-ASPIREES/$i.html $nom
echo "<tr><td align=\"center\" width=\"50\">$i</td><td align=\"center\" width=\"100\"><a href=\"$nom\">$nom</a></td><td><a href=\"../PAGES-ASPIREES/$i.html\">PAGE ASPIREE</a></td></tr>" >> $tablo;
let "i+=1"; 
}
echo "</table></body></html>" >> $tablo; 