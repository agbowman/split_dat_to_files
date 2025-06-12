CREATE PROGRAM afc_maintain_prices:dba
 RECORD bill_items(
   1 bi[*]
     2 bill_item_id = f8
     2 price_sched_items_id = f8
     2 ext_description = c100
     2 price_as_of = f8
     2 updated_price_as_of = f8
     2 found_price_to_update = i2
     2 interval_template_cd = f8
     2 interval_cdf = c12
     2 interval_display = c40
     2 new_psi = f8
     2 prices[*]
       3 price_sched_items_id = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 inactivate_ind = i2
       3 price = f8
     2 iit[*]
       3 item_interval_id = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 price = f8
       3 interval_id = f8
       3 updated_price = f8
       3 new_interval_id = f8
       3 beg_value = f8
       3 end_value = f8
       3 bim[*]
         4 bill_item_mod_id = f8
 )
 FREE SET psicolumns
 RECORD psicolumns(
   1 col[100]
     2 col_name = c50
 )
 FREE SET iitcolumns
 RECORD iitcolumns(
   1 col[100]
     2 col_name = c50
 )
 FREE SET bimcolumns
 RECORD bimcolumns(
   1 col[100]
     2 col_name = c50
 )
 RECORD psirequest(
   1 price_sched_items_qual = i2
   1 price_sched_items[*]
     2 action_type = vc
     2 price_sched_id = f8
     2 bill_item_id = f8
     2 price_sched_items_id = f8
     2 price_ind = i2
     2 price = f8
     2 percent_revenue = i4
     2 charge_level_cd = f8
     2 interval_template_cd = f8
     2 detail_charge_ind_ind = i2
     2 detail_charge_ind = i2
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm_ind = i2
     2 end_effective_dt_tm = dq8
     2 updt_cnt = i2
     2 units_ind = i2
     2 units_ind_ind = i2
     2 stats_only_ind_ind = i2
     2 stats_only_ind = i2
     2 allowable = f8
     2 exclusive_ind_ind = i2
     2 exclusive_ind = i2
     2 tax = f8
     2 cost_adj_amt = f8
     2 capitation_ind = i2
     2 referral_req_ind = i2
     2 billing_discount_priority = i4
 )
 CALL echorecord(request,"ccluserdir:afc_price_req.dat")
 DECLARE hold_amount = f8
 DECLARE one_sec = f8
 DECLARE cnt = i4
 DECLARE codeset = i4
 DECLARE cdf_meaning = c12
 DECLARE inactive_cd = f8
 DECLARE active_cd = f8
 DECLARE new_price_id = f8
 DECLARE dcode = f8
 DECLARE interval_cd = f8
 DECLARE new_iit_id = f8
 DECLARE meaningval = c12
 DECLARE displayval = c40
 SET col_count = 0
 SET iit_col_count = 0
 SET bim_col_count = 0
 SET request->percentchange = (request->percentchange/ 100)
 SET max_price_num = 0
 SET found_interval = 0
 SET found_price = 0
 SET found_update = 0
 SET codeset = 48
 SET cdf_meaning = "INACTIVE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,inactive_cd)
 CALL echo(build("the inactive code value is: ",inactive_cd))
 SET codeset = 48
 SET cdf_meaning = "ACTIVE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,active_cd)
 CALL echo(build("the active code value is: ",active_cd))
 SET codeset = 13019
 SET cdf_meaning = "INTERVALCODE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,interval_cd)
 CALL echo(build("the interval code value is: ",interval_cd))
 CALL get_bill_items(0)
 IF (size(bill_items->bi,5) > 0)
  IF ((request->setzero_ind != 1))
   CALL get_prices_as_of(0)
   CALL get_prices_to_update(0)
   CALL update_effective_dates(0)
   CALL get_psi_columns(0)
   CALL add_prices(0)
   IF (found_price=1
    AND (request->interval_ind IN (0, 2)))
    CALL create_report(0)
   ENDIF
   IF ((request->interval_ind IN (1, 2)))
    CALL get_interval_prices(0)
    CALL get_iit_columns(0)
    CALL get_bim_columns(0)
    CALL copy_interval_prices(0)
    IF (found_interval=1)
     CALL create_interval_report(0)
    ENDIF
   ENDIF
  ELSE
   CALL get_prices_to_update(0)
   CALL update_effective_dates(0)
   CALL get_psi_columns(0)
   CALL add_zero_prices(0)
   CALL create_report(0)
  ENDIF
 ELSE
  CALL text(23,1,"No bill items found.")
 ENDIF
 SUBROUTINE get_bill_items(a)
   CALL echo("Getting bill items...")
   SET num_bi = 0
   SELECT
    IF ((request->level_ind=1))INTO "nl:"
     b.bill_item_id, b.ext_description
     FROM bill_item b
     WHERE (b.ext_owner_cd=request->ext_owner_code)
      AND b.ext_parent_reference_id != 0
      AND b.active_ind=1
    ELSEIF ((request->level_ind=2))INTO "nl:"
     b.bill_item_id, b.ext_description
     FROM bill_item b
     WHERE (b.ext_owner_cd=request->ext_owner_code)
      AND b.ext_parent_reference_id != 0
      AND b.ext_child_reference_id=0
      AND b.active_ind=1
    ELSEIF ((request->level_ind=3))INTO "nl:"
     b.bill_item_id, b.ext_description
     FROM bill_item b
     WHERE (b.ext_owner_cd=request->ext_owner_code)
      AND b.ext_parent_reference_id != 0
      AND b.ext_child_reference_id != 0
      AND b.active_ind=1
    ELSEIF ((request->level_ind=4))INTO "nl:"
     b.bill_item_id, b.ext_description
     FROM bill_item b
     WHERE (b.ext_owner_cd=request->ext_owner_code)
      AND b.ext_parent_reference_id=0
      AND b.ext_child_reference_id != 0
      AND b.active_ind=1
    ELSE
    ENDIF
    DETAIL
     num_bi = (num_bi+ 1), stat = alterlist(bill_items->bi,num_bi), bill_items->bi[num_bi].
     bill_item_id = b.bill_item_id,
     bill_items->bi[num_bi].ext_description = b.ext_description, bill_items->bi[num_bi].price_as_of
      = 0.0, bill_items->bi[num_bi].updated_price_as_of = 0.0,
     bill_items->bi[num_bi].found_price_to_update = 0, bill_items->bi[num_bi].interval_template_cd =
     0.0, bill_items->bi[num_bi].new_psi = 0.0
    WITH nocounter
   ;end select
   CALL echo(build("# of bill items found:",size(bill_items->bi,5)))
   CALL echorecord(bill_items,"ccluserdir:afc_bi.dat")
 END ;Subroutine
 SUBROUTINE get_prices_as_of(b)
   CALL echo("Getting price as of...")
   SET hold_amount = 0.0
   IF ((request->interval_ind=2))
    SELECT INTO "nl:"
     p.price
     FROM (dummyt d  WITH seq = value(size(bill_items->bi,5))),
      price_sched_items p
     PLAN (d)
      JOIN (p
      WHERE (p.bill_item_id=bill_items->bi[d.seq].bill_item_id)
       AND (p.price_sched_id=request->from_price_sched_id)
       AND p.active_ind=1
       AND p.beg_effective_dt_tm <= cnvtdatetime(request->price_effective_dt_tm)
       AND p.end_effective_dt_tm >= cnvtdatetime(request->price_effective_dt_tm))
     DETAIL
      bill_items->bi[d.seq].price_as_of = p.price, bill_items->bi[d.seq].found_price_to_update = 1,
      bill_items->bi[d.seq].price_sched_items_id = p.price_sched_items_id,
      bill_items->bi[d.seq].interval_template_cd = p.interval_template_cd
      IF (p.interval_template_cd > 0)
       found_interval = 1, dcode = bill_items->bi[d.seq].interval_template_cd, meaningval =
       uar_get_code_meaning(dcode),
       bill_items->bi[d.seq].interval_cdf = meaningval,
       CALL echo(meaningval), displayval = uar_get_code_display(dcode),
       bill_items->bi[d.seq].interval_display = displayval,
       CALL echo(displayval)
      ELSE
       found_price = 1
       IF ((request->flat_ind=1))
        bill_items->bi[d.seq].updated_price_as_of = (p.price+ request->flatchange)
       ELSE
        bill_items->bi[d.seq].updated_price_as_of = (p.price+ (p.price * request->percentchange))
       ENDIF
       IF ((request->roundingdirection_ind=2))
        IF ((request->roundingamount_ind=1))
         bill_items->bi[d.seq].updated_price_as_of = ceil(bill_items->bi[d.seq].updated_price_as_of)
        ELSEIF ((request->roundingamount_ind=2))
         hold_amount = (bill_items->bi[d.seq].updated_price_as_of * 10), hold_amount = ceil(
          hold_amount), bill_items->bi[d.seq].updated_price_as_of = (hold_amount/ 10)
        ELSE
         hold_amount = (bill_items->bi[d.seq].updated_price_as_of * 100), hold_amount = ceil(
          hold_amount), bill_items->bi[d.seq].updated_price_as_of = (hold_amount/ 100)
        ENDIF
       ELSEIF ((request->roundingdirection_ind=3))
        IF ((request->roundingamount_ind=1))
         bill_items->bi[d.seq].updated_price_as_of = floor(bill_items->bi[d.seq].updated_price_as_of)
        ELSEIF ((request->roundingamount_ind=2))
         hold_amount = (bill_items->bi[d.seq].updated_price_as_of * 10), hold_amount = floor(
          hold_amount), bill_items->bi[d.seq].updated_price_as_of = (hold_amount/ 10)
        ELSE
         hold_amount = (bill_items->bi[d.seq].updated_price_as_of * 100), hold_amount = floor(
          hold_amount), bill_items->bi[d.seq].updated_price_as_of = (hold_amount/ 100)
        ENDIF
       ELSEIF ((request->roundingdirection_ind=4))
        IF ((request->roundingamount_ind=1))
         bill_items->bi[d.seq].updated_price_as_of = round((bill_items->bi[d.seq].updated_price_as_of
          + 0.000001),0)
        ELSEIF ((request->roundingamount_ind=2))
         bill_items->bi[d.seq].updated_price_as_of = round((bill_items->bi[d.seq].updated_price_as_of
          + 0.000001),1)
        ELSE
         bill_items->bi[d.seq].updated_price_as_of = round((bill_items->bi[d.seq].updated_price_as_of
          + 0.000001),2)
        ENDIF
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
   ELSEIF ((request->interval_ind=0))
    SELECT INTO "nl:"
     p.price
     FROM (dummyt d  WITH seq = value(size(bill_items->bi,5))),
      price_sched_items p
     PLAN (d)
      JOIN (p
      WHERE (p.bill_item_id=bill_items->bi[d.seq].bill_item_id)
       AND (p.price_sched_id=request->from_price_sched_id)
       AND p.active_ind=1
       AND p.beg_effective_dt_tm <= cnvtdatetime(request->price_effective_dt_tm)
       AND p.end_effective_dt_tm >= cnvtdatetime(request->price_effective_dt_tm)
       AND p.interval_template_cd=0)
     DETAIL
      bill_items->bi[d.seq].price_as_of = p.price, bill_items->bi[d.seq].found_price_to_update = 1,
      bill_items->bi[d.seq].price_sched_items_id = p.price_sched_items_id,
      found_price = 1
      IF ((request->flat_ind=1))
       bill_items->bi[d.seq].updated_price_as_of = (p.price+ request->flatchange)
      ELSE
       bill_items->bi[d.seq].updated_price_as_of = (p.price+ (p.price * request->percentchange))
      ENDIF
      IF ((request->roundingdirection_ind=2))
       IF ((request->roundingamount_ind=1))
        bill_items->bi[d.seq].updated_price_as_of = ceil(bill_items->bi[d.seq].updated_price_as_of)
       ELSEIF ((request->roundingamount_ind=2))
        hold_amount = (bill_items->bi[d.seq].updated_price_as_of * 10), hold_amount = ceil(
         hold_amount), bill_items->bi[d.seq].updated_price_as_of = (hold_amount/ 10)
       ELSE
        hold_amount = (bill_items->bi[d.seq].updated_price_as_of * 100), hold_amount = ceil(
         hold_amount), bill_items->bi[d.seq].updated_price_as_of = (hold_amount/ 100)
       ENDIF
      ELSEIF ((request->roundingdirection_ind=3))
       IF ((request->roundingamount_ind=1))
        bill_items->bi[d.seq].updated_price_as_of = floor(bill_items->bi[d.seq].updated_price_as_of)
       ELSEIF ((request->roundingamount_ind=2))
        hold_amount = (bill_items->bi[d.seq].updated_price_as_of * 10), hold_amount = floor(
         hold_amount), bill_items->bi[d.seq].updated_price_as_of = (hold_amount/ 10)
       ELSE
        hold_amount = (bill_items->bi[d.seq].updated_price_as_of * 100), hold_amount = floor(
         hold_amount), bill_items->bi[d.seq].updated_price_as_of = (hold_amount/ 100)
       ENDIF
      ELSEIF ((request->roundingdirection_ind=4))
       IF ((request->roundingamount_ind=1))
        bill_items->bi[d.seq].updated_price_as_of = round((bill_items->bi[d.seq].updated_price_as_of
         + 0.000001),0)
       ELSEIF ((request->roundingamount_ind=2))
        bill_items->bi[d.seq].updated_price_as_of = round((bill_items->bi[d.seq].updated_price_as_of
         + 0.000001),1)
       ELSE
        bill_items->bi[d.seq].updated_price_as_of = round((bill_items->bi[d.seq].updated_price_as_of
         + 0.000001),2)
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     p.price
     FROM (dummyt d  WITH seq = value(size(bill_items->bi,5))),
      price_sched_items p
     PLAN (d)
      JOIN (p
      WHERE (p.bill_item_id=bill_items->bi[d.seq].bill_item_id)
       AND (p.price_sched_id=request->from_price_sched_id)
       AND p.active_ind=1
       AND p.beg_effective_dt_tm <= cnvtdatetime(request->price_effective_dt_tm)
       AND p.end_effective_dt_tm >= cnvtdatetime(request->price_effective_dt_tm)
       AND p.interval_template_cd > 0)
     DETAIL
      bill_items->bi[d.seq].price_as_of = p.price, bill_items->bi[d.seq].found_price_to_update = 1,
      bill_items->bi[d.seq].price_sched_items_id = p.price_sched_items_id,
      bill_items->bi[d.seq].interval_template_cd = p.interval_template_cd, found_interval = 1, dcode
       = bill_items->bi[d.seq].interval_template_cd,
      meaningval = uar_get_code_meaning(dcode), bill_items->bi[d.seq].interval_cdf = meaningval,
      CALL echo(meaningval),
      displayval = uar_get_code_display(dcode), bill_items->bi[d.seq].interval_display = displayval,
      CALL echo(displayval)
     WITH nocounter
    ;end select
   ENDIF
   CALL echorecord(bill_items,"ccluserdir:p_as_of.dat")
 END ;Subroutine
 SUBROUTINE get_prices_to_update(c)
   CALL echo("Getting prices to update...")
   SET price_num = 0
   SET do_nothing = 0
   SET one_sec = (1.0/ 86400.0)
   SELECT INTO "nl:"
    p.price_sched_items_id, p.beg_effective_dt_tm, p.end_effective_dt_tm
    FROM (dummyt d  WITH seq = value(size(bill_items->bi,5))),
     price_sched_items p
    PLAN (d
     WHERE (((bill_items->bi[d.seq].found_price_to_update=1)) OR ((request->setzero_ind=1))) )
     JOIN (p
     WHERE (p.bill_item_id=bill_items->bi[d.seq].bill_item_id)
      AND (p.price_sched_id=request->to_price_sched_id)
      AND p.active_ind=1)
    ORDER BY p.bill_item_id
    HEAD p.bill_item_id
     price_num = 0
    DETAIL
     found_update = 1
     IF (p.beg_effective_dt_tm >= cnvtdatetime(request->beg_effective_dt_tm)
      AND p.end_effective_dt_tm <= cnvtdatetime(request->end_effective_dt_tm))
      price_num = (price_num+ 1), stat = alterlist(bill_items->bi[d.seq].prices,price_num),
      bill_items->bi[d.seq].prices[price_num].price_sched_items_id = p.price_sched_items_id,
      bill_items->bi[d.seq].prices[price_num].inactivate_ind = 1, bill_items->bi[d.seq].prices[
      price_num].price = p.price
     ELSEIF (p.beg_effective_dt_tm < cnvtdatetime(request->beg_effective_dt_tm)
      AND p.end_effective_dt_tm >= cnvtdatetime(request->beg_effective_dt_tm))
      price_num = (price_num+ 1), stat = alterlist(bill_items->bi[d.seq].prices,price_num),
      bill_items->bi[d.seq].prices[price_num].price_sched_items_id = p.price_sched_items_id,
      bill_items->bi[d.seq].prices[price_num].beg_effective_dt_tm = cnvtdatetime(p
       .beg_effective_dt_tm), bill_items->bi[d.seq].prices[price_num].end_effective_dt_tm =
      datetimeadd(request->beg_effective_dt_tm,- (one_sec)), bill_items->bi[d.seq].prices[price_num].
      price = p.price
     ELSEIF (p.beg_effective_dt_tm >= cnvtdatetime(request->beg_effective_dt_tm)
      AND p.beg_effective_dt_tm <= cnvtdatetime(request->end_effective_dt_tm)
      AND p.end_effective_dt_tm > cnvtdatetime(request->end_effective_dt_tm))
      price_num = (price_num+ 1), stat = alterlist(bill_items->bi[d.seq].prices,price_num),
      bill_items->bi[d.seq].prices[price_num].price_sched_items_id = p.price_sched_items_id,
      bill_items->bi[d.seq].prices[price_num].beg_effective_dt_tm = datetimeadd(request->
       end_effective_dt_tm,one_sec), bill_items->bi[d.seq].prices[price_num].end_effective_dt_tm =
      cnvtdatetime(p.end_effective_dt_tm), bill_items->bi[d.seq].prices[price_num].price = p.price
     ELSE
      do_nothing = 1
     ENDIF
     IF (price_num > max_price_num)
      max_price_num = price_num
     ENDIF
    WITH nocounter
   ;end select
   CALL echorecord(bill_items,"ccluserdir:afc_price.dat")
   CALL echo(build("max_price_num is:",max_price_num))
 END ;Subroutine
 SUBROUTINE update_effective_dates(d)
  CALL echo("Updating effective dates...")
  FOR (bi_counter = 1 TO size(bill_items->bi,5))
    FOR (count = 1 TO size(bill_items->bi[bi_counter].prices,5))
      IF ((bill_items->bi[bi_counter].prices[count].inactivate_ind=0))
       SELECT INTO "nl:"
        psi2.price_sched_items_id
        FROM price_sched_items psi,
         price_sched_items psi2
        PLAN (psi
         WHERE (psi.price_sched_items_id=bill_items->bi[bi_counter].prices[count].
         price_sched_items_id))
         JOIN (psi2
         WHERE psi2.price_sched_items_id != psi.price_sched_items_id
          AND psi2.price_sched_id=psi.price_sched_id
          AND psi2.bill_item_id=psi.bill_item_id
          AND psi2.beg_effective_dt_tm=psi.beg_effective_dt_tm
          AND psi2.end_effective_dt_tm=psi.end_effective_dt_tm
          AND psi2.active_ind=1)
        WITH nocounter
       ;end select
       IF (curqual=0)
        UPDATE  FROM price_sched_items p
         SET p.beg_effective_dt_tm = cnvtdatetime(bill_items->bi[bi_counter].prices[count].
           beg_effective_dt_tm), p.end_effective_dt_tm = cnvtdatetime(bill_items->bi[bi_counter].
           prices[count].end_effective_dt_tm), p.updt_id = request->user,
          p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(curdate,curtime), p.updt_task =
          951233,
          p.updt_applctx = 0
         WHERE (p.price_sched_items_id=bill_items->bi[bi_counter].prices[count].price_sched_items_id)
        ;end update
       ELSE
        DELETE  FROM price_sched_items p
         WHERE (p.price_sched_items_id=bill_items->bi[bi_counter].prices[count].price_sched_items_id)
        ;end delete
       ENDIF
      ELSE
       SELECT INTO "nl:"
        psi2.price_sched_items_id
        FROM price_sched_items psi,
         price_sched_items psi2
        PLAN (psi
         WHERE (psi.price_sched_items_id=bill_items->bi[bi_counter].prices[count].
         price_sched_items_id))
         JOIN (psi2
         WHERE psi2.price_sched_items_id != psi.price_sched_items_id
          AND psi2.price_sched_id=psi.price_sched_id
          AND psi2.bill_item_id=psi.bill_item_id
          AND psi2.beg_effective_dt_tm=psi.beg_effective_dt_tm
          AND psi2.end_effective_dt_tm=psi.end_effective_dt_tm
          AND psi2.active_ind=0)
        WITH nocounter
       ;end select
       IF (curqual=0)
        UPDATE  FROM price_sched_items p
         SET p.active_ind = 0, p.active_status_prsnl_id = request->user, p.active_status_cd =
          inactive_cd,
          p.active_status_dt_tm = cnvtdatetime(curdate,curtime), p.updt_id = request->user, p
          .updt_cnt = (p.updt_cnt+ 1),
          p.updt_dt_tm = cnvtdatetime(curdate,curtime), p.updt_task = 951233, p.updt_applctx = 0
         WHERE (p.price_sched_items_id=bill_items->bi[bi_counter].prices[count].price_sched_items_id)
        ;end update
       ELSE
        DELETE  FROM price_sched_items p
         WHERE (p.price_sched_items_id=bill_items->bi[bi_counter].prices[count].price_sched_items_id)
        ;end delete
       ENDIF
      ENDIF
    ENDFOR
  ENDFOR
 END ;Subroutine
 SUBROUTINE get_psi_columns(e)
   CALL echo("Getting psi columns...")
   SELECT INTO "nl:"
    l.attr_name
    FROM dtable t,
     dtableattr a,
     dtableattrl l
    WHERE t.table_name="PRICE_SCHED_ITEMS"
     AND t.table_name=a.table_name
     AND l.structtype="F"
     AND btest(l.stat,11)=0
     AND  NOT (l.attr_name IN ("PRICE_SCHED_ITEMS_ID", "ACTIVE_IND", "ACTIVE_STATUS_CD",
    "ACTIVE_STATUS_DT_TM", "ACTIVE_STATUS_PRSNL_ID",
    "BEG_EFFECTIVE_DT_TM", "END_EFFECTIVE_DT_TM", "PRICE", "PRICE_SCHED_ID", "UPDT_APPLCTX",
    "UPDT_CNT", "UPDT_DT_TM", "UPDT_ID", "UPDT_TASK"))
    DETAIL
     col_count = (col_count+ 1)
     IF (mod(col_count,100)=1)
      stat = alter(psicolumns->col,(col_count+ 99))
     ENDIF
     psicolumns->col[col_count].col_name = l.attr_name
    WITH nocounter
   ;end select
   CALL echorecord(psicolumns,"ccluserdir:afc_psi.dat")
   CALL echo(build("col_count is: ",col_count))
 END ;Subroutine
 SUBROUTINE add_prices(f)
  CALL echo("Adding prices...")
  FOR (count = 1 TO size(bill_items->bi,5))
    IF ((bill_items->bi[count].found_price_to_update=1))
     SELECT INTO "nl:"
      psi2.price_sched_items_id
      FROM price_sched_items psi,
       price_sched_items psi2
      PLAN (psi
       WHERE (psi.price_sched_items_id=bill_items->bi[count].price_sched_items_id))
       JOIN (psi2
       WHERE psi2.price_sched_items_id != psi.price_sched_items_id
        AND psi2.price_sched_id=psi.price_sched_id
        AND psi2.bill_item_id=psi.bill_item_id
        AND psi2.beg_effective_dt_tm=psi.beg_effective_dt_tm
        AND psi2.end_effective_dt_tm=psi.end_effective_dt_tm
        AND psi2.active_ind=1)
      WITH nocounter
     ;end select
     IF (curqual=0)
      IF ((request->interval_ind=1)
       AND (bill_items->bi[count].interval_template_cd > 0))
       SET new_price_id = 0.0
       SELECT INTO "nl:"
        price_seq_num = seq(price_sched_seq,nextval)"##################;rp0"
        FROM dual
        DETAIL
         new_price_id = cnvtreal(price_seq_num)
        WITH format, counter
       ;end select
       CALL echo(build("New Price ID: ",new_price_id))
       SET bill_items->bi[count].new_psi = new_price_id
       CALL parser("insert into price_sched_items (")
       FOR (x = 1 TO col_count)
         CALL parser(concat(trim(psicolumns->col[x].col_name),","))
       ENDFOR
       CALL parser("PRICE_SCHED_ITEMS_ID,ACTIVE_IND,ACTIVE_STATUS_CD,ACTIVE_STATUS_DT_TM,")
       CALL parser("ACTIVE_STATUS_PRSNL_ID,BEG_EFFECTIVE_DT_TM,END_EFFECTIVE_DT_TM,")
       CALL parser("PRICE,PRICE_SCHED_ID,")
       CALL parser("UPDT_APPLCTX,UPDT_CNT,UPDT_DT_TM,UPDT_ID,UPDT_TASK)")
       CALL parser("(select ")
       FOR (x = 1 TO col_count)
         CALL parser(concat("PSI.",trim(psicolumns->col[x].col_name),", "))
       ENDFOR
       CALL parser("new_price_id,")
       CALL parser("1,")
       CALL parser("ACTIVE_CD,")
       CALL parser("cnvtdatetime(curdate, curtime3),")
       CALL parser("request->user,")
       CALL parser("cnvtdatetime(request->beg_effective_dt_tm),")
       CALL parser("cnvtdatetime(request->end_effective_dt_tm),")
       CALL parser("bill_items->bi[count]->updated_price_as_of,")
       CALL parser("request->to_price_sched_id,")
       CALL parser("0,")
       CALL parser("0,")
       CALL parser("cnvtdatetime(curdate, curtime3),")
       CALL parser("request->user,")
       CALL parser("951234")
       CALL parser("from price_sched_items PSI")
       CALL parser(build("where PSI.price_sched_items_id = ",bill_items->bi[count].
         price_sched_items_id,")"))
       CALL parser("go")
      ELSEIF ((request->interval_ind=0)
       AND (bill_items->bi[count].interval_template_cd=0))
       SET new_price_id = 0.0
       SELECT INTO "nl:"
        price_seq_num = seq(price_sched_seq,nextval)"##################;rp0"
        FROM dual
        DETAIL
         new_price_id = cnvtreal(price_seq_num)
        WITH format, counter
       ;end select
       CALL echo(build("New Price ID: ",new_price_id))
       SET bill_items->bi[count].new_psi = new_price_id
       CALL parser("insert into price_sched_items (")
       FOR (x = 1 TO col_count)
         CALL parser(concat(trim(psicolumns->col[x].col_name),","))
       ENDFOR
       CALL parser("PRICE_SCHED_ITEMS_ID,ACTIVE_IND,ACTIVE_STATUS_CD,ACTIVE_STATUS_DT_TM,")
       CALL parser("ACTIVE_STATUS_PRSNL_ID,BEG_EFFECTIVE_DT_TM,END_EFFECTIVE_DT_TM,")
       CALL parser("PRICE,PRICE_SCHED_ID,")
       CALL parser("UPDT_APPLCTX,UPDT_CNT,UPDT_DT_TM,UPDT_ID,UPDT_TASK)")
       CALL parser("(select ")
       FOR (x = 1 TO col_count)
         CALL parser(concat("PSI.",trim(psicolumns->col[x].col_name),", "))
       ENDFOR
       CALL parser("new_price_id,")
       CALL parser("1,")
       CALL parser("ACTIVE_CD,")
       CALL parser("cnvtdatetime(curdate, curtime3),")
       CALL parser("request->user,")
       CALL parser("cnvtdatetime(request->beg_effective_dt_tm),")
       CALL parser("cnvtdatetime(request->end_effective_dt_tm),")
       CALL parser("bill_items->bi[count]->updated_price_as_of,")
       CALL parser("request->to_price_sched_id,")
       CALL parser("0,")
       CALL parser("0,")
       CALL parser("cnvtdatetime(curdate, curtime3),")
       CALL parser("request->user,")
       CALL parser("951234")
       CALL parser("from price_sched_items PSI")
       CALL parser(build("where PSI.price_sched_items_id = ",bill_items->bi[count].
         price_sched_items_id,")"))
       CALL parser("go")
      ELSE
       SET new_price_id = 0.0
       SELECT INTO "nl:"
        price_seq_num = seq(price_sched_seq,nextval)"##################;rp0"
        FROM dual
        DETAIL
         new_price_id = cnvtreal(price_seq_num)
        WITH format, counter
       ;end select
       CALL echo(build("New Price ID: ",new_price_id))
       SET bill_items->bi[count].new_psi = new_price_id
       CALL parser("insert into price_sched_items (")
       FOR (x = 1 TO col_count)
         CALL parser(concat(trim(psicolumns->col[x].col_name),","))
       ENDFOR
       CALL parser("PRICE_SCHED_ITEMS_ID,ACTIVE_IND,ACTIVE_STATUS_CD,ACTIVE_STATUS_DT_TM,")
       CALL parser("ACTIVE_STATUS_PRSNL_ID,BEG_EFFECTIVE_DT_TM,END_EFFECTIVE_DT_TM,")
       CALL parser("PRICE,PRICE_SCHED_ID,")
       CALL parser("UPDT_APPLCTX,UPDT_CNT,UPDT_DT_TM,UPDT_ID,UPDT_TASK)")
       CALL parser("(select ")
       FOR (x = 1 TO col_count)
         CALL parser(concat("PSI.",trim(psicolumns->col[x].col_name),", "))
       ENDFOR
       CALL parser("new_price_id,")
       CALL parser("1,")
       CALL parser("ACTIVE_CD,")
       CALL parser("cnvtdatetime(curdate, curtime3),")
       CALL parser("request->user,")
       CALL parser("cnvtdatetime(request->beg_effective_dt_tm),")
       CALL parser("cnvtdatetime(request->end_effective_dt_tm),")
       CALL parser("bill_items->bi[count]->updated_price_as_of,")
       CALL parser("request->to_price_sched_id,")
       CALL parser("0,")
       CALL parser("0,")
       CALL parser("cnvtdatetime(curdate, curtime3),")
       CALL parser("request->user,")
       CALL parser("951234")
       CALL parser("from price_sched_items PSI")
       CALL parser(build("where PSI.price_sched_items_id = ",bill_items->bi[count].
         price_sched_items_id,")"))
       CALL parser("go")
      ENDIF
     ENDIF
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE add_zero_prices(g)
   CALL echo("Adding zero prices...")
   SET stat = alterlist(psirequest->price_sched_items,size(bill_items->bi,5))
   SET psirequest->price_sched_items_qual = size(bill_items->bi,5)
   SET pcount = 0
   FOR (count = 1 TO size(bill_items->bi,5))
    SELECT INTO "nl:"
     psi.price_sched_items_id
     FROM price_sched_items psi
     WHERE (psi.price_sched_id=request->to_price_sched_id)
      AND (psi.bill_item_id=bill_items->bi[count].bill_item_id)
      AND psi.beg_effective_dt_tm=cnvtdatetime(request->beg_effective_dt_tm)
      AND psi.end_effective_dt_tm=cnvtdatetime(request->end_effective_dt_tm)
      AND psi.active_ind=1
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET pcount = (pcount+ 1)
     SET psirequest->price_sched_items[pcount].action_type = "ADD"
     SET psirequest->price_sched_items[pcount].price_sched_id = request->to_price_sched_id
     SET psirequest->price_sched_items[pcount].bill_item_id = bill_items->bi[pcount].bill_item_id
     SET psirequest->price_sched_items[pcount].price = 0.00
     SET psirequest->price_sched_items[pcount].detail_charge_ind_ind = 1
     SET psirequest->price_sched_items[pcount].detail_charge_ind = 1
     SET psirequest->price_sched_items[pcount].active_ind = 1
     SET psirequest->price_sched_items[pcount].active_status_cd = active_cd
     SET psirequest->price_sched_items[pcount].active_status_dt_tm = cnvtdatetime(curdate,curtime)
     SET psirequest->price_sched_items[pcount].active_status_prsnl_id = request->user
     SET psirequest->price_sched_items[pcount].beg_effective_dt_tm = cnvtdatetime(request->
      beg_effective_dt_tm)
     SET psirequest->price_sched_items[pcount].end_effective_dt_tm = cnvtdatetime(request->
      end_effective_dt_tm)
     SET psirequest->price_sched_items[pcount].updt_cnt = 0
     SET psirequest->price_sched_items[pcount].allowable = 0.0
     SET psirequest->price_sched_items[pcount].tax = 0.0
     SET psirequest->price_sched_items[pcount].exclusive_ind_ind = 0
     SET psirequest->price_sched_items[pcount].exclusive_ind = 0
     SET psirequest->price_sched_items[pcount].cost_adj_amt = 0.0
     SET psirequest->price_sched_items[pcount].capitation_ind = 0
     SET psirequest->price_sched_items[pcount].referral_req_ind = 0
     SET psirequest->price_sched_items[pcount].billing_discount_priority = 0
    ENDIF
   ENDFOR
   EXECUTE afc_add_price_sched_item  WITH replace(request,psirequest)
 END ;Subroutine
 SUBROUTINE get_interval_prices(h)
   CALL echo("Getting interval prices...")
   SET int_count = 0
   SET bim_count = 0
   SELECT INTO "nl:"
    bill_item_id = bill_items->bi[d.seq].bill_item_id, i.item_interval_id, i.price
    FROM (dummyt d  WITH seq = value(size(bill_items->bi,5))),
     item_interval_table i,
     interval_table it
    PLAN (d
     WHERE (bill_items->bi[d.seq].interval_template_cd > 0)
      AND (bill_items->bi[d.seq].found_price_to_update=1))
     JOIN (i
     WHERE (i.interval_template_cd=bill_items->bi[d.seq].interval_template_cd)
      AND (i.parent_entity_id=bill_items->bi[d.seq].price_sched_items_id)
      AND i.parent_entity_name="PRICE_SCHED_ITEMS"
      AND i.active_ind=1)
     JOIN (it
     WHERE it.interval_id=i.interval_id)
    ORDER BY bill_item_id, it.beg_value
    HEAD bill_item_id
     int_count = 0
    DETAIL
     int_count = (int_count+ 1), stat = alterlist(bill_items->bi[d.seq].iit,int_count), bill_items->
     bi[d.seq].iit[int_count].item_interval_id = i.item_interval_id,
     bill_items->bi[d.seq].iit[int_count].beg_value = it.beg_value, bill_items->bi[d.seq].iit[
     int_count].end_value = it.end_value, bill_items->bi[d.seq].iit[int_count].beg_effective_dt_tm =
     cnvtdatetime(i.beg_effective_dt_tm)
     IF (i.end_effective_dt_tm=null)
      bill_items->bi[d.seq].iit[int_count].end_effective_dt_tm = cnvtdatetime(
       "31 DEC 2100 23:59:59.99")
     ELSE
      bill_items->bi[d.seq].iit[int_count].end_effective_dt_tm = cnvtdatetime(i.end_effective_dt_tm)
     ENDIF
     bill_items->bi[d.seq].iit[int_count].price = i.price, bill_items->bi[d.seq].iit[int_count].
     interval_id = i.interval_id
     IF ((request->flat_ind=1))
      bill_items->bi[d.seq].iit[int_count].updated_price = (i.price+ request->flatchange)
     ELSE
      bill_items->bi[d.seq].iit[int_count].updated_price = (i.price+ (i.price * request->
      percentchange))
     ENDIF
     IF ((request->roundingdirection_ind=2))
      IF ((request->roundingamount_ind=1))
       bill_items->bi[d.seq].iit[int_count].updated_price = ceil(bill_items->bi[d.seq].iit[int_count]
        .updated_price)
      ELSEIF ((request->roundingamount_ind=2))
       hold_amount = (bill_items->bi[d.seq].iit[int_count].updated_price * 10), hold_amount = ceil(
        hold_amount), bill_items->bi[d.seq].iit[int_count].updated_price = (hold_amount/ 10)
      ELSE
       hold_amount = (bill_items->bi[d.seq].iit[int_count].updated_price * 100), hold_amount = ceil(
        hold_amount), bill_items->bi[d.seq].iit[int_count].updated_price = (hold_amount/ 100)
      ENDIF
     ELSEIF ((request->roundingdirection_ind=3))
      IF ((request->roundingamount_ind=1))
       bill_items->bi[d.seq].iit[int_count].updated_price = floor(bill_items->bi[d.seq].iit[int_count
        ].updated_price)
      ELSEIF ((request->roundingamount_ind=2))
       hold_amount = (bill_items->bi[d.seq].iit[int_count].updated_price * 10), hold_amount = floor(
        hold_amount), bill_items->bi[d.seq].iit[int_count].updated_price = (hold_amount/ 10)
      ELSE
       hold_amount = (bill_items->bi[d.seq].iit[int_count].updated_price * 100), hold_amount = floor(
        hold_amount), bill_items->bi[d.seq].iit[int_count].updated_price = (hold_amount/ 100)
      ENDIF
     ELSEIF ((request->roundingdirection_ind=4))
      IF ((request->roundingamount_ind=1))
       bill_items->bi[d.seq].iit[int_count].updated_price = round((bill_items->bi[d.seq].iit[
        int_count].updated_price+ 0.000001),0)
      ELSEIF ((request->roundingamount_ind=2))
       bill_items->bi[d.seq].iit[int_count].updated_price = round((bill_items->bi[d.seq].iit[
        int_count].updated_price+ 0.000001),1)
      ELSE
       bill_items->bi[d.seq].iit[int_count].updated_price = round((bill_items->bi[d.seq].iit[
        int_count].updated_price+ 0.000001),2)
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   FOR (count = 1 TO size(bill_items->bi,5))
     IF ((bill_items->bi[count].interval_template_cd > 0)
      AND (bill_items->bi[count].found_price_to_update=1)
      AND (bill_items->bi[count].interval_cdf="CODETEMPLATE"))
      FOR (count2 = 1 TO size(bill_items->bi[count].iit,5))
       SET bim_count = 0
       SELECT INTO "nl:"
        b.bill_item_mod_id
        FROM bill_item_modifier b
        WHERE (b.bill_item_id=bill_items->bi[count].bill_item_id)
         AND b.bill_item_type_cd=interval_cd
         AND (b.key2_id=bill_items->bi[count].iit[count2].item_interval_id)
         AND b.active_ind=1
        DETAIL
         bim_count = (bim_count+ 1), stat = alterlist(bill_items->bi[count].iit[count2].bim,bim_count
          ), bill_items->bi[count].iit[count2].bim[bim_count].bill_item_mod_id = b.bill_item_mod_id
        WITH nocounter
       ;end select
      ENDFOR
     ENDIF
   ENDFOR
   CALL echorecord(bill_items,"ccluserdir:afc_int.dat")
 END ;Subroutine
 SUBROUTINE get_iit_columns(i)
   CALL echo("Getting iit columns...")
   SELECT INTO "nl:"
    l.attr_name
    FROM dtable t,
     dtableattr a,
     dtableattrl l
    WHERE t.table_name="ITEM_INTERVAL_TABLE"
     AND t.table_name=a.table_name
     AND l.structtype="F"
     AND btest(l.stat,11)=0
     AND  NOT (l.attr_name IN ("ITEM_INTERVAL_ID", "ACTIVE_IND", "ACTIVE_STATUS_CD",
    "ACTIVE_STATUS_PRSNL_ID", "BEG_EFFECTIVE_DT_TM",
    "END_EFFECTIVE_DT_TM", "PARENT_ENTITY_ID", "PRICE", "UPDT_APPLCTX", "UPDT_CNT",
    "UPDT_DT_TM", "UPDT_ID", "UPDT_TASK"))
    DETAIL
     iit_col_count = (iit_col_count+ 1)
     IF (mod(iit_col_count,100)=1)
      stat = alter(iitcolumns->col,(iit_col_count+ 99))
     ENDIF
     iitcolumns->col[iit_col_count].col_name = l.attr_name
    WITH nocounter
   ;end select
   CALL echorecord(iitcolumns,"ccluserdir:afc_iit.dat")
   CALL echo(build("iit_col_count is: ",iit_col_count))
 END ;Subroutine
 SUBROUTINE get_bim_columns(j)
   CALL echo("Getting bim columns...")
   SELECT INTO "nl:"
    l.attr_name
    FROM dtable t,
     dtableattr a,
     dtableattrl l
    WHERE t.table_name="BILL_ITEM_MODIFIER"
     AND t.table_name=a.table_name
     AND l.structtype="F"
     AND btest(l.stat,11)=0
     AND  NOT (l.attr_name IN ("BILL_ITEM_MOD_ID", "ACTIVE_IND", "ACTIVE_STATUS_CD",
    "ACTIVE_STATUS_PRSNL_ID", "BEG_EFFECTIVE_DT_TM",
    "END_EFFECTIVE_DT_TM", "KEY2_ID", "UPDT_APPLCTX", "UPDT_CNT", "UPDT_DT_TM",
    "UPDT_ID", "UPDT_TASK"))
    DETAIL
     bim_col_count = (bim_col_count+ 1)
     IF (mod(bim_col_count,100)=1)
      stat = alter(bimcolumns->col,(bim_col_count+ 99))
     ENDIF
     bimcolumns->col[bim_col_count].col_name = l.attr_name
    WITH nocounter
   ;end select
   CALL echorecord(bimcolumns,"ccluserdir:afc_bim.dat")
   CALL echo(build("bim_col_count is: ",bim_col_count))
 END ;Subroutine
 SUBROUTINE copy_interval_prices(k)
  CALL echo("Copying interval prices...")
  FOR (count = 1 TO size(bill_items->bi,5))
    IF ((bill_items->bi[count].interval_template_cd > 0)
     AND (bill_items->bi[count].found_price_to_update=1))
     FOR (count2 = 1 TO size(bill_items->bi[count].iit,5))
       CALL echo(bill_items->bi[count].iit[count2].item_interval_id)
       CALL echo(bill_items->bi[count].iit[count2].interval_id)
       CALL echo("******")
       SET new_iit_id = 0.0
       SELECT INTO "nl:"
        iit_seq_num = seq(price_sched_seq,nextval)"##################;rp0"
        FROM dual
        DETAIL
         new_iit_id = cnvtreal(iit_seq_num)
        WITH format, counter
       ;end select
       CALL echo(build("New IIT ID: ",new_iit_id))
       SET bill_items->bi[count].iit[count2].new_interval_id = new_iit_id
       CALL parser("insert into item_interval_table (")
       FOR (x = 1 TO iit_col_count)
         CALL parser(concat(trim(iitcolumns->col[x].col_name),","))
       ENDFOR
       CALL parser("ITEM_INTERVAL_ID,ACTIVE_IND,ACTIVE_STATUS_CD,")
       CALL parser("ACTIVE_STATUS_PRSNL_ID,BEG_EFFECTIVE_DT_TM,END_EFFECTIVE_DT_TM,")
       CALL parser("PARENT_ENTITY_ID,PRICE,")
       CALL parser("UPDT_APPLCTX,UPDT_CNT,UPDT_DT_TM,UPDT_ID,UPDT_TASK)")
       CALL parser("(select ")
       FOR (x = 1 TO iit_col_count)
         CALL parser(concat("IIT.",trim(iitcolumns->col[x].col_name),", "))
       ENDFOR
       CALL parser("bill_items->bi[count]->iit[count2]->new_interval_id,")
       CALL parser("1,")
       CALL parser("ACTIVE_CD,")
       CALL parser("request->user,")
       CALL parser("cnvtdatetime(request->beg_effective_dt_tm),")
       CALL parser("cnvtdatetime(request->end_effective_dt_tm),")
       CALL parser("bill_items->bi[count]->new_psi,")
       IF ((request->interval_ind IN (1, 2)))
        CALL parser("bill_items->bi[count]->iit[count2]->updated_price,")
       ELSE
        CALL parser("bill_items->bi[count]->iit[count2]->price,")
       ENDIF
       CALL parser("0,")
       CALL parser("0,")
       CALL parser("cnvtdatetime(curdate, curtime3),")
       CALL parser("request->user,")
       CALL parser("951234")
       CALL parser("from item_interval_table iit ")
       CALL parser(build("where iit.item_interval_id = ",bill_items->bi[count].iit[count2].
         item_interval_id,")"))
       CALL parser("go")
       CALL echo("Now get bim columns...")
       FOR (count3 = 1 TO size(bill_items->bi[count].iit[count2].bim,5))
         CALL parser("insert into bill_item_modifier (")
         FOR (x = 1 TO bim_col_count)
           CALL parser(concat(trim(bimcolumns->col[x].col_name),","))
         ENDFOR
         CALL parser("BILL_ITEM_MOD_ID,ACTIVE_IND,ACTIVE_STATUS_CD,")
         CALL parser("ACTIVE_STATUS_PRSNL_ID,BEG_EFFECTIVE_DT_TM,END_EFFECTIVE_DT_TM,")
         CALL parser("KEY2_ID,")
         CALL parser("UPDT_APPLCTX,UPDT_CNT,UPDT_DT_TM,UPDT_ID,UPDT_TASK)")
         CALL parser("(select ")
         FOR (x = 1 TO bim_col_count)
           CALL parser(concat("BIM.",trim(bimcolumns->col[x].col_name),", "))
         ENDFOR
         CALL parser("cnvtreal(seq(BILL_ITEM_SEQ, nextval)),")
         CALL parser("1,")
         CALL parser("ACTIVE_CD,")
         CALL parser("request->user,")
         CALL parser("cnvtdatetime(request->beg_effective_dt_tm),")
         CALL parser("cnvtdatetime(request->end_effective_dt_tm),")
         CALL parser("bill_items->bi[count]->iit[count2]->new_interval_id,")
         CALL parser("0,")
         CALL parser("0,")
         CALL parser("cnvtdatetime(curdate, curtime3),")
         CALL parser("request->user,")
         CALL parser("951234")
         CALL parser("from bill_item_modifier bim ")
         CALL parser(build("where bim.bill_item_mod_id = ",bill_items->bi[count].iit[count2].bim[
           count3].bill_item_mod_id,")"))
         CALL parser("go")
       ENDFOR
     ENDFOR
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE create_report(l)
   CALL echo("Creating reports...")
   SET first_time = 1
   SET no_prices = 0
   SELECT
    desc = bill_items->bi[d.seq].ext_description, bill_item_id = bill_items->bi[d.seq].bill_item_id,
    price_sched = request->to_price_sched_id,
    price_as_of = bill_items->bi[d.seq].price_as_of, updated_price = bill_items->bi[d.seq].
    updated_price_as_of, req_beg_date = cnvtdatetime(request->beg_effective_dt_tm),
    req_end_date = cnvtdatetime(request->end_effective_dt_tm), price_size = size(bill_items->bi[d.seq
     ].prices,5)
    FROM (dummyt d  WITH seq = value(size(bill_items->bi,5)))
    PLAN (d
     WHERE (bill_items->bi[d.seq].interval_template_cd=0)
      AND ((bill_items->bi[d.seq].found_price_to_update) OR ((request->setzero_ind=1))) )
    ORDER BY desc, bill_item_id
    HEAD REPORT
     line = fillstring(130,"=")
     IF ((request->setzero_ind=1))
      col 0, "Price Maintenance Preview of Zero Prices"
     ELSE
      col 0, "Price Maintenance Preview of Non Interval Prices"
     ENDIF
     col 100, curdate"MMM-DD-YYYY;;D", col 112,
     curtime"HH:MM:SS;;M", row + 1, col 0,
     line, row + 1, col 0,
     "Action", col 12, "Bill Item",
     col 40, "Bill Item Id", col 55,
     "Price Sched", col 71, "Price",
     col 82, "Begin Effective Date", col 104,
     "End Effective Date", row + 1, col 0,
     line, row + 1
    HEAD bill_item_id
     IF (first_time != 1)
      row + 1
     ENDIF
     first_time = 0, col 0, "ADD"
     IF (desc=" ")
      col 12, "<BLANK DESCRIPTION>"
     ELSE
      col 12, desc"#################################"
     ENDIF
     col 40, bill_item_id, col 55,
     request->to_price_sched_desc"##############", col 71, updated_price"$#####.##",
     col 82, req_beg_date"MM/DD/YYYY HH:MM:SS;;D", col 104,
     req_end_date"MM/DD/YYYY HH:MM:SS;;D", row + 1
    DETAIL
     no_prices = 1
     FOR (i = 1 TO size(bill_items->bi[d.seq].prices,5))
       IF ((bill_items->bi[d.seq].prices[i].inactivate_ind=1))
        col 0, "INACTIVATE"
       ELSE
        col 0, "UPDATE"
       ENDIF
       IF (desc=" ")
        col 12, "<BLANK DESCRIPTION>"
       ELSE
        col 12, desc"#################################"
       ENDIF
       col 40, bill_item_id, col 55,
       request->to_price_sched_desc"##############", col 71, bill_items->bi[d.seq].prices[i].price
       "$#####.##",
       col 82, bill_items->bi[d.seq].prices[i].beg_effective_dt_tm"MM/DD/YYYY HH:MM:SS;;D", col 104,
       bill_items->bi[d.seq].prices[i].end_effective_dt_tm"MM/DD/YYYY HH:MM:SS;;D", row + 1,
       no_prices = 0
     ENDFOR
    WITH nocounter, outerjoin = d2
   ;end select
 END ;Subroutine
 SUBROUTINE create_interval_report(m)
   SET first_time = 1
   SET no_prices = 0
   SELECT
    desc = bill_items->bi[d.seq].ext_description, bill_item_id = bill_items->bi[d.seq].bill_item_id,
    price_sched = request->to_price_sched_id,
    price_as_of = bill_items->bi[d.seq].price_as_of, req_beg_date = cnvtdatetime(request->
     beg_effective_dt_tm), req_end_date = cnvtdatetime(request->end_effective_dt_tm),
    iit_size = size(bill_items->bi[d.seq].iit,5)
    FROM (dummyt d  WITH seq = value(size(bill_items->bi,5)))
    PLAN (d
     WHERE (bill_items->bi[d.seq].interval_template_cd != 0))
    ORDER BY desc, bill_item_id
    HEAD REPORT
     line = fillstring(130,"="), col 0, "Price Maintenance Preview of New Interval Prices",
     col 100, curdate"MMM-DD-YYYY;;D", col 112,
     curtime"HH:MM:SS;;M", row + 1, col 0,
     line, row + 1, col 0,
     "Action", col 5, "Bill Item",
     col 25, "Price Sched", col 40,
     "Interval", col 55, "Beg Value",
     col 65, "End Value", col 75,
     "Price", col 85, "Begin Effective Date",
     col 107, "End Effective Date", row + 1,
     col 0, line, row + 1
    HEAD bill_item_id
     IF (first_time != 1)
      row + 1
     ENDIF
     first_time = 0
    DETAIL
     FOR (i = 1 TO size(bill_items->bi[d.seq].iit,5))
       col 0, "ADD"
       IF (desc=" ")
        col 5, "<BLANK DESCRIPTION>"
       ELSE
        col 5, desc"####################"
       ENDIF
       col 25, request->to_price_sched_desc"#############", col 40,
       bill_items->bi[d.seq].interval_display"##############", col 55, bill_items->bi[d.seq].iit[i].
       beg_value"#####",
       col 65, bill_items->bi[d.seq].iit[i].end_value"#####", col 75,
       bill_items->bi[d.seq].iit[i].updated_price"$#####.##", col 85, request->beg_effective_dt_tm
       "MM/DD/YYYY HH:MM:SS;;D",
       col 107, request->end_effective_dt_tm"MM/DD/YYYY HH:MM:SS;;D", row + 1
     ENDFOR
    WITH nocounter
   ;end select
   IF (found_update=1)
    SET first_time = 1
    SET no_prices = 0
    SELECT
     desc = bill_items->bi[d.seq].ext_description, bill_item_id = bill_items->bi[d.seq].bill_item_id,
     price_sched = request->to_price_sched_id,
     price_as_of = bill_items->bi[d.seq].price_as_of, req_beg_date = cnvtdatetime(request->
      beg_effective_dt_tm), req_end_date = cnvtdatetime(request->end_effective_dt_tm),
     iit_size = size(bill_items->bi[d.seq].iit,5)
     FROM (dummyt d  WITH seq = value(size(bill_items->bi,5)))
     PLAN (d
      WHERE (bill_items->bi[d.seq].interval_template_cd != 0))
     ORDER BY desc, bill_item_id
     HEAD REPORT
      line = fillstring(130,"="), col 0, "Price Maintenance Preview of Updated Interval Prices",
      col 100, curdate"MMM-DD-YYYY;;D", col 112,
      curtime"HH:MM:SS;;M", row + 1, col 0,
      line, row + 1, col 0,
      "Action", col 12, "Bill Item",
      col 32, "Price Sched", col 50,
      "Interval", col 75, "New Begin Effective Date",
      col 102, "New End Effective Date", row + 1,
      col 0, line, row + 1
     HEAD bill_item_id
      IF (first_time != 1)
       row + 1
      ENDIF
      first_time = 0
     DETAIL
      FOR (j = 1 TO size(bill_items->bi[d.seq].prices,5))
        IF ((bill_items->bi[d.seq].prices[j].inactivate_ind=1))
         col 0, "INACTIVATE"
        ELSE
         col 0, "UPDATE"
        ENDIF
        IF (desc=" ")
         col 12, "<BLANK DESCRIPTION>"
        ELSE
         col 12, desc"####################"
        ENDIF
        col 32, request->to_price_sched_desc"###############", col 50,
        bill_items->bi[d.seq].interval_display"##################", col 75, bill_items->bi[d.seq].
        prices[j].beg_effective_dt_tm"MM/DD/YYYY HH:MM:SS;;D",
        col 102, bill_items->bi[d.seq].prices[j].end_effective_dt_tm"MM/DD/YYYY HH:MM:SS;;D", row + 1
      ENDFOR
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 FREE SET billitems
 FREE SET psicolumns
 FREE SET iitcolumns
 FREE SET bimcolumns
 FREE SET psirequest
END GO
