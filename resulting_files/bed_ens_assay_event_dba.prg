CREATE PROGRAM bed_ens_assay_event:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 duplicate_event_ind = i2
 )
 SET reply->status_data.status = "F"
 DECLARE event_code = vc
 SET failed = "N"
 SELECT INTO "nl:"
  FROM br_dta_work b
  PLAN (b
   WHERE (b.match_dta_cd=request->dta_code_value))
  DETAIL
   event_code = b.org_event_code
  WITH nocounter
 ;end select
 UPDATE  FROM br_dta_work b
  SET b.match_dta_cd = 0, b.updt_id = reqinfo->updt_id, b.updt_dt_tm = cnvtdatetime(curdate,curtime),
   b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = (b.updt_cnt
   + 1),
   b.org_event_code = " "
  PLAN (b
   WHERE (b.match_dta_cd=request->dta_code_value))
  WITH nocounter
 ;end update
 IF ((request->event_code_value > 0))
  IF (event_code > " ")
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=72
      AND cnvtupper(cv.display)=cnvtupper(event_code))
    DETAIL
     IF ((cv.code_value != request->event_code_value))
      reply->duplicate_event_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF ((reply->duplicate_event_ind=0))
    UPDATE  FROM code_value cv
     SET cv.display = event_code, cv.display_key = cnvtupper(cnvtalphanum(event_code)), cv
      .description = event_code,
      cv.definition = event_code, cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id =
      reqinfo->updt_id,
      cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt = (cv
      .updt_cnt+ 1)
     WHERE (cv.code_value=request->event_code_value)
     WITH nocounter
    ;end update
    UPDATE  FROM v500_event_code v
     SET v.event_cd_disp = event_code, v.event_cd_disp_key = cnvtupper(cnvtalphanum(event_code)), v
      .event_cd_descr = event_code,
      v.event_cd_definition = event_code, v.updt_dt_tm = cnvtdatetime(curdate,curtime3), v.updt_id =
      reqinfo->updt_id,
      v.updt_task = reqinfo->updt_task, v.updt_applctx = reqinfo->updt_applctx, v.updt_cnt = (v
      .updt_cnt+ 1)
     WHERE (v.event_cd=request->event_code_value)
     WITH nocounter
    ;end update
   ENDIF
  ENDIF
  DELETE  FROM code_value_event_r r
   WHERE (r.event_cd=request->event_code_value)
    AND (r.parent_cd=request->dta_code_value)
   WITH nocounter
  ;end delete
 ENDIF
#exit_script
 IF (failed="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
