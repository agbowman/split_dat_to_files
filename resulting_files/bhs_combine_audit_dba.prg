CREATE PROGRAM bhs_combine_audit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "UserName" = "*",
  "Please enter start date" = "SYSDATE",
  "End Date" = "SYSDATE"
  WITH outdev, username, start_dt_tm,
  end_dt_tm
 SELECT INTO  $OUTDEV
  FROM person_combine pc,
   person p,
   encounter e,
   encntr_alias ea,
   prsnl pr
  PLAN (pc
   WHERE pc.updt_dt_tm BETWEEN cnvtdatetime( $START_DT_TM) AND cnvtdatetime( $END_DT_TM)
    AND pc.active_ind=1)
   JOIN (p
   WHERE p.person_id=pc.to_person_id
    AND p.active_ind=1)
   JOIN (e
   WHERE e.person_id=p.person_id
    AND e.active_ind=1)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=1077.00)
   JOIN (pr
   WHERE pr.person_id=pc.updt_id
    AND pr.username=patstring( $2))
  ORDER BY pc.updt_id, pc.to_person_id
  HEAD REPORT
   col 50, "Combine/Uncombine Report", total_pat = 0,
   row_cnt = 0
  HEAD PAGE
   row + 1, col 10, "User Name",
   col 30, "Patient Name", col 60,
   "Combined Date", col 75, "To Fin Number",
   col 85, "From FIN Number"
  HEAD pc.updt_id
   row + 1, col 10,
   CALL print(trim(pr.name_full_formatted))
   IF (((row_cnt+ 10) >= 50))
    BREAK
   ENDIF
  DETAIL
   d = format(pc.updt_dt_tm,"MM/DD/YY;;q"), row + 1, col 30,
   CALL print(trim(p.name_full_formatted)), col 60, pc.updt_dt_tm,
   col 75,
   CALL print(trim(ea.alias)), d = ""
   IF (((row_cnt+ 10) >= 50))
    BREAK
   ENDIF
  FOOT  pc.to_person_id
   total_pat = (total_pat+ 1)
  FOOT REPORT
   row + 1, col 10, "Total # Patients",
   col 35, total_pat
  WITH time = 100
 ;end select
END GO
