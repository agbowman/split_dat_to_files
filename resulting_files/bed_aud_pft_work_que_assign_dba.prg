CREATE PROGRAM bed_aud_pft_work_que_assign:dba
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
     2 que_type = vc
     2 que_name = vc
     2 criteria = vc
     2 value = vc
     2 assign_prsnl = vc
 )
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM pft_queue_assignment pqa
   WHERE pqa.active_ind=1
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
  FROM pft_queue_assignment pqa,
   person p,
   code_value cv1,
   code_value cv2,
   code_value cv3
  PLAN (pqa
   WHERE pqa.active_ind=1)
   JOIN (p
   WHERE p.person_id=outerjoin(pqa.assigned_prsnl_id)
    AND p.active_ind=outerjoin(1))
   JOIN (cv1
   WHERE cv1.code_value=outerjoin(pqa.pft_entity_type_cd)
    AND cv1.active_ind=outerjoin(1))
   JOIN (cv2
   WHERE cv2.code_value=outerjoin(pqa.pft_entity_status_cd)
    AND cv2.active_ind=outerjoin(1))
   JOIN (cv3
   WHERE cv3.code_value=outerjoin(pqa.value_specifier_cd)
    AND cv3.active_ind=outerjoin(1))
  ORDER BY cv1.display, cv2.display, p.name_full_formatted
  DETAIL
   tcnt = (tcnt+ 1), temp->tcnt = tcnt, stat = alterlist(temp->tqual,tcnt),
   temp->tqual[tcnt].que_type = cv1.display, temp->tqual[tcnt].que_name = cv2.display, temp->tqual[
   tcnt].criteria = cv3.display,
   temp->tqual[tcnt].value = pqa.value_display_txt, temp->tqual[tcnt].assign_prsnl = p
   .name_full_formatted
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,5)
 SET reply->collist[1].header_text = "Queue Type"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Queue Name"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Criteria"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Value"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Assigned Personnel"
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
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].que_type
   SET reply->rowlist[row_nbr].celllist[2].string_value = temp->tqual[x].que_name
   SET reply->rowlist[row_nbr].celllist[3].string_value = temp->tqual[x].criteria
   SET reply->rowlist[row_nbr].celllist[4].string_value = temp->tqual[x].value
   SET reply->rowlist[row_nbr].celllist[5].string_value = temp->tqual[x].assign_prsnl
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("pft_work_queue_assignment.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
