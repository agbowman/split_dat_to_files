CREATE PROGRAM bhs_rpt_open_preg:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Query type" = "",
  "Operator" = "",
  "Start gestational age (weeks)" = "44",
  "End gestational age (weeks)" = "45",
  "Start date" = "CURDATE",
  "End date" = "CURDATE",
  "Organization" = value(*),
  "Search type" = 0,
  "Enter physician last name" = "*",
  "Physician" = value(*),
  "Recipient email(s)  (Leave blank to display to screen)" = ""
  WITH outdev, s_qtype, s_operator,
  s_num_wks1, s_num_wks2, s_start_date,
  s_end_date, f_org_id, n_search_type,
  s_phys_last_name, f_physician_id, s_recipients
 FREE RECORD frec
 RECORD frec(
   1 file_name = vc
   1 file_buf = vc
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
 )
 FREE RECORD pregnancy
 RECORD pregnancy(
   1 patient[*]
     2 person_lastname = vc
     2 person_firstname = vc
     2 mrn = vc
     2 gest_age = vc
     2 primary_physician = vc
     2 facility = vc
     2 edd = vc
   1 patient_cnt = i4
   1 debug = vc
   1 debug_f8 = f8
 )
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_error = vc WITH protect, noconstant("")
 DECLARE ms_subject = vc WITH protect, noconstant("")
 IF (textlen(trim( $S_RECIPIENTS,3)) > 1
  AND findstring("@", $S_RECIPIENTS)=0)
  SET ms_error = "Invalid email address."
  GO TO exit_script
 ENDIF
 EXECUTE dcp_rpt_open_preg_drv "MINE",  $S_QTYPE,  $S_OPERATOR,
  $S_NUM_WKS1,  $S_NUM_WKS2,  $S_START_DATE,
  $S_END_DATE,  $F_ORG_ID,  $N_SEARCH_TYPE,
  $S_PHYS_LAST_NAME,  $F_PHYSICIAN_ID
 IF (size(pregnancy->patient,5)=0)
  SET ms_error = "No data returned."
  GO TO exit_script
 ENDIF
 IF (textlen(trim( $S_RECIPIENTS,3)) > 1)
  SET ms_subject = build("Open Pregnancy by EGA-EDD Report - ",trim(format(sysdate,
     "mm_dd_yy hh:mm;;d"),3))
  SET frec->file_name = build(cnvtlower(curprog),"_",trim(format( $S_START_DATE,"mm_dd_yy ;;d"),3),
   "_to_",trim(format( $S_END_DATE,"mm_dd_yy;;d"),3),
   ".csv")
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"PATIENT MRN",','"LAST NAME",','"FIRST NAME",','"GESTATIONAL AGE",',
   '"EDD",',
   '"PREGNANCY ADDED BY",','"FACILITY NAME",',char(13))
  SET stat = cclio("WRITE",frec)
  FOR (ml_cnt = 1 TO pregnancy->patient_cnt)
   SET frec->file_buf = build('"',trim(pregnancy->patient[ml_cnt].mrn,3),'","',trim(pregnancy->
     patient[ml_cnt].person_lastname,3),'","',
    trim(pregnancy->patient[ml_cnt].person_firstname,3),'","',trim(pregnancy->patient[ml_cnt].
     gest_age,3),'","',trim(pregnancy->patient[ml_cnt].edd,3),
    '","',trim(pregnancy->patient[ml_cnt].primary_physician,3),'","',trim(pregnancy->patient[ml_cnt].
     facility,3),'"',
    char(13))
   SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  EXECUTE bhs_ma_email_file
  CALL emailfile(frec->file_name,frec->file_name,concat('"',trim( $S_RECIPIENTS),'"'),ms_subject,1)
 ELSE
  SELECT INTO value( $OUTDEV)
   patient_mrn = substring(1,100,pregnancy->patient[d.seq].mrn), last_name = substring(1,100,
    pregnancy->patient[d.seq].person_lastname), first_name = substring(1,100,pregnancy->patient[d.seq
    ].person_firstname),
   gestational_age = substring(1,100,pregnancy->patient[d.seq].gest_age), edd = substring(1,100,
    pregnancy->patient[d.seq].edd), pregnancy_added_by = substring(1,100,pregnancy->patient[d.seq].
    primary_physician),
   facility_name = substring(1,500,pregnancy->patient[d.seq].facility)
   FROM (dummyt d  WITH seq = pregnancy->patient_cnt)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
#exit_script
 CALL echorecord(pregnancy)
 FREE RECORD pregnancy
 FREE RECORD frec
 IF (textlen(trim( $S_RECIPIENTS,3)) > 1
  AND textlen(trim(ms_error,3))=0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    msg1 = "The report has been sent to:", msg2 = build2("     ", $S_RECIPIENTS),
    CALL print(calcpos(36,18)),
    msg1, row + 2, msg2
   WITH dio = 08
  ;end select
 ELSEIF (textlen(trim(ms_error,3)) > 0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(26,18)),
    ms_error
   WITH dio = 08
  ;end select
 ENDIF
END GO
