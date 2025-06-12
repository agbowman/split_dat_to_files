CREATE PROGRAM bed_aud_all_pos_chrt_tsk:dba
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
 SET stat = alterlist(reply->collist,2)
 SET reply->collist[1].header_text = "Task Type"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Task Description"
 SET reply->collist[2].data_type = 1
 SET row_nbr = 0
 SELECT INTO "NL:"
  FROM code_value cv,
   order_task ot,
   code_value cv2
  PLAN (cv
   WHERE cv.code_set=6026
    AND  NOT (cv.display_key IN ("ABSTRACTING", "ANALYSIS", "ASSEMBLY", "CHARTRETRIEVAL", "CODING",
   "EDANALYSIS", "EDCODING", "EMAIL", "ENDORSEMENTS", "FILING",
   "INPATIENTABSTRACTING", "INPATIENTANALYSIS", "INPATIENTCODING", "ORDERNOTIFICATIONS",
   "OUTPATIENTABSTRACTING",
   "OUTPATIENT", "ANALYSIS", "OUTPATIENTCODING", "PERSONAL", "PHONEMSG",
   "REANALYSIS", "RECEIPT", "SCANNING", "SCANNINGPREP", "TRANSCRIPTION")))
   JOIN (ot
   WHERE ot.active_ind=1
    AND ot.allpositionchart_ind=1
    AND ot.task_type_cd=cv.code_value)
   JOIN (cv2
   WHERE cv2.code_value=outerjoin(ot.task_type_cd)
    AND cv2.active_ind=outerjoin(1))
  ORDER BY cv2.display_key, cnvtupper(ot.task_description)
  DETAIL
   row_nbr = (row_nbr+ 1), stat = alterlist(reply->rowlist,row_nbr), stat = alterlist(reply->rowlist[
    row_nbr].celllist,2)
   IF (cv2.code_value=0)
    reply->rowlist[row_nbr].celllist[1].string_value = "<inactive task type>"
   ELSE
    reply->rowlist[row_nbr].celllist[1].string_value = cv2.display
   ENDIF
   reply->rowlist[row_nbr].celllist[2].string_value = ot.task_description
  WITH nocounter
 ;end select
 IF ((request->skip_volume_check_ind=0))
  IF (row_nbr > 5000)
   SET reply->high_volume_flag = 2
   SET stat = alterlist(reply->rowlist,0)
   GO TO exit_script
  ELSEIF (row_nbr > 3000)
   SET reply->high_volume_flag = 1
   SET stat = alterlist(reply->rowlist,0)
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("iview_aud_all_pos_chrt_tsk.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 CALL echorecord(reply)
END GO
