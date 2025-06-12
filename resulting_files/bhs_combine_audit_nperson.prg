CREATE PROGRAM bhs_combine_audit_nperson
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "UserName" = "*",
  "Please enter start date" = "SYSDATE",
  "End Date" = "SYSDATE"
  WITH outdev, username, start_dt_tm,
  end_dt_tm
 SELECT DISTINCT INTO  $OUTDEV
  pc.person_combine_id, pr.username, pr.name_full_formatted,
  toalias = ea.alias, fromname = p.name_full_formatted, toname = p1.name_full_formatted,
  fromalias = pa.alias, toalias = pa1.alias, time = format(pc.updt_dt_tm,"dd-mmm-yyyy hh:mm:ss ;;d")
  FROM person_combine pc,
   prsnl pr,
   person p,
   person p1,
   encntr_alias ea,
   person_alias pa1,
   person_alias pa
  PLAN (pc
   WHERE pc.updt_dt_tm BETWEEN cnvtdatetime( $START_DT_TM) AND cnvtdatetime( $END_DT_TM)
    AND pc.active_ind=1)
   JOIN (p
   WHERE p.person_id=pc.from_person_id)
   JOIN (p1
   WHERE p1.person_id=pc.to_person_id)
   JOIN (pa
   WHERE pa.person_id=outerjoin(p.person_id)
    AND pa.person_alias_type_cd=outerjoin(2.0))
   JOIN (pa1
   WHERE pa1.person_id=p1.person_id
    AND pa1.person_alias_type_cd=2.0
    AND pa1.active_ind=1)
   JOIN (ea
   WHERE ea.encntr_id=outerjoin(pc.encntr_id)
    AND ea.encntr_alias_type_cd=outerjoin(1077.00))
   JOIN (pr
   WHERE pr.person_id=pc.updt_id
    AND pr.username=patstring( $2))
  ORDER BY pc.updt_dt_tm, pc.to_person_id, pc.from_person_id
  WITH nocounter, separator = " ", format
 ;end select
END GO
