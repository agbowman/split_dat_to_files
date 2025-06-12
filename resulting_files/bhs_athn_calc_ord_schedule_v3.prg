CREATE PROGRAM bhs_athn_calc_ord_schedule_v3
 FREE RECORD result
 RECORD result(
   1 catalog_type_cd = f8
   1 error_ind = i2
   1 requested_start_dt_tm = dq8
   1 valid_dose_dt_tm = dq8
   1 next_dose_dt_tm = dq8
   1 stop_dt_tm = dq8
   1 requested_doses[*]
     2 dose_dt_tm = dq8
   1 stop_type_cd = f8
   1 reference_start_dt_tm = dq8
   1 constant_ind = i2
   1 duration_value = f8
   1 duration_unit_cd = f8
   1 stop_type_flag = i2
   1 start_date_time_padding = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req510902
 RECORD req510902(
   1 orders[*]
     2 order_id = f8
     2 catalog_cd = f8
     2 order_type_flag = i2
     2 schedule_time_zone = i4
     2 stop_type_flag = i2
     2 conversation_start_date_time = dq8
     2 order_entry_format_id = f8
     2 triggering_action_flag = i2
     2 calculate_tod_stop_in_doses_ind = i2
     2 number_of_doses = i2
     2 new_schedule_details
       3 requested_start_date_time = dq8
       3 stop_date_time = dq8
       3 reference_start_date_time = dq8
       3 prn[*]
         4 prn_ind = i2
       3 constant[*]
         4 constant_ind = i2
       3 future[*]
         4 future_ind = i2
       3 priority
         4 priority_cd = f8
         4 collection_priority_cd = f8
         4 pharmacy_priority_cd = f8
       3 frequency[*]
         4 frequency_id = f8
         4 times_of_day[*]
           5 minutes_from_midnight = i2
       3 duration[*]
         4 value = f8
         4 unit_cd = f8
       3 move_doses[*]
         4 schedule_exception_id = f8
         4 type_flag = i2
         4 original_instance_date_time = dq8
         4 new_instance_date_time = dq8
       3 skip_doses[*]
         4 schedule_exception_id = f8
         4 type_flag = i2
         4 original_instance_date_time = dq8
       3 infuse_over_details[*]
         4 value = f8
         4 unit_cd = f8
       3 scheduling_instructions[*]
         4 offset_date_time = vc
         4 future_ind = i2
       3 default_requested_start_offset = vc
       3 default_reference_start_offset = vc
       3 default_stop_offset = vc
     2 previous_schedule_details
       3 requested_start_date_time = dq8
       3 infuse_over_details[*]
         4 value = f8
         4 unit_cd = f8
       3 priority
         4 priority_cd = f8
         4 collection_priority_cd = f8
         4 pharmacy_priority_cd = f8
       3 frequency[*]
         4 frequency_id = f8
         4 times_of_day[*]
           5 minutes_from_midnight = i2
       3 move_doses[*]
         4 schedule_exception_id = f8
         4 type_flag = i2
         4 original_instance_date_time = dq8
         4 new_instance_date_time = dq8
       3 skip_doses[*]
         4 schedule_exception_id = f8
         4 type_flag = i2
         4 original_instance_date_time = dq8
     2 encounter_id = f8
     2 start_date_time_padding = vc
 ) WITH protect
 FREE RECORD rep510902
 RECORD rep510902(
   1 transaction_status
     2 success_ind = i2
     2 debug_error_message = vc
   1 order_schedules[*]
     2 order_id = f8
     2 order[*]
       3 schedule_review_needed_ind = i2
       3 start_on_schedule_ind = i2
       3 requested_start_date_time = dq8
       3 valid_dose_date_time = dq8
       3 next_dose_date_time = dq8
       3 stop_date_time = dq8
       3 reference_start_date_time = dq8
       3 stop_type_flag = i2
       3 prn[*]
         4 prn_ind = i2
       3 constant[*]
         4 constant_ind = i2
       3 duration[*]
         4 value = f8
         4 unit_cd = f8
       3 remaining_doses_info[*]
         4 number_of_remaining_doses = i4
         4 requested_doses[*]
           5 dose_date_time = dq8
       3 move_doses[*]
         4 schedule_exception_id = f8
         4 type_flag = i2
         4 original_instance_date_time = dq8
         4 new_instance_date_time = dq8
       3 skip_doses[*]
         4 schedule_exception_id = f8
         4 type_flag = i2
         4 original_instance_date_time = dq8
       3 priority
         4 priority_cd = f8
         4 collection_priority_cd = f8
         4 pharmacy_priority_cd = f8
       3 hide_detail_value
         4 duration_ind = i2
         4 stop_date_time_ind = i2
     2 error_status[*]
       3 error_type = i2
       3 error_message = vc
       3 user_display_message = vc
 ) WITH protect
 FREE RECORD req_format_str
 RECORD req_format_str(
   1 param = vc
 ) WITH protect
 FREE RECORD rep_format_str
 RECORD rep_format_str(
   1 param = vc
 ) WITH protect
 DECLARE callcalcorderactionschedule(null) = i2
 DECLARE formatparameters(null) = i4
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE idx = i4 WITH protect, noconstant(0)
 SET result->status_data.status = "F"
 IF (( $2 <= 0.0))
  CALL echo("INVALID ENCOUNTER ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $3 <= 0.0))
  CALL echo("INVALID ORDER ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $4 <= 0.0))
  CALL echo("INVALID CATALOG CD PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  FROM order_catalog oc
  PLAN (oc
   WHERE (oc.catalog_cd= $4))
  DETAIL
   result->catalog_type_cd = oc.catalog_type_cd
  WITH nocounter
 ;end select
 SET stat = formatparameters(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET stat = callcalcorderactionschedule(null)
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
  DECLARE v7 = vc WITH protect, noconstant("")
  DECLARE v8 = vc WITH protect, noconstant("")
  DECLARE v9 = vc WITH protect, noconstant("")
  DECLARE v10 = vc WITH protect, noconstant("")
  DECLARE v11 = vc WITH protect, noconstant("")
  DECLARE v12 = vc WITH protect, noconstant("")
  DECLARE v13 = vc WITH protect, noconstant("")
  IF ((result->status_data.status="S"))
   SELECT INTO value(moutputdevice)
    FROM dummyt d
    PLAN (d
     WHERE d.seq > 0)
    HEAD REPORT
     html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
      '"',"UTF-8",'"'," ?>"), col 0, html_tag,
     row + 1, col + 1, "<ReplyMessage>",
     row + 1, v1 = build("<ErrorInd>",cnvtint(result->error_ind),"</ErrorInd>"), col + 1,
     v1, row + 1, v2 = build("<RequestedStartDate>",format(result->requested_start_dt_tm,
       "MM/DD/YYYY HH:MM:SS;;D"),"</RequestedStartDate>"),
     col + 1, v2, row + 1,
     v3 = build("<ValidDoseDate>",format(result->valid_dose_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),
      "</ValidDoseDate>"), col + 1, v3,
     row + 1, v4 = build("<NextDoseDate>",format(result->next_dose_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),
      "</NextDoseDate>"), col + 1,
     v4, row + 1, v5 = build("<StopDate>",format(result->stop_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),
      "</StopDate>"),
     col + 1, v5, row + 1,
     col + 1, "<RequestedDoses>", row + 1
     FOR (idx = 1 TO size(result->requested_doses,5))
       col + 1, "<RequestedDose>", row + 1,
       v6 = build("<DoseDate>",format(result->requested_doses[idx].dose_dt_tm,
         "MM/DD/YYYY HH:MM:SS;;D"),"</DoseDate>"), col + 1, v6,
       row + 1, col + 1, "</RequestedDose>",
       row + 1
     ENDFOR
     col + 1, "</RequestedDoses>", row + 1,
     v7 = build("<StopTypeCd>",cnvtint(result->stop_type_cd),"</StopTypeCd>"), col + 1, v7,
     row + 1, v8 = build("<StopType>",trim(replace(replace(replace(replace(replace(
            uar_get_code_display(result->stop_type_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
         "&apos;",0),'"',"&quot;",0),3),"</StopType>"), col + 1,
     v8, row + 1, v9 = build("<ReferenceStartDate>",format(result->reference_start_dt_tm,
       "MM/DD/YYYY HH:MM:SS;;D"),"</ReferenceStartDate>"),
     col + 1, v9, row + 1,
     v10 = build("<ConstantInd>",result->constant_ind,"</ConstantInd>"), col + 1, v10,
     row + 1, v11 = build("<DurationValue>",cnvtint(result->duration_value),"</DurationValue>"), col
      + 1,
     v11, row + 1, v12 = build("<DurationUnitCd>",cnvtint(result->duration_unit_cd),
      "</DurationUnitCd>"),
     col + 1, v12, row + 1,
     v13 = build("<StopTypeFlag>",result->stop_type_flag,"</StopTypeFlag>"), col + 1, v13,
     row + 1, col + 1, "</ReplyMessage>",
     row + 1
    WITH maxcol = 32000, nocounter, nullreport,
     formfeed = none, format = variable, time = 30
   ;end select
  ENDIF
 ENDIF
 FREE RECORD result
 FREE RECORD req510902
 FREE RECORD rep510902
 FREE RECORD req_format_str
 FREE RECORD rep_format_str
 SUBROUTINE callcalcorderactionschedule(null)
   DECLARE applicationid = i4 WITH protect, constant(600005)
   DECLARE taskid = i4 WITH protect, constant(3202004)
   DECLARE requestid = i4 WITH protect, constant(510902)
   DECLARE c_pharmacy_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
   DECLARE c_lab_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,"GENERAL LAB"))
   DECLARE c_drstop_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4009,"DRSTOP"))
   DECLARE c_hard_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4009,"HARD"))
   DECLARE c_soft_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4009,"SOFT"))
   SET stat = alterlist(req510902->orders,1)
   SET req510902->orders[1].order_id =  $3
   SET req510902->orders[1].catalog_cd =  $4
   SET req510902->orders[1].order_type_flag =  $5
   SET req510902->orders[1].schedule_time_zone =  $6
   SET req510902->orders[1].stop_type_flag =  $7
   IF (size(trim( $8,3)) > 0)
    SET req510902->orders[1].conversation_start_date_time = cnvtdatetime( $8)
   ENDIF
   IF (size(trim( $23,3)) > 0)
    SET req510902->orders[1].new_schedule_details.reference_start_date_time = cnvtdatetime( $23)
   ENDIF
   SET req510902->orders[1].order_entry_format_id =  $9
   SET req510902->orders[1].number_of_doses = 3
   SET req510902->orders[1].triggering_action_flag =  $19
   IF (size(trim( $17,3)) > 0)
    SET req510902->orders[1].new_schedule_details.requested_start_date_time = cnvtdatetime( $17)
   ENDIF
   IF (size(trim( $18,3)) > 0)
    SET req510902->orders[1].new_schedule_details.stop_date_time = cnvtdatetime( $18)
   ENDIF
   SET stat = alterlist(req510902->orders[1].new_schedule_details.prn,1)
   SET req510902->orders[1].new_schedule_details.prn[1].prn_ind =  $15
   SET stat = alterlist(req510902->orders[1].new_schedule_details.constant,1)
   SET req510902->orders[1].new_schedule_details.constant[1].constant_ind =  $16
   IF ((result->catalog_type_cd=c_pharmacy_cd))
    SET req510902->orders[1].new_schedule_details.priority.pharmacy_priority_cd =  $10
   ELSEIF ((result->catalog_type_cd=c_lab_cd))
    SET req510902->orders[1].new_schedule_details.priority.collection_priority_cd =  $10
   ELSE
    SET req510902->orders[1].new_schedule_details.priority.priority_cd =  $10
   ENDIF
   SET req510902->orders[1].new_schedule_details.default_requested_start_offset =  $11
   SET stat = alterlist(req510902->orders[1].new_schedule_details.duration,1)
   SET req510902->orders[1].new_schedule_details.duration[1].value =  $12
   SET req510902->orders[1].new_schedule_details.duration[1].unit_cd =  $13
   IF (( $14 > 0.0))
    SET stat = alterlist(req510902->orders[1].new_schedule_details.frequency,1)
    SET req510902->orders[1].new_schedule_details.frequency[1].frequency_id =  $14
   ENDIF
   IF (size(trim( $17,3)) > 0)
    SET req510902->orders[1].previous_schedule_details.requested_start_date_time = cnvtdatetime( $17)
   ENDIF
   IF (( $20 > 0.0))
    IF ((result->catalog_type_cd=c_pharmacy_cd))
     SET req510902->orders[1].previous_schedule_details.priority.pharmacy_priority_cd =  $20
    ELSEIF ((result->catalog_type_cd=c_lab_cd))
     SET req510902->orders[1].previous_schedule_details.priority.collection_priority_cd =  $20
    ELSE
     SET req510902->orders[1].previous_schedule_details.priority.priority_cd =  $20
    ENDIF
   ENDIF
   IF (( $21 > 0.0))
    SET stat = alterlist(req510902->orders[1].previous_schedule_details.frequency,1)
    SET req510902->orders[1].previous_schedule_details.frequency[1].frequency_id =  $21
   ENDIF
   SET req510902->orders[1].encounter_id =  $2
   SET req510902->orders[1].start_date_time_padding = result->start_date_time_padding
   CALL echorecord(req510902)
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req510902,
    "REC",rep510902,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep510902)
   IF ((rep510902->transaction_status.success_ind=1)
    AND size(rep510902->order_schedules,5) > 0)
    IF (size(rep510902->order_schedules[1].error_status,5) > 0)
     SET result->error_ind = 1
    ENDIF
    IF (size(rep510902->order_schedules[1].order,5) > 0)
     SET result->requested_start_dt_tm = rep510902->order_schedules[1].order[1].
     requested_start_date_time
     SET result->valid_dose_dt_tm = rep510902->order_schedules[1].order[1].valid_dose_date_time
     SET result->next_dose_dt_tm = rep510902->order_schedules[1].order[1].next_dose_date_time
     SET result->stop_dt_tm = rep510902->order_schedules[1].order[1].stop_date_time
     IF (size(rep510902->order_schedules[1].order[1].remaining_doses_info,5) > 0)
      SET stat = alterlist(result->requested_doses,size(rep510902->order_schedules[1].order[1].
        remaining_doses_info[1].requested_doses,5))
      FOR (idx = 1 TO size(rep510902->order_schedules[1].order[1].remaining_doses_info[1].
       requested_doses,5))
        SET result->requested_doses[idx].dose_dt_tm = rep510902->order_schedules[1].order[1].
        remaining_doses_info[1].requested_doses[idx].dose_date_time
      ENDFOR
     ENDIF
     SET result->stop_type_cd = evaluate(rep510902->order_schedules[1].order[1].stop_type_flag,1,
      c_soft_cd,2,c_hard_cd,
      3,c_drstop_cd,0.0)
     SET result->reference_start_dt_tm = rep510902->order_schedules[1].order[1].
     reference_start_date_time
     IF (size(rep510902->order_schedules[1].order[1].constant,5) > 0)
      SET result->constant_ind = rep510902->order_schedules[1].order[1].constant[1].constant_ind
     ENDIF
     IF (size(rep510902->order_schedules[1].order[1].duration,5) > 0)
      SET result->duration_value = rep510902->order_schedules[1].order[1].duration[1].value
      SET result->duration_unit_cd = rep510902->order_schedules[1].order[1].duration[1].unit_cd
     ENDIF
     SET result->stop_type_flag = rep510902->order_schedules[1].order[1].stop_type_flag
    ENDIF
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
 SUBROUTINE formatparameters(null)
  IF (textlen(trim( $22,3)))
   SET req_format_str->param =  $22
   EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
    "REP_FORMAT_STR")
   SET result->start_date_time_padding = rep_format_str->param
  ENDIF
  RETURN(success)
 END ;Subroutine
END GO
