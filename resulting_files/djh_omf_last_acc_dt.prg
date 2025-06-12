CREATE PROGRAM djh_omf_last_acc_dt
 PROMPT
  "Output to File/Printer/MINE" = "MINE "
  WITH outdev
 IF (findstring("@", $1) > 0)
  SET output_dest = build(format(cnvtdatetime(curdate,curtime3),"YYYYMMDDHHMMSS;;D"))
  SET email_ind = 1
 ELSE
  SET output_dest =  $1
  SET email_ind = 0
 ENDIF
 CALL echo(output_dest)
 DECLARE date_qual = dq8
 SET date_qual = cnvtlookbehind("0,D",cnvtdatetime(curdate,curtime3))
 CALL echo(format(date_qual,"YYYY/MM/DD;;D"))
 DECLARE output_string = vc
 SELECT DISTINCT INTO value(output_dest)
  pr.name_full_formatted, pr.username, position = uar_get_code_display(pr.position_cd),
  updt_dt_tm = format(pr.updt_dt_tm,"YYYY/MM/DD ;;D")
  FROM prsnl pr,
   omf_app_ctx_day_st oa
  PLAN (pr
   WHERE ((pr.username="*09757*") OR (((pr.username="*01979*") OR (pr.username="*39464*")) ))
    AND pr.person_id=oa.person_id)
   JOIN (oa
   WHERE oa.person_id=outerjoin(pr.person_id))
  ORDER BY pr.name_full_formatted, oa.start_day DESC, 0
  HEAD REPORT
   col 1, ",", "User",
   ",", "Login", ",",
   "Position", ",", "Last Login",
   ",", "Update Date", ",",
   row + 1
  HEAD pr.name_full_formatted
   position = trim(uar_get_code_display(pr.position_cd)), last_login = format(oa.start_day,
    "YYYY/MM/DD;;D"), output_string = build(',"',pr.name_full_formatted,'","',pr.username,'","',
    position,'","',last_login,'","',updt_dt_tm,
    '",'),
   col 1, output_string
   IF ( NOT (curendreport))
    row + 1
   ENDIF
  WITH format = variable, formfeed = none
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(concat(output_dest,".dat"))
  SET filename_out = concat(format(curdate,"YYYY-MM-DD ;;D"),"x",".csv")
  DECLARE subject_line = vc
  SET subject_line = concat(curprog,"V1.0 - Last Log-In Date for selected IDs")
  EXECUTE bhs_ma_email_file
  CALL emailfile(filename_in,filename_out, $1,subject_line,1)
 ENDIF
#end_prog
END GO
