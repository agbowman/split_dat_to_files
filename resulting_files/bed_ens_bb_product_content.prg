CREATE PROGRAM bed_ens_bb_product_content
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 DECLARE error_msg = vc WITH private
 DECLARE error_flag = vc WITH private
 DECLARE numrows = i4
 DECLARE product_found = vc
 DECLARE product_id = f8
 DECLARE auto = i2
 DECLARE directed = i2
 DECLARE calcexp = i2
 DECLARE dispense = i2
 DECLARE valanti = i2
 DECLARE valtransf = i2
 DECLARE intunit = i2
 DECLARE prodcat_id = f8
 DECLARE nextid = f8
 DECLARE voldef = i4
 DECLARE quarmin = i4
 DECLARE expval = i4
 SET reply->status_data.status = "F"
 SET error_flag = "F"
 SET auto = 0
 SET directed = 0
 SET calcexp = 0
 SET dispense = 0
 SET valanti = 0
 SET valtransf = 0
 SET intunit = 0
 SET nextid = 0
 SET voldef = 0
 SET quarmin = 0
 SET expval = 0
 SET numrows = size(request->product_list,5)
 FOR (x = 1 TO numrows)
   IF ((request->product_list[x].auto_ind="Y"))
    SET auto = 1
   ELSE
    SET auto = 0
   ENDIF
   IF ((request->product_list[x].directed_ind="Y"))
    SET directed = 1
   ELSE
    SET directed = 0
   ENDIF
   IF ((request->product_list[x].calc_exp_from_draw_ind="Y"))
    SET calcexp = 1
   ELSE
    SET calcexp = 0
   ENDIF
   IF ((request->product_list[x].dispense_ind="Y"))
    SET dispense = 1
   ELSE
    SET dispense = 0
   ENDIF
   IF ((request->product_list[x].validate_antibody_ind="Y"))
    SET valanti = 1
   ELSE
    SET valanti = 0
   ENDIF
   IF ((request->product_list[x].validate_transf_req_ind="Y"))
    SET valtransf = 1
   ELSE
    SET valtransf = 0
   ENDIF
   IF ((request->product_list[x].int_units_ind="Y"))
    SET intunit = 1
   ELSE
    SET intunit = 0
   ENDIF
   IF ((request->product_list[x].volume_def <= " "))
    SET voldef = 0
   ELSE
    SET voldef = cnvtint(request->product_list[x].volume_def)
   ENDIF
   IF ((request->product_list[x].min_bef_quar <= " "))
    SET quarmin = 0
   ELSE
    SET quarmin = cnvtint(request->product_list[x].min_bef_quar)
   ENDIF
   IF ((request->product_list[x].max_exp_val <= " "))
    SET expval = 0
   ELSE
    SET expval = cnvtint(request->product_list[x].max_exp_val)
   ENDIF
   SET product_found = "N"
   SELECT INTO "nl:"
    FROM br_bb_product b
    PLAN (b
     WHERE (b.display=request->product_list[x].display))
    DETAIL
     product_found = "Y", product_id = b.product_id
    WITH nocounter
   ;end select
   SET prodcat_id = 0.0
   SELECT INTO "nl:"
    FROM br_bb_prodcat bp
    PLAN (bp
     WHERE (bp.display=request->product_list[x].prodcat_disp))
    DETAIL
     prodcat_id = bp.prodcat_id
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat("Error reading product category",request->product_list[x].prodcat_disp,
     " for product ",request->product_list[x].display)
    GO TO exit_script
   ENDIF
   IF (product_found="N")
    SELECT INTO "nl:"
     y = seq(bedrock_seq,nextval)
     FROM dual
     DETAIL
      nextid = cnvtreal(y)
     WITH nocounter
    ;end select
    CALL echo(build("nextid = ",nextid))
    INSERT  FROM br_bb_product b
     SET b.product_id = nextid, b.display = request->product_list[x].display, b.description = request
      ->product_list[x].description,
      b.selected_ind = 0, b.product_cd = 0.0, b.prodcat_id = prodcat_id,
      b.bar_code_val = request->product_list[x].bar_code_val, b.auto_ind = auto, b.directed_ind =
      directed,
      b.max_exp_unit = request->product_list[x].max_exp_unit, b.max_exp_val = expval, b
      .calc_exp_from_draw_ind = calcexp,
      b.volume_def = voldef, b.def_supplier = request->product_list[x].def_supplier, b
      .aborh_conf_test_name = request->product_list[x].aborh_conf_test_name,
      b.dispense_ind = dispense, b.min_bef_quar = quarmin, b.validate_antibody_ind = valanti,
      b.validate_transf_req_ind = valtransf, b.int_units_ind = intunit, b.def_storage_temp = request
      ->product_list[x].def_storage_temp,
      b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_id = reqinfo->updt_id, b.updt_task =
      reqinfo->updt_task,
      b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "T"
     SET error_msg = concat("Error adding product ",request->product_list[x].display,
      " to Bedrock table")
     GO TO exit_script
    ENDIF
   ELSE
    UPDATE  FROM br_bb_product b
     SET b.display = request->product_list[x].display, b.description = request->product_list[x].
      description, b.selected_ind = 0,
      b.product_cd = 0.0, b.prodcat_id = prodcat_id, b.bar_code_val = request->product_list[x].
      bar_code_val,
      b.auto_ind = auto, b.directed_ind = directed, b.max_exp_unit = request->product_list[x].
      max_exp_unit,
      b.max_exp_val = expval, b.calc_exp_from_draw_ind = calcexp, b.volume_def = voldef,
      b.def_supplier = request->product_list[x].def_supplier, b.aborh_conf_test_name = request->
      product_list[x].aborh_conf_test_name, b.dispense_ind = dispense,
      b.min_bef_quar = quarmin, b.validate_antibody_ind = valanti, b.validate_transf_req_ind =
      valtransf,
      b.int_units_ind = intunit, b.def_storage_temp = cnvtint(request->product_list[x].
       def_storage_temp), b.updt_dt_tm = cnvtdatetime(curdate,curtime),
      b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
      updt_applctx,
      b.updt_cnt = (b.updt_cnt+ 1)
     WHERE b.product_id=product_id
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "T"
     SET error_msg = concat("Error updating product ",request->product_list[x].display,
      " in Bedrock table")
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 GO TO exit_script
#exit_script
 IF (error_flag="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  CALL echo(error_msg)
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_IMP_BB_PRODUCT_CONTENT","  >> ERROR MSG: ",
   error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
