CREATE PROGRAM bhs_nomen_list_export:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "List type (required):" = "",
  "Type in email address or leave default for report preview:" = "Report_Preview"
  WITH outdev, nomenlist, email
 DECLARE var_output = vc
 DECLARE email_ind = i4
 SET email_ind = 4
 IF (findstring("@", $EMAIL) > 0)
  SET email_ind = 1
  SET var_output = "bhs_nomen_list_export"
  SET filedelimiter1 = '"'
  SET filedelimiter2 = ","
 ELSE
  SET var_output =  $OUTDEV
  SET email_ind = 0
  SET filedelimiter1 = ""
  SET filedelimiter2 = ""
 ENDIF
 SELECT INTO value(var_output)
  nomenclature_id = b.nomenclature_id, source_string = trim(n.source_string,3), nomen_list = b
  .nomen_list
  FROM bhs_nomen_list b,
   nomenclature n
  PLAN (b
   WHERE b.nomen_list_key IN ( $NOMENLIST)
    AND b.active_ind=1
    AND b.nomenclature_id > 0)
   JOIN (n
   WHERE n.nomenclature_id=b.nomenclature_id
    AND n.nomenclature_id > 0)
  ORDER BY nomen_list
  WITH nocounter, pcformat(value(filedelimiter1),value(filedelimiter2)), format
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(var_output)
  SET email_address = trim( $EMAIL)
  SET filename_out = "bhs_nomen_list_export.csv"
  EXECUTE bhs_ma_email_file
  CALL emailfile(concat(filename_in,".dat"),filename_out,email_address,curprog,0)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = concat(filename_out," will be sent to -"), msg2 = concat("   ", $EMAIL), col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 1, row + 1,
    "{F/1}{CPI/9}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
 ENDIF
END GO
