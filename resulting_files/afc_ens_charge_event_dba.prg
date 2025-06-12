CREATE PROGRAM afc_ens_charge_event:dba
 CALL echo("*****PM_HEADER_CCL.inc - 668615****")
 IF ((validate(gen_nbr_error,- (9))=- (9)))
  DECLARE gen_nbr_error = i2 WITH constant(3)
 ENDIF
 IF ((validate(insert_error,- (9))=- (9)))
  DECLARE insert_error = i2 WITH constant(4)
 ENDIF
 IF ((validate(update_error,- (9))=- (9)))
  DECLARE update_error = i2 WITH constant(5)
 ENDIF
 IF ((validate(replace_error,- (9))=- (9)))
  DECLARE replace_error = i2 WITH constant(6)
 ENDIF
 IF ((validate(delete_error,- (9))=- (9)))
  DECLARE delete_error = i2 WITH constant(7)
 ENDIF
 IF ((validate(undelete_error,- (9))=- (9)))
  DECLARE undelete_error = i2 WITH constant(8)
 ENDIF
 IF ((validate(remove_error,- (9))=- (9)))
  DECLARE remove_error = i2 WITH constant(9)
 ENDIF
 IF ((validate(attribute_error,- (9))=- (9)))
  DECLARE attribute_error = i2 WITH constant(10)
 ENDIF
 IF ((validate(lock_error,- (9))=- (9)))
  DECLARE lock_error = i2 WITH constant(11)
 ENDIF
 IF ((validate(none_found,- (9))=- (9)))
  DECLARE none_found = i2 WITH constant(12)
 ENDIF
 IF ((validate(select_error,- (9))=- (9)))
  DECLARE select_error = i2 WITH constant(13)
 ENDIF
 IF ((validate(add_history_error,- (9))=- (9)))
  DECLARE add_history_error = i2 WITH constant(14)
 ENDIF
 IF ((validate(transaction_error,- (9))=- (9)))
  DECLARE transaction_error = i2 WITH constant(15)
 ENDIF
 IF ((validate(none_found_ft,- (9))=- (9)))
  DECLARE none_found_ft = i2 WITH constant(16)
 ENDIF
 IF ((validate(failed,- (9))=- (9)))
  DECLARE failed = i2 WITH noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH noconstant("")
  SET table_name = fillstring(50," ")
 ENDIF
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 charge_event_qual = i2
    1 charge_event[10]
      2 charge_event_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[2]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
  SET action_begin = 1
  SET action_end = request->charge_event_qual
  SET reply->charge_event_qual = request->charge_event_qual
 ENDIF
 CALL echo("  AFC_ENS_CHARGE_EVENT: START")
 SET hafc_ens_charge_event = 0
 SET istatus = 0
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET reply->status_data.status = "F"
 SET failed = false
 SET table_name = "CHARGE_EVENT"
 CASE (request->action_type)
  OF "ADD":
   CALL echo("  AFC_ENS_CHARGE_EVENT: ADD HERE")
   EXECUTE afc_add_charge_event
   IF (failed != false)
    CALL echo("  AFC_ENS_CHARGE_EVENT: ADD Failed")
    GO TO check_error
   ENDIF
  OF "UPT":
   CALL echo("  AFC_ENS_CHARGE_EVENT: UPDATE HERE")
   EXECUTE afc_upt_charge_event
   IF (failed != false)
    CALL echo("  AFC_ENS_CHARGE_EVENT: UPT Failed")
    GO TO check_error
   ENDIF
  OF "DEL":
   CALL echo("  AFC_ENS_CHARGE_EVENT: DELETE HERE")
   EXECUTE afc_del_charge_event
   IF (failed != false)
    CALL echo("  AFC_ENS_CHARGE_EVENT: DEL Failed")
    GO TO check_error
   ENDIF
  OF "RPL":
   CALL echo("  AFC_ENS_CHARGE_EVENT: REPLACE HERE")
   EXECUTE afc_rpl_charge_event
   IF (failed != false)
    CALL echo("  AFC_ENS_CHARGE_EVENT: RPL Failed")
    GO TO check_error
   ENDIF
  OF "UND":
   CALL echo("  AFC_ENS_CHARGE_EVENT: UNDELETE HERE")
   EXECUTE afc_und_charge_event
   IF (failed != false)
    CALL echo("  AFC_ENS_CHARGE_EVENT: UND Failed")
    GO TO check_error
   ENDIF
  ELSE
   CALL echo("  AFC_ENS_CHARGE_EVENT: ELSE HERE")
   SET failed = true
   GO TO check_error
 ENDCASE
#check_error
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  CASE (failed)
   OF gen_nbr_error:
    SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR"
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   OF replace_error:
    SET reply->status_data.subeventstatus[1].operationname = "REPLACE"
   OF delete_error:
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
   OF undelete_error:
    SET reply->status_data.subeventstatus[1].operationname = "UNDELETE"
   OF remove_error:
    SET reply->status_data.subeventstatus[1].operationname = "REMOVE"
   OF attribute_error:
    SET reply->status_data.subeventstatus[1].operationname = "ATTRIBUTE"
   OF lock_error:
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  SET reqinfo->commit_ind = false
  SET reply->status_data.subeventstatus[2].targetobjectname = "CCL_ERROR"
  SET ierrcode = error(serrmsg,0)
  SET reply->status_data.subeventstatus[2].targetobjectvalue = serrmsg
  SET reply->status_data.subeventstatus[2].operationname = "RECEIVE"
  SET reply->status_data.subeventstatus[2].operationstatus = "S"
 ENDIF
#end_program
END GO
