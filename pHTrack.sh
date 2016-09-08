#!/bin/bash

PassedStormID=$1
#TrackURL=$2
TrackFile="track.dat"
QueriesOut="QueriesOut.sql"


#curl --retry 5 "$TrackURL" > $TrackFile
pYear=$(echo $PassedStormID | cut -c1-4)

sed -i 's/\s\+/,/g' $TrackFile
sed -i '/^ *$/d' $TrackFile

ufFirstLine=$(sed -n '/.*,1,/p' $TrackFile)
ufLastLine=$(tail -1 $TrackFile)
ufDateStart=$(echo $ufFirstLine | cut -d ',' -f 5)
ufDateEnd=$(echo $ufLastLine | cut -d ',' -f 5)
pDateStart=$pYear"-"$(echo $ufDateStart | cut -c1-5 | sed 's/\//-/')
pDateEnd=$pYear"-"$(echo $ufDateEnd | cut -c1-5 | sed 's/\//-/')

sed -i 's/al\,/al /g' $TrackFile
stormType=$(sed '2q;d' $TrackFile | cut -d ',' -f 1)
stormName=$(sed '2q;d' $TrackFile | cut -d ',' -f 2)

declare -a windSpeeds
declare -a pressures

sed -i 's/AL\,/AL /g' $TrackFile
sed -i 's/,-,/,9999,/g' $TrackFile

sed -i '1,3d' $TrackFile

readarray trackData < $TrackFile

for lineNo in "${trackData[@]}"; do
	windSpeeds=(${windSpeeds[@]} $(echo $lineNo | cut -d ',' -f 6))
	pressures=(${pressures[@]} $(echo $lineNo | cut -d ',' -f 7))
done

maxWindSpeed=0
minPressure=9999

for n in "${windSpeeds[@]}"; do
	((n > maxWindSpeed)) && maxWindSpeed=$n
done

for n in "${pressures[@]}"; do
	((n < minPressure)) && minPressure=$n
done

sed -i ':a;N;$!ba;s/\n,/\],\
\[/g' $TrackFile
sed -i '0,/,/{s/,/\[/}' $TrackFile
sed -i '$s/$/\]/' $TrackFile

trackFileData=$(cat $TrackFile)

queryString="INSERT INTO HurricaneTracks VALUES ('"$PassedStormID"','"$pDateStart"','"$pDateEnd"','"$stormName"','"$stormType"',"$maxWindSpeed","$minPressure",'["$trackFileData"]',NULL);"
queryStringCleaner="UPDATE HurricaneTracks SET ASON=(REPLACE(ASON,'], [','],[')) WHERE ASON LIKE '%], [%';"

echo $queryString > $QueriesOut
echo $queryStringCleaner >> $QueriesOut
echo $queryString

mysql Core < $QueriesOut
rm $QueriesOut
