CREATE PROGRAM bhs_prax_save_followup
 FREE RECORD result
 RECORD result(
   1 person_id = f8
   1 encntr_id = f8
   1 comment = vc
   1 address = vc
   1 recipient = vc
   1 pat_ed_doc_id = f8
   1 pat_ed_followup_id = f8
   1 cmt_long_text_id = f8
   1 add_long_text_id = f8
   1 recipient_long_text_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE callupdateprogram(null) = i2
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 SET result->status_data.status = "F"
 IF (( $2 <= 0.0))
  CALL echo("INVALID ENCOUNTER ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $3 <= 0.0))
  CALL echo("INVALID PERSONNEL ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SET result->encntr_id =  $2
 SELECT INTO "NL:"
  FROM encounter e
  PLAN (e
   WHERE (e.encntr_id=result->encntr_id)
    AND e.active_ind=1
    AND e.beg_effective_dt_tm < sysdate
    AND e.end_effective_dt_tm > sysdate)
  ORDER BY e.person_id
  HEAD e.person_id
   result->person_id = e.person_id
  WITH nocounter, time = 30
 ;end select
 FREE RECORD req_format_str
 RECORD req_format_str(
   1 param = vc
 ) WITH protect
 FREE RECORD rep_format_str
 RECORD rep_format_str(
   1 param = vc
 ) WITH protect
 SET req_format_str->param =  $12
 EXECUTE bhs_prax_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
  "REP_FORMAT_STR")
 SET result->comment = rep_format_str->param
 SET req_format_str->param =  $15
 EXECUTE bhs_prax_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
  "REP_FORMAT_STR")
 SET result->address = rep_format_str->param
 SET req_format_str->param =  $30
 EXECUTE bhs_prax_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
  "REP_FORMAT_STR")
 SET result->recipient = rep_format_str->param
 SET stat = callupdateprogram(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 CALL echorecord(result)
 IF (size(trim(moutputdevice,3)) > 0)
  DECLARE v1 = vc WITH protect, noconstant("")
  DECLARE v2 = vc WITH protect, noconstant("")
  DECLARE v3 = vc WITH protect, noconstant("")
  DECLARE v4 = vc WITH protect, noconstant("")
  DECLARE v5 = vc WITH protect, noconstant("")
  DECLARE v6 = vc WITH protect, noconstant("")
  SELECT INTO value(moutputdevice)
   FROM dummyt d
   PLAN (d
    WHERE d.seq > 0)
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1, v1 = build("<Status>",result->status_data.status,"</Status>"), col + 1,
    v1, row + 1, v2 = build("<PatEdDocId>",cnvtint(result->pat_ed_doc_id),"</PatEdDocId>"),
    col + 1, v2, row + 1,
    v3 = build("<PatEdFollowUpId>",cnvtint(result->pat_ed_followup_id),"</PatEdFollowUpId>"), col + 1,
    v3,
    row + 1, v4 = build("<CommentLongTextId>",cnvtint(result->cmt_long_text_id),
     "</CommentLongTextId>"), col + 1,
    v4, row + 1, v5 = build("<AddressLongTextId>",cnvtint(result->add_long_text_id),
     "</AddressLongTextId>"),
    col + 1, v5, row + 1,
    v6 = build("<RecipientLongTextId>",cnvtint(result->recipient_long_text_id),
     "</RecipientLongTextId>"), col + 1, v6,
    row + 1, col + 1, "</ReplyMessage>",
    row + 1
   WITH maxcol = 32000, nocounter, nullreport,
    formfeed = none, format = variable, time = 30
  ;end select
 ENDIF
 FREE RECORD result
 FREE RECORD req4250785
 FREE RECORD rep4250785
 SUBROUTINE callupdateprogram(null)
   FREE RECORD i_request
   RECORD i_request(
     1 prsnl_id = f8
   ) WITH protect
   FREE RECORD i_reply
   RECORD i_reply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   SET i_request->prsnl_id =  $3
   CALL echorecord(i_request)
   EXECUTE bhs_prax_impersonate_user  WITH replace("REQUEST","I_REQUEST"), replace("REPLY","I_REPLY")
   IF ((i_reply->status_data.status != "S"))
    CALL echo("IMPERSONATE USER FAILED...EXITING!")
    RETURN(fail)
   ENDIF
   FREE RECORD req4250785
   RECORD req4250785(
     1 pat_ed_doc_id = f8
     1 encntr_id = f8
     1 person_id = f8
     1 event_id = f8
     1 pat_ed_domain_cd = f8
     1 sign_flag = i2
     1 task_flag = i2
     1 provider_id = f8
     1 provider_name = vc
     1 cmt_long_text_id = f8
     1 long_text = vc
     1 followup_dt_tm = dq8
     1 add_long_text_id = f8
     1 add_long_text = vc
     1 fol_within_range = vc
     1 fol_days = i2
     1 day_or_week = i2
     1 active_ind = i2
     1 organization_id = f8
     1 location_cd = f8
     1 address_type_cd = f8
     1 pat_ed_followup_id = f8
     1 quick_pick_cd = f8
     1 followup_range_cd = f8
     1 address_id = f8
     1 phone_id = f8
     1 followup_needed_ind = i2
     1 recipient_long_text_id = f8
     1 recipient_long_text = vc
   ) WITH protect
   FREE RECORD rep4250785
   RECORD rep4250785(
     1 pat_ed_doc_id = f8
     1 pat_ed_followup_id = f8
     1 cmt_long_text_id = f8
     1 add_long_text_id = f8
     1 recipient_long_text_id = f8
     1 status_data
       2 status = c1
       2 subeventstatus[*]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   SET req4250785->pat_ed_doc_id =  $4
   SET req4250785->encntr_id = result->encntr_id
   SET req4250785->person_id = result->person_id
   SET req4250785->event_id =  $5
   SET req4250785->pat_ed_domain_cd =  $6
   SET req4250785->sign_flag =  $7
   SET req4250785->task_flag =  $8
   SET req4250785->provider_id =  $9
   SET req4250785->provider_name =  $10
   SET req4250785->cmt_long_text_id =  $11
   SET req4250785->long_text = result->comment
   SET req4250785->followup_dt_tm = cnvtdatetime( $13)
   SET req4250785->add_long_text_id =  $14
   SET req4250785->add_long_text = result->address
   SET req4250785->fol_within_range =  $16
   SET req4250785->fol_days =  $17
   SET req4250785->day_or_week =  $18
   SET req4250785->active_ind =  $19
   SET req4250785->organization_id =  $20
   SET req4250785->location_cd =  $21
   SET req4250785->address_type_cd =  $22
   SET req4250785->pat_ed_followup_id =  $23
   SET req4250785->quick_pick_cd =  $24
   SET req4250785->followup_range_cd =  $25
   SET req4250785->address_id =  $26
   SET req4250785->phone_id =  $27
   SET req4250785->followup_needed_ind =  $28
   SET req4250785->recipient_long_text_id =  $29
   SET req4250785->recipient_long_text = result->recipient
   CALL echorecord(req4250785)
   EXECUTE fndis_upd_multi_followup  WITH replace("REQUEST","REQ4250785"), replace("REPLY",
    "REP4250785")
   CALL echorecord(rep4250785)
   IF ((rep4250785->status_data.status="S"))
    SET result->pat_ed_doc_id = rep4250785->pat_ed_doc_id
    SET result->pat_ed_followup_id = rep4250785->pat_ed_followup_id
    SET result->cmt_long_text_id = rep4250785->cmt_long_text_id
    SET result->add_long_text_id = rep4250785->add_long_text_id
    SET result->recipient_long_text_id = rep4250785->recipient_long_text_id
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
END GO
