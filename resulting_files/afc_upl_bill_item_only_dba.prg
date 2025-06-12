CREATE PROGRAM afc_upl_bill_item_only:dba
 SET version = 0
 DECLARE module = vc WITH constant("afc_upl_bill_item_only")
 EXECUTE pft_log module, "Start", 2
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
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
 DECLARE new_nbr = f8
 DECLARE mod_new_nbr = f8
 DECLARE dbegin = i4
 DECLARE dend = i4
 DECLARE count1 = i4
 DECLARE upload_cd = f8
 DECLARE bill_type_cd = f8
 SET stat = uar_get_meaning_by_codeset(13016,"UPLOAD",1,upload_cd)
 SET stat = uar_get_meaning_by_codeset(13019,"BILL CODE",1,bill_type_cd)
 SET reply->status_data.status = "F"
 CALL createbillitem(1,size(requestin->list_0,5))
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
   OF none_found:
    SET reply->status_data.subeventstatus[1].operationname = "NONE_FOUND"
    SET reply->status_data.status = "Z"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  SET reqinfo->commit_ind = false
 ENDIF
 GO TO end_program
 SUBROUTINE createbillitem(dbegin,dend)
   FOR (count1 = dbegin TO dend)
     SET new_nbr = 0.0
     CALL echo("new_nbr before select = ",0)
     CALL echo(new_nbr)
     SELECT INTO "nl:"
      y = seq(bill_item_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       new_nbr = cnvtreal(y)
      WITH format, counter
     ;end select
     IF (curqual=0)
      SET failed = gen_nbr_error
      RETURN
     ENDIF
     INSERT  FROM bill_item b
      SET b.bill_item_id = new_nbr, b.ext_parent_reference_id = new_nbr, b.ext_parent_contributor_cd
        = upload_cd,
       b.ext_child_reference_id = 0, b.ext_child_contributor_cd = 0, b.ext_description = requestin->
       list_0[count1].description,
       b.ext_short_desc = substring(0,50,requestin->list_0[count1].description), b.ext_owner_cd =
       cnvtreal(requestin->list_0[count1].activitytype), b.parent_qual_cd = 1,
       b.charge_point_cd = 0, b.workload_only_ind = 0, b.beg_effective_dt_tm = cnvtdatetime(sysdate),
       b.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"), b.active_ind = 1, b
       .active_status_cd = reqdata->active_status_cd,
       b.active_status_prsnl_id = reqinfo->updt_id, b.active_status_dt_tm = cnvtdatetime(sysdate), b
       .updt_cnt = 0,
       b.updt_dt_tm = cnvtdatetime(sysdate), b.updt_id = reqinfo->updt_id, b.updt_applctx = reqinfo->
       updt_applctx,
       b.updt_task = reqinfo->updt_task, b.ext_parent_entity_name = "", b.ext_child_entity_name = "",
       b.misc_ind = 0, b.stats_only_ind = 0, b.child_seq = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET failed = insert_error
      RETURN
     ENDIF
     SET mod_new_nbr = 0.0
     SELECT INTO "nl:"
      y = seq(bill_item_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       mod_new_nbr = cnvtreal(y)
      WITH format, counter
     ;end select
     IF (curqual=0)
      SET failed = gen_nbr_error
      RETURN
     ENDIF
     INSERT  FROM bill_item_modifier bm
      SET bm.bill_item_mod_id = mod_new_nbr, bm.bill_item_id = new_nbr, bm.bill_item_type_cd =
       bill_type_cd,
       bm.key1_id = cnvtreal(requestin->list_0[count1].cdmsched), bm.key2_id = 1, bm.key3_id = 0,
       bm.key4_id = 0, bm.key5_id = 0, bm.key6 = requestin->list_0[count1].cdm,
       bm.key7 = requestin->list_0[count1].description, bm.key8 = "", bm.bim1_int = 1,
       bm.bim2_int = 0, bm.bim_ind = 0, bm.bim1_ind = 0,
       bm.bim1_nbr = 0, bm.key1_entity_name = "BILL_ITEM", bm.key2_entity_name = "",
       bm.key4_entity_name = "", bm.key5_entity_name = "", bm.beg_effective_dt_tm = cnvtdatetime(
        sysdate),
       bm.end_effective_dt_tm = cnvtdatetime("31-dec-2100 23:59:59"), bm.active_ind = 1, bm
       .active_status_cd = reqdata->active_status_cd,
       bm.active_status_prsnl_id = reqinfo->updt_id, bm.active_status_dt_tm = cnvtdatetime(sysdate),
       bm.updt_cnt = 0,
       bm.updt_dt_tm = cnvtdatetime(sysdate), bm.updt_id = reqinfo->updt_id, bm.updt_applctx =
       reqinfo->updt_applctx,
       bm.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET failed = insert_error
      RETURN
     ENDIF
   ENDFOR
 END ;Subroutine
 EXECUTE pft_log module, "End", 2
#end_program
END GO
