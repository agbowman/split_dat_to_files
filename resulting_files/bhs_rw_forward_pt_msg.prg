CREATE PROGRAM bhs_rw_forward_pt_msg
 PROMPT
  "Enter PowerForm DCP_FORMS_ACTIVITY_ID (as string): " = " "
 SET retval = 0
 DECLARE log_message = vc WITH protect, noconstant(" ")
 IF (trim( $1,4) <= " ")
  SET log_message = "No DCP_FORMS_ACTIVITY_ID passed in"
  CALL echo(log_message)
  GO TO exit_script
 ELSEIF (cnvtreal( $1) <= 0.00)
  SET log_message = build2("DCP_FORMS_ACTIVITY_ID of ",trim( $1)," not valid")
  CALL echo(log_message)
  GO TO exit_script
 ENDIF
 FREE RECORD work
 RECORD work(
   1 form_name = vc
   1 form_dt_tm = dq8
   1 person_id = f8
   1 encntr_id = f8
   1 patient_name = vc
   1 tmp_comments = vc
   1 caller = vc
   1 call_back_type = vc
   1 call_back_num = vc
   1 call_status = vc
   1 patient_msg = vc
   1 call_category = vc
   1 call_level = vc
   1 responsible_party = vc
   1 message_status = vc
   1 message_comments = vc
   1 forward_to_name = vc
   1 sender_prsnl_id = f8
   1 pharmacy = vc
   1 s_sym_ini = vc
   1 s_sym_add = vc
   1 s_sym_len_ini = vc
   1 s_sym_len_add = vc
   1 s_sym_trt_ini = vc
   1 s_sym_trt_add = vc
   1 s_sym_vis_ini = vc
   1 s_sym_vis_add = vc
   1 s_other_ini = vc
   1 s_other_add = vc
   1 s_pat_pref = vc
   1 s_narrative = vc
 )
 SELECT INTO "NL:"
  dfa.form_dt_tm
  FROM dcp_forms_activity dfa
  PLAN (dfa
   WHERE dfa.dcp_forms_activity_id=cnvtreal( $1))
  DETAIL
   work->form_dt_tm = dfa.form_dt_tm
  WITH nocounter
 ;end select
 DECLARE tmp_ref_nbr = vc WITH constant(build(trim( $1,4),"*"))
 DECLARE cs8_auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE cs8_mod1_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE cs8_mod2_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE cs72_patient_form_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PATIENTMEDICALCARETRIAGE"))
 DECLARE cs72_medication_form_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PRESCRIPTIONREFILLTRIAGE"))
 DECLARE cs72_referral_form_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "REFERRALREQUESTTRIAGE"))
 DECLARE cs72_caller_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"CALLERIFNOTPATIENT"))
 DECLARE cs72_callback_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"CALLBACKREQUESTED"))
 DECLARE cs72_callbacknum_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"CALLBACK"))
 DECLARE cs72_patientmsg_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "ACCESSSERVICESMESSAGE"))
 DECLARE cs72_callcategory_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"CALLCATEGORY"))
 DECLARE cs72_callstatus_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"CALLSTATUS"))
 DECLARE cs72_calllevel_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"MESSAGELEVEL"))
 DECLARE cs72_responsible_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"RESPONSIBLEPARTY"))
 DECLARE cs72_messagestatus_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"MESSAGESTATUS"))
 DECLARE cs72_messagestatuscomments_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "MESSAGESTATUSCOMMENTS"))
 DECLARE cs72_pharmacy_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"PHARMACY"))
 DECLARE cs72_forward_to_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"FORWARDMESSAGETO"))
 DECLARE cs120_compress_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",120,"OCFCOMPRESSION"))
 DECLARE current_dt_tm = c20 WITH constant(format(cnvtdatetime(curdate,curtime3),
   "DD-MMM-YYYY HH:MM:SS;;D"))
 DECLARE line_return = c2 WITH constant(concat(char(013),char(010)))
 DECLARE mf_sym_ini_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SYMPTOMSINITIALRESPONSE"))
 DECLARE mf_sym_add_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SYMPTOMSADDITIONALRESPONSE"))
 DECLARE mf_sym_len_ini_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SYMPTOMSLENGTHINITIALRESPONSE"))
 DECLARE mf_sym_len_add_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SYMPTOMSLENGTHADDITIONALRESPONSE"))
 DECLARE mf_sym_trt_ini_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SYMPTOMSTREATMENTINITIALRESPONSE"))
 DECLARE mf_sym_trt_add_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SYMPTOMSTREATMENTADDITIONALRESPONSE"))
 DECLARE mf_sym_vis_ini_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SYMPTOMSVISITINITIALRESPONSE"))
 DECLARE mf_sym_vis_add_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SYMPTOMSVISITADDITIONALRESPONSE"))
 DECLARE mf_other_ini_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "OTHERPROBLEMSINITIALRESPONSE"))
 DECLARE mf_other_add_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "OTHERPROBLEMSADDITIONALRESPONSE"))
 DECLARE mf_pat_pref_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PATIENTSPREFERREDACTION"))
 DECLARE mf_narrative_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"NARRATIVE"))
 SELECT INTO "NL:"
  FROM clinical_event ce,
   person p,
   ce_event_prsnl cep,
   ce_blob cb,
   ce_string_result csr
  PLAN (ce
   WHERE ce.reference_nbr=patstring(tmp_ref_nbr)
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ce.result_status_cd IN (cs8_auth_cd, cs8_mod1_cd, cs8_mod2_cd))
   JOIN (p
   WHERE ce.person_id=p.person_id)
   JOIN (cep
   WHERE ce.event_id=cep.event_id
    AND cep.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (cb
   WHERE outerjoin(ce.event_id)=cb.event_id
    AND cb.valid_until_dt_tm >= outerjoin(cnvtdatetime(current_dt_tm)))
   JOIN (csr
   WHERE outerjoin(ce.event_id)=csr.event_id
    AND csr.valid_until_dt_tm >= outerjoin(cnvtdatetime(current_dt_tm)))
  ORDER BY cep.action_dt_tm DESC, ce.event_id
  HEAD ce.person_id
   work->person_id = ce.person_id, work->patient_name = trim(p.name_full_formatted),
   CALL echo(p.name_full_formatted),
   work->encntr_id = ce.encntr_id, work->caller = trim(p.name_full_formatted,3), work->
   sender_prsnl_id = cep.action_prsnl_id
  DETAIL
   CASE (ce.event_cd)
    OF cs72_patient_form_cd:
     work->form_name = trim(ce.event_tag,3)
    OF cs72_medication_form_cd:
     work->form_name = trim(ce.event_tag,3)
    OF cs72_referral_form_cd:
     work->form_name = trim(ce.event_tag,3)
    OF cs72_caller_cd:
     work->caller = trim(ce.result_val,3)
    OF cs72_callback_cd:
     work->call_back_type = trim(ce.result_val,3)
    OF cs72_callbacknum_cd:
     work->call_back_num = trim(ce.result_val,3)
    OF cs72_callstatus_cd:
     work->call_status = trim(ce.result_val,3)
    OF cs72_patientmsg_cd:
     blob_in = fillstring(32000," "),blob_out1 = fillstring(32000," "),blob_out2 = fillstring(32000,
      " "),
     blob_out3 = fillstring(32000," "),blob_ret_len = 0,
     IF (cb.compression_cd=cs120_compress_cd)
      blob_in = cb.blob_contents,
      CALL uar_ocf_uncompress(blob_in,32000,blob_out1,32000,blob_ret_len), blob_out2 = blob_out1
     ELSE
      blob_out2 = cb.blob_contents
     ENDIF
     ,blob_out2 = replace(blob_out2,"\pard","<BR>",0),blob_out2 = replace(blob_out2,"\par","<BR>",0),
     blob_out2 = replace(blob_out2,"ocf_blob","",0),
     CALL uar_rtf(blob_out2,textlen(blob_out2),blob_out3,32000,32000,0)blob_out3 = replace(blob_out3,
      "<BR>",char(010),0),work->patient_msg = trim(blob_out3,3)
    OF cs72_callcategory_cd:
     work->call_category = trim(ce.result_val,3)
    OF cs72_calllevel_cd:
     work->call_level = trim(ce.result_val,3)
    OF cs72_responsible_cd:
     work->responsible_party = trim(ce.result_val,3)
    OF cs72_messagestatus_cd:
     work->message_status = trim(ce.result_val,3)
    OF cs72_messagestatuscomments_cd:
     blob_in = fillstring(32000," "),blob_out1 = fillstring(32000," "),blob_out2 = fillstring(32000,
      " "),
     blob_out3 = fillstring(32000," "),blob_ret_len = 0,
     IF (cb.compression_cd=cs120_compress_cd)
      blob_in = cb.blob_contents,
      CALL uar_ocf_uncompress(blob_in,32000,blob_out1,32000,blob_ret_len), blob_out2 = blob_out1
     ELSE
      blob_out2 = cb.blob_contents
     ENDIF
     ,blob_out2 = replace(blob_out2,"\pard","<BR>",0),blob_out2 = replace(blob_out2,"\par","<BR>",0),
     blob_out2 = replace(blob_out2,"ocf_blob","",0),
     CALL uar_rtf(blob_out2,textlen(blob_out2),blob_out3,32000,32000,0)blob_out3 = replace(blob_out3,
      "<BR>",char(010),0),work->message_comments = trim(blob_out3,3)
    OF cs72_forward_to_cd:
     work->forward_to_name = trim(ce.result_val,3)
    OF cs72_pharmacy_cd:
     work->pharmacy = trim(ce.result_val,3)
    OF mf_sym_ini_cd:
     work->s_sym_ini = trim(ce.result_val)
    OF mf_sym_add_cd:
     work->s_sym_add = trim(ce.result_val)
    OF mf_sym_len_ini_cd:
     work->s_sym_len_ini = trim(ce.result_val)
    OF mf_sym_len_add_cd:
     work->s_sym_len_add = trim(ce.result_val)
    OF mf_sym_trt_ini_cd:
     work->s_sym_trt_ini = trim(ce.result_val)
    OF mf_sym_trt_add_cd:
     work->s_sym_trt_add = trim(ce.result_val)
    OF mf_sym_vis_ini_cd:
     work->s_sym_vis_ini = trim(ce.result_val)
    OF mf_sym_vis_add_cd:
     work->s_sym_vis_add = trim(ce.result_val)
    OF mf_other_ini_cd:
     work->s_other_ini = trim(ce.result_val)
    OF mf_other_add_cd:
     work->s_other_add = trim(ce.result_val)
    OF mf_pat_pref_cd:
     work->s_pat_pref = trim(ce.result_val)
    OF mf_narrative_cd:
     CALL echo("in narrative")blob_in = fillstring(32000," "),blob_out1 = fillstring(32000," "),
     blob_out2 = fillstring(32000," "),blob_out3 = fillstring(32000," "),blob_ret_len = 0,
     IF (cb.compression_cd=cs120_compress_cd)
      blob_in = cb.blob_contents,
      CALL uar_ocf_uncompress(blob_in,32000,blob_out1,32000,blob_ret_len), blob_out2 = blob_out1
     ELSE
      blob_out2 = cb.blob_contents
     ENDIF
     ,blob_out2 = replace(blob_out2,"\pard","<BR>",0),blob_out2 = replace(blob_out2,"\par","<BR>",0),
     blob_out2 = replace(blob_out2,"ocf_blob","",0),
     CALL uar_rtf(blob_out2,textlen(blob_out2),blob_out3,32000,32000,0)blob_out3 = replace(blob_out3,
      "<BR>",char(010),0),work->s_narrative = trim(blob_out3,3)
   ENDCASE
  WITH nocounter
 ;end select
 IF ((((work->person_id <= 0.00)) OR ((work->encntr_id <= 0.00))) )
  SET log_message = build2("Patient identifiers missing for events attached to ",
   "DCP_FORMS_ACTIVITY_ID ",tmp_ref_nbr)
  CALL echo(log_message)
  GO TO exit_script
 ELSEIF (trim(work->forward_to_name) <= " ")
  SET log_message = build2("No forward to value found for DCP_FORMS_ACTIVITY_ID ",tmp_ref_nbr)
  CALL echo(log_message)
  GO TO exit_script
 ENDIF
 RECORD phone_triage_request(
   1 person_id = f8
   1 encntr_id = f8
   1 reference_task_id = f8
   1 task_type_cd = f8
   1 task_status_cd = f8
   1 task_dt_tm = c20
   1 task_activity_cd = f8
   1 msg_subject_cd = f8
   1 msg_subject = vc
   1 msg_text = gvc
   1 stat_ind = i2
   1 confidential_ind = i2
   1 read_ind = i2
   1 delivery_ind = i2
   1 event_id = f8
   1 event_class_cd = f8
   1 assign_prsnl_list[*]
     2 assign_prsnl_id = f8
 )
 RECORD phone_triage_reqinfo(
   1 commit_ind = i2
   1 updt_id = f8
   1 updt_task = i4
   1 updt_applctx = i4
 )
 RECORD phone_triage_reply(
   1 status_data
     2 status = c1
   1 result
     2 task_status = c1
     2 assign_prsnl_list[*]
       3 assign_prsnl_id = f8
   1 task_id = f8
 )
 DECLARE cs48_active_cd = f8 WITH constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 SELECT INTO "NL:"
  pr.person_id
  FROM prsnl pr
  PLAN (pr
   WHERE (pr.name_full_formatted=work->forward_to_name)
    AND pr.active_ind=1
    AND pr.active_status_cd=cs48_active_cd)
  HEAD REPORT
   p_cnt = 0
  DETAIL
   p_cnt = (p_cnt+ 1), stat = alterlist(phone_triage_request->assign_prsnl_list,p_cnt),
   phone_triage_request->assign_prsnl_list[p_cnt].assign_prsnl_id = pr.person_id
  WITH nocounter
 ;end select
 IF (size(phone_triage_request->assign_prsnl_list,5) <= 0)
  SET log_message = build2("No PRSNL rows found for NAME_FULL_FORMATTED ",work->forward_to_name)
  CALL echo(log_message)
  GO TO exit_script
 ENDIF
 SET phone_triage_request->person_id = work->person_id
 SET phone_triage_request->encntr_id = work->encntr_id
 SET phone_triage_request->task_type_cd = uar_get_code_by("MEANING",6026,"PHONE MSG")
 SET phone_triage_request->task_status_cd = uar_get_code_by("MEANING",79,"PENDING")
 SET phone_triage_request->task_dt_tm = format(cnvtdatetime(curdate,curtime3),
  "DD-MMM-YYYY HH:MM:SS;;D")
 SET phone_triage_request->task_activity_cd = uar_get_code_by("MEANING",6027,"COMP PERS")
 SET phone_triage_request->msg_subject_cd = 0.00
 SET phone_triage_request->msg_text = build2("::Call Date/Time: ",format(work->form_dt_tm,
   "MM/DD/YYYY;;D")," ",cnvtupper(format(work->form_dt_tm,"HH:MM;;S")),line_return)
 SET phone_triage_request->msg_text = build2(phone_triage_request->msg_text,"Responsible Party: ",
  work->responsible_party,line_return)
 SET phone_triage_request->msg_text = build2(phone_triage_request->msg_text,"Message Status: ",work->
  message_status,line_return)
 SET phone_triage_request->msg_text = build2(phone_triage_request->msg_text,"Caller: ",work->caller,
  line_return)
 SET phone_triage_request->msg_text = build2(phone_triage_request->msg_text,"Callback number: ",work
  ->call_back_num,line_return)
 SET phone_triage_request->msg_text = build2(phone_triage_request->msg_text,line_return,
  "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",line_return)
 SET phone_triage_request->msg_text = build2(phone_triage_request->msg_text,
  "Message Status Comments: ",line_return,work->message_comments)
 SET phone_triage_request->msg_text = build2(phone_triage_request->msg_text,line_return,
  "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",line_return,line_return)
 SET phone_triage_request->msg_text = build2(phone_triage_request->msg_text,"Call Status: ",work->
  call_status,line_return)
 SET phone_triage_request->msg_text = build2(phone_triage_request->msg_text,line_return,
  "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",line_return)
 SET phone_triage_request->msg_text = build2(phone_triage_request->msg_text,"Patient Message:",
  line_return,work->patient_msg)
 SET phone_triage_request->msg_text = build2(phone_triage_request->msg_text,line_return,
  "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",line_return)
 SET phone_triage_request->msg_text = build2(phone_triage_request->msg_text,"Pharmacy:",line_return,
  work->pharmacy)
 SET phone_triage_request->msg_text = build2(phone_triage_request->msg_text,line_return,
  "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",line_return,line_return)
 SET phone_triage_request->msg_text = build2(phone_triage_request->msg_text,"Medical Home")
 SET phone_triage_request->msg_text = build2(phone_triage_request->msg_text,line_return,
  "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",line_return)
 IF (trim(work->s_sym_ini) > " ")
  SET phone_triage_request->msg_text = build2(phone_triage_request->msg_text,
   "What are your symptoms?"," (patient response)",line_return,work->s_sym_ini)
  SET phone_triage_request->msg_text = build2(phone_triage_request->msg_text,line_return,
   "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",line_return)
 ENDIF
 IF (trim(work->s_sym_len_ini) > " ")
  SET phone_triage_request->msg_text = build2(phone_triage_request->msg_text,
   "How long have you had these symptoms?"," (patient response)",line_return,work->s_sym_len_ini)
  SET phone_triage_request->msg_text = build2(phone_triage_request->msg_text,line_return,
   "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",line_return)
 ENDIF
 IF (trim(work->s_sym_trt_ini) > " ")
  SET phone_triage_request->msg_text = build2(phone_triage_request->msg_text,
   "What have you tried so far for these symptoms and did it help"," (patient response)",line_return,
   work->s_sym_trt_ini)
  SET phone_triage_request->msg_text = build2(phone_triage_request->msg_text,line_return,
   "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",line_return)
 ENDIF
 IF (trim(work->s_sym_vis_ini) > " ")
  SET phone_triage_request->msg_text = build2(phone_triage_request->msg_text,
   "Have you been either here or somewhere else for this problem?"," (patient response)",line_return,
   work->s_sym_vis_ini)
  SET phone_triage_request->msg_text = build2(phone_triage_request->msg_text,line_return,
   "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",line_return)
 ENDIF
 IF (trim(work->s_other_ini) > " ")
  SET phone_triage_request->msg_text = build2(phone_triage_request->msg_text,
   "Do you have other problems that you'd like us to know about?"," (patient response)",line_return,
   work->s_other_ini)
  SET phone_triage_request->msg_text = build2(phone_triage_request->msg_text,line_return,
   "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",line_return)
 ENDIF
 IF (trim(work->s_pat_pref) > " ")
  SET phone_triage_request->msg_text = build2(phone_triage_request->msg_text,
   "Patient's Preferred Action:",line_return,work->s_pat_pref)
  SET phone_triage_request->msg_text = build2(phone_triage_request->msg_text,line_return,
   "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",line_return)
 ENDIF
 IF (trim(work->s_narrative) > " ")
  SET phone_triage_request->msg_text = build2(phone_triage_request->msg_text,
   "Narrative (Clinical Response to Above)",line_return,work->s_narrative)
  SET phone_triage_request->msg_text = build2(phone_triage_request->msg_text,line_return,
   "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",line_return)
 ENDIF
 SET phone_triage_request->confidential_ind = 0
 SET phone_triage_request->read_ind = 0
 SET phone_triage_request->delivery_ind = 0
 SET phone_triage_request->event_id = 0.00
 SET phone_triage_request->event_class_cd = 0.00
 SET phone_triage_reqinfo->updt_id = work->sender_prsnl_id
 SET work->tmp_comments = build2(work->caller,":",work->call_back_type," ",work->call_back_num)
 SELECT INTO "NL:"
  FROM order_task ot
  PLAN (ot
   WHERE ot.task_description="Phone Message")
  DETAIL
   phone_triage_request->reference_task_id = ot.reference_task_id
  WITH nocounter
 ;end select
 IF ((work->form_name="Prescription Refill - Triage"))
  SET phone_triage_request->msg_subject = "Medication renewal"
 ELSE
  SET phone_triage_request->msg_subject = build2(trim(work->call_category,3)," (Phone Triage)")
 ENDIF
 IF ((work->call_level="Urgent"))
  SET phone_triage_request->stat_ind = 1
 ELSE
  SET phone_triage_request->stat_ind = 0
 ENDIF
 FREE SET line_return
 SET log_message = "Filling out server req to create task"
 RECORD inboxrequest(
   1 person_id = f8
   1 encntr_id = f8
   1 stat_ind = i2
   1 task_type_cd = f8
   1 task_type_meaning = c12
   1 reference_task_id = f8
   1 task_dt_tm = dq8
   1 task_activity_meaning = c12
   1 msg_text = c32768
   1 msg_subject_cd = f8
   1 msg_subject = c255
   1 confidential_ind = i2
   1 read_ind = i2
   1 delivery_ind = i2
   1 event_id = f8
   1 event_class_meaning = c12
   1 assign_prsnl_list[*]
     2 assign_prsnl_id = f8
   1 task_status_meaning = c12
 )
 RECORD inboxreply(
   1 task_status = c1
   1 task_id = f8
   1 assign_prsnl_list[*]
     2 assign_prsnl_id = f8
     2 encntr_sec_ind = i2
   1 status_data
     2 status = c1
     2 substatus = i2
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = c100
 )
 DECLARE req = i4
 DECLARE happ = i4
 DECLARE htask = i4
 DECLARE hreq = i4
 DECLARE hreply = i4
 DECLARE crmstatus = i4
 SET ecrmok = 0
 SET null = 0
 IF (validate(recdate,"Y")="Y"
  AND validate(recdate,"N")="N")
  RECORD recdate(
    1 datetime = dq8
  )
 ENDIF
 SUBROUTINE srvrequest(taskhandle,reqno)
   SET htask = taskhandle
   SET req = reqno
   SET crmstatus = uar_crmbeginreq(htask,0,req,hreq)
   IF (crmstatus != ecrmok)
    CALL echo("Invalid CrmBeginReq return status")
   ELSEIF (hreq=null)
    CALL echo("Invalid hReq handle")
   ELSE
    SET request_handle = hreq
    SET hinboxrequest = uar_crmgetrequest(hreq)
    IF (hinboxrequest=null)
     CALL echo("Invalid request handle return from CrmGetRequest")
    ELSE
     SET stat = uar_srvsetdouble(hinboxrequest,"PERSON_ID",inboxrequest->person_id)
     SET stat = uar_srvsetdouble(hinboxrequest,"ENCNTR_ID",inboxrequest->encntr_id)
     SET stat = uar_srvsetshort(hinboxrequest,"STAT_IND",cnvtint(inboxrequest->stat_ind))
     SET stat = uar_srvsetdouble(hinboxrequest,"TASK_TYPE_CD",inboxrequest->task_type_cd)
     SET stat = uar_srvsetstring(hinboxrequest,"TASK_TYPE_MEANING",nullterm(inboxrequest->
       task_type_meaning))
     SET stat = uar_srvsetdouble(hinboxrequest,"REFERENCE_TASK_ID",inboxrequest->reference_task_id)
     SET recdate->datetime = inboxrequest->task_dt_tm
     SET stat = uar_srvsetdate2(hinboxrequest,"TASK_DT_TM",recdate)
     SET stat = uar_srvsetstring(hinboxrequest,"TASK_ACTIVITY_MEANING",nullterm(inboxrequest->
       task_activity_meaning))
     SET stat = uar_srvsetstring(hinboxrequest,"MSG_TEXT",nullterm(inboxrequest->msg_text))
     SET stat = uar_srvsetdouble(hinboxrequest,"MSG_SUBJECT_CD",inboxrequest->msg_subject_cd)
     SET stat = uar_srvsetstring(hinboxrequest,"MSG_SUBJECT",nullterm(inboxrequest->msg_subject))
     SET stat = uar_srvsetshort(hinboxrequest,"CONFIDENTIAL_IND",cnvtint(inboxrequest->
       confidential_ind))
     SET stat = uar_srvsetshort(hinboxrequest,"READ_IND",cnvtint(inboxrequest->read_ind))
     SET stat = uar_srvsetshort(hinboxrequest,"DELIVERY_IND",cnvtint(inboxrequest->delivery_ind))
     SET stat = uar_srvsetdouble(hinboxrequest,"EVENT_ID",inboxrequest->event_id)
     SET stat = uar_srvsetstring(hinboxrequest,"EVENT_CLASS_MEANING",nullterm(inboxrequest->
       event_class_meaning))
     FOR (ndx1 = 1 TO size(inboxrequest->assign_prsnl_list,5))
      SET hassign_prsnl_list = uar_srvadditem(hinboxrequest,"ASSIGN_PRSNL_LIST")
      IF (hassign_prsnl_list=null)
       CALL echo("ASSIGN_PRSNL_LIST","Invalid handle")
      ELSE
       SET stat = uar_srvsetdouble(hassign_prsnl_list,"ASSIGN_PRSNL_ID",inboxrequest->
        assign_prsnl_list[ndx1].assign_prsnl_id)
      ENDIF
     ENDFOR
     SET stat = uar_srvsetstring(hinboxrequest,"TASK_STATUS_MEANING",nullterm(inboxrequest->
       task_status_meaning))
    ENDIF
   ENDIF
   IF (crmstatus=ecrmok)
    CALL echo(concat("**** Begin perform request #",cnvtstring(req)," -EKS Event @",format(curdate,
       "dd-mmm-yyyy;;d")," ",
      format(curtime,"hh:mm:ss.cc;3;m")))
    SET crmstatus = uar_crmperform(hreq)
    CALL echo(concat("**** End perform request #",cnvtstring(req)," -EKS Event @",format(curdate,
       "dd-mmm-yyyy;;d")," ",
      format(curtime,"hh:mm:ss.cc;3;m")))
    IF (crmstatus != ecrmok)
     CALL echo("Invalid CrmPerform return status")
    ENDIF
   ELSE
    CALL echo("CrmPerform not executed do to begin request error")
   ENDIF
 END ;Subroutine
 SUBROUTINE srvreply(taskhandle,reqno)
   DECLARE item_cnt = i4 WITH protect
   SET htask = taskhandle
   SET req = reqno
   IF (crmstatus=ecrmok)
    SET hinboxreply = uar_crmgetreply(hreq)
    IF (hinboxreply=null)
     CALL echo("Invalid handle from CrmGetReply")
    ELSE
     CALL echo("Retrieving reply message")
     SET inboxreply->task_status = uar_srvgetstringptr(hinboxreply,"TASK_STATUS")
     SET inboxreply->task_id = uar_srvgetdouble(hinboxreply,"TASK_ID")
     SET item_cnt = uar_srvgetitemcount(hinboxreply,"ASSIGN_PRSNL_LIST")
     SET stat = alterlist(inboxreply->assign_prsnl_list,item_cnt)
     FOR (ndx1 = 1 TO item_cnt)
      SET hassign_prsnl_list = uar_srvgetitem(hinboxreply,"ASSIGN_PRSNL_LIST",(ndx1 - 1))
      IF (hassign_prsnl_list=null)
       CALL echo("Invalid handle return from SrvGetItem for hASSIGN_PRSNL_LIST")
      ELSE
       SET inboxreply->assign_prsnl_list[ndx1].assign_prsnl_id = uar_srvgetdouble(hassign_prsnl_list,
        "ASSIGN_PRSNL_ID")
       SET inboxreply->assign_prsnl_list[ndx1].encntr_sec_ind = uar_srvgetshort(hassign_prsnl_list,
        "ENCNTR_SEC_IND")
      ENDIF
     ENDFOR
     SET hstatus_data = uar_srvgetstruct(hinboxreply,"STATUS_DATA")
     IF (hstatus_data=null)
      CALL echo("Invalid handle")
     ELSE
      SET inboxreply->status_data.status = uar_srvgetstringptr(hstatus_data,"STATUS")
      SET inboxreply->status_data.substatus = uar_srvgetshort(hstatus_data,"SUBSTATUS")
      SET item_cnt = uar_srvgetitemcount(hstatus_data,"SUBEVENTSTATUS")
      SET stat = alterlist(inboxreply->status_data.subeventstatus,item_cnt)
      FOR (ndx2 = 1 TO item_cnt)
       SET hsubeventstatus = uar_srvgetitem(hstatus_data,"SUBEVENTSTATUS",(ndx2 - 1))
       IF (hsubeventstatus=null)
        CALL echo("Invalid handle return from SrvGetItem for hSUBEVENTSTATUS")
       ELSE
        SET inboxreply->status_data.subeventstatus[ndx2].operationname = uar_srvgetstringptr(
         hsubeventstatus,"OPERATIONNAME")
        SET inboxreply->status_data.subeventstatus[ndx2].operationstatus = uar_srvgetstringptr(
         hsubeventstatus,"OPERATIONSTATUS")
        SET inboxreply->status_data.subeventstatus[ndx2].targetobjectname = uar_srvgetstringptr(
         hsubeventstatus,"TARGETOBJECTNAME")
        SET inboxreply->status_data.subeventstatus[ndx2].targetobjectvalue = uar_srvgetstringptr(
         hsubeventstatus,"TARGETOBJECTVALUE")
       ENDIF
      ENDFOR
     ENDIF
    ENDIF
   ELSE
    CALL echo("Could not retrieve reply due to CrmBegin request error")
   ENDIF
   CALL echo("Ending CRM Request")
   CALL uar_crmendreq(hreq)
 END ;Subroutine
 DECLARE phonemsg = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6026,"PHONEMSG"))
 SET msgsubject = phone_triage_request->msg_subject
 SET msg = phone_triage_request->msg_text
 SET inboxrequest->person_id = phone_triage_request->person_id
 SET inboxrequest->encntr_id = phone_triage_request->encntr_id
 SET inboxrequest->stat_ind = phone_triage_request->stat_ind
 SET inboxrequest->task_type_cd = phonemsg
 SET inboxrequest->task_type_meaning = "PHONE MSG"
 SET inboxrequest->reference_task_id = phone_triage_request->reference_task_id
 SET inboxrequest->task_dt_tm = cnvtdatetime(curdate,curtime3)
 SET inboxrequest->task_activity_meaning = "comp pers"
 SET inboxrequest->msg_text = fillstring(3100," ")
 SET inboxrequest->msg_text = msg
 SET inboxrequest->msg_subject_cd = 0
 SET inboxrequest->msg_subject = msgsubject
 SET inboxrequest->confidential_ind = 0
 SET inboxrequest->read_ind = 0
 SET inboxrequest->delivery_ind = 0
 SET inboxrequest->event_id = 0
 SET inboxrequest->event_class_meaning = " "
 SET inboxrequest->task_status_meaning = " "
 SET stat = alterlist(inboxrequest->assign_prsnl_list,size(phone_triage_request->assign_prsnl_list,5)
  )
 FOR (x = 1 TO size(phone_triage_request->assign_prsnl_list,5))
   SET inboxrequest->assign_prsnl_list[1].assign_prsnl_id = phone_triage_request->assign_prsnl_list[x
   ].assign_prsnl_id
 ENDFOR
 SET reqc = 967102
 SET happc = 0
 SET appc = 3055000
 SET taskc = 3202004
 SET htaskc = 0
 SET hreqc = 0
 SET log_message = "Calling server to create task"
 SET stat = uar_crmbeginapp(appc,happc)
 SET stat = uar_crmbegintask(happc,taskc,htaskc)
 CALL echo(build("beginReq",stat))
 CALL srvrequest(htaskc,reqc)
 CALL srvreply(htaskc,reqc)
 CALL echorecord(inboxrequest)
 CALL echorecord(inboxreply)
 SET phone_triage_reply->task_id = inboxreply->task_id
 SET log_message = "Task as been created by server"
 IF ((phone_triage_reply->task_id <= 0.00))
  SET log_message = build2("DCP_ADD_TASK didn't provide TASK_ID, message comments not set")
  CALL echo(log_message)
  GO TO exit_script
 ENDIF
 UPDATE  FROM task_activity ta
  SET ta.comments = work->tmp_comments, ta.msg_sender_id = work->sender_prsnl_id, ta.updt_id = work->
   sender_prsnl_id
  WHERE (ta.task_id=phone_triage_reply->task_id)
  WITH nocounter
 ;end update
 COMMIT
 SET log_message = build2("curqual:",curqual,"Phone message successfully sent. TASK_ID ",trim(
   cnvtstring(phone_triage_reply->task_id),3))
 CALL echo(log_message)
 SET retval = 100
#exit_script
 FREE SET cs8_auth_cd
 FREE SET cs8_mod1_cd
 FREE SET cs8_mod2_cd
 FREE SET cs72_forward_to_cd
 FREE SET cs48_active_ind
 FREE SET tmp_ref_nbr
 FREE SET cs72_patient_form_cd
 FREE SET cs72_medication_form_cd
 FREE SET cs72_referral_form_cd
 FREE SET cs72_caller_cd
 FREE SET cs72_callback_cd
 FREE SET cs72_callbacknum_cd
 FREE SET cs72_messagelevel_cd
 FREE SET cs72_callcategory_cd
 FREE SET cs72_callstatus_cd
 FREE SET cs72_calllevel_cd
 FREE SET cs72_responsible_cd
 FREE SET cs72_messagestatus_cd
 FREE SET cs72_messagestatuscomment_cd
 FREE SET cs72_forward_to_cd
 FREE SET cs120_compress_cd
 FREE SET current_dt_tm
 FREE RECORD work
 FREE RECORD phone_triage_request
 FREE RECORD phone_triage_reqinfo
 FREE RECORD phone_triage_reply
END GO
