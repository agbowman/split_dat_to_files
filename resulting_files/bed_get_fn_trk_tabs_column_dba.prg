CREATE PROGRAM bed_get_fn_trk_tabs_column:dba
 FREE SET reply
 RECORD reply(
   1 tabs[*]
     2 name_value_prefs_id = f8
     2 name = vc
     2 list_type = vc
     2 sequence = i2
     2 refresh_time = i4
     2 refresh_unit = i2
     2 scroll_time = i4
     2 scroll_unit = i2
     2 column_view
       3 id = f8
       3 name = vc
     2 custom_filter_id = f8
     2 location_view
       3 code_value = f8
       3 display = vc
       3 description = vc
       3 mean = vc
     2 trk_group_code_value = f8
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET beg_pos = 0
 SET end_pos = 0
 SET temp_beg_pos = 0
 SET temp_end_pos = 0
 SET tab_count = 0
 SET tot_tab_count = 0
 SET col_count = 0
 SET tot_col_count = 0
 DECLARE search_string = vc
 IF ((request->trk_group_code_value > 0))
  SET search_string1 = build('"TRKBEDLIST*',cnvtint(request->trk_group_code_value),'*"')
  SET search_string2 = build('"LOCATION*',cnvtint(request->trk_group_code_value),'*"')
  SET search_string3 = build('"TRKPRVLIST*',cnvtint(request->trk_group_code_value),'*"')
  SET search_string4 = build('"TRKGROUP*',cnvtint(request->trk_group_code_value),'*"')
 ELSE
  SET search_string1 = '"TRKBEDLIST*"'
  SET search_string2 = '"LOCATION*"'
  SET search_string3 = '"TRKPRVLIST*"'
  SET search_string4 = '"TRKGROUP*"'
 ENDIF
 DECLARE nvp_parser = vc
 SET nvp_parser = concat('nvp.active_ind = 1 and nvp.pvc_name = "TABINFO" and ',
  'nvp.parent_entity_name = "DETAIL_PREFS" and ',"(nvp.pvc_value = ",trim(search_string1)," or ",
  "nvp.pvc_value = ",trim(search_string2)," or ","nvp.pvc_value = ",trim(search_string3),
  " or ","nvp.pvc_value = ",trim(search_string4),")")
 DECLARE nvp_vp_parser = vc
 SET nvp_vp_parser = concat('nvp_vp.active_ind = 1 and nvp_vp.pvc_name = "VIEW_CAPTION" and ',
  "nvp_vp.parent_entity_id  = vp.view_prefs_id")
 IF ((request->tab_name > "   *"))
  SET nvp_vp_parser = concat(trim(nvp_vp_parser),' and nvp_vp.pvc_value = "',trim(request->tab_name),
   '"')
 ENDIF
 DECLARE nvp_vp_parser2 = vc
 SET nvp_vp_parser2 = concat('nvp_vp2.active_ind = 1 and nvp_vp2.pvc_name = "DISPLAY_SEQ" and ',
  "nvp_vp2.parent_entity_id  = vp.view_prefs_id")
 SELECT INTO "NL:"
  FROM name_value_prefs nvp,
   detail_prefs dp,
   view_prefs vp,
   name_value_prefs nvp_vp,
   name_value_prefs nvp_vp2
  PLAN (nvp
   WHERE parser(nvp_parser))
   JOIN (dp
   WHERE dp.detail_prefs_id=nvp.parent_entity_id
    AND dp.active_ind=1
    AND dp.application_number=4250111
    AND (dp.position_cd=request->position_code_value)
    AND dp.prsnl_id=0.0
    AND dp.person_id=0.0
    AND dp.view_name="TRKLISTVIEW"
    AND dp.comp_name="CUSTOM"
    AND dp.comp_seq=1)
   JOIN (vp
   WHERE vp.active_ind=1
    AND vp.application_number=4250111
    AND (vp.position_cd=request->position_code_value)
    AND vp.frame_type="TRACKLIST"
    AND vp.view_name="TRKLISTVIEW"
    AND vp.view_seq=dp.view_seq)
   JOIN (nvp_vp
   WHERE parser(nvp_vp_parser))
   JOIN (nvp_vp2
   WHERE parser(nvp_vp_parser2))
  HEAD REPORT
   stat = alterlist(reply->tabs,10)
  DETAIL
   tot_length = 0, temp_beg_pos = 0, temp_end_pos = 0,
   temp_tot_length = 0, refresh_time = 0, refresh_unit = 0,
   scroll_time = 0, scroll_unit = 0, filter_all_prv = 0,
   filter_unavail_prv = 0, filter_id = 0.0, bed_view_cd = 0.0,
   list_type_cd = 0.0, column_view_id = 0.0, track_group_cd = 0.0,
   filter_id = 0.0, location_view_cd = 0.0, loc_security_cd = 0.0,
   edit_security_cd = 0.0, filters = fillstring(100," "), filter_from_date = fillstring(20," "),
   filter_to_date = fillstring(20," "), refresh_rate = fillstring(10," "), scroll_rate = fillstring(
    10," ")
   IF (nvp.pvc_value="TRKBEDLIST*")
    tot_length = size(nvp.pvc_value,1), beg_pos = 1, end_pos = findstring(";",nvp.pvc_value,beg_pos,0
     ),
    list_type = substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value), beg_pos = (end_pos+ 1), end_pos
     = findstring(";",nvp.pvc_value,beg_pos,0),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos), bed_view_cd = cnvtreal(
     substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), empty_values = substring(beg_pos,8,nvp.pvc_value), beg_pos = (beg_pos+ 8),
    end_pos = findstring(";",nvp.pvc_value,beg_pos,0), list_type_cd = cnvtreal(substring(beg_pos,(
      end_pos - beg_pos),nvp.pvc_value)), beg_pos = (end_pos+ 1),
    end_pos = findstring(";",nvp.pvc_value,beg_pos,0), column_view_id = cnvtreal(substring(beg_pos,(
      end_pos - beg_pos),nvp.pvc_value)), beg_pos = (end_pos+ 1),
    end_pos = findstring(";",nvp.pvc_value,beg_pos,0), track_group_cd = cnvtreal(substring(beg_pos,(
      end_pos - beg_pos),nvp.pvc_value)), beg_pos = (end_pos+ 1),
    end_pos = findstring(";",nvp.pvc_value,beg_pos,0), refresh_rate = substring(beg_pos,(end_pos -
     beg_pos),nvp.pvc_value)
    IF (refresh_rate != "0")
     temp_tot_length = (end_pos - beg_pos), temp_end_pos = findstring(",",trim(refresh_rate),1,0),
     refresh_unit = cnvtint(substring(1,1,refresh_rate)),
     temp_beg_pos = (temp_end_pos+ 1), refresh_time = cnvtint(substring(temp_beg_pos,temp_tot_length,
       refresh_rate))
    ENDIF
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), filter_id = cnvtreal(
     substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), location_view_cd =
    cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), scroll_rate =
    substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)
    IF (scroll_rate != "0")
     temp_tot_length = (end_pos - beg_pos), temp_end_pos = findstring(",",trim(scroll_rate),1,0),
     scroll_unit = cnvtint(substring(1,(temp_end_pos - 1),scroll_rate)),
     temp_beg_pos = (temp_end_pos+ 1), scroll_time = cnvtint(substring(temp_beg_pos,temp_tot_length,
       scroll_rate))
    ENDIF
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), loc_security_cd =
    cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), edit_security_cd =
    cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), dnbr = cnvtint(substring(beg_pos,tot_length,nvp.pvc_value))
   ELSEIF (nvp.pvc_value="LOCATION*")
    tot_length = size(nvp.pvc_value,1), beg_pos = 1, end_pos = findstring(";",nvp.pvc_value,beg_pos,0
     ),
    list_type = substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value), beg_pos = (end_pos+ 1), end_pos
     = findstring(";",nvp.pvc_value,beg_pos,0),
    facility_cd = 0.0, building_cd = 0.0, unit_cd = 0.0,
    room_cd = 0.0, bed_cd = 0.0, beg_pos = (end_pos+ 1),
    end_pos = findstring(";",nvp.pvc_value,beg_pos), facility_cd = cnvtreal(substring(beg_pos,(
      end_pos - beg_pos),nvp.pvc_value)), beg_pos = (end_pos+ 1),
    end_pos = findstring(";",nvp.pvc_value,beg_pos), building_cd = cnvtreal(substring(beg_pos,(
      end_pos - beg_pos),nvp.pvc_value)), beg_pos = (end_pos+ 1),
    end_pos = findstring(";",nvp.pvc_value,beg_pos), unit_cd = cnvtreal(substring(beg_pos,(end_pos -
      beg_pos),nvp.pvc_value)), beg_pos = (end_pos+ 1),
    end_pos = findstring(";",nvp.pvc_value,beg_pos), room_cd = cnvtreal(substring(beg_pos,(end_pos -
      beg_pos),nvp.pvc_value)), beg_pos = (end_pos+ 1),
    end_pos = findstring(";",nvp.pvc_value,beg_pos), bed_cd = cnvtreal(substring(beg_pos,(end_pos -
      beg_pos),nvp.pvc_value)), beg_pos = (end_pos+ 1),
    end_pos = findstring(";",nvp.pvc_value,beg_pos,0), list_type_cd = cnvtreal(substring(beg_pos,(
      end_pos - beg_pos),nvp.pvc_value)), beg_pos = (end_pos+ 1),
    end_pos = findstring(";",nvp.pvc_value,beg_pos,0), column_view_id = cnvtreal(substring(beg_pos,(
      end_pos - beg_pos),nvp.pvc_value)), beg_pos = (end_pos+ 1),
    end_pos = findstring(";",nvp.pvc_value,beg_pos,0), track_group_cd = cnvtreal(substring(beg_pos,(
      end_pos - beg_pos),nvp.pvc_value)), beg_pos = (end_pos+ 1),
    end_pos = findstring(";",nvp.pvc_value,beg_pos,0), refresh_rate = substring(beg_pos,(end_pos -
     beg_pos),nvp.pvc_value)
    IF (refresh_rate != "0")
     temp_tot_length = (end_pos - beg_pos), temp_end_pos = findstring(",",trim(refresh_rate),1,0),
     refresh_unit = cnvtint(substring(1,1,refresh_rate)),
     temp_beg_pos = (temp_end_pos+ 1), refresh_time = cnvtint(substring(temp_beg_pos,temp_tot_length,
       refresh_rate))
    ENDIF
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), filter_id = cnvtreal(
     substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), location_view_cd =
    cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), scroll_rate =
    substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)
    IF (scroll_rate != "0")
     temp_tot_length = (end_pos - beg_pos), temp_end_pos = findstring(",",trim(scroll_rate),1,0),
     scroll_unit = cnvtint(substring(1,(temp_end_pos - 1),scroll_rate)),
     temp_beg_pos = (temp_end_pos+ 1), scroll_time = cnvtint(substring(temp_beg_pos,temp_tot_length,
       scroll_rate))
    ENDIF
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), loc_security_cd =
    cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), edit_security_cd =
    cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), dnbr = cnvtint(substring(beg_pos,tot_length,nvp.pvc_value))
   ELSEIF (nvp.pvc_value="TRKPRVLIST*")
    tot_length = size(nvp.pvc_value,1), beg_pos = 1, end_pos = findstring(";",nvp.pvc_value,beg_pos,0
     ),
    list_type = substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value), beg_pos = (end_pos+ 1), end_pos
     = findstring(";",nvp.pvc_value,beg_pos,0),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), temp = substring(
     beg_pos,(end_pos - beg_pos),nvp.pvc_value),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), list_type_cd =
    cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), column_view_id =
    cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), track_group_cd =
    cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), refresh_rate =
    substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)
    IF (refresh_rate != "0")
     temp_tot_length = (end_pos - beg_pos), temp_end_pos = findstring(",",trim(refresh_rate),1,0),
     refresh_unit = cnvtint(substring(1,1,refresh_rate)),
     temp_beg_pos = (temp_end_pos+ 1), refresh_time = cnvtint(substring(temp_beg_pos,temp_tot_length,
       refresh_rate))
    ENDIF
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), filter_id = cnvtreal(
     substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), location_view_cd =
    cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), scroll_rate =
    substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)
    IF (scroll_rate != "0")
     temp_tot_length = (end_pos - beg_pos), temp_end_pos = findstring(",",trim(scroll_rate),1,0),
     scroll_unit = cnvtint(substring(1,(temp_end_pos - 1),scroll_rate)),
     temp_beg_pos = (temp_end_pos+ 1), scroll_time = cnvtint(substring(temp_beg_pos,temp_tot_length,
       scroll_rate))
    ENDIF
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), loc_security_cd =
    cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), edit_security_cd =
    cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), dnbr = cnvtint(substring(beg_pos,tot_length,nvp.pvc_value))
   ELSEIF (nvp.pvc_value="TRKGROUP*")
    tot_length = size(nvp.pvc_value,1), beg_pos = 1, end_pos = findstring(";",nvp.pvc_value,beg_pos,0
     ),
    list_type = substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value), beg_pos = (end_pos+ 1), end_pos
     = findstring(";",nvp.pvc_value,beg_pos,0),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), temp = substring(
     beg_pos,(end_pos - beg_pos),nvp.pvc_value),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), list_type_cd =
    cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), column_view_id =
    cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), track_group_cd =
    cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), refresh_rate =
    substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)
    IF (refresh_rate != "0")
     temp_tot_length = (end_pos - beg_pos), temp_end_pos = findstring(",",trim(refresh_rate),1,0),
     refresh_unit = cnvtint(substring(1,1,refresh_rate)),
     temp_beg_pos = (temp_end_pos+ 1), refresh_time = cnvtint(substring(temp_beg_pos,temp_tot_length,
       refresh_rate))
    ENDIF
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), filter_id = cnvtreal(
     substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), location_view_cd =
    cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), scroll_rate =
    substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)
    IF (scroll_rate != "0")
     temp_tot_length = (end_pos - beg_pos), temp_end_pos = findstring(",",trim(scroll_rate),1,0),
     scroll_unit = cnvtint(substring(1,(temp_end_pos - 1),scroll_rate)),
     temp_beg_pos = (temp_end_pos+ 1), scroll_time = cnvtint(substring(temp_beg_pos,temp_tot_length,
       scroll_rate))
    ENDIF
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), loc_security_cd =
    cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), end_pos = findstring(";",nvp.pvc_value,beg_pos,0), edit_security_cd =
    cnvtreal(substring(beg_pos,(end_pos - beg_pos),nvp.pvc_value)),
    beg_pos = (end_pos+ 1), dnbr = cnvtint(substring(beg_pos,tot_length,nvp.pvc_value))
   ENDIF
   found = 0
   FOR (i = 1 TO tot_tab_count)
     IF ((reply->tabs[i].name=nvp_vp.pvc_value)
      AND (reply->tabs[i].list_type=list_type)
      AND (reply->tabs[i].sequence=cnvtint(nvp_vp2.pvc_value)))
      found = 1, i = tot_tab_count
     ENDIF
   ENDFOR
   IF (found=0)
    tab_count = (tab_count+ 1), tot_tab_count = (tot_tab_count+ 1)
    IF (tab_count > 10)
     stat = alterlist(reply->tabs,(tot_tab_count+ 10))
    ENDIF
    reply->tabs[tot_tab_count].name_value_prefs_id = nvp.name_value_prefs_id, reply->tabs[
    tot_tab_count].name = trim(nvp_vp.pvc_value), reply->tabs[tot_tab_count].sequence = cnvtint(
     nvp_vp2.pvc_value),
    reply->tabs[tot_tab_count].list_type = list_type, reply->tabs[tot_tab_count].column_view.id =
    column_view_id, reply->tabs[tot_tab_count].custom_filter_id = filter_id,
    reply->tabs[tot_tab_count].location_view.code_value = location_view_cd, reply->tabs[tot_tab_count
    ].refresh_time = refresh_time, reply->tabs[tot_tab_count].refresh_unit = refresh_unit,
    reply->tabs[tot_tab_count].scroll_time = scroll_time, reply->tabs[tot_tab_count].scroll_unit =
    scroll_unit, reply->tabs[tot_tab_count].trk_group_code_value = track_group_cd
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->tabs,tot_tab_count)
  WITH nocounter
 ;end select
 IF (tot_tab_count > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = tot_tab_count),
    predefined_prefs pp
   PLAN (d
    WHERE (reply->tabs[d.seq].column_view.id > 0))
    JOIN (pp
    WHERE pp.active_ind=1
     AND pp.predefined_type_meaning="TRK*"
     AND (pp.predefined_prefs_id=reply->tabs[d.seq].column_view.id))
   DETAIL
    reply->tabs[d.seq].column_view.name = pp.name
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = tot_tab_count),
    code_value cv
   PLAN (d
    WHERE (reply->tabs[d.seq].location_view.code_value > 0.0))
    JOIN (cv
    WHERE (cv.code_value=reply->tabs[d.seq].location_view.code_value))
   DETAIL
    reply->tabs[d.seq].location_view.display = cv.display, reply->tabs[d.seq].location_view.
    description = cv.description, reply->tabs[d.seq].location_view.mean = cv.cdf_meaning
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (tot_tab_count > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
