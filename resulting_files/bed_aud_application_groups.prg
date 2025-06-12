CREATE PROGRAM bed_aud_application_groups
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
 RECORD temp(
   1 groups[*]
     2 code_value = f8
     2 display = vc
     2 applications[*]
       3 number = i4
       3 description = vc
       3 tasks[*]
         4 number = i4
         4 description = vc
         4 granted_ind = i2
 )
 DECLARE dba_app_cd = f8
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=500
   AND cv.display="DBA"
   AND cv.active_ind=1
  DETAIL
   dba_app_cd = cv.code_value
  WITH nocounter
 ;end select
 SET high_volume_cnt = 0.0
 SET gcnt = 0
 SET acnt = 0
 SELECT INTO "nl:"
  FROM code_value cv,
   application_access aa,
   application a
  PLAN (cv
   WHERE cv.code_set=500
    AND cv.code_value != dba_app_cd
    AND cv.active_ind=1)
   JOIN (aa
   WHERE aa.app_group_cd=outerjoin(cv.code_value)
    AND aa.active_ind=outerjoin(1))
   JOIN (a
   WHERE a.application_number=outerjoin(aa.application_number)
    AND a.active_ind=outerjoin(1))
  ORDER BY cv.display, a.description, cv.code_value
  HEAD cv.code_value
   gcnt = (gcnt+ 1), stat = alterlist(temp->groups,gcnt), temp->groups[gcnt].code_value = cv
   .code_value,
   temp->groups[gcnt].display = cv.display, acnt = 0
  DETAIL
   IF (a.application_number > 0)
    acnt = (acnt+ 1), stat = alterlist(temp->groups[gcnt].applications,acnt), temp->groups[gcnt].
    applications[acnt].number = a.application_number,
    temp->groups[gcnt].applications[acnt].description = a.description
   ENDIF
  WITH nocounter
 ;end select
 IF (gcnt > 0)
  SET tcnt = 0
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = gcnt),
    (dummyt d2  WITH seq = 1),
    application_task_r atr,
    application_task at,
    task_access ta
   PLAN (d1
    WHERE maxrec(d2,size(temp->groups[d1.seq].applications,5)))
    JOIN (d2)
    JOIN (atr
    WHERE (atr.application_number=temp->groups[d1.seq].applications[d2.seq].number))
    JOIN (at
    WHERE at.task_number=atr.task_number
     AND at.active_ind=1)
    JOIN (ta
    WHERE ta.task_number=outerjoin(at.task_number)
     AND ta.app_group_cd=outerjoin(temp->groups[d1.seq].code_value))
   ORDER BY d1.seq, d2.seq, at.task_number
   HEAD d1.seq
    tcnt = 0
   HEAD d2.seq
    tcnt = 0
   DETAIL
    high_volume_cnt = (high_volume_cnt+ 1), tcnt = (tcnt+ 1), stat = alterlist(temp->groups[d1.seq].
     applications[d2.seq].tasks,tcnt),
    temp->groups[d1.seq].applications[d2.seq].tasks[tcnt].number = at.task_number, temp->groups[d1
    .seq].applications[d2.seq].tasks[tcnt].description = at.description
    IF (ta.task_number > 0)
     temp->groups[d1.seq].applications[d2.seq].tasks[tcnt].granted_ind = 1
    ELSE
     temp->groups[d1.seq].applications[d2.seq].tasks[tcnt].granted_ind = 0
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = gcnt),
    task_access ta,
    application_task at
   PLAN (d)
    JOIN (ta
    WHERE (ta.app_group_cd=temp->groups[d.seq].code_value)
     AND  NOT ( EXISTS (
    (SELECT
     atr.task_number
     FROM application_task_r atr
     WHERE atr.task_number=ta.task_number
      AND atr.application_number IN (
     (SELECT
      aa.application_number
      FROM application_access aa
      WHERE aa.app_group_cd=ta.app_group_cd
       AND aa.active_ind=1))))))
    JOIN (at
    WHERE at.task_number=ta.task_number)
   ORDER BY d.seq, at.task_number
   HEAD d.seq
    acnt = size(temp->groups[d.seq].applications,5), acnt = (acnt+ 1), stat = alterlist(temp->groups[
     d.seq].applications,acnt),
    temp->groups[d.seq].applications[acnt].description = "Tasks Only", tcnt = 0
   DETAIL
    high_volume_cnt = (high_volume_cnt+ 1), tcnt = (tcnt+ 1), stat = alterlist(temp->groups[d.seq].
     applications[acnt].tasks,tcnt),
    temp->groups[d.seq].applications[acnt].tasks[tcnt].number = at.task_number, temp->groups[d.seq].
    applications[acnt].tasks[tcnt].description = at.description, temp->groups[d.seq].applications[
    acnt].tasks[tcnt].granted_ind = 1
   WITH nocounter
  ;end select
 ENDIF
 IF (gcnt=0)
  GO TO exit_script
 ENDIF
 IF ((request->skip_volume_check_ind=0))
  IF (high_volume_cnt > 60000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 30000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET stat = alterlist(reply->collist,6)
 SET reply->collist[1].header_text = "Application Group"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Application Description"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Application Number"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Associated Tasks"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Task Number"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Task Granted"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET row_nbr = 0
 FOR (g = 1 TO gcnt)
  SET acnt = size(temp->groups[g].applications,5)
  IF (acnt=0)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,6)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->groups[g].display
  ELSE
   FOR (a = 1 TO acnt)
    SET tcnt = size(temp->groups[g].applications[a].tasks,5)
    FOR (t = 1 TO tcnt)
      SET row_nbr = (row_nbr+ 1)
      SET stat = alterlist(reply->rowlist,row_nbr)
      SET stat = alterlist(reply->rowlist[row_nbr].celllist,6)
      SET reply->rowlist[row_nbr].celllist[1].string_value = temp->groups[g].display
      SET reply->rowlist[row_nbr].celllist[2].string_value = temp->groups[g].applications[a].
      description
      IF ((temp->groups[g].applications[a].number > 0))
       SET reply->rowlist[row_nbr].celllist[3].string_value = cnvtstring(temp->groups[g].
        applications[a].number)
      ELSE
       SET reply->rowlist[row_nbr].celllist[3].string_value = " "
      ENDIF
      SET reply->rowlist[row_nbr].celllist[4].string_value = temp->groups[g].applications[a].tasks[t]
      .description
      SET reply->rowlist[row_nbr].celllist[5].string_value = cnvtstring(temp->groups[g].applications[
       a].tasks[t].number)
      IF ((temp->groups[g].applications[a].tasks[t].granted_ind=1))
       SET reply->rowlist[row_nbr].celllist[6].string_value = "Yes"
      ELSE
       SET reply->rowlist[row_nbr].celllist[6].string_value = "No"
      ENDIF
    ENDFOR
   ENDFOR
  ENDIF
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("application_groups.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
