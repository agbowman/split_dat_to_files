CREATE PROGRAM bed_ens_epcs_details:dba
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
 RECORD tempupdatenominator(
   1 details[*]
     2 detail_id = f8
     2 nominator_id = f8
 )
 RECORD tempupdatesignature(
   1 details[*]
     2 detail_id = f8
     2 signature_txt = vc
 )
 RECORD tempdeletedetails(
   1 details[*]
     2 detail_id = f8
 )
 DECLARE updatenominatorcount = i4
 DECLARE updatesignaturecount = i4
 DECLARE deletecount = i4
 DECLARE detailid = f8
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
 FOR (i = 1 TO size(request->details,5))
  SET detailid = request->details[i].detail_id
  IF ((request->details[i].action_flag=0))
   IF ((request->details[i].nominator.action_flag=2))
    SET updatenominatorcount = (updatenominatorcount+ 1)
    SET stat = alterlist(tempupdatenominator->details,updatenominatorcount)
    SET tempupdatenominator->details[updatenominatorcount].detail_id = detailid
    SET tempupdatenominator->details[updatenominatorcount].nominator_id = request->details[i].
    nominator.nominator_id
   ENDIF
   IF ((request->details[i].signature.action_flag=2))
    SET updatesignaturecount = (updatesignaturecount+ 1)
    SET stat = alterlist(tempupdatesignature->details,updatesignaturecount)
    SET tempupdatesignature->details[updatesignaturecount].detail_id = detailid
    SET tempupdatesignature->details[updatesignaturecount].signature_txt = request->details[i].
    signature.signature_txt
   ENDIF
  ELSEIF ((request->details[i].action_flag=3))
   SET deletecount = (deletecount+ 1)
   SET stat = alterlist(tempdeletedetails->details,deletecount)
   SET tempdeletedetails->details[deletecount].detail_id = request->details[i].detail_id
  ENDIF
 ENDFOR
 IF (deletecount > 0)
  UPDATE  FROM eprescribe_detail ed,
    (dummyt d  WITH seq = deletecount)
   SET ed.cs_approver_sig_txt = " ", ed.cs_nominator_id = 0.0, ed.updt_cnt = (ed.updt_cnt+ 1),
    ed.updt_applctx = reqinfo->updt_applctx, ed.updt_dt_tm = cnvtdatetime(curdate,curtime3), ed
    .updt_id = reqinfo->updt_id,
    ed.updt_task = reqinfo->updt_task
   PLAN (d)
    JOIN (ed
    WHERE (ed.eprescribe_detail_id=tempdeletedetails->details[d.seq].detail_id))
   WITH nocounter
  ;end update
  CALL bederrorcheck("Error revoking the approver and nominator")
 ENDIF
 IF (updatenominatorcount > 0)
  UPDATE  FROM eprescribe_detail ed,
    (dummyt d  WITH seq = updatenominatorcount)
   SET ed.cs_nominator_id = tempupdatenominator->details[d.seq].nominator_id, ed.updt_cnt = (ed
    .updt_cnt+ 1), ed.updt_applctx = reqinfo->updt_applctx,
    ed.updt_dt_tm = cnvtdatetime(curdate,curtime3), ed.updt_id = reqinfo->updt_id, ed.updt_task =
    reqinfo->updt_task
   PLAN (d)
    JOIN (ed
    WHERE (ed.eprescribe_detail_id=tempupdatenominator->details[d.seq].detail_id))
   WITH nocounter
  ;end update
  CALL bederrorcheck("Error updating the nominator id.")
 ENDIF
 IF (updatesignaturecount > 0)
  UPDATE  FROM eprescribe_detail ed,
    (dummyt d  WITH seq = updatesignaturecount)
   SET ed.cs_approver_sig_txt = tempupdatesignature->details[d.seq].signature_txt, ed.updt_cnt = (ed
    .updt_cnt+ 1), ed.updt_applctx = reqinfo->updt_applctx,
    ed.updt_dt_tm = cnvtdatetime(curdate,curtime3), ed.updt_id = reqinfo->updt_id, ed.updt_task =
    reqinfo->updt_task
   PLAN (d)
    JOIN (ed
    WHERE (ed.eprescribe_detail_id=tempupdatesignature->details[d.seq].detail_id))
   WITH nocounter
  ;end update
  CALL bederrorcheck("Error updating the signature text.")
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
