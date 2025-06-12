CREATE PROGRAM dcp_chk_person_cbn:dba
 RECORD reply(
   1 prsn_cmbn_ind = i2
   1 new_patient_id = f8
   1 new_name_full = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persistscript
 FREE SET dm_cmb_request
 RECORD dm_cmb_request(
   1 person_id = f8
   1 encntr_id = f8
 )
 FREE SET dm_cmb_reply
 RECORD dm_cmb_reply(
   1 person_id = f8
   1 encntr_id = f8
   1 new_person_id = f8
   1 new_encntr_id = f8
   1 valid_person_ind = i2
   1 valid_encntr_ind = i2
   1 person_encntr_match_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET modify = predeclare
 DECLARE failure_ind = i2 WITH protect, noconstant(false)
 DECLARE zero_ind = i2 WITH protect, noconstant(false)
 DECLARE status = i2 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 CALL getpersoncmbnind(null)
 SUBROUTINE getpersoncmbnind(null)
   IF ((request->patient_id=0))
    SET failure_ind = true
    GO TO failure
   ENDIF
   SET dm_cmb_request->person_id = request->patient_id
   SET dm_cmb_request->encntr_id = request->encntr_id
   SET modify = nopredeclare
   EXECUTE dm_combine_in_process  WITH replace(request,dm_cmb_request), replace(reply,dm_cmb_reply)
   SET modify = predeclare
   IF ((dm_cmb_reply->valid_person_ind=0)
    AND (dm_cmb_reply->new_person_id != request->patient_id))
    SET reply->prsn_cmbn_ind = 1
    SET reply->new_name_full = getpersonname(dm_cmb_reply->new_person_id)
    SET reply->new_patient_id = dm_cmb_reply->new_person_id
   ELSE
    SET reply->prsn_cmbn_ind = 0
    SET zero_ind = true
    GO TO failure
   ENDIF
 END ;Subroutine
 SUBROUTINE getpersonname(patient_id)
   DECLARE name_full_formatted = vc WITH protect, noconstant("")
   IF (patient_id > 0.0)
    SELECT INTO "nl:"
     FROM person p
     WHERE p.person_id=patient_id
     DETAIL
      name_full_formatted = p.name_full_formatted
     WITH nocounter
    ;end select
   ENDIF
   RETURN(name_full_formatted)
 END ;Subroutine
 SET modify = nopredeclare
#failure
 IF (failure_ind=true)
  CALL echo("*Person combine check is failed*")
 ELSEIF (zero_ind=true)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
