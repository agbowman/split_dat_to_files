CREATE PROGRAM djh_sec_history_csv:dba
 PROMPT
  "Output to File/Printer/MINE" = "David.Hounshell@bhs.org"
  WITH outdev
 IF (findstring("@", $1) > 0)
  SET output_dest = build(format(cnvtdatetime(curdate,curtime3),"YYYYMMDDHHMMSS;;D"))
  SET email_ind = 1
 ELSE
  SET output_dest =  $1
  SET email_ind = 0
 ENDIF
 CALL echo(output_dest)
 SET lncnt = 0
 SELECT INTO value(output_dest)
  FROM sec_history p
  ORDER BY p.username
  HEAD REPORT
   col 1, "Ln#,", "UserName,",
   "Passwd_cnt,", "qual,", row + 1
  HEAD p.username
   lncnt = (lncnt+ 1), output_string = build(lncnt,',"',p.username,'"',',"',
    p.passwd_cnt,'"',',"',p.qual,'"'), col 1,
   output_string
   IF ( NOT (curendreport))
    row + 1
   ENDIF
  WITH format = variable, formfeed = none, maxcol = 2000
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(concat(output_dest,".dat"))
  SET filename_out = concat(format(curdate,"YYYY-MM-DD ;;D"),"SEC_History",".csv")
  DECLARE subject_line = vc
  SET subject_line = concat(curprog,"-V1.0 - Sec Hist ",curnode)
  EXECUTE bhs_ma_email_file
  CALL emailfile(filename_in,filename_out, $1,subject_line,1)
 ENDIF
#end_prog
END GO
