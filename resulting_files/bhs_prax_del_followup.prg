CREATE PROGRAM bhs_prax_del_followup
 FREE RECORD result
 RECORD result(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE calldeleteprogram(null) = i2
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 SET result->status_data.status = "F"
 IF (( $2 <= 0.0))
  CALL echo("INVALID FOLLOWUP ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SET stat = calldeleteprogram(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 CALL echorecord(result)
 IF (size(trim(moutputdevice,3)) > 0)
  DECLARE v1 = vc WITH protect, noconstant("")
  SELECT INTO value(moutputdevice)
   FROM dummyt d
   PLAN (d
    WHERE d.seq > 0)
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1, v1 = build("<Status>",result->status_data.status,"</Status>"), col + 1,
    v1, row + 1, col + 1,
    "</ReplyMessage>", row + 1
   WITH maxcol = 32000, nocounter, nullreport,
    formfeed = none, format = variable, time = 30
  ;end select
 ENDIF
 FREE RECORD result
 FREE RECORD req4250785
 FREE RECORD rep4250785
 SUBROUTINE calldeleteprogram(null)
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
   SET req4250785->task_flag = 0
   SET req4250785->pat_ed_followup_id =  $2
   CALL echorecord(req4250785)
   EXECUTE fndis_upd_multi_followup  WITH replace("REQUEST","REQ4250785"), replace("REPLY",
    "REP4250785")
   CALL echorecord(rep4250785)
   IF ((rep4250785->status_data.status="S"))
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
END GO
