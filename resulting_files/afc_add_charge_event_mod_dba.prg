CREATE PROGRAM afc_add_charge_event_mod:dba
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
    1 charge_event_mod_qual = i2
    1 charge_event_mod[10]
      2 charge_event_mod_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
  SET action_begin = 1
  SET action_end = request->charge_event_mod_qual
  SET reply->charge_event_mod_qual = request->charge_event_mod_qual
 ENDIF
 SET reply->status_data.status = "F"
 SET table_name = "CHARGE_EVENT_MOD"
 CALL add_charge_event_mod(action_begin,action_end)
 IF (failed != false)
  GO TO check_error
 ENDIF
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
 ENDIF
 GO TO end_program
 SUBROUTINE add_charge_event_mod(add_begin,add_end)
   FOR (x = add_begin TO add_end)
     SET active_code = 0.0
     IF ((request->charge_event_mod[x].active_status_cd=0))
      SELECT INTO "nl:"
       FROM code_value c
       WHERE c.code_set=48
        AND c.cdf_meaning="ACTIVE"
       DETAIL
        active_code = c.code_value
       WITH nocounter
      ;end select
     ENDIF
     SET new_nbr = 0.0
     SELECT INTO "nl:"
      y = seq(charge_event_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       new_nbr = cnvtreal(y)
      WITH format, counter
     ;end select
     IF (curqual=0)
      SET failed = gen_nbr_error
      RETURN
     ELSE
      IF (validate(reply->charge_event_mod[x].charge_event_mod_id,"Z") != "Z")
       SET request->charge_event_mod[x].charge_event_mod_id = new_nbr
      ENDIF
     ENDIF
     INSERT  FROM charge_event_mod c
      SET c.charge_event_mod_id = new_nbr, c.charge_event_id =
       IF ((request->charge_event_mod[x].charge_event_id=0)) 0
       ELSE request->charge_event_mod[x].charge_event_id
       ENDIF
       , c.charge_event_mod_type_cd =
       IF ((request->charge_event_mod[x].charge_event_mod_type_cd=0)) 0
       ELSE request->charge_event_mod[x].charge_event_mod_type_cd
       ENDIF
       ,
       c.field1 = request->charge_event_mod[x].field1, c.field2 = request->charge_event_mod[x].field2,
       c.field3 = request->charge_event_mod[x].field3,
       c.field4 = request->charge_event_mod[x].field4, c.field5 = request->charge_event_mod[x].field5,
       c.field6 = request->charge_event_mod[x].field6,
       c.field7 = request->charge_event_mod[x].field7, c.field8 = request->charge_event_mod[x].field8,
       c.field9 = request->charge_event_mod[x].field9,
       c.field10 = request->charge_event_mod[x].field10, c.field1_id = request->charge_event_mod[x].
       field1_id, c.field2_id = request->charge_event_mod[x].field2_id,
       c.field3_id = request->charge_event_mod[x].field3_id, c.field4_id = request->charge_event_mod[
       x].field4_id, c.field5_id = request->charge_event_mod[x].field5_id,
       c.beg_effective_dt_tm =
       IF ((request->charge_event_mod[x].beg_effective_dt_tm <= 0)) cnvtdatetime(sysdate)
       ELSE cnvtdatetime(request->charge_event_mod[x].beg_effective_dt_tm)
       ENDIF
       , c.end_effective_dt_tm =
       IF ((request->charge_event_mod[x].end_effective_dt_tm <= 0)) cnvtdatetime(
         "31-dec-2100 00:00:00")
       ELSE cnvtdatetime(request->charge_event_mod[x].end_effective_dt_tm)
       ENDIF
       , c.active_ind =
       IF ((request->charge_event_mod[x].active_ind_ind=false)) true
       ELSE request->charge_event_mod[x].active_ind
       ENDIF
       ,
       c.active_status_cd =
       IF ((request->charge_event_mod[x].active_status_cd=0)) active_code
       ELSE request->charge_event_mod[x].active_status_cd
       ENDIF
       , c.active_status_prsnl_id =
       IF ((request->charge_event_mod[x].active_status_prsnl_id=0)) reqinfo->updt_id
       ELSE request->charge_event_mod[x].active_status_prsnl_id
       ENDIF
       , c.active_status_dt_tm =
       IF ((request->charge_event_mod[x].active_status_dt_tm <= 0)) cnvtdatetime(sysdate)
       ELSE cnvtdatetime(request->charge_event_mod[x].active_status_dt_tm)
       ENDIF
       ,
       c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_id = reqinfo->updt_id,
       c.updt_applctx = reqinfo->updt_applctx, c.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET failed = insert_error
      RETURN
     ELSE
      IF (validate(reply->status_data.status,"Z") != "Z")
       SET reply->charge_event_mod[x].charge_event_mod_id = request->charge_event_mod[x].
       charge_event_mod_id
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
