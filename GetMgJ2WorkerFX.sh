#!/bin/bash

PATH="$PATH:/usr/local/bin"
ramDrive="/dev/shm"
SECONDS=0
getHour=$1
getDate=$(date -d '4 hour ago' -u +"%Y%m%d")
modelRunString=$getDate"_"$getHour"Z"
wg2Path="/home/astump/src/grib2/wgrib2"
xml2Path=$ramDrive"/wxMOSg2"

cmcBase="http://dd.weather.gc.ca/model_gem_global/25km/grib2/lat_lon/"$getHour
gfsBase="http://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs."$getDate""$getHour
hrrrBase="http://nomads.ncep.noaa.gov/pub/data/nccf/com/hrrr/prod/hrrr."$getDate
namBase="http://nomads.ncep.noaa.gov/pub/data/nccf/com/nam/prod/nam."$getDate
rapBase="http://tgftp.nws.noaa.gov/SL.us008001/ST.opnl/MT.rap_CY."$getHour"/RD."$getDate"/PT.grid_DF.gr2"

FHoursG=($(echo "SELECT FHour FROM GFSFHA WHERE DoGet=1 AND GFS=1 AND Round="$2";" | mysql -N WxObs))
FHoursH=($(echo "SELECT FHour FROM GFSFHA WHERE DoGet=1 AND HRRR=1 AND Round="$2";" | mysql -N WxObs))
FHoursN=($(echo "SELECT FHour FROM GFSFHA WHERE DoGet=1 AND NAM=1 AND Round="$2";" | mysql -N WxObs))
FHoursR=($(echo "SELECT FHour FROM GFSFHA WHERE DoGet=1 AND RAP=1 AND Round="$2";" | mysql -N WxObs))
Heights=($(echo "SELECT HeightMb FROM ModelHeightLevels WHERE GFS=1 ORDER BY HeightMb DESC;" | mysql -N WxObs))

pointInputReadIn=$(cat $xml2Path/pointDump.txt)

for tFHour in ${FHoursH[@]}
do

	modelName="HRRR"
	iterk=0
	gribSpot=3
	tFHour2D=$(echo -| awk -v fh="$tFHour" '{printf "%02d\n", fh}')
	tFHour3D=$(echo -| awk -v fh="$tFHour" '{printf "%03d\n", fh}')
	tFHour4D=$(echo -| awk -v fh="$tFHour" '{printf "%04d\n", fh}')
	Sounding=$xml2Path/outHRRR_$tFHour4D.csv
	thisFHData=$hrrrBase"/hrrr.t"$getHour"z.wrfprsf"$tFHour2D".grib2"
	Filters=$(cat $ramDrive/g2FiltersD.txt)"\|"$(cat $ramDrive/g2FiltersR.txt)

	$wg2Path/get_inv.pl $thisFHData".idx" | grep "$Filters" | $wg2Path/get_grib.pl $thisFHData $xml2Path/fx$tFHour4D
	"$wg2Path/wgrib2" $xml2Path/fx$tFHour4D $pointInputReadIn > $Sounding
	"$wg2Path/g2ctl" $xml2Path/fx$tFHour4D > $xml2Path/fx$tFHour4D".ctl"
	gribmap -v -i $xml2Path/fx$tFHour4D".ctl"

	RH[100]=$(sed -n '/^2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	RH[150]=$(sed -n '/^7:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
 	RH[200]=$(sed -n '/^12:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	RH[250]=$(sed -n '/^17:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	RH[300]=$(sed -n '/^22:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	RH[350]=$(sed -n '/^27:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	RH[400]=$(sed -n '/^32:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	RH[450]=$(sed -n '/^37:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	RH[500]=$(sed -n '/^43:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	RH[550]=$(sed -n '/^48:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	RH[600]=$(sed -n '/^53:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	RH[650]=$(sed -n '/^58:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	RH[700]=$(sed -n '/^63:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	RH[750]=$(sed -n '/^68:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	RH[800]=$(sed -n '/^73:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	RH[850]=$(sed -n '/^78:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	RH[900]=$(sed -n '/^83:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	RH[950]=$(sed -n '/^88:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	RH[1000]=$(sed -n '/^93:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	RH[0]=$(sed -n '/^100:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')

	TK[100]=$(sed -n '/^1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	TK[150]=$(sed -n '/^6:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	TK[200]=$(sed -n '/^11:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	TK[250]=$(sed -n '/^16:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	TK[300]=$(sed -n '/^21:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	TK[350]=$(sed -n '/^26:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	TK[400]=$(sed -n '/^31:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	TK[450]=$(sed -n '/^36:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	TK[500]=$(sed -n '/^42:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	TK[550]=$(sed -n '/^47:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	TK[600]=$(sed -n '/^52:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	TK[650]=$(sed -n '/^57:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	TK[700]=$(sed -n '/^62:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	TK[750]=$(sed -n '/^67:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	TK[800]=$(sed -n '/^72:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	TK[850]=$(sed -n '/^77:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	TK[900]=$(sed -n '/^82:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	TK[950]=$(sed -n '/^87:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	TK[1000]=$(sed -n '/^92:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	TK[0]=$(sed -n '/^98:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')

	WU[100]=$(sed -n '/^4:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	WV[100]=$(sed -n '/^5:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	WU[150]=$(sed -n '/^9:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	WV[150]=$(sed -n '/^10:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	WU[200]=$(sed -n '/^14:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	WV[200]=$(sed -n '/^15:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	WU[250]=$(sed -n '/^19:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	WV[250]=$(sed -n '/^20:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	WU[300]=$(sed -n '/^24:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	WV[300]=$(sed -n '/^25:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	WU[350]=$(sed -n '/^29:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	WV[350]=$(sed -n '/^30:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	WU[400]=$(sed -n '/^34:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	WV[400]=$(sed -n '/^35:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	WU[450]=$(sed -n '/^39:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	WV[450]=$(sed -n '/^40:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	WU[500]=$(sed -n '/^45:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	WV[500]=$(sed -n '/^46:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	WU[550]=$(sed -n '/^50:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	WV[550]=$(sed -n '/^51:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	WU[600]=$(sed -n '/^55:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	WV[600]=$(sed -n '/^56:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	WU[650]=$(sed -n '/^60:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	WV[650]=$(sed -n '/^61:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	WU[700]=$(sed -n '/^65:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	WV[700]=$(sed -n '/^66:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	WU[750]=$(sed -n '/^70:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	WV[750]=$(sed -n '/^71:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	WU[800]=$(sed -n '/^75:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	WV[800]=$(sed -n '/^76:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	WU[850]=$(sed -n '/^80:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	WV[850]=$(sed -n '/^81:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	WU[900]=$(sed -n '/^85:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	WV[900]=$(sed -n '/^86:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	WU[950]=$(sed -n '/^90:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	WV[950]=$(sed -n '/^91:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	WU[1000]=$(sed -n '/^95:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	WV[1000]=$(sed -n '/^96:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	WU[0]=$(sed -n '/^101:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	WV[0]=$(sed -n '/^102:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')

	CAPE=$(sed -n '/^105:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	CIN=$(sed -n '/^106:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	PRATE=$(sed -n '/^103:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	PWAT=$(sed -n '/^107:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	HGT500=$(sed -n '/^41:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	LI=$(sed -n '/^109:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	
	TC=($(echo -| awk -v tk="${TK[*]}" '{fields=split(tk,tka,/ /)} { for (i=1; i<=fields; i++) { printf "%.1f\n", tka[i]-273.15 }}'))
	TD=($(echo -| awk -v tc="${TC[*]}" -v rh="${RH[*]}" '{fields=split(tc,tca,/ /); split(rh,rha,/ /)} { for (i=1; i<=fields; i++) { printf "%.1f\n", tca[i]-(100-rha[i])/5}}'))
	WD=($(echo -| awk -v wu="${WU[*]}" -v wv="${WV[*]}" '{fields=split(wu,wua,/ /); split(wv,wva,/ /)} { for (i=1; i<=fields; i++) { printf "%.1f\n", 57.29578*(atan2(wua[i], wva[i]))+180 }}'))
	WS=($(echo -| awk -v wu="${WU[*]}" -v wv="${WV[*]}" '{fields=split(wu,wua,/ /); split(wv,wva,/ /)} { for (i=1; i<=fields; i++) { printf "%.0f\n", sqrt(wua[i]*wua[i]+wva[i]*wva[i])*1.944 }}'))

	for thKey in ${!TK[@]}
	do
		HRRR_T[$thKey]=${HRRR_T[$thKey]}"\"T"$thKey"_"$tFHour"\":\""${TC[$iterk]}"\", "
		HRRR_D[$thKey]=${HRRR_D[$thKey]}"\"D"$thKey"_"$tFHour"\":\""${TD[$iterk]}"\", "
		HRRR_WS[$thKey]=${HRRR_WS[$thKey]}"\"WS"$thKey"_"$tFHour"\":\""${WS[$iterk]}"\", "
		HRRR_WD[$thKey]=${HRRR_WD[$thKey]}"\"WD"$thKey"_"$tFHour"\":\""${WD[$iterk]}"\", "
		iterk=$((iterk+1))
	done

	CIN=$(echo -| awk -v cin="$CIN" '{printf "%.2f\n", cin}')
	LI=$(echo -| awk -v li="$LI" '{printf "%.2f\n", li}')
	PRATE=$(echo -| awk -v ap="$PRATE" '{printf "%.2f\n", ap*0.03937}')
	PWAT=$(echo -| awk -v pw="$PWAT" '{printf "%.2f\n", pw*0.03937}')

	HRRR_PRATE=$HRRR_PRATE"\"PRATE_"$tFHour"\":\""$PRATE"\", "
	HRRR_PWAT=$HRRR_PWAT"\"PWAT_"$tFHour"\":\""$PWAT"\", "
	HRRR_CAPE=$HRRR_CAPE"\"CAPE_"$tFHour"\":\""$CAPE"\", "
	HRRR_CIN=$HRRR_CIN"\"CIN_"$tFHour"\":\""$CIN"\", "
	HRRR_HGT500=$HRRR_HGT500"\"HGT500_"$tFHour"\":\""$HGT500"\", "

	echo "run /dev/shm/ModelData.gs ${modelName} ${tFHour4D} ${getDate} ${getHour}" | grads -blc "open "$xml2Path"/fx"$tFHour4D".ctl"
	
done

for thHeight in ${Heights[@]}
do
	echo ${HRRR_D[$thHeight]} >> $xml2Path"/HRRR_"$2".json"
	echo ${HRRR_T[$thHeight]} >> $xml2Path"/HRRR_"$2".json"
	echo ${HRRR_WD[$thHeight]} >> $xml2Path"/HRRR_"$2".json"
	echo ${HRRR_WS[$thHeight]} >> $xml2Path"/HRRR_"$2".json"
done

echo $HRRR_CAPE >> $xml2Path"/HRRR_"$2".json"
echo $HRRR_CIN >> $xml2Path"/HRRR_"$2".json"
echo $HRRR_PRATE >> $xml2Path"/HRRR_"$2".json"
echo $HRRR_PWAT >> $xml2Path"/HRRR_"$2".json"
echo $HRRR_HGT500 >> $xml2Path"/HRRR_"$2".json"
echo $HRRR_LI >> $xml2Path"/HRRR_"$2".json"

if [ $getHour -eq "00" ] || [ $getHour -eq "06" ] || [ $getHour -eq "12" ] || [ $getHour -eq "18" ]; then

	for tFHour in ${FHoursG[@]}
	do

		modelName="GFS"
		iterk=0
		gribSpot=3
		tFHour3D=$(echo -| awk -v fh="$tFHour" '{printf "%03d\n", fh}')
		tFHour4D=$(echo -| awk -v fh="$tFHour" '{printf "%04d\n", fh}')
		Sounding=$xml2Path/outGFS_$tFHour4D.csv
		thisFHData=$gfsBase"/gfs.t"$getHour"z.pgrb2.0p25.f"$tFHour3D
		Filters=$(cat $ramDrive/g2Filters.txt)

		$wg2Path/get_inv.pl $thisFHData".idx" | grep "$Filters" | $wg2Path/get_grib.pl $thisFHData $xml2Path/fh$tFHour4D
		"$wg2Path/wgrib2" $xml2Path/fh$tFHour4D $pointInputReadIn > $Sounding
		"$wg2Path/g2ctl" $xml2Path/fh$tFHour4D > $xml2Path/fh$tFHour4D".ctl"
		gribmap -v -i $xml2Path/fh$tFHour4D".ctl"

		RH[100]=$(sed -n '/^2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[150]=$(sed -n '/^6:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	 	RH[200]=$(sed -n '/^10:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[250]=$(sed -n '/^14:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[300]=$(sed -n '/^18:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[350]=$(sed -n '/^22:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[400]=$(sed -n '/^26:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[450]=$(sed -n '/^30:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[500]=$(sed -n '/^35:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[550]=$(sed -n '/^39:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[600]=$(sed -n '/^43:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[650]=$(sed -n '/^47:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[700]=$(sed -n '/^51:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[750]=$(sed -n '/^55:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[800]=$(sed -n '/^59:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[850]=$(sed -n '/^63:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[900]=$(sed -n '/^67:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[950]=$(sed -n '/^71:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[1000]=$(sed -n '/^75:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[0]=$(sed -n '/^79:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')

		TK[100]=$(sed -n '/^1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[150]=$(sed -n '/^5:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[200]=$(sed -n '/^9:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[250]=$(sed -n '/^13:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[300]=$(sed -n '/^17:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[350]=$(sed -n '/^21:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[400]=$(sed -n '/^25:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[450]=$(sed -n '/^29:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[500]=$(sed -n '/^34:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[550]=$(sed -n '/^38:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[600]=$(sed -n '/^42:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[650]=$(sed -n '/^46:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[700]=$(sed -n '/^50:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[750]=$(sed -n '/^54:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[800]=$(sed -n '/^58:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[850]=$(sed -n '/^62:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[900]=$(sed -n '/^66:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[950]=$(sed -n '/^70:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[1000]=$(sed -n '/^74:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[0]=$(sed -n '/^78:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')

		WU[100]=$(sed -n '/^3:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[100]=$(sed -n '/^4:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[150]=$(sed -n '/^7:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[150]=$(sed -n '/^8:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[200]=$(sed -n '/^11:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[200]=$(sed -n '/^12:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[250]=$(sed -n '/^15:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[250]=$(sed -n '/^16:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[300]=$(sed -n '/^19:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[300]=$(sed -n '/^20:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[350]=$(sed -n '/^23:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[350]=$(sed -n '/^24:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[400]=$(sed -n '/^27:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[400]=$(sed -n '/^28:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[450]=$(sed -n '/^31:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[450]=$(sed -n '/^33:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[500]=$(sed -n '/^36:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[500]=$(sed -n '/^37:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[550]=$(sed -n '/^40:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[550]=$(sed -n '/^41:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[600]=$(sed -n '/^44:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[600]=$(sed -n '/^45:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[650]=$(sed -n '/^48:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[650]=$(sed -n '/^49:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[700]=$(sed -n '/^52:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[700]=$(sed -n '/^53:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[750]=$(sed -n '/^56:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[750]=$(sed -n '/^57:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[800]=$(sed -n '/^60:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[800]=$(sed -n '/^61:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[850]=$(sed -n '/^64:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[850]=$(sed -n '/^65:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[900]=$(sed -n '/^68:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[900]=$(sed -n '/^69:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[950]=$(sed -n '/^72:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[950]=$(sed -n '/^73:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[1000]=$(sed -n '/^76:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[1000]=$(sed -n '/^77:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[0]=$(sed -n '/^80:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[0]=$(sed -n '/^81:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')

		CAPE=$(sed -n '/^84:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		CIN=$(sed -n '/^85:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		LI=$(sed -n '/^83:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		PRATE=$(sed -n '/^82:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		PWAT=$(sed -n '/^86:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		HGT500=$(sed -n '/^33:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	
		TC=($(echo -| awk -v tk="${TK[*]}" '{fields=split(tk,tka,/ /)} { for (i=1; i<=fields; i++) { printf "%.1f\n", tka[i]-273.15 }}'))
		TD=($(echo -| awk -v tc="${TC[*]}" -v rh="${RH[*]}" '{fields=split(tc,tca,/ /); split(rh,rha,/ /)} { for (i=1; i<=fields; i++) { printf "%.1f\n", tca[i]-(100-rha[i])/5}}'))
		WD=($(echo -| awk -v wu="${WU[*]}" -v wv="${WV[*]}" '{fields=split(wu,wua,/ /); split(wv,wva,/ /)} { for (i=1; i<=fields; i++) { printf "%.1f\n", 57.29578*(atan2(wua[i], wva[i]))+180 }}'))
		WS=($(echo -| awk -v wu="${WU[*]}" -v wv="${WV[*]}" '{fields=split(wu,wua,/ /); split(wv,wva,/ /)} { for (i=1; i<=fields; i++) { printf "%.0f\n", sqrt(wua[i]*wua[i]+wva[i]*wva[i])*1.944 }}'))

		for thKey in ${!TK[@]}
		do
			GFS_T[$thKey]=${GFS_T[$thKey]}"\"T"$thKey"_"$tFHour"\":\""${TC[$iterk]}"\", "
			GFS_D[$thKey]=${GFS_D[$thKey]}"\"D"$thKey"_"$tFHour"\":\""${TD[$iterk]}"\", "
			GFS_WS[$thKey]=${GFS_WS[$thKey]}"\"WS"$thKey"_"$tFHour"\":\""${WS[$iterk]}"\", "
			GFS_WD[$thKey]=${GFS_WD[$thKey]}"\"WD"$thKey"_"$tFHour"\":\""${WD[$iterk]}"\", "
			iterk=$((iterk+1))
		done

		CIN=$(echo -| awk -v cin="$CIN" '{printf "%.2f\n", cin}')
		LI=$(echo -| awk -v li="$LI" '{printf "%.2f\n", li}')
		PRATE=$(echo -| awk -v ap="$PRATE" '{printf "%.2f\n", ap*0.03937}')
		PWAT=$(echo -| awk -v pw="$PWAT" '{printf "%.2f\n", pw*0.03937}')

		GFS_PRATE=$GFS_PRATE"\"PRATE_"$tFHour"\":\""$PRATE"\", "
		GFS_PWAT=$GFS_PWAT"\"PWAT_"$tFHour"\":\""$PWAT"\", "
		GFS_CAPE=$GFS_CAPE"\"CAPE_"$tFHour"\":\""$CAPE"\", "
		GFS_CIN=$GFS_CIN"\"CIN_"$tFHour"\":\""$CIN"\", "
		GFS_LI=$GFS_LI"\"LI_"$tFHour"\":\""$LI"\", "
		GFS_HGT500=$GFS_HGT500"\"HGT500_"$tFHour"\":\""$HGT500"\", "

		echo "run /dev/shm/ModelData.gs ${modelName} ${tFHour4D} ${getDate} ${getHour}" | grads -blc "open "$xml2Path"/fh"$tFHour4D".ctl"
	
	done

	for tFHour in ${FHoursN[@]}
	do

		modelName="NAM"
		iterk=0
		gribSpot=3
		tFHour2D=$(echo -| awk -v fh="$tFHour" '{printf "%02d\n", fh}')
		tFHour4D=$(echo -| awk -v fh="$tFHour" '{printf "%04d\n", fh}')
		Sounding=$xml2Path/outNAM_$tFHour4D.csv
		thisFHData=$namBase"/nam.t"$getHour"z.conusnest.hiresf"$tFHour2D".tm00.grib2"
		Filters=$(cat $ramDrive/g2Filters.txt)"\|"$(cat $ramDrive/g2FiltersR.txt)

		$wg2Path/get_inv.pl $thisFHData".idx" | grep "$Filters" | $wg2Path/get_grib.pl $thisFHData $xml2Path/fn$tFHour4D
		"$wg2Path/wgrib2" $xml2Path/fn$tFHour4D $pointInputReadIn > $Sounding
		"$wg2Path/g2ctl" $xml2Path/fn$tFHour4D > $xml2Path/fn$tFHour4D".ctl"
		gribmap -v -i $xml2Path/fn$tFHour4D".ctl"

		RH[100]=$(sed -n '/^2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[150]=$(sed -n '/^5:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	 	RH[200]=$(sed -n '/^8:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[250]=$(sed -n '/^11:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[300]=$(sed -n '/^14:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[350]=$(sed -n '/^17:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[400]=$(sed -n '/^20:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[450]=$(sed -n '/^23:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[500]=$(sed -n '/^27:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[550]=$(sed -n '/^30:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[600]=$(sed -n '/^33:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[650]=$(sed -n '/^36:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[700]=$(sed -n '/^39:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[750]=$(sed -n '/^42:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[800]=$(sed -n '/^45:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[850]=$(sed -n '/^48:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[900]=$(sed -n '/^51:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[950]=$(sed -n '/^54:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[1000]=$(sed -n '/^57:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[0]=$(sed -n '/^61:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')

		TK[100]=$(sed -n '/^1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[150]=$(sed -n '/^4:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[200]=$(sed -n '/^7:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[250]=$(sed -n '/^10:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[300]=$(sed -n '/^13:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[350]=$(sed -n '/^16:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[400]=$(sed -n '/^19:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[450]=$(sed -n '/^22:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[500]=$(sed -n '/^26:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[550]=$(sed -n '/^29:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[600]=$(sed -n '/^32:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[650]=$(sed -n '/^35:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[700]=$(sed -n '/^38:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[750]=$(sed -n '/^41:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[800]=$(sed -n '/^44:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[850]=$(sed -n '/^47:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[900]=$(sed -n '/^50:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[950]=$(sed -n '/^53:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[1000]=$(sed -n '/^56:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[0]=$(sed -n '/^60:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')

		WU[100]=$(sed -n '/^3.1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[100]=$(sed -n '/^3.2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[150]=$(sed -n '/^6.1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[150]=$(sed -n '/^6.2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[200]=$(sed -n '/^9.1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[200]=$(sed -n '/^9.2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[250]=$(sed -n '/^12.1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[250]=$(sed -n '/^12.2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[300]=$(sed -n '/^15.1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[300]=$(sed -n '/^15.2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[350]=$(sed -n '/^18.1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[350]=$(sed -n '/^18.2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[400]=$(sed -n '/^21.1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[400]=$(sed -n '/^21.2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[450]=$(sed -n '/^24.1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[450]=$(sed -n '/^24.2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[500]=$(sed -n '/^28.1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[500]=$(sed -n '/^28.2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[550]=$(sed -n '/^31.1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[550]=$(sed -n '/^31.2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[600]=$(sed -n '/^34.1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[600]=$(sed -n '/^34.2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[650]=$(sed -n '/^37.1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[650]=$(sed -n '/^37.2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[700]=$(sed -n '/^40.1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[700]=$(sed -n '/^40.2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[750]=$(sed -n '/^43.1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[750]=$(sed -n '/^43.2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[800]=$(sed -n '/^46.1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[800]=$(sed -n '/^46.2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[850]=$(sed -n '/^49.1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[850]=$(sed -n '/^49.2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[900]=$(sed -n '/^52.1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[900]=$(sed -n '/^52.2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[950]=$(sed -n '/^55.1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[950]=$(sed -n '/^55.2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[1000]=$(sed -n '/^58.1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[1000]=$(sed -n '/^58.2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[0]=$(sed -n '/^62.1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[0]=$(sed -n '/^62.2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')

		CAPE=$(sed -n '/^63:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		CIN=$(sed -n '/^64:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		PRATE=$(sed -n '/^68:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		PWAT=$(sed -n '/^65:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		HGT500=$(sed -n '/^25:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		LI=$(sed -n '/^66:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	
		TC=($(echo -| awk -v tk="${TK[*]}" '{fields=split(tk,tka,/ /)} { for (i=1; i<=fields; i++) { printf "%.1f\n", tka[i]-273.15 }}'))
		TD=($(echo -| awk -v tc="${TC[*]}" -v rh="${RH[*]}" '{fields=split(tc,tca,/ /); split(rh,rha,/ /)} { for (i=1; i<=fields; i++) { printf "%.1f\n", tca[i]-(100-rha[i])/5}}'))
		WD=($(echo -| awk -v wu="${WU[*]}" -v wv="${WV[*]}" '{fields=split(wu,wua,/ /); split(wv,wva,/ /)} { for (i=1; i<=fields; i++) { printf "%.1f\n", 57.29578*(atan2(wua[i], wva[i]))+180 }}'))
		WS=($(echo -| awk -v wu="${WU[*]}" -v wv="${WV[*]}" '{fields=split(wu,wua,/ /); split(wv,wva,/ /)} { for (i=1; i<=fields; i++) { printf "%.0f\n", sqrt(wua[i]*wua[i]+wva[i]*wva[i])*1.944 }}'))

		xmlOut=$xml2Path/xmlOutNAM$tFHour4D.xml
		cp /dev/shm/obs.xml $xmlOut
	
		for thKey in ${!TK[@]}
		do
			NAM_T[$thKey]=${NAM_T[$thKey]}"\"T"$thKey"_"$tFHour"\":\""${TC[$iterk]}"\", "
			NAM_D[$thKey]=${NAM_D[$thKey]}"\"D"$thKey"_"$tFHour"\":\""${TD[$iterk]}"\", "
			NAM_WS[$thKey]=${NAM_WS[$thKey]}"\"WS"$thKey"_"$tFHour"\":\""${WS[$iterk]}"\", "
			NAM_WD[$thKey]=${NAM_WD[$thKey]}"\"WD"$thKey"_"$tFHour"\":\""${WD[$iterk]}"\", "
			iterk=$((iterk+1));
		done

		CIN=$(echo -| awk -v cin="$CIN" '{printf "%.2f\n", cin}')
		LI=$(echo -| awk -v li="$LI" '{printf "%.2f\n", li}')
		PRATE=$(echo -| awk -v ap="$PRATE" '{printf "%.2f\n", ap*0.03937}')
		PWAT=$(echo -| awk -v pw="$PWAT" '{printf "%.2f\n", pw*0.03937}')

		NAM_PRATE=$NAM_PRATE"\"PRATE_"$tFHour"\":\""$PRATE"\", "
		NAM_PWAT=$NAM_PWAT"\"PWAT_"$tFHour"\":\""$PWAT"\", "
		NAM_CAPE=$NAM_CAPE"\"CAPE_"$tFHour"\":\""$CAPE"\", "
		NAM_CIN=$NAM_CIN"\"CIN_"$tFHour"\":\""$CIN"\", "
		NAM_LI=$NAM_LI"\"LI_"$tFHour"\":\""$LI"\", "
		NAM_HGT500=$NAM_HGT500"\"HGT500_"$tFHour"\":\""$HGT500"\", "

		echo "run /dev/shm/ModelData.gs ${modelName} ${tFHour4D} ${getDate} ${getHour}" | grads -blc "open "$xml2Path"/fn"$tFHour4D".ctl"
		
	done

	for tFHour in ${FHoursR[@]}
	do

		modelName="RAP"
		iterk=0
		gribSpot=3
		tFHour4D=$(echo -| awk -v fh="$tFHour" '{printf "%04d\n", fh}')
		Sounding=$xml2Path/outRAP_$tFHour4D.csv
		thisFHData=$rapBase"/fh."$tFHour4D"_tl.press_gr.us13km"
		Filters=$(cat $ramDrive/g2Filters.txt)

		$wg2Path/get_inv.pl $thisFHData".idx" | grep "$Filters" | $wg2Path/get_grib.pl $thisFHData $xml2Path/fr$tFHour4D
		"$wg2Path/wgrib2" $xml2Path/fr$tFHour4D $pointInputReadIn > $Sounding
		"$wg2Path/g2ctl" $xml2Path/fr$tFHour4D > $xml2Path/fr$tFHour4D".ctl"
		gribmap -v -i $xml2Path/fr$tFHour4D".ctl"

		RH[100]=$(sed -n '/^2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[150]=$(sed -n '/^5:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	 	RH[200]=$(sed -n '/^8:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[250]=$(sed -n '/^11:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[300]=$(sed -n '/^14:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[350]=$(sed -n '/^17:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[400]=$(sed -n '/^20:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[450]=$(sed -n '/^23:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[500]=$(sed -n '/^27:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[550]=$(sed -n '/^30:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[600]=$(sed -n '/^33:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[650]=$(sed -n '/^36:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[700]=$(sed -n '/^39:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[750]=$(sed -n '/^42:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[800]=$(sed -n '/^45:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[850]=$(sed -n '/^48:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[900]=$(sed -n '/^51:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[950]=$(sed -n '/^54:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[1000]=$(sed -n '/^57:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		RH[0]=$(sed -n '/^60:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')

		TK[100]=$(sed -n '/^1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[150]=$(sed -n '/^4:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[200]=$(sed -n '/^7:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[250]=$(sed -n '/^10:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[300]=$(sed -n '/^13:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[350]=$(sed -n '/^16:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[400]=$(sed -n '/^19:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[450]=$(sed -n '/^22:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[500]=$(sed -n '/^26:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[550]=$(sed -n '/^29:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[600]=$(sed -n '/^32:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[650]=$(sed -n '/^35:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[700]=$(sed -n '/^38:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[750]=$(sed -n '/^41:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[800]=$(sed -n '/^44:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[850]=$(sed -n '/^47:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[900]=$(sed -n '/^50:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[950]=$(sed -n '/^53:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[1000]=$(sed -n '/^56:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		TK[0]=$(sed -n '/^59:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	
		WU[100]=$(sed -n '/^3.1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[100]=$(sed -n '/^3.2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[150]=$(sed -n '/^6.1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[150]=$(sed -n '/^6.2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[200]=$(sed -n '/^9.1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[200]=$(sed -n '/^9.2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[250]=$(sed -n '/^12.1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[250]=$(sed -n '/^12.2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[300]=$(sed -n '/^15.1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[300]=$(sed -n '/^15.2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[350]=$(sed -n '/^18.1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[350]=$(sed -n '/^18.2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[400]=$(sed -n '/^21.1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[400]=$(sed -n '/^21.2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[450]=$(sed -n '/^24.1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[450]=$(sed -n '/^24.2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[500]=$(sed -n '/^28.1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[500]=$(sed -n '/^28.2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[550]=$(sed -n '/^31.1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[550]=$(sed -n '/^31.2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[600]=$(sed -n '/^34.1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[600]=$(sed -n '/^34.2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[650]=$(sed -n '/^37.1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[650]=$(sed -n '/^37.2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[700]=$(sed -n '/^40.1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[700]=$(sed -n '/^40.2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[750]=$(sed -n '/^43.1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[750]=$(sed -n '/^43.2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[800]=$(sed -n '/^46.1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[800]=$(sed -n '/^46.2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[850]=$(sed -n '/^49.1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[850]=$(sed -n '/^49.2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[900]=$(sed -n '/^52.1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[900]=$(sed -n '/^52.2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[950]=$(sed -n '/^55.1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[950]=$(sed -n '/^55.2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[1000]=$(sed -n '/^58.1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[1000]=$(sed -n '/^58.2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WU[0]=$(sed -n '/^61.1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		WV[0]=$(sed -n '/^61.2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')

		CAPE=$(sed -n '/^64:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		CIN=$(sed -n '/^65:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		PRATE=$(sed -n '/^67:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		PWAT=$(sed -n '/^66:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
		HGT500=$(sed -n '/^25:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	
		TC=($(echo -| awk -v tk="${TK[*]}" '{fields=split(tk,tka,/ /)} { for (i=1; i<=fields; i++) { printf "%.1f\n", tka[i]-273.15 }}'))
		TD=($(echo -| awk -v tc="${TC[*]}" -v rh="${RH[*]}" '{fields=split(tc,tca,/ /); split(rh,rha,/ /)} { for (i=1; i<=fields; i++) { printf "%.1f\n", tca[i]-(100-rha[i])/5}}'))
		WD=($(echo -| awk -v wu="${WU[*]}" -v wv="${WV[*]}" '{fields=split(wu,wua,/ /); split(wv,wva,/ /)} { for (i=1; i<=fields; i++) { printf "%.1f\n", 57.29578*(atan2(wua[i], wva[i]))+180 }}'))
		WS=($(echo -| awk -v wu="${WU[*]}" -v wv="${WV[*]}" '{fields=split(wu,wua,/ /); split(wv,wva,/ /)} { for (i=1; i<=fields; i++) { printf "%.0f\n", sqrt(wua[i]*wua[i]+wva[i]*wva[i])*1.944 }}'))

		xmlOut=$xml2Path/xmlOutRAP$tFHour4D.xml
		cp /dev/shm/obs.xml $xmlOut

		for thKey in ${!TK[@]};
		do
			RAP_T[$thKey]=${RAP_T[$thKey]}"\"T"$thKey"_"$tFHour"\":\""${TC[$iterk]}"\", "
			RAP_D[$thKey]=${RAP_D[$thKey]}"\"D"$thKey"_"$tFHour"\":\""${TD[$iterk]}"\", "
			RAP_WS[$thKey]=${RAP_WS[$thKey]}"\"WS"$thKey"_"$tFHour"\":\""${WS[$iterk]}"\", "
			RAP_WD[$thKey]=${RAP_WD[$thKey]}"\"WD"$thKey"_"$tFHour"\":\""${WD[$iterk]}"\", "
			iterk=$((iterk+1));
		done

		CIN=$(echo -| awk -v cin="$CIN" '{printf "%.2f\n", cin}')
		PRATE=$(echo -| awk -v ap="$PRATE" '{printf "%.2f\n", ap*0.03937}')
		PWAT=$(echo -| awk -v pw="$PWAT" '{printf "%.2f\n", pw*0.03937}')

		RAP_PRATE=$RAP_PRATE"\"PRATE_"$tFHour"\":\""$PRATE"\", "
		RAP_PWAT=$RAP_PWAT"\"PWAT_"$tFHour"\":\""$PWAT"\", "
		RAP_CAPE=$RAP_CAPE"\"CAPE_"$tFHour"\":\""$CAPE"\", "
		RAP_CIN=$RAP_CIN"\"CIN_"$tFHour"\":\""$CIN"\", "
		RAP_HGT500=$RAP_HGT500"\"HGT500_"$tFHour"\":\""$HGT500"\", "

		echo "run /dev/shm/ModelData.gs ${modelName} ${tFHour4D} ${getDate} ${getHour}" | grads -blc "open "$xml2Path"/fr"$tFHour4D".ctl"

	done

	for thHeight in ${Heights[@]}
	do
		echo ${GFS_D[$thHeight]} >> $xml2Path"/GFS_"$2".json"
		echo ${GFS_T[$thHeight]} >> $xml2Path"/GFS_"$2".json"
		echo ${GFS_WD[$thHeight]} >> $xml2Path"/GFS_"$2".json"
		echo ${GFS_WS[$thHeight]} >> $xml2Path"/GFS_"$2".json"
		echo ${NAM_D[$thHeight]} >> $xml2Path"/NAM_"$2".json"
		echo ${NAM_T[$thHeight]} >> $xml2Path"/NAM_"$2".json"
		echo ${NAM_WD[$thHeight]} >> $xml2Path"/NAM_"$2".json"
		echo ${NAM_WS[$thHeight]} >> $xml2Path"/NAM_"$2".json"
		echo ${RAP_D[$thHeight]} >> $xml2Path"/RAP_"$2".json"
		echo ${RAP_T[$thHeight]} >> $xml2Path"/RAP_"$2".json"
		echo ${RAP_WD[$thHeight]} >> $xml2Path"/RAP_"$2".json"
		echo ${RAP_WS[$thHeight]} >> $xml2Path"/RAP_"$2".json"
	done
	
	echo $GFS_CAPE >> $xml2Path"/GFS_"$2".json"
	echo $GFS_CIN >> $xml2Path"/GFS_"$2".json"
	echo $GFS_PRATE >> $xml2Path"/GFS_"$2".json"
	echo $GFS_PWAT >> $xml2Path"/GFS_"$2".json"
	echo $GFS_LI >> $xml2Path"/GFS_"$2".json"
	echo $GFS_HGT500 >> $xml2Path"/GFS_"$2".json"

	echo $NAM_CAPE >> $xml2Path"/NAM_"$2".json"
	echo $NAM_CIN >> $xml2Path"/NAM_"$2".json"
	echo $NAM_PRATE >> $xml2Path"/NAM_"$2".json"
	echo $NAM_PWAT >> $xml2Path"/NAM_"$2".json"
	echo $NAM_HGT500 >> $xml2Path"/NAM_"$2".json"
	echo $NAM_LI >> $xml2Path"/NAM_"$2".json"

	echo $RAP_CAPE >> $xml2Path"/RAP_"$2".json"
	echo $RAP_CIN >> $xml2Path"/RAP_"$2".json"
	echo $RAP_PRATE >> $xml2Path"/RAP_"$2".json"
	echo $RAP_PWAT >> $xml2Path"/RAP_"$2".json"
	echo $RAP_HGT500 >> $xml2Path"/RAP_"$2".json"

	if [ $getHour -eq "00" ] || [ $getHour -eq "12" ]; then

		FHoursC=($(echo "SELECT FHour FROM GFSFHA WHERE DoGet=1 AND CMC=1 AND Round="$2";" | mysql -N WxObs))
		VarsC=($(echo "SELECT VarName FROM CMCModelVars WHERE HeightLoop=0;" | mysql -N WxObs))
		VarsCL=($(echo "SELECT VarName FROM CMCModelVars WHERE HeightLoop=1;" | mysql -N WxObs))
		HeightsC=($(echo "SELECT HeightMb FROM ModelHeightLevels WHERE CMC=1 ORDER BY HeightMb DESC;" | mysql -N WxObs))

		for tFHour in ${FHoursC[@]}
		do
	
			modelName="CMC"
			iterk=0
			gribSpot=3
			tFHour3D=$(echo -| awk -v fh="$tFHour" '{printf "%03d\n", fh}')
			tFHour4D=$(echo -| awk -v fh="$tFHour" '{printf "%04d\n", fh}')
			mg2File="fc"$tFHour4D
			Sounding=$xml2Path/outCMC_$tFHour4D.csv
			for tVar in ${VarsCL[@]}
			do
				for tHeight in ${HeightsC[@]}
				do
					thisFHData=$cmcBase"/"$tFHour3D"/CMC_glb_"$tVar"_"$tHeight"_latlon.24x.24_"$getDate""$getHour"_P"$tFHour3D".grib2"
					echo $thisFHData
					curl --retry 0 $thisFHData > $xml2Path"/fc"$tFHour4D"_"$tVar"_"$tHeight".part"
				done
			done
			for tVar in ${VarsC[@]}
			do
				thisFHData=$cmcBase"/"$tFHour3D"/CMC_glb_"$tVar"_latlon.24x.24_"$getDate""$getHour"_P"$tFHour3D".grib2"
				echo $thisFHData
				curl --retry 0 $thisFHData > $xml2Path"/fc"$tFHour4D"_"$tVar"_SFC_0.part"
			done
			cat $xml2Path/fc$tFHour4D*.part > $xml2Path"/fc"$tFHour4D
			rm $xml2Path/fc$tFHour4D*.part
			"$wg2Path/wgrib2" $xml2Path/fc$tFHour4D $pointInputReadIn > $Sounding
			"$wg2Path/g2ctl" $xml2Path/fc$tFHour4D > $xml2Path/fc$tFHour4D".ctl"
			gribmap -v -i $xml2Path/fc$tFHour4D".ctl"

			DK[0]=$(sed -n '/^2:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')

			TK[100]=$(sed -n '/^24:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			TK[150]=$(sed -n '/^25:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			TK[200]=$(sed -n '/^26:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			TK[250]=$(sed -n '/^27:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			TK[300]=$(sed -n '/^28:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			TK[350]=$(sed -n '/^29:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			TK[400]=$(sed -n '/^30:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			TK[450]=$(sed -n '/^31:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			TK[500]=$(sed -n '/^32:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			TK[550]=$(sed -n '/^33:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			TK[600]=$(sed -n '/^34:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			TK[650]=$(sed -n '/^35:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			TK[700]=$(sed -n '/^36:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			TK[750]=$(sed -n '/^37:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			TK[800]=$(sed -n '/^38:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			TK[850]=$(sed -n '/^39:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			TK[900]=$(sed -n '/^40:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			TK[950]=$(sed -n '/^41:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			TK[1000]=$(sed -n '/^23:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			TK[0]=$(sed -n '/^42:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	
			WU[100]=$(sed -n '/^44:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			WV[100]=$(sed -n '/^63:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			WU[150]=$(sed -n '/^45:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			WV[150]=$(sed -n '/^64:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			WU[200]=$(sed -n '/^46:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			WV[200]=$(sed -n '/^65:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			WU[250]=$(sed -n '/^47:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			WV[250]=$(sed -n '/^66:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			WU[300]=$(sed -n '/^48:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			WV[300]=$(sed -n '/^67:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			WU[350]=$(sed -n '/^49:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			WV[350]=$(sed -n '/^68:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			WU[400]=$(sed -n '/^50:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			WV[400]=$(sed -n '/^69:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			WU[450]=$(sed -n '/^51:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			WV[450]=$(sed -n '/^70:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			WU[500]=$(sed -n '/^52:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			WV[500]=$(sed -n '/^71:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			WU[550]=$(sed -n '/^53:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			WV[550]=$(sed -n '/^72:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			WU[600]=$(sed -n '/^54:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			WV[600]=$(sed -n '/^73:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			WU[650]=$(sed -n '/^55:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			WV[650]=$(sed -n '/^74:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			WU[700]=$(sed -n '/^56:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			WV[700]=$(sed -n '/^75:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			WU[750]=$(sed -n '/^57:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			WV[750]=$(sed -n '/^76:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			WU[800]=$(sed -n '/^58:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			WV[800]=$(sed -n '/^77:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			WU[850]=$(sed -n '/^59:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			WV[850]=$(sed -n '/^78:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			WU[900]=$(sed -n '/^60:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			WV[900]=$(sed -n '/^79:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			WU[950]=$(sed -n '/^61:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			WV[950]=$(sed -n '/^80:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			WU[1000]=$(sed -n '/^43:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			WV[1000]=$(sed -n '/^62:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			WU[0]=$(sed -n '/^61:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			WV[0]=$(sed -n '/^80:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')

			PRATE=$(sed -n '/^1:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
			HGT500=$(sed -n '/^12:/p' $Sounding | cut -d ',' -f $gribSpot | sed 's/val\=//g')
	
			TC=($(echo -| awk -v tk="${TK[*]}" '{fields=split(tk,tka,/ /)} { for (i=1; i<=fields; i++) { printf "%.1f\n", tka[i]-273.15 }}'))
			TD=($(echo -| awk -v tk="${DK[*]}" '{fields=split(dk,dka,/ /)} { for (i=1; i<=fields; i++) { printf "%.1f\n", dka[i]-273.15 }}'))
			WD=($(echo -| awk -v wu="${WU[*]}" -v wv="${WV[*]}" '{fields=split(wu,wua,/ /); split(wv,wva,/ /)} { for (i=1; i<=fields; i++) { printf "%.1f\n", 57.29578*(atan2(wua[i], wva[i]))+180 }}'))
			WS=($(echo -| awk -v wu="${WU[*]}" -v wv="${WV[*]}" '{fields=split(wu,wua,/ /); split(wv,wva,/ /)} { for (i=1; i<=fields; i++) { printf "%.0f\n", sqrt(wua[i]*wua[i]+wva[i]*wva[i])*1.944 }}'))
	
			for thKey in ${!TK[@]}
			do
				CMC_T[$thKey]=${CMC_T[$thKey]}"\"T"$thKey"_"$tFHour"\":\""${TC[$iterk]}"\", "
				CMC_D[$thKey]=${CMC_D[$thKey]}"\"D"$thKey"_"$tFHour"\":\""${TD[$iterk]}"\", "
				CMC_WS[$thKey]=${CMC_WS[$thKey]}"\"WS"$thKey"_"$tFHour"\":\""${WS[$iterk]}"\", "
				CMC_WD[$thKey]=${CMC_WD[$thKey]}"\"WD"$thKey"_"$tFHour"\":\""${WD[$iterk]}"\", "
				iterk=$((iterk+1))
			done
	
			PRATE=$(echo -| awk -v ap="$PRATE" '{printf "%.2f\n", ap*0.03937}')
	
			CMC_PRATE=$CMC_PRATE"\"PRATE_"$tFHour"\":\""$PRATE"\", "
			CMC_HGT500=$CMC_HGT500"\"HGT500_"$tFHour"\":\""$HGT500"\", "

			echo "run /dev/shm/ModelData.gs ${modelName} ${tFHour4D} ${getDate} ${getHour}" | grads -blc "open "$xml2Path"/fc"$tFHour4D".ctl"
	
		done
	
		for thHeight in ${Heights[@]}
		do
			echo ${CMC_D[$thHeight]} >> $xml2Path"/CMC_"$2".json"
			echo ${CMC_T[$thHeight]} >> $xml2Path"/CMC_"$2".json"
			echo ${CMC_WD[$thHeight]} >> $xml2Path"/CMC_"$2".json"
			echo ${CMC_WS[$thHeight]} >> $xml2Path"/CMC_"$2".json"
		done

		echo $CMC_PRATE >> $xml2Path"/CMC_"$2".json"
		echo $CMC_HGT500 >> $xml2Path"/CMC_"$2".json"

	fi

fi
