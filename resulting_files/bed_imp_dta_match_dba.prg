CREATE PROGRAM bed_imp_dta_match:dba
 FREE SET reply
 RECORD reply(
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
 SET dta_id = 0.0
 SET task_assay_cd = 0.0
 SET cs_cnt = size(requestin->list_0,5)
 FOR (x = 1 TO cs_cnt)
   SET task_assay_cd = 0
   SET dta_id = 0
   SELECT INTO "NL:"
    FROM br_dta_work dta
    WHERE (dta.alias=requestin->list_0[x].event_code_alias)
    DETAIL
     dta_id = dta.dta_id
    WITH nocounter
   ;end select
   IF (dta_id > 0)
    SELECT INTO "NL:"
     FROM discrete_task_assay dta
     WHERE dta.active_ind=1
      AND (dta.mnemonic=requestin->list_0[x].task_assay)
     DETAIL
      task_assay_cd = dta.task_assay_cd
     WITH nocounter
    ;end select
    IF (task_assay_cd > 0)
     UPDATE  FROM br_dta_work dta
      SET dta.match_dta_cd = task_assay_cd, dta.org_event_code = trim(requestin->list_0[x].event_code
        ), dta.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       dta.updt_cnt = (dta.updt_cnt+ 1)
      WHERE dta.dta_id=dta_id
     ;end update
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Unable to insert ",requestin->list_0[x].task_assay,
       " into br_dta_work table.")
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
