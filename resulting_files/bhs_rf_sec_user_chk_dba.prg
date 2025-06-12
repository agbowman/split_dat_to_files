CREATE PROGRAM bhs_rf_sec_user_chk:dba
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
 SET lncnt = 0
 SELECT INTO value(output_dest)
  prsnl_fullname = p.name_full_formatted, prsnl_username = p.username, sec_username = s.username,
  person_id = p.person_id, updt_date = p.updt_dt_tm
  FROM sec_user s,
   dummyt d,
   prsnl p
  PLAN (p
   WHERE p.active_ind=1
    AND p.username != ""
    AND p.username != " *"
    AND p.username="RF*"
    AND p.username IS NOT null
    AND p.active_status_cd=188)
   JOIN (d)
   JOIN (s
   WHERE p.username=s.userkey)
  ORDER BY s.username, p.updt_dt_tm, p.name_full_formatted
  HEAD REPORT
   col 1, "Ln#,", "Name,",
   "Log-In,", "Sec_username,", "person_id,",
   "UPDT,", row + 1
  HEAD p.name_full_formatted
   lncnt = (lncnt+ 1), output_string = build(lncnt,',"',trim(prsnl_fullname),'"',',"',
    trim(prsnl_username),'"',',"',trim(sec_username),'"',
    ',"',format(person_id,"99999999999"),'"',',"',format(p.updt_dt_tm,"YYYY-MM-DD;;D"),
    '"'), col 1,
   output_string
   IF ( NOT (curendreport))
    row + 1
   ENDIF
  FOOT REPORT
   row + 1, col 1, ",",
   curprog, ",", curnode,
   ",", curdate
  WITH outerjoin = d, format = variable, formfeed = none,
   maxcol = 2000
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(concat(output_dest,".dat"))
  SET filename_out = concat(format(curdate,"YYYY-MM-DD ;;D"),"_sec_user",".csv")
  DECLARE subject_line = vc
  SET subject_line = concat(curprog,"-V1.0 - sec_user ",curnode)
  EXECUTE bhs_ma_email_file
  CALL emailfile(filename_in,filename_out, $1,subject_line,1)
 ENDIF
END GO
