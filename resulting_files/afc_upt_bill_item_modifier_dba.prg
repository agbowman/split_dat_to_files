CREATE PROGRAM afc_upt_bill_item_modifier:dba
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
 DECLARE script_version = vc WITH private, noconstant("237600.FT.006")
 SET updt_cnt_error = 20
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 bill_item_modifier_qual = i2
    1 bill_item_modifier[10]
      2 bill_item_mod_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
  SET action_begin = 1
  SET action_end = request->bill_item_modifier_qual
  SET reply->bill_item_modifier_qual = request->bill_item_modifier_qual
 ENDIF
 DECLARE codeset = i4
 DECLARE cdf_meaning = c12
 DECLARE cnt = i4
 DECLARE bctype_cd = f8
 DECLARE adtype_cd = f8
 DECLARE cptype_cd = f8
 DECLARE wltype_cd = f8
 DECLARE active_code = f8
 SET codeset = 13019
 SET cdf_meaning = "BILL CODE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,bctype_cd)
 CALL echo(build("the bill code cd is : ",bctype_cd))
 SET codeset = 13019
 SET cdf_meaning = "ADD ON"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,adtype_cd)
 CALL echo(build("the add on cd is : ",adtype_cd))
 SET codeset = 13019
 SET cdf_meaning = "CHARGE POINT"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,cptype_cd)
 CALL echo(build("the charge point cd is : ",cptype_cd))
 SET codeset = 13019
 SET cdf_meaning = "WORKLOAD"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,wltype_cd)
 CALL echo(build("the charge point cd is : ",wltype_cd))
 SET reply->status_data.status = "F"
 SET table_name = "BILL_ITEM_MODIFIER"
 CALL upt_bill_item_modifier(action_begin,action_end)
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
   OF updt_cnt_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDT_CNT"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  SET reqinfo->commit_ind = false
 ENDIF
 GO TO end_program
 SUBROUTINE upt_bill_item_modifier(upt_begin,upt_end)
   SET cur_updt_cnt[value(upt_end)] = 0
   SET count1 = 0
   SELECT INTO "nl:"
    b.*
    FROM bill_item_modifier b,
     (dummyt d  WITH seq = value(upt_end))
    PLAN (d)
     JOIN (b
     WHERE (b.bill_item_mod_id=request->bill_item_modifier[d.seq].bill_item_mod_id))
    WITH forupdate(b)
   ;end select
   IF (curqual != upt_end)
    SET failed = lock_error
    RETURN
   ENDIF
   UPDATE  FROM bill_item_modifier b,
     (dummyt d  WITH seq = value(upt_end))
    SET b.key1_entity_name =
     IF ((request->bill_item_modifier[d.seq].bill_item_type_cd=adtype_cd)) "BILL_ITEM"
     ELSE "CODE_VALUE"
     ENDIF
     , b.key2_entity_name =
     IF ((request->bill_item_modifier[d.seq].key2_id=bctype_cd)) " "
     ELSE "CODE_VALUE"
     ENDIF
     , b.key3_entity_name =
     IF ((request->bill_item_modifier[d.seq].bill_item_type_cd=wltype_cd)) "WORKLOAD_CODE"
     ELSE ""
     ENDIF
     ,
     b.key4_entity_name =
     IF ((request->bill_item_modifier[d.seq].key4_id=cptype_cd)) "CODE_VALUE"
     ELSE " "
     ENDIF
     , b.bill_item_id = nullcheck(b.bill_item_id,request->bill_item_modifier[d.seq].bill_item_id,
      IF ((request->bill_item_modifier[d.seq].bill_item_id=0)) 0
      ELSE 1
      ENDIF
      ), b.bill_item_type_cd = nullcheck(b.bill_item_type_cd,request->bill_item_modifier[d.seq].
      bill_item_type_cd,
      IF ((request->bill_item_modifier[d.seq].bill_item_type_cd=0)) 0
      ELSE 1
      ENDIF
      ),
     b.key1_id = nullcheck(b.key1_id,request->bill_item_modifier[d.seq].key1_id,
      IF ((request->bill_item_modifier[d.seq].key1_id=0)) 0
      ELSE 1
      ENDIF
      ), b.key2_id = nullcheck(b.key2_id,request->bill_item_modifier[d.seq].key2_id,
      IF ((request->bill_item_modifier[d.seq].key2_id=0)) 0
      ELSE 1
      ENDIF
      ), b.key3_id = request->bill_item_modifier[d.seq].key3_id,
     b.key4_id = nullcheck(b.key4_id,request->bill_item_modifier[d.seq].key4_id,
      IF ((request->bill_item_modifier[d.seq].key4_id=0)) 0
      ELSE 1
      ENDIF
      ), b.key5_id = nullcheck(b.key5_id,request->bill_item_modifier[d.seq].key5_id,
      IF ((request->bill_item_modifier[d.seq].key5_id=0)) 0
      ELSE 1
      ENDIF
      ), b.key6 = nullcheck(b.key6,request->bill_item_modifier[d.seq].key6,
      IF ((request->bill_item_modifier[d.seq].key6="")) 0
      ELSE 1
      ENDIF
      ),
     b.key7 = nullcheck(b.key7,request->bill_item_modifier[d.seq].key7,
      IF ((request->bill_item_modifier[d.seq].key7="")) 0
      ELSE 1
      ENDIF
      ), b.key8 = nullcheck(b.key8,request->bill_item_modifier[d.seq].key8,
      IF ((request->bill_item_modifier[d.seq].key8="")) 0
      ELSE 1
      ENDIF
      ), b.key9 = nullcheck(b.key9,request->bill_item_modifier[d.seq].key9,
      IF ((request->bill_item_modifier[d.seq].key9="")) 0
      ELSE 1
      ENDIF
      ),
     b.key10 = nullcheck(b.key10,request->bill_item_modifier[d.seq].key10,
      IF ((request->bill_item_modifier[d.seq].key10="")) 0
      ELSE 1
      ENDIF
      ), b.key11 = nullcheck(b.key11,request->bill_item_modifier[d.seq].key11,
      IF ((request->bill_item_modifier[d.seq].key11="")) 0
      ELSE 1
      ENDIF
      ), b.key12 = nullcheck(b.key12,request->bill_item_modifier[d.seq].key12,
      IF ((request->bill_item_modifier[d.seq].key12="")) 0
      ELSE 1
      ENDIF
      ),
     b.key13 = nullcheck(b.key13,request->bill_item_modifier[d.seq].key13,
      IF ((request->bill_item_modifier[d.seq].key13="")) 0
      ELSE 1
      ENDIF
      ), b.key14 = nullcheck(b.key14,request->bill_item_modifier[d.seq].key14,
      IF ((request->bill_item_modifier[d.seq].key14="")) 0
      ELSE 1
      ENDIF
      ), b.key15 = nullcheck(b.key15,request->bill_item_modifier[d.seq].key15,
      IF ((request->bill_item_modifier[d.seq].key15="")) 0
      ELSE 1
      ENDIF
      ),
     b.key11_id = request->bill_item_modifier[d.seq].key11_id, b.key12_id = request->
     bill_item_modifier[d.seq].key12_id, b.key13_id = request->bill_item_modifier[d.seq].key13_id,
     b.key14_id = request->bill_item_modifier[d.seq].key14_id, b.key15_id = request->
     bill_item_modifier[d.seq].key15_id, b.bim1_int = request->bill_item_modifier[d.seq].bim1_int,
     b.bim2_int = request->bill_item_modifier[d.seq].bim2_int, b.bim_ind = request->
     bill_item_modifier[d.seq].bim_ind, b.bim1_ind = request->bill_item_modifier[d.seq].bim1_ind,
     b.bim1_nbr = request->bill_item_modifier[d.seq].bim1_nbr, b.beg_effective_dt_tm = nullcheck(b
      .beg_effective_dt_tm,cnvtdatetime(request->bill_item_modifier[d.seq].beg_effective_dt_tm),
      IF ((request->bill_item_modifier[d.seq].beg_effective_dt_tm=0)) 0
      ELSE 1
      ENDIF
      ), b.end_effective_dt_tm = nullcheck(b.end_effective_dt_tm,cnvtdatetime(request->
       bill_item_modifier[d.seq].end_effective_dt_tm),
      IF ((request->bill_item_modifier[d.seq].end_effective_dt_tm=0)) 0
      ELSE 1
      ENDIF
      ),
     b.active_status_cd = nullcheck(b.active_status_cd,request->bill_item_modifier[d.seq].
      active_status_cd,
      IF ((request->bill_item_modifier[d.seq].active_status_cd=0)) 0
      ELSE 1
      ENDIF
      ), b.active_status_prsnl_id = nullcheck(b.active_status_prsnl_id,request->bill_item_modifier[d
      .seq].active_status_prsnl_id,
      IF ((request->bill_item_modifier[d.seq].active_status_prsnl_id=0)) 0
      ELSE 1
      ENDIF
      ), b.active_status_dt_tm = nullcheck(b.active_status_dt_tm,cnvtdatetime(request->
       bill_item_modifier[d.seq].active_status_dt_tm),
      IF ((request->bill_item_modifier[d.seq].active_status_dt_tm=0)) 0
      ELSE 1
      ENDIF
      ),
     b.active_ind =
     IF ((request->bill_item_modifier[d.seq].active_ind_ind=1)) request->bill_item_modifier[d.seq].
      active_ind
     ELSE b.active_ind
     ENDIF
     , b.updt_cnt = (b.updt_cnt+ 1), b.updt_dt_tm = cnvtdatetime(curdate,curtime),
     b.updt_id = reqinfo->updt_id, b.updt_applctx = reqinfo->updt_applctx, b.updt_task = reqinfo->
     updt_task
    PLAN (d)
     JOIN (b
     WHERE (b.bill_item_mod_id=request->bill_item_modifier[d.seq].bill_item_mod_id))
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL echo("curqual")
    SET failed = update_error
    RETURN
   ELSE
    CALL echo("for loop")
    FOR (x = upt_begin TO upt_end)
      SET reply->bill_item_modifier[x].bill_item_mod_id = request->bill_item_modifier[x].
      bill_item_mod_id
    ENDFOR
   ENDIF
 END ;Subroutine
#end_program
END GO
