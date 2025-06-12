CREATE PROGRAM bhs_ma_phys_30_day_nologin
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
 SET date_qual = cnvtlookbehind("30,D",cnvtdatetime(curdate,curtime3))
 DECLARE ref_phys = f8
 SET ref_phys = uar_get_code_by("display",88,"Reference Physician")
 CALL echo(format(date_qual,"YYYY/MM/DD;;D"))
 DECLARE output_string = vc
 SELECT DISTINCT INTO value(output_dest)
  pr.name_last, pr.name_first, pr.username,
  position = uar_get_code_display(pr.position_cd), updt_dt_tm = format(pr.updt_dt_tm,"YYYY/MM/DD;;D")
  FROM prsnl pr,
   omf_app_ctx_day_st oa
  PLAN (pr
   WHERE pr.active_ind=1
    AND pr.active_status_cd=188.00
    AND pr.physician_ind=1
    AND pr.updt_dt_tm < cnvtdatetime((curdate - 30),0)
    AND pr.name_last_key != "*INBOX*"
    AND pr.name_first_key != "*INBOX*"
    AND pr.username > " "
    AND pr.username != "DUM*"
    AND pr.username != "TERM*"
    AND pr.username != "TRMMSO*"
    AND pr.username != "RADIOLOGY"
    AND pr.username != "OINBOX"
    AND pr.username != "INPTDIAB"
    AND pr.username != "NONPCP"
    AND pr.username != "PHYSICIAN"
    AND pr.username != "RESIDENT"
    AND pr.username != "SUS*"
    AND pr.username != "SPND*"
    AND pr.username != "HIST"
    AND pr.username != "REHABMED"
    AND pr.username != "TRANSFUSE"
    AND pr.username != "REFUSORD"
    AND pr.position_cd != ref_phys
    AND  NOT (pr.person_id IN (
   (SELECT
    oai.person_id
    FROM omf_app_ctx_day_st oai
    WHERE oai.person_id=pr.person_id
     AND oai.start_day > cnvtdatetime((curdate - 30),000)))))
   JOIN (oa
   WHERE oa.person_id=outerjoin(pr.person_id))
  ORDER BY pr.name_last, pr.name_first, oa.start_day DESC,
   0
  HEAD REPORT
   col 1, ",", "Last Name",
   ",", "First Name", ",",
   "Phys-Ind", ",", "Login",
   ",", "Position", ",",
   "Last Login", ",", "Update Date",
   ",", "Update ID", ",",
   row + 1
  HEAD pr.name_last
   IF (pr.physician_ind=1)
    physflg = "*"
   ELSE
    physflg = " "
   ENDIF
   position = trim(uar_get_code_display(pr.position_cd)), last_login = format(oa.start_day,
    "YYYY/MM/DD;;D"), output_string = build(',"',pr.name_last,'","',pr.name_first,'","',
    physflg,'","',pr.username,'","',position,
    '","',last_login,'","',updt_dt_tm,'","',
    pr.updt_id,'",'),
   col 1, output_string
   IF ( NOT (curendreport))
    row + 1
   ENDIF
  WITH format = variable, formfeed = none
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(concat(output_dest,".dat"))
  SET filename_out = concat(format(curdate,"YYYY-MM-DD;;D"),"-PHYS.csv")
  DECLARE subject_line = vc
  SET subject_line = concat(curprog," V1.x - Baystate Health CIS PHYS Acnts Inactive 30 days")
  EXECUTE bhs_ma_email_file
  CALL emailfile(filename_in,filename_out, $1,subject_line,1)
 ENDIF
#end_prog
END GO
