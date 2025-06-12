CREATE PROGRAM bhs_rpt_iv_count:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Performed Date Start:" = "CURDATE",
  "Performed Date End:" = "CURDATE"
  WITH outdev, s_start_dt, s_stop_dt
 DECLARE mf_start_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_stop_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_cs72_peripheralivinsertion_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PERIPHERALIVINSERTIONCHARGE"))
 DECLARE mf_cs72_centrallineinsert_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CENTRALLINEINSERTIONDATETIME"))
 DECLARE mf_cs72_peripheralivdcreason_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PERIPHERALIVDCREASON"))
 DECLARE mf_cs8_active_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2627"))
 DECLARE mf_cs8_altered_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!16901"))
 DECLARE mf_cs8_auth_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2628"))
 DECLARE mf_cs8_modified_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2636"))
 DECLARE mf_cs220_bmc_cd = f8 WITH protect, constant(673936.00)
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
   1 l_piv_nonus_cnt = i4
   1 l_piv_us_cnt = i4
   1 l_central_line_cnt = i4
   1 l_piv_infiltrate_cnt = i4
 )
 SELECT INTO "nl:"
  FROM clinical_event ce,
   encounter e
  PLAN (ce
   WHERE ce.performed_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
    AND ce.event_cd IN (mf_cs72_peripheralivinsertion_cd, mf_cs72_centrallineinsert_cd,
   mf_cs72_peripheralivdcreason_cd)
    AND ce.view_level=1
    AND ce.publish_flag=1
    AND ce.result_status_cd IN (mf_cs8_active_cd, mf_cs8_altered_cd, mf_cs8_auth_cd,
   mf_cs8_modified_cd)
    AND ce.valid_until_dt_tm > cnvtdatetime(sysdate))
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id
    AND e.active_ind=1
    AND e.loc_facility_cd=mf_cs220_bmc_cd)
  ORDER BY ce.event_id
  HEAD ce.event_id
   IF (ce.event_cd=mf_cs72_peripheralivinsertion_cd)
    IF (trim(ce.result_val,3) IN ("ED ONLY US Guided Peripheral IV Placement by RN",
    "ED ONLY US Guided Peripheral IV Placement by Provider",
    "BMC IV Team ONLY US Guided Peripheral IV Placement"))
     m_rec->l_piv_us_cnt += 1
    ELSEIF (trim(ce.result_val,3) IN ("BMC IV Team ONLY Peripheral IV Placement",
    "Peripheral IV Insertion No Charge"))
     m_rec->l_piv_nonus_cnt += 1
    ENDIF
   ELSEIF (ce.event_cd=mf_cs72_centrallineinsert_cd)
    m_rec->l_central_line_cnt += 1
   ELSEIF (ce.event_cd=mf_cs72_peripheralivdcreason_cd)
    IF (trim(cnvtupper(ce.result_val),3)="*INFILTRATE*")
     m_rec->l_piv_infiltrate_cnt += 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO  $OUTDEV
  peripheral_iv_non_ultrasound_guided = m_rec->l_piv_nonus_cnt, peripheral_iv_ultrasound_guuided =
  m_rec->l_piv_us_cnt, peripheral_iv_extravasations = m_rec->l_piv_infiltrate_cnt,
  central_line_insertions = m_rec->l_central_line_cnt
  FROM (dummyt d  WITH seq = 1)
  WITH nocounter, format, separator = " "
 ;end select
 CALL echorecord(m_rec)
#exit_script
END GO
