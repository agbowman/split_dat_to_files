CREATE PROGRAM br_upd_lighthouse_ccn:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 UPDATE  FROM br_client_item_reltn bcir
  SET bcir.item_display = "CCN and Eligible Provider Setup", bcir.updt_dt_tm = cnvtdatetime(curdate,
    curtime), bcir.updt_id = reqinfo->updt_id,
   bcir.updt_task = reqinfo->updt_task, bcir.updt_applctx = reqinfo->updt_applctx, bcir.updt_cnt = (
   bcir.updt_cnt+ 1)
  WHERE bcir.item_mean="LIGHTREPORTSCCN"
  WITH nocounter
 ;end update
 CALL bederrorcheck("Failed updating name in br_client_item_reltn table.")
 UPDATE  FROM br_step brs
  SET brs.step_disp = "CCN and Eligible Provider Setup", brs.updt_dt_tm = cnvtdatetime(curdate,
    curtime), brs.updt_id = reqinfo->updt_id,
   brs.updt_task = reqinfo->updt_task, brs.updt_applctx = reqinfo->updt_applctx, brs.updt_cnt = (brs
   .updt_cnt+ 1)
  WHERE brs.step_mean="LIGHTREPORTSCCN"
  WITH nocounter
 ;end update
 CALL bederrorcheck("Failed updating name in br_step table.")
 CALL bederrorcheck("Descriptive error message not provided.")
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
