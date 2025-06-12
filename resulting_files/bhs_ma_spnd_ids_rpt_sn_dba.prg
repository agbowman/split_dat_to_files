CREATE PROGRAM bhs_ma_spnd_ids_rpt_sn:dba
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
 SET date_qual = cnvtlookbehind("90,D",cnvtdatetime(curdate,curtime3))
 CALL echo(format(date_qual,"YYYY/MM/DD;;D"))
 DECLARE output_string = vc
 SELECT DISTINCT INTO value(output_dest)
  pr.name_last, pr.name_first, pr.username,
  position = uar_get_code_display(pr.position_cd), updt_dt_tm = format(pr.updt_dt_tm,"YYYY/MM/DD ;;D"
   )
  FROM prsnl pr
  PLAN (pr
   WHERE pr.updt_id=99999999
    AND pr.username != "Z99999999"
    AND pr.username="SN*"
    AND pr.updt_dt_tm BETWEEN cnvtdatetime(curdate,0) AND cnvtdatetime(curdate,2400))
  ORDER BY pr.name_last, pr.name_first, 0
  HEAD REPORT
   col 1, ",", "Last Name",
   ",", "First Name", ",",
   "Phys-Ind", ",", "Login",
   ",", "Position", ",",
   "Update Date", ",", row + 1
  HEAD pr.name_last
   IF (pr.physician_ind=1)
    physflg = "*"
   ELSE
    physflg = " "
   ENDIF
   position = trim(uar_get_code_display(pr.position_cd)), output_string = build(',"',pr.name_last,
    '","',pr.name_first,'","',
    physflg,'","',substring(1,7,pr.username),'","',position,
    '","',updt_dt_tm,'",'), col 1,
   output_string
   IF ( NOT (curendreport))
    row + 1
   ENDIF
  WITH format = variable, formfeed = none
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(concat(output_dest,".dat"))
  SET filename_out = concat(format(curdate,"YYYY-MM-DD;;D"),"_SN_SPND.csv")
  DECLARE subject_line = vc
  SET subject_line = concat(curprog," V1.1 - List Suspended IDs")
  EXECUTE bhs_ma_email_file
  CALL emailfile(filename_in,filename_out, $1,subject_line,1)
 ENDIF
#end_prog
END GO
