CREATE PROGRAM bhs_eks_teaching_coverage
 DECLARE teaching_cov = f8 WITH constant(uar_get_code_by("DISPLAYKEY",333,"TEACHINGCOVERAGE")),
 protect
 DECLARE group_display = vc
 SET retval = 0
 SELECT INTO "nl:"
  FROM encntr_prsnl_reltn epr,
   prsnl pr
  PLAN (epr
   WHERE epr.encntr_id=trigger_encntrid
    AND epr.encntr_prsnl_r_cd=teaching_cov
    AND epr.end_effective_dt_tm > sysdate
    AND epr.active_ind=1)
   JOIN (pr
   WHERE pr.person_id=epr.prsnl_person_id)
  DETAIL
   group_display = pr.name_full_formatted
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET log_message = build("No Medical Teaching Teams found")
  GO TO exit_code
 ELSE
  SET log_misc1 = concat('"',trim(group_display),'"')
  SET log_message = log_misc1
  SET retval = 100
 ENDIF
#exit_code
END GO
