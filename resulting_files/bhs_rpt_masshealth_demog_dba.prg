CREATE PROGRAM bhs_rpt_masshealth_demog:dba
 FREE RECORD m_rec
 RECORD m_rec(
   1 fac[*]
     2 s_fac = vc
     2 f_fac = f8
     2 l_pat_cnt = i4
     2 l_race_cnt = i4
     2 s_race_per = vc
     2 l_eth_cnt = i4
     2 s_eth_per = vc
     2 l_lang_spok_cnt = i4
     2 s_lang_spok_per = vc
     2 l_lang_writ_cnt = i4
     2 s_lang_writ_per = vc
     2 l_lang_pri_cnt = i4
     2 s_lang_pri_per = vc
     2 l_sex_orient_cnt = i4
     2 s_sex_orient_per = vc
     2 l_gender_id_cnt = i4
     2 s_gender_id_per = vc
   1 pat[*]
     2 s_fac = vc
     2 f_fac = f8
     2 s_cmrn = vc
     2 f_person_id = f8
     2 s_race = vc
     2 s_ethnicity = vc
     2 s_lang_spoken = vc
     2 s_lang_written = vc
     2 s_lang_pri = vc
     2 s_sex_orient = vc
     2 s_gender_id = vc
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
 DECLARE ms_beg_dt_tm = vc WITH protect, constant("01-JAN-2022 00:00:00")
 DECLARE ms_end_dt_tm = vc WITH protect, constant("31-DEC-2022 23:59:59")
 DECLARE mf_cs4_cmrn = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2621"))
 CALL echo(build2("mf_CS4_CMRN: ",mf_cs4_cmrn))
 DECLARE mf_cs8_active = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ACTIVE"))
 DECLARE mf_cs8_alter = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_cs8_auth = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_cs8_modified = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_cs319_fin = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE mf_cs355_user_def = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",355,"USERDEFINED"
   ))
 DECLARE mf_cs356_race1 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"RACE1"))
 DECLARE mf_cs356_lang_read = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,
   "LANGUAGEREAD"))
 DECLARE mf_cs356_ethnicity = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"ETHNICITY")
  )
 DECLARE mf_cs14003_sex_ori = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14003,
   "SHXSEXUALORIENTATION"))
 DECLARE mf_cs14003_gend_id = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14003,
   "SHXGENDERIDENTITY"))
 CALL echo(build2("mf_CS355_USER_DEF: ",mf_cs355_user_def))
 CALL echo(build2("mf_CS356_RACE1: ",mf_cs356_race1))
 CALL echo(build2("mf_CS356_LANG_READ: ",mf_cs356_lang_read))
 CALL echo(build2("mf_CS356_ETHNICITY: ",mf_cs356_ethnicity))
 CALL echo(build2("mf_CS14003_SEX_ORI: ",mf_cs14003_sex_ori))
 CALL echo(build2("mf_CS14003_GEND_ID: ",mf_cs14003_gend_id))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_exp = i4 WITH protect, noconstant(0)
 DECLARE ml_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE mf_tmp = f8 WITH protect, noconstant(0.0)
 CALL echo(build2("beg dt: ",ms_beg_dt_tm," end dt: ",ms_end_dt_tm))
 FOR (ml_loop = 1 TO size(requestin->list_0,5))
  SET ms_tmp = trim(requestin->list_0[ml_loop].corpmrn,3)
  WHILE (substring(1,1,ms_tmp)="0")
   SET ms_tmp = trim(substring(2,textlen(ms_tmp),ms_tmp))
   SET requestin->list_0[ml_loop].corpmrn = ms_tmp
  ENDWHILE
 ENDFOR
 CALL echo("main select")
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(requestin->list_0,5))),
   person_alias pa,
   person p,
   dummyt d2,
   person_info pi
  PLAN (d1)
   JOIN (pa
   WHERE (pa.alias=requestin->list_0[d1.seq].corpmrn)
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > sysdate
    AND pa.person_alias_type_cd=mf_cs4_cmrn)
   JOIN (p
   WHERE p.person_id=pa.person_id)
   JOIN (d2)
   JOIN (pi
   WHERE pi.person_id=p.person_id
    AND pi.active_ind=1
    AND pi.end_effective_dt_tm > sysdate
    AND pi.info_type_cd=mf_cs355_user_def
    AND pi.info_sub_type_cd IN (mf_cs356_race1, mf_cs356_lang_read, mf_cs356_ethnicity))
  ORDER BY d1.seq, pa.person_id, pi.info_sub_type_cd,
   pi.beg_effective_dt_tm DESC
  HEAD REPORT
   CALL echo("head report main"), pl_cnt = 0
  HEAD d1.seq
   null
  HEAD pa.person_id
   pl_cnt += 1
   IF (pl_cnt > size(m_rec->pat,5))
    CALL alterlist(m_rec->pat,(pl_cnt+ 1000))
   ENDIF
   m_rec->pat[pl_cnt].s_cmrn = trim(pa.alias,3), m_rec->pat[pl_cnt].s_fac = trim(requestin->list_0[d1
    .seq].facility,3), m_rec->pat[pl_cnt].f_person_id = pa.person_id
  HEAD pi.info_sub_type_cd
   IF (p.ethnic_grp_cd > 0.0)
    m_rec->pat[pl_cnt].s_ethnicity = trim(uar_get_code_display(p.ethnic_grp_cd),3)
   ELSEIF (pi.info_sub_type_cd=mf_cs356_ethnicity)
    m_rec->pat[pl_cnt].s_ethnicity = trim(uar_get_code_display(pi.value_cd),3)
   ENDIF
   IF (pi.info_sub_type_cd=mf_cs356_race1)
    m_rec->pat[pl_cnt].s_race = trim(uar_get_code_display(pi.value_cd),3)
   ENDIF
   IF (p.language_cd=0.0)
    m_rec->pat[pl_cnt].s_lang_spoken = "unknown"
   ELSE
    m_rec->pat[pl_cnt].s_lang_spoken = trim(uar_get_code_display(p.language_cd),3), m_rec->pat[pl_cnt
    ].s_lang_pri = trim(uar_get_code_display(p.language_cd),3)
   ENDIF
   IF (pi.info_sub_type_cd=mf_cs356_lang_read)
    m_rec->pat[pl_cnt].s_lang_spoken = trim(uar_get_code_display(p.language_cd),3), m_rec->pat[pl_cnt
    ].s_lang_written = trim(uar_get_code_display(p.language_cd),3)
   ENDIF
  FOOT  pa.person_id
   IF (size(m_rec->fac,5) > 0)
    ml_idx = locateval(ml_exp,1,size(m_rec->fac,5),m_rec->pat[pl_cnt].s_fac,m_rec->fac[ml_exp].s_fac)
   ELSE
    ml_idx = 0
   ENDIF
   IF (ml_idx=0)
    ml_idx = (size(m_rec->fac,5)+ 1),
    CALL alterlist(m_rec->fac,ml_idx)
   ENDIF
   m_rec->fac[ml_idx].s_fac = m_rec->pat[pl_cnt].s_fac, m_rec->fac[ml_idx].l_pat_cnt += 1
   IF (cnvtlower(m_rec->pat[pl_cnt].s_race) != "*unknown*")
    m_rec->fac[ml_idx].l_race_cnt += 1
   ENDIF
   IF (cnvtlower(m_rec->pat[pl_cnt].s_ethnicity) != "*unknown*")
    m_rec->fac[ml_idx].l_eth_cnt += 1
   ENDIF
   IF (cnvtlower(m_rec->pat[pl_cnt].s_ethnicity) != "*unknown*")
    m_rec->fac[ml_idx].l_lang_spok_cnt += 1, m_rec->fac[ml_idx].l_lang_writ_cnt += 1, m_rec->fac[
    ml_idx].l_lang_pri_cnt += 1
   ENDIF
   IF (cnvtlower(m_rec->pat[pl_cnt].s_ethnicity) != "*unknown*")
    m_rec->fac[ml_idx].l_sex_orient_cnt += 1
   ENDIF
   IF (cnvtlower(m_rec->pat[pl_cnt].s_ethnicity) != "*unknown*")
    m_rec->fac[ml_idx].l_gender_id_cnt += 1
   ENDIF
  FOOT REPORT
   CALL alterlist(m_rec->pat,pl_cnt)
  WITH nocounter, outerjoin = d2
 ;end select
 CALL echo("bhs demog")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_rec->pat,5))),
   bhs_demographics bd
  PLAN (d)
   JOIN (bd
   WHERE (bd.person_id=m_rec->pat[d.seq].f_person_id)
    AND bd.end_effective_dt_tm > sysdate
    AND bd.active_ind=1)
  ORDER BY d.seq, bd.person_id, bd.updt_dt_tm
  HEAD REPORT
   null
  HEAD bd.person_id
   null
  DETAIL
   IF (trim(bd.description)="race 1"
    AND textlen(trim(m_rec->pat[d.seq].s_race,3))=0)
    m_rec->pat[d.seq].s_race = trim(uar_get_code_display(bd.code_value),3)
   ENDIF
   IF (trim(bd.description)="language read"
    AND textlen(trim(m_rec->pat[d.seq].s_lang_written,3))=0)
    m_rec->pat[d.seq].s_lang_written = trim(uar_get_code_display(bd.code_value),3)
   ENDIF
   IF (trim(bd.description)="hispanic ind"
    AND textlen(trim(m_rec->pat[d.seq].s_ethnicity,3))=0)
    m_rec->pat[d.seq].s_ethnicity = trim(bd.display,3)
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("sexual orientation / gender id")
 SELECT INTO "nl:"
  sa.person_id, sr.task_assay_cd, sr.beg_effective_dt_tm,
  sr.end_effective_dt_tm, sr.response_type, sr.response_unit_cd,
  sr.response_val, n.source_string
  FROM (dummyt d  WITH seq = value(size(m_rec->pat,5))),
   shx_response sr,
   shx_activity sa,
   shx_alpha_response sar,
   nomenclature n
  PLAN (d)
   JOIN (sa
   WHERE (sa.person_id=m_rec->pat[d.seq].f_person_id)
    AND sa.active_ind=1
    AND sa.end_effective_dt_tm > sysdate)
   JOIN (sr
   WHERE sr.shx_activity_id=sa.shx_activity_id
    AND sr.active_ind=1
    AND sr.end_effective_dt_tm > sysdate
    AND sr.task_assay_cd IN (mf_cs14003_sex_ori, mf_cs14003_gend_id))
   JOIN (sar
   WHERE (sar.shx_response_id= Outerjoin(sr.shx_response_id))
    AND (sar.active_ind= Outerjoin(1))
    AND (sar.end_effective_dt_tm> Outerjoin(sysdate)) )
   JOIN (n
   WHERE (n.nomenclature_id= Outerjoin(sar.nomenclature_id))
    AND (n.active_ind= Outerjoin(1)) )
  ORDER BY d.seq, sa.person_id, sr.task_assay_cd,
   sar.beg_effective_dt_tm
  HEAD REPORT
   null
  HEAD sa.person_id
   null
  HEAD sr.task_assay_cd
   IF (sr.task_assay_cd=mf_cs14003_sex_ori)
    m_rec->pat[d.seq].s_sex_orient = trim(n.source_string,3)
   ELSEIF (sr.task_assay_cd=mf_cs14003_gend_id)
    m_rec->pat[d.seq].s_gender_id = trim(n.source_string,3)
   ENDIF
  WITH nocounter, expand = 2
 ;end select
 FOR (ml_loop = 1 TO size(m_rec->fac,5))
   SET mf_tmp = 0
   SET mf_tmp = ((cnvtreal(m_rec->fac[ml_loop].l_race_cnt)/ cnvtreal(m_rec->fac[ml_loop].l_pat_cnt))
    * 100)
   SET ms_tmp = trim(format(mf_tmp,"###.##%;R"),3)
   SET m_rec->fac[ml_loop].s_race_per = ms_tmp
   CALL echo(build2("Race: ",ms_tmp))
   SET mf_tmp = ((cnvtreal(m_rec->fac[ml_loop].l_eth_cnt)/ cnvtreal(m_rec->fac[ml_loop].l_pat_cnt))
    * 100)
   SET ms_tmp = trim(format(mf_tmp,"###.##%;R"),3)
   SET m_rec->fac[ml_loop].s_eth_per = ms_tmp
   SET mf_tmp = ((cnvtreal(m_rec->fac[ml_loop].l_lang_spok_cnt)/ cnvtreal(m_rec->fac[ml_loop].
    l_pat_cnt)) * 100)
   SET ms_tmp = trim(format(mf_tmp,"###.##%;R"),3)
   SET m_rec->fac[ml_loop].s_lang_spok_per = ms_tmp
   SET mf_tmp = ((cnvtreal(m_rec->fac[ml_loop].l_lang_writ_cnt)/ cnvtreal(m_rec->fac[ml_loop].
    l_pat_cnt)) * 100)
   SET ms_tmp = trim(format(mf_tmp,"###.##%;R"),3)
   SET m_rec->fac[ml_loop].s_lang_writ_per = ms_tmp
   SET mf_tmp = ((cnvtreal(m_rec->fac[ml_loop].l_lang_pri_cnt)/ cnvtreal(m_rec->fac[ml_loop].
    l_pat_cnt)) * 100)
   SET ms_tmp = trim(format(mf_tmp,"###.##%;R"),3)
   SET m_rec->fac[ml_loop].s_lang_pri_per = ms_tmp
   SET mf_tmp = ((cnvtreal(m_rec->fac[ml_loop].l_sex_orient_cnt)/ cnvtreal(m_rec->fac[ml_loop].
    l_pat_cnt)) * 100)
   SET ms_tmp = trim(format(mf_tmp,"###.##%;R"),3)
   SET m_rec->fac[ml_loop].s_sex_orient_per = ms_tmp
   SET mf_tmp = ((cnvtreal(m_rec->fac[ml_loop].l_gender_id_cnt)/ cnvtreal(m_rec->fac[ml_loop].
    l_pat_cnt)) * 100)
   SET ms_tmp = trim(format(mf_tmp,"###.##%;R"),3)
   SET m_rec->fac[ml_loop].s_gender_id_per = ms_tmp
 ENDFOR
 IF (size(m_rec->fac,5))
  SET frec->file_name = "je_anystat_masshealth_summary.csv"
  CALL echo(build2("filename: ",frec->file_name))
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET ms_tmp = concat(
   '"Facility","Total Facility Encounter Count","Race","Ethnicity","Preferred Spoken Language",',
   '"Preferred Written Language","Primary Language","Sexual Orientation","Gender Identity"')
  CALL echo(ms_tmp)
  SET frec->file_buf = concat(ms_tmp,char(13),char(10))
  SET stat = cclio("WRITE",frec)
  FOR (ml_loop = 1 TO size(m_rec->fac,5))
    SET ms_tmp = concat('"',m_rec->fac[ml_loop].s_fac,'",','"',trim(cnvtstring(m_rec->fac[ml_loop].
       l_pat_cnt),3),
     '",','"',m_rec->fac[ml_loop].s_race_per,'",','"',
     m_rec->fac[ml_loop].s_eth_per,'",','"',m_rec->fac[ml_loop].s_lang_spok_per,'",',
     '"',m_rec->fac[ml_loop].s_lang_writ_per,'",','"',m_rec->fac[ml_loop].s_lang_pri_per,
     '",','"',m_rec->fac[ml_loop].s_sex_orient_per,'",','"',
     m_rec->fac[ml_loop].s_gender_id_per,'"')
    CALL echo(ms_tmp)
    SET frec->file_buf = concat(ms_tmp,char(13),char(10))
    SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
 ENDIF
 IF (size(m_rec->pat,5))
  SET stat = initrec(frec)
  SET frec->file_name = "je_anystat_masshealth_detail.csv"
  CALL echo(build2("filename: ",frec->file_name))
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET ms_tmp = concat(
   '"CMRN","Facility","Cerner Person ID","Race","Ethnicity","Preferred Spoken Language",',
   '"Preferred Written Language","Primary Language","Sexual Orientation","Gender Identity"')
  CALL echo(ms_tmp)
  SET frec->file_buf = concat(ms_tmp,char(13),char(10))
  SET stat = cclio("WRITE",frec)
  FOR (ml_loop = 1 TO size(m_rec->pat,5))
    SET ms_tmp = concat('"',m_rec->pat[ml_loop].s_cmrn,'",','"',m_rec->pat[ml_loop].s_fac,
     '",','"',trim(cnvtstring(m_rec->pat[ml_loop].f_person_id),3),'",','"',
     m_rec->pat[ml_loop].s_race,'",','"',m_rec->pat[ml_loop].s_ethnicity,'",',
     '"',m_rec->pat[ml_loop].s_lang_spoken,'",','"',m_rec->pat[ml_loop].s_lang_written,
     '",','"',m_rec->pat[ml_loop].s_lang_pri,'",','"',
     m_rec->pat[ml_loop].s_sex_orient,'",','"',m_rec->pat[ml_loop].s_gender_id,'"')
    CALL echo(ms_tmp)
    SET frec->file_buf = concat(ms_tmp,char(13),char(10))
    SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
 ENDIF
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
