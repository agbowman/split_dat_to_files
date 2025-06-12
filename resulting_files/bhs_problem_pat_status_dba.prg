CREATE PROGRAM bhs_problem_pat_status:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Choose the problem" = "",
  "Choose the type of report" = 0,
  "Enter the password" = "",
  "Choose a physician" = 0,
  "Choose a practice" = 0,
  "Enter an email address(es) separated by a space" = ""
  WITH outdev, problem, type,
  pass, pcp, group,
  email
 EXECUTE bhs_sys_stand_subroutine
 FREE RECORD t_record
 RECORD t_record(
   1 name = vc
   1 pat_cnt = i4
   1 pat_qual[*]
     2 pid = f8
     2 name = vc
     2 mrn = vc
     2 status = vc
     2 reason = vc
 )
 DECLARE mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,
   "CORPORATEMEDICALRECORDNUMBER"))
 DECLARE l_line = vc
 DECLARE t_line = vc
 IF (( $TYPE=0))
  SELECT INTO  $OUTDEV
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   DETAIL
    col 0, "You did not select a report type. Choose a report type."
   WITH nocounter
  ;end select
  GO TO exit_script
 ELSEIF (( $TYPE=1))
  IF (( $PCP=0))
   SELECT INTO  $OUTDEV
    FROM (dummyt d  WITH seq = 1)
    PLAN (d)
    DETAIL
     col 0, "You did not select a physician. Choose a physician."
    WITH nocounter
   ;end select
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   FROM person p
   PLAN (p
    WHERE (p.person_id= $PCP)
     AND p.active_ind=1)
   DETAIL
    t_record->name = trim(p.name_full_formatted)
  ;end select
  SET l_line = concat("b.pcp_id = ",trim(cnvtstring( $PCP)))
 ELSEIF (( $TYPE=2))
  IF (( $GROUP=0))
   SELECT INTO  $OUTDEV
    FROM (dummyt d  WITH seq = 1)
    PLAN (d)
    DETAIL
     col 0, "You did not select a practice. Choose a practice."
    WITH nocounter
   ;end select
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   FROM bhs_physician_location b,
    bhs_practice_location b1
   PLAN (b
    WHERE (b.location_id= $GROUP))
    JOIN (b1
    WHERE b1.location_id=b.location_id)
   ORDER BY b.person_id
   HEAD REPORT
    t_record->name = b1.location_description, l_line = "b.pcp_id in ( ", first_ind = 0
   HEAD b.person_id
    IF (first_ind=0)
     l_line = concat(l_line,trim(cnvtstring(b.person_id))), first_ind = 1
    ELSE
     l_line = concat(l_line,",",trim(cnvtstring(b.person_id)))
    ENDIF
   FOOT REPORT
    l_line = concat(l_line,")")
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM bhs_problem_registry b,
   person p,
   person_alias pa
  PLAN (b
   WHERE parser(l_line)
    AND b.problem="DIABETES")
   JOIN (p
   WHERE p.person_id=b.person_id)
   JOIN (pa
   WHERE pa.person_id=b.person_id
    AND pa.person_alias_type_cd=mrn_cd
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY b.person_id, pa.active_status_dt_tm DESC
  HEAD b.person_id
   IF (((b.active_ind=1) OR (b.active_ind=0
    AND b.reason != "Patient Expired")) )
    t_record->pat_cnt = (t_record->pat_cnt+ 1), stat = alterlist(t_record->pat_qual,t_record->pat_cnt
     ), t_record->pat_qual[t_record->pat_cnt].pid = b.person_id,
    t_record->pat_qual[t_record->pat_cnt].name = p.name_full_formatted, t_record->pat_qual[t_record->
    pat_cnt].mrn = pa.alias
    IF (b.active_ind=0)
     t_record->pat_qual[t_record->pat_cnt].status = "Inactive", t_record->pat_qual[t_record->pat_cnt]
     .reason = b.reason
    ELSE
     t_record->pat_qual[t_record->pat_cnt].status = "Active"
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (( $TYPE=1))
  SELECT INTO "diabetes_patient_status.xls"
   name = t_record->pat_qual[d.seq].name, id = t_record->pat_qual[d.seq].pid
   FROM (dummyt d  WITH seq = t_record->pat_cnt)
   PLAN (d)
   ORDER BY name, id
   HEAD REPORT
    t_line = concat("Diabetes Patient Status Report for ",t_record->name), col 0, t_line,
    row + 1, t_line = concat("Name",char(9),"MRN",char(9),"Status",
     char(9),"Reason"), col 0,
    t_line, row + 1
   HEAD id
    t_line = concat(t_record->pat_qual[d.seq].name,char(9),t_record->pat_qual[d.seq].mrn,char(9),
     t_record->pat_qual[d.seq].status,
     char(9),t_record->pat_qual[d.seq].reason), col 0, t_line,
    row + 1
   WITH nocounter, maxcol = 1000, formfeed = none
  ;end select
 ELSEIF (( $TYPE=2))
  SELECT INTO "diabetes_patient_status.xls"
   p_name = p.name_full_formatted, name = t_record->pat_qual[d.seq].name, id = t_record->pat_qual[d
   .seq].pid
   FROM (dummyt d  WITH seq = t_record->pat_cnt),
    bhs_problem_registry b,
    person p
   PLAN (d)
    JOIN (b
    WHERE (b.person_id=t_record->pat_qual[d.seq].pid))
    JOIN (p
    WHERE p.person_id=b.pcp_id)
   ORDER BY p_name, name, id
   HEAD REPORT
    t_line = concat("Diabetes Registry for ",t_record->name), col 0, t_line,
    row + 1, t_line = concat("Physician",char(9),"Name",char(9),"MRN",
     char(9),"Status",char(9),"Reason"), col 0,
    t_line, row + 1
   HEAD id
    t_line = concat(p.name_full_formatted,char(9),t_record->pat_qual[d.seq].name,char(9),t_record->
     pat_qual[d.seq].mrn,
     char(9),t_record->pat_qual[d.seq].status,char(9),t_record->pat_qual[d.seq].reason), col 0,
    t_line,
    row + 1
   WITH nocounter, maxcol = 1000, formfeed = none
  ;end select
 ENDIF
 IF (findfile("diabetes_patient_status.xls")=1)
  SET email_list = "anthony.jacobson@bhs.org"
  SET subject_line = "Diabetes Patient Status"
  CALL emailfile("diabetes_patient_status.xls","diabetes_patient_status.xls",email_list,subject_line,
   1)
  SET t_line = concat("The report was emailed to ",email_list)
  SELECT INTO  $OUTDEV
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   DETAIL
    col 0, t_line
   WITH nocounter
  ;end select
 ENDIF
#exit_script
END GO
