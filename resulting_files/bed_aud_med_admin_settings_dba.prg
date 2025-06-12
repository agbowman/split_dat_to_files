CREATE PROGRAM bed_aud_med_admin_settings:dba
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
   1 positions[*]
     2 display = vc
     2 tasks[*]
       3 type = vc
 )
 SET reply->run_status_flag = 1
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SET total_positions = 0
  SET pcnt = 0
  SELECT INTO "NL:"
   FROM code_value cv_psn,
    detail_prefs dp,
    name_value_prefs nvp,
    order_task_position_xref otpx,
    order_task ot,
    code_value cv_type
   PLAN (cv_psn
    WHERE cv_psn.code_set=88
     AND cv_psn.active_ind=1)
    JOIN (dp
    WHERE dp.position_cd=cv_psn.code_value
     AND dp.application_number=600005
     AND dp.view_name="MAR"
     AND dp.comp_name="MAR"
     AND dp.active_ind=1)
    JOIN (nvp
    WHERE nvp.parent_entity_id=dp.detail_prefs_id
     AND nvp.parent_entity_name="DETAIL_PREFS"
     AND nvp.pvc_name="DIRECT_CHARTING"
     AND nvp.active_ind=1)
    JOIN (otpx
    WHERE otpx.position_cd=cv_psn.code_value)
    JOIN (ot
    WHERE ot.reference_task_id=otpx.reference_task_id
     AND ot.active_ind=1)
    JOIN (cv_type
    WHERE cv_type.code_value=ot.task_type_cd
     AND cv_type.cdf_meaning IN ("MED", "IV")
     AND cv_type.active_ind=1)
   ORDER BY cv_psn.code_value, cv_type.code_value
   HEAD cv_psn.code_value
    high_volume_cnt = high_volume_cnt
   HEAD cv_type.code_value
    IF (nvp.pvc_value="0")
     high_volume_cnt = (high_volume_cnt+ 1)
    ENDIF
   WITH nocounter
  ;end select
  CALL echo(build("********** high_volume_cnt = ",high_volume_cnt))
  IF (high_volume_cnt > 60000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 30000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET total_positions = 0
 SET pcnt = 0
 SELECT INTO "NL:"
  FROM code_value cv_psn,
   detail_prefs dp,
   name_value_prefs nvp,
   order_task_position_xref otpx,
   order_task ot,
   code_value cv_type
  PLAN (cv_psn
   WHERE cv_psn.code_set=88
    AND cv_psn.active_ind=1)
   JOIN (dp
   WHERE dp.position_cd=cv_psn.code_value
    AND dp.application_number=600005
    AND dp.view_name="MAR"
    AND dp.comp_name="MAR"
    AND dp.active_ind=1)
   JOIN (nvp
   WHERE nvp.parent_entity_id=dp.detail_prefs_id
    AND nvp.parent_entity_name="DETAIL_PREFS"
    AND nvp.pvc_name="DIRECT_CHARTING"
    AND nvp.active_ind=1)
   JOIN (otpx
   WHERE otpx.position_cd=cv_psn.code_value)
   JOIN (ot
   WHERE ot.reference_task_id=otpx.reference_task_id
    AND ot.active_ind=1)
   JOIN (cv_type
   WHERE cv_type.code_value=ot.task_type_cd
    AND cv_type.cdf_meaning IN ("MED", "IV")
    AND cv_type.active_ind=1)
  ORDER BY cv_psn.display, cv_type.display, cv_psn.code_value,
   cv_type.code_value
  HEAD cv_psn.code_value
   total_positions = (total_positions+ 1)
   IF (nvp.pvc_value="0")
    pcnt = (pcnt+ 1), stat = alterlist(temp->positions,pcnt), temp->positions[pcnt].display = cv_psn
    .display,
    tcnt = 0
   ENDIF
  HEAD cv_type.code_value
   IF (nvp.pvc_value="0")
    tcnt = (tcnt+ 1), stat = alterlist(temp->positions[pcnt].tasks,tcnt), temp->positions[pcnt].
    tasks[tcnt].type = cv_type.display
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,2)
 SET reply->collist[1].header_text = "Position"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Task Type"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET row_nbr = 0
 IF (pcnt > 0)
  FOR (p = 1 TO pcnt)
   SET tcnt = size(temp->positions[p].tasks,5)
   FOR (t = 1 TO tcnt)
     SET row_nbr = (row_nbr+ 1)
     SET stat = alterlist(reply->rowlist,row_nbr)
     SET stat = alterlist(reply->rowlist[row_nbr].celllist,2)
     SET reply->rowlist[row_nbr].celllist[1].string_value = temp->positions[p].display
     SET reply->rowlist[row_nbr].celllist[2].string_value = temp->positions[p].tasks[t].type
   ENDFOR
  ENDFOR
 ENDIF
 IF (row_nbr > 0)
  SET reply->run_status_flag = 3
 ELSE
  SET reply->run_status_flag = 1
 ENDIF
 SET stat = alterlist(reply->statlist,1)
 SET reply->statlist[1].statistic_meaning = "PSNMEDADMINSET"
 SET reply->statlist[1].total_items = total_positions
 SET reply->statlist[1].qualifying_items = pcnt
 IF (pcnt > 0)
  SET reply->statlist[1].status_flag = 3
 ELSE
  SET reply->statlist[1].status_flag = 1
 ENDIF
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("positions_med_admin_chart_settings.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
