CREATE PROGRAM bed_aud_cn_purge_criteria:dba
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
     2 task_type = vc
     2 task_status = vc
     2 patient_status = vc
     2 purge_if_active = i2
     2 nbr_of_days_retained = i4
 )
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM tl_purge_criteria tpc
   WHERE tpc.active_ind=1
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
  FROM tl_purge_criteria tpc,
   code_value cv1
  PLAN (tpc
   WHERE tpc.active_ind=1)
   JOIN (cv1
   WHERE cv1.code_value=tpc.task_type_cd
    AND cv1.active_ind=1)
  ORDER BY cv1.display, tpc.tl_purge_description, tpc.task_status_flag
  DETAIL
   tcnt = (tcnt+ 1), temp->tcnt = tcnt, stat = alterlist(temp->tqual,tcnt),
   temp->tqual[tcnt].description = tpc.tl_purge_description, temp->tqual[tcnt].task_type = cv1
   .display, null_ind = nullind(tpc.task_status_flag)
   IF (null_ind=1)
    temp->tqual[tcnt].task_status = " "
   ELSEIF (tpc.task_status_flag=0)
    temp->tqual[tcnt].task_status = "Purge Completed Tasks"
   ELSEIF (tpc.task_status_flag=1)
    temp->tqual[tcnt].task_status = "Purge Dropped Tasks"
   ELSEIF (tpc.task_status_flag=2)
    temp->tqual[tcnt].task_status = "Purge Active Tasks"
   ENDIF
   null_ind = nullind(tpc.patient_status_flag)
   IF (null_ind=1)
    temp->tqual[tcnt].patient_status = " "
   ELSEIF (tpc.patient_status_flag=0)
    temp->tqual[tcnt].patient_status = "Patient Discharged"
   ELSEIF (tpc.patient_status_flag=1)
    temp->tqual[tcnt].patient_status = "Patient Not Discharged"
   ENDIF
   temp->tqual[tcnt].purge_if_active = tpc.purge_active_flag, temp->tqual[tcnt].nbr_of_days_retained
    = tpc.retention_days
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,6)
 SET reply->collist[1].header_text = "Task Type"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Purge Criteria Description"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Task Status"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Patient Status"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Purge If Task is Active"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Number of Days the Task will be Retained"
 SET reply->collist[6].data_type = 3
 SET reply->collist[6].hide_ind = 0
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,6)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].task_type
   SET reply->rowlist[row_nbr].celllist[2].string_value = temp->tqual[x].description
   SET reply->rowlist[row_nbr].celllist[3].string_value = temp->tqual[x].task_status
   SET reply->rowlist[row_nbr].celllist[4].string_value = temp->tqual[x].patient_status
   IF ((temp->tqual[x].purge_if_active=0))
    SET reply->rowlist[row_nbr].celllist[5].string_value = "X"
   ELSEIF ((temp->tqual[x].purge_if_active=1))
    SET reply->rowlist[row_nbr].celllist[5].string_value = " "
   ENDIF
   SET reply->rowlist[row_nbr].celllist[6].nbr_value = temp->tqual[x].nbr_of_days_retained
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("cn_task_purge_criteria.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
