CREATE PROGRAM afc_upt_bill_item_internal:dba
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
    1 bill_item_qual = i2
    1 bill_item[10]
      2 bill_item_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
  SET action_begin = 1
  SET action_end = request->bill_item_qual
  SET reply->bill_item_qual = request->bill_item_qual
 ENDIF
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE adtype_cd = f8
 SET code_set = 13019
 SET cdf_meaning = "ADD ON"
 DECLARE codecnt = i4
 SET codecnt = 1
 SET stat = uar_get_meaning_by_codeset(13019,cdf_meaning,codecnt,adtype_cd)
 SET reply->status_data.status = "F"
 SET table_name = "BILL_ITEM"
 CALL upt_bill_item(action_begin,action_end)
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
 SUBROUTINE upt_bill_item(upt_begin,upt_end)
   FOR (count = upt_begin TO upt_end)
     SET cur_updt_cnt[value(upt_end)] = 0
     SET count1 = 0
     SELECT INTO "nl:"
      b.*
      FROM bill_item b,
       (dummyt d  WITH seq = value(upt_end))
      PLAN (d)
       JOIN (b
       WHERE (b.bill_item_id=request->bill_item[d.seq].bill_item_id))
      HEAD REPORT
       count1 = 0
      DETAIL
       count1 += 1, cur_updt_cnt[count1] = b.updt_cnt
      WITH forupdate(b)
     ;end select
     IF (count1 != upt_end)
      SET failed = lock_error
      RETURN
     ENDIF
     CALL echo("Found Update Records")
     UPDATE  FROM bill_item b,
       (dummyt d  WITH seq = 1)
      SET b.seq = 1, b.ext_parent_reference_id = nullcheck(b.ext_parent_reference_id,request->
        bill_item[count].ext_parent_reference_id,
        IF ((request->bill_item[count].ext_parent_reference_id=0)) 0
        ELSE 1
        ENDIF
        ), b.ext_parent_contributor_cd = nullcheck(b.ext_parent_contributor_cd,request->bill_item[
        count].ext_parent_contributor_cd,
        IF ((request->bill_item[count].ext_parent_contributor_cd=0)) 0
        ELSE 1
        ENDIF
        ),
       b.ext_child_reference_id = nullcheck(b.ext_child_reference_id,request->bill_item[count].
        ext_child_reference_id,
        IF ((request->bill_item[count].ext_child_reference_id=0)) 0
        ELSE 1
        ENDIF
        ), b.ext_child_contributor_cd = nullcheck(b.ext_child_contributor_cd,request->bill_item[count
        ].ext_child_contributor_cd,
        IF ((request->bill_item[count].ext_child_contributor_cd=0)) 0
        ELSE 1
        ENDIF
        ), b.ext_description = nullcheck(b.ext_description,request->bill_item[count].ext_description,
        IF ((request->bill_item[count].ext_description="")) 0
        ELSE 1
        ENDIF
        ),
       b.ext_owner_cd = nullcheck(b.ext_owner_cd,request->bill_item[count].ext_owner_cd,
        IF ((request->bill_item[count].ext_owner_cd=0)) 0
        ELSE 1
        ENDIF
        ), b.parent_qual_cd = nullcheck(b.parent_qual_cd,request->bill_item[count].parent_qual_cd,
        IF ((request->bill_item[count].parent_qual_cd=0)) 0
        ELSE 1
        ENDIF
        ), b.charge_point_cd = nullcheck(b.charge_point_cd,request->bill_item[count].charge_point_cd,
        IF ((request->bill_item[count].charge_point_cd=0)) 0
        ELSE 1
        ENDIF
        ),
       b.physician_qual_cd = nullcheck(b.physician_qual_cd,request->bill_item[count].
        physician_qual_cd,
        IF ((request->bill_item[count].physician_qual_cd=0)) 0
        ELSE 1
        ENDIF
        ), b.calc_type_cd = nullcheck(b.calc_type_cd,request->bill_item[count].calc_type_cd,
        IF ((request->bill_item[count].calc_type_cd=0)) 0
        ELSE 1
        ENDIF
        ), b.beg_effective_dt_tm = nullcheck(b.beg_effective_dt_tm,cnvtdatetime(request->bill_item[
         count].beg_effective_dt_tm),
        IF ((request->bill_item[count].beg_effective_dt_tm=0)) 0
        ELSE 1
        ENDIF
        ),
       b.end_effective_dt_tm = nullcheck(b.end_effective_dt_tm,cnvtdatetime(request->bill_item[count]
         .end_effective_dt_tm),
        IF ((request->bill_item[count].end_effective_dt_tm=0)) 0
        ELSE 1
        ENDIF
        ), b.active_status_cd = nullcheck(b.active_status_cd,request->bill_item[count].
        active_status_cd,
        IF ((request->bill_item[count].active_status_cd=0)) 0
        ELSE 1
        ENDIF
        ), b.active_status_prsnl_id = nullcheck(b.active_status_prsnl_id,request->bill_item[count].
        active_status_prsnl_id,
        IF ((request->bill_item[count].active_status_prsnl_id=0)) 0
        ELSE 1
        ENDIF
        ),
       b.active_status_dt_tm = nullcheck(b.active_status_dt_tm,cnvtdatetime(request->bill_item[count]
         .active_status_dt_tm),
        IF ((request->bill_item[count].active_status_dt_tm=0)) 0
        ELSE 1
        ENDIF
        ), b.updt_cnt = (cur_updt_cnt[d.seq]+ 1), b.updt_dt_tm = cnvtdatetime(curdate,curtime),
       b.updt_id = reqinfo->updt_id, b.updt_applctx = reqinfo->updt_applctx, b.updt_task = reqinfo->
       updt_task,
       b.ext_parent_entity_name = "BILL_ITEM", b.ext_child_entity_name = ""
      PLAN (d)
       JOIN (b
       WHERE (b.bill_item_id=request->bill_item[count].bill_item_id))
      WITH nocounter
     ;end update
     CALL echo(build("CurQual is: ",curqual))
     IF (curqual=0)
      SET failed = update_error
      RETURN
     ELSE
      SET reply->bill_item[count].bill_item_id = request->bill_item[count].bill_item_id
     ENDIF
     IF (curqual=0)
      SET failed = update_error
      RETURN
     ENDIF
     CALL echo("Updated Records")
     CALL echo("Now updating Bill Item Modifier")
     UPDATE  FROM bill_item_modifier bim,
       (dummyt d  WITH seq = 1)
      SET bim.key6 = request->bill_item[count].ext_description, bim.updt_cnt = (bim.updt_cnt+ 1), bim
       .updt_dt_tm = cnvtdatetime(curdate,curtime),
       bim.updt_id = reqinfo->updt_id, bim.updt_applctx = reqinfo->updt_applctx, bim.updt_task =
       reqinfo->updt_task
      PLAN (d)
       JOIN (bim
       WHERE bim.bill_item_type_cd=adtype_cd
        AND (bim.key1_id=request->bill_item[count].bill_item_id))
      WITH nocounter
     ;end update
   ENDFOR
 END ;Subroutine
#end_program
END GO
