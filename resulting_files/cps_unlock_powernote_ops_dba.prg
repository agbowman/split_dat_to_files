CREATE PROGRAM cps_unlock_powernote_ops:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD aud_request(
   1 audit_list[*]
     2 scd_story_id = f8
     2 event_type = c12
     2 event_name = c12
     2 event_message = c255
     2 event_dt_tm = dq8
     2 event_entity_id = f8
     2 event_entity_name = c30
     2 event_enum = i4
     2 person_id = f8
     2 encntr_id = f8
 )
 SET reply->status_data.status = "F"
 DECLARE hr_look_back = i4 WITH protect, noconstant(72)
 DECLARE hr_cnt = i4 WITH protect, noconstant(0)
 DECLARE stat_cnt = i2 WITH protect, noconstant(0)
 DECLARE storycnt = i4 WITH protect, noconstant(0)
 DECLARE unlockmsg = vc WITH protect, noconstant("")
 DECLARE debug_data = i2 WITH protect, noconstant(0)
 DECLARE pipepos = i4 WITH protect, noconstant(0)
 DECLARE hr_len = i4 WITH protect, noconstant(0)
 DECLARE storyupdcnt = i4 WITH protect, noconstant(0)
 DECLARE ppaudinscnt = i4 WITH protect, noconstant(0)
 IF (validate(request->debug_ind,0))
  CALL echo("Turning Debug On")
  SET debug_data = 1
 ENDIF
 IF ( NOT (validate(request->batch_selection)))
  SET reply->status_data.status = "F"
  SET stat_cnt = (stat_cnt+ 1)
  SET stat = alter(reply->status_data.subeventstatus,stat_cnt)
  SET reply->status_data.subeventstatus[stat_cnt].operationname = "VALIDATE"
  SET reply->status_data.subeventstatus[stat_cnt].operationstatus = "F"
  SET reply->status_data.subeventstatus[stat_cnt].targetobjectname = "REQUEST"
  SET reply->status_data.subeventstatus[stat_cnt].targetobjectvalue =
  "Batch_selection has not been defined."
  CALL echo("Batch_selection has not been defined.")
  GO TO general_failure
 ENDIF
 CALL echorecord(request)
 SET total_len = size(trim(request->batch_selection))
 IF (total_len=0)
  SET reply->status_data.status = "F"
  SET stat_cnt = (stat_cnt+ 1)
  SET stat = alter(reply->status_data.subeventstatus,stat_cnt)
  SET reply->status_data.subeventstatus[stat_cnt].operationname = "PARSE"
  SET reply->status_data.subeventstatus[stat_cnt].operationstatus = "F"
  SET reply->status_data.subeventstatus[stat_cnt].targetobjectname = "REQUEST"
  SET reply->status_data.subeventstatus[stat_cnt].targetobjectvalue = "Missing the batch_selection"
  CALL echo("Missing the batch_selection")
  GO TO general_failure
 ENDIF
 SET pipepos = findstring("|",request->batch_selection)
 IF (pipepos=0)
  SET reply->status_data.status = "F"
  SET stat_cnt = (stat_cnt+ 1)
  SET stat = alter(reply->status_data.subeventstatus,stat_cnt)
  SET reply->status_data.subeventstatus[stat_cnt].operationname = "PARSE"
  SET reply->status_data.subeventstatus[stat_cnt].operationstatus = "F"
  SET reply->status_data.subeventstatus[stat_cnt].targetobjectname = "REQUEST"
  SET reply->status_data.subeventstatus[stat_cnt].targetobjectvalue = "Could not find the pipe"
  CALL echo("Could not find the pipe")
  GO TO general_failure
 ENDIF
 CALL echo(build("Pipe Position = ",pipepos))
 SET hr_len = (total_len - pipepos)
 CALL echo(build("number of characters in the hours position = ",hr_len))
 FOR (x = 1 TO hr_len)
   IF ( NOT (substring((x+ pipepos),1,request->batch_selection) IN ("1", "2", "3", "4", "5",
   "6", "7", "8", "9", "0")))
    SET reply->status_data.status = "F"
    SET stat_cnt = (stat_cnt+ 1)
    SET stat = alter(reply->status_data.subeventstatus,stat_cnt)
    SET reply->status_data.subeventstatus[stat_cnt].operationname = "PARSE"
    SET reply->status_data.subeventstatus[stat_cnt].operationstatus = "F"
    SET reply->status_data.subeventstatus[stat_cnt].targetobjectname = "REQUEST"
    SET reply->status_data.subeventstatus[stat_cnt].targetobjectvalue =
    "Invalid data in batch selection"
    CALL echo("Invalid data in batch selection")
    GO TO general_failure
   ELSE
    SET hr_cnt = (hr_cnt+ 1)
   ENDIF
 ENDFOR
 CALL echo(build("hr_cnt = ",hr_cnt))
 SET hr_look_back = cnvtint(substring((pipepos+ 1),hr_cnt,request->batch_selection))
 CALL echo(build("hr_look_back =",hr_look_back))
 IF (hr_look_back=0)
  SET reply->status_data.status = "F"
  SET stat_cnt = (stat_cnt+ 1)
  SET stat = alter(reply->status_data.subeventstatus,stat_cnt)
  SET reply->status_data.subeventstatus[stat_cnt].operationname = "PARSE"
  SET reply->status_data.subeventstatus[stat_cnt].operationstatus = "F"
  SET reply->status_data.subeventstatus[stat_cnt].targetobjectname = "REQUEST"
  SET reply->status_data.subeventstatus[stat_cnt].targetobjectvalue = "Missing the hr_look_back"
  CALL echo("Missing the hr_look_back")
  GO TO general_failure
 ELSEIF (hr_look_back < 3)
  SET hr_look_back = 3
 ENDIF
 CALL echo(build("actual hr_look_back =",hr_look_back))
 DECLARE str_hr_look_back = vc WITH noconstant(trim(cnvtstring(hr_look_back)))
 DECLARE chour = vc WITH constant(",H")
 DECLARE lockcomparetime = dq8 WITH protect, noconstant(cnvtlookbehind(build(str_hr_look_back,chour))
  )
 CALL echo(build("Look back time being used: ",format(lockcomparetime,";;q")))
 DECLARE ddoc = f8 WITH noconstant(uar_get_code_by("MEANING",15749,"DOC"))
 DECLARE ddictated = f8 WITH noconstant(uar_get_code_by("MEANING",15750,"DICTATED"))
 SELECT INTO "NL:"
  FROM scd_story scd
  PLAN (scd
   WHERE scd.story_type_cd=ddoc
    AND scd.story_completion_status_cd != ddictated
    AND scd.update_lock_user_id > 0.0
    AND scd.update_lock_dt_tm < cnvtdatetime(lockcomparetime)
    AND scd.update_lock_dt_tm > cnvtdatetime("01-JAN-2010 00:00")
    AND  NOT ( EXISTS (
   (SELECT
    lb.parent_entity_id
    FROM long_blob lb
    WHERE lb.parent_entity_id=scd.scd_story_id
     AND lb.parent_entity_name="SCD_STORY"))))
  ORDER BY scd.update_lock_dt_tm
  DETAIL
   storycnt = (storycnt+ 1), stat = alterlist(aud_request->audit_list,storycnt), aud_request->
   audit_list[storycnt].scd_story_id = scd.scd_story_id,
   aud_request->audit_list[storycnt].event_type = "CLINDOC", aud_request->audit_list[storycnt].
   event_name = "SCDUNLNOTE", unlockmsg =
   "This PowerNote was unlocked by ops via cps_unlock_powernote_ops. ",
   unlockmsg = concat(unlockmsg,"  STORY_ID = ",cnvtstring(scd.scd_story_id)), unlockmsg = concat(
    unlockmsg,", ORIG update_lock_dt_tm: ",format(scd.update_lock_dt_tm,";;q")), unlockmsg = concat(
    unlockmsg,", ORIG update_lock_user_id = ",cnvtstring(scd.update_lock_user_id)),
   unlockmsg = concat(unlockmsg,", Updated on: ",format(sysdate,";;q")), aud_request->audit_list[
   storycnt].event_message = unlockmsg, aud_request->audit_list[storycnt].event_dt_tm = scd
   .update_lock_dt_tm,
   aud_request->audit_list[storycnt].event_entity_id = scd.scd_story_id, aud_request->audit_list[
   storycnt].event_entity_name = "SCD_STORY", aud_request->audit_list[storycnt].event_enum = scd
   .update_lock_user_id,
   aud_request->audit_list[storycnt].person_id = scd.person_id, aud_request->audit_list[storycnt].
   encntr_id = scd.encounter_id
  WITH nocounter
 ;end select
 IF (debug_data=1)
  CALL echorecord(aud_request)
 ENDIF
 DECLARE notecnt = i4 WITH noconstant(size(aud_request->audit_list,5))
 CALL echo(build("Total notes to update:",notecnt))
 IF (notecnt > 0)
  UPDATE  FROM scd_story scd,
    (dummyt d1  WITH seq = value(notecnt))
   SET scd.update_lock_dt_tm = null, scd.update_lock_user_id = 0.0, scd.updt_dt_tm = sysdate,
    scd.updt_id = reqinfo->updt_id, scd.updt_task = reqinfo->updt_task, scd.updt_applctx = reqinfo->
    updt_applctx,
    scd.updt_cnt = (scd.updt_cnt+ 1)
   PLAN (d1)
    JOIN (scd
    WHERE (scd.scd_story_id=aud_request->audit_list[d1.seq].scd_story_id))
   WITH nocounter
  ;end update
  SET storyupdcnt = curqual
  CALL echo(build("number of rows to update = ",storyupdcnt))
  FOR (x = 1 TO notecnt)
   INSERT  FROM pp_audit_event pae
    SET pae.pp_audit_event_id = seq(carenet_seq,nextval), pae.event_type = aud_request->audit_list[x]
     .event_type, pae.event_name = aud_request->audit_list[x].event_name,
     pae.event_message = aud_request->audit_list[x].event_message, pae.event_dt_tm = cnvtdatetime(
      aud_request->audit_list[x].event_dt_tm), pae.event_entity_id = aud_request->audit_list[x].
     event_entity_id,
     pae.event_entity_name = aud_request->audit_list[x].event_entity_name, pae.event_enum =
     aud_request->audit_list[x].event_enum, pae.person_id = aud_request->audit_list[x].person_id,
     pae.encntr_id = aud_request->audit_list[x].encntr_id, pae.user_id = reqinfo->updt_id, pae
     .app_nbr = reqinfo->updt_app,
     pae.updt_dt_tm = sysdate, pae.updt_task = reqinfo->updt_task, pae.updt_applctx = reqinfo->
     updt_applctx,
     pae.updt_id = reqinfo->updt_id
    WITH nocounter
   ;end insert
   SET ppaudinscnt = (ppaudinscnt+ curqual)
  ENDFOR
  CALL echo(build("number of rows to insert = ",ppaudinscnt))
  IF (ppaudinscnt=storyupdcnt)
   COMMIT
   CALL echo("Updating and Inserting Complete")
   SET stat_cnt = (stat_cnt+ 1)
   SET stat = alter(reply->status_data.subeventstatus,stat_cnt)
   SET reply->status_data.subeventstatus[stat_cnt].operationname = "UPDATE"
   SET reply->status_data.subeventstatus[stat_cnt].operationstatus = "S"
   SET reply->status_data.subeventstatus[stat_cnt].targetobjectname = "SCD_STORY"
   SET reply->status_data.subeventstatus[stat_cnt].targetobjectvalue = "update and insert success."
   GO TO success
  ELSE
   ROLLBACK
   SET stat_cnt = (stat_cnt+ 1)
   SET stat = alter(reply->status_data.subeventstatus,stat_cnt)
   SET reply->status_data.subeventstatus[stat_cnt].operationname = "ADD"
   SET reply->status_data.subeventstatus[stat_cnt].operationstatus = "F"
   SET reply->status_data.subeventstatus[stat_cnt].targetobjectname = "pp_audit_event"
   SET reply->status_data.subeventstatus[stat_cnt].targetobjectvalue = "update vs insert difference."
   CALL echo("update vs insert difference..")
   GO TO general_failure
  ENDIF
 ELSE
  SET stat_cnt = (stat_cnt+ 1)
  SET stat = alter(reply->status_data.subeventstatus,stat_cnt)
  SET reply->status_data.subeventstatus[stat_cnt].operationname = "UPDATE"
  SET reply->status_data.subeventstatus[stat_cnt].operationstatus = "S"
  SET reply->status_data.subeventstatus[stat_cnt].targetobjectname = "No Update Needed"
  SET reply->status_data.subeventstatus[stat_cnt].targetobjectvalue =
  "There are no locked notes within params"
  GO TO success
 ENDIF
#general_failure
 SET reply->status_data.status = "F"
 CALL echorecord(request)
 CALL echorecord(aud_request)
 CALL echorecord(reply)
 CALL echo("General Failure")
 GO TO exit_script
#success
 SET reply->status_data.status = "S"
 CALL echo("Success!")
 GO TO exit_script
#exit_script
 CALL echorecord(reply)
 CALL echo("The script is complete.")
END GO
