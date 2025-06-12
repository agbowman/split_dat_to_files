CREATE PROGRAM bed_ens_phys_exp_history:dba
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
 DECLARE requestcount = i4 WITH constant(size(request->histories,5))
 IF (requestcount=0)
  GO TO exit_script
 ENDIF
 INSERT  FROM (dummyt d  WITH seq = value(requestcount)),
   br_phys_exper_history br
  SET br.br_phys_exper_history_id = seq(bedrock_seq,nextval), br.new_value = request->histories[d.seq
   ].new_value, br.position_cd = request->histories[d.seq].position_code_value,
   br.preference_name = request->histories[d.seq].preference_name, br.previous_value = request->
   histories[d.seq].previous_value, br.topic_name = request->histories[d.seq].topic_name,
   br.transaction_dt_tm = cnvtdatetime(request->histories[d.seq].transaction_dt_tm), br.updt_applctx
    = reqinfo->updt_applctx, br.updt_cnt = 0,
   br.updt_dt_tm = cnvtdatetime(curdate,curtime3), br.updt_id = reqinfo->updt_id, br.updt_task =
   reqinfo->updt_task
  PLAN (d)
   JOIN (br)
  WITH nocounter
 ;end insert
 CALL bederrorcheck("Erroring ensuring to br_phys_exper_history")
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
