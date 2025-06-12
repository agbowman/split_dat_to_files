CREATE PROGRAM bed_aud_cn_pat_acc_list_tasks:dba
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
   1 positions[*]
     2 pos_disp = vc
     2 locations[*]
       3 loc_disp = vc
       3 task_groups[*]
         4 group_disp = vc
         4 task_types[*]
           5 type_disp = vc
 )
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM pip p,
    code_value cv1,
    code_value cv2,
    pip_section ps,
    pip_prefs pp,
    code_value cv4,
    code_value_group cvg,
    code_value cv5
   PLAN (p
    WHERE p.prsnl_id=0)
    JOIN (cv1
    WHERE cv1.code_value=p.position_cd
     AND cv1.active_ind=1)
    JOIN (ps
    WHERE ps.pip_id=p.pip_id)
    JOIN (pp
    WHERE pp.parent_entity_id=ps.pip_section_id
     AND pp.pref_name="TASK_GROUP")
    JOIN (cv4
    WHERE cv4.code_value=pp.merge_id
     AND cv4.active_ind=1)
    JOIN (cvg
    WHERE cvg.parent_code_value=pp.merge_id)
    JOIN (cv5
    WHERE cv5.code_value=cvg.child_code_value
     AND cv5.active_ind=1)
    JOIN (cv2
    WHERE cv2.code_value=outerjoin(p.location_cd)
     AND cv2.active_ind=outerjoin(1))
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
 SET pcnt = 0
 SET lcnt = 0
 SET tgcnt = 0
 SET ttcnt = 0
 SELECT INTO "NL:"
  FROM pip p,
   code_value cv1,
   code_value cv2,
   pip_section ps,
   pip_prefs pp,
   code_value cv4,
   code_value_group cvg,
   code_value cv5
  PLAN (p
   WHERE p.prsnl_id=0)
   JOIN (cv1
   WHERE cv1.code_value=p.position_cd
    AND cv1.active_ind=1)
   JOIN (ps
   WHERE ps.pip_id=p.pip_id)
   JOIN (pp
   WHERE pp.parent_entity_id=ps.pip_section_id
    AND pp.pref_name="TASK_GROUP")
   JOIN (cv4
   WHERE cv4.code_value=pp.merge_id
    AND cv4.active_ind=1)
   JOIN (cvg
   WHERE cvg.parent_code_value=pp.merge_id)
   JOIN (cv5
   WHERE cv5.code_value=cvg.child_code_value
    AND cv5.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=outerjoin(p.location_cd)
    AND cv2.active_ind=outerjoin(1))
  ORDER BY cv1.display, cv2.display, cv4.display,
   cv5.display, p.position_cd, p.location_cd,
   pp.merge_id
  HEAD p.position_cd
   pcnt = (pcnt+ 1), stat = alterlist(temp->positions,pcnt), temp->positions[pcnt].pos_disp = cv1
   .display,
   lcnt = 0
  HEAD p.location_cd
   lcnt = (lcnt+ 1), stat = alterlist(temp->positions[pcnt].locations,lcnt)
   IF (cv2.display=" ")
    temp->positions[pcnt].locations[lcnt].loc_disp = "<none>"
   ELSE
    temp->positions[pcnt].locations[lcnt].loc_disp = cv2.display
   ENDIF
   tgcnt = 0
  HEAD pp.merge_id
   tgcnt = (tgcnt+ 1), stat = alterlist(temp->positions[pcnt].locations[lcnt].task_groups,tgcnt),
   temp->positions[pcnt].locations[lcnt].task_groups[tgcnt].group_disp = cv4.display,
   ttcnt = 0
  DETAIL
   ttcnt = (ttcnt+ 1), stat = alterlist(temp->positions[pcnt].locations[lcnt].task_groups[tgcnt].
    task_types,ttcnt), temp->positions[pcnt].locations[lcnt].task_groups[tgcnt].task_types[ttcnt].
   type_disp = cv5.display
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,4)
 SET reply->collist[1].header_text = "Position"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Location"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Task Group"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Task Type"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 IF (pcnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (p = 1 TO pcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,4)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->positions[p].pos_disp
   SET lcnt = size(temp->positions[p].locations,5)
   FOR (x = 1 TO lcnt)
     IF (x > 1)
      SET row_nbr = (row_nbr+ 1)
      SET stat = alterlist(reply->rowlist,row_nbr)
      SET stat = alterlist(reply->rowlist[row_nbr].celllist,4)
     ENDIF
     SET reply->rowlist[row_nbr].celllist[2].string_value = temp->positions[p].locations[x].loc_disp
     SET tgcnt = size(temp->positions[p].locations[x].task_groups,5)
     FOR (g = 1 TO tgcnt)
       IF (g > 1)
        SET row_nbr = (row_nbr+ 1)
        SET stat = alterlist(reply->rowlist,row_nbr)
        SET stat = alterlist(reply->rowlist[row_nbr].celllist,4)
       ENDIF
       SET reply->rowlist[row_nbr].celllist[3].string_value = temp->positions[p].locations[x].
       task_groups[g].group_disp
       SET ttcnt = size(temp->positions[p].locations[x].task_groups[g].task_types,5)
       FOR (t = 1 TO ttcnt)
        IF (t > 1)
         SET row_nbr = (row_nbr+ 1)
         SET stat = alterlist(reply->rowlist,row_nbr)
         SET stat = alterlist(reply->rowlist[row_nbr].celllist,4)
        ENDIF
        SET reply->rowlist[row_nbr].celllist[4].string_value = temp->positions[p].locations[x].
        task_groups[g].task_types[t].type_disp
       ENDFOR
     ENDFOR
   ENDFOR
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("cn_patient_access_list_task_sections.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
