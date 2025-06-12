CREATE PROGRAM bed_ens_eces_ord_code_reltn:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 error_msg = vc
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 DECLARE dta_ind = i2
 SET cnt = size(request->relationships,5)
 FOR (x = 1 TO cnt)
   DELETE  FROM code_value_event_r c
    WHERE (c.event_cd=request->relationships[x].event_code_value)
     AND (c.parent_cd=request->relationships[x].assay_code_value)
    WITH nocounter
   ;end delete
   IF (curqual=0)
    SET error_flag = "Y"
    SET reply->error_msg = build2("Unable to delete ",request->relationships[x].event_code_value,
     " from code_value_event_r table.")
    GO TO exit_script
   ENDIF
   SET dta_ind = 0
   SELECT INTO "nl"
    FROM code_value cv
    WHERE (cv.code_value=request->relationships[x].assay_code_value)
     AND cv.code_set=14003
    DETAIL
     dta_ind = 1
    WITH nocounter
   ;end select
   IF (dta_ind=1)
    UPDATE  FROM discrete_task_assay dta
     SET dta.event_cd = 0.0, dta.updt_applctx = reqinfo->updt_applctx, dta.updt_cnt = (dta.updt_cnt+
      1),
      dta.updt_dt_tm = cnvtdatetime(curdate,curtime3), dta.updt_id = reqinfo->updt_id, dta.updt_task
       = reqinfo->updt_task
     WHERE (dta.task_assay_cd=request->relationships[x].assay_code_value)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET reply->error_msg = build2("Unable to remove event_cd ",request->relationships[x].
      event_code_value," from discrete_task_assay table.")
     GO TO exit_script
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
