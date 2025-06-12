CREATE PROGRAM bed_ens_assay_match:dba
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
 )
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET cnt = 0
 DECLARE event_code = vc
 SET cnt = size(request->assays,5)
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO cnt)
   SET event_code = " "
   SET match_cd = 0.0
   SELECT INTO "nl:"
    FROM br_dta_work b
    PLAN (b
     WHERE (b.dta_id=request->assays[x].id))
    DETAIL
     event_code = b.org_event_code, match_cd = b.match_dta_cd
    WITH nocounter
   ;end select
   IF (event_code > " ")
    SET ierrcode = 0
    UPDATE  FROM br_dta_work b
     SET b.match_dta_cd = request->assays[x].code_value, b.updt_id = reqinfo->updt_id, b.updt_dt_tm
       = cnvtdatetime(curdate,curtime),
      b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = (b
      .updt_cnt+ 1),
      b.org_event_code =
      IF ((request->assays[x].code_value=0)) " "
      ELSE b.org_event_code
      ENDIF
     PLAN (b
      WHERE (b.dta_id=request->assays[x].id))
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = "Y"
     SET reply->error_msg = serrmsg
     GO TO exit_script
    ENDIF
   ELSE
    SET ierrcode = 0
    UPDATE  FROM br_dta_work b
     SET b.match_dta_cd = request->assays[x].code_value, b.updt_id = reqinfo->updt_id, b.updt_dt_tm
       = cnvtdatetime(curdate,curtime),
      b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = (b
      .updt_cnt+ 1),
      b.org_event_code = request->assays[x].event_name
     PLAN (b
      WHERE (b.dta_id=request->assays[x].id))
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = "Y"
     SET reply->error_msg = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (failed="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
