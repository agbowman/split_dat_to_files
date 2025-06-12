CREATE PROGRAM bhs_rad_non_matched_studies
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin date:" = "CURDATE",
  "End date:" = "CURDATE"
  WITH outdev, bdate, edate
 DECLARE var_output = vc
 DECLARE email_ind = i4
 SET email_ind = 4
 IF (findstring("@", $OUTDEV) > 0)
  SET email_ind = 1
  SET var_output = "bhsradnonmatchedstudies"
  SET filedelimiter1 = '"'
  SET filedelimiter2 = ","
 ELSE
  SET var_output =  $OUTDEV
  SET email_ind = 0
  SET filedelimiter1 = ""
  SET filedelimiter2 = ""
 ENDIF
 SET beg_date_qual = cnvtdatetime( $BDATE)
 SET end_date_qual = cnvtdatetime( $EDATE)
 IF (cnvtupper( $BDATE) IN ("DAY"))
  SET beg_date_qual = cnvtdatetime((curdate - 1),0)
  SET end_date_qual = cnvtdatetime((curdate - 1),0)
 ELSEIF (datetimediff(end_date_qual,beg_date_qual) > 31)
  CALL echo("Date range > 31")
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
 ELSEIF (datetimediff(end_date_qual,beg_date_qual) < 0)
  CALL echo("Date range < 0")
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Your date range is incorrect", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08
  ;end select
  GO TO exit_prg
 ENDIF
 SELECT INTO value(var_output)
  study_date, patient_name, patient_identifier,
  study_description, station_name
  FROM im_acquired_study
  WHERE matched_study_id=0
   AND active_ind=1
   AND study_date BETWEEN format(cnvtdatetime(beg_date_qual),"YYYYMMDD;;d") AND format(cnvtdatetime(
    end_date_qual),"YYYYMMDD;;d")
  ORDER BY study_date
  WITH nocounter, format, pcformat(value(filedelimiter1),value(filedelimiter2)),
   time = 300
 ;end select
 CALL echo(format(cnvtdatetime(beg_date_qual),"YYYYMMDD;;d"))
 CALL echo(format(cnvtdatetime(end_date_qual),"YYYYMMDD;;d"))
 IF (email_ind=1)
  SET filename_in = trim(var_output)
  SET email_address = trim( $OUTDEV)
  SET filename_out = "bhsradnonmatchedstudies.csv"
  SET subject = concat(curprog," - rad nonmatched studies")
  EXECUTE bhs_ma_email_file
  CALL emailfile(concat(filename_in,".dat"),filename_out,email_address,subject,0)
 ENDIF
END GO
