CREATE PROGRAM afc_add_reference_api:dba
 IF ("Z"=validate(afc_add_reference_api_vrsn,"Z"))
  DECLARE afc_add_reference_api_vrsn = vc WITH noconstant("640107.025")
 ENDIF
 SET afc_add_reference_api_vrsn = "640107.025"
 RECORD holdreq(
   1 nbr_of_recs = i2
   1 qual[*]
     2 action = i2
     2 ext_id = f8
     2 ext_contributor_cd = f8
     2 parent_qual_ind = f8
     2 careset_ind = i2
     2 ext_owner_cd = f8
     2 ext_sub_owner_cd = f8
     2 ext_description = c100
     2 ext_short_desc = c50
     2 workload_only_ind = i2
     2 price_qual = i2
     2 prices[*]
       3 price_sched_id = f8
       3 price = f8
     2 billcode_qual = i2
     2 billcodes[*]
       3 billcode_sched_cd = f8
       3 billcode = c25
       3 bim1_int = f8
     2 child_qual = i4
     2 children[*]
       3 ext_id = f8
       3 ext_contributor_cd = f8
       3 ext_description = c100
       3 ext_short_desc = c50
       3 child_seq = i4
       3 bi_id = f8
       3 ext_owner_cd = f8
       3 ext_sub_owner_cd = f8
   1 logical_domain_id = f8
 )
 IF (validate(reply->status_data.status,"Z")="Z")
  FREE SET reply
  RECORD reply(
    1 bill_item_qual = i4
    1 bill_item[*]
      2 bill_item_id = f8
    1 qual[*]
      2 bill_item_id = f8
    1 price_sched_items_qual = i2
    1 price_sched_items[*]
      2 price_sched_id = f8
      2 price_sched_items_id = f8
    1 bill_item_modifier_qual = i2
    1 bill_item_modifier[10]
      2 bill_item_mod_id = f8
    1 actioncnt = i2
    1 actionlist[*]
      2 action1 = vc
      2 action2 = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c20
        3 targetobjectname = c15
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE codeset = i4
 DECLARE cdf_meaning = c12
 DECLARE cnt = i4
 DECLARE taskcat = f8
 DECLARE billcodecd = f8
 DECLARE count1 = i4
 DECLARE barcodecd = f8
 DECLARE item_master_cd = f8
 DECLARE supplies_cd = f8
 DECLARE logicaldomainenabledind = i2 WITH protect, noconstant(0)
 DECLARE msstat = f8 WITH protect, noconstant(0.0)
 SET code_set = 13016
 SET code_value = 0.0
 SET cdf_meaning = "TASKCAT"
 EXECUTE cpm_get_cd_for_cdf
 SET taskcat = code_value
 SET update_children_start = cnvtdatetime(sysdate)
 SET update_children_end = cnvtdatetime(sysdate)
 SET update_children_count = 0
 SET count1 = 0
 SET load_start = cnvtdatetime(sysdate)
 SET load_end = cnvtdatetime(sysdate)
 CALL echo("FIND LARGESTCHILDQUAL")
 SET largestchildqual = 0
 FOR (x = 1 TO request->nbr_of_recs)
   IF (size(request->qual[x].children,5) > largestchildqual)
    SET largestchildqual = size(request->qual[x].children,5)
   ENDIF
 ENDFOR
 CALL echo(build("LARGESTCHILDQUAL: ",largestchildqual))
 SET endflag = 0
 CALL echo("JOIN TO FIND 0 CONT CD")
 SELECT INTO "nl:"
  d1.seq, d2.seq
  FROM (dummyt d1  WITH seq = value(request->nbr_of_recs)),
   (dummyt d2  WITH seq = value(largestchildqual))
  PLAN (d1
   WHERE size(request->qual[d1.seq].children,5) > 0)
   JOIN (d2
   WHERE d2.seq <= size(request->qual[d1.seq].children,5))
  DETAIL
   IF ((request->qual[d1.seq].ext_id > 0)
    AND (((request->qual[d1.seq].ext_contributor_cd=0)) OR ((request->qual[d1.seq].children[d2.seq].
   ext_id > 0)
    AND (request->qual[d1.seq].children[d2.seq].ext_contributor_cd=0))) )
    CALL echo("External id sent with no contributor....ending program."), endflag = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (endflag=1)
  GO TO end_program
 ENDIF
 SET psub = 0
 SET ttlpsub = request->nbr_of_recs
 SET stat = alterlist(reply->qual,request->nbr_of_recs)
 CALL echo("Initialize")
 CALL initialize("init")
 SET code_set = 13019
 SET code_value = 0.0
 SET cdf_meaning = "BILL CODE"
 EXECUTE cpm_get_cd_for_cdf
 SET billcodecd = code_value
 SET code_set = 13019
 SET code_value = 0.0
 SET cdf_meaning = "BARCODE"
 EXECUTE cpm_get_cd_for_cdf
 SET barcodecd = code_value
 SET code_set = 13016
 SET code_value = 0.0
 SET cdf_meaning = "ITEM MASTER"
 EXECUTE cpm_get_cd_for_cdf
 SET item_master_cd = code_value
 SET code_set = 106
 SET code_value = 0.0
 SET cdf_meaning = "GENERAL CARE"
 EXECUTE cpm_get_cd_for_cdf
 SET supplies_cd = code_value
 RECORD ensbillitemrequest(
   1 bill_item_qual = i2
   1 bill_item[*]
     2 action_type = c3
     2 bill_item_id = f8
     2 ext_parent_reference_id = f8
     2 ext_parent_contributor_cd = f8
     2 ext_child_reference_id = f8
     2 ext_child_contributor_cd = f8
     2 ext_description = c100
     2 ext_short_desc = c50
     2 ext_owner_cd = f8
     2 ext_sub_owner_cd = f8
     2 parent_qual_ind = f8
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_prsnl_id = f8
     2 active_status_dt_tm = dq8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 charge_point_cd = f8
     2 workload_only_ind = i2
     2 updt_cnt = i4
     2 misc_ind = i2
     2 stats_only_ind = i2
     2 child_seq = i4
     2 late_chrg_excl_ind = i2
   1 logical_domain_id = f8
   1 logical_domain_enabled_ind = i2
 )
 RECORD enspsirequest(
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
     2 stats_only_ind = i2
     2 stats_only_ind_ind = i2
     2 capitation_ind = i2
     2 referral_req_ind = i2
     2 allowable = f8
     2 exclusive_ind_ind = i2
     2 exclusive_ind = i2
     2 tax = f8
     2 cost_adj_amt = f8
     2 billing_discount_priority = i4
 )
 RECORD ensbimrequest(
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
     2 key11_id = f8
     2 key12_id = f8
     2 key13_id = f8
     2 key14_id = f8
     2 key15_id = f8
     2 bim1_int = f8
     2 bim2_int = f8
     2 bim_ind = i2
     2 bim1_ind = i2
     2 bim1_nbr = f8
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 updt_cnt = i2
 )
 SET parent_id = - (1)
 FOR (psub = 1 TO ttlpsub)
  CALL echo(concat("============  qual[",cnvtstring(psub),"]  ============="))
  IF ((holdreq->qual[psub].ext_id != 0))
   IF ((holdreq->qual[psub].parent_qual_ind=1))
    IF ((holdreq->qual[psub].action=3))
     CALL check_del_item("Group",holdreq->qual[psub].ext_id,holdreq->qual[psub].ext_contributor_cd)
     CALL delete_children("")
     SET holdreq->qual[psub].child_qual = 0
    ELSE
     CALL check_add_item("Group",holdreq->qual[psub].ext_id,holdreq->qual[psub].ext_contributor_cd)
     IF ((holdreq->qual[psub].price_qual != 0))
      FOR (i = 1 TO holdreq->qual[psub].price_qual)
        CALL check_add_price(reply->qual[psub].bill_item_id,holdreq->qual[psub].prices[i].
         price_sched_id,holdreq->qual[psub].prices[i].price)
      ENDFOR
     ENDIF
     IF ((holdreq->qual[psub].billcode_qual != 0))
      FOR (i = 1 TO holdreq->qual[psub].billcode_qual)
        CALL check_add_billcode(reply->qual[psub].bill_item_id,holdreq->qual[psub].billcodes[i].
         billcode_sched_cd,holdreq->qual[psub].billcodes[i].billcode,holdreq->qual[psub].
         ext_description,holdreq->qual[psub].ext_contributor_cd,
         holdreq->qual[psub].ext_owner_cd,holdreq->qual[psub].billcodes[i].bim1_int)
      ENDFOR
     ENDIF
    ENDIF
    IF ((holdreq->qual[psub].child_qual > 0))
     IF ((holdreq->qual[psub].careset_ind=1))
      CALL careset_cleanup_children("")
      COMMIT
      CALL careset_update_children("")
      COMMIT
      CALL careset_add_children("")
      COMMIT
     ELSE
      CALL cleanup_children("")
      COMMIT
      CALL update_children("")
      COMMIT
      CALL add_children("")
      COMMIT
     ENDIF
    ENDIF
   ELSE
    IF ((holdreq->qual[psub].action=3))
     CALL check_del_item("Detail",holdreq->qual[psub].ext_id,holdreq->qual[psub].ext_contributor_cd)
    ELSE
     CALL check_add_item("Detail",holdreq->qual[psub].ext_id,holdreq->qual[psub].ext_contributor_cd)
    ENDIF
   ENDIF
  ENDIF
 ENDFOR
 GO TO end_program
 SUBROUTINE delete_children(str)
   CALL echo("DELETE CHILDREN BEGIN")
   SET count1 = 0
   SET ensbillitemrequest->bill_item_qual = count1
   SELECT INTO "nl:"
    b.bill_item_id, b.active_status_cd, b.ext_description,
    b.ext_short_desc, b.ext_child_reference_id
    FROM bill_item b
    WHERE ((b.ext_child_reference_id+ 0) != 0)
     AND (b.ext_parent_reference_id=holdreq->qual[psub].ext_id)
     AND (b.ext_parent_contributor_cd=holdreq->qual[psub].ext_contributor_cd)
     AND ((b.active_ind+ 0)=1)
    DETAIL
     count1 += 1, stat = alterlist(ensbillitemrequest->bill_item,count1), ensbillitemrequest->
     bill_item_qual = count1,
     ensbillitemrequest->bill_item[count1].bill_item_id = b.bill_item_id, ensbillitemrequest->
     bill_item[count1].active_status_cd = b.active_status_cd, ensbillitemrequest->bill_item[count1].
     action_type = "DEL"
    WITH nocounter
   ;end select
   IF ((ensbillitemrequest->bill_item_qual > 0))
    SET action_begin = 1
    SET action_end = ensbillitemrequest->bill_item_qual
    CALL echo("Execute AFC_DEL_BILL_ITEM")
    EXECUTE afc_del_bill_item  WITH replace("REQUEST","ENSBILLITEMREQUEST")
   ENDIF
 END ;Subroutine
 SUBROUTINE cleanup_children(str)
   CALL echo("CLEANUP_CHILDREN BEGIN")
   SET count1 = 0
   SET ensbillitemrequest->bill_item_qual = count1
   SELECT INTO "nl:"
    d1.seq, b.bill_item_id, b.active_status_cd,
    b.ext_description, b.ext_short_desc, b.ext_child_reference_id
    FROM bill_item b,
     (dummyt d1  WITH seq = value(holdreq->qual[psub].child_qual))
    PLAN (b
     WHERE ((b.ext_child_reference_id+ 0) != 0)
      AND (b.ext_parent_reference_id=holdreq->qual[psub].ext_id)
      AND (b.ext_parent_contributor_cd=holdreq->qual[psub].ext_contributor_cd)
      AND ((b.active_ind+ 0)=1))
     JOIN (d1
     WHERE ((b.ext_parent_reference_id+ 0)=holdreq->qual[psub].ext_id)
      AND ((b.ext_parent_contributor_cd+ 0) > 0)
      AND (b.ext_child_reference_id=holdreq->qual[psub].children[d1.seq].ext_id)
      AND (b.ext_child_contributor_cd=holdreq->qual[psub].children[d1.seq].ext_contributor_cd)
      AND ((b.active_ind+ 0)=1))
    DETAIL
     CALL echo("B.EXT_CHILD_CONTRIBUTOR_CD: ",0),
     CALL echo(b.ext_child_contributor_cd),
     CALL echo("HOLDREQ->QUAL[PSUB]->CHILDREN[D1.SEQ]->EXT_CONTRIBUTOR_CD: ",0),
     CALL echo(holdreq->qual[psub].children[d1.seq].ext_contributor_cd)
     IF ((b.ext_child_contributor_cd=holdreq->qual[psub].children[d1.seq].ext_contributor_cd))
      CALL echo(concat("to delete: ",cnvtstring(b.bill_item_id,17,2))), count1 += 1, stat = alterlist
      (ensbillitemrequest->bill_item,count1),
      ensbillitemrequest->bill_item_qual = count1, ensbillitemrequest->bill_item[count1].bill_item_id
       = b.bill_item_id, ensbillitemrequest->bill_item[count1].active_status_cd = b.active_status_cd,
      ensbillitemrequest->bill_item[count1].action_type = "DEL"
     ENDIF
    WITH outerjoin = b, dontexist, nocounter
   ;end select
   IF ((ensbillitemrequest->bill_item_qual > 0))
    CALL echo("*****THERE ARE ITEMS TO DELETE*****")
    SET action_begin = 1
    SET action_end = ensbillitemrequest->bill_item_qual
    CALL echo("Execute AFC_DEL_BILL_ITEM")
    EXECUTE afc_del_bill_item  WITH replace("REQUEST","ENSBILLITEMREQUEST")
   ENDIF
 END ;Subroutine
 SUBROUTINE update_children(str)
   CALL echo("UPDATE_CHILDREN BEGIN")
   SET update_children_start = cnvtdatetime(sysdate)
   SET count1 = 0
   SET ensbillitemrequest->bill_item_qual = count1
   SET update_children_count += size(holdreq->qual[psub].children)
   IF (update_children_count=0)
    CALL echo("NO CHILDREN TO UPDATE")
   ELSE
    SELECT INTO "nl:"
     FROM bill_item b,
      (dummyt d2  WITH seq = value(holdreq->qual[psub].child_qual))
     PLAN (d2
      WHERE (holdreq->qual[psub].children[d2.seq].ext_id != 0))
      JOIN (b
      WHERE ((b.ext_parent_reference_id+ 0)=holdreq->qual[psub].ext_id)
       AND ((b.ext_parent_contributor_cd+ 0) > 0)
       AND (b.ext_child_reference_id=holdreq->qual[psub].children[d2.seq].ext_id)
       AND (b.ext_child_contributor_cd=holdreq->qual[psub].children[d2.seq].ext_contributor_cd)
       AND (((b.ext_description != holdreq->qual[psub].children[d2.seq].ext_description)) OR ((((b
      .ext_short_desc != holdreq->qual[psub].children[d2.seq].ext_short_desc)) OR ((((b.ext_owner_cd
       != holdreq->qual[psub].children[d2.seq].ext_owner_cd)) OR ((((b.ext_sub_owner_cd != holdreq->
      qual[psub].children[d2.seq].ext_sub_owner_cd)) OR (b.active_ind=0)) )) )) )) )
     ORDER BY b.ext_parent_reference_id
     DETAIL
      holdreq->qual[psub].children[d2.seq].bi_id = b.bill_item_id
     WITH nocounter
    ;end select
    UPDATE  FROM bill_item b,
      (dummyt d2  WITH seq = value(holdreq->qual[psub].child_qual))
     SET b.active_ind = evaluate(b.bill_item_id,holdreq->qual[psub].children[d2.seq].bi_id,1,b
       .active_ind), b.ext_description = holdreq->qual[psub].children[d2.seq].ext_description, b
      .ext_short_desc = holdreq->qual[psub].children[d2.seq].ext_short_desc,
      b.ext_owner_cd =
      IF ((holdreq->qual[psub].children[d2.seq].ext_owner_cd > 0)) holdreq->qual[psub].children[d2
       .seq].ext_owner_cd
      ELSE b.ext_owner_cd
      ENDIF
      , b.ext_sub_owner_cd =
      IF ((holdreq->qual[psub].children[d2.seq].ext_sub_owner_cd >= 0)) holdreq->qual[psub].children[
       d2.seq].ext_sub_owner_cd
      ELSE b.ext_sub_owner_cd
      ENDIF
      , b.updt_cnt = (b.updt_cnt+ 1),
      b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_id = reqinfo->updt_id, b.updt_applctx =
      reqinfo->updt_applctx,
      b.updt_task = reqinfo->updt_task
     PLAN (d2
      WHERE (holdreq->qual[psub].children[d2.seq].ext_id != 0))
      JOIN (b
      WHERE ((b.ext_parent_reference_id+ 0)=holdreq->qual[psub].ext_id)
       AND ((b.ext_parent_contributor_cd+ 0) > 0)
       AND (b.ext_child_reference_id=holdreq->qual[psub].children[d2.seq].ext_id)
       AND (b.ext_child_contributor_cd=holdreq->qual[psub].children[d2.seq].ext_contributor_cd))
     WITH nocounter
    ;end update
    SELECT INTO "nl:"
     FROM bill_item b,
      (dummyt d2  WITH seq = value(holdreq->qual[psub].child_qual))
     PLAN (d2
      WHERE (holdreq->qual[psub].children[d2.seq].ext_id != 0))
      JOIN (b
      WHERE ((b.ext_parent_reference_id+ 0)=0)
       AND ((b.ext_parent_contributor_cd+ 0)=0)
       AND (b.ext_child_reference_id=holdreq->qual[psub].children[d2.seq].ext_id)
       AND (b.ext_child_contributor_cd=holdreq->qual[psub].children[d2.seq].ext_contributor_cd)
       AND (((b.ext_description != holdreq->qual[psub].children[d2.seq].ext_description)) OR ((((b
      .ext_short_desc != holdreq->qual[psub].children[d2.seq].ext_short_desc)) OR ((((b.ext_owner_cd
       != holdreq->qual[psub].children[d2.seq].ext_owner_cd)) OR ((((b.ext_sub_owner_cd != holdreq->
      qual[psub].children[d2.seq].ext_sub_owner_cd)) OR (b.active_ind=0)) )) )) )) )
     ORDER BY b.ext_parent_reference_id
     DETAIL
      holdreq->qual[psub].children[d2.seq].bi_id = b.bill_item_id
     WITH nocounter
    ;end select
    UPDATE  FROM bill_item b,
      (dummyt d2  WITH seq = value(holdreq->qual[psub].child_qual))
     SET b.active_ind = evaluate(b.bill_item_id,holdreq->qual[psub].children[d2.seq].bi_id,1,b
       .active_ind), b.ext_description = holdreq->qual[psub].children[d2.seq].ext_description, b
      .ext_short_desc = holdreq->qual[psub].children[d2.seq].ext_short_desc,
      b.ext_owner_cd =
      IF ((holdreq->qual[psub].children[d2.seq].ext_owner_cd > 0)) holdreq->qual[psub].children[d2
       .seq].ext_owner_cd
      ELSE b.ext_owner_cd
      ENDIF
      , b.updt_cnt = (b.updt_cnt+ 1), b.updt_dt_tm = cnvtdatetime(curdate,curtime),
      b.updt_id = reqinfo->updt_id, b.updt_applctx = reqinfo->updt_applctx, b.updt_task = reqinfo->
      updt_task
     PLAN (d2
      WHERE (holdreq->qual[psub].children[d2.seq].ext_id != 0))
      JOIN (b
      WHERE ((b.ext_parent_reference_id+ 0)=0)
       AND ((b.ext_parent_contributor_cd+ 0)=0)
       AND (b.ext_child_reference_id=holdreq->qual[psub].children[d2.seq].ext_id)
       AND (b.ext_child_contributor_cd=holdreq->qual[psub].children[d2.seq].ext_contributor_cd))
     WITH nocounter
    ;end update
   ENDIF
   SET update_children_end = cnvtdatetime(sysdate)
   CALL echo("UPDATE_CHILDREN START: ",0)
   CALL echo(format(update_children_start,"hh:mm:ss;;s"))
   CALL echo("UPDATE_CHILDREN END: ",0)
   CALL echo(format(update_children_end,"hh:mm:ss;;s"))
 END ;Subroutine
 SUBROUTINE add_children(str)
   CALL echo("Add_Children")
   SET count1 = 0
   SET ensbillitemrequest->bill_item_qual = count1
   SELECT INTO "nl:"
    d2.seq, holdreq->qual[psub].children[d2.seq].ext_description, holdreq->qual[psub].children[d2.seq
    ].ext_short_desc,
    b.bill_item_id, b.ext_description, b.ext_short_desc
    FROM bill_item b,
     (dummyt d2  WITH seq = value(holdreq->qual[psub].child_qual))
    PLAN (d2)
     JOIN (b
     WHERE (b.ext_parent_reference_id=holdreq->qual[psub].ext_id)
      AND (b.ext_parent_contributor_cd=holdreq->qual[psub].ext_contributor_cd)
      AND (b.ext_child_reference_id=holdreq->qual[psub].children[d2.seq].ext_id)
      AND (b.ext_child_contributor_cd=holdreq->qual[psub].children[d2.seq].ext_contributor_cd)
      AND ((b.active_ind+ 0)=1))
    DETAIL
     IF ((holdreq->qual[psub].children[d2.seq].ext_id != 0))
      count1 += 1, stat = alterlist(ensbillitemrequest->bill_item,count1), ensbillitemrequest->
      bill_item_qual = count1,
      ensbillitemrequest->bill_item[count1].ext_owner_cd =
      IF ((holdreq->qual[psub].children[d2.seq].ext_owner_cd > 0)) holdreq->qual[psub].children[d2
       .seq].ext_owner_cd
      ELSE holdreq->qual[psub].ext_owner_cd
      ENDIF
      , ensbillitemrequest->bill_item[count1].ext_sub_owner_cd =
      IF ((holdreq->qual[psub].children[d2.seq].ext_sub_owner_cd > 0)) holdreq->qual[psub].children[
       d2.seq].ext_sub_owner_cd
      ELSE holdreq->qual[psub].ext_sub_owner_cd
      ENDIF
      , ensbillitemrequest->bill_item[count1].workload_only_ind = holdreq->qual[psub].
      workload_only_ind,
      ensbillitemrequest->bill_item[count1].ext_parent_reference_id = holdreq->qual[psub].ext_id,
      ensbillitemrequest->bill_item[count1].ext_parent_contributor_cd = holdreq->qual[psub].
      ext_contributor_cd, ensbillitemrequest->bill_item[count1].ext_child_reference_id = holdreq->
      qual[psub].children[d2.seq].ext_id,
      ensbillitemrequest->bill_item[count1].ext_child_contributor_cd = holdreq->qual[psub].children[
      d2.seq].ext_contributor_cd, ensbillitemrequest->bill_item[count1].ext_description = holdreq->
      qual[psub].children[d2.seq].ext_description, ensbillitemrequest->bill_item[count1].
      ext_short_desc = holdreq->qual[psub].children[d2.seq].ext_short_desc,
      ensbillitemrequest->bill_item[count1].parent_qual_ind = 0, ensbillitemrequest->bill_item[count1
      ].active_ind_ind = 1, ensbillitemrequest->bill_item[count1].active_ind = 1,
      ensbillitemrequest->bill_item[count1].action_type = "ADD"
     ENDIF
    WITH outerjoin = d2, dontexist, nocounter
   ;end select
   SELECT INTO "nl:"
    d1.seq
    FROM bill_item b,
     (dummyt d1  WITH seq = value(ensbillitemrequest->bill_item_qual))
    PLAN (d1)
     JOIN (b
     WHERE (b.ext_parent_reference_id=ensbillitemrequest->bill_item[d1.seq].ext_child_reference_id)
      AND (b.ext_parent_contributor_cd=ensbillitemrequest->bill_item[d1.seq].ext_child_contributor_cd
     )
      AND ((b.ext_child_reference_id+ 0)=0)
      AND ((b.ext_child_contributor_cd+ 0)=0))
    DETAIL
     ensbillitemrequest->bill_item[d1.seq].parent_qual_ind = 1
    WITH nocounter
   ;end select
   IF ((ensbillitemrequest->bill_item_qual > 0))
    SET action_begin = 1
    SET action_end = ensbillitemrequest->bill_item_qual
    SET ensbillitemrequest->logical_domain_id = holdreq->logical_domain_id
    SET ensbillitemrequest->logical_domain_enabled_ind = logicaldomainenabledind
    CALL echo("Execute AFC_ADD_BILL_ITEM")
    EXECUTE afc_add_bill_item  WITH replace("REQUEST","ENSBILLITEMREQUEST")
   ELSE
    CALL echo("NO CHILDREN TO ADD")
   ENDIF
   SET count1 = 0
   SET ensbillitemrequest->bill_item_qual = count1
   SELECT INTO "nl:"
    d2.seq, holdreq->qual[psub].children[d2.seq].ext_description, holdreq->qual[psub].children[d2.seq
    ].ext_short_desc,
    b.bill_item_id, b.ext_description, b.ext_short_desc
    FROM bill_item b,
     (dummyt d2  WITH seq = value(holdreq->qual[psub].child_qual))
    PLAN (d2
     WHERE (holdreq->qual[psub].children[d2.seq].ext_contributor_cd != taskcat))
     JOIN (b
     WHERE ((((b.ext_parent_reference_id+ 0)=0)
      AND ((b.ext_parent_contributor_cd+ 0)=0)
      AND (b.ext_child_reference_id=holdreq->qual[psub].children[d2.seq].ext_id)
      AND (b.ext_child_contributor_cd=holdreq->qual[psub].children[d2.seq].ext_contributor_cd)) OR ((
     b.ext_parent_reference_id=holdreq->qual[psub].children[d2.seq].ext_id)
      AND (b.ext_parent_contributor_cd=holdreq->qual[psub].children[d2.seq].ext_contributor_cd)
      AND ((b.ext_child_reference_id+ 0)=0)
      AND ((b.ext_child_contributor_cd+ 0)=0)
      AND ((b.active_ind+ 0)=1))) )
    DETAIL
     IF ((holdreq->qual[psub].children[d2.seq].ext_id != 0))
      count1 += 1, stat = alterlist(ensbillitemrequest->bill_item,count1), ensbillitemrequest->
      bill_item_qual = count1,
      ensbillitemrequest->bill_item[count1].ext_owner_cd =
      IF ((holdreq->qual[psub].children[d2.seq].ext_owner_cd > 0)) holdreq->qual[psub].children[d2
       .seq].ext_owner_cd
      ELSE holdreq->qual[psub].ext_owner_cd
      ENDIF
      , ensbillitemrequest->bill_item[count1].ext_sub_owner_cd =
      IF ((holdreq->qual[psub].children[d2.seq].ext_sub_owner_cd > 0)) holdreq->qual[psub].children[
       d2.seq].ext_sub_owner_cd
      ELSE holdreq->qual[psub].ext_sub_owner_cd
      ENDIF
      , ensbillitemrequest->bill_item[count1].workload_only_ind = holdreq->qual[psub].
      workload_only_ind,
      ensbillitemrequest->bill_item[count1].ext_parent_reference_id = 0, ensbillitemrequest->
      bill_item[count1].ext_parent_contributor_cd = 0, ensbillitemrequest->bill_item[count1].
      ext_child_reference_id = holdreq->qual[psub].children[d2.seq].ext_id,
      ensbillitemrequest->bill_item[count1].ext_child_contributor_cd = holdreq->qual[psub].children[
      d2.seq].ext_contributor_cd, ensbillitemrequest->bill_item[count1].ext_description = holdreq->
      qual[psub].children[d2.seq].ext_description, ensbillitemrequest->bill_item[count1].
      ext_short_desc = holdreq->qual[psub].children[d2.seq].ext_short_desc,
      ensbillitemrequest->bill_item[count1].parent_qual_ind = 0, ensbillitemrequest->bill_item[count1
      ].active_ind_ind = 1, ensbillitemrequest->bill_item[count1].active_ind = 1,
      ensbillitemrequest->bill_item[count1].action_type = "ADD"
     ENDIF
    WITH outerjoin = d2, dontexist, nocounter
   ;end select
   IF ((ensbillitemrequest->bill_item_qual > 0))
    SET action_begin = 1
    SET action_end = ensbillitemrequest->bill_item_qual
    SET ensbillitemrequest->logical_domain_id = holdreq->logical_domain_id
    SET ensbillitemrequest->logical_domain_enabled_ind = logicaldomainenabledind
    EXECUTE afc_add_bill_item  WITH replace("REQUEST","ENSBILLITEMREQUEST")
   ELSE
    CALL echo("NO DEFAULT CHILDREN TO ADD")
   ENDIF
 END ;Subroutine
 SUBROUTINE careset_cleanup_children(str)
   CALL echo("CARESET_CLEANUP_CHILDREN BEGIN")
   SET count1 = 0
   SET ensbillitemrequest->bill_item_qual = count1
   SELECT INTO "nl:"
    d1.seq, b.bill_item_id, b.active_status_cd,
    b.ext_description, b.ext_short_desc, b.ext_child_reference_id
    FROM bill_item b,
     (dummyt d1  WITH seq = value(holdreq->qual[psub].child_qual))
    PLAN (b
     WHERE ((b.ext_child_reference_id+ 0) != 0)
      AND (b.ext_parent_reference_id=holdreq->qual[psub].ext_id)
      AND (b.ext_parent_contributor_cd=holdreq->qual[psub].ext_contributor_cd)
      AND ((b.active_ind+ 0)=1))
     JOIN (d1
     WHERE ((b.ext_parent_reference_id+ 0)=holdreq->qual[psub].ext_id)
      AND ((b.ext_parent_contributor_cd+ 0) > 0)
      AND (b.ext_child_reference_id=holdreq->qual[psub].children[d1.seq].ext_id)
      AND (b.ext_child_contributor_cd=holdreq->qual[psub].children[d1.seq].ext_contributor_cd)
      AND ((b.active_ind+ 0)=1))
    DETAIL
     IF ((b.ext_child_contributor_cd=holdreq->qual[psub].children[d1.seq].ext_contributor_cd))
      CALL echo(concat("to delete: ",cnvtstring(b.bill_item_id,17,2))), count1 += 1, stat = alterlist
      (ensbillitemrequest->bill_item,count1),
      ensbillitemrequest->bill_item_qual = count1, ensbillitemrequest->bill_item[count1].bill_item_id
       = b.bill_item_id, ensbillitemrequest->bill_item[count1].active_status_cd = b.active_status_cd,
      ensbillitemrequest->bill_item[count1].action_type = "DEL"
     ENDIF
    WITH outerjoin = b, dontexist, nocounter
   ;end select
   IF ((ensbillitemrequest->bill_item_qual > 0))
    SET action_begin = 1
    SET action_end = ensbillitemrequest->bill_item_qual
    CALL echo("Execute AFC_DEL_BILL_ITEM")
    EXECUTE afc_del_bill_item  WITH replace("REQUEST","ENSBILLITEMREQUEST")
   ENDIF
 END ;Subroutine
 SUBROUTINE careset_update_children(str)
   CALL echo("CARESET_UPDATE_CHILDREN BEGIN")
   SET update_children_start = cnvtdatetime(sysdate)
   SET count1 = 0
   SET ensbillitemrequest->bill_item_qual = count1
   SET update_children_count += size(holdreq->qual[psub].children)
   CALL echo("update careset children")
   IF (update_children_count=0)
    CALL echo("NO CHILDREN TO UPDATE")
   ELSE
    SELECT INTO "nl:"
     FROM bill_item b,
      (dummyt d2  WITH seq = value(holdreq->qual[psub].child_qual))
     PLAN (d2
      WHERE (holdreq->qual[psub].children[d2.seq].ext_id != 0))
      JOIN (b
      WHERE ((b.ext_parent_reference_id+ 0)=holdreq->qual[psub].ext_id)
       AND ((b.ext_parent_contributor_cd+ 0) > 0)
       AND (b.ext_child_reference_id=holdreq->qual[psub].children[d2.seq].ext_id)
       AND (b.ext_child_contributor_cd=holdreq->qual[psub].children[d2.seq].ext_contributor_cd)
       AND (((b.ext_description != holdreq->qual[psub].children[d2.seq].ext_description)) OR ((((b
      .ext_short_desc != holdreq->qual[psub].children[d2.seq].ext_short_desc)) OR ((((b.ext_owner_cd
       != holdreq->qual[psub].children[d2.seq].ext_owner_cd)) OR ((((b.ext_sub_owner_cd != holdreq->
      qual[psub].children[d2.seq].ext_sub_owner_cd)) OR (b.active_ind=0)) )) )) )) )
     ORDER BY b.ext_parent_reference_id
     DETAIL
      holdreq->qual[psub].children[d2.seq].bi_id = b.bill_item_id
     WITH nocounter
    ;end select
    UPDATE  FROM bill_item b,
      (dummyt d2  WITH seq = value(holdreq->qual[psub].child_qual))
     SET b.active_ind = evaluate(b.bill_item_id,holdreq->qual[psub].children[d2.seq].bi_id,1,b
       .active_ind), b.ext_description = holdreq->qual[psub].children[d2.seq].ext_description, b
      .ext_short_desc = holdreq->qual[psub].children[d2.seq].ext_short_desc,
      b.ext_owner_cd =
      IF ((holdreq->qual[psub].children[d2.seq].ext_owner_cd > 0)) holdreq->qual[psub].children[d2
       .seq].ext_owner_cd
      ELSE b.ext_owner_cd
      ENDIF
      , b.ext_sub_owner_cd =
      IF ((holdreq->qual[psub].children[d2.seq].ext_sub_owner_cd >= 0)) holdreq->qual[psub].children[
       d2.seq].ext_sub_owner_cd
      ELSE b.ext_sub_owner_cd
      ENDIF
      , b.updt_cnt = (b.updt_cnt+ 1),
      b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_id = reqinfo->updt_id, b.updt_applctx =
      reqinfo->updt_applctx,
      b.updt_task = reqinfo->updt_task
     PLAN (d2
      WHERE (holdreq->qual[psub].children[d2.seq].ext_id != 0))
      JOIN (b
      WHERE ((b.ext_parent_reference_id+ 0)=holdreq->qual[psub].ext_id)
       AND ((b.ext_parent_contributor_cd+ 0) > 0)
       AND (b.ext_child_reference_id=holdreq->qual[psub].children[d2.seq].ext_id)
       AND (b.ext_child_contributor_cd=holdreq->qual[psub].children[d2.seq].ext_contributor_cd))
     WITH nocounter
    ;end update
   ENDIF
   SET update_children_end = cnvtdatetime(sysdate)
   CALL echo("UPDATE_CHILDREN START: ",0)
   CALL echo(format(update_children_start,"hh:mm:ss;;s"))
   CALL echo("UPDATE_CHILDREN END: ",0)
   CALL echo(format(update_children_end,"hh:mm:ss;;s"))
 END ;Subroutine
 SUBROUTINE careset_add_children(str)
   CALL echo("CARESET_Add_Children")
   SET count1 = 0
   SET ensbillitemrequest->bill_item_qual = count1
   SELECT INTO "nl:"
    d2.seq, holdreq->qual[psub].children[d2.seq].ext_description, holdreq->qual[psub].children[d2.seq
    ].ext_short_desc,
    b.bill_item_id, b.ext_description, b.ext_short_desc
    FROM bill_item b,
     (dummyt d2  WITH seq = value(holdreq->qual[psub].child_qual))
    PLAN (d2)
     JOIN (b
     WHERE ((b.active_ind+ 0)=1)
      AND (b.ext_parent_reference_id=holdreq->qual[psub].ext_id)
      AND (b.ext_parent_contributor_cd=holdreq->qual[psub].ext_contributor_cd)
      AND (b.ext_child_reference_id=holdreq->qual[psub].children[d2.seq].ext_id)
      AND (b.ext_child_contributor_cd=holdreq->qual[psub].children[d2.seq].ext_contributor_cd))
    DETAIL
     IF ((holdreq->qual[psub].children[d2.seq].ext_id != 0))
      count1 += 1, stat = alterlist(ensbillitemrequest->bill_item,count1), ensbillitemrequest->
      bill_item_qual = count1,
      ensbillitemrequest->bill_item[count1].ext_owner_cd =
      IF ((holdreq->qual[psub].children[d2.seq].ext_owner_cd > 0)) holdreq->qual[psub].children[d2
       .seq].ext_owner_cd
      ELSE holdreq->qual[psub].ext_owner_cd
      ENDIF
      , ensbillitemrequest->bill_item[count1].ext_sub_owner_cd =
      IF ((holdreq->qual[psub].children[d2.seq].ext_sub_owner_cd > 0)) holdreq->qual[psub].children[
       d2.seq].ext_sub_owner_cd
      ELSE holdreq->qual[psub].ext_sub_owner_cd
      ENDIF
      , ensbillitemrequest->bill_item[count1].workload_only_ind = holdreq->qual[psub].
      workload_only_ind,
      ensbillitemrequest->bill_item[count1].ext_parent_reference_id = holdreq->qual[psub].ext_id,
      ensbillitemrequest->bill_item[count1].ext_parent_contributor_cd = holdreq->qual[psub].
      ext_contributor_cd, ensbillitemrequest->bill_item[count1].ext_child_reference_id = holdreq->
      qual[psub].children[d2.seq].ext_id,
      ensbillitemrequest->bill_item[count1].ext_child_contributor_cd = holdreq->qual[psub].children[
      d2.seq].ext_contributor_cd, ensbillitemrequest->bill_item[count1].ext_description = holdreq->
      qual[psub].children[d2.seq].ext_description, ensbillitemrequest->bill_item[count1].
      ext_short_desc = holdreq->qual[psub].children[d2.seq].ext_short_desc,
      ensbillitemrequest->bill_item[count1].child_seq = holdreq->qual[psub].children[d2.seq].
      child_seq, ensbillitemrequest->bill_item[count1].parent_qual_ind = 0, ensbillitemrequest->
      bill_item[count1].active_ind_ind = 1,
      ensbillitemrequest->bill_item[count1].active_ind = 1, ensbillitemrequest->bill_item[count1].
      action_type = "ADD"
     ENDIF
    WITH outerjoin = d2, dontexist, nocounter
   ;end select
   SELECT INTO "nl:"
    d1.seq
    FROM bill_item b,
     (dummyt d1  WITH seq = value(ensbillitemrequest->bill_item_qual))
    PLAN (d1)
     JOIN (b
     WHERE (b.ext_parent_reference_id=ensbillitemrequest->bill_item[d1.seq].ext_child_reference_id)
      AND (b.ext_parent_contributor_cd=ensbillitemrequest->bill_item[d1.seq].ext_child_contributor_cd
     )
      AND ((b.ext_child_reference_id+ 0)=0)
      AND ((b.ext_child_contributor_cd+ 0)=0))
    DETAIL
     ensbillitemrequest->bill_item[d1.seq].parent_qual_ind = 1
    WITH nocounter
   ;end select
   IF ((ensbillitemrequest->bill_item_qual > 0))
    SET action_begin = 1
    SET action_end = ensbillitemrequest->bill_item_qual
    SET ensbillitemrequest->logical_domain_id = holdreq->logical_domain_id
    SET ensbillitemrequest->logical_domain_enabled_ind = logicaldomainenabledind
    CALL echo("Execute AFC_ADD_BILL_ITEM")
    EXECUTE afc_add_bill_item  WITH replace("REQUEST","ENSBILLITEMREQUEST")
   ELSE
    CALL echo("NO CHILDREN TO ADD")
   ENDIF
   SET count1 = 0
   SET ensbillitemrequest->bill_item_qual = count1
   SELECT INTO "nl:"
    d2.seq, holdreq->qual[psub].children[d2.seq].ext_description, holdreq->qual[psub].children[d2.seq
    ].ext_short_desc,
    b.bill_item_id, b.ext_description, b.ext_short_desc
    FROM bill_item b,
     (dummyt d2  WITH seq = value(holdreq->qual[psub].child_qual))
    PLAN (d2
     WHERE (holdreq->qual[psub].children[d2.seq].ext_contributor_cd != taskcat))
     JOIN (b
     WHERE ((b.active_ind+ 0)=1)
      AND ((((b.ext_parent_reference_id+ 0)=0)
      AND ((b.ext_parent_contributor_cd+ 0)=0)
      AND (b.ext_child_reference_id=holdreq->qual[psub].children[d2.seq].ext_id)
      AND (b.ext_child_contributor_cd=holdreq->qual[psub].children[d2.seq].ext_contributor_cd)) OR ((
     b.ext_parent_reference_id=holdreq->qual[psub].children[d2.seq].ext_id)
      AND (b.ext_parent_contributor_cd=holdreq->qual[psub].children[d2.seq].ext_contributor_cd)
      AND ((b.ext_child_reference_id+ 0)=0)
      AND ((b.ext_child_contributor_cd+ 0)=0))) )
    DETAIL
     IF ((holdreq->qual[psub].children[d2.seq].ext_id != 0))
      count1 += 1, stat = alterlist(ensbillitemrequest->bill_item,count1), ensbillitemrequest->
      bill_item_qual = count1,
      ensbillitemrequest->bill_item[count1].ext_owner_cd =
      IF ((holdreq->qual[psub].children[d2.seq].ext_owner_cd > 0)) holdreq->qual[psub].children[d2
       .seq].ext_owner_cd
      ELSE holdreq->qual[psub].ext_owner_cd
      ENDIF
      , ensbillitemrequest->bill_item[count1].ext_sub_owner_cd =
      IF ((holdreq->qual[psub].children[d2.seq].ext_sub_owner_cd > 0)) holdreq->qual[psub].children[
       d2.seq].ext_sub_owner_cd
      ELSE holdreq->qual[psub].ext_sub_owner_cd
      ENDIF
      , ensbillitemrequest->bill_item[count1].workload_only_ind = holdreq->qual[psub].
      workload_only_ind,
      ensbillitemrequest->bill_item[count1].ext_parent_reference_id = 0, ensbillitemrequest->
      bill_item[count1].ext_parent_contributor_cd = 0, ensbillitemrequest->bill_item[count1].
      ext_child_reference_id = holdreq->qual[psub].children[d2.seq].ext_id,
      ensbillitemrequest->bill_item[count1].ext_child_contributor_cd = holdreq->qual[psub].children[
      d2.seq].ext_contributor_cd, ensbillitemrequest->bill_item[count1].ext_description = holdreq->
      qual[psub].children[d2.seq].ext_description, ensbillitemrequest->bill_item[count1].
      ext_short_desc = holdreq->qual[psub].children[d2.seq].ext_short_desc,
      ensbillitemrequest->bill_item[count1].parent_qual_ind = 0, ensbillitemrequest->bill_item[count1
      ].active_ind_ind = 1, ensbillitemrequest->bill_item[count1].active_ind = 1,
      ensbillitemrequest->bill_item[count1].action_type = "ADD"
     ENDIF
    WITH outerjoin = d2, dontexist, nocounter
   ;end select
   IF ((ensbillitemrequest->bill_item_qual > 0))
    SET action_begin = 1
    SET action_end = ensbillitemrequest->bill_item_qual
    SET ensbillitemrequest->logical_domain_id = holdreq->logical_domain_id
    SET ensbillitemrequest->logical_domain_enabled_ind = logicaldomainenabledind
    EXECUTE afc_add_bill_item  WITH replace("REQUEST","ENSBILLITEMREQUEST")
   ELSE
    CALL echo("NO DEFAULT CHILDREN TO ADD")
   ENDIF
 END ;Subroutine
 SUBROUTINE check_add_billcode(bi_id,bc_cd,bc,desc,cont_cd,owner_cd,bim1_int)
   SET stat = alterlist(ensbimrequest->bill_item_modifier,1)
   SET ensbimrequest->bill_item_modifier_qual = 1
   SET ensbimrequest->bill_item_modifier[1].action_type = "ADD"
   SET ensbimrequest->bill_item_modifier[1].bill_item_id = bi_id
   SET ensbimrequest->bill_item_modifier[1].key1_id = bc_cd
   SET ensbimrequest->bill_item_modifier[1].key6 = bc
   SET ensbimrequest->bill_item_modifier[1].key7 = desc
   IF (cont_cd=item_master_cd
    AND owner_cd=supplies_cd)
    SET ensbimrequest->bill_item_modifier[1].bill_item_type_cd = barcodecd
   ELSE
    SET ensbimrequest->bill_item_modifier[1].bill_item_type_cd = billcodecd
   ENDIF
   SET ensbimrequest->bill_item_modifier[1].bim1_int = bim1_int
   SET action_begin = 1
   SET action_end = 1
   EXECUTE afc_add_bill_item_modifier  WITH replace("REQUEST","ENSBIMREQUEST")
 END ;Subroutine
 SUBROUTINE check_add_price(bitem_id,ps_id,in_price)
   SET psi_id = 0.0
   SELECT INTO "nl:"
    p.price_sched_items_id
    FROM price_sched_items p
    WHERE p.bill_item_id=bitem_id
     AND p.price_sched_id=ps_id
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
     AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
    DETAIL
     psi_id = p.price_sched_items_id
    WITH nocounter
   ;end select
   SET price_count = 1
   SET enspsirequest->price_sched_items_qual = price_count
   SET stat = alterlist(enspsirequest->price_sched_items,price_count)
   IF (curqual=0)
    SET enspsirequest->price_sched_items[price_count].action_type = "ADD"
   ELSE
    SET enspsirequest->price_sched_items[price_count].action_type = "DEL"
    SET enspsirequest->price_sched_items[price_count].price_sched_items_id = psi_id
    SET enspsirequest->price_sched_items[price_count].price_sched_id = ps_id
    SET enspsirequest->price_sched_items[price_count].bill_item_id = bitem_id
    SET enspsirequest->price_sched_items[price_count].end_effective_dt_tm_ind = 1
    SET enspsirequest->price_sched_items[price_count].end_effective_dt_tm = cnvtdatetime(curdate,
     curtime)
    SET price_count += 1
    SET enspsirequest->price_sched_items_qual = price_count
    SET stat = alterlist(enspsirequest->price_sched_items,price_count)
    SET enspsirequest->price_sched_items[price_count].action_type = "ADD"
   ENDIF
   SET enspsirequest->price_sched_items[price_count].price_sched_id = ps_id
   SET enspsirequest->price_sched_items[price_count].bill_item_id = bitem_id
   SET enspsirequest->price_sched_items[price_count].price = in_price
   SET action_begin = 1
   SET action_end = 1
   IF ((enspsirequest->price_sched_items[price_count].action_type="ADD"))
    EXECUTE afc_add_price_sched_item  WITH replace("REQUEST","ENSPSIREQUEST")
   ELSEIF ((enspsirequest->price_sched_items[price_count].action_type="DEL"))
    EXECUTE afc_del_price_sched_item  WITH replace("REQUEST","ENSPSIREQUEST")
   ELSE
    CALL echo(concat("Invalid action_type ",enspsirequest->price_sched_items[price_count].action_type
      ))
   ENDIF
 END ;Subroutine
 SUBROUTINE check_add_item(str,tmp_id,tmp_cd)
   CALL echo(concat("%%%%%   str: ",str," item_id: ",cnvtstring(tmp_id)," item_cd: ",
     cnvtstring(tmp_cd),"  %%%%%"))
   SET ensbillitemrequest->bill_item_qual = 1
   SET stat = alterlist(ensbillitemrequest->bill_item,1)
   SET ensbillitemrequest->bill_item[1].bill_item_id = 0.0
   SET ensbillitemrequest->bill_item[1].action_type = "ADD"
   IF (str="Group")
    SELECT INTO "nl:"
     b.bill_item_id, b.ext_description, b.misc_ind,
     b.ext_short_desc
     FROM bill_item b
     WHERE b.ext_parent_reference_id=tmp_id
      AND b.ext_parent_contributor_cd=tmp_cd
      AND ((b.ext_child_reference_id+ 0)=0)
     DETAIL
      CALL echo(concat("## b.bill_item_id = ",cnvtstring(b.bill_item_id,17,2))), ensbillitemrequest->
      bill_item[1].bill_item_id = b.bill_item_id, ensbillitemrequest->bill_item[1].action_type =
      "UPT",
      reply->qual[psub].bill_item_id = b.bill_item_id, ensbillitemrequest->bill_item[1].misc_ind = b
      .misc_ind
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     b.bill_item_id, b.ext_description, b.misc_ind,
     b.ext_short_desc
     FROM bill_item b
     WHERE ((b.ext_parent_reference_id+ 0)=0)
      AND b.ext_child_reference_id=tmp_id
      AND b.ext_child_contributor_cd=tmp_cd
      AND ((b.active_ind+ 0)=1)
     DETAIL
      ensbillitemrequest->bill_item[1].bill_item_id = b.bill_item_id, ensbillitemrequest->bill_item[1
      ].active_ind_ind = 1, ensbillitemrequest->bill_item[1].active_ind = 1,
      ensbillitemrequest->bill_item[1].action_type = "UPT", reply->qual[psub].bill_item_id = b
      .bill_item_id, ensbillitemrequest->bill_item[1].misc_ind = b.misc_ind
     WITH nocounter
    ;end select
   ENDIF
   IF (str="Group")
    SET ensbillitemrequest->bill_item[1].ext_parent_reference_id = tmp_id
    SET ensbillitemrequest->bill_item[1].ext_parent_contributor_cd = tmp_cd
    SET ensbillitemrequest->bill_item[1].ext_child_reference_id = 0.0
    SET ensbillitemrequest->bill_item[1].ext_child_contributor_cd = 0.0
    SET ensbillitemrequest->bill_item[1].parent_qual_ind = 1
   ELSE
    SET ensbillitemrequest->bill_item[1].ext_parent_reference_id = 0.0
    SET ensbillitemrequest->bill_item[1].ext_parent_contributor_cd = 0.0
    SET ensbillitemrequest->bill_item[1].ext_child_reference_id = tmp_id
    SET ensbillitemrequest->bill_item[1].ext_child_contributor_cd = tmp_cd
    SET ensbillitemrequest->bill_item[1].parent_qual_ind = 0
   ENDIF
   SET ensbillitemrequest->bill_item[1].ext_description = holdreq->qual[psub].ext_description
   SET ensbillitemrequest->bill_item[1].ext_short_desc = holdreq->qual[psub].ext_short_desc
   SET ensbillitemrequest->bill_item[1].ext_owner_cd = holdreq->qual[psub].ext_owner_cd
   SET ensbillitemrequest->bill_item[1].ext_sub_owner_cd = holdreq->qual[psub].ext_sub_owner_cd
   SET ensbillitemrequest->bill_item[1].workload_only_ind = holdreq->qual[psub].workload_only_ind
   SET action_begin = 1
   SET action_end = 1
   IF (curqual=0)
    CALL echo("afc_add_bill_item")
    SET ensbillitemrequest->logical_domain_id = holdreq->logical_domain_id
    SET ensbillitemrequest->logical_domain_enabled_ind = logicaldomainenabledind
    EXECUTE afc_add_bill_item  WITH replace("REQUEST","ENSBILLITEMREQUEST")
    SET reply->qual[psub].bill_item_id = ensbillitemrequest->bill_item[1].bill_item_id
   ELSE
    CALL echo("afc_upt_bill_item")
    SET ensbillitemrequest->logical_domain_id = holdreq->logical_domain_id
    SET ensbillitemrequest->logical_domain_enabled_ind = logicaldomainenabledind
    EXECUTE afc_upt_bill_item  WITH replace("REQUEST","ENSBILLITEMREQUEST")
   ENDIF
   SET parent_id = reply->qual[psub].bill_item_id
 END ;Subroutine
 SUBROUTINE check_del_item(str,tmp_id,tmp_cd)
   CALL echo("CHECK_DEL_ITEM BEGIN")
   SET stat = alterlist(ensbillitemrequest->bill_item,1)
   SET ensbillitemrequest->bill_item[1].bill_item_id = 0.0
   IF (str="Group")
    SET ensbillitemrequest->bill_item_qual = 1
    SELECT INTO "nl:"
     b.bill_item_id
     FROM bill_item b
     WHERE b.ext_parent_reference_id=tmp_id
      AND b.ext_parent_contributor_cd=tmp_cd
      AND ((b.ext_child_reference_id+ 0)=0)
      AND ((b.active_ind+ 0)=1)
     DETAIL
      ensbillitemrequest->bill_item[1].bill_item_id = b.bill_item_id, ensbillitemrequest->bill_item[
      count1].action_type = "DEL"
     WITH nocounter
    ;end select
   ELSE
    SET count1 = 0
    SET ensbillitemrequest->bill_item_qual = count1
    SELECT INTO "nl:"
     b.bill_item_id
     FROM bill_item b
     WHERE ((b.ext_parent_reference_id+ 0) > 0)
      AND ((b.ext_parent_contributor_cd+ 0) > 0)
      AND b.ext_child_reference_id=tmp_id
      AND b.ext_child_contributor_cd=tmp_cd
      AND ((b.active_ind+ 0)=1)
     DETAIL
      count1 += 1, stat = alterlist(ensbillitemrequest->bill_item,count1), ensbillitemrequest->
      bill_item_qual = count1,
      ensbillitemrequest->bill_item[count1].bill_item_id = b.bill_item_id, ensbillitemrequest->
      bill_item[count1].action_type = "DEL"
     WITH nocounter
    ;end select
   ENDIF
   SET action_begin = 1
   SET action_end = ensbillitemrequest->bill_item_qual
   IF (curqual > 0)
    EXECUTE afc_del_bill_item  WITH replace("REQUEST","ENSBILLITEMREQUEST")
    SET reply->qual[psub].bill_item_id = ensbillitemrequest->bill_item[1].bill_item_id
   ENDIF
 END ;Subroutine
 SUBROUTINE initialize(str)
   DECLARE ridx = i2 WITH protect, noconstant(0)
   CALL echo("Initialize begin")
   SET reply->status_data.status = "F"
   SET reply->actioncnt = 0
   SET stat = alterlist(holdreq->qual,request->nbr_of_recs)
   FOR (psub = 1 TO request->nbr_of_recs)
     SET holdreq->qual[psub].action = request->qual[psub].action
     IF ((request->qual[psub].ext_id=0))
      SET holdreq->qual[psub].ext_id = 0.0
     ELSE
      SET holdreq->qual[psub].ext_id = request->qual[psub].ext_id
     ENDIF
     IF ((request->qual[psub].ext_contributor_cd=0))
      SET holdreq->qual[psub].ext_contributor_cd = 0.0
     ELSE
      SET holdreq->qual[psub].ext_contributor_cd = request->qual[psub].ext_contributor_cd
     ENDIF
     SET holdreq->qual[psub].ext_owner_cd = request->qual[psub].ext_owner_cd
     IF ((validate(request->qual[psub].ext_sub_owner_cd,- (0.00001)) != - (0.00001)))
      SET holdreq->qual[psub].ext_sub_owner_cd = request->qual[psub].ext_sub_owner_cd
     ENDIF
     SET holdreq->qual[psub].ext_description = request->qual[psub].ext_description
     SET holdreq->qual[psub].ext_short_desc = request->qual[psub].ext_short_desc
     SET holdreq->qual[psub].careset_ind = request->qual[psub].careset_ind
     IF (validate(request->qual[psub].workload_only_ind,999) != 999)
      SET holdreq->qual[psub].workload_only_ind = request->qual[psub].workload_only_ind
     ENDIF
     SET holdreq->qual[psub].parent_qual_ind = request->qual[psub].parent_qual_ind
     IF ((request->qual[psub].price_qual > 0))
      CALL echo("Price_Qual is present")
      SET holdreq->qual[psub].price_qual = request->qual[psub].price_qual
      SET stat = alterlist(holdreq->qual[psub].prices,holdreq->qual[psub].price_qual)
      FOR (i = 1 TO request->qual[psub].price_qual)
       SET holdreq->qual[psub].prices[i].price_sched_id = request->qual[psub].prices[i].
       price_sched_id
       SET holdreq->qual[psub].prices[i].price = request->qual[psub].prices[i].price
      ENDFOR
     ELSE
      SET holdreq->qual[psub].price_qual = 0
     ENDIF
     IF ((request->qual[psub].billcode_qual > 0))
      CALL echo("BillCode_Qual is present")
      SET holdreq->qual[psub].billcode_qual = request->qual[psub].billcode_qual
      SET stat = alterlist(holdreq->qual[psub].billcodes,holdreq->qual[psub].billcode_qual)
      FOR (i = 1 TO request->qual[psub].billcode_qual)
        SET holdreq->qual[psub].billcodes[i].billcode_sched_cd = request->qual[psub].billcodes[i].
        billcode_sched_cd
        SET holdreq->qual[psub].billcodes[i].billcode = request->qual[psub].billcodes[i].billcode
        SET holdreq->qual[psub].billcodes[i].bim1_int = validate(request->qual[psub].billcodes[i].
         bim1_int,0)
      ENDFOR
     ELSE
      SET holdreq->qual[psub].billcode_qual = 0
     ENDIF
     IF ((request->qual[psub].careset_ind=1))
      SELECT INTO "nl:"
       ext_id = request->qual[psub].children[d1.seq].ext_id
       FROM (dummyt d1  WITH seq = value(request->qual[psub].child_qual))
       PLAN (d1
        WHERE (request->qual[psub].children[d1.seq].ext_id > 0.0))
       ORDER BY ext_id
       HEAD ext_id
        ridx += 1, stat = alterlist(holdreq->qual[psub].children,ridx), holdreq->qual[psub].children[
        ridx].ext_id = request->qual[psub].children[d1.seq].ext_id
        IF ((request->qual[psub].children[d1.seq].ext_contributor_cd=0))
         holdreq->qual[psub].children[ridx].ext_contributor_cd = 0.0
        ELSE
         holdreq->qual[psub].children[ridx].ext_contributor_cd = request->qual[psub].children[d1.seq]
         .ext_contributor_cd
        ENDIF
        holdreq->qual[psub].children[ridx].ext_description = request->qual[psub].children[d1.seq].
        ext_description, holdreq->qual[psub].children[ridx].ext_short_desc = request->qual[psub].
        children[d1.seq].ext_short_desc, holdreq->qual[psub].children[ridx].ext_owner_cd = request->
        qual[psub].children[d1.seq].ext_owner_cd,
        msstat = assign(holdreq->qual[psub].children[ridx].ext_sub_owner_cd,validate(request->qual[
          psub].children[d1.seq].ext_sub_owner_cd,0.0))
       WITH nocounter
      ;end select
      SET holdreq->qual[psub].child_qual = ridx
     ELSE
      SET holdreq->qual[psub].child_qual = size(request->qual[psub].children,5)
      SET stat = alterlist(holdreq->qual[psub].children,holdreq->qual[psub].child_qual)
      FOR (i = 1 TO holdreq->qual[psub].child_qual)
        IF ((request->qual[psub].children[i].ext_id=0))
         SET holdreq->qual[psub].children[i].ext_id = 0.0
        ELSE
         SET holdreq->qual[psub].children[i].ext_id = request->qual[psub].children[i].ext_id
        ENDIF
        IF ((request->qual[psub].children[i].ext_contributor_cd=0))
         SET holdreq->qual[psub].children[i].ext_contributor_cd = 0.0
        ELSE
         SET holdreq->qual[psub].children[i].ext_contributor_cd = request->qual[psub].children[i].
         ext_contributor_cd
        ENDIF
        SET holdreq->qual[psub].children[i].ext_description = request->qual[psub].children[i].
        ext_description
        SET holdreq->qual[psub].children[i].ext_short_desc = request->qual[psub].children[i].
        ext_short_desc
        SET holdreq->qual[psub].children[i].ext_owner_cd = request->qual[psub].children[i].
        ext_owner_cd
        IF ((validate(request->qual[psub].children[i].ext_sub_owner_cd,- (0.00001)) != - (0.00001)))
         SET holdreq->qual[psub].children[i].ext_sub_owner_cd = request->qual[psub].children[i].
         ext_sub_owner_cd
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   IF (validate(request->logical_domain_id))
    IF (validate(request->logical_domain_enabled_ind))
     SET logicaldomainenabledind = request->logical_domain_enabled_ind
    ELSE
     SET logicaldomainenabledind = true
    ENDIF
    SET holdreq->logical_domain_id = request->logical_domain_id
   ENDIF
 END ;Subroutine
#end_program
 FREE SET holdreq
 SET load_end = cnvtdatetime(sysdate)
 CALL echo("LOAD START: ",0)
 CALL echo(format(load_start,"hh:mm:ss;;s"))
 CALL echo("LOAD END: ",0)
 CALL echo(format(load_end,"hh:mm:ss;;s"))
 CALL echo("Total Children: ",0)
 CALL echo(update_children_count,0)
END GO
