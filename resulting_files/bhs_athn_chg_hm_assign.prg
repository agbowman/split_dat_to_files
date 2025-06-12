CREATE PROGRAM bhs_athn_chg_hm_assign
 FREE RECORD result
 RECORD result(
   1 comment = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE callchgprogram(null) = i2
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 SET result->status_data.status = "F"
 IF (( $2 <= 0.0))
  CALL echo("INVALID PERSON ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $3 <= 0.0))
  CALL echo("INVALID PERSONNEL ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $4 <= 0.0))
  CALL echo("INVALID RECOMMENDATION ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $14 <= 0.0))
  CALL echo("INVALID RECORDED FOR PERSONNEL ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (cnvtint( $7) != 1
  AND cnvtint( $12) != 1)
  CALL echo("INVALID CHANGE INDICATORS PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 FREE RECORD req_format_str
 RECORD req_format_str(
   1 param = vc
 ) WITH protect
 FREE RECORD rep_format_str
 RECORD rep_format_str(
   1 param = vc
 ) WITH protect
 SET req_format_str->param =  $6
 EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
  "REP_FORMAT_STR")
 SET result->comment = rep_format_str->param
 SET stat = callchgprogram(null)
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
 FREE RECORD req966325
 FREE RECORD rep966325
 SUBROUTINE callchgprogram(null)
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
   EXECUTE bhs_athn_impersonate_user  WITH replace("REQUEST","I_REQUEST"), replace("REPLY","I_REPLY")
   IF ((i_reply->status_data.status != "S"))
    CALL echo("IMPERSONATE USER FAILED...EXITING!")
    RETURN(fail)
   ENDIF
   FREE RECORD req966325
   RECORD req966325(
     1 due_actions[*]
     1 postpone_actions[*]
     1 cancel_actions[*]
     1 satisfy_actions[*]
     1 frequency_actions[*]
       2 recommendation_id = f8
       2 restore_default = i2
       2 frequency_value = i4
       2 frequency_unit_cd = f8
       2 on_behalf_of_prsnl_id = f8
       2 reason_cd = f8
       2 comment = vc
       2 prev_frequency_value = f8
       2 prev_frequency_unit_cd = f8
       2 due_dt_tm = dq8
       2 person_id = f8
     1 due_date_actions[*]
       2 recommendation_id = f8
       2 restore_default = i2
       2 new_due_dt_tm = dq8
       2 on_behalf_of_prsnl_id = f8
       2 reason_cd = f8
       2 comment = vc
       2 prev_due_dt_tm = dq8
       2 person_id = f8
     1 assign_actions[*]
       2 person_id = f8
       2 expect_id = f8
       2 step_id = f8
       2 expectation_ftdesc = vc
       2 on_behalf_of_prsnl_id = f8
       2 reason_cd = f8
       2 comment = vc
       2 frequency_value = i4
       2 frequency_unit_cd = f8
       2 new_due_dt_tm = dq8
       2 prev_frequency_value = i4
       2 prev_frequency_unit_cd = f8
     1 undo_actions[*]
     1 assign_action_override_cnt = i4
   ) WITH protect
   FREE RECORD rep966325
   RECORD rep966325(
     1 recommendations[*]
       2 action_flag = i2
       2 recommendation_id = f8
       2 person_id = f8
       2 expect_id = f8
       2 status_flag = i2
       2 due_dt_tm = dq8
       2 first_due_dt_tm = dq8
       2 expectation_ftdesc = vc
       2 step_id = f8
     1 status_data
       2 status = c1
       2 status_value = i4
       2 subeventstatus[*]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   IF (cnvtint( $7)=1)
    SET stat = alterlist(req966325->frequency_actions,1)
    SET req966325->frequency_actions[1].recommendation_id =  $4
    SET req966325->frequency_actions[1].frequency_value =  $8
    SET req966325->frequency_actions[1].frequency_unit_cd =  $9
    SET req966325->frequency_actions[1].on_behalf_of_prsnl_id =  $14
    SET req966325->frequency_actions[1].reason_cd =  $5
    SET req966325->frequency_actions[1].comment = result->comment
    SET req966325->frequency_actions[1].prev_frequency_value =  $10
    SET req966325->frequency_actions[1].prev_frequency_unit_cd =  $11
    SET req966325->frequency_actions[1].person_id =  $2
   ENDIF
   IF (cnvtint( $12)=1)
    SET stat = alterlist(req966325->due_date_actions,1)
    SET req966325->due_date_actions[1].recommendation_id =  $4
    SET req966325->due_date_actions[1].new_due_dt_tm = cnvtdatetime( $13)
    SET req966325->due_date_actions[1].on_behalf_of_prsnl_id =  $14
    SET req966325->due_date_actions[1].reason_cd =  $5
    SET req966325->due_date_actions[1].comment = result->comment
    SET req966325->due_date_actions[1].person_id =  $2
   ENDIF
   CALL echorecord(req966325)
   EXECUTE pco_hm_redirect_modifications  WITH replace("REQUEST","REQ966325"), replace("REPLY",
    "REP966325")
   CALL echorecord(rep966325)
   IF ((rep966325->status_data.status="S"))
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
END GO
