CREATE PROGRAM bhs_powernote_inbox_audit
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "start date" = "SYSDATE",
  "end_dt" = "SYSDATE",
  "Enter Email or Report" = "Report_View"
  WITH outdev, start_dt_tm, end_dt,
  email
 DECLARE var_output = vc
 DECLARE email_ind = i4
 SET email_ind = 4
 IF (findstring("@", $EMAIL) > 0)
  SET email_ind = 1
  SET var_output = "bhs_powernote_inbox_audit"
  SET filedelimiter1 = '"'
  SET filedelimiter2 = ","
 ELSE
  SET var_output =  $OUTDEV
  SET email_ind = 0
  SET filedelimiter1 = ""
  SET filedelimiter2 = ""
 ENDIF
 SELECT DISTINCT INTO value(var_output)
  patient_name = p.name_full_formatted, mrn = pa.alias, fin = ea.alias,
  physician = pr.name_full_formatted, requested_physician = pr1.name_full_formatted, request_time = c
  .request_dt_tm,
  powernote = s.title, e.disch_dt_tm
  FROM ce_event_prsnl c,
   prsnl pr,
   prsnl pr1,
   clinical_event ce,
   person p,
   scd_story s,
   encntr_alias ea,
   person_alias pa,
   encounter e
  PLAN (c
   WHERE c.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND c.action_status_cd IN (657, 614384.00)
    AND c.request_dt_tm BETWEEN cnvtdatetime( $2) AND cnvtdatetime( $3)
    AND c.action_prsnl_id != 0.00)
   JOIN (pr
   WHERE pr.person_id=c.action_prsnl_id
    AND ((pr.physician_ind+ 0)=1)
    AND  NOT (((pr.position_cd+ 0) IN (68877695.0, 925850.0))))
   JOIN (pr1
   WHERE pr1.person_id=c.request_prsnl_id
    AND ((pr1.position_cd+ 0) IN (68877695.0, 925850.0)))
   JOIN (p
   WHERE p.person_id=c.person_id)
   JOIN (ce
   WHERE ce.event_id=c.event_id
    AND ((ce.entry_mode_cd+ 0)=781113.00))
   JOIN (s
   WHERE s.event_id=c.event_id)
   JOIN (ea
   WHERE ea.encntr_id=s.encounter_id
    AND ((ea.encntr_alias_type_cd+ 0)=1077))
   JOIN (pa
   WHERE p.person_id=pa.person_id
    AND ((pa.person_alias_type_cd+ 0)=2))
   JOIN (e
   WHERE s.encounter_id=e.encntr_id)
  ORDER BY pr.name_last_key
  WITH nocounter, format, pcformat(value(filedelimiter1),value(filedelimiter2)),
   time = 300
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(var_output)
  SET email_address = trim( $EMAIL)
  SET filename_out = "bhs_powernot_inbox_audit.csv"
  EXECUTE bhs_ma_email_file
  CALL emailfile(concat(filename_in,".dat"),filename_out,email_address,curprog,0)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = concat(trim("bhs_powernote_inbox_audit"),format(curdate,"MMDDYYYY;;D"),
     ".csv will be sent to -"), msg2 = concat("   ", $EMAIL), col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 1, row + 1,
    "{F/1}{CPI/9}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
 ENDIF
END GO
