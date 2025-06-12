CREATE PROGRAM bhs_rpt_bactrim_allergy:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Beg Date:" = "CURDATE",
  "End Date:" = "CURDATE",
  "Report Type:" = "person"
  WITH outdev, s_beg_dt, s_end_dt,
  s_rep_type
 FREE RECORD m_rec
 RECORD m_rec(
   1 fac[*]
     2 f_cd = f8
     2 s_disp = vc
   1 pat[*]
     2 f_person_id = f8
     2 s_pat_name = vc
     2 s_mrn = vc
     2 s_dob = vc
     2 enc[*]
       3 f_encntr_id = f8
       3 s_fin = vc
       3 s_reg_dt_tm = vc
       3 s_disch_dt_tm = vc
       3 s_enc_type_clas = vc
       3 s_enc_type = vc
       3 ord[*]
         4 f_ord_id = f8
         4 f_ord_cat = f8
         4 s_ord_cat = vc
         4 s_disp_line = vc
         4 s_ord_status = vc
         4 s_ord_dt_tm = vc
       3 alg[*]
         4 f_alg_id = f8
         4 f_nomen_id = f8
         4 s_source_id = vc
         4 s_source_string = vc
         4 s_onset_dt_tm = vc
     2 s_alg_source_id = vc
     2 s_alg_source_string = vc
     2 s_alg_onset_dt_tm = vc
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
 DECLARE ms_filename = vc WITH protect, constant("bhs_rpt_bactrim_allergy.csv")
 DECLARE ms_report_type = vc WITH protect, constant(cnvtlower(trim( $S_REP_TYPE,3)))
 DECLARE mf_cs69_inpat = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!17006"))
 DECLARE mf_cs69_obs = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!73451"))
 DECLARE mf_cs72_sulf_trim = f8 WITH protect, constant(uar_get_code_by_cki("MUL.ORD!d00124"))
 DECLARE mf_cs319_fin = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE mf_cs319_mrn = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!8021"))
 DECLARE mf_cs6004_cancel = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3099"))
 DECLARE mf_cs6004_deleted = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!44311"))
 CALL echo(build2("mf_CS69_INPAT: ",mf_cs69_inpat))
 CALL echo(build2("mf_CS69_OBS: ",mf_cs69_obs))
 CALL echo(build2("mf_CS72_SULF_TRIM: ",mf_cs72_sulf_trim))
 CALL echo(build2("mf_CS6004_CANCEL: ",mf_cs6004_cancel))
 CALL echo(build2("mf_CS6004_DELETED: ",mf_cs6004_deleted))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_exp = i4 WITH protect, noconstant(0)
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
  CALL echo(build2("date range: ",ms_beg_dt_tm," to ",ms_end_dt_tm))
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=220
   AND cv.active_ind=1
   AND cv.end_effective_dt_tm > sysdate
   AND cv.cdf_meaning="FACILITY"
   AND cv.display_key IN ("BMC", "BWH", "BFMC", "BNH")
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   pl_cnt += 1,
   CALL alterlist(m_rec->fac,pl_cnt), m_rec->fac[pl_cnt].f_cd = cv.code_value,
   m_rec->fac[pl_cnt].s_disp = trim(cv.display,3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   orders o,
   allergy a,
   nomenclature n,
   encntr_alias ea1,
   encntr_alias ea2
  PLAN (e
   WHERE e.reg_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND e.active_ind=1
    AND e.encntr_type_class_cd IN (mf_cs69_obs, mf_cs69_inpat)
    AND expand(ml_exp,1,size(m_rec->fac,5),e.loc_facility_cd,m_rec->fac[ml_exp].f_cd))
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (o
   WHERE o.person_id=e.person_id
    AND o.encntr_id=e.encntr_id
    AND o.catalog_cd=mf_cs72_sulf_trim
    AND  NOT (o.order_status_cd IN (mf_cs6004_cancel, mf_cs6004_deleted)))
   JOIN (a
   WHERE a.person_id=e.person_id
    AND a.active_ind=1
    AND a.end_effective_dt_tm > o.orig_order_dt_tm)
   JOIN (n
   WHERE n.nomenclature_id=a.substance_nom_id
    AND n.active_ind=1
    AND n.source_string_keycap IN ("SULFA*", "SULFANOMIDE*"))
   JOIN (ea1
   WHERE ea1.encntr_id=e.encntr_id
    AND ea1.active_ind=1
    AND ea1.end_effective_dt_tm > sysdate
    AND ea1.encntr_alias_type_cd=mf_cs319_fin)
   JOIN (ea2
   WHERE ea2.encntr_id=e.encntr_id
    AND ea2.active_ind=1
    AND ea2.end_effective_dt_tm > sysdate
    AND ea2.encntr_alias_type_cd=mf_cs319_mrn)
  ORDER BY e.person_id, e.encntr_id, o.order_id
  HEAD REPORT
   pl_per = 0, pl_enc = 0, pl_ord = 0,
   pl_alg = 0
  HEAD e.person_id
   pl_enc = 0, pl_ord = 0, pl_alg = 0,
   pl_per += 1
   IF (pl_per > size(m_rec->pat,5))
    CALL alterlist(m_rec->pat,(pl_per+ 100))
   ENDIF
   m_rec->pat[pl_per].f_person_id = e.person_id, m_rec->pat[pl_per].s_pat_name = trim(p
    .name_full_formatted,3), m_rec->pat[pl_per].s_dob = trim(format(cnvtdatetimeutc(datetimezone(p
       .birth_dt_tm,p.birth_tz),1),"mm/dd/yy hh:mm;;d"),3),
   m_rec->pat[pl_per].s_mrn = trim(ea2.alias,3)
  HEAD e.encntr_id
   pl_ord = 0, pl_alg = 0, pl_enc += 1
   IF (pl_enc > size(m_rec->pat[pl_per].enc,5))
    CALL alterlist(m_rec->pat[pl_per].enc,pl_enc)
   ENDIF
   m_rec->pat[pl_per].enc[pl_enc].f_encntr_id = e.encntr_id, m_rec->pat[pl_per].enc[pl_enc].s_fin =
   trim(ea1.alias,3), m_rec->pat[pl_per].enc[pl_enc].s_reg_dt_tm = trim(format(e.reg_dt_tm,
     "mm/dd/yy hh:mm;;d"),3),
   m_rec->pat[pl_per].enc[pl_enc].s_disch_dt_tm = trim(format(e.disch_dt_tm,"mm/dd/yy hh:mm;;d"),3),
   m_rec->pat[pl_per].enc[pl_enc].s_enc_type_clas = trim(uar_get_code_display(e.encntr_type_class_cd),
    3), m_rec->pat[pl_per].enc[pl_enc].s_enc_type = trim(uar_get_code_display(e.encntr_type_cd),3)
  HEAD o.order_id
   pl_ord += 1,
   CALL alterlist(m_rec->pat[pl_per].enc[pl_enc].ord,pl_ord), m_rec->pat[pl_per].enc[pl_enc].ord[
   pl_ord].f_ord_id = o.order_id,
   m_rec->pat[pl_per].enc[pl_enc].ord[pl_ord].f_ord_cat = o.catalog_cd, m_rec->pat[pl_per].enc[pl_enc
   ].ord[pl_ord].s_ord_cat = trim(uar_get_code_display(o.catalog_cd),3), m_rec->pat[pl_per].enc[
   pl_enc].ord[pl_ord].s_disp_line = trim(o.order_detail_display_line,3),
   m_rec->pat[pl_per].enc[pl_enc].ord[pl_ord].s_ord_status = trim(uar_get_code_display(o
     .order_status_cd),3), m_rec->pat[pl_per].enc[pl_enc].ord[pl_ord].s_ord_dt_tm = trim(format(o
     .orig_order_dt_tm,"mm/dd/yy hh:mm;;d"),3)
  DETAIL
   pl_alg += 1,
   CALL alterlist(m_rec->pat[pl_per].enc[pl_enc].alg,pl_alg)
   IF (findstring(trim(n.source_identifier,3),m_rec->pat[pl_per].s_alg_source_id)=0)
    IF (pl_alg > 1)
     IF (textlen(trim(m_rec->pat[pl_per].s_alg_source_id,3)) > 0)
      m_rec->pat[pl_per].s_alg_source_id = concat(m_rec->pat[pl_per].s_alg_source_id,";")
     ENDIF
     IF (textlen(trim(m_rec->pat[pl_per].s_alg_source_string,3)) > 0)
      m_rec->pat[pl_per].s_alg_source_string = concat(m_rec->pat[pl_per].s_alg_source_string,";")
     ENDIF
     IF (textlen(trim(m_rec->pat[pl_per].s_alg_onset_dt_tm,3)) > 0)
      m_rec->pat[pl_per].s_alg_onset_dt_tm = concat(m_rec->pat[pl_per].s_alg_onset_dt_tm,";")
     ENDIF
    ENDIF
    m_rec->pat[pl_per].s_alg_source_id = concat(m_rec->pat[pl_per].s_alg_source_id,trim(n
      .source_identifier,3)), m_rec->pat[pl_per].s_alg_source_string = concat(m_rec->pat[pl_per].
     s_alg_source_string,trim(n.source_string,3))
    IF (a.onset_dt_tm=null)
     m_rec->pat[pl_per].s_alg_onset_dt_tm = concat(m_rec->pat[pl_per].s_alg_onset_dt_tm,trim(format(a
        .beg_effective_dt_tm,"mm/dd/yy;;d"),3))
    ELSE
     m_rec->pat[pl_per].s_alg_onset_dt_tm = concat(m_rec->pat[pl_per].s_alg_onset_dt_tm,trim(format(a
        .onset_dt_tm,"mm/dd/yy;;d"),3))
    ENDIF
   ENDIF
   m_rec->pat[pl_per].enc[pl_enc].alg[pl_alg].f_alg_id = a.allergy_id, m_rec->pat[pl_per].enc[pl_enc]
   .alg[pl_alg].f_nomen_id = n.nomenclature_id, m_rec->pat[pl_per].enc[pl_enc].alg[pl_alg].
   s_source_id = trim(n.source_identifier,3),
   m_rec->pat[pl_per].enc[pl_enc].alg[pl_alg].s_source_string = trim(n.source_string,3), m_rec->pat[
   pl_per].enc[pl_enc].alg[pl_alg].s_onset_dt_tm = trim(format(a.onset_dt_tm,"mm/dd/yy hh:mm;;d"),3)
  FOOT REPORT
   CALL alterlist(m_rec->pat,pl_per)
  WITH nocounter, expand = 1
 ;end select
 CALL echo(build2("ms_FILENAME: ",ms_filename))
 DECLARE ms_per = vc WITH protect, noconstant(" ")
 DECLARE ms_enc = vc WITH protect, noconstant(" ")
 DECLARE ms_ord = vc WITH protect, noconstant(" ")
 DECLARE ms_alg = vc WITH protect, noconstant(" ")
 IF (size(m_rec->pat,5))
  SET frec->file_name = ms_filename
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  IF (ms_report_type="person")
   SET ms_tmp = concat('"PAT_NAME","MRN","DOB","ORDER_CATALOG","ALLERGY(S)","SOURCE_ID(S)"')
   SET stat = cclio("WRITE",frec)
   DECLARE ml_per = i4 WITH protect, noconstant(0)
   DECLARE ml_enc = i4 WITH protect, noconstant(0)
   DECLARE ml_ord = i4 WITH protect, noconstant(0)
   FOR (ml_per = 1 TO size(m_rec->pat,5))
     SET ms_per = concat('"',m_rec->pat[ml_per].s_pat_name,'",','"',m_rec->pat[ml_per].s_mrn,
      '",','"',m_rec->pat[ml_per].s_dob,'",')
     SET ms_alg = concat('"',m_rec->pat[ml_per].s_alg_source_string,'",','"',m_rec->pat[ml_per].
      s_alg_source_id,
      '",','"',m_rec->pat[ml_per].s_alg_onset_dt_tm,'"')
     FOR (ml_enc = 1 TO size(m_rec->pat[ml_per].enc,5))
       FOR (ml_ord = 1 TO size(m_rec->pat[ml_per].enc[ml_enc].ord,5))
         SET ms_ord = concat('"',m_rec->pat[ml_per].enc[ml_enc].ord[ml_ord].s_ord_cat,'",')
       ENDFOR
     ENDFOR
     CALL echo(build2("ms_per: ",ms_per))
     CALL echo(build2("ms_enc: ",ms_enc))
     CALL echo(build2("ms_ord: ",ms_ord))
     CALL echo(build2("ms_alg: ",ms_alg))
     SET frec->file_buf = concat(ms_per,ms_enc,ms_ord,ms_alg,char(13),
      char(10))
     SET stat = cclio("WRITE",frec)
   ENDFOR
  ELSEIF (ms_report_type="encounter")
   SET ms_tmp = concat('"PAT_NAME","FIN","ENC_TYPE_CLASS","ORDER_CATALOG","ALLERGY(S)","ONSET_DT_TM"'
    )
   SET frec->file_buf = concat(ms_tmp,char(13),char(10))
   SET stat = cclio("WRITE",frec)
   DECLARE ml_per = i4 WITH protect, noconstant(0)
   DECLARE ml_enc = i4 WITH protect, noconstant(0)
   DECLARE ml_ord = i4 WITH protect, noconstant(0)
   FOR (ml_per = 1 TO size(m_rec->pat,5))
     SET ms_per = concat('"',m_rec->pat[ml_per].s_pat_name,'",')
     SET ms_alg = concat('"',m_rec->pat[ml_per].s_alg_source_string,'",','"',m_rec->pat[ml_per].
      s_alg_onset_dt_tm,
      '"')
     FOR (ml_enc = 1 TO size(m_rec->pat[ml_per].enc,5))
       SET ms_enc = concat('"',m_rec->pat[ml_per].enc[ml_enc].s_fin,'",','"',m_rec->pat[ml_per].enc[
        ml_enc].s_enc_type_clas,
        '",')
       FOR (ml_ord = 1 TO size(m_rec->pat[ml_per].enc[ml_enc].ord,5))
         SET ms_ord = concat('"',m_rec->pat[ml_per].enc[ml_enc].ord[ml_ord].s_ord_cat,'",','"',m_rec
          ->pat[ml_per].enc[ml_enc].ord[ml_ord].s_ord_dt_tm,
          '",')
       ENDFOR
       CALL echo(build2("ms_per: ",ms_per))
       CALL echo(build2("ms_enc: ",ms_enc))
       CALL echo(build2("ms_ord: ",ms_ord))
       CALL echo(build2("ms_alg: ",ms_alg))
       SET frec->file_buf = concat(ms_per,ms_enc,ms_ord,ms_alg,char(13),
        char(10))
       SET stat = cclio("WRITE",frec)
     ENDFOR
   ENDFOR
  ELSE
   SET ms_tmp = concat(
    '"PAT_NAME","MRN","DOB","FIN","REG_DT_TM","DISCH_DT_TM","ENC_TYPE_CLASS","ENC_TYPE","ORDER_CATALOG",',
    '"DETAIL_LINE","ORD_STATUS","ORD_DT_TM","ALLERGY(S)","SOURCE_ID(S)","ONSET_DT_TM"')
   SET frec->file_buf = concat(ms_tmp,char(13),char(10))
   SET stat = cclio("WRITE",frec)
   DECLARE ml_per = i4 WITH protect, noconstant(0)
   DECLARE ml_enc = i4 WITH protect, noconstant(0)
   DECLARE ml_ord = i4 WITH protect, noconstant(0)
   FOR (ml_per = 1 TO size(m_rec->pat,5))
     SET ms_per = concat('"',m_rec->pat[ml_per].s_pat_name,'",','"',m_rec->pat[ml_per].s_mrn,
      '",','"',m_rec->pat[ml_per].s_dob,'",')
     SET ms_alg = concat('"',m_rec->pat[ml_per].s_alg_source_string,'",','"',m_rec->pat[ml_per].
      s_alg_source_id,
      '",','"',m_rec->pat[ml_per].s_alg_onset_dt_tm,'"')
     FOR (ml_enc = 1 TO size(m_rec->pat[ml_per].enc,5))
      SET ms_enc = concat('"',m_rec->pat[ml_per].enc[ml_enc].s_fin,'",','"',m_rec->pat[ml_per].enc[
       ml_enc].s_reg_dt_tm,
       '",','"',m_rec->pat[ml_per].enc[ml_enc].s_disch_dt_tm,'",','"',
       m_rec->pat[ml_per].enc[ml_enc].s_enc_type_clas,'",','"',m_rec->pat[ml_per].enc[ml_enc].
       s_enc_type,'",')
      FOR (ml_ord = 1 TO size(m_rec->pat[ml_per].enc[ml_enc].ord,5))
        SET ms_ord = concat('"',m_rec->pat[ml_per].enc[ml_enc].ord[ml_ord].s_ord_cat,'",','"',m_rec->
         pat[ml_per].enc[ml_enc].ord[ml_ord].s_disp_line,
         '",','"',m_rec->pat[ml_per].enc[ml_enc].ord[ml_ord].s_ord_status,'",','"',
         m_rec->pat[ml_per].enc[ml_enc].ord[ml_ord].s_ord_dt_tm,'",')
        CALL echo(build2("ms_per: ",ms_per))
        CALL echo(build2("ms_enc: ",ms_enc))
        CALL echo(build2("ms_ord: ",ms_ord))
        CALL echo(build2("ms_alg: ",ms_alg))
        SET frec->file_buf = concat(ms_per,ms_enc,ms_ord,ms_alg,char(13),
         char(10))
        SET stat = cclio("WRITE",frec)
      ENDFOR
     ENDFOR
   ENDFOR
  ENDIF
  SET stat = cclio("CLOSE",frec)
  EXECUTE bhs_ma_email_file
  SET ms_tmp = concat("Bactrim file")
  CALL emailfile(value(ms_filename),ms_filename,"joe.echols@baystatehealth.org",ms_tmp,1)
 ENDIF
#exit_script
 FREE RECORD m_rec
END GO
