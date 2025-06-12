CREATE PROGRAM bed_ens_bb_product_details:dba
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
 DECLARE repsze = i4
 DECLARE supplier_cd = f8
 DECLARE prodcat_cd = f8
 DECLARE prodclass_cd = f8
 DECLARE supplier_name = vc
 DECLARE storage_disp = vc
 DECLARE conf_name = vc
 DECLARE active_cd = f8
 DECLARE hours_val = i4
 DECLARE days_val = i4
 DECLARE unit = vc
 DECLARE bccnt = i4
 DECLARE inactive_cd = f8
 SET bcnt = 0
 DECLARE bcid = f8
 DECLARE bcexists = i2
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
 SET reply->status_data.status = "F"
 SET error_flag = "F"
 SET repsze = size(request->prodlist,5)
 FOR (ii = 1 TO repsze)
   IF ((((request->prodlist[ii].action_flag=1)) OR ((((request->prodlist[ii].action_flag=0)) OR ((
   request->prodlist[ii].action_flag=2))) )) )
    SELECT INTO "nl:"
     FROM product_index pi
     PLAN (pi
      WHERE (pi.product_cd=request->prodlist[ii].product_code_value))
     DETAIL
      prodcat_cd = pi.product_cat_cd, prodclass_cd = pi.product_class_cd
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET error_flag = "T"
     SET error_msg = concat("Unable to read product_index for product_cd ",cnvtstring(request->
       prodlist[ii].product_code_value))
     GO TO exit_script
    ENDIF
    IF ((((request->prodlist[ii].action_flag=1)) OR ((request->prodlist[ii].action_flag=2))) )
     IF ((request->prodlist[ii].max_exp_unit_flag=1))
      SET days_val = request->prodlist[ii].max_exp_val
      SET hours_val = 0
     ELSEIF ((request->prodlist[ii].max_exp_unit_flag=0))
      SET hours_val = request->prodlist[ii].max_exp_val
      SET days_val = 0
     ENDIF
     UPDATE  FROM product_index pi
      SET pi.autologous_ind = request->prodlist[ii].auto_ind, pi.directed_ind = request->prodlist[ii]
       .directed_ind, pi.max_days_expire = days_val,
       pi.max_hrs_expire = hours_val, pi.drawn_dt_tm_ind = request->prodlist[ii].
       calc_exp_from_draw_ind, pi.default_volume = request->prodlist[ii].volume_def,
       pi.default_supplier_id = request->prodlist[ii].def_supplier_id, pi.synonym_id = request->
       prodlist[ii].aborh_conf_test_id, pi.allow_dispense_ind = request->prodlist[ii].dispense_ind,
       pi.auto_quarantine_min = request->prodlist[ii].min_bef_quar, pi.validate_ag_ab_ind = request->
       prodlist[ii].validate_antibody_ind, pi.validate_trans_req_ind = request->prodlist[ii].
       validate_transf_req_ind,
       pi.intl_units_ind = request->prodlist[ii].int_units_ind, pi.storage_temp_cd = request->
       prodlist[ii].def_storage_temp_code_value, pi.dir_bill_item_cd = 0.0,
       pi.auto_bill_item_cd = 0.0, pi.active_ind = 1, pi.active_status_cd = active_cd,
       pi.active_status_dt_tm = cnvtdatetime(curdate,curtime), pi.active_status_prsnl_id = reqinfo->
       updt_id, pi.updt_applctx = reqinfo->updt_applctx,
       pi.updt_cnt = (pi.updt_cnt+ 1), pi.updt_dt_tm = cnvtdatetime(curdate,curtime), pi.updt_id =
       reqinfo->updt_id,
       pi.updt_task = reqinfo->updt_task, pi.aliquot_ind = request->prodlist[ii].aliquot_ind
      WHERE (pi.product_cd=request->prodlist[ii].product_code_value)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET error_flag = "T"
      SET error_msg = concat("Unable to update product_index for product_cd ",cnvtstring(request->
        prodlist[ii].product_code_value))
      GO TO exit_script
     ENDIF
    ENDIF
    SET bcexists = validate(request->prodlist[ii].barcodes)
    CALL echo(build("bcexists = ",bcexists))
    IF (bcexists=0)
     IF ((request->prodlist[ii].action_flag=1)
      AND (request->prodlist[ii].bar_code_val > " "))
      SET new_pathnet_seq = 0.0
      SELECT INTO "nl:"
       seqn = seq(pathnet_seq,nextval)"###########################;rp0"
       FROM dual
       DETAIL
        new_pathnet_seq = cnvtreal(seqn)
       WITH format, nocounter
      ;end select
      INSERT  FROM product_barcode pb
       SET pb.product_barcode_id = new_pathnet_seq, pb.product_barcode = request->prodlist[ii].
        bar_code_val, pb.product_cd = request->prodlist[ii].product_code_value,
        pb.product_cat_cd = prodcat_cd, pb.product_class_cd = prodclass_cd, pb.active_ind = 1,
        pb.active_status_cd = active_cd, pb.active_status_dt_tm = cnvtdatetime(curdate,curtime), pb
        .active_status_prsnl_id = reqinfo->updt_id,
        pb.updt_cnt = 0, pb.updt_id = reqinfo->updt_id, pb.updt_dt_tm = cnvtdatetime(curdate,curtime),
        pb.updt_task = reqinfo->updt_task, pb.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
     ELSEIF ((request->prodlist[ii].action_flag=2)
      AND (request->prodlist[ii].bar_code_val > " "))
      SET bcid = 0.0
      SET bcnt = 0
      SELECT INTO "nl:"
       FROM product_barcode pb
       PLAN (pb
        WHERE (pb.product_cd=request->prodlist[ii].product_code_value))
       DETAIL
        bcnt = (bcnt+ 1), bcid = pb.product_barcode_id
       WITH nocounter
      ;end select
      IF (bcnt=1)
       UPDATE  FROM product_barcode pb
        SET pb.product_barcode = request->prodlist[ii].bar_code_val, pb.updt_cnt = (pb.updt_cnt+ 1),
         pb.updt_id = reqinfo->updt_id,
         pb.updt_dt_tm = cnvtdatetime(curdate,curtime), pb.updt_task = reqinfo->updt_task, pb
         .updt_applctx = reqinfo->updt_applctx
        WHERE pb.product_barcode_id=bcid
        WITH nocounter
       ;end update
      ELSEIF (bcnt=0
       AND (request->prodlist[ii].bar_code_val > " "))
       SET new_pathnet_seq = 0.0
       SELECT INTO "nl:"
        seqn = seq(pathnet_seq,nextval)"###########################;rp0"
        FROM dual
        DETAIL
         new_pathnet_seq = cnvtreal(seqn)
        WITH format, nocounter
       ;end select
       INSERT  FROM product_barcode pb
        SET pb.product_barcode_id = new_pathnet_seq, pb.product_barcode = request->prodlist[ii].
         bar_code_val, pb.product_cd = request->prodlist[ii].product_code_value,
         pb.product_cat_cd = prodcat_cd, pb.product_class_cd = prodclass_cd, pb.active_ind = 1,
         pb.active_status_cd = active_cd, pb.active_status_dt_tm = cnvtdatetime(curdate,curtime), pb
         .active_status_prsnl_id = reqinfo->updt_id,
         pb.updt_cnt = 0, pb.updt_id = reqinfo->updt_id, pb.updt_dt_tm = cnvtdatetime(curdate,curtime
          ),
         pb.updt_task = reqinfo->updt_task, pb.updt_applctx = reqinfo->updt_applctx
        WITH nocounter
       ;end insert
      ENDIF
     ENDIF
    ELSE
     SET bccnt = size(request->prodlist[ii].barcodes,5)
     IF (bccnt > 0)
      FOR (jj = 1 TO bccnt)
        IF ((request->prodlist[ii].barcodes[jj].action_flag=1))
         SET new_pathnet_seq = 0.0
         SELECT INTO "nl:"
          seqn = seq(pathnet_seq,nextval)"###########################;rp0"
          FROM dual
          DETAIL
           new_pathnet_seq = cnvtreal(seqn)
          WITH format, nocounter
         ;end select
         INSERT  FROM product_barcode pb
          SET pb.product_barcode_id = new_pathnet_seq, pb.product_barcode = request->prodlist[ii].
           barcodes[jj].bar_code_val, pb.product_cd = request->prodlist[ii].product_code_value,
           pb.product_cat_cd = prodcat_cd, pb.product_class_cd = prodclass_cd, pb.active_ind = 1,
           pb.active_status_cd = active_cd, pb.active_status_dt_tm = cnvtdatetime(curdate,curtime),
           pb.active_status_prsnl_id = reqinfo->updt_id,
           pb.updt_cnt = 0, pb.updt_id = reqinfo->updt_id, pb.updt_dt_tm = cnvtdatetime(curdate,
            curtime),
           pb.updt_task = reqinfo->updt_task, pb.updt_applctx = reqinfo->updt_applctx
          WITH nocounter
         ;end insert
        ELSEIF ((request->prodlist[ii].barcodes[jj].action_flag=2)
         AND (request->prodlist[ii].barcodes[jj].id > 0))
         UPDATE  FROM product_barcode pb
          SET pb.product_barcode = request->prodlist[ii].barcodes[jj].bar_code_val, pb.updt_cnt = (pb
           .updt_cnt+ 1), pb.updt_id = reqinfo->updt_id,
           pb.updt_dt_tm = cnvtdatetime(curdate,curtime), pb.updt_task = reqinfo->updt_task, pb
           .updt_applctx = reqinfo->updt_applctx
          WHERE (pb.product_barcode_id=request->prodlist[ii].barcodes[jj].id)
          WITH nocounter
         ;end update
        ELSEIF ((request->prodlist[ii].barcodes[jj].action_flag=3)
         AND (request->prodlist[ii].barcodes[jj].id > 0))
         UPDATE  FROM product_barcode pb
          SET pb.active_ind = 0, pb.active_status_cd = inactive_cd, pb.active_status_dt_tm =
           cnvtdatetime(curdate,curtime),
           pb.active_status_prsnl_id = reqinfo->updt_id, pb.updt_cnt = (pb.updt_cnt+ 1), pb.updt_id
            = reqinfo->updt_id,
           pb.updt_dt_tm = cnvtdatetime(curdate,curtime), pb.updt_task = reqinfo->updt_task, pb
           .updt_applctx = reqinfo->updt_applctx
          WHERE (pb.product_barcode_id=request->prodlist[ii].barcodes[jj].id)
          WITH nocounter
         ;end update
        ENDIF
      ENDFOR
     ENDIF
    ENDIF
    IF ((((request->prodlist[ii].action_flag=1)) OR ((request->prodlist[ii].action_flag=2))) )
     SET storage_disp = " "
     SELECT INTO "nl:"
      FROM code_value cv
      PLAN (cv
       WHERE cv.code_set=1663
        AND cv.active_ind=1
        AND (cv.code_value=request->prodlist[ii].def_storage_temp_code_value))
      DETAIL
       storage_disp = cv.display
      WITH nocounter
     ;end select
     SET supplier_name = " "
     SELECT INTO "nl:"
      FROM organization o
      PLAN (o
       WHERE (o.organization_id=request->prodlist[ii].def_supplier_id))
      DETAIL
       supplier_name = o.org_name
      WITH nocounter
     ;end select
     SET conf_name = " "
     SELECT INTO "nl:"
      FROM order_catalog_synonym ocs
      PLAN (ocs
       WHERE (ocs.synonym_id=request->prodlist[ii].aborh_conf_test_id))
      DETAIL
       conf_name = ocs.mnemonic
      WITH nocounter
     ;end select
     IF ((request->prodlist[ii].max_exp_unit_flag=1))
      SET unit = "days"
     ELSEIF ((request->prodlist[ii].max_exp_unit_flag=0))
      SET unit = "hours"
     ENDIF
     UPDATE  FROM br_bb_product bp
      SET bp.auto_ind = request->prodlist[ii].auto_ind, bp.directed_ind = request->prodlist[ii].
       directed_ind, bp.max_exp_unit = unit,
       bp.max_exp_val = request->prodlist[ii].max_exp_val, bp.calc_exp_from_draw_ind = request->
       prodlist[ii].calc_exp_from_draw_ind, bp.volume_def = request->prodlist[ii].volume_def,
       bp.def_supplier = supplier_name, bp.aborh_conf_test_name = conf_name, bp.dispense_ind =
       request->prodlist[ii].dispense_ind,
       bp.min_bef_quar = request->prodlist[ii].min_bef_quar, bp.validate_antibody_ind = request->
       prodlist[ii].validate_antibody_ind, bp.validate_transf_req_ind = request->prodlist[ii].
       validate_transf_req_ind,
       bp.int_units_ind = request->prodlist[ii].int_units_ind, bp.def_storage_temp = storage_disp, bp
       .updt_applctx = reqinfo->updt_applctx,
       bp.updt_cnt = (bp.updt_cnt+ 1), bp.updt_dt_tm = cnvtdatetime(curdate,curtime), bp.updt_id =
       reqinfo->updt_id,
       bp.updt_task = reqinfo->updt_task, bp.aliquot_ind = request->prodlist[ii].aliquot_ind, bp
       .active_ind = 1
      WHERE (bp.product_cd=request->prodlist[ii].product_code_value)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET error_flag = "T"
      SET error_msg = concat("Unable to update br_bb_product for product_cd ",cnvtstring(request->
        prodlist[ii].product_cd))
      GO TO exit_script
     ENDIF
     UPDATE  FROM code_value cv
      SET cv.active_ind = 1, cv.active_dt_tm = cnvtdatetime(curdate,curtime3), cv.active_type_cd =
       active_cd,
       cv.active_status_prsnl_id = reqinfo->updt_id, cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_id =
       reqinfo->updt_id,
       cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->updt_applctx, cv.updt_dt_tm =
       cnvtdatetime(curdate,curtime3)
      WHERE (cv.code_value=request->prodlist[ii].product_code_value)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET error_flag = "T"
      SET error_msg = concat("Unable to update code_value for product_cd ",cnvtstring(request->
        prodlist[ii].product_code_value))
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSEIF (error_flag="T")
  SET reply->error_msg = concat(">> PROGRAM NAME: BED_ENS_BB_PRODUCT_DETAILS  ",">> ERROR MESSAGE: ",
   error_msg)
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
