CREATE PROGRAM bed_aud_cn_ord_task_pform_assn:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 paramlist[*]
      2 param_type_mean = vc
      2 pdate1 = dq8
      2 pdate2 = dq8
      2 vlist[*]
        3 dbl_value = f8
        3 string_value = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 FREE RECORD temp
 RECORD temp(
   1 tcnt = i2
   1 tqual[*]
     2 catalog_type = vc
     2 primary_synonym = vc
     2 syn_active_ind = i2
     2 task_desc = vc
     2 task_active_ind = i2
     2 chart_as_done_ind = i2
     2 capture_bill_ind = i2
     2 quick_chart_ind = i2
     2 ignore_rel_fields_ind = i2
     2 task_overdue_time = vc
     2 task_overdue_units = vc
     2 task_retain_time = vc
     2 task_retain_units = vc
     2 task_type = vc
     2 task_activity = vc
     2 task_resched_time = i4
     2 task_grace_period = i4
     2 all_pos_to_chart_ind = i2
     2 task_event = vc
     2 powerform_name = vc
 )
 DECLARE medtask = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6026
    AND cv.cdf_meaning="MED"
    AND cv.active_ind=1)
  DETAIL
   medtask = cv.code_value
  WITH nocounter
 ;end select
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM order_task ot,
    order_task_xref otx,
    order_catalog oc
   PLAN (ot
    WHERE ot.task_type_cd != medtask)
    JOIN (otx
    WHERE otx.reference_task_id=outerjoin(ot.reference_task_id))
    JOIN (oc
    WHERE oc.catalog_cd=outerjoin(otx.catalog_cd))
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 5000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 3000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET tcnt = 0
 SELECT INTO "NL:"
  FROM order_task ot,
   order_task_xref otx,
   order_catalog oc,
   code_value cv1,
   code_value cv2,
   code_value cv3,
   code_value cv4,
   dcp_forms_ref dfr
  PLAN (ot
   WHERE ot.task_type_cd != medtask)
   JOIN (otx
   WHERE otx.reference_task_id=outerjoin(ot.reference_task_id))
   JOIN (oc
   WHERE oc.catalog_cd=outerjoin(otx.catalog_cd))
   JOIN (cv1
   WHERE cv1.code_value=outerjoin(oc.catalog_type_cd)
    AND cv1.active_ind=outerjoin(1))
   JOIN (cv2
   WHERE cv2.code_value=outerjoin(ot.task_type_cd)
    AND cv2.active_ind=outerjoin(1))
   JOIN (cv3
   WHERE cv3.code_value=outerjoin(ot.task_activity_cd)
    AND cv3.active_ind=outerjoin(1))
   JOIN (cv4
   WHERE cv4.code_value=outerjoin(ot.event_cd)
    AND cv4.active_ind=outerjoin(1))
   JOIN (dfr
   WHERE dfr.dcp_forms_ref_id=outerjoin(ot.dcp_forms_ref_id)
    AND dfr.active_ind=outerjoin(1))
  ORDER BY cv1.display, oc.primary_mnemonic, ot.task_description
  DETAIL
   tcnt = (tcnt+ 1), temp->tcnt = tcnt, stat = alterlist(temp->tqual,tcnt),
   temp->tqual[tcnt].catalog_type = cv1.display, temp->tqual[tcnt].primary_synonym = oc
   .primary_mnemonic, temp->tqual[tcnt].syn_active_ind = oc.active_ind,
   temp->tqual[tcnt].task_desc = ot.task_description, temp->tqual[tcnt].task_active_ind = ot
   .active_ind, temp->tqual[tcnt].chart_as_done_ind = ot.quick_chart_done_ind,
   temp->tqual[tcnt].capture_bill_ind = ot.capture_bill_info_ind, temp->tqual[tcnt].quick_chart_ind
    = ot.quick_chart_ind, temp->tqual[tcnt].ignore_rel_fields_ind = ot.ignore_req_ind
   IF (ot.overdue_min > 0)
    temp->tqual[tcnt].task_overdue_time = cnvtstring(ot.overdue_min)
   ELSE
    temp->tqual[tcnt].task_overdue_time = " "
   ENDIF
   IF (ot.overdue_units=1)
    temp->tqual[tcnt].task_overdue_units = "Minutes"
   ELSEIF (ot.overdue_units=2)
    temp->tqual[tcnt].task_overdue_units = "Hours"
   ELSE
    temp->tqual[tcnt].task_overdue_units = " "
   ENDIF
   IF (ot.retain_time > 0)
    temp->tqual[tcnt].task_retain_time = cnvtstring(ot.retain_time)
   ELSE
    temp->tqual[tcnt].task_retain_time = " "
   ENDIF
   IF (ot.retain_units=1)
    temp->tqual[tcnt].task_retain_units = "Minutes"
   ELSEIF (ot.retain_units=2)
    temp->tqual[tcnt].task_retain_units = "Hours"
   ELSEIF (ot.retain_units=3)
    temp->tqual[tcnt].task_retain_units = "Days"
   ELSEIF (ot.retain_units=4)
    temp->tqual[tcnt].task_retain_units = "Weeks"
   ELSEIF (ot.retain_units=5)
    temp->tqual[tcnt].task_retain_units = "Months"
   ELSE
    temp->tqual[tcnt].task_retain_units = " "
   ENDIF
   temp->tqual[tcnt].task_type = cv2.display, temp->tqual[tcnt].task_activity = cv3.display, temp->
   tqual[tcnt].task_resched_time = ot.reschedule_time,
   temp->tqual[tcnt].task_grace_period = ot.grace_period_mins, temp->tqual[tcnt].all_pos_to_chart_ind
    = ot.allpositionchart_ind, temp->tqual[tcnt].task_event = cv4.display,
   temp->tqual[tcnt].powerform_name = dfr.description
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,20)
 SET reply->collist[1].header_text = "Catalog Type"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Millennium Name (Primary Synonym)"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Millennium Name (Primary Synonym) Active Indicator"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Task Description"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Task Active Indicator"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Chart as Done"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Capture Billing"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Quick Chart"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Ignore Required Fields"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Task Overdue Time"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Task Overdue Units"
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "Task Retain Time"
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = "Task Retain Units"
 SET reply->collist[13].data_type = 1
 SET reply->collist[13].hide_ind = 0
 SET reply->collist[14].header_text = "Task Type"
 SET reply->collist[14].data_type = 1
 SET reply->collist[14].hide_ind = 0
 SET reply->collist[15].header_text = "Task Activity"
 SET reply->collist[15].data_type = 1
 SET reply->collist[15].hide_ind = 0
 SET reply->collist[16].header_text = "Task Reschedule Time (Hours)"
 SET reply->collist[16].data_type = 3
 SET reply->collist[16].hide_ind = 0
 SET reply->collist[17].header_text = "Task Grace Period (Minutes)"
 SET reply->collist[17].data_type = 3
 SET reply->collist[17].hide_ind = 0
 SET reply->collist[18].header_text = "Task All Positions to Chart"
 SET reply->collist[18].data_type = 1
 SET reply->collist[18].hide_ind = 0
 SET reply->collist[19].header_text = "Task Event Code"
 SET reply->collist[19].data_type = 1
 SET reply->collist[19].hide_ind = 0
 SET reply->collist[20].header_text = "PowerForm Name"
 SET reply->collist[20].data_type = 1
 SET reply->collist[20].hide_ind = 0
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,20)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].catalog_type
   SET reply->rowlist[row_nbr].celllist[2].string_value = temp->tqual[x].primary_synonym
   IF ((temp->tqual[x].syn_active_ind=1))
    SET reply->rowlist[row_nbr].celllist[3].string_value = "X"
   ELSE
    SET reply->rowlist[row_nbr].celllist[3].string_value = " "
   ENDIF
   SET reply->rowlist[row_nbr].celllist[4].string_value = temp->tqual[x].task_desc
   IF ((temp->tqual[x].task_active_ind=1))
    SET reply->rowlist[row_nbr].celllist[5].string_value = "X"
   ELSE
    SET reply->rowlist[row_nbr].celllist[5].string_value = " "
   ENDIF
   IF ((temp->tqual[x].chart_as_done_ind=1))
    SET reply->rowlist[row_nbr].celllist[6].string_value = "X"
   ELSE
    SET reply->rowlist[row_nbr].celllist[6].string_value = " "
   ENDIF
   IF ((temp->tqual[x].capture_bill_ind=1))
    SET reply->rowlist[row_nbr].celllist[7].string_value = "X"
   ELSE
    SET reply->rowlist[row_nbr].celllist[7].string_value = " "
   ENDIF
   IF ((temp->tqual[x].quick_chart_ind=1))
    SET reply->rowlist[row_nbr].celllist[8].string_value = "X"
   ELSE
    SET reply->rowlist[row_nbr].celllist[8].string_value = " "
   ENDIF
   IF ((temp->tqual[x].ignore_rel_fields_ind=1))
    SET reply->rowlist[row_nbr].celllist[9].string_value = "X"
   ELSE
    SET reply->rowlist[row_nbr].celllist[9].string_value = " "
   ENDIF
   SET reply->rowlist[row_nbr].celllist[10].string_value = temp->tqual[x].task_overdue_time
   SET reply->rowlist[row_nbr].celllist[11].string_value = temp->tqual[x].task_overdue_units
   SET reply->rowlist[row_nbr].celllist[12].string_value = temp->tqual[x].task_retain_time
   SET reply->rowlist[row_nbr].celllist[13].string_value = temp->tqual[x].task_retain_units
   SET reply->rowlist[row_nbr].celllist[14].string_value = temp->tqual[x].task_type
   SET reply->rowlist[row_nbr].celllist[15].string_value = temp->tqual[x].task_activity
   SET reply->rowlist[row_nbr].celllist[16].nbr_value = temp->tqual[x].task_resched_time
   SET reply->rowlist[row_nbr].celllist[17].nbr_value = temp->tqual[x].task_grace_period
   IF ((temp->tqual[x].all_pos_to_chart_ind=1))
    SET reply->rowlist[row_nbr].celllist[18].string_value = "X"
   ELSE
    SET reply->rowlist[row_nbr].celllist[18].string_value = " "
   ENDIF
   SET reply->rowlist[row_nbr].celllist[19].string_value = temp->tqual[x].task_event
   SET reply->rowlist[row_nbr].celllist[20].string_value = temp->tqual[x].powerform_name
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("cn_ord_task_powerform_assn.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
