CREATE PROGRAM bhs_eks_check_reltn
 SET pid = trigger_personid
 SET eid = trigger_encntrid
 SET attending = uar_get_code_by("displaykey",333,"ATTENDINGPHYSICIAN")
 SET resident = uar_get_code_by("displaykey",333,"RESIDENT")
 SET covering_resident = uar_get_code_by("displaykey",333,"COVERINGRESIDENT")
 SET dba = uar_get_code_by("displaykey",333,"INFOSYSTEMSUPPORT")
 SET pa = uar_get_code_by("displaykey",333,"PHYSICIANASSISTANT")
 SET np = uar_get_code_by("displaykey",333,"NURSEPRACTITIONER")
 SET midwife = uar_get_code_by("displaykey",333,"MIDWIFE")
 SET curr_user = reqinfo->updt_id
 CALL echo(curr_user)
 SET retval = 0
 SELECT INTO "nl:"
  FROM encntr_prsnl_reltn epr
  PLAN (epr
   WHERE epr.encntr_id=eid
    AND epr.prsnl_person_id=curr_user
    AND epr.encntr_prsnl_r_cd IN (attending, resident, covering_resident, dba, pa,
   np, midwife))
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET retval = 100
 ENDIF
END GO
