CREATE PROGRAM bed_ens_conversation_fields:dba
 FREE SET reply
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
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET fcnt = 0
 SET fcnt = size(request->fields,5)
 FOR (f = 1 TO fcnt)
   IF ((request->fields[f].action_flag=2))
    UPDATE  FROM pm_flx_prompt pfp
     SET pfp.label = request->fields[f].label, pfp.required_ind = request->fields[f].required_ind,
      pfp.display_only_ind = request->fields[f].display_only_ind,
      pfp.updt_cnt = (pfp.updt_cnt+ 1), pfp.updt_dt_tm = cnvtdatetime(curdate,curtime3), pfp.updt_id
       = reqinfo->updt_id,
      pfp.updt_task = reqinfo->updt_task, pfp.updt_applctx = reqinfo->updt_applctx
     WHERE (pfp.prompt_id=request->fields[f].id)
     WITH nocounter
    ;end update
    CALL bederrorcheck("Failed Field Update")
   ELSEIF ((request->fields[f].action_flag=3))
    SET seq_nbr = 0
    SET conv_id = 0.0
    SELECT INTO "NL:"
     FROM pm_flx_prompt pfp
     WHERE (pfp.prompt_id=request->fields[f].id)
     DETAIL
      seq_nbr = pfp.sequence, conv_id = pfp.parent_entity_id
     WITH nocounter
    ;end select
    CALL bederrorcheck("Failed Sequence Get")
    DELETE  FROM pm_flx_prompt pfp
     WHERE (pfp.prompt_id=request->fields[f].id)
     WITH nocounter
    ;end delete
    CALL bederrorcheck("Failed Field Delete")
    UPDATE  FROM pm_flx_prompt pfp
     SET pfp.sequence = (pfp.sequence - 1), pfp.updt_cnt = (pfp.updt_cnt+ 1), pfp.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      pfp.updt_id = reqinfo->updt_id, pfp.updt_task = reqinfo->updt_task, pfp.updt_applctx = reqinfo
      ->updt_applctx
     WHERE pfp.parent_entity_name="PM_FLX_CONVERSATION"
      AND pfp.parent_entity_id=conv_id
      AND pfp.sequence > seq_nbr
     WITH nocounter
    ;end update
    CALL bederrorcheck("Failed Sequence Update")
   ENDIF
 ENDFOR
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
