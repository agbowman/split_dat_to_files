CREATE PROGRAM cclocdviewex:dba
 SET errmsg = fillstring(132," ")
 SET error_check = error(errmsg,1)
 SET errorcode = 0
 SET interactive = validate(reply->ops_event,"ZZZ")
 IF (interactive="ZZZ")
  RECORD reply(
    1 ops_event = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ELSE
  SET reply->status_data.status = "F"
  SET reply->ops_event = substring(1,100,"CCLOCDView must be run interactively.")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "F"
 SET reply->ops_event = ""
 SET message = window
 CALL clear(20,01)
 CALL clear(21,01)
 CALL clear(22,01)
 CALL clear(23,01)
 CALL clear(24,01)
 CALL video(n)
 SET num = 0
 SET plan_text = "001"
 CALL text(22,05,"Enter the OCD number or (Return) for Backup / Temp Dictionary.")
 CALL accept(23,05,"9(6);H",num)
 SET num = cnvtint(curaccept)
 SET ocdnumstring = format(num,"######;P0")
 CALL clear(22,01)
 CALL clear(23,01)
 CALL video(n)
 SET group = fillstring(1,"S")
 CALL text(22,05,
  "Enter S for source, B for backup dictionary, O for Original Backup directory or T for Temp Dictionary."
  )
 CALL accept(23,05,"P(1);C",group
  WHERE curaccept IN ("S", "s", "B", "b", "O",
  "o", "T", "t"))
 IF (group=cnvtupper(curaccept))
  SET source_ind = 1
 ELSE
  IF (cnvtupper(curaccept)="B")
   SET source_ind = 2
  ELSE
   IF (cnvtupper(curaccept)="O")
    SET source_ind = 3
   ELSE
    SET source_ind = 4
    CALL clear(22,01)
    CALL text(22,05,"Enter Plan Number to view Tempory Dictionary.")
    CALL accept(23,05,"P(3);C",plan_text)
    SET plan_text = curaccept
    IF (cnvtreal(plan_text) > 99)
     SET plan_num = plan_text
    ELSEIF (cnvtreal(plan_text) > 9)
     SET plan_num = substring(2,2,plan_text)
    ELSE
     SET plan_num = substring(3,1,plan_text)
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 SET output_dest = fillstring(40," ")
 SET output_dest = "MINE"
 CALL clear(22,01)
 CALL clear(23,01)
 CALL text(22,05,"Enter an output destination.")
 CALL accept(23,05,"P(40);C",output_dest)
 SET output_dest = curaccept
 CALL clear(22,01)
 CALL clear(23,01)
 SET message = nowindow
 FREE SET ocddir
 IF (cursys="AIX")
  IF (source_ind < 3)
   SET path = value(concat(trim(logical("cer_ocd")),"/",ocdnumstring,"/"))
   SET logical ocddir value(concat(trim(logical("cer_ocd")),"/",ocdnumstring))
  ELSE
   IF (source_ind=3)
    SET path = value(concat(trim(logical("cer_ocd")),"/orginalbackup/"))
    SET logical ocddir value(concat(trim(logical("cer_ocd")),"/originalbackup"))
   ELSE
    SET path = value(concat(trim(logical("cer_ocd")),"/plans/plan_",plan_num))
    SET logical ocddir value(concat(trim(logical("cer_ocd")),"/plans/plan_",plan_num))
   ENDIF
  ENDIF
 ELSE
  IF (source_ind < 3)
   SET cerocd = logical("cer_ocd")
   SET len = findstring("]",cerocd)
   SET line = concat(substring(1,(len - 1),cerocd),ocdnumstring,"]")
   SET logical ocddir line
   SET path = line
  ELSE
   IF (source_ind=3)
    SET cerocd = logical("cer_ocd")
    SET len = findstring("]",cerocd)
    SET line = concat(substring(1,(len - 1),cerocd),"originalbackup","]")
    SET logical ocddir line
    SET path = line
   ELSE
    SET cerocd = logical("cer_ocd")
    SET len = findstring("]",cerocd)
    SET line = concat(substring(1,(len - 1),cerocd),"plans.plan_",plan_num,"]")
    SET logical ocddir line
    SET path = line
   ENDIF
  ENDIF
 ENDIF
 IF (source_ind=1)
  SET minidic = concat("ocddir:","dicocd",ocdnumstring,".dat")
  SET fullpath = build(path,"dicocd",ocdnumstring,".dat")
 ELSE
  IF (source_ind=2)
   SET minidic = concat("ocddir:","dicopr",ocdnumstring,".dat")
   SET fullpath = build(path,"dicopr",ocdnumstring,".dat")
  ELSE
   IF (source_ind=3)
    SET minidic = concat("ocddir:","backupccl.dat")
    SET fullpath = build(path,"backupccl.dat")
   ELSE
    SET minidic = concat("ocddir:","tempccl.dat")
    SET fullpath = build(path,"tempccl.dat")
   ENDIF
  ENDIF
 ENDIF
 FREE SET fstat
 SET fstat = findfile(minidic)
 IF (fstat=0)
  SET reply->ops_event = substring(1,100,concat("The mini-dictionary does not exist at ",trim(minidic
     ),"."))
  GO TO exit_script
 ENDIF
 FREE DEFINE dicocd
 FREE SET minidictionary
 SET minidictionary = minidic
 DEFINE dicocd value(minidictionary)
 SELECT INTO value(output_dest)
  dp.object, dp.object_name, dp.app_major_version,
  dp.app_minor_version, dc.object, dc.object_name,
  dc.qual, dp.datestamp, dp.timestamp
  FROM dcompileocd dc,
   dprotectocd dp
  PLAN (dp)
   JOIN (dc
   WHERE dp.platform=dc.platform
    AND dp.object=dc.object
    AND dp.object_name=dc.object_name
    AND dp.group=dc.group)
  ORDER BY dp.object, dp.object_name, dc.qual
  HEAD REPORT
   rline = fillstring(120,"="), row 1,
   CALL center("Objects Currently in the Mini Dictionary",0,79),
   row + 1,
   CALL center(trim(fullpath),0,79), row + 1,
   rdate = format(curdate,"mmm-dd-yyyy;;d"), rtime = format(curtime,"hh:mm;;m"),
   CALL center(concat(rdate,"  ",rtime),0,79),
   row + 2, col 0, "Type",
   col 10, "Object Name", col 45,
   "Date", col 56, "Time",
   col 65, "       Rev", col 80,
   "       OCD", col 95, "Begin Qual",
   col 110, "  End Qual", row + 1,
   col 0, rline, row + 2
  HEAD dp.object_name
   object_name = fillstring(32," "), object_name = concat(" ",dp.object_name), col 0,
   dp.object, col 10, object_name,
   col 45, dp.datestamp"mm/dd/yyyy;;d", col 56,
   dp.timestamp"hh:mm:ss;2;m", col 65, dp.app_major_version,
   col 80, dp.app_minor_version, col 95,
   dc.qual
  DETAIL
   row + 0
  FOOT  dp.object_name
   col 110, dc.qual, row + 1
  FOOT REPORT
   row + 1,
   CALL center("******** End Report ********",0,79)
  WITH outerjoin = dp, noheading, noformfeed,
   nullreport, format = stream
 ;end select
 FREE DEFINE dicocd
 SET errorcode = error(errmsg,0)
 IF (errorcode != 0)
  SET reply->ops_event = substring(1,100,concat("CCL error displaying contents of ",trim(minidic),"."
    ))
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
 SET reply->ops_event = "CCLOCDView Successful"
#exit_script
 CALL echo(concat("***Status: ",trim(reply->status_data.status)))
 CALL echo(concat("***Text: ",trim(reply->ops_event)))
 CALL echo("***")
END GO
