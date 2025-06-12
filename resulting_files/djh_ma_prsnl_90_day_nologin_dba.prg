CREATE PROGRAM djh_ma_prsnl_90_day_nologin:dba
 PROMPT
  "Output to File/Printer/MINE" = '"David.Hounshell@bhs.org"'
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
 SET date_qual = cnvtlookbehind("90,D",cnvtdatetime(curdate,curtime3))
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
    AND ((pr.physician_ind != 1) OR (pr.physician_ind=1
    AND ((pr.position_cd=925850) OR (((pr.position_cd=93550176) OR (((pr.position_cd=227480046) OR (
   pr.position_cd=228835487)) )) )) ))
    AND pr.active_status_cd=188.00
    AND pr.updt_dt_tm < cnvtdatetime((curdate - 90),0)
    AND pr.username > " "
    AND pr.username != "TESTPR"
    AND pr.username != "REFUSORD"
    AND pr.username != "CN*"
    AND pr.username != "EDATTEND"
    AND pr.username != "INPTATTEND"
    AND pr.username != "FNDTLIST"
    AND pr.username != "FNENGINE"
    AND pr.username != "EDPLASMA"
    AND pr.username != "TRAUMARESIDENT"
    AND pr.username != "TRAUMARES"
    AND pr.username != "EDCACHE"
    AND pr.username != "DUM*"
    AND pr.name_last_key != "BHS*"
    AND pr.name_last_key != "BMC*"
    AND pr.name_last_key != "FMC*"
    AND pr.name_last_key != "MLH*"
    AND pr.name_last_key != "ORGS*"
    AND pr.name_last_key != "INBOX*"
    AND pr.username != "BHSDBA"
    AND pr.username != "CERSUP1"
    AND pr.username != "CERSUP2"
    AND pr.username != "CERSUP3"
    AND pr.username != "CERSUP4"
    AND pr.username != "CERSUP5"
    AND pr.username != "ETE1"
    AND pr.username != "ETE2"
    AND pr.username != "ETE3"
    AND pr.username != "MED2A"
    AND pr.username != "MOBJECTS"
    AND pr.username != "RESET"
    AND pr.username != "PATROL"
    AND pr.username != "SHIELDS"
    AND pr.username != "PHTRIAGE"
    AND pr.username != "BEDROCK"
    AND pr.username != "CER*"
    AND  NOT (pr.position_cd IN (0, 925824, 925830, 925831, 925832,
   925833, 925834, 925835, 925836, 925837,
   925841, 925842, 925843, 925844, 925845,
   925846, 925847, 925848, 925851, 925852,
   925825, 925826, 925827, 925828, 719476,
   966300, 966301, 1646210, 777650, 457,
   65699687, 227498645, 227489555, 227488270, 227500552,
   227501096, 227493605, 227501606, 227502108, 227494305,
   227502642, 227477522, 227490084, 227481339, 227494883,
   227466524, 227460684, 227499154, 227495902, 227476846,
   227499682, 227496433, 228838033, 228895728, 227497546,
   227498152, 227496916))
    AND  NOT (pr.person_id IN (
   (SELECT
    oai.person_id
    FROM omf_app_ctx_day_st oai
    WHERE oai.person_id=pr.person_id
     AND oai.start_day > cnvtdatetime((curdate - 90),000)))))
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
   ",", row + 1
  HEAD pr.name_last
   IF (pr.physician_ind=1)
    physflg = "*"
   ELSE
    physflg = " "
   ENDIF
   position = trim(uar_get_code_display(pr.position_cd)), last_login = format(oa.start_day,
    "YYYY/MM/DD;;D"), output_string = build(',"',pr.name_last,'","',pr.name_first,'","',
    physflg,'","',pr.username,'","',position,
    '","',last_login,'","',updt_dt_tm,'",'),
   col 1, output_string
   IF ( NOT (curendreport))
    row + 1
   ENDIF
  WITH format = variable, formfeed = none
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(concat(output_dest,".dat"))
  SET filename_out = concat(format(curdate,"YYYY-MM-DD;;D"),".csv")
  DECLARE subject_line = vc
  SET subject_line = concat(curprog," V5.2 - BHS CIS Acnts inactive 90 days")
  EXECUTE bhs_ma_email_file
  CALL emailfile(filename_in,filename_out, $1,subject_line,1)
 ENDIF
#end_prog
END GO
