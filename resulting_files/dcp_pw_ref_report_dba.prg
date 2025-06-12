CREATE PROGRAM dcp_pw_ref_report:dba
 SET print_ind = request->print_id_ind
 SET pathway_catalog_id = request->pathway_catalog_id
 SET printer_name = request->printer_name
 SET cur_cc = fillstring(100," ")
 SET cur_tf = fillstring(100," ")
 SET xcol = 30
 SET ycol = 50
 SET char_ctr = 0
 SET start_pos = 0
 SET end_pos = 0
 SET numchars = 0
 SET numlines = 0
 SET centered_desc = fillstring(100," ")
 SET orderable_id = fillstring(100," ")
 SET event_cd_disp = fillstring(100," ")
 SET default_type_disp = fillstring(100," ")
 SET index = 56
 SET found_ind = 0
 SET m = 1
 SET x = 0
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(30," ")
 DECLARE pw_rpt_temp = vc WITH public, noconstant(fillstring(100," "))
 DECLARE pw_rpt_temp2 = vc WITH public, noconstant(fillstring(100," "))
 DECLARE report_file = vc WITH public, noconstant(fillstring(100," "))
 RECORD os(
   1 display[255] = c1
 )
 RECORD temp(
   1 display[56] = c1
 )
 RECORD notetemp(
   1 newstring[255] = c1
 )
 RECORD printed(
   1 qual_lines[6]
     2 display[56] = c1
 )
 RECORD noteprinted(
   1 note[90] = c1
 )
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET note_meaning = "NOTE"
 SET order_create_meaning = "ORDER CREATE"
 SET label_meaning = "LABEL"
 SET outcome_create_meaning = "OUTCOME CREA"
 SET task_create_meaning = "TASK CREATE"
 SET result_outcome_meaning = "RESULT OUTCO"
 SET pw_rpt_temp = trim(concat("rpt_",cnvtstring(request->pathway_catalog_id)))
 SET pw_rpt_temp2 = trim(concat("rpt2_",cnvtstring(request->pathway_catalog_id)))
 SET report_file = trim(concat("ccluserdir:pw_rpt",trim(cnvtstring(request->pathway_catalog_id))))
 CALL echo(report_file)
 SET event_cd_text_meaning = "TXT"
 SET code_set = 53
 SET cdf_meaning = event_cd_text_meaning
 EXECUTE cpm_get_cd_for_cdf
 SET text_type_code = code_value
 SET code_set = 16750
 SET cdf_meaning = note_meaning
 EXECUTE cpm_get_cd_for_cdf
 SET note_type_cd = code_value
 SET code_set = 16750
 SET cdf_meaning = order_create_meaning
 EXECUTE cpm_get_cd_for_cdf
 SET order_create_type_cd = code_value
 SET code_set = 16750
 SET cdf_meaning = label_meaning
 EXECUTE cpm_get_cd_for_cdf
 SET label_type_cd = code_value
 SET code_set = 16750
 SET cdf_meaning = outcome_create_meaning
 EXECUTE cpm_get_cd_for_cdf
 SET outcome_create_type_cd = code_value
 SET code_set = 16750
 SET cdf_meaning = task_create_meaning
 EXECUTE cpm_get_cd_for_cdf
 SET task_create_type_cd = code_value
 SET code_set = 16750
 SET cdf_meaning = result_outcome_meaning
 EXECUTE cpm_get_cd_for_cdf
 SET result_outcome_type_cd = code_value
 SELECT DISTINCT INTO TABLE value(pw_rpt_temp)
  care_category_id = pc.care_category_id, time_frame_id = pc.time_frame_id, comp_seq = pc.sequence,
  comp_type_cd = pc.comp_type_cd, parent_entity_name = pc.parent_entity_name, parent_entity_id = pc
  .parent_entity_id,
  pw_comp_id = pc.pathway_comp_id, comp_note_desc = substring(1,255,lt.long_text), comp_create_desc
   = substring(1,30,ocs.mnemonic),
  comp_results_desc = substring(1,30,dta.description), catalog_cd = ocs.catalog_cd, comp_label_desc
   = substring(1,50,pc2.comp_label),
  table_used = decode(lt.seq,"LT",ocs.seq,"OC",dta.seq,
   "DT",pc2.seq,"PC"), os_display_line = concat("-",trim(ost.order_sentence_display_line)), os_id =
  pc.order_sentence_id,
  required_ind = pc.required_ind, include_ind = pc.include_ind, task_assay_cd = pc.task_assay_cd,
  result_desc = dta.description, event_code = pc.event_cd, outcome_type = vec.def_event_class_cd,
  rrf_age_units_cd = pc.rrf_age_units_cd, rrf_age_qty = pc.rrf_age_qty, rrf_sex_cd = pc.rrf_sex_cd,
  result_units_cd = pc.result_units_cd, result_value = pc.result_value, outcome_operator_cd = pc
  .outcome_operator_cd
  FROM pathway_comp pc,
   long_text lt,
   order_catalog_synonym ocs,
   discrete_task_assay dta,
   pathway_comp pc2,
   order_sentence ost,
   v500_event_code vec,
   (dummyt d  WITH seq = 1),
   (dummyt d2  WITH seq = 1)
  PLAN (pc
   WHERE pc.pathway_catalog_id=pathway_catalog_id
    AND pc.active_ind=1)
   JOIN (d)
   JOIN (((lt
   WHERE pc.comp_type_cd=note_type_cd
    AND lt.parent_entity_id=pc.pathway_comp_id
    AND lt.parent_entity_name="PATHWAY_COMP"
    AND lt.long_text_id=pc.parent_entity_id)
   ) ORJOIN ((((ocs
   WHERE ((pc.comp_type_cd=order_create_type_cd) OR (((pc.comp_type_cd=outcome_create_type_cd) OR (pc
   .comp_type_cd=task_create_type_cd)) ))
    AND pc.parent_entity_id=ocs.synonym_id)
   JOIN (d2)
   JOIN (ost
   WHERE pc.order_sentence_id=ost.order_sentence_id
    AND pc.order_sentence_id > 0)
   ) ORJOIN ((((dta)
   JOIN (vec
   WHERE pc.comp_type_cd=result_outcome_type_cd
    AND dta.task_assay_cd=pc.task_assay_cd
    AND pc.event_cd=vec.event_cd)
   ) ORJOIN ((pc2
   WHERE pc.comp_type_cd=label_type_cd
    AND pc2.pathway_comp_id=pc.pathway_comp_id)
   )) )) ))
  ORDER BY care_category_id, time_frame_id, comp_seq
  WITH counter, outerjoin = d, outerjoin = d2
 ;end select
 FREE SET request
 RECORD request(
   1 dta_list[*]
     2 task_assay_cd = f8
     2 age_qty = i4
     2 age_units = vc
     2 sex_cd = f8
 )
 FREE SET reply
 RECORD reply(
   1 qual[*]
     2 task_assay_cd = f8
     2 reference_range_factor_id = f8
     2 age_in_minutes = f8
     2 age_from_units_cd = f8
     2 age_from_minutes = i4
     2 age_to_units_cd = f8
     2 age_to_minutes = i4
     2 specimen_type_cd = f8
     2 patient_condition_cd = f8
     2 alpha_response_ind = i2
     2 default_result = f8
     2 units_cd = f8
     2 units_disp = vc
     2 units_mean = c12
     2 review_ind = i2
     2 review_low = f8
     2 review_high = f8
     2 sensitive_ind = i2
     2 sensitive_low = f8
     2 sensitive_high = f8
     2 normal_ind = i2
     2 normal_low = f8
     2 normal_high = f8
     2 critical_ind = i2
     2 critical_low = f8
     2 critical_high = f8
     2 delta_check_type_cd = f8
     2 delta_minutes = f8
     2 delta_value = f8
     2 updt_cnt = i4
     2 numeric_ind = i2
     2 data_map_type_flag = i2
     2 result_entry_format = i4
     2 max_digits = i4
     2 min_digits = i4
     2 min_decimal_places = i4
     2 alpha_ind = i2
     2 alpha_cnt = i4
     2 alpha[*]
       3 sequence = i4
       3 nomenclature_id = f8
       3 result_value = f8
       3 default_ind = i2
       3 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RANGE OF xt IS parser(pw_rpt_temp)
 RECORD outcome_data(
   1 qual[*]
     2 sequence = i4
     2 outcome_type = f8
     2 task_assay_cd = f8
     2 rrf_age_units_cd = f8
     2 rrf_age_units_disp = vc
     2 rrf_age_units_mean = vc
     2 rrf_age_qty = i4
     2 rrf_sex_cd = f8
     2 alpha_ind = i4
     2 alpha[*]
       3 sequence = i4
       3 nomenclature_id = f8
       3 result_value = f8
       3 default_ind = i2
       3 description = vc
 )
 SELECT INTO "nl:"
  xt.outcome_type, xt.parent_entity_name, xt.task_assay_cd,
  xt.rrf_age_units_cd, xt.rrf_age_qty, xt.rrf_sex_cd
  FROM (dummyt d1  WITH seq = 1),
   code_value cv
  PLAN (xt
   WHERE xt.outcome_type=text_type_code)
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (cv
   WHERE xt.rrf_age_units_cd=cv.code_value)
  HEAD REPORT
   outcome_cnt = 0, cnt = 0, y = 1
  DETAIL
   outcome_cnt = (outcome_cnt+ 1), stat = alterlist(outcome_data->qual,outcome_cnt), stat = alterlist
   (request->dta_list,outcome_cnt),
   outcome_data->qual[outcome_cnt].outcome_type = xt.outcome_type, outcome_data->qual[outcome_cnt].
   task_assay_cd = xt.task_assay_cd, outcome_data->qual[outcome_cnt].rrf_age_units_cd = xt
   .rrf_age_units_cd,
   outcome_data->qual[outcome_cnt].rrf_age_qty = xt.rrf_age_qty, outcome_data->qual[outcome_cnt].
   rrf_sex_cd = xt.rrf_sex_cd, outcome_data->qual[outcome_cnt].rrf_age_units_mean = cv.cdf_meaning,
   request->dta_list[outcome_cnt].task_assay_cd = outcome_data->qual[outcome_cnt].task_assay_cd,
   request->dta_list[outcome_cnt].age_qty = outcome_data->qual[outcome_cnt].rrf_age_qty, request->
   dta_list[outcome_cnt].age_units = outcome_data->qual[outcome_cnt].rrf_age_units_mean,
   request->dta_list[outcome_cnt].sex_cd = outcome_data->qual[outcome_cnt].rrf_sex_cd
  WITH nocounter
 ;end select
 EXECUTE dcp_get_pw_dta_resp
 SET outcome_cnt = cnvtint(size(outcome_data->qual,5))
 SET cnt = 0
 SET y = 0
 CALL echo(build("outcome count= ",outcome_cnt))
 FOR (y = 1 TO outcome_cnt)
   CALL echo(build("alpha cnt = ",size(reply->qual[y].alpha,5)))
   SET stat = alterlist(outcome_data->qual[y].alpha,size(reply->qual[y].alpha,5))
   FOR (x = 1 TO size(reply->qual[y].alpha,5))
     SET outcome_data->qual[y].alpha[x].sequence = reply->qual[y].alpha[x].sequence
     SET outcome_data->qual[y].alpha[x].result_value = reply->qual[y].alpha[x].result_value
     SET outcome_data->qual[y].alpha[x].default_ind = reply->qual[y].alpha[x].default_ind
     SET outcome_data->qual[y].alpha[x].nomenclature_id = reply->qual[y].alpha[x].nomenclature_id
     SET outcome_data->qual[y].alpha[x].description = reply->qual[y].alpha[x].description
   ENDFOR
 ENDFOR
 SELECT INTO TABLE value(pw_rpt_temp2)
  care_category_seq = cc.sequence, care_category_id = cc.care_category_id, care_category_desc = cc
  .description,
  time_frame_seq = tf.sequence, time_frame_id = tf.time_frame_id, time_frame_desc = tf.description,
  comp_sequence = xt.comp_seq, pw_comp_id = xt.pw_comp_id, comp_type_cd = xt.comp_type_cd,
  comp_note_desc = xt.comp_note_desc, comp_create_desc = xt.comp_create_desc, comp_results_desc = xt
  .comp_results_desc,
  comp_label_desc = xt.comp_label_desc, table_used = xt.table_used, os_id = xt.os_id,
  os_display_line = xt.os_display_line, include_ind = xt.include_ind, required_ind = xt.required_ind,
  catalog_cd = cnvtstring(xt.catalog_cd), task_assay_cd = xt.task_assay_cd, result_desc = xt
  .result_desc,
  event_code = cnvtstring(xt.event_code), result_units_cd = xt.result_units_cd, result_value = xt
  .result_value,
  outcome_operator_cd = xt.outcome_operator_cd, outcome_type = xt.outcome_type
  FROM time_frame tf,
   care_category cc,
   (dummyt d  WITH seq = 1)
  PLAN (cc
   WHERE pathway_catalog_id=cc.pathway_catalog_id
    AND cc.active_ind=1)
   JOIN (tf
   WHERE pathway_catalog_id=tf.pathway_catalog_id
    AND tf.active_ind=1)
   JOIN (d
   WHERE d.seq=1)
   JOIN (xt
   WHERE cc.care_category_id=xt.care_category_id
    AND tf.time_frame_id=xt.time_frame_id)
  ORDER BY care_category_seq, time_frame_seq, comp_sequence
  WITH outerjoin = d
 ;end select
 RANGE OF xt2 IS parser(pw_rpt_temp2)
 SELECT INTO trim(value(report_file))
  pwc.description, pwc.pathway_catalog_id, pwc.version,
  pwc.updt_dt_tm, xt2.care_category_seq, xt2.care_category_desc,
  xt2.time_frame_seq, xt2.time_frame_desc, xt2.comp_sequence,
  xt2.comp_note_desc, xt2.comp_create_desc, xt2.comp_results_desc,
  xt2.comp_label_desc, xt2.cond_desc, xt2.cond_ind,
  xt2.os_display_line, xt2.os_id, xt2.required_ind,
  xt2.include_ind, xt2.catalog_cd, xt2.task_assay_cd,
  xt2.result_desc, xt2.event_cd, xt2.result_units_cd,
  xt2.result_value, xt2.outcome_operator_cd, cv2.display,
  cv.display, xt2.outcome_type
  FROM pathway_catalog pwc,
   code_value cv,
   code_value cv2,
   (dummyt d  WITH seq = 1)
  PLAN (xt2)
   JOIN (d
   WHERE d.seq=1)
   JOIN (pwc
   WHERE pwc.pathway_catalog_id=pathway_catalog_id)
   JOIN (cv
   WHERE cv.code_value=xt2.result_units_cd)
   JOIN (cv2
   WHERE cv2.code_value=xt2.outcome_operator_cd)
  HEAD REPORT
   IF (print_ind=0)
    centered_desc = format(trim(pwc.description),";C")
   ELSE
    centered_desc = format(concat(trim(pwc.description)," (",trim(cnvtstring(pathway_catalog_id)),")"
      ),";C")
   ENDIF
  HEAD PAGE
   "{cpi/13}{f/20}", xcol = 20, ycol = 0,
   "{cpi/15}",
   CALL print(calcpos(xcol,ycol)), "Pathway Catalog Audit",
   xcol = 180,
   CALL print(calcpos(xcol,ycol)), "Date:   ",
   curdate"MM/DD/YY;R;D", xcol = 360,
   CALL print(calcpos(xcol,ycol)),
   "Time:   ", curtime"hh:mm;R;S", xcol = 540,
   CALL print(calcpos(xcol,ycol)), "Page:   ", curpage"###;L",
   row + 1, ycol = (ycol+ 25), xcol = 20,
   CALL print(calcpos(xcol,ycol)), "{b}{cpi/9}", centered_desc,
   "{endb}", ycol = (ycol+ 10), row + 2,
   "{cpi/15}",
   CALL print(calcpos(xcol,ycol)), "Version Number ",
   pwc.version, ycol = (ycol+ 10), row + 2,
   CALL print(calcpos(xcol,ycol)), "Last Updated:   ", pwc.updt_dt_tm,
   row + 1, "{cpi/13}"
  HEAD xt2.care_category_desc
   "{cpi/13}", row + 1, ycol = (ycol+ 30)
   IF (((ycol+ 65) >= 700))
    BREAK, ycol = (ycol+ 19)
   ENDIF
   xcol = 50,
   CALL print(calcpos(xcol,ycol)), "{B}{U}",
   xt2.care_category_desc, row + 1, cur_cc = concat(trim(xt2.care_category_desc,1)," (cont'd)")
  HEAD xt2.time_frame_desc
   IF (xt2.comp_type_cd > 0)
    "{cpi/13}", row + 1, ycol = (ycol+ 15)
    IF (((ycol+ 50) >= 700))
     BREAK, xcol = 50, ycol = (ycol+ 19),
     CALL print(calcpos(xcol,ycol)), "{b}{u}", cur_cc,
     row + 1, ycol = (ycol+ 15)
    ENDIF
    xcol = 58,
    CALL print(calcpos(xcol,ycol)), "{u}",
    xt2.time_frame_desc, row + 1, cur_tf = concat(trim(xt2.time_frame_desc,1)," (cont'd)")
   ENDIF
  DETAIL
   IF (xt2.comp_type_cd > 0)
    IF (xt2.os_id > 0)
     xcol = 280, numchars = textlen(trim(xt2.os_display_line))
     IF (numchars < 56)
      numlines = 1, printed->qual_lines[1] = xt2.os_display_line, row + 1,
      line_ctr = 1
     ELSE
      numlines = ((numchars/ 56)+ 1), end_pos = 0, line_ctr = 1,
      start_pos = 1, char_ctr = 1
      FOR (i = 1 TO numchars)
        os->display[i] = substring(i,1,xt2.os_display_line)
      ENDFOR
      IF (i < 255)
       FOR (i = (numchars+ 1) TO 255)
         os->display[i] = " "
       ENDFOR
      ENDIF
      WHILE (char_ctr <= numchars)
        temp = fillstring(56," "), printed->qual_lines[line_ctr] = fillstring(56," ")
        IF (line_ctr > 1)
         start_pos = (end_pos+ 1)
        ENDIF
        IF (((numchars - start_pos) < 56)
         AND line_ctr > 1)
         m = 1
         FOR (i = start_pos TO numchars)
          temp->display[m] = os->display[i],m = (m+ 1)
         ENDFOR
         m = 1
         FOR (i = char_ctr TO numchars)
          printed->qual_lines[line_ctr].display[m] = temp->display[m],m = (m+ 1)
         ENDFOR
         char_ctr = (numchars+ 1), found_ind = 1
        ELSE
         temp = substring(start_pos,56,os), found_ind = 0
        ENDIF
        index = 56
        WHILE (found_ind=0
         AND index > 0)
          IF ((temp->display[index]=","))
           found_ind = 1
           FOR (i = 1 TO index)
             printed->qual_lines[line_ctr].display[i] = temp->display[i]
           ENDFOR
           char_ctr = (char_ctr+ index), end_pos = ((start_pos+ index) - 1)
          ELSE
           index = (index - 1), found_ind = 0
          ENDIF
        ENDWHILE
        IF (index=0
         AND found_ind=0)
         m = 1
         FOR (i = start_pos TO (start_pos+ 56))
          printed->qual_lines[line_ctr].display[m] = temp->display[m],m = (m+ 1)
         ENDFOR
         end_pos = (start_pos+ 56)
        ENDIF
        line_ctr = (line_ctr+ 1)
      ENDWHILE
     ENDIF
    ELSEIF (xt2.task_assay_cd > 0)
     xcol = 280
     IF (xt2.outcome_type != text_type_code)
      value = format(cnvtreal(xt2.result_value),"#########################.##;l"), default_type_disp
       = concat(trim(cv2.display)," ",trim(value)," ",trim(cv.display)), numlines = 1,
      printed->qual_lines[1] = default_type_disp, row + 1, line_ctr = 1
     ELSE
      FOR (x = 1 TO size(outcome_data->qual,5))
        IF ((outcome_data->qual[x].task_assay_cd=xt2.task_assay_cd))
         default_type_disp = concat(trim(cv2.display),"  (")
         FOR (y = 1 TO size(outcome_data->qual[x].alpha,5))
           IF ((outcome_data->qual[x].alpha[y].result_value=xt2.result_value))
            default_type_disp = trim(concat(trim(default_type_disp),trim(outcome_data->qual[x].alpha[
               y].description),","))
           ENDIF
         ENDFOR
         default_type_disp = trim(concat(trim(default_type_disp),")")), numchars = textlen(trim(
           default_type_disp))
         IF (numchars < 56)
          numlines = 1, printed->qual_lines[1] = default_type_disp, row + 1,
          line_ctr = 1,
          CALL echo(build("**************",line_ctr))
         ELSE
          numlines = ((numchars/ 56)+ 1), end_pos = 0, line_ctr = 1,
          start_pos = 1, char_ctr = 1
          FOR (i = 1 TO numchars)
            os->display[i] = substring(i,1,default_type_disp)
          ENDFOR
          IF (i < 255)
           FOR (i = (numchars+ 1) TO 255)
             os->display[i] = " "
           ENDFOR
          ENDIF
          WHILE (char_ctr <= numchars)
            temp = fillstring(56," "), printed->qual_lines[line_ctr] = fillstring(56," ")
            IF (line_ctr > 1)
             start_pos = (end_pos+ 1)
            ENDIF
            IF (((numchars - start_pos) < 56)
             AND line_ctr > 1)
             m = 1
             FOR (i = start_pos TO numchars)
              temp->display[m] = os->display[i],m = (m+ 1)
             ENDFOR
             m = 1
             FOR (i = char_ctr TO numchars)
              printed->qual_lines[line_ctr].display[m] = temp->display[m],m = (m+ 1)
             ENDFOR
             char_ctr = (numchars+ 1), found_ind = 1
            ELSE
             temp = substring(start_pos,56,os), found_ind = 0
            ENDIF
            index = 56
            WHILE (found_ind=0
             AND index > 0)
              IF ((temp->display[index]=","))
               found_ind = 1
               FOR (i = 1 TO index)
                 printed->qual_lines[line_ctr].display[i] = temp->display[i]
               ENDFOR
               char_ctr = (char_ctr+ index), end_pos = ((start_pos+ index) - 1)
              ELSE
               index = (index - 1), found_ind = 0
              ENDIF
            ENDWHILE
            IF (index=0
             AND found_ind=0)
             m = 1
             FOR (i = start_pos TO (start_pos+ 56))
              printed->qual_lines[line_ctr].display[m] = temp->display[m],m = (m+ 1)
             ENDFOR
             end_pos = (start_pos+ 56)
            ENDIF
            line_ctr = (line_ctr+ 1)
          ENDWHILE
         ENDIF
        ENDIF
      ENDFOR
     ENDIF
    ENDIF
    ycol = (ycol+ 15)
    IF (((ycol+ (line_ctr * 13)) >= 700))
     BREAK, xcol = 50, ycol = (ycol+ 19),
     CALL print(calcpos(xcol,ycol)), "{cpi/13}{b}{u}", cur_cc,
     row + 1, ycol = (ycol+ 15), xcol = 58,
     CALL print(calcpos(xcol,ycol)), "{cpi/13}{u}", cur_tf,
     row + 1, ycol = (ycol+ 15)
    ENDIF
    "{cpi/14}", xcol = 39,
    CALL print(calcpos(xcol,ycol)),
    xt2.comp_sequence, ")", xcol = 80
    IF (xt2.required_ind=1)
     CALL print(calcpos(xcol,ycol)), "R"
    ELSEIF (xt2.include_ind=1)
     CALL print(calcpos(xcol,ycol)), "I"
    ELSE
     CALL print(calcpos(xcol,ycol)), "E"
    ENDIF
    xcol = 95
    IF (xt2.table_used="LT")
     CALL print(calcpos(xcol,ycol)), "NO", notetemp = fillstring(255," "),
     xcol = (xcol+ 24), x = findstring(char(13),xt2.comp_note_desc)
     IF (x > 0)
      notetemp = substring(1,(x - 1),xt2.comp_note_desc)
     ELSE
      notetemp = format(trim(xt2.comp_note_desc),";L")
     ENDIF
     numchars = textlen(trim(notetemp))
     IF (numchars > 90)
      start_pos = 1
      WHILE (start_pos <= numchars)
       noteprinted = fillstring(90," "),
       IF (((numchars - start_pos) < 90))
        ycol = (ycol+ 15), row + 1, m = 1
        FOR (i = start_pos TO numchars)
          noteprinted->note[m] = notetemp->newstring[i], m = (m+ 1), start_pos = (numchars+ 1)
        ENDFOR
        IF (m < 90)
         FOR (i = m TO 89)
           noteprinted->note[i] = " "
         ENDFOR
        ENDIF
        CALL print(calcpos(xcol,ycol)), noteprinted, start_pos = (numchars+ 1)
       ELSE
        m = 1
        FOR (i = start_pos TO (start_pos+ 89))
         noteprinted->note[m] = notetemp->newstring[i],m = (m+ 1)
        ENDFOR
        IF (start_pos > 1)
         ycol = (ycol+ 15), row + 1
        ENDIF
        CALL print(calcpos(xcol,ycol)), noteprinted, start_pos = (start_pos+ 90)
       ENDIF
      ENDWHILE
     ELSE
      CALL print(calcpos(xcol,ycol)), notetemp, " "
     ENDIF
    ELSEIF (xt2.table_used="OC")
     IF (xt2.comp_type_cd=order_create_type_cd)
      IF (print_ind=1)
       orderable_id = trim(concat("(",trim(xt2.catalog_cd),")")),
       CALL print(calcpos(xcol,ycol)), "OR ",
       orderable_id, xcol = (xcol+ 35)
      ELSE
       CALL print(calcpos(xcol,ycol)), "OR"
      ENDIF
     ELSEIF (xt2.comp_type_cd=outcome_create_type_cd)
      CALL print(calcpos(xcol,ycol)), "OO"
     ELSEIF (xt2.comp_type_cd=task_create_type_cd)
      CALL print(calcpos(xcol,ycol)), "TA"
     ENDIF
     xcol = (xcol+ 24),
     CALL print(calcpos(xcol,ycol)), xt2.comp_create_desc,
     " "
    ELSEIF (xt2.table_used="DT")
     IF (print_ind=1)
      event_cd_disp = trim(concat("(",trim(xt2.event_code),")")),
      CALL print(calcpos(xcol,ycol)), "EO ",
      event_cd_disp, xcol = (xcol+ 35)
     ELSE
      CALL print(calcpos(xcol,ycol)), "EO"
     ENDIF
     xcol = (xcol+ 24),
     CALL print(calcpos(xcol,ycol)), xt2.comp_results_desc,
     " "
    ELSEIF (xt2.table_used="PC")
     CALL print(calcpos(xcol,ycol)), "LA", xcol = (xcol+ 24),
     CALL print(calcpos(xcol,ycol)), xt2.comp_label_desc
    ENDIF
    IF (((xt2.os_id > 0) OR (xt2.task_assay_cd > 0)) )
     IF (line_ctr=1)
      xcol = 280,
      CALL print(calcpos(xcol,ycol)), printed->qual_lines[1]
     ELSE
      FOR (i = 1 TO (line_ctr - 1))
        IF (i > 1)
         ycol = (ycol+ 13), row + 1
        ENDIF
        xcol = 280,
        CALL print(calcpos(xcol,ycol)), printed->qual_lines[i]
      ENDFOR
     ENDIF
    ENDIF
    row + 1
   ENDIF
  FOOT PAGE
   "{cpi/15}", ycol = 740, xcol = 30,
   CALL print(calcpos(xcol,ycol)), "{B}Legend:  {ENDB}", xcol = 70,
   CALL print(calcpos(xcol,ycol)), "I=Included, E=Excluded, R=Required", ycol = (ycol+ 11),
   CALL print(calcpos(xcol,ycol)), "OR=Orderable, EO=Expected Outcome, NO=Note, LA=Label"
  WITH outerjoin = d, maxcol = 800, maxrow = 500,
   dio = 08
 ;end select
 FREE RANGE xt
 FREE RANGE xt2
 SET report_file = trim(concat(trim(report_file),".dat"))
 CALL echo(report_file)
 SET spool value(report_file) value(printer_name) WITH notify, deleted
END GO
