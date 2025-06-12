CREATE PROGRAM bhs_eks_ews_check_custom_list
 PROMPT
  "Enter Patient List Display: " = "",
  " Enter List Owner Username: " = "",
  "  Enter PERSON_ID to check: " = 0.00,
  "  Enter ENCNTR_ID to check: " = 0.00
 IF (validate(eksevent,"A")="A"
  AND validate(eksevent,"Z")="Z")
  DECLARE log_message = vc
  DECLARE retval = i4
  DECLARE log_misc1 = vc
 ENDIF
 SET retval = - (1)
 DECLARE var_list_name = vc
 DECLARE var_user_name = vc
 DECLARE var_person_id = f8
 DECLARE var_encntr_id = f8
 DECLARE search_type_ind = i2
 DECLARE cs27360_custom_list_cd = f8 WITH constant(uar_get_code_by("MEANING",27360,"CUSTOM"))
 DECLARE list_found_ind = i2
 DECLARE person_found_ind = i2
 DECLARE encntr_found_ind = i2
 IF (textlen( $1) < 1)
  SET log_message = "No patient list name given"
  SET retval = - (1)
  GO TO exit_script
 ELSE
  SET var_list_name = trim( $1,3)
  SET log_message = build2("Patient List name '",var_list_name,"'")
 ENDIF
 IF (trim(cnvtupper(cnvtalphanum( $2)),4) <= " ")
  SET log_message = build2(log_message," | No owner username given")
  SET retval = - (1)
  GO TO exit_script
 ELSE
  SET var_user_name = trim(cnvtupper(cnvtalphanum( $2)),4)
  SET log_message = build2(log_message," | Owner username '",var_user_name,"'")
 ENDIF
 IF (cnvtreal( $3) <= 0.00)
  SET log_message = build2(log_message," | No PERSON_ID given")
 ELSE
  SET var_person_id = cnvtreal( $3)
  SET log_message = build2(log_message," | PERSON_ID = ",trim(build2(var_person_id),3))
 ENDIF
 IF (cnvtreal( $4) <= 0.00)
  SET log_message = build2(log_message," | No ENCNTR_ID given")
 ELSE
  SET var_encntr_id = cnvtreal( $4)
  SET log_message = build2(log_message," | ENCNTR_ID = ",trim(build2(var_encntr_id),3))
 ENDIF
 IF (((var_person_id+ var_encntr_id) <= 0.00))
  SET log_message = build(log_message," | No PERSON_ID or ENCNTR_ID found")
  SET retval = - (1)
  GO TO exit_script
 ELSEIF (var_encntr_id > 0.00)
  SET search_type = "E"
  SET log_message = build2(log_message," | Qualifying on ENCNTR_ID")
 ELSE
  SET search_type = "P"
  SET log_message = build2(log_message," | Qualifying on PERSON_ID")
 ENDIF
 SELECT INTO "nl:"
  dpl.name
  FROM dcp_patient_list dpl,
   prsnl pr,
   dcp_pl_custom_entry dplce2
  PLAN (dpl
   WHERE dpl.name=patstring(var_list_name)
    AND dpl.patient_list_type_cd=cs27360_custom_list_cd)
   JOIN (pr
   WHERE dpl.owner_prsnl_id=pr.person_id
    AND pr.username=var_user_name)
   JOIN (dplce2
   WHERE outerjoin(dpl.patient_list_id)=dplce2.patient_list_id
    AND dplce2.encntr_id=outerjoin(var_encntr_id))
  ORDER BY dplce2.encntr_id
  HEAD dpl.patient_list_id
   CALL echo(dpl.name),
   CALL echo(var_list_name)
   IF (dplce2.encntr_id > 0.00)
    encntr_found_ind = 1, person_found_ind = 1, list_found_ind = 1,
    log_misc1 = trim(build2(dpl.patient_list_id),3),
    CALL echo(build("patient found on some list",dpl.name,":",dpl.patient_list_id))
   ENDIF
   IF (trim(dpl.name,3)=trim(var_list_name,3)
    AND findstring("*",var_list_name) <= 0)
    list_found_ind = 1, log_misc1 = trim(build2(dpl.patient_list_id),3),
    CALL echo(build("exact list found",dpl.name,":",dpl.patient_list_id))
   ENDIF
  WITH nocounter
 ;end select
 IF (list_found_ind != 1)
  SET log_message = build2(log_message," | Patient List '",var_list_name,"' not found for user '",
   var_user_name,
   "'")
  SET retval = 0
  GO TO exit_script
 ELSE
  SET log_message = build2(log_message," | Patient List '",var_list_name,"' found (",log_misc1,
   ") for user '",var_user_name,"'")
 ENDIF
 IF (search_type="P")
  SET log_message = build2(log_message," | PERSON_ID ",trim(build2(var_person_id),3))
  IF (person_found_ind=1)
   SET log_message = build2(log_message," found on patient list")
   SET retval = 100
  ELSE
   SET log_message = build2(log_message," NOT found on patient list")
   SET retval = 0
  ENDIF
 ELSE
  SET log_message = build2(log_message," | ENCNTR_ID ",trim(build2(var_encntr_id),3))
  IF (encntr_found_ind=1)
   SET log_message = build2(log_message," found on patient list")
   SET retval = 100
  ELSE
   SET log_message = build2(log_message," NOT found on patient list")
   SET retval = 0
  ENDIF
 ENDIF
#exit_script
 SET log_message = build2(log_message,". Exitting Script")
 CALL echo(build2("RETVAL: ",retval))
 CALL echo(build2("LOG_MESSAGE: ",log_message))
 FREE SET var_encntr_id
 FREE SET var_list_name
 FREE SET var_user_name
 FREE SET search_type_ind
 FREE SET cs27360_custom_list_cd
 FREE SET list_found_ind
 FREE SET person_found_ind
 FREE SET encntr_found_ind
END GO
