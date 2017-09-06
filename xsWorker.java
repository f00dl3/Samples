/* XML Stations v6
Worker Process 
Conceived 2017-09-02
Updated 2017-09-06 */

package jASUtils;

import java.io.*;
import java.lang.Math;
import java.math.RoundingMode;
import java.sql.*;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.Scanner;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.xpath.*;
import org.w3c.dom.Document;
import org.xml.sax.SAXException;

import org.json.*;

import jASUtils.ShellUtils;

public class xsWorker {

	public static double windDirCalc(double tWUin, double tWVin) { return 57.29578*(Math.atan2(tWUin, tWVin))+180; }
	public static double windSpdCalc(double tWUin, double tWVin) { return Math.sqrt(tWUin*tWUin+tWVin*tWVin)*1.944; }
	public static double calcSLCL(double tTCin, double tRHin) { return (20+(tTCin/5))*(100-tRHin); }

	public static void main(String args[]) {

		final String stationType = args[0];
		final String region = args[1];
		final String xsTmp = "/dev/shm/xsTmp";
		final File xsTmpGrib2Obj = new File(xsTmp+"/grib2");
		final File jsonOutFile = new File(xsTmp+"/output_"+stationType+"_"+region+".json");
		final String wgrib2Path = "/home/astump/src/grib2/wgrib2";

		DecimalFormat df = new DecimalFormat("#.###");
		df.setRoundingMode(RoundingMode.CEILING);

		if(stationType.equals("Full")) {

			List<String> wxStations = new ArrayList<String>();
			List<String> wxStationPoints = new ArrayList<String>();

			String pointInputString = "";

			final File pointInputDump = new File(xsTmp+"/pointDump"+region+".txt");	
			final String getStationListSQL = "SELECT Station FROM WxObs.Stations WHERE Active=1 AND Region='"+region+"' AND Priority < 4 ORDER BY Priority, Station DESC;";
			final String getStationPointListSQL = "SELECT SUBSTRING(Point, 2, CHAR_LENGTH(Point)-2) as fixedPoint FROM WxObs.Stations WHERE Active=1 AND Region='"+region+"' AND Priority < 4 ORDER BY Priority, Station DESC;";
			final File hrrrSounding = new File(xsTmp+"/grib2/outSounding_HRRR_"+region+".csv");
			final File rapSounding = new File(xsTmp+"/grib2/outSounding_RAP_"+region+".csv");
			final String hrrrMatch = "TMP|RH|UGRD|VGRD|CAPE|CIN|4LFTX|HGT|PWAT|TMP|RH|HLCY";
			final String rapMatch = hrrrMatch;

			int gribSpot = 0;
			int iterk = 0;

			try (
				Connection conn = MyDBConnector.getMyConnection(); Statement stmt = conn.createStatement();
				ResultSet resultSetStations = stmt.executeQuery(getStationListSQL);
			) { while (resultSetStations.next()) { wxStations.add(resultSetStations.getString("Station")); } }
			catch (Exception e) { e.printStackTrace(); }

			try (
				Connection conn = MyDBConnector.getMyConnection(); Statement stmt = conn.createStatement();
				ResultSet resultSetStationPoints = stmt.executeQuery(getStationPointListSQL);
			) { while (resultSetStationPoints.next()) { wxStationPoints.add(resultSetStationPoints.getString("fixedPoint")); } }
			catch (Exception e) { e.printStackTrace(); }

			for (String thisPoint : wxStationPoints) {
				String thisGeo = thisPoint.replace(",", " ");
				pointInputString = pointInputString+"-lon "+thisGeo+" ";
			}

			try { ShellUtils.varToFile(pointInputString, pointInputDump, false); } catch (FileNotFoundException fnf) { fnf.printStackTrace(); }

			System.out.println(" --> Parsing GRIB2 data HRRR for region "+region);
			try { ShellUtils.runProcessOutFile("\""+wgrib2Path+"/wgrib2\" "+xsTmp+"/grib2/HRRR "+pointInputString+" -match \":("+hrrrMatch+"):\"", hrrrSounding, false); } catch (FileNotFoundException fnf) { fnf.printStackTrace(); }

			System.out.println(" --> Parsing GRIB2 data RAP for region "+region);
			try { ShellUtils.runProcessOutFile("\""+wgrib2Path+"/wgrib2\" "+xsTmp+"/grib2/RAP "+pointInputString+" -match \":("+rapMatch+"):\"", rapSounding, false); } catch (FileNotFoundException fnf) { fnf.printStackTrace(); }
			
			ShellUtils.sedFileReplace(hrrrSounding.getPath(), ":lon", ",lon");
			ShellUtils.sedFileReplace(rapSounding.getPath(), ":lon", ",lon");

			for (String thisStation : wxStations) {

				gribSpot = (gribSpot + 3);

				File xmlOut = new File(xsTmp+"/"+thisStation+".xml");
				String thisGeo = wxStationPoints.get(iterk);

				System.out.println(" --> Processing "+thisStation+" - GRIB2 spot is "+gribSpot+", coords "+thisGeo);

				JSONObject jStationObj = new JSONObject();
				JSONObject jStationData = new JSONObject();
				jStationObj.put(thisStation, jStationData);

				int thisNullCounter = 0;
				int thisNullCounterModel = 0;
				String tDewpointF = null;
				String tPressureMb = null;
				String tRelativeHumidity = null;
				String tTempF = null;
				String tTimeString = null;
				String tWeather = null;
				String tWindDegrees = null;
				String tWindDirection = null;
				String tWindSpeed = null;
				String tWindGust = null;
				String tVisibility = null;

				Scanner xmlScanner = null; try {		
					xmlScanner = new Scanner(xmlOut);
					while(xmlScanner.hasNext()) {
						String line = xmlScanner.nextLine();
						if(line.contains("<dewpoint_f>")) { Pattern p = Pattern.compile("<dewpoint_f>(.*)</dewpoint_f>"); Matcher m = p.matcher(line); if (m.find()) { tDewpointF = m.group(1); } }
						if(line.contains("<observation_time>")) { Pattern p = Pattern.compile("<observation_time>(.*)</observation_time>"); Matcher m = p.matcher(line); if (m.find()) { tTimeString = m.group(1); } }
						if(line.contains("<pressure_mb>")) { Pattern p = Pattern.compile("<pressure_mb>(.*)</pressure_mb>"); Matcher m = p.matcher(line); if (m.find()) { tPressureMb = m.group(1); } }
						if(line.contains("<relative_humidity>")) { Pattern p = Pattern.compile("<relative_humidity>(.*)</relative_humidity>"); Matcher m = p.matcher(line); if (m.find()) { tRelativeHumidity = m.group(1); } }
						if(line.contains("<temp_f>")) { Pattern p = Pattern.compile("<temp_f>(.*)</temp_f>"); Matcher m = p.matcher(line); if (m.find()) { tTempF = m.group(1); } }
						if(line.contains("<weather>")) { Pattern p = Pattern.compile("<weather>(.*)</weather>"); Matcher m = p.matcher(line); if (m.find()) { tWeather = m.group(1); } }
						if(line.contains("<wind_degrees>")) { Pattern p = Pattern.compile("<wind_degrees>(.*)</wind_degrees>"); Matcher m = p.matcher(line); if (m.find()) { tWindDegrees = m.group(1); } }
						if(line.contains("<wind_dir>")) { Pattern p = Pattern.compile("<wind_dir>(.*)</wind_dir>"); Matcher m = p.matcher(line); if (m.find()) { tWindDirection = m.group(1); } }
						if(line.contains("<wind_mph>")) { Pattern p = Pattern.compile("<wind_mph>(.*)</wind_mph>"); Matcher m = p.matcher(line); if (m.find()) { tWindSpeed = m.group(1); } }
						if(line.contains("<wind_gust_mph>")) { Pattern p = Pattern.compile("<wind_gust_mph>(.*)</wind_gust_mph>"); Matcher m = p.matcher(line); if (m.find()) { tWindGust = m.group(1); } }
						if(line.contains("<visibility_mi>")) { Pattern p = Pattern.compile("<visibility_mi>(.*)</visibility_mi>"); Matcher m = p.matcher(line); if (m.find()) { tVisibility = m.group(1); } }
					}
				}
				catch (FileNotFoundException fnf) { fnf.printStackTrace(); }
			
				if (tTempF != null) { jStationData.put("Temperature", tTempF); } else { thisNullCounter++; }
				if (tDewpointF != null) { jStationData.put("Dewpoint", tDewpointF); } else { thisNullCounter++; }
				if (tRelativeHumidity != null) { jStationData.put("RelativeHumidity", tRelativeHumidity); } else { thisNullCounter++; }
				if (tPressureMb != null) { jStationData.put("Pressure", tPressureMb); } else { thisNullCounter++; }
				if (tTimeString != null) { jStationData.put("TimeString", tTimeString); } else { thisNullCounter++; }
				if (tVisibility != null) { jStationData.put("Visibility", tVisibility); } else { thisNullCounter++; }
				if (tWeather != null) { jStationData.put("Weather", tWeather); } else { thisNullCounter++; }
				if (tWindDegrees != null) { jStationData.put("WindDegrees", tWindDegrees); } else { thisNullCounter++; }
				if (tWindDirection != null) { jStationData.put("WindDirection", tWindDirection); } else { thisNullCounter++; }
				if (tWindGust != null) { jStationData.put("WindGust", tWindGust); } else { thisNullCounter++; }
				if (tWindSpeed != null) { jStationData.put("WindSpeed", tWindSpeed); } else { thisNullCounter++; }

				double tRH100 = 0.001; double tRH125 = 0.001; double tRH150 = 0.001; double tRH175 = 0.001; 
				double tRH200 = 0.001; double tRH225 = 0.001; double tRH250 = 0.001; double tRH275 = 0.001; 
				double tRH300 = 0.001; double tRH325 = 0.001; double tRH350 = 0.001; double tRH375 = 0.001; 
				double tRH400 = 0.001; double tRH425 = 0.001; double tRH450 = 0.001; double tRH475 = 0.001; 
				double tRH500 = 0.001; double tRH525 = 0.001; double tRH550 = 0.001; double tRH575 = 0.001; 
				double tRH600 = 0.001; double tRH625 = 0.001; double tRH650 = 0.001; double tRH675 = 0.001; 
				double tRH700 = 0.001; double tRH725 = 0.001; double tRH750 = 0.001; double tRH775 = 0.001; 
				double tRH800 = 0.001; double tRH825 = 0.001; double tRH850 = 0.001; double tRH875 = 0.001; 
				double tRH900 = 0.001; double tRH925 = 0.001; double tRH950 = 0.001; double tRH975 = 0.001; 
				double tRH1000 = 0.001; double tRH0 = 0.001;

				double tTC100 = 0.001; double tTC125 = 0.001; double tTC150 = 0.001; double tTC175 = 0.001; 
				double tTC200 = 0.001; double tTC225 = 0.001; double tTC250 = 0.001; double tTC275 = 0.001; 
				double tTC300 = 0.001; double tTC325 = 0.001; double tTC350 = 0.001; double tTC375 = 0.001; 
				double tTC400 = 0.001; double tTC425 = 0.001; double tTC450 = 0.001; double tTC475 = 0.001; 
				double tTC500 = 0.001; double tTC525 = 0.001; double tTC550 = 0.001; double tTC575 = 0.001; 
				double tTC600 = 0.001; double tTC625 = 0.001; double tTC650 = 0.001; double tTC675 = 0.001; 
				double tTC700 = 0.001; double tTC725 = 0.001; double tTC750 = 0.001; double tTC775 = 0.001; 
				double tTC800 = 0.001; double tTC825 = 0.001; double tTC850 = 0.001; double tTC875 = 0.001; 
				double tTC900 = 0.001; double tTC925 = 0.001; double tTC950 = 0.001; double tTC975 = 0.001; 
				double tTC1000 = 0.001; double tTC0 = 0.001;

				double tWU100 = 0.001; double tWU125 = 0.001; double tWU150 = 0.001; double tWU175 = 0.001; 
				double tWU200 = 0.001; double tWU225 = 0.001; double tWU250 = 0.001; double tWU275 = 0.001; 
				double tWU300 = 0.001; double tWU325 = 0.001; double tWU350 = 0.001; double tWU375 = 0.001; 
				double tWU400 = 0.001; double tWU425 = 0.001; double tWU450 = 0.001; double tWU475 = 0.001; 
				double tWU500 = 0.001; double tWU525 = 0.001; double tWU550 = 0.001; double tWU575 = 0.001; 
				double tWU600 = 0.001; double tWU625 = 0.001; double tWU650 = 0.001; double tWU675 = 0.001; 
				double tWU700 = 0.001; double tWU725 = 0.001; double tWU750 = 0.001; double tWU775 = 0.001; 
				double tWU800 = 0.001; double tWU825 = 0.001; double tWU850 = 0.001; double tWU875 = 0.001; 
				double tWU900 = 0.001; double tWU925 = 0.001; double tWU950 = 0.001; double tWU975 = 0.001; 
				double tWU1000 = 0.001; double tWU0 = 0.001;

				double tWV100 = 0.001; double tWV125 = 0.001; double tWV150 = 0.001; double tWV175 = 0.001; 
				double tWV200 = 0.001; double tWV225 = 0.001; double tWV250 = 0.001; double tWV275 = 0.001; 
				double tWV300 = 0.001; double tWV325 = 0.001; double tWV350 = 0.001; double tWV375 = 0.001; 
				double tWV400 = 0.001; double tWV425 = 0.001; double tWV450 = 0.001; double tWV475 = 0.001; 
				double tWV500 = 0.001; double tWV525 = 0.001; double tWV550 = 0.001; double tWV575 = 0.001; 
				double tWV600 = 0.001; double tWV625 = 0.001; double tWV650 = 0.001; double tWV675 = 0.001; 
				double tWV700 = 0.001; double tWV725 = 0.001; double tWV750 = 0.001; double tWV775 = 0.001; 
				double tWV800 = 0.001; double tWV825 = 0.001; double tWV850 = 0.001; double tWV875 = 0.001; 
				double tWV900 = 0.001; double tWV925 = 0.001; double tWV950 = 0.001; double tWV975 = 0.001; 
				double tWV1000 = 0.001; double tWV0 = 0.001;

				double tCAPE = 0.001; double tCIN = 0.001; double tLI = 0.001; double tPWAT = 0.001; double tHGT500 = 0.001;

				final int iSx = 31; /* Relative Humidity Offset */
				final int iSs = 14;

				Scanner hrrrScanner = null; try {		
					hrrrScanner = new Scanner(hrrrSounding);
					while(hrrrScanner.hasNext()) {

						String line = hrrrScanner.nextLine();

						if(line.startsWith(((iSx+0)+(iSs*0))+":")) { String[] lineTmp = line.split(","); tRH100 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+0)+(iSs*1))+":")) { String[] lineTmp = line.split(","); tRH125 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+0)+(iSs*2))+":")) { String[] lineTmp = line.split(","); tRH150 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+0)+(iSs*3))+":")) { String[] lineTmp = line.split(","); tRH175 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+0)+(iSs*4))+":")) { String[] lineTmp = line.split(","); tRH200 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+0)+(iSs*5))+":")) { String[] lineTmp = line.split(","); tRH225 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+0)+(iSs*6))+":")) { String[] lineTmp = line.split(","); tRH250 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+0)+(iSs*7))+":")) { String[] lineTmp = line.split(","); tRH275 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+0)+(iSs*8))+":")) { String[] lineTmp = line.split(","); tRH300 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+0)+(iSs*9))+":")) { String[] lineTmp = line.split(","); tRH325 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+0)+(iSs*10))+":")) { String[] lineTmp = line.split(","); tRH350 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+0)+(iSs*11))+":")) { String[] lineTmp = line.split(","); tRH375 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+0)+(iSs*12))+":")) { String[] lineTmp = line.split(","); tRH400 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+0)+(iSs*13))+":")) { String[] lineTmp = line.split(","); tRH425 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+0)+(iSs*14))+":")) { String[] lineTmp = line.split(","); tRH450 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+0)+(iSs*15))+":")) { String[] lineTmp = line.split(","); tRH475 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+0)+(iSs*16))+":")) { String[] lineTmp = line.split(","); tRH500 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+0)+(iSs*17))+":")) { String[] lineTmp = line.split(","); tRH525 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+0)+(iSs*18))+":")) { String[] lineTmp = line.split(","); tRH550 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+0)+(iSs*19))+":")) { String[] lineTmp = line.split(","); tRH575 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+0)+(iSs*20))+":")) { String[] lineTmp = line.split(","); tRH600 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+0)+(iSs*21))+":")) { String[] lineTmp = line.split(","); tRH625 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+0)+(iSs*22))+":")) { String[] lineTmp = line.split(","); tRH650 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+0)+(iSs*23))+":")) { String[] lineTmp = line.split(","); tRH675 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+0)+(iSs*24))+":")) { String[] lineTmp = line.split(","); tRH700 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+0)+(iSs*25))+":")) { String[] lineTmp = line.split(","); tRH725 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+0)+(iSs*26))+":")) { String[] lineTmp = line.split(","); tRH750 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+0)+(iSs*27))+":")) { String[] lineTmp = line.split(","); tRH775 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+0)+(iSs*28))+":")) { String[] lineTmp = line.split(","); tRH800 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+0)+(iSs*29))+":")) { String[] lineTmp = line.split(","); tRH825 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+0)+(iSs*30))+":")) { String[] lineTmp = line.split(","); tRH850 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+0)+(iSs*31))+":")) { String[] lineTmp = line.split(","); tRH875 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+0)+(iSs*32))+":")) { String[] lineTmp = line.split(","); tRH900 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+0)+(iSs*33))+":")) { String[] lineTmp = line.split(","); tRH925 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+0)+(iSs*34))+":")) { String[] lineTmp = line.split(","); tRH950 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+0)+(iSs*35))+":")) { String[] lineTmp = line.split(","); tRH975 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith("533:")) { String[] lineTmp = line.split(","); tRH1000 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith("605:")) { String[] lineTmp = line.split(","); tRH0 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }

						if(line.startsWith(((iSx-1)+(iSs*0))+":")) { String[] lineTmp = line.split(","); tTC100 = Double.parseDouble(lineTmp[gribSpot].replace("val=", ""))-273.15; }
						if(line.startsWith(((iSx-1)+(iSs*1))+":")) { String[] lineTmp = line.split(","); tTC125 = Double.parseDouble(lineTmp[gribSpot].replace("val=", ""))-273.15; }
						if(line.startsWith(((iSx-1)+(iSs*2))+":")) { String[] lineTmp = line.split(","); tTC150 = Double.parseDouble(lineTmp[gribSpot].replace("val=", ""))-273.15; }
						if(line.startsWith(((iSx-1)+(iSs*3))+":")) { String[] lineTmp = line.split(","); tTC175 = Double.parseDouble(lineTmp[gribSpot].replace("val=", ""))-273.15; }
						if(line.startsWith(((iSx-1)+(iSs*4))+":")) { String[] lineTmp = line.split(","); tTC200 = Double.parseDouble(lineTmp[gribSpot].replace("val=", ""))-273.15; }
						if(line.startsWith(((iSx-1)+(iSs*5))+":")) { String[] lineTmp = line.split(","); tTC225 = Double.parseDouble(lineTmp[gribSpot].replace("val=", ""))-273.15; }
						if(line.startsWith(((iSx-1)+(iSs*6))+":")) { String[] lineTmp = line.split(","); tTC250 = Double.parseDouble(lineTmp[gribSpot].replace("val=", ""))-273.15; }
						if(line.startsWith(((iSx-1)+(iSs*7))+":")) { String[] lineTmp = line.split(","); tTC275 = Double.parseDouble(lineTmp[gribSpot].replace("val=", ""))-273.15; }
						if(line.startsWith(((iSx-1)+(iSs*8))+":")) { String[] lineTmp = line.split(","); tTC300 = Double.parseDouble(lineTmp[gribSpot].replace("val=", ""))-273.15; }
						if(line.startsWith(((iSx-1)+(iSs*9))+":")) { String[] lineTmp = line.split(","); tTC325 = Double.parseDouble(lineTmp[gribSpot].replace("val=", ""))-273.15; }
						if(line.startsWith(((iSx-1)+(iSs*10))+":")) { String[] lineTmp = line.split(","); tTC350 = Double.parseDouble(lineTmp[gribSpot].replace("val=", ""))-273.15; }
						if(line.startsWith(((iSx-1)+(iSs*11))+":")) { String[] lineTmp = line.split(","); tTC375 = Double.parseDouble(lineTmp[gribSpot].replace("val=", ""))-273.15; }
						if(line.startsWith(((iSx-1)+(iSs*12))+":")) { String[] lineTmp = line.split(","); tTC400 = Double.parseDouble(lineTmp[gribSpot].replace("val=", ""))-273.15; }
						if(line.startsWith(((iSx-1)+(iSs*13))+":")) { String[] lineTmp = line.split(","); tTC425 = Double.parseDouble(lineTmp[gribSpot].replace("val=", ""))-273.15; }
						if(line.startsWith(((iSx-1)+(iSs*14))+":")) { String[] lineTmp = line.split(","); tTC450 = Double.parseDouble(lineTmp[gribSpot].replace("val=", ""))-273.15; }
						if(line.startsWith(((iSx-1)+(iSs*15))+":")) { String[] lineTmp = line.split(","); tTC475 = Double.parseDouble(lineTmp[gribSpot].replace("val=", ""))-273.15; }
						if(line.startsWith(((iSx-1)+(iSs*16))+":")) { String[] lineTmp = line.split(","); tTC500 = Double.parseDouble(lineTmp[gribSpot].replace("val=", ""))-273.15; }
						if(line.startsWith(((iSx-1)+(iSs*17))+":")) { String[] lineTmp = line.split(","); tTC525 = Double.parseDouble(lineTmp[gribSpot].replace("val=", ""))-273.15; }
						if(line.startsWith(((iSx-1)+(iSs*18))+":")) { String[] lineTmp = line.split(","); tTC550 = Double.parseDouble(lineTmp[gribSpot].replace("val=", ""))-273.15; }
						if(line.startsWith(((iSx-1)+(iSs*19))+":")) { String[] lineTmp = line.split(","); tTC575 = Double.parseDouble(lineTmp[gribSpot].replace("val=", ""))-273.15; }
						if(line.startsWith(((iSx-1)+(iSs*20))+":")) { String[] lineTmp = line.split(","); tTC600 = Double.parseDouble(lineTmp[gribSpot].replace("val=", ""))-273.15; }
						if(line.startsWith(((iSx-1)+(iSs*21))+":")) { String[] lineTmp = line.split(","); tTC625 = Double.parseDouble(lineTmp[gribSpot].replace("val=", ""))-273.15; }
						if(line.startsWith(((iSx-1)+(iSs*22))+":")) { String[] lineTmp = line.split(","); tTC650 = Double.parseDouble(lineTmp[gribSpot].replace("val=", ""))-273.15; }
						if(line.startsWith(((iSx-1)+(iSs*23))+":")) { String[] lineTmp = line.split(","); tTC675 = Double.parseDouble(lineTmp[gribSpot].replace("val=", ""))-273.15; }
						if(line.startsWith(((iSx-1)+(iSs*24))+":")) { String[] lineTmp = line.split(","); tTC700 = Double.parseDouble(lineTmp[gribSpot].replace("val=", ""))-273.15; }
						if(line.startsWith(((iSx-1)+(iSs*25))+":")) { String[] lineTmp = line.split(","); tTC725 = Double.parseDouble(lineTmp[gribSpot].replace("val=", ""))-273.15; }
						if(line.startsWith(((iSx-1)+(iSs*26))+":")) { String[] lineTmp = line.split(","); tTC750 = Double.parseDouble(lineTmp[gribSpot].replace("val=", ""))-273.15; }
						if(line.startsWith(((iSx-1)+(iSs*27))+":")) { String[] lineTmp = line.split(","); tTC775 = Double.parseDouble(lineTmp[gribSpot].replace("val=", ""))-273.15; }
						if(line.startsWith(((iSx-1)+(iSs*28))+":")) { String[] lineTmp = line.split(","); tTC800 = Double.parseDouble(lineTmp[gribSpot].replace("val=", ""))-273.15; }
						if(line.startsWith(((iSx-1)+(iSs*29))+":")) { String[] lineTmp = line.split(","); tTC825 = Double.parseDouble(lineTmp[gribSpot].replace("val=", ""))-273.15; }
						if(line.startsWith(((iSx-1)+(iSs*30))+":")) { String[] lineTmp = line.split(","); tTC850 = Double.parseDouble(lineTmp[gribSpot].replace("val=", ""))-273.15; }
						if(line.startsWith(((iSx-1)+(iSs*31))+":")) { String[] lineTmp = line.split(","); tTC875 = Double.parseDouble(lineTmp[gribSpot].replace("val=", ""))-273.15; }
						if(line.startsWith(((iSx-1)+(iSs*32))+":")) { String[] lineTmp = line.split(","); tTC900 = Double.parseDouble(lineTmp[gribSpot].replace("val=", ""))-273.15; }
						if(line.startsWith(((iSx-1)+(iSs*33))+":")) { String[] lineTmp = line.split(","); tTC925 = Double.parseDouble(lineTmp[gribSpot].replace("val=", ""))-273.15; }
						if(line.startsWith(((iSx-1)+(iSs*34))+":")) { String[] lineTmp = line.split(","); tTC950 = Double.parseDouble(lineTmp[gribSpot].replace("val=", ""))-273.15; }
						if(line.startsWith(((iSx-1)+(iSs*35))+":")) { String[] lineTmp = line.split(","); tTC975 = Double.parseDouble(lineTmp[gribSpot].replace("val=", ""))-273.15; }
						if(line.startsWith("534:")) { String[] lineTmp = line.split(","); tTC1000 = Double.parseDouble(lineTmp[gribSpot].replace("val=", ""))-273.15; }
						if(line.startsWith("609:")) { String[] lineTmp = line.split(","); tTC0 = Double.parseDouble(lineTmp[gribSpot].replace("val=", ""))-273.15; }

						if(line.startsWith(((iSx+5)+(iSs*0))+":")) { String[] lineTmp = line.split(","); tWU100 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+5)+(iSs*1))+":")) { String[] lineTmp = line.split(","); tWU125 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+5)+(iSs*2))+":")) { String[] lineTmp = line.split(","); tWU150 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+5)+(iSs*3))+":")) { String[] lineTmp = line.split(","); tWU175 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+5)+(iSs*4))+":")) { String[] lineTmp = line.split(","); tWU200 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+5)+(iSs*5))+":")) { String[] lineTmp = line.split(","); tWU225 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+5)+(iSs*6))+":")) { String[] lineTmp = line.split(","); tWU250 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+5)+(iSs*7))+":")) { String[] lineTmp = line.split(","); tWU275 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+5)+(iSs*8))+":")) { String[] lineTmp = line.split(","); tWU300 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+5)+(iSs*9))+":")) { String[] lineTmp = line.split(","); tWU325 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+5)+(iSs*10))+":")) { String[] lineTmp = line.split(","); tWU350 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+5)+(iSs*11))+":")) { String[] lineTmp = line.split(","); tWU375 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+5)+(iSs*12))+":")) { String[] lineTmp = line.split(","); tWU400 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+5)+(iSs*13))+":")) { String[] lineTmp = line.split(","); tWU425 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+5)+(iSs*14))+":")) { String[] lineTmp = line.split(","); tWU450 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+5)+(iSs*15))+":")) { String[] lineTmp = line.split(","); tWU475 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+5)+(iSs*16))+":")) { String[] lineTmp = line.split(","); tWU500 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+5)+(iSs*17))+":")) { String[] lineTmp = line.split(","); tWU525 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+5)+(iSs*18))+":")) { String[] lineTmp = line.split(","); tWU550 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+5)+(iSs*19))+":")) { String[] lineTmp = line.split(","); tWU575 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+5)+(iSs*20))+":")) { String[] lineTmp = line.split(","); tWU600 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+5)+(iSs*21))+":")) { String[] lineTmp = line.split(","); tWU625 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+5)+(iSs*22))+":")) { String[] lineTmp = line.split(","); tWU650 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+5)+(iSs*23))+":")) { String[] lineTmp = line.split(","); tWU675 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+5)+(iSs*24))+":")) { String[] lineTmp = line.split(","); tWU700 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+5)+(iSs*25))+":")) { String[] lineTmp = line.split(","); tWU725 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+5)+(iSs*26))+":")) { String[] lineTmp = line.split(","); tWU750 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+5)+(iSs*27))+":")) { String[] lineTmp = line.split(","); tWU775 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+5)+(iSs*28))+":")) { String[] lineTmp = line.split(","); tWU800 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+5)+(iSs*29))+":")) { String[] lineTmp = line.split(","); tWU825 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+5)+(iSs*30))+":")) { String[] lineTmp = line.split(","); tWU850 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+5)+(iSs*31))+":")) { String[] lineTmp = line.split(","); tWU875 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+5)+(iSs*32))+":")) { String[] lineTmp = line.split(","); tWU900 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+5)+(iSs*33))+":")) { String[] lineTmp = line.split(","); tWU925 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+5)+(iSs*34))+":")) { String[] lineTmp = line.split(","); tWU950 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+5)+(iSs*35))+":")) { String[] lineTmp = line.split(","); tWU975 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith("538:")) { String[] lineTmp = line.split(","); tWU1000 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith("610:")) { String[] lineTmp = line.split(","); tWU0 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }

						if(line.startsWith(((iSx+6)+(iSs*0))+":")) { String[] lineTmp = line.split(","); tWV100 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+6)+(iSs*1))+":")) { String[] lineTmp = line.split(","); tWV125 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+6)+(iSs*2))+":")) { String[] lineTmp = line.split(","); tWV150 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+6)+(iSs*3))+":")) { String[] lineTmp = line.split(","); tWV175 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+6)+(iSs*4))+":")) { String[] lineTmp = line.split(","); tWV200 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+6)+(iSs*5))+":")) { String[] lineTmp = line.split(","); tWV225 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+6)+(iSs*6))+":")) { String[] lineTmp = line.split(","); tWV250 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+6)+(iSs*7))+":")) { String[] lineTmp = line.split(","); tWV275 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+6)+(iSs*8))+":")) { String[] lineTmp = line.split(","); tWV300 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+6)+(iSs*9))+":")) { String[] lineTmp = line.split(","); tWV325 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+6)+(iSs*10))+":")) { String[] lineTmp = line.split(","); tWV350 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+6)+(iSs*11))+":")) { String[] lineTmp = line.split(","); tWV375 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+6)+(iSs*12))+":")) { String[] lineTmp = line.split(","); tWV400 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+6)+(iSs*13))+":")) { String[] lineTmp = line.split(","); tWV425 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+6)+(iSs*14))+":")) { String[] lineTmp = line.split(","); tWV450 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+6)+(iSs*15))+":")) { String[] lineTmp = line.split(","); tWV475 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+6)+(iSs*16))+":")) { String[] lineTmp = line.split(","); tWV500 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+6)+(iSs*17))+":")) { String[] lineTmp = line.split(","); tWV525 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+6)+(iSs*18))+":")) { String[] lineTmp = line.split(","); tWV550 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+6)+(iSs*19))+":")) { String[] lineTmp = line.split(","); tWV575 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+6)+(iSs*20))+":")) { String[] lineTmp = line.split(","); tWV600 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+6)+(iSs*21))+":")) { String[] lineTmp = line.split(","); tWV625 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+6)+(iSs*22))+":")) { String[] lineTmp = line.split(","); tWV650 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+6)+(iSs*23))+":")) { String[] lineTmp = line.split(","); tWV675 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+6)+(iSs*24))+":")) { String[] lineTmp = line.split(","); tWV700 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+6)+(iSs*25))+":")) { String[] lineTmp = line.split(","); tWV725 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+6)+(iSs*26))+":")) { String[] lineTmp = line.split(","); tWV750 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+6)+(iSs*27))+":")) { String[] lineTmp = line.split(","); tWV775 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+6)+(iSs*28))+":")) { String[] lineTmp = line.split(","); tWV800 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+6)+(iSs*29))+":")) { String[] lineTmp = line.split(","); tWV825 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+6)+(iSs*30))+":")) { String[] lineTmp = line.split(","); tWV850 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+6)+(iSs*31))+":")) { String[] lineTmp = line.split(","); tWV875 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+6)+(iSs*32))+":")) { String[] lineTmp = line.split(","); tWV900 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+6)+(iSs*33))+":")) { String[] lineTmp = line.split(","); tWV925 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+6)+(iSs*34))+":")) { String[] lineTmp = line.split(","); tWV950 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith(((iSx+6)+(iSs*35))+":")) { String[] lineTmp = line.split(","); tWV975 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith("539:")) { String[] lineTmp = line.split(","); tWV1000 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith("611:")) { String[] lineTmp = line.split(","); tWV0 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }

						if(line.startsWith("677:")) { String[] lineTmp = line.split(","); tCAPE = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith("676:")) { String[] lineTmp = line.split(","); tCIN = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith("633:")) { String[] lineTmp = line.split(","); tLI = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith("636:")) { String[] lineTmp = line.split(","); tPWAT = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith("253:")) { String[] lineTmp = line.split(","); tHGT500 = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }

					}
				}
				catch (FileNotFoundException fnf) { fnf.printStackTrace(); }

				double tTD100 = tTC100-(100-tRH100)/5; double tTD125 = tTC125-(100-tRH125)/5; double tTD150 = tTC150-(100-tRH150)/5; double tTD175 = tTC175-(100-tRH175)/5;
				double tTD200 = tTC200-(100-tRH200)/5; double tTD225 = tTC225-(100-tRH225)/5; double tTD250 = tTC250-(100-tRH250)/5; double tTD275 = tTC275-(100-tRH275)/5;
				double tTD300 = tTC300-(100-tRH300)/5; double tTD325 = tTC325-(100-tRH325)/5; double tTD350 = tTC350-(100-tRH350)/5; double tTD375 = tTC375-(100-tRH375)/5;
				double tTD400 = tTC400-(100-tRH400)/5; double tTD425 = tTC425-(100-tRH425)/5; double tTD450 = tTC450-(100-tRH450)/5; double tTD475 = tTC475-(100-tRH475)/5;
				double tTD500 = tTC500-(100-tRH500)/5; double tTD525 = tTC525-(100-tRH525)/5; double tTD550 = tTC550-(100-tRH550)/5; double tTD575 = tTC575-(100-tRH575)/5;
				double tTD600 = tTC600-(100-tRH600)/5; double tTD625 = tTC625-(100-tRH625)/5; double tTD650 = tTC650-(100-tRH650)/5; double tTD675 = tTC675-(100-tRH675)/5;
				double tTD700 = tTC700-(100-tRH700)/5; double tTD725 = tTC725-(100-tRH725)/5; double tTD750 = tTC750-(100-tRH750)/5; double tTD775 = tTC775-(100-tRH775)/5;
				double tTD800 = tTC800-(100-tRH800)/5; double tTD825 = tTC825-(100-tRH825)/5; double tTD850 = tTC850-(100-tRH850)/5; double tTD875 = tTC875-(100-tRH875)/5;
				double tTD900 = tTC900-(100-tRH900)/5; double tTD925 = tTC925-(100-tRH925)/5; double tTD950 = tTC950-(100-tRH950)/5; double tTD975 = tTC975-(100-tRH975)/5;
				double tTD1000 = tTC1000-(100-tRH1000)/5; double tTD0 = tTC0-(100-tRH0)/5;

				double tCCL = 0.001; double tFZLV = 0.001; double tWZLV = 0.001;

				double tWD100 = windDirCalc(tWU100, tWV100); double tWD125 = windDirCalc(tWU125, tWV125); double tWD150 = windDirCalc(tWU150, tWV150); double tWD175 = windDirCalc(tWU175, tWV175); 
				double tWS100 = windSpdCalc(tWU100, tWV100); double tWS125 = windSpdCalc(tWU125, tWV125); double tWS150 = windSpdCalc(tWU150, tWV150); double tWS175 = windSpdCalc(tWU175, tWV175);
				double tWD200 = windDirCalc(tWU200, tWV200); double tWD225 = windDirCalc(tWU225, tWV225); double tWD250 = windDirCalc(tWU150, tWV250); double tWD275 = windDirCalc(tWU275, tWV275); 
				double tWS200 = windSpdCalc(tWU200, tWV200); double tWS225 = windSpdCalc(tWU225, tWV225); double tWS250 = windSpdCalc(tWU150, tWV250); double tWS275 = windSpdCalc(tWU275, tWV275);
				double tWD300 = windDirCalc(tWU300, tWV300); double tWD325 = windDirCalc(tWU325, tWV325); double tWD350 = windDirCalc(tWU150, tWV350); double tWD375 = windDirCalc(tWU375, tWV375); 
				double tWS300 = windSpdCalc(tWU300, tWV300); double tWS325 = windSpdCalc(tWU325, tWV325); double tWS350 = windSpdCalc(tWU150, tWV350); double tWS375 = windSpdCalc(tWU375, tWV375);
				double tWD400 = windDirCalc(tWU400, tWV400); double tWD425 = windDirCalc(tWU425, tWV425); double tWD450 = windDirCalc(tWU150, tWV450); double tWD475 = windDirCalc(tWU475, tWV475); 
				double tWS400 = windSpdCalc(tWU400, tWV400); double tWS425 = windSpdCalc(tWU425, tWV425); double tWS450 = windSpdCalc(tWU150, tWV450); double tWS475 = windSpdCalc(tWU475, tWV475);
				double tWD500 = windDirCalc(tWU500, tWV500); double tWD525 = windDirCalc(tWU525, tWV525); double tWD550 = windDirCalc(tWU150, tWV550); double tWD575 = windDirCalc(tWU575, tWV575); 
				double tWS500 = windSpdCalc(tWU500, tWV500); double tWS525 = windSpdCalc(tWU525, tWV525); double tWS550 = windSpdCalc(tWU150, tWV550); double tWS575 = windSpdCalc(tWU575, tWV575);
				double tWD600 = windDirCalc(tWU600, tWV600); double tWD625 = windDirCalc(tWU625, tWV625); double tWD650 = windDirCalc(tWU150, tWV650); double tWD675 = windDirCalc(tWU675, tWV675); 
				double tWS600 = windSpdCalc(tWU600, tWV600); double tWS625 = windSpdCalc(tWU625, tWV625); double tWS650 = windSpdCalc(tWU150, tWV650); double tWS675 = windSpdCalc(tWU675, tWV675);
				double tWD700 = windDirCalc(tWU700, tWV700); double tWD725 = windDirCalc(tWU725, tWV725); double tWD750 = windDirCalc(tWU150, tWV750); double tWD775 = windDirCalc(tWU775, tWV775); 
				double tWS700 = windSpdCalc(tWU700, tWV700); double tWS725 = windSpdCalc(tWU725, tWV725); double tWS750 = windSpdCalc(tWU150, tWV750); double tWS775 = windSpdCalc(tWU775, tWV775);
				double tWD800 = windDirCalc(tWU800, tWV800); double tWD825 = windDirCalc(tWU825, tWV825); double tWD850 = windDirCalc(tWU150, tWV850); double tWD875 = windDirCalc(tWU875, tWV875); 
				double tWS800 = windSpdCalc(tWU800, tWV800); double tWS825 = windSpdCalc(tWU825, tWV825); double tWS850 = windSpdCalc(tWU150, tWV850); double tWS875 = windSpdCalc(tWU875, tWV875);
				double tWD900 = windDirCalc(tWU900, tWV900); double tWD925 = windDirCalc(tWU925, tWV925); double tWD950 = windDirCalc(tWU150, tWV950); double tWD975 = windDirCalc(tWU975, tWV975); 
				double tWS900 = windSpdCalc(tWU900, tWV900); double tWS925 = windSpdCalc(tWU925, tWV925); double tWS950 = windSpdCalc(tWU150, tWV950); double tWS975 = windSpdCalc(tWU975, tWV975);
				double tWD1000 = windDirCalc(tWU1000, tWV1000); double tWD0 = windDirCalc(tWU0, tWV0); 
				double tWS1000 = windSpdCalc(tWU1000, tWV1000); double tWS0 = windSpdCalc(tWU0, tWV0);
	
				Scanner rapScanner = null; try {		
					rapScanner = new Scanner(rapSounding);
					while(rapScanner.hasNext()) {

						String line = rapScanner.nextLine();

						if(line.startsWith("238:")) { String[] lineTmp = line.split(","); tCCL = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }
						if(line.startsWith("258:")) { String[] lineTmp = line.split(","); tFZLV = Double.parseDouble(lineTmp[gribSpot].replace("val=", ""))*3.28084; }
						if(line.startsWith("224:")) { String[] lineTmp = line.split(","); tWZLV = Double.parseDouble(lineTmp[gribSpot].replace("val=", "")); }

					}
				}
				catch (FileNotFoundException fnf) { fnf.printStackTrace(); }

				double tSLCL = calcSLCL(tTC0, tRH0);
				
				if (tRH500 != 0.001) { 
					jStationData
						.put("RH100", tRH100).put("RH125", tRH125).put("RH150", tRH150).put("RH175", tRH175)
						.put("RH200", tRH200).put("RH225", tRH225).put("RH250", tRH250).put("RH275", tRH275)
						.put("RH300", tRH300).put("RH325", tRH325).put("RH350", tRH350).put("RH375", tRH275)
						.put("RH400", tRH400).put("RH425", tRH425).put("RH450", tRH450).put("RH475", tRH475)
						.put("RH500", tRH500).put("RH525", tRH525).put("RH550", tRH550).put("RH575", tRH575)
						.put("RH600", tRH600).put("RH625", tRH625).put("RH650", tRH650).put("RH675", tRH675)
						.put("RH700", tRH700).put("RH725", tRH725).put("RH750", tRH750).put("RH775", tRH775)
						.put("RH800", tRH800).put("RH825", tRH825).put("RH850", tRH850).put("RH875", tRH875)
						.put("RH900", tRH900).put("RH925", tRH925).put("RH950", tRH950).put("RH975", tRH975)
						.put("RH1000", tRH1000).put("RH0", tRH0)
						.put("WD100", df.format(tWD100)).put("WD125", df.format(tWD125)).put("WD150", df.format(tWD150)).put("WD175", df.format(tWD175))
						.put("WD200", df.format(tWD200)).put("WD225", df.format(tWD225)).put("WD250", df.format(tWD250)).put("WD275", df.format(tWD275))
						.put("WD300", df.format(tWD300)).put("WD325", df.format(tWD325)).put("WD350", df.format(tWD350)).put("WD375", df.format(tWD275))
						.put("WD400", df.format(tWD400)).put("WD425", df.format(tWD425)).put("WD450", df.format(tWD450)).put("WD475", df.format(tWD475))
						.put("WD500", df.format(tWD500)).put("WD525", df.format(tWD525)).put("WD550", df.format(tWD550)).put("WD575", df.format(tWD575))
						.put("WD600", df.format(tWD600)).put("WD625", df.format(tWD625)).put("WD650", df.format(tWD650)).put("WD675", df.format(tWD675))
						.put("WD700", df.format(tWD700)).put("WD725", df.format(tWD725)).put("WD750", df.format(tWD750)).put("WD775", df.format(tWD775))
						.put("WD800", df.format(tWD800)).put("WD825", df.format(tWD825)).put("WD850", df.format(tWD850)).put("WD875", df.format(tWD875))
						.put("WD900", df.format(tWD900)).put("WD925", df.format(tWD925)).put("WD950", df.format(tWD950)).put("WD975", df.format(tWD975))
						.put("WD1000", df.format(tWD1000)).put("WD0", df.format(tWD0))
						.put("WS100", df.format(tWS100)).put("WS125", df.format(tWS125)).put("WS150", df.format(tWS150)).put("WS175", df.format(tWS175))
						.put("WS200", df.format(tWS200)).put("WS225", df.format(tWS225)).put("WS250", df.format(tWS250)).put("WS275", df.format(tWS275))
						.put("WS300", df.format(tWS300)).put("WS325", df.format(tWS325)).put("WS350", df.format(tWS350)).put("WS375", df.format(tWS275))
						.put("WS400", df.format(tWS400)).put("WS425", df.format(tWS425)).put("WS450", df.format(tWS450)).put("WS475", df.format(tWS475))
						.put("WS500", df.format(tWS500)).put("WS525", df.format(tWS525)).put("WS550", df.format(tWS550)).put("WS575", df.format(tWS575))
						.put("WS600", df.format(tWS600)).put("WS625", df.format(tWS625)).put("WS650", df.format(tWS650)).put("WS675", df.format(tWS675))
						.put("WS700", df.format(tWS700)).put("WS725", df.format(tWS725)).put("WS750", df.format(tWS750)).put("WS775", df.format(tWS775))
						.put("WS800", df.format(tWS800)).put("WS825", df.format(tWS825)).put("WS850", df.format(tWS850)).put("WS875", df.format(tWS875))
						.put("WS900", df.format(tWS900)).put("WS925", df.format(tWS925)).put("WS950", df.format(tWS950)).put("WS975", df.format(tWS975))
						.put("WS1000", df.format(tWS1000)).put("WS0", df.format(tWS0))
						.put("D100", df.format(tTD100)).put("D125", df.format(tTD125)).put("D150", df.format(tTD150)).put("D175", df.format(tTD175))
						.put("D200", df.format(tTD200)).put("D225", df.format(tTD225)).put("D250", df.format(tTD250)).put("D275", df.format(tTD275))
						.put("D300", df.format(tTD300)).put("D325", df.format(tTD325)).put("D350", df.format(tTD350)).put("D375", df.format(tTD275))
						.put("D400", df.format(tTD400)).put("D425", df.format(tTD425)).put("D450", df.format(tTD450)).put("D475", df.format(tTD475))
						.put("D500", df.format(tTD500)).put("D525", df.format(tTD525)).put("D550", df.format(tTD550)).put("D575", df.format(tTD575))
						.put("D600", df.format(tTD600)).put("D625", df.format(tTD625)).put("D650", df.format(tTD650)).put("D675", df.format(tTD675))
						.put("D700", df.format(tTD700)).put("D725", df.format(tTD725)).put("D750", df.format(tTD750)).put("D775", df.format(tTD775))
						.put("D800", df.format(tTD800)).put("D825", df.format(tTD825)).put("D850", df.format(tTD850)).put("D875", df.format(tTD875))
						.put("D900", df.format(tTD900)).put("D925", df.format(tTD925)).put("D950", df.format(tTD950)).put("D975", df.format(tTD975))
						.put("D1000", df.format(tTD1000)).put("D0", df.format(tTD0))
						.put("T100", df.format(tTC100)).put("T125", df.format(tTC125)).put("T150", df.format(tTC150)).put("T175", df.format(tTC175))
						.put("T200", df.format(tTC200)).put("T225", df.format(tTC225)).put("T250", df.format(tTC250)).put("T275", df.format(tTC275))
						.put("T300", df.format(tTC300)).put("T325", df.format(tTC325)).put("T350", df.format(tTC350)).put("T375", df.format(tTC275))
						.put("T400", df.format(tTC400)).put("T425", df.format(tTC425)).put("T450", df.format(tTC450)).put("T475", df.format(tTC475))
						.put("T500", df.format(tTC500)).put("T525", df.format(tTC525)).put("T550", df.format(tTC550)).put("T575", df.format(tTC575))
						.put("T600", df.format(tTC600)).put("T625", df.format(tTC625)).put("T650", df.format(tTC650)).put("T675", df.format(tTC675))
						.put("T700", df.format(tTC700)).put("T725", df.format(tTC725)).put("T750", df.format(tTC750)).put("T775", df.format(tTC775))
						.put("T800", df.format(tTC800)).put("T825", df.format(tTC825)).put("T850", df.format(tTC850)).put("T875", df.format(tTC875))
						.put("T900", df.format(tTC900)).put("T925", df.format(tTC925)).put("T950", df.format(tTC950)).put("T975", df.format(tTC975))
						.put("T1000", df.format(tTC1000)).put("T0", df.format(tTC0))
						.put("CAPE", tCAPE).put("CIN", tCIN).put("LI", tLI).put("PWAT", tPWAT).put("HGT500", tHGT500);
				} else { thisNullCounterModel++; }

				
				if (tFZLV != 0.001) {
					jStationData.put("WZLV", tWZLV).put("FZLV", tFZLV).put("CCL", tCCL).put("SLCL", df.format(tSLCL));
				} else { thisNullCounterModel++; }

				if (thisNullCounter != 11) {
					String thisJSONstring = jStationObj.toString().substring(1);
					thisJSONstring = thisJSONstring.substring(0, thisJSONstring.length()-1)+",";
					try { ShellUtils.varToFile(thisJSONstring, jsonOutFile, false); } catch (FileNotFoundException fnf) { fnf.printStackTrace(); }
					System.out.println(" -> Completed: "+thisStation+" ("+stationType+")");
					if (thisNullCounterModel == 2) { System.out.println("!!! WARN: NO MODEL DATA FOR Station "+thisStation+" !"); }
				} else { System.out.println("!!! WARN: NO DATA FOR Station "+thisStation+" !"); }

				iterk++;
				xmlOut.delete();

			}
			hrrrSounding.delete();
			rapSounding.delete();

		}

		if(stationType.equals("Basic")) {

			List<String> wxStations = new ArrayList<String>();
			final String getStationListSQL = "SELECT Station FROM WxObs.Stations WHERE Active=1 AND Region='"+region+"' AND Priority = 4 ORDER BY Priority, Station DESC;";
		
			try (
				Connection conn = MyDBConnector.getMyConnection(); Statement stmt = conn.createStatement();
				ResultSet resultSetStations = stmt.executeQuery(getStationListSQL);
			) { while (resultSetStations.next()) { wxStations.add(resultSetStations.getString("Station")); } }
			catch (Exception e) { e.printStackTrace(); }

			for (String thisStation : wxStations) {

				File xmlOut = new File(xsTmp+"/"+thisStation+".xml");
			
				JSONObject jStationObj = new JSONObject();
				JSONObject jStationData = new JSONObject();
				jStationObj.put(thisStation, jStationData);

				int thisNullCounter = 0;
				String tDewpointF = null;
				String tPressureMb = null;
				String tRelativeHumidity = null;
				String tTempF = null;
				String tTimeString = null;
				String tWeather = null;
				String tWindDegrees = null;
				String tWindDirection = null;
				String tWindSpeed = null;
				String tWindGust = null;
				String tVisibility = null;

				Scanner xmlScanner = null; try {		
					xmlScanner = new Scanner(xmlOut);
					while(xmlScanner.hasNext()) {
						String line = xmlScanner.nextLine();
						if(line.contains("<dewpoint_f>")) { Pattern p = Pattern.compile("<dewpoint_f>(.*)</dewpoint_f>"); Matcher m = p.matcher(line); if (m.find()) { tDewpointF = m.group(1); } }
						if(line.contains("<observation_time>")) { Pattern p = Pattern.compile("<observation_time>(.*)</observation_time>"); Matcher m = p.matcher(line); if (m.find()) { tTimeString = m.group(1); } }
						if(line.contains("<pressure_mb>")) { Pattern p = Pattern.compile("<pressure_mb>(.*)</pressure_mb>"); Matcher m = p.matcher(line); if (m.find()) { tPressureMb = m.group(1); } }
						if(line.contains("<relative_humidity>")) { Pattern p = Pattern.compile("<relative_humidity>(.*)</relative_humidity>"); Matcher m = p.matcher(line); if (m.find()) { tRelativeHumidity = m.group(1); } }
						if(line.contains("<temp_f>")) { Pattern p = Pattern.compile("<temp_f>(.*)</temp_f>"); Matcher m = p.matcher(line); if (m.find()) { tTempF = m.group(1); } }
						if(line.contains("<weather>")) { Pattern p = Pattern.compile("<weather>(.*)</weather>"); Matcher m = p.matcher(line); if (m.find()) { tWeather = m.group(1); } }
						if(line.contains("<wind_degrees>")) { Pattern p = Pattern.compile("<wind_degrees>(.*)</wind_degrees>"); Matcher m = p.matcher(line); if (m.find()) { tWindDegrees = m.group(1); } }
						if(line.contains("<wind_dir>")) { Pattern p = Pattern.compile("<wind_dir>(.*)</wind_dir>"); Matcher m = p.matcher(line); if (m.find()) { tWindDirection = m.group(1); } }
						if(line.contains("<wind_mph>")) { Pattern p = Pattern.compile("<wind_mph>(.*)</wind_mph>"); Matcher m = p.matcher(line); if (m.find()) { tWindSpeed = m.group(1); } }
						if(line.contains("<wind_gust_mph>")) { Pattern p = Pattern.compile("<wind_gust_mph>(.*)</wind_gust_mph>"); Matcher m = p.matcher(line); if (m.find()) { tWindGust = m.group(1); } }
						if(line.contains("<visibility_mi>")) { Pattern p = Pattern.compile("<visibility_mi>(.*)</visibility_mi>"); Matcher m = p.matcher(line); if (m.find()) { tVisibility = m.group(1); } }
					}
				}
				catch (FileNotFoundException fnf) { fnf.printStackTrace(); }

				if (tTempF != null) { jStationData.put("Temperature", tTempF); } else { thisNullCounter++; }
				if (tDewpointF != null) { jStationData.put("Dewpoint", tDewpointF); } else { thisNullCounter++; }
				if (tRelativeHumidity != null) { jStationData.put("RelativeHumidity", tRelativeHumidity); } else { thisNullCounter++; }
				if (tPressureMb != null) { jStationData.put("Pressure", tPressureMb); } else { thisNullCounter++; }
				if (tTimeString != null) { jStationData.put("TimeString", tTimeString); } else { thisNullCounter++; }
				if (tVisibility != null) { jStationData.put("Visibility", tVisibility); } else { thisNullCounter++; }
				if (tWeather != null) { jStationData.put("Weather", tWeather); } else { thisNullCounter++; }
				if (tWindDegrees != null) { jStationData.put("WindDegrees", tWindDegrees); } else { thisNullCounter++; }
				if (tWindGust != null) { jStationData.put("WindGust", tWindGust); } else { thisNullCounter++; }
				if (tWindSpeed != null) { jStationData.put("WindSpeed", tWindSpeed); } else { thisNullCounter++; }

				if (thisNullCounter != 10) {
					String thisJSONstring = jStationObj.toString().substring(1);
					thisJSONstring = thisJSONstring.substring(0, thisJSONstring.length()-1)+",";
					try { ShellUtils.varToFile(thisJSONstring, jsonOutFile, true); } catch (FileNotFoundException fnf) { fnf.printStackTrace(); }
					System.out.println(" -> Completed: "+thisStation+" ("+stationType+")");
				} else { System.out.println("!!! WARN: NO DATA FOR Station "+thisStation+" !"); }

				xmlOut.delete();
		
			}

		}
		
		if(stationType.equals("METAR")) {

			List<String> wxStations = new ArrayList<String>();
			final String getStationListSQL = "SELECT Station FROM WxObs.Stations WHERE Active=1 AND Region='"+region+"' AND Priority = 5 ORDER BY Priority, Station DESC;";
			final File xmlMetarsIn = new File(xsTmp+"/metars.xml");

			try (
				Connection conn = MyDBConnector.getMyConnection(); Statement stmt = conn.createStatement();
				ResultSet resultSetStations = stmt.executeQuery(getStationListSQL);
			) { while (resultSetStations.next()) { wxStations.add(resultSetStations.getString("Station")); } }
			catch (Exception e) { e.printStackTrace(); }

			try {

				DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
				DocumentBuilder builder = factory.newDocumentBuilder();
				Document xmlDoc = builder.parse(xmlMetarsIn);

				for (String thisStation : wxStations) {

					int thisNullCounter = 0;
					String tDewpointC = null;
					String tPressureMb = null;
					String tTempC = null;
					String tTimeString = null;
					String tWeather = null;
					String tWindDegrees = null;
					String tWindSpeed = null;
					String tVisibility = null;
					String tPrecipIn = null;
					String tRawMETAR = null;

					try {
						XPathFactory xPathFactory = XPathFactory.newInstance();
						XPath xpath = xPathFactory.newXPath();
						tTempC = xpath.evaluate("//*[station_id='"+thisStation+"']/temp_c", xmlDoc);
						tDewpointC = xpath.evaluate("//*[station_id='"+thisStation+"']/dewpoint_c", xmlDoc);
						tPressureMb = xpath.evaluate("//*[station_id='"+thisStation+"']/sea_level_pressure_mb", xmlDoc);
						tTimeString = xpath.evaluate("//*[station_id='"+thisStation+"']/observation_time", xmlDoc);
						tWeather = xpath.evaluate("//*[station_id='"+thisStation+"']/wx_string", xmlDoc);
						tWindDegrees = xpath.evaluate("//*[station_id='"+thisStation+"']/wind_dir_degrees", xmlDoc);
						tWindSpeed = xpath.evaluate("//*[station_id='"+thisStation+"']/wind_speed_kt", xmlDoc);
						tVisibility = xpath.evaluate("//*[station_id='"+thisStation+"']/visibility_statute_mi", xmlDoc);
						tPrecipIn = xpath.evaluate("//*[station_id='"+thisStation+"']/precip_in", xmlDoc);
						tRawMETAR = xpath.evaluate("//*[station_id='"+thisStation+"']/raw_text", xmlDoc);

					}
					catch (XPathException xpx) { xpx.printStackTrace(); }
								
					JSONObject jStationObj = new JSONObject();
					JSONObject jStationData = new JSONObject();
					jStationObj.put(thisStation, jStationData);

					if (tTempC != null) { jStationData.put("Temperature", tTempC); } else { thisNullCounter++; }
					if (tDewpointC != null) { jStationData.put("Dewpoint", tDewpointC); } else { thisNullCounter++; }
					if (tPressureMb != null) { jStationData.put("Pressure", tPressureMb); } else { thisNullCounter++; }
					if (tTimeString != null) { jStationData.put("TimeString", tTimeString); } else { thisNullCounter++; }
					if (tVisibility != null) { jStationData.put("Visibility", tVisibility); } else { thisNullCounter++; }
					if (tWeather != null) { jStationData.put("Weather", tWeather); } else { thisNullCounter++; }
					if (tWindDegrees != null) { jStationData.put("WindDegrees", tWindDegrees); } else { thisNullCounter++; }
					if (tWindSpeed != null) { jStationData.put("WindSpeed", tWindSpeed); } else { thisNullCounter++; }
					if (tPrecipIn != null) { jStationData.put("PrecipIn", tPrecipIn); } else { thisNullCounter++; }
					if (tRawMETAR != null) { jStationData.put("RawMETAR", tRawMETAR); } else { thisNullCounter++; }

					if (thisNullCounter != 10) {
						String thisJSONstring = jStationObj.toString().substring(1);
						thisJSONstring = thisJSONstring.substring(0, thisJSONstring.length()-1)+",";
						try { ShellUtils.varToFile(thisJSONstring, jsonOutFile, true); } catch (FileNotFoundException fnf) { fnf.printStackTrace(); }
						System.out.println(" -> Completed: "+thisStation+" ("+stationType+")");
					} else { System.out.println("!!! WARN: NO DATA FOR Station "+thisStation+" !"); }
					
				}

			}

			catch (SAXException sex) { sex.printStackTrace(); }
			catch (ParserConfigurationException pcx) { pcx.printStackTrace(); }
			catch (IOException iox) { iox.printStackTrace(); }

		}

		if(stationType.equals("Bouy")) {
			
			List<String> wxStations = new ArrayList<String>();
			final String getStationListSQL = "SELECT SUBSTR(Station,2) FROM WxObs.Stations WHERE Active=1 AND Region='"+region+"' AND Priority = 6 ORDER BY Priority, Station DESC;";

			try (
				Connection conn = MyDBConnector.getMyConnection(); Statement stmt = conn.createStatement();
				ResultSet resultSetStations = stmt.executeQuery(getStationListSQL);
			) { while (resultSetStations.next()) { wxStations.add(resultSetStations.getString("Station")); } }
			catch (Exception e) { e.printStackTrace(); }

			for (String thisStation : wxStations) {
			
				File xmlOut = new File(xsTmp+"/"+thisStation+".xml");
			
				JSONObject jStationObj = new JSONObject();
				JSONObject jStationData = new JSONObject();
				jStationObj.put(thisStation, jStationData);

				int thisNullCounter = 0;
				String tDewpointF = null;
				String tPressureMb = null;
				String tRelativeHumidity = null;
				String tTempF = null;
				String tTimeString = null;
				String tWaterTempF = null;
				String tWaveDegrees = null;
				String tWaveDirection = null;
				String tWaveHeight = null;
				String tWavePeriodAvg = null;
				String tWavePeriodDom = null;
				String tWeather = null;
				String tWindDegrees = null;
				String tWindDirection = null;
				String tWindSpeed = null;
				String tWindGust = null;
				String tVisibility = null;

				Scanner xmlScanner = null; try {		
					xmlScanner = new Scanner(xmlOut);
					while(xmlScanner.hasNext()) {
						String line = xmlScanner.nextLine();
						if(line.contains("<dewpoint_f>")) { Pattern p = Pattern.compile("<dewpoint_f>(.*)</dewpoint_f>"); Matcher m = p.matcher(line); if (m.find()) { tDewpointF = m.group(1); } }
						if(line.contains("<observation_time>")) { Pattern p = Pattern.compile("<observation_time>(.*)</observation_time>"); Matcher m = p.matcher(line); if (m.find()) { tTimeString = m.group(1); } }
						if(line.contains("<pressure_mb>")) { Pattern p = Pattern.compile("<pressure_mb>(.*)</pressure_mb>"); Matcher m = p.matcher(line); if (m.find()) { tPressureMb = m.group(1); } }
						if(line.contains("<relative_humidity>")) { Pattern p = Pattern.compile("<relative_humidity>(.*)</relative_humidity>"); Matcher m = p.matcher(line); if (m.find()) { tRelativeHumidity = m.group(1); } }
						if(line.contains("<temp_f>")) { Pattern p = Pattern.compile("<temp_f>(.*)</temp_f>"); Matcher m = p.matcher(line); if (m.find()) { tTempF = m.group(1); } }
						if(line.contains("<weather>")) { Pattern p = Pattern.compile("<weather>(.*)</weather>"); Matcher m = p.matcher(line); if (m.find()) { tWeather = m.group(1); } }
						if(line.contains("<water_temp_f>")) { Pattern p = Pattern.compile("<water_temp_f>(.*)</water_temp_f>"); Matcher m = p.matcher(line); if (m.find()) { tWaterTempF = m.group(1); } }
						if(line.contains("<mean_wave_degrees>")) { Pattern p = Pattern.compile("<mean_wave_degrees>(.*)</mean_wave_degrees>"); Matcher m = p.matcher(line); if (m.find()) { tWaveDegrees = m.group(1); } }
						if(line.contains("<mean_wave_dir>")) { Pattern p = Pattern.compile("<mean_wave_dir>(.*)</mean_wave_dir>"); Matcher m = p.matcher(line); if (m.find()) { tWaveDirection = m.group(1); } }
						if(line.contains("<wave_height_m>")) { Pattern p = Pattern.compile("<wave_height_m>(.*)</wave_height_m>"); Matcher m = p.matcher(line); if (m.find()) { tWaveHeight = m.group(1); } }
						if(line.contains("<average_period_sec>")) { Pattern p = Pattern.compile("<average_period_sec>(.*)</average_period_sec>"); Matcher m = p.matcher(line); if (m.find()) { tWavePeriodAvg = m.group(1); } }
						if(line.contains("<dominant_period_sec>")) { Pattern p = Pattern.compile("<dominant_period_sec>(.*)</dominant_period_sec>"); Matcher m = p.matcher(line); if (m.find()) { tWavePeriodDom = m.group(1); } }
						if(line.contains("<wind_degrees>")) { Pattern p = Pattern.compile("<wind_degrees>(.*)</wind_degrees>"); Matcher m = p.matcher(line); if (m.find()) { tWindDegrees = m.group(1); } }
						if(line.contains("<wind_dir>")) { Pattern p = Pattern.compile("<wind_dir>(.*)</wind_dir>"); Matcher m = p.matcher(line); if (m.find()) { tWindDirection = m.group(1); } }
						if(line.contains("<wind_mph>")) { Pattern p = Pattern.compile("<wind_mph>(.*)</wind_mph>"); Matcher m = p.matcher(line); if (m.find()) { tWindSpeed = m.group(1); } }
						if(line.contains("<wind_gust_mph>")) { Pattern p = Pattern.compile("<wind_gust_mph>(.*)</wind_gust_mph>"); Matcher m = p.matcher(line); if (m.find()) { tWindGust = m.group(1); } }
						if(line.contains("<visibility_mi>")) { Pattern p = Pattern.compile("<visibility_mi>(.*)</visibility_mi>"); Matcher m = p.matcher(line); if (m.find()) { tVisibility = m.group(1); } }
					}
				}
				catch (FileNotFoundException fnf) { fnf.printStackTrace(); }
			
				if (tTempF != null) { jStationData.put("Temperature", tTempF); } else { thisNullCounter++; }
				if (tDewpointF != null) { jStationData.put("Dewpoint", tDewpointF); } else { thisNullCounter++; }
				if (tRelativeHumidity != null) { jStationData.put("RelativeHumidity", tRelativeHumidity); } else { thisNullCounter++; }
				if (tPressureMb != null) { jStationData.put("Pressure", tPressureMb); } else { thisNullCounter++; }
				if (tTimeString != null) { jStationData.put("TimeString", tTimeString); } else { thisNullCounter++; }
				if (tVisibility != null) { jStationData.put("Visibility", tVisibility); } else { thisNullCounter++; }
				if (tWaterTempF != null) { jStationData.put("WaterTemp", tWaterTempF); } else { thisNullCounter++; }
				if (tWaveDegrees != null) { jStationData.put("WaveDegrees", tWaveDegrees); } else { thisNullCounter++; }
				if (tWaveDirection != null) { jStationData.put("WaveDirection", tWaveDirection); } else { thisNullCounter++; }
				if (tWaveHeight != null) { jStationData.put("WaveHeight", tWaveHeight); } else { thisNullCounter++; }
				if (tWavePeriodAvg != null) { jStationData.put("WavePeriodAverage", tWavePeriodAvg); } else { thisNullCounter++; }
				if (tWavePeriodDom != null) { jStationData.put("WavePeriodDominant", tWavePeriodDom); } else { thisNullCounter++; }
				if (tWeather != null) { jStationData.put("Weather", tWeather); } else { thisNullCounter++; }
				if (tWindDegrees != null) { jStationData.put("WindDegrees", tWindDegrees); } else { thisNullCounter++; }
				if (tWindDirection != null) { jStationData.put("WindDirection", tWindDirection); } else { thisNullCounter++; }
				if (tWindGust != null) { jStationData.put("WindGust", tWindGust); } else { thisNullCounter++; }
				if (tWindSpeed != null) { jStationData.put("WindSpeed", tWindSpeed); } else { thisNullCounter++; }

				if (thisNullCounter != 17) {
					String thisJSONstring = jStationObj.toString().substring(1);
					thisJSONstring = thisJSONstring.substring(0, thisJSONstring.length()-1)+",";
					try { ShellUtils.varToFile(thisJSONstring, jsonOutFile, true); } catch (FileNotFoundException fnf) { fnf.printStackTrace(); }
					System.out.println(" -> Completed: "+thisStation+" ("+stationType+")");
				} else { System.out.println("!!! WARN: NO DATA FOR Station "+thisStation+" !"); }
					
				xmlOut.delete();
				
			}
			
		}
		
		if(stationType.equals("Hydro")) {
			
			List<String> wxStations = new ArrayList<String>();
			final String getStationListSQL = "SELECT Station FROM WxObs.Stations WHERE Active=1 AND Priority=7 ORDER BY Priority, Station DESC;";

			try (
				Connection conn = MyDBConnector.getMyConnection(); Statement stmt = conn.createStatement();
				ResultSet resultSetStations = stmt.executeQuery(getStationListSQL);
			) { while (resultSetStations.next()) { wxStations.add(resultSetStations.getString("Station")); } }
			catch (Exception e) { e.printStackTrace(); }

			for (String thisStation : wxStations) {
			
				File xmlOut = new File(xsTmp+"/"+thisStation+".xml");
			
				JSONObject jStationObj = new JSONObject();
				JSONObject jStationData = new JSONObject();
				jStationObj.put(thisStation, jStationData);
				
				int thisNullCounter = 0;
				String tDewpointF = null;
				String tPressureMb = null;
				String tRelativeHumidity = null;
				String tTempF = null;
				String tTimeString = null;
				String tWaterTempF = null;
				String tWaveDegrees = null;
				String tWaveDirection = null;
				String tWaveHeight = null;
				String tWavePeriodAvg = null;
				String tWavePeriodDom = null;
				String tWeather = null;
				String tWindDegrees = null;
				String tWindDirection = null;
				String tWindSpeed = null;
				String tWindGust = null;
				String tVisibility = null;

				Scanner xmlScanner = null; try {		
					xmlScanner = new Scanner(xmlOut);
					while(xmlScanner.hasNext()) {
						String line = xmlScanner.nextLine();
						if(line.contains("<dewpoint_f>")) { Pattern p = Pattern.compile("<dewpoint_f>(.*)</dewpoint_f>"); Matcher m = p.matcher(line); if (m.find()) { tDewpointF = m.group(1); } }
						if(line.contains("<observation_time>")) { Pattern p = Pattern.compile("<observation_time>(.*)</observation_time>"); Matcher m = p.matcher(line); if (m.find()) { tTimeString = m.group(1); } }
						if(line.contains("<pressure_mb>")) { Pattern p = Pattern.compile("<pressure_mb>(.*)</pressure_mb>"); Matcher m = p.matcher(line); if (m.find()) { tPressureMb = m.group(1); } }
						if(line.contains("<relative_humidity>")) { Pattern p = Pattern.compile("<relative_humidity>(.*)</relative_humidity>"); Matcher m = p.matcher(line); if (m.find()) { tRelativeHumidity = m.group(1); } }
						if(line.contains("<temp_f>")) { Pattern p = Pattern.compile("<temp_f>(.*)</temp_f>"); Matcher m = p.matcher(line); if (m.find()) { tTempF = m.group(1); } }
						if(line.contains("<weather>")) { Pattern p = Pattern.compile("<weather>(.*)</weather>"); Matcher m = p.matcher(line); if (m.find()) { tWeather = m.group(1); } }
						if(line.contains("<water_temp_f>")) { Pattern p = Pattern.compile("<water_temp_f>(.*)</water_temp_f>"); Matcher m = p.matcher(line); if (m.find()) { tWaterTempF = m.group(1); } }
						if(line.contains("<mean_wave_degrees>")) { Pattern p = Pattern.compile("<mean_wave_degrees>(.*)</mean_wave_degrees>"); Matcher m = p.matcher(line); if (m.find()) { tWaveDegrees = m.group(1); } }
						if(line.contains("<mean_wave_dir>")) { Pattern p = Pattern.compile("<mean_wave_dir>(.*)</mean_wave_dir>"); Matcher m = p.matcher(line); if (m.find()) { tWaveDirection = m.group(1); } }
						if(line.contains("<wave_height_m>")) { Pattern p = Pattern.compile("<wave_height_m>(.*)</wave_height_m>"); Matcher m = p.matcher(line); if (m.find()) { tWaveHeight = m.group(1); } }
						if(line.contains("<average_period_sec>")) { Pattern p = Pattern.compile("<average_period_sec>(.*)</average_period_sec>"); Matcher m = p.matcher(line); if (m.find()) { tWavePeriodAvg = m.group(1); } }
						if(line.contains("<dominant_period_sec>")) { Pattern p = Pattern.compile("<dominant_period_sec>(.*)</dominant_period_sec>"); Matcher m = p.matcher(line); if (m.find()) { tWavePeriodDom = m.group(1); } }
						if(line.contains("<wind_degrees>")) { Pattern p = Pattern.compile("<wind_degrees>(.*)</wind_degrees>"); Matcher m = p.matcher(line); if (m.find()) { tWindDegrees = m.group(1); } }
						if(line.contains("<wind_dir>")) { Pattern p = Pattern.compile("<wind_dir>(.*)</wind_dir>"); Matcher m = p.matcher(line); if (m.find()) { tWindDirection = m.group(1); } }
						if(line.contains("<wind_mph>")) { Pattern p = Pattern.compile("<wind_mph>(.*)</wind_mph>"); Matcher m = p.matcher(line); if (m.find()) { tWindSpeed = m.group(1); } }
						if(line.contains("<wind_gust_mph>")) { Pattern p = Pattern.compile("<wind_gust_mph>(.*)</wind_gust_mph>"); Matcher m = p.matcher(line); if (m.find()) { tWindGust = m.group(1); } }
						if(line.contains("<visibility_mi>")) { Pattern p = Pattern.compile("<visibility_mi>(.*)</visibility_mi>"); Matcher m = p.matcher(line); if (m.find()) { tVisibility = m.group(1); } }
					}
				}
				catch (FileNotFoundException fnf) { fnf.printStackTrace(); }
			
				if (tTempF != null) { jStationData.put("Temperature", tTempF); } else { thisNullCounter++; }
				if (tDewpointF != null) { jStationData.put("Dewpoint", tDewpointF); } else { thisNullCounter++; }
				if (tRelativeHumidity != null) { jStationData.put("RelativeHumidity", tRelativeHumidity); } else { thisNullCounter++; }
				if (tPressureMb != null) { jStationData.put("Pressure", tPressureMb); } else { thisNullCounter++; }
				if (tTimeString != null) { jStationData.put("TimeString", tTimeString); } else { thisNullCounter++; }
				if (tVisibility != null) { jStationData.put("Visibility", tVisibility); } else { thisNullCounter++; }
				if (tWaterTempF != null) { jStationData.put("WaterTemp", tWaterTempF); } else { thisNullCounter++; }
				if (tWaveDegrees != null) { jStationData.put("WaveDegrees", tWaveDegrees); } else { thisNullCounter++; }
				if (tWaveDirection != null) { jStationData.put("WaveDirection", tWaveDirection); } else { thisNullCounter++; }
				if (tWaveHeight != null) { jStationData.put("WaveHeight", tWaveHeight); } else { thisNullCounter++; }
				if (tWavePeriodAvg != null) { jStationData.put("WavePeriodAverage", tWavePeriodAvg); } else { thisNullCounter++; }
				if (tWavePeriodDom != null) { jStationData.put("WavePeriodDominant", tWavePeriodDom); } else { thisNullCounter++; }
				if (tWeather != null) { jStationData.put("Weather", tWeather); } else { thisNullCounter++; }
				if (tWindDegrees != null) { jStationData.put("WindDegrees", tWindDegrees); } else { thisNullCounter++; }
				if (tWindDirection != null) { jStationData.put("WindDirection", tWindDirection); } else { thisNullCounter++; }
				if (tWindGust != null) { jStationData.put("WindGust", tWindGust); } else { thisNullCounter++; }
				if (tWindSpeed != null) { jStationData.put("WindSpeed", tWindSpeed); } else { thisNullCounter++; }

				if (thisNullCounter != 17) {
					String thisJSONstring = jStationObj.toString().substring(1);
					thisJSONstring = thisJSONstring.substring(0, thisJSONstring.length()-1)+",";
					try { ShellUtils.varToFile(thisJSONstring, jsonOutFile, true); } catch (FileNotFoundException fnf) { fnf.printStackTrace(); }
					System.out.println(" -> Completed: "+thisStation+" ("+stationType+")");
				} else { System.out.println("!!! WARN: NO DATA FOR Station "+thisStation+" !"); }
					
				xmlOut.delete();
				
			}
			
		}
	}

}
