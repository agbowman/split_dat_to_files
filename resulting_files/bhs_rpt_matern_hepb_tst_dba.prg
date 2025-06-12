CREATE PROGRAM bhs_rpt_matern_hepb_tst:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Facility:" = 0,
  "Delivery Date lookback (hrs) :" = 24
  WITH outdev, mf_facility, ml_hrs
 DECLARE mf_cs72_heptransresult_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "HEPATITISBTRANSCRIBEDRESULT"))
 DECLARE mf_cs72_hepbsurfaceag_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "HEPBSURFACEAG"))
 DECLARE mf_cs72_datetimeofbirth_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",72,
   "Date, Time of Birth:"))
 DECLARE mf_cs4_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE mf_cs8_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_cs8_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_cs8_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_cs8_active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ACTIVE"))
 DECLARE mf_cs351_family_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",351,"FAMILY"))
 DECLARE mf_cs40_child_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",40,"CHILD"))
 DECLARE mf_cs72_hepatitisbimmuneglobulin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   72,"HEPATITISBIMMUNEGLOBULIN"))
 DECLARE mf_cs72_hepatitisbpediatricvac_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   72,"HEPATITISBPEDIATRICVACCINE"))
 DECLARE mf_cs72_hepbsurfagneutra_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "HEPATITISBSURFACEAGNEUTRALIZATION"))
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE ms_outdev = vc WITH protect, noconstant(value( $OUTDEV))
 DECLARE ml_ops_ind = i4 WITH protect, noconstant(0)
 DECLARE mf_beg_dt_tm = f8 WITH protect, noconstant(0.0)
 DECLARE mf_end_dt_tm = f8 WITH protect, noconstant(0.0)
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 f_mom_person_id = f8
     2 s_mom_name = vc
     2 f_delivery_date = f8
     2 s_mom_cmrn = vc
     2 l_ch_cnt = i4
     2 qual[*]
       3 f_child_person_id = f8
       3 s_child_name = vc
       3 s_child_cmrn = vc
       3 s_hepb_immuneglob_dt = vc
       3 s_hepb_pediatricvac_dt = vc
 )
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 )
 IF (ms_outdev="OPS")
  SET mf_beg_dt_tm = cnvtdatetime((curdate - 1),070000)
  SET mf_end_dt_tm = cnvtdatetime(curdate,065900)
 ELSE
  SET mf_beg_dt_tm = cnvtdatetime(curdate,(curtime3 - ((( $ML_HRS * 100) * 60) * 60)))
  SET mf_end_dt_tm = cnvtdatetime(curdate,curtime3)
 ENDIF
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   person_alias pa,
   clinical_event ce1,
   clinical_event ce2,
   ce_date_result cdr,
   encounter e2
  PLAN (e
   WHERE (e.loc_facility_cd= $MF_FACILITY)
    AND e.reg_dt_tm > cnvtdatetime((curdate - 365),0))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (pa
   WHERE pa.person_id=outerjoin(p.person_id)
    AND pa.active_ind=outerjoin(1)
    AND pa.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
    AND pa.person_alias_type_cd=outerjoin(mf_cs4_cmrn_cd))
   JOIN (ce2
   WHERE ce2.person_id=p.person_id
    AND ce2.event_cd=mf_cs72_datetimeofbirth_cd
    AND ce2.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ce2.result_status_cd IN (mf_cs8_auth_cd, mf_cs8_modified_cd, mf_cs8_altered_cd,
   mf_cs8_active_cd))
   JOIN (cdr
   WHERE cdr.event_id=ce2.event_id
    AND cdr.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND cdr.result_dt_tm BETWEEN cnvtdatetime(mf_beg_dt_tm) AND cnvtdatetime(mf_end_dt_tm))
   JOIN (e2
   WHERE e2.person_id=p.person_id
    AND e2.reg_dt_tm > cnvtdatetime((curdate - 365),0))
   JOIN (ce1
   WHERE ce1.encntr_id=e2.encntr_id
    AND cnvtupper(trim(ce1.result_val,3))="POSITIVE"
    AND ce1.event_cd IN (mf_cs72_hepbsurfaceag_cd, mf_cs72_heptransresult_cd,
   mf_cs72_hepbsurfagneutra_cd)
    AND ce1.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ce1.result_status_cd IN (mf_cs8_auth_cd, mf_cs8_modified_cd, mf_cs8_altered_cd,
   mf_cs8_active_cd))
  ORDER BY e.person_id
  HEAD REPORT
   m_rec->l_cnt = 0
  HEAD e.person_id
   m_rec->l_cnt = (m_rec->l_cnt+ 1), stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->
   l_cnt].f_delivery_date = cdr.result_dt_tm,
   m_rec->qual[m_rec->l_cnt].f_mom_person_id = p.person_id, m_rec->qual[m_rec->l_cnt].s_mom_name =
   trim(p.name_full_formatted,3), m_rec->qual[m_rec->l_cnt].s_mom_cmrn = trim(pa.alias,3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM person_person_reltn ppr,
   person p,
   person_alias pa
  PLAN (ppr
   WHERE expand(ml_idx1,1,m_rec->l_cnt,ppr.person_id,m_rec->qual[ml_idx1].f_mom_person_id)
    AND ppr.active_ind=1
    AND ppr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ppr.person_reltn_cd=mf_cs40_child_cd
    AND ppr.person_reltn_type_cd=mf_cs351_family_cd)
   JOIN (p
   WHERE p.person_id=ppr.related_person_id
    AND p.birth_dt_tm > cnvtdatetime((curdate - 30),0))
   JOIN (pa
   WHERE pa.person_id=outerjoin(p.person_id)
    AND pa.active_ind=outerjoin(1)
    AND pa.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3))
    AND pa.person_alias_type_cd=outerjoin(mf_cs4_cmrn_cd))
  ORDER BY ppr.person_id, p.person_id, pa.beg_effective_dt_tm
  HEAD ppr.person_id
   ml_idx2 = locateval(ml_idx1,1,m_rec->l_cnt,ppr.person_id,m_rec->qual[ml_idx1].f_mom_person_id),
   m_rec->qual[ml_idx1].l_ch_cnt = 0
  HEAD p.person_id
   m_rec->qual[ml_idx1].l_ch_cnt = (m_rec->qual[ml_idx1].l_ch_cnt+ 1), stat = alterlist(m_rec->qual[
    ml_idx1].qual,m_rec->qual[ml_idx1].l_ch_cnt), m_rec->qual[ml_idx1].qual[m_rec->qual[ml_idx1].
   l_ch_cnt].f_child_person_id = p.person_id,
   m_rec->qual[ml_idx1].qual[m_rec->qual[ml_idx1].l_ch_cnt].s_child_name = trim(p.name_full_formatted,
    3), m_rec->qual[ml_idx1].qual[m_rec->qual[ml_idx1].l_ch_cnt].s_child_cmrn = trim(pa.alias,3)
  WITH nocounter
 ;end select
 IF ((m_rec->l_cnt > 0))
  FOR (ml_idx1 = 1 TO m_rec->l_cnt)
    IF ((m_rec->qual[ml_idx1].l_ch_cnt > 0))
     FOR (ml_idx2 = 1 TO m_rec->qual[ml_idx1].l_ch_cnt)
       SELECT INTO "nl:"
        FROM clinical_event ce
        PLAN (ce
         WHERE (ce.person_id=m_rec->qual[ml_idx1].qual[ml_idx2].f_child_person_id)
          AND ce.event_cd IN (mf_cs72_hepatitisbimmuneglobulin_cd, mf_cs72_hepatitisbpediatricvac_cd)
          AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
          AND ce.result_status_cd IN (mf_cs8_auth_cd, mf_cs8_modified_cd, mf_cs8_altered_cd,
         mf_cs8_active_cd))
        ORDER BY ce.event_cd, ce.event_end_dt_tm
        HEAD ce.event_cd
         IF (ce.event_cd=mf_cs72_hepatitisbimmuneglobulin_cd)
          m_rec->qual[ml_idx1].qual[ml_idx2].s_hepb_immuneglob_dt = format(ce.event_end_dt_tm,
           "MM/DD/YYYY;;D")
         ELSEIF (ce.event_cd=mf_cs72_hepatitisbpediatricvac_cd)
          m_rec->qual[ml_idx1].qual[ml_idx2].s_hepb_pediatricvac_dt = format(ce.event_end_dt_tm,
           "MM/DD/YYYY;;D")
         ENDIF
        WITH nocounter
       ;end select
     ENDFOR
    ENDIF
  ENDFOR
 ENDIF
 IF (ms_outdev="OPS")
  SET frec->file_name = concat("bhs_rpt_pcm_matern_hepb_",format(sysdate,"MMDDYYYY;;q"),".csv")
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"MOM_NAME",','"MOM_CMRN",','"DATE_OF_DELIVERY",','"BABY_CMRN",',
   '"HEPB_IMMUNE_GLOBULIN",',
   '"HEPB_PEDIATRIC_VACCINE"',char(13),char(10))
  SET stat = cclio("WRITE",frec)
  FOR (ml_idx1 = 1 TO m_rec->l_cnt)
    IF ((m_rec->qual[ml_idx1].l_ch_cnt > 0))
     FOR (ml_idx2 = 1 TO m_rec->qual[ml_idx1].l_ch_cnt)
      SET frec->file_buf = concat('"',m_rec->qual[ml_idx1].s_mom_name,'","',m_rec->qual[ml_idx1].
       s_mom_cmrn,'","',
       trim(substring(1,20,format(m_rec->qual[ml_idx1].f_delivery_date,";;q"))),'","',m_rec->qual[
       ml_idx1].qual[ml_idx2].s_child_cmrn,'","',trim(substring(1,20,m_rec->qual[ml_idx1].qual[
         ml_idx2].s_hepb_immuneglob_dt)),
       '","',trim(substring(1,20,m_rec->qual[ml_idx1].qual[ml_idx2].s_hepb_pediatricvac_dt)),'"',char
       (13),char(10))
      SET stat = cclio("WRITE",frec)
     ENDFOR
    ELSE
     SET frec->file_buf = concat('"',m_rec->qual[ml_idx1].s_mom_name,'","',m_rec->qual[ml_idx1].
      s_mom_cmrn,'","',
      trim(substring(1,20,format(m_rec->qual[ml_idx1].f_delivery_date,";;q"))),'","','","','","','"',
      char(13),char(10))
     SET stat = cclio("WRITE",frec)
    ENDIF
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  DECLARE ms_tmp = vc WITH protect, noconstant("")
  DECLARE ms_email = vc WITH protect, constant("angelce.lazovski@bhs.org")
  EXECUTE bhs_ma_email_file
  SET ms_tmp = concat("HepB Report: ",format(cnvtdatetime(curdate,curtime3),"YYYYMMDDHHMMSS;;q"))
  CALL emailfile(value(frec->file_name),frec->file_name,ms_email,ms_tmp,1)
 ELSE
  IF ((m_rec->l_cnt > 0))
   SELECT INTO  $OUTDEV
    mom_name = trim(substring(1,100,m_rec->qual[d.seq].s_mom_name)), mom_cmrn = trim(substring(1,20,
      m_rec->qual[d.seq].s_mom_cmrn)), date_of_delivery = trim(substring(1,20,format(m_rec->qual[d
       .seq].f_delivery_date,";;q"))),
    baby_cmrn = trim(substring(1,20,m_rec->qual[d.seq].qual[d2.seq].s_child_cmrn)),
    hepb_immune_globulin = trim(substring(1,20,m_rec->qual[d.seq].qual[d2.seq].s_hepb_immuneglob_dt)),
    hepb_pediatric_vaccine = trim(substring(1,20,m_rec->qual[d.seq].qual[d2.seq].
      s_hepb_pediatricvac_dt))
    FROM (dummyt d  WITH seq = m_rec->l_cnt),
     (dummyt d2  WITH seq = 1)
    PLAN (d
     WHERE maxrec(d2,m_rec->qual[d.seq].l_ch_cnt))
     JOIN (d2)
    ORDER BY mom_name
    WITH nocounter, maxcol = 20000, format,
     separator = " ", memsort
   ;end select
  ELSE
   SELECT INTO  $OUTDEV
    FROM dummyt
    HEAD REPORT
     msg1 = "Report finished successfully. No patients qualified.", col 0,
     "{PS/792 0 translate 90 rotate/}",
     y_pos = 18, row + 1, "{F/1}{CPI/7}",
     CALL print(calcpos(36,(y_pos+ 0))), msg1
    WITH dio = 08
   ;end select
  ENDIF
 ENDIF
 CALL echorecord(m_rec)
#exit_script
END GO
