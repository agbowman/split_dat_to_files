CREATE PROGRAM bhs_ma_ap_signed_sched2:dba
 PROMPT
  "Defaut Prompt for any error messages:" = "MINE",
  "Beginning Date:" = cnvtdatetime((curdate - 1),curtime3),
  "End Date:" = cnvtdatetime(curdate,curtime3),
  "Select Facility" = 10,
  "Type in email address or leave default for report preview:" = "Report_Preview"
  WITH outdev, bdate, edate,
  fname, email
 IF (( $FNAME < 1))
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "You must select a facility", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
  GO TO exit_prg
 ELSE
  SET loc_where = build2(" e.loc_facility_cd + 0 = ", $FNAME)
 ENDIF
 IF (datetimediff(cnvtdatetime( $EDATE),cnvtdatetime( $BDATE)) > 31)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Your date range is larger than 31 days.", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
  GO TO exit_prg
 ELSEIF (datetimediff(cnvtdatetime( $EDATE),cnvtdatetime( $BDATE)) < 0)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Your date range is outside 31 days.", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08
  ;end select
  GO TO exit_prg
 ENDIF
 DECLARE var_output = vc
 DECLARE email_ind = i4
 SET email_ind = 4
 IF (findstring("@", $EMAIL) > 0)
  SET email_ind = 1
  SET var_output = "bhs_ma_ap_signed_sched2"
  SET filedelimiter1 = '"'
  SET filedelimiter2 = ","
 ELSE
  SET var_output =  $OUTDEV
  SET email_ind = 0
  SET filedelimiter1 = ""
  SET filedelimiter2 = ""
 ENDIF
 SET bhsap = uar_get_code_by("DISPLAYKEY",88,"BHSASSOCIATEPROFESSIONAL")
 SET attdoc = uar_get_code_by("MEANING",333,"ATTENDDOC")
 SET active = uar_get_code_by("MEANING",48,"ACTIVE")
 SET fin = uar_get_code_by("MEANING",319,"FIN NBR")
 SELECT DISTINCT INTO value(var_output)
  o.order_id, apname = prl.name_full_formatted, attending = prl2.name_full_formatted,
  order_status = uar_get_code_display(o.order_status_cd), patient_name = p.name_full_formatted,
  patient_acct_num = ea.alias,
  drug_mnemonic = o.order_mnemonic, review_dt_tm = format(ordr.review_dt_tm,";;q"), order_dt_tm =
  format(o.orig_order_dt_tm,";;q")
  FROM prsnl prl,
   order_review ordr,
   orders o,
   encounter e,
   person p,
   encntr_alias ea,
   encntr_prsnl_reltn epr,
   prsnl prl2
  PLAN (prl
   WHERE prl.position_cd=bhsap
    AND ((prl.active_ind+ 0)=1))
   JOIN (ordr
   WHERE ordr.review_personnel_id=prl.person_id
    AND ((ordr.reviewed_status_flag+ 0)=1)
    AND ((ordr.review_dt_tm+ 0) BETWEEN cnvtdatetime( $BDATE) AND cnvtdatetime( $EDATE)))
   JOIN (o
   WHERE o.order_id=ordr.order_id
    AND ((o.catalog_cd+ 0) IN (772218, 772254, 772322, 772368, 772558,
   772560, 772744, 772780, 772906, 773076,
   773094, 773114, 773154, 773244, 773260,
   773292, 773496, 906172, 1346326, 1346348,
   1355735, 1357760, 1358297, 1360466, 1361270,
   1361283, 1361670, 1361741, 1362436, 1363355,
   1363557, 2342977, 24430197, 24431927, 24432294,
   95371335)))
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND ((e.loc_facility_cd+ 0)=value( $FNAME)))
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (ea
   WHERE ea.encntr_id=o.encntr_id
    AND ((ea.encntr_alias_type_cd+ 0)=fin))
   JOIN (epr
   WHERE epr.encntr_id=outerjoin(e.encntr_id)
    AND epr.encntr_prsnl_r_cd=outerjoin(attdoc)
    AND epr.active_status_cd=outerjoin(active)
    AND ((epr.beg_effective_dt_tm+ 0) <= outerjoin(cnvtdatetime(curdate,curtime)))
    AND ((epr.end_effective_dt_tm+ 0) > outerjoin(cnvtdatetime(curdate,curtime))))
   JOIN (prl2
   WHERE prl2.person_id=epr.prsnl_person_id)
  ORDER BY o.order_id
  WITH nocounter, format, pcformat(value(filedelimiter1),value(filedelimiter2)),
   time = 1000
 ;end select
 IF (curqual=0)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "No data was found for the timeframe", col 0, "{PS/792 0 translate 90 rotate/}",
    y_pos = 18, row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1
   WITH dio = 08
  ;end select
  GO TO exit_prg
 ENDIF
 IF (email_ind=1)
  SET filename_in = trim(var_output)
  SET email_address = trim( $EMAIL)
  SET filename_out = "bhs_ma_ap_signed_sched2.csv"
  EXECUTE bhs_ma_email_file
  CALL emailfile(concat(filename_in,".dat"),filename_out,email_address,curprog,0)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = concat(trim("bhs_pa_sched2_"),format(curdate,"MMDDYYYY;;D"),".csv will be sent to -"),
    msg2 = concat("   ", $EMAIL), col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 1, row + 1,
    "{F/1}{CPI/9}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
 ENDIF
#exit_prg
END GO
