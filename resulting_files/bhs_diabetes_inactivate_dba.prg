CREATE PROGRAM bhs_diabetes_inactivate:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Choose the problem type" = "",
  "Enter the Practice's Password" = "",
  "Choose a physician" = 0,
  "Choose the patient you wish to change" = 0,
  "Please enter a reason" = ""
  WITH outdev, problem, pass,
  pcp, person, reason
 FREE RECORD t_record
 RECORD t_record(
   1 pat_cnt = i4
   1 pat_qual[*]
     2 person_id = f8
     2 active_ind = i2
 )
 IF (( $PCP=0))
  SELECT INTO  $OUTDEV
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   DETAIL
    col 0, "You must choose a physician"
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 IF (( $PERSON=0))
  SELECT INTO  $OUTDEV
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   DETAIL
    col 0, "You must choose a patient"
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 IF (textlen( $REASON)=1)
  SELECT INTO  $OUTDEV
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   DETAIL
    col 0, "You must choose a reason"
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM bhs_problem_registry b
  PLAN (b
   WHERE (b.person_id= $PERSON)
    AND (b.problem= $PROBLEM))
  ORDER BY b.person_id
  HEAD b.person_id
   t_record->pat_cnt = (t_record->pat_cnt+ 1), stat = alterlist(t_record->pat_qual,t_record->pat_cnt),
   t_record->pat_qual[t_record->pat_cnt].person_id = b.person_id
   IF (b.active_ind=1)
    t_record->pat_qual[t_record->pat_cnt].active_ind = 0
   ELSE
    t_record->pat_qual[t_record->pat_cnt].active_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 FOR (i = 1 TO t_record->pat_cnt)
  UPDATE  FROM bhs_problem_registry b
   SET b.active_ind = t_record->pat_qual[i].active_ind, b.reason =  $REASON
   WHERE (b.person_id=t_record->pat_qual[i].person_id)
    AND (b.problem= $PROBLEM)
  ;end update
  COMMIT
 ENDFOR
 SELECT INTO  $OUTDEV
  FROM (dummyt d  WITH seq = t_record->pat_cnt),
   person p
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=t_record->pat_qual[d.seq].person_id)
    AND p.active_ind=1)
  ORDER BY p.name_full_formatted
  HEAD REPORT
   col 0, "The following patient's status changed. 1 = Active 0 = Inactive", row + 1,
   col 0, "Patient", col 50,
   "New Status", col 65, "Reason",
   row + 1
  HEAD p.name_full_formatted
   col 0,
   CALL print(trim(p.name_full_formatted)), col 50,
   CALL print(trim(cnvtstring(t_record->pat_qual[d.seq].active_ind))), col 65,
   CALL print(trim( $REASON)),
   row + 1
  WITH nocounter
 ;end select
#exit_script
END GO
