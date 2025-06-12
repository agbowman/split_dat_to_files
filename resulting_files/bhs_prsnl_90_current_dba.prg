CREATE PROGRAM bhs_prsnl_90_current:dba
 PROMPT
  "Output to File/Printer/MINE/Email" = "MINE"
 IF (findstring("@", $1) > 0)
  SET output_dest = build(format(cnvtdatetime(curdate,curtime3),"YYYYMMDDHHMMSS;;D"))
  SET email_ind = 1
 ELSE
  SET output_dest =  $1
  SET email_ind = 0
 ENDIF
 CALL echo(output_dest)
 DECLARE date_qual = dq8
 SET date_qual = cnvtlookbehind("90,D",cnvtdatetime(curdate,curtime3))
 CALL echo(format(date_qual,"YYYY/MM/DD;;D"))
 DECLARE output_string = vc
 SELECT DISTINCT INTO value(output_dest)
  person_id = o.person_id, username = substring(1,15,p.username), position = uar_get_code_display(p
   .position_cd),
  name = substring(1,40,p.name_full_formatted), last_login = format(o.start_day,"yyyy/mm/dd;;d"),
  updt_dt_tm = format(p.updt_dt_tm,"yyyy/mm/dd;;d"),
  p.active_ind
  FROM dummyt d1,
   omf_app_ctx_day_st o,
   prsnl p
  PLAN (d1)
   JOIN (o
   WHERE o.start_day > cnvtdatetime((curdate - 90),0000))
   JOIN (p
   WHERE p.person_id=o.person_id)
  ORDER BY position, name, person_id
  HEAD REPORT
   col 1, ",", "User",
   ",", "Login", ",",
   "Position", ",", "Last Login",
   ",", "Update Date", ",",
   row + 1
  DETAIL
   output_string = build(',"',p.name_full_formatted,'","',p.username,'","',
    position,'","',last_login,'","',updt_dt_tm,
    '",'), col 1, output_string,
   row + 1
  WITH outerjoin = d1, format = variable, formfeed = none
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(concat(output_dest,".dat"))
  SET filename_out = concat(format(curdate,"YYYYMMDD ;;D"),".csv")
  DECLARE subject_line = vc
  SET subject_line = concat(curprog," - Baystate Health CIS Acnts active 90 days")
  EXECUTE bhs_ma_email_file
  CALL emailfile(filename_in,filename_out, $1,subject_line,1)
 ENDIF
#end_prog
END GO
