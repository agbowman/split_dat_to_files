CREATE PROGRAM bhs_combine_audit_nenuncombine
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "UserName" = "*",
  "Please enter start date" = "SYSDATE",
  "End Date" = "SYSDATE",
  "Email or Report" = "Report_View"
  WITH outdev, username, start_dt_tm,
  end_dt_tm, email
 DECLARE var_output = vc
 DECLARE email_ind = i4
 SET email_ind = 4
 IF (findstring("@", $EMAIL) > 0)
  SET email_ind = 1
  SET var_output = "combinetestinge"
  SET filedelimiter1 = '"'
  SET filedelimiter2 = ","
 ELSE
  SET var_output =  $OUTDEV
  SET email_ind = 0
  SET filedelimiter1 = ""
  SET filedelimiter2 = ""
 ENDIF
 SELECT DISTINCT INTO value(var_output)
  en# = pr.username, pr.name_full_formatted, name = p.name_full_formatted,
  from_encntr = ec.from_encntr_id, ec.updt_dt_tm"mm/dd/yyyy hh:mm:ss", ec.to_encntr_id,
  from_mrn = pa.alias, from_fin = ea1.alias, to_fin = ea.alias
  FROM encntr_combine ec,
   prsnl pr,
   encounter e,
   encounter e1,
   person_alias pa1,
   encntr_combine_det ecd,
   encntr_alias ea1,
   person_alias pa,
   encntr_alias ea,
   person p1,
   person p
  PLAN (ec
   WHERE ec.updt_dt_tm BETWEEN cnvtdatetime( $START_DT_TM) AND cnvtdatetime( $END_DT_TM)
    AND ec.active_ind=1)
   JOIN (pr
   WHERE pr.person_id=ec.updt_id
    AND pr.username=patstring( $2))
   JOIN (ea
   WHERE ea.encntr_id=outerjoin(ec.to_encntr_id)
    AND ea.encntr_alias_type_cd=outerjoin(1077.00)
    AND ea.updt_task != outerjoin(100102)
    AND ea.active_ind=outerjoin(1))
   JOIN (e1
   WHERE ea.encntr_id=e1.encntr_id)
   JOIN (p1
   WHERE p1.person_id=e1.person_id)
   JOIN (pa1
   WHERE pa1.person_id=p1.person_id
    AND ((pa1.person_alias_type_cd+ 0)=2))
   JOIN (e
   WHERE e.encntr_id=ec.from_encntr_id)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=2)
   JOIN (ecd
   WHERE ecd.encntr_combine_id=ec.encntr_combine_id
    AND ecd.entity_name="ENCNTR_ALIAS")
   JOIN (ea1
   WHERE ea1.encntr_alias_id=outerjoin(ecd.entity_id)
    AND ea1.encntr_alias_type_cd=outerjoin(1077)
    AND ea1.updt_task=outerjoin(100102)
    AND ea1.active_ind=outerjoin(0))
  ORDER BY pa.alias, ea.alias, pr.person_id,
   ec.to_encntr_id, 0
  HEAD REPORT
   CALL center("Combine Report On Same Person FIN Only",0,150), line = fillstring(200,"="), total_cnt
    = 0
  HEAD PAGE
   row + 1, col + 0,
   CALL print(build("EN#",",")),
   col + 0,
   CALL print(build("User Name",",")), col + 0,
   CALL print(build("From MRN",",")), col + 0,
   CALL print(build("To MRN",",")),
   col + 0,
   CALL print(build("FIN FROM",",")), col + 0,
   CALL print(build("FIN TO",",")), col + 0,
   CALL print(build("Date",","))
  HEAD pr.username
   row + 1, col + 0,
   CALL print(trim(pr.username)),
   col + 0,
   CALL print(","), col + 0,
   CALL print(build(pr.name_last_key,char(32),pr.name_first_key)), col + 0,
   CALL print(",")
  HEAD pa.alias
   row + 1, col + 0,
   CALL print(char(32)),
   col + 0,
   CALL print(","), col + 0,
   CALL print(" "), col + 0,
   CALL print(","),
   col + 0,
   CALL print(trim(pa.alias)), col + 0,
   CALL print(","), col + 0,
   CALL print(trim(pa1.alias))
  DETAIL
   row + 1, col + 0,
   CALL print(char(32)),
   col + 0,
   CALL print(","), col + 0,
   CALL print(char(32)), col + 0,
   CALL print(","),
   col + 0,
   CALL print(char(32)), col + 0,
   CALL print(","), col + 0,
   CALL print(char(32)),
   col + 0,
   CALL print(","), col + 0,
   CALL print(trim(ea1.alias)), col + 0,
   CALL print(","),
   col + 0,
   CALL print(trim(ea.alias)), col + 0,
   CALL print(","), time = build2(format(ec.updt_dt_tm,"MM/DD/YY;;D")," ",format(ec.updt_dt_tm,
     "HH:MM;;S")), col + 0,
   CALL print(time)
  WITH nocounter, maxcol = 150, maxrow = 1,
   formfeed = none, pcformat(value(filedelimiter1),value(filedelimiter2)), landscape
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(var_output)
  SET email_address = trim( $EMAIL)
  SET filename_out = "combinetesting.csv"
  EXECUTE bhs_ma_email_file
  CALL emailfile(concat(filename_in,".dat"),filename_out,email_address,curprog,0)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = concat(trim("combinetestinge"),format(curdate,"MMDDYYYY;;D"),".csv will be sent to -"),
    msg2 = concat("   ", $EMAIL), col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 1, row + 1,
    "{F/1}{CPI/9}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
 ENDIF
END GO
