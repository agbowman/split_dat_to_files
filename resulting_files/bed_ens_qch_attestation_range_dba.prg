CREATE PROGRAM bed_ens_qch_attestation_range:dba
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
 DECLARE name_value_id = f8
 SELECT INTO "nl:"
  FROM br_name_value br
  PLAN (br
   WHERE br.br_nv_key1="QCH_ATTESTATION_DT_TM")
  DETAIL
   name_value_id = br.br_name_value_id
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error on ensure getting the QCH attestation date time range.")
 IF (name_value_id > 0)
  UPDATE  FROM br_name_value br
   SET br.br_value = format(request->attestation_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D"), br.updt_cnt = (br
    .updt_cnt+ 1), br.updt_applctx = reqinfo->updt_applctx,
    br.updt_dt_tm = cnvtdatetime(curdate,curtime3), br.updt_id = reqinfo->updt_id, br.updt_task =
    reqinfo->updt_task
   PLAN (br
    WHERE br.br_name_value_id=name_value_id)
   WITH nocounter
  ;end update
  CALL bederrorcheck(
   "Error on updating the br_name_value table with the QCH attestation date time range.")
 ELSE
  INSERT  FROM br_name_value br
   SET br.br_name_value_id = cnvtreal(seq(bedrock_seq,nextval)), br.br_nv_key1 =
    "QCH_ATTESTATION_DT_TM", br.br_value = format(request->attestation_dt_tm,
     "DD-MMM-YYYY HH:MM:SS;;D"),
    br.updt_cnt = 0, br.updt_applctx = reqinfo->updt_applctx, br.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    br.updt_id = reqinfo->updt_id, br.updt_task = reqinfo->updt_task
   PLAN (br)
   WITH nocounter
  ;end insert
  CALL bederrorcheck(
   "Error on inserting the br_name_value table with the QCH attestation date time range.")
 ENDIF
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
