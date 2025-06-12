CREATE PROGRAM bhs_prsnl_last_login_test:dba
 PROMPT
  "Output to File/Printer/MINE/Email" = "MINE",
  "Select Position Code/s" = 0,
  "Days not logged in" = 90
  WITH prompt1, prompt2, prompt3
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
  pr.name_full_formatted, pr.username, position = uar_get_code_display(pr.position_cd),
  last_login = format(oa.start_day,"YYYY/MM/DD ;;D"), updt_dt_tm = format(pr.updt_dt_tm,
   "YYYY/MM/DD ;;D")
  FROM prsnl pr,
   omf_app_ctx_day_st oa,
   dummyt d1
  PLAN (pr
   WHERE pr.active_ind=1
    AND pr.updt_dt_tm < cnvtdatetime((curdate -  $PROMPT3),0000)
    AND pr.username > " "
    AND (pr.position_cd= $PROMPT2))
   JOIN (d1)
   JOIN (oa
   WHERE oa.person_id=pr.person_id
    AND oa.start_day < cnvtdatetime((curdate -  $PROMPT3),000)
    AND  NOT ( EXISTS (
   (SELECT
    oai.person_id
    FROM omf_app_ctx_day_st oai
    WHERE oai.person_id=oa.person_id
     AND oai.start_day > oa.start_day))))
  ORDER BY pr.name_full_formatted
  HEAD REPORT
   col 1, ",", "User",
   ",", "Login", ",",
   "Position", ",", "Last Login",
   ",", "Update Date", ",",
   row + 1
  DETAIL
   IF (((oa.start_day < cnvtdatetime(date_qual)) OR (oa.start_day=null)) )
    position = trim(uar_get_code_display(pr.position_cd)), output_string = build(',"',pr
     .name_full_formatted,'","',pr.username,'","',
     position,'","',last_login,'","',updt_dt_tm,
     '",'), col 1,
    output_string
    IF ( NOT (curendreport))
     row + 1
    ENDIF
   ENDIF
  WITH outerjoin = d1, format = variable, formfeed = none
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(concat(output_dest,".dat"))
  SET filename_out = concat(format(curdate,"YYYYMMDD ;;D"),".csv")
  DECLARE subject_line = vc
  SET subject_line = concat(curprog," - Baystate Health CIS Select Positions and Days ")
  SET dclcom = concat('sed "s/$/`echo \\\r`/" ',filename_in," | uuencode ",filename_out,
   ' | mail -s "',
   subject_line,'" ', $1)
  SET len = size(trim(dclcom))
  SET status = 0
  CALL dcl(dclcom,len,status)
  SET dclcom = concat("rm ",output_dest,"*")
  SET len = size(trim(dclcom))
  SET status = 0
  CALL echo(dclcom)
  CALL dcl(dclcom,len,status)
 ENDIF
#end_prog
END GO
