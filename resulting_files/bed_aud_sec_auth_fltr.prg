CREATE PROGRAM bed_aud_sec_auth_fltr
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 app_groups[*]
      2 ag_code_value = f8
    1 positions[*]
      2 pos_code_value = f8
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
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 FREE RECORD temp_pos
 RECORD temp_pos(
   1 pos[*]
     2 position_cd = f8
     2 disp = vc
     2 index = i4
 )
 FREE RECORD temp_ag
 RECORD temp_ag(
   1 ag[*]
     2 ag_cd = f8
     2 disp = vc
     2 pos_cnt = i4
     2 pos[*]
       3 pos_code_value = f8
 )
 SET pos_size = size(request->positions,5)
 SET pos_cnt = 0
 IF (pos_size > 0)
  SET stat = alterlist(temp_pos->pos,pos_size)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(pos_size)),
    code_value cv
   PLAN (d)
    JOIN (cv
    WHERE (cv.code_value=request->positions[d.seq].pos_code_value)
     AND cv.active_ind=1)
   ORDER BY cnvtupper(cv.display)
   HEAD REPORT
    pos_cnt = 0
   DETAIL
    pos_cnt = (pos_cnt+ 1), temp_pos->pos[pos_cnt].position_cd = cv.code_value, temp_pos->pos[pos_cnt
    ].disp = cv.display
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set=88
     AND cv.active_ind=1)
   ORDER BY cnvtupper(cv.display)
   HEAD REPORT
    cnt = 0, pos_cnt = 0, stat = alterlist(temp_pos->pos,100)
   DETAIL
    cnt = (cnt+ 1), pos_cnt = (pos_cnt+ 1)
    IF (cnt > 100)
     stat = alterlist(temp_pos->pos,(pos_cnt+ 100)), cnt = 1
    ENDIF
    temp_pos->pos[pos_cnt].position_cd = cv.code_value, temp_pos->pos[pos_cnt].disp = cv.display
   FOOT REPORT
    stat = alterlist(temp_pos->pos,pos_cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->skip_volume_check_ind=0))
  IF (pos_cnt > 100)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ENDIF
 ENDIF
 SET ag_size = size(request->app_groups,5)
 SET ag_cnt = 0
 IF (ag_size > 0)
  SET stat = alterlist(temp_ag->ag,ag_size)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(ag_size)),
    code_value cv
   PLAN (d)
    JOIN (cv
    WHERE (cv.code_value=request->app_groups[d.seq].ag_code_value)
     AND cv.active_ind=1)
   ORDER BY cnvtupper(cv.display)
   HEAD REPORT
    ag_cnt = 0
   DETAIL
    ag_cnt = (ag_cnt+ 1), temp_ag->ag[ag_cnt].ag_cd = cv.code_value, temp_ag->ag[ag_cnt].disp = cv
    .display
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set=500
     AND cv.active_ind=1)
   ORDER BY cnvtupper(cv.display)
   HEAD REPORT
    cnt = 0, ag_cnt = 0, stat = alterlist(temp_ag->ag,100)
   DETAIL
    cnt = (cnt+ 1), ag_cnt = (ag_cnt+ 1)
    IF (cnt > 100)
     stat = alterlist(temp_ag->ag,(ag_cnt+ 100)), cnt = 1
    ENDIF
    temp_ag->ag[ag_cnt].ag_cd = cv.code_value, temp_ag->ag[ag_cnt].disp = cv.display
   FOOT REPORT
    stat = alterlist(temp_ag->ag,ag_cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (pos_cnt > 0
  AND ag_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(pos_cnt)),
    application_group ag
   PLAN (d)
    JOIN (ag
    WHERE (ag.position_cd=temp_pos->pos[d.seq].position_cd)
     AND ((ag.app_group_cd+ 0) > 0)
     AND ((ag.person_id+ 0) IN (0, null))
     AND ag.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ag.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   ORDER BY d.seq, ag.app_group_cd
   DETAIL
    FOR (a = 1 TO ag_cnt)
      IF ((temp_ag->ag[a].ag_cd=ag.app_group_cd))
       tcnt = size(temp_ag->ag[a].pos,5), tcnt = (tcnt+ 1), stat = alterlist(temp_ag->ag[a].pos,tcnt),
       temp_ag->ag[a].pos[tcnt].pos_code_value = ag.position_cd, temp_ag->ag[a].pos_cnt = tcnt
      ENDIF
    ENDFOR
   WITH nocounter
  ;end select
  SET col_cnt = 1
  SET stat = alterlist(reply->collist,col_cnt)
  SET reply->collist[1].header_text = "Application Group"
  SET reply->collist[1].data_type = 1
  SET reply->collist[1].hide_ind = 0
  FOR (p = 1 TO pos_cnt)
    SET col_cnt = (col_cnt+ 1)
    SET stat = alterlist(reply->collist,col_cnt)
    SET reply->collist[col_cnt].header_text = temp_pos->pos[p].disp
    SET reply->collist[col_cnt].data_type = 1
    SET reply->collist[col_cnt].hide_ind = 0
    SET temp_pos->pos[p].index = col_cnt
  ENDFOR
  SET row_cnt = 0
  FOR (a = 1 TO ag_cnt)
    SET row_cnt = (row_cnt+ 1)
    SET stat = alterlist(reply->rowlist,row_cnt)
    SET stat = alterlist(reply->rowlist[row_cnt].celllist,col_cnt)
    SET reply->rowlist[row_cnt].celllist[1].string_value = temp_ag->ag[a].disp
    FOR (p = 1 TO temp_ag->ag[a].pos_cnt)
      SET num = 0
      SET index = 0
      SET index = locateval(num,1,pos_cnt,temp_ag->ag[a].pos[p].pos_code_value,temp_pos->pos[num].
       position_cd)
      IF (index > 0)
       SET reply->rowlist[row_cnt].celllist[temp_pos->pos[index].index].string_value = "X"
      ENDIF
    ENDFOR
  ENDFOR
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("bedrock_security_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 CALL echorecord(reply)
END GO
