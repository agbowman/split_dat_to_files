CREATE PROGRAM dm2_arc_chk_rest_person:dba
 IF ((validate(dcpra_request->person_id,- (1))=- (1)))
  RECORD dcpra_request(
    1 person_id = f8
  )
 ENDIF
 IF ((validate(dcpra_reply->archive_ind,- (1))=- (1)))
  RECORD dcpra_reply(
    1 archive_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
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
 IF ((validate(reply->archive_ind,- (1))=- (1)))
  FREE RECORD reply
  RECORD reply(
    1 archive_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SUBROUTINE dm2_init_reply(didr_dummyt)
  SET reply->archive_ind = 0
  SET reply->status_data.status = "S"
 END ;Subroutine
 CALL dm2_init_reply(1)
 SET dcpra_request->person_id = request->person_id
 CALL echo("executing dm2_arc_check_person")
 EXECUTE dm2_arc_check_person  WITH replace("REQUEST","DCPRA_REQUEST"), replace("REPLY","DCPRA_REPLY"
  )
 IF ((dcpra_reply->status_data.status != "S"))
  CALL echo("ERROR: returned from dm2_arc_check_person")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.targetobjectvalue = dcpra_reply->status_data.subeventstatus.
  targetobjectvalue
  GO TO exit_program
 ENDIF
 SET reply->archive_ind = dcpra_reply->archive_ind
 IF ((dcpra_reply->archive_ind=1))
  SET drp_request->person_id = request->person_id
  SET drp_request->wait_ind = request->wait_ind
  CALL echo("executing dm2_arc_rest_person")
  EXECUTE dm2_arc_rest_person  WITH replace("REQUEST","DRP_REQUEST"), replace("REPLY","DRP_REPLY")
  IF ((drp_reply->status_data.status != "S"))
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus.targetobjectvalue = drp_reply->status_data.subeventstatus.
   targetobjectvalue
   GO TO exit_program
  ENDIF
 ENDIF
#exit_program
 FREE RECORD dcpra_reply
 FREE RECORD dcpra_request
 FREE RECORD drp_request
 FREE RECORD drp_reply
END GO
