#!/usr/bin/ksh
#1
mkdir braviary3
echo "Ходы  Body Slam Bounce Double-Edge Heat Wave Helping Hand\nFire Pledge Last Resort Low Kick Mega Kick Mega Punch Mud-Slap Seismic\nToss Sleep Talk Snore Swift\ncranidos:\nВозможности  Overland=6 Jump=4\nPower=3 Intelligence=3 Sinker=0" > braviary3/torchic
mkdir braviary3/lickilicky
mkdir braviary3/gurdurr
touch braviary3/cranidos
mkdir braviary3/empoleon
mkdir empoleon3
mkdir empoleon3/lilligant
mkdir empoleon3/jynx
mkdir empoleon3/ampharos
echo "Способности  Scratch Leer\nAssurance Dragon Rage Double Chop Scary Face Slash False Swipe Dragon\nClaw Dragon Dance Taunt Dragon Pulse Swords Dance Guillotine Outrage\nGiga Impact" > empoleon3/axew
mkdir empoleon3/sudowoodo
mkdir empoleon3/alakazam
echo "Возможности  Overland=6 Surface=6 Jump=1 Power=2\nIntelligence=3 Amorphous=0" > grimer5
echo "Тип диеты\nCarnivore" > staraptor1
echo "Тип покемона  NORMAL FLYING" > taillow5
mkdir wormadam1
echo "Развитые\nспособности  Sand Veil" > wormadam1/donphan
echo "Ходы  After You Body Slam Covet\nDouble-Edge Dynamicpunch Fire Punch Fury Cutter Gunk Shot Ice Punch	Icy Wind Low Kick Mega Kick Mega Punch Mud-Slap Rock Climb Seismic\nToss Shock Wave Sleep Talk Snore Sucker Punch Thunderpunch Water Pulse\nUproar" > wormadam1/vigoroth
mkdir wormadam1/piloswine
mkdir wormadam1/trubbish
mkdir wormadam1/karrablast
echo "weight=191.8 height59.0 atk=14 def=10" > wormadam1/conkeldurr
#2
chmod u=rwx,g=wx,o=rwx braviary3
chmod u=rw,g=w,o=r braviary3/torchic
chmod u=rwx,g=rx,o=w braviary3/lickilicky
chmod u=wx,g=rw,o=x braviary3/gurdurr
chmod u=r,g=r braviary3/cranidos
chmod u=rwx,g=rx,o=w braviary3/empoleon
chmod u=wx,g=x,o=x empoleon3
chmod 700 empoleon3/lilligant
chmod 357 empoleon3/jynx
chmod u=rx,g=rwx,o=rwx empoleon3/ampharos
chmod 666 empoleon3/axew
chmod 551 empoleon3/sudowoodo
chmod u=rx,g=rwx,o=rw empoleon3/alakazam
chmod u=rw,g=,o= grimer5
chmod u=r,g=,o=r staraptor1
chmod u=r,g=,o= taillow5
chmod u=wx,g=rwx,o=wx wormadam1
chmod u=rw,g=,o=r wormadam1/donphan
chmod u=rw,g=w,o=r wormadam1/vigoroth
chmod u=rx,g=rwx,o=wx wormadam1/piloswine
chmod u=rwx,g=rwx,o=rwx wormadam1/trubbish
chmod u=rx,g=wx,o=rwx wormadam1/karrablast
chmod u=rw,g=,o=r wormadam1/conkeldurr
#3
ln taillow5 wormadam1/donphantaillow
chmod u+r empoleon3
chmod u+r empoleon3/jynx
cp -R empoleon3 braviary3/empoleon
chmod u-r empoleon3/jynx
chmod u-r empoleon3
cat braviary3/torchic wormadam1/donphan > grimer5_29
ln -s staraptor1 empoleon3/axewstaraptor
chmod u+w wormadam1/karrablast
cp grimer5 wormadam1/karrablast
chmod u-w wormadam1/karrablast
ln -s braviary3 Copy_24
cat grimer5 > empoleon3/axewgrimer
#4
wc -m ./*3 ./*/*3 2>/dev/null | sort
ls -lR | sort -rk2 | grep -v 'total' | head -3
cat -n  l* */l* 2>&1 | sort -r
ls -lRt a* 2>/dev/null
ls -lR *on* | sort -r | tail -2
ls -lRtu a* 2>/tmp/err_log | tail -2
#5
rm grimer5
rm wormadam1/vigoroth
rm -f empoleon3/axewstarapt*
rm -f wormadam1/donphantaill*
chmod -R u=rwx braviary3
rm -rf braviary3
rm -rf empoleon3/ampharos