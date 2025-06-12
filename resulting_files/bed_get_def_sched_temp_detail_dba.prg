CREATE PROGRAM bed_get_def_sched_temp_detail:dba
 FREE SET reply
 RECORD reply(
   1 logical_domain_id = f8
   1 uk_date_format = vc
   1 day_begin = vc
   1 day_end = vc
   1 apply_begin = vc
   1 apply_end = vc
   1 apply_occurrences = vc
   1 apply_range = vc
   1 week_opt_nbr_of_weeks = vc
   1 week_opt_days_of_week = vc
   1 month_opt1_dates_of_month = vc
   1 month_opt1_nbr_of_months = vc
   1 month_opt2_weeks_of_month = vc
   1 month_opt2_days_of_week = vc
   1 month_opt2_nbr_of_months = vc
   1 year_opt1_months_of_year = vc
   1 year_opt1_dates_of_month = vc
   1 year_opt2_weeks_of_month = vc
   1 year_opt2_days_of_week = vc
   1 year_opt2_months_of_year = vc
   1 resources[*]
     2 code_value = f8
     2 name = vc
     2 sch_res_mnemonic = vc
     2 sch_res_refer_text_id = f8
     2 sch_res_refer_text = vc
     2 sch_res_refer_text_updt_cnt = i4
     2 sch_res_updt_cnt = i4
     2 bedrock_res_type_id = f8
     2 bedrock_res_type_name = vc
     2 bedrock_res_type_display = vc
     2 person_id = f8
     2 person_name = vc
     2 position_code_value = f8
     2 position_display = vc
     2 serv_res_code_value = f8
     2 serv_res_display = vc
     2 subsect_code_value = f8
     2 subsect_display = vc
     2 sect_code_value = f8
     2 sect_display = vc
   1 slots[*]
     2 name = vc
     2 type_id = f8
     2 type_name = vc
     2 type_description = vc
     2 type_interval = i4
     2 type_duration = i4
     2 type_contiguous_ind = i2
     2 type_flex_rule_id = f8
     2 type_flex_rule_display = vc
     2 type_priority_cd = f8
     2 type_priority_display = vc
     2 type_disp_scheme_id = f8
     2 type_disp_scheme_display = vc
     2 type_disp_scheme_border_size = i4
     2 type_disp_scheme_border_color = i4
     2 type_disp_scheme_border_style = i4
     2 type_disp_scheme_shape = i4
     2 type_disp_scheme_pen_shape = i4
     2 start_time = vc
     2 end_time = vc
     2 interval = vc
     2 time_block = vc
     2 releases[*]
       3 name = vc
       3 type_id = f8
       3 type_name = vc
       3 type_description = vc
       3 type_interval = i4
       3 type_duration = i4
       3 type_contiguous_ind = i2
       3 type_flex_rule_id = f8
       3 type_flex_rule_display = vc
       3 type_priority_cd = f8
       3 type_priority_display = vc
       3 type_disp_scheme_id = f8
       3 type_disp_scheme_display = vc
       3 type_disp_scheme_border_size = i4
       3 type_disp_scheme_border_color = i4
       3 type_disp_scheme_border_style = i4
       3 type_disp_scheme_shape = i4
       3 type_disp_scheme_pen_shape = i4
       3 start_time = vc
       3 end_time = vc
       3 unit = vc
       3 unit_code_value = f8
       3 unit_display = vc
       3 unit_value = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET sect_cd = 0.0
 SET subsect_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=223
   AND cv.cdf_meaning IN ("SECTION", "SUBSECTION")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="SECTION")
    sect_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="SUBSECTION")
    subsect_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 DECLARE phy_res_type_id = f8
 DECLARE phy_res_type_name = vc
 DECLARE phy_res_type_display = vc
 DECLARE nurse_res_type_id = f8
 DECLARE nurse_res_type_name = vc
 DECLARE nurse_res_type_display = vc
 DECLARE thera_res_type_id = f8
 DECLARE thera_res_type_name = vc
 DECLARE thera_res_type_display = vc
 DECLARE other_res_type_id = f8
 DECLARE other_res_type_name = vc
 DECLARE other_res_type_display = vc
 DECLARE room_res_type_id = f8
 DECLARE room_res_type_name = vc
 DECLARE room_res_type_display = vc
 SELECT INTO "nl:"
  FROM br_name_value b
  WHERE b.br_nv_key1="SCHRESGROUP"
   AND b.br_name IN ("PHY", "NURSE", "THERA", "OTHER", "ROOM")
  DETAIL
   IF (b.br_name="PHY")
    phy_res_type_id = b.br_name_value_id, phy_res_type_name = b.br_name, phy_res_type_display = b
    .br_value
   ELSEIF (b.br_name="NURSE")
    nurse_res_type_id = b.br_name_value_id, nurse_res_type_name = b.br_name, nurse_res_type_display
     = b.br_value
   ELSEIF (b.br_name="THERA")
    thera_res_type_id = b.br_name_value_id, thera_res_type_name = b.br_name, thera_res_type_display
     = b.br_value
   ELSEIF (b.br_name="OTHER")
    other_res_type_id = b.br_name_value_id, other_res_type_name = b.br_name, other_res_type_display
     = b.br_value
   ELSEIF (b.br_name="ROOM")
    room_res_type_id = b.br_name_value_id, room_res_type_name = b.br_name, room_res_type_display = b
    .br_value
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM br_sch_template b1,
   br_sch_temp_res_r b2,
   sch_resource s,
   long_text_reference ltr,
   br_name_value bnv,
   prsnl p,
   code_value cvpos,
   code_value cvloc,
   resource_group rg1,
   resource_group rg2,
   code_value cvsub,
   code_value cvsect
  PLAN (b1
   WHERE (b1.br_sch_template_id=request->br_sch_template_id))
   JOIN (b2
   WHERE b2.br_sch_template_id=outerjoin(b1.br_sch_template_id))
   JOIN (s
   WHERE s.mnemonic_key=outerjoin(cnvtupper(b2.resource_name))
    AND s.quota=outerjoin(0)
    AND s.active_ind=outerjoin(1))
   JOIN (ltr
   WHERE ltr.long_text_id=outerjoin(s.info_sch_text_id)
    AND ltr.active_ind=outerjoin(1))
   JOIN (bnv
   WHERE bnv.br_nv_key1=outerjoin("SCHRESGROUPRES")
    AND bnv.br_name=outerjoin(cnvtstring(s.resource_cd)))
   JOIN (p
   WHERE p.person_id=outerjoin(s.person_id)
    AND p.active_ind=outerjoin(1))
   JOIN (cvpos
   WHERE cvpos.code_value=outerjoin(p.position_cd)
    AND cvpos.active_ind=outerjoin(1))
   JOIN (cvloc
   WHERE cvloc.code_value=outerjoin(s.service_resource_cd)
    AND cvloc.active_ind=outerjoin(1))
   JOIN (rg1
   WHERE rg1.child_service_resource_cd=outerjoin(cvloc.code_value)
    AND rg1.resource_group_type_cd=outerjoin(subsect_cd)
    AND rg1.active_ind=outerjoin(1))
   JOIN (rg2
   WHERE rg2.child_service_resource_cd=outerjoin(rg1.parent_service_resource_cd)
    AND rg2.resource_group_type_cd=outerjoin(sect_cd)
    AND rg2.active_ind=outerjoin(1))
   JOIN (cvsub
   WHERE cvsub.code_value=outerjoin(rg1.parent_service_resource_cd)
    AND cvsub.active_ind=outerjoin(1))
   JOIN (cvsect
   WHERE cvsect.code_value=outerjoin(rg2.parent_service_resource_cd)
    AND cvsect.active_ind=outerjoin(1))
  ORDER BY b1.br_sch_template_id
  HEAD b1.br_sch_template_id
   reply->logical_domain_id = b1.logical_domain_id, reply->uk_date_format = b1.uk_date_format_str,
   reply->day_begin = b1.daybegin_str,
   reply->day_end = b1.dayend_str, reply->apply_begin = b1.apply_beg_dt_tm_string, reply->apply_end
    = b1.apply_end_dt_tm_string,
   reply->apply_occurrences = b1.apply_occurrences_str, reply->apply_range = b1.apply_range_str,
   reply->week_opt_nbr_of_weeks = b1.week_opt_nbrofweeks,
   reply->week_opt_days_of_week = b1.week_opt_daysofweek, reply->month_opt1_dates_of_month = b1
   .month_opt1_datesofmonth, reply->month_opt1_nbr_of_months = b1.month_opt1_nbrofmonths,
   reply->month_opt2_weeks_of_month = b1.month_opt2_weeksofmonth, reply->month_opt2_days_of_week = b1
   .month_opt2_daysofweek, reply->month_opt2_nbr_of_months = b1.month_opt2_nbrofmonths,
   reply->year_opt1_months_of_year = b1.year_opt1_monthsofyear, reply->year_opt1_dates_of_month = b1
   .year_opt1_datesofmonth, reply->year_opt2_weeks_of_month = b1.year_opt2_weeksofmonth,
   reply->year_opt2_days_of_week = b1.year_opt2_daysofweek, reply->year_opt2_months_of_year = b1
   .year_opt2_monthsofyear, rcnt = 0
  DETAIL
   rcnt = (rcnt+ 1), stat = alterlist(reply->resources,rcnt), reply->resources[rcnt].code_value = s
   .resource_cd,
   reply->resources[rcnt].name = b2.resource_name, reply->resources[rcnt].sch_res_mnemonic = s
   .mnemonic, reply->resources[rcnt].sch_res_refer_text_id = ltr.long_text_id,
   reply->resources[rcnt].sch_res_refer_text = ltr.long_text, reply->resources[rcnt].
   sch_res_refer_text_updt_cnt = ltr.updt_cnt, reply->resources[rcnt].sch_res_updt_cnt = s.updt_cnt
   IF (bnv.br_value=cnvtstring(phy_res_type_id))
    reply->resources[rcnt].bedrock_res_type_id = phy_res_type_id, reply->resources[rcnt].
    bedrock_res_type_name = phy_res_type_name, reply->resources[rcnt].bedrock_res_type_display =
    phy_res_type_display
   ELSEIF (bnv.br_value=cnvtstring(nurse_res_type_id))
    reply->resources[rcnt].bedrock_res_type_id = nurse_res_type_id, reply->resources[rcnt].
    bedrock_res_type_name = nurse_res_type_name, reply->resources[rcnt].bedrock_res_type_display =
    nurse_res_type_display
   ELSEIF (bnv.br_value=cnvtstring(thera_res_type_id))
    reply->resources[rcnt].bedrock_res_type_id = thera_res_type_id, reply->resources[rcnt].
    bedrock_res_type_name = thera_res_type_name, reply->resources[rcnt].bedrock_res_type_display =
    thera_res_type_display
   ELSEIF (bnv.br_value=cnvtstring(other_res_type_id))
    reply->resources[rcnt].bedrock_res_type_id = other_res_type_id, reply->resources[rcnt].
    bedrock_res_type_name = other_res_type_name, reply->resources[rcnt].bedrock_res_type_display =
    other_res_type_display
   ELSEIF (bnv.br_value=cnvtstring(room_res_type_id))
    reply->resources[rcnt].bedrock_res_type_id = room_res_type_id, reply->resources[rcnt].
    bedrock_res_type_name = room_res_type_name, reply->resources[rcnt].bedrock_res_type_display =
    room_res_type_display
   ENDIF
   reply->resources[rcnt].person_id = p.person_id, reply->resources[rcnt].person_name = p
   .name_full_formatted, reply->resources[rcnt].position_code_value = cvpos.code_value,
   reply->resources[rcnt].position_display = cvpos.display, reply->resources[rcnt].
   serv_res_code_value = cvloc.code_value, reply->resources[rcnt].serv_res_display = cvloc.display,
   reply->resources[rcnt].subsect_code_value = cvsub.code_value, reply->resources[rcnt].
   subsect_display = cvsub.display, reply->resources[rcnt].sect_code_value = cvsect.code_value,
   reply->resources[rcnt].sect_display = cvsect.display
  WITH nocounter
 ;end select
 SET scnt = 0
 SELECT INTO "nl:"
  FROM br_sch_temp_slot_r b1,
   sch_slot_type s1,
   code_value cv1,
   sch_disp_scheme sds1,
   sch_flex_string sfs1,
   br_sch_temp_slot_release_r b2,
   sch_slot_type s2,
   code_value cv2,
   sch_disp_scheme sds2,
   sch_flex_string sfs2,
   code_value cv3
  PLAN (b1
   WHERE (b1.br_sch_template_id=request->br_sch_template_id))
   JOIN (s1
   WHERE s1.mnemonic_key=outerjoin(cnvtupper(b1.slot_name))
    AND s1.active_ind=outerjoin(1))
   JOIN (cv1
   WHERE cv1.code_value=outerjoin(s1.priority_cd)
    AND cv1.active_ind=outerjoin(1))
   JOIN (sds1
   WHERE sds1.disp_scheme_id=outerjoin(s1.disp_scheme_id)
    AND sds1.active_ind=outerjoin(1))
   JOIN (sfs1
   WHERE sfs1.sch_flex_id=outerjoin(s1.sch_flex_id)
    AND sfs1.active_ind=outerjoin(1))
   JOIN (b2
   WHERE b2.br_sch_temp_slot_r_id=outerjoin(b1.br_sch_temp_slot_r_id))
   JOIN (s2
   WHERE s2.mnemonic_key=outerjoin(cnvtupper(b2.release_name))
    AND s2.active_ind=outerjoin(1))
   JOIN (cv2
   WHERE cv2.code_value=outerjoin(s2.priority_cd)
    AND cv2.active_ind=outerjoin(1))
   JOIN (sds2
   WHERE sds2.disp_scheme_id=outerjoin(s2.disp_scheme_id)
    AND sds2.active_ind=outerjoin(1))
   JOIN (sfs2
   WHERE sfs2.sch_flex_id=outerjoin(s2.sch_flex_id)
    AND sfs2.active_ind=outerjoin(1))
   JOIN (cv3
   WHERE cv3.cdf_meaning=outerjoin(b2.release_unit)
    AND cv3.code_set=outerjoin(54)
    AND cv3.active_ind=outerjoin(1))
  ORDER BY b1.br_sch_temp_slot_r_id
  HEAD b1.br_sch_temp_slot_r_id
   scnt = (scnt+ 1), stat = alterlist(reply->slots,scnt), reply->slots[scnt].name = b1.slot_name,
   reply->slots[scnt].start_time = b1.slot_start_str, reply->slots[scnt].end_time = b1.slot_end_str,
   reply->slots[scnt].interval = b1.interval_str,
   reply->slots[scnt].type_id = s1.slot_type_id, reply->slots[scnt].time_block = b1.time_block_str,
   reply->slots[scnt].type_name = s1.mnemonic,
   reply->slots[scnt].type_description = s1.description, reply->slots[scnt].type_interval = s1
   .interval, reply->slots[scnt].type_duration = s1.def_duration,
   reply->slots[scnt].type_contiguous_ind = s1.contiguous_ind, reply->slots[scnt].type_flex_rule_id
    = s1.sch_flex_id, reply->slots[scnt].type_flex_rule_display = sfs1.mnemonic,
   reply->slots[scnt].type_priority_cd = s1.priority_cd, reply->slots[scnt].type_priority_display =
   cv1.display, reply->slots[scnt].type_disp_scheme_id = s1.disp_scheme_id,
   reply->slots[scnt].type_disp_scheme_display = sds1.mnemonic, reply->slots[scnt].
   type_disp_scheme_border_size = sds1.border_size, reply->slots[scnt].type_disp_scheme_border_color
    = sds1.border_color,
   reply->slots[scnt].type_disp_scheme_border_style = sds1.border_style, reply->slots[scnt].
   type_disp_scheme_shape = sds1.shape, reply->slots[scnt].type_disp_scheme_pen_shape = sds1
   .pen_shape,
   lcnt = 0
  DETAIL
   IF (b2.br_sch_temp_slot_release_r_id > 0)
    lcnt = (lcnt+ 1), stat = alterlist(reply->slots[scnt].releases,lcnt), reply->slots[scnt].
    releases[lcnt].name = b2.release_name,
    reply->slots[scnt].releases[lcnt].start_time = b2.release_start_time_str, reply->slots[scnt].
    releases[lcnt].end_time = b2.release_end_time_str, reply->slots[scnt].releases[lcnt].type_id = s2
    .slot_type_id,
    reply->slots[scnt].releases[lcnt].unit = b2.release_unit, reply->slots[scnt].releases[lcnt].
    unit_code_value = cv3.code_value, reply->slots[scnt].releases[lcnt].unit_display = cv3.display,
    reply->slots[scnt].releases[lcnt].unit_value = b2.release_unit_value_str, reply->slots[scnt].
    releases[lcnt].type_name = s2.mnemonic, reply->slots[scnt].releases[lcnt].type_description = s2
    .description,
    reply->slots[scnt].releases[lcnt].type_interval = s2.interval, reply->slots[scnt].releases[lcnt].
    type_duration = s2.def_duration, reply->slots[scnt].releases[lcnt].type_contiguous_ind = s2
    .contiguous_ind,
    reply->slots[scnt].releases[lcnt].type_flex_rule_id = s2.sch_flex_id, reply->slots[scnt].
    releases[lcnt].type_flex_rule_display = sfs2.mnemonic, reply->slots[scnt].releases[lcnt].
    type_priority_cd = s2.priority_cd,
    reply->slots[scnt].releases[lcnt].type_priority_display = cv2.display, reply->slots[scnt].
    releases[lcnt].type_disp_scheme_id = s2.disp_scheme_id, reply->slots[scnt].releases[lcnt].
    type_disp_scheme_display = sds2.mnemonic,
    reply->slots[scnt].releases[lcnt].type_disp_scheme_border_size = sds2.border_size, reply->slots[
    scnt].releases[lcnt].type_disp_scheme_border_color = sds2.border_color, reply->slots[scnt].
    releases[lcnt].type_disp_scheme_border_style = sds2.border_style,
    reply->slots[scnt].releases[lcnt].type_disp_scheme_shape = sds2.shape, reply->slots[scnt].
    releases[lcnt].type_disp_scheme_pen_shape = sds2.pen_shape
   ENDIF
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
