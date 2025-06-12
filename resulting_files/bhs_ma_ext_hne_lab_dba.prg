CREATE PROGRAM bhs_ma_ext_hne_lab:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date" = "CURDATE",
  "End Date:" = "CURDATE"
  WITH outdev, s_start_dt, s_stop_dt
 DECLARE mf_start_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_stop_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_cs89_sunquest_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",89,"SUNQUEST"))
 DECLARE mf_cs8_active_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2627"))
 DECLARE mf_cs8_altered_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!16901"))
 DECLARE mf_cs8_auth_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2628"))
 DECLARE mf_cs8_modified_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2636"))
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
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 s_pat_fname = vc
     2 s_pat_lname = vc
     2 s_pat_dob = vc
     2 l_rcnt = i4
     2 rqual[*]
       3 f_clin_event_id = f8
       3 f_event_cd = f8
       3 s_event = vc
       3 s_catalog = vc
       3 s_result = vc
       3 s_result_unit = vc
       3 s_date_of_service = vc
 )
 SELECT INTO "nl:"
  FROM encounter e,
   code_value cv,
   person p,
   clinical_event ce1
  PLAN (e
   WHERE e.disch_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
    AND e.active_ind=1
    AND e.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (cv
   WHERE cv.code_value=e.financial_class_cd
    AND cv.code_set=354
    AND cv.display_key IN ("HNEIDENTICAL", "HNEBHSPPO", "HNEBHSHMO", "HNEHMOBAYCAREHP",
   "HNESELECTHMO",
   "HNESELECTPPO", "HNEFFNONBHPHMOP", "HNEMEDICAREADVANTA", "MBHPHNEACO", "HNEMEDICARE2NDRY",
   "HNECONNECTORCARE", "HNEMEDICAREADVPPO"))
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (ce1
   WHERE ce1.encntr_id=e.encntr_id
    AND ce1.contributor_system_cd=mf_cs89_sunquest_cd
    AND ce1.result_status_cd IN (mf_cs8_active_cd, mf_cs8_altered_cd, mf_cs8_auth_cd,
   mf_cs8_modified_cd)
    AND trim(ce1.event_tag,3) != "In Error"
    AND ce1.valid_until_dt_tm > cnvtdatetime(sysdate)
    AND ce1.view_level=1)
  ORDER BY e.encntr_id, ce1.event_cd
  HEAD e.encntr_id
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
   f_encntr_id = e.encntr_id,
   m_rec->qual[m_rec->l_cnt].f_person_id = e.person_id, m_rec->qual[m_rec->l_cnt].s_pat_fname = trim(
    p.name_first_key,3), m_rec->qual[m_rec->l_cnt].s_pat_lname = trim(p.name_last_key,3),
   m_rec->qual[m_rec->l_cnt].s_pat_dob = trim(format(cnvtdatetime(p.birth_dt_tm),"YYYYMMDD;;q"),3)
  DETAIL
   IF (size(trim(ce1.result_val,3)) > 0)
    m_rec->qual[m_rec->l_cnt].l_rcnt += 1, stat = alterlist(m_rec->qual[m_rec->l_cnt].rqual,m_rec->
     qual[m_rec->l_cnt].l_rcnt), m_rec->qual[m_rec->l_cnt].rqual[m_rec->qual[m_rec->l_cnt].l_rcnt].
    f_clin_event_id = ce1.clinical_event_id,
    m_rec->qual[m_rec->l_cnt].rqual[m_rec->qual[m_rec->l_cnt].l_rcnt].f_event_cd = ce1.event_cd,
    m_rec->qual[m_rec->l_cnt].rqual[m_rec->qual[m_rec->l_cnt].l_rcnt].s_event = trim(
     uar_get_code_display(ce1.event_cd),3), m_rec->qual[m_rec->l_cnt].rqual[m_rec->qual[m_rec->l_cnt]
    .l_rcnt].s_catalog = trim(uar_get_code_display(ce1.catalog_cd),3),
    m_rec->qual[m_rec->l_cnt].rqual[m_rec->qual[m_rec->l_cnt].l_rcnt].s_result = trim(ce1.result_val,
     3), m_rec->qual[m_rec->l_cnt].rqual[m_rec->qual[m_rec->l_cnt].l_rcnt].s_result_unit = trim(
     uar_get_code_display(ce1.result_units_cd),3), m_rec->qual[m_rec->l_cnt].rqual[m_rec->qual[m_rec
    ->l_cnt].l_rcnt].s_date_of_service = trim(format(ce1.performed_dt_tm,"YYYYMMDD;;q"),3)
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(m_rec)
#exit_script
END GO
