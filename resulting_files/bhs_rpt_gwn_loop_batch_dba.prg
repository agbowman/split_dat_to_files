CREATE PROGRAM bhs_rpt_gwn_loop_batch:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date:" = "CURDATE",
  "End Date:" = "CURDATE"
  WITH outdev, s_beg_dt, s_end_dt
 FREE RECORD m_rec
 RECORD m_rec(
   1 pat[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 s_fin = vc
     2 s_loop_start_dt_tm = vc
     2 s_care_plan = vc
     2 s_vis_action = vc
     2 s_pat_email = vc
     2 s_mrn = vc
     2 s_pat_name_first = vc
     2 s_pat_name_mid = vc
     2 s_pat_name_last = vc
     2 s_pat_dob = vc
     2 s_pat_sex = vc
     2 s_pat_phone_home = vc
     2 s_pat_phone_cell = vc
     2 s_pat_loc = vc
 ) WITH protect
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 )
 SET frec->file_buf = "w"
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  )
 ENDIF
 SET reply->status_data[1].status = "F"
 DECLARE mf_cs200_pulsox = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "PULSEOXIMETEREDONLY"))
 CALL echo(build2("mf_CS200_PULSOX: ",mf_cs200_pulsox))
 DECLARE mf_cs8_auth = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2628"))
 DECLARE mf_cs8_mod = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2636"))
 DECLARE mf_cs8_alter = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!16901"))
 DECLARE mf_cs36_spanish = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!24408"))
 DECLARE mf_cs43_home = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4017"))
 DECLARE mf_cs43_cell = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2510010055"))
 DECLARE mf_cs212_email = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!8010"))
 DECLARE mf_cs319_fin = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE mf_cs319_mrn = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!8021"))
 DECLARE mf_cs6003_order = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3094"))
 CALL echo(build2("mf_CS6003_ORDER: ",mf_cs6003_order))
 DECLARE mf_cs6004_ordered = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3102"))
 DECLARE mf_cs6004_canceled = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3099"))
 DECLARE mf_cs6004_deleted = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!44311"))
 DECLARE mf_cs6004_dc = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3101"))
 CALL echo(build2("mf_CS6004_ORDERED: ",mf_cs6004_ordered))
 CALL echo(build2("mf_CS6004_CANCELED: ",mf_cs6004_canceled))
 CALL echo(build2("mf_CS6004_DELETED: ",mf_cs6004_deleted))
 CALL echo(build2("mf_CS6004_DC: ",mf_cs6004_dc))
 DECLARE ms_loc_dir = vc WITH protect, constant(build(logical("bhscust"),
   "/ftp/bhs_rpt_gwn_loop_batch/"))
 DECLARE ms_file_name = vc WITH protect, constant(concat(ms_loc_dir,"bhs_gwn_covidloop_",trim(format(
     sysdate,"mmddyyhhmm;;d"),3),".csv"))
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ml_exp = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE ms_dcl = vc WITH protect, noconstant(" ")
 DECLARE mn_dcl_stat = i4 WITH protect, noconstant(0)
 EXECUTE bhs_check_domain
 IF (validate(request->batch_selection)=0)
  IF (((textlen(trim( $S_BEG_DT,3))=0) OR (textlen(trim( $S_END_DT,3))=0)) )
   SET ms_log = "Both dates must be filled out"
   GO TO exit_script
  ENDIF
  IF (cnvtdatetime( $S_BEG_DT) > cnvtdatetime( $S_END_DT))
   SET ms_log = "End date must be greater than Beg date"
   GO TO exit_script
  ENDIF
  SET ms_beg_dt_tm = concat(trim( $S_BEG_DT,3)," 00:00:00")
  SET ms_end_dt_tm = concat(trim( $S_END_DT,3)," 23:59:59")
 ELSE
  SET ms_beg_dt_tm = trim(format(datetimefind(cnvtlookbehind("1,D",sysdate),"D","B","B"),
    "dd-mmm-yyyy hh:mm:ss;;d"),3)
  SET ms_end_dt_tm = trim(format(datetimefind(cnvtlookbehind("1,D",sysdate),"D","E","E"),
    "dd-mmm-yyyy hh:mm:ss;;d"),3)
 ENDIF
 CALL echo(build2("beg dt: ",ms_beg_dt_tm," end dt: ",ms_end_dt_tm))
 SELECT INTO "nl:"
  FROM order_action oa,
   orders o,
   person p,
   person_name pn,
   encntr_alias ea1,
   encntr_alias ea2
  PLAN (oa
   WHERE oa.action_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND oa.action_type_cd=mf_cs6003_order)
   JOIN (o
   WHERE o.order_id=oa.order_id
    AND  NOT (o.order_status_cd IN (mf_cs6004_canceled, mf_cs6004_deleted))
    AND o.catalog_cd=mf_cs200_pulsox
    AND o.active_ind=1)
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (pn
   WHERE pn.person_id=p.person_id
    AND pn.active_ind=1)
   JOIN (ea1
   WHERE ea1.encntr_id=o.encntr_id
    AND ea1.active_ind=1
    AND ea1.end_effective_dt_tm > sysdate
    AND ea1.encntr_alias_type_cd=mf_cs319_fin)
   JOIN (ea2
   WHERE ea2.encntr_id=o.encntr_id
    AND ea2.active_ind=1
    AND ea2.end_effective_dt_tm > sysdate
    AND ea2.encntr_alias_type_cd=mf_cs319_mrn)
  ORDER BY p.person_id
  HEAD REPORT
   pl_cnt = 0
  HEAD p.person_id
   pl_cnt += 1
   IF (pl_cnt > size(m_rec->pat,5))
    CALL alterlist(m_rec->pat,(pl_cnt+ 10))
   ENDIF
   m_rec->pat[pl_cnt].f_person_id = o.person_id, m_rec->pat[pl_cnt].f_encntr_id = o.encntr_id, m_rec
   ->pat[pl_cnt].s_fin = trim(ea1.alias,3),
   m_rec->pat[pl_cnt].s_loop_start_dt_tm = trim(format(sysdate,"YYYY-MM-DD;;d"),3), m_rec->pat[pl_cnt
   ].s_care_plan = "Monitor", m_rec->pat[pl_cnt].s_vis_action = "Schedule",
   m_rec->pat[pl_cnt].s_mrn = trim(ea2.alias,3), m_rec->pat[pl_cnt].s_pat_name_first = trim(p
    .name_first,3), m_rec->pat[pl_cnt].s_pat_name_mid = trim(pn.name_middle,3),
   m_rec->pat[pl_cnt].s_pat_name_last = trim(p.name_last,3), m_rec->pat[pl_cnt].s_pat_dob = trim(
    format(p.birth_dt_tm,"YYYY-MM-DD;;d"),3), m_rec->pat[pl_cnt].s_pat_sex = substring(1,1,
    uar_get_code_display(p.sex_cd))
   IF (p.language_cd=mf_cs36_spanish)
    m_rec->pat[pl_cnt].s_pat_loc = "es_ES"
   ENDIF
  FOOT REPORT
   CALL alterlist(m_rec->pat,pl_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM phone ph
  PLAN (ph
   WHERE expand(ml_exp,1,size(m_rec->pat,5),ph.parent_entity_id,m_rec->pat[ml_exp].f_person_id)
    AND ph.parent_entity_name="PERSON"
    AND ph.active_ind=1
    AND ph.end_effective_dt_tm > sysdate
    AND ph.phone_type_cd IN (mf_cs43_home, mf_cs43_cell))
  ORDER BY ph.parent_entity_id, ph.phone_type_cd, ph.phone_type_seq
  HEAD ph.parent_entity_id
   ml_idx = locatevalsort(ml_loc,1,size(m_rec->pat,5),ph.parent_entity_id,m_rec->pat[ml_loc].
    f_person_id)
  HEAD ph.phone_type_cd
   IF (ph.phone_type_cd=mf_cs43_home)
    m_rec->pat[ml_idx].s_pat_phone_home = cnvtphone(ph.phone_num,ph.phone_format_cd)
   ELSEIF (ph.phone_type_cd=mf_cs43_cell)
    m_rec->pat[ml_idx].s_pat_phone_cell = cnvtphone(ph.phone_num,ph.phone_format_cd)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM address a
  PLAN (a
   WHERE expand(ml_exp,1,size(m_rec->pat,5),a.parent_entity_id,m_rec->pat[ml_exp].f_person_id)
    AND a.parent_entity_name="PERSON"
    AND a.active_ind=1
    AND a.end_effective_dt_tm > sysdate
    AND a.address_type_cd=mf_cs212_email)
  ORDER BY a.parent_entity_id, a.address_type_cd, a.address_type_seq
  HEAD a.parent_entity_id
   ml_idx = locatevalsort(ml_loc,1,size(m_rec->pat,5),a.parent_entity_id,m_rec->pat[ml_loc].
    f_person_id)
  HEAD a.address_type_cd
   m_rec->pat[ml_idx].s_pat_email = trim(a.street_addr,3)
  WITH nocounter, expand = 1
 ;end select
 CALL echo(build2("size: ",size(m_rec->pat,5)))
 CALL echo("CCLIO")
 IF (size(m_rec->pat,5) > 0)
  SET frec->file_name = ms_file_name
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = concat(
   '"visit_id","loop_start_date","careplan","visit_action","patient_email_address",',
   '"patient_med_rec_num","patient_name_first","patient_name_middle","patient_name_last",',
   '"patient_date_of_birth","patient_sex","patient_home_phone","patient_cell_phone",',
   '"patient_locale"',char(13),
   char(10))
  SET stat = cclio("WRITE",frec)
  FOR (ml_loop = 1 TO size(m_rec->pat,5))
   SET frec->file_buf = concat('"',m_rec->pat[ml_loop].s_fin,'",','"',m_rec->pat[ml_loop].
    s_loop_start_dt_tm,
    '",','"',m_rec->pat[ml_loop].s_care_plan,'",','"',
    m_rec->pat[ml_loop].s_vis_action,'",','"',m_rec->pat[ml_loop].s_pat_email,'",',
    '"',m_rec->pat[ml_loop].s_mrn,'",','"',m_rec->pat[ml_loop].s_pat_name_first,
    '",','"',m_rec->pat[ml_loop].s_pat_name_mid,'",','"',
    m_rec->pat[ml_loop].s_pat_name_last,'",','"',m_rec->pat[ml_loop].s_pat_dob,'",',
    '"',m_rec->pat[ml_loop].s_pat_sex,'",','"',m_rec->pat[ml_loop].s_pat_phone_home,
    '",','"',m_rec->pat[ml_loop].s_pat_phone_cell,'",','"',
    m_rec->pat[ml_loop].s_pat_loc,'"',char(13),char(10))
   SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
 ENDIF
 SET reply->status_data[1].status = "S"
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
