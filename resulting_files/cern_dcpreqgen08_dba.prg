CREATE PROGRAM cern_dcpreqgen08:dba
 RECORD request(
   1 person_id = f8
   1 print_prsnl_id = f8
   1 order_qual[*]
     2 order_id = f8
     2 encntr_id = f8
     2 conversation_id = f8
   1 printer_name = c50
 )
 RECORD orders(
   1 name = vc
   1 pat_type = vc
   1 age = vc
   1 dob = vc
   1 mrn = vc
   1 location = vc
   1 facility = vc
   1 nurse_unit = vc
   1 room = vc
   1 bed = vc
   1 sex = vc
   1 fnbr = vc
   1 med_service = vc
   1 admit_diagnosis = vc
   1 height = vc
   1 height_dt_tm = vc
   1 weight = vc
   1 weight_dt_tm = vc
   1 admit_dt = vc
   1 dischg_dt = vc
   1 los = i4
   1 attending = vc
   1 admitting = vc
   1 order_location = vc
   1 spoolout_ind = i2
   1 cnt = i2
   1 qual[*]
     2 order_id = f8
     2 display_ind = i2
     2 template_order_flag = i2
     2 cs_flag = i2
     2 iv_ind = i2
     2 mnemonic = vc
     2 mnem_ln_cnt = i2
     2 mnem_ln_qual[*]
       3 mnem_line = vc
     2 display_line = vc
     2 disp_ln_cnt = i2
     2 disp_ln_qual[*]
       3 disp_line = vc
     2 order_dt = vc
     2 signed_dt = vc
     2 status = vc
     2 accession = vc
     2 catalog = vc
     2 catalog_type_cd = f8
     2 activity = vc
     2 activity_type_cd = f8
     2 last_action_seq = i4
     2 enter_by = vc
     2 order_dr = vc
     2 type = vc
     2 action = vc
     2 action_type_cd = f8
     2 comment_ind = i2
     2 comment = vc
     2 com_ln_cnt = i2
     2 com_ln_qual[*]
       3 com_line = vc
     2 oe_format_id = f8
     2 clin_line_ind = i2
     2 stat_ind = i2
     2 d_cnt = i2
     2 d_qual[*]
       3 field_description = vc
       3 label_text = vc
       3 value = vc
       3 field_value = f8
       3 oe_field_meaning_id = f8
       3 group_seq = i4
       3 print_ind = i2
       3 clin_line_ind = i2
       3 label = vc
       3 suffix = i2
     2 priority = vc
     2 req_st_dt = vc
     2 frequency = vc
     2 rate = vc
     2 duration = vc
     2 duration_unit = vc
     2 nurse_collect = vc
 )
 RECORD allergy(
   1 cnt = i2
   1 qual[*]
     2 list = vc
   1 line = vc
   1 line_cnt = i2
   1 line_qual[*]
     2 line = vc
 )
 RECORD diagnosis(
   1 cnt = i2
   1 qual[*]
     2 diag = vc
   1 dline = vc
   1 dline_cnt = i2
   1 dline_qual[*]
     2 dline = vc
 )
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 SET order_cnt = 0
 SET order_cnt = size(request->order_qual,5)
 SET stat = alterlist(orders->qual,order_cnt)
 SET person_id = 0
 SET encntr_id = 0
 SET orders->spoolout_ind = 0
 SET pharm_flag = 0
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 4
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_cd = code_value
 SET code_set = 14
 SET cdf_meaning = "ORD COMMENT"
 EXECUTE cpm_get_cd_for_cdf
 SET comment_cd = code_value
 SET code_set = 319
 SET cdf_meaning = "FIN NBR"
 EXECUTE cpm_get_cd_for_cdf
 SET fnbr_cd = code_value
 SET code_set = 333
 SET cdf_meaning = "ADMITDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET admit_doc_cd = code_value
 SET code_set = 333
 SET cdf_meaning = "ATTENDDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET attend_doc_cd = code_value
 SET code_set = 12025
 SET cdf_meaning = "CANCELED"
 EXECUTE cpm_get_cd_for_cdf
 SET canceled_cd = code_value
 SET code_set = 8
 SET cdf_meaning = "INERROR"
 EXECUTE cpm_get_cd_for_cdf
 SET inerror_cd = code_value
 SET code_set = 6000
 SET cdf_meaning = "PHARMACY"
 EXECUTE cpm_get_cd_for_cdf
 SET pharmacy_cd = code_value
 SET code_set = 16389
 SET cdf_meaning = "IVSOLUTIONS"
 EXECUTE cpm_get_cd_for_cdf
 SET iv_cd = code_value
 SET code_set = 6003
 SET cdf_meaning = "COMPLETE"
 EXECUTE cpm_get_cd_for_cdf
 SET complete_cd = code_value
 SET code_set = 6003
 SET cdf_meaning = "MODIFY"
 EXECUTE cpm_get_cd_for_cdf
 SET modify_cd = code_value
 SET code_set = 6003
 SET cdf_meaning = "ORDER"
 EXECUTE cpm_get_cd_for_cdf
 SET order_cd = code_value
 SET code_set = 6003
 SET cdf_meaning = "CANCEL"
 EXECUTE cpm_get_cd_for_cdf
 SET cancel_cd = code_value
 SET code_set = 6003
 SET cdf_meaning = "DISCONTINUE"
 EXECUTE cpm_get_cd_for_cdf
 SET discont_cd = code_value
 DECLARE offset = i2 WITH protect, noconstant(0)
 DECLARE daylight = i2 WITH protect, noconstant(0)
 DECLARE tz_index = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM person p,
   encounter e,
   person_alias pa,
   encntr_alias ea,
   encntr_prsnl_reltn epr,
   prsnl pl,
   (dummyt d1  WITH seq = 1),
   (dummyt d2  WITH seq = 1),
   (dummyt d3  WITH seq = 1),
   encntr_loc_hist elh,
   time_zone_r t
  PLAN (p
   WHERE (p.person_id=request->person_id))
   JOIN (e
   WHERE (e.encntr_id=request->order_qual[1].encntr_id))
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id)
   JOIN (t
   WHERE t.parent_entity_id=outerjoin(elh.loc_facility_cd)
    AND t.parent_entity_name=outerjoin("LOCATION"))
   JOIN (d1)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=mrn_alias_cd
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (d2)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=fnbr_cd
    AND ea.active_ind=1)
   JOIN (d3)
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND ((epr.encntr_prsnl_r_cd=admit_doc_cd) OR (epr.encntr_prsnl_r_cd=attend_doc_cd))
    AND epr.active_ind=1)
   JOIN (pl
   WHERE pl.person_id=epr.prsnl_person_id)
  HEAD REPORT
   person_id = p.person_id, encntr_id = e.encntr_id, orders->name = p.name_full_formatted,
   orders->pat_type = trim(uar_get_code_display(e.encntr_type_cd)), orders->sex =
   uar_get_code_display(p.sex_cd), orders->age = cnvtage(cnvtdate(p.birth_dt_tm),curdate),
   tz_index = datetimezonebyname(trim(t.time_zone)), orders->dob = concat(format(datetimezone(p
      .birth_dt_tm,p.birth_tz),"mm/dd/yyyy;;Q")," ",datetimezonebyindex(p.birth_tz,offset,daylight,7,
     p.birth_dt_tm)), orders->admit_dt = concat(format(datetimezone(e.reg_dt_tm,tz_index),
     "mm/dd/yyyy;;Q")," ",datetimezonebyindex(tz_index,offset,daylight,7,e.reg_dt_tm)),
   orders->dischg_dt = concat(format(datetimezone(e.disch_dt_tm,tz_index),"mm/dd/yyyy;;d")," ",
    datetimezonebyindex(tz_index,offset,daylight,7,e.disch_dt_tm))
   IF (((e.disch_dt_tm=null) OR (e.disch_dt_tm=0)) )
    orders->los = (datetimecmp(cnvtdatetime(curdate,curtime3),e.reg_dt_tm)+ 1)
   ELSE
    orders->los = (datetimecmp(e.disch_dt_tm,e.reg_dt_tm)+ 1)
   ENDIF
   orders->facility = uar_get_code_description(e.loc_facility_cd), orders->nurse_unit =
   uar_get_code_display(e.loc_nurse_unit_cd), orders->room = uar_get_code_display(e.loc_room_cd),
   orders->bed = uar_get_code_display(e.loc_bed_cd), orders->location = concat(trim(orders->
     nurse_unit),"/",trim(orders->room),"/",trim(orders->bed)), orders->admit_diagnosis = e
   .reason_for_visit,
   orders->med_service = uar_get_code_display(e.med_service_cd)
  HEAD epr.encntr_prsnl_r_cd
   IF (epr.encntr_prsnl_r_cd=admit_doc_cd)
    orders->admitting = pl.name_full_formatted
   ELSEIF (epr.encntr_prsnl_r_cd=attend_doc_cd)
    orders->attending = pl.name_full_formatted
   ENDIF
  DETAIL
   IF (pa.person_alias_type_cd=mrn_alias_cd)
    IF (pa.alias_pool_cd > 0)
     orders->mrn = cnvtalias(pa.alias,pa.alias_pool_cd)
    ELSE
     orders->mrn = pa.alias
    ENDIF
   ENDIF
   IF (ea.encntr_alias_type_cd=fnbr_cd)
    IF (ea.alias_pool_cd > 0)
     orders->fnbr = cnvtalias(ea.alias,ea.alias_pool_cd)
    ELSE
     orders->fnbr = ea.alias
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d1, dontcare = pa,
   outerjoin = d2, dontcare = ea, outerjoin = d3,
   dontcare = epr
 ;end select
 SET height_cd = 0
 SET weight_cd = 0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=72
    AND cv.display_key IN ("KHHEIGHTCM", "KHWEIGHTKG")
    AND cv.active_ind=1)
  DETAIL
   CASE (cv.display_key)
    OF "KHHEIGHTCM":
     height_cd = cv.code_value
    OF "KHWEIGHTKG":
     weight_cd = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event c
  PLAN (c
   WHERE c.person_id=person_id
    AND c.encntr_id=encntr_id
    AND c.event_cd IN (height_cd, weight_cd)
    AND c.view_level=1
    AND c.publish_flag=1
    AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
    AND c.result_status_cd != inerror_cd)
  ORDER BY c.event_end_dt_tm
  DETAIL
   IF (c.event_cd=height_cd)
    orders->height = concat(trim(c.event_tag)," ",trim(uar_get_code_display(c.result_units_cd))),
    orders->height_dt_tm = concat(format(datetimezone(c.updt_dt_tm,c.performed_tz),
      "mm/dd/yyyy  hh:mm;;d")," ",datetimezonebyindex(c.performed_tz,offset,daylight,7,c.updt_dt_tm))
   ELSEIF (c.event_cd=weight_cd)
    orders->weight = concat(trim(c.event_tag)," ",trim(uar_get_code_display(c.result_units_cd))),
    orders->weight_dt_tm = concat(format(datetimezone(c.updt_dt_tm,c.performed_tz),
      "mm/dd/yyyy  hh:mm;;d")," ",datetimezonebyindex(c.performed_tz,offset,daylight,7,c.updt_dt_tm))
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM allergy a,
   (dummyt d  WITH seq = 1),
   nomenclature n
  PLAN (a
   WHERE (a.person_id=request->person_id)
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (a.end_effective_dt_tm=null))
    AND a.reaction_status_cd != canceled_cd)
   JOIN (d)
   JOIN (n
   WHERE n.nomenclature_id=a.substance_nom_id)
  ORDER BY cnvtdatetime(a.onset_dt_tm)
  HEAD REPORT
   allergy->cnt = 0
  DETAIL
   IF (((n.source_string > " ") OR (a.substance_ftdesc > " ")) )
    allergy->cnt = (allergy->cnt+ 1), stat = alterlist(allergy->qual,allergy->cnt), allergy->qual[
    allergy->cnt].list = a.substance_ftdesc
    IF (n.source_string > " ")
     allergy->qual[allergy->cnt].list = n.source_string
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d, dontcare = n
 ;end select
 FOR (x = 1 TO allergy->cnt)
   IF (x=1)
    SET allergy->line = allergy->qual[x].list
   ELSE
    SET allergy->line = concat(trim(allergy->line),", ",trim(allergy->qual[x].list))
   ENDIF
 ENDFOR
 IF ((allergy->cnt > 0))
  SET pt->line_cnt = 0
  SET max_length = 90
  EXECUTE dcp_parse_text value(allergy->line), value(max_length)
  SET stat = alterlist(allergy->line_qual,pt->line_cnt)
  SET allergy->line_cnt = pt->line_cnt
  FOR (x = 1 TO pt->line_cnt)
    SET allergy->line_qual[x].line = pt->lns[x].line
  ENDFOR
 ENDIF
 SET mnem_disp_level = "1"
 SET iv_disp_level = "0"
 IF (pharm_flag=1)
  SELECT INTO "nl:"
   FROM name_value_prefs n,
    app_prefs a
   PLAN (n
    WHERE n.pvc_name IN ("MNEM_DISP_LEVEL", "IV_DISP_LEVEL"))
    JOIN (a
    WHERE a.app_prefs_id=n.parent_entity_id
     AND a.prsnl_id=0
     AND a.position_cd=0)
   DETAIL
    IF (n.pvc_name="MNEM_DISP_LEVEL"
     AND n.pvc_value IN ("0", "1", "2"))
     mnem_disp_level = n.pvc_value
    ELSEIF (n.pvc_name="IV_DISP_LEVEL"
     AND n.pvc_value IN ("0", "1"))
     iv_disp_level = n.pvc_value
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET ord_cnt = 0
 SELECT INTO "nl:"
  FROM orders o,
   order_action oa,
   prsnl pl,
   prsnl pl2,
   (dummyt d1  WITH seq = value(order_cnt))
  PLAN (d1)
   JOIN (o
   WHERE (o.order_id=request->order_qual[d1.seq].order_id))
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_sequence=o.last_action_sequence)
   JOIN (pl
   WHERE pl.person_id=oa.action_personnel_id)
   JOIN (pl2
   WHERE pl2.person_id=oa.order_provider_id)
  ORDER BY o.oe_format_id, o.activity_type_cd, o.current_start_dt_tm
  HEAD REPORT
   orders->order_location = trim(uar_get_code_display(oa.order_locn_cd))
  HEAD o.order_id
   ord_cnt = (ord_cnt+ 1), orders->qual[ord_cnt].status = uar_get_code_display(o.order_status_cd),
   orders->qual[ord_cnt].catalog = uar_get_code_display(o.catalog_type_cd),
   orders->qual[ord_cnt].catalog_type_cd = o.catalog_type_cd, orders->qual[ord_cnt].activity =
   uar_get_code_display(o.activity_type_cd), orders->qual[ord_cnt].activity_type_cd = o
   .activity_type_cd,
   orders->qual[ord_cnt].display_line = o.clinical_display_line, orders->qual[ord_cnt].order_id = o
   .order_id, orders->qual[ord_cnt].display_ind = 1,
   orders->qual[ord_cnt].template_order_flag = o.template_order_flag, orders->qual[ord_cnt].cs_flag
    = o.cs_flag, orders->qual[ord_cnt].oe_format_id = o.oe_format_id
   IF (substring(245,10,o.clinical_display_line) > "  ")
    orders->qual[ord_cnt].clin_line_ind = 1
   ELSE
    orders->qual[ord_cnt].clin_line_ind = 0
   ENDIF
   orders->qual[ord_cnt].mnemonic = o.hna_order_mnemonic, orders->qual[ord_cnt].order_dt = concat(
    format(datetimezone(oa.order_dt_tm,oa.order_tz),"mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(oa
     .order_tz,offset,daylight,7,oa.order_dt_tm)), orders->qual[ord_cnt].signed_dt = concat(format(
     datetimezone(o.orig_order_dt_tm,o.orig_order_tz),"mm/dd/yy hh:mm;;d")," ",datetimezonebyindex(o
     .orig_order_tz,offset,daylight,7,o.orig_order_dt_tm)),
   orders->qual[ord_cnt].comment_ind = o.order_comment_ind, orders->qual[ord_cnt].last_action_seq = o
   .last_action_sequence, orders->qual[ord_cnt].enter_by = pl.name_full_formatted,
   orders->qual[ord_cnt].order_dr = pl2.name_full_formatted, orders->qual[ord_cnt].type =
   uar_get_code_display(oa.communication_type_cd), orders->qual[ord_cnt].action_type_cd = oa
   .action_type_cd,
   orders->qual[ord_cnt].action = uar_get_code_display(oa.action_type_cd), orders->qual[ord_cnt].
   iv_ind = o.iv_ind
   IF (o.dcp_clin_cat_cd=iv_cd)
    orders->qual[ord_cnt].iv_ind = 1
   ENDIF
   IF (o.catalog_type_cd=pharmacy_cd)
    IF (mnem_disp_level="0")
     orders->qual[ord_cnt].mnemonic = trim(o.hna_order_mnemonic)
    ENDIF
    IF (mnem_disp_level="1")
     IF (((o.hna_order_mnemonic=o.ordered_as_mnemonic) OR (o.ordered_as_mnemonic=" ")) )
      orders->qual[ord_cnt].mnemonic = trim(o.hna_order_mnemonic)
     ELSE
      orders->qual[ord_cnt].mnemonic = concat(trim(o.hna_order_mnemonic),"(",trim(o
        .ordered_as_mnemonic),")")
     ENDIF
    ENDIF
    IF (mnem_disp_level="2"
     AND o.iv_ind != 1)
     IF (((o.hna_order_mnemonic=o.ordered_as_mnemonic) OR (o.ordered_as_mnemonic=" ")) )
      orders->qual[ord_cnt].mnemonic = trim(o.hna_order_mnemonic)
     ELSE
      orders->qual[ord_cnt].mnemonic = concat(trim(o.hna_order_mnemonic),"(",trim(o
        .ordered_as_mnemonic),")")
     ENDIF
     IF (o.order_mnemonic != o.ordered_as_mnemonic
      AND o.order_mnemonic > " ")
      orders->qual[ord_cnt].mnemonic = concat(trim(orders->qual[ord_cnt].mnemonic),"(",trim(o
        .order_mnemonic),")")
     ENDIF
    ENDIF
   ENDIF
   IF (oa.action_type_cd IN (order_cd, modify_cd, cancel_cd, discont_cd))
    orders->qual[ord_cnt].display_ind = 1, orders->spoolout_ind = 1
   ELSE
    orders->qual[ord_cnt].display_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_detail od,
   oe_format_fields oef,
   order_entry_fields of1,
   (dummyt d1  WITH seq = value(order_cnt))
  PLAN (d1)
   JOIN (od
   WHERE (orders->qual[d1.seq].order_id=od.order_id))
   JOIN (oef
   WHERE (oef.oe_format_id=orders->qual[d1.seq].oe_format_id)
    AND (oef.action_type_cd=orders->qual[d1.seq].action_type_cd)
    AND oef.oe_field_id=od.oe_field_id)
   JOIN (of1
   WHERE of1.oe_field_id=oef.oe_field_id)
  ORDER BY od.order_id, od.oe_field_id, od.action_sequence DESC
  HEAD REPORT
   orders->qual[d1.seq].d_cnt = 0
  HEAD od.order_id
   stat = alterlist(orders->qual[d1.seq].d_qual,5), orders->qual[d1.seq].stat_ind = 0
  HEAD od.oe_field_id
   act_seq = od.action_sequence, odflag = 1
   IF (((od.oe_field_meaning="COLLPRI") OR (od.oe_field_meaning="PRIORITY")) )
    orders->qual[d1.seq].priority = od.oe_field_display_value
   ENDIF
   IF (od.oe_field_meaning="REQSTARTDTTM")
    orders->qual[d1.seq].req_st_dt = od.oe_field_display_value
   ENDIF
   IF (od.oe_field_meaning="FREQ")
    orders->qual[d1.seq].frequency = od.oe_field_display_value
   ENDIF
   IF (od.oe_field_meaning="RATE")
    orders->qual[d1.seq].rate = od.oe_field_display_value
   ENDIF
   IF (od.oe_field_meaning="DURATION")
    orders->qual[d1.seq].duration = od.oe_field_display_value
   ENDIF
   IF (od.oe_field_meaning="DURATIONUNIT")
    orders->qual[d1.seq].duration_unit = od.oe_field_display_value
   ENDIF
   IF (od.oe_field_meaning="NURSECOLLECT")
    orders->qual[d1.seq].nurse_collect = od.oe_field_display_value
   ENDIF
  HEAD od.action_sequence
   IF (act_seq != od.action_sequence)
    odflag = 0
   ENDIF
  DETAIL
   IF (odflag=1)
    orders->qual[d1.seq].d_cnt = (orders->qual[d1.seq].d_cnt+ 1), dc = orders->qual[d1.seq].d_cnt
    IF (dc > size(orders->qual[d1.seq].d_qual,5))
     stat = alterlist(orders->qual[d1.seq].d_qual,(dc+ 5))
    ENDIF
    orders->qual[d1.seq].d_qual[dc].label_text = trim(oef.label_text), orders->qual[d1.seq].d_qual[dc
    ].field_value = od.oe_field_value, orders->qual[d1.seq].d_qual[dc].group_seq = oef.group_seq,
    orders->qual[d1.seq].d_qual[dc].oe_field_meaning_id = od.oe_field_meaning_id, orders->qual[d1.seq
    ].d_qual[dc].value = trim(od.oe_field_display_value), orders->qual[d1.seq].d_qual[dc].
    clin_line_ind = oef.clin_line_ind,
    orders->qual[d1.seq].d_qual[dc].label = trim(oef.clin_line_label), orders->qual[d1.seq].d_qual[dc
    ].suffix = oef.clin_suffix_ind
    IF (od.oe_field_display_value > " ")
     orders->qual[d1.seq].d_qual[dc].print_ind = 0
    ELSE
     orders->qual[d1.seq].d_qual[dc].print_ind = 1
    ENDIF
    IF (((od.oe_field_meaning_id=1100) OR (((od.oe_field_meaning_id=8) OR (((od.oe_field_meaning_id=
    127) OR (od.oe_field_meaning_id=43)) )) ))
     AND trim(cnvtupper(od.oe_field_display_value))="STAT")
     orders->qual[d1.seq].stat_ind = 1
    ENDIF
    IF (of1.field_type_flag=7)
     IF (od.oe_field_value=1)
      IF (((oef.disp_yes_no_flag=0) OR (oef.disp_yes_no_flag=1)) )
       orders->qual[d1.seq].d_qual[dc].value = trim(oef.label_text)
      ELSE
       orders->qual[d1.seq].d_qual[dc].clin_line_ind = 0
      ENDIF
     ELSE
      IF (((oef.disp_yes_no_flag=0) OR (oef.disp_yes_no_flag=2)) )
       orders->qual[d1.seq].d_qual[dc].value = trim(oef.clin_line_label)
      ELSE
       orders->qual[d1.seq].d_qual[dc].clin_line_ind = 0
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  FOOT  od.order_id
   stat = alterlist(orders->qual[d1.seq].d_qual,dc)
  WITH nocounter
 ;end select
 FOR (x = 1 TO order_cnt)
   IF ((orders->qual[x].clin_line_ind=1))
    SET started_build_ind = 0
    FOR (fsub = 1 TO 31)
      FOR (xx = 1 TO orders->qual[x].d_cnt)
        IF ((((orders->qual[x].d_qual[xx].group_seq=fsub)) OR (fsub=31))
         AND (orders->qual[x].d_qual[xx].print_ind=0))
         SET orders->qual[x].d_qual[xx].print_ind = 1
         IF ((orders->qual[x].d_qual[xx].clin_line_ind=1))
          IF (started_build_ind=0)
           SET started_build_ind = 1
           IF ((orders->qual[x].d_qual[xx].suffix=0)
            AND (orders->qual[x].d_qual[xx].label > "  "))
            SET orders->qual[x].display_line = concat(trim(orders->qual[x].d_qual[xx].label)," ",trim
             (orders->qual[x].d_qual[xx].value))
           ELSEIF ((orders->qual[x].d_qual[xx].suffix=1)
            AND (orders->qual[x].d_qual[xx].label > " "))
            SET orders->qual[x].display_line = concat(trim(orders->qual[x].d_qual[xx].value)," ",trim
             (orders->qual[x].d_qual[xx].label))
           ELSE
            SET orders->qual[x].display_line = concat(trim(orders->qual[x].d_qual[xx].value)," ")
           ENDIF
          ELSE
           IF ((orders->qual[x].d_qual[xx].suffix=0)
            AND (orders->qual[x].d_qual[xx].label > "  "))
            SET orders->qual[x].display_line = concat(trim(orders->qual[x].display_line),",",trim(
              orders->qual[x].d_qual[xx].label)," ",trim(orders->qual[x].d_qual[xx].value))
           ELSEIF ((orders->qual[x].d_qual[xx].suffix=1)
            AND (orders->qual[x].d_qual[xx].label > " "))
            SET orders->qual[x].display_line = concat(trim(orders->qual[x].display_line),",",trim(
              orders->qual[x].d_qual[xx].value)," ",trim(orders->qual[x].d_qual[xx].label))
           ELSE
            SET orders->qual[x].display_line = concat(trim(orders->qual[x].display_line),",",trim(
              orders->qual[x].d_qual[xx].value)," ")
           ENDIF
          ENDIF
         ENDIF
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
 ENDFOR
 FOR (x = 1 TO order_cnt)
   IF ((orders->qual[x].display_line > " "))
    SET pt->line_cnt = 0
    SET max_length = 90
    EXECUTE dcp_parse_text value(orders->qual[x].display_line), value(max_length)
    SET stat = alterlist(orders->qual[x].disp_ln_qual,pt->line_cnt)
    SET orders->qual[x].disp_ln_cnt = pt->line_cnt
    FOR (y = 1 TO pt->line_cnt)
      SET orders->qual[x].disp_ln_qual[y].disp_line = pt->lns[y].line
    ENDFOR
   ENDIF
 ENDFOR
 FOR (x = 1 TO order_cnt)
   SELECT INTO "nl:"
    FROM accession_order_r aor
    PLAN (aor
     WHERE (aor.order_id=orders->qual[x].order_id))
    DETAIL
     orders->qual[x].accession = aor.accession
    WITH nocounter
   ;end select
 ENDFOR
 FOR (x = 1 TO order_cnt)
   IF ((orders->qual[x].iv_ind=1))
    SELECT INTO "nl:"
     FROM order_ingredient oi
     PLAN (oi
      WHERE (oi.order_id=orders->qual[x].order_id))
     ORDER BY oi.action_sequence, oi.comp_sequence
     HEAD oi.action_sequence
      mnemonic_line = fillstring(1000," "), first_time = "Y"
     DETAIL
      IF (first_time="Y")
       IF (oi.ordered_as_mnemonic > " ")
        mnemonic_line = concat(trim(oi.ordered_as_mnemonic),", ",trim(oi.order_detail_display_line))
       ELSE
        mnemonic_line = concat(trim(oi.order_mnemonic),", ",trim(oi.order_detail_display_line))
       ENDIF
       first_time = "N"
      ELSE
       IF (oi.ordered_as_mnemonic > " ")
        mnemonic_line = concat(trim(mnemonic_line),", ",trim(oi.ordered_as_mnemonic),", ",trim(oi
          .order_detail_display_line))
       ELSE
        mnemonic_line = concat(trim(mnemonic_line),", ",trim(oi.order_mnemonic),", ",trim(oi
          .order_detail_display_line))
       ENDIF
      ENDIF
     FOOT REPORT
      orders->qual[x].mnemonic = mnemonic_line
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 FOR (x = 1 TO order_cnt)
   IF ((orders->qual[x].mnemonic > " "))
    SET pt->line_cnt = 0
    SET max_length = 90
    EXECUTE dcp_parse_text value(orders->qual[x].mnemonic), value(max_length)
    SET stat = alterlist(orders->qual[x].mnem_ln_qual,pt->line_cnt)
    SET orders->qual[x].mnem_ln_cnt = pt->line_cnt
    FOR (y = 1 TO pt->line_cnt)
      SET orders->qual[x].mnem_ln_qual[y].mnem_line = pt->lns[y].line
    ENDFOR
   ENDIF
 ENDFOR
 FOR (x = 1 TO order_cnt)
   IF ((orders->qual[x].comment_ind=1))
    SELECT INTO "nl:"
     FROM order_comment oc,
      long_text lt
     PLAN (oc
      WHERE (oc.order_id=orders->qual[x].order_id)
       AND oc.comment_type_cd=comment_cd)
      JOIN (lt
      WHERE lt.long_text_id=oc.long_text_id)
     DETAIL
      orders->qual[x].comment = lt.long_text
     WITH nocounter
    ;end select
    SET pt->line_cnt = 0
    SET max_length = 110
    EXECUTE dcp_parse_text value(orders->qual[x].comment), value(max_length)
    SET stat = alterlist(orders->qual[x].com_ln_qual,pt->line_cnt)
    SET orders->qual[x].com_ln_cnt = pt->line_cnt
    FOR (y = 1 TO pt->line_cnt)
      SET orders->qual[x].com_ln_qual[y].com_line = pt->lns[y].line
    ENDFOR
   ENDIF
 ENDFOR
 IF ((orders->spoolout_ind=1))
  SET new_timedisp = cnvtstring(curtime3)
  SET tempfile1a = build(concat("cer_temp:dcpreq","_",new_timedisp),".dat")
  SELECT INTO value(tempfile1a)
   d1.seq
   FROM (dummyt d1  WITH seq = 1)
   PLAN (d1)
   HEAD REPORT
    first_page = "Y"
   DETAIL
    FOR (vv = 1 TO value(order_cnt))
      IF ((orders->qual[vv].display_ind=1))
       spoolout = 1
       IF (first_page="N")
        BREAK
       ENDIF
       first_page = "N", "{cpi/14}{f/12}", row + 1,
       "{pos/50/60}{box/98/5}", row + 1, "{pos/50/135}{box/98/18}",
       row + 1, "{pos/50/345}{box/98/21}", row + 1,
       "{pos/50/590}{box/98/6}", row + 1, "{pos/50/680}{box/98/2}",
       row + 1, "{cpi/11}{f/12}", row + 1,
       "{pos/255/70}{b}Hospital Name", row + 1, "{pos/235/85}Division/Address",
       row + 1, "{pos/255/100}Service Requisition", row + 1,
       "{pos/225/115}{f/6}Department: ", "{f/4}", orders->qual[vv].catalog,
       ", ", orders->qual[vv].activity, row + 1,
       "{pos/60/148}{f/6}Patient Name:  ", "{f/4}", "{b}",
       orders->name, "{endb}", row + 1,
       "{pos/60/160}{f/6}Care Unit: ", "{f/4}", orders->nurse_unit,
       row + 1, "{pos/330/160}{f/6}DOB: ", "{f/4}",
       orders->dob, "{pos/330/172}{f/6}Age: ", "{f/4}",
       orders->age, "{pos/430/172}{f/6}Sex: ", "{f/4}",
       orders->sex, row + 1, "{pos/60/172}{f/6}Room/Bed: ",
       "{f/4}", orders->room, " / ",
       orders->bed, "{pos/330/184}{f/6}Ht: ", "{f/4}",
       orders->height, "{pos/430/184}{f/6}Wt: ", "{f/4}",
       orders->weight, row + 1, "{pos/60/184}{f/6}MRN #: ",
       "{f/4}", "{b}", orders->mrn,
       "{endb}", "{pos/330/196}{f/6}FIN #: ", "{f/4}",
       "{b}", orders->fnbr, "{endb}",
       row + 1, "{pos/60/196}{f/6}{b}Allergies: {endb}", "{f/4}",
       row + 1, ycol = 196, msg_ind = 0
       IF ((allergy->cnt > 0))
        aup = allergy->cnt
        IF ((allergy->cnt > 6))
         aup = 6, msg_ind = 1
        ENDIF
        xcol = 125
        FOR (asub = 1 TO aup)
          CALL print(calcpos(xcol,ycol)), allergy->qual[asub].list, ycol = (ycol+ 12),
          row + 1
        ENDFOR
        IF (msg_ind=1)
         CALL print(calcpos(xcol,ycol)), "***See Patient Record for More Allergies***", msg_ind = 0,
         ycol = (ycol+ 12), row + 1
        ENDIF
       ENDIF
       "{pos/60/280}{f/6}Admit Date: ", "{f/4}", orders->admit_dt,
       row + 1, "{pos/60/292}{f/6}Service: ", "{f/4}",
       orders->med_service, row + 1, "{pos/60/304}{f/6}Attending MD: ",
       "{f/4}", orders->attending, row + 1,
       "{pos/280/280}{f/6}Admit Diagnosis: ", "{f/4}", orders->admit_diagnosis,
       row + 1, "{pos/295/304}{f/6}Ordering MD: ", "{f/4}",
       orders->qual[vv].order_dr, row + 1, "{pos/60/360}{f/6}Ordered Procedure: ",
       "{f/4}", "{B}", orders->qual[vv].mnemonic,
       "{ENDB}", "{pos/410/360}{f/6}Order ID #: ", "{f/4}",
       orders->qual[vv].order_id"#######", row + 1, ycol = 360
       IF ((orders->qual[vv].action != "Order"))
        ycol = (ycol+ 12), xcol = 200,
        CALL print(calcpos(xcol,ycol)),
        "*****", orders->qual[vv].action, "*****",
        row + 1
       ENDIF
       xcol = 60, ycol = (ycol+ 12)
       FOR (fsub = 1 TO 31)
         FOR (x = 1 TO orders->qual[vv].d_cnt)
           IF ((((orders->qual[vv].d_qual[x].group_seq=fsub)) OR (fsub=31))
            AND (orders->qual[vv].d_qual[x].print_ind=0))
            orders->qual[vv].d_qual[x].print_ind = 1, ww = substring(81,90,orders->qual[vv].d_qual[x]
             .value)
            IF (ww > " ")
             str_a = substring(1,80,orders->qual[vv].d_qual[x].value), str_b = substring(81,90,orders
              ->qual[vv].d_qual[x].value), str_c = substring(171,85,orders->qual[vv].d_qual[x].value),
             CALL print(calcpos(xcol,ycol)), "{f/6}", orders->qual[vv].d_qual[x].label_text,
             "{f/4} :  ", str_a, row + 1
             IF (str_b > " ")
              ycol = (ycol+ 12), xcol = 75,
              CALL print(calcpos(xcol,ycol)),
              str_b, row + 1
              IF (str_c > " ")
               ycol = (ycol+ 12), xcol = 75,
               CALL print(calcpos(xcol,ycol)),
               str_c, row + 1
              ENDIF
             ENDIF
            ELSE
             CALL print(calcpos(xcol,ycol)), "{f/6}", orders->qual[vv].d_qual[x].label_text,
             "{f/4} :  ", orders->qual[vv].d_qual[x].value, row + 1
            ENDIF
            ycol = (ycol+ 12), row + 1, xcol = 60
           ENDIF
         ENDFOR
       ENDFOR
       IF (xcol=330)
        row + 1, ycol = (ycol+ 15)
       ENDIF
       row + 1, xcol = 60, ycol = (ycol+ 12),
       CALL print(calcpos(xcol,ycol)), "Order Comments: ", row + 1,
       ycol = (ycol+ 12)
       IF ((orders->qual[vv].comment_ind=1)
        AND (orders->qual[vv].com_ln_cnt > 0))
        IF ((orders->qual[vv].com_ln_cnt > 6))
         ocnt = 6, msg_ind = 1
        ELSE
         ocnt = orders->qual[vv].com_ln_cnt
        ENDIF
        FOR (com_cnt = 1 TO ocnt)
          xcol = 75,
          CALL print(calcpos(xcol,ycol)), orders->qual[vv].com_ln_qual[com_cnt].com_line,
          row + 1, ycol = (ycol+ 12)
        ENDFOR
        IF (msg_ind=1)
         CALL print(calcpos(xcol,ycol)), "***See Order Record for More Comments***", msg_ind = 0,
         ycol = (ycol+ 12), row + 1
        ENDIF
       ENDIF
       xcol = 60, ycol = 600,
       CALL print(calcpos(xcol,ycol)),
       "{f/6}{b}Notes: {endb}{f/4}", row + 1, "{pos/60/695}{f/6}Entered By: ",
       "{f/4}", orders->qual[vv].enter_by, row + 1,
       "{pos/350/695}{f/6}Date/Time: ", "{f/4}", orders->qual[vv].signed_dt
      ENDIF
    ENDFOR
    "{font/8}{cpi/12}{pos/50/720}", "dcpreqgen08"
   WITH nocounter, maxrow = 800, maxcol = 750,
    dio = postscript
  ;end select
  SET spool value(trim(tempfile1a)) value(trim(request->printer_name)) WITH deleted
 ENDIF
#exit_script
END GO
