CREATE PROGRAM bhs_req_adt
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
   1 cmrn = vc
   1 location = vc
   1 facility = vc
   1 nurse_unit = vc
   1 room = vc
   1 bed = vc
   1 isolation = vc
   1 sex = vc
   1 fnbr = vc
   1 fnbr_barcode = vc
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
 RECORD problem(
   1 problem_total = i4
   1 seq[*]
     2 status = vc
     2 beg_effective_dt_tm = vc
     2 text = vc
     2 full_text = vc
 )
 DECLARE ms_subject = vc WITH protect, noconstant("")
 DECLARE vv = i4 WITH protect, noconstant(0)
 DECLARE dclcom = vc WITH protect, noconstant("")
 DECLARE len = i4 WITH protect, noconstant(0)
 DECLARE ms_location_display = vc WITH protect, noconstant("")
 SET order_cnt = 0
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
 DECLARE cmrn_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE fmrn_cd = f8 WITH public, constant(uar_get_code_by("MEANING",319,"MRN"))
 SET code_set = 4
 SET cdf_meaning = "CMRN"
 EXECUTE cpm_get_cd_for_cdf
 SET cmrn_alias_cd = code_value
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
 DECLARE discontinue_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6003,"DISCONTINUE"))
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
 DECLARE snmct_cd = f8 WITH public, constant(uar_get_code_by("MEANING",400,"SNMCT"))
 DECLARE bmc_cd = f8 WITH public, constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE MEDICAL CENTER"))
 DECLARE bmc_psych_cd = f8 WITH public, constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE MEDICAL CENTER INPATIENT PSYCHIATRY"))
 DECLARE bfmc_cd = f8 WITH public, constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE FRANKLIN MEDICAL CENTER"))
 DECLARE bfmc_psych_cd = f8 WITH public, constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE FRANKLIN MEDICAL CENTER INPATIENT PSYCHIATRY"))
 DECLARE bnh_cd = f8 WITH public, constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE NOBLE HOSPITAL"))
 DECLARE bnh_psych_cd = f8 WITH public, constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE NOBLE HOSPITAL INPATIENT PSYCHIATRY"))
 DECLARE bnh_rehab_cd = f8 WITH public, constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE NOBLE REHABILITATION"))
 DECLARE bwh_cd = f8 WITH public, constant(uar_get_code_by("DESCRIPTION",220,"BAYSTATE WING HOSPITAL"
   ))
 DECLARE bwh_psych_cd = f8 WITH public, constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE WING HOSPITAL INPATIENT PSYCHIATRY"))
 DECLARE ml_email_flag = i2 WITH noconstant(0), protect
 DECLARE bmc_flag = i2
 SET bmc_flag = 0
 EXECUTE bhs_check_domain
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
    AND pa.person_alias_type_cd=cmrn_alias_cd
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND pa.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (d2)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd IN (fnbr_cd, fmrn_cd)
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
   person_id = p.person_id, encntr_id = e.encntr_id, orders->name = p.name_full_formatted,
   orders->pat_type = trim(uar_get_code_display(e.encntr_type_cd)), orders->sex =
   uar_get_code_display(p.sex_cd), orders->age = cnvtage(cnvtdate(cnvtdatetimeutc(datetimezone(p
       .birth_dt_tm,p.birth_tz),1)),curdate),
   orders->dob = format(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1),"@SHORTDATE;;Q"),
   orders->admit_dt = format(e.reg_dt_tm,"@SHORTDATETIME;;Q"), orders->dischg_dt = format(e
    .disch_dt_tm,"@SHORTDATETIME;;Q")
   IF (((e.disch_dt_tm=null) OR (e.disch_dt_tm=0)) )
    orders->los = (datetimecmp(cnvtdatetime(sysdate),e.reg_dt_tm)+ 1)
   ELSE
    orders->los = (datetimecmp(e.disch_dt_tm,e.reg_dt_tm)+ 1)
   ENDIF
   temp_cd = e.loc_temp_cd, orders->facility = uar_get_code_description(e.loc_facility_cd)
   IF (e.loc_facility_cd IN (bmc_psych_cd, bmc_cd, bfmc_cd, bfmc_psych_cd, bnh_cd,
   bnh_psych_cd, bnh_rehab_cd, bwh_cd, bwh_psych_cd))
    ml_email_flag = 1, ms_location_display = trim(uar_get_code_display(e.loc_facility_cd))
   ENDIF
   orders->nurse_unit = uar_get_code_display(e.loc_nurse_unit_cd), orders->room =
   uar_get_code_display(e.loc_room_cd), orders->bed = uar_get_code_display(e.loc_bed_cd),
   orders->isolation = uar_get_code_display(e.isolation_cd), orders->location = concat(trim(orders->
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
   IF (pa.person_alias_type_cd=cmrn_cd)
    IF (pa.alias_pool_cd > 0)
     orders->cmrn = cnvtalias(pa.alias,pa.alias_pool_cd)
    ELSE
     orders->cmrn = pa.alias
    ENDIF
   ENDIF
   IF (ea.encntr_alias_type_cd=fmrn_cd)
    IF (ea.alias_pool_cd > 0)
     orders->mrn = cnvtalias(ea.alias,ea.alias_pool_cd)
    ELSE
     orders->mrn = ea.alias
    ENDIF
   ENDIF
   IF (ea.encntr_alias_type_cd=fnbr_cd)
    IF (ea.alias_pool_cd > 0)
     orders->fnbr = cnvtalias(ea.alias,ea.alias_pool_cd), orders->fnbr_barcode = build("*",ea.alias,
      "*")
    ELSE
     orders->fnbr = ea.alias, orders->fnbr_barcode = build("*",ea.alias,"*")
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d1, dontcare = pa,
   outerjoin = d2, dontcare = ea, outerjoin = d3,
   dontcare = epr
 ;end select
 SELECT INTO "nl"
  p.problem_id, problem = build(p.problem_ftdesc,n.source_string)
  FROM problem p,
   nomenclature n
  PLAN (p
   WHERE p.person_id=person_id
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ((p.end_effective_dt_tm >= cnvtdatetime(sysdate)) OR (p.end_effective_dt_tm=null)) )
   JOIN (n
   WHERE (n.nomenclature_id= Outerjoin(p.nomenclature_id))
    AND n.source_vocabulary_cd=snmct_cd
    AND n.source_identifier IN ("454254013", "395346010", "451474015", "420207019", "176116017",
   "443260013", "1228929015", "1209803017", "MDRO", "420206011",
   "1210857011", "395344013", "1229153018", "182291014", "188335012",
   "185113014"))
  ORDER BY p.person_id, cnvtdatetime(p.onset_dt_tm) DESC
  HEAD p.person_id
   cnt = 0
  DETAIL
   IF (((n.source_string > " ") OR (p.problem_ftdesc > " ")) )
    cnt += 1
    IF (mod(cnt,10)=1)
     stat = alterlist(problem->seq,(cnt+ 9))
    ENDIF
    IF (p.nomenclature_id > 0)
     problem->seq[cnt].text = n.source_string
    ELSE
     problem->seq[cnt].text = p.problem_ftdesc
    ENDIF
    problem->seq[cnt].status = uar_get_code_display(p.life_cycle_status_cd), problem->seq[cnt].
    beg_effective_dt_tm = substring(1,14,format(p.beg_effective_dt_tm,"@SHORTDATETIME;;Q")), problem
    ->seq[cnt].full_text = build(problem->seq[cnt].status,": ",problem->seq[cnt].text)
   ENDIF
  FOOT  p.person_id
   problem->problem_total = cnt, stat = alterlist(problem->seq,cnt)
  WITH nocounter
 ;end select
 SET height_cd = 0
 SET weight_cd = 0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=72
    AND cv.display_key IN ("HEIGHT", "WEIGHT")
    AND cv.active_ind=1)
  DETAIL
   CASE (cv.display_key)
    OF "HEIGHT":
     height_cd = cv.code_value
    OF "WEIGHT":
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
    AND o.template_order_flag IN (0, 1, 3))
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_sequence=o.last_action_sequence
    AND ((cnvtlookbehind("30,S") < oa.action_dt_tm
    AND oa.dept_status_cd IN (
   (SELECT DISTINCT
    cve.code_value
    FROM code_value_extension cve
    WHERE cve.code_set=14281
     AND cve.field_name="REQ_PRINT_FLG"
     AND substring(1,1,cve.field_value)="Y"))) OR (cnvtlookbehind("30,S") > oa.action_dt_tm
    AND oa.dept_status_cd IN (
   (SELECT DISTINCT
    cve.code_value
    FROM code_value_extension cve
    WHERE cve.code_set=14281
     AND cve.field_name="REQ_PRINT_FLG"
     AND substring(2,1,cve.field_value)="Y")))) )
   JOIN (pl
   WHERE pl.person_id=oa.action_personnel_id)
   JOIN (pl2
   WHERE pl2.person_id=oa.order_provider_id)
  ORDER BY o.oe_format_id, o.activity_type_cd, o.current_start_dt_tm
  HEAD REPORT
   ord_cnt = 0, orders->order_location = trim(uar_get_code_display(oa.order_locn_cd))
  HEAD o.order_id
   ord_cnt += 1, stat = alterlist(orders->qual,ord_cnt), orders->qual[ord_cnt].status =
   uar_get_code_display(o.order_status_cd),
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
    AND oef.accept_flag IN (0, 1))
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
    orders->qual[d1.seq].d_cnt += 1, dc = orders->qual[d1.seq].d_cnt
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
    SET max_length = 90
    EXECUTE dcp_parse_text value(orders->qual[x].comment), value(max_length)
    SET stat = alterlist(orders->qual[x].com_ln_qual,pt->line_cnt)
    SET orders->qual[x].com_ln_cnt = pt->line_cnt
    FOR (y = 1 TO pt->line_cnt)
      SET orders->qual[x].com_ln_qual[y].com_line = pt->lns[y].line
    ENDFOR
   ENDIF
 ENDFOR
 DECLARE s_primarymnemonic = vc
 IF ((orders->spoolout_ind=1))
  CALL echorecord(orders)
  SET new_timedisp = cnvtstring(curtime3)
  SET tempfile1a = build(concat("cer_temp:dcpreq61","_",new_timedisp),".dat")
  SET temp = fillstring(50," ")
  IF (ml_email_flag=1)
   CALL echo("this is a bmc patient")
   SET bmcreqfile = build(concat("bmcdcpreq","_",new_timedisp),".dat")
   FOR (vv = 1 TO order_cnt)
     SELECT INTO value(bmcreqfile)
      d1.seq
      FROM (dummyt d1  WITH seq = 1)
      PLAN (d1)
      HEAD REPORT
       spaces = fillstring(50," ")
      HEAD PAGE
       col 52, orders->facility, row + 1,
       col 55, "Order Requisition", row + 1,
       col 10, "Patient Information", row + 1,
       col 10, "Patient: ", orders->name,
       col 80, "MRN#:", orders->mrn,
       row + 1
       IF (temp_cd > 0)
        temp_loc_disp = uar_get_code_display(temp_cd), col 10, "Temp Loc: ",
        temp_loc_disp
       ELSE
        col 10, "Location: ", orders->location
       ENDIF
       col 80, "CMRN#: ", orders->cmrn,
       row + 1, col 10, "Attending MD: ",
       orders->attending, col 80, "Acct#: ",
       orders->fnbr, row + 1, col 10,
       "LOS: ", orders->los, " Days",
       col 40, "Admit Date: ", orders->admit_dt,
       col 80, "Patient Type: ", orders->pat_type,
       row + 1, col 10, "Age: ",
       orders->age, col 40, "DOB: ",
       orders->dob, col 80, "Height: ",
       orders->height, row + 1, col 10,
       "Sex: ", orders->sex, col 80,
       "Weight: ", orders->weight, row + 1,
       col 10, "Allergies:"
       IF ((allergy->line_cnt > 0))
        FOR (zz = 1 TO allergy->line_cnt)
          IF (zz > 1)
           row + 1
          ENDIF
          col 30, allergy->line_qual[zz].line
        ENDFOR
       ENDIF
       col 10, "Primary Diagnosis: ", orders->admit_diagnosis,
       row + 1, col 10, "Isolation:",
       row + 1
       FOR (i = 1 TO problem->problem_total)
         IF (i=1)
          tempstring = problem->seq[i].text
         ELSE
          tempstring = concat(tempstring,",  ",problem->seq[i].text)
         ENDIF
       ENDFOR
      DETAIL
       col 10, "Procedure: ", orders->qual[vv].mnemonic,
       s_primarymnemonic = orders->qual[vv].mnemonic, col 80, "Order Status: ",
       orders->qual[vv].status, row + 1, col 10,
       "Order ID: ", orders->qual[vv].order_id, row + 1
       FOR (fsub = 1 TO 31)
         FOR (ww = 1 TO orders->qual[vv].d_cnt)
           IF ((((orders->qual[vv].d_qual[ww].group_seq=fsub)) OR (fsub=31
            AND (orders->qual[vv].d_qual[ww].print_ind=0))) )
            IF ((orders->qual[vv].d_qual[ww].value > " "))
             orders->qual[vv].d_qual[ww].print_ind = 1, tempstring = orders->qual[vv].d_qual[ww].
             value, col 10,
             orders->qual[vv].d_qual[ww].label_text, ": ", col 50,
             tempstring, row + 1
            ENDIF
           ENDIF
         ENDFOR
       ENDFOR
       row + 2, col 10, "Ordering MD: ",
       orders->qual[vv].order_dr, col 80, "Order Date/Time: ",
       orders->qual[vv].signed_dt, row + 1, col 10,
       "Order Type: ", orders->qual[vv].type, row + 1,
       col 10, "Order entered by: ", orders->qual[vv].enter_by,
       col 80, "Printed Date/Time: ", curdate,
       " ", curtime, row + 1,
       col 10, "Order Comments", row + 1
       IF ((orders->qual[vv].com_ln_cnt > 0))
        IF ((orders->qual[vv].com_ln_cnt > 8))
         orders->qual[vv].com_ln_cnt = 8
        ENDIF
        FOR (w = 1 TO orders->qual[vv].com_ln_cnt)
          col 10, orders->qual[vv].com_ln_qual[w].com_line, row + 1
        ENDFOR
       ENDIF
       col 10, "Acct#: ", orders->fnbr_barcode,
       col 80, "BHS_REQ_ADT ", orders->fnbr_barcode,
       row + 1
      WITH nocounter, maxrow = 800, maxcol = 750
     ;end select
     IF (gl_bhs_prod_flag=0
      AND gs_bhs_env_name != "P627")
      CALL echo("not in prod, cancel")
      GO TO exit_script
     ENDIF
     SET ms_subject = concat(trim(ms_location_display,3),"> ",s_primarymnemonic," - ",orders->name)
     SET dclcom = concat("cat ",bmcreqfile,' | tr -d \\r | mail -s "',ms_subject,'" ',
      "CIS.PhysicianOrdersInbox@bhs.org")
     SET len = size(trim(dclcom))
     SET status = 0
     SET stat = dcl(dclcom,len,status)
     SET dclcom = concat("rm ",bmcreqfile)
     SET len = size(trim(dclcom))
     SET status = 0
     SET stat = dcl(dclcom,len,status)
   ENDFOR
  ELSE
   CALL echo("this is not a bmc patient")
   SELECT INTO value(request->printer_name)
    d1.seq
    FROM (dummyt d1  WITH seq = 1)
    PLAN (d1)
    HEAD REPORT
     first_page = "Y", spaces = fillstring(50," "),
     MACRO (line_wrap)
      limit = 0, maxlen = 45, cr = char(13),
      lf = char(10)
      WHILE (tempstring > " "
       AND limit < 1000)
        ii = 0, limit += 1, pos = 0
        WHILE (pos=0)
         ii += 1,
         IF (substring((maxlen - ii),1,tempstring) IN (" ", ","))
          pos = (maxlen - ii)
         ELSEIF (ii=maxlen)
          pos = maxlen
         ENDIF
        ENDWHILE
        printstring = substring(1,pos,tempstring), lfloc = findstring(lf,printstring), crloc =
        findstring(cr,printstring)
        IF (lfloc=0
         AND crloc=0)
         CALL print(calcpos(xcol,xrow)), printstring, row + 1,
         xrow += 12, tempstring = substring((pos+ 1),9999,tempstring)
        ELSE
         IF (((crloc < lfloc
          AND crloc > 0) OR (lfloc=0)) )
          printstring = substring(1,(crloc - 1),printstring),
          CALL print(calcpos(xcol,xrow)), printstring,
          row + 1, xrow += 12, tempstring = substring((crloc+ 2),9999,tempstring)
         ELSEIF (((lfloc < crloc
          AND lfloc > 0) OR (crloc=0)) )
          printstring = substring(1,(lfloc - 1),printstring),
          CALL print(calcpos(xcol,xrow)), printstring,
          row + 1, xrow += 12, tempstring = substring((lfloc+ 2),9999,tempstring)
         ENDIF
         WHILE (substring(1,1,tempstring) IN (" ", cr, lf))
           tempstring = substring(2,9999,tempstring)
         ENDWHILE
        ENDIF
      ENDWHILE
     ENDMACRO
    HEAD PAGE
     "{font/8}", row + 1, xrow = 70,
     xcol = 190,
     CALL print(calcpos(1,xrow)), "{cpi/8}{B}",
     spos = (324 - cnvtint((cnvtint((size(orders->facility)/ 2)) * 12))),
     CALL print(calcpos(spos,xrow)), orders->facility,
     row + 1, xrow += 10, xcol = 250,
     CALL print(calcpos(xcol,xrow)), "{cpi/10}{B}Order Requisition", row + 1,
     xrow += 10, xcol = 44, "{cpi/12}",
     row + 1, row + 1, col 1,
     CALL print(calcpos(xcol,xrow)), "{box/85/1}", xrow += 10,
     xcol = 50,
     CALL print(calcpos(xcol,xrow)), "{b/19}Patient Information",
     xrow += 25, xcol = 50, row + 1,
     col 1,
     CALL print(calcpos(xcol,xrow)), "Patient:",
     xcol = 125,
     CALL print(calcpos(xcol,xrow)), orders->name,
     xcol = 380,
     CALL print(calcpos(xcol,xrow)), "MRN#:",
     xcol = 425,
     CALL print(calcpos(xcol,xrow)), orders->mrn,
     xrow += 14, xcol = 50
     IF (temp_cd > 0)
      temp_loc_disp = uar_get_code_display(temp_cd), row + 1, col 1,
      CALL print(calcpos(xcol,xrow)), "Temp Loc:", xcol = 125,
      CALL print(calcpos(xcol,xrow)), temp_loc_disp
     ELSE
      row + 1, col 1,
      CALL print(calcpos(xcol,xrow)),
      "Location:", xcol = 125,
      CALL print(calcpos(xcol,xrow)),
      orders->location
     ENDIF
     xcol = 380,
     CALL print(calcpos(xcol,xrow)), "CMRN#:",
     xcol = 425,
     CALL print(calcpos(xcol,xrow)), orders->cmrn,
     xrow += 14, xcol = 50, row + 1,
     col 1,
     CALL print(calcpos(xcol,xrow)), "Attending MD:",
     xcol = 125,
     CALL print(calcpos(xcol,xrow)), orders->attending,
     xcol = 380,
     CALL print(calcpos(xcol,xrow)), "Acct#:",
     xcol = 425,
     CALL print(calcpos(xcol,xrow)), orders->fnbr,
     xrow += 20, xcol = 50, row + 1,
     col 1,
     CALL print(calcpos(xcol,xrow)), "LOS:",
     xcol = 80,
     CALL print(calcpos(xcol,xrow)), orders->los,
     " Days", xcol = 220,
     CALL print(calcpos(xcol,xrow)),
     "Admit Date:", xcol = 280,
     CALL print(calcpos(xcol,xrow)),
     orders->admit_dt, xcol = 380,
     CALL print(calcpos(xcol,xrow)),
     "Patient Type:", xcol = 450,
     CALL print(calcpos(xcol,xrow)),
     orders->pat_type, xrow += 20, xcol = 50,
     row + 1, col 1,
     CALL print(calcpos(xcol,xrow)),
     "Age:", xcol = 80,
     CALL print(calcpos(xcol,xrow)),
     orders->age, xcol = 220,
     CALL print(calcpos(xcol,xrow)),
     "DOB:", xcol = 250,
     CALL print(calcpos(xcol,xrow)),
     orders->dob, xcol = 380,
     CALL print(calcpos(xcol,xrow)),
     "Height:", xcol = 425,
     CALL print(calcpos(xcol,xrow)),
     orders->height, xrow += 14, xcol = 50,
     row + 1, col 1,
     CALL print(calcpos(xcol,xrow)),
     "Sex:", xcol = 100,
     CALL print(calcpos(xcol,xrow)),
     orders->sex, xcol = 380,
     CALL print(calcpos(xcol,xrow)),
     "Weight:", xcol = 425,
     CALL print(calcpos(xcol,xrow)),
     orders->weight, xrow += 20, xcol = 50,
     row + 1, col 1,
     CALL print(calcpos(xcol,xrow)),
     "Allergies:"
     IF ((allergy->line_cnt > 0))
      FOR (zz = 1 TO allergy->line_cnt)
        xcol = 125
        IF (zz > 1)
         xrow += 12
        ENDIF
        CALL print(calcpos(xcol,xrow)), allergy->line_qual[zz].line, row + 1
      ENDFOR
     ENDIF
     xrow += 14, xcol = 50, row + 1,
     col 1,
     CALL print(calcpos(xcol,xrow)), "Primary Diagnosis:",
     xcol = 145,
     CALL print(calcpos(xcol,xrow)), orders->admit_diagnosis,
     xrow += 14, xcol = 50, row + 1,
     col 1,
     CALL print(calcpos(xcol,xrow)), "Isolation:",
     xcol = 100
     FOR (i = 1 TO problem->problem_total)
       IF (i=1)
        tempstring = problem->seq[i].text
       ELSE
        tempstring = concat(tempstring,",  ",problem->seq[i].text)
       ENDIF
     ENDFOR
     line_wrap
    DETAIL
     FOR (vv = 1 TO value(order_cnt))
       IF (first_page="N")
        BREAK
       ENDIF
       first_page = "N", xrow += 25, xcol = 50,
       row + 1,
       CALL print(calcpos(xcol,xrow)), "Procedure: ",
       xcol = 110,
       CALL print(calcpos(xcol,xrow)), orders->qual[vv].mnemonic,
       xcol = 380,
       CALL print(calcpos(xcol,xrow)), "Order Status:",
       xcol = 460,
       CALL print(calcpos(xcol,xrow)), orders->qual[vv].status,
       xrow += 14, xcol = 50, row + 1,
       CALL print(calcpos(xcol,xrow)), "Order ID:", xcol = 90,
       CALL print(calcpos(xcol,xrow)), orders->qual[vv].order_id, xcol = 50,
       xrow += 17, row + 1
       FOR (fsub = 1 TO 31)
         FOR (ww = 1 TO orders->qual[vv].d_cnt)
           IF ((((orders->qual[vv].d_qual[ww].group_seq=fsub)) OR (fsub=31
            AND (orders->qual[vv].d_qual[ww].print_ind=0))) )
            IF ((orders->qual[vv].d_qual[ww].value > " "))
             orders->qual[vv].d_qual[ww].print_ind = 1, xcol = 50,
             CALL print(calcpos(xcol,xrow)),
             orders->qual[vv].d_qual[ww].label_text, ":", tempstring = orders->qual[vv].d_qual[ww].
             value,
             xcol = 330, line_wrap
            ENDIF
           ENDIF
         ENDFOR
       ENDFOR
       xrow = 560, xcol = 50, row + 1,
       CALL print(calcpos(xcol,xrow)), "Ordering MD:", xcol = 134,
       CALL print(calcpos(xcol,xrow)), orders->qual[vv].order_dr, xcol = 350,
       CALL print(calcpos(xcol,xrow)), "Order Date/Time:", xcol = 450,
       CALL print(calcpos(xcol,xrow)), orders->qual[vv].signed_dt, xrow += 12,
       xcol = 50, row + 1,
       CALL print(calcpos(xcol,xrow)),
       "Order Type:", xcol = 134,
       CALL print(calcpos(xcol,xrow)),
       orders->qual[vv].type, xrow += 12, xcol = 50,
       row + 1,
       CALL print(calcpos(xcol,xrow)), "Order entered by:",
       xcol = 134,
       CALL print(calcpos(xcol,xrow)), orders->qual[vv].enter_by,
       xcol = 350,
       CALL print(calcpos(xcol,xrow)), "Printed Date/Time:",
       xcol = 450,
       CALL print(calcpos(xcol,xrow)), curdate,
       " ", curtime, xrow += 15,
       xcol = 44, row + 1,
       CALL print(calcpos(xcol,xrow)),
       "{box/80/1}", xrow += 10, xcol = 50,
       CALL print(calcpos(xcol,xrow)), "{b/14}Order Comments", xrow += 10
       IF ((orders->qual[vv].com_ln_cnt > 0))
        IF ((orders->qual[vv].com_ln_cnt > 8))
         orders->qual[vv].com_ln_cnt = 8
        ENDIF
        FOR (w = 1 TO orders->qual[vv].com_ln_cnt)
          xrow += 15, xcol = 70, row + 1,
          CALL print(calcpos(xcol,xrow)), orders->qual[vv].com_ln_qual[w].com_line
        ENDFOR
       ENDIF
       xrow += 20, xcol = 50,
       CALL print(calcpos(xcol,xrow)),
       "{b/4}Acct#: ", "{BCR/100}{FR/0}{CPI/6}{F/28/2}", orders->fnbr_barcode,
       row + 1, "{f/8}{cpi/12}", row + 1,
       xrow += 10, xcol = 370,
       CALL print(calcpos(xcol,xrow)),
       "{cpi/14}BHS_REQ_ADT ", orders->fnbr_barcode, row + 1
     ENDFOR
    WITH nocounter, maxrow = 800, maxcol = 750,
     dio = 08
   ;end select
  ENDIF
 ENDIF
#exit_script
 FREE RECORD orders
 FREE RECORD request
 FREE RECORD allergy
 FREE RECORD diagnosis
 FREE RECORD pt
 FREE RECORD problem
END GO
