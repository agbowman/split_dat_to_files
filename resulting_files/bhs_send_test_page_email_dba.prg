CREATE PROGRAM bhs_send_test_page_email:dba
 PROMPT
  "" = "MINE",
  "Email/pager address (ex: 40748@epage.bhs.org):" = "",
  "Subject:" = ""
  WITH outdev, email, subject
 EXECUTE bhs_sys_stand_subroutine
 SET ms_email_list = trim( $EMAIL)
 SET ms_tmp_str = concat( $SUBJECT)
 SET ms_filename = "test_dcl_file.dat"
 SELECT INTO value(ms_filename)
  p.name_full_formatted
  FROM person p
  WITH maxrec = 5, nocounter
 ;end select
 CALL echo("emailing file")
 SET stat = emailfile(ms_filename,ms_filename,ms_email_list,ms_tmp_str,1)
 SELECT INTO  $OUTDEV
  FROM dummyt
  HEAD REPORT
   msg1 = build("status: ",stat), msg2 = "(1 = email sent (If correct address was supplied)", col 0,
   "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
   "{F/1}{CPI/7}",
   CALL print(calcpos(36,(y_pos+ 0))), msg1,
   row + 2, msg2
  WITH dio = 08
 ;end select
END GO
