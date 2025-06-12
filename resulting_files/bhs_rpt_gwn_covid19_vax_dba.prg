CREATE PROGRAM bhs_rpt_gwn_covid19_vax:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date:" = "CURDATE",
  "End Date:" = "CURDATE",
  "Vaccine:" = "PFIZER",
  "Vaccine Dose:" = "P1"
  WITH outdev, s_beg_dt, s_end_dt,
  s_vax_manu, s_vax_dose
 FREE RECORD m_rec
 RECORD m_rec(
   1 pat[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 s_fin = vc
     2 s_loop_start_dt_tm = vc
     2 s_pat_email = vc
     2 s_mrn = vc
     2 s_pat_name_first = vc
     2 s_pat_name_mid = vc
     2 s_pat_name_last = vc
     2 s_pat_dob = vc
     2 s_pat_sex = vc
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
 DECLARE ms_vax_manu = vc WITH protect, constant(trim(cnvtupper( $S_VAX_MANU),3))
 DECLARE ms_vax_dose = vc WITH protect, constant(trim(cnvtupper( $S_VAX_DOSE),3))
 DECLARE ms_info_domain = vc WITH protect, noconstant("BHS_RPT_GWN_COVID19_VAX")
 DECLARE ms_info_name = vc WITH protect, constant(concat(ms_vax_manu,"_",ms_vax_dose,
   "_LAST_STOP_DT_TM"))
 CALL echo(build2(ms_info_domain," ",ms_info_name))
 DECLARE mf_cs8_auth = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2628"))
 DECLARE mf_cs8_mod = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2636"))
 DECLARE mf_cs8_alter = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!16901"))
 DECLARE mf_cs36_spanish = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!24408"))
 DECLARE mf_cs43_cell = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2510010055"))
 DECLARE mf_cs72_pfizer = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SARSCOV2COVID19MRNABNT162B2VAC"))
 DECLARE mf_cs72_moderna = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SARSCOV2COVID19MRNA1273VACCINE"))
 DECLARE mf_cs72_janssen = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SARSCOV2COVID19AD26VACCINE"))
 CALL echo(build2("mf_CS72_PFIZER: ",mf_cs72_pfizer))
 CALL echo(build2("mf_CS72_MODERNA: ",mf_cs72_moderna))
 CALL echo(build2("mf_CS72_JANSSEN: ",mf_cs72_janssen))
 DECLARE mf_cs212_email = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!8010"))
 DECLARE mf_cs319_fin = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE mf_cs319_mrn = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!8021"))
 DECLARE mf_cs331_pcp = f8 WITH protect, constant(uar_get_code_by("MEANING",331,"PCP"))
 DECLARE ms_loc_dir = vc WITH protect, constant(build(logical("bhscust"),
   "/ftp/bhs_rpt_gwn_covid19_vax/"))
 DECLARE mf_vax_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ml_exp = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE ms_dcl = vc WITH protect, noconstant(" ")
 DECLARE mn_dcl_stat = i4 WITH protect, noconstant(0)
 DECLARE ms_file_name = vc WITH protect, noconstant(" ")
 DECLARE ms_parse_pcp = vc WITH protect, noconstant(" ")
 DECLARE ms_parse_dose = vc WITH protect, noconstant(" ")
 DECLARE ms_proc_id = vc WITH protect, noconstant(" ")
 DECLARE ms_sponsor = vc WITH protect, noconstant(" ")
 DECLARE ms_log = vc WITH protect, noconstant(" ")
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 EXECUTE bhs_check_domain
 CALL echo("main prog")
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
  CALL echo("run from ops")
  SET mn_ops = 1
  SELECT INTO "nl:"
   FROM dm_info d
   WHERE d.info_domain=ms_info_domain
    AND d.info_name=ms_info_name
   DETAIL
    CALL echo("DETAIL"), ms_beg_dt_tm = trim(format(d.info_date,"dd-mmm-yyyy hh:mm;;d")),
    CALL echo(build2("ms_beg_dt_tm: ",ms_beg_dt_tm))
   WITH nocounter
  ;end select
  IF (((curqual < 1) OR (textlen(trim(ms_beg_dt_tm,3))=0)) )
   CALL echo("insert")
   SET ms_beg_dt_tm = trim(format(cnvtlookbehind("15,min",sysdate),"dd-mmm-yyyy hh:mm;;d"),3)
   INSERT  FROM dm_info d
    SET d.info_domain = ms_info_domain, d.info_name = ms_info_name, d.info_date = sysdate,
     d.updt_dt_tm = sysdate, d.updt_id = reqinfo->updt_id
    WITH nocounter
   ;end insert
   COMMIT
  ENDIF
  SET ms_end_dt_tm = trim(format(sysdate,"dd-mmm-yyyy hh:mm;;d"),3)
 ENDIF
 CALL echo(build2("beg dt: ",ms_beg_dt_tm," end dt: ",ms_end_dt_tm))
 IF (ms_vax_manu="MODERNA")
  SET mf_vax_cd = mf_cs72_moderna
 ELSEIF (ms_vax_manu="PFIZER")
  SET mf_vax_cd = mf_cs72_pfizer
 ELSEIF (ms_vax_manu="JANSSEN")
  SET mf_vax_cd = mf_cs72_janssen
 ENDIF
 CALL echo(build2("mf_vax_cd: ",mf_vax_cd))
 IF (ms_vax_manu="JANSSEN")
  SET ms_proc_id = "P1"
  SET ms_parse_dose = " 1=1"
  IF (ms_vax_dose="*NA*")
   SET ms_file_name = concat("bhs_gwn_",trim(cnvtlower(ms_vax_manu),3),"_na_",trim(format(sysdate,
      "mmddyyhhmm;;d"),3),".csv")
  ELSE
   SET ms_file_name = concat("bhs_gwn_",trim(cnvtlower(ms_vax_manu),3),"_",trim(format(sysdate,
      "mmddyyhhmm;;d"),3),".csv")
  ENDIF
 ELSEIF (ms_vax_dose="*1")
  SET ms_proc_id = "P1"
  SET ms_parse_dose =
  " od.oe_field_meaning = 'OTHER' and trim(od.oe_field_display_value, 3) = '1st' "
  IF (ms_vax_dose="*NA*")
   SET ms_file_name = concat("bhs_gwn_",trim(cnvtlower(ms_vax_manu),3),"_na_initial_",trim(format(
      sysdate,"mmddyyhhmm;;d"),3),".csv")
  ELSE
   SET ms_file_name = concat("bhs_gwn_",trim(cnvtlower(ms_vax_manu),3),"_initial_",trim(format(
      sysdate,"mmddyyhhmm;;d"),3),".csv")
  ENDIF
 ELSEIF (ms_vax_dose="*2")
  SET ms_proc_id = "P2"
  SET ms_parse_dose =
  " od.oe_field_meaning = 'OTHER' and trim(od.oe_field_display_value, 3) = '2nd' "
  IF (ms_vax_dose="*NA*")
   SET ms_file_name = concat("bhs_gwn_",trim(cnvtlower(ms_vax_manu),3),"_na_second_",trim(format(
      sysdate,"mmddyyhhmm;;d"),3),".csv")
  ELSE
   SET ms_file_name = concat("bhs_gwn_",trim(cnvtlower(ms_vax_manu),3),"_second_",trim(format(sysdate,
      "mmddyyhhmm;;d"),3),".csv")
  ENDIF
 ENDIF
 CALL echo(build2("ms_file_name: ",ms_file_name))
 IF (ms_vax_dose="*NA*")
  SET ms_sponsor = "Baystate Health"
  SET ms_parse_pcp = concat(" not exists(select ppr.prsnl_person_id ",
   " from person_prsnl_reltn ppr, prsnl pr "," where ppr.person_id = ce.person_id ",
   "   and ppr.active_ind = 1 ","   and ppr.end_effective_dt_tm > sysdate ",
   "   and ppr.person_prsnl_r_cd = mf_CS331_PCP ","   and pr.person_id = ppr.prsnl_person_id ",
   "   and pr.username in ('EN*'))")
 ELSE
  SET ms_sponsor = "Baystate Health Care Team"
  SET ms_parse_pcp = concat(" exists(select ppr.prsnl_person_id ",
   " from person_prsnl_reltn ppr, prsnl pr "," where ppr.person_id = ce.person_id ",
   "   and ppr.active_ind = 1 ","   and ppr.end_effective_dt_tm > sysdate ",
   "   and ppr.person_prsnl_r_cd = mf_CS331_PCP ","   and pr.person_id = ppr.prsnl_person_id ",
   "   and pr.username in ('EN*'))")
 ENDIF
 CALL echo(build2("ms_parse_pcp: ",ms_parse_pcp))
 SELECT INTO "nl:"
  FROM clinical_event ce,
   orders o,
   order_detail od,
   oe_format_fields oef,
   person p,
   person_name pn,
   encntr_alias ea1,
   encntr_alias ea2
  PLAN (ce
   WHERE ce.event_end_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND ce.result_status_cd IN (mf_cs8_auth, mf_cs8_mod, mf_cs8_alter)
    AND ce.valid_until_dt_tm > sysdate
    AND ce.event_cd=mf_vax_cd
    AND parser(ms_parse_pcp))
   JOIN (o
   WHERE o.order_id=ce.order_id)
   JOIN (od
   WHERE od.order_id=o.order_id
    AND parser(ms_parse_dose))
   JOIN (oef
   WHERE oef.oe_format_id=o.oe_format_id
    AND oef.oe_field_id=od.oe_field_id
    AND oef.clin_line_ind=1
    AND oef.label_text="Series Schedule")
   JOIN (p
   WHERE p.person_id=ce.person_id)
   JOIN (pn
   WHERE pn.person_id=p.person_id
    AND pn.active_ind=1)
   JOIN (ea1
   WHERE ea1.encntr_id=ce.encntr_id
    AND ea1.active_ind=1
    AND ea1.end_effective_dt_tm > sysdate
    AND ea1.encntr_alias_type_cd=mf_cs319_fin)
   JOIN (ea2
   WHERE ea2.encntr_id=ce.encntr_id
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
   m_rec->pat[pl_cnt].f_person_id = ce.person_id, m_rec->pat[pl_cnt].f_encntr_id = ce.encntr_id,
   m_rec->pat[pl_cnt].s_fin = trim(ea1.alias,3),
   m_rec->pat[pl_cnt].s_loop_start_dt_tm = trim(format(sysdate,"YYYY-MM-DD;;d"),3), m_rec->pat[pl_cnt
   ].s_mrn = trim(ea2.alias,3), m_rec->pat[pl_cnt].s_pat_name_first = trim(p.name_first,3),
   m_rec->pat[pl_cnt].s_pat_name_mid = trim(pn.name_middle,3), m_rec->pat[pl_cnt].s_pat_name_last =
   trim(p.name_last,3), m_rec->pat[pl_cnt].s_pat_dob = trim(format(p.birth_dt_tm,"YYYY-MM-DD;;d"),3),
   m_rec->pat[pl_cnt].s_pat_sex = substring(1,1,uar_get_code_display(p.sex_cd))
   IF (p.language_cd=mf_cs36_spanish)
    m_rec->pat[pl_cnt].s_pat_loc = "es_ES"
   ENDIF
  FOOT REPORT
   CALL alterlist(m_rec->pat,pl_cnt)
  WITH nocounter
 ;end select
 CALL echo(build2("size: ",size(m_rec->pat,5)))
 SELECT INTO "nl:"
  FROM phone ph
  PLAN (ph
   WHERE expand(ml_exp,1,size(m_rec->pat,5),ph.parent_entity_id,m_rec->pat[ml_exp].f_person_id)
    AND ph.parent_entity_name="PERSON"
    AND ph.active_ind=1
    AND ph.end_effective_dt_tm > sysdate
    AND ph.phone_type_cd=mf_cs43_cell)
  ORDER BY ph.parent_entity_id, ph.phone_type_cd, ph.phone_type_seq
  HEAD ph.parent_entity_id
   ml_idx = locatevalsort(ml_loc,1,size(m_rec->pat,5),ph.parent_entity_id,m_rec->pat[ml_loc].
    f_person_id)
  HEAD ph.phone_type_cd
   m_rec->pat[ml_idx].s_pat_phone_cell = cnvtphone(ph.phone_num,ph.phone_format_cd)
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
  SET frec->file_name = build(ms_loc_dir,ms_file_name)
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = concat('"visit_id","loop_start_date","procedure_id","patient_email_address",',
   '"patient_med_rec_num","patient_name_first","patient_name_middle","patient_name_last",',
   '"patient_date_of_birth","patient_sex","patient_cell_phone",','"patient_locale","sponsor_id"',char
   (13),
   char(10))
  SET stat = cclio("WRITE",frec)
  FOR (ml_loop = 1 TO size(m_rec->pat,5))
   SET frec->file_buf = concat('"',m_rec->pat[ml_loop].s_fin,'",','"',m_rec->pat[ml_loop].
    s_loop_start_dt_tm,
    '",','"',ms_proc_id,'",','"',
    m_rec->pat[ml_loop].s_pat_email,'",','"',m_rec->pat[ml_loop].s_mrn,'",',
    '"',m_rec->pat[ml_loop].s_pat_name_first,'",','"',m_rec->pat[ml_loop].s_pat_name_mid,
    '",','"',m_rec->pat[ml_loop].s_pat_name_last,'",','"',
    m_rec->pat[ml_loop].s_pat_dob,'",','"',m_rec->pat[ml_loop].s_pat_sex,'",',
    '"',m_rec->pat[ml_loop].s_pat_phone_cell,'",','"',m_rec->pat[ml_loop].s_pat_loc,
    '",','"',ms_sponsor,'"',char(13),
    char(10))
   SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
 ENDIF
 IF (mn_ops=1)
  UPDATE  FROM dm_info d
   SET d.info_date = cnvtlookahead("1,S",cnvtdatetime(ms_end_dt_tm)), d.updt_dt_tm = sysdate, d
    .updt_id = reqinfo->updt_id
   WHERE d.info_domain=ms_info_domain
    AND d.info_name=ms_info_name
   WITH nocounter
  ;end update
  COMMIT
 ENDIF
 SET reply->status_data[1].status = "S"
#exit_script
 CALL echo(ms_log)
 FREE RECORD m_rec
END GO
