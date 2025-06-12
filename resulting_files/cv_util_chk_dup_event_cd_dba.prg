CREATE PROGRAM cv_util_chk_dup_event_cd:dba
 SET event_cd = 0
 SET eventcnt = 0
 SET line_s = 0
 SELECT
  ref_event_cd = ref.event_cd, task_assay_cd = ref.task_assay_cd, registry_name = ref
  .registry_field_name
  FROM cv_xref ref
  WHERE ref.active_ind > 0
   AND ref.event_cd > 0
  ORDER BY ref_event_cd
  HEAD REPORT
   eventcnt = 0, lins_s = fillstring(190,"*")
  HEAD PAGE
   col 0, "#######Duplicate Event codes in cv_xref tables:##################### ", row + 1,
   col 0, "Event_cd:", col 10,
   "Task_Assay_cd:", col 30, "Registry_field_name:",
   col + 42, "Total Numbers of Duplicate event codes:", row + 1,
   line_s, row + 1
  HEAD ref_event_cd
   eventcnt = 0
  DETAIL
   eventcnt = (eventcnt+ 1)
  FOOT  ref_event_cd
   IF (eventcnt > 1)
    col 0, ref.event_cd, col 10,
    ref.task_assay_cd, col 30, registry_name,
    col 120, eventcnt, row + 1
   ENDIF
  WITH nocounter
 ;end select
END GO
