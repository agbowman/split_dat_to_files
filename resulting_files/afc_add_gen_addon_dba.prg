CREATE PROGRAM afc_add_gen_addon:dba
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
   1 bill_item_mod_qual = i2
   1 bill_item[*]
     2 bill_item_mod_id = f8
     2 delete_ind = i2
     2 bill_item_qual = i2
     2 bill_item_id = f8
     2 ext_owner_cd = f8
     2 ext_owner_disp = c40
     2 ext_owner_desc = c60
     2 ext_owner_mean = c12
     2 ext_parent_reference_id = f8
     2 ext_parent_contributor_cd = f8
     2 ext_child_reference_id = f8
     2 ext_child_contributor_cd = f8
     2 ext_description = vc
     2 ext_short_desc = vc
     2 parent_qual_cd = f8
     2 charge_point_cd = f8
     2 physician_qual_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
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
 SET global = "AFC ADD GEN"
 SET specific = "AFC ADD SPEC"
 SET code_set_106 = 106
 SET generaladd = "ADD ON"
 SET afc_item = "INTERNAL"
 SET code_set_13019 = 13019
 SET afc_item_value = 0.0
 SET specificvalue = 0.0
 SET globalvalue = 0.0
 SET defvalue = 0.0
 SET generalvalue = 0.0
 SET oldbillitemid = 0.0
 SET newbillitemid = 0.0
 SET active_code = 0.0
 SET qualcnt = 0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=code_set_106
   AND cv.cdf_meaning IN (global, specific, "AFC ADD DEF")
  DETAIL
   IF (cv.cdf_meaning=global)
    globalvalue = cv.code_value
   ELSEIF (cv.cdf_meaning=specific)
    specificvalue = cv.code_value
   ELSEIF (cv.cdf_meaning="AFC ADD DEF")
    defvalue = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=code_set_13019
   AND cv.cdf_meaning=generaladd
  DETAIL
   generalvalue = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=13016
   AND cv.cdf_meaning=afc_item
  DETAIL
   afc_item_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=48
   AND c.cdf_meaning="ACTIVE"
  DETAIL
   active_code = c.code_value
  WITH nocounter
 ;end select
 FOR (x = action_begin TO action_end)
  CASE (request->bill_item[x].type_of_add)
   OF "S":
    CALL echo("Inside of case s")
    SET new_nbr = 0.0
    SELECT INTO "nl:"
     y = seq(bill_item_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      new_nbr = cnvtreal(y)
     WITH format, counter
    ;end select
    SET newbillitemid = new_nbr
    INSERT  FROM bill_item b
     SET b.bill_item_id = new_nbr, b.ext_description = request->bill_item[x].ext_description, b
      .ext_owner_cd = specificvalue,
      b.ext_parent_reference_id = new_nbr, b.ext_parent_contributor_cd = afc_item_value, b
      .ext_child_reference_id = 0,
      b.ext_child_contributor_cd = 0, b.parent_qual_cd = 1, b.active_ind = 1,
      b.active_status_dt_tm = cnvtdatetime(sysdate), b.beg_effective_dt_tm = cnvtdatetime(sysdate), b
      .updt_cnt = 0,
      b.updt_dt_tm = cnvtdatetime(sysdate), b.active_status_cd = active_code, b.updt_id = reqinfo->
      updt_id,
      b.updt_applctx = reqinfo->updt_applctx, b.updt_task = reqinfo->updt_task, b
      .ext_parent_entity_name = "BILL_ITEM"
     WITH nocounter
    ;end insert
    IF (curqual > 0)
     SET qualcnt += 1
     SET stat = alterlist(reply->bill_item,qualcnt)
     SET reply->bill_item[qualcnt].bill_item_qual = 1
     SET reply->bill_item[qualcnt].bill_item_id = new_nbr
     SET reqinfo->commit_ind = true
     SELECT
      b.*
      FROM bill_item b
      WHERE b.bill_item_id=new_nbr
      DETAIL
       reply->bill_item[qualcnt].ext_owner_cd = b.ext_owner_cd, reply->bill_item[qualcnt].
       ext_parent_reference_id = b.ext_parent_reference_id, reply->bill_item[qualcnt].
       ext_parent_contributor_cd = b.ext_parent_contributor_cd,
       reply->bill_item[qualcnt].ext_child_reference_id = b.ext_child_reference_id, reply->bill_item[
       qualcnt].ext_child_contributor_cd = b.ext_child_contributor_cd, reply->bill_item[qualcnt].
       ext_description = b.ext_description,
       reply->bill_item[qualcnt].ext_short_desc = b.ext_short_desc, reply->bill_item[qualcnt].
       parent_qual_cd = b.parent_qual_cd, reply->bill_item[qualcnt].charge_point_cd = b
       .charge_point_cd,
       reply->bill_item[qualcnt].beg_effective_dt_tm = b.beg_effective_dt_tm, reply->bill_item[
       qualcnt].end_effective_dt_tm = b.end_effective_dt_tm
      WITH nocounter
     ;end select
    ENDIF
   OF "G":
    SET newbillitemid = request->bill_item[x].key1_bill_item_id
   OF "O":
    SET newbillitemid = request->bill_item[x].key1_bill_item_id
   OF "D":
    UPDATE  FROM bill_item_modifier bim
     SET bim.active_ind = false, bim.active_status_cd = 0, bim.active_status_prsnl_id = reqinfo->
      updt_id,
      bim.active_status_dt_tm = cnvtdatetime(sysdate), bim.updt_dt_tm = cnvtdatetime(sysdate), bim
      .updt_id = reqinfo->updt_id,
      bim.updt_applctx = reqinfo->updt_applctx, bim.updt_task = reqinfo->updt_task
     WHERE (bim.bill_item_mod_id=request->bill_item[x].bill_item_mod_id)
     WITH nocounter
    ;end update
    IF ((request->bill_item[x].bill_item_id != 0))
     UPDATE  FROM price_sched_items p
      SET p.active_ind = false, p.active_status_cd = 0, p.active_status_prsnl_id = reqinfo->updt_id,
       p.active_status_dt_tm = cnvtdatetime(sysdate), p.updt_dt_tm = cnvtdatetime(sysdate), p.updt_id
        = reqinfo->updt_id,
       p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->updt_task
      WHERE (p.bill_item_id=request->bill_item[x].bill_item_id)
      WITH nocounter
     ;end update
     UPDATE  FROM bill_item b
      SET b.active_ind = false, b.active_status_cd = 0, b.active_status_prsnl_id = reqinfo->updt_id,
       b.active_status_dt_tm = cnvtdatetime(sysdate), b.updt_dt_tm = cnvtdatetime(sysdate), b.updt_id
        = reqinfo->updt_id,
       b.updt_applctx = reqinfo->updt_applctx, b.updt_task = reqinfo->updt_task
      WHERE (b.bill_item_id=request->bill_item[x].bill_item_id)
      WITH nocounter
     ;end update
     IF (curqual > 0)
      SET qualcnt += 1
      SET stat = alterlist(reply->bill_item,qualcnt)
      SET reply->bill_item[qualcnt].delete_ind = 1
      SET reply->bill_item[qualcnt].bill_item_id = request->bill_item[x].bill_item_id
      SET reqinfo->commit_ind = true
     ENDIF
    ENDIF
    IF (curqual > 0)
     SET reply->bill_item_mod_qual += 1
     IF ((qualcnt != reply->bill_item_mod_qual))
      SET qualcnt += 1
      SET stat = alterlist(reply->bill_item,qualcnt)
     ENDIF
     SET reply->bill_item[qualcnt].bill_item_mod_id = request->bill_item[x].bill_item_mod_id
     SET reqinfo->commit_ind = true
    ENDIF
   OF "U":
    UPDATE  FROM bill_item_modifier bim
     SET bim.key6 = request->bill_item[x].ext_description, bim.key3_id =
      IF ((request->bill_item[x].quantity != 0)) request->bill_item[x].quantity
      ENDIF
      , bim.key1_entity_name = "BILL_ITEM",
      bim.key2_entity_name = "CODE_VALUE"
     WHERE (bim.bill_item_mod_id=request->bill_item[x].bill_item_mod_id)
     WITH nocounter
    ;end update
    IF (curqual > 0)
     SET reply->bill_item_mod_qual += 1
     IF ((qualcnt != reply->bill_item_mod_qual))
      SET qualcnt += 1
      SET stat = alterlist(reply->bill_item,qualcnt)
     ENDIF
     SET reply->bill_item[qualcnt].bill_item_mod_id = request->bill_item[x].bill_item_mod_id
     SET reqinfo->commit_ind = true
    ENDIF
  ENDCASE
  IF ((request->bill_item[x].type_of_add != "D"))
   SET oldbillitemid = request->bill_item[x].bill_item_id
   SET new_nbr = 0.0
   SELECT INTO "nl:"
    y = seq(bill_item_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     new_nbr = cnvtreal(y)
    WITH format, counter
   ;end select
   INSERT  FROM bill_item_modifier bim
    SET bim.bill_item_mod_id = new_nbr, bim.bill_item_id = oldbillitemid, bim.bill_item_type_cd =
     generalvalue,
     bim.key1_id = newbillitemid, bim.key1_entity_name = "BILL_ITEM", bim.key6 = cnvtstring(request->
      bill_item[x].ext_description),
     bim.key2_id =
     IF ((request->bill_item[x].type_of_add="S")) specificvalue
     ELSEIF ((request->bill_item[x].type_of_add="G")) globalvalue
     ELSE defvalue
     ENDIF
     , bim.key2_entity_name = "CODE_VALUE", bim.key3_id = request->bill_item[x].quantity,
     bim.active_ind = 1, bim.beg_effective_dt_tm = cnvtdatetime(sysdate), bim.updt_cnt = 0,
     bim.updt_dt_tm = cnvtdatetime(sysdate), bim.updt_id = reqinfo->updt_id, bim.updt_applctx =
     reqinfo->updt_applctx,
     bim.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (curqual > 0)
    SET reply->bill_item_mod_qual += 1
    IF ((qualcnt != reply->bill_item_mod_qual))
     SET qualcnt = reply->bill_item_mod_qual
     SET stat = alterlist(reply->bill_item,qualcnt)
    ENDIF
    SET reply->bill_item[qualcnt].bill_item_mod_id = new_nbr
    SET reqinfo->commit_ind = true
   ENDIF
  ENDIF
 ENDFOR
#end_program
END GO
