CREATE PROGRAM cps_get_ppa:dba
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
 RECORD reply(
   1 ppa_qual = i4
   1 ppa_id = f8
   1 last_dt_tm = dq8
   1 last_tz = i4
   1 swarnmsg = c100
   1 status_data
     2 status = c1
     2 subeventstatus[2]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET swarnmsg = fillstring(100," ")
 SET reply->swarnmsg = fillstring(100," ")
 SET failed = false
 SET max_ppa_id = 0.0
 SELECT INTO "nl:"
  FROM person_prsnl_activity ppa
  PLAN (ppa
   WHERE (ppa.ppa_id=
   (SELECT
    max(ppa2.ppa_id)
    FROM person_prsnl_activity ppa2
    WHERE ((ppa2.prsnl_id+ 0)=request->prsnl_id)
     AND (ppa2.person_id=request->person_id)
     AND (ppa2.ppa_type_cd=request->ppa_type_cd)
     AND ((ppa2.active_ind+ 0)=1))))
  HEAD REPORT
   reply->ppa_id = ppa.ppa_id, reply->last_dt_tm = ppa.ppa_last_dt_tm, reply->last_tz = ppa
   .ppa_last_tz
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->ppa_qual = 0
  SET reply->status_data.status = "Z"
  SET swarnmsg = "No records found."
 ELSE
  IF (curqual < 0)
   SET reply->status_data.status = "F"
   SET failed = select_error
  ELSE
   SET reply->ppa_qual = 1
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 CALL echo(build(" reply->ppa_qual = ",reply->ppa_qual))
 CALL echo(build(" reply->ppa_id = ",reply->ppa_id))
 GO TO error_check
#error_check
 IF (failed=false)
  SET reqinfo->commit_ind = true
 ELSE
  CASE (failed)
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   OF select_error:
    SET reply->status_data.subeventstatus[1].operationname = "GET"
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
 ENDIF
 GO TO end_program
#end_program
 SET mod_version = "003 03/28/06 CA9381"
END GO
