CREATE PROGRAM bhs_eks_chk_vnod:dba
 DECLARE mf_person_id = f8 WITH protect, constant(trigger_personid)
 DECLARE mf_encntr_id = f8 WITH protect, constant(trigger_encntrid)
 DECLARE mf_vnod_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "VOLUNTARYNONOPIOIDDIRECTIVE"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 IF (validate(retval)=0)
  DECLARE retval = i4 WITH public, noconstant(0)
 ENDIF
 IF (validate(log_message)=0)
  DECLARE log_message = vc WITH public, noconstant(" ")
 ENDIF
 SELECT INTO "nl:"
  FROM clinical_event ce
  WHERE ce.encntr_id=mf_encntr_id
   AND ce.person_id=mf_person_id
   AND ce.event_cd=mf_vnod_cd
   AND ce.result_status_cd IN (mf_auth_cd, mf_modified_cd, mf_altered_cd)
   AND ce.valid_until_dt_tm > sysdate
  HEAD REPORT
   log_message = concat("VNOD found on encounter: ",trim(cnvtstring(mf_encntr_id),3)," event_id: ",
    trim(cnvtstring(ce.event_id),3))
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET retval = 100
 ELSE
  SET log_message = concat("No VNOD found on encounter: ",trim(cnvtstring(mf_encntr_id),3))
 ENDIF
 CALL echo(build2(retval," ",log_message))
#exit_script
END GO
