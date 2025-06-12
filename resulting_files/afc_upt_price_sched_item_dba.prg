CREATE PROGRAM afc_upt_price_sched_item:dba
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
 SET updt_cnt_error = 20
 CALL echorecord(request)
 IF (validate(reply->status_data.status,"Z")="Z")
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
 ENDIF
 DECLARE action_begin = i4
 DECLARE action_end = i4
 SET action_begin = 1
 SET action_end = request->price_sched_items_qual
 SET reply->price_sched_items_qual = request->price_sched_items_qual
 SET stat = alterlist(reply->price_sched_items,action_end)
 SET reply->status_data.status = "F"
 SET table_name = "PRICE_SCHED_ITEMS"
 CALL upt_price_sched_items(action_begin,action_end)
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
 SUBROUTINE upt_price_sched_items(upt_begin,upt_end)
   SET cur_updt_cnt[value(upt_end)] = 0
   SET count1 = 0
   SELECT INTO "nl:"
    p.*
    FROM price_sched_items p,
     (dummyt d  WITH seq = value(upt_end))
    PLAN (d)
     JOIN (p
     WHERE (p.price_sched_items_id=request->price_sched_items[d.seq].price_sched_items_id))
    HEAD REPORT
     count1 = 0
    DETAIL
     count1 += 1, cur_updt_cnt[count1] = p.updt_cnt
    WITH nocounter, forupdate(p)
   ;end select
   IF (count1 != upt_end)
    SET failed = lock_error
    RETURN
   ENDIF
   FOR (x = upt_begin TO upt_end)
     IF ((request->price_sched_items[x].action_type="UPT"))
      CALL echo(concat("price: ",cnvtstring(request->price_sched_items[x].price,17,2)))
      CALL echo(concat("price_sched_items_id: ",cnvtstring(request->price_sched_items[x].
         price_sched_items_id,17,2)))
      UPDATE  FROM price_sched_items p,
        (dummyt d  WITH seq = 1)
       SET p.seq = 1, p.price_sched_id =
        IF ((request->price_sched_items[x].price_sched_id IN (null, 0))) p.price_sched_id
        ELSE request->price_sched_items[x].price_sched_id
        ENDIF
        , p.price =
        IF ((request->price_sched_items[x].price=0)) p.price
        ELSE request->price_sched_items[x].price
        ENDIF
        ,
        p.allowable =
        IF ((request->price_sched_items[x].allowable=0)) p.allowable
        ELSE request->price_sched_items[x].allowable
        ENDIF
        , p.percent_revenue =
        IF ((request->price_sched_items[x].percent_revenue=0)) p.percent_revenue
        ELSE request->price_sched_items[x].percent_revenue
        ENDIF
        , p.charge_level_cd = nullcheck(p.charge_level_cd,request->price_sched_items[x].
         charge_level_cd,
         IF ((request->price_sched_items[x].charge_level_cd=0)) 0
         ELSE 1
         ENDIF
         ),
        p.interval_template_cd =
        IF ((request->price_sched_items[x].interval_template_cd=0)) 0
        ELSE request->price_sched_items[x].interval_template_cd
        ENDIF
        , p.detail_charge_ind = nullcheck(p.detail_charge_ind,request->price_sched_items[x].
         detail_charge_ind,
         IF ((request->price_sched_items[x].detail_charge_ind_ind=0)) 0
         ELSE 1
         ENDIF
         ), p.stats_only_ind = nullcheck(p.stats_only_ind,request->price_sched_items[x].
         stats_only_ind,
         IF ((request->price_sched_items[x].stats_only_ind_ind=0)) 0
         ELSE 1
         ENDIF
         ),
        p.exclusive_ind = nullcheck(p.exclusive_ind,request->price_sched_items[x].exclusive_ind,
         IF ((request->price_sched_items[x].exclusive_ind_ind=0)) 0
         ELSE 1
         ENDIF
         ), p.tax =
        IF ((request->price_sched_items[x].tax IN (null, 0))) p.tax
        ELSE request->price_sched_items[x].tax
        ENDIF
        , p.cost_adj_amt =
        IF ((request->price_sched_items[x].cost_adj_amt IN (null, 0))) p.cost_adj_amt
        ELSE request->price_sched_items[x].cost_adj_amt
        ENDIF
        ,
        p.billing_discount_priority_seq =
        IF ((request->price_sched_items[x].billing_discount_priority=1)) 1
        ELSE request->price_sched_items[x].billing_discount_priority
        ENDIF
        , p.beg_effective_dt_tm = nullcheck(p.beg_effective_dt_tm,cnvtdatetime(request->
          price_sched_items[x].beg_effective_dt_tm),
         IF ((request->price_sched_items[x].beg_effective_dt_tm=0)) 0
         ELSE 1
         ENDIF
         ), p.end_effective_dt_tm =
        IF ((request->price_sched_items[x].end_effective_dt_tm_ind=0)
         AND (request->price_sched_items[x].end_effective_dt_tm=0)) p.end_effective_dt_tm
        ELSEIF ((request->price_sched_items[x].end_effective_dt_tm_ind=1)
         AND (request->price_sched_items[x].end_effective_dt_tm=0)) null
        ELSE cnvtdatetime(request->price_sched_items[x].end_effective_dt_tm)
        ENDIF
        ,
        p.active_ind =
        IF ((request->price_sched_items[x].active_ind_ind=0)) p.active_ind
        ELSE request->price_sched_items[x].active_ind
        ENDIF
        , p.active_status_cd = nullcheck(p.active_status_cd,request->price_sched_items[x].
         active_status_cd,
         IF ((request->price_sched_items[x].active_status_cd=0)) 0
         ELSE 1
         ENDIF
         ), p.active_status_prsnl_id = nullcheck(p.active_status_prsnl_id,request->price_sched_items[
         x].active_status_prsnl_id,
         IF ((request->price_sched_items[x].active_status_prsnl_id=0)) 0
         ELSE 1
         ENDIF
         ),
        p.active_status_dt_tm = nullcheck(p.active_status_dt_tm,cnvtdatetime(request->
          price_sched_items[x].active_status_dt_tm),
         IF ((request->price_sched_items[x].active_status_dt_tm=0)) 0
         ELSE 1
         ENDIF
         ), p.capitation_ind = request->price_sched_items[x].capitation_ind, p.referral_req_ind =
        request->price_sched_items[x].referral_req_ind,
        p.updt_cnt = (cur_updt_cnt[d.seq]+ 1), p.updt_dt_tm = cnvtdatetime(curdate,curtime), p
        .updt_id = reqinfo->updt_id,
        p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->updt_task, p.units_ind =
        nullcheck(p.units_ind,request->price_sched_items[x].units_ind,
         IF ((request->price_sched_items[x].units_ind_ind=0)) 0
         ELSE 1
         ENDIF
         )
       PLAN (d)
        JOIN (p
        WHERE (p.price_sched_items_id=request->price_sched_items[x].price_sched_items_id)
         AND (request->price_sched_items[x].action_type="UPT"))
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET failed = update_error
       RETURN
      ELSE
       SET stat = alterlist(reply->price_sched_items,x)
       SET reply->price_sched_items[x].price_sched_id = request->price_sched_items[x].price_sched_id
       SET reply->price_sched_items[x].price_sched_items_id = request->price_sched_items[x].
       price_sched_items_id
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
