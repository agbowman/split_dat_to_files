CREATE PROGRAM bed_aud_ap_cyto_standard_rpts:dba
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
     2 report_disp = vc
     2 report_desc = vc
     2 report_section = vc
     2 report_value = vc
     2 hot_key_seq = i4
     2 report_short_code = vc
     2 active_ind = i2
 )
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM cyto_standard_rpt c,
    cyto_standard_rpt_r cr
   PLAN (c)
    JOIN (cr
    WHERE cr.standard_rpt_id=c.standard_rpt_id)
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
  work_seq =
  IF (c.hot_key_sequence=0) "Z"
  ELSE cnvtstring(c.hot_key_sequence)
  ENDIF
  FROM cyto_standard_rpt c,
   cyto_standard_rpt_r cr,
   nomenclature n,
   code_value cv1,
   code_value cv2
  PLAN (c)
   JOIN (cr
   WHERE cr.standard_rpt_id=c.standard_rpt_id)
   JOIN (cv1
   WHERE cv1.code_value=c.catalog_cd
    AND cv1.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=cr.task_assay_cd
    AND cv2.active_ind=1)
   JOIN (n
   WHERE n.nomenclature_id=outerjoin(cr.nomenclature_id)
    AND n.active_ind=outerjoin(1))
  ORDER BY cv1.display, work_seq, c.short_desc
  DETAIL
   IF (cr.nomenclature_id=0
    AND cr.result_text=" ")
    tcnt = tcnt
   ELSE
    tcnt = (tcnt+ 1), temp->tcnt = tcnt, stat = alterlist(temp->tqual,tcnt),
    temp->tqual[tcnt].report_disp = cv1.display, temp->tqual[tcnt].report_desc = c.description, temp
    ->tqual[tcnt].report_section = cv2.display
    IF ((cr.nomenclature_id=- (1)))
     temp->tqual[tcnt].report_value = "(None)"
    ELSEIF (n.source_string > " ")
     temp->tqual[tcnt].report_value = n.source_string
    ELSE
     temp->tqual[tcnt].report_value = cr.result_text
    ENDIF
    temp->tqual[tcnt].hot_key_seq = c.hot_key_sequence, temp->tqual[tcnt].report_short_code = c
    .short_desc, temp->tqual[tcnt].active_ind = c.active_ind
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,7)
 SET reply->collist[1].header_text = "Report"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Hot Key Sequence"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Report Short Code"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Standard Report Description"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Active Indicator"
 SET reply->collist[5].data_type = 3
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Assay Display"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Result Value"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,7)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].report_disp
   IF ((temp->tqual[x].hot_key_seq > 0))
    SET reply->rowlist[row_nbr].celllist[2].string_value = cnvtstring(temp->tqual[x].hot_key_seq)
   ELSE
    SET reply->rowlist[row_nbr].celllist[2].string_value = " "
   ENDIF
   SET reply->rowlist[row_nbr].celllist[3].string_value = temp->tqual[x].report_short_code
   SET reply->rowlist[row_nbr].celllist[4].string_value = temp->tqual[x].report_desc
   SET reply->rowlist[row_nbr].celllist[5].nbr_value = temp->tqual[x].active_ind
   SET reply->rowlist[row_nbr].celllist[6].string_value = temp->tqual[x].report_section
   SET reply->rowlist[row_nbr].celllist[7].string_value = temp->tqual[x].report_value
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("ap_cyto_standard_rpts.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
