CREATE PROGRAM ct_del_log_checklist:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD chg_questions_req(
   1 questions[*]
     2 prot_elig_quest_id = f8
     2 question = vc
     2 desired_value = c1
     2 answer_format_id = f8
     2 elig_quest_nbr = i4
     2 value_required_flag = i2
     2 date_required_flag = i2
     2 long_text_id = f8
     2 delete_ind = i2
 ) WITH protect
 RECORD chg_questions_rep(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 RECORD chg_checklist_req(
   1 prot_amendment_id = f8
   1 prot_questionnaire_id = f8
   1 questionnaire_type_cd = f8
   1 questionnaire_name = vc
   1 special_inst_text = vc
   1 desc_text = vc
   1 delete_ind = i2
 ) WITH protect
 RECORD chg_checklist_rep(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE lock_error = i2 WITH private, constant(1)
 DECLARE update_error = i2 WITH private, constant(2)
 DECLARE insert_error = i2 WITH private, constant(3)
 DECLARE exe_error = i2 WITH private, constant(3)
 DECLARE script_date = f8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE fail_flag = i2 WITH protect, noconstant(0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE cnt = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 IF ((request->prot_questionnaire_id > 0))
  SELECT INTO "nl:"
   peq.prot_elig_quest_id
   FROM prot_elig_quest peq
   WHERE (peq.prot_questionnaire_id=request->prot_questionnaire_id)
    AND peq.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
   HEAD peq.prot_questionnaire_id
    cnt = 0,
    CALL echo(build("peq.prot_questionnaire_id = ",peq.prot_questionnaire_id))
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(chg_questions_req->questions,(cnt+ 9))
    ENDIF
    chg_questions_req->questions[cnt].prot_elig_quest_id = peq.prot_elig_quest_id, chg_questions_req
    ->questions[cnt].delete_ind = 1
   FOOT  peq.prot_questionnaire_id
    stat = alterlist(chg_questions_req->questions,cnt)
   WITH nocounter
  ;end select
  EXECUTE ct_chg_questions  WITH replace("REQUEST","CHG_QUESTIONS_REQ"), replace("REPLY",
   "CHG_QUESTIONS_REP")
  CALL echorecord(chg_questions_req)
  CALL echorecord(chg_questions_rep)
  IF ((chg_questions_rep->status_data.status != "S"))
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error logically deleted from  prot_elig_quest table."
   SET fail_flag = lock_error
   GO TO check_error
  ENDIF
  SET chg_checklist_req->prot_questionnaire_id = request->prot_questionnaire_id
  SET chg_checklist_req->delete_ind = 1
  EXECUTE ct_chg_checklist  WITH replace("REQUEST","CHG_CHECKLIST_REQ"), replace("REPLY",
   "CHG_CHECKLIST_REP")
  IF ((chg_checklist_rep->status_data.status != "S"))
   SET fail_flag exe_error moverec(chg_checklist_rep->status_data.subeventstatus[1],reply->
    status_data.subeventstatus[1])
   GO TO check_error
  ENDIF
 ENDIF
#check_error
 IF (fail_flag=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  SET reply->status_data.subeventstatus[1].operationname = ""
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectname = ""
  SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
 ELSE
  CALL echo("fail_flag != 0")
  CASE (fail_flag)
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
   OF lock_error:
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
    SET reply->status_data.subeventstatus[1].operationstatus = "L"
   OF exe_error:
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
    SET reply->status_data.subeventstatus[1].operationstatus = "L"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Unknown error."
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
  ENDCASE
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reqinfo->commit_ind = 0
 ENDIF
 FREE RECORD ins_prot_elig_quest
 FREE RECORD ins_prot_questionnaire
 SET last_mod = "000"
 SET mod_date = "August 9, 2007"
END GO
