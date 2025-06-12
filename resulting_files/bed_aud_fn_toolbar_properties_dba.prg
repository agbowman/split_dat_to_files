CREATE PROGRAM bed_aud_fn_toolbar_properties:dba
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
 RECORD temp(
   1 tlist[*]
     2 tracking_group_disp = vc
     2 position_cd = f8
     2 position_disp = vc
     2 button = vc
     2 action_type = i2
     2 option_id = f8
     2 option_disp = vc
     2 action = i4
     2 visible_ind = i2
     2 icon = vc
     2 last_update_by = vc
 )
 RECORD sort_temp(
   1 tlist[*]
     2 tracking_group_disp = vc
     2 position_disp = vc
     2 button = vc
     2 action_type = i2
     2 option_disp = vc
     2 visible_ind = i2
     2 icon = vc
     2 last_update_by = vc
 )
 DECLARE comp_type_cd = f8
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=20500
   AND cv.cdf_meaning="FORMASSOC"
   AND cv.active_ind=1
  DETAIL
   comp_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "NL:"
   FROM track_prefs tp,
    track_comp_prefs tcp,
    code_value cv
   PLAN (tp
    WHERE tp.comp_type_cd=comp_type_cd
     AND tp.parent_pref_id=0.0)
    JOIN (cv
    WHERE cv.code_value=cnvtint(tp.comp_pref)
     AND cv.active_ind=1)
    JOIN (tcp
    WHERE tcp.track_pref_id=tp.track_pref_id)
   DETAIL
    IF (tcp.sub_comp_pref > " ")
     high_volume_cnt = (high_volume_cnt+ 1)
    ENDIF
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
  FROM track_prefs tp,
   track_comp_prefs tcp,
   code_value cv,
   person p
  PLAN (tp
   WHERE tp.comp_type_cd=comp_type_cd
    AND tp.parent_pref_id=0.0)
   JOIN (cv
   WHERE cv.code_value=cnvtint(tp.comp_pref)
    AND cv.active_ind=1)
   JOIN (tcp
   WHERE tcp.track_pref_id=tp.track_pref_id)
   JOIN (p
   WHERE p.person_id=outerjoin(tcp.updt_id))
  DETAIL
   IF (tcp.sub_comp_pref > " ")
    semi_colon_psn = 0, semi_colon_psn = findstring(";",tp.comp_name_unq,1)
    IF (semi_colon_psn > 0)
     position_cd = 0.0, position_cd = cnvtreal(substring(1,(semi_colon_psn - 1),tp.comp_name_unq))
     IF (position_cd > 0)
      tcnt = (tcnt+ 1), stat = alterlist(temp->tlist,tcnt), temp->tlist[tcnt].tracking_group_disp =
      cv.display,
      temp->tlist[tcnt].position_cd = position_cd, temp->tlist[tcnt].button = tcp.sub_comp_name, temp
      ->tlist[tcnt].last_update_by = p.name_full_formatted,
      temp->tlist[tcnt].action_type = cnvtint(substring(1,1,tcp.sub_comp_pref))
      IF ((temp->tlist[tcnt].action_type=1))
       end_pos = findstring(";",tcp.sub_comp_pref,3,0), temp->tlist[tcnt].option_id = cnvtint(
        substring(3,(end_pos - 3),tcp.sub_comp_pref)), beg_pos = (end_pos+ 1),
       end_pos = findstring(";",tcp.sub_comp_pref,beg_pos,0), temp->tlist[tcnt].action = cnvtint(
        substring(beg_pos,(end_pos - beg_pos),tcp.sub_comp_pref)), beg_pos = (end_pos+ 1),
       temp->tlist[tcnt].visible_ind = cnvtint(substring(beg_pos,1,tcp.sub_comp_pref)), end_pos =
       size(trim(tcp.sub_comp_pref),1), beg_pos = (beg_pos+ 2)
       IF (end_pos > beg_pos)
        temp->tlist[tcnt].icon = substring(beg_pos,((end_pos - beg_pos)+ 1),tcp.sub_comp_pref)
       ENDIF
      ELSEIF ((temp->tlist[tcnt].action_type=2))
       end_pos = findstring(";",tcp.sub_comp_pref,3,0), temp->tlist[tcnt].option_id = cnvtint(
        substring(3,(end_pos - 3),tcp.sub_comp_pref)), beg_pos = (end_pos+ 1),
       temp->tlist[tcnt].visible_ind = cnvtint(substring(beg_pos,1,tcp.sub_comp_pref)), end_pos =
       size(trim(tcp.sub_comp_pref),1), beg_pos = (beg_pos+ 2)
       IF (end_pos > beg_pos)
        temp->tlist[tcnt].icon = substring(beg_pos,((end_pos - beg_pos)+ 1),tcp.sub_comp_pref)
       ENDIF
      ELSEIF ((temp->tlist[tcnt].action_type=3))
       end_pos = findstring(";",tcp.sub_comp_pref,3,0), temp->tlist[tcnt].visible_ind = cnvtint(
        substring(3,1,tcp.sub_comp_pref)), end_pos = size(trim(tcp.sub_comp_pref),1),
       beg_pos = 5
       IF (end_pos > beg_pos)
        temp->tlist[tcnt].icon = substring(beg_pos,((end_pos - beg_pos)+ 1),tcp.sub_comp_pref)
       ENDIF
       temp->tlist[tcnt].option_disp = "Pre-Arrival Form"
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (tcnt > 0)
  SELECT INTO "NL"
   FROM (dummyt d  WITH seq = tcnt),
    code_value cv
   PLAN (d)
    JOIN (cv
    WHERE (cv.code_value=temp->tlist[d.seq].position_cd)
     AND cv.active_ind=1)
   DETAIL
    temp->tlist[d.seq].position_disp = cv.display
   WITH nocounter
  ;end select
  SELECT INTO "NL"
   FROM (dummyt d  WITH seq = tcnt),
    pm_flx_conversation p,
    pm_flx_task_conv_reltn p2
   PLAN (d)
    JOIN (p
    WHERE (temp->tlist[d.seq].action_type=1)
     AND p.active_ind=1)
    JOIN (p2
    WHERE p2.conversation_id=p.conversation_id
     AND p2.active_ind=1
     AND (p2.task=temp->tlist[d.seq].option_id))
   DETAIL
    temp->tlist[d.seq].option_disp = p.description
   WITH nocounter
  ;end select
  SELECT INTO "NL"
   FROM (dummyt d  WITH seq = tcnt),
    dcp_forms_ref dfr
   PLAN (d)
    JOIN (dfr
    WHERE (temp->tlist[d.seq].action_type=2)
     AND (dfr.dcp_forms_ref_id=temp->tlist[d.seq].option_id))
   DETAIL
    temp->tlist[d.seq].option_disp = dfr.description
   WITH nocounter
  ;end select
  SET stat = alterlist(sort_temp->tlist,tcnt)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = tcnt)
   PLAN (d)
   ORDER BY temp->tlist[d.seq].tracking_group_disp, temp->tlist[d.seq].position_disp
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1), sort_temp->tlist[cnt].tracking_group_disp = temp->tlist[d.seq].
    tracking_group_disp, sort_temp->tlist[cnt].position_disp = temp->tlist[d.seq].position_disp,
    sort_temp->tlist[cnt].button = temp->tlist[d.seq].button, sort_temp->tlist[cnt].action_type =
    temp->tlist[d.seq].action_type, sort_temp->tlist[cnt].option_disp = temp->tlist[d.seq].
    option_disp,
    sort_temp->tlist[cnt].visible_ind = temp->tlist[d.seq].visible_ind, sort_temp->tlist[cnt].icon =
    temp->tlist[d.seq].icon, sort_temp->tlist[cnt].last_update_by = temp->tlist[d.seq].last_update_by
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->collist,8)
 SET reply->collist[1].header_text = "Tracking Group"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Position"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Button"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Action Type"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Action Option"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Visible"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Icon"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Last Update By"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 DECLARE string_size = i2
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,8)
   SET reply->rowlist[row_nbr].celllist[1].string_value = sort_temp->tlist[x].tracking_group_disp
   SET reply->rowlist[row_nbr].celllist[2].string_value = sort_temp->tlist[x].position_disp
   SET reply->rowlist[row_nbr].celllist[3].string_value = substring(10,1,sort_temp->tlist[x].button)
   IF ((sort_temp->tlist[x].action_type=1))
    SET reply->rowlist[row_nbr].celllist[4].string_value = "Conversation"
   ELSEIF ((sort_temp->tlist[x].action_type=2))
    SET reply->rowlist[row_nbr].celllist[4].string_value = "Powerform"
   ELSEIF ((sort_temp->tlist[x].action_type=3))
    SET reply->rowlist[row_nbr].celllist[4].string_value = "Pre-Arrival"
   ENDIF
   SET reply->rowlist[row_nbr].celllist[5].string_value = sort_temp->tlist[x].option_disp
   IF ((sort_temp->tlist[x].visible_ind=1))
    SET reply->rowlist[row_nbr].celllist[6].string_value = "yes"
   ELSE
    SET reply->rowlist[row_nbr].celllist[6].string_value = "no"
   ENDIF
   SET string_size = size(sort_temp->tlist[x].icon,1)
   SET reply->rowlist[row_nbr].celllist[7].string_value = substring(3,(string_size - 2),sort_temp->
    tlist[x].icon)
   SET reply->rowlist[row_nbr].celllist[8].string_value = sort_temp->tlist[x].last_update_by
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("firstnet_toolbar_properties.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
