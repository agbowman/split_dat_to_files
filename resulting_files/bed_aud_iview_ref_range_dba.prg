CREATE PROGRAM bed_aud_iview_ref_range:dba
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
   1 tqual[*]
     2 assay_display = vc
     2 assay_desc = vc
     2 assay_code_value = f8
     2 result_type = vc
     2 activity_type = vc
 )
 SET reply->run_status_flag = 1
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   FROM discrete_task_assay dta,
    v500_event_set_explode ese,
    v500_event_set_code esc,
    working_view_item wvi,
    reference_range_factor rrf
   PLAN (dta
    WHERE dta.active_ind=1)
    JOIN (ese
    WHERE ese.event_cd=dta.event_cd
     AND ese.event_set_level=0)
    JOIN (esc
    WHERE esc.event_set_cd=ese.event_set_cd)
    JOIN (wvi
    WHERE wvi.primitive_event_set_name=esc.event_set_name)
    JOIN (rrf
    WHERE rrf.task_assay_cd=outerjoin(dta.task_assay_cd))
   DETAIL
    IF (rrf.task_assay_cd=0)
     high_volume_cnt = (high_volume_cnt+ 1)
    ENDIF
   WITH nocounter
  ;end select
  IF (high_volume_cnt > 5000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 3000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET tcnt = 0
 SET total_cnt = 0
 SELECT INTO "NL:"
  FROM discrete_task_assay dta,
   v500_event_set_explode ese,
   v500_event_set_code esc,
   working_view_item wvi,
   code_value cv1,
   code_value cv2,
   reference_range_factor rrf
  PLAN (dta
   WHERE dta.active_ind=1)
   JOIN (ese
   WHERE ese.event_cd=dta.event_cd
    AND ese.event_set_level=0)
   JOIN (esc
   WHERE esc.event_set_cd=ese.event_set_cd)
   JOIN (wvi
   WHERE wvi.primitive_event_set_name=esc.event_set_name)
   JOIN (cv1
   WHERE cv1.code_value=dta.default_result_type_cd
    AND cv1.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=dta.activity_type_cd
    AND cv2.active_ind=1)
   JOIN (rrf
   WHERE rrf.task_assay_cd=outerjoin(dta.task_assay_cd))
  ORDER BY dta.mnemonic, dta.task_assay_cd
  HEAD dta.task_assay_cd
   total_cnt = (total_cnt+ 1)
   IF (rrf.task_assay_cd=0)
    tcnt = (tcnt+ 1), stat = alterlist(temp->tqual,tcnt), temp->tqual[tcnt].assay_display = dta
    .mnemonic,
    temp->tqual[tcnt].assay_desc = dta.description, temp->tqual[tcnt].assay_code_value = dta
    .task_assay_cd, temp->tqual[tcnt].result_type = cv1.display,
    temp->tqual[tcnt].activity_type = cv2.display
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,5)
 SET reply->collist[1].header_text = "Assay Display"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Assay Description"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Assay Code Value"
 SET reply->collist[3].data_type = 2
 SET reply->collist[3].hide_ind = 1
 SET reply->collist[4].header_text = "Result Type"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Activity Type"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,5)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].assay_display
   SET reply->rowlist[row_nbr].celllist[2].string_value = temp->tqual[x].assay_desc
   SET reply->rowlist[row_nbr].celllist[3].double_value = temp->tqual[x].assay_code_value
   SET reply->rowlist[row_nbr].celllist[4].string_value = temp->tqual[x].result_type
   SET reply->rowlist[row_nbr].celllist[5].string_value = temp->tqual[x].activity_type
 ENDFOR
 IF (total_cnt > 0)
  SET reply->run_status_flag = 3
 ELSE
  SET reply->run_status_flag = 1
 ENDIF
 SET stat = alterlist(reply->statlist,1)
 SET reply->statlist[1].statistic_meaning = "IVIEWREFRANGE"
 SET reply->statlist[1].total_items = total_cnt
 SET reply->statlist[1].qualifying_items = tcnt
 IF (tcnt > 0)
  SET reply->statlist[1].status_flag = 3
 ELSE
  SET reply->statlist[1].status_flag = 1
 ENDIF
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("assays_missing_reference_range.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
