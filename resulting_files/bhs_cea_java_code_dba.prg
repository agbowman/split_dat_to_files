CREATE PROGRAM bhs_cea_java_code:dba
 SELECT DISTINCT
  cea.action_prsnl_group_id, cea.assign_prsnl_id, cea.action_prsnl_id,
  cea.event_id, ce.person_id, ce.event_cd,
  ce.encntr_id, ce.event_class_cd, ce.normalcy_cd
  FROM encounter e,
   v500_event_set_explode ex,
   clinical_event ce,
   ce_event_action cea
  PLAN (cea
   WHERE cea.action_prsnl_id=1
    AND cea.updt_dt_tm BETWEEN cnvtdatetime((curdate - 1),0) AND cnvtdatetime(curdate,0))
   JOIN (ce
   WHERE ce.event_id=cea.event_id
    AND ce.valid_until_dt_tm > sysdate
    AND ce.person_id=1)
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id
    AND e.encntr_type_cd IN (1, 2))
   JOIN (ex
   WHERE ex.event_cd=ce.event_cd
    AND ex.event_set_cd IN (1, 2))
  WITH time = 5, maxrec = 50, rdbplan,
   format, separator = " "
 ;end select
END GO
