CREATE PROGRAM bhs_eks_premedic_plat_transfus:dba
 SET eid = trigger_encntrid
 SET retval = 0
 SET check_result_cd = uar_get_code_by("DISPLAYKEY",72,"PREMEDICATEDPRIORPLATELETTRANSFUSION")
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE ce.encntr_id=eid
    AND ce.event_cd=check_result_cd
    AND ce.result_val="Yes")
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET retval = 100
 ENDIF
#exit_prog
END GO
