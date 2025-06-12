CREATE PROGRAM bhs_ma_phy_signed_powerntest
 PROMPT
  "Defaut Prompt for any error messages:" = "MINE",
  "Beginning Date:" = "SYSDATE",
  "End Date:" = "SYSDATE",
  "Look at reports created 90 days back from this date:" = "CURDATE",
  "Select Facility" = 0,
  "Type in email address or leave default for report preview:" = "Report_Preview",
  "Note Type(ex: Phys *):" = "Discharge Summary"
  WITH outdev, bdate, edate,
  lbdate, fname, email,
  notetype
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
 DECLARE acctcd = f8 WITH constant(uar_get_code_by("meaning",319,"FIN NBR")), protect
 DECLARE mrncd = f8 WITH constant(uar_get_code_by("meaning",319,"MRN")), protect
 DECLARE signeventcd = f8 WITH constant(uar_get_code_by("meaning",21,"SIGN")), protect
 DECLARE completedeventcd = f8 WITH constant(uar_get_code_by("meaning",103,"COMPLETED")), protect
 DECLARE refusedeventcd = f8 WITH constant(uar_get_code_by("meaning",103,"REFUSED")), protect
 DECLARE signstorycd = f8 WITH constant(uar_get_code_by("meaning",15750,"SIGNED")), protect
 DECLARE bhsresident = f8 WITH constant(925850.0), protect
 DECLARE bhsradresident = f8 WITH constant(68877695.0), protect
 DECLARE notetypeval = vc WITH noconstant(" ")
 SET lbdatestart = datetimeadd(cnvtdatetime( $LBDATE),- (90))
 SET lbdateend = datetimefind(cnvtdatetime( $LBDATE),"D","E","E")
 CALL echo("noteType")
 IF (( $NOTETYPE="Discharge Summary"))
  SET notetypeval = build("trim(srp.display_key) =value(",char(34),"PHYSICIANDISCHARGESUMMARY*",char(
    34),")")
 ELSEIF (( $NOTETYPE="History and Physical"))
  SET notetypeval = build("trim(srp.display_key) in(",char(34),"MEDICALHP",char(34),",",
   char(34),"SURGICALHP",char(34),")")
 ELSE
  SET notetypeval = replace(cnvtupper(trim( $NOTETYPE)),"1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ*",
   "1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ*",3)
  SET notetypeval = build("trim(srp.display_key) =value(",char(34),notetypeval,char(34),")")
 ENDIF
 CALL echo(notetypeval)
 SELECT DISTINCT INTO value(var_output)
  *
  FROM scd_story s,
   scd_story_pattern ssp,
   scr_pattern srp,
   ce_event_prsnl cep
  PLAN (srp)
   JOIN (ssp
   WHERE ssp.scr_pattern_id=srp.scr_pattern_id)
   JOIN (s
   WHERE s.scd_story_id=ssp.scd_story_id
    AND s.person_id=19683927)
   JOIN (cep
   WHERE cep.event_id=s.event_id)
  WITH nocounter, format, pcformat(value(filedelimiter1),value(filedelimiter2)),
   time = 600
 ;end select
 IF (curqual=0)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "No results found for this note / timeframe", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
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
