CREATE PROGRAM afc_upt_charge_desc_master:dba
 DECLARE afc_upt_charge_desc_master = vc WITH constant("CHARGSVC-13775.001")
 IF (validate(false,0)=0
  AND validate(false,1)=1)
  DECLARE false = i2 WITH public, constant(0)
 ENDIF
 IF (validate(true,0)=0
  AND validate(true,1)=1)
  DECLARE true = i2 WITH public, constant(1)
 ENDIF
 IF (validate(gen_nbr_error,0)=0
  AND validate(gen_nbr_error,1)=1)
  DECLARE gen_nbr_error = i2 WITH public, constant(3)
 ENDIF
 IF (validate(insert_error,0)=0
  AND validate(insert_error,1)=1)
  DECLARE insert_error = i2 WITH public, constant(4)
 ENDIF
 IF (validate(update_error,0)=0
  AND validate(update_error,1)=1)
  DECLARE update_error = i2 WITH public, constant(5)
 ENDIF
 IF (validate(replace_error,0)=0
  AND validate(replace_error,1)=1)
  DECLARE replace_error = i2 WITH public, constant(6)
 ENDIF
 IF (validate(delete_error,0)=0
  AND validate(delete_error,1)=1)
  DECLARE delete_error = i2 WITH public, constant(7)
 ENDIF
 IF (validate(undelete_error,0)=0
  AND validate(undelete_error,1)=1)
  DECLARE undelete_error = i2 WITH public, constant(8)
 ENDIF
 IF (validate(remove_error,0)=0
  AND validate(remove_error,1)=1)
  DECLARE remove_error = i2 WITH public, constant(9)
 ENDIF
 IF (validate(attribute_error,0)=0
  AND validate(attribute_error,1)=1)
  DECLARE attribute_error = i2 WITH public, constant(10)
 ENDIF
 IF (validate(lock_error,0)=0
  AND validate(lock_error,1)=1)
  DECLARE lock_error = i2 WITH public, constant(11)
 ENDIF
 IF (validate(none_found,0)=0
  AND validate(none_found,1)=1)
  DECLARE none_found = i2 WITH public, constant(12)
 ENDIF
 IF (validate(select_error,0)=0
  AND validate(select_error,1)=1)
  DECLARE select_error = i2 WITH public, constant(13)
 ENDIF
 IF (validate(update_cnt_error,0)=0
  AND validate(update_cnt_error,1)=1)
  DECLARE update_cnt_error = i2 WITH public, constant(14)
 ENDIF
 IF (validate(not_found,0)=0
  AND validate(not_found,1)=1)
  DECLARE not_found = i2 WITH public, constant(15)
 ENDIF
 IF (validate(inactivate_error,0)=0
  AND validate(inactivate_error,1)=1)
  DECLARE inactivate_error = i2 WITH public, constant(17)
 ENDIF
 IF (validate(activate_error,0)=0
  AND validate(activate_error,1)=1)
  DECLARE activate_error = i2 WITH public, constant(18)
 ENDIF
 IF (validate(uar_error,0)=0
  AND validate(uar_error,1)=1)
  DECLARE uar_error = i2 WITH public, constant(20)
 ENDIF
 IF (validate(pft_failed,0)=0
  AND validate(pft_failed,1)=1)
  DECLARE pft_failed = i2 WITH public, noconstant(false)
 ENDIF
 IF (validate(table_name,"X")="X"
  AND validate(table_name,"Z")="Z")
  DECLARE table_name = vc WITH public, noconstant(" ")
 ENDIF
 IF (validate(call_echo_ind,0)=0
  AND validate(call_echo_ind,1)=1)
  DECLARE call_echo_ind = i2 WITH public, noconstant(false)
 ENDIF
 IF (validate(failed,0)=0
  AND validate(failed,1)=1)
  DECLARE failed = i2 WITH public, noconstant(false)
 ENDIF
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 charge_desc_master[*]
      2 cdm_id = f8
      2 cdm_code = vc
      2 issue = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD mrsstatus
 RECORD mrsstatus(
   1 objarray[*]
     2 status = i4
     2 modify_this_record = i2
 ) WITH protect
 DECLARE modifiedfields = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE table_name = vc WITH protect, constant("CHARGE_DESC_MASTER")
 DECLARE success_status = vc WITH protect, constant("SUCCESS")
 DECLARE pending_status = vc WITH protect, constant("PENDING")
 DECLARE lock_error_status = vc WITH protect, constant("LOCK")
 DECLARE update_error_status = vc WITH protect, constant("UPDATE")
 DECLARE attribute_error_status = vc WITH protect, constant("ATTRIBUTE")
 DECLARE request_size = i4 WITH protect, constant(size(request->charge_desc_master,5))
 SET stat = alterlist(mrsstatus->objarray,request_size)
 SET stat = alterlist(reply->charge_desc_master,request_size)
 SET reply->status_data.status = "F"
 FOR (cnt = 1 TO request_size)
   SET reply->charge_desc_master[cnt].cdm_id = request->charge_desc_master[cnt].cdm_id
   SET reply->charge_desc_master[cnt].cdm_code = request->charge_desc_master[cnt].cdm_code
   SET reply->charge_desc_master[cnt].issue = pending_status
 ENDFOR
 CALL updatechargedescmaster(request_size)
 SUBROUTINE (updatechargedescmaster(prequestsize=i4) =null)
   DECLARE cdmcount = i4 WITH protect, noconstant(0)
   DECLARE updateddttm = dq8 WITH protect, noconstant(cnvtdatetime(sysdate))
   DECLARE blocked = i2 WITH protect, noconstant(false)
   FOR (cdmcount = 1 TO prequestsize)
     IF (validate(request->charge_desc_master[cdmcount].cdm_id,- (0.00001)) <= 0.0)
      SET reply->charge_desc_master[cdmcount].issue = attribute_error_status
      CALL checkerror(attribute_error)
      RETURN
     ENDIF
   ENDFOR
   SELECT INTO "nl:"
    c.*
    FROM charge_desc_master c,
     (dummyt dt  WITH seq = value(prequestsize))
    PLAN (dt)
     JOIN (c
     WHERE (c.charge_desc_master_id=request->charge_desc_master[dt.seq].cdm_id))
    DETAIL
     modifiedfields = 0
     IF (validate(request->charge_desc_master[dt.seq].description,c.description) != char(128)
      AND validate(request->charge_desc_master[dt.seq].description,c.description) != c.description)
      modifiedfields += 1
     ENDIF
     IF ((request->charge_desc_master[dt.seq].updt_cnt != c.updt_cnt)
      AND (request->charge_desc_master[dt.seq].updt_cnt != - (99999)))
      blocked = true
     ELSE
      mrsstatus->objarray[dt.seq].status = 1
      IF (modifiedfields > 0)
       mrsstatus->objarray[dt.seq].modify_this_record = true
      ENDIF
     ENDIF
    WITH forupdate(c)
   ;end select
   FOR (cdmcount = 1 TO size(mrsstatus->objarray,5))
     IF ((mrsstatus->objarray[cdmcount].status != 1))
      SET reply->charge_desc_master[cdmcount].issue = lock_error_status
      CALL checkerror(lock_error)
      RETURN
     ENDIF
   ENDFOR
   UPDATE  FROM charge_desc_master c,
     (dummyt dt  WITH seq = value(prequestsize))
    SET c.description =
     IF (validate(request->charge_desc_master[dt.seq].description,char(128)) != char(128)) validate(
       request->charge_desc_master[dt.seq].description,char(128))
     ELSE c.description
     ENDIF
     , c.updt_cnt = (c.updt_cnt+ 1), c.updt_dt_tm = cnvtdatetime(updateddttm),
     c.updt_id = reqinfo->updt_id, c.updt_applctx = reqinfo->updt_applctx, c.updt_task = reqinfo->
     updt_task
    PLAN (dt
     WHERE (mrsstatus->objarray[dt.seq].modify_this_record=true))
     JOIN (c
     WHERE (c.charge_desc_master_id=request->charge_desc_master[dt.seq].cdm_id))
    WITH nocounter, status(mrsstatus->objarray[dt.seq].status)
   ;end update
   FOR (cdmcount = 1 TO size(mrsstatus->objarray,5))
    IF ((mrsstatus->objarray[cdmcount].status != 1))
     SET reply->charge_desc_master[cdmcount].issue = update_error_status
     CALL checkerror(update_error)
     RETURN
    ENDIF
    SET reply->charge_desc_master[cdmcount].issue = success_status
   ENDFOR
   CALL checkerror(true)
 END ;Subroutine
 SUBROUTINE (checkerror(nfailed=i4) =null)
   IF (nfailed=true)
    SET reply->status_data.status = "S"
    SET reqinfo->commit_ind = true
   ELSE
    CASE (nfailed)
     OF update_error:
      SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
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
 END ;Subroutine
END GO
