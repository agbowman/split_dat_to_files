CREATE PROGRAM bed_aud_ap_interp_patterns:dba
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
     2 report_section = vc
     2 result_interp_pattern = vc
     2 result_interp_text = vc
 )
 RECORD result_text(
   1 text_lines[*]
     2 text_line = vc
 )
 DECLARE ap = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=106
    AND cv.cdf_meaning="AP"
    AND cv.active_ind=1)
  DETAIL
   ap = cv.code_value
  WITH nocounter
 ;end select
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM discrete_task_assay dta,
    interp_task_assay ita,
    interp_result ir
   PLAN (dta
    WHERE dta.activity_type_cd=ap
     AND dta.active_ind=1)
    JOIN (ita
    WHERE ita.task_assay_cd=dta.task_assay_cd
     AND ita.active_ind=1)
    JOIN (ir
    WHERE ir.interp_id=ita.interp_id
     AND ir.active_ind=1)
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
  FROM discrete_task_assay dta,
   code_value cv,
   interp_task_assay ita,
   interp_result ir,
   long_text_reference ltr
  PLAN (dta
   WHERE dta.activity_type_cd=ap
    AND dta.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=dta.task_assay_cd
    AND cv.active_ind=1)
   JOIN (ita
   WHERE ita.task_assay_cd=dta.task_assay_cd
    AND ita.active_ind=1)
   JOIN (ir
   WHERE ir.interp_id=ita.interp_id
    AND ir.active_ind=1)
   JOIN (ltr
   WHERE ltr.long_text_id=outerjoin(ir.long_text_id)
    AND ltr.active_ind=outerjoin(1))
  ORDER BY cv.display
  DETAIL
   tcnt = (tcnt+ 1), stat = alterlist(temp->tqual,tcnt), temp->tqual[tcnt].report_section = cv
   .display,
   temp->tqual[tcnt].result_interp_pattern = ir.hash_pattern, temp->tqual[tcnt].result_interp_text =
   ltr.long_text
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,3)
 SET reply->collist[1].header_text = "Assay Display"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Result Interpretation Pattern"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Result Interpretation Text"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 DECLARE rest_of_text = vc
 DECLARE first_part_of_text = vc
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET txcnt = 0
   SET beg_pos = 0
   SET beg_text = 0
   SET end_text = 0
   SET text_len = 0
   SET beg_pos = (findstring("\deftab1134",temp->tqual[x].result_interp_text,1)+ 11)
   IF (beg_pos > 0)
    SET beg_text = (findstring(" ",temp->tqual[x].result_interp_text,beg_pos)+ 1)
    IF (beg_text > 0)
     SET end_text = (findstring("\",temp->tqual[x].result_interp_text,beg_text) - 1)
     IF (end_text=0)
      SET end_text = (findstring("}",temp->tqual[x].result_interp_text,beg_text) - 1)
     ENDIF
    ENDIF
   ENDIF
   IF (beg_text > 0
    AND end_text > 0)
    SET text_len = ((end_text - beg_text)+ 1)
    SET txcnt = (txcnt+ 1)
    SET stat = alterlist(result_text->text_lines,txcnt)
    SET result_text->text_lines[txcnt].text_line = substring(beg_text,text_len,temp->tqual[x].
     result_interp_text)
    SET search_flag = 1
    WHILE (search_flag=1)
      SET beg_text = findstring("\par",temp->tqual[x].result_interp_text,end_text)
      IF (beg_text > 0)
       SET beg_text = (beg_text+ 4)
      ENDIF
      IF (beg_text > 0)
       SET end_text = (findstring("\par",temp->tqual[x].result_interp_text,beg_text) - 1)
       IF (end_text=0)
        SET end_text = (findstring("}",temp->tqual[x].result_interp_text,beg_text) - 1)
       ENDIF
      ENDIF
      IF (beg_text > 0
       AND end_text > 0
       AND end_text > beg_text)
       SET text_len = ((end_text - beg_text)+ 1)
       SET txcnt = (txcnt+ 1)
       SET stat = alterlist(result_text->text_lines,txcnt)
       SET result_text->text_lines[txcnt].text_line = substring(beg_text,text_len,temp->tqual[x].
        result_interp_text)
      ELSE
       SET search_flag = 0
      ENDIF
    ENDWHILE
   ELSE
    SET txcnt = (txcnt+ 1)
    SET stat = alterlist(result_text->text_lines,txcnt)
    SET result_text->text_lines[txcnt].text_line = " "
   ENDIF
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,3)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].report_section
   SET dollar_pos = 0
   SET dollar_pos = findstring("$",temp->tqual[x].result_interp_pattern,1)
   IF (dollar_pos=0)
    SET reply->rowlist[row_nbr].celllist[2].string_value = temp->tqual[x].result_interp_pattern
   ELSE
    SET text_len = 0
    SET text_len = textlen(trim(temp->tqual[x].result_interp_pattern))
    IF (text_len=1)
     SET reply->rowlist[row_nbr].celllist[2].string_value = "No Result"
    ELSE
     IF (dollar_pos=1)
      SET rest_of_text = " "
      SET rest_of_text = substring((dollar_pos+ 1),(text_len - 1),temp->tqual[x].
       result_interp_pattern)
      SET reply->rowlist[row_nbr].celllist[2].string_value = concat("No Result",rest_of_text)
     ELSE
      SET first_part_of_text = " "
      SET rest_of_text = " "
      SET first_part_of_text = substring(1,(dollar_pos - 1),temp->tqual[x].result_interp_pattern)
      SET rest_of_text = substring((dollar_pos+ 1),(text_len - 1),temp->tqual[x].
       result_interp_pattern)
      SET reply->rowlist[row_nbr].celllist[2].string_value = concat(first_part_of_text,"No Result",
       rest_of_text)
     ENDIF
    ENDIF
   ENDIF
   IF (txcnt > 0)
    SET reply->rowlist[row_nbr].celllist[3].string_value = result_text->text_lines[1].text_line
    FOR (text_cnt = 2 TO txcnt)
      SET row_nbr = (row_nbr+ 1)
      SET stat = alterlist(reply->rowlist,row_nbr)
      SET stat = alterlist(reply->rowlist[row_nbr].celllist,3)
      SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].report_section
      SET reply->rowlist[row_nbr].celllist[2].string_value = reply->rowlist[(row_nbr - 1)].celllist[2
      ].string_value
      SET reply->rowlist[row_nbr].celllist[3].string_value = result_text->text_lines[text_cnt].
      text_line
    ENDFOR
   ENDIF
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("ap_cyto_interp_patterns.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
