CREATE PROGRAM bed_aud_pt_association:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 positions[*]
      2 position_code_value = f8
    1 tasks[*]
      2 task_id = f8
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
 FREE RECORD temp_tasks
 RECORD temp_tasks(
   1 qual[*]
     2 task_type = vc
     2 task_desc = vc
     2 pos_to_chart = vc
     2 all_pos = vc
     2 pos_code_value = f8
     2 task_id = f8
 )
 SET colnum = 4
 SET stat = alterlist(reply->collist,colnum)
 SET reply->collist[1].header_text = "Task Type"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Task Description"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Position to Chart Task"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "All Positions Can Chart this Task"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET task_size = size(request->tasks,5)
 SET pos_size = size(request->positions,5)
 IF (task_size=0
  AND pos_size=0)
  SELECT INTO "nl:"
   cv.display, ot.task_description, cv2.display,
   ot.allpositionchart_ind
   FROM order_task ot,
    code_value cv,
    code_value cv2,
    order_task_position_xref ox
   PLAN (ot
    WHERE ot.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=ot.task_type_cd
     AND cv.active_ind=1)
    JOIN (ox
    WHERE ox.reference_task_id=outerjoin(ot.reference_task_id))
    JOIN (cv2
    WHERE cv2.code_value=outerjoin(ox.position_cd))
   ORDER BY cv.display_key, ot.task_description_key, cv2.display_key
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(reply->rowlist,cnt), stat = alterlist(reply->rowlist[cnt].
     celllist,colnum),
    reply->rowlist[cnt].celllist[1].string_value = cv.display, reply->rowlist[cnt].celllist[2].
    string_value = ot.task_description
    IF (cv2.code_value=0
     AND ot.allpositionchart_ind=1)
     reply->rowlist[cnt].celllist[3].string_value = "All"
    ELSEIF (cv2.code_value > 0)
     reply->rowlist[cnt].celllist[3].string_value = cv2.display
    ENDIF
    IF (ot.allpositionchart_ind=0)
     reply->rowlist[cnt].celllist[4].string_value = "No"
    ELSE
     reply->rowlist[cnt].celllist[4].string_value = "Yes"
    ENDIF
   WITH nocounter
  ;end select
 ELSEIF (task_size > 0
  AND pos_size=0)
  CALL echo("SOME TASKS AND NO POSITIONS")
  SELECT INTO "nl:"
   cv.display, ot.task_description, cv2.display,
   ot.allpositionchart_ind
   FROM order_task ot,
    code_value cv,
    code_value cv2,
    order_task_position_xref ox,
    (dummyt d  WITH seq = value(task_size))
   PLAN (d)
    JOIN (ot
    WHERE (ot.reference_task_id=request->tasks[d.seq].task_id)
     AND ot.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=ot.task_type_cd
     AND cv.active_ind=1)
    JOIN (ox
    WHERE ox.reference_task_id=outerjoin(ot.reference_task_id))
    JOIN (cv2
    WHERE cv2.code_value=outerjoin(ox.position_cd)
     AND  NOT (cv2.code_value=0
     AND ot.allpositionchart_ind=0))
   ORDER BY cv.display_key, ot.task_description_key, cv2.display_key
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(reply->rowlist,cnt), stat = alterlist(reply->rowlist[cnt].
     celllist,colnum),
    reply->rowlist[cnt].celllist[1].string_value = cv.display, reply->rowlist[cnt].celllist[2].
    string_value = ot.task_description
    IF (cv2.code_value=0
     AND ot.allpositionchart_ind=1)
     reply->rowlist[cnt].celllist[3].string_value = "All"
    ELSEIF (cv2.code_value > 0)
     reply->rowlist[cnt].celllist[3].string_value = cv2.display
    ENDIF
    IF (ot.allpositionchart_ind=0)
     reply->rowlist[cnt].celllist[4].string_value = "No"
    ELSE
     reply->rowlist[cnt].celllist[4].string_value = "Yes"
    ENDIF
   WITH nocounter
  ;end select
 ELSEIF (pos_size > 0
  AND task_size=0)
  SELECT INTO "nl:"
   cv.display, ot.task_description, ot.allpositionchart_ind
   FROM order_task ot,
    code_value cv
   PLAN (ot
    WHERE ot.allpositionchart_ind=1
     AND ot.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=ot.task_type_cd
     AND cv.active_ind=1)
   HEAD REPORT
    cnt = size(temp_tasks->qual,5)
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(temp_tasks->qual,cnt), temp_tasks->qual[cnt].task_type = cv
    .display,
    temp_tasks->qual[cnt].task_desc = ot.task_description, temp_tasks->qual[cnt].pos_to_chart = "All",
    temp_tasks->qual[cnt].all_pos = "Yes",
    temp_tasks->qual[cnt].pos_code_value = ot.allpositionchart_ind, temp_tasks->qual[cnt].task_id =
    ot.reference_task_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   cv.display, ot.task_description, cv2.display,
   ot.allpositionchart_ind
   FROM order_task ot,
    code_value cv,
    code_value cv2,
    order_task_position_xref ox,
    (dummyt d  WITH seq = value(pos_size))
   PLAN (d)
    JOIN (ox
    WHERE (ox.position_cd=request->positions[d.seq].position_code_value))
    JOIN (ot
    WHERE ot.reference_task_id=ox.reference_task_id
     AND ot.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=ot.task_type_cd
     AND cv.active_ind=1)
    JOIN (cv2
    WHERE cv2.code_value=ox.position_cd)
   HEAD REPORT
    cnt = size(temp_tasks->qual,5)
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(temp_tasks->qual,cnt), temp_tasks->qual[cnt].task_type = cv
    .display,
    temp_tasks->qual[cnt].task_desc = ot.task_description
    IF (cv2.code_value=0
     AND ot.allpositionchart_ind=1)
     temp_tasks->qual[cnt].pos_to_chart = "All"
    ELSEIF (cv2.code_value > 0)
     temp_tasks->qual[cnt].pos_to_chart = cv2.display
    ENDIF
    IF (ot.allpositionchart_ind=0)
     temp_tasks->qual[cnt].all_pos = "No"
    ELSE
     temp_tasks->qual[cnt].all_pos = "Yes"
    ENDIF
    temp_tasks->qual[cnt].task_id = ot.reference_task_id, temp_tasks->qual[cnt].pos_code_value = ox
    .position_cd
   WITH nocounter
  ;end select
  SET temp_tasks_size = size(temp_tasks->qual,5)
  IF (temp_tasks_size > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = temp_tasks_size),
     order_task ot,
     code_value cv,
     code_value cv2
    PLAN (d)
     JOIN (ot
     WHERE (ot.reference_task_id=temp_tasks->qual[d.seq].task_id))
     JOIN (cv
     WHERE (cv.code_value=temp_tasks->qual[d.seq].pos_code_value))
     JOIN (cv2
     WHERE cv2.code_value=ot.task_activity_cd)
    ORDER BY cv.display_key, ot.task_description_key, cv2.display_key
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1), stat = alterlist(reply->rowlist,cnt), stat = alterlist(reply->rowlist[cnt].
      celllist,colnum),
     reply->rowlist[cnt].celllist[1].string_value = temp_tasks->qual[d.seq].task_type, reply->
     rowlist[cnt].celllist[2].string_value = temp_tasks->qual[d.seq].task_desc, reply->rowlist[cnt].
     celllist[3].string_value = temp_tasks->qual[d.seq].pos_to_chart,
     reply->rowlist[cnt].celllist[4].string_value = temp_tasks->qual[d.seq].all_pos
    WITH nocounter
   ;end select
  ENDIF
 ELSE
  SELECT INTO "nl:"
   cv.display, ot.task_description, ot.allpositionchart_ind
   FROM (dummyt d  WITH seq = task_size),
    order_task ot,
    code_value cv
   PLAN (d)
    JOIN (ot
    WHERE (ot.reference_task_id=request->tasks[d.seq].task_id)
     AND ot.allpositionchart_ind=1
     AND ot.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=ot.task_type_cd
     AND cv.active_ind=1)
   HEAD REPORT
    cnt = size(temp_tasks->qual,5)
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(temp_tasks->qual,cnt), temp_tasks->qual[cnt].task_type = cv
    .display,
    temp_tasks->qual[cnt].task_desc = ot.task_description, temp_tasks->qual[cnt].pos_to_chart = "All",
    temp_tasks->qual[cnt].all_pos = "Yes",
    temp_tasks->qual[cnt].pos_code_value = ot.allpositionchart_ind, temp_tasks->qual[cnt].task_id =
    ot.reference_task_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   cv.display, ot.task_description, cv2.display,
   ot.allpositionchart_ind
   FROM (dummyt d  WITH seq = task_size),
    order_task ot,
    code_value cv,
    code_value cv2,
    order_task_position_xref ox
   PLAN (d)
    JOIN (ot
    WHERE (ot.reference_task_id=request->tasks[d.seq].task_id)
     AND ot.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=ot.task_type_cd
     AND cv.active_ind=1)
    JOIN (ox
    WHERE ox.reference_task_id=ot.reference_task_id)
    JOIN (cv2
    WHERE cv2.code_value=ox.position_cd)
   HEAD REPORT
    cnt = size(temp_tasks->qual,5), num = 0
   DETAIL
    pos = 0, pos = locateval(num,1,pos_size,ox.position_cd,request->positions[num].
     position_code_value)
    IF (pos > 0)
     cnt = (cnt+ 1), stat = alterlist(temp_tasks->qual,cnt), temp_tasks->qual[cnt].task_type = cv
     .display,
     temp_tasks->qual[cnt].task_desc = ot.task_description
     IF (cv2.code_value=0
      AND ot.allpositionchart_ind=1)
      temp_tasks->qual[cnt].pos_to_chart = "All"
     ELSEIF (cv2.code_value > 0)
      temp_tasks->qual[cnt].pos_to_chart = cv2.display
     ENDIF
     IF (ot.allpositionchart_ind=0)
      temp_tasks->qual[cnt].all_pos = "No"
     ELSE
      temp_tasks->qual[cnt].all_pos = "Yes"
     ENDIF
     temp_tasks->qual[cnt].task_id = ot.reference_task_id, temp_tasks->qual[cnt].pos_code_value = ox
     .position_cd
    ENDIF
   WITH nocounter
  ;end select
  SET temp_tasks_size = size(temp_tasks->qual,5)
  IF (temp_tasks_size > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = temp_tasks_size),
     order_task ot,
     code_value cv,
     code_value cv2
    PLAN (d)
     JOIN (ot
     WHERE (ot.reference_task_id=temp_tasks->qual[d.seq].task_id))
     JOIN (cv
     WHERE (cv.code_value=temp_tasks->qual[d.seq].pos_code_value))
     JOIN (cv2
     WHERE cv2.code_value=ot.task_activity_cd)
    ORDER BY cv.display_key, ot.task_description_key, cv2.display_key
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1), stat = alterlist(reply->rowlist,cnt), stat = alterlist(reply->rowlist[cnt].
      celllist,colnum),
     reply->rowlist[cnt].celllist[1].string_value = temp_tasks->qual[d.seq].task_type, reply->
     rowlist[cnt].celllist[2].string_value = temp_tasks->qual[d.seq].task_desc, reply->rowlist[cnt].
     celllist[3].string_value = temp_tasks->qual[d.seq].pos_to_chart,
     reply->rowlist[cnt].celllist[4].string_value = temp_tasks->qual[d.seq].all_pos
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SET high_volume_cnt = size(reply->rowlist,5)
 IF ((request->skip_volume_check_ind=0))
  IF (high_volume_cnt > 10000)
   SET reply->high_volume_flag = 2
   SET stat = alterlist(reply->rowlist,0)
   SET stat = alterlist(reply->collist,0)
   GO TO exit_script
  ELSEIF (high_volume_cnt > 5000)
   SET reply->high_volume_flag = 1
   SET stat = alterlist(reply->rowlist,0)
   SET stat = alterlist(reply->collist,0)
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("position_tasks_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
