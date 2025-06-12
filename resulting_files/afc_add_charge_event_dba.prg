CREATE PROGRAM afc_add_charge_event:dba
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
    1 charge_event[*]
      2 charge_event_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
  CALL echo("before action begin")
 ENDIF
 SET action_begin = 1
 SET action_end = size(request->charge_event,5)
 SET reply->status_data.status = "F"
 SET table_name = "CHARGE_EVENT"
 CALL add_charge_event(action_begin,action_end)
 IF (failed != false)
  GO TO check_error
 ENDIF
#check_error
 IF (failed=false)
  IF (size(reply->charge_event,5) > 0)
   SET reply->status_data.status = "S"
   SET reqinfo->commit_ind = true
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ELSE
  CALL echo("  Error AFC_ADD_CHARGE_EVENT")
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
 SUBROUTINE add_charge_event(add_begin,add_end)
   FOR (x = add_begin TO add_end)
     SET active_code = 0.0
     IF ((request->charge_event[x].active_status_cd=0))
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
     INSERT  FROM charge_event c
      SET c.charge_event_id = new_nbr, c.ext_m_event_id =
       IF ((request->charge_event[x].ext_master_event_id=0)) 0
       ELSE request->charge_event[x].ext_master_event_id
       ENDIF
       , c.ext_m_event_cont_cd =
       IF ((request->charge_event[x].ext_master_event_cont_cd=0)) 0
       ELSE request->charge_event[x].ext_master_event_cont_cd
       ENDIF
       ,
       c.ext_m_reference_id =
       IF ((request->charge_event[x].ext_master_reference_id=0)) 0
       ELSE request->charge_event[x].ext_master_reference_id
       ENDIF
       , c.ext_m_reference_cont_cd =
       IF ((request->charge_event[x].ext_master_reference_cont_cd=0)) 0
       ELSE request->charge_event[x].ext_master_reference_cont_cd
       ENDIF
       , c.ext_p_event_id =
       IF ((request->charge_event[x].ext_parent_event_id=0)) 0
       ELSE request->charge_event[x].ext_parent_event_id
       ENDIF
       ,
       c.ext_p_event_cont_cd =
       IF ((request->charge_event[x].ext_parent_event_cont_cd=0)) 0
       ELSE request->charge_event[x].ext_parent_event_cont_cd
       ENDIF
       , c.ext_p_reference_id =
       IF ((request->charge_event[x].ext_parent_reference_id=0)) 0
       ELSE request->charge_event[x].ext_parent_reference_id
       ENDIF
       , c.ext_p_reference_cont_cd =
       IF ((request->charge_event[x].ext_parent_reference_cont_cd=0)) 0
       ELSE request->charge_event[x].ext_parent_reference_cont_cd
       ENDIF
       ,
       c.ext_i_event_id =
       IF ((request->charge_event[x].ext_item_event_id=0)) 0
       ELSE request->charge_event[x].ext_item_event_id
       ENDIF
       , c.ext_i_event_cont_cd =
       IF ((request->charge_event[x].ext_item_event_cont_cd=0)) 0
       ELSE request->charge_event[x].ext_item_event_cont_cd
       ENDIF
       , c.ext_i_reference_id =
       IF ((request->charge_event[x].ext_item_reference_id=0)) 0
       ELSE request->charge_event[x].ext_item_reference_id
       ENDIF
       ,
       c.ext_i_reference_cont_cd =
       IF ((request->charge_event[x].ext_item_reference_cont_cd=0)) 0
       ELSE request->charge_event[x].ext_item_reference_cont_cd
       ENDIF
       , c.order_id =
       IF ((request->charge_event[x].order_id=0)) 0
       ELSE request->charge_event[x].order_id
       ENDIF
       , c.person_id =
       IF ((request->charge_event[x].person_id=0)) 0
       ELSE request->charge_event[x].person_id
       ENDIF
       ,
       c.encntr_id =
       IF ((request->charge_event[x].encntr_id=0)) 0
       ELSE request->charge_event[x].encntr_id
       ENDIF
       , c.accession =
       IF ((request->charge_event[x].accession="")) ""
       ELSE request->charge_event[x].accession
       ENDIF
       , c.report_priority_cd =
       IF ((request->charge_event[x].report_priority_cd=0)) 0
       ELSE request->charge_event[x].report_priority_cd
       ENDIF
       ,
       c.collection_priority_cd =
       IF ((request->charge_event[x].collection_priority_cd=0)) 0
       ELSE request->charge_event[x].collection_priority_cd
       ENDIF
       , c.reference_nbr =
       IF ((request->charge_event[x].reference_nbr="")) ""
       ELSE request->charge_event[x].reference_nbr
       ENDIF
       , c.research_account_id =
       IF ((request->charge_event[x].research_acct_id=0)) 0
       ELSE request->charge_event[x].research_acct_id
       ENDIF
       ,
       c.abn_status_cd =
       IF ((request->charge_event[x].abn_status_cd=0)) 0
       ELSE request->charge_event[x].abn_status_cd
       ENDIF
       , c.perf_loc_cd =
       IF ((request->charge_event[x].perf_loc_cd=0)) 0
       ELSE request->charge_event[x].perf_loc_cd
       ENDIF
       , c.health_plan_id =
       IF ((request->charge_event[x].health_plan_id=0)) 0
       ELSE request->charge_event[x].health_plan_id
       ENDIF
       ,
       c.cancelled_ind =
       IF ((request->charge_event[x].cancelled_ind=0)) 0
       ELSE request->charge_event[x].cancelled_ind
       ENDIF
       , c.epsdt_ind =
       IF ((request->charge_event[x].epsdt_ind=0)) 0
       ELSE request->charge_event[x].epsdt_ind
       ENDIF
       , c.active_ind = 1,
       c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_id = reqinfo->updt_id,
       c.updt_applctx = reqinfo->updt_applctx, c.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (curqual=0)
      CALL echo("  AFC_ADD_CHARGE_EVENT Insert Error")
      SET failed = insert_error
      RETURN
     ELSE
      SET stat = alterlist(reply->charge_event,x)
      SET reply->charge_event[x].charge_event_id = new_nbr
      CALL echo("  AFC_ADD_CHARGE_EVENT  Insert OK  id = ",0)
      CALL echo(reply->charge_event[x].charge_event_id)
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
