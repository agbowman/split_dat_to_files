CREATE PROGRAM bed_ens_bb_product
 FREE SET reply
 RECORD reply(
   1 product_list[*]
     2 product_id = f8
     2 product_code_value = f8
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET t_reply
 RECORD t_reply(
   1 product_list[*]
     2 product_id = f8
     2 product_cd = f8
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET prodrec
 RECORD prodrec(
   1 plist[*]
     2 pcode = f8
     2 pdisp = vc
 )
 DECLARE error_msg = vc
 DECLARE error_flag = vc
 DECLARE numrows = i4
 DECLARE prodcat_id = f8
 DECLARE display = vc
 DECLARE description = vc
 DECLARE dup = vc
 DECLARE hold_code_value = f8
 DECLARE next_code = f8
 DECLARE inactive_cd = f8
 DECLARE active_cd = f8
 DECLARE auth_data_status_cd = f8
 DECLARE repcnt = i4
 DECLARE billcnt = i4
 DECLARE selected_ind = i2
 DECLARE bbactcd = f8
 DECLARE bbowncd = f8
 SET t_reply->status_data.status = "F"
 SET error_flag = "F"
 SET repcnt = 0
 SET billcnt = 0
 SET display = fillstring(40," ")
 SET description = fillstring(60," ")
 SET numrows = size(request->product_list,5)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=48
    AND cv.cdf_meaning="INACTIVE"
    AND cv.active_ind=1)
  DETAIL
   inactive_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=48
    AND cv.cdf_meaning="ACTIVE"
    AND cv.active_ind=1)
  DETAIL
   active_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=8
    AND cv.cdf_meaning="AUTH"
    AND cv.active_ind=1)
  DETAIL
   auth_data_status_cd = cv.code_value
  WITH nocounter
 ;end select
 FOR (x = 1 TO numrows)
   IF ((request->product_list[x].action_flag=1))
    CALL add_product(x)
   ELSEIF ((request->product_list[x].action_flag=2))
    CALL update_product(x)
   ELSEIF ((request->product_list[x].action_flag=3))
    CALL remove_product(x)
   ELSEIF ((request->product_list[x].action_flag=0))
    SET stat = x
   ELSE
    SET error_flag = "T"
    SET error_msg = concat("Invalid action_flag for product_id: ",cnvtstring(request->product_list[x]
      .product_id)," Action flag: ",cnvtstring(request->product_list[x].action_flag))
    GO TO exit_script
   ENDIF
 ENDFOR
 GO TO exit_script
 SUBROUTINE add_product(x)
   DECLARE barcode = vc
   SET auto_ind = 0
   SET dir_ind = 0
   SET max_days = 0
   SET max_hours = 0
   SET calc_ind = 0
   SET vol_def = 0
   DECLARE def_supp = vc
   DECLARE aborh = vc
   SET disp_ind = 0
   SET min_bef = 0
   SET anti_ind = 0
   SET transf_ind = 0
   SET int_units = 0
   DECLARE def_temp = vc
   SET aliquot = 0
   SELECT INTO "nl"
    FROM br_bb_product bp
    PLAN (bp
     WHERE (bp.product_id=request->product_list[x].product_id))
    DETAIL
     prodcat_id = bp.prodcat_id, display = bp.display, description = bp.description,
     selected_ind = bp.selected_ind, barcode = bp.bar_code_val, auto_ind = bp.auto_ind,
     dir_ind = bp.directed_ind
     IF (cnvtupper(bp.max_exp_unit)="HOURS")
      max_hours = bp.max_exp_val
     ELSE
      max_hours = 0
     ENDIF
     IF (cnvtupper(bp.max_exp_unit)="DAYS")
      max_days = bp.max_exp_val
     ELSE
      max_days = 0
     ENDIF
     calc_ind = bp.calc_exp_from_draw_ind, vol_def = bp.volume_def, def_supp = bp.def_supplier,
     aborh = bp.aborh_conf_test_name, disp_ind = bp.dispense_ind, min_bef = bp.min_bef_quar,
     anti_ind = bp.validate_antibody_ind, transf_ind = bp.validate_transf_req_ind, int_units = bp
     .int_units_ind,
     def_temp = bp.def_storage_temp, aliquot = bp.aliquot_ind
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat("Unable to add product from product_id: ",cnvtstring(request->
      product_list[x].product_id)," Product not found on BR_BB_PRODUCT table.")
    GO TO exit_script
   ELSEIF (selected_ind=1)
    SET error_flag = "T"
    SET error_msg = concat("Unable to add product from product_id: ",cnvtstring(request->
      product_list[x].product_id)," Product already selected on BR_BB_PRODUCT table.")
    GO TO exit_script
   ENDIF
   SET dup = "N"
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=1604
      AND cnvtupper(cv.display)=cnvtupper(display))
    DETAIL
     dup = "Y", hold_code_value = cv.code_value
    WITH nocounter
   ;end select
   IF (dup="N")
    SET hold_code_value = 0.0
    SET next_code = 0.0
    EXECUTE cpm_next_code
    INSERT  FROM code_value cv
     SET cv.begin_effective_dt_tm = cnvtdatetime(curdate,curtime), cv.cdf_meaning = "", cv.cki = "",
      cv.code_set = 1604, cv.code_value = next_code, cv.collation_seq = 0,
      cv.concept_cki = "", cv.definition = description, cv.description = description,
      cv.display = display, cv.display_key = cnvtupper(cnvtalphanum(display)), cv.end_effective_dt_tm
       = cnvtdatetime("31-DEC-2100 00:00:00.00"),
      cv.active_ind = 0, cv.active_dt_tm = cnvtdatetime(curdate,curtime3), cv.active_type_cd =
      inactive_cd,
      cv.data_status_cd = auth_data_status_cd, cv.data_status_dt_tm = cnvtdatetime(curdate,curtime3),
      cv.data_status_prsnl_id = reqinfo->updt_id,
      cv.active_status_prsnl_id = reqinfo->updt_id, cv.updt_cnt = 0, cv.updt_id = reqinfo->updt_id,
      cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->updt_applctx, cv.updt_dt_tm =
      cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
    IF (curqual > 0)
     SET hold_code_value = next_code
    ELSE
     SET error_flag = "T"
     SET error_msg = concat("Error creating code value on code set 1604 for product_id: ",cnvtstring(
       request->product_list[x].product_id))
     GO TO exit_script
    ENDIF
    INSERT  FROM product_index pi
     SET pi.product_cd = hold_code_value, pi.product_cat_cd = 0.0, pi.product_class_cd = 0.0,
      pi.autologous_ind = auto_ind, pi.directed_ind = dir_ind, pi.allow_dispense_ind = disp_ind,
      pi.default_volume = vol_def, pi.max_days_expire = max_days, pi.max_hrs_expire = max_hours,
      pi.default_supplier_id = 0, pi.synonym_id = 0.0, pi.auto_quarantine_min = min_bef,
      pi.active_ind = 0, pi.active_status_cd = inactive_cd, pi.active_status_dt_tm = cnvtdatetime(
       curdate,curtime),
      pi.active_status_prsnl_id = reqinfo->updt_id, pi.updt_cnt = 0, pi.updt_dt_tm = cnvtdatetime(
       curdate,curtime),
      pi.updt_id = reqinfo->updt_id, pi.updt_applctx = reqinfo->updt_applctx, pi.updt_task = reqinfo
      ->updt_task,
      pi.intl_units_ind = int_units, pi.auto_bill_item_cd = 0.0, pi.dir_bill_item_cd = 0.0,
      pi.validate_ag_ab_ind = anti_ind, pi.validate_trans_req_ind = transf_ind, pi.storage_temp_cd =
      0.0,
      pi.drawn_dt_tm_ind = calc_ind, pi.aliquot_ind = aliquot
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "T"
     SET error_msg = concat("Unable to add product to product_index table for product_id: ",
      cnvtstring(request->product_list[x].product_id))
     GO TO exit_script
    ENDIF
   ENDIF
   UPDATE  FROM br_bb_product bp
    SET bp.product_cd = hold_code_value, bp.selected_ind = 1, bp.updt_applctx = reqinfo->updt_applctx,
     bp.updt_cnt = (bp.updt_cnt+ 1), bp.updt_dt_tm = cnvtdatetime(curdate,curtime), bp.updt_id =
     reqinfo->updt_id,
     bp.updt_task = reqinfo->updt_task, bp.active_ind = 0
    WHERE (bp.product_id=request->product_list[x].product_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat("Unable to update product on br_bb_product table for product_id: ",
     cnvtstring(request->product_list[x].product_id))
    GO TO exit_script
   ENDIF
   IF (prodcat_id > 0.0)
    UPDATE  FROM br_bb_prodcat bc
     SET bc.selected_ind = 1, bc.updt_applctx = reqinfo->updt_applctx, bc.updt_cnt = (bc.updt_cnt+ 1),
      bc.updt_dt_tm = cnvtdatetime(curdate,curtime), bc.updt_id = reqinfo->updt_id, bc.updt_task =
      reqinfo->updt_task
     WHERE bc.prodcat_id=prodcat_id
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "T"
     SET error_msg = concat(
      "Unable to update product category on br_bb_prodcat table for product_id: ",cnvtstring(request
       ->product_list[x].product_id))
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE update_product(x)
   SET error_flag = "T"
   SET error_msg = "Product update not supported - program terminating"
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE remove_product(x)
   SELECT INTO "nl"
    FROM br_bb_product bp
    PLAN (bp
     WHERE (bp.product_id=request->product_list[x].product_id))
    DETAIL
     hold_code_value = bp.product_cd
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat("No product found to remove on br_bb_product table for product_id: ",
     cnvtstring(request->product_list[x].product_id))
    GO TO exit_script
   ENDIF
   UPDATE  FROM br_bb_product bp
    SET bp.selected_ind = 0, bp.updt_applctx = reqinfo->updt_applctx, bp.updt_cnt = (bp.updt_cnt+ 1),
     bp.updt_dt_tm = cnvtdatetime(curdate,curtime), bp.updt_id = reqinfo->updt_id, bp.updt_task =
     reqinfo->updt_task,
     bp.active_ind = 0
    WHERE (bp.product_id=request->product_list[x].product_id)
   ;end update
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat("Unable to update product on br_bb_product table for product_id: ",
     cnvtstring(request->product_list[x].product_id))
    GO TO exit_script
   ENDIF
   IF (hold_code_value > 0)
    UPDATE  FROM code_value cv
     SET cv.active_ind = 0, cv.begin_effective_dt_tm = cnvtdatetime(curdate,curtime), cv
      .end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
      cv.active_dt_tm = cnvtdatetime(curdate,curtime3), cv.active_type_cd = inactive_cd, cv
      .data_status_cd = auth_data_status_cd,
      cv.data_status_dt_tm = cnvtdatetime(curdate,curtime3), cv.data_status_prsnl_id = reqinfo->
      updt_id, cv.active_status_prsnl_id = reqinfo->updt_id,
      cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_id = reqinfo->updt_id, cv.updt_task = reqinfo->
      updt_task,
      cv.updt_applctx = reqinfo->updt_applctx, cv.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WHERE cv.code_value=hold_code_value
      AND cv.code_set=1604
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "T"
     SET error_msg = concat("Error inactivating code value on code set 1604 for product_id: ",
      cnvtstring(request->product_list[x].product_id))
     GO TO exit_script
    ENDIF
    UPDATE  FROM product_index pi
     SET pi.active_ind = 0, pi.product_cat_cd = 0.0, pi.active_status_cd = inactive_cd,
      pi.active_status_dt_tm = cnvtdatetime(curdate,curtime), pi.active_status_prsnl_id = reqinfo->
      updt_id, pi.updt_cnt = (pi.updt_cnt+ 1),
      pi.updt_dt_tm = cnvtdatetime(curdate,curtime), pi.updt_id = reqinfo->updt_id, pi.updt_applctx
       = reqinfo->updt_applctx,
      pi.updt_task = reqinfo->updt_task
     WHERE pi.product_cd=hold_code_value
     WITH nocounter
    ;end update
   ENDIF
 END ;Subroutine
 SUBROUTINE add_billing(x)
   FREE SET request
   RECORD request(
     1 nbr_of_recs = i2
     1 qual[*]
       2 action = i2
       2 ext_id = f8
       2 ext_contributor_cd = f8
       2 parent_qual_ind = f8
       2 careset_ind = i2
       2 ext_owner_cd = f8
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
       2 child_qual = i2
       2 children[*]
         3 ext_id = f8
         3 ext_contributor_cd = f8
         3 ext_description = c100
         3 ext_short_desc = c50
         3 child_seq = i4
         3 bi_id = f8
         3 ext_owner_cd = f8
   )
   SET stat = alterlist(request->qual,billcnt)
   SET request->nbr_of_recs = billcnt
   IF (repcnt > 0)
    IF (billcnt > 0)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = billcnt)
      PLAN (d)
      DETAIL
       request->qual[d.seq].action = 1, request->qual[d.seq].ext_id = prodrec->plist[d.seq].pcode,
       request->qual[d.seq].ext_contributor_cd = bbactcd,
       request->qual[d.seq].parent_qual_ind = 1, request->qual[d.seq].ext_description = prodrec->
       plist[d.seq].pdisp, request->qual[d.seq].ext_short_desc = prodrec->plist[d.seq].pdisp,
       request->qual[d.seq].ext_owner_cd = bbowncd, request->qual[d.seq].billcode_qual = 0, request->
       qual[d.seq].child_qual = 0,
       request->qual[d.seq].price_qual = 0
      WITH nocounter
     ;end select
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
     EXECUTE afc_add_reference_api
     IF ((reply->status_data.status != "S"))
      SET error_flag = "T"
      SET error_msg = "Error creating bill items - program terminating"
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
#exit_script
 IF (error_flag="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  CALL echo(error_msg)
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_BB_PRODUCT","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
