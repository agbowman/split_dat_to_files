CREATE PROGRAM dm_encntr_history_rpt:dba
 PAINT
 CALL clear(1,1)
 SET rperson_id = 0
 CALL text(1,1,"Enter Person ID (0 to exit): ")
 CALL accept(1,30,"9(10)")
 SET rperson_id = curaccept
 CALL clear(1,1)
 IF (rperson_id=0)
  GO TO end_script
 ENDIF
 SET dm_fin_nbr_cd = 0
 SET dm_visit_cd = 0
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=319
   AND c.cdf_meaning="FIN NBR"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   dm_fin_nbr_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=319
   AND c.cdf_meaning="VISITID"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   dm_visit_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.person_id
  FROM person p
  WHERE p.person_id=rperson_id
   AND p.active_ind=1
 ;end select
 IF (curqual=0)
  SELECT
   d.seq
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   DETAIL
    row + 1,
    "The person does not exist or the person_id is not active, please enter an active person_id."
   WITH nocounter
  ;end select
  EXECUTE dm_encntr_history_rpt
  GO TO end_script
 ENDIF
 SET lines = fillstring(106,"-")
 SELECT DISTINCT
  e.encntr_id"########", pc.from_person_id"########", pc.to_person_id"########",
  pc.updt_dt_tm"MM/DD/YYYY HH:MM;;d", f.updt_dt_tm"MM/DD/YYYY HH:MM;;d", v.updt_dt_tm
  "MM/DD/YYYY HH:MM;;d",
  dt = cnvtdatetime(sysdate)"MM/DD/YYYY;l;d", tm = cnvtdatetime(sysdate)";l;s"
  FROM encounter e,
   person_combine_det pcd,
   person_combine pc,
   encntr_alias f,
   encntr_alias v,
   dummyt d1,
   dummyt d2,
   dummyt d3,
   dummyt d4
  PLAN (e
   WHERE e.active_ind=1
    AND e.person_id=rperson_id)
   JOIN (d1)
   JOIN (pcd
   WHERE e.encntr_id=pcd.entity_id
    AND pcd.active_ind=1
    AND pcd.entity_name="ENCOUNTER")
   JOIN (d2)
   JOIN (pc
   WHERE pc.active_ind=1
    AND pcd.person_combine_id=pc.person_combine_id)
   JOIN (d3)
   JOIN (f
   WHERE f.active_ind=1
    AND f.encntr_alias_type_cd=dm_fin_nbr_cd
    AND e.encntr_id=f.encntr_id
    AND f.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND f.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (d4)
   JOIN (v
   WHERE v.active_ind=1
    AND v.encntr_alias_type_cd=dm_visit_cd
    AND e.encntr_id=v.encntr_id
    AND v.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND v.end_effective_dt_tm >= cnvtdatetime(sysdate))
  ORDER BY e.encntr_id
  HEAD REPORT
   col 0, "Encounter History of Person_ID ", rperson_id,
   row + 1, "Date: ", dt,
   row + 1, "Time: ", tm,
   row + 2
  HEAD PAGE
   col 0, "EncntrID", col 14,
   "FromPersonID", col 30, "ToPersonID",
   col 46, "CombineUpdtDtTm", col 66,
   "FinNbr updt_dt_tm", col 86, "VisitID updt_dt_tm",
   row + 1, col 0, lines,
   row + 1
  DETAIL
   IF (pc.updt_dt_tm != null)
    col 0, e.encntr_id, col 14,
    pc.from_person_id, col 30, pc.to_person_id,
    col 46, pc.updt_dt_tm, col 66,
    f.updt_dt_tm, col 86, v.updt_dt_tm
   ELSE
    col 0, e.encntr_id, col 14,
    "******** Not Combined ********"
   ENDIF
   row + 2
  WITH outerjoin = d1, outerjoin = d2, outerjoin = d3,
   outerjoin = d4
 ;end select
 IF (curqual=0)
  SELECT
   d.seq
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   DETAIL
    row + 1, "No encounter activites found for Person_ID", rperson_id
   WITH nocounter
  ;end select
 ENDIF
#end_script
END GO
