CREATE PROGRAM bed_ens_bb_prodcat_prod_r:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE error_flag = vc
 DECLARE error_msg = vc
 DECLARE prodcnt = i4
 DECLARE catcnt = i4
 DECLARE prodcat_id = f8
 DECLARE prodclass_cd = f8
 DECLARE active_cd = f8
 DECLARE inactive_cd = f8
 SET reply->status_data.status = "F"
 SET error_flag = "F"
 SET catcnt = size(request->prodcatlist,5)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=48
    AND cv.cdf_meaning="ACTIVE")
  DETAIL
   active_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=48
    AND cv.cdf_meaning="INACTIVE")
  DETAIL
   inactive_cd = cv.code_value
  WITH nocounter
 ;end select
 FOR (ii = 1 TO catcnt)
   SET prodcnt = size(request->prodcatlist[ii].prodlist,5)
   SELECT INTO "nl"
    FROM br_bb_prodcat bc
    PLAN (bc
     WHERE (bc.prodcat_cd=request->prodcatlist[ii].prodcat_code_value))
    DETAIL
     prodcat_id = bc.prodcat_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM product_category pc
    PLAN (pc
     WHERE (pc.product_cat_cd=request->prodcatlist[ii].prodcat_code_value))
    DETAIL
     prodclass_cd = pc.product_class_cd
    WITH nocounter
   ;end select
   FOR (jj = 1 TO prodcnt)
     IF ((request->prodcatlist[ii].prodlist[jj].action_flag=1))
      UPDATE  FROM br_bb_product bp
       SET bp.prodcat_id = prodcat_id, bp.updt_dt_tm = cnvtdatetime(curdate,curtime), bp.updt_id =
        reqinfo->updt_id,
        bp.updt_cnt = (bp.updt_cnt+ 1), bp.updt_applctx = reqinfo->updt_applctx, bp.updt_task =
        reqinfo->updt_task,
        bp.active_ind = 1
       WHERE (bp.product_cd=request->prodcatlist[ii].prodlist[jj].product_code_value)
       WITH nocounter
      ;end update
      UPDATE  FROM br_bb_prodcat bc
       SET bc.selected_ind = 1, bc.updt_dt_tm = cnvtdatetime(curdate,curtime), bc.updt_id = reqinfo->
        updt_id,
        bc.updt_cnt = (bc.updt_cnt+ 1), bc.updt_applctx = reqinfo->updt_applctx, bc.updt_task =
        reqinfo->updt_task,
        bc.active_ind = 1
       WHERE bc.prodcat_id=prodcat_id
       WITH nocounter
      ;end update
      SET found_ind = 0
      SELECT INTO "nl:"
       FROM product_index pi
       WHERE (pi.product_cd=request->prodcatlist[ii].prodlist[jj].product_code_value)
       DETAIL
        found_ind = 1
       WITH nocounter
      ;end select
      IF (found_ind=0)
       SET auto_ind = 0
       SET dir_ind = 0
       SET max_days = 0
       SET max_hours = 0
       SET calc_ind = 0
       SET vol_def = 0
       SET disp_ind = 0
       SET min_bef = 0
       SET anti_ind = 0
       SET transf_ind = 0
       SET int_units = 0
       SET aliquot = 0
       SELECT INTO "nl:"
        FROM br_bb_product bp
        WHERE (bp.product_cd=request->prodcatlist[ii].prodlist[jj].product_code_value)
         AND bp.prodcat_id=prodcat_id
        DETAIL
         auto_ind = bp.auto_ind, dir_ind = bp.directed_ind
         IF (cnvtupper(bp.max_exp_unit)="HOURS")
          max_hours = bp.max_exp_val
         ENDIF
         IF (cnvtupper(bp.max_exp_unit)="DAYS")
          max_days = bp.max_exp_val
         ENDIF
         calc_ind = bp.calc_exp_from_draw_ind, vol_def = bp.volume_def, disp_ind = bp.dispense_ind,
         min_bef = bp.min_bef_quar, anti_ind = bp.validate_antibody_ind, transf_ind = bp
         .validate_transf_req_ind,
         int_units = bp.int_units_ind, aliquot = bp.aliquot_ind
        WITH nocounter
       ;end select
       INSERT  FROM product_index pi
        SET pi.product_cd = request->prodcatlist[ii].prodlist[jj].product_code_value, pi
         .product_cat_cd = request->prodcatlist[ii].prodcat_code_value, pi.product_class_cd =
         prodclass_cd,
         pi.autologous_ind = auto_ind, pi.directed_ind = dir_ind, pi.allow_dispense_ind = disp_ind,
         pi.default_volume = vol_def, pi.max_days_expire = max_days, pi.max_hrs_expire = max_hours,
         pi.default_supplier_id = 0, pi.synonym_id = 0.0, pi.auto_quarantine_min = min_bef,
         pi.intl_units_ind = int_units, pi.auto_bill_item_cd = 0.0, pi.dir_bill_item_cd = 0.0,
         pi.validate_ag_ab_ind = anti_ind, pi.validate_trans_req_ind = transf_ind, pi.storage_temp_cd
          = 0.0,
         pi.drawn_dt_tm_ind = calc_ind, pi.aliquot_ind = aliquot, pi.active_ind = 1,
         pi.active_status_cd = active_cd, pi.active_status_dt_tm = cnvtdatetime(curdate,curtime), pi
         .active_status_prsnl_id = reqinfo->updt_id,
         pi.updt_cnt = 0, pi.updt_dt_tm = cnvtdatetime(curdate,curtime), pi.updt_id = reqinfo->
         updt_id,
         pi.updt_applctx = reqinfo->updt_applctx, pi.updt_task = reqinfo->updt_task
        WITH nocounter
       ;end insert
      ELSE
       UPDATE  FROM product_index pi
        SET pi.product_cat_cd = request->prodcatlist[ii].prodcat_code_value, pi.product_class_cd =
         prodclass_cd, pi.updt_dt_tm = cnvtdatetime(curdate,curtime),
         pi.updt_id = reqinfo->updt_id, pi.updt_cnt = (pi.updt_cnt+ 1), pi.updt_applctx = reqinfo->
         updt_applctx,
         pi.updt_task = reqinfo->updt_task, pi.active_ind = 1, pi.active_status_cd = active_cd,
         pi.active_status_dt_tm = cnvtdatetime(curdate,curtime), pi.active_status_prsnl_id = reqinfo
         ->updt_id
        WHERE (pi.product_cd=request->prodcatlist[ii].prodlist[jj].product_code_value)
        WITH nocounter
       ;end update
      ENDIF
      UPDATE  FROM code_value cv
       SET cv.updt_dt_tm = cnvtdatetime(curdate,curtime), cv.updt_id = reqinfo->updt_id, cv.updt_cnt
         = (cv.updt_cnt+ 1),
        cv.updt_applctx = reqinfo->updt_applctx, cv.updt_task = reqinfo->updt_task, cv.active_ind = 1,
        cv.active_type_cd = active_cd, cv.active_dt_tm = cnvtdatetime(curdate,curtime), cv
        .active_status_prsnl_id = reqinfo->updt_id
       WHERE (cv.code_value=request->prodcatlist[ii].prodlist[jj].product_code_value)
       WITH nocounter
      ;end update
     ELSEIF ((request->prodcatlist[ii].prodlist[jj].action_flag=3))
      UPDATE  FROM br_bb_product bp
       SET bp.prodcat_id = 0.0, bp.updt_dt_tm = cnvtdatetime(curdate,curtime), bp.updt_id = reqinfo->
        updt_id,
        bp.updt_cnt = (bp.updt_cnt+ 1), bp.updt_applctx = reqinfo->updt_applctx, bp.updt_task =
        reqinfo->updt_task,
        bp.active_ind = 0
       WHERE (bp.product_cd=request->prodcatlist[ii].prodlist[jj].product_code_value)
       WITH nocounter
      ;end update
      UPDATE  FROM product_index pi
       SET pi.product_cat_cd = 0.0, pi.updt_dt_tm = cnvtdatetime(curdate,curtime), pi.updt_id =
        reqinfo->updt_id,
        pi.updt_cnt = (pi.updt_cnt+ 1), pi.updt_applctx = reqinfo->updt_applctx, pi.updt_task =
        reqinfo->updt_task
       WHERE (pi.product_cd=request->prodcatlist[ii].prodlist[jj].product_code_value)
       WITH nocounter
      ;end update
      SET prod_found = 0
      SELECT INTO "nl:"
       FROM br_bb_product bp
       PLAN (bp
        WHERE bp.prodcat_id=prodcat_id)
       DETAIL
        prod_found = 1
       WITH nocounter
      ;end select
      IF (prod_found=0)
       UPDATE  FROM br_bb_prodcat bc
        SET bc.selected_ind = 1, bc.updt_dt_tm = cnvtdatetime(curdate,curtime), bc.updt_id = reqinfo
         ->updt_id,
         bc.updt_cnt = (bc.updt_cnt+ 1), bc.updt_applctx = reqinfo->updt_applctx, bc.updt_task =
         reqinfo->updt_task,
         bc.active_ind = 1
        WHERE bc.prodcat_id=prodcat_id
        WITH nocounter
       ;end update
      ENDIF
     ENDIF
   ENDFOR
 ENDFOR
#exit_script
 IF (error_flag="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSEIF (error_flag="T")
  SET reply->error_msg = concat(">> PROGRAM NAME: BED_ENS_BB_PRODCAT_PROD_R  ",">> ERROR MESSAGE: ",
   error_msg)
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
