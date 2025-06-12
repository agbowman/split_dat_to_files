CREATE PROGRAM afc_del_mrp_from_bill_item:dba
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
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
  RECORD billitems(
    1 bill_item_qual = i4
    1 bill_item[*]
      2 bill_item_id = f8
      2 cost_adj_flex_id = f8
      2 min_charge_amt = f8
      2 cost_basis_amt = f8
      2 cost_adj_amt = f8
      2 adj_type_flag = i2
      2 price = f8
      2 price_sched_qual = i4
      2 price_sched[*]
        3 price_sched_id = f8
        3 tax = f8
  )
  RECORD temppricesched(
    1 price_sched_qual = i4
    1 price_sched[*]
      2 price_sched_id = f8
  )
 ENDIF
 IF ((request->cost_adj_flex_id > 0))
  SET billitemcnt = 0
  SELECT DISTINCT INTO "nl:"
   bi.*, caf.*
   FROM cost_adj_flex caf,
    item_class_node_r icnr,
    bill_item bi
   PLAN (caf
    WHERE (caf.cost_adj_sched_id=request->cost_adj_sched_id)
     AND (caf.cost_adj_flex_id=request->cost_adj_flex_id))
    JOIN (icnr
    WHERE icnr.class_node_id=caf.parent_entity_id)
    JOIN (bi
    WHERE bi.ext_parent_reference_id=icnr.item_id)
   DETAIL
    billitemcnt += 1, billitems->bill_item_qual = billitemcnt, stat = alterlist(billitems->bill_item,
     billitemcnt),
    billitems->bill_item[billitemcnt].bill_item_id = bi.bill_item_id, billitems->bill_item[
    billitemcnt].cost_adj_flex_id = caf.cost_adj_flex_id
   WITH nocounter
  ;end select
 ELSE
  SET billitemcnt = 0
  SELECT DISTINCT INTO "nl:"
   bi.*, caf.*
   FROM cost_adj_flex caf,
    item_class_node_r icnr,
    bill_item bi
   PLAN (caf
    WHERE (caf.cost_adj_sched_id=request->cost_adj_sched_id))
    JOIN (icnr
    WHERE icnr.class_node_id=caf.parent_entity_id)
    JOIN (bi
    WHERE bi.ext_parent_reference_id=icnr.item_id)
   DETAIL
    billitemcnt += 1, billitems->bill_item_qual = billitemcnt, stat = alterlist(billitems->bill_item,
     billitemcnt),
    billitems->bill_item[billitemcnt].bill_item_id = bi.bill_item_id, billitems->bill_item[
    billitemcnt].cost_adj_flex_id = caf.cost_adj_flex_id, billitems->bill_item[billitemcnt].
    min_charge_amt = caf.min_charge_amt
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->price_sched_id > 0))
  CALL echo("here 1")
  SET priceschedcnt = 0
  SELECT INTO "nl:"
   FROM price_schedule_adj psa
   WHERE (psa.cost_adj_sched_id=request->cost_adj_sched_id)
    AND (psa.price_sched_id=request->price_sched_id)
   DETAIL
    priceschedcnt += 1, temppricesched->price_sched_qual = priceschedcnt, stat = alterlist(
     temppricesched->price_sched,priceschedcnt),
    temppricesched->price_sched[priceschedcnt].price_sched_id = psa.price_sched_id
   WITH nocounter
  ;end select
 ELSE
  SET priceschedcnt = 0
  SELECT INTO "nl:"
   FROM price_schedule_adj psa
   WHERE (psa.cost_adj_sched_id=request->cost_adj_sched_id)
   DETAIL
    priceschedcnt += 1, temppricesched->price_sched_qual = priceschedcnt, stat = alterlist(
     temppricesched->price_sched,priceschedcnt),
    temppricesched->price_sched[priceschedcnt].price_sched_id = psa.price_sched_id
   WITH nocounter
  ;end select
 ENDIF
 SET x = 0
 FOR (x = 1 TO billitems->bill_item_qual)
  SET billitems->bill_item[x].price_sched_qual = temppricesched->price_sched_qual
  FOR (z = 1 TO temppricesched->price_sched_qual)
   SET stat = alterlist(billitems->bill_item[x].price_sched,z)
   SET billitems->bill_item[x].price_sched[z].price_sched_id = temppricesched->price_sched[z].
   price_sched_id
  ENDFOR
 ENDFOR
 CALL echorecord(billitems)
 SET pscnt = 0
 SET bicnt = 0
 FOR (bicnt = 1 TO billitems->bill_item_qual)
  CALL echo(build("Price_Sched_Qual: ",billitems->bill_item[bicnt].price_sched_qual))
  FOR (pscnt = 1 TO billitems->bill_item[bicnt].price_sched_qual)
    SET found_one = 0
    SELECT INTO "nl:"
     FROM price_sched_items psi
     WHERE (psi.price_sched_id=billitems->bill_item[bicnt].price_sched[pscnt].price_sched_id)
      AND (psi.bill_item_id=billitems->bill_item[bicnt].bill_item_id)
      AND psi.active_ind=1
      AND psi.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND psi.end_effective_dt_tm >= cnvtdatetime(sysdate)
     DETAIL
      found_one = 1, billitems->bill_item[bicnt].price_sched[pscnt].tax = psi.tax
     WITH nocounter
    ;end select
    CALL echo(build("price_sched_items_id = ",billitems->bill_item[bicnt].price_sched[pscnt].
      price_sched_id))
    CALL echo(build("bill_item_id = ",billitems->bill_item[bicnt].bill_item_id))
    IF (found_one=1)
     UPDATE  FROM price_sched_items psi
      SET psi.cost_adj_amt = 0, psi.price = 0
      WHERE (psi.price_sched_id=billitems->bill_item[bicnt].price_sched[pscnt].price_sched_id)
       AND (psi.bill_item_id=billitems->bill_item[bicnt].bill_item_id)
      WITH nocounter
     ;end update
    ENDIF
  ENDFOR
 ENDFOR
 SET xmrp = 0
 FOR (xmrp = 1 TO billitems->bill_item_qual)
   UPDATE  FROM bill_item bi
    SET bi.cost_basis_amt = 0
    WHERE (bi.bill_item_id=billitems->bill_item[xmrp].bill_item_id)
   ;end update
 ENDFOR
 SET reqinfo->commit_ind = true
END GO
