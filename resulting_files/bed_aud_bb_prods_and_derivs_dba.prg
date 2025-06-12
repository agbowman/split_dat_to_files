CREATE PROGRAM bed_aud_bb_prods_and_derivs:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 paramlist[*]
      2 param_type_mean = vc
      2 pdate1 = dq8
      2 pdate2 = dq8
      2 vlist[*]
        3 dbl_value = f8
        3 string_value = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 FREE RECORD temp
 RECORD temp(
   1 tqual[*]
     2 class = vc
     2 category = vc
     2 red_cell_ind = i2
     2 requires_aborh_confirm_ind = i2
     2 prod_pat_comp_valid_ind = i2
     2 print_crossmatch_tag_ind = i2
     2 unit_of_measure = vc
     2 shipping_condition = vc
     2 volume_ind = i2
     2 crossmatch_tag_req_ind = i2
     2 component_tag_req_ind = i2
     2 pilot_label_ind = i2
     2 seqment_nbr_ind = i2
     2 alternate_nbr_ind = i2
     2 product_or_derivative = vc
     2 barcode = vc
     2 autologous_ind = i2
     2 directed_ind = i2
     2 aliquot_ind = i2
     2 time_to_expire = i4
     2 time_unit = vc
     2 default_volume = i4
     2 storage_temp = vc
     2 valid_antibodies_ind = i2
     2 valid_trans_reqs_ind = i2
     2 disp_without_mods_ind = i2
     2 confirmatory_test = vc
     2 quarantine_minutes = i4
     2 expire_from_drawn_date_ind = i2
     2 international_units_ind = i2
 )
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM product_index pi,
    code_value cv1,
    product_category pcat,
    code_value cv2,
    product_class pclass
   PLAN (pi
    WHERE pi.active_ind=1)
    JOIN (cv1
    WHERE cv1.code_value=pi.product_cd
     AND cv1.active_ind=1)
    JOIN (pcat
    WHERE pcat.product_cat_cd=pi.product_cat_cd
     AND pcat.active_ind=1)
    JOIN (cv2
    WHERE cv2.code_value=pcat.product_cat_cd
     AND cv2.code_value=1)
    JOIN (pclass
    WHERE pclass.product_class_cd=pi.product_class_cd
     AND pclass.active_ind=1)
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 5000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 3000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET tcnt = 0
 SELECT INTO "NL:"
  FROM product_index pi,
   code_value cv1,
   product_class pclass,
   product_category pcat,
   code_value cv2,
   code_value cv3,
   code_value cv4,
   product_barcode pb,
   code_value cv5,
   order_catalog_synonym ocs
  PLAN (pi
   WHERE pi.active_ind=1)
   JOIN (cv1
   WHERE cv1.code_value=pi.product_cd
    AND cv1.active_ind=1)
   JOIN (pclass
   WHERE pclass.product_class_cd=pi.product_class_cd
    AND pclass.active_ind=1)
   JOIN (pcat
   WHERE pcat.product_cat_cd=pi.product_cat_cd
    AND pcat.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=pcat.product_cat_cd
    AND cv2.active_ind=1)
   JOIN (cv3
   WHERE cv3.code_value=outerjoin(pcat.default_unit_measure_cd)
    AND cv3.active_ind=outerjoin(1))
   JOIN (cv4
   WHERE cv4.code_value=outerjoin(pcat.default_ship_cond_cd)
    AND cv4.active_ind=outerjoin(1))
   JOIN (pb
   WHERE pb.product_cat_cd=outerjoin(pi.product_cat_cd)
    AND pb.product_cd=outerjoin(pi.product_cd)
    AND pb.active_ind=outerjoin(1))
   JOIN (cv5
   WHERE cv5.code_value=outerjoin(pi.storage_temp_cd)
    AND cv5.active_ind=outerjoin(1))
   JOIN (ocs
   WHERE ocs.synonym_id=outerjoin(pi.synonym_id)
    AND ocs.active_ind=outerjoin(1))
  ORDER BY pclass.description, cv2.display, cv1.display
  DETAIL
   tcnt = (tcnt+ 1), stat = alterlist(temp->tqual,tcnt), temp->tqual[tcnt].class = pclass.description,
   temp->tqual[tcnt].category = cv2.display, temp->tqual[tcnt].red_cell_ind = pcat
   .red_cell_product_ind, temp->tqual[tcnt].requires_aborh_confirm_ind = pcat.confirm_required_ind,
   temp->tqual[tcnt].prod_pat_comp_valid_ind = pcat.valid_aborh_compat_ind, temp->tqual[tcnt].
   print_crossmatch_tag_ind = pcat.crossmatch_tag_ind, temp->tqual[tcnt].unit_of_measure = cv3
   .display,
   temp->tqual[tcnt].shipping_condition = cv4.display, temp->tqual[tcnt].volume_ind = pcat
   .prompt_vol_ind, temp->tqual[tcnt].crossmatch_tag_req_ind = pcat.crossmatch_tag_ind,
   temp->tqual[tcnt].component_tag_req_ind = pcat.component_tag_ind, temp->tqual[tcnt].
   pilot_label_ind = pcat.pilot_label_ind, temp->tqual[tcnt].seqment_nbr_ind = pcat
   .prompt_segment_ind,
   temp->tqual[tcnt].alternate_nbr_ind = pcat.prompt_alternate_ind, temp->tqual[tcnt].
   product_or_derivative = cv1.display, temp->tqual[tcnt].barcode = pb.product_barcode,
   temp->tqual[tcnt].autologous_ind = pi.autologous_ind, temp->tqual[tcnt].directed_ind = pi
   .directed_ind, temp->tqual[tcnt].aliquot_ind = pi.aliquot_ind
   IF (pi.max_days_expire > 0)
    temp->tqual[tcnt].time_to_expire = pi.max_days_expire, temp->tqual[tcnt].time_unit = "days"
   ELSEIF (pi.max_hrs_expire > 0)
    temp->tqual[tcnt].time_to_expire = pi.max_hrs_expire, temp->tqual[tcnt].time_unit = "hours"
   ELSE
    temp->tqual[tcnt].time_to_expire = 0, temp->tqual[tcnt].time_unit = " "
   ENDIF
   temp->tqual[tcnt].default_volume = pi.default_volume, temp->tqual[tcnt].storage_temp = cv5.display,
   temp->tqual[tcnt].valid_antibodies_ind = pi.validate_ag_ab_ind,
   temp->tqual[tcnt].valid_trans_reqs_ind = pi.validate_trans_req_ind, temp->tqual[tcnt].
   disp_without_mods_ind = pi.allow_dispense_ind, temp->tqual[tcnt].confirmatory_test = ocs.mnemonic,
   temp->tqual[tcnt].quarantine_minutes = pi.auto_quarantine_min, temp->tqual[tcnt].
   expire_from_drawn_date_ind = pi.drawn_dt_tm_ind, temp->tqual[tcnt].international_units_ind = pi
   .intl_units_ind
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,30)
 SET reply->collist[1].header_text = "Class"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Category"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Red Cell"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Requires ABO/Rh Confirmation"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Product-Patient Compatibility Validation"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Print Crossmatch Tag"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Unit of Measure"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Shipping Condition"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Volume"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Is a Crossmatch Tag required for a product prior to use?"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Is a Component Tag required for a product prior to use?"
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "Pilot Label"
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = "Segment Number"
 SET reply->collist[13].data_type = 1
 SET reply->collist[13].hide_ind = 0
 SET reply->collist[14].header_text = "Alternate Number"
 SET reply->collist[14].data_type = 1
 SET reply->collist[14].hide_ind = 0
 SET reply->collist[15].header_text = "Product or Derivative"
 SET reply->collist[15].data_type = 1
 SET reply->collist[15].hide_ind = 0
 SET reply->collist[16].header_text = "Barcode"
 SET reply->collist[16].data_type = 1
 SET reply->collist[16].hide_ind = 0
 SET reply->collist[17].header_text = "Autologous"
 SET reply->collist[17].data_type = 1
 SET reply->collist[17].hide_ind = 0
 SET reply->collist[18].header_text = "Directed"
 SET reply->collist[18].data_type = 1
 SET reply->collist[18].hide_ind = 0
 SET reply->collist[19].header_text = "Aliquot"
 SET reply->collist[19].data_type = 1
 SET reply->collist[19].hide_ind = 0
 SET reply->collist[20].header_text = "Time to Expiration"
 SET reply->collist[20].data_type = 3
 SET reply->collist[20].hide_ind = 0
 SET reply->collist[21].header_text = "Time Unit"
 SET reply->collist[21].data_type = 1
 SET reply->collist[21].hide_ind = 0
 SET reply->collist[22].header_text = "Default Volume"
 SET reply->collist[22].data_type = 3
 SET reply->collist[22].hide_ind = 0
 SET reply->collist[23].header_text = "Storage Temperature"
 SET reply->collist[23].data_type = 1
 SET reply->collist[23].hide_ind = 0
 SET reply->collist[24].header_text = "Validate Antibodies"
 SET reply->collist[24].data_type = 1
 SET reply->collist[24].hide_ind = 0
 SET reply->collist[25].header_text = "Validate Transfusion Requirements"
 SET reply->collist[25].data_type = 1
 SET reply->collist[25].hide_ind = 0
 SET reply->collist[26].header_text = "Dispense Without Modifications"
 SET reply->collist[26].data_type = 1
 SET reply->collist[26].hide_ind = 0
 SET reply->collist[27].header_text = "Confirmatory Test"
 SET reply->collist[27].data_type = 1
 SET reply->collist[27].hide_ind = 0
 SET reply->collist[28].header_text = "Quarantine Minutes"
 SET reply->collist[28].data_type = 3
 SET reply->collist[28].hide_ind = 0
 SET reply->collist[29].header_text = "Expire from Drawn Date"
 SET reply->collist[29].data_type = 1
 SET reply->collist[29].hide_ind = 0
 SET reply->collist[30].header_text = "International Units (Derivatives Only)"
 SET reply->collist[30].data_type = 1
 SET reply->collist[30].hide_ind = 0
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,30)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].class
   SET reply->rowlist[row_nbr].celllist[2].string_value = temp->tqual[x].category
   IF ((temp->tqual[x].red_cell_ind=1))
    SET reply->rowlist[row_nbr].celllist[3].string_value = "X"
   ELSE
    SET reply->rowlist[row_nbr].celllist[3].string_value = " "
   ENDIF
   IF ((temp->tqual[x].requires_aborh_confirm_ind=1))
    SET reply->rowlist[row_nbr].celllist[4].string_value = "X"
   ELSE
    SET reply->rowlist[row_nbr].celllist[4].string_value = " "
   ENDIF
   IF ((temp->tqual[x].prod_pat_comp_valid_ind=1))
    SET reply->rowlist[row_nbr].celllist[5].string_value = "X"
   ELSE
    SET reply->rowlist[row_nbr].celllist[5].string_value = " "
   ENDIF
   IF ((temp->tqual[x].print_crossmatch_tag_ind=1))
    SET reply->rowlist[row_nbr].celllist[6].string_value = "X"
   ELSE
    SET reply->rowlist[row_nbr].celllist[6].string_value = " "
   ENDIF
   SET reply->rowlist[row_nbr].celllist[7].string_value = temp->tqual[x].unit_of_measure
   SET reply->rowlist[row_nbr].celllist[8].string_value = temp->tqual[x].shipping_condition
   IF ((temp->tqual[x].volume_ind=1))
    SET reply->rowlist[row_nbr].celllist[9].string_value = "X"
   ELSE
    SET reply->rowlist[row_nbr].celllist[9].string_value = " "
   ENDIF
   IF ((temp->tqual[x].crossmatch_tag_req_ind=1))
    SET reply->rowlist[row_nbr].celllist[10].string_value = "X"
   ELSE
    SET reply->rowlist[row_nbr].celllist[10].string_value = " "
   ENDIF
   IF ((temp->tqual[x].component_tag_req_ind=1))
    SET reply->rowlist[row_nbr].celllist[11].string_value = "X"
   ELSE
    SET reply->rowlist[row_nbr].celllist[11].string_value = " "
   ENDIF
   IF ((temp->tqual[x].pilot_label_ind=1))
    SET reply->rowlist[row_nbr].celllist[12].string_value = "X"
   ELSE
    SET reply->rowlist[row_nbr].celllist[12].string_value = " "
   ENDIF
   IF ((temp->tqual[x].seqment_nbr_ind=1))
    SET reply->rowlist[row_nbr].celllist[13].string_value = "X"
   ELSE
    SET reply->rowlist[row_nbr].celllist[13].string_value = " "
   ENDIF
   IF ((temp->tqual[x].alternate_nbr_ind=1))
    SET reply->rowlist[row_nbr].celllist[14].string_value = "X"
   ELSE
    SET reply->rowlist[row_nbr].celllist[14].string_value = " "
   ENDIF
   SET reply->rowlist[row_nbr].celllist[15].string_value = temp->tqual[x].product_or_derivative
   SET reply->rowlist[row_nbr].celllist[16].string_value = temp->tqual[x].barcode
   IF ((temp->tqual[x].autologous_ind=1))
    SET reply->rowlist[row_nbr].celllist[17].string_value = "X"
   ELSE
    SET reply->rowlist[row_nbr].celllist[17].string_value = " "
   ENDIF
   IF ((temp->tqual[x].directed_ind=1))
    SET reply->rowlist[row_nbr].celllist[18].string_value = "X"
   ELSE
    SET reply->rowlist[row_nbr].celllist[18].string_value = " "
   ENDIF
   IF ((temp->tqual[x].aliquot_ind=1))
    SET reply->rowlist[row_nbr].celllist[19].string_value = "X"
   ELSE
    SET reply->rowlist[row_nbr].celllist[19].string_value = " "
   ENDIF
   SET reply->rowlist[row_nbr].celllist[20].nbr_value = temp->tqual[x].time_to_expire
   SET reply->rowlist[row_nbr].celllist[21].string_value = temp->tqual[x].time_unit
   SET reply->rowlist[row_nbr].celllist[22].nbr_value = temp->tqual[x].default_volume
   SET reply->rowlist[row_nbr].celllist[23].string_value = temp->tqual[x].storage_temp
   IF ((temp->tqual[x].valid_antibodies_ind=1))
    SET reply->rowlist[row_nbr].celllist[24].string_value = "X"
   ELSE
    SET reply->rowlist[row_nbr].celllist[24].string_value = " "
   ENDIF
   IF ((temp->tqual[x].valid_trans_reqs_ind=1))
    SET reply->rowlist[row_nbr].celllist[25].string_value = "X"
   ELSE
    SET reply->rowlist[row_nbr].celllist[25].string_value = " "
   ENDIF
   IF ((temp->tqual[x].disp_without_mods_ind=1))
    SET reply->rowlist[row_nbr].celllist[26].string_value = "X"
   ELSE
    SET reply->rowlist[row_nbr].celllist[26].string_value = " "
   ENDIF
   SET reply->rowlist[row_nbr].celllist[27].string_value = temp->tqual[x].confirmatory_test
   SET reply->rowlist[row_nbr].celllist[28].nbr_value = temp->tqual[x].quarantine_minutes
   IF ((temp->tqual[x].expire_from_drawn_date_ind=1))
    SET reply->rowlist[row_nbr].celllist[29].string_value = "X"
   ELSE
    SET reply->rowlist[row_nbr].celllist[29].string_value = " "
   ENDIF
   IF ((temp->tqual[x].international_units_ind=1))
    SET reply->rowlist[row_nbr].celllist[30].string_value = "X"
   ELSE
    SET reply->rowlist[row_nbr].celllist[30].string_value = " "
   ENDIF
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("bb_product_and_derivatives.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
