package jASUtils;

import java.io.*;
import java.sql.*;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.concurrent.*;
import java.util.Date;

import jASUtils.MyDBConnector;
import jASUtils.ShellUtils;

public class SDUtils {

	public static void main (String[] args) {

		String build = "SD Utils Java - Build 346";
		String updated = "07 AUG 2017 @ 19:10 CT";
		String usbDrivePath = "/media/astump/PHONE";
		String cachePath = "/home/astump/.cache";
		DateFormat dateFormat = new SimpleDateFormat("yyMMddHHmm");
		Date date = new Date();
		String thisTimestamp = dateFormat.format(date);
		System.out.println(build+"\n"+updated+"\n"+usbDrivePath+"\nRun time: "+thisTimestamp+"\nby Anthony Stump\n\n");

		System.out.println("Requesting privilages and setting path...");
		ShellUtils.runProcess("sudo echo Done");

		System.setProperty("user.dir", usbDrivePath);
		System.out.println("Installing ASWebUI off MicroSD card...");
		ShellUtils.runProcess("bash "+usbDrivePath+"/ASWebUI/Install.sh");

		System.out.println("Cleaning crap off this MicroSD card...");
		
		String[] pathsToDelete = {
			"/.mmsyscache/",
			"/.the.pdfviewer3/",
			"/.Trash-1000/",
			"/albumthumbs/",
			"/Android/data/",
			"/AppGame/",
			"/DCIM/.thumbnails/",
			"/LOST.DIR/",
			"/ppy_cross/",
			"/tmp/" };
		
		for (String thisPathString : pathsToDelete) {
			File thisFolder = new File(usbDrivePath+thisPathString);
			ShellUtils.deleteDir(thisFolder);
		}

		String[] filesToDelete = { ".bugsense", "tapcontext" };
		for (String thisFileString : filesToDelete) {
			File thisFile = new File(usbDrivePath+thisFileString);
			thisFile.delete();
		}
		
		System.out.println("Creating encrypted backup of MySQL critical databases...");
		System.setProperty("user.dir", usbDrivePath+"/");
		new File(cachePath+"/SQLDumps").mkdirs();
		
		String[] sqlTasks = { "Core", "jspServ", "lahman2016", "net_snmp", "WebCal" };
		for (String task : sqlTasks) {
			ShellUtils.runProcess("sudo -i mysqldump "+task+" --result-file="+cachePath+"/SQLDumps/"+task+".sql");
		}

		ShellUtils.runProcess("tar -zcvf \""+cachePath+"/"+thisTimestamp+"-Struct.tar.gz\" "+cachePath+"/SQLDumps/*");
		File sqlCacheFolder = new File(cachePath+"/SQLDumps");
		ShellUtils.deleteDir(sqlCacheFolder);		
		ShellUtils.runProcess("gpg --output \""+usbDrivePath+"/[data]/Tools/SQL/Backup/"+thisTimestamp+"-Struct.tar.gz.gpg\" --encrypt --recipient f00dl3a@gmail.com \""+cachePath+"/"+thisTimestamp+"-Struct.tar.gz\"");
		File unEncDbBU = new File(cachePath+"/"+thisTimestamp+"-Struct.tar.gz");
		unEncDbBU.delete();

		System.out.println("Backing up CODEX data...");
		ShellUtils.runProcess("tar -zvcf \""+usbDrivePath+"/[data]/Tools/dev/codex.tar.gz\" \"/home/astump/src/codex\"");

		System.out.println("Backing up all SD Card data...");
		ShellUtils.runProcess("tar -zcvf \"/home/astump/USB-Back/"+thisTimestamp+".tar.gz\" \""+usbDrivePath+"\"");
		ShellUtils.runProcess("(ls /home/astump/USB-Back/* -t | head -n 4; ls /home/astump/USB-Back/*)|sort|uniq -u|xargs rm");

		System.out.println("Writing log into database...");
		String usbBackSizeKB = Long.toString(new File("/home/astump/USB-Back/1708061140.tar.gz").length()/1024);
		String updateQuery = "INSERT INTO Core.Log_SDUtils (Date,Time,Notes,ZIPSize) VALUES (CURDATE(),CURTIME(),'Ran "+build+" Modified "+updated+"',"+usbBackSizeKB+");";		
		try (
			Connection conn = MyDBConnector.getMyConnection();
			Statement stmt = conn.createStatement();
		) { ResultSet rs = stmt.executeQuery(updateQuery); }
		catch (Exception e) { e.printStackTrace(); }
		
	}

}
