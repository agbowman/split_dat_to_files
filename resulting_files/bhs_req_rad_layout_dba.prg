CREATE PROGRAM bhs_req_rad_layout:dba
 PROMPT
  "program_name" = ""
  WITH program_name
 EXECUTE bhs_check_domain
 SET trace = rdbdebug
 SET trace = rdbbind
 SET dm2_debug_flag = 10
 DECLARE program1 = vc WITH public
 SET program1 =  $PROGRAM_NAME
 CALL echo(build("call_program = ",program1))
 CALL echorecord(request)
 RECORD orders(
   1 name = vc
   1 s_addr_line1 = vc
   1 s_addr_line2 = vc
   1 s_addr_line3 = vc
   1 pat_type = vc
   1 s_home_phone = vc
   1 age = vc
   1 dob = vc
   1 mrn = vc
   1 cmrn = vc
   1 trauma = vc
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
   1 brader_display = vc
   1 braden_score = vc
   1 braden_dt_tm = vc
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
     2 f_catalog_cd = f8
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
     2 s_consult_phys = vc
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
 RECORD problem(
   1 problem_total = i4
   1 seq[*]
     2 status = vc
     2 beg_effective_dt_tm = vc
     2 text = vc
     2 full_text = vc
 )
 DECLARE found_irradiation = i4 WITH noconstant(0), protect
 DECLARE found_cmv_neg = i4 WITH noconstant(0), protect
 DECLARE bold_yes = i4 WITH noconstant(0), protect
 DECLARE los_days = vc WITH protect
 DECLARE continued = vc WITH protect
 DECLARE value = vc WITH protect
 DECLARE detail_label = vc WITH protect
 DECLARE send_mail = i2 WITH noconstant(0), protect
 DECLARE mf_homephone = f8 WITH constant(uar_get_code_by("DISPLAYKEY",43,"HOME")), protect
 SET cr2 = char(10)
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
 DECLARE other_alias_cd = f8 WITH public, constant(uar_get_code_by("meaning",4,"OTHER"))
 DECLARE fmrn_cd = f8 WITH public, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE trauma_cd = f8 WITH public, constant(uar_get_code_by("displaykey",263,"TRAUMANUMBER"))
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
 DECLARE tempstring = vc WITH public
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
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
 DECLARE ms_filename = vc WITH protect, noconstant(" ")
 DECLARE ms_filename_in = vc WITH protect, noconstant(" ")
 DECLARE dclcom = vc WITH protect, noconstant(" ")
 DECLARE subject = vc WITH protect, noconstant(" ")
 DECLARE mf_icd9_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,"ICD9CODE"))
 DECLARE mf_activeencntrorder = f8 WITH constant(uar_get_code_by("DISPLAYKEY",16449,
   "ACTIVEENCOUNTERORDER")), protect
 DECLARE mf_addr_home_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"HOME"))
 DECLARE diacnt = i4 WITH noconstant(0), protect
 DECLARE diagx = i4 WITH noconstant(0), protect
 DECLARE mf_tbed1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "THERAPEUTICBEDCLINITRON"))
 DECLARE mf_tbed2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "THERAPEUTICBEDCLINITRONRITEHITE"))
 DECLARE mf_tbed3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "THERAPEUTICBEDMAGNUMTHERAPEUTIC"))
 DECLARE mf_tbed4_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "THERAPEUTICBEDMAGNUMECLIPSEULTRA"))
 DECLARE mf_tbed5_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "THERAPEUTICBEDROTOREST"))
 DECLARE mf_tbed6_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "THERAPEUTICBEDSIZEWISEMIGHTYAIR"))
 DECLARE mf_tbed7_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "THERAPEUTICBEDSIZEWISEBIGTURN"))
 DECLARE mf_tbed8_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "THERAPEUTICBEDSYNERGYAIRELITE"))
 DECLARE mf_tbed9_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "THERAPEUTICBEDTOTALCARESPO2RT"))
 DECLARE mf_tbed10_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "THERAPEUTICBEDTRIFLEX"))
 DECLARE mf_tbed11_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "THERAPEUTICBEDTCBARIATRICPLUSAIR"))
 DECLARE mf_tbed12_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "THERAPEUTICBEDTCBARIATRICPLUSFOAM"))
 DECLARE mf_tbed13_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "THERAPEUTICBEDTCBARIATRICPLUSPULM"))
 DECLARE mf_consulting_md = f8 WITH constant(uar_get_code_by("DISPLAYKEY",16449,
   "CONSULTING PHYSICIAN")), protect
 DECLARE mf_ptunderinvestcovid = f8 WITH constant(uar_get_code_by("DISPLAYKEY",16449,
   "PATIENTUNDERINVESTIGATIONFORCOVID")), protect
 CALL echo("patient information")
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
    AND pa.person_alias_type_cd IN (cmrn_alias_cd, other_alias_cd)
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
   uar_get_code_display(p.sex_cd), orders->age = cnvtage(cnvtdate(p.birth_dt_tm),curdate),
   orders->dob = format(p.birth_dt_tm,"@SHORTDATE"), orders->admit_dt = format(e.reg_dt_tm,
    "@SHORTDATETIME"), orders->dischg_dt = format(e.disch_dt_tm,"@SHORTDATETIME")
   IF (((e.disch_dt_tm=null) OR (e.disch_dt_tm=0)) )
    orders->los = (datetimecmp(cnvtdatetime(sysdate),e.reg_dt_tm)+ 1)
   ELSE
    orders->los = (datetimecmp(e.disch_dt_tm,e.reg_dt_tm)+ 1)
   ENDIF
   temp_cd = e.loc_temp_cd, orders->facility = uar_get_code_description(e.loc_facility_cd), orders->
   nurse_unit = uar_get_code_display(e.loc_nurse_unit_cd),
   orders->room = uar_get_code_display(e.loc_room_cd), orders->bed = uar_get_code_display(e
    .loc_bed_cd), orders->isolation = uar_get_code_display(e.isolation_cd),
   orders->location = concat(trim(orders->nurse_unit),"/",trim(orders->room),"/",trim(orders->bed)),
   orders->admit_diagnosis = e.reason_for_visit, orders->med_service = uar_get_code_display(e
    .med_service_cd)
  HEAD epr.encntr_prsnl_r_cd
   IF (epr.encntr_prsnl_r_cd=admit_doc_cd
    AND e.encntr_id > 0)
    orders->admitting = pl.name_full_formatted
   ELSEIF (epr.encntr_prsnl_r_cd=attend_doc_cd
    AND e.encntr_id > 0)
    orders->attending = pl.name_full_formatted
   ELSEIF (e.encntr_id=0)
    orders->attending = "N/A", orders->admitting = "N/A"
   ENDIF
  DETAIL
   IF (pa.person_alias_type_cd=cmrn_cd)
    orders->cmrn = format(pa.alias,"#######;p0")
   ENDIF
   IF (pa.person_alias_type_cd=other_alias_cd
    AND pa.alias_pool_cd=trauma_cd)
    orders->trauma = format(pa.alias,"#######;p0")
   ENDIF
   IF (ea.encntr_alias_type_cd=fmrn_cd
    AND e.encntr_id > 0)
    orders->mrn = format(ea.alias,"#######;p0")
   ELSEIF (e.encntr_id=0)
    orders->mrn = "N/A"
   ENDIF
   IF (ea.encntr_alias_type_cd=fnbr_cd
    AND e.encntr_id > 0)
    IF (ea.alias_pool_cd > 0)
     orders->fnbr = cnvtalias(ea.alias,ea.alias_pool_cd), orders->fnbr_barcode = build("*",ea.alias,
      "*")
    ELSE
     orders->fnbr = ea.alias, orders->fnbr_barcode = build("*",ea.alias,"*")
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
   orders->s_addr_line1 = trim(ad.street_addr)
   IF (textlen(trim(ad.street_addr2))=0)
    orders->s_addr_line2 = concat(trim(ad.city),", ",trim(uar_get_code_display(ad.state_cd))," ",trim
     (ad.zipcode))
   ELSE
    orders->s_addr_line2 = trim(ad.street_addr2), orders->s_addr_line3 = concat(trim(ad.city),", ",
     trim(uar_get_code_display(ad.state_cd))," ",trim(ad.zipcode))
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM phone ph
  PLAN (ph
   WHERE ph.parent_entity_name="PERSON"
    AND (ph.parent_entity_id=request->person_id)
    AND ph.phone_type_cd=mf_homephone
    AND ph.active_ind=1
    AND ph.end_effective_dt_tm > sysdate
    AND ph.phone_type_seq=1)
  DETAIL
   orders->s_home_phone = ph.phone_num
  WITH nocounter
 ;end select
 CALL echo("problems")
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
    beg_effective_dt_tm = substring(1,14,format(p.beg_effective_dt_tm,"@SHORTDATETIME")), problem->
    seq[cnt].full_text = build(problem->seq[cnt].status,": ",problem->seq[cnt].text)
   ENDIF
  FOOT  p.person_id
   problem->problem_total = cnt, stat = alterlist(problem->seq,cnt)
  WITH nocounter
 ;end select
 CALL echo("clinical_event info")
 SET height_cd = 0
 SET weight_cd = 0
 SET braden_cd = 0
 SET braden_ped_cd = 0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=72
    AND cv.display_key IN ("HEIGHT", "WEIGHT", "BRADENSCORE", "BRADENQSCOREPEDIATRICS")
    AND cv.active_ind=1)
  DETAIL
   CASE (cv.display_key)
    OF "HEIGHT":
     height_cd = cv.code_value
    OF "WEIGHT":
     weight_cd = cv.code_value
    OF "BRADENSCORE":
     braden_cd = cv.code_value
    OF "BRADENQSCOREPEDIATRICS":
     braden_ped_cd = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event c
  PLAN (c
   WHERE c.person_id=person_id
    AND c.encntr_id=encntr_id
    AND c.event_cd IN (height_cd, weight_cd, braden_cd, braden_ped_cd)
    AND c.view_level=1
    AND c.publish_flag=1
    AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
    AND c.result_status_cd != inerror_cd)
  ORDER BY c.event_end_dt_tm
  DETAIL
   IF (c.event_cd=height_cd)
    orders->height = concat(trim(c.event_tag)," ",trim(uar_get_code_display(c.result_units_cd))),
    orders->height_dt_tm = format(c.updt_dt_tm,"@SHORTDATETIME")
   ELSEIF (c.event_cd=weight_cd)
    orders->weight = concat(trim(c.event_tag)," ",trim(uar_get_code_display(c.result_units_cd))),
    orders->weight_dt_tm = format(c.updt_dt_tm,"@SHORTDATETIME")
   ELSEIF (c.event_cd=braden_cd)
    orders->braden_score = concat(trim(uar_get_code_display(c.event_cd)),": ",trim(c.event_tag)," ",
     trim(uar_get_code_display(c.result_units_cd))), orders->braden_dt_tm = format(c.updt_dt_tm,
     "@SHORTDATETIME")
   ELSEIF (c.event_cd=braden_ped_cd)
    orders->braden_score = concat(trim(uar_get_code_display(c.event_cd)),": ",trim(c.event_tag)," ",
     trim(uar_get_code_display(c.result_units_cd)))
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("mnemonic on pharm orders")
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
 CALL echo("order level info")
 SET ord_cnt = 0
 SELECT INTO "nl:"
  FROM orders o,
   order_action oa,
   prsnl pl,
   prsnl pl2,
   (dummyt d1  WITH seq = value(size(request->order_qual,5)))
  PLAN (d1)
   JOIN (o
   WHERE (o.order_id=request->order_qual[d1.seq].order_id)
    AND o.template_order_flag IN (0, 1, 2))
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_sequence=o.last_action_sequence
    AND ((cnvtlookbehind("30,s") <= oa.action_dt_tm
    AND oa.dept_status_cd IN (
   (SELECT DISTINCT
    cve.code_value
    FROM code_value_extension cve
    WHERE cve.code_set=14281
     AND cve.field_name="REQ_PRINT_FLG"
     AND substring(7,1,cve.field_value)="Y"))) OR (cnvtlookbehind("30,s") > oa.action_dt_tm
    AND oa.dept_status_cd > 0)) )
   JOIN (pl
   WHERE pl.person_id=oa.action_personnel_id)
   JOIN (pl2
   WHERE pl2.person_id=oa.order_provider_id)
  ORDER BY o.oe_format_id, o.activity_type_cd, o.current_start_dt_tm
  HEAD REPORT
   orders->order_location = trim(uar_get_code_display(oa.order_locn_cd))
  HEAD o.order_id
   ord_cnt += 1, stat = alterlist(orders->qual,ord_cnt), orders->qual[ord_cnt].status =
   uar_get_code_display(o.order_status_cd),
   orders->qual[ord_cnt].s_fut_facilty = uar_get_code_display(o.future_location_facility_cd), orders
   ->qual[ord_cnt].s_fut_unit = uar_get_code_display(o.future_location_nurse_unit_cd), orders->qual[
   ord_cnt].f_fut_facilty_cd = o.future_location_facility_cd,
   orders->qual[ord_cnt].f_fut_unit_cd = o.future_location_nurse_unit_cd, orders->qual[ord_cnt].
   catalog = uar_get_code_display(o.catalog_type_cd), orders->qual[ord_cnt].catalog_type_cd = o
   .catalog_type_cd,
   orders->qual[ord_cnt].f_catalog_cd = o.catalog_cd, orders->qual[ord_cnt].activity =
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
    .order_dt_tm,"@SHORTDATETIME"), orders->qual[ord_cnt].signed_dt = format(o.orig_order_dt_tm,
    "@SHORTDATETIME"),
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
    orders->spoolout_ind = 0,
    CALL echo("#####>No Print<#####")
   ELSE
    orders->spoolout_ind = 1,
    CALL echo("#####>Print<#####")
   ENDIF
   order_cnt = ord_cnt
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("#####>No Print<#####")
 ENDIF
 CALL echo("order detail info")
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
    AND od.oe_field_id IN (mf_icd9_cd, mf_consulting_md, mf_ptunderinvestcovid))) )
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
   IF (od.oe_field_meaning="CONSULTDOC")
    orders->qual[d1.seq].s_consult_phys = od.oe_field_display_value
   ENDIF
  HEAD od.action_sequence
   IF (act_seq != od.action_sequence)
    odflag = 0
   ENDIF
  DETAIL
   temp_len = 0, temp_string1 = fillstring(100,""), temp_string2 = fillstring(100,""),
   temp_string3 = fillstring(100,"")
   IF (odflag=1)
    orders->qual[d1.seq].d_cnt += 1, dc = orders->qual[d1.seq].d_cnt
    IF (dc > size(orders->qual[d1.seq].d_qual,5))
     stat = alterlist(orders->qual[d1.seq].d_qual,(dc+ 5))
    ENDIF
    IF (od.oe_field_meaning="ICD9")
     diacnt += 1, orders->qual[d1.seq].d_qual[dc].label_text = build("Diagnosis #",diacnt)
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
 SELECT INTO "nl:"
  FROM nomenclature n,
   (dummyt d1  WITH seq = value(size(orders->qual,5))),
   (dummyt d2  WITH seq = 1)
  PLAN (d1
   WHERE maxrec(d2,size(orders->qual[d1.seq].d_qual,5)))
   JOIN (d2)
   JOIN (n
   WHERE (n.nomenclature_id=orders->qual[d1.seq].d_qual[d2.seq].field_value)
    AND (orders->qual[d1.seq].d_qual[d2.seq].oe_field_meaning_id=20))
  DETAIL
   orders->qual[d1.seq].d_qual[d2.seq].value = concat(" (",trim(n.source_identifier),")",trim(n
     .source_string))
  FOOT REPORT
   null
  WITH nocounter
 ;end select
 CALL echo("build order details")
 FOR (x = 1 TO order_cnt)
   IF ((orders->qual[x].clin_line_ind=1))
    SET started_build_ind = 0
    FOR (fsub = 1 TO 31)
      FOR (xx = 1 TO orders->qual[x].d_cnt)
        IF ((((orders->qual[x].d_qual[xx].group_seq=fsub)) OR (fsub=31))
         AND (orders->qual[x].d_qual[xx].print_ind=0))
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
 CALL echo("line wrap order details")
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
 SELECT INTO "nl:"
  FROM diagnosis d
  PLAN (d
   WHERE (d.encntr_id=request->order_qual[1].encntr_id)
    AND cnvtdatetime(sysdate) BETWEEN d.beg_effective_dt_tm AND d.end_effective_dt_tm
    AND d.active_ind=1)
  HEAD REPORT
   initial = 1
  DETAIL
   IF (initial=1)
    orders->admit_diagnosis = d.diagnosis_display, initial = 0
   ELSE
    orders->admit_diagnosis = concat(orders->admit_diagnosis,", ",d.diagnosis_display)
   ENDIF
  WITH nocounter
 ;end select
 IF ((orders->spoolout_ind=1))
  SET new_timedisp = cnvtstring(curtime3)
  SET tempfile1a = build(concat("cer_temp:dcpreq61","_",new_timedisp),".dat")
  SET temp = fillstring(50," ")
  SET ms_filename = build2("bhs_req_04_",trim(new_timedisp),".dat")
  CALL echo(build2("file name: ",ms_filename))
  CALL echo("creating file")
  SELECT INTO value(ms_filename)
   FROM (dummyt d1  WITH seq = value(size(orders->qual,5)))
   PLAN (d1
    WHERE (orders->qual[d1.seq].f_catalog_cd IN (mf_tbed1_cd, mf_tbed2_cd, mf_tbed3_cd, mf_tbed4_cd,
    mf_tbed5_cd,
    mf_tbed6_cd, mf_tbed7_cd, mf_tbed8_cd, mf_tbed9_cd, mf_tbed10_cd,
    mf_tbed11_cd, mf_tbed12_cd, mf_tbed13_cd)))
   HEAD REPORT
    first_page = "Y", spaces = fillstring(50," "), footer_start_pos = 0,
    temp_s = fillstring(1000,""), temp_s2 = fillstring(45,"")
   HEAD PAGE
    row + 1, col 45, orders->facility,
    row + 1, col 48, "Order Requisition",
    row + 1, col 1, "Patient Information",
    row + 1, col 1, "Patient: ",
    orders->name, row + 1, col 45,
    "MRN#:", orders->mrn
    IF (temp_cd > 0)
     temp_loc_disp = uar_get_code_display(temp_cd), row + 1, col 1,
     "Temp Loc: ", temp_loc_disp
    ELSE
     row + 1, col 1, "Location: ",
     orders->location
    ENDIF
    row + 1, col 1, "Location: ",
    orders->location, col 45, "Trauma #: ",
    orders->trauma, row + 1, col 1,
    "Attending MD: ", orders->attending, col 45,
    "Acct#: ", orders->fnbr, row + 1,
    col 1, "Admit Date: ", orders->admit_dt,
    col 45, "Patient Type: ", orders->pat_type,
    row + 1, col 1, "Age: ",
    orders->age, col 45, "DOB: ",
    orders->dob, col 65, "Height: ",
    orders->height, row + 1, col 1,
    "Sex: ", orders->sex, col 45,
    "Weight: ", orders->weight, row + 1,
    col 1, orders->braden_score, row + 1,
    col 1, "Order Details:"
   DETAIL
    row + 1, col 1, "Procedure: ",
    orders->qual[d1.seq].mnemonic, row + 1, col 1,
    "Order Status: ", orders->qual[d1.seq].status, row + 1,
    col 1, "Order ID: ", orders->qual[d1.seq].order_id
    FOR (fsub = 1 TO 31)
      FOR (ww = 1 TO orders->qual[d1.seq].d_cnt)
        IF ((((orders->qual[d1.seq].d_qual[ww].group_seq=fsub)) OR (fsub=31
         AND (orders->qual[d1.seq].d_qual[ww].print_ind=0))) )
         IF ((orders->qual[d1.seq].d_qual[ww].value > " "))
          orders->qual[d1.seq].d_qual[ww].print_ind = 1, tempstring = orders->qual[d1.seq].d_qual[ww]
          .value, row + 1,
          col 2, orders->qual[d1.seq].d_qual[ww].label_text, ":"
          IF (textlen(tempstring) > 50)
           ms_tmp = substring(1,50,tempstring), col 45, ms_tmp,
           ms_tmp = substring(50,textlen(tempstring),tempstring), row + 1, ms_tmp
          ELSE
           col 45, tempstring
          ENDIF
          footer_idx = d1.seq
         ENDIF
        ENDIF
      ENDFOR
    ENDFOR
   FOOT PAGE
    row + 1, col 1, "Ordering MD: ",
    orders->qual[footer_idx].order_dr, col 45, "Order Date/Time: ",
    orders->qual[footer_idx].signed_dt, row + 1, col 1,
    "Order Entered by: ", orders->qual[footer_idx].enter_by, col 45,
    "Printed Date/Time: ", curdate, " ",
    curtime, row + 1, col 1,
    "BHS_REQ_04", row + 4, col 1,
    "DELIVERY:", row + 2, col 1,
    "Materials Tech: ________________________________", row + 2, col 1,
    "Date: ___________________  Time: _______________", row + 2, col 1,
    "Customer Signature: ____________________________", row + 2, col 1,
    "Serial Number: _________________________________", row + 4, col 1,
    "PICK UP:", row + 2, col 1,
    "Materials Tech: ________________________________", row + 2, col 1,
    "Date: ___________________  Time: _______________", row + 2, col 1,
    "Customer Signature: ____________________________", row + 2, col 1,
    "Serial Number: _________________________________"
   WITH nocounter, format, format = variable
  ;end select
  IF (curqual > 0)
   CALL echo(build2(curdomain,";;"))
   IF (gl_bhs_prod_flag=0)
    CALL echo("not in prod, cancel")
    GO TO exit_script
   ENDIF
   CALL echo("emailing file")
   SET subject = concat(orders->name)
   SET dclcom = concat('mail -s "',subject,'" ',
    "MaterialServices.MaterialServicesBedRequests@baystatehealth.org < ",ms_filename)
   SET len = size(trim(dclcom))
   SET status = 0
   SET stat = dcl(dclcom,len,status)
   CALL echo("deleting email file")
   IF (findfile(ms_filename)=0)
    IF (findfile(concat("bhscust:",ms_filename))=1)
     SET ms_filename = concat("bhscust:",ms_filename)
    ELSEIF (findfile(concat("ccluserdir:",ms_filename))=1)
     SET ms_filename = concat("ccluserdir:",ms_filename)
    ENDIF
   ENDIF
   SET stat = remove(ms_filename)
   IF (((stat=0) OR (findfile(ms_filename)=1)) )
    CALL echo("Unable to delete email file")
   ELSE
    CALL echo("Email File Deleted")
   ENDIF
  ENDIF
  SET new_timedisp = cnvtstring(curtime3)
  SET tempfile1a = build(concat("cer_temp:dcpreq61","_",new_timedisp),".dat")
  SET temp = fillstring(50," ")
  CALL echo(build2("printing to: ",request->printer_name))
  EXECUTE reportrtl
  DECLARE _createfonts(dummy) = null WITH protect
  DECLARE _createpens(dummy) = null WITH protect
  DECLARE pagebreak(dummy) = null WITH protect
  DECLARE initializereport(dummy) = null WITH protect
  DECLARE _hreport = h WITH noconstant(0), protect
  DECLARE _yoffset = f8 WITH noconstant(0.0), protect
  DECLARE _xoffset = f8 WITH noconstant(0.0), protect
  DECLARE rpt_render = i2 WITH constant(0), protect
  DECLARE _crlf = vc WITH constant(concat(char(13),char(10))), protect
  DECLARE rpt_calcheight = i2 WITH constant(1), protect
  DECLARE _yshift = f8 WITH noconstant(0.0), protect
  DECLARE _xshift = f8 WITH noconstant(0.0), protect
  DECLARE _sendto = vc WITH noconstant(""), protect
  DECLARE _rpterr = i2 WITH noconstant(0), protect
  DECLARE _rptstat = i2 WITH noconstant(0), protect
  DECLARE _oldfont = i4 WITH noconstant(0), protect
  DECLARE _oldpen = i4 WITH noconstant(0), protect
  DECLARE _dummyfont = i4 WITH noconstant(0), protect
  DECLARE _dummypen = i4 WITH noconstant(0), protect
  DECLARE _fdrawheight = f8 WITH noconstant(0.0), protect
  DECLARE _rptpage = h WITH noconstant(0), protect
  DECLARE _diotype = i2 WITH noconstant(8), protect
  DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
  DECLARE _remsex = i4 WITH noconstant(1), protect
  DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
  DECLARE _bcontprint_header2 = i2 WITH noconstant(0), protect
  DECLARE _remallergy = i4 WITH noconstant(1), protect
  DECLARE _remprimary_diag = i4 WITH noconstant(1), protect
  DECLARE _bcontprint_header = i2 WITH noconstant(0), protect
  DECLARE _remdetail_value = i4 WITH noconstant(1), protect
  DECLARE _remdetail_label = i4 WITH noconstant(1), protect
  DECLARE _bcontorder_details = i2 WITH noconstant(0), protect
  DECLARE _remorder_comment = i4 WITH noconstant(1), protect
  DECLARE _bcontorder_comments = i2 WITH noconstant(0), protect
  DECLARE _helvetica10b0 = i4 WITH noconstant(0), protect
  DECLARE _helvetica14b0 = i4 WITH noconstant(0), protect
  DECLARE _helvetica12b0 = i4 WITH noconstant(0), protect
  DECLARE _times8b0 = i4 WITH noconstant(0), protect
  DECLARE _times8i0 = i4 WITH noconstant(0), protect
  DECLARE _times12bi0 = i4 WITH noconstant(0), protect
  DECLARE _times100 = i4 WITH noconstant(0), protect
  DECLARE _helvetica60 = i4 WITH noconstant(0), protect
  DECLARE _helvetica120 = i4 WITH noconstant(0), protect
  DECLARE _helvetica100 = i4 WITH noconstant(0), protect
  DECLARE _times12b0 = i4 WITH noconstant(0), protect
  DECLARE _pen10s0c0 = i4 WITH noconstant(0), protect
  DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
  SUBROUTINE pagebreak(dummy)
    SET _rptpage = uar_rptendpage(_hreport)
    SET _rptpage = uar_rptstartpage(_hreport)
    SET _yoffset = rptreport->m_margintop
  END ;Subroutine
  SUBROUTINE (finalizereport(ssendreport=vc) =null WITH protect)
    SET _rptpage = uar_rptendpage(_hreport)
    SET _rptstat = uar_rptendreport(_hreport)
    DECLARE sfilename = vc WITH noconstant(trim(ssendreport)), private
    DECLARE bprint = i2 WITH noconstant(0), private
    IF (textlen(sfilename) > 0)
     SET bprint = checkqueue(sfilename)
     IF (bprint)
      EXECUTE cpm_create_file_name "RPT", "PS"
      SET sfilename = cpm_cfn_info->file_name_path
     ENDIF
    ENDIF
    SET _rptstat = uar_rptprinttofile(_hreport,nullterm(sfilename))
    IF (bprint)
     SET spool value(sfilename) value(ssendreport) WITH deleted, dio = value(_diotype)
    ENDIF
    DECLARE _errorfound = i2 WITH noconstant(0), protect
    DECLARE _errcnt = i2 WITH noconstant(0), protect
    SET _errorfound = uar_rptfirsterror(_hreport,rpterror)
    WHILE (_errorfound=rpt_errorfound
     AND _errcnt < 512)
      SET _errcnt += 1
      SET stat = alterlist(rpterrors->errors,_errcnt)
      SET rpterrors->errors[_errcnt].m_severity = rpterror->m_severity
      SET rpterrors->errors[_errcnt].m_text = rpterror->m_text
      SET rpterrors->errors[_errcnt].m_source = rpterror->m_source
      SET _errorfound = uar_rptnexterror(_hreport,rpterror)
    ENDWHILE
    SET _rptstat = uar_rptdestroyreport(_hreport)
  END ;Subroutine
  SUBROUTINE (transfuse_header(ncalc=i2) =f8 WITH protect)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = transfuse_headerabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE (transfuse_headerabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
    DECLARE sectionheight = f8 WITH noconstant(2.000000), private
    IF ( NOT (program1 IN (cnvtupper("BHS_REQ_BBT"))))
     RETURN(0.0)
    ENDIF
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 20
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 1.709)
     SET rptsd->m_x = (offsetx+ 0.313)
     SET rptsd->m_width = 7.000
     SET rptsd->m_height = 0.292
     SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     IF ((request->order_qual[1].encntr_id > 0))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Order Requisition",char(0)))
     ENDIF
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 1.688)
     SET rptsd->m_x = (offsetx+ 0.250)
     SET rptsd->m_width = 7.000
     SET rptsd->m_height = 0.251
     IF ((request->order_qual[1].encntr_id=0))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Baystate Health Order Requisition",
        char(0)))
     ENDIF
     SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.250),(offsety+ 0.938),3.751,0.625,
      rpt_nofill,rpt_white)
     SET _rptstat = uar_rptrect(_hreport,(offsetx+ 4.000),(offsety+ 0.000),3.251,0.938,
      rpt_nofill,rpt_white)
     SET _rptstat = uar_rptrect(_hreport,(offsetx+ 4.000),(offsety+ 0.938),3.251,0.625,
      rpt_nofill,rpt_white)
     SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.250),(offsety+ 0.375),1.750,0.563,
      rpt_nofill,rpt_white)
     SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.250),(offsety+ 0.000),3.751,0.375,
      rpt_nofill,rpt_white)
     SET rptsd->m_flags = 4
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.188)
     SET rptsd->m_x = (offsetx+ 0.313)
     SET rptsd->m_width = 1.198
     SET rptsd->m_height = 0.188
     SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Tech__________",char(0)))
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.053)
     SET rptsd->m_x = (offsetx+ 1.188)
     SET rptsd->m_width = 0.407
     SET rptsd->m_height = 0.323
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Type on File",char(0)))
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.188)
     SET rptsd->m_x = (offsetx+ 1.438)
     SET rptsd->m_width = 0.896
     SET rptsd->m_height = 0.209
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("_________",char(0)))
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.073)
     SET rptsd->m_x = (offsetx+ 2.001)
     SET rptsd->m_width = 1.323
     SET rptsd->m_height = 0.136
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Specimen",char(0)))
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.188)
     SET rptsd->m_x = (offsetx+ 2.001)
     SET rptsd->m_width = 1.063
     SET rptsd->m_height = 0.188
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("#___________________",char(0)))
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.063)
     SET rptsd->m_x = (offsetx+ 3.126)
     SET rptsd->m_width = 0.938
     SET rptsd->m_height = 0.271
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Con Ordered(X) Yes[ ]  No [ ]",char(
        0)))
     SET rptsd->m_flags = 20
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.011)
     SET rptsd->m_x = (offsetx+ 4.313)
     SET rptsd->m_width = 2.667
     SET rptsd->m_height = 0.146
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("PRODUCT ORDERS (X)",char(0)))
     SET rptsd->m_flags = 4
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.376)
     SET rptsd->m_x = (offsetx+ 4.375)
     SET rptsd->m_width = 2.688
     SET rptsd->m_height = 0.146
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
       "# of Units/Volume Ordered:_____________________",char(0)))
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.188)
     SET rptsd->m_x = (offsetx+ 4.313)
     SET rptsd->m_width = 2.813
     SET rptsd->m_height = 0.146
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
       "[ ] RBC  [ ] PLT   [ ] FFT   [ ] CRY   Other:___________",char(0)))
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.563)
     SET rptsd->m_x = (offsetx+ 4.313)
     SET rptsd->m_width = 2.626
     SET rptsd->m_height = 0.146
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
       "[ ] for O.R. [ ] TBG  Date:________________  [ ] TBH",char(0)))
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.750)
     SET rptsd->m_x = (offsetx+ 4.500)
     SET rptsd->m_width = 2.626
     SET rptsd->m_height = 0.146
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
       "Pt. Has (X):   [ ] Auto unit(s)        [ ] Directed Unit(s)",char(0)))
     SET rptsd->m_flags = 20
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.376)
     SET rptsd->m_x = (offsetx+ 0.313)
     SET rptsd->m_width = 1.500
     SET rptsd->m_height = 0.146
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("TEST ORDERS (X):",char(0)))
     SET rptsd->m_flags = 4
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.563)
     SET rptsd->m_x = (offsetx+ 2.063)
     SET rptsd->m_width = 1.896
     SET rptsd->m_height = 0.146
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("O.R.Date:__________________________",
       char(0)))
     SET rptsd->m_flags = 20
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.563)
     SET rptsd->m_x = (offsetx+ 0.313)
     SET rptsd->m_width = 1.625
     SET rptsd->m_height = 0.146
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("[ ] T&S   [ ] ABORH   [ ] CORD",char
       (0)))
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.376)
     SET rptsd->m_x = (offsetx+ 2.063)
     SET rptsd->m_width = 2.001
     SET rptsd->m_height = 0.146
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("PAD Pt (X)",char(0)))
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.750)
     SET rptsd->m_x = (offsetx+ 0.313)
     SET rptsd->m_width = 1.500
     SET rptsd->m_height = 0.146
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("[ ] GELSC      [ ] DAT",char(0)))
     SET rptsd->m_flags = 4
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 1.000)
     SET rptsd->m_x = (offsetx+ 0.313)
     SET rptsd->m_width = 3.501
     SET rptsd->m_height = 0.146
     SET _dummyfont = uar_rptsetfont(_hreport,_times8i0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
       "AntiBodies____________________________________________________________",char(0)))
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.750)
     SET rptsd->m_x = (offsetx+ 2.063)
     SET rptsd->m_width = 2.001
     SET rptsd->m_height = 0.146
     SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
       "PAD Billing#:_______________________",char(0)))
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 1.157)
     SET rptsd->m_x = (offsetx+ 4.125)
     SET rptsd->m_width = 3.001
     SET rptsd->m_height = 0.146
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
       "[ ] CMV neg      [ ] Irradiated    [ ] ? Rxn",char(0)))
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 1.344)
     SET rptsd->m_x = (offsetx+ 4.125)
     SET rptsd->m_width = 2.688
     SET rptsd->m_height = 0.146
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
       "Other:___________________________________________",char(0)))
     SET rptsd->m_flags = 20
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.969)
     SET rptsd->m_x = (offsetx+ 4.063)
     SET rptsd->m_width = 2.876
     SET rptsd->m_height = 0.146
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("PATIENT INSTRUCTIONS (X)",char(0)))
     SET rptsd->m_flags = 4
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 1.386)
     SET rptsd->m_x = (offsetx+ 0.313)
     SET rptsd->m_width = 3.563
     SET rptsd->m_height = 0.146
     SET _dummyfont = uar_rptsetfont(_hreport,_times8i0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
       "Comments:_____________________________________________________________",char(0)))
     SET rptsd->m_flags = 20
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 1.188)
     SET rptsd->m_x = (offsetx+ 0.313)
     SET rptsd->m_width = 3.563
     SET rptsd->m_height = 0.178
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
       "and__________________________________________________________",char(0)))
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE (requistion_head_noencounter(ncalc=i2) =f8 WITH protect)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = requistion_head_noencounterabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE (requistion_head_noencounterabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
    DECLARE sectionheight = f8 WITH noconstant(0.310000), private
    IF ( NOT ((request->order_qual[1].encntr_id=0)
     AND program1 != cnvtupper("BHS_REQ_BBT")))
     RETURN(0.0)
    ENDIF
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 20
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.001)
     SET rptsd->m_x = (offsetx+ 0.000)
     SET rptsd->m_width = 7.500
     SET rptsd->m_height = 0.282
     SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     IF ((request->order_qual[1].encntr_id=0)
      AND program1 != cnvtupper("BHS_REQ_BBT"))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Baystate Health Order Requisition",
        char(0)))
     ENDIF
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE (requistion_head(ncalc=i2) =f8 WITH protect)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = requistion_headabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE (requistion_headabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
    DECLARE sectionheight = f8 WITH noconstant(0.630000), private
    DECLARE __facilty_name = vc WITH noconstant(build2(orders->facility,char(0))), protect
    IF ( NOT ((request->order_qual[1].encntr_id > 0)
     AND cnvtupper(program1) != "BHS_REQ_BBT"))
     RETURN(0.0)
    ENDIF
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 20
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.313)
     SET rptsd->m_x = (offsetx+ 0.000)
     SET rptsd->m_width = 7.500
     SET rptsd->m_height = 0.282
     SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Order Requisition",char(0)))
     SET rptsd->m_flags = 16
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.001)
     SET rptsd->m_x = (offsetx+ 0.000)
     SET rptsd->m_width = 7.500
     SET rptsd->m_height = 0.261
     SET _dummyfont = uar_rptsetfont(_hreport,_helvetica14b0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__facilty_name)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE (print_header2(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = print_header2abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE (print_header2abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
   WITH protect)
    DECLARE sectionheight = f8 WITH noconstant(2.270000), private
    DECLARE growsum = i4 WITH noconstant(0), private
    DECLARE drawheight_sex = f8 WITH noconstant(0.0), private
    DECLARE __pname = vc WITH noconstant(build2(orders->name,char(0))), protect
    DECLARE __attend = vc WITH noconstant(build2(orders->attending,char(0))), protect
    DECLARE __age = vc WITH noconstant(build2(orders->age,char(0))), protect
    DECLARE __sex = vc WITH noconstant(build2(orders->sex,char(0))), protect
    DECLARE __dob = vc WITH noconstant(build2(orders->dob,char(0))), protect
    DECLARE __address1 = vc WITH noconstant(build2(orders->s_addr_line1,char(0))), protect
    DECLARE __address2 = vc WITH noconstant(build2(orders->s_addr_line2,char(0))), protect
    DECLARE __address3 = vc WITH noconstant(build2(orders->s_addr_line3,char(0))), protect
    IF ( NOT (program1 IN ("BHS_REQ_OLO")))
     DECLARE __cmrn = vc WITH noconstant(build2(orders->cmrn,char(0))), protect
    ENDIF
    IF ((request->order_qual[1].encntr_id > 0))
     DECLARE __acct_num = vc WITH noconstant(build2(orders->fnbr,char(0))), protect
    ENDIF
    IF ( NOT (cnvtupper(program1) IN ("BHS_REQ_OLO"))
     AND (request->order_qual[1].encntr_id > 0))
     DECLARE __plocation = vc WITH noconstant(build2(orders->location,char(0))), protect
    ENDIF
    IF (program1 IN ("BHS_REQ_RAD"))
     DECLARE __homephone = vc WITH noconstant(build2(orders->s_home_phone,char(0))), protect
    ENDIF
    IF ( NOT (program1 IN ("BHS_REQ_OLO", "BHS_REQ_RAD")))
     RETURN(0.0)
    ENDIF
    IF (bcontinue=0)
     SET _remsex = 1
    ENDIF
    SET rptsd->m_flags = 5
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    IF (bcontinue)
     SET rptsd->m_y = offsety
    ELSE
     SET rptsd->m_y = (offsety+ 0.875)
    ENDIF
    SET rptsd->m_x = (offsetx+ 3.271)
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _holdremsex = _remsex
    IF (_remsex > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remsex,((size(__sex) -
        _remsex)+ 1),__sex)))
     SET drawheight_sex = rptsd->m_height
     IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
      SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
     ENDIF
     IF ((rptsd->m_drawlength=0))
      SET _remsex = 0
     ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remsex,((size(__sex) - _remsex)+ 1),
        __sex)))))
      SET _remsex += rptsd->m_drawlength
     ELSE
      SET _remsex = 0
     ENDIF
     SET growsum += _remsex
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdallborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.000
    SET rptsd->m_height = 0.282
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica10b0)
    SET _dummypen = uar_rptsetpen(_hreport,_pen10s0c0)
    IF (ncalc=rpt_render
     AND bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Information",char(0)))
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.376)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.230
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    IF (ncalc=rpt_render
     AND bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient :",char(0)))
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.376)
    SET rptsd->m_x = (offsetx+ 1.188)
    SET rptsd->m_width = 3.188
    SET rptsd->m_height = 0.230
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
    IF (ncalc=rpt_render
     AND bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__pname)
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.230
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica10b0)
    IF (ncalc=rpt_render
     AND bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Attending MD:",char(0)))
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.875)
    SET rptsd->m_x = (offsetx+ 1.501)
    SET rptsd->m_width = 0.376
    SET rptsd->m_height = 0.230
    IF (ncalc=rpt_render
     AND bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Age:",char(0)))
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.875)
    SET rptsd->m_x = (offsetx+ 2.688)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.230
    IF (ncalc=rpt_render
     AND bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Gender:",char(0)))
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 1.188)
    SET rptsd->m_width = 3.501
    SET rptsd->m_height = 0.230
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
    IF (ncalc=rpt_render
     AND bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__attend)
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.875)
    SET rptsd->m_x = (offsetx+ 1.876)
    SET rptsd->m_width = 0.563
    SET rptsd->m_height = 0.230
    IF (ncalc=rpt_render
     AND bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__age)
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    IF (bcontinue)
     SET rptsd->m_y = offsety
    ELSE
     SET rptsd->m_y = (offsety+ 0.875)
    ENDIF
    SET rptsd->m_x = (offsetx+ 3.271)
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = drawheight_sex
    IF (ncalc=rpt_render
     AND _holdremsex > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremsex,((size(__sex)
         - _holdremsex)+ 1),__sex)))
    ELSE
     SET _remsex = _holdremsex
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.875)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 0.438
    SET rptsd->m_height = 0.230
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica10b0)
    IF (ncalc=rpt_render
     AND bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("DOB:",char(0)))
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.875)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.230
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
    IF (ncalc=rpt_render
     AND bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__dob)
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.125)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica10b0)
    IF (ncalc=rpt_render
     AND bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Address :",char(0)))
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.313)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 6.375
    SET rptsd->m_height = 0.219
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
    IF (ncalc=rpt_render
     AND bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__address1)
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.532)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 6.188
    SET rptsd->m_height = 0.219
    IF (ncalc=rpt_render
     AND bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__address2)
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.761)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 4.063
    SET rptsd->m_height = 0.219
    IF (ncalc=rpt_render
     AND bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__address3)
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.875)
    SET rptsd->m_x = (offsetx+ 4.250)
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = 0.230
    IF (ncalc=rpt_render
     AND bcontinue=0)
     IF ( NOT (program1 IN ("BHS_REQ_OLO")))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("BHS CMRN#:",char(0)))
     ENDIF
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.875)
    SET rptsd->m_x = (offsetx+ 5.375)
    SET rptsd->m_width = 1.178
    SET rptsd->m_height = 0.230
    IF (ncalc=rpt_render
     AND bcontinue=0)
     IF ( NOT (program1 IN ("BHS_REQ_OLO")))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cmrn)
     ENDIF
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.084)
    SET rptsd->m_x = (offsetx+ 4.250)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.230
    IF (ncalc=rpt_render
     AND bcontinue=0)
     IF ((request->order_qual[1].encntr_id > 0))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("BHS Acct#:",char(0)))
     ENDIF
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.084)
    SET rptsd->m_x = (offsetx+ 5.188)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.230
    IF (ncalc=rpt_render
     AND bcontinue=0)
     IF ((request->order_qual[1].encntr_id > 0))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__acct_num)
     ENDIF
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 4.875)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.188
    IF (ncalc=rpt_render
     AND bcontinue=0)
     IF ( NOT (cnvtupper(program1) IN ("BHS_REQ_OLO"))
      AND (request->order_qual[1].encntr_id > 0))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Location:",char(0)))
     ENDIF
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 5.563)
    SET rptsd->m_width = 1.375
    SET rptsd->m_height = 0.188
    IF (ncalc=rpt_render
     AND bcontinue=0)
     IF ( NOT (cnvtupper(program1) IN ("BHS_REQ_OLO"))
      AND (request->order_qual[1].encntr_id > 0))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__plocation)
     ENDIF
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.021)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 0.511
    SET rptsd->m_height = 0.219
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica10b0)
    IF (ncalc=rpt_render
     AND bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Phone:",char(0)))
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.021)
    SET rptsd->m_x = (offsetx+ 0.688)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.219
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
    IF (ncalc=rpt_render
     AND bcontinue=0)
     IF (program1 IN ("BHS_REQ_RAD"))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__homephone)
     ENDIF
    ENDIF
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    IF (growsum > 0)
     SET bcontinue = 1
    ELSE
     SET bcontinue = 0
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE (print_header(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = print_headerabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE (print_headerabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
   WITH protect)
    DECLARE sectionheight = f8 WITH noconstant(2.590000), private
    DECLARE growsum = i4 WITH noconstant(0), private
    DECLARE drawheight_allergy = f8 WITH noconstant(0.0), private
    DECLARE drawheight_primary_diag = f8 WITH noconstant(0.0), private
    DECLARE __pname = vc WITH noconstant(build2(orders->name,char(0))), protect
    IF ( NOT (program1 IN ("BHS_REQ_OLO")))
     DECLARE __plocation = vc WITH noconstant(build2(orders->location,char(0))), protect
    ENDIF
    DECLARE __attend = vc WITH noconstant(build2(orders->attending,char(0))), protect
    IF ( NOT (program1 IN ("BHS_REQ_OLO")))
     DECLARE __admit_dt = vc WITH noconstant(build2(orders->admit_dt,char(0))), protect
    ENDIF
    DECLARE __age = vc WITH noconstant(build2(orders->age,char(0))), protect
    DECLARE __sex = vc WITH noconstant(build2(orders->sex,char(0))), protect
    IF ( NOT (program1 IN ("BHS_REQ_OLO")))
     DECLARE __mrn = vc WITH noconstant(build2(orders->mrn,char(0))), protect
    ENDIF
    IF ( NOT (program1 IN ("BHS_REQ_OLO")))
     DECLARE __trama_num = vc WITH noconstant(build2(orders->trauma,char(0))), protect
    ENDIF
    IF ( NOT (program1 IN ("BHS_REQ_OLO")))
     DECLARE __acct_num = vc WITH noconstant(build2(orders->fnbr,char(0))), protect
    ENDIF
    DECLARE __dob = vc WITH noconstant(build2(orders->dob,char(0))), protect
    IF ( NOT (program1 IN ("BHS_REQ_OLO")))
     DECLARE __height = vc WITH noconstant(build2(orders->height,char(0))), protect
    ENDIF
    IF ( NOT (program1 IN ("BHS_REQ_OLO")))
     DECLARE __weight = vc WITH noconstant(build2(orders->weight,char(0))), protect
    ENDIF
    IF ( NOT (program1 IN ("BHS_REQ_OLO")))
     DECLARE __temp_loc = vc WITH noconstant(build2(uar_get_code_display(temp_cd),char(0))), protect
    ENDIF
    IF ( NOT (program1 IN ("BHS_REQ_OLO")))
     DECLARE __cmrn = vc WITH noconstant(build2(orders->cmrn,char(0))), protect
    ENDIF
    IF ( NOT (program1 IN ("BHS_REQ_OLO")))
     DECLARE __pat_type = vc WITH noconstant(build2(orders->pat_type,char(0))), protect
    ENDIF
    IF ( NOT (program1 IN ("BHS_REQ_OLO")))
     DECLARE __allergy = vc WITH noconstant(build2(allergy->line,char(0))), protect
    ENDIF
    IF ( NOT (program1 IN ("BHS_REQ_OLO")))
     DECLARE __primary_diag = vc WITH noconstant(build2(orders->admit_diagnosis,char(0))), protect
    ENDIF
    DECLARE __braden_score = vc WITH noconstant(build2(orders->braden_score,char(0))), protect
    IF ( NOT ( NOT (program1 IN ("BHS_REQ_OLO", "BHS_REQ_RAD"))))
     RETURN(0.0)
    ENDIF
    IF (bcontinue=0)
     SET _remallergy = 1
     SET _remprimary_diag = 1
    ENDIF
    SET rptsd->m_flags = 5
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    IF (bcontinue)
     SET rptsd->m_y = offsety
    ELSE
     SET rptsd->m_y = (offsety+ 2.126)
    ENDIF
    SET rptsd->m_x = (offsetx+ 1.063)
    SET rptsd->m_width = 6.563
    SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    IF ( NOT (program1 IN ("BHS_REQ_OLO")))
     SET _holdremallergy = _remallergy
     IF (_remallergy > 0)
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remallergy,((size(
          __allergy) - _remallergy)+ 1),__allergy)))
      SET drawheight_allergy = rptsd->m_height
      IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
       SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
      ENDIF
      IF ((rptsd->m_drawlength=0))
       SET _remallergy = 0
      ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remallergy,((size(__allergy) -
         _remallergy)+ 1),__allergy)))))
       SET _remallergy += rptsd->m_drawlength
      ELSE
       SET _remallergy = 0
      ENDIF
      SET growsum += _remallergy
     ENDIF
    ELSE
     SET _remallergy = 0
     SET _holdremallergy = _remallergy
    ENDIF
    SET rptsd->m_flags = 5
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    IF (bcontinue)
     SET rptsd->m_y = offsety
    ELSE
     SET rptsd->m_y = (offsety+ 2.376)
    ENDIF
    SET rptsd->m_x = (offsetx+ 1.501)
    SET rptsd->m_width = 6.125
    SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
    IF ( NOT (program1 IN ("BHS_REQ_OLO")))
     SET _holdremprimary_diag = _remprimary_diag
     IF (_remprimary_diag > 0)
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remprimary_diag,((size(
          __primary_diag) - _remprimary_diag)+ 1),__primary_diag)))
      SET drawheight_primary_diag = rptsd->m_height
      IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
       SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
      ENDIF
      IF ((rptsd->m_drawlength=0))
       SET _remprimary_diag = 0
      ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remprimary_diag,((size(__primary_diag)
          - _remprimary_diag)+ 1),__primary_diag)))))
       SET _remprimary_diag += rptsd->m_drawlength
      ELSE
       SET _remprimary_diag = 0
      ENDIF
      SET growsum += _remprimary_diag
     ENDIF
    ELSE
     SET _remprimary_diag = 0
     SET _holdremprimary_diag = _remprimary_diag
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.125)
    SET rptsd->m_x = (offsetx+ 2.063)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.188
    IF (ncalc=rpt_render
     AND bcontinue=0)
     IF ( NOT (program1 IN ("BHS_REQ_OLO")))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Admit Date:",char(0)))
     ENDIF
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 0.313)
    SET rptsd->m_width = 0.532
    SET rptsd->m_height = 0.188
    IF (ncalc=rpt_render
     AND bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient :",char(0)))
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 1.313)
    SET rptsd->m_width = 3.188
    SET rptsd->m_height = 0.188
    IF (ncalc=rpt_render
     AND bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__pname)
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.563)
    SET rptsd->m_x = (offsetx+ 0.313)
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = 0.188
    IF (ncalc=rpt_render
     AND bcontinue=0)
     IF ( NOT (program1 IN ("BHS_REQ_OLO")))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Location:",char(0)))
     ENDIF
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.938)
    SET rptsd->m_x = (offsetx+ 0.313)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.188
    IF (ncalc=rpt_render
     AND bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Attending MD:",char(0)))
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 0.313)
    SET rptsd->m_width = 0.376
    SET rptsd->m_height = 0.188
    IF (ncalc=rpt_render
     AND bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Age:",char(0)))
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.750)
    SET rptsd->m_x = (offsetx+ 0.313)
    SET rptsd->m_width = 0.313
    SET rptsd->m_height = 0.188
    IF (ncalc=rpt_render
     AND bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Sex:",char(0)))
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.563)
    SET rptsd->m_x = (offsetx+ 1.313)
    SET rptsd->m_width = 3.188
    SET rptsd->m_height = 0.188
    IF (ncalc=rpt_render
     AND bcontinue=0)
     IF ( NOT (program1 IN ("BHS_REQ_OLO")))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__plocation)
     ENDIF
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.938)
    SET rptsd->m_x = (offsetx+ 1.313)
    SET rptsd->m_width = 3.188
    SET rptsd->m_height = 0.188
    IF (ncalc=rpt_render
     AND bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__attend)
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.125)
    SET rptsd->m_x = (offsetx+ 2.876)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.188
    IF (ncalc=rpt_render
     AND bcontinue=0)
     IF ( NOT (program1 IN ("BHS_REQ_OLO")))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__admit_dt)
     ENDIF
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 0.938)
    SET rptsd->m_width = 1.563
    SET rptsd->m_height = 0.188
    IF (ncalc=rpt_render
     AND bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__age)
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.750)
    SET rptsd->m_x = (offsetx+ 0.938)
    SET rptsd->m_width = 1.698
    SET rptsd->m_height = 0.188
    IF (ncalc=rpt_render
     AND bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__sex)
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 4.625)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.188
    IF (ncalc=rpt_render
     AND bcontinue=0)
     IF ( NOT (program1 IN ("BHS_REQ_OLO")))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MRN#:",char(0)))
     ENDIF
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.688)
    SET rptsd->m_x = (offsetx+ 4.625)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.188
    IF (ncalc=rpt_render
     AND bcontinue=0)
     IF ( NOT (program1 IN ("BHS_REQ_OLO")))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Trauma#:",char(0)))
     ENDIF
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.938)
    SET rptsd->m_x = (offsetx+ 4.625)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.188
    IF (ncalc=rpt_render
     AND bcontinue=0)
     IF ( NOT (program1 IN ("BHS_REQ_OLO")))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Acct#:",char(0)))
     ENDIF
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.313)
    SET rptsd->m_x = (offsetx+ 0.313)
    SET rptsd->m_width = 0.438
    SET rptsd->m_height = 0.188
    IF (ncalc=rpt_render
     AND bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("DOB:",char(0)))
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.375)
    SET rptsd->m_x = (offsetx+ 4.625)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.188
    IF (ncalc=rpt_render
     AND bcontinue=0)
     IF ( NOT (program1 IN ("BHS_REQ_OLO")))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Height:",char(0)))
     ENDIF
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.563)
    SET rptsd->m_x = (offsetx+ 4.625)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.188
    IF (ncalc=rpt_render
     AND bcontinue=0)
     IF ( NOT (program1 IN ("BHS_REQ_OLO")))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Weight:",char(0)))
     ENDIF
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 5.563)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.188
    IF (ncalc=rpt_render
     AND bcontinue=0)
     IF ( NOT (program1 IN ("BHS_REQ_OLO")))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__mrn)
     ENDIF
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.688)
    SET rptsd->m_x = (offsetx+ 5.563)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.188
    IF (ncalc=rpt_render
     AND bcontinue=0)
     IF ( NOT (program1 IN ("BHS_REQ_OLO")))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__trama_num)
     ENDIF
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.938)
    SET rptsd->m_x = (offsetx+ 5.563)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.188
    IF (ncalc=rpt_render
     AND bcontinue=0)
     IF ( NOT (program1 IN ("BHS_REQ_OLO")))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__acct_num)
     ENDIF
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.313)
    SET rptsd->m_x = (offsetx+ 0.813)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.188
    IF (ncalc=rpt_render
     AND bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__dob)
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.375)
    SET rptsd->m_x = (offsetx+ 5.563)
    SET rptsd->m_width = 1.209
    SET rptsd->m_height = 0.188
    IF (ncalc=rpt_render
     AND bcontinue=0)
     IF ( NOT (program1 IN ("BHS_REQ_OLO")))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__height)
     ENDIF
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.563)
    SET rptsd->m_x = (offsetx+ 5.563)
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = 0.198
    IF (ncalc=rpt_render
     AND bcontinue=0)
     IF ( NOT (program1 IN ("BHS_REQ_OLO")))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__weight)
     ENDIF
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 0.313)
    SET rptsd->m_width = 0.907
    SET rptsd->m_height = 0.188
    IF (ncalc=rpt_render
     AND bcontinue=0)
     IF ( NOT (program1 IN ("BHS_REQ_OLO")))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Temp Loc:",char(0)))
     ENDIF
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 1.313)
    SET rptsd->m_width = 3.188
    SET rptsd->m_height = 0.188
    IF (ncalc=rpt_render
     AND bcontinue=0)
     IF ( NOT (program1 IN ("BHS_REQ_OLO")))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__temp_loc)
     ENDIF
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdallborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 7.000
    SET rptsd->m_height = 0.282
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica10b0)
    SET _dummypen = uar_rptsetpen(_hreport,_pen10s0c0)
    IF (ncalc=rpt_render
     AND bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Information",char(0)))
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.125)
    SET rptsd->m_x = (offsetx+ 0.313)
    SET rptsd->m_width = 0.376
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    IF (ncalc=rpt_render
     AND bcontinue=0)
     IF ( NOT (program1 IN ("BHS_REQ_OLO")))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("LOS:",char(0)))
     ENDIF
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 4.625)
    SET rptsd->m_width = 0.657
    SET rptsd->m_height = 0.188
    IF (ncalc=rpt_render
     AND bcontinue=0)
     IF ( NOT (program1 IN ("BHS_REQ_OLO")))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("CMRN#:",char(0)))
     ENDIF
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.126)
    SET rptsd->m_x = (offsetx+ 0.313)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.188
    IF (ncalc=rpt_render
     AND bcontinue=0)
     IF ( NOT (program1 IN ("BHS_REQ_OLO")))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Allergies:",char(0)))
     ENDIF
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.376)
    SET rptsd->m_x = (offsetx+ 0.313)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.188
    IF (ncalc=rpt_render
     AND bcontinue=0)
     IF ( NOT (program1 IN ("BHS_REQ_OLO")))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Primary Diagnosis:",char(0)))
     ENDIF
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.125)
    SET rptsd->m_x = (offsetx+ 4.625)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.188
    IF (ncalc=rpt_render
     AND bcontinue=0)
     IF ( NOT (program1 IN ("BHS_REQ_OLO")))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Type:",char(0)))
     ENDIF
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.125)
    SET rptsd->m_x = (offsetx+ 0.750)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.188
    IF (ncalc=rpt_render
     AND bcontinue=0)
     IF ( NOT (program1 IN ("BHS_REQ_OLO")))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(los_days,char(0)))
     ENDIF
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 5.563)
    SET rptsd->m_width = 1.178
    SET rptsd->m_height = 0.188
    IF (ncalc=rpt_render
     AND bcontinue=0)
     IF ( NOT (program1 IN ("BHS_REQ_OLO")))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cmrn)
     ENDIF
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.125)
    SET rptsd->m_x = (offsetx+ 5.563)
    SET rptsd->m_width = 1.198
    SET rptsd->m_height = 0.188
    IF (ncalc=rpt_render
     AND bcontinue=0)
     IF ( NOT (program1 IN ("BHS_REQ_OLO")))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__pat_type)
     ENDIF
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    IF (bcontinue)
     SET rptsd->m_y = offsety
    ELSE
     SET rptsd->m_y = (offsety+ 2.126)
    ENDIF
    SET rptsd->m_x = (offsetx+ 1.063)
    SET rptsd->m_width = 6.563
    SET rptsd->m_height = drawheight_allergy
    IF (ncalc=rpt_render
     AND _holdremallergy > 0)
     IF ( NOT (program1 IN ("BHS_REQ_OLO")))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremallergy,((size(
          __allergy) - _holdremallergy)+ 1),__allergy)))
     ENDIF
    ELSE
     SET _remallergy = _holdremallergy
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    IF (bcontinue)
     SET rptsd->m_y = offsety
    ELSE
     SET rptsd->m_y = (offsety+ 2.376)
    ENDIF
    SET rptsd->m_x = (offsetx+ 1.501)
    SET rptsd->m_width = 6.125
    SET rptsd->m_height = drawheight_primary_diag
    IF (ncalc=rpt_render
     AND _holdremprimary_diag > 0)
     IF ( NOT (program1 IN ("BHS_REQ_OLO")))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremprimary_diag,((
         size(__primary_diag) - _holdremprimary_diag)+ 1),__primary_diag)))
     ENDIF
    ELSE
     SET _remprimary_diag = _holdremprimary_diag
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.938)
    SET rptsd->m_x = (offsetx+ 0.313)
    SET rptsd->m_width = 0.969
    SET rptsd->m_height = 0.188
    IF (ncalc=rpt_render
     AND bcontinue=0)
     IF ((orders->braden_score != null))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Braden Score: ",char(0)))
     ENDIF
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.938)
    SET rptsd->m_x = (offsetx+ 1.313)
    SET rptsd->m_width = 1.719
    SET rptsd->m_height = 0.188
    IF (ncalc=rpt_render
     AND bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__braden_score)
    ENDIF
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    IF (growsum > 0)
     SET bcontinue = 1
    ELSE
     SET bcontinue = 0
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE (order_section(ncalc=i2) =f8 WITH protect)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = order_sectionabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE (order_sectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
    DECLARE sectionheight = f8 WITH noconstant(1.420000), private
    DECLARE __mnemonic = vc WITH noconstant(build2(orders->qual[prt_ord].mnemonic,char(0))), protect
    DECLARE __order_status = vc WITH noconstant(build2(orders->qual[prt_ord].status,char(0))),
    protect
    IF ( NOT (program1 IN ("BHS_REQ_OLO")))
     DECLARE __order_id = vc WITH noconstant(build2(orders->qual[prt_ord].order_id,char(0))), protect
    ENDIF
    IF (program1 IN ("BHS_REQ_OLO", "BHS_REQ_RAD"))
     DECLARE __order_prov_layout = vc WITH noconstant(build2(orders->qual[prt_ord].order_dr,char(0))),
     protect
    ENDIF
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 4
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.813)
     SET rptsd->m_x = (offsetx+ 0.250)
     SET rptsd->m_width = 0.750
     SET rptsd->m_height = 0.188
     SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Procedure:",char(0)))
     SET rptsd->m_flags = 0
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     IF (program1 IN ("BHS_REQ_OLO"))
      SET _fntcond = _helvetica10b0
     ELSE
      SET _fntcond = _helvetica100
     ENDIF
     SET rptsd->m_y = (offsety+ 0.813)
     SET rptsd->m_x = (offsetx+ 1.000)
     SET rptsd->m_width = 4.188
     SET rptsd->m_height = 0.188
     SET _dummyfont = uar_rptsetfont(_hreport,_fntcond)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__mnemonic)
     SET rptsd->m_flags = 4
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 1.063)
     SET rptsd->m_x = (offsetx+ 4.688)
     SET rptsd->m_width = 0.938
     SET rptsd->m_height = 0.188
     SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Order Status:",char(0)))
     SET rptsd->m_flags = 0
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 1.063)
     SET rptsd->m_x = (offsetx+ 5.750)
     SET rptsd->m_width = 1.500
     SET rptsd->m_height = 0.188
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__order_status)
     SET rptsd->m_flags = 4
     SET rptsd->m_borders = rpt_sdallborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.563)
     SET rptsd->m_x = (offsetx+ 0.250)
     SET rptsd->m_width = 7.011
     SET rptsd->m_height = 0.251
     SET _dummyfont = uar_rptsetfont(_hreport,_helvetica10b0)
     SET _dummypen = uar_rptsetpen(_hreport,_pen10s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Order Details",char(0)))
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 1.063)
     SET rptsd->m_x = (offsetx+ 0.563)
     SET rptsd->m_width = 0.584
     SET rptsd->m_height = 0.188
     SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
     SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
     IF ( NOT (program1 IN ("BHS_REQ_OLO", "BHS_REQ_RAD")))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Order ID:",char(0)))
     ENDIF
     SET rptsd->m_flags = 0
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 1.063)
     SET rptsd->m_x = (offsetx+ 1.438)
     SET rptsd->m_width = 1.813
     SET rptsd->m_height = 0.188
     IF ( NOT (program1 IN ("BHS_REQ_OLO")))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__order_id)
     ENDIF
     SET rptsd->m_flags = 4
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.053)
     SET rptsd->m_x = (offsetx+ 0.188)
     SET rptsd->m_width = 1.563
     SET rptsd->m_height = 0.261
     SET _dummyfont = uar_rptsetfont(_hreport,_helvetica12b0)
     IF (program1 IN ("BHS_REQ_OLO", "BHS_REQ_RAD"))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Ordering Provider :",char(0)))
     ENDIF
     SET rptsd->m_flags = 20
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.303)
     SET rptsd->m_x = (offsetx+ 0.094)
     SET rptsd->m_width = 7.344
     SET rptsd->m_height = 0.261
     SET _dummyfont = uar_rptsetfont(_hreport,_times12bi0)
     IF (program1 IN ("BHS_REQ_OLO", "BHS_REQ_RAD"))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
        "All orders below are electronically signed by this provider",char(0)))
     ENDIF
     SET rptsd->m_flags = 0
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.053)
     SET rptsd->m_x = (offsetx+ 1.792)
     SET rptsd->m_width = 5.459
     SET rptsd->m_height = 0.261
     SET _dummyfont = uar_rptsetfont(_hreport,_helvetica120)
     IF (program1 IN ("BHS_REQ_OLO", "BHS_REQ_RAD"))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__order_prov_layout)
     ENDIF
     SET rptsd->m_flags = 4
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 1.063)
     SET rptsd->m_x = (offsetx+ 0.250)
     SET rptsd->m_width = 0.938
     SET rptsd->m_height = 0.188
     SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
     IF (program1 IN ("BHS_REQ_RAD"))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("BHS Order ID:",char(0)))
     ENDIF
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE (line1(ncalc=i2) =f8 WITH protect)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = line1abs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE (line1abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
    DECLARE sectionheight = f8 WITH noconstant(0.090000), private
    IF ( NOT (program1=cnvtupper("bhs_req_irra")))
     RETURN(0.0)
    ENDIF
    IF (ncalc=rpt_render)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.313),(offsety+ 0.047),(offsetx+ 5.876),(offsety
      + 0.047))
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE (order_details(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = order_detailsabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE (order_detailsabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
   WITH protect)
    DECLARE sectionheight = f8 WITH noconstant(0.170000), private
    DECLARE growsum = i4 WITH noconstant(0), private
    DECLARE drawheight_detail_value = f8 WITH noconstant(0.0), private
    DECLARE drawheight_detail_label = f8 WITH noconstant(0.0), private
    DECLARE __detail_value = vc WITH noconstant(build2(value,char(0))), protect
    DECLARE __detail_label = vc WITH noconstant(build2(detail_label,char(0))), protect
    IF (bcontinue=0)
     SET _remdetail_value = 1
     SET _remdetail_label = 1
    ENDIF
    SET rptsd->m_flags = 5
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    IF (bcontinue)
     SET rptsd->m_y = offsety
    ELSE
     SET rptsd->m_y = (offsety+ 0.001)
    ENDIF
    SET rptsd->m_x = (offsetx+ 2.876)
    SET rptsd->m_width = 4.375
    SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _holdremdetail_value = _remdetail_value
    IF (_remdetail_value > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remdetail_value,((size(
         __detail_value) - _remdetail_value)+ 1),__detail_value)))
     SET drawheight_detail_value = rptsd->m_height
     IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
      SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
     ENDIF
     IF ((rptsd->m_drawlength=0))
      SET _remdetail_value = 0
     ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remdetail_value,((size(__detail_value)
         - _remdetail_value)+ 1),__detail_value)))))
      SET _remdetail_value += rptsd->m_drawlength
     ELSE
      SET _remdetail_value = 0
     ENDIF
     SET growsum += _remdetail_value
    ENDIF
    SET rptsd->m_flags = 5
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    IF (bcontinue)
     SET rptsd->m_y = offsety
    ELSE
     SET rptsd->m_y = (offsety+ 0.001)
    ENDIF
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 2.438
    SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
    SET _holdremdetail_label = _remdetail_label
    IF (_remdetail_label > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remdetail_label,((size(
         __detail_label) - _remdetail_label)+ 1),__detail_label)))
     SET drawheight_detail_label = rptsd->m_height
     IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
      SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
     ENDIF
     IF ((rptsd->m_drawlength=0))
      SET _remdetail_label = 0
     ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remdetail_label,((size(__detail_label)
         - _remdetail_label)+ 1),__detail_label)))))
      SET _remdetail_label += rptsd->m_drawlength
     ELSE
      SET _remdetail_label = 0
     ENDIF
     SET growsum += _remdetail_label
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    IF (bcontinue)
     SET rptsd->m_y = offsety
    ELSE
     SET rptsd->m_y = (offsety+ 0.001)
    ENDIF
    SET rptsd->m_x = (offsetx+ 2.876)
    SET rptsd->m_width = 4.375
    SET rptsd->m_height = drawheight_detail_value
    IF (ncalc=rpt_render
     AND _holdremdetail_value > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremdetail_value,((
        size(__detail_value) - _holdremdetail_value)+ 1),__detail_value)))
    ELSE
     SET _remdetail_value = _holdremdetail_value
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    IF (bcontinue)
     SET rptsd->m_y = offsety
    ELSE
     SET rptsd->m_y = (offsety+ 0.001)
    ENDIF
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 2.438
    SET rptsd->m_height = drawheight_detail_label
    IF (ncalc=rpt_render
     AND _holdremdetail_label > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremdetail_label,((
        size(__detail_label) - _holdremdetail_label)+ 1),__detail_label)))
    ELSE
     SET _remdetail_label = _holdremdetail_label
    ENDIF
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    IF (growsum > 0)
     SET bcontinue = 1
    ELSE
     SET bcontinue = 0
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE (future_order_info(ncalc=i2) =f8 WITH protect)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = future_order_infoabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE (future_order_infoabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
    DECLARE sectionheight = f8 WITH noconstant(0.500000), private
    DECLARE __future_facility = vc WITH noconstant(build2(orders->qual[prt_ord].s_fut_facilty,char(0)
      )), protect
    DECLARE __future_unit = vc WITH noconstant(build2(orders->qual[prt_ord].s_fut_unit,char(0))),
    protect
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 4
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.001)
     SET rptsd->m_x = (offsetx+ 0.250)
     SET rptsd->m_width = 1.313
     SET rptsd->m_height = 0.188
     SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Future Order Facility:",char(0)))
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.188)
     SET rptsd->m_x = (offsetx+ 0.250)
     SET rptsd->m_width = 1.188
     SET rptsd->m_height = 0.188
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Future Order Unit:",char(0)))
     SET rptsd->m_flags = 0
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.001)
     SET rptsd->m_x = (offsetx+ 1.751)
     SET rptsd->m_width = 3.376
     SET rptsd->m_height = 0.188
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__future_facility)
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.188)
     SET rptsd->m_x = (offsetx+ 1.751)
     SET rptsd->m_width = 3.626
     SET rptsd->m_height = 0.188
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__future_unit)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE (testing_section(ncalc=i2) =f8 WITH protect)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = testing_sectionabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE (testing_sectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
    DECLARE sectionheight = f8 WITH noconstant(0.200000), private
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 4
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.001)
     SET rptsd->m_x = (offsetx+ 0.198)
     SET rptsd->m_width = 1.678
     SET rptsd->m_height = 0.198
     SET _oldfont = uar_rptsetfont(_hreport,_times100)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("_Yoffset",char(0)))
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE (print_top_foot_blank(ncalc=i2) =f8 WITH protect)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = print_top_foot_blankabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE (print_top_foot_blankabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
    DECLARE sectionheight = f8 WITH noconstant(0.740000), private
    IF ( NOT ( NOT (cnvtupper(program1) IN ("BHS_REQ_OLO", "BHS_REQ_RAD"))))
     RETURN(0.0)
    ENDIF
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE (patient_note_olo(ncalc=i2) =f8 WITH protect)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = patient_note_oloabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE (patient_note_oloabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
    DECLARE sectionheight = f8 WITH noconstant(0.270000), private
    IF ( NOT (program1 IN ("BHS_REQ_OLO")))
     RETURN(0.0)
    ENDIF
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 4
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.001)
     SET rptsd->m_x = (offsetx+ 0.000)
     SET rptsd->m_width = 7.500
     SET rptsd->m_height = 0.251
     SET _oldfont = uar_rptsetfont(_hreport,_times12b0)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     IF (cnvtupper(program1) IN ("BHS_REQ_OLO"))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
        "PLEASE BRING THIS FORM WITH YOU TO THE LAB TO HAVE YOUR LAB WORK DRAWN. ",char(0)))
     ENDIF
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE (patient_note_rad1(ncalc=i2) =f8 WITH protect)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = patient_note_rad1abs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE (patient_note_rad1abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
    DECLARE sectionheight = f8 WITH noconstant(0.250000), private
    IF ( NOT (program1 IN ("BHS_REQ_RAD")))
     RETURN(0.0)
    ENDIF
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 4
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.001)
     SET rptsd->m_x = (offsetx+ 0.042)
     SET rptsd->m_width = 7.959
     SET rptsd->m_height = 0.251
     SET _oldfont = uar_rptsetfont(_hreport,_times12b0)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     IF (cnvtupper(program1) IN ("BHS_REQ_RAD"))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
        "PLEASE BRING THIS FORM WITH YOU TO HAVE THIS TEST COMPLETED",char(0)))
     ENDIF
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE (print_footer(ncalc=i2) =f8 WITH protect)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = print_footerabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE (print_footerabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
    DECLARE sectionheight = f8 WITH noconstant(0.860000), private
    DECLARE __ordering_dr = vc WITH noconstant(build2(orders->qual[prt_ord].order_dr,char(0))),
    protect
    IF ( NOT (program1 IN ("BHS_REQ_OLO")))
     DECLARE __order_type = vc WITH noconstant(build2(orders->qual[prt_ord].type,char(0))), protect
    ENDIF
    IF ( NOT (program1 IN ("BHS_REQ_OLO")))
     DECLARE __entered_by = vc WITH noconstant(build2(orders->qual[prt_ord].enter_by,char(0))),
     protect
    ENDIF
    DECLARE __order_date = vc WITH noconstant(build2(orders->qual[prt_ord].signed_dt,char(0))),
    protect
    DECLARE __printed_date = vc WITH noconstant(build2(format(cnvtdatetime(curdate,curtime),
       "@SHORTDATETIME"),char(0))), protect
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 4
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.126)
     SET rptsd->m_x = (offsetx+ 0.250)
     SET rptsd->m_width = 0.855
     SET rptsd->m_height = 0.188
     SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Ordering MD:",char(0)))
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.344)
     SET rptsd->m_x = (offsetx+ 0.250)
     SET rptsd->m_width = 0.750
     SET rptsd->m_height = 0.188
     IF ( NOT (program1 IN ("BHS_REQ_OLO")))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Order Type:",char(0)))
     ENDIF
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.126)
     SET rptsd->m_x = (offsetx+ 4.063)
     SET rptsd->m_width = 1.125
     SET rptsd->m_height = 0.188
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Order Date/Time:",char(0)))
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.563)
     SET rptsd->m_x = (offsetx+ 0.250)
     SET rptsd->m_width = 1.063
     SET rptsd->m_height = 0.188
     IF ( NOT (program1 IN ("BHS_REQ_OLO")))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Order entered by:",char(0)))
     ENDIF
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.313)
     SET rptsd->m_x = (offsetx+ 4.063)
     SET rptsd->m_width = 1.250
     SET rptsd->m_height = 0.188
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Printed Date/Time:",char(0)))
     SET rptsd->m_flags = 0
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.126)
     SET rptsd->m_x = (offsetx+ 1.313)
     SET rptsd->m_width = 2.011
     SET rptsd->m_height = 0.188
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ordering_dr)
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.344)
     SET rptsd->m_x = (offsetx+ 1.375)
     SET rptsd->m_width = 2.021
     SET rptsd->m_height = 0.188
     IF ( NOT (program1 IN ("BHS_REQ_OLO")))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__order_type)
     ENDIF
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.563)
     SET rptsd->m_x = (offsetx+ 1.313)
     SET rptsd->m_width = 2.251
     SET rptsd->m_height = 0.188
     IF ( NOT (program1 IN ("BHS_REQ_OLO")))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__entered_by)
     ENDIF
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.126)
     SET rptsd->m_x = (offsetx+ 5.313)
     SET rptsd->m_width = 1.688
     SET rptsd->m_height = 0.188
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__order_date)
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.313)
     SET rptsd->m_x = (offsetx+ 5.313)
     SET rptsd->m_width = 1.938
     SET rptsd->m_height = 0.188
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__printed_date)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE (order_comments(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = order_commentsabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE (order_commentsabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
   WITH protect)
    DECLARE sectionheight = f8 WITH noconstant(0.190000), private
    DECLARE growsum = i4 WITH noconstant(0), private
    DECLARE drawheight_order_comment = f8 WITH noconstant(0.0), private
    DECLARE __order_comment = vc WITH noconstant(build2(orders->qual[prt_ord].comment,char(0))),
    protect
    IF (bcontinue=0)
     SET _remorder_comment = 1
    ENDIF
    SET rptsd->m_flags = 5
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_oneandahalf
    SET rptsd->m_rotationangle = 0
    IF (bcontinue)
     SET rptsd->m_y = offsety
    ELSE
     SET rptsd->m_y = (offsety+ 0.001)
    ENDIF
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 7.000
    SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen10s0c0)
    SET _holdremorder_comment = _remorder_comment
    IF (_remorder_comment > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remorder_comment,((size(
         __order_comment) - _remorder_comment)+ 1),__order_comment)))
     SET drawheight_order_comment = rptsd->m_height
     IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
      SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
     ENDIF
     IF ((rptsd->m_drawlength=0))
      SET _remorder_comment = 0
     ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remorder_comment,((size(__order_comment)
         - _remorder_comment)+ 1),__order_comment)))))
      SET _remorder_comment += rptsd->m_drawlength
     ELSE
      SET _remorder_comment = 0
     ENDIF
     SET growsum += _remorder_comment
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    IF (bcontinue)
     SET rptsd->m_y = offsety
    ELSE
     SET rptsd->m_y = (offsety+ 0.001)
    ENDIF
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 7.000
    SET rptsd->m_height = drawheight_order_comment
    IF (ncalc=rpt_render
     AND _holdremorder_comment > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremorder_comment,((
        size(__order_comment) - _holdremorder_comment)+ 1),__order_comment)))
    ELSE
     SET _remorder_comment = _holdremorder_comment
    ENDIF
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    IF (growsum > 0)
     SET bcontinue = 1
    ELSE
     SET bcontinue = 0
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE (order_comments_header(ncalc=i2) =f8 WITH protect)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = order_comments_headerabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE (order_comments_headerabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
    DECLARE sectionheight = f8 WITH noconstant(0.380000), private
    IF (ncalc=rpt_render)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.250),(offsety+ 0.000),7.011,0.260,
      rpt_nofill,rpt_white)
     SET rptsd->m_flags = 4
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.063)
     SET rptsd->m_x = (offsetx+ 0.313)
     SET rptsd->m_width = 1.323
     SET rptsd->m_height = 0.209
     SET _oldfont = uar_rptsetfont(_hreport,_helvetica10b0)
     SET _dummypen = uar_rptsetpen(_hreport,_pen10s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Order Comments",char(0)))
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.063)
     SET rptsd->m_x = (offsetx+ 2.251)
     SET rptsd->m_width = 1.323
     SET rptsd->m_height = 0.188
     SET _dummyfont = uar_rptsetfont(_hreport,_times8i0)
     SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
     IF ((orders->qual[prt_ord].comment=null))
      SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("< no order comments>",char(0)))
     ENDIF
     SET rptsd->m_flags = 0
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.063)
     SET rptsd->m_x = (offsetx+ 4.563)
     SET rptsd->m_width = 1.646
     SET rptsd->m_height = 0.209
     SET _dummyfont = uar_rptsetfont(_hreport,_times100)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(continued,char(0)))
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE (foot_page(ncalc=i2) =f8 WITH protect)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = foot_pageabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE (foot_pageabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
    DECLARE sectionheight = f8 WITH noconstant(0.190000), private
    DECLARE __program_name = vc WITH noconstant(build2(cnvtupper(program1),char(0))), protect
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 64
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.001)
     SET rptsd->m_x = (offsetx+ 5.500)
     SET rptsd->m_width = 1.688
     SET rptsd->m_height = 0.188
     SET _oldfont = uar_rptsetfont(_hreport,_helvetica60)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__program_name)
     SET rptsd->m_flags = 16
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.001)
     SET rptsd->m_x = (offsetx+ 2.376)
     SET rptsd->m_width = 1.938
     SET rptsd->m_height = 0.188
     SET _dummyfont = uar_rptsetfont(_hreport,_times100)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE initializereport(dummy)
    SET rptreport->m_recsize = 104
    SET rptreport->m_reportname = "BHS_REQ_RAD_LAYOUT"
    SET rptreport->m_pagewidth = 8.50
    SET rptreport->m_pageheight = 11.00
    SET rptreport->m_orientation = rpt_portrait
    SET rptreport->m_marginleft = 0.50
    SET rptreport->m_marginright = 0.50
    SET rptreport->m_margintop = 0.50
    SET rptreport->m_marginbottom = 0.20
    SET rptreport->m_horzprintoffset = _xshift
    SET rptreport->m_vertprintoffset = _yshift
    SET rptreport->m_dioflag = 0
    SET rptreport->m_needsnotonaskharabic = 0
    SET _yoffset = rptreport->m_margintop
    SET _xoffset = rptreport->m_marginleft
    SET _hreport = uar_rptcreatereport(rptreport,_outputtype,rpt_inches)
    SET _rpterr = uar_rptseterrorlevel(_hreport,rpt_error)
    SET _rptstat = uar_rptstartreport(_hreport)
    SET _rptpage = uar_rptstartpage(_hreport)
    CALL _createfonts(0)
    CALL _createpens(0)
  END ;Subroutine
  SUBROUTINE _createfonts(dummy)
    SET rptfont->m_recsize = 62
    SET rptfont->m_fontname = rpt_times
    SET rptfont->m_pointsize = 10
    SET rptfont->m_bold = rpt_off
    SET rptfont->m_italic = rpt_off
    SET rptfont->m_underline = rpt_off
    SET rptfont->m_strikethrough = rpt_off
    SET rptfont->m_rgbcolor = rpt_black
    SET _times100 = uar_rptcreatefont(_hreport,rptfont)
    SET rptfont->m_fontname = rpt_helvetica
    SET rptfont->m_pointsize = 12
    SET rptfont->m_bold = rpt_on
    SET _helvetica12b0 = uar_rptcreatefont(_hreport,rptfont)
    SET rptfont->m_fontname = rpt_times
    SET rptfont->m_pointsize = 8
    SET _times8b0 = uar_rptcreatefont(_hreport,rptfont)
    SET rptfont->m_bold = rpt_off
    SET rptfont->m_italic = rpt_on
    SET _times8i0 = uar_rptcreatefont(_hreport,rptfont)
    SET rptfont->m_fontname = rpt_helvetica
    SET rptfont->m_pointsize = 14
    SET rptfont->m_bold = rpt_on
    SET rptfont->m_italic = rpt_off
    SET _helvetica14b0 = uar_rptcreatefont(_hreport,rptfont)
    SET rptfont->m_pointsize = 10
    SET rptfont->m_bold = rpt_off
    SET _helvetica100 = uar_rptcreatefont(_hreport,rptfont)
    SET rptfont->m_bold = rpt_on
    SET _helvetica10b0 = uar_rptcreatefont(_hreport,rptfont)
    SET rptfont->m_fontname = rpt_times
    SET rptfont->m_pointsize = 12
    SET rptfont->m_italic = rpt_on
    SET _times12bi0 = uar_rptcreatefont(_hreport,rptfont)
    SET rptfont->m_fontname = rpt_helvetica
    SET rptfont->m_bold = rpt_off
    SET rptfont->m_italic = rpt_off
    SET _helvetica120 = uar_rptcreatefont(_hreport,rptfont)
    SET rptfont->m_fontname = rpt_times
    SET rptfont->m_bold = rpt_on
    SET _times12b0 = uar_rptcreatefont(_hreport,rptfont)
    SET rptfont->m_fontname = rpt_helvetica
    SET rptfont->m_pointsize = 6
    SET rptfont->m_bold = rpt_off
    SET _helvetica60 = uar_rptcreatefont(_hreport,rptfont)
  END ;Subroutine
  SUBROUTINE _createpens(dummy)
    SET rptpen->m_recsize = 16
    SET rptpen->m_penwidth = 0.014
    SET rptpen->m_penstyle = 0
    SET rptpen->m_rgbcolor = rpt_black
    SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
    SET rptpen->m_penwidth = 0.010
    SET _pen10s0c0 = uar_rptcreatepen(_hreport,rptpen)
  END ;Subroutine
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(size(orders->qual,5)))
   PLAN (d1
    WHERE  NOT ((orders->qual[d1.seq].f_catalog_cd IN (mf_tbed1_cd, mf_tbed2_cd, mf_tbed3_cd,
    mf_tbed4_cd, mf_tbed5_cd,
    mf_tbed6_cd, mf_tbed7_cd, mf_tbed8_cd, mf_tbed9_cd, mf_tbed10_cd,
    mf_tbed11_cd, mf_tbed12_cd, mf_tbed13_cd))))
   WITH nocounter
  ;end select
  IF (curqual > 0)
   CALL echorecord(orders)
   SET ms_filename = request->printer_name
   FOR (prt_ord = 1 TO size(orders->qual,5))
     DECLARE becont = i2
     SET becont = 0
     SET page_size = 10.5
     SET d0 = initializereport(0)
     SET los_days = concat(trim(cnvtstring(orders->los))," ","Days")
     SET d0 = requistion_head(rpt_render)
     SET d0 = transfuse_header(rpt_render)
     SET d0 = requistion_head_noencounter(rpt_render)
     SET remain_space = (page_size - _yoffset)
     SET d0 = print_header(rpt_render,remain_space,becont)
     SET d0 = print_header2(rpt_render,remain_space,becont)
     WHILE (becont=1)
       SET _yoffset = (page_size - ((((print_footer(rpt_calcheight)+ foot_page(rpt_calcheight))+
       print_top_foot_blank(rpt_calcheight))+ patient_note_olo(rpt_calcheight))+ patient_note_rad1(
        rpt_calcheight)))
       SET continued = "(continued)"
       SET d0 = print_top_foot_blank(rpt_render)
       SET d0 = patient_note_olo(rpt_render)
       SET d0 = patient_note_rad1(rpt_render)
       SET d0 = print_footer(rpt_render)
       SET d0 = foot_page(rpt_render)
       SET d0 = pagebreak(0)
       SET continued = ""
       SET d0 = requistion_head(rpt_render)
       SET d0 = transfuse_header(rpt_render)
       SET d0 = requistion_head_noencounter(rpt_render)
       SET remain_space = (page_size - _yoffset)
       CALL echo(build("becont1 = ",becont))
       CALL echo(build("remain_space = ",remain_space))
       CALL echo(build("becont2 = ",becont))
       SET d0 = print_header(rpt_render,remain_space,becont)
       SET d0 = print_header2(rpt_render,remain_space,becont)
       SET remain_space = (page_size - _yoffset)
       SET becont = 0
     ENDWHILE
     SET remain_space = (page_size - _yoffset)
     SET remain_space = (page_size - _yoffset)
     CALL echo(build("remain_space = ",remain_space))
     CALL echo(build("program1 = ",program1))
     CALL echo(build("size_orders = ",size(orders->qual[1].d_qual,5)))
     IF (size(orders->qual[prt_ord].d_qual,5)=0)
      SET d0 = order_section(rpt_render)
     ENDIF
     SET detail_cnt = 0
     FOR (fsub = 1 TO 31)
       FOR (ord_detail_cnt = 1 TO size(orders->qual[prt_ord].d_qual,5))
         IF ((((orders->qual[prt_ord].d_qual[ord_detail_cnt].group_seq=fsub)) OR (fsub=31
          AND (orders->qual[prt_ord].d_qual[ord_detail_cnt].print_ind=0))) )
          IF ((orders->qual[prt_ord].d_qual[ord_detail_cnt].value > " "))
           SET orders->qual[prt_ord].d_qual[ord_detail_cnt].print_ind = 1
           SET detail_cnt += 1
           IF (detail_cnt=1)
            SET d0 = order_section(rpt_render)
            IF ((orders->qual[prt_ord].f_fut_facilty_cd > 0))
             SET do = future_order_info(rpt_render)
            ENDIF
           ENDIF
           SET detail_label = concat(trim(orders->qual[prt_ord].d_qual[ord_detail_cnt].label_text),
            ":")
           SET value = trim(orders->qual[prt_ord].d_qual[ord_detail_cnt].value)
           SET remain_space = ((page_size - _yoffset) - ((((print_footer(rpt_calcheight)+ foot_page(
            rpt_calcheight))+ print_top_foot_blank(rpt_calcheight))+ patient_note_olo(rpt_calcheight)
           )+ patient_note_rad1(rpt_calcheight)))
           SET d0 = order_details(rpt_render,remain_space,becont)
           WHILE (becont=1)
             SET _yoffset = (page_size - ((((print_footer(rpt_calcheight)+ foot_page(rpt_calcheight))
             + print_top_foot_blank(rpt_calcheight))+ patient_note_olo(rpt_calcheight))+
             patient_note_rad1(rpt_calcheight)))
             SET continued = "(continued)"
             SET d0 = print_top_foot_blank(rpt_render)
             SET d0 = patient_note_olo(rpt_render)
             SET d0 = patient_note_rad1(rpt_render)
             SET d0 = print_footer(rpt_render)
             SET d0 = foot_page(rpt_render)
             SET d0 = pagebreak(0)
             SET d0 = order_section(rpt_render)
             SET continued = ""
             SET remain_space = (page_size - _yoffset)
             SET d0 = order_details(rpt_render,remain_space,becont)
             SET becont = 0
           ENDWHILE
          ENDIF
         ENDIF
       ENDFOR
     ENDFOR
     CALL echo(build("_Yoffset1 = ",_yoffset))
     SET total = ((order_comments_header(rpt_calcheight)+ _yoffset)+ order_comments(rpt_calcheight,
      remain_space,becont))
     CALL echo(build("total## = ",total))
     IF (((_yoffset+ (((((order_comments_header(rpt_calcheight)+ print_footer(rpt_calcheight))+
     foot_page(rpt_calcheight))+ print_top_foot_blank(rpt_calcheight))+ patient_note_olo(
      rpt_calcheight))+ patient_note_rad1(rpt_calcheight))) > page_size))
      SET _yoffset = (page_size - ((((print_footer(rpt_calcheight)+ foot_page(rpt_calcheight))+
      print_top_foot_blank(rpt_calcheight))+ patient_note_olo(rpt_calcheight))+ patient_note_rad1(
       rpt_calcheight)))
      SET d0 = print_top_foot_blank(rpt_render)
      SET d0 = patient_note_olo(rpt_render)
      SET d0 = patient_note_rad1(rpt_render)
      SET d0 = print_footer(rpt_render)
      SET d0 = foot_page(rpt_render)
      SET d0 = pagebreak(0)
      SET continued = ""
      CALL echo(build("_Yoffset2 = ",_yoffset))
      SET d0 = requistion_head(rpt_render)
      SET d0 = requistion_head_noencounter(rpt_render)
      SET d0 = transfuse_header(rpt_render)
      SET d0 = print_header(rpt_render,remain_space,becont)
      SET d0 = print_header2(rpt_render,remain_space,becont)
      SET d0 = print_top_foot_blank(rpt_render)
      SET d0 = order_comments_header(rpt_render)
      SET remain_space = (page_size - _yoffset)
      SET d0 = order_comments(rpt_render,remain_space,becont)
      SET remain_space = (page_size - _yoffset)
     ELSE
      SET d0 = print_top_foot_blank(rpt_render)
      SET d0 = order_comments_header(rpt_render)
      SET remain_space = (page_size - _yoffset)
      SET d0 = order_comments(rpt_render,remain_space,becont)
      SET remain_space = (page_size - _yoffset)
     ENDIF
     WHILE (becont=1)
       SET _yoffset = (page_size - ((((print_footer(rpt_calcheight)+ foot_page(rpt_calcheight))+
       print_top_foot_blank(rpt_calcheight))+ patient_note_olo(rpt_calcheight))+ patient_note_rad1(
        rpt_calcheight)))
       SET continued = "(continued)"
       SET d0 = print_top_foot_blank(rpt_render)
       SET d0 = patient_note_olo(rpt_render)
       SET d0 = patient_note_rad1(rpt_render)
       SET d0 = print_footer(rpt_render)
       SET d0 = foot_page(rpt_render)
       SET d0 = pagebreak(0)
       SET d0 = requistion_head(rpt_render)
       SET d0 = requistion_head_noencounter(rpt_render)
       SET d0 = transfuse_header(rpt_render)
       SET d0 = print_top_foot_blank(rpt_render)
       SET d0 = order_comments_header(rpt_render)
       SET remain_space = (page_size - _yoffset)
       SET d0 = order_comments(rpt_render,remain_space,becont)
       SET continued = ""
       SET remain_space = (page_size - _yoffset)
       SET becont = 0
     ENDWHILE
     SET remain_space = (page_size - _yoffset)
     SET _yoffset = (page_size - ((((print_footer(rpt_calcheight)+ foot_page(rpt_calcheight))+
     print_top_foot_blank(rpt_calcheight))+ patient_note_olo(rpt_calcheight))+ patient_note_rad1(
      rpt_calcheight)))
     SET d0 = print_top_foot_blank(rpt_render)
     SET d0 = patient_note_olo(rpt_render)
     SET d0 = patient_note_rad1(rpt_render)
     SET d0 = print_footer(rpt_render)
     SET d0 = foot_page(rpt_render)
     SET d0 = finalizereport(ms_filename)
   ENDFOR
   CALL echo("sent to printer")
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
