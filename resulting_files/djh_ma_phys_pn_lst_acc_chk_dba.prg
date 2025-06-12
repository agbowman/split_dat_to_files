CREATE PROGRAM djh_ma_phys_pn_lst_acc_chk:dba
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
 DECLARE date_qual = dq8
 SET date_qual = cnvtlookbehind("1,D",cnvtdatetime(curdate,curtime3))
 CALL echo(format(date_qual,"YYYY/MM/DD;;D"))
 DECLARE output_string = vc
 SELECT DISTINCT INTO value(output_dest)
  pr.name_last, pr.name_first, pr.username,
  position = uar_get_code_display(pr.position_cd), updt_dt_tm = format(pr.updt_dt_tm,"YYYY/MM/DD ;;D"
   )
  FROM prsnl pr,
   omf_app_ctx_day_st oa
  PLAN (pr
   WHERE pr.active_ind=1
    AND pr.physician_ind=1
    AND pr.active_status_cd=188.00
    AND pr.updt_dt_tm < cnvtdatetime((curdate - 1),0)
    AND pr.username="PN*"
    AND  NOT (pr.person_id IN (
   (SELECT
    oai.person_id
    FROM omf_app_ctx_day_st oai
    WHERE oai.person_id=pr.person_id
     AND oai.start_day > cnvtdatetime((curdate - 1),000)))))
   JOIN (oa
   WHERE oa.person_id=outerjoin(pr.person_id))
  ORDER BY pr.name_last, pr.name_first, oa.start_day DESC,
   0
  HEAD REPORT
   col 1, ",", "Last Name",
   ",", "First Name", ",",
   "Login", ",", "Position",
   ",", "Last Login", ",",
   "Update Date", ",", row + 1
  HEAD pr.name_last
   position = trim(uar_get_code_display(pr.position_cd)), last_login = format(oa.start_day,
    "YYYY/MM/DD;;D"), output_string = build(',"',pr.name_last,'","',pr.name_first,'","',
    pr.username,'","',position,'","',last_login,
    '","',updt_dt_tm,'",'),
   col 1, output_string
   IF ( NOT (curendreport))
    row + 1
   ENDIF
  WITH format = variable, formfeed = none
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(concat(output_dest,".dat"))
  SET filename_out = concat(format(curdate,"YYYYMMDD ;;D"),"_PHYS",".csv")
  DECLARE subject_line = vc
  SET subject_line = concat(curprog," V1.0 - CIS Acnts Physicians inactive 1 day")
  EXECUTE bhs_ma_email_file
  CALL emailfile(filename_in,filename_out, $1,subject_line,1)
 ENDIF
#end_prog
END GO
