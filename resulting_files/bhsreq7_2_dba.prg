CREATE PROGRAM bhsreq7_2:dba
 IF (validate(request)=0)
  RECORD request(
    1 person_id = f8
    1 print_prsnl_id = f8
    1 order_qual[*]
      2 order_id = f8
      2 encntr_id = f8
      2 conversation_id = f8
    1 printer_name = c50
  )
 ENDIF
 RECORD orders(
   1 name = vc
   1 pat_type = vc
   1 age = vc
   1 dob = vc
   1 ms_address_lone = vc
   1 ms_address_ltwo = vc
   1 ms_city = vc
   1 ms_state = vc
   1 ms_zip = vc
   1 mrn = vc
   1 s_cmrn = vc
   1 location = vc
   1 facility = vc
   1 nurse_unit = vc
   1 room = vc
   1 bed = vc
   1 sex = vc
   1 fnbr = vc
   1 fmrn = vc
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
     2 collectedyn = vc
     2 fut_facilty = vc
     2 fut_unit = vc
     2 fut_facilty_cd = f8
     2 fut_unit_cd = f8
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
 DECLARE mf_cmrn_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4,"CORPORATEMEDICALRECORDNUMBER")
  ), protect
 SET code_set = 14
 SET cdf_meaning = "ORD COMMENT"
 EXECUTE cpm_get_cd_for_cdf
 SET comment_cd = code_value
 SET code_set = 319
 SET cdf_meaning = "FIN NBR"
 EXECUTE cpm_get_cd_for_cdf
 SET fnbr_cd = code_value
 SET code_set = 319
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET fmrn_cd = code_value
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
 DECLARE tempstring = vc WITH public, noconstant
 DECLARE undo_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6003,"UNDO"))
 DECLARE transfercancel_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6003,
   "TRANSFERCANCEL"))
 DECLARE suspend_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6003,"SUSPEND"))
 DECLARE activatestudentorder_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6003,
   "ACTIVATESTUDENTORDER"))
 DECLARE statuschange_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6003,"STATUSCHANGE")
  )
 DECLARE review_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6003,"REVIEW"))
 DECLARE resumerenew_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6003,"RESUMERENEW"))
 DECLARE resume_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6003,"RESUME"))
 DECLARE restore_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6003,"RESTORE"))
 DECLARE reschedule_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6003,"RESCHEDULE"))
 DECLARE renew_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6003,"RENEW"))
 DECLARE order_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6003,"ORDER"))
 DECLARE modify_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6003,"MODIFY"))
 DECLARE historyorder_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6003,"HISTORYORDER")
  )
 DECLARE futurediscontinue_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6003,
   "FUTUREDISCONTINUE"))
 DECLARE dischargeorder_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6003,
   "DISCHARGEORDER"))
 DECLARE discont_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6003,"DISCONTINUE"))
 DECLARE demogchange_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6003,"DEMOGCHANGE"))
 DECLARE void_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6003,"VOID"))
 DECLARE complete_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6003,"COMPLETE"))
 DECLARE collection_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6003,"COLLECTION"))
 DECLARE clearfutureactions_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6003,
   "CLEARFUTUREACTIONS"))
 DECLARE cancelreorder_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6003,
   "CANCELREORDER"))
 DECLARE canceldc_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6003,"CANCELDC"))
 DECLARE cancel_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6003,"CANCEL"))
 DECLARE addalias_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6003,"ADDALIAS"))
 DECLARE activate_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6003,"ACTIVATE"))
 DECLARE incomplete_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6004,"INCOMPLETE"))
 DECLARE pointofcare_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",106,"POINTOFCARE"))
 DECLARE pod_loc_bed_cd = f8 WITH public, noconstant
 DECLARE pod_loc_room_cd = f8 WITH public, noconstant
 DECLARE pod_loc_nurse_unit_cd = f8 WITH public, noconstant
 DECLARE pod_loc_building_cd = f8 WITH public, noconstant
 DECLARE pod_loc_facility_cd = f8 WITH public, noconstant
 DECLARE pod_roombed = vc WITH public, noconstant
 DECLARE pod_printername = vc WITH public, noconstant
 DECLARE mf_icd9_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,"ICD9CODE"))
 DECLARE mf_activeencntrorder = f8 WITH constant(uar_get_code_by("DISPLAYKEY",16449,
   "ACTIVEENCOUNTERORDER")), protect
 DECLARE ml_diacnt = i4 WITH noconstant(0), protect
 DECLARE ml_diagx = i4 WITH noconstant(0), protect
 DECLARE mf_addr_home_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"HOME"))
 DECLARE mf_consulting_md = f8 WITH constant(uar_get_code_by("DISPLAYKEY",16449,
   "CONSULTING PHYSICIAN")), protect
 DECLARE mf_specialinstructions = f8 WITH constant(uar_get_code_by("DISPLAYKEY",16449,
   "SPECIALINSTRUCTIONS")), protect
 DECLARE mf_cs16449_perfloc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "PERFORMINGLOCATIONAMBULATORY"))
 DECLARE mf_cs220_labcorp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"LABCORP"))
 DECLARE ml_labcorp_ind = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM order_detail od,
   code_value cv
  PLAN (od
   WHERE (od.order_id=request->order_qual[1].order_id)
    AND od.oe_field_id=mf_cs16449_perfloc_cd)
   JOIN (cv
   WHERE cv.code_value=od.oe_field_value)
  ORDER BY od.order_id, od.action_sequence DESC
  HEAD od.order_id
   IF (trim(cv.display_key,3)="LABCORP")
    ml_labcorp_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (ml_labcorp_ind=1)
  EXECUTE bhs_ma_amb_rln_req
  GO TO exit_script
 ENDIF
 DECLARE mf_cs6004_future_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!11559"))
 DECLARE ml_print_draw_only = i4 WITH protect, noconstant(0)
 DECLARE ml_ord_idx = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM orders o,
   encounter e,
   code_value cv
  PLAN (o
   WHERE expand(ml_ord_idx,1,size(request->order_qual,5),o.order_id,request->order_qual[ml_ord_idx].
    order_id)
    AND o.order_status_cd=mf_cs6004_future_cd)
   JOIN (e
   WHERE e.encntr_id=o.originating_encntr_id)
   JOIN (cv
   WHERE cv.code_value=e.loc_nurse_unit_cd
    AND cv.code_set=220
    AND cv.active_ind=1
    AND cv.display_key IN ("BMAPREOP", "TRANSPLANTPRE", "TRANSPLANTPOST", "TRNSDNRPSTSRGB"))
  DETAIL
   ml_print_draw_only = 1, request->order_qual[1].encntr_id = o.originating_encntr_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM person p,
   encounter e,
   person_alias pa,
   person_alias pa1,
   encntr_alias ea,
   encntr_prsnl_reltn epr,
   prsnl pl,
   (dummyt d1  WITH seq = 1),
   (dummyt d2  WITH seq = 1),
   (dummyt d3  WITH seq = 1),
   (dummyt d4  WITH seq = 1)
  PLAN (p
   WHERE (p.person_id=request->person_id))
   JOIN (e
   WHERE (e.encntr_id=request->order_qual[1].encntr_id))
   JOIN (d1)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=mrn_alias_cd
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND pa.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (d4)
   JOIN (pa1
   WHERE pa1.person_id=p.person_id
    AND pa1.person_alias_type_cd=mf_cmrn_cd
    AND pa1.active_ind=1
    AND pa1.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND pa1.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (d2)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd IN (fnbr_cd, fmrn_cd)
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
   orders->dob = format(p.birth_dt_tm,"@SHORTDATE;;Q"), orders->admit_dt = format(e.reg_dt_tm,
    "@SHORTDATE;;Q"), orders->dischg_dt = format(e.disch_dt_tm,"@SHORTDATE;;Q")
   IF (((e.disch_dt_tm=null) OR (e.disch_dt_tm=0)) )
    orders->los = (datetimecmp(cnvtdatetime(sysdate),e.reg_dt_tm)+ 1)
   ELSE
    orders->los = (datetimecmp(e.disch_dt_tm,e.reg_dt_tm)+ 1)
   ENDIF
   orders->facility = uar_get_code_description(e.loc_facility_cd), orders->nurse_unit =
   uar_get_code_display(e.loc_nurse_unit_cd), orders->room = uar_get_code_display(e.loc_room_cd),
   orders->bed = uar_get_code_display(e.loc_bed_cd), orders->location = concat(trim(orders->
     nurse_unit),"/",trim(orders->room),"/",trim(orders->bed)), pod_loc_bed_cd = e.loc_bed_cd,
   pod_loc_room_cd = e.loc_room_cd, pod_loc_nurse_unit_cd = e.loc_nurse_unit_cd, pod_loc_building_cd
    = e.loc_building_cd,
   pod_loc_facility_cd = e.loc_facility_cd, orders->admit_diagnosis = e.reason_for_visit, orders->
   med_service = uar_get_code_display(e.med_service_cd)
  HEAD epr.encntr_prsnl_r_cd
   IF ((request->order_qual[1].encntr_id > 0))
    IF (epr.encntr_prsnl_r_cd=admit_doc_cd)
     orders->admitting = pl.name_full_formatted
    ELSEIF (epr.encntr_prsnl_r_cd=attend_doc_cd)
     orders->attending = pl.name_full_formatted
    ENDIF
   ELSE
    orders->admitting = "N/A", orders->attending = "N/A"
   ENDIF
  DETAIL
   IF (pa1.person_alias_type_cd=mf_cmrn_cd)
    IF (pa1.alias_pool_cd > 0)
     orders->s_cmrn = cnvtalias(pa1.alias,pa1.alias_pool_cd)
    ELSE
     orders->s_cmrn = pa1.alias
    ENDIF
   ENDIF
   IF (pa.person_alias_type_cd=mrn_alias_cd)
    orders->mrn = format(pa.alias,"#######;p0")
   ENDIF
   IF (ea.encntr_alias_type_cd=fnbr_cd
    AND e.encntr_id > 0)
    orders->fnbr = format(ea.alias,"##########;l")
   ELSEIF (e.encntr_id=0)
    orders->fnbr = "N/A"
   ENDIF
   IF (ea.encntr_alias_type_cd=fmrn_cd
    AND e.encntr_id > 0)
    orders->fmrn = format(ea.alias,"#########;l")
   ELSEIF (e.encntr_id=0)
    orders->fmrn = "N/A"
   ENDIF
  WITH nocounter, outerjoin = d1, dontcare = pa,
   dontcare = pa1, outerjoin = d2, dontcare = ea,
   outerjoin = d3, dontcare = epr
 ;end select
 SELECT INTO "nl:"
  FROM address ad
  WHERE ad.parent_entity_name="PERSON"
   AND (ad.parent_entity_id=request->person_id)
   AND ad.address_type_cd=mf_addr_home_cd
   AND ad.active_ind=1
   AND ad.end_effective_dt_tm > sysdate
   AND ad.address_type_seq=1
  DETAIL
   orders->ms_address_lone = ad.street_addr, orders->ms_address_ltwo = ad.street_addr2, orders->
   ms_city = ad.city,
   orders->ms_state = ad.state, orders->ms_zip = ad.zipcode
  WITH nocounter
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
    orders->height_dt_tm = format(c.updt_dt_tm,"@SHORTDATETIME;;Q")
   ELSEIF (c.event_cd=weight_cd)
    orders->weight = concat(trim(c.event_tag)," ",trim(uar_get_code_display(c.result_units_cd))),
    orders->weight_dt_tm = format(c.updt_dt_tm,"@SHORTDATETIME;;Q")
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
    AND a.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ((a.end_effective_dt_tm >= cnvtdatetime(sysdate)) OR (a.end_effective_dt_tm=null))
    AND a.reaction_status_cd != canceled_cd)
   JOIN (d)
   JOIN (n
   WHERE n.nomenclature_id=a.substance_nom_id)
  ORDER BY cnvtdatetime(a.onset_dt_tm)
  HEAD REPORT
   allergy->cnt = 0
  DETAIL
   IF (((n.source_string > " ") OR (a.substance_ftdesc > " ")) )
    allergy->cnt += 1, stat = alterlist(allergy->qual,allergy->cnt), allergy->qual[allergy->cnt].list
     = a.substance_ftdesc
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
   WHERE (o.order_id=request->order_qual[d1.seq].order_id)
    AND  NOT (o.activity_type_cd=pointofcare_cd))
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
   ord_cnt += 1, orders->qual[ord_cnt].fut_facilty = uar_get_code_display(o
    .future_location_facility_cd), orders->qual[ord_cnt].fut_unit = uar_get_code_display(o
    .future_location_nurse_unit_cd),
   orders->qual[ord_cnt].fut_facilty_cd = o.future_location_facility_cd, orders->qual[ord_cnt].
   fut_unit_cd = o.future_location_nurse_unit_cd, orders->qual[ord_cnt].status = uar_get_code_display
   (o.order_status_cd),
   orders->qual[ord_cnt].catalog = uar_get_code_display(o.catalog_type_cd), orders->qual[ord_cnt].
   catalog_type_cd = o.catalog_type_cd, orders->qual[ord_cnt].activity = uar_get_code_display(o
    .activity_type_cd),
   orders->qual[ord_cnt].activity_type_cd = o.activity_type_cd, orders->qual[ord_cnt].display_line =
   o.clinical_display_line, orders->qual[ord_cnt].order_id = o.order_id,
   orders->qual[ord_cnt].display_ind = 1, orders->qual[ord_cnt].template_order_flag = o
   .template_order_flag, orders->qual[ord_cnt].cs_flag = o.cs_flag,
   orders->qual[ord_cnt].oe_format_id = o.oe_format_id
   IF (substring(245,10,o.clinical_display_line) > "  ")
    orders->qual[ord_cnt].clin_line_ind = 1
   ELSE
    orders->qual[ord_cnt].clin_line_ind = 0
   ENDIF
   orders->qual[ord_cnt].mnemonic = o.hna_order_mnemonic, orders->qual[ord_cnt].order_dt = format(oa
    .order_dt_tm,"@SHORTDATETIME;;Q"), orders->qual[ord_cnt].signed_dt = format(o.orig_order_dt_tm,
    "@SHORTDATETIME;;Q"),
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
   IF ((((request->print_prsnl_id=0)
    AND oa.action_type_cd IN (transfercancel_cd, suspend_cd, dischargeorder_cd, discont_cd, void_cd,
   cancelreorder_cd, canceldc_cd, cancel_cd)) OR ((request->print_prsnl_id > 0)
    AND oa.action_type_cd IN (transfercancel_cd, suspend_cd, order_cd, modify_cd, dischargeorder_cd,
   discont_cd, void_cd, complete_cd, collection_cd, cancelreorder_cd,
   canceldc_cd, cancel_cd, activate_cd)))
    AND (orders->qual[ord_cnt].template_order_flag IN (0, 2)))
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
    AND (((oef.action_type_cd=orders->qual[d1.seq].action_type_cd)) OR ((orders->qual[d1.seq].
   action_type_cd IN (activatestudentorder_cd, activate_cd, modify_cd))
    AND oef.action_type_cd=order_cd))
    AND oef.oe_field_id=od.oe_field_id
    AND ((oef.accept_flag IN (0, 1, 3)
    AND od.oe_field_id != mf_activeencntrorder) OR (oef.accept_flag IN (2)
    AND od.oe_field_id IN (mf_icd9_cd, mf_consulting_md, mf_specialinstructions))) )
   JOIN (of1
   WHERE of1.oe_field_id=oef.oe_field_id)
  ORDER BY od.order_id, oef.group_seq, oef.field_seq,
   od.oe_field_id, od.action_sequence DESC
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
   IF (od.oe_field_meaning="COLLECTYN")
    orders->qual[d1.seq].collectedyn = od.oe_field_display_value
   ENDIF
  HEAD od.action_sequence
   IF (act_seq != od.action_sequence)
    odflag = 0
   ENDIF
   ml_diacnt = 0
  DETAIL
   IF (odflag=1)
    orders->qual[d1.seq].d_cnt += 1, dc = orders->qual[d1.seq].d_cnt
    IF (dc > size(orders->qual[d1.seq].d_qual,5))
     stat = alterlist(orders->qual[d1.seq].d_qual,(dc+ 5))
    ENDIF
    IF (od.oe_field_meaning_id=20)
     ml_diacnt += 1, orders->qual[d1.seq].d_qual[dc].label_text = build("Diagnosis #",ml_diacnt)
    ELSE
     orders->qual[d1.seq].d_qual[dc].label_text = trim(oef.label_text)
    ENDIF
    orders->qual[d1.seq].d_qual[dc].field_value = od.oe_field_value, orders->qual[d1.seq].d_qual[dc].
    group_seq = oef.group_seq, orders->qual[d1.seq].d_qual[dc].oe_field_meaning_id = od
    .oe_field_meaning_id,
    orders->qual[d1.seq].d_qual[dc].value = trim(od.oe_field_display_value), orders->qual[d1.seq].
    d_qual[dc].clin_line_ind = oef.clin_line_ind, orders->qual[d1.seq].d_qual[dc].label = trim(oef
     .clin_line_label),
    orders->qual[d1.seq].d_qual[dc].suffix = oef.clin_suffix_ind
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
 SET ml_diacnt = 0
 SELECT INTO "nl:"
  d1.seq
  FROM nomenclature n,
   (dummyt d1  WITH seq = value(size(orders->qual,5))),
   (dummyt d2  WITH seq = 1)
  PLAN (d1
   WHERE maxrec(d2,size(orders->qual[d1.seq].d_qual,5)))
   JOIN (d2)
   JOIN (n
   WHERE (n.nomenclature_id=orders->qual[d1.seq].d_qual[d2.seq].field_value)
    AND (orders->qual[d1.seq].d_qual[d2.seq].oe_field_meaning_id=20))
  ORDER BY d1.seq
  HEAD d1.seq
   ml_diacnt = 0
  DETAIL
   ml_diacnt += 1, orders->qual[d1.seq].d_qual[d2.seq].label_text = build("Diagnosis #",ml_diacnt),
   orders->qual[d1.seq].d_qual[d2.seq].value = concat("(",trim(n.source_identifier),") ",trim(n
     .source_string))
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
  SET orders->qual[x].accession = "n/a"
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
    SET max_length = 90
    EXECUTE dcp_parse_text value(orders->qual[x].comment), value(max_length)
    SET stat = alterlist(orders->qual[x].com_ln_qual,pt->line_cnt)
    SET orders->qual[x].com_ln_cnt = pt->line_cnt
    FOR (y = 1 TO pt->line_cnt)
      SET orders->qual[x].com_ln_qual[y].com_line = replace(replace(pt->lns[y].line,char(013)," "),
       char(010)," ")
    ENDFOR
   ENDIF
 ENDFOR
 CALL echo(build("orders->spoolout_ind = ",orders->spoolout_ind))
 IF ((orders->spoolout_ind=1))
  IF ((request->print_prsnl_id > 0))
   SELECT INTO "nl:"
    sort_order =
    IF (pod_loc_bed_cd=cv.code_value) 1
    ELSEIF (pod_loc_room_cd=cv.code_value) 2
    ELSEIF (pod_loc_nurse_unit_cd=cv.code_value) 3
    ELSEIF (pod_loc_building_cd=cv.code_value) 4
    ELSEIF (pod_loc_facility_cd=cv.code_value) 5
    ENDIF
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=220
      AND cv.code_value IN (pod_loc_bed_cd, pod_loc_room_cd, pod_loc_nurse_unit_cd,
     pod_loc_building_cd, pod_loc_facility_cd))
    ORDER BY sort_order
    DETAIL
     pod_roombed = build(cv.display_key,pod_roombed)
    WITH nocounter
   ;end select
   CALL echo(pod_roombed)
   SET pod_printername = request->printer_name
   SELECT INTO "nl:"
    cv1.display, cv2.definition
    FROM code_value cv1,
     code_value cv2
    PLAN (cv1
     WHERE cv1.code_set=103026
      AND cv1.display=pod_roombed)
     JOIN (cv2
     WHERE cv2.code_set=103027
      AND cv1.definition=cv2.display)
    DETAIL
     pod_printername = cv2.definition
    WITH nocounter
   ;end select
   IF ((request->printer_name != "CER_T*"))
    SET request->printer_name = pod_printername
   ENDIF
  ENDIF
  SET new_timedisp = cnvtstring(curtime3)
  SET tempfile1a = build(concat("cer_temp:dcpreq","_",new_timedisp),".dat")
  CALL echo(build("tempfile1a =",tempfile1a))
  SELECT INTO value(request->printer_name)
   d1.seq
   FROM (dummyt d1  WITH seq = 1)
   PLAN (d1)
   HEAD REPORT
    xcol = 20, hold_set_ind = 0, line1 = fillstring(115,"_"),
    break_variable = 0
   HEAD PAGE
    IF (ml_print_draw_only=1)
     xcol = 80, ycol = 20,
     CALL print(calcpos(xcol,ycol)),
     "{cpi/12}{b}PLEASE DRAW & SEND TESTING TO BAYSTATE MEDICAL CENTER", row + 1
    ENDIF
    "{CPI/8}{POS/24/30}{color/20/145}", row + 1, "{CPI/8}{POS/24/37}{color/20/145}",
    row + 1, "{CPI/8}{POS/24/44}{color/20/145}", row + 1,
    "{CPI/8}{POS/24/51}{color/20/145}", row + 1, "{CPI/8}{POS/24/58}{color/20/145}",
    row + 1, "{CPI/8}{POS/24/65}{color/20/145}", row + 1
    IF (encntr_id=0)
     "{CPI/8}{POS/24/72}{color/20/145}", row + 1
    ENDIF
    xcol = 30, ycol = 45,
    CALL print(calcpos(xcol,ycol)),
    "{f/8}{cpi/10}{b}PATIENT NAME ", xcol = 130,
    CALL print(calcpos(xcol,ycol)),
    orders->name, "{endb}", row + 1,
    xcol = 470,
    CALL print(calcpos(xcol,ycol)), "{b}Acct # ",
    orders->fnbr, "{endb}", row + 1
    IF (encntr_id=0)
     xcol = 40, ycol += 12,
     CALL print(calcpos(xcol,ycol)),
     "{cpi/12}DOB: ", orders->dob, row + 1,
     xcol = 40, ycol += 12,
     CALL print(calcpos(xcol,ycol)),
     "{cpi/14}{b}Ordering Provider:{endb} ", orders->qual[1].order_dr, row + 1
    ELSE
     xcol = 40, ycol += 12,
     CALL print(calcpos(xcol,ycol)),
     "{cpi/12}Order entered by: ", orders->qual[1].enter_by, row + 1
    ENDIF
    xcol = 40, ycol += 12, first_page = "Y",
    previous = 0
   DETAIL
    FOR (vv = 1 TO value(order_cnt))
     IF (vv > 1
      AND (previous=(vv+ 1)))
      BREAK, previous = (vv+ 1)
     ENDIF
     ,
     IF ((orders->qual[vv].display_ind=1))
      CALL echo(build("order",vv," col= ",ycol))
      IF (hold_set_ind=0)
       hold_oe_format_id = orders->qual[vv].oe_format_id, hold_activity_type_cd = orders->qual[vv].
       activity_type_cd, hold_set_ind = 1
      ELSE
       IF (vv > 1)
        break_variable = (ycol+ ((((orders->qual[vv].d_cnt/ 2)+ orders->qual[vv].com_ln_cnt)+ 9) * 20
        ))
        IF (break_variable > 660)
         BREAK
        ENDIF
       ENDIF
      ENDIF
      hold_activity_type_cd = orders->qual[vv].activity_type_cd, hold_oe_format_id = orders->qual[vv]
      .oe_format_id, xcol = 30,
      ycol += 10,
      CALL print(calcpos(xcol,ycol)), "{cpi/12}{b}",
      line1, "{endb}", row + 1,
      xcol = 40, ycol += 21,
      CALL print(calcpos(xcol,ycol)),
      "{cpi/14}Ordering MD: ", orders->qual[vv].order_dr, row + 1
      IF ((orders->qual[vv].fut_facilty_cd=0))
       xcol = 40, ycol += 11,
       CALL print(calcpos(xcol,ycol)),
       "Order Type: ", orders->qual[vv].type, row + 1,
       xcol = 40, ycol += 11,
       CALL print(calcpos(xcol,ycol)),
       "Order Action: ", orders->qual[vv].action, row + 1
      ELSE
       xcol = 40, ycol += 11,
       CALL print(calcpos(xcol,ycol)),
       "Attending MD: ", orders->attending, row + 1
      ENDIF
      xcol = 40, ycol += 11,
      CALL print(calcpos(xcol,ycol)),
      "Order Status: ", orders->qual[vv].status, row + 1,
      xcol = 40, ycol += 11
      IF ((orders->qual[vv].fut_facilty_cd > 0))
       CALL print(calcpos(xcol,ycol)), "Future Order Facility: ", orders->qual[vv].fut_facilty,
       row + 1, xcol = 40, ycol += 11,
       CALL print(calcpos(xcol,ycol)), "Future Order Unit: ", orders->qual[vv].fut_unit,
       row + 1, xcol = 40, ycol += 11,
       xcol = 40, ycol += 11, row + 1,
       CALL print(calcpos(xcol,ycol)), "{cpi/12}{b}Ordering Provider: ", orders->qual[vv].order_dr,
       "{endb}", row + 1, xcol = 40,
       ycol += 11,
       CALL print(calcpos(xcol,ycol)),
       "{cpi/12}{b}All orders below are electronically signed by this provider.",
       "{endb}", row + 1, xcol = 40,
       ycol += 11
      ENDIF
      xcol = 30, ycol += 15,
      CALL print(calcpos(xcol,ycol)),
      "{cpi/12}{b}Procedure: ", orders->qual[vv].mnemonic, "{endb}",
      row + 1, xcol = 300,
      CALL print(calcpos(xcol,ycol)),
      "{b}Order ID: ", orders->qual[vv].order_id"##########", "{endb}",
      row + 1, xcol = 30, ycol += 15,
      CALL print(calcpos(xcol,ycol)), "{cpi/12}Accession #: ", orders->qual[vv].accession,
      row + 1, xcol = 300, lastodxcol = xcol
      FOR (x = 1 TO orders->qual[vv].d_cnt)
        IF ((orders->qual[vv].d_qual[x].print_ind=0)
         AND  NOT ((orders->qual[vv].d_qual[x].oe_field_meaning_id IN (20.0, 2.0))))
         orders->qual[vv].d_qual[x].print_ind = 1, row + 1, xcol = 30,
         lastodxcol = xcol, ycol += 12,
         CALL print(calcpos(xcol,ycol))
         IF (((size(orders->qual[vv].d_qual[x].label_text)+ size(orders->qual[vv].d_qual[x].value))
          > 100))
          CALL print(substring(1,100,concat(orders->qual[vv].d_qual[x].label_text,": ",orders->qual[
            vv].d_qual[x].value))), "..."
         ELSE
          orders->qual[vv].d_qual[x].label_text, ": ", orders->qual[vv].d_qual[x].value
         ENDIF
        ENDIF
      ENDFOR
      FOR (x = 1 TO orders->qual[vv].d_cnt)
        IF ((orders->qual[vv].d_qual[x].print_ind=0)
         AND (orders->qual[vv].d_qual[x].oe_field_meaning_id IN (2.0))
         AND (orders->qual[vv].d_qual[x].label_text="Copy To"))
         orders->qual[vv].d_qual[x].print_ind = 1, row + 1, xcol = 30,
         lastodxcol = xcol, ycol += 12,
         CALL print(calcpos(xcol,ycol))
         IF (((size(orders->qual[vv].d_qual[x].label_text)+ size(orders->qual[vv].d_qual[x].value))
          > 100))
          CALL print(substring(1,100,concat(orders->qual[vv].d_qual[x].label_text,": ",orders->qual[
            vv].d_qual[x].value))), "..."
         ELSE
          orders->qual[vv].d_qual[x].label_text, ": ", orders->qual[vv].d_qual[x].value
         ENDIF
        ENDIF
      ENDFOR
      FOR (ml_diagx = 1 TO orders->qual[vv].d_cnt)
        IF ((orders->qual[vv].d_qual[ml_diagx].print_ind=0)
         AND (orders->qual[vv].d_qual[ml_diagx].oe_field_meaning_id=20))
         orders->qual[vv].d_qual[ml_diagx].print_ind = 1, row + 1, xcol = 30,
         ycol += 12,
         CALL print(calcpos(xcol,ycol))
         IF (((size(orders->qual[vv].d_qual[ml_diagx].label_text)+ size(orders->qual[vv].d_qual[
          ml_diagx].value)) > 100))
          CALL print(substring(1,100,concat(orders->qual[vv].d_qual[ml_diagx].label_text,": ",orders
            ->qual[vv].d_qual[ml_diagx].value))), "..."
         ELSE
          orders->qual[vv].d_qual[ml_diagx].label_text, ": ", orders->qual[vv].d_qual[ml_diagx].value
         ENDIF
        ENDIF
      ENDFOR
      IF ((orders->qual[vv].comment_ind=1)
       AND (orders->qual[vv].com_ln_cnt > 0))
       IF ((orders->qual[vv].com_ln_cnt > 10))
        ocnt = 10
       ELSE
        ocnt = orders->qual[vv].com_ln_cnt
       ENDIF
       xcol = 30, ycol += 15
       FOR (com_cnt = 1 TO ocnt)
         CALL print(calcpos(xcol,ycol)), "{cpi/14}", orders->qual[vv].com_ln_qual[com_cnt].com_line,
         row + 1, ycol += 11
       ENDFOR
       ycol += 12
      ENDIF
     ENDIF
    ENDFOR
   FOOT PAGE
    "{cpi/12}{pos/30/660}", line1, ycol,
    row + 1, "{cpi/12}{pos/220/687}", "{b/8}Patient: ",
    "{pos/265/687}", orders->name
    IF ((request->order_qual[1].encntr_id != 0))
     "{pos/220/698}", "Acct #: ", orders->fnbr
    ENDIF
    "{pos/330/698}", "DOB: ", orders->dob
    IF ((request->order_qual[1].encntr_id != 0))
     "{pos/410/698}", "ADM: ", orders->admit_dt,
     row + 1, "{pos/220/709}", "{b/5}MRN # ",
     orders->fmrn
    ENDIF
    "{pos/330/709}", "{b}Age:{endb} ", orders->age,
    "{pos/410/709}", "{b}Gender:{endb} ", orders->sex,
    row + 1
    IF ((request->order_qual[1].encntr_id != 0))
     "{pos/220/720}", "Attending MD: ", orders->attending,
     row + 1, "{pos/465/720}", "{b}Location:{endb} ",
     orders->location, row + 1
    ELSE
     "{pos/220/720}", "{b}Address:{endb} ", orders->ms_address_lone
     IF (textlen(orders->ms_address_ltwo) != 0)
      ", ", orders->ms_address_ltwo
     ENDIF
     ", ", row + 1, "{pos/220/731}",
     orders->ms_city, ", ", orders->ms_state,
     ", ", orders->ms_zip, row + 1
    ENDIF
    "{pos/490/731}", "Page # ", curpage,
    row + 1, "{cpi/10}{pos/30/675}{b}", orders->facility,
    row + 1, "{cpi/10}{pos/30/690}{b}", "Laboratory Order Requisition",
    "{font/8}{cpi/10}{pos/30/705}", "Printed: ", "{endb}",
    curdate, " ", curtime,
    row + 1, "{font/8}{cpi/12}{pos/50/720}", curprog
   WITH nocounter, dio = postscript, maxcol = 800,
    maxrow = 750
  ;end select
 ENDIF
 CALL echorecord(orders)
#exit_script
END GO
