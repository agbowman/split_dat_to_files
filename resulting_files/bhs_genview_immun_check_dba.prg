CREATE PROGRAM bhs_genview_immun_check:dba
 DECLARE var_person_id = f8 WITH protect
 DECLARE var_encntr_id = f8 WITH protect
 DECLARE var_ip_ind = vc WITH protect
 DECLARE ms_log = vc WITH protect, noconstant(" ")
 IF (validate(request->visit[1].encntr_id,0.00) <= 0.00)
  IF (cnvtreal( $1) <= 0.00)
   GO TO exit_script
  ELSE
   SET var_encntr_id = cnvtreal( $1)
  ENDIF
 ELSE
  SET var_encntr_id = request->visit[1].encntr_id
 ENDIF
 DECLARE inpatient_var = f8
 SET inpatient_var = uar_get_code_by("DISPLAYKEY",321,"INPATIENT")
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 SELECT DISTINCT INTO "nl:"
  e.encntr_id, e.encntr_type_cd
  FROM encounter e
  PLAN (e
   WHERE e.encntr_id=var_encntr_id)
  ORDER BY e.person_id, e.encntr_class_cd
  DETAIL
   IF (e.encntr_class_cd=inpatient_var)
    var_ip_ind = "Y"
   ENDIF
   var_person_id = e.person_id
  WITH nocounter
 ;end select
 IF (var_ip_ind="Y")
  EXECUTE bhs_genview_immun_check_ip var_person_id
 ELSE
  EXECUTE bhs_genview_immun_check_amb var_person_id
 ENDIF
#exit_script
 SET last_mod =
 "001 30-12-16 C14393 SR 414030933 Modified the script to print Meningococcal B vaccine in the Powerchart Application."
END GO
