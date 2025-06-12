CREATE PROGRAM bhs_rpt_powernote_extract:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "runtype:" = "",
  "Days to look back (Only if runType = UPDATE):" = 0,
  'additional output (Email address, "OPSJOB")' = "CIScore@baystatehealth.org"
  WITH outdev, runtype, days,
  email
 EXECUTE bhs_sys_stand_subroutine
 DECLARE encounterpathway = f8 WITH noconstant(validatecodevalue("DISPLAYKEY",14409,
   "ENCOUNTERPATHWAY")), protect
 DECLARE tline = vc WITH noconstant(" ")
 DECLARE ms_type = vc WITH protect, noconstant("")
 DECLARE ms_file_name_in = vc WITH protect, noconstant("")
 DECLARE ms_file_name_out = vc WITH protect, noconstant("")
 DECLARE ms_user_name = vc WITH protect, noconstant("")
 DECLARE ms_server_name = vc WITH protect, noconstant("")
 DECLARE ms_local_dir = vc WITH protect, noconstant("")
 DECLARE ms_back_dir = vc WITH protect, noconstant("")
 IF (((findstring("@", $EMAIL) > 0) OR (cnvtupper( $EMAIL)="OPSJOB")) )
  IF (findstring("@", $EMAIL) > 0)
   SET email_ind = 1
  ENDIF
  SET var_output = concat(trim("powernote"))
  SET filedelimiter1 = '"'
  SET filedelimiter2 = ","
 ELSE
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = concat("You must enter an email address or OPSJOB(to FTP file)"), msg2 = concat("   "),
    col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 1, row + 1,
    "{F/1}{CPI/9}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
  GO TO exit_program
 ENDIF
 SELECT INTO concat(var_output)
  scr_pattern_id = sp.scr_pattern_id, display = trim(sp.display,3), definition = trim(sp.definition,3
   ),
  active_ind = sp.active_ind, active_status_dt_tm = trim(format(sp.active_status_dt_tm,";;q"),3),
  updt_cnt = sp.updt_cnt,
  updt_dt_tm = trim(format(sp.updt_dt_tm,";;q"),3)
  FROM scr_pattern sp
  WHERE sp.pattern_type_cd IN (encounterpathway)
   AND sp.active_ind=1
   AND ((( $RUNTYPE="ALL")) OR (( $RUNTYPE="UPDATE")
   AND sp.updt_dt_tm >= cnvtdatetime((curdate -  $DAYS),0)))
  HEAD REPORT
   tline = build(char(34),"scr_pattern_id",char(34),char(44),char(34),
    "display",char(34),char(44),char(34),"definition",
    char(34),char(44),char(34),"active_ind",char(34),
    char(44),char(34),"active_status_dt_tm",char(34),char(44),
    char(34),"updt_cnt",char(34),char(44),char(34),
    "updt_dt_tm",char(34),char(44)), col 0, tline,
   row + 1
  DETAIL
   tline = build(scr_pattern_id,char(44),char(34),display,char(34),
    char(44),char(34),definition,char(34),char(44),
    active_ind,char(44),char(34),active_status_dt_tm,char(34),
    char(44),updt_cnt,char(44),char(34),updt_dt_tm,
    char(34),char(44)), col 0, tline,
   row + 1
  WITH maxcol = 32000, format = variable, formfeed = none,
   check
 ;end select
 IF (cnvtupper( $EMAIL)="OPSJOB")
  SET ms_type = "SENT FILE"
  SET ms_file_name_in = concat(var_output,".dat")
  SET ms_file_name_out = concat(var_output,".txt")
  SET ms_user_name = "transport"
  SET ms_server_name = "bsoradbp01"
  SET ms_local_dir = "$CCLUSERDIR"
  SET ms_back_dir = "/u01/home/extracts/knowmgmt"
  CALL sftpfile(ms_type,ms_file_name_in,ms_file_name_out,ms_user_name,ms_server_name,
   ms_local_dir,ms_back_dir)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = concat(var_output,".txt was SFTPd to -"), msg2 = concat("   ",ms_server_name," - ",
     ms_back_dir), col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 1, row + 1,
    "{F/1}{CPI/9}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
 ELSEIF (email_ind=1)
  SET filename_in = trim(var_output)
  SET email_address = trim( $EMAIL)
  SET filename_out = concat(var_output,".csv")
  CALL emailfile(concat(filename_in,".dat"),filename_out,email_address,curprog,0)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = concat(var_output,".csv will be sent to -"), msg2 = concat("   ", $EMAIL), col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 1, row + 1,
    "{F/1}{CPI/9}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
 ENDIF
#exit_program
END GO
