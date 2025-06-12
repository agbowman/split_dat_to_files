CREATE PROGRAM bbt_add_bb_mod_option:dba
 RECORD reply(
   1 option_id = f8
   1 new_prods[*]
     2 mod_new_prod_id = f8
     2 orig_product_cd = f8
     2 new_product_cd = f8
     2 orig_plasma_prod_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD err_chk(
   1 failed_ind = i2
   1 qual[*]
     2 status = i4
     2 error_nbr = i4
     2 error_msg = vc
 )
 SET reply->status_data.status = "F"
 SET modify = predeclare
 DECLARE display_key_new = vc WITH noconstant(" ")
 DECLARE mop_cnt = i4 WITH noconstant(0)
 DECLARE mnp_cnt = i4 WITH noconstant(0)
 DECLARE mst_cnt = i4 WITH noconstant(0)
 DECLARE md_cnt = i4 WITH noconstant(0)
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE yr = i2 WITH noconstant(0)
 DECLARE bb_mod_pool_nbr_id = f8 WITH noconstant(0.0)
 DECLARE errmsg = c132 WITH noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH noconstant(error(errmsg,1))
 DECLARE errcnt = i4 WITH noconstant(0)
 DECLARE stat = i4 WITH noconstant(0)
 SET display_key_new = cnvtupper(cnvtalphanum(request->display))
 SELECT INTO "nl:"
  mo.display_key
  FROM bb_mod_option mo
  PLAN (mo
   WHERE mo.display_key=display_key_new)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET errmsg = build("Display key not unique:",display_key_new)
  CALL errorhandler("SELECT","F","BB_MOD_OPTION",errmsg)
  SET reqinfo->commit_ind = 0
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  y = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   reply->option_id = y
  WITH format, counter
 ;end select
 IF (curqual=0)
  SET errmsg = "Unable to obtain reference sequence id"
  CALL errorhandler("SELECT","F","DUAL",errmsg)
  SET reqinfo->commit_ind = 0
  GO TO exit_script
 ENDIF
 INSERT  FROM bb_mod_option mo
  SET mo.option_id = reply->option_id, mo.display = request->display, mo.display_key =
   display_key_new,
   mo.beg_effective_dt_tm = cnvtdatetime(sysdate), mo.end_effective_dt_tm = cnvtdatetime(
    "31-DEC-2100 23:59:59.99"), mo.new_product_ind = request->new_product_ind,
   mo.split_ind = request->split_ind, mo.ad_hoc_ind = request->ad_hoc_ind, mo.change_attribute_ind =
   request->change_attribute_ind,
   mo.crossover_ind = request->crossover_ind, mo.pool_product_ind = request->pool_product_ind, mo
   .generate_prod_nbr_ind = request->generate_prod_nbr_ind,
   mo.prod_nbr_prefix = request->prod_nbr_prefix, mo.prod_nbr_ccyy_ind = request->prod_nbr_ccyy_ind,
   mo.prod_nbr_starting_nbr = request->prod_nbr_starting_nbr,
   mo.dispose_orig_ind = request->dispose_orig_ind, mo.chg_orig_exp_dt_ind = request->
   chg_orig_exp_dt_ind, mo.orig_nbr_days_exp = request->orig_nbr_days_exp,
   mo.orig_nbr_hrs_exp = request->orig_nbr_hrs_exp, mo.active_ind = request->active_ind, mo
   .active_status_cd =
   IF ((request->active_ind=1)) reqdata->active_status_cd
   ELSE reqdata->inactive_status_cd
   ENDIF
   ,
   mo.active_status_dt_tm = cnvtdatetime(sysdate), mo.active_status_prsnl_id = reqinfo->updt_id, mo
   .updt_applctx = reqinfo->updt_applctx,
   mo.updt_task = reqinfo->updt_task, mo.updt_dt_tm = cnvtdatetime(sysdate), mo.updt_id = reqinfo->
   updt_id,
   mo.updt_cnt = 0, mo.label_info_prompt_ind = request->label_info_prompt_ind, mo
   .generate_isbt_nbr_ind = request->generate_isbt_nbr_ind,
   mo.recon_rbc_ind = request->recon_rbc_ind
  WITH nocounter
 ;end insert
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("INSERT","F","BB_MOD_OPTION",errmsg)
  SET reqinfo->commit_ind = 0
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  SET errmsg = "Insert failed."
  CALL errorhandler("INSERT","F","BB_MOD_OPTION",errmsg)
  SET reqinfo->commit_ind = 0
  GO TO exit_script
 ENDIF
 SET mop_cnt = size(request->orig_prods,5)
 IF (mop_cnt=0)
  SET errmsg = "No original products found in request."
  CALL errorhandler("SIZE","F","REQUEST->ORIG_PRODS",errmsg)
  SET reqinfo->commit_ind = 0
  GO TO exit_script
 ENDIF
 SET stat = alterlist(err_chk->qual,mop_cnt)
 INSERT  FROM (dummyt d  WITH seq = value(mop_cnt)),
   bb_mod_orig_product mop
  SET mop.option_id = reply->option_id, mop.orig_product_cd = request->orig_prods[d.seq].
   orig_product_cd, mop.updt_applctx = reqinfo->updt_applctx,
   mop.updt_task = reqinfo->updt_task, mop.updt_dt_tm = cnvtdatetime(sysdate), mop.updt_id = reqinfo
   ->updt_id,
   mop.updt_cnt = 0
  PLAN (d)
   JOIN (mop
   WHERE (mop.option_id=reply->option_id)
    AND (mop.orig_product_cd=request->orig_prods[d.seq].orig_product_cd))
  WITH nocounter, status(err_chk->qual[d.seq].status,err_chk->qual[d.seq].error_nbr,err_chk->qual[d
   .seq].error_msg)
 ;end insert
 SET err_chk->failed_ind = 0
 FOR (errcnt = 1 TO mop_cnt)
   IF ((err_chk->qual[errcnt].status=0))
    SET errmsg = build("Error (",err_chk->qual[errcnt].error_nbr,"):",err_chk->qual[errcnt].error_msg
     )
    CALL errorhandler("INSERT","F","BB_MOD_ORIG_PRODUCT",errmsg)
    SET err_chk->failed_ind = 1
   ENDIF
 ENDFOR
 IF ((err_chk->failed_ind=1))
  SET reqinfo->commit_ind = 0
  GO TO exit_script
 ENDIF
 SET mnp_cnt = size(request->new_prods,5)
 IF (mnp_cnt=0)
  SET errmsg = "No new products found in request."
  CALL errorhandler("SIZE","F","REQUEST->NEW_PRODS",errmsg)
  SET reqinfo->commit_ind = 0
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->new_prods,mnp_cnt)
 FOR (cnt = 1 TO mnp_cnt)
   SET reply->new_prods[cnt].orig_product_cd = request->new_prods[cnt].orig_product_cd
   SET reply->new_prods[cnt].new_product_cd = request->new_prods[cnt].new_product_cd
   SET reply->new_prods[cnt].orig_plasma_prod_cd = request->new_prods[cnt].orig_plasma_prod_cd
   SELECT INTO "nl:"
    y = seq(reference_seq,nextval)
    FROM dual
    DETAIL
     reply->new_prods[cnt].mod_new_prod_id = y
    WITH format, counter
   ;end select
   IF (curqual=0)
    SET errmsg = "Unable to obtain reference sequence id"
    CALL errorhandler("SELECT","F","DUAL",errmsg)
    SET reqinfo->commit_ind = 0
    GO TO exit_script
   ENDIF
 ENDFOR
 SET stat = alterlist(err_chk->qual,mnp_cnt)
 INSERT  FROM (dummyt d  WITH seq = value(mnp_cnt)),
   bb_mod_new_product mnp
  SET mnp.mod_new_prod_id = reply->new_prods[d.seq].mod_new_prod_id, mnp.option_id = reply->option_id,
   mnp.orig_product_cd = request->new_prods[d.seq].orig_product_cd,
   mnp.new_product_cd = request->new_prods[d.seq].new_product_cd, mnp.orig_plasma_prod_cd = request->
   new_prods[d.seq].orig_plasma_prod_cd, mnp.quantity = request->new_prods[d.seq].quantity,
   mnp.default_sub_id_flag = request->new_prods[d.seq].default_sub_id_flag, mnp.max_prep_hrs =
   request->new_prods[d.seq].max_prep_hrs, mnp.default_orig_exp_ind = request->new_prods[d.seq].
   default_orig_exp_ind,
   mnp.calc_exp_drawn_ind = request->new_prods[d.seq].calc_exp_drawn_ind, mnp.default_exp_days =
   request->new_prods[d.seq].default_exp_days, mnp.default_exp_hrs = request->new_prods[d.seq].
   default_exp_hrs,
   mnp.allow_extend_exp_ind = request->new_prods[d.seq].allow_extend_exp_ind, mnp
   .default_orig_vol_ind = request->new_prods[d.seq].default_orig_vol_ind, mnp.default_volume =
   request->new_prods[d.seq].default_volume,
   mnp.calc_vol_ind = request->new_prods[d.seq].calc_vol_ind, mnp.prompt_vol_ind = request->
   new_prods[d.seq].prompt_vol_ind, mnp.validate_vol_ind = request->new_prods[d.seq].validate_vol_ind,
   mnp.default_unit_of_meas_cd = request->new_prods[d.seq].default_unit_of_meas_cd, mnp.synonym_id =
   request->new_prods[d.seq].synonym_id, mnp.require_assign_ind = request->new_prods[d.seq].
   require_assign_ind,
   mnp.bag_type_cd = request->new_prods[d.seq].bag_type_cd, mnp.crossover_reason_cd = request->
   new_prods[d.seq].crossover_reason_cd, mnp.allow_no_aborh_ind = request->new_prods[d.seq].
   allow_no_aborh_ind,
   mnp.default_supplier_id = request->new_prods[d.seq].default_supplier_id, mnp.updt_applctx =
   reqinfo->updt_applctx, mnp.updt_task = reqinfo->updt_task,
   mnp.updt_dt_tm = cnvtdatetime(sysdate), mnp.updt_id = reqinfo->updt_id, mnp.updt_cnt = 0,
   mnp.isbt_barcode = request->new_prods[d.seq].default_isbt_barcode, mnp.codabar_barcode = request->
   new_prods[d.seq].default_codabar_barcode
  PLAN (d)
   JOIN (mnp
   WHERE (mnp.mod_new_prod_id=reply->new_prods[d.seq].mod_new_prod_id))
  WITH nocounter, status(err_chk->qual[d.seq].status,err_chk->qual[d.seq].error_nbr,err_chk->qual[d
   .seq].error_msg)
 ;end insert
 SET err_chk->failed_ind = 0
 FOR (errcnt = 1 TO mnp_cnt)
   IF ((err_chk->qual[errcnt].status=0))
    SET errmsg = build("Error (",err_chk->qual[errcnt].error_nbr,"):",err_chk->qual[errcnt].error_msg
     )
    CALL errorhandler("INSERT","F","BB_MOD_NEW_PRODUCT",errmsg)
    SET err_chk->failed_ind = 1
   ENDIF
 ENDFOR
 IF ((err_chk->failed_ind=1))
  SET reqinfo->commit_ind = 0
  GO TO exit_script
 ENDIF
 FOR (cnt = 1 TO mnp_cnt)
  SET mst_cnt = size(request->new_prods[cnt].spec_testings,5)
  IF (mst_cnt > 0)
   SET stat = alterlist(err_chk->qual,mst_cnt)
   INSERT  FROM (dummyt d  WITH seq = value(mst_cnt)),
     bb_mod_special_testing mst
    SET mst.mod_new_prod_id = reply->new_prods[cnt].mod_new_prod_id, mst.special_testing_cd = request
     ->new_prods[cnt].spec_testings[d.seq].special_testing_cd, mst.updt_applctx = reqinfo->
     updt_applctx,
     mst.updt_task = reqinfo->updt_task, mst.updt_dt_tm = cnvtdatetime(sysdate), mst.updt_id =
     reqinfo->updt_id,
     mst.updt_cnt = 0
    PLAN (d)
     JOIN (mst
     WHERE (mst.mod_new_prod_id=reply->new_prods[cnt].mod_new_prod_id)
      AND (mst.special_testing_cd=request->new_prods[cnt].spec_testings[d.seq].special_testing_cd))
    WITH nocounter, status(err_chk->qual[d.seq].status,err_chk->qual[d.seq].error_nbr,err_chk->qual[d
     .seq].error_msg)
   ;end insert
   SET err_chk->failed_ind = 0
   FOR (errcnt = 1 TO mst_cnt)
     IF ((err_chk->qual[errcnt].status=0))
      SET errmsg = build("Error (",err_chk->qual[errcnt].error_nbr,"):",err_chk->qual[errcnt].
       error_msg)
      CALL errorhandler("INSERT","F","BB_MOD_SPECIAL_TESTING",errmsg)
      SET err_chk->failed_ind = 1
     ENDIF
   ENDFOR
   IF ((err_chk->failed_ind=1))
    SET reqinfo->commit_ind = 0
    GO TO exit_script
   ENDIF
  ENDIF
 ENDFOR
 IF ((request->generate_prod_nbr_ind=1))
  SET yr = year(cnvtdatetime(sysdate))
  SELECT INTO "nl:"
   mpn.option_id, mpn.prefix, mpn.year
   FROM bb_mod_pool_nbr mpn
   PLAN (mpn
    WHERE (mpn.option_id=reply->option_id)
     AND (mpn.prefix=request->prod_nbr_prefix)
     AND mpn.year=yr)
   WITH nocounter
  ;end select
  SET error_check = error(errmsg,0)
  IF (error_check != 0)
   CALL errorhandler("SELECT","F","BB_MOD_POOL_NBR",errmsg)
   SET reqinfo->commit_ind = 0
   GO TO exit_script
  ENDIF
  IF (curqual=0)
   SELECT INTO "nl:"
    y = seq(reference_seq,nextval)
    FROM dual
    DETAIL
     bb_mod_pool_nbr_id = y
    WITH format, counter
   ;end select
   IF (curqual=0)
    SET errmsg = "Unable to obtain reference sequence id"
    CALL errorhandler("SELECT","F","DUAL",errmsg)
    SET reqinfo->commit_ind = 0
    GO TO exit_script
   ENDIF
   INSERT  FROM bb_mod_pool_nbr mpn
    SET mpn.mod_pool_nbr_id = bb_mod_pool_nbr_id, mpn.option_id = reply->option_id, mpn.prefix =
     request->prod_nbr_prefix,
     mpn.year = yr, mpn.seq_nbr = (request->prod_nbr_starting_nbr - 1), mpn.updt_applctx = reqinfo->
     updt_applctx,
     mpn.updt_task = reqinfo->updt_task, mpn.updt_dt_tm = cnvtdatetime(sysdate), mpn.updt_id =
     reqinfo->updt_id,
     mpn.updt_cnt = 0
    WITH nocounter
   ;end insert
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("INSERT","F","BB_MOD_POOL_NBR",errmsg)
    SET reqinfo->commit_ind = 0
    GO TO exit_script
   ENDIF
   IF (curqual=0)
    SET errmsg = "Insert failed."
    CALL errorhandler("INSERT","F","BB_MOD_POOL_NBR",errmsg)
    SET reqinfo->commit_ind = 0
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 SET md_cnt = size(request->devices,5)
 IF (md_cnt=0)
  GO TO set_status
 ENDIF
 SET stat = alterlist(err_chk->qual,md_cnt)
 INSERT  FROM (dummyt d  WITH seq = value(md_cnt)),
   bb_mod_device md
  SET md.option_id = reply->option_id, md.device_type_cd = request->devices[d.seq].device_type_cd, md
   .default_ind = request->devices[d.seq].default_ind,
   md.max_capacity = request->devices[d.seq].max_capacity, md.start_stop_time_ind = request->devices[
   d.seq].start_stop_time_ind, md.modification_duration = request->devices[d.seq].
   modification_duration,
   md.updt_applctx = reqinfo->updt_applctx, md.updt_task = reqinfo->updt_task, md.updt_dt_tm =
   cnvtdatetime(sysdate),
   md.updt_id = reqinfo->updt_id, md.updt_cnt = 0
  PLAN (d)
   JOIN (md
   WHERE (md.option_id=reply->option_id)
    AND (md.device_type_cd=request->devices[d.seq].device_type_cd))
  WITH nocounter, status(err_chk->qual[d.seq].status,err_chk->qual[d.seq].error_nbr,err_chk->qual[d
   .seq].error_msg)
 ;end insert
 SET err_chk->failed_ind = 0
 FOR (errcnt = 1 TO md_cnt)
   IF ((err_chk->qual[errcnt].status=0))
    SET errmsg = build("Error (",err_chk->qual[errcnt].error_nbr,"):",err_chk->qual[errcnt].error_msg
     )
    CALL errorhandler("INSERT","F","BB_MOD_DEVICE",errmsg)
    SET err_chk->failed_ind = 1
   ENDIF
 ENDFOR
 IF ((err_chk->failed_ind=1))
  SET reqinfo->commit_ind = 0
  GO TO exit_script
 ENDIF
 SUBROUTINE (errorhandler(operationname=vc,operationstatus=c1,targetobjectname=vc,targetobjectvalue=
  vc) =null)
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(reply->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (reply->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt += 1
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[error_cnt].operationname = operationname
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = targetobjectvalue
 END ;Subroutine
#set_status
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
 FREE RECORD err_chk
END GO
