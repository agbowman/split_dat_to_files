CREATE PROGRAM afc_import_bill_items:dba
 FREE SET psirequest
 RECORD psirequest(
   1 price_sched_items_qual = i2
   1 price_sched_items[*]
     2 action_type = c3
     2 price_sched_id = f8
     2 bill_item_id = f8
     2 price_sched_items_id = f8
     2 price_ind = i2
     2 price = f8
     2 allowable = f8
     2 percent_revenue = i4
     2 charge_level_cd = f8
     2 interval_template_cd = f8
     2 detail_charge_ind_ind = i2
     2 detail_charge_ind = i2
     2 exclusive_ind_ind = i2
     2 exclusive_ind = i2
     2 tax = f8
     2 cost_adj_amt = f8
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 end_effective_dt_tm_ind = i2
     2 updt_cnt = i2
     2 units_ind = i2
     2 units_ind_ind = i2
     2 stats_only_ind_ind = i2
     2 stats_only_ind = i2
     2 capitation_ind = i2
     2 referral_req_ind = i2
     2 billing_discount_priority = i4
 )
 FREE SET bimrequest
 RECORD bimrequest(
   1 bill_item_modifier_qual = i2
   1 bill_item_modifier[*]
     2 action_type = c3
     2 bill_item_mod_id = f8
     2 bill_item_id = f8
     2 bill_item_type_cd = f8
     2 key1_id = f8
     2 key2_id = f8
     2 key3_id = f8
     2 key4_id = f8
     2 key5_id = f8
     2 key11_id = f8
     2 key12_id = f8
     2 key13_id = f8
     2 key14_id = f8
     2 key15_id = f8
     2 key6 = vc
     2 key7 = vc
     2 key8 = vc
     2 key9 = vc
     2 key10 = vc
     2 key11 = vc
     2 key12 = vc
     2 key13 = vc
     2 key14 = vc
     2 key15 = vc
     2 bim1_int = f8
     2 bim2_int = f8
     2 bim_ind = i2
     2 bim1_ind = i2
     2 bim1_nbr = f8
     2 key15 = vc
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
 )
 IF ( NOT (validate(rejects)))
  FREE SET rejects
  RECORD rejects(
    1 errors[*]
      2 ext_description = c50
      2 price = c10
      2 price_sched = c25
      2 bill_code = c40
      2 bill_code_sched = c25
      2 message = c100
  )
 ELSE
  SET stat = initrec(rejects)
 ENDIF
 IF ( NOT (validate(reply)))
  FREE SET reply
  RECORD reply(
    1 price_sched_items_qual = i2
    1 price_sched_items[*]
      2 price_sched_id = f8
      2 price_sched_items_id = f8
    1 bill_item_modifier_qual = i2
    1 bill_item_modifier[1]
      2 bill_item_mod_id = f8
    1 item_interval_qual = i2
    1 item_interval[1]
      2 item_interval_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ELSE
  SET stat = initrec(reply)
 ENDIF
 IF ( NOT (validate(intervaldata)))
  FREE SET intervaldata
  RECORD intervaldata(
    1 list[*]
      2 bill_item_id = vc
      2 price_sched = vc
      2 interval_template = vc
      2 valid = i2
      2 processed = i2
      2 invalidreason = vc
      2 price_sched_items_id_string = vc
      2 price_sched_items_id = f8
      2 interval_template_cd = f8
      2 beg_effective_dt_tm = vc
      2 end_effective_dt_tm = vc
      2 intervalranges[*]
        3 rangebegin = f8
        3 rangeend = f8
        3 interval_id = f8
        3 interval_range_found = i2
  )
 ELSE
  SET stat = initrec(intervaldata)
 ENDIF
 IF ( NOT (validate(priceintervalrequest)))
  FREE SET priceintervalrequest
  RECORD priceintervalrequest(
    1 item_interval_qual = i2
    1 item_interval[*]
      2 action_type = c3
      2 upt_flg = i2
      2 interval_id = f8
      2 item_interval_id = f8
      2 interval_template_cd = f8
      2 parent_entity_id = f8
      2 parent_entity_name = vc
      2 price = f8
      2 units = f8
  )
 ELSE
  SET stat = initrec(priceintervalrequest)
 ENDIF
 DECLARE equal_line = vc
 DECLARE file_name = vc
 DECLARE code_list[1] = f8
 DECLARE total_remaining = i4
 DECLARE start_index = i4
 DECLARE occurances = i4
 DECLARE display = c40
 DECLARE cnt = i4
 DECLARE codeset = i4
 DECLARE cdf_meaning = c12
 DECLARE bill_code_cd = f8
 SET codeset = 13019
 SET cdf_meaning = "BILL CODE"
 SET cnt = 1
 DECLARE dbillcodeschedcd = f8
 DECLARE dreqpricebegeffdttm = dq8
 DECLARE dreqpriceendeffdttm = dq8
 DECLARE dreqbillbegeffdttm = dq8
 DECLARE dreqbillendeffdttm = dq8
 DECLARE dpricebegeffdttm = dq8
 DECLARE dpriceendeffdttm = dq8
 DECLARE dbillitemendeffdttm = dq8
 DECLARE dbillitembegeffdttm = dq8
 DECLARE dpricescheditemsid = f8
 DECLARE dbillitemmodifierid = f8
 DECLARE intervalpos = i4 WITH protect, noconstant(0)
 DECLARE intervalrangepos = i4 WITH protect, noconstant(0)
 DECLARE intervalidx = i4 WITH protect, noconstant(0)
 DECLARE intervalrangeidx = i4 WITH protect, noconstant(0)
 DECLARE tempitemintervalid = f8 WITH protect, noconstant(0)
 DECLARE dintervaltemplatecd = f8 WITH protect, noconstant(0)
 DECLARE ipos = i4
 DECLARE iplace = i4
 DECLARE iindex = i4
 DECLARE icount = i4
 DECLARE bupdpricesched = i2
 DECLARE bupdbillcode = i2
 DECLARE dprice = f8
 DECLARE sbillcodedesc = vc
 DECLARE sbillcode = vc
 DECLARE baddpricesched = i2
 DECLARE baddbillcodesched = i2
 DECLARE s_price_sched_items = vc WITH protect, constant("PRICE_SCHED_ITEMS")
 IF ( NOT (validate(num_rejects)))
  DECLARE num_rejects = i4
 ENDIF
 IF ( NOT (validate(action_begin)))
  DECLARE action_begin = i4
 ENDIF
 IF ( NOT (validate(action_end)))
  DECLARE action_end = i4
 ENDIF
 IF ( NOT (validate(price_sched_id)))
  DECLARE price_sched_id = i4
 ENDIF
 IF ( NOT (validate(cs_14274)))
  DECLARE cs_14274 = i4 WITH constant(14274)
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=13019
   AND cv.cdf_meaning="BILL CODE"
   AND cv.active_ind=1
  DETAIL
   bill_code_cd = cv.code_value
  WITH maxqual(cv,1), nocounter
 ;end select
 CALL echo(build("the bill code code value is: ",bill_code_cd))
 CALL echo(build("the list size is: ",value(size(requestin->list_0,5))))
 SET num_rejects = 0
 SELECT INTO "nl:"
  FROM bill_item b,
   (dummyt d1  WITH seq = value(size(requestin->list_0,5)))
  PLAN (d1)
   JOIN (b
   WHERE b.bill_item_id=cnvtreal(requestin->list_0[d1.seq].bill_item_id)
    AND b.ext_parent_reference_id=cnvtreal(requestin->list_0[d1.seq].parent_ref_id)
    AND b.ext_child_reference_id=cnvtreal(requestin->list_0[d1.seq].child_ref_id)
    AND b.active_ind=1)
  DETAIL
   IF (b.bill_item_id=0)
    requestin->list_0[d1.seq].bill_item_id = "0", num_rejects += 1, stat = alterlist(rejects->errors,
     num_rejects),
    rejects->errors[num_rejects].ext_description = trim(requestin->list_0[d1.seq].description),
    rejects->errors[num_rejects].price = trim(requestin->list_0[d1.seq].price), rejects->errors[
    num_rejects].price_sched = trim(requestin->list_0[d1.seq].price_sched),
    rejects->errors[num_rejects].bill_code = trim(requestin->list_0[d1.seq].bill_code), rejects->
    errors[num_rejects].bill_code_sched = trim(requestin->list_0[d1.seq].bill_code_sched), rejects->
    errors[num_rejects].message = "No bill item match found."
   ENDIF
  WITH nocounter, outerjoin = d1
 ;end select
 CALL validateintervalrows(0)
 SET action_begin = 1
 SET action_end = 1
 FOR (i = 1 TO value(size(requestin->list_0,5)))
   SET reply->status_data.status = "F"
   SET intervalpos = 0
   IF (cnvtreal(requestin->list_0[i].bill_item_id) != 0)
    IF ((requestin->list_0[i].price_sched != ""))
     SET price_sched_id = 0.0
     SET dpricescheditemsid = 0.0
     SET dintervaltemplatecd = 0.0
     CALL echo(build("Price Sched Desc: ",requestin->list_0[i].price_sched))
     SELECT INTO "nl:"
      FROM price_sched p
      WHERE (p.price_sched_desc=requestin->list_0[i].price_sched)
      DETAIL
       price_sched_id = p.price_sched_id
      WITH nocounter
     ;end select
     IF (price_sched_id != 0)
      IF (cnvtreal(requestin->list_0[i].price_sched_items_id)=0)
       CALL echo(build("Price Sched Item ID(ADD): ",requestin->list_0[i].price_sched_items_id))
       SET stat = alterlist(psirequest->price_sched_items,1)
       SET psirequest->price_sched_items_qual = 1
       SET psirequest->price_sched_items[1].price_sched_id = price_sched_id
       SET psirequest->price_sched_items[1].detail_charge_ind = 1
       SET psirequest->price_sched_items[1].detail_charge_ind_ind = 1
       SET psirequest->price_sched_items[1].bill_item_id = cnvtreal(requestin->list_0[i].bill_item_id
        )
       SET dreqpricebegeffdttm = cnvtdatetime(cnvtdate2(getdates(requestin->list_0[i].
          price_beg_effective_dt_tm),"MM/DD/YYYY"),cnvttime2(substring(12,8,getdates(requestin->
           list_0[i].price_beg_effective_dt_tm)),"HH:MM:SS"))
       IF (dreqpricebegeffdttm <= 0.0)
        SET dreqpricebegeffdttm = cnvtdatetime(sysdate)
       ENDIF
       SET dreqpriceendeffdttm = cnvtdatetime(cnvtdate2(getdates(requestin->list_0[i].
          price_end_effective_dt_tm),"MM/DD/YYYY"),cnvttime2(substring(12,8,getdates(requestin->
           list_0[i].price_end_effective_dt_tm)),"HH:MM:SS"))
       IF (dreqpriceendeffdttm <= 0.0)
        SET dreqpriceendeffdttm = cnvtdatetime("31-DEC-2100 23:59:59")
       ENDIF
       SELECT INTO "nl:"
        FROM price_sched_items ps,
         price_sched p
        PLAN (ps
         WHERE ps.bill_item_id=cnvtreal(requestin->list_0[i].bill_item_id)
          AND ps.active_ind=1)
         JOIN (p
         WHERE p.price_sched_id=ps.price_sched_id
          AND (p.price_sched_desc=requestin->list_0[i].price_sched)
          AND p.active_ind=1)
        ORDER BY ps.end_effective_dt_tm DESC
        DETAIL
         dpricescheditemsid = ps.price_sched_items_id, dprice = ps.price, dpricebegeffdttm =
         cnvtdatetime(ps.beg_effective_dt_tm),
         dpriceendeffdttm = cnvtdatetime(ps.end_effective_dt_tm), dintervaltemplatecd = ps
         .interval_template_cd
        WITH nocounter, maxrec = 1
       ;end select
       SET bupdpricesched = false
       SET baddpricesched = false
       IF (validate(requestin->list_0[i].interval_template)
        AND textlen(trim(validate(requestin->list_0[i].interval_template,""))) > 0)
        SET intervalpos = locatevalsort(intervalidx,1,size(intervaldata->list,5),requestin->list_0[i]
         .bill_item_id,intervaldata->list[intervalidx].bill_item_id,
         requestin->list_0[i].price_sched,intervaldata->list[intervalidx].price_sched,requestin->
         list_0[i].interval_template,intervaldata->list[intervalidx].interval_template,requestin->
         list_0[i].price_beg_effective_dt_tm,
         intervaldata->list[intervalidx].beg_effective_dt_tm,requestin->list_0[i].
         price_end_effective_dt_tm,intervaldata->list[intervalidx].end_effective_dt_tm)
       ENDIF
       IF (((intervalpos=0) OR (intervalpos > 0
        AND (intervaldata->list[intervalpos].price_sched_items_id=0))) )
        CALL echo("Executing afc_add_price_sched_item")
        IF (curqual > 0)
         SET ipos = 0
         SET iindex = 0
         SET ipos = locateval(iindex,1,size(requestin->list_0,5),dpricescheditemsid,cnvtreal(
           requestin->list_0[iindex].price_sched_items_id))
         IF (ipos=0)
          SET bupdpricesched = true
          SET baddpricesched = true
         ELSE
          IF (dreqpricebegeffdttm > dpriceendeffdttm
           AND dreqpricebegeffdttm < dreqpriceendeffdttm)
           SET baddpricesched = true
          ENDIF
         ENDIF
        ELSE
         SET baddpricesched = true
        ENDIF
       ENDIF
       IF (bupdpricesched=true)
        SET stat = alterlist(psirequest->price_sched_items,1)
        SET psirequest->price_sched_items_qual = 1
        SET psirequest->price_sched_items[1].action_type = "UPT"
        SET psirequest->price_sched_items[1].price_sched_items_id = dpricescheditemsid
        SET psirequest->price_sched_items[1].interval_template_cd = dintervaltemplatecd
        SET psirequest->price_sched_items[1].price = dprice
        SET psirequest->price_sched_items[1].beg_effective_dt_tm = cnvtdatetime(dpricebegeffdttm)
        IF (dreqpricebegeffdttm <= dpriceendeffdttm)
         SET psirequest->price_sched_items[1].end_effective_dt_tm = cnvtlookbehind("1, S",
          dreqpricebegeffdttm)
        ELSE
         SET psirequest->price_sched_items[1].end_effective_dt_tm = dpriceendeffdttm
        ENDIF
        SET action_begin = 1
        SET action_end = 1
        CALL echo("Executing afc_upt_price_sched_item")
        IF ((psirequest->price_sched_items[1].end_effective_dt_tm > dpricebegeffdttm))
         EXECUTE afc_upt_price_sched_item  WITH replace(request,psirequest)
         IF ((reply->status_data.status="F"))
          SET num_rejects += 1
          SET stat = alterlist(rejects->errors,num_rejects)
          SET rejects->errors[num_rejects].ext_description = trim(requestin->list_0[i].description)
          SET rejects->errors[num_rejects].price = trim(requestin->list_0[i].price)
          SET rejects->errors[num_rejects].price_sched = trim(requestin->list_0[i].price_sched)
          SET rejects->errors[num_rejects].bill_code = trim(requestin->list_0[i].bill_code)
          SET rejects->errors[num_rejects].bill_code_sched = trim(requestin->list_0[i].
           bill_code_sched)
          SET rejects->errors[num_rejects].message = "Error in afc_upt_price_sched_item."
         ENDIF
        ENDIF
       ENDIF
       SET action_begin = 1
       SET action_end = 1
       SET psirequest->price_sched_items[1].action_type = "ADD"
       SET psirequest->price_sched_items[1].price_sched_items_id = 0.0
       IF (intervalpos > 0)
        SET psirequest->price_sched_items[1].interval_template_cd = intervaldata->list[intervalpos].
        interval_template_cd
        SET psirequest->price_sched_items[1].price = 0
        IF (cnvtreal(requestin->list_0[i].price_sched_items_id) > 0)
         SET intervaldata->list[intervalpos].price_sched_items_id = cnvtreal(requestin->list_0[i].
          price_sched_items_id)
        ENDIF
       ELSE
        SET psirequest->price_sched_items[1].price = cnvtreal(requestin->list_0[i].price)
       ENDIF
       SET psirequest->price_sched_items[1].beg_effective_dt_tm = dreqpricebegeffdttm
       SET psirequest->price_sched_items[1].end_effective_dt_tm = dreqpriceendeffdttm
       IF (baddpricesched=true
        AND dreqpricebegeffdttm < dreqpriceendeffdttm)
        EXECUTE afc_add_price_sched_item  WITH replace(request,psirequest)
        IF ((reply->status_data.status="F"))
         SET num_rejects += 1
         SET stat = alterlist(rejects->errors,num_rejects)
         SET rejects->errors[num_rejects].ext_description = trim(requestin->list_0[i].description)
         SET rejects->errors[num_rejects].price = trim(requestin->list_0[i].price)
         SET rejects->errors[num_rejects].price_sched = trim(requestin->list_0[i].price_sched)
         SET rejects->errors[num_rejects].bill_code = trim(requestin->list_0[i].bill_code)
         SET rejects->errors[num_rejects].bill_code_sched = trim(requestin->list_0[i].bill_code_sched
          )
         SET rejects->errors[num_rejects].message = "Error in afc_add_price_sched_item."
        ELSEIF (validate(requestin->list_0[i].interval_template)
         AND intervalpos > 0
         AND size(reply->price_sched_items,5)=1)
         SET intervaldata->list[intervalpos].price_sched_items_id = reply->price_sched_items[1].
         price_sched_items_id
        ENDIF
       ENDIF
      ELSE
       CALL echo(build("Price Sched Item ID(UPDATE): ",requestin->list_0[i].price_sched_items_id))
       SET stat = alterlist(psirequest->price_sched_items,1)
       SET psirequest->price_sched_items_qual = 1
       SET psirequest->price_sched_items[1].action_type = "UPT"
       SET psirequest->price_sched_items[1].price_sched_items_id = cnvtreal(requestin->list_0[i].
        price_sched_items_id)
       SET psirequest->price_sched_items[1].price_sched_id = price_sched_id
       SET psirequest->price_sched_items[1].detail_charge_ind = 1
       SET psirequest->price_sched_items[1].detail_charge_ind_ind = 1
       SET psirequest->price_sched_items[1].bill_item_id = cnvtreal(requestin->list_0[i].bill_item_id
        )
       SET psirequest->price_sched_items[1].price = cnvtreal(requestin->list_0[i].price)
       SET psirequest->price_sched_items[1].beg_effective_dt_tm = cnvtdatetime(cnvtdate2(getdates(
          requestin->list_0[i].price_beg_effective_dt_tm),"MM/DD/YYYY"),cnvttime2(substring(12,8,
          getdates(requestin->list_0[i].price_beg_effective_dt_tm)),"HH:MM:SS"))
       IF ((psirequest->price_sched_items[1].beg_effective_dt_tm <= 0.0))
        SET psirequest->price_sched_items[1].beg_effective_dt_tm = cnvtdatetime(sysdate)
       ENDIF
       SET psirequest->price_sched_items[1].end_effective_dt_tm = cnvtdatetime(cnvtdate2(getdates(
          requestin->list_0[i].price_end_effective_dt_tm),"MM/DD/YYYY"),cnvttime2(substring(12,8,
          getdates(requestin->list_0[i].price_end_effective_dt_tm)),"HH:MM:SS"))
       IF ((psirequest->price_sched_items[1].end_effective_dt_tm <= 0.0))
        SET psirequest->price_sched_items[1].end_effective_dt_tm = cnvtdatetime(
         "31-DEC-2100 23:59:59")
       ENDIF
       IF (validate(requestin->list_0[i].interval_template)
        AND textlen(trim(validate(requestin->list_0[i].interval_template,""),3)) > 0)
        SET intervalpos = locatevalsort(intervalidx,1,size(intervaldata->list,5),requestin->list_0[i]
         .bill_item_id,intervaldata->list[intervalidx].bill_item_id,
         requestin->list_0[i].price_sched,intervaldata->list[intervalidx].price_sched,requestin->
         list_0[i].interval_template,intervaldata->list[intervalidx].interval_template,requestin->
         list_0[i].price_beg_effective_dt_tm,
         intervaldata->list[intervalidx].beg_effective_dt_tm,requestin->list_0[i].
         price_end_effective_dt_tm,intervaldata->list[intervalidx].end_effective_dt_tm)
        IF (intervalpos > 0)
         SET psirequest->price_sched_items[1].interval_template_cd = intervaldata->list[intervalpos].
         interval_template_cd
         SET psirequest->price_sched_items[1].price = 0
         IF (cnvtreal(requestin->list_0[i].price_sched_items_id) > 0)
          SET intervaldata->list[intervalpos].price_sched_items_id = cnvtreal(requestin->list_0[i].
           price_sched_items_id)
         ENDIF
        ENDIF
       ENDIF
       SET action_begin = 1
       SET action_end = 1
       CALL echo("Executing afc_upt_price_sched_item")
       EXECUTE afc_upt_price_sched_item  WITH replace(request,psirequest)
       IF ((reply->status_data.status="F"))
        SET num_rejects += 1
        SET stat = alterlist(rejects->errors,num_rejects)
        SET rejects->errors[num_rejects].ext_description = trim(requestin->list_0[i].description)
        SET rejects->errors[num_rejects].price = trim(requestin->list_0[i].price)
        SET rejects->errors[num_rejects].price_sched = trim(requestin->list_0[i].price_sched)
        SET rejects->errors[num_rejects].bill_code = trim(requestin->list_0[i].bill_code)
        SET rejects->errors[num_rejects].bill_code_sched = trim(requestin->list_0[i].bill_code_sched)
        SET rejects->errors[num_rejects].message = "Error in afc_upt_price_sched_item."
       ENDIF
      ENDIF
     ELSE
      SET num_rejects += 1
      SET stat = alterlist(rejects->errors,num_rejects)
      SET rejects->errors[num_rejects].ext_description = trim(requestin->list_0[i].description)
      SET rejects->errors[num_rejects].price = trim(requestin->list_0[i].price)
      SET rejects->errors[num_rejects].price_sched = trim(requestin->list_0[i].price_sched)
      SET rejects->errors[num_rejects].bill_code = trim(requestin->list_0[i].bill_code)
      SET rejects->errors[num_rejects].bill_code_sched = trim(requestin->list_0[i].bill_code_sched)
      SET rejects->errors[num_rejects].message = "Price schedule did not match description on table."
     ENDIF
     SET tempitemintervalid = 0
     IF (validate(requestin->list_0[i].interval_template)
      AND intervalpos > 0
      AND (intervaldata->list[intervalpos].price_sched_items_id > 0))
      SET intervalrangepos = locateval(intervalrangeidx,1,size(intervaldata->list[intervalpos].
        intervalranges,5),cnvtreal(requestin->list_0[i].interval_begin),intervaldata->list[
       intervalpos].intervalranges[intervalrangeidx].rangebegin,
       cnvtreal(requestin->list_0[i].interval_end),intervaldata->list[intervalpos].intervalranges[
       intervalrangeidx].rangeend)
      IF (intervalrangepos > 0)
       SELECT INTO "nl:"
        FROM item_interval_table iit
        PLAN (iit
         WHERE iit.active_ind=1
          AND (iit.interval_id=intervaldata->list[intervalpos].intervalranges[intervalrangepos].
         interval_id)
          AND (iit.parent_entity_id=intervaldata->list[intervalpos].price_sched_items_id)
          AND iit.parent_entity_name=s_price_sched_items)
        HEAD REPORT
         tempitemintervalid = iit.item_interval_id
        WITH nocounter
       ;end select
       SET stat = initrec(priceintervalrequest)
       IF (tempitemintervalid > 0)
        SET priceintervalrequest->item_interval_qual = 1
        SET stat = alterlist(priceintervalrequest->item_interval,1)
        SET priceintervalrequest->item_interval[1].action_type = "UPT"
        SET priceintervalrequest->item_interval[1].interval_id = intervaldata->list[intervalpos].
        intervalranges[intervalrangepos].interval_id
        SET priceintervalrequest->item_interval[1].item_interval_id = tempitemintervalid
        SET priceintervalrequest->item_interval[1].interval_template_cd = intervaldata->list[
        intervalpos].interval_template_cd
        SET priceintervalrequest->item_interval[1].parent_entity_id = intervaldata->list[intervalpos]
        .price_sched_items_id
        SET priceintervalrequest->item_interval[1].parent_entity_name = s_price_sched_items
        SET priceintervalrequest->item_interval[1].price = cnvtreal(requestin->list_0[i].price)
        SET priceintervalrequest->item_interval[1].units = 0.0
        CALL echo("Executing afc_upt_price_sched_interval")
        EXECUTE afc_upt_price_sched_interval  WITH replace(request,priceintervalrequest)
        IF ((reply->status_data.status="F"))
         SET num_rejects += 1
         SET stat = alterlist(rejects->errors,num_rejects)
         SET rejects->errors[num_rejects].ext_description = trim(requestin->list_0[i].description)
         SET rejects->errors[num_rejects].price = trim(requestin->list_0[i].price)
         SET rejects->errors[num_rejects].price_sched = trim(requestin->list_0[i].price_sched)
         SET rejects->errors[num_rejects].bill_code = trim(requestin->list_0[i].bill_code)
         SET rejects->errors[num_rejects].bill_code_sched = trim(requestin->list_0[i].bill_code_sched
          )
         SET rejects->errors[num_rejects].message = "Error in afc_upt_price_sched_interval."
        ENDIF
       ELSE
        SET priceintervalrequest->item_interval_qual = 1
        SET stat = alterlist(priceintervalrequest->item_interval,1)
        SET priceintervalrequest->item_interval[1].action_type = "ADD"
        SET priceintervalrequest->item_interval[1].interval_id = intervaldata->list[intervalpos].
        intervalranges[intervalrangepos].interval_id
        SET priceintervalrequest->item_interval[1].item_interval_id = 0.0
        SET priceintervalrequest->item_interval[1].interval_template_cd = intervaldata->list[
        intervalpos].interval_template_cd
        SET priceintervalrequest->item_interval[1].parent_entity_id = intervaldata->list[intervalpos]
        .price_sched_items_id
        SET priceintervalrequest->item_interval[1].parent_entity_name = s_price_sched_items
        SET priceintervalrequest->item_interval[1].price = cnvtreal(requestin->list_0[i].price)
        SET priceintervalrequest->item_interval[1].units = 0.0
        CALL echo("Executing afc_add_price_sched_interval")
        EXECUTE afc_add_price_sched_interval  WITH replace(request,priceintervalrequest)
        IF ((reply->status_data.status="F"))
         SET num_rejects += 1
         SET stat = alterlist(rejects->errors,num_rejects)
         SET rejects->errors[num_rejects].ext_description = trim(requestin->list_0[i].description)
         SET rejects->errors[num_rejects].price = trim(requestin->list_0[i].price)
         SET rejects->errors[num_rejects].price_sched = trim(requestin->list_0[i].price_sched)
         SET rejects->errors[num_rejects].bill_code = trim(requestin->list_0[i].bill_code)
         SET rejects->errors[num_rejects].bill_code_sched = trim(requestin->list_0[i].bill_code_sched
          )
         SET rejects->errors[num_rejects].message = "Error in afc_add_price_sched_interval."
        ENDIF
       ENDIF
      ELSE
       SET num_rejects += 1
       SET stat = alterlist(rejects->errors,num_rejects)
       SET rejects->errors[num_rejects].ext_description = trim(requestin->list_0[i].description)
       SET rejects->errors[num_rejects].price = trim(requestin->list_0[i].price)
       SET rejects->errors[num_rejects].price_sched = trim(requestin->list_0[i].price_sched)
       SET rejects->errors[num_rejects].bill_code = trim(requestin->list_0[i].bill_code)
       SET rejects->errors[num_rejects].bill_code_sched = trim(requestin->list_0[i].bill_code_sched)
       SET rejects->errors[num_rejects].message = "Error processing interval data."
      ENDIF
     ENDIF
    ENDIF
    IF ((requestin->list_0[i].bill_code_sched != "")
     AND (requestin->list_0[i].bill_code != ""))
     SET bill_code_sched = 0
     SET start_index = 1
     SET occurances = 0
     SELECT INTO "nl:"
      FROM code_value cv
      WHERE cv.code_set=14002
       AND cv.display=trim(requestin->list_0[i].bill_code_sched)
       AND cv.active_ind=1
      DETAIL
       code_list[1] = cv.code_value, occurances = 1
      WITH maxqual(cm,1), nocounter
     ;end select
     IF (occurances=1)
      IF (cnvtreal(requestin->list_0[i].bill_item_mod_id)=0)
       SET stat = alterlist(bimrequest->bill_item_modifier,1)
       SET bimrequest->bill_item_modifier_qual = 1
       SET bimrequest->bill_item_modifier[1].bill_item_id = cnvtreal(requestin->list_0[i].
        bill_item_id)
       SET bimrequest->bill_item_modifier[1].key1_id = code_list[1]
       SET bimrequest->bill_item_modifier[1].bill_item_type_cd = bill_code_cd
       SET bimrequest->bill_item_modifier[1].bim1_int = cnvtint(requestin->list_0[i].priority)
       SET dbillcodeschedcd = uar_get_code_by("DISPLAY",14002,requestin->list_0[i].bill_code_sched)
       SET dreqbillbegeffdttm = cnvtdatetime(cnvtdate2(getdates(requestin->list_0[i].
          bill_code_beg_effective_dt_tm),"MM/DD/YYYY"),cnvttime2(substring(12,8,getdates(requestin->
           list_0[i].bill_code_beg_effective_dt_tm)),"HH:MM:SS"))
       SET dreqbillendeffdttm = cnvtdatetime(cnvtdate2(getdates(requestin->list_0[i].
          bill_code_end_effective_dt_tm),"MM/DD/YYYY"),cnvttime2(substring(12,8,getdates(requestin->
           list_0[i].bill_code_end_effective_dt_tm)),"HH:MM:SS"))
       IF (dreqbillbegeffdttm <= 0.0)
        SET dreqbillbegeffdttm = cnvtdatetime(sysdate)
       ENDIF
       IF (dreqbillendeffdttm <= 0.0)
        SET dreqbillendeffdttm = cnvtdatetime("31-DEC-2100 23:59:59")
       ENDIF
       SET bupdbillcode = false
       SET baddbillcodesched = false
       SELECT INTO "nl:"
        FROM bill_item_modifier b
        WHERE b.bill_item_id=cnvtreal(requestin->list_0[i].bill_item_id)
         AND b.key1_id=dbillcodeschedcd
         AND b.bim1_int=cnvtreal(requestin->list_0[i].priority)
         AND b.active_ind=1
        ORDER BY b.end_effective_dt_tm DESC
        DETAIL
         dbillitemmodifierid = b.bill_item_mod_id, sbillcode = b.key6, sbillcodedesc = b.key7,
         dbillitembegeffdttm = cnvtdatetime(b.beg_effective_dt_tm), dbillitemendeffdttm =
         cnvtdatetime(b.end_effective_dt_tm)
        WITH nocounter, maxrec = 1
       ;end select
       IF (curqual > 0)
        SET iplace = 0
        SET icount = 0
        SET iplace = locateval(icount,1,size(requestin->list_0,5),dbillitemmodifierid,cnvtreal(
          requestin->list_0[icount].bill_item_mod_id))
        IF (iplace=0)
         SET bupdbillcode = true
         SET baddbillcodesched = true
        ELSE
         IF (dreqbillbegeffdttm > dbillitemendeffdttm
          AND dreqbillbegeffdttm < dreqbillendeffdttm)
          SET baddbillcodesched = true
         ENDIF
        ENDIF
       ELSE
        SET baddbillcodesched = true
       ENDIF
       IF (bupdbillcode=true)
        SET stat = alterlist(bimrequest->bill_item_modifier,1)
        SET bimrequest->bill_item_modifier_qual = 1
        SET bimrequest->bill_item_modifier[1].action_type = "UPT"
        SET bimrequest->bill_item_modifier[1].bill_item_mod_id = dbillitemmodifierid
        SET bimrequest->bill_item_modifier[1].key6 = sbillcode
        SET bimrequest->bill_item_modifier[1].key7 = sbillcodedesc
        SET bimrequest->bill_item_modifier[1].beg_effective_dt_tm = cnvtdatetime(dbillitembegeffdttm)
        SET bimrequest->bill_item_modifier[1].end_effective_dt_tm = cnvtlookbehind("1, S",
         dreqbillbegeffdttm)
        SET add_begin = 1
        SET add_end = 1
        IF ((bimrequest->bill_item_modifier[1].end_effective_dt_tm > dbillitembegeffdttm))
         CALL echo("Executing afc_upt_bill_item_modifier")
         EXECUTE afc_upt_bill_item_modifier  WITH replace(request,bimrequest)
         IF ((reply->status_data.status="F"))
          SET num_rejects += 1
          SET stat = alterlist(rejects->errors,num_rejects)
          SET rejects->errors[num_rejects].ext_description = trim(requestin->list_0[i].description)
          SET rejects->errors[num_rejects].price = trim(requestin->list_0[i].price)
          SET rejects->errors[num_rejects].price_sched = trim(requestin->list_0[i].price_sched)
          SET rejects->errors[num_rejects].bill_code = trim(requestin->list_0[i].bill_code)
          SET rejects->errors[num_rejects].bill_code_sched = trim(requestin->list_0[i].
           bill_code_sched)
          SET rejects->errors[num_rejects].message = "Error in afc_upt_bill_item_modifier."
         ENDIF
        ENDIF
       ENDIF
       SET bimrequest->bill_item_modifier[1].action_type = "ADD"
       SET bimrequest->bill_item_modifier[1].bill_item_mod_id = 0.0
       SET bimrequest->bill_item_modifier[1].key6 = requestin->list_0[i].bill_code
       SET bimrequest->bill_item_modifier[1].key7 = requestin->list_0[i].bill_code_desc
       SET add_begin = 1
       SET add_end = 1
       SET bimrequest->bill_item_modifier[1].beg_effective_dt_tm = dreqbillbegeffdttm
       SET bimrequest->bill_item_modifier[1].end_effective_dt_tm = dreqbillendeffdttm
       SET dbillitemmodifierid = 0.0
       IF (baddbillcodesched=true
        AND dreqbillbegeffdttm < dreqbillendeffdttm)
        EXECUTE afc_add_bill_item_modifier  WITH replace(request,bimrequest)
        IF ((reply->status_data.status="F"))
         SET num_rejects += 1
         SET stat = alterlist(rejects->errors,num_rejects)
         SET rejects->errors[num_rejects].ext_description = trim(requestin->list_0[i].description)
         SET rejects->errors[num_rejects].price = trim(requestin->list_0[i].price)
         SET rejects->errors[num_rejects].price_sched = trim(requestin->list_0[i].price_sched)
         SET rejects->errors[num_rejects].bill_code = trim(requestin->list_0[i].bill_code)
         SET rejects->errors[num_rejects].bill_code_sched = trim(requestin->list_0[i].bill_code_sched
          )
         SET rejects->errors[num_rejects].message = "Error in afc_add_bill_item_modifier."
        ENDIF
       ENDIF
      ELSE
       SET stat = alterlist(bimrequest->bill_item_modifier,1)
       SET bimrequest->bill_item_modifier_qual = 1
       SET bimrequest->bill_item_modifier[1].action_type = "UPT"
       SET bimrequest->bill_item_modifier[1].bill_item_mod_id = cnvtreal(requestin->list_0[i].
        bill_item_mod_id)
       SET bimrequest->bill_item_modifier[1].bill_item_id = cnvtreal(requestin->list_0[i].
        bill_item_id)
       SET bimrequest->bill_item_modifier[1].key1_id = code_list[1]
       SET bimrequest->bill_item_modifier[1].bill_item_type_cd = bill_code_cd
       SET bimrequest->bill_item_modifier[1].key6 = requestin->list_0[i].bill_code
       SET bimrequest->bill_item_modifier[1].key7 = requestin->list_0[i].bill_code_desc
       SET bimrequest->bill_item_modifier[1].bim1_int = cnvtint(requestin->list_0[i].priority)
       SET bimrequest->bill_item_modifier[1].beg_effective_dt_tm = cnvtdatetime(cnvtdate2(getdates(
          requestin->list_0[i].bill_code_beg_effective_dt_tm),"MM/DD/YYYY"),cnvttime2(substring(12,8,
          getdates(requestin->list_0[i].bill_code_beg_effective_dt_tm)),"HH:MM:SS"))
       IF ((bimrequest->bill_item_modifier[1].beg_effective_dt_tm <= 0.0))
        SET bimrequest->bill_item_modifier[1].beg_effective_dt_tm = cnvtdatetime(sysdate)
       ENDIF
       SET bimrequest->bill_item_modifier[1].end_effective_dt_tm = cnvtdatetime(cnvtdate2(getdates(
          requestin->list_0[i].bill_code_end_effective_dt_tm),"MM/DD/YYYY"),cnvttime2(substring(12,8,
          getdates(requestin->list_0[i].bill_code_end_effective_dt_tm)),"HH:MM:SS"))
       IF ((bimrequest->bill_item_modifier[1].end_effective_dt_tm <= 0.0))
        SET bimrequest->bill_item_modifier[1].end_effective_dt_tm = cnvtdatetime(
         "31-DEC-2100 23:59:59")
       ENDIF
       SET add_begin = 1
       SET add_end = 1
       CALL echo("Executing afc_upt_bill_item_modifier")
       EXECUTE afc_upt_bill_item_modifier  WITH replace(request,bimrequest)
       IF ((reply->status_data.status="F"))
        SET num_rejects += 1
        SET stat = alterlist(rejects->errors,num_rejects)
        SET rejects->errors[num_rejects].ext_description = trim(requestin->list_0[i].description)
        SET rejects->errors[num_rejects].price = trim(requestin->list_0[i].price)
        SET rejects->errors[num_rejects].price_sched = trim(requestin->list_0[i].price_sched)
        SET rejects->errors[num_rejects].bill_code = trim(requestin->list_0[i].bill_code)
        SET rejects->errors[num_rejects].bill_code_sched = trim(requestin->list_0[i].bill_code_sched)
        SET rejects->errors[num_rejects].message = "Error in afc_upt_bill_item_modifier."
       ENDIF
      ENDIF
     ELSE
      SET num_rejects += 1
      SET stat = alterlist(rejects->errors,num_rejects)
      SET rejects->errors[num_rejects].ext_description = trim(requestin->list_0[i].description)
      SET rejects->errors[num_rejects].price = trim(requestin->list_0[i].price)
      SET rejects->errors[num_rejects].price_sched = trim(requestin->list_0[i].price_sched)
      SET rejects->errors[num_rejects].bill_code = trim(requestin->list_0[i].bill_code)
      SET rejects->errors[num_rejects].bill_code_sched = trim(requestin->list_0[i].bill_code_sched)
      SET rejects->errors[num_rejects].message = "Bill code schedule did not match 14002 display."
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 IF (num_rejects > 0)
  SET equal_line = fillstring(130,"=")
  SET file_name = "ccluserdir:afc_import.err"
  SELECT INTO value(file_name)
   desc = trim(rejects->errors[d1.seq].ext_description), price = trim(rejects->errors[d1.seq].price),
   price_schedule = trim(rejects->errors[d1.seq].price_sched),
   bill_code = trim(rejects->errors[d1.seq].bill_code), bill_code_schedule = trim(rejects->errors[d1
    .seq].bill_code_sched), message = rejects->errors[d1.seq].message,
   run_date = format(curdate,"mm/dd/yy;;d"), run_time = format(curtime,"hh:mm;;m")
   FROM (dummyt d1  WITH seq = value(size(rejects->errors,5)))
   ORDER BY message, desc
   HEAD REPORT
    col 47, "** AFC Import Error Log **", col 100,
    "Run Date: ", run_date, " ",
    run_time, row + 2
   HEAD PAGE
    col 120, "Page: ", curpage"##",
    row + 1, col 00, "Error Message",
    row + 1, col 05, "Bill Item",
    col 35, "Schedule", col 55,
    "Price/Bill Code", row + 1, col 00,
    equal_line, row + 1
   HEAD message
    row + 1, col 00, message
   HEAD desc
    row + 1, col 05, desc
   DETAIL
    IF (((message="Error in afc_add_price_sched_item.") OR (((message=
    "Error in afc_upt_price_sched_item.") OR (message=
    "Price schedule did not match description on table.")) )) )
     col 40, price_schedule, col 65,
     price, row + 1
    ELSEIF (((message="Error in afc_add_bill_item_modifier.") OR (((message=
    "Error in afc_upt_bill_item_modifier.") OR (message=
    "Bill code schedule did not match 14002 display.")) )) )
     col 40, bill_code_schedule, col 65,
     bill_code, row + 1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SUBROUTINE (getdates(sdates=vc) =vc)
   DECLARE snewdate = vc WITH protect
   SET sdates = trim(sdates,7)
   SET sdates = replace(sdates," ","/",0)
   SET sdates = replace(sdates,":","/",0)
   SET snewdate = concat(cnvtstring(cnvtint(piece(sdates,"/",1,"0")),2,0,"R"),"/",cnvtstring(cnvtint(
      piece(sdates,"/",2,"0")),2,0,"R"),"/",cnvtstring(cnvtint(piece(sdates,"/",3,"0")),4,0,"R"),
    " ",cnvtstring(cnvtint(piece(sdates,"/",4,"0")),2,0,"R"),":",cnvtstring(cnvtint(piece(sdates,"/",
       5,"0")),2,0,"R"),":",
    cnvtstring(cnvtint(piece(sdates,"/",6,"0")),2,0,"R"))
   RETURN(snewdate)
 END ;Subroutine
 SUBROUTINE (validateintervalrows(dummyvar=i2) =null)
   DECLARE pos = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE iter = i4 WITH protect, noconstant(0)
   DECLARE intervalcnt = i4 WITH protect, noconstant(0)
   DECLARE intervalpos = i4 WITH protect, noconstant(0)
   DECLARE rangepos = i4 WITH protect, noconstant(0)
   DECLARE rangeidx = i4 WITH protect, noconstant(0)
   DECLARE rangecnt = i4 WITH protect, noconstant(0)
   DECLARE temprangebeg = vc WITH protect, noconstant("")
   DECLARE temprangeend = vc WITH protect, noconstant("")
   DECLARE errinvalidintervaltemplate = vc WITH constant("Interval template is not valid for upload."
    )
   DECLARE errmissingintervalrange = vc WITH constant(
    "All ranges are not populated for the interval template.")
   DECLARE errmissingintervalprice = vc WITH constant("Price not populated for all interval ranges.")
   DECLARE errduplicateintervalrange = vc WITH constant(
    "Duplicate range populated for interval template.")
   DECLARE errmuliplepsiid = vc WITH constant(
    "More than 1 Price_Sched_Items_id populated for interval template.")
   DECLARE errinvalidintervalrange = vc WITH constant("Interval Range doesn't match database values."
    )
   IF (size(requestin->list_0,5) > 0)
    IF (validate(requestin->list_0[1].interval_template)
     AND validate(requestin->list_0[1].interval_begin)
     AND validate(requestin->list_0[1].interval_end))
     SELECT INTO "nl:"
      billid = requestin->list_0[d.seq].bill_item_id, pricesched = requestin->list_0[d.seq].
      price_sched, intervaltemplate = requestin->list_0[d.seq].interval_template,
      begdttm = requestin->list_0[d.seq].price_beg_effective_dt_tm, enddttm = requestin->list_0[d.seq
      ].price_end_effective_dt_tm
      FROM (dummyt d  WITH seq = size(requestin->list_0,5))
      PLAN (d
       WHERE cnvtreal(requestin->list_0[d.seq].bill_item_id) != 0
        AND textlen(trim(requestin->list_0[d.seq].interval_template)))
      ORDER BY billid, pricesched, intervaltemplate,
       begdttm, enddttm
      DETAIL
       pos = locatevalsort(idx,1,size(intervaldata->list,5),requestin->list_0[d.seq].bill_item_id,
        intervaldata->list[idx].bill_item_id,
        requestin->list_0[d.seq].price_sched,intervaldata->list[idx].price_sched,requestin->list_0[d
        .seq].interval_template,intervaldata->list[idx].interval_template,requestin->list_0[d.seq].
        price_beg_effective_dt_tm,
        intervaldata->list[idx].beg_effective_dt_tm,requestin->list_0[d.seq].
        price_end_effective_dt_tm,intervaldata->list[idx].end_effective_dt_tm)
       IF (pos <= 0)
        intervalcnt = (size(intervaldata->list,5)+ 1), stat = alterlist(intervaldata->list,
         intervalcnt), intervaldata->list[intervalcnt].valid = true,
        intervaldata->list[intervalcnt].processed = false, intervaldata->list[intervalcnt].
        bill_item_id = requestin->list_0[d.seq].bill_item_id, intervaldata->list[intervalcnt].
        price_sched = requestin->list_0[d.seq].price_sched,
        intervaldata->list[intervalcnt].interval_template = requestin->list_0[d.seq].
        interval_template, intervaldata->list[intervalcnt].beg_effective_dt_tm = requestin->list_0[d
        .seq].price_beg_effective_dt_tm, intervaldata->list[intervalcnt].end_effective_dt_tm =
        requestin->list_0[d.seq].price_end_effective_dt_tm
       ENDIF
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      beg_value = cnvtstring(it.beg_value,20), end_value = cnvtstring(it.end_value,20)
      FROM code_value cv,
       interval_table it
      PLAN (cv
       WHERE cv.code_set=cs_14274
        AND expand(iter,1,size(intervaldata->list,5),cv.display,intervaldata->list[iter].
        interval_template)
        AND cv.active_ind=1
        AND cv.cdf_meaning="TEMPLATE")
       JOIN (it
       WHERE it.interval_template_cd=cv.code_value
        AND it.active_ind=1)
      ORDER BY cv.display, it.beg_value
      DETAIL
       pos = locateval(idx,1,size(intervaldata->list,5),cv.display,intervaldata->list[idx].
        interval_template)
       WHILE (pos > 0
        AND pos <= size(intervaldata->list,5))
         intervaldata->list[pos].interval_template_cd = cv.code_value, rangecnt = (size(intervaldata
          ->list[pos].intervalranges,5)+ 1), stat = alterlist(intervaldata->list[pos].intervalranges,
          rangecnt),
         intervaldata->list[pos].intervalranges[rangecnt].rangebegin = it.beg_value, intervaldata->
         list[pos].intervalranges[rangecnt].rangeend = it.end_value, intervaldata->list[pos].
         intervalranges[rangecnt].interval_id = it.interval_id,
         pos = locateval(idx,(pos+ 1),size(intervaldata->list,5),cv.display,intervaldata->list[idx].
          interval_template)
       ENDWHILE
      WITH nocounter, expand = 2
     ;end select
     FOR (i = 1 TO value(size(requestin->list_0,5)))
       IF (cnvtreal(requestin->list_0[i].bill_item_id) != 0
        AND textlen(trim(requestin->list_0[i].interval_template,3)) > 0)
        SET pos = locatevalsort(idx,1,size(intervaldata->list,5),requestin->list_0[i].bill_item_id,
         intervaldata->list[idx].bill_item_id,
         requestin->list_0[i].price_sched,intervaldata->list[idx].price_sched,requestin->list_0[i].
         interval_template,intervaldata->list[idx].interval_template,requestin->list_0[i].
         price_beg_effective_dt_tm,
         intervaldata->list[idx].beg_effective_dt_tm,requestin->list_0[i].price_end_effective_dt_tm,
         intervaldata->list[idx].end_effective_dt_tm)
        IF (pos > 0)
         IF (intervaldata->list[pos].valid
          AND  NOT (intervaldata->list[pos].processed))
          IF ((intervaldata->list[pos].interval_template_cd=0))
           SET intervaldata->list[pos].valid = false
           SET intervaldata->list[pos].invalidreason = errinvalidintervaltemplate
           SET requestin->list_0[i].bill_item_id = "0"
           CALL addtorejects(trim(requestin->list_0[i].description),trim(requestin->list_0[i].price),
            trim(requestin->list_0[i].price_sched),trim(requestin->list_0[i].bill_code),trim(
             requestin->list_0[i].bill_code_sched),
            intervaldata->list[pos].invalidreason)
          ENDIF
          FOR (j = 1 TO value(size(intervaldata->list[pos].intervalranges,5)))
            IF (intervaldata->list[pos].valid)
             SET temprangebeg = cnvtstring(intervaldata->list[pos].intervalranges[j].rangebegin,20)
             SET temprangeend = cnvtstring(intervaldata->list[pos].intervalranges[j].rangeend,20)
             SET rangepos = locateval(rangeidx,1,size(requestin->list_0,5),temprangebeg,requestin->
              list_0[rangeidx].interval_begin,
              temprangeend,requestin->list_0[rangeidx].interval_end,intervaldata->list[pos].
              bill_item_id,requestin->list_0[rangeidx].bill_item_id,intervaldata->list[pos].
              price_sched,
              requestin->list_0[rangeidx].price_sched,intervaldata->list[pos].interval_template,
              requestin->list_0[rangeidx].interval_template,intervaldata->list[pos].
              beg_effective_dt_tm,requestin->list_0[rangeidx].price_beg_effective_dt_tm,
              intervaldata->list[pos].end_effective_dt_tm,requestin->list_0[rangeidx].
              price_end_effective_dt_tm)
             IF (rangepos=0)
              SET intervaldata->list[pos].valid = false
              SET intervaldata->list[pos].invalidreason = errmissingintervalrange
              SET requestin->list_0[i].bill_item_id = "0"
              CALL addtorejects(trim(requestin->list_0[i].description),trim(requestin->list_0[i].
                price),trim(requestin->list_0[i].price_sched),trim(requestin->list_0[i].bill_code),
               trim(requestin->list_0[i].bill_code_sched),
               intervaldata->list[pos].invalidreason)
             ELSE
              IF (intervaldata->list[pos].valid
               AND ((trim(requestin->list_0[rangepos].price)=null) OR (trim(requestin->list_0[
               rangepos].price)="")) )
               SET intervaldata->list[pos].valid = false
               SET intervaldata->list[pos].invalidreason = errmissingintervalprice
               SET requestin->list_0[i].bill_item_id = "0"
               CALL addtorejects(trim(requestin->list_0[i].description),trim(requestin->list_0[i].
                 price),trim(requestin->list_0[i].price_sched),trim(requestin->list_0[i].bill_code),
                trim(requestin->list_0[i].bill_code_sched),
                intervaldata->list[pos].invalidreason)
              ENDIF
             ENDIF
            ENDIF
          ENDFOR
          IF (intervaldata->list[pos].valid)
           SET rangepos = 0
           SET rangepos = locateval(rangeidx,1,size(requestin->list_0,5),intervaldata->list[pos].
            bill_item_id,requestin->list_0[rangeidx].bill_item_id,
            intervaldata->list[pos].price_sched,requestin->list_0[rangeidx].price_sched,intervaldata
            ->list[pos].interval_template,requestin->list_0[rangeidx].interval_template,intervaldata
            ->list[pos].beg_effective_dt_tm,
            requestin->list_0[rangeidx].price_beg_effective_dt_tm,intervaldata->list[pos].
            end_effective_dt_tm,requestin->list_0[rangeidx].price_end_effective_dt_tm)
           IF (rangepos > 0)
            SET intervaldata->list[pos].price_sched_items_id_string = requestin->list_0[i].
            price_sched_items_id
            SET intervaldata->list[pos].price_sched_items_id = cnvtreal(requestin->list_0[i].
             price_sched_items_id)
           ENDIF
           WHILE (rangepos > 0
            AND intervaldata->list[pos].valid)
            IF (trim(intervaldata->list[pos].price_sched_items_id_string) != trim(requestin->list_0[
             rangepos].price_sched_items_id))
             SET intervaldata->list[pos].valid = false
             SET intervaldata->list[pos].invalidreason = errmuliplepsiid
             SET requestin->list_0[i].bill_item_id = "0"
             CALL addtorejects(trim(requestin->list_0[i].description),trim(requestin->list_0[i].price
               ),trim(requestin->list_0[i].price_sched),trim(requestin->list_0[i].bill_code),trim(
               requestin->list_0[i].bill_code_sched),
              intervaldata->list[pos].invalidreason)
            ENDIF
            IF (intervaldata->list[pos].valid)
             SET intervalpos = locateval(rangeidx,1,size(intervaldata->list[pos].intervalranges,5),
              cnvtreal(requestin->list_0[rangepos].interval_begin),intervaldata->list[pos].
              intervalranges[rangeidx].rangebegin,
              cnvtreal(requestin->list_0[rangepos].interval_end),intervaldata->list[pos].
              intervalranges[rangeidx].rangeend)
             IF (intervalpos < 1)
              SET intervaldata->list[pos].valid = false
              SET intervaldata->list[pos].invalidreason = errinvalidintervalrange
              SET requestin->list_0[i].bill_item_id = "0"
              CALL addtorejects(trim(requestin->list_0[i].description),trim(requestin->list_0[i].
                price),trim(requestin->list_0[i].price_sched),trim(requestin->list_0[i].bill_code),
               trim(requestin->list_0[i].bill_code_sched),
               intervaldata->list[pos].invalidreason)
             ELSE
              IF (intervaldata->list[pos].intervalranges[rangeidx].interval_range_found)
               SET intervaldata->list[pos].valid = false
               SET intervaldata->list[pos].invalidreason = errduplicateintervalrange
               SET requestin->list_0[i].bill_item_id = "0"
               CALL addtorejects(trim(requestin->list_0[i].description),trim(requestin->list_0[i].
                 price),trim(requestin->list_0[i].price_sched),trim(requestin->list_0[i].bill_code),
                trim(requestin->list_0[i].bill_code_sched),
                intervaldata->list[pos].invalidreason)
              ELSE
               SET intervaldata->list[pos].intervalranges[rangeidx].interval_range_found = true
              ENDIF
             ENDIF
             SET rangepos = locateval(rangeidx,(rangepos+ 1),size(requestin->list_0,5),intervaldata->
              list[pos].bill_item_id,requestin->list_0[rangeidx].bill_item_id,
              intervaldata->list[pos].price_sched,requestin->list_0[rangeidx].price_sched,
              intervaldata->list[pos].interval_template,requestin->list_0[rangeidx].interval_template
              )
            ENDIF
           ENDWHILE
          ENDIF
         ELSE
          IF ( NOT (intervaldata->list[pos].valid))
           SET requestin->list_0[i].bill_item_id = "0"
           CALL addtorejects(trim(requestin->list_0[i].description),trim(requestin->list_0[i].price),
            trim(requestin->list_0[i].price_sched),trim(requestin->list_0[i].bill_code),trim(
             requestin->list_0[i].bill_code_sched),
            intervaldata->list[pos].invalidreason)
          ENDIF
         ENDIF
         SET intervaldata->list[pos].processed = true
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (addtorejects(ext_description=vc,price=vc,price_sched=vc,bill_code=vc,bill_code_sched=vc,
  message=vc) =null)
   SET num_rejects += 1
   SET stat = alterlist(rejects->errors,num_rejects)
   SET rejects->errors[num_rejects].ext_description = ext_description
   SET rejects->errors[num_rejects].price = price
   SET rejects->errors[num_rejects].price_sched = price_sched
   SET rejects->errors[num_rejects].bill_code = bill_code
   SET rejects->errors[num_rejects].bill_code_sched = bill_code_sched
   SET rejects->errors[num_rejects].message = message
 END ;Subroutine
END GO
