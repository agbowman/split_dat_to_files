CREATE PROGRAM ccps_pha_lbt_preproc_ret:dba
 IF (debug_ind=1)
  CALL echo("Entering ccps_pha_lbt_preproc_ret . .")
 ENDIF
 DECLARE alias_type_docdea_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!9850"))
 DECLARE ident_type_brand_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3303"))
 DECLARE ident_type_desc_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3290"))
 DECLARE ident_type_generic_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3294"))
 DECLARE pharm_type_retail_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!101132")
  )
 DECLARE wl_lang_eng_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!6261"))
 FREE RECORD preproc_ret
 RECORD preproc_ret(
   1 qual[*]
     2 rx_nbr = vc
     2 sig = vc
     2 disp_qty = vc
     2 refills_remain = i2
     2 exp_dt_tm = dq8
     2 lot_nbr = vc
     2 cost = f8
     2 ins_pd = f8
     2 pat_pd = f8
     2 payment_method = vc
     2 phys_id = f8
     2 phys_dea = vc
     2 ord_phys_address_street = vc
     2 ord_phys_address_city = vc
     2 ord_phys_address_state = vc
     2 ord_phys_zipcode = vc
     2 disp_sr_cd = f8
     2 disp_sr_desc = vc
     2 disp_sr_address_street = vc
     2 disp_sr_address_city = vc
     2 disp_sr_address_state = vc
     2 disp_sr_zipcode = vc
     2 disp_sr_phone = vc
     2 disp_dt_tm = dq8
     2 warn_lbl_cnt = i2
     2 warn_lbl[*]
       3 label_nbr = i2
       3 label_txt = vc
 ) WITH persistscript
 SET stat = alterlist(preproc_ret->qual,label_rec_size)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(dummyt_loop_cnt)),
   fill_print_ord_hx po,
   prod_dispense_hx pdh,
   mm_lot_reltn mlr,
   lot_number_info lni,
   long_text lt,
   long_text lt1,
   prsnl_alias pa
  PLAN (d
   WHERE initarray(expand_start,evaluate(d.seq,1,1,(expand_start+ m_n_expand_size))))
   JOIN (po
   WHERE (po.run_id=label_rec->run_id)
    AND expand(label_rec_ndx,expand_start,(expand_start+ (m_n_expand_size - 1)),po.order_row_seq,
    label_ids->qual[label_rec_ndx].order_row_seq,
    po.order_id,label_ids->qual[label_rec_ndx].order_id))
   JOIN (pdh
   WHERE pdh.dispense_hx_id=po.dispense_id
    AND pdh.ingred_sequence=po.ingred_seq)
   JOIN (mlr
   WHERE mlr.parent_entity_id=outerjoin(pdh.prod_dispense_hx_id)
    AND mlr.parent_entity_name=outerjoin("PROD_DISPENSE_HX"))
   JOIN (lni
   WHERE lni.lot_number_id=outerjoin(mlr.lot_number_id))
   JOIN (lt
   WHERE lt.long_text_id=outerjoin(po.sig_text_id))
   JOIN (lt1
   WHERE lt1.long_text_id=outerjoin(po.sig_alt_lang_text_id))
   JOIN (pa
   WHERE pa.person_id=outerjoin(po.ord_phys_id)
    AND pa.prsnl_alias_type_cd=outerjoin(alias_type_docdea_cd)
    AND pa.active_ind=outerjoin(1)
    AND pa.beg_effective_dt_tm <= outerjoin(cnvtdatetime(sysdate))
    AND pa.end_effective_dt_tm > outerjoin(cnvtdatetime(sysdate)))
  ORDER BY po.order_row_seq
  HEAD REPORT
   MACRO (build_infuse)
    dsinfuse = fillstring(12," ")
    IF (po.infuse_over > 0)
     pass_field_in = po.infuse_over, parse_zeroes, dsinfuse = concat(trim(dsvalue)," ",trim(po
       .infuse_unit_s))
    ENDIF
   ENDMACRO
   ,
   MACRO (build_volume)
    dsvolume = fillstring(13," "), pass_field_in = po.tot_volume, parse_zeroes,
    dsvolume = concat(trim(dsvalue)," "," mL")
   ENDMACRO
   ,
   MACRO (build_rate)
    dsrate = fillstring(20," ")
    IF (po.titrate_ind=1)
     dsrate = "Titrate     "
    ELSE
     pass_field_in = po.ml_hr, parse_zeroes, dsrate = concat(trim(dsvalue)," "," mL/hr")
    ENDIF
   ENDMACRO
   ,
   MACRO (build_interval)
    dsinterval = fillstring(15," "), pass_field_in = po.replace_every, parse_zeroes,
    dsinterval = concat(trim(dsvalue)," ",trim(po.replace_every_unit_s))
   ENDMACRO
   ,
   MACRO (build_dose)
    dsdose = fillstring(12," "), pass_field_in = po.dose_quantity, parse_zeroes,
    dsdose = concat(trim(dsvalue))
   ENDMACRO
   ,
   MACRO (build_fill)
    dsfill = fillstring(12," "), pass_field_in = po.fill_quantity, parse_zeroes,
    dsfill = concat(trim(dsvalue))
   ENDMACRO
   ,
   MACRO (parse_zeroes)
    dsvalue = fillstring(16," "), move_fld = fillstring(16," "), strfld = fillstring(16," "),
    sig_dig = 0, sig_dec = 0, strfld = cnvtstring(pass_field_in,16,4,r),
    str_cnt = 1, len = 0
    WHILE (str_cnt < 12
     AND substring(str_cnt,1,strfld) IN ("0", " "))
      str_cnt = (str_cnt+ 1)
    ENDWHILE
    sig_dig = (str_cnt - 1), str_cnt = 16
    WHILE (str_cnt > 12
     AND substring(str_cnt,1,strfld) IN ("0", " "))
      str_cnt = (str_cnt - 1)
    ENDWHILE
    IF (str_cnt=12
     AND substring(str_cnt,1,strfld)=".")
     str_cnt = (str_cnt - 1)
    ENDIF
    sig_dec = str_cnt
    IF (sig_dig=11
     AND sig_dec=11)
     dsvalue = "n/a"
    ELSE
     len = movestring(strfld,(sig_dig+ 1),move_fld,1,(sig_dec - sig_dig)), dsvalue = trim(move_fld)
     IF (substring(1,1,dsvalue)=".")
      dsvalue = concat("0",trim(move_fld))
     ENDIF
    ENDIF
   ENDMACRO
   ,
   MACRO (build_pick_qty)
    real_pick = (po.dose_quantity * po.fill_quantity), pickqty = fillstring(13," "), pass_field_in =
    real_pick,
    parse_zeroes, pickqty = concat(trim(dsvalue)," ",trim(po.dose_quantity_unit_s))
   ENDMACRO
   ,
   MACRO (build_address)
    IF (((size(trim(sstreet)) > 0) OR (size(trim(scity)) > 0))
     AND size(trim(sstate)) > 0)
     sseperator1 = ","
    ELSE
     sseperator1 = ""
    ENDIF
    IF (((size(trim(sstate)) > 0) OR (size(trim(szip)) > 0))
     AND size(trim(sphone)) > 0)
     sseperator2 = " - "
    ELSE
     sseperator2 = ""
    ENDIF
    saddress = concat(trim(sstreet)," ",trim(scity),sseperator1,trim(sstate),
     " ",trim(szip),sseperator2,trim(sphone))
   ENDMACRO
   ,
   MACRO (build_normalized_rate)
    snormalizedrate = fillstring(30," ")
    IF (po.ord_type=2
     AND validate(po.normalized_rate) > 0
     AND validate(po.normalized_rate_unit_cd) > 0)
     pass_field_in = validate(po.normalized_rate,0.0), parse_zeroes, snormalizedrate = concat("[",
      trim(dsvalue,3)," ",trim(validate(po.normalized_rate_unit_s,""),3),"]")
    ENDIF
   ENDMACRO
   ,
   CALL echo("Last Mod for pha_label_driver_macros.inc: 016 09/10/07"), found_ndx = 0,
   eval_ndx = 0
  DETAIL
   found_ndx = locateval(eval_ndx,1,label_rec_size,po.order_row_seq,label_ids->qual[eval_ndx].
    order_row_seq,
    po.order_id,label_ids->qual[eval_ndx].order_id)
   WHILE (found_ndx != 0)
     label_rec->qual[found_ndx].manufacturer = uar_get_code_display(po.manf_cd), preproc_ret->qual[
     found_ndx].rx_nbr = trim(po.rx_nbr_s)
     IF (size(lt1.long_text) > 0)
      preproc_ret->qual[found_ndx].sig = trim(lt1.long_text)
     ELSE
      preproc_ret->qual[found_ndx].sig = trim(lt.long_text)
     ENDIF
     pass_field_in = po.disp_qty, parse_zeroes, preproc_ret->qual[found_ndx].disp_qty = build2(trim(
       dsvalue)," ",uar_get_code_display(po.disp_qty_unit_cd)),
     preproc_ret->qual[found_ndx].refills_remain = po.refills_remaining, preproc_ret->qual[found_ndx]
     .exp_dt_tm = po.rx_expire_dt_tm, preproc_ret->qual[found_ndx].lot_nbr = lni.lot_number,
     preproc_ret->qual[found_ndx].cost = po.ord_price, preproc_ret->qual[found_ndx].ins_pd = po
     .reimbursement, preproc_ret->qual[found_ndx].pat_pd = po.copay,
     preproc_ret->qual[found_ndx].payment_method = uar_get_code_display(po.payment_method_cd),
     preproc_ret->qual[found_ndx].phys_id = po.ord_phys_id, preproc_ret->qual[found_ndx].phys_dea =
     cnvtalias(pa.alias,pa.alias_pool_cd),
     preproc_ret->qual[found_ndx].disp_sr_cd = po.dispense_sr_cd, preproc_ret->qual[found_ndx].
     disp_sr_desc = uar_get_code_description(po.dispense_sr_cd), preproc_ret->qual[found_ndx].
     disp_dt_tm = po.dispense_dt_tm,
     found_ndx = locateval(eval_ndx,(found_ndx+ 1),label_rec_size,po.order_row_seq,label_ids->qual[
      eval_ndx].order_row_seq,
      po.order_id,label_ids->qual[eval_ndx].order_id)
   ENDWHILE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(dummyt_loop_cnt)),
   (dummyt d1  WITH seq = 1),
   fill_print_ord_hx po,
   med_identifier mi
  PLAN (d
   WHERE initarray(expand_start,evaluate(d.seq,1,1,(expand_start+ m_n_expand_size)))
    AND maxrec(d1,size(label_rec->qual[d.seq].ingredients,5)))
   JOIN (d1)
   JOIN (po
   WHERE (po.run_id=label_rec->run_id)
    AND expand(label_rec_ndx,expand_start,(expand_start+ (m_n_expand_size - 1)),po.order_row_seq,
    label_ids->qual[label_rec_ndx].order_row_seq,
    po.order_id,label_ids->qual[label_rec_ndx].order_id))
   JOIN (mi
   WHERE mi.item_id=po.item_id
    AND mi.pharmacy_type_cd=pharm_type_retail_cd
    AND mi.med_product_id=po.med_product_id
    AND mi.med_identifier_type_cd IN (ident_type_brand_cd, ident_type_desc_cd, ident_type_generic_cd)
   )
  HEAD REPORT
   found_ndx = 0, eval_ndx = 0
  DETAIL
   found_ndx = locateval(eval_ndx,1,label_rec_size,mi.item_id,label_ids->qual[eval_ndx].item_id)
   WHILE (found_ndx != 0)
    IF (po.tnf_id=0
     AND po.compound_ind=0)
     CASE (mi.med_identifier_type_cd)
      OF ident_type_brand_cd:
       label_rec->qual[found_ndx].brand_name = trim(mi.value),label_rec->qual[found_ndx].ingredients[
       d1.seq].brand_name = trim(mi.value)
      OF ident_type_desc_cd:
       label_rec->qual[found_ndx].label_description = trim(mi.value),label_rec->qual[found_ndx].
       ingredient_description = trim(mi.value),label_rec->qual[found_ndx].ingredients[d1.seq].
       description = trim(mi.value),
       label_rec->qual[found_ndx].ingredients[d1.seq].label_description = trim(mi.value)
      OF ident_type_generic_cd:
       label_rec->qual[found_ndx].generic_name = trim(mi.value),label_rec->qual[found_ndx].
       ingredients[d1.seq].generic_name = trim(mi.value)
     ENDCASE
    ENDIF
    ,found_ndx = locateval(eval_ndx,(found_ndx+ 1),label_rec_size,mi.item_id,label_ids->qual[eval_ndx
     ].item_id)
   ENDWHILE
 ;end select
 SET stat = alterlist(preproc_ret->qual,expand_total)
 SELECT INTO "nl:"
  address_found = decode(a.seq,1,0)
  FROM (dummyt d  WITH seq = value(dummyt_loop_cnt)),
   address a
  PLAN (d
   WHERE initarray(expand_start,evaluate(d.seq,1,1,(expand_start+ m_n_expand_size))))
   JOIN (a
   WHERE expand(label_rec_ndx,expand_start,(expand_start+ (m_n_expand_size - 1)),a.parent_entity_id,
    preproc_ret->qual[label_rec_ndx].phys_id)
    AND a.address_type_cd=business_address_cd
    AND a.parent_entity_name="PERSON"
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= sysdate
    AND a.end_effective_dt_tm > sysdate)
  ORDER BY a.parent_entity_id
  HEAD REPORT
   found_ndx = 0, eval_ndx = 0
  HEAD a.parent_entity_id
   CALL echo(a.street_addr), found_ndx = locateval(eval_ndx,1,label_rec_size,a.parent_entity_id,
    preproc_ret->qual[eval_ndx].phys_id)
   WHILE (found_ndx != 0)
    IF (address_found=1)
     preproc_ret->qual[found_ndx].ord_phys_address_street = a.street_addr
     IF (size(trim(a.street_addr2)) > 0)
      preproc_ret->qual[found_ndx].ord_phys_address_street = build2(preproc_ret->qual[found_ndx].
       ord_phys_address_street," ",a.street_addr2)
     ENDIF
     preproc_ret->qual[found_ndx].ord_phys_address_city = a.city
     IF (a.state_cd > 0)
      preproc_ret->qual[found_ndx].ord_phys_address_state = uar_get_code_display(a.state_cd)
     ELSE
      preproc_ret->qual[found_ndx].ord_phys_address_state = a.state
     ENDIF
     preproc_ret->qual[found_ndx].ord_phys_zipcode = a.zipcode
    ENDIF
    ,found_ndx = locateval(eval_ndx,(found_ndx+ 1),label_rec_size,a.parent_entity_id,preproc_ret->
     qual[eval_ndx].phys_id)
   ENDWHILE
  WITH nocounter
 ;end select
 SET stat = alterlist(preproc_ret->qual,label_rec_size)
 SELECT INTO "nl:"
  md.mdx_gfc_nomen_id, wlx.*, w.*
  FROM (dummyt d  WITH seq = value(dummyt_loop_cnt)),
   medication_definition md,
   warning_label_xref wlx,
   warning_label w
  PLAN (d
   WHERE initarray(expand_start,evaluate(d.seq,1,1,(expand_start+ m_n_expand_size))))
   JOIN (md
   WHERE expand(label_rec_ndx,expand_start,(expand_start+ (m_n_expand_size - 1)),md.item_id,label_ids
    ->qual[label_rec_ndx].item_id))
   JOIN (wlx
   WHERE wlx.nomenclature_id=md.mdx_gfc_nomen_id
    AND wlx.active_ind=1
    AND wlx.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND wlx.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (w
   WHERE w.label_nbr=wlx.label_nbr
    AND w.language_cd=wl_lang_eng_cd
    AND w.label_nbr_seq=wlx.label_nbr_seq
    AND w.active_ind=1
    AND w.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND w.end_effective_dt_tm > cnvtdatetime(sysdate))
  ORDER BY w.label_nbr
  HEAD REPORT
   found_ndx = 0, eval_ndx = 0, cnt = 0
  DETAIL
   found_ndx = locateval(eval_ndx,1,label_rec_size,md.item_id,label_ids->qual[eval_ndx].item_id)
   WHILE (found_ndx != 0)
    IF (((cnt=0) OR (cnt > 0
     AND (w.label_nbr != preproc_ret->qual[found_ndx].warn_lbl[cnt].label_nbr))) )
     cnt = (cnt+ 1),
     CALL echo(cnt)
     IF (mod(cnt,5)=1)
      stat = alterlist(preproc_ret->qual[found_ndx].warn_lbl,(cnt+ 5))
     ENDIF
     preproc_ret->qual[found_ndx].warn_lbl[cnt].label_nbr = w.label_nbr, preproc_ret->qual[found_ndx]
     .warn_lbl[cnt].label_txt = w.label_full_text
    ENDIF
    ,found_ndx = locateval(eval_ndx,(found_ndx+ 1),label_rec_size,md.item_id,label_ids->qual[eval_ndx
     ].item_id)
   ENDWHILE
  FOOT REPORT
   preproc_ret->qual[found_ndx].warn_lbl_cnt = cnt, stat = alterlist(preproc_ret->qual[found_ndx].
    warn_lbl,cnt)
  WITH nocounter
 ;end select
 RECORD temp_request(
   1 data[*]
     2 serv_res_cd = f8
   1 active_ind = i2
   1 rx_type_cd = f8
   1 pharmacy_ind = i2
   1 unit_based_ind = i2
   1 work_station_ind = i2
   1 device_ind = i2
   1 section_ind = i2
   1 address_ind = i2
   1 resgroup_ind = i2
   1 facility_ind = i2
   1 loc_facility_cd = f8
   1 identifier_ind = i2
   1 price_code_ind = i2
 )
 RECORD temp_reply(
   1 data[*]
     2 state_control_nbr = c100
     2 serv_res_cd = f8
     2 display = vc
     2 desc = vc
     2 serv_res_type = vc
     2 active_ind = i2
     2 inv_res_cd = f8
     2 loc_cd = f8
     2 loc_display = vc
     2 loc_desc = vc
     2 pat_care_loc_ind = i2
     2 rx_type_cd = f8
     2 org_id = f8
     2 exists_ind = i2
     2 dea_number = vc
     2 disp_priority_cd = f8
     2 downtime_range_id = f8
     2 nabp_number = vc
     2 otc_sales_tax = f8
     2 rxnbr_cd = f8
     2 rx_in_charge_id = f8
     2 sales_tax = f8
     2 state_license_number = vc
     2 tax_number = vc
     2 track_nbr_cd = f8
     2 updt_cnt = i4
     2 cdf_meaning = c12
     2 building_cd = f8
     2 facility_cd = f8
     2 rx_charge_ind = i2
     2 inv_location_cd = f8
     2 available_ind = i2
     2 cost_basis_cd = f8
     2 address[*]
       3 address_type_cd = f8
       3 street_addr = vc
       3 street_addr2 = vc
       3 street_addr3 = vc
       3 street_addr4 = vc
       3 city = vc
       3 county = vc
       3 state = vc
       3 state_cd = f8
       3 zipcode = vc
       3 country = vc
       3 phone = vc
     2 resgroup[*]
       3 parent_service_resource_cd = f8
       3 child_service_resource_cd = f8
       3 resource_group_type_cd = f8
       3 sequence = i4
     2 ident_list[*]
       3 serv_res_identifier_id = f8
       3 identifier_type_cd = f8
       3 value = vc
       3 value_key = vc
       3 updt_cnt = i4
     2 floorstock_ind = i2
     2 pharmacy_type_cd = f8
     2 facility_list[*]
       3 facility_cd = f8
       3 display = vc
       3 description = vc
     2 serv_res_type_cd = f8
     2 inv_loc_desc = vc
     2 price_code_list[*]
       3 price_code_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET stat = alterlist(temp_request->data,size(preproc_ret->qual,5))
 SET temp_request->rx_type_cd = pharm_type_retail_cd
 SET temp_request->active_ind = 1
 SET temp_request->pharmacy_ind = 1
 SET temp_request->address_ind = 1
 FOR (idx = 1 TO size(preproc_ret->qual,5))
   SET temp_request->data[idx].serv_res_cd = preproc_ret->qual[idx].disp_sr_cd
 ENDFOR
 EXECUTE rx_get_service_resources  WITH replace("REQUEST","TEMP_REQUEST"), replace("REPLY",
  "TEMP_REPLY")
 CALL echorecord(temp_reply)
 FOR (idx = 1 TO size(preproc_ret->qual,5))
   SET preproc_ret->qual[idx].disp_sr_address_street = trim(temp_reply->data[idx].address[1].
    street_addr)
   SET preproc_ret->qual[idx].disp_sr_address_city = trim(temp_reply->data[idx].address[1].city)
   SET preproc_ret->qual[idx].disp_sr_address_state = trim(temp_reply->data[idx].address[1].state)
   SET preproc_ret->qual[idx].disp_sr_zipcode = trim(temp_reply->data[idx].address[1].zipcode)
   SET preproc_ret->qual[idx].disp_sr_phone = trim(temp_reply->data[idx].address[1].phone)
 ENDFOR
 EXECUTE ccps_pha_lbt_preproc
#exit_script
 IF (debug_ind=1)
  CALL echorecord(preproc_ret)
  CALL echo("Last Mod = 002 07/06/11 md8090")
  CALL echo(". . Exiting ccps_pha_lbt_preproc_ret")
 ENDIF
END GO
