CREATE PROGRAM afc_del_interface_file:dba
 CALL echo("going through afc_del_interface_file")
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
    1 interface_file_qual = i2
    1 interface_file[10]
      2 interface_file_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
  SET action_begin = 1
  SET action_end = request->interface_file_qual
  SET reply->interface_file_qual = request->interface_file_qual
 ENDIF
 SET reply->status_data.status = "F"
 SET table_name = "INTERFACE_FILE"
 CALL del_interface_file(action_begin,action_end)
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
 SUBROUTINE del_interface_file(del_begin,del_end)
   FOR (x = del_begin TO del_end)
     DECLARE code_set = i4
     DECLARE cdf_meaning = c12
     DECLARE active_code = f8
     SET code_set = 48
     SET cdf_meaning = "INACTIVE"
     DECLARE activecnt = i4
     SET activecnt = 1
     IF ((request->interface_file[x].active_status_cd=0))
      SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,activecnt,active_code)
      CALL echo("active_code")
      CALL echo(active_code)
     ENDIF
     CALL echo("interface_file_id")
     CALL echo(request->interface_file[x].interface_file_id)
     UPDATE  FROM interface_file i
      SET i.active_ind = false, i.active_status_dt_tm = cnvtdatetime(sysdate), i.updt_cnt = (i
       .updt_cnt+ 1),
       i.updt_dt_tm = cnvtdatetime(sysdate), i.updt_id = reqinfo->updt_id, i.updt_applctx = reqinfo->
       updt_applctx,
       i.updt_task = reqinfo->updt_task, i.cdm_sched_cd = request->interface_file[x].cdm_sched_cd, i
       .cpt_sched_cd = request->interface_file[x].cpt_sched_cd,
       i.mult_bill_code_sched_cd = request->interface_file[x].mult_bill_code_sched_cd, i
       .contributor_system_cd = request->interface_file[x].contributor_system_cd, i.doc_nbr_cd =
       request->interface_file[x].doc_nbr_cd,
       i.explode_ind = request->interface_file[x].explode_ind
      WHERE (i.interface_file_id=request->interface_file[x].interface_file_id)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = update_error
      RETURN
     ELSE
      SET reply->interface_file[x].interface_file_id = request->interface_file[x].interface_file_id
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
