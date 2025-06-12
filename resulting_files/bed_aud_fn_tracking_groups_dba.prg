CREATE PROGRAM bed_aud_fn_tracking_groups:dba
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
     2 description = vc
     2 meaning = vc
     2 active = vc
     2 track_name_format_cd = vc
     2 track_reltn_cd = vc
     2 bed_status_dirty_cd = vc
     2 pm_menu_min_task_id = vc
     2 pm_menu_max_task_id = vc
     2 pm_button_min_task_id = vc
     2 pm_button_max_task_id = vc
     2 filter_count_meaning = vc
     2 def_manuf_type_cd = vc
     2 def_track_sensor_id = vc
     2 checkout_valid_script = vc
 )
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM code_value cv
   WHERE cv.code_set=16370
    AND cv.cdf_meaning="ER"
    AND cv.active_ind=1
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
  FROM code_value cv,
   code_value_extension cve1,
   code_value_extension cve2,
   code_value_extension cve3,
   code_value_extension cve4,
   code_value_extension cve5,
   code_value_extension cve6,
   code_value_extension cve7,
   code_value_extension cve8,
   code_value_extension cve9,
   code_value_extension cve10,
   code_value_extension cve11,
   code_value cv1,
   code_value cv2,
   code_value cv3,
   code_value cv4
  PLAN (cv
   WHERE cv.code_set=16370
    AND cv.cdf_meaning="ER"
    AND cv.active_ind=1)
   JOIN (cve1
   WHERE cve1.code_value=cv.code_value
    AND cve1.field_name="Tracking Name Format Cd")
   JOIN (cve2
   WHERE cve2.code_value=cv.code_value
    AND cve2.field_name="Tracking Relation Cd")
   JOIN (cve3
   WHERE cve3.code_value=cv.code_value
    AND cve3.field_name="Bed Status Dirty Cd")
   JOIN (cve4
   WHERE cve4.code_value=cv.code_value
    AND cve4.field_name="PM Menu Min Task Id")
   JOIN (cve5
   WHERE cve5.code_value=cv.code_value
    AND cve5.field_name="PM Menu Max Task Id")
   JOIN (cve6
   WHERE cve6.code_value=cv.code_value
    AND cve6.field_name="PM Button Min Task Id")
   JOIN (cve7
   WHERE cve7.code_value=cv.code_value
    AND cve7.field_name="PM Button Max Task Id")
   JOIN (cve8
   WHERE cve8.code_value=cv.code_value
    AND cve8.field_name="Filter Count Meaning")
   JOIN (cve9
   WHERE cve9.code_value=cv.code_value
    AND cve9.field_name="Def Manuf Type Cd")
   JOIN (cve10
   WHERE cve10.code_value=cv.code_value
    AND cve10.field_name="Def Tracking Sensor Id")
   JOIN (cve11
   WHERE cve11.code_value=cv.code_value
    AND cve11.field_name="Checkout Validation Script")
   JOIN (cv1
   WHERE cv1.code_value=outerjoin(cnvtreal(cve1.field_value))
    AND cv1.active_ind=outerjoin(1))
   JOIN (cv2
   WHERE cv2.code_value=outerjoin(cnvtreal(cve2.field_value))
    AND cv2.active_ind=outerjoin(1))
   JOIN (cv3
   WHERE cv3.code_value=outerjoin(cnvtreal(cve3.field_value))
    AND cv3.active_ind=outerjoin(1))
   JOIN (cv4
   WHERE cv4.code_value=outerjoin(cnvtreal(cve9.field_value))
    AND cv4.active_ind=outerjoin(1))
  ORDER BY cv.description
  DETAIL
   tcnt = (tcnt+ 1), temp->tcnt = tcnt, stat = alterlist(temp->tqual,tcnt),
   temp->tqual[tcnt].description = cv.description, temp->tqual[tcnt].meaning = cv.cdf_meaning
   IF (cv.active_ind=1)
    temp->tqual[tcnt].active = "X"
   ENDIF
   temp->tqual[tcnt].track_name_format_cd = cv1.display, temp->tqual[tcnt].track_reltn_cd = cv2
   .display, temp->tqual[tcnt].bed_status_dirty_cd = cv3.display,
   temp->tqual[tcnt].pm_menu_min_task_id = cve4.field_value, temp->tqual[tcnt].pm_menu_max_task_id =
   cve5.field_value, temp->tqual[tcnt].pm_button_min_task_id = cve6.field_value,
   temp->tqual[tcnt].pm_button_max_task_id = cve7.field_value, temp->tqual[tcnt].filter_count_meaning
    = cve8.field_value, temp->tqual[tcnt].def_manuf_type_cd = cv4.display,
   temp->tqual[tcnt].def_track_sensor_id = cve10.field_value, temp->tqual[tcnt].checkout_valid_script
    = cve11.field_value
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,14)
 SET reply->collist[1].header_text = "Tracking Group Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Meaning"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Active"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Tracking Name Format"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Tracking Relation"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Bed Status Dirty"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "PM Menu Min Task ID"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "PM Menu Max Task ID"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "PM Button Min Task ID"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "PM Button Max Task ID"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Filter Count Meaning"
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "Default Manufacturer Type"
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = "Default Tracking Sensor ID"
 SET reply->collist[13].data_type = 1
 SET reply->collist[13].hide_ind = 0
 SET reply->collist[14].header_text = "Checkout Validation Script"
 SET reply->collist[14].data_type = 1
 SET reply->collist[14].hide_ind = 0
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,14)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].description
   SET reply->rowlist[row_nbr].celllist[2].string_value = temp->tqual[x].meaning
   SET reply->rowlist[row_nbr].celllist[3].string_value = temp->tqual[x].active
   SET reply->rowlist[row_nbr].celllist[4].string_value = temp->tqual[x].track_name_format_cd
   SET reply->rowlist[row_nbr].celllist[5].string_value = temp->tqual[x].track_reltn_cd
   SET reply->rowlist[row_nbr].celllist[6].string_value = temp->tqual[x].bed_status_dirty_cd
   SET reply->rowlist[row_nbr].celllist[7].string_value = temp->tqual[x].pm_menu_min_task_id
   SET reply->rowlist[row_nbr].celllist[8].string_value = temp->tqual[x].pm_menu_max_task_id
   SET reply->rowlist[row_nbr].celllist[9].string_value = temp->tqual[x].pm_button_min_task_id
   SET reply->rowlist[row_nbr].celllist[10].string_value = temp->tqual[x].pm_button_max_task_id
   SET reply->rowlist[row_nbr].celllist[11].string_value = temp->tqual[x].filter_count_meaning
   SET reply->rowlist[row_nbr].celllist[12].string_value = temp->tqual[x].def_manuf_type_cd
   SET reply->rowlist[row_nbr].celllist[13].string_value = temp->tqual[x].def_track_sensor_id
   SET reply->rowlist[row_nbr].celllist[14].string_value = temp->tqual[x].checkout_valid_script
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("fn_tracking_groups_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
