CREATE PROGRAM cv_utl_ce_resstat:dba
 SET resstat_notdone_cd = 0.0
 SET resstat_auth_cd = 0.0
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=8
   AND c.active_ind=1
  DETAIL
   IF (cnvtupper(trim(c.cdf_meaning,3))="NOT DONE")
    resstat_notdone_cd = c.code_value
   ELSEIF (cnvtupper(trim(c.cdf_meaning,3))="AUTH")
    resstat_auth_cd = c.code_value
   ENDIF
  WITH nocounter
 ;end select
 UPDATE  FROM clinical_event
  SET result_status_cd = resstat_notdone_cd
  WHERE parent_event_id=event_id
   AND event_id IN (
  (SELECT DISTINCT
   parent_event_id
   FROM clinical_event
   WHERE result_status_cd=resstat_notdone_cd))
   AND result_status_cd=resstat_auth_cd
 ;end update
END GO
