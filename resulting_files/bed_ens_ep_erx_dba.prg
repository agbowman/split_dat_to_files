CREATE PROGRAM bed_ens_ep_erx:dba
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
 SET providercount = size(request->providers,5)
 IF (providercount=0)
  GO TO exit_script
 ENDIF
 UPDATE  FROM br_eligible_provider bep,
   (dummyt d  WITH seq = providercount)
  SET bep.erx_submission_ind = request->providers[d.seq].erx_submission_ind, bep.updt_cnt = (bep
   .updt_cnt+ 1), bep.updt_applctx = reqinfo->updt_applctx,
   bep.updt_dt_tm = cnvtdatetime(curdate,curtime3), bep.updt_id = reqinfo->updt_id, bep.updt_task =
   reqinfo->updt_task
  PLAN (d)
   JOIN (bep
   WHERE (bep.br_eligible_provider_id=request->providers[d.seq].eligible_provider_id))
  WITH nocounter
 ;end update
 CALL bederrorcheck("Error updating br_eligible_provider.")
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
