CREATE PROGRAM bhs_rpt_ccl_new_includes:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Beg Date:" = "CURDATE",
  "End Date:" = "CURDATE",
  "Email to:" = ""
  WITH outdev, s_beg_dt, s_end_dt,
  s_recipients
 EXECUTE bhs_sys_stand_subroutine
 FREE RECORD reply
 RECORD reply(
   1 status_data[1]
     2 status = c1
 )
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(concat( $S_BEG_DT," 00:00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(concat( $S_END_DT," 23:59:59"))
 DECLARE ms_output = vc WITH protect, noconstant(value( $OUTDEV))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_line = vc WITH protect, noconstant(" ")
 DECLARE ms_recipients = vc WITH protect, noconstant(trim( $S_RECIPIENTS))
 DECLARE ms_email_file = vc WITH protect, noconstant("bhs_ccl_includes.csv")
 IF (validate(request->batch_selection))
  SET ms_end_dt_tm = trim(format(datetimefind(cnvtlookbehind("1,D",sysdate),"D","E","E"),
    "dd-mmm-yyyy hh:mm:ss;;d"))
  SET ms_beg_dt_tm = trim(format(datetimefind(cnvtlookbehind("1,W",cnvtdatetime(ms_end_dt_tm)),"D",
     "B","B"),"dd-mmm-yyyy hh:mm:ss;;d"))
  SET ms_recipients = "CIScore@baystatehealth.org"
 ENDIF
 IF (ms_recipients <= " ")
  SELECT INTO value(ms_output)
   p.name_last, d.user_name, d.object_name,
   d.source_name
   FROM dprotect d,
    prsnl p,
    dummyt d1
   PLAN (d
    WHERE d.object="P"
     AND cnvtdatetime(concat(format(d.datestamp,"dd-mmm-yyyy;;d")," 00:00:00")) > cnvtdatetime(
     ms_beg_dt_tm))
    JOIN (d1)
    JOIN (p
    WHERE p.username=d.user_name)
   ORDER BY p.name_last, d.datestamp DESC
   HEAD REPORT
    pl_cnt = 0, pl_beg_pos = 0, pl_end_pos = 0,
    pl_cont = 0, col 0, "User_Name",
    col 25, "User_ID", col 35,
    "Script", col 70, "Date",
    col 80, "Group", col 87,
    "Path"
   DETAIL
    pl_cont = 0, pl_beg_pos = 0, pl_end_pos = 0,
    pl_cont = 1
    IF (pl_cont=1)
     row + 1
     IF (d.user_name="EN15469")
      ms_tmp = "Kauffman, Bob"
     ELSE
      ms_tmp = trim(p.name_full_formatted)
     ENDIF
     col 0, ms_tmp, col 25,
     d.user_name, col 35, d.object_name,
     ms_tmp = trim(format(d.datestamp,"mm/dd/yyyy;;d")), col 70, ms_tmp,
     ms_tmp = trim(cnvtstring(d.group)), col 80, ms_tmp,
     ms_tmp = trim(d.source_name,3), col 87, ms_tmp
    ENDIF
   WITH nocounter, outerjoin = d1, maxrow = 1,
    maxcol = 2000, format, separator = " "
  ;end select
  SELECT INTO "nl:"
   DETAIL
    row + 0
   WITH skipreport = value(1)
  ;end select
 ELSE
  SELECT INTO value(concat("bhscust:",ms_email_file))
   p.name_last, d.user_name, d.object_name,
   d.source_name
   FROM dprotect d,
    prsnl p,
    dummyt d1
   PLAN (d
    WHERE d.object="P"
     AND cnvtdatetime(concat(format(d.datestamp,"dd-mmm-yyyy;;d")," 00:00:00")) > cnvtdatetime(
     ms_beg_dt_tm))
    JOIN (d1)
    JOIN (p
    WHERE p.username=d.user_name)
   ORDER BY p.name_last, d.datestamp DESC
   HEAD REPORT
    ms_line = "NAME,USERID,SCRIPT,DATE,GROUP,PATH", col 0, ms_line,
    pl_cnt = 0, pl_beg_pos = 0, pl_end_pos = 0,
    pl_cont = 0
   DETAIL
    pl_cont = 0, pl_beg_pos = 0, pl_end_pos = 0,
    pl_cont = 1
    IF (pl_cont=1)
     IF (d.user_name="EN15469")
      ms_tmp = "Kauffman, Bob"
     ELSE
      ms_tmp = trim(p.name_full_formatted)
     ENDIF
     ms_line = concat('"',ms_tmp,'",'), ms_tmp = trim(d.user_name), ms_line = concat(ms_line,'"',
      ms_tmp,'",'),
     ms_tmp = trim(d.object_name), ms_line = concat(ms_line,'"',ms_tmp,'",'), ms_tmp = trim(format(d
       .datestamp,"mm/dd/yyyy;;d")),
     ms_line = concat(ms_line,'"',ms_tmp,'",'), ms_tmp = trim(cnvtstring(d.group)), ms_line = concat(
      ms_line,'"',ms_tmp,'",'),
     ms_tmp = trim(d.source_name,3), ms_line = concat(ms_line,'"',ms_tmp,'"'),
     CALL echo(ms_line),
     col 0, row + 1, ms_line
    ENDIF
   WITH nocounter, outerjoin = d1, maxrow = 1,
    maxcol = 2000, format, separator = " "
  ;end select
  IF (findfile(concat("bhscust:",ms_email_file)) > 0)
   SET ms_line = concat("CCL Includes ",ms_beg_dt_tm," to ",ms_end_dt_tm)
   CALL emailfile(concat("$bhscust/",ms_email_file),concat("$bhscust/",ms_email_file),ms_recipients,
    ms_line,1)
   IF (findfile(concat("bhscust:",ms_email_file))=1)
    CALL echo("Unable to delete email file")
   ELSE
    CALL echo("Email File Deleted")
   ENDIF
  ELSE
   CALL echo("email file not found")
  ENDIF
 ENDIF
 SET reply->status_data[1].status = "S"
#exit_script
END GO
