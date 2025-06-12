CREATE PROGRAM bed_aud_fn_discern_reports:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 positions[*]
      2 code_value = f8
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
     2 report_name = vc
     2 script = vc
     2 report_type = vc
     2 position = vc
     2 params = vc
     2 last_update_by = vc
 )
 FREE RECORD positions
 RECORD positions(
   1 plist[*]
     2 code_value = f8
     2 disp = c40
 )
 DECLARE positions_list = vc
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM predefined_prefs pp
   PLAN (pp
    WHERE pp.name="FNRPT*")
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
 SET nbr_of_pos_in_req = size(request->positions,5)
 SET tcnt = 0
 SELECT INTO "NL:"
  FROM predefined_prefs pp,
   code_value cv1,
   name_value_prefs nvp1,
   name_value_prefs nvp2,
   name_value_prefs nvp3,
   long_text_reference ltr,
   person p
  PLAN (pp
   WHERE pp.name="FNRPT*"
    AND pp.active_ind=1)
   JOIN (cv1
   WHERE cv1.code_value=outerjoin(cnvtreal(pp.predefined_type_meaning))
    AND cv1.code_set=outerjoin(20323)
    AND cv1.active_ind=outerjoin(1))
   JOIN (nvp1
   WHERE nvp1.parent_entity_id=outerjoin(pp.predefined_prefs_id)
    AND nvp1.parent_entity_name=outerjoin("PREDEFINED_PREFS")
    AND nvp1.pvc_name=outerjoin("reportname")
    AND nvp1.active_ind=outerjoin(1))
   JOIN (nvp2
   WHERE nvp2.parent_entity_id=outerjoin(pp.predefined_prefs_id)
    AND nvp2.parent_entity_name=outerjoin("PREDEFINED_PREFS")
    AND nvp2.pvc_name=outerjoin("position")
    AND nvp2.active_ind=outerjoin(1))
   JOIN (nvp3
   WHERE nvp3.parent_entity_id=outerjoin(pp.predefined_prefs_id)
    AND nvp3.parent_entity_name=outerjoin("PREDEFINED_PREFS")
    AND nvp3.pvc_name=outerjoin("parameterString")
    AND nvp3.active_ind=outerjoin(1))
   JOIN (ltr
   WHERE ltr.long_text_id=outerjoin(nvp3.merge_id)
    AND ltr.active_ind=outerjoin(1))
   JOIN (p
   WHERE p.person_id=outerjoin(pp.updt_id))
  ORDER BY nvp1.pvc_value
  DETAIL
   tcnt = (tcnt+ 1), stat = alterlist(temp->tqual,tcnt), temp->tqual[tcnt].report_name = nvp1
   .pvc_value,
   temp->tqual[tcnt].script = pp.name, temp->tqual[tcnt].report_type = cv1.display, temp->tqual[tcnt]
   .position = concat(nvp2.pvc_value," "),
   temp->tqual[tcnt].params = ltr.long_text, temp->tqual[tcnt].last_update_by = p.name_full_formatted
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,6)
 SET reply->collist[1].header_text = "Report Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Script"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Report Type"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Position"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Parameters"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Last Update By"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   IF ((temp->tqual[x].position > " "))
    SET pcnt = 0
    SET semicolon_pos = findstring(";",temp->tqual[x].position,1)
    SET len = (semicolon_pos - 1)
    SET nbr_pos = cnvtint(substring(1,len,temp->tqual[x].position))
    SET start_pos = (semicolon_pos+ 1)
    SET size_of_string = size(temp->tqual[x].position,1)
    FOR (p = 1 TO nbr_pos)
      SET end_pos = 0
      SET end_pos = findstring(",",temp->tqual[x].position,start_pos)
      IF (end_pos > 0)
       SET len = (end_pos - start_pos)
      ELSE
       SET end_pos = size_of_string
       SET len = ((end_pos - start_pos)+ 1)
       SET p = (nbr_pos+ 1)
      ENDIF
      SET pcnt = (pcnt+ 1)
      SET stat = alterlist(positions->plist,pcnt)
      SET positions->plist[pcnt].code_value = cnvtint(substring(start_pos,len,temp->tqual[x].position
        ))
      SET start_pos = (end_pos+ 1)
    ENDFOR
   ENDIF
   SET move_temp = 0
   IF (((nbr_of_pos_in_req=0) OR (pcnt=0)) )
    SET move_temp = 1
   ELSE
    SET found_ind = 0
    FOR (p = 1 TO pcnt)
     FOR (v = 1 TO nbr_of_pos_in_req)
       IF ((positions->plist[p].code_value=request->positions[v].code_value))
        SET found_ind = 1
        SET v = (nbr_of_pos_in_req+ 1)
       ENDIF
     ENDFOR
     IF (found_ind=1)
      SET p = (pcnt+ 1)
     ENDIF
    ENDFOR
    IF (found_ind=1)
     SET move_temp = 1
    ENDIF
   ENDIF
   IF (move_temp=1)
    SET row_nbr = (row_nbr+ 1)
    SET stat = alterlist(reply->rowlist,row_nbr)
    SET stat = alterlist(reply->rowlist[row_nbr].celllist,6)
    SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].report_name
    SET reply->rowlist[row_nbr].celllist[2].string_value = temp->tqual[x].script
    SET reply->rowlist[row_nbr].celllist[3].string_value = temp->tqual[x].report_type
    IF ((temp->tqual[x].position > " "))
     SET positions_list = " "
     SET first_one = 1
     SELECT INTO "NL:"
      FROM (dummyt d  WITH seq = pcnt),
       code_value cv
      PLAN (d)
       JOIN (cv
       WHERE (cv.code_value=positions->plist[d.seq].code_value))
      DETAIL
       IF (first_one=1)
        first_one = 0, positions_list = cv.display
       ELSE
        positions_list = concat(positions_list,", ",cv.display)
       ENDIF
      WITH nocounter
     ;end select
     SET reply->rowlist[row_nbr].celllist[4].string_value = positions_list
    ELSE
     SET reply->rowlist[row_nbr].celllist[4].string_value = " "
    ENDIF
    SET reply->rowlist[row_nbr].celllist[5].string_value = temp->tqual[x].params
    SET reply->rowlist[row_nbr].celllist[6].string_value = temp->tqual[x].last_update_by
   ENDIF
 ENDFOR
 CALL echorecord(reply)
#exit_script
 SET reply->status_data.status = "S"
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("fn_discern_reports_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
