CREATE PROGRAM bhs_combine_audit_new
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "UserName" = "*",
  "Please enter start date" = "SYSDATE",
  "End Date" = "SYSDATE"
  WITH outdev, username, start_dt_tm,
  end_dt_tm
 SELECT INTO  $OUTDEV
  FROM person_combine pc,
   prsnl pr,
   person p,
   person p1,
   encntr_alias ea
  PLAN (pc
   WHERE pc.updt_dt_tm BETWEEN cnvtdatetime( $START_DT_TM) AND cnvtdatetime( $END_DT_TM)
    AND pc.active_ind=1)
   JOIN (p
   WHERE p.person_id=pc.from_person_id)
   JOIN (p1
   WHERE p1.person_id=pc.to_person_id)
   JOIN (ea
   WHERE pc.encntr_id=ea.encntr_id
    AND pc.encntr_id != 0.00
    AND ea.encntr_alias_type_cd=1077.00)
   JOIN (pr
   WHERE pr.person_id=pc.updt_id
    AND pr.username=patstring( $2))
  ORDER BY pc.to_person_id, pc.from_person_id
  HEAD REPORT
   CALL center("Combine/Uncombine Report",0,150), line = fillstring(200,"="), total_cnt = 0,
   total_person = 0
  HEAD PAGE
   row + 1, col 10, "User Name",
   col 30, "Patient To ", col 60,
   "FIN Moved", col 80, "Date",
   col 90, "Uncombine Indicater", col 100,
   "Total Moved"
  HEAD pc.to_person_id
   row + 1, total_cnt = (total_cnt+ 1), col 10,
   CALL print(trim(pr.name_full_formatted)), col 30,
   CALL print(trim(p1.name_full_formatted)),
   col 60,
   CALL print(trim(ea.alias)), d = format(pc.updt_dt_tm,"MM/DD/YY;;q"),
   col 80,
   CALL print(trim(d)), d = ""
   IF (pc.combine_action_cd=1103)
    col 90, "Uncombine"
   ELSE
    "Mod/Comb"
   ENDIF
  HEAD pc.from_person_id
   total_person = (total_person+ 1)
  HEAD pc.encntr_id
   total_cnt = (total_cnt+ 1)
  FOOT REPORT
   row + 1, col 10, "Total # Patients Moved",
   col 35, total_person, row + 1,
   col 10, "Total # Encounter", col 30,
   total_cnt, col 100, "page:",
   col + 1, curpage"###"
  WITH time = 60, nullreport
 ;end select
END GO
