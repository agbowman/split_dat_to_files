CREATE PROGRAM bed_get_esh_loc:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 all_results_ind = i2
    1 all_specialty_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 DECLARE all_results_code_value = f8 WITH protect
 DECLARE all_specialty_code_value = f8 WITH protect
 DECLARE given_event_set_name_code = f8 WITH protect
 SELECT INTO "nl:"
  FROM v500_event_set_code v
  WHERE v.event_set_name_key="ALLRESULTSECTIONS"
   AND trim(cnvtupper(v.event_set_name))="ALL RESULT SECTIONS"
  DETAIL
   all_results_code_value = v.event_set_cd
  WITH nocounter
 ;end select
 CALL bederrorcheck("Failed to retrive the all results event set code")
 SELECT INTO "nl:"
  FROM v500_event_set_code v
  WHERE v.event_set_name_key="ALLSPECIALTYSECTIONS"
   AND trim(cnvtupper(v.event_set_name))="ALL SPECIALTY SECTIONS"
  DETAIL
   all_specialty_code_value = v.event_set_cd
  WITH nocounter
 ;end select
 CALL bederrorcheck("Failed to retrive the all specialty event set code")
 SELECT INTO "nl:"
  FROM v500_event_set_code v
  WHERE trim(cnvtupper(v.event_set_name))=trim(cnvtupper(request->event_set_name))
  DETAIL
   given_event_set_name_code = v.event_set_cd
  WITH nocounter
 ;end select
 CALL bederrorcheck("Failed to retrive the code for the given event set name")
 IF (given_event_set_name_code=0.0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM v500_event_set_canon v
  WHERE v.event_set_cd=given_event_set_name_code
   AND v.parent_event_set_cd=all_results_code_value
  DETAIL
   reply->all_results_ind = 1
  WITH nocounter
 ;end select
 CALL bederrorcheck("Failed to query v500_event_set_canon for all results event set")
 SELECT INTO "nl:"
  FROM v500_event_set_canon v
  WHERE v.event_set_cd=given_event_set_name_code
   AND v.parent_event_set_cd=all_specialty_code_value
  DETAIL
   reply->all_specialty_ind = 1
  WITH nocounter
 ;end select
 CALL bederrorcheck("Failed to query v500_event_set_canon for all speciality event set")
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
