CREATE PROGRAM bed_imp_dta_work_non:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 DECLARE error_msg = vc
 DECLARE activity_type = vc
 DECLARE result_type = vc
 DECLARE facility = vc
 SET dta_cnt = size(requestin->list_0,5)
 FOR (x = 1 TO dta_cnt)
   IF (validate(requestin->list_0[x].activity_type))
    SET activity_type = trim(requestin->list_0[x].activity_type)
   ELSE
    SET activity_type = " "
   ENDIF
   IF (validate(requestin->list_0[x].result_type))
    SET result_type = trim(requestin->list_0[x].activity_type)
   ELSE
    SET result_type = " "
   ENDIF
   IF (validate(requestin->list_0[x].facility) > 0)
    SET facility = trim(requestin->list_0[x].facility)
   ELSE
    SET facility = " "
   ENDIF
   UPDATE  FROM br_dta_work b
    SET b.long_desc = requestin->list_0[x].long_name, b.alias = requestin->list_0[x].alias, b
     .activity_type =
     IF (activity_type > " ") activity_type
     ELSE b.activity_type
     ENDIF
     ,
     b.result_type =
     IF (result_type > " ") result_type
     ELSE b.result_type
     ENDIF
     , b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
     b.updt_task = reqinfo->updt_task, b.updt_cnt = (b.updt_cnt+ 1), b.updt_applctx = reqinfo->
     updt_applctx
    WHERE cnvtupper(b.short_desc)=cnvtupper(requestin->list_0[x].short_name)
     AND cnvtupper(b.facility)=cnvtupper(facility)
   ;end update
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  CALL echo("**************************************************************")
  CALL echo("**************************************************************")
  CALL echo("*                                                            *")
  CALL echo("*               LEGACY DTA FILE IMPORTED SUCCESSFULLY        *")
  CALL echo("*                                                            *")
  CALL echo("**************************************************************")
  CALL echo("**************************************************************")
 ELSE
  CALL echo(error_msg)
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_IMP_DTA_WORK_NON","  >> ERROR MSG: ",
   error_msg)
  SET reqinfo->commit_ind = 0
  CALL echo("**************************************************************")
  CALL echo("**************************************************************")
  CALL echo("*                                                            *")
  CALL echo("*         	   LEGACY DTA FILE IMPORT HAS FAILED         *")
  CALL echo("*  Do not run additional imports, contact the BEDROCK team   *")
  CALL echo("*                                                            *")
  CALL echo("**************************************************************")
  CALL echo("**************************************************************")
 ENDIF
END GO
