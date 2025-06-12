CREATE PROGRAM bhs_req_05:dba
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
   1 ms_address_lone = vc
   1 ms_address_ltwo = vc
   1 ms_city = vc
   1 ms_state = vc
   1 ms_zip = vc
   1 mrn = vc
   1 cmrn = vc
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
     2 reprint_ind = i2
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
       3 f_oe_field_id = f8
     2 priority = vc
     2 req_st_dt = vc
     2 frequency = vc
     2 rate = vc
     2 duration = vc
     2 duration_unit = vc
     2 nurse_collect = vc
     2 collectedyn = vc
     2 s_fut_facilty = vc
     2 s_fut_unit = vc
     2 f_fut_facilty_cd = f8
     2 f_fut_unit_cd = f8
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
 SET person_id = 0
 SET encntr_id = 0
 SET orders->spoolout_ind = 0
 SET pharm_flag = 0
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 319
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_cd = code_value
 SET code_set = 4
 SET cdf_meaning = "CMRN"
 EXECUTE cpm_get_cd_for_cdf
 SET cmrn_cd = code_value
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
 DECLARE temp_cd = f8
 SET temp_cd = 0.00
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
 DECLARE mf_consulting_md = f8 WITH constant(uar_get_code_by("DISPLAYKEY",16449,
   "CONSULTING PHYSICIAN")), protect
 DECLARE pointofcare_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",106,"POINTOFCARE"))
 DECLARE pod_loc_bed_cd = f8 WITH public, noconstant
 DECLARE pod_loc_room_cd = f8 WITH public, noconstant
 DECLARE pod_loc_nurse_unit_cd = f8 WITH public, noconstant
 DECLARE pod_loc_building_cd = f8 WITH public, noconstant
 DECLARE pod_loc_facility_cd = f8 WITH public, noconstant
 DECLARE pod_roombed = vc WITH public, noconstant
 DECLARE pod_printername = vc WITH public, noconstant
 DECLARE inprocess_cd = f8 WITH public, constant(uar_get_code_by("MEANING",14281,"LABINPROCESS"))
 DECLARE collected_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",14281,"COLLECTED"))
 DECLARE inlab_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",14281,"INLAB"))
 DECLARE prelim_cd = f8 WITH public, constant(uar_get_code_by("MEANING",14281,"LABPRELIM"))
 DECLARE dc_cd = f8 WITH public, constant(uar_get_code_by("MEANING",14281,"DISCONTINUED"))
 DECLARE mf_icd9_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,"ICD9CODE"))
 DECLARE mf_onhold = f8 WITH constant(uar_get_code_by("DESCRIPTION",14281,"On Hold")), protect
 DECLARE mf_collectedyn = f8 WITH constant(uar_get_code_by("DISPLAYKEY",16449,"COLLECTED Y/N")),
 protect
 DECLARE mf_activeencntrorder = f8 WITH constant(uar_get_code_by("DISPLAYKEY",16449,
   "ACTIVEENCOUNTERORDER")), protect
 DECLARE mf_ordered = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14281,"ORDERED")), protect
 DECLARE mf_examordered = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14281,"EXAMORDERED")),
 protect
 DECLARE ml_diacnt = i4 WITH noconstant(0), protect
 DECLARE mf_addr_home_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"HOME"))
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
   encntr_alias ea,
   encntr_prsnl_reltn epr,
   prsnl pl,
   (dummyt d1  WITH seq = 1),
   (dummyt d2  WITH seq = 1),
   (dummyt d3  WITH seq = 1)
  PLAN (p
   WHERE (p.person_id=request->person_id))
   JOIN (e
   WHERE (e.encntr_id=request->order_qual[1].encntr_id))
   JOIN (d1)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=cmrn_cd
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND pa.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (d2)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd IN (fnbr_cd, mrn_cd)
    AND ea.active_ind=1)
   JOIN (d3)
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.encntr_prsnl_r_cd IN (admit_doc_cd, attend_doc_cd)
    AND epr.active_ind=1
    AND epr.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (pl
   WHERE pl.person_id=epr.prsnl_person_id)
  HEAD REPORT
   person_id = p.person_id,
   CALL echo(build("personid =",p.person_id)), encntr_id = e.encntr_id,
   orders->name = p.name_full_formatted, orders->pat_type = trim(uar_get_code_display(e
     .encntr_type_cd)), orders->sex = uar_get_code_display(p.sex_cd),
   orders->age = cnvtage(cnvtdate(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1)),curdate),
   orders->dob = format(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1),"@SHORTDATE;;Q"),
   orders->admit_dt = format(e.reg_dt_tm,"@SHORTDATE;;Q"),
   orders->dischg_dt = format(e.disch_dt_tm,"@SHORTDATE;;Q")
   IF (((e.disch_dt_tm=null) OR (e.disch_dt_tm=0)) )
    orders->los = (datetimecmp(cnvtdatetime(sysdate),e.reg_dt_tm)+ 1)
   ELSE
    orders->los = (datetimecmp(e.disch_dt_tm,e.reg_dt_tm)+ 1)
   ENDIF
   temp_cd = e.loc_temp_cd, orders->facility = uar_get_code_description(e.loc_facility_cd), orders->
   nurse_unit = uar_get_code_display(e.loc_nurse_unit_cd),
   orders->room = uar_get_code_display(e.loc_room_cd), orders->bed = uar_get_code_display(e
    .loc_bed_cd), orders->location = concat(trim(orders->nurse_unit),"/",trim(orders->room),"/",trim(
     orders->bed)),
   pod_loc_bed_cd = e.loc_bed_cd, pod_loc_room_cd = e.loc_room_cd, pod_loc_nurse_unit_cd = e
   .loc_nurse_unit_cd,
   pod_loc_building_cd = e.loc_building_cd, pod_loc_facility_cd = e.loc_facility_cd, orders->
   admit_diagnosis = e.reason_for_visit,
   orders->med_service = uar_get_code_display(e.med_service_cd)
  HEAD epr.encntr_prsnl_r_cd
   IF (epr.encntr_prsnl_r_cd=admit_doc_cd)
    orders->admitting = pl.name_full_formatted
   ELSEIF (epr.encntr_prsnl_r_cd=attend_doc_cd
    AND e.encntr_id > 0)
    orders->attending = pl.name_full_formatted
   ELSEIF (e.encntr_id=0)
    orders->attending = "N/A"
   ENDIF
  DETAIL
   IF (pa.person_alias_type_cd=cmrn_cd)
    IF (pa.alias_pool_cd > 0)
     orders->cmrn = cnvtalias(pa.alias,pa.alias_pool_cd)
    ELSE
     orders->cmrn = pa.alias
    ENDIF
   ENDIF
   IF (ea.encntr_alias_type_cd=mrn_cd
    AND e.encntr_id > 0)
    IF (ea.alias_pool_cd > 0)
     orders->mrn = cnvtalias(ea.alias,ea.alias_pool_cd)
    ELSE
     orders->mrn = ea.alias
    ENDIF
   ELSEIF (e.encntr_id=0)
    orders->mrn = "N/A"
   ENDIF
   IF (ea.encntr_alias_type_cd=fnbr_cd
    AND e.encntr_id > 0)
    IF (ea.alias_pool_cd > 0)
     orders->fnbr = cnvtalias(ea.alias,ea.alias_pool_cd)
    ELSE
     orders->fnbr = ea.alias
    ENDIF
   ELSEIF (e.encntr_id=0)
    orders->fnbr = "N/A"
   ENDIF
  WITH nocounter, outerjoin = d1, dontcare = pa,
   outerjoin = d2, dontcare = ea, outerjoin = d3,
   dontcare = epr
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
 SELECT INTO "NL:"
  FROM orders o,
   order_action oa,
   prsnl pl,
   prsnl pl2,
   (dummyt d1  WITH seq = value(size(request->order_qual,5)))
  PLAN (d1)
   JOIN (o
   WHERE (o.order_id=request->order_qual[d1.seq].order_id)
    AND o.template_order_flag IN (0, 2))
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_sequence=o.last_action_sequence
    AND ((cnvtlookbehind("30,S") < oa.action_dt_tm
    AND oa.dept_status_cd IN (collected_cd)) OR (cnvtlookbehind("30,S") > oa.action_dt_tm
    AND oa.dept_status_cd IN (inprocess_cd, collected_cd, inlab_cd, prelim_cd, dc_cd,
   mf_onhold, mf_ordered, mf_examordered))) )
   JOIN (pl
   WHERE pl.person_id=oa.action_personnel_id)
   JOIN (pl2
   WHERE pl2.person_id=oa.order_provider_id)
  ORDER BY o.oe_format_id, o.activity_type_cd, o.current_start_dt_tm
  HEAD REPORT
   orders->order_location = trim(uar_get_code_display(oa.order_locn_cd))
  HEAD o.order_id
   ord_cnt += 1, stat = alterlist(orders->qual,ord_cnt)
   IF (cnvtlookbehind("30,S") > oa.action_dt_tm)
    orders->qual[ord_cnt].reprint_ind = 1
   ELSE
    orders->qual[ord_cnt].reprint_ind = 0
   ENDIF
   orders->qual[ord_cnt].status = uar_get_code_display(o.order_status_cd), orders->qual[ord_cnt].
   s_fut_facilty = uar_get_code_display(o.future_location_facility_cd), orders->qual[ord_cnt].
   s_fut_unit = uar_get_code_display(o.future_location_nurse_unit_cd),
   orders->qual[ord_cnt].f_fut_facilty_cd = o.future_location_facility_cd, orders->qual[ord_cnt].
   f_fut_unit_cd = o.future_location_nurse_unit_cd, orders->qual[ord_cnt].catalog =
   uar_get_code_display(o.catalog_type_cd),
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
  FOOT REPORT
   IF (ord_cnt=0)
    orders->spoolout_ind = 0
   ELSE
    orders->spoolout_ind = 1
   ENDIF
   order_cnt = ord_cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_detail od,
   oe_format_fields oef,
   prsnl p,
   (dummyt d1  WITH seq = value(order_cnt))
  PLAN (d1)
   JOIN (od
   WHERE (orders->qual[d1.seq].order_id=od.order_id))
   JOIN (oef
   WHERE (oef.oe_format_id=orders->qual[d1.seq].oe_format_id)
    AND (((oef.action_type_cd=orders->qual[d1.seq].action_type_cd)) OR ((orders->qual[d1.seq].
   action_type_cd IN (activatestudentorder_cd, activate_cd, modify_cd, collection_cd))
    AND oef.action_type_cd=order_cd))
    AND oef.oe_field_id=od.oe_field_id
    AND ((oef.accept_flag IN (0, 1, 3)
    AND od.oe_field_id != mf_activeencntrorder) OR (oef.accept_flag=2
    AND od.oe_field_id IN (mf_icd9_cd, mf_consulting_md))) )
   JOIN (p
   WHERE p.person_id=od.updt_id)
  ORDER BY od.order_id, oef.group_seq, oef.field_seq,
   od.oe_field_id, od.action_sequence DESC
  HEAD REPORT
   orders->qual[d1.seq].d_cnt = 0, cnt = 0
  HEAD od.order_id
   orders->qual[d1.seq].d_cnt = 0, stat = alterlist(orders->qual[d1.seq].d_qual,5)
  HEAD od.oe_field_id
   IF (od.oe_field_meaning != "ICD9")
    orders->qual[d1.seq].d_cnt += 1, dc = orders->qual[d1.seq].d_cnt
    IF (dc > size(orders->qual[d1.seq].d_qual,5))
     stat = alterlist(orders->qual[d1.seq].d_qual,(dc+ 5))
    ENDIF
    orders->qual[d1.seq].d_qual[dc].label_text = trim(oef.label_text), orders->qual[d1.seq].d_qual[dc
    ].field_value = od.oe_field_value, orders->qual[d1.seq].d_qual[dc].group_seq = oef.group_seq,
    orders->qual[d1.seq].d_qual[dc].oe_field_meaning_id = od.oe_field_meaning_id, orders->qual[d1.seq
    ].d_qual[dc].value = trim(od.oe_field_display_value), orders->qual[d1.seq].d_qual[dc].field_value
     = od.oe_field_value,
    orders->qual[d1.seq].d_qual[dc].clin_line_ind = oef.clin_line_ind, orders->qual[d1.seq].d_qual[dc
    ].label = trim(oef.clin_line_label), orders->qual[d1.seq].d_qual[dc].suffix = oef.clin_suffix_ind,
    orders->qual[d1.seq].d_qual[dc].f_oe_field_id = od.oe_field_id
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
    IF (od.oe_field_id=mf_collectedyn
     AND od.oe_field_value=1)
     orders->qual[d1.seq].d_qual[dc].value = concat(orders->qual[d1.seq].d_qual[dc].value," ",trim(
       format(od.updt_dt_tm,"mm/dd/yy hh:mm;1;Q"))," by ",trim(p.name_full_formatted))
    ENDIF
   ENDIF
  FOOT  od.order_id
   stat = alterlist(orders->qual[d1.seq].d_qual,dc)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_detail od,
   oe_format_fields oef,
   (dummyt d1  WITH seq = value(order_cnt))
  PLAN (d1)
   JOIN (od
   WHERE (orders->qual[d1.seq].order_id=od.order_id))
   JOIN (oef
   WHERE (oef.oe_format_id=orders->qual[d1.seq].oe_format_id)
    AND (((oef.action_type_cd=orders->qual[d1.seq].action_type_cd)) OR ((orders->qual[d1.seq].
   action_type_cd IN (activatestudentorder_cd, activate_cd, modify_cd, collection_cd))
    AND oef.action_type_cd=order_cd))
    AND oef.oe_field_id=od.oe_field_id
    AND oef.accept_flag=2
    AND od.oe_field_id IN (mf_icd9_cd))
  ORDER BY od.order_id, oef.group_seq, oef.field_seq,
   od.oe_field_id, od.action_sequence DESC
  HEAD REPORT
   null
  HEAD od.order_id
   appcnt = 0
  DETAIL
   IF (od.oe_field_meaning="ICD9")
    orders->qual[d1.seq].d_cnt += 1, appcnt = orders->qual[d1.seq].d_cnt
    IF (appcnt > size(orders->qual[d1.seq].d_qual,5))
     stat = alterlist(orders->qual[d1.seq].d_qual,(appcnt+ 5))
    ENDIF
    orders->qual[d1.seq].d_qual[appcnt].label_text = trim(oef.label_text), orders->qual[d1.seq].
    d_qual[appcnt].field_value = od.oe_field_value, orders->qual[d1.seq].d_qual[appcnt].group_seq =
    oef.group_seq,
    orders->qual[d1.seq].d_qual[appcnt].oe_field_meaning_id = od.oe_field_meaning_id, orders->qual[d1
    .seq].d_qual[appcnt].value = trim(od.oe_field_display_value), orders->qual[d1.seq].d_qual[appcnt]
    .field_value = od.oe_field_value,
    orders->qual[d1.seq].d_qual[appcnt].clin_line_ind = oef.clin_line_ind, orders->qual[d1.seq].
    d_qual[appcnt].label = trim(oef.clin_line_label), orders->qual[d1.seq].d_qual[appcnt].suffix =
    oef.clin_suffix_ind
    IF (od.oe_field_display_value > " ")
     orders->qual[d1.seq].d_qual[appcnt].print_ind = 0
    ELSE
     orders->qual[d1.seq].d_qual[appcnt].print_ind = 1
    ENDIF
   ENDIF
  FOOT  od.order_id
   stat = alterlist(orders->qual[d1.seq].d_qual,appcnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d_qual_oe_field_meaning_id = orders->qual[d1.seq].d_qual[d2.seq].oe_field_meaning_id
  FROM nomenclature n,
   (dummyt d1  WITH seq = value(size(orders->qual,5))),
   (dummyt d2  WITH seq = 1)
  PLAN (d1
   WHERE maxrec(d2,size(orders->qual[d1.seq].d_qual,5)))
   JOIN (d2)
   JOIN (n
   WHERE (n.nomenclature_id=orders->qual[d1.seq].d_qual[d2.seq].field_value)
    AND (orders->qual[d1.seq].d_qual[d2.seq].oe_field_meaning_id=20))
  HEAD REPORT
   ml_diacnt = 0
  DETAIL
   ml_diacnt += 1, orders->qual[d1.seq].d_qual[d2.seq].label_text = build("Diagnosis #",ml_diacnt),
   orders->qual[d1.seq].d_qual[d2.seq].value = concat(" (",trim(n.source_identifier),")",trim(n
     .source_string))
  FOOT REPORT
   ml_diacnt = 0
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
 IF ((orders->spoolout_ind=1))
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
  SET new_timedisp = cnvtstring(curtime3)
  SET tempfile1a = build(concat("cer_temp:dcpreq","_",new_timedisp),".dat")
  SET ord_count = size(orders->qual,5)
  SET original_printer_name = request->printer_name
  CALL echorecord(request)
  CALL echorecord(orders)
  FOR (x = 1 TO ord_count)
    IF ((orders->qual[x].display_ind=1))
     IF ((orders->qual[x].reprint_ind=1))
      SET request->printer_name = original_printer_name
     ELSE
      SET request->printer_name = pod_printername
     ENDIF
     SELECT INTO value(request->printer_name)
      oid = orders->qual[x].order_id
      FROM (dummyt d1  WITH seq = 1)
      PLAN (d1)
      HEAD REPORT
       xcol = 20, hold_set_ind = 0, line1 = fillstring(115,"_"),
       break_variable = 0, lastodxcol = 0
      HEAD PAGE
       IF (ml_print_draw_only=1)
        xcol = 80, ycol = 20,
        CALL print(calcpos(xcol,ycol)),
        "{cpi/12}{b}PLEASE DRAW & SEND TESTING TO BAYSTATE MEDICAL CENTER", row + 1
       ENDIF
       "{CPI/8}{POS/24/30}{color/20/145}", row + 1, "{CPI/8}{POS/24/37}{color/20/145}",
       row + 1, "{CPI/8}{POS/24/44}{color/20/145}", row + 1,
       "{CPI/8}{POS/24/51}{color/20/145}", row + 1, "{CPI/8}{POS/24/58}{color/20/145}",
       row + 1, "{CPI/8}{POS/24/65}{color/20/145}", row + 1,
       "{CPI/8}{POS/24/72}{color/20/145}", row + 1, xcol = 30,
       ycol = 45,
       CALL print(calcpos(xcol,ycol)), "{f/8}{cpi/10}{b}PATIENT NAME: ",
       xcol = 130,
       CALL print(calcpos(xcol,ycol)), orders->name,
       "{endb}", row + 1, xcol = 470,
       CALL print(calcpos(xcol,ycol)), "{b}Acct # ", orders->fnbr,
       "{endb}", row + 1, xcol = 40,
       ycol += 12,
       CALL print(calcpos(xcol,ycol)), "{cpi/12}DOB: ",
       orders->dob, row + 1, xcol = 40,
       ycol += 12,
       CALL print(calcpos(xcol,ycol)), "{cpi/14}{b}Ordering Provider:{endb} ",
       orders->qual[1].order_dr, row + 1, xcol = 40,
       ycol += 12, od_cnt = 0, ocnt = 0
      DETAIL
       IF (hold_set_ind=0)
        hold_oe_format_id = orders->qual[x].oe_format_id, hold_activity_type_cd = orders->qual[x].
        activity_type_cd, hold_set_ind = 1
       ELSE
        hold_activity_type_cd = orders->qual[x].activity_type_cd, hold_oe_format_id = orders->qual[x]
        .oe_format_id
       ENDIF
       xcol = 30, ycol += 10,
       CALL print(calcpos(xcol,ycol)),
       "{cpi/12}{b}", line1, "{endb}",
       row + 1, xcol = 40, ycol += 21,
       CALL print(calcpos(xcol,ycol)), "{cpi/14}Ordering MD: ", orders->qual[x].order_dr,
       row + 1
       IF ((orders->qual[x].f_fut_facilty_cd=0))
        xcol = 40, ycol += 11,
        CALL print(calcpos(xcol,ycol)),
        "Order Type: ", orders->qual[x].type, row + 1,
        xcol = 40, ycol += 11,
        CALL print(calcpos(xcol,ycol)),
        "Order Action: ", orders->qual[x].action, row + 1
       ELSE
        xcol = 40, ycol += 11,
        CALL print(calcpos(xcol,ycol)),
        "Attending MD: ", orders->attending, row + 1
       ENDIF
       xcol = 40, ycol += 11,
       CALL print(calcpos(xcol,ycol)),
       "Order Status: ", orders->qual[x].status, row + 1,
       xcol = 40, ycol += 11
       IF ((orders->qual[x].f_fut_facilty_cd > 0))
        CALL print(calcpos(xcol,ycol)), "Future Order Facility: ", orders->qual[x].s_fut_facilty,
        row + 1, xcol = 40, ycol += 11,
        CALL print(calcpos(xcol,ycol)), "Future Order Unit: ", orders->qual[x].s_fut_unit,
        row + 1, xcol = 40, ycol += 11,
        xcol = 40, ycol += 11, row + 1,
        CALL print(calcpos(xcol,ycol)), "{cpi/12}{b}Ordering Provider: ", orders->qual[x].order_dr,
        "{endb}", row + 1, xcol = 40,
        ycol += 11,
        CALL print(calcpos(xcol,ycol)),
        "{cpi/12}{b}All orders below are electronically signed by this provider.",
        "{endb}", row + 1, xcol = 30,
        ycol += 15
       ENDIF
       xcol = 30, ycol += 15,
       CALL print(calcpos(xcol,ycol)),
       "{cpi/12}{b}Procedure: ", orders->qual[x].mnemonic, "{endb}",
       row + 1, xcol = 300,
       CALL print(calcpos(xcol,ycol)),
       "{b}Order ID: ", orders->qual[x].order_id"##########", "{endb}",
       row + 1, xcol = 30, ycol += 15,
       CALL print(calcpos(xcol,ycol)), "{cpi/12}Accession #: ", orders->qual[x].accession,
       row + 1, od_cnt = size(orders->qual[x].d_qual,5)
       FOR (y = 1 TO od_cnt)
         IF ( NOT ((orders->qual[x].d_qual[y].oe_field_meaning_id IN (6006.0, 20.0, 2.0))))
          IF ((orders->qual[x].d_qual[y].print_ind=0))
           orders->qual[x].d_qual[y].print_ind = 1, row + 1, xcol = 30,
           lastodxcol = xcol, ycol += 12,
           CALL print(calcpos(xcol,ycol))
           IF (((size(orders->qual[x].d_qual[y].label_text)+ size(orders->qual[x].d_qual[y].value))
            > 57))
            CALL print(substring(1,57,concat(orders->qual[x].d_qual[y].label_text,": ",orders->qual[x
              ].d_qual[y].value))), "..."
           ELSE
            orders->qual[x].d_qual[y].label_text, ": ", orders->qual[x].d_qual[y].value
           ENDIF
          ENDIF
         ENDIF
       ENDFOR
       FOR (y = 1 TO od_cnt)
         IF ((orders->qual[x].d_qual[y].oe_field_meaning_id IN (2.0)))
          IF ((orders->qual[x].d_qual[y].print_ind=0)
           AND (orders->qual[x].d_qual[y].label_text="Copy To"))
           orders->qual[x].d_qual[y].print_ind = 1, row + 1, xcol = 30,
           lastodxcol = xcol, ycol += 12,
           CALL print(calcpos(xcol,ycol))
           IF (((size(orders->qual[x].d_qual[y].label_text)+ size(orders->qual[x].d_qual[y].value))
            > 57))
            CALL print(substring(1,57,concat(orders->qual[x].d_qual[y].label_text,": ",orders->qual[x
              ].d_qual[y].value))), "..."
           ELSE
            orders->qual[x].d_qual[y].label_text, ": ", orders->qual[x].d_qual[y].value
           ENDIF
          ENDIF
         ENDIF
       ENDFOR
       FOR (y = 1 TO od_cnt)
         IF ((orders->qual[x].d_qual[y].oe_field_meaning_id IN (6006.0)))
          IF ((orders->qual[x].d_qual[y].print_ind=0))
           orders->qual[x].d_qual[y].print_ind = 1, row + 1, xcol = 30,
           lastodxcol = xcol, ycol += 12,
           CALL print(calcpos(xcol,ycol))
           IF (((size(orders->qual[x].d_qual[y].label_text)+ size(orders->qual[x].d_qual[y].value))
            > 100))
            CALL print(substring(1,100,concat(orders->qual[x].d_qual[y].label_text,": ",orders->qual[
              x].d_qual[y].value))), "..."
           ELSE
            orders->qual[x].d_qual[y].label_text, ": ", orders->qual[x].d_qual[y].value
           ENDIF
          ENDIF
         ENDIF
       ENDFOR
       FOR (y = 1 TO od_cnt)
         IF ((orders->qual[x].d_qual[y].oe_field_meaning_id=20))
          IF ((orders->qual[x].d_qual[y].print_ind=0))
           orders->qual[x].d_qual[y].print_ind = 1, row + 1, xcol = 30,
           lastodxcol = xcol, ycol += 12,
           CALL print(calcpos(xcol,ycol))
           IF (((size(orders->qual[x].d_qual[y].label_text)+ size(orders->qual[x].d_qual[y].value))
            > 100))
            CALL print(substring(1,100,concat(orders->qual[x].d_qual[y].label_text,": ",orders->qual[
              x].d_qual[y].value))), "..."
           ELSE
            orders->qual[x].d_qual[y].label_text, ": ", orders->qual[x].d_qual[y].value
           ENDIF
          ENDIF
         ENDIF
       ENDFOR
       IF ((orders->qual[x].comment_ind=1)
        AND (orders->qual[x].com_ln_cnt > 0))
        IF ((orders->qual[x].com_ln_cnt > 10))
         ocnt = 10
        ELSE
         ocnt = orders->qual[x].com_ln_cnt
        ENDIF
        xcol = 30, ycol += 15
        FOR (com_cnt = 1 TO ocnt)
          CALL print(calcpos(xcol,ycol)), "{cpi/14}", orders->qual[x].com_ln_qual[com_cnt].com_line,
          row + 1, ycol += 11
        ENDFOR
        ycol += 12
       ENDIF
      FOOT PAGE
       "{cpi/12}{pos/30/660}", line1, row + 1,
       "{cpi/12}{pos/30/705}{b}", "Printed: ", curdate,
       "  ", curtime, "{endb}",
       row + 1, "{cpi/12}{pos/220/687}", "{b/8}Patient: ",
       "{pos/265/687}", orders->name, "{pos/330/698}",
       "DOB: ", orders->dob, "{pos/330/709}",
       "{b}Age:{endb} ", orders->age, "{pos/420/709}",
       "{b}Gender:{endb} ", orders->sex, row + 1
       IF ((request->order_qual[1].encntr_id != 0))
        "{pos/220/698}", "CMRN #: ", orders->cmrn,
        "{pos/410/698}", "ADM: ", orders->admit_dt,
        row + 1, "{pos/220/709}", "{b/5}MRN # ",
        orders->mrn, "{pos/220/720}", "Attending MD: ",
        orders->attending, row + 1
        IF (temp_cd > 0)
         temp_loc_disp = uar_get_code_display(temp_cd), "{pos/465/720}", "{b}Temp Loc{endb}: ",
         temp_loc_disp, row + 1
        ELSE
         "{pos/465/720}", "{b}Location:{endb} ", orders->location,
         row + 1
        ENDIF
       ELSE
        "{pos/220/720}", "{b}Address:{endb} ", orders->ms_address_lone
        IF (textlen(orders->ms_address_ltwo) != 0)
         ", ", orders->ms_address_ltwo
        ENDIF
        ", ", row + 1, "{pos/220/731}",
        orders->ms_city, ", ", orders->ms_state,
        ", ", orders->ms_zip, row + 1
       ENDIF
       "{pos/490/731}", "Page # ", x,
       row + 1, "{cpi/10}{pos/30/675}{b}", orders->facility,
       row + 1, "{cpi/10}{pos/30/690}{b}", "Order Requisition",
       "{font/8}{cpi/12}{pos/30/731}", curprog
      WITH nocounter, dio = postscript, maxcol = 800,
       maxrow = 750
     ;end select
    ENDIF
  ENDFOR
 ENDIF
#exit_script
END GO
