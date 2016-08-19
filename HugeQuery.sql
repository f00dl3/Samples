SELECT 
	ojc.ObsID, ojc.observation_time, ojc.station_id,
	(CASE WHEN ojc.TimeOverride IS NOT NULL THEN ojc.TimeOverride ELSE ojc.GetTime END) as ForcedTime,
	ojc.weather, ojc.temp_f, ojc.dewpoint_f, ojc.relative_humidity,
	ojc.wind_dir, ojc.wind_degrees, ojc.wind_mph, ojc.wind_gust_mph,
	ojc.pressure_mb, ojc.visibility_mi, 
	emp.weather as emp_weather, emp.temp_f as emp_temp_f, emp.dewpoint_f as emp_dewpoint_f,
	fnb.weather as fnb_weather, fnb.temp_f as fnb_temp_f, fnb.dewpoint_f as fnb_dewpoint_f,
	mci.weather as mci_weather, mci.temp_f as mci_temp_f, mci.dewpoint_f as mci_dewpoint_f,
	stj.weather as stj_weather, stj.temp_f as stj_temp_f, stj.dewpoint_f as stj_dewpoint_f,
	szl.weather as szl_weather, szl.temp_f as szl_temp_f, szl.dewpoint_f as szl_dewpoint_f,
	top.weather as top_weather, top.temp_f as top_temp_f, top.dewpoint_f as top_dewpoint_f,
	ojc.CAPE, ojc.CIN, ojc.LI, ojc.EHI, ojc.CAPS, ojc.SFCWB, ojc.SLCL, ojc.FZLV, ojc.WZLV,
	ojc.LAPSE, ojc.KIND, ojc.EIND, ojc.MMR, ojc.PWAT, ojc.BRN, ojc.BSHR, ojc.MUVV,
	ojc.950T, emp.950T as emp_950T, fnb.950T as fnb_950T, mci.950T as mci_950T, stj.950T as stj_950T, szl.950T as szl_950T, top.950T as top_950T,
	ojc.950D, emp.950D as emp_950D, fnb.950D as fnb_950D, mci.950D as mci_950D, stj.950D as stj_950D, szl.950D as szl_950D, top.950D as top_950D,
	ojc.950WB, emp.950WB as emp_950WB, fnb.950WB as fnb_950WB, mci.950WB as mci_950WB, stj.950WB as stj_950WB, szl.950WB as szl_950WB, top.950WB as top_950WB,
	ojc.950WS, emp.950WS as emp_950WS, fnb.950WS as fnb_950WS, mci.950WS as mci_950WS, stj.950WS as stj_950WS, szl.950WS as szl_950WS, top.950WS as top_950WS,
	ojc.950WD, emp.950WD as emp_950WD, fnb.950WD as fnb_950WD, mci.950WD as mci_950WD, stj.950WD as stj_950WD, szl.950WD as szl_950WD, top.950WD as top_950WD,
	ojc.900T, emp.900T as emp_900T, fnb.900T as fnb_900T, mci.900T as mci_900T, stj.900T as stj_900T, szl.900T as szl_900T, top.900T as top_900T,
	ojc.900D, emp.900D as emp_900D, fnb.900D as fnb_900D, mci.900D as mci_900D, stj.900D as stj_900D, szl.900D as szl_900D, top.900D as top_900D,
	ojc.900WB, emp.900WB as emp_900WB, fnb.900WB as fnb_900WB, mci.900WB as mci_900WB, stj.900WB as stj_900WB, szl.900WB as szl_900WB, top.900WB as top_900WB,
	ojc.900WS, emp.900WS as emp_900WS, fnb.900WS as fnb_900WS, mci.900WS as mci_900WS, stj.900WS as stj_900WS, szl.900WS as szl_900WS, top.900WS as top_900WS,
	ojc.900WD, emp.900WD as emp_900WD, fnb.900WD as fnb_900WD, mci.900WD as mci_900WD, stj.900WD as stj_900WD, szl.900WD as szl_900WD, top.900WD as top_900WD,
	ojc.850T, emp.850T as emp_850T, fnb.850T as fnb_850T, mci.850T as mci_850T, stj.850T as stj_850T, szl.850T as szl_850T, top.850T as top_850T,
	ojc.850D, emp.850D as emp_850D, fnb.850D as fnb_850D, mci.850D as mci_850D, stj.850D as stj_850D, szl.850D as szl_850D, top.850D as top_850D,
	ojc.850WB, emp.850WB as emp_850WB, fnb.850WB as fnb_850WB, mci.850WB as mci_850WB, stj.850WB as stj_850WB, szl.850WB as szl_850WB, top.850WB as top_850WB,
	ojc.850WS, emp.850WS as emp_850WS, fnb.850WS as fnb_850WS, mci.850WS as mci_850WS, stj.850WS as stj_850WS, szl.850WS as szl_850WS, top.850WS as top_850WS,
	ojc.850WD, emp.850WD as emp_850WD, fnb.850WD as fnb_850WD, mci.850WD as mci_850WD, stj.850WD as stj_850WD, szl.850WD as szl_850WD, top.850WD as top_850WD,
	ojc.800T, emp.800T as emp_800T, fnb.800T as fnb_800T, mci.800T as mci_800T, stj.800T as stj_800T, szl.800T as szl_800T, top.800T as top_800T,
	ojc.800D, emp.800D as emp_800D, fnb.800D as fnb_800D, mci.800D as mci_800D, stj.800D as stj_800D, szl.800D as szl_800D, top.800D as top_800D,
	ojc.800WB, emp.800WB as emp_800WB, fnb.800WB as fnb_800WB, mci.800WB as mci_800WB, stj.800WB as stj_800WB, szl.800WB as szl_800WB, top.800WB as top_800WB,
	ojc.800WS, emp.800WS as emp_800WS, fnb.800WS as fnb_800WS, mci.800WS as mci_800WS, stj.800WS as stj_800WS, szl.800WS as szl_800WS, top.800WS as top_800WS,
	ojc.800WD, emp.800WD as emp_800WD, fnb.800WD as fnb_800WD, mci.800WD as mci_800WD, stj.800WD as stj_800WD, szl.800WD as szl_800WD, top.800WD as top_800WD,
	ojc.750T, emp.750T as emp_750T, fnb.750T as fnb_750T, mci.750T as mci_750T, stj.750T as stj_750T, szl.750T as szl_750T, top.750T as top_750T,
	ojc.750D, emp.750D as emp_750D, fnb.750D as fnb_750D, mci.750D as mci_750D, stj.750D as stj_750D, szl.750D as szl_750D, top.750D as top_750D,
	ojc.750WB, emp.750WB as emp_750WB, fnb.750WB as fnb_750WB, mci.750WB as mci_750WB, stj.750WB as stj_750WB, szl.750WB as szl_750WB, top.750WB as top_750WB,
	ojc.750WS, emp.750WS as emp_750WS, fnb.750WS as fnb_750WS, mci.750WS as mci_750WS, stj.750WS as stj_750WS, szl.750WS as szl_750WS, top.750WS as top_750WS,
	ojc.750WD, emp.750WD as emp_750WD, fnb.750WD as fnb_750WD, mci.750WD as mci_750WD, stj.750WD as stj_750WD, szl.750WD as szl_750WD, top.750WD as top_750WD,
	ojc.700T, emp.700T as emp_700T, fnb.700T as fnb_700T, mci.700T as mci_700T, stj.700T as stj_700T, szl.700T as szl_700T, top.700T as top_700T,
	ojc.700D, emp.700D as emp_700D, fnb.700D as fnb_700D, mci.700D as mci_700D, stj.700D as stj_700D, szl.700D as szl_700D, top.700D as top_700D,
	ojc.700WB, emp.700WB as emp_700WB, fnb.700WB as fnb_700WB, mci.700WB as mci_700WB, stj.700WB as stj_700WB, szl.700WB as szl_700WB, top.700WB as top_700WB,
	ojc.700WS, emp.700WS as emp_700WS, fnb.700WS as fnb_700WS, mci.700WS as mci_700WS, stj.700WS as stj_700WS, szl.700WS as szl_700WS, top.700WS as top_700WS,
	ojc.700WD, emp.700WD as emp_700WD, fnb.700WD as fnb_700WD, mci.700WD as mci_700WD, stj.700WD as stj_700WD, szl.700WD as szl_700WD, top.700WD as top_700WD,
	ojc.650T, emp.650T as emp_650T, fnb.650T as fnb_650T, mci.650T as mci_650T, stj.650T as stj_650T, szl.650T as szl_650T, top.650T as top_650T,
	ojc.650D, emp.650D as emp_650D, fnb.650D as fnb_650D, mci.650D as mci_650D, stj.650D as stj_650D, szl.650D as szl_650D, top.650D as top_650D,
	ojc.650WB, emp.650WB as emp_650WB, fnb.650WB as fnb_650WB, mci.650WB as mci_650WB, stj.650WB as stj_650WB, szl.650WB as szl_650WB, top.650WB as top_650WB,
	ojc.650WS, emp.650WS as emp_650WS, fnb.650WS as fnb_650WS, mci.650WS as mci_650WS, stj.650WS as stj_650WS, szl.650WS as szl_650WS, top.650WS as top_650WS,
	ojc.650WD, emp.650WD as emp_650WD, fnb.650WD as fnb_650WD, mci.650WD as mci_650WD, stj.650WD as stj_650WD, szl.650WD as szl_650WD, top.650WD as top_650WD,
	ojc.600T, emp.600T as emp_600T, fnb.600T as fnb_600T, mci.600T as mci_600T, stj.600T as stj_600T, szl.600T as szl_600T, top.600T as top_600T,
	ojc.600D, emp.600D as emp_600D, fnb.600D as fnb_600D, mci.600D as mci_600D, stj.600D as stj_600D, szl.600D as szl_600D, top.600D as top_600D,
	ojc.600WB, emp.600WB as emp_600WB, fnb.600WB as fnb_600WB, mci.600WB as mci_600WB, stj.600WB as stj_600WB, szl.600WB as szl_600WB, top.600WB as top_600WB,
	ojc.600WS, emp.600WS as emp_600WS, fnb.600WS as fnb_600WS, mci.600WS as mci_600WS, stj.600WS as stj_600WS, szl.600WS as szl_600WS, top.600WS as top_600WS,
	ojc.600WD, emp.600WD as emp_600WD, fnb.600WD as fnb_600WD, mci.600WD as mci_600WD, stj.600WD as stj_600WD, szl.600WD as szl_600WD, top.600WD as top_600WD,
	ojc.550T, emp.550T as emp_550T, fnb.550T as fnb_550T, mci.550T as mci_550T, stj.550T as stj_550T, szl.550T as szl_550T, top.550T as top_550T,
	ojc.550D, emp.550D as emp_550D, fnb.550D as fnb_550D, mci.550D as mci_550D, stj.550D as stj_550D, szl.550D as szl_550D, top.550D as top_550D,
	ojc.550WB, emp.550WB as emp_550WB, fnb.550WB as fnb_550WB, mci.550WB as mci_550WB, stj.550WB as stj_550WB, szl.550WB as szl_550WB, top.550WB as top_550WB,
	ojc.550WS, emp.550WS as emp_550WS, fnb.550WS as fnb_550WS, mci.550WS as mci_550WS, stj.550WS as stj_550WS, szl.550WS as szl_550WS, top.550WS as top_550WS,
	ojc.550WD, emp.550WD as emp_550WD, fnb.550WD as fnb_550WD, mci.550WD as mci_550WD, stj.550WD as stj_550WD, szl.550WD as szl_550WD, top.550WD as top_550WD,
	ojc.500T, emp.500T as emp_500T, fnb.500T as fnb_500T, mci.500T as mci_500T, stj.500T as stj_500T, szl.500T as szl_500T, top.500T as top_500T,
	ojc.500D, emp.500D as emp_500D, fnb.500D as fnb_500D, mci.500D as mci_500D, stj.500D as stj_500D, szl.500D as szl_500D, top.500D as top_500D,
	ojc.500WB, emp.500WB as emp_500WB, fnb.500WB as fnb_500WB, mci.500WB as mci_500WB, stj.500WB as stj_500WB, szl.500WB as szl_500WB, top.500WB as top_500WB,
	ojc.500WS, emp.500WS as emp_500WS, fnb.500WS as fnb_500WS, mci.500WS as mci_500WS, stj.500WS as stj_500WS, szl.500WS as szl_500WS, top.500WS as top_500WS,
	ojc.500WD, emp.500WD as emp_500WD, fnb.500WD as fnb_500WD, mci.500WD as mci_500WD, stj.500WD as stj_500WD, szl.500WD as szl_500WD, top.500WD as top_500WD,
	ojc.450T, emp.450T as emp_450T, fnb.450T as fnb_450T, mci.450T as mci_450T, stj.450T as stj_450T, szl.450T as szl_450T, top.450T as top_450T,
	ojc.450D, emp.450D as emp_450D, fnb.450D as fnb_450D, mci.450D as mci_450D, stj.450D as stj_450D, szl.450D as szl_450D, top.450D as top_450D,
	ojc.450WB, emp.450WB as emp_450WB, fnb.450WB as fnb_450WB, mci.450WB as mci_450WB, stj.450WB as stj_450WB, szl.450WB as szl_450WB, top.450WB as top_450WB,
	ojc.450WS, emp.450WS as emp_450WS, fnb.450WS as fnb_450WS, mci.450WS as mci_450WS, stj.450WS as stj_450WS, szl.450WS as szl_450WS, top.450WS as top_450WS,
	ojc.450WD, emp.450WD as emp_450WD, fnb.450WD as fnb_450WD, mci.450WD as mci_450WD, stj.450WD as stj_450WD, szl.450WD as szl_450WD, top.450WD as top_450WD,
	ojc.400T, emp.400T as emp_400T, fnb.400T as fnb_400T, mci.400T as mci_400T, stj.400T as stj_400T, szl.400T as szl_400T, top.400T as top_400T,
	ojc.400D, emp.400D as emp_400D, fnb.400D as fnb_400D, mci.400D as mci_400D, stj.400D as stj_400D, szl.400D as szl_400D, top.400D as top_400D,
	ojc.400WB, emp.400WB as emp_400WB, fnb.400WB as fnb_400WB, mci.400WB as mci_400WB, stj.400WB as stj_400WB, szl.400WB as szl_400WB, top.400WB as top_400WB,
	ojc.400WS, emp.400WS as emp_400WS, fnb.400WS as fnb_400WS, mci.400WS as mci_400WS, stj.400WS as stj_400WS, szl.400WS as szl_400WS, top.400WS as top_400WS,
	ojc.400WD, emp.400WD as emp_400WD, fnb.400WD as fnb_400WD, mci.400WD as mci_400WD, stj.400WD as stj_400WD, szl.400WD as szl_400WD, top.400WD as top_400WD,
	ojc.350T, emp.350T as emp_350T, fnb.350T as fnb_350T, mci.350T as mci_350T, stj.350T as stj_350T, szl.350T as szl_350T, top.350T as top_350T,
	ojc.350D, emp.350D as emp_350D, fnb.350D as fnb_350D, mci.350D as mci_350D, stj.350D as stj_350D, szl.350D as szl_350D, top.350D as top_350D,
	ojc.350WB, emp.350WB as emp_350WB, fnb.350WB as fnb_350WB, mci.350WB as mci_350WB, stj.350WB as stj_350WB, szl.350WB as szl_350WB, top.350WB as top_350WB,
	ojc.350WS, emp.350WS as emp_350WS, fnb.350WS as fnb_350WS, mci.350WS as mci_350WS, stj.350WS as stj_350WS, szl.350WS as szl_350WS, top.350WS as top_350WS,
	ojc.350WD, emp.350WD as emp_350WD, fnb.350WD as fnb_350WD, mci.350WD as mci_350WD, stj.350WD as stj_350WD, szl.350WD as szl_350WD, top.350WD as top_350WD,
	ojc.300T, emp.300T as emp_300T, fnb.300T as fnb_300T, mci.300T as mci_300T, stj.300T as stj_300T, szl.300T as szl_300T, top.300T as top_300T,
	ojc.300D, emp.300D as emp_300D, fnb.300D as fnb_300D, mci.300D as mci_300D, stj.300D as stj_300D, szl.300D as szl_300D, top.300D as top_300D,
	ojc.300WB, emp.300WB as emp_300WB, fnb.300WB as fnb_300WB, mci.300WB as mci_300WB, stj.300WB as stj_300WB, szl.300WB as szl_300WB, top.300WB as top_300WB,
	ojc.300WS, emp.300WS as emp_300WS, fnb.300WS as fnb_300WS, mci.300WS as mci_300WS, stj.300WS as stj_300WS, szl.300WS as szl_300WS, top.300WS as top_300WS,
	ojc.300WD, emp.300WD as emp_300WD, fnb.300WD as fnb_300WD, mci.300WD as mci_300WD, stj.300WD as stj_300WD, szl.300WD as szl_300WD, top.300WD as top_300WD,
	ojc.250T, emp.250T as emp_250T, fnb.250T as fnb_250T, mci.250T as mci_250T, stj.250T as stj_250T, szl.250T as szl_250T, top.250T as top_250T,
	ojc.250WS, emp.250WS as emp_250WS, fnb.250WS as fnb_250WS, mci.250WS as mci_250WS, stj.250WS as stj_250WS, szl.250WS as szl_250WS, top.250WS as top_250WS,
	ojc.250WD, emp.250WD as emp_250WD, fnb.250WD as fnb_250WD, mci.250WD as mci_250WD, stj.250WD as stj_250WD, szl.250WD as szl_250WD, top.250WD as top_250WD,
	ojc.200T, emp.200T as emp_200T, fnb.200T as fnb_200T, mci.200T as mci_200T, stj.200T as stj_200T, szl.200T as szl_200T, top.200T as top_200T,
	ojc.200WS, emp.200WS as emp_200WS, fnb.200WS as fnb_200WS, mci.200WS as mci_200WS, stj.200WS as stj_200WS, szl.200WS as szl_200WS, top.200WS as top_200WS,
	ojc.200WD, emp.200WD as emp_200WD, fnb.200WD as fnb_200WD, mci.200WD as mci_200WD, stj.200WD as stj_200WD, szl.200WD as szl_200WD, top.200WD as top_200WD,
	ojc.150T, emp.150T as emp_150T, fnb.150T as fnb_150T, mci.150T as mci_150T, stj.150T as stj_150T, szl.150T as szl_150T, top.150T as top_150T,
	ojc.150WS, emp.150WS as emp_150WS, fnb.150WS as fnb_150WS, mci.150WS as mci_150WS, stj.150WS as stj_150WS, szl.150WS as szl_150WS, top.150WS as top_150WS,
	ojc.150WD, emp.150WD as emp_150WD, fnb.150WD as fnb_150WD, mci.150WD as mci_150WD, stj.150WD as stj_150WD, szl.150WD as szl_150WD, top.150WD as top_150WD,
	ojc.100T, emp.100T as emp_100T, fnb.100T as fnb_100T, mci.100T as mci_100T, stj.100T as stj_100T, szl.100T as szl_100T, top.100T as top_100T,
	ojc.100WS, emp.100WS as emp_100WS, fnb.100WS as fnb_100WS, mci.100WS as mci_100WS, stj.100WS as stj_100WS, szl.100WS as szl_100WS, top.100WS as top_100WS,
	ojc.100WD, emp.100WD as emp_100WD, fnb.100WD as fnb_100WD, mci.100WD as mci_100WD, stj.100WD as stj_100WD, szl.100WD as szl_100WD, top.100WD as top_100WD
FROM XML_WxObs ojc
LEFT JOIN XML_WxObsKEMP fnb ON SUBSTRING(ojc.GetTime, 1, 13) = SUBSTRING(fnb.GetTime, 1, 13)
LEFT JOIN XML_WxObsKFNB emp ON SUBSTRING(ojc.GetTime, 1, 13) = SUBSTRING(emp.GetTime, 1, 13)
LEFT JOIN XML_WxObsKMCI mci ON SUBSTRING(ojc.GetTime, 1, 13) = SUBSTRING(mci.GetTime, 1, 13)
LEFT JOIN XML_WxObsKSTJ stj ON SUBSTRING(ojc.GetTime, 1, 13) = SUBSTRING(stj.GetTime, 1, 13)
LEFT JOIN XML_WxObsKSZL szl ON SUBSTRING(ojc.GetTime, 1, 13) = SUBSTRING(szl.GetTime, 1, 13)
LEFT JOIN XML_WxObsKTOP top ON SUBSTRING(ojc.GetTime, 1, 13) = SUBSTRING(top.GetTime, 1, 13)
WHERE ojc.GetTime BETWEEN '2016-08-17 20:00:00' AND '2016-08-18 20:00:00'
ORDER BY ForcedTime ASC,
LIMIT 24;
