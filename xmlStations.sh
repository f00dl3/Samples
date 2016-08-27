Stations=$(cat /dev/shm/xmlStations.txt)

for Station in $Stations
do
	echo $Station
	Sounding="/dev/shm/"$Station".txt"
	xmlOut="/dev/shm/"$Station".xml"
	curl --retry 5 "http://w1.weather.gov/xml/current_obs/K"$Station".xml" > $xmlOut
	curl --retry 5 "http://vortex.plymouth.edu/cgi-bin/gen_grbsnd.cgi?id=K"$Station"&mo=rc1&pl=out4&ft=h00&cu=latest&pt=parcel" > $Sounding
	sed -i 's/\s\+/,/g' $Sounding
	BRN=$(sed -n '/.*Bulk\,Rich\,Number/p' $Sounding | cut -d ',' -f 4)
	BSHR=$(sed -n '/.*Bulk\,Shear\:/p' $Sounding | cut -d ',' -f 3)
	CAPE=$(sed -n '/.*CAPE/p' $Sounding | cut -d ',' -f 3)
	CAPS=$(sed -n '/.*Cap\,Strength\:/{p;q;}' $Sounding | cut -d ',' -f 3)
	CIN=$(sed -n '/.*Inhibition/p' $Sounding | cut -d ',' -f 4)
	EHI=$(sed -n '/Energy\-Hel\,index/p' $Sounding | cut -d ',' -f 3)
	EIND=$(sed -n '/.*Energy\,Index\:/p' $Sounding | cut -d ',' -f 3)
	KIND=$(sed -n '/.*K\,Index\:/{p;q;}' $Sounding | cut -d ',' -f 3)
	LAPSE=$(sed -n '/.*500\,lapse\,rate\:/p' $Sounding | cut -d ',' -f 4)
	LI=$(sed -n '/.*Lifted\,Index\:/p' $Sounding | cut -d ',' -f 3)
	MMR=$(sed -n '/.*\,Mean\,mixing\,ratio/{p;q;}' $Sounding | cut -d ',' -f 5)
	MUVV=$(sed -n '/.*Max\,Up\,Vert\,Vel\:/{p;q;}' $Sounding | cut -d ',' -f 5)
	PWAT=$(sed -n '/.*\Precipitable\,water/{p;q;}' $Sounding | cut -d ',' -f 3)
	SLCL=$(sed -n '/.*Sfc\-Lift\,cond\,lev\,/p' $Sounding | cut -d ',' -f 8)
	FZLV=$(sed -n '/.*Freezing\,level\:/p' $Sounding | cut -d ',' -f 9)
	WZLV=$(sed -n '/.*Wetbulb\,zero\:/p' $Sounding | cut -d ',' -f 9)
	SSFC=$(sed -n '/.*SFC\,/p' $Sounding)
	WBSFC=$(echo $SSFC | cut -d ',' -f 8)
	S950=$(sed -n '/.*2\,950/p' $Sounding)
	TT950=$(echo $S950 | cut -d ',' -f 5)
	TD950=$(echo $S950 | cut -d ',' -f 6)
	WB950=$(echo $S950 | cut -d ',' -f 9)
	WD950=$(echo $S950 | cut -d ',' -f 10)
	WS950=$(echo $S950 | cut -d ',' -f 11)
	S900=$(sed -n '/.*3\,900/p' $Sounding)
	TT900=$(echo $S900 | cut -d ',' -f 5)
	TD900=$(echo $S900 | cut -d ',' -f 6)
	WB900=$(echo $S900 | cut -d ',' -f 9)
	WD900=$(echo $S900 | cut -d ',' -f 10)
	WS900=$(echo $S900 | cut -d ',' -f 11)
	S850=$(sed -n '/.*4\,850/p' $Sounding)
	TT850=$(echo $S850 | cut -d ',' -f 5)
	TD850=$(echo $S850 | cut -d ',' -f 6)
	WB850=$(echo $S850 | cut -d ',' -f 9)
	WD850=$(echo $S850 | cut -d ',' -f 10)
	WS850=$(echo $S850 | cut -d ',' -f 11)
	S800=$(sed -n '/.*5\,800/p' $Sounding)
	TT800=$(echo $S800 | cut -d ',' -f 5)
	TD800=$(echo $S800 | cut -d ',' -f 6)
	WB800=$(echo $S800 | cut -d ',' -f 9)
	WD800=$(echo $S800 | cut -d ',' -f 10)
	WS800=$(echo $S800 | cut -d ',' -f 11)
	S750=$(sed -n '/.*6\,750/p' $Sounding)
	TT750=$(echo $S750 | cut -d ',' -f 5)
	TD750=$(echo $S750 | cut -d ',' -f 6)
	WB750=$(echo $S750 | cut -d ',' -f 9)
	WD750=$(echo $S750 | cut -d ',' -f 10)
	WS750=$(echo $S750 | cut -d ',' -f 11)
	S700=$(sed -n '/.*7\,700/p' $Sounding)
	TT700=$(echo $S700 | cut -d ',' -f 5)
	TD700=$(echo $S700 | cut -d ',' -f 6)
	WB700=$(echo $S700 | cut -d ',' -f 9)
	WD700=$(echo $S700 | cut -d ',' -f 10)
	WS700=$(echo $S700 | cut -d ',' -f 11)
	S650=$(sed -n '/.*8\,650/p' $Sounding)
	TT650=$(echo $S650 | cut -d ',' -f 5)
	TD650=$(echo $S650 | cut -d ',' -f 6)
	WB650=$(echo $S650 | cut -d ',' -f 9)
	WD650=$(echo $S650 | cut -d ',' -f 10)
	WS650=$(echo $S650 | cut -d ',' -f 11)
	S600=$(sed -n '/.*9\,600/p' $Sounding)
	TT600=$(echo $S600 | cut -d ',' -f 5)
	TD600=$(echo $S600 | cut -d ',' -f 6)
	WB600=$(echo $S600 | cut -d ',' -f 9)
	WD600=$(echo $S600 | cut -d ',' -f 10)
	WS600=$(echo $S600 | cut -d ',' -f 11)
	S550=$(sed -n '/.*10\,550/p' $Sounding)
	TT550=$(echo $S550 | cut -d ',' -f 5)
	TD550=$(echo $S550 | cut -d ',' -f 6)
	WB550=$(echo $S550 | cut -d ',' -f 9)
	WD550=$(echo $S550 | cut -d ',' -f 10)
	WS550=$(echo $S550 | cut -d ',' -f 11)
	S500=$(sed -n '/.*11\,500/p' $Sounding)
	TT500=$(echo $S500 | cut -d ',' -f 5)
	TD500=$(echo $S500 | cut -d ',' -f 6)
	WB500=$(echo $S500 | cut -d ',' -f 9)
	WD500=$(echo $S500 | cut -d ',' -f 10)
	WS500=$(echo $S500 | cut -d ',' -f 11)
	S450=$(sed -n '/.*12\,450/p' $Sounding)
	TT450=$(echo $S450 | cut -d ',' -f 5)
	TD450=$(echo $S450 | cut -d ',' -f 6)
	WB450=$(echo $S450 | cut -d ',' -f 9)
	WD450=$(echo $S450 | cut -d ',' -f 10)
	WS450=$(echo $S450 | cut -d ',' -f 11)
	S400=$(sed -n '/.*13\,400/p' $Sounding)
	TT400=$(echo $S400 | cut -d ',' -f 5)
	TD400=$(echo $S400 | cut -d ',' -f 6)
	WB400=$(echo $S400 | cut -d ',' -f 9)
	WD400=$(echo $S400 | cut -d ',' -f 10)
	WS400=$(echo $S400 | cut -d ',' -f 11)
	S350=$(sed -n '/.*14\,350/p' $Sounding)
	TT350=$(echo $S350 | cut -d ',' -f 5)
	TD350=$(echo $S350 | cut -d ',' -f 6)
	WB350=$(echo $S350 | cut -d ',' -f 9)
	WD350=$(echo $S350 | cut -d ',' -f 10)
	WS350=$(echo $S350 | cut -d ',' -f 11)
	S300=$(sed -n '/.*15\,300/p' $Sounding)
	TT300=$(echo $S300 | cut -d ',' -f 5)
	TD300=$(echo $S300 | cut -d ',' -f 6)
	WB300=$(echo $S300 | cut -d ',' -f 9)
	WD300=$(echo $S300 | cut -d ',' -f 10)
	WS300=$(echo $S300 | cut -d ',' -f 11)
	S250=$(sed -n '/.*16\,250/p' $Sounding)
	TT250=$(echo $S250 | cut -d ',' -f 5)
	WD250=$(echo $S250 | cut -d ',' -f 6)
	WS250=$(echo $S250 | cut -d ',' -f 7)
	S200=$(sed -n '/.*17\,200/p' $Sounding)
	TT200=$(echo $S200 | cut -d ',' -f 5)
	WD200=$(echo $S200 | cut -d ',' -f 6)
	WS200=$(echo $S200 | cut -d ',' -f 7)
	S150=$(sed -n '/.*18\,150/p' $Sounding)
	TT150=$(echo $S150 | cut -d ',' -f 5)
	WD150=$(echo $S150 | cut -d ',' -f 6)
	WS150=$(echo $S150 | cut -d ',' -f 7)
	S100=$(sed -n '/.*19\,100/p' $Sounding)
	TT100=$(echo $S100 | cut -d ',' -f 5)
	WD100=$(echo $S100 | cut -d ',' -f 6)
	WS100=$(echo $S100 | cut -d ',' -f 7)
	sed -i '/\/dewpoint_c/a <CAPE>'"$CAPE"'<\/CAPE><EHI>'"$EHI"'<\/EHI><LI>'"$LI"'<\/LI><CIN>'"$CIN"'<\/CIN><EIND>'"$EIND"'<\/EIND>' $xmlOut
	sed -i '/\/dewpoint_c/a <MUVV>'"$MUVV"'<\/MUVV><MMR>'"$MMR"'<\/MMR><PWAT>'"$PWAT"'<\/PWAT><KIND>'"$KIND"'<\/KIND><CAPS>'"$CAPS"'<\/CAPS>' $xmlOut
	sed -i '/\/dewpoint_c/a <SLCL>'"$SLCL"'<\/SLCL><LAPSE>'"$LAPSE"'<\/LAPSE><BRN>'"$BRN"'<\/BRN><BSHR>'"$BSHR"'<\/BSHR><SFCWB>'"$WBSFC"'<\/SFCWB>' $xmlOut
	sed -i '/\/dewpoint_c/a <FZLV>'"$FZLV"'<\/FZLV><WZLV>'"$WZLV"'<\/WZLV>' $xmlOut
	sed -i '/\/dewpoint_c/a <950WS>'"$WS950"'<\/950WS><950WB>'"$WB950"'<\/950WB><950WD>'"$WD950"'<\/950WD><950T>'"$TT950"'<\/950T><950D>'"$TD950"'<\/950D>' $xmlOut
	sed -i '/\/dewpoint_c/a <900WS>'"$WS900"'<\/900WS><900WB>'"$WB900"'<\/900WB><900WD>'"$WD900"'<\/900WD><900T>'"$TT900"'<\/900T><900D>'"$TD900"'<\/900D>' $xmlOut
	sed -i '/\/dewpoint_c/a <850WS>'"$WS850"'<\/850WS><850WB>'"$WB850"'<\/850WB><850WD>'"$WD850"'<\/850WD><850T>'"$TT850"'<\/850T><850D>'"$TD850"'<\/850D>' $xmlOut
	sed -i '/\/dewpoint_c/a <800WS>'"$WS800"'<\/800WS><800WB>'"$WB800"'<\/800WB><800WD>'"$WD800"'<\/800WD><800T>'"$TT800"'<\/800T><800D>'"$TD800"'<\/800D>' $xmlOut
	sed -i '/\/dewpoint_c/a <750WS>'"$WS750"'<\/750WS><750WB>'"$WB750"'<\/750WB><750WD>'"$WD750"'<\/750WD><750T>'"$TT750"'<\/750T><750D>'"$TD750"'<\/750D>' $xmlOut
	sed -i '/\/dewpoint_c/a <700WS>'"$WS700"'<\/700WS><700WB>'"$WB700"'<\/700WB><700WD>'"$WD700"'<\/700WD><700T>'"$TT700"'<\/700T><700D>'"$TD700"'<\/700D>' $xmlOut
	sed -i '/\/dewpoint_c/a <650WS>'"$WS650"'<\/650WS><650WB>'"$WB650"'<\/650WB><650WD>'"$WD650"'<\/650WD><650T>'"$TT650"'<\/650T><650D>'"$TD650"'<\/650D>' $xmlOut
	sed -i '/\/dewpoint_c/a <600WS>'"$WS600"'<\/600WS><600WB>'"$WB600"'<\/600WB><600WD>'"$WD600"'<\/600WD><600T>'"$TT600"'<\/600T><600D>'"$TD600"'<\/600D>' $xmlOut
	sed -i '/\/dewpoint_c/a <550WS>'"$WS550"'<\/550WS><550WB>'"$WB550"'<\/550WB><550WD>'"$WD550"'<\/550WD><550T>'"$TT550"'<\/550T><550D>'"$TD550"'<\/550D>' $xmlOut
	sed -i '/\/dewpoint_c/a <500WS>'"$WS500"'<\/500WS><500WB>'"$WB500"'<\/500WB><500WD>'"$WD500"'<\/500WD><500T>'"$TT500"'<\/500T><500D>'"$TD500"'<\/500D>' $xmlOut
	sed -i '/\/dewpoint_c/a <450WS>'"$WS450"'<\/450WS><450WB>'"$WB450"'<\/450WB><450WD>'"$WD450"'<\/450WD><450T>'"$TT450"'<\/450T><450D>'"$TD450"'<\/450D>' $xmlOut
	sed -i '/\/dewpoint_c/a <400WS>'"$WS400"'<\/400WS><400WB>'"$WB400"'<\/400WB><400WD>'"$WD400"'<\/400WD><400T>'"$TT400"'<\/400T><400D>'"$TD400"'<\/400D>' $xmlOut
	sed -i '/\/dewpoint_c/a <350WS>'"$WS350"'<\/350WS><350WB>'"$WB350"'<\/350WB><350WD>'"$WD350"'<\/350WD><350T>'"$TT350"'<\/350T><350D>'"$TD350"'<\/350D>' $xmlOut
	sed -i '/\/dewpoint_c/a <300WS>'"$WS300"'<\/300WS><300WB>'"$WB300"'<\/300WB><300WD>'"$WD300"'<\/300WD><300T>'"$TT300"'<\/300T><300D>'"$TD300"'<\/300D>' $xmlOut
	sed -i '/\/dewpoint_c/a <250WS>'"$WS250"'<\/250WS><250WD>'"$WD250"'<\/250WD><250T>'"$TT250"'<\/250T>' $xmlOut
	sed -i '/\/dewpoint_c/a <200WS>'"$WS200"'<\/200WS><200WD>'"$WD200"'<\/200WD><200T>'"$TT200"'<\/200T>' $xmlOut
	sed -i '/\/dewpoint_c/a <150WS>'"$WS150"'<\/150WS><150WD>'"$WD150"'<\/150WD><150T>'"$TT150"'<\/150T>' $xmlOut
	sed -i '/\/dewpoint_c/a <100WS>'"$WS100"'<\/100WS><100WD>'"$WD100"'<\/100WD><100T>'"$TT100"'<\/100T>' $xmlOut
	mysql Core << EOF
	load xml local infile '$xmlOut'
	into table XML_WxObsK$Station
	rows identified by '<current_observation>';
	update XML_WxObsK$Station set dewpoint_f=temp_f where dewpoint_f IS NULL;
EOF
	rm $xmlOut
	rm $Sounding
done
