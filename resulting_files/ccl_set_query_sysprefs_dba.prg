CREATE PROGRAM ccl_set_query_sysprefs:dba
 PROMPT
  "Enter output device for summary (screen/file/printer): " = mine,
  "Enter maximum allowed timeout to apply to Discern queries (300 seconds): " = "300",
  "Enter default timeout to apply to ad-hoc queries (15 seconds):  " = "100"
 RECORD upd_request(
   1 application_number = i4
   1 position_cd = f8
   1 prsnl_id = f8
   1 nv[3]
     2 pvc_name = c32
     2 pvc_value = vc
     2 sequence = i4
     2 merge_id = f8
     2 merge_name = vc
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD upd_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE smaxtimeout = vc
 DECLARE sdefaulttimeout = vc
 DECLARE errmsg = c255
 DECLARE bisdba = i2
 SET smaxtimeout = trim(cnvtupper( $2))
 SET sdefaulttimeout = trim(cnvtupper( $3))
 IF (((isnumeric(smaxtimeout) != 1) OR (cnvtint(smaxtimeout) <= 0)) )
  CALL echo(concat(char(10),"The maximum timeout value entered: ",smaxtimeout,
    " is invalid. Please specify a valid number."))
  GO TO end_script
 ENDIF
 IF (cnvtint(smaxtimeout) < 15)
  CALL echo(concat(char(10),
    "The maximum timeout value must be 15 seconds or higher. Please re-enter."))
  GO TO end_script
 ENDIF
 IF (((isnumeric(sdefaulttimeout) != 1) OR (cnvtint(sdefaulttimeout) <= 0)) )
  CALL echo(concat(char(10),"The default timeout value entered: ",sdefaulttimeout,
    " is invalid. Please specify a valid number."))
  GO TO end_script
 ENDIF
 SET bisdba = 0
 SELECT INTO "NL:"
  p.username, position = uar_get_code_meaning(p.position_cd)
  FROM prsnl p
  WHERE p.username=trim(curuser)
  DETAIL
   IF (trim(position)="DBA")
    bisdba = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (bisdba=0)
  CALL echo(concat(char(10),"Failed to update system query preferences! User must be a DBA."))
  GO TO end_script
 ENDIF
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET errmsg = fillstring(255," ")
 SET upd_request->application_number = 3050000
 SET upd_request->position_cd = 0
 FOR (i = 1 TO 2)
   SET upd_request->nv[i].sequence = 0
   SET upd_request->nv[i].merge_id = 0
   SET upd_request->nv[i].merge_name = ""
 ENDFOR
 SET upd_request->nv[1].pvc_name = "CCL_QUERY_MAXTIMEOUT"
 SET upd_request->nv[1].pvc_value = smaxtimeout
 SET upd_request->nv[2].pvc_name = "CCL_QUERY_DEFAULTTIMEOUT"
 SET upd_request->nv[2].pvc_value = sdefaulttimeout
 EXECUTE dcp_add_app_prefs  WITH replace("REQUEST","UPD_REQUEST"), replace("REPLY","UPD_REPLY")
 IF (curqual=0)
  SET errcode = error(errmsg,1)
  IF (errcode != 0)
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO  $1
  d.*
  FROM dummyt d
  HEAD REPORT
   col 0, "Discern Explorer Query domain-level preferences", row + 2,
   col 0, "Maximum allowed timeout in seconds to apply to Discern queries: ", smaxtimeout,
   row + 1, col 0, "Default timeout in seconds to apply to new Discern queries: ",
   sdefaulttimeout, row + 1
  WITH nocounter
 ;end select
#exit_script
 IF ((upd_reply->status_data.status="F"))
  CALL echo("Failed to update Discern query domain-level prefs!")
  SET reply->status_data.subeventstatus[1].operationname = "UPD"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "APP_PREFS"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
  SET reqinfo->commit_ind = 0
  ROLLBACK
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  COMMIT
 ENDIF
#end_script
END GO
