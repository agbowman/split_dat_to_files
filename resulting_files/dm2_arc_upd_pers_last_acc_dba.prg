CREATE PROGRAM dm2_arc_upd_pers_last_acc:dba
 IF ((validate(dula_request->person_id,- (1))=- (1)))
  FREE RECORD dula_request
  RECORD dula_request(
    1 person_id = f8
  )
 ENDIF
 IF (validate(dula_reply->status_data.status,"X")="X")
  FREE RECORD dula_reply
  RECORD dula_reply(
    1 err_num = i4
    1 err_msg = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET dula_request->person_id = request->person_id
 EXECUTE dm2_arc_upd_pers_last_acc_c  WITH replace("REQUEST","DULA_REQUEST"), replace("REPLY",
  "DULA_REPLY")
END GO
