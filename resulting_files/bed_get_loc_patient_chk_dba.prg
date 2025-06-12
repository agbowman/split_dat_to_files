CREATE PROGRAM bed_get_loc_patient_chk:dba
 FREE SET reply
 RECORD reply(
   1 locations[*]
     2 code_value = f8
     2 patient_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET locrequest
 RECORD locrequest(
   1 location[*]
     2 location_cd = f8
     2 location_occupied_details_ind = i2
 )
 FREE SET locreply
 RECORD locreply(
   1 qual_cnt = i4
   1 location[*]
     2 location_cd = f8
     2 location_occupied_ind = i2
     2 location_pending_occupied_ind = i2
     2 location_occupied_details[*]
       3 person_id = f8
       3 name_full_formatted = vc
       3 encntr_id = f8
       3 encntr_pending_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET req_cnt = 0
 SET req_cnt = size(request->locations,5)
 SET acm_fail_ind = 0
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->locations,req_cnt)
 SET stat = alterlist(locrequest->location,req_cnt)
 FOR (x = 1 TO req_cnt)
  SET reply->locations[x].code_value = request->locations[x].code_value
  SET locrequest->location[x].location_cd = request->locations[x].code_value
 ENDFOR
 IF (checkprg("PM_CHK_LOCATIONS")=0)
  CALL echo("SCRIPT MISSING")
  GO TO exit_script
 ENDIF
 EXECUTE pm_chk_locations  WITH replace("REQUEST",locrequest), replace("REPLY",locreply)
 IF ((locreply->status_data.status="F"))
  SET acm_fail_ind = 1
 ELSE
  SET rep_cnt = size(locreply->location,5)
  FOR (x = 1 TO rep_cnt)
    IF ((((locreply->location[x].location_occupied_ind=1)) OR ((locreply->location[x].
    location_pending_occupied_ind=1))) )
     SET reply->locations[x].patient_ind = 1
    ENDIF
  ENDFOR
 ENDIF
#exit_script
 IF (acm_fail_ind=0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
 CALL echorecord(locreply)
END GO
