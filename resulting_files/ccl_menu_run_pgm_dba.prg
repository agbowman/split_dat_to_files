CREATE PROGRAM ccl_menu_run_pgm:dba
 FREE SET reply
 RECORD reply(
   1 pgm_complete = vc
   1 qual[*]
     2 new_line = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET xyz_no_parameters = size(request->qual,5)
 SET xyz_cntr = 0
 SET xyz_output = "N"
 SET xyz_output1 = fillstring(100," ")
 SET xyz_output2 = fillstring(1000," ")
 SET xyz_parameter = fillstring(100," ")
 SET xyz_command1 = fillstring(1000," ")
 SET xyz_charx = fillstring(100," ")
 SET xyz_errmsg = fillstring(255," ")
 SET xyz_pgm_complete = fillstring(20," ")
 SET xyz_formfeed = char(12)
 SET group = 0
 SELECT INTO "nl:"
  grp = p.group
  FROM dprotect p
  WHERE p.object="P"
   AND p.object_name=value(cnvtupper(request->program_name))
  ORDER BY p.group
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt += 1
   IF (cnt=1)
    group = p.group
   ENDIF
  WITH nocounter, maxqual(p,1)
 ;end select
 IF (group=0)
  SET xyz_command1 = cnvtlower(concat("execute ",trim(request->program_name)," "))
 ELSE
  SET groupnum = build("GROUP",floor(group))
  SET xyz_command1 = cnvtlower(concat("execute ",trim(request->program_name),":",groupnum," "))
 ENDIF
 SET xyz_output1 = cnvtlower(build("cer_temp:mnu",curuser,curtime2))
 FOR (x = 1 TO xyz_no_parameters)
   SET xyz_parameter = fillstring(100," ")
   SET xyz_charx = request->qual[x].parameter
   IF (x > 1)
    SET xyz_command1 = concat(trim(xyz_command1),", ")
   ENDIF
   IF ((request->qual[x].data_type="O")
    AND xyz_charx="MINE")
    SET xyz_parameter = build(" VALUE('",xyz_output1,"')")
    SET xyz_output = "Y"
   ELSEIF ((request->qual[x].data_type IN ("O", "C")))
    SET xyz_parameter = build(" VALUE('",xyz_charx,"')")
   ELSEIF ((request->qual[x].data_type="N"))
    SET xyz_parameter = build(" VALUE(",request->qual[x].parameter,")")
   ENDIF
   SET xyz_command1 = concat(trim(xyz_command1),trim(xyz_parameter))
 ENDFOR
 SET xyz_command1 = concat(trim(xyz_command1)," go")
 CALL echo(concat("xyz_COMMAND1:",xyz_command1),1,10)
 CALL echo(build("file_loc: ",value(build(xyz_output1,".DAT"))),1,10)
 SET reply->pgm_complete = xyz_command1
 IF (trim(xyz_output)="Y")
  CALL parser(xyz_command1)
  FREE DEFINE rtl2
  FREE SET file_loc
  SET logical file_loc value(build(xyz_output1,".DAT"))
  DEFINE rtl2 "file_loc"
  SELECT INTO "nl:"
   *
   FROM rtl2t
   WITH nocounter, maxrec = 1
  ;end select
  IF (curqual > 0)
   SELECT INTO "nl:"
    new_line = r.line
    FROM rtl2t r
    HEAD REPORT
     stat = alterlist(reply->qual,10), xyz_cntr = 0
    DETAIL
     xyz_cntr += 1
     IF (mod(xyz_cntr,10)=1
      AND xyz_cntr != 1)
      stat = alterlist(reply->qual,(xyz_cntr+ 9))
     ENDIF
     reply->qual[xyz_cntr].new_line = trim(new_line)
    FOOT REPORT
     reply->status_data.status = "S", stat = alterlist(reply->qual,xyz_cntr)
    WITH nocounter
   ;end select
  ELSE
   SET reply->pgm_complete = "Nothing Qualified"
   SET xyz_pgm_complete = "Error"
   SET stat = alterlist(reply->qual,1)
  ENDIF
 ELSE
  CALL parser(xyz_command1)
  SET reply->pgm_complete = "Program is printing !"
  SET reply->status_data.status = "S"
  SET stat = alterlist(reply->qual,1)
 ENDIF
 CALL echo(concat("reply->pgm_complete:",reply->pgm_complete),1,10)
 CALL echo(build("xyz_cntr:",xyz_cntr),1,10)
 FOR (x = 1 TO xyz_cntr)
   CALL echo(reply->qual[x].new_line,1,10)
 ENDFOR
 IF (((curqual > 0) OR (xyz_pgm_complete="Error")) )
  SET reply->status_data.status = "S"
  SET failed = "F"
  GO TO exit_script
 ELSE
  SET errcode = error(xyz_errmsg,1)
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[0].operationname = "run pgm"
  SET reply->status_data.subeventstatus[0].operationstatus = "F"
  SET reply->status_data.subeventstatus[0].targetobjectname = "ccl_menu_run_pgm"
  SET reply->status_data.subeventstatus[0].targetobjectvalue = xyz_errmsg
  SET reqinfo->commit_ind = 0
  GO TO endit
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  GO TO endit
 ENDIF
#endit
END GO
