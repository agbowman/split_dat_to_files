CREATE PROGRAM bhs_eks_updt_custom_list
 PROMPT
  "Enter PATIENT_LIST_ID to update: " = 0.00,
  "Choose Action (A)dd or (R)emove: " = "",
  "  Enter PERSON_ID to add/remove: " = 0.00,
  "  Enter ENCNTR_ID to add/remove: " = 0.00
 IF (validate(eksevent,"A")="A"
  AND validate(eksevent,"Z")="Z")
  DECLARE log_message = vc
  DECLARE retval = i4
 ENDIF
 FREE RECORD bhs_request
 RECORD bhs_request(
   1 patient_list_id = f8
   1 additions[*]
     2 person_id = f8
     2 encounter_id = f8
     2 priority = i4
   1 subtractions[*]
     2 person_id = f8
     2 encounter_id = f8
 )
 FREE RECORD bhs_reqinfo
 RECORD bhs_reqinfo(
   1 commit_ind = i2
   1 updt_id = f8
   1 updt_task = i4
   1 updt_applctx = i4
 )
 FREE RECORD bhs_reply
 RECORD bhs_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE var_updt_action = c1
 DECLARE var_person_id = f8
 DECLARE var_encntr_id = f8
 IF (cnvtreal( $1) <= 0.00)
  SET log_message = "No PATIENT_LIST_ID given"
  SET retval = - (1)
  GO TO exit_script
 ELSE
  SET bhs_request->patient_list_id = cnvtreal( $1)
  SET log_message = build2("PATIENT_LIST_ID = ",trim(build2(bhs_request->patient_list_id),3))
 ENDIF
 IF ( NOT (trim(cnvtupper( $2),4) IN ("A", "R")))
  SET log_message = build2(log_message," | No action given")
  SET retval = - (1)
  GO TO exit_script
 ELSE
  SET var_updt_action = trim(cnvtupper( $2),4)
  SET log_message = build2(log_message," | Update Action = '",var_updt_action,"'")
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
  IF (var_person_id <= 0.00)
   SELECT INTO "NL:"
    e.person_id
    FROM encounter e
    PLAN (e
     WHERE e.encntr_id=var_encntr_id)
    DETAIL
     var_person_id = e.person_id
    WITH nocounter
   ;end select
   SET log_message = build2(log_message," | PERSON_ID = ",trim(build2(var_person_id),3),
    " (from ENCOUNTER table)")
  ENDIF
 ENDIF
 IF (((var_person_id+ var_encntr_id) <= 0.00))
  SET log_message = build2(log_message," | No PERSON_ID or ENCNTR_ID to add/remove")
  SET retval = - (1)
  GO TO exit_script
 ELSE
  IF (var_updt_action="A")
   SET stat = alterlist(bhs_request->additions,1)
   SET bhs_request->additions[1].person_id = var_person_id
   SET bhs_request->additions[1].encounter_id = var_encntr_id
  ELSE
   SET stat = alterlist(bhs_request->subtractions,1)
   SET bhs_request->subtractions[1].person_id = var_person_id
   SET bhs_request->subtractions[1].encounter_id = var_encntr_id
  ENDIF
 ENDIF
 EXECUTE dcp_upd_custom_pl  WITH replace(request,bhs_request), replace(reqinfo,bhs_reqinfo), replace(
  reply,bhs_reply)
 SET log_message = build2(log_message," | PERSON_ID ",trim(build2(var_person_id),3)," & ENCNTR_ID ",
  trim(build2(var_encntr_id),3))
 IF ((bhs_reqinfo->commit_ind=1))
  COMMIT
  SET retval = 100
  IF (var_updt_action="A")
   SET log_message = build2(log_message," added to patient list")
  ELSE
   SET log_message = build2(log_message," removed from patient list")
  ENDIF
 ELSE
  ROLLBACK
  SET retval = - (1)
  IF (var_updt_action="A")
   SET log_message = build2(log_message," NOT added to patient list")
  ELSE
   SET log_message = build2(log_message," NOT removed from patient list")
  ENDIF
 ENDIF
#exit_script
 SET log_message = build2(log_message,". Exitting Script")
 CALL echo(log_message)
 FREE SET var_updt_action
 FREE SET var_person_id
 FREE SET var_encntr_id
 FREE RECORD bhs_request
 FREE RECORD bhs_reqinfo
 FREE RECORD bhs_reply
END GO
