CREATE PROGRAM bhs_eks_find_dup_insurance:dba
 DECLARE mf_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE mf_authverified = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"AUTHVERIFIED")), protect
 SET retval = 0
 SELECT INTO "NL:"
  FROM encntr_plan_reltn epr
  PLAN (epr
   WHERE epr.encntr_id=trigger_encntrid
    AND epr.active_ind=1
    AND epr.data_status_cd=mf_authverified
    AND epr.active_status_cd=mf_active)
  WITH nocounter
 ;end select
 IF (curqual > 1)
  SET retval = 100
 ENDIF
END GO
