CREATE PROGRAM bhs_rpt_careware_hiv:dba
 DECLARE mf_cs72_hivrnaultrasensitive_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "HIVRNAULTRASENSITIVE"))
 DECLARE mf_cs72_abscd4helpertcells_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ABSCD4HELPERTCELLS"))
 DECLARE mf_cs72_cd4helpertcells_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CD4HELPERTCELLS"))
 DECLARE mf_cs72_rprtiterresult_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "RPRTITERRESULT"))
 DECLARE mf_cs72_syphilisscreenbycia_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SYPHILISSCREENBYCIA"))
 DECLARE mf_cs72_syphilistesting_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SYPHILISTESTING"))
 DECLARE mf_cs72_chlamydiaamplifiedprobe_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   72,"CHLAMYDIAAMPLIFIEDPROBE"))
 DECLARE mf_cs72_chlamydiagcamplifiedprobe_cd = f8 WITH protect, constant(uar_get_code_by(
   "DISPLAYKEY",72,"CHLAMYDIAGCAMPLIFIEDPROBE"))
 DECLARE mf_cs72_gcamplifiedprobe_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "GCAMPLIFIEDPROBE"))
 DECLARE mf_cs72_tbcellularbloodtesttspot_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   72,"TBCELLULARBLOODTESTTSPOT"))
 DECLARE mf_cs72_cytologyreportsgynpaptest_cd = f8 WITH protect, constant(uar_get_code_by(
   "DISPLAYKEY",72,"CYTOLOGYREPORTSGYNPAPTEST"))
 DECLARE mf_cs72_hcvquantlogresult_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "HCVQUANTLOGRESULT"))
 DECLARE mf_cs72_hepatitiscrnapcrquantitative_cd = f8 WITH protect, constant(uar_get_code_by(
   "DISPLAYKEY",72,"HEPATITISCRNAPCRQUANTITATIVE"))
 DECLARE mf_cs72_antihbsquant_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ANTIHBSQUANT"))
 DECLARE mf_cs72_hepatitisbsurfaceantigen_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   72,"HEPATITISBSURFACEANTIGEN"))
 DECLARE mf_cs72_antihavigg_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ANTIHAVIGG"))
 DECLARE mf_cs72_antihepatitisaigm_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ANTIHEPATITISAIGM"))
 DECLARE mf_cs72_hivabag4thgeneration_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "HIVABAG4THGENERATION"))
 DECLARE mf_cs72_hepbcoreab_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "HEPBCOREAB"))
 DECLARE mf_cs72_hepcvirusab_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "HEPCVIRUSAB"))
 DECLARE mf_cs72_neisseriagonorrhoeaeurineampprobe_cd = f8 WITH protect, constant(uar_get_code_by(
   "DISPLAYKEY",72,"NEISSERIAGONORRHOEAEURINEAMPPROBE"))
 DECLARE mf_cs72_chlamydiatrachomatisurineampprobe_cd = f8 WITH protect, constant(uar_get_code_by(
   "DISPLAYKEY",72,"CHLAMYDIATRACHOMATISURINEAMPPROBE"))
 DECLARE mf_cs72_cytologyreportsgeneral_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   72,"CYTOLOGYREPORTSGENERAL"))
 DECLARE mf_cs72_hepatitisbsurfaceab_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "HEPATITISBSURFACEAB"))
 DECLARE mf_cs72_hepatitisbcoreabtotal_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "HEPATITISBCOREABTOTAL"))
 DECLARE mf_cs72_hepatitiscab_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "HEPATITISCAB"))
 DECLARE mf_cs8_active_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2627"))
 DECLARE mf_cs8_altered_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!16901"))
 DECLARE mf_cs8_auth_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2628"))
 DECLARE mf_cs8_modified_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2636"))
 DECLARE mf_cs319_fin_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE mf_cs319_mrn_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!8021"))
 DECLARE mf_cs400_icd10_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4101498946"
   ))
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE mf_start_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_stop_dt = f8 WITH protect, noconstant(0.0)
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 s_fin = vc
     2 s_mrn = vc
     2 s_per_fname = vc
     2 s_per_lname = vc
     2 s_per_dob = vc
     2 s_enc_loc = vc
     2 l_lcnt = i4
     2 lqual[*]
       3 f_event_id = f8
       3 s_test_name = vc
       3 s_performed_dt = vc
       3 s_result = vc
 )
 IF (cnvtupper(trim( $2,3))="CURDATE*")
  SET mf_start_dt = cnvtdatetime(concat(format(datetimeadd(cnvtdatetime(sysdate),cnvtint(substring(8,
        5,trim( $2,3)))),"DD-MMM-YYYY;;d")," 00:00:00"))
 ELSEIF (cnvtupper(trim( $2,3))="LASTWEEK")
  SET mf_start_dt = cnvtdatetime(format(datetimefind(cnvtdatetime((curdate - 7),0),"W","B","B"),
    "DD-MMM-YYYY HH:MM:SS;;d"))
 ELSEIF (cnvtupper(trim( $2,3))="LASTMONTH")
  SET mf_start_dt = cnvtdatetime(format(cnvtlookbehind("1,D",cnvtdatetime(format(cnvtdatetime(curdate,
        0),"01-MMM-YYYY;;d"))),"01-MMM-YYYY 00:00:00;;d"))
 ELSE
  SET mf_start_dt = cnvtdatetime(concat(trim( $2,3)," 00:00:00"))
 ENDIF
 IF (cnvtupper(trim( $3,3))="CURDATE*")
  SET mf_stop_dt = cnvtdatetime(concat(format(datetimeadd(cnvtdatetime(sysdate),cnvtint(substring(8,5,
        trim( $3,3)))),"DD-MMM-YYYY;;d")," 23:59:59"))
 ELSEIF (cnvtupper(trim( $3,3))="LASTWEEK")
  SET mf_stop_dt = cnvtdatetime(format(datetimefind(cnvtdatetime((curdate - 7),0),"W","E","E"),
    "DD-MMM-YYYY HH:MM:SS;;d"))
 ELSEIF (cnvtupper(trim( $3,3))="LASTMONTH")
  SET mf_stop_dt = cnvtdatetime(format(cnvtlookbehind("1,D",cnvtdatetime(format(cnvtdatetime(curdate,
        0),"01-MMM-YYYY;;d"))),"DD-MMM-YYYY 23:59:59;;d"))
 ELSE
  SET mf_stop_dt = cnvtdatetime(concat(trim( $3,3)," 23:59:59"))
 ENDIF
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   diagnosis d,
   nomenclature n,
   encntr_alias ea1,
   encntr_alias ea2
  PLAN (e
   WHERE e.disch_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
    AND e.active_ind=1
    AND e.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (d
   WHERE d.encntr_id=e.encntr_id
    AND d.active_ind=1
    AND d.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (n
   WHERE n.nomenclature_id=d.nomenclature_id
    AND n.source_identifier IN ("D84.9", "Z21", "B20")
    AND n.source_vocabulary_cd=mf_cs400_icd10_cd)
   JOIN (ea1
   WHERE ea1.encntr_id=e.encntr_id
    AND ea1.active_ind=1
    AND ea1.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ea1.encntr_alias_type_cd=mf_cs319_fin_cd)
   JOIN (ea2
   WHERE ea2.encntr_id=e.encntr_id
    AND ea2.active_ind=1
    AND ea2.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ea2.encntr_alias_type_cd=mf_cs319_mrn_cd)
  ORDER BY e.encntr_id
  HEAD e.encntr_id
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
   f_encntr_id = e.encntr_id,
   m_rec->qual[m_rec->l_cnt].f_person_id = e.person_id, m_rec->qual[m_rec->l_cnt].s_per_fname = trim(
    p.name_first_key,3), m_rec->qual[m_rec->l_cnt].s_per_lname = trim(p.name_last_key,3),
   m_rec->qual[m_rec->l_cnt].s_per_dob = trim(format(p.birth_dt_tm,"MM/DD/YYYY;;q"),3), m_rec->qual[
   m_rec->l_cnt].s_enc_loc = trim(uar_get_code_display(e.loc_facility_cd),3), m_rec->qual[m_rec->
   l_cnt].s_fin = trim(ea1.alias,3),
   m_rec->qual[m_rec->l_cnt].s_mrn = trim(ea2.alias,3)
  WITH nocounter
 ;end select
 FOR (ml_idx1 = 1 TO m_rec->l_cnt)
   SELECT INTO "nl:"
    FROM clinical_event ce
    PLAN (ce
     WHERE (ce.encntr_id=m_rec->qual[ml_idx1].f_encntr_id)
      AND ce.view_level=1
      AND ce.event_cd IN (mf_cs72_hivrnaultrasensitive_cd, mf_cs72_abscd4helpertcells_cd,
     mf_cs72_cd4helpertcells_cd, mf_cs72_rprtiterresult_cd, mf_cs72_syphilisscreenbycia_cd,
     mf_cs72_syphilistesting_cd, mf_cs72_chlamydiaamplifiedprobe_cd,
     mf_cs72_chlamydiagcamplifiedprobe_cd, mf_cs72_gcamplifiedprobe_cd,
     mf_cs72_tbcellularbloodtesttspot_cd,
     mf_cs72_cytologyreportsgynpaptest_cd, mf_cs72_hcvquantlogresult_cd,
     mf_cs72_hepatitiscrnapcrquantitative_cd, mf_cs72_antihbsquant_cd,
     mf_cs72_hepatitisbsurfaceantigen_cd,
     mf_cs72_antihavigg_cd, mf_cs72_antihepatitisaigm_cd, mf_cs72_hivabag4thgeneration_cd,
     mf_cs72_hepbcoreab_cd, mf_cs72_hepcvirusab_cd,
     mf_cs72_neisseriagonorrhoeaeurineampprobe_cd, mf_cs72_chlamydiatrachomatisurineampprobe_cd,
     mf_cs72_cytologyreportsgeneral_cd, mf_cs72_hepatitisbsurfaceab_cd,
     mf_cs72_hepatitisbcoreabtotal_cd,
     mf_cs72_hepatitiscab_cd)
      AND ce.result_status_cd IN (mf_cs8_active_cd, mf_cs8_altered_cd, mf_cs8_auth_cd,
     mf_cs8_modified_cd)
      AND ce.valid_until_dt_tm > cnvtdatetime(sysdate))
    ORDER BY ce.event_cd, ce.performed_dt_tm DESC
    HEAD ce.event_cd
     m_rec->qual[ml_idx1].l_lcnt += 1, stat = alterlist(m_rec->qual[ml_idx1].lqual,m_rec->qual[
      ml_idx1].l_lcnt), m_rec->qual[ml_idx1].lqual[m_rec->qual[ml_idx1].l_lcnt].f_event_id = ce
     .event_id,
     m_rec->qual[ml_idx1].lqual[m_rec->qual[ml_idx1].l_lcnt].s_test_name = trim(uar_get_code_display(
       ce.event_cd),3)
     IF (ce.event_cd IN (mf_cs72_cytologyreportsgynpaptest_cd, mf_cs72_cytologyreportsgeneral_cd))
      m_rec->qual[ml_idx1].lqual[m_rec->qual[ml_idx1].l_lcnt].s_result = "Note Found", m_rec->qual[
      ml_idx1].lqual[m_rec->qual[ml_idx1].l_lcnt].s_performed_dt = trim(format(ce.event_start_dt_tm,
        "MM/DD/YYYY;;q"),3)
     ELSE
      m_rec->qual[ml_idx1].lqual[m_rec->qual[ml_idx1].l_lcnt].s_result = trim(ce.result_val,3), m_rec
      ->qual[ml_idx1].lqual[m_rec->qual[ml_idx1].l_lcnt].s_performed_dt = trim(format(ce
        .performed_dt_tm,"MM/DD/YYYY;;q"),3)
     ENDIF
    WITH nocounter
   ;end select
 ENDFOR
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 ) WITH protect
 SET frec->file_name = concat("bhs_rpt_careware_",trim(format(mf_start_dt,"YYYYMMDD;;q"),3),"_",trim(
   format(mf_stop_dt,"YYYYMMDD;;q"),3),".csv")
 SET frec->file_buf = "w"
 SET stat = cclio("OPEN",frec)
 SET frec->file_buf = concat('"FIN"',",",'"MRN"',",",'"PatientLastName"',
  ",",'"PatientFirstName"',",",'"TestName"',",",
  '"TestDate"',",",'"TestResult"',char(13),char(10))
 SET stat = cclio("WRITE",frec)
 FOR (ml_idx1 = 1 TO m_rec->l_cnt)
   IF ((m_rec->qual[ml_idx1].l_lcnt > 0))
    FOR (ml_idx2 = 1 TO m_rec->qual[ml_idx1].l_lcnt)
     SET frec->file_buf = concat('"',m_rec->qual[ml_idx1].s_fin,'","',m_rec->qual[ml_idx1].s_mrn,
      '","',
      m_rec->qual[ml_idx1].s_per_lname,'","',m_rec->qual[ml_idx1].s_per_fname,'","',m_rec->qual[
      ml_idx1].lqual[ml_idx2].s_test_name,
      '","',m_rec->qual[ml_idx1].lqual[ml_idx2].s_performed_dt,'","',m_rec->qual[ml_idx1].lqual[
      ml_idx2].s_result,'"',
      char(13),char(10))
     SET stat = cclio("WRITE",frec)
    ENDFOR
   ENDIF
 ENDFOR
 SET stat = cclio("CLOSE",frec)
 DECLARE ms_tmp = vc WITH protect, noconstant("")
 DECLARE ms_email = vc WITH protect, constant("angelce.lazovski@bhs.org,jason.williams@bhs.org")
 EXECUTE bhs_ma_email_file
 SET ms_tmp = concat("CAREWARE Extract ",format(cnvtdatetime(sysdate),"YYYYMMDDHHMMSS;;q"))
 CALL emailfile(value(frec->file_name),frec->file_name,ms_email,ms_tmp,1)
#exit_script
END GO
