CREATE PROGRAM dm2_arc_rest_person_async:dba
 IF ((validate(drp_request->person_id,- (1))=- (1)))
  RECORD drp_request(
    1 person_id = f8
    1 wait_ind = i2
  )
 ENDIF
 IF (validate(drp_reply->status_data.status,"X")="X")
  RECORD drp_reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET drp_request->wait_ind = 1
 SET drp_request->person_id = request->person_id
 EXECUTE dm2_arc_rest_person  WITH replace("REQUEST","DRP_REQUEST"), replace("REPLY","DRP_REPLY")
 IF ((drp_reply->status_data.status="F"))
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 FREE RECORD drp_request
 FREE RECORD drp_reply
END GO
