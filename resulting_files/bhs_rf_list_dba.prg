CREATE PROGRAM bhs_rf_list:dba
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
 DECLARE ref_phys = f8
 SET ref_phys = uar_get_code_by("display",88,"Reference Physician")
 CALL echo(format(date_qual,"YYYY/MM/DD;;D"))
 DECLARE output_string = vc
 SELECT DISTINCT INTO value(output_dest)
  p.username, p.person_id, p_position_disp = uar_get_code_display(p.position_cd)"###################",
  p.updt_dt_tm, p.create_prsnl_id, p.create_dt_tm,
  p.updt_id, p.name_full_formatted, p.position_cd,
  p.active_ind
  FROM prsnl p
  WHERE p.active_ind=1
   AND ((p.position_cd=ref_phys) OR (p.username="RF*"))
   AND p.updt_dt_tm BETWEEN cnvtdatetime(curdate,0) AND cnvtdatetime(curdate,2400)
  ORDER BY p.updt_dt_tm, p.name_full_formatted
  HEAD REPORT
   col 1, ",", "Node:",
   ",", curnode, row + 1,
   col 1, ",", "UserName",
   ",", "person_id", ",",
   "Full Name", ",", "Phys-Ind",
   ",", "Position", ",",
   "Update Date", ",", "Update ID",
   ",", row + 1
  HEAD p.name_last
   IF (p.physician_ind=1)
    physflg = "*"
   ELSE
    physflg = " "
   ENDIF
   output_string = build(',"',p.username,'","',cnvtstring(p.person_id),'","',
    p.name_full_formatted,'","',physflg,'","',p_position_disp,
    '","',format(p.updt_dt_tm,"mm-dd-yyyy;;D"),'","',format(p.updt_id,"###########"),'",'), col 1,
   output_string
   IF ( NOT (curendreport))
    row + 1
   ENDIF
  WITH format = variable, formfeed = none
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(concat(output_dest,".dat"))
  SET filename_out = concat(format(curdate,"YYYY-MM-DD;;D"),"_RF_CHG.csv")
  DECLARE subject_line = vc
  SET subject_line = concat(curprog," V1.0 - Reference Phys chgs")
  EXECUTE bhs_ma_email_file
  CALL emailfile(filename_in,filename_out, $1,subject_line,1)
 ENDIF
#end_prog
END GO
