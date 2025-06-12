CREATE PROGRAM bed_get_bb_product_details:dba
 FREE SET reply
 RECORD reply(
   1 product_list[*]
     2 product_id = f8
     2 product_code_value = f8
     2 display = vc
     2 bar_code_val = vc
     2 auto_ind = i2
     2 directed_ind = i2
     2 max_exp_unit_flag = i4
     2 max_exp_val = i4
     2 calc_exp_from_draw_ind = i2
     2 volume_def = i4
     2 def_supplier_id = f8
     2 def_supplier_name = vc
     2 aborh_conf_test_name = vc
     2 aborh_conf_test_id = f8
     2 dispense_ind = i2
     2 min_bef_quar = i4
     2 validate_antibody_ind = i2
     2 validate_transf_req_ind = i2
     2 int_units_ind = i2
     2 def_storage_temp_display = vc
     2 def_storage_temp_code_value = f8
     2 barcodes[*]
       3 bar_code_val = vc
       3 bar_code_id = f8
     2 aliquot_ind = i2
     2 isbt_match_products[*]
       3 code_value = f8
       3 display = vc
       3 directed_ind = i2
       3 auto_ind = i2
       3 aliquot_ind = i2
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
 DECLARE bcsze = i4
 SET reply->status_data.status = "F"
 SET error_flag = "F"
 SET repsze = 0
 SET supplier_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=278
    AND cv.cdf_meaning="BBSUPPL")
  DETAIL
   supplier_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (supplier_cd=0.0)
  SET error_flag = "T"
  SET error_msg = "No bb supplier org type code found - program terminating"
  GO TO exit_script
 ENDIF
 SET prodcat_id = 0.0
 SELECT INTO "nl:"
  FROM br_bb_prodcat b
  WHERE (b.prodcat_cd=request->prodcat_code_value)
   AND b.active_ind=1
  DETAIL
   prodcat_id = b.prodcat_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM product_index pi,
   br_bb_product bp
  PLAN (pi
   WHERE (pi.product_cat_cd=request->prodcat_code_value)
    AND pi.active_ind=1)
   JOIN (bp
   WHERE bp.product_cd=pi.product_cd
    AND bp.prodcat_id=prodcat_id
    AND bp.selected_ind=1
    AND bp.active_ind=1)
  DETAIL
   repsze = (repsze+ 1), stat = alterlist(reply->product_list,repsze), reply->product_list[repsze].
   product_id = bp.product_id,
   reply->product_list[repsze].product_code_value = bp.product_cd, reply->product_list[repsze].
   display = bp.display, reply->product_list[repsze].auto_ind = bp.auto_ind,
   reply->product_list[repsze].directed_ind = bp.directed_ind
   IF (cnvtupper(trim(bp.max_exp_unit))="HOURS")
    reply->product_list[repsze].max_exp_unit_flag = 0
   ELSEIF (cnvtupper(trim(bp.max_exp_unit))="DAYS")
    reply->product_list[repsze].max_exp_unit_flag = 1
   ENDIF
   reply->product_list[repsze].max_exp_val = bp.max_exp_val, reply->product_list[repsze].
   calc_exp_from_draw_ind = bp.calc_exp_from_draw_ind, reply->product_list[repsze].volume_def = bp
   .volume_def,
   reply->product_list[repsze].def_supplier_name = bp.def_supplier, reply->product_list[repsze].
   def_supplier_id = 0.0, reply->product_list[repsze].aborh_conf_test_name = bp.aborh_conf_test_name,
   reply->product_list[repsze].aborh_conf_test_id = 0.0, reply->product_list[repsze].dispense_ind =
   bp.dispense_ind, reply->product_list[repsze].min_bef_quar = bp.min_bef_quar,
   reply->product_list[repsze].validate_antibody_ind = bp.validate_antibody_ind, reply->product_list[
   repsze].validate_transf_req_ind = bp.validate_transf_req_ind, reply->product_list[repsze].
   int_units_ind = bp.int_units_ind,
   reply->product_list[repsze].def_storage_temp_code_value = 0.0, reply->product_list[repsze].
   def_storage_temp_display = bp.def_storage_temp, reply->product_list[repsze].aliquot_ind = bp
   .aliquot_ind
  WITH nocounter
 ;end select
 IF (repsze > 0)
  FOR (ii = 1 TO repsze)
   SET bcsze = 0
   SELECT INTO "nl:"
    FROM product_barcode pb
    PLAN (pb
     WHERE (pb.product_cd=reply->product_list[ii].product_code_value)
      AND pb.active_ind=1
      AND pb.product_barcode > " ")
    DETAIL
     bcsze = (bcsze+ 1), stat = alterlist(reply->product_list[ii].barcodes,bcsze), reply->
     product_list[ii].barcodes[bcsze].bar_code_val = pb.product_barcode,
     reply->product_list[ii].barcodes[bcsze].bar_code_id = pb.product_barcode_id, reply->
     product_list[ii].bar_code_val = reply->product_list[ii].barcodes[1].bar_code_val
    WITH nocounter
   ;end select
  ENDFOR
 ENDIF
 IF (repsze > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = repsze),
    code_value cv
   PLAN (d)
    JOIN (cv
    WHERE cv.code_set=1663
     AND cv.active_ind=1
     AND cv.display_key=cnvtupper(cnvtalphanum(reply->product_list[d.seq].def_storage_temp_display)))
   DETAIL
    reply->product_list[d.seq].def_storage_temp_code_value = cv.code_value
   WITH nocounter
  ;end select
  SET data_partition_ind = 0
  SET field_found = 0
  RANGE OF c IS code_value_set
  SET field_found = validate(c.br_client_id)
  FREE RANGE c
  IF (field_found=0)
   SET prg_exists_ind = 0
   SET prg_exists_ind = checkprg("ACM_GET_ACC_LOGICAL_DOMAINS")
   IF (prg_exists_ind > 0)
    SET field_found = 0
    RANGE OF o IS organization
    SET field_found = validate(o.logical_domain_id)
    FREE RANGE o
    IF (field_found=1)
     SET data_partition_ind = 1
     FREE SET acm_get_acc_logical_domains_req
     RECORD acm_get_acc_logical_domains_req(
       1 write_mode_ind = i2
       1 concept = i4
     )
     FREE SET acm_get_acc_logical_domains_rep
     RECORD acm_get_acc_logical_domains_rep(
       1 logical_domain_grp_id = f8
       1 logical_domains_cnt = i4
       1 logical_domains[*]
         2 logical_domain_id = f8
       1 status_block
         2 status_ind = i2
         2 error_code = i4
     )
     SET acm_get_acc_logical_domains_req->write_mode_ind = 0
     SET acm_get_acc_logical_domains_req->concept = 3
     EXECUTE acm_get_acc_logical_domains  WITH replace("REQUEST",acm_get_acc_logical_domains_req),
     replace("REPLY",acm_get_acc_logical_domains_rep)
    ENDIF
   ENDIF
  ENDIF
  DECLARE org_parse = vc
  SET org_parse =
  "o.org_name_key = cnvtupper(cnvtalphanum(reply->product_list[d.seq].def_supplier_name))"
  IF (data_partition_ind=1)
   IF ((acm_get_acc_logical_domains_rep->logical_domains_cnt > 0))
    SET org_parse = concat(org_parse," and o.logical_domain_id in (")
    FOR (d = 1 TO acm_get_acc_logical_domains_rep->logical_domains_cnt)
      IF ((d=acm_get_acc_logical_domains_rep->logical_domains_cnt))
       SET org_parse = build(org_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
        logical_domain_id,")")
      ELSE
       SET org_parse = build(org_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
        logical_domain_id,",")
      ENDIF
    ENDFOR
   ENDIF
  ENDIF
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = repsze),
    organization o,
    org_type_reltn otr
   PLAN (d)
    JOIN (o
    WHERE parser(org_parse))
    JOIN (otr
    WHERE otr.organization_id=o.organization_id
     AND otr.org_type_cd=supplier_cd
     AND otr.active_ind=1)
   DETAIL
    reply->product_list[d.seq].def_supplier_id = o.organization_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = repsze),
    order_catalog_synonym ocs
   PLAN (d)
    JOIN (ocs
    WHERE ocs.mnemonic_key_cap=cnvtupper(reply->product_list[d.seq].aborh_conf_test_name)
     AND ocs.active_ind=1)
   DETAIL
    reply->product_list[d.seq].aborh_conf_test_id = ocs.synonym_id
   WITH nocounter
  ;end select
 ENDIF
 IF (repsze > 0)
  RECORD temp(
    1 qual[*]
      2 barcode = vc
  )
  FOR (r = 1 TO repsze)
    SET tcnt = 0
    SELECT INTO "nl:"
     FROM bb_isbt_product_type b
     WHERE (b.product_cd=reply->product_list[r].product_code_value)
      AND b.active_ind=1
     DETAIL
      tcnt = (tcnt+ 1), stat = alterlist(temp->qual,tcnt), temp->qual[tcnt].barcode = b.isbt_barcode
     WITH nocounter
    ;end select
    SET icnt = 0
    SELECT INTO "nl:"
     FROM bb_isbt_product_type b,
      product_index p,
      code_value cv
     PLAN (b
      WHERE (b.product_cd != reply->product_list[r].product_code_value)
       AND b.active_ind=1)
      JOIN (p
      WHERE p.product_cd=b.product_cd
       AND p.active_ind=1)
      JOIN (cv
      WHERE cv.code_value=p.product_cd
       AND cv.active_ind=1)
     DETAIL
      found_ind = 0, start = 1, num = 0
      IF (tcnt > 0)
       found_ind = locateval(num,start,tcnt,b.isbt_barcode,temp->qual[num].barcode)
      ENDIF
      IF (found_ind > 0)
       IF (icnt=0)
        icnt = (icnt+ 1), stat = alterlist(reply->product_list[r].isbt_match_products,icnt), reply->
        product_list[r].isbt_match_products[icnt].code_value = cv.code_value,
        reply->product_list[r].isbt_match_products[icnt].display = cv.display, reply->product_list[r]
        .isbt_match_products[icnt].directed_ind = p.directed_ind, reply->product_list[r].
        isbt_match_products[icnt].auto_ind = p.autologous_ind,
        reply->product_list[r].isbt_match_products[icnt].aliquot_ind = p.aliquot_ind
       ELSE
        found_ind = 0, start = 1, num = 0,
        found_ind = locateval(num,start,icnt,b.product_cd,reply->product_list[r].isbt_match_products[
         num].code_value)
        IF (found_ind=0)
         icnt = (icnt+ 1), stat = alterlist(reply->product_list[r].isbt_match_products,icnt), reply->
         product_list[r].isbt_match_products[icnt].code_value = cv.code_value,
         reply->product_list[r].isbt_match_products[icnt].display = cv.display, reply->product_list[r
         ].isbt_match_products[icnt].directed_ind = p.directed_ind, reply->product_list[r].
         isbt_match_products[icnt].auto_ind = p.autologous_ind,
         reply->product_list[r].isbt_match_products[icnt].aliquot_ind = p.aliquot_ind
        ENDIF
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
  ENDFOR
 ENDIF
#exit_script
 IF (error_flag="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSEIF (error_flag="T")
  SET reply->error_msg = concat(">> PROGRAM NAME: BED_GET_BB_PRODUCT_DETAILS  ",">> ERROR MESSAGE: ",
   error_msg)
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
