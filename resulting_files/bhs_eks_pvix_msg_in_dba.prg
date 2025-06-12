CREATE PROGRAM bhs_eks_pvix_msg_in:dba
 PROMPT
  "clinical_event_id" = ""
  WITH f_clin_event_id
 DECLARE mf_clin_event_id = f8 WITH protect, constant(cnvtreal( $F_CLIN_EVENT_ID))
 DECLARE mf_nocomp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",120,"NOCOMPRESSION"))
 DECLARE mf_comp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",120,"OCFCOMPRESSION"))
 DECLARE mf_npi_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",320,
   "NATIONALPROVIDERIDENTIFIER"))
 DECLARE mf_pcp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",331,"PCP"))
 DECLARE mf_routine_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",1304,"ROUTINE"))
 DECLARE mf_person_id = f8 WITH protect, noconstant(0.0)
 DECLARE mf_encntr_id = f8 WITH protect, noconstant(0.0)
 DECLARE mf_event_id = f8 WITH protect, noconstant(0.0)
 DECLARE ms_log = vc WITH protect, noconstant(" ")
 DECLARE ms_blob = vc WITH protect, noconstant(fillstring(32768," "))
 DECLARE ms_subject = vc WITH protect, noconstant(" ")
 DECLARE ms_body = vc WITH protect, noconstant(" ")
 DECLARE ml_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_end = i4 WITH protect, noconstant(0)
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_prsnl_id = vc WITH protect, noconstant(" ")
 DECLARE mf_prsnl_id = f8 WITH protect, noconstant(0.0)
 DECLARE ms_prsnl_name = vc WITH protect, noconstant(" ")
 DECLARE ms_prsnl_alias = vc WITH protect, noconstant(" ")
 DECLARE mf_sender_id = f8 WITH protect, noconstant(0.0)
 EXECUTE bhs_hlp_ccl
 RECORD inboxrequest(
   1 message_list[*]
     2 draft_msg_uid = vc
     2 person_id = f8
     2 encntr_id = f8
     2 event_cd = f8
     2 task_type_cd = f8
     2 priority_cd = f8
     2 save_to_chart_ind = i2
     2 msg_sender_pool_id = f8
     2 msg_sender_person_id = f8
     2 msg_sender_prsnl_id = f8
     2 msg_subject = vc
     2 refill_request_ind = i2
     2 msg_text = gvc
     2 reminder_dt_tm = dq8
     2 due_dt_tm = dq8
     2 callername = vc
     2 callerphone = vc
     2 notify_info[1]
       3 notify_pool_ind = f8
       3 notify_prsnl_id = f8
       3 notify_priority_cd = f8
       3 notify_status_list[*]
         4 notify_status_cd = f8
         4 delay[1]
           5 value = i4
           5 unit_flag = i2
     2 action_request_list[*]
       3 action_request_cd = f8
     2 assign_prsnl_list[*]
       3 assign_prsnl_id = f8
       3 cc_ind = i2
       3 selection_nbr = i4
     2 assign_person_list[*]
       3 assign_person_id = f8
       3 cc_ind = i2
       3 selection_nbr = i4
       3 reply_allowed_ind = i2
     2 assign_pool_list[*]
       3 assign_pool_id = f8
       3 assign_prsnl_id = f8
       3 cc_ind = i2
       3 selection_nbr = i4
     2 encounter_class_cd = f8
     2 encounter_type_cd = f8
     2 org_id = f8
     2 get_best_encounter = i2
     2 create_encounter = i2
     2 proposed_order_list[*]
       3 proposed_order_id = f8
     2 event_id = f8
     2 order_id = f8
     2 encntr_prsnl_reltn_cd = f8
     2 facility_cd = f8
     2 send_to_chart_ind = i2
     2 original_task_uid = vc
     2 rx_renewal_list[*]
       3 rx_renewal_uid = vc
     2 task_status_flag = i2
     2 task_activity_flag = i2
     2 event_class_flag = i2
     2 attachments[*]
       3 name = c255
       3 location_handle = c255
       3 media_identifier = c255
       3 media_version = i4
     2 sender_email = c320
     2 assign_emails[*]
       3 email = c320
       3 cc_ind = i2
       3 selection_nbr = i4
       3 first_name = c100
       3 last_name = c100
       3 display_name = c100
     2 sender_email_display_name = c100
   1 action_dt_tm = dq8
   1 action_tz = i4
   1 skip_validation_ind = i2
 )
 RECORD inboxreply(
   1 task_id = f8
   1 status_data[1]
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 invalid_receivers[*]
     2 entity_id = f8
     2 entity_type = vc
 )
 CALL pause(4)
 SET retval = - (1)
 SELECT INTO "nl:"
  FROM prsnl pr
  WHERE pr.name_first_key="PVIXNOTIFICATION"
   AND pr.name_last_key="SECUREMESSAGE"
  HEAD REPORT
   mf_sender_id = pr.person_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event ce,
   ce_event_note cen,
   long_blob lb
  PLAN (ce
   WHERE ce.clinical_event_id=mf_clin_event_id)
   JOIN (cen
   WHERE cen.event_id=ce.event_id)
   JOIN (lb
   WHERE lb.parent_entity_id=cen.ce_event_note_id
    AND lb.active_ind=1)
  HEAD REPORT
   blob_out = fillstring(32768," "), blob_ret_len = 0,
   CALL echo("head report"),
   CALL echo(build2("compression_cd: ",lb.compression_cd)), mf_event_id = ce.event_id, mf_person_id
    = ce.person_id,
   mf_encntr_id = ce.encntr_id
   IF (lb.compression_cd=mf_nocomp_cd)
    CALL echo("nocomp"), ms_body = trim(lb.long_blob,3)
   ELSEIF (((lb.compression_cd=mf_comp_cd) OR (cen.compression_cd=mf_comp_cd)) )
    CALL echo("comp"),
    CALL uar_ocf_uncompress(lb.long_blob,size(lb.long_blob),blob_out,32768,blob_ret_len), ms_body =
    trim(blob_out,3),
    CALL echo(build2("ms_body: ",ms_body))
   ENDIF
  WITH format(date,"mm/dd/yy hh:mm;;d"), uar_code("D")
 ;end select
 IF (curqual < 1)
  SET ms_log = "0sbj"
 ELSE
  SET ms_log = build2(textlen(trim(ms_blob,3)),"sbj")
 ENDIF
 CALL echo(build2("clin_event_id: ",mf_clin_event_id,"mf_event_id: ",mf_event_id))
 SET ms_blob = bhs_sbr_get_blob(mf_event_id,0)
 CALL echo(build2("ms_blob: ",ms_blob))
 SET ml_end = findstring("|",ms_blob,1)
 SET ms_prsnl_id = substring(1,(ml_end - 1),ms_blob)
 CALL echo(build2("prsnl_id: ",ms_prsnl_id))
 SET ml_pos = (ml_end+ 1)
 SET ml_end = findstring("|",ms_blob,ml_pos)
 CALL echo(build2("ml_pos: ",ml_pos," ml_end: ",ml_end))
 SET ms_prsnl_alias = substring(ml_pos,(ml_end - ml_pos),ms_blob)
 SET ms_prsnl_alias = replace(ms_prsnl_alias,"<","")
 CALL echo(build2("prsnl alias: ",ms_prsnl_alias))
 SET ml_pos = (ml_end+ 1)
 SET ml_end = textlen(trim(ms_blob,3))
 SET ms_subject = substring(ml_pos,((ml_end - ml_pos)+ 1),ms_blob)
 SET ms_subject = replace(ms_subject,"<","")
 IF (ms_log != "0sbj"
  AND textlen(trim(ms_subject,3)) > 0)
  SET ms_log = ms_subject
  CALL echo(build2("ms_subject : ",ms_subject))
 ENDIF
 IF (textlen(trim(ms_prsnl_id,3)) > 0
  AND trim(ms_prsnl_id,3) != "0")
  IF (ms_prsnl_alias="PRSNL")
   CALL echo("PRSNL")
   SET mf_prsnl_id = cnvtreal(ms_prsnl_id)
   SELECT INTO "nl:"
    FROM prsnl pr
    WHERE pr.person_id=mf_prsnl_id
    HEAD REPORT
     ms_prsnl_name = trim(pr.name_full_formatted,3),
     CALL echo(build2("ms_prsnl_name: ",ms_prsnl_name))
    WITH nocounter
   ;end select
  ELSEIF (ms_prsnl_alias="NPI")
   CALL echo("NPI")
   SELECT INTO "nl:"
    FROM prsnl_alias pa,
     prsnl pr
    PLAN (pa
     WHERE pa.prsnl_alias_type_cd=mf_npi_cd
      AND pa.active_ind=1
      AND pa.end_effective_dt_tm > sysdate
      AND pa.alias=ms_prsnl_id)
     JOIN (pr
     WHERE pr.person_id=pa.person_id)
    HEAD REPORT
     mf_prsnl_id = pa.person_id, ms_prsnl_name = trim(pr.name_full_formatted,3),
     CALL echo(build2("ms_prsnl_name: ",ms_prsnl_name))
    WITH nocounter
   ;end select
  ENDIF
  CALL echo(build2("mf_prsnl_id: ",mf_prsnl_id))
 ELSE
  CALL echo("PCP")
  SELECT INTO "nl:"
   FROM person_prsnl_reltn ppr,
    prsnl pr
   PLAN (ppr
    WHERE ppr.person_id=mf_person_id
     AND ppr.active_ind=1
     AND ppr.person_prsnl_r_cd=mf_pcp_cd
     AND ppr.end_effective_dt_tm > sysdate)
    JOIN (pr
    WHERE pr.person_id=ppr.prsnl_person_id)
   HEAD REPORT
    mf_prsnl_id = ppr.prsnl_person_id, ms_prsnl_name = trim(pr.name_full_formatted,3),
    CALL echo(build2("ms_prsnl_name: ",ms_prsnl_name))
   WITH nocounter
  ;end select
 ENDIF
 IF (mf_prsnl_id=0)
  CALL echo("no prsnl_id found")
  GO TO exit_script
 ENDIF
 SET stat = initrec(inboxrequest)
 SET stat = alterlist(inboxrequest->message_list,1)
 SET inboxrequest->message_list[1].msg_sender_prsnl_id = mf_sender_id
 SET inboxrequest->message_list[1].person_id = mf_person_id
 SET inboxrequest->message_list[1].encntr_id = mf_encntr_id
 SET inboxrequest->message_list[1].task_type_cd = 2678
 SET inboxrequest->message_list[1].msg_text = ms_body
 SET inboxrequest->message_list[1].msg_subject = ms_subject
 SET inboxrequest->message_list[1].event_id = 0
 SET inboxrequest->message_list[1].priority_cd = mf_routine_cd
 SET stat = alterlist(inboxrequest->message_list[1].assign_prsnl_list,1)
 SET inboxrequest->message_list[1].assign_prsnl_list[1].assign_prsnl_id = mf_prsnl_id
 SET stat = tdbexecute(0,967100,967503,"REC",inboxrequest,
  "REC",inboxreply)
 IF ((inboxreply->status_data[1].status="S"))
  CALL echo("msg sent")
 ENDIF
 SET ms_log = concat(ms_log," ibx:",inboxreply->status_data[1].status)
 SET retval = 100
 CALL echo(ms_log)
 SET log_message = ms_log
 CALL echo(retval)
 CALL echorecord(inboxrequest)
 CALL echorecord(inboxreply)
#exit_script
END GO
