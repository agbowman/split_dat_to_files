CREATE PROGRAM afc_add_price_sched_item:dba
 DECLARE codeset = i4
 DECLARE cdf_meaning = c12
 DECLARE cnt = i4
 DECLARE active_code = f8
 IF ((validate(action_begin,- (1))=- (1)))
  DECLARE action_begin = i4
  DECLARE action_end = i4
 ENDIF
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
 CALL echo("add_price_sched_item")
 CALL echorecord(request)
 IF (validate(reply->status_data.status,"Z")="Z")
  FREE SET reply
  RECORD reply(
    1 price_sched_items_qual = i2
    1 price_sched_items[*]
      2 price_sched_id = f8
      2 price_sched_items_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
  SET action_begin = 1
  SET action_end = request->price_sched_items_qual
  SET reply->price_sched_items_qual = request->price_sched_items_qual
  SET stat = alterlist(reply->price_sched_items,action_end)
 ENDIF
 SET reply->status_data.status = "F"
 CALL echo("executing afc_add_price_sched_item...")
 SET table_name = "PRICE_SCHED_ITEMS"
 CALL add_price_sched_items(action_begin,action_end)
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
 SUBROUTINE add_price_sched_items(add_begin,add_end)
   FOR (x = add_begin TO add_end)
     CALL echo("x:")
     CALL echo(x)
     IF ((request->price_sched_items[x].action_type="ADD"))
      IF ((request->price_sched_items[x].active_status_cd=0))
       SET codeset = 48
       SET cdf_meaning = "ACTIVE"
       SET cnt = 1
       SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,active_code)
       CALL echo(build("the active code is : ",active_code))
      ENDIF
      SET new_nbr = 0.0
      SELECT INTO "nl:"
       y = seq(price_sched_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        new_nbr = cnvtreal(y)
       WITH format, counter
      ;end select
      IF (curqual=0)
       SET failed = gen_nbr_error
       RETURN
      ELSE
       SET request->price_sched_items[x].price_sched_items_id = new_nbr
      ENDIF
      CALL echo("price_sched_items_id")
      CALL echo(new_nbr)
      INSERT  FROM price_sched_items p
       SET p.price_sched_id = request->price_sched_items[x].price_sched_id, p.bill_item_id =
        IF ((request->price_sched_items[x].bill_item_id=0)) 0
        ELSE request->price_sched_items[x].bill_item_id
        ENDIF
        , p.price_sched_items_id = new_nbr,
        p.price =
        IF ((request->price_sched_items[x].price=0)) 0
        ELSE request->price_sched_items[x].price
        ENDIF
        , p.allowable =
        IF ((request->price_sched_items[x].allowable=0)) 0
        ELSE request->price_sched_items[x].allowable
        ENDIF
        , p.percent_revenue =
        IF ((request->price_sched_items[x].percent_revenue=0)) null
        ELSE request->price_sched_items[x].percent_revenue
        ENDIF
        ,
        p.charge_level_cd =
        IF ((request->price_sched_items[x].charge_level_cd=0)) 0
        ELSE request->price_sched_items[x].charge_level_cd
        ENDIF
        , p.interval_template_cd =
        IF ((request->price_sched_items[x].interval_template_cd=0)) 0
        ELSE request->price_sched_items[x].interval_template_cd
        ENDIF
        , p.detail_charge_ind =
        IF ((request->price_sched_items[x].detail_charge_ind_ind=false)) null
        ELSE request->price_sched_items[x].detail_charge_ind
        ENDIF
        ,
        p.stats_only_ind =
        IF ((request->price_sched_items[x].stats_only_ind_ind=false)) null
        ELSE request->price_sched_items[x].stats_only_ind
        ENDIF
        , p.tax =
        IF ((request->price_sched_items[x].tax=0)) 0
        ELSE request->price_sched_items[x].tax
        ENDIF
        , p.exclusive_ind =
        IF ((request->price_sched_items[x].exclusive_ind_ind=false)) 0
        ELSE request->price_sched_items[x].exclusive_ind
        ENDIF
        ,
        p.cost_adj_amt =
        IF ((request->price_sched_items[x].cost_adj_amt=false)) 0
        ELSE request->price_sched_items[x].cost_adj_amt
        ENDIF
        , p.billing_discount_priority_seq =
        IF ((request->price_sched_items[x].billing_discount_priority=1)) 1
        ELSE request->price_sched_items[x].billing_discount_priority
        ENDIF
        , p.beg_effective_dt_tm =
        IF ((request->price_sched_items[x].beg_effective_dt_tm <= 0)) cnvtdatetime(sysdate)
        ELSE cnvtdatetime(request->price_sched_items[x].beg_effective_dt_tm)
        ENDIF
        ,
        p.end_effective_dt_tm =
        IF ((request->price_sched_items[x].end_effective_dt_tm <= 0)) cnvtdatetime(
          "31-DEC-2100 23:59:59")
        ELSE cnvtdatetime(request->price_sched_items[x].end_effective_dt_tm)
        ENDIF
        , p.active_ind =
        IF ((request->price_sched_items[x].active_ind_ind=false)) true
        ELSE request->price_sched_items[x].active_ind
        ENDIF
        , p.active_status_cd =
        IF ((request->price_sched_items[x].active_status_cd=0)) active_code
        ELSE request->price_sched_items[x].active_status_cd
        ENDIF
        ,
        p.active_status_prsnl_id =
        IF ((request->price_sched_items[x].active_status_prsnl_id=0)) reqinfo->updt_id
        ELSE request->price_sched_items[x].active_status_prsnl_id
        ENDIF
        , p.active_status_dt_tm =
        IF ((request->price_sched_items[x].active_status_dt_tm <= 0)) cnvtdatetime(sysdate)
        ELSE cnvtdatetime(request->price_sched_items[x].active_status_dt_tm)
        ENDIF
        , p.capitation_ind = request->price_sched_items[x].capitation_ind,
        p.referral_req_ind = request->price_sched_items[x].referral_req_ind, p.updt_cnt = 0, p
        .updt_dt_tm = cnvtdatetime(sysdate),
        p.updt_id = reqinfo->updt_id, p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->
        updt_task,
        p.units_ind =
        IF ((request->price_sched_items[x].units_ind_ind=false)) null
        ELSE request->price_sched_items[x].units_ind
        ENDIF
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET failed = insert_error
       RETURN
      ELSE
       SET stat = alter2(reply->price_sched_items,x)
       SET reply->price_sched_items[x].price_sched_items_id = request->price_sched_items[x].
       price_sched_items_id
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
