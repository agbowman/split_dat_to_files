CREATE PROGRAM bhs_ma_phy_signed_powetest:dba
 PROMPT
  "Defaut Prompt for any error messages:" = "MINE",
  "Beginning Date:" = "SYSDATE",
  "End Date:" = "SYSDATE",
  "Select Facility" = 0,
  "Type in email address or leave default for report preview:" = "Report_Preview",
  "Note Type:" = 0,
  "prsnlType" = 0
  WITH outdev, bdate, edate,
  fname, email, notetype,
  prsnltype
 DECLARE acctcd = f8 WITH constant(uar_get_code_by("meaning",319,"FIN NBR")), protect
 DECLARE mrncd = f8 WITH constant(uar_get_code_by("meaning",319,"MRN")), protect
 DECLARE signeventcd = f8 WITH constant(uar_get_code_by("meaning",21,"SIGN")), protect
 DECLARE completedeventcd = f8 WITH constant(uar_get_code_by("meaning",103,"COMPLETED")), protect
 DECLARE refusedeventcd = f8 WITH constant(uar_get_code_by("meaning",103,"REFUSED")), protect
 DECLARE signstorycd = f8 WITH constant(uar_get_code_by("meaning",15750,"SIGNED")), protect
 DECLARE bhsresident = f8 WITH constant(uar_get_code_by("DISPLAYKEY",88,"BHSRESIDENT")), protect
 DECLARE bhsradresident = f8 WITH constant(uar_get_code_by("DISPLAYKEY",88,"BHSRADRESIDENT")),
 protect
 DECLARE bhsassociateprofessional = f8 WITH constant(uar_get_code_by("DISPLAYKEY",88,
   "BHSASSOCIATEPROFESSIONAL"))
 DECLARE auth = f8 WITH constant(uar_get_code_by("meaning",8,"AUTH")), protect
 DECLARE dictated = f8 WITH constant(uar_get_code_by("meaning",8,"DICTATED")), protect
 DECLARE modified = f8 WITH constant(uar_get_code_by("meaning",8,"MODIFIED")), protect
 DECLARE altered = f8 WITH constant(uar_get_code_by("meaning",8,"ALTERED")), protect
 DECLARE transcribed = f8 WITH constant(uar_get_code_by("meaning",8,"TRANSCRIBED")), protect
 DECLARE notetypeval = vc WITH noconstant(" ")
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
  SET var_output = "bhsmaattdsigneddischsum"
  SET filedelimiter1 = '"'
  SET filedelimiter2 = ","
 ELSE
  SET var_output =  $OUTDEV
  SET email_ind = 0
  SET filedelimiter1 = ""
  SET filedelimiter2 = ""
 ENDIF
 SELECT INTO value(var_output)
  folder = uar_get_code_display(ce.event_cd), ce.clinsig_updt_dt_tm";;q", ce.event_id,
  ce.event_cd, cep.action_dt_tm, cep.event_id,
  report_id = s.scd_story_id, patient = substring(1,40,trim(pe.name_full_formatted)), mrn = trim(
   cnvtstring(ea.alias)),
  acctnum = trim(cnvtstring(ea1.alias)), dischargedate = format(e.disch_dt_tm,"mm/dd/yyyy HH:MM:SS"),
  title = substring(1,40,trim(s.title)),
  physician = substring(1,40,trim(p.name_full_formatted)), phy_postion = uar_get_code_display(p
   .position_cd), reqest_sent_to = substring(1,40,trim(p2.name_full_formatted)),
  request_type = uar_get_code_display(cep2.action_type_cd), request_by = p3.name_full_formatted,
  physician_action = uar_get_code_display(cep.action_status_cd),
  action = uar_get_code_display(cep.action_type_cd), date = format(cep.updt_dt_tm,
   "MM/DD/YYYY HH:MM:SS"), cep.action_prsnl_id,
  notestatus = uar_get_code_display(s.story_completion_status_cd), s.event_id, cep.ce_event_prsnl_id,
  ce.valid_until_dt_tm, sortaction =
  IF (cnvtupper(uar_get_code_display(cep.action_status_cd))="COMPLETED") 1
  ELSEIF (cnvtupper(uar_get_code_display(cep.action_status_cd))="REFUSED") 2
  ELSE 3
  ENDIF
  FROM ce_event_prsnl cep,
   prsnl p,
   prsnl p1,
   prsnl p2,
   prsnl p3,
   person pe,
   scd_story s,
   clinical_event ce,
   ce_event_prsnl cep2,
   encntr_alias ea,
   encntr_alias ea1,
   encounter e
  PLAN (p1
   WHERE p1.active_ind=1
    AND cnvtdatetime(curdate,curtime3) BETWEEN p1.beg_effective_dt_tm AND p1.end_effective_dt_tm
    AND ((1 IN ( $PRSNLTYPE)
    AND ((p1.physician_ind+ 0)=1)
    AND  NOT (((p1.position_cd+ 0) IN (bhsresident, bhsradresident, bhsassociateprofessional)))) OR (
   2 IN ( $PRSNLTYPE)
    AND ((p1.position_cd+ 0) IN (bhsresident, bhsradresident, bhsassociateprofessional)))) )
   JOIN (cep
   WHERE cep.action_prsnl_id=p1.person_id
    AND cep.valid_until_dt_tm > cnvtdatetime(curdate,curtime)
    AND cep.person_id=1686098
    AND cep.action_status_cd IN (653, 656)
    AND ((cep.action_type_cd+ 0)=107)
    AND cep.action_dt_tm BETWEEN cnvtdatetime( $BDATE) AND cnvtdatetime( $EDATE))
   JOIN (p
   WHERE p.person_id=cep.action_prsnl_id
    AND ((1 IN ( $PRSNLTYPE)
    AND ((p.physician_ind+ 0)=1)
    AND  NOT (((p.position_cd+ 0) IN (bhsresident, bhsradresident, bhsassociateprofessional)))) OR (2
    IN ( $PRSNLTYPE)
    AND ((p.position_cd+ 0) IN (bhsresident, bhsradresident, bhsassociateprofessional)))) )
   JOIN (p3
   WHERE p3.person_id=outerjoin(cep.request_prsnl_id))
   JOIN (s
   WHERE s.event_id=outerjoin(cep.event_id)
    AND s.story_completion_status_cd=outerjoin(10396.00))
   JOIN (ce
   WHERE ce.event_id=cep.event_id
    AND ce.event_cd IN ( $NOTETYPE)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.result_status_cd IN (auth, dictated, modified, altered, transcribed))
   JOIN (pe
   WHERE pe.person_id=s.person_id)
   JOIN (ea
   WHERE ea.encntr_id=outerjoin(s.encounter_id)
    AND ea.encntr_alias_type_cd=outerjoin(mrncd))
   JOIN (ea1
   WHERE ea1.encntr_id=outerjoin(s.encounter_id)
    AND ea1.encntr_alias_type_cd=outerjoin(acctcd))
   JOIN (e
   WHERE e.encntr_id=s.encounter_id
    AND e.loc_facility_cd IN ( $FNAME))
   JOIN (cep2
   WHERE cep2.event_id=outerjoin(cep.event_id)
    AND ((cep2.ce_event_prsnl_id+ 0) != outerjoin(cep.ce_event_prsnl_id))
    AND ((cep2.request_prsnl_id+ 0)=outerjoin(cep.action_prsnl_id))
    AND cep2.valid_until_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00")))
   JOIN (p2
   WHERE p2.person_id=outerjoin(cep2.action_prsnl_id))
  ORDER BY folder, cep.event_id, sortaction,
   cep.action_dt_tm, physician, patient
  WITH nocounter, format, pcformat(value(filedelimiter1),value(filedelimiter2)),
   format(date,";;q"), time = 600
 ;end select
 IF (curqual=0)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "No data found", msg2 = "Please try again", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/12}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
  GO TO exit_prg
 ENDIF
 IF (email_ind=1)
  SET filename_in = trim(var_output)
  SET email_address = trim( $EMAIL)
  SET filename_out = "bhs_ma_attd_signed_disch_sum.csv"
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
