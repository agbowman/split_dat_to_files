CREATE PROGRAM bed_aud_os_prod_scan:dba
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
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 DECLARE pharmacytypeinpatient = f8 WITH protect, constant(uar_get_code_by("meaning",4500,"INPATIENT"
   ))
 DECLARE active_status_active = f8 WITH protect, constant(uar_get_code_by("meaning",48,"ACTIVE"))
 DECLARE flex_type_syspkgtyp = f8 WITH protect, constant(uar_get_code_by("meaning",4062,"SYSPKGTYP"))
 DECLARE med_ident_type_ndc = f8 WITH protect, constant(uar_get_code_by("meaning",11000,"NDC"))
 DECLARE med_ident_type_desc = f8 WITH protect, constant(uar_get_code_by("meaning",11000,"DESC"))
 DECLARE medproduct = f8 WITH protect, constant(uar_get_code_by("meaning",4063,"MEDPRODUCT"))
 DECLARE flex_obj_type_orderable = f8 WITH protect, constant(uar_get_code_by("meaning",4063,
   "ORDERABLE"))
 DECLARE catalog_type_pharmacy = f8 WITH protect, constant(uar_get_code_by("meaning",6000,"PHARMACY")
  )
 DECLARE mnem_type_rxmnemonic = f8 WITH protect, constant(uar_get_code_by("meaning",6011,"RXMNEMONIC"
   ))
 DECLARE mnem_type_ygeneric = f8 WITH protect, constant(uar_get_code_by("meaning",6011,"GENERICPROD")
  )
 DECLARE mnem_type_ztrade = f8 WITH protect, constant(uar_get_code_by("meaning",6011,"TRADEPROD"))
 DECLARE filter_type_ordersentence = f8 WITH protect, constant(uar_get_code_by("meaning",30620,
   "ORDERSENT"))
 DECLARE route_form_comp_populate(null) = null
 DECLARE route_form_comp(route=f8,form=f8) = vc
 DECLARE order_list_extract(null) = null
 DECLARE uom_conversion(uom_id=f8) = i2
 DECLARE uom_compare(os_uom_id=f8,med_uom_id=f8) = i2
 DECLARE uom_extract(null) = null
 DECLARE syn_prod_link_extract(null) = null
 DECLARE syn_prod_link_chk(syn_id=f8,item_id=f8) = i2
 DECLARE no_product_format(ff=i2,rf=i2,fac=i2) = vc
 DECLARE populate_reply(null) = null
 DECLARE hld_osd_os_id = f8 WITH protect, noconstant(0)
 DECLARE hld_osd_os_desc = vc WITH protect, noconstant("")
 DECLARE hld_osd_str_dose_id = f8 WITH protect, noconstant(0)
 DECLARE hld_osd_str_dose_desc = vc WITH protect, noconstant("")
 DECLARE hld_osd_str_uom_id = f8 WITH protect, noconstant(0)
 DECLARE hld_osd_str_uom_desc = vc WITH protect, noconstant("")
 DECLARE hld_osd_vol_dose_id = f8 WITH protect, noconstant(0)
 DECLARE hld_osd_vol_dose_desc = vc WITH protect, noconstant("")
 DECLARE hld_osd_vol_uom_id = f8 WITH protect, noconstant(0)
 DECLARE hld_osd_vol_uom_desc = vc WITH protect, noconstant("")
 DECLARE hld_osd_route_id = f8 WITH protect, noconstant(0)
 DECLARE hld_osd_route_desc = vc WITH protect, noconstant("")
 DECLARE hld_osd_form_id = f8 WITH protect, noconstant(0)
 DECLARE hld_osd_form_desc = vc WITH protect, noconstant("")
 DECLARE os_str_uom_cnvt = i2 WITH protect, noconstant(0)
 DECLARE os_vol_uom_cnvt = i2 WITH protect, noconstant(0)
 DECLARE med_str_uom_cnvt = i2 WITH protect, noconstant(0)
 DECLARE med_vol_uom_cnvt = i2 WITH protect, noconstant(0)
 DECLARE os_str_dose_cnvt = f8 WITH protect, noconstant(0)
 DECLARE os_vol_dose_cnvt = f8 WITH protect, noconstant(0)
 DECLARE no_product_output = vc WITH protect, noconstant("")
 DECLARE os_no_products_ind = i2 WITH protect, noconstant(0)
 DECLARE str_uom_err_output = vc WITH protect, noconstant("")
 DECLARE vol_uom_err_output = vc WITH protect, noconstant("")
 DECLARE med_linked_disp = vc WITH protect, noconstant("")
 DECLARE med_ready_display = vc WITH protect, noconstant("")
 DECLARE output = vc WITH protect, noconstant("")
 DECLARE dup_chk_string = vc WITH protect, noconstant("")
 DECLARE dup_chk_ind = i2 WITH protect, noconstant(0)
 DECLARE os_chk_ind = i2 WITH protect, noconstant(0)
 DECLARE med_linked_status = i2 WITH protect, noconstant(0)
 DECLARE med_disqualify_ind = i2 WITH protect, noconstant(0)
 DECLARE med_nr_ind = i2 WITH protect, noconstant(0)
 DECLARE vol_uom_err_ind = i2 WITH protect, noconstant(0)
 RECORD order_list(
   1 order_info[*]
     2 catalog_cd = f8
     2 synonym_id = f8
     2 synonym = vc
     2 os_info[*]
       3 os_disp_line = vc
       3 os_id = f8
       3 os_str_dose = vc
       3 os_str_uom = vc
       3 os_str_uom_id = f8
       3 os_vol_dose = vc
       3 os_vol_uom = vc
       3 os_vol_uom_id = f8
       3 os_route = vc
       3 os_route_id = f8
       3 os_form = vc
       3 os_form_id = f8
       3 os_route_form_err = vc
       3 os_dup_chk_string = vc
       3 facility_err = i2
       3 route_form_err = i2
       3 form_form_err = i2
       3 med_info[*]
         4 med_desc = vc
         4 med_str = f8
         4 med_str_uom = vc
         4 med_vol = f8
         4 med_vol_uom = vc
         4 med_form = vc
         4 med_ndc = vc
         4 str_uom_err_output = vc
         4 vol_uom_err_output = vc
         4 med_linked_disp = vc
         4 med_ready_display = vc
 ) WITH protect
 SET stat = alterlist(order_list->order_info,4000)
 RECORD syn_prod_linking(
   1 item[*]
     2 item_id = f8
     2 syn[*]
       3 syn_id = f8
 ) WITH protect
 SET stat = alterlist(syn_prod_linking->item,3000)
 RECORD uom(
   1 uom[*]
     2 uom_name_cv = f8
     2 uom_numerator_cv = f8
     2 uom_base = i2
     2 uom_branch = i2
 ) WITH protect
 RECORD route_form(
   1 route[*]
     2 route_cd = f8
     2 form[*]
       3 form_cd = f8
 ) WITH protect
 SET stat = alterlist(route_form->route,50)
 CALL syn_prod_link_extract(null)
 CALL route_form_comp_populate(null)
 CALL uom_extract(null)
 CALL order_list_extract(null)
 CALL populate_reply(null)
 SUBROUTINE route_form_comp_populate(null)
  SELECT INTO "nl:"
   FROM route_form_r r,
    code_value cv1,
    code_value cv2
   PLAN (r)
    JOIN (cv1
    WHERE cv1.code_value=r.route_cd
     AND cv1.active_ind=1
     AND cv1.code_set=4001)
    JOIN (cv2
    WHERE cv2.code_value=r.form_cd
     AND cv2.active_ind=1
     AND cv2.code_set=4002)
   ORDER BY r.route_cd, r.form_cd
   HEAD REPORT
    f_cnt = 0, r_cnt = 0
   HEAD r.route_cd
    f_cnt = 0, r_cnt = (r_cnt+ 1)
    IF (mod(r_cnt,10)=1
     AND r_cnt > 50)
     stat = alterlist(route_form->route,(r_cnt+ 9))
    ENDIF
    route_form->route[r_cnt].route_cd = r.route_cd, stat = alterlist(route_form->route[r_cnt].form,10
     )
   HEAD r.form_cd
    f_cnt = (f_cnt+ 1)
    IF (mod(f_cnt,10)=1
     AND f_cnt > 10)
     stat = alterlist(route_form->route[r_cnt].form,(f_cnt+ 9))
    ENDIF
    route_form->route[r_cnt].form[f_cnt].form_cd = r.form_cd
   FOOT  r.route_cd
    stat = alterlist(route_form->route[r_cnt].form,f_cnt)
   FOOT REPORT
    stat = alterlist(route_form->route,r_cnt)
   WITH nocounter
  ;end select
  CALL bederrorcheck("RouteFormCompPop")
 END ;Subroutine
 SUBROUTINE route_form_comp(route,form)
   DECLARE rnum = i4 WITH protect, noconstant(0)
   DECLARE fnum = i4 WITH protect, noconstant(0)
   DECLARE rpos = i4 WITH protect, noconstant(0)
   DECLARE fpos = i4 WITH protect, noconstant(0)
   SET rpos = locateval(rnum,0,size(route_form->route,5),route,route_form->route[rnum].route_cd)
   IF (rpos=0)
    RETURN("X")
   ELSE
    IF (form=0)
     RETURN("-")
    ELSE
     SET fpos = locateval(fnum,0,size(route_form->route[rpos].form,5),form,route_form->route[rnum].
      form[fnum].form_cd)
     IF (fpos=0)
      RETURN("X")
     ENDIF
    ENDIF
   ENDIF
   RETURN(" ")
 END ;Subroutine
 SUBROUTINE order_list_extract(null)
  SELECT INTO "nl:"
   ocs.synonym_id, ocs.mnemonic_key_cap, os.order_sentence_id,
   os.order_sentence_display_line, osd.oe_field_display_value, osd.default_parent_entity_id,
   ofm.oe_field_meaning
   FROM order_catalog_synonym ocs,
    ord_cat_sent_r ocsr,
    filter_entity_reltn fer,
    ocs_facility_r ocfr,
    order_sentence os,
    (left JOIN order_sentence_detail osd ON os.order_sentence_id=osd.order_sentence_id
     AND osd.field_type_flag IN (2, 6)),
    (left JOIN oe_field_meaning ofm ON osd.oe_field_meaning_id=ofm.oe_field_meaning_id
     AND ofm.oe_field_meaning IN ("STRENGTHDOSE", "STRENGTHDOSEUNIT", "VOLUMEDOSE", "VOLUMEDOSEUNIT",
    "RXROUTE",
    "DRUGFORM"))
   PLAN (ocs
    WHERE ocs.catalog_type_cd=catalog_type_pharmacy
     AND ocs.orderable_type_flag IN (0, 1)
     AND ocs.oe_format_id > 0
     AND ocs.hide_flag=0
     AND  NOT (ocs.mnemonic_type_cd IN (mnem_type_ygeneric, mnem_type_ztrade, mnem_type_rxmnemonic))
     AND ocs.active_ind=1)
    JOIN (ocsr
    WHERE ocsr.active_ind=1
     AND ocsr.synonym_id=ocs.synonym_id
     AND ocsr.catalog_cd=ocs.catalog_cd)
    JOIN (os
    WHERE os.usage_flag IN (0, 1)
     AND os.order_sentence_id=ocsr.order_sentence_id)
    JOIN (fer
    WHERE fer.parent_entity_id=ocsr.order_sentence_id
     AND fer.filter_type_cd=filter_type_ordersentence
     AND fer.filter_entity1_id IN (0, request->vv_facility))
    JOIN (ocfr
    WHERE ocfr.synonym_id=ocs.synonym_id
     AND ocfr.facility_cd IN (0, request->vv_facility))
    JOIN (osd)
    JOIN (ofm)
   ORDER BY ocs.catalog_cd, ocs.synonym_id, os.order_sentence_id,
    osd.oe_field_id
   HEAD REPORT
    syn_cnt = 0, os_cnt = 0, med_cnt = 0,
    facility_err = 0, holder = 0, os_pos = 0,
    dup_cnt = 0, dnum = 0
   HEAD ocs.synonym_id
    syn_cnt = (syn_cnt+ 1)
    IF (mod(syn_cnt,100)=1
     AND syn_cnt > 4000)
     stat = alterlist(order_list->order_info,(syn_cnt+ 99))
    ENDIF
    order_list->order_info[syn_cnt].catalog_cd = ocs.catalog_cd, order_list->order_info[syn_cnt].
    synonym_id = ocs.synonym_id, order_list->order_info[syn_cnt].synonym = ocs.mnemonic,
    os_cnt = 0
   HEAD os.order_sentence_id
    hld_osd_os_id = os.order_sentence_id, hld_osd_os_desc = os.order_sentence_display_line
   HEAD osd.oe_field_id
    CASE (ofm.oe_field_meaning)
     OF "STRENGTHDOSE":
      hld_osd_str_dose_id = osd.default_parent_entity_id,hld_osd_str_dose_desc = osd
      .oe_field_display_value
     OF "STRENGTHDOSEUNIT":
      hld_osd_str_uom_id = osd.default_parent_entity_id,hld_osd_str_uom_desc = osd
      .oe_field_display_value
     OF "VOLUMEDOSE":
      hld_osd_vol_dose_id = osd.default_parent_entity_id,hld_osd_vol_dose_desc = osd
      .oe_field_display_value
     OF "VOLUMEDOSEUNIT":
      hld_osd_vol_uom_id = osd.default_parent_entity_id,hld_osd_vol_uom_desc = osd
      .oe_field_display_value
     OF "RXROUTE":
      hld_osd_route_id = osd.default_parent_entity_id,hld_osd_route_desc = osd.oe_field_display_value
     OF "DRUGFORM":
      hld_osd_form_id = osd.default_parent_entity_id,hld_osd_form_desc = osd.oe_field_display_value
    ENDCASE
   FOOT  os.order_sentence_id
    dup_chk_string = build(ocs.synonym_id,hld_osd_str_dose_desc,hld_osd_str_uom_id,
     hld_osd_vol_dose_desc,hld_osd_vol_uom_id,
     hld_osd_route_id,hld_osd_form_id), dup_chk_ind = locateval(dnum,0,size(order_list->order_info[
      syn_cnt].os_info,5),dup_chk_string,order_list->order_info[syn_cnt].os_info[dnum].
     os_dup_chk_string)
    IF (dup_chk_ind=0)
     os_cnt = (os_cnt+ 1), stat = alterlist(order_list->order_info[syn_cnt].os_info,os_cnt),
     order_list->order_info[syn_cnt].os_info[os_cnt].os_disp_line = hld_osd_os_desc,
     order_list->order_info[syn_cnt].os_info[os_cnt].os_id = hld_osd_os_id, order_list->order_info[
     syn_cnt].os_info[os_cnt].os_str_dose = hld_osd_str_dose_desc, order_list->order_info[syn_cnt].
     os_info[os_cnt].os_str_uom = hld_osd_str_uom_desc,
     order_list->order_info[syn_cnt].os_info[os_cnt].os_str_uom_id = hld_osd_str_uom_id, order_list->
     order_info[syn_cnt].os_info[os_cnt].os_vol_dose = hld_osd_vol_dose_desc, order_list->order_info[
     syn_cnt].os_info[os_cnt].os_vol_uom = hld_osd_vol_uom_desc,
     order_list->order_info[syn_cnt].os_info[os_cnt].os_vol_uom_id = hld_osd_vol_uom_id, order_list->
     order_info[syn_cnt].os_info[os_cnt].os_route = hld_osd_route_desc, order_list->order_info[
     syn_cnt].os_info[os_cnt].os_route_id = hld_osd_route_id,
     order_list->order_info[syn_cnt].os_info[os_cnt].os_form = hld_osd_form_desc, order_list->
     order_info[syn_cnt].os_info[os_cnt].os_form_id = hld_osd_form_id, order_list->order_info[syn_cnt
     ].os_info[os_cnt].os_dup_chk_string = dup_chk_string,
     order_list->order_info[syn_cnt].os_info[os_cnt].os_route_form_err = route_form_comp(
      hld_osd_route_id,hld_osd_form_id), order_list->order_info[syn_cnt].os_info[os_cnt].facility_err
      = 0, order_list->order_info[syn_cnt].os_info[os_cnt].form_form_err = 0,
     order_list->order_info[syn_cnt].os_info[os_cnt].route_form_err = 0
    ENDIF
    hld_osd_str_dose_id = 0, hld_osd_str_dose_desc = "", hld_osd_str_uom_id = 0,
    hld_osd_str_uom_desc = "", hld_osd_vol_dose_id = 0, hld_osd_vol_dose_desc = "",
    hld_osd_vol_uom_id = 0, hld_osd_vol_uom_desc = "", hld_osd_route_id = 0,
    hld_osd_route_desc = "", hld_osd_form_id = 0, hld_osd_form_desc = ""
   FOOT REPORT
    stat = alterlist(order_list->order_info,syn_cnt)
   WITH nocounter
  ;end select
  CALL bederrorcheck("OrderListExtract")
 END ;Subroutine
 SUBROUTINE uom_conversion(uom_id)
   DECLARE uom_num_one = i4 WITH protect, noconstant(0)
   DECLARE uom_num_two = i4 WITH protect, noconstant(0)
   DECLARE uom_pos_one = i4 WITH protect, noconstant(0)
   DECLARE uom_pos_two = i4 WITH protect, noconstant(0)
   IF (uom_id != 0)
    SET uom_num_one = 0
    SET uom_pos_one = locateval(uom_num_one,1,size(uom->uom,5),uom_id,uom->uom[uom_num_one].
     uom_name_cv)
    IF (uom_pos_one=0)
     RETURN(uom_id)
    ELSE
     IF ((uom->uom[uom_pos_one].uom_numerator_cv != 0))
      SET uom_num_two = 0
      SET uom_pos_two = locateval(uom_num_two,1,size(uom->uom,5),uom->uom[uom_pos_one].
       uom_numerator_cv,uom->uom[uom_num_two].uom_name_cv)
      RETURN(uom->uom[uom_pos_two].uom_base)
     ELSE
      RETURN(uom->uom[uom_pos_one].uom_base)
     ENDIF
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE uom_compare(os_uom_id,med_uom_id)
  IF (os_uom_id != 0
   AND med_uom_id=0)
   RETURN(1)
  ELSEIF (os_uom_id != med_uom_id
   AND os_uom_id != 0
   AND med_uom_id != 0)
   RETURN(2)
  ENDIF
  RETURN(0)
 END ;Subroutine
 SUBROUTINE uom_extract(null)
  SELECT INTO "nl:"
   FROM dose_calculator_uom cod,
    code_value cv1,
    code_value cv2
   PLAN (cod)
    JOIN (cv1
    WHERE cod.uom_cd=cv1.code_value
     AND cv1.code_set=54)
    JOIN (cv2
    WHERE outerjoin(cod.uom_numerator_cd)=cv2.code_value
     AND cv2.code_set=outerjoin(54))
   ORDER BY cod.uom_type_flag, cod.uom_base_nbr, cod.uom_branch_nbr
   HEAD REPORT
    uom_cnt = 0
   DETAIL
    uom_cnt = (uom_cnt+ 1), stat = alterlist(uom->uom,uom_cnt), uom->uom[uom_cnt].uom_base = cod
    .uom_base_nbr,
    uom->uom[uom_cnt].uom_branch = cod.uom_branch_nbr, uom->uom[uom_cnt].uom_name_cv = cod.uom_cd,
    uom->uom[uom_cnt].uom_numerator_cv = cod.uom_numerator_cd
   WITH nocounter
  ;end select
  CALL bederrorcheck("UOMExtract")
 END ;Subroutine
 SUBROUTINE syn_prod_link_extract(null)
  SELECT INTO "nl:"
   FROM synonym_item_r sir
   ORDER BY sir.item_id, sir.synonym_id
   HEAD REPORT
    syn_cnt = 0, item_cnt = 0
   HEAD sir.item_id
    item_cnt = (item_cnt+ 1)
    IF (mod(item_cnt,100)=1
     AND item_cnt > 3000)
     stat = alterlist(syn_prod_linking->item,(item_cnt+ 99))
    ENDIF
    syn_prod_linking->item[item_cnt].item_id = sir.item_id, stat = alterlist(syn_prod_linking->item[
     item_cnt].syn,10), syn_cnt = 0
   HEAD sir.synonym_id
    syn_cnt = (syn_cnt+ 1)
    IF (mod(syn_cnt,10)=1
     AND syn_cnt > 10)
     stat = alterlist(syn_prod_linking->item[item_cnt].syn,(syn_cnt+ 9))
    ENDIF
    syn_prod_linking->item[item_cnt].syn[syn_cnt].syn_id = sir.synonym_id
   FOOT  sir.item_id
    stat = alterlist(syn_prod_linking->item[item_cnt].syn,syn_cnt)
   FOOT REPORT
    stat = alterlist(syn_prod_linking->item,item_cnt)
   WITH nullreport
  ;end select
  CALL bederrorcheck("SynProdLinkExtract")
 END ;Subroutine
 SUBROUTINE syn_prod_link_chk(syn_id,item_id)
   DECLARE item_num = i4 WITH protect, noconstant(0)
   DECLARE item_pos = i4 WITH protect, noconstant(0)
   DECLARE syn_num = i4 WITH protect, noconstant(0)
   DECLARE syn_pos = i4 WITH protect, noconstant(0)
   SET item_pos = locateval(item_num,1,size(syn_prod_linking->item,5),item_id,syn_prod_linking->item[
    item_num].item_id)
   IF (item_pos > 0)
    SET syn_num = 0
    SET syn_pos = locateval(syn_num,1,size(syn_prod_linking->item[item_pos].syn,5),syn_id,
     syn_prod_linking->item[item_pos].syn[syn_num].syn_id)
    IF (syn_pos > 0)
     RETURN(0)
    ELSEIF (syn_pos=0)
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(2)
 END ;Subroutine
 SUBROUTINE no_product_format(ff,rf,fac)
   IF (ff=1)
    SET output = "NO PRODUCTS:FF"
   ENDIF
   IF (rf=1
    AND ff=0)
    SET output = "NO PRODUCTS:RF"
   ELSEIF (rf=1
    AND ff=1)
    SET output = build(output,",RF")
   ENDIF
   IF (fac=1
    AND rf=0
    AND ff=0)
    SET output = "NO PRODUCTS:FAC"
   ELSEIF (fac=1
    AND ((rf=1) OR (ff=1)) )
    SET output = build(output,",FAC")
   ENDIF
   RETURN(output)
 END ;Subroutine
 SUBROUTINE populate_reply(null)
   DECLARE total_col = i4 WITH protect, constant(22)
   DECLARE rcnt = i4 WITH protect, noconstant(0)
   SET stat = alterlist(reply->collist,total_col)
   SET reply->collist[1].header_text = "Synonym"
   SET reply->collist[1].data_type = 1
   SET reply->collist[1].hide_ind = 0
   SET reply->collist[2].header_text = "OS ID"
   SET reply->collist[2].data_type = 2
   SET reply->collist[2].hide_ind = 0
   SET reply->collist[3].header_text = "Order Sentence Display"
   SET reply->collist[3].data_type = 1
   SET reply->collist[3].hide_ind = 0
   SET reply->collist[4].header_text = "Order Sentence Strength"
   SET reply->collist[4].data_type = 1
   SET reply->collist[4].hide_ind = 0
   SET reply->collist[5].header_text = "Order Sentence Strength Unit"
   SET reply->collist[5].data_type = 1
   SET reply->collist[5].hide_ind = 0
   SET reply->collist[6].header_text = "Order Sentence Volume"
   SET reply->collist[6].data_type = 1
   SET reply->collist[6].hide_ind = 0
   SET reply->collist[7].header_text = "Order Sentence Volume Unit"
   SET reply->collist[7].data_type = 1
   SET reply->collist[7].hide_ind = 0
   SET reply->collist[8].header_text = "Order Sentence Route"
   SET reply->collist[8].data_type = 1
   SET reply->collist[8].hide_ind = 0
   SET reply->collist[9].header_text = "Order Sentence Drug Form"
   SET reply->collist[9].data_type = 1
   SET reply->collist[9].hide_ind = 0
   SET reply->collist[10].header_text = "Ready Ind"
   SET reply->collist[10].data_type = 2
   SET reply->collist[10].hide_ind = 0
   SET reply->collist[11].header_text = "Product Label Description"
   SET reply->collist[11].data_type = 1
   SET reply->collist[11].hide_ind = 0
   SET reply->collist[12].header_text = "Product Strength"
   SET reply->collist[12].data_type = 1
   SET reply->collist[12].hide_ind = 0
   SET reply->collist[13].header_text = "Product Strength Unit"
   SET reply->collist[13].data_type = 1
   SET reply->collist[13].hide_ind = 0
   SET reply->collist[14].header_text = "Product Volume"
   SET reply->collist[14].data_type = 1
   SET reply->collist[14].hide_ind = 0
   SET reply->collist[15].header_text = "Product Volume Unit"
   SET reply->collist[15].data_type = 1
   SET reply->collist[15].hide_ind = 0
   SET reply->collist[16].header_text = "Product Drug Form"
   SET reply->collist[16].data_type = 1
   SET reply->collist[16].hide_ind = 0
   SET reply->collist[17].header_text = "NDC"
   SET reply->collist[17].data_type = 1
   SET reply->collist[17].hide_ind = 0
   SET reply->collist[18].header_text = "Strength Mismatch"
   SET reply->collist[18].data_type = 1
   SET reply->collist[18].hide_ind = 0
   SET reply->collist[19].header_text = "Volume mismatch"
   SET reply->collist[19].data_type = 1
   SET reply->collist[19].hide_ind = 0
   SET reply->collist[20].header_text = "Route Form Incompatibility"
   SET reply->collist[20].data_type = 1
   SET reply->collist[20].hide_ind = 0
   SET reply->collist[21].header_text = "Linked?"
   SET reply->collist[21].data_type = 1
   SET reply->collist[21].hide_ind = 0
   SET reply->collist[22].header_text = "Status"
   SET reply->collist[22].data_type = 1
   SET reply->collist[22].hide_ind = 0
   SELECT INTO "nl:"
    strength_uom = uar_get_code_display(md.strength_unit_cd), volume_uom = uar_get_code_display(md
     .volume_unit_cd), form = uar_get_code_display(mdef.form_cd),
    syn_id = order_list->order_info[d1.seq].synonym_id, cat_cd = order_list->order_info[d1.seq].
    catalog_cd, os_id = order_list->order_info[d1.seq].os_info[d2.seq].os_id
    FROM (dummyt d1  WITH seq = value(size(order_list->order_info,5))),
     (dummyt d2  WITH seq = 1),
     order_catalog_item_r ocir,
     med_identifier mi1,
     med_identifier mi2,
     med_flex_object_idx mfoi,
     med_dispense md,
     medication_definition mdef,
     med_def_flex mdf,
     (left JOIN med_flex_object_idx mfoi2 ON mdf.med_def_flex_id=mfoi2.med_def_flex_id
      AND mfoi2.flex_object_type_cd=flex_obj_type_orderable
      AND mfoi2.active_ind=1
      AND mfoi2.parent_entity_id IN (0, request->vv_facility))
    PLAN (d1
     WHERE maxrec(d2,size(order_list->order_info[d1.seq].os_info,5)))
     JOIN (d2)
     JOIN (ocir
     WHERE (ocir.catalog_cd=order_list->order_info[d1.seq].catalog_cd))
     JOIN (mi1
     WHERE mi1.med_identifier_type_cd=med_ident_type_desc
      AND mi1.med_product_id=0
      AND mi1.pharmacy_type_cd=pharmacytypeinpatient
      AND mi1.active_ind=1
      AND mi1.primary_ind=1
      AND ocir.item_id=mi1.item_id)
     JOIN (mi2
     WHERE mi1.item_id=mi2.item_id
      AND mi2.med_identifier_type_cd=med_ident_type_ndc
      AND mi2.pharmacy_type_cd=pharmacytypeinpatient
      AND mi2.active_ind=1)
     JOIN (mfoi
     WHERE mi2.med_product_id=mfoi.parent_entity_id
      AND mfoi.sequence=1
      AND mfoi.active_ind=1
      AND mfoi.flex_object_type_cd=medproduct)
     JOIN (md
     WHERE mi1.item_id=md.item_id
      AND md.pharmacy_type_cd=pharmacytypeinpatient)
     JOIN (mdef
     WHERE mdef.item_id=mi1.item_id)
     JOIN (mdf
     WHERE mdf.flex_type_cd=flex_type_syspkgtyp
      AND mdf.pharmacy_type_cd=pharmacytypeinpatient
      AND mdf.active_status_cd=active_status_active
      AND mdf.item_id=mi1.item_id)
     JOIN (mfoi2)
    ORDER BY ocir.catalog_cd, syn_id, os_id,
     mi1.item_id
    HEAD REPORT
     cat_cnt = 0, syn_cnt = 0, os_cnt = 0,
     med_cnt = 0
    HEAD syn_id
     syn_cnt = (syn_cnt+ 1)
    HEAD os_id
     os_chk_ind = 0, os_str_uom_cnvt = 0, os_vol_uom_cnvt = 0,
     os_str_dose_cnvt = 0, os_vol_dose_cnvt = 0, os_no_products_ind = 1,
     os_conv_str_ind = 0, os_conv_vol_ind = 0, med_cnt = 0,
     stat = alterlist(order_list->order_info[d1.seq].os_info[d2.seq].med_info,10)
    HEAD mi1.item_id
     med_disqualify_ind = 0, med_nr_ind = 0, str_uom_err_output = " ",
     vol_uom_err_output = " ", med_linked_status = 0, med_linked_disp = " "
     IF (mfoi2.med_def_flex_id=null)
      order_list->order_info[d1.seq].os_info[d2.seq].facility_err = 1, med_disqualify_ind = 1
     ENDIF
     IF ((order_list->order_info[d1.seq].os_info[d2.seq].os_form_id != mdef.form_cd)
      AND  NOT ((order_list->order_info[d1.seq].os_info[d2.seq].os_form_id IN (0, null))))
      order_list->order_info[d1.seq].os_info[d2.seq].form_form_err = 1, med_disqualify_ind = 1
     ENDIF
     IF (route_form_comp(order_list->order_info[d1.seq].os_info[d2.seq].os_route_id,mdef.form_cd)="X"
      AND  NOT ((order_list->order_info[d1.seq].os_info[d2.seq].os_route_id IN (null, 0)))
      AND (((order_list->order_info[d1.seq].os_info[d2.seq].os_form_id IN (null, 0))) OR ((order_list
     ->order_info[d1.seq].os_info[d2.seq].form_form_err=1))) )
      order_list->order_info[d1.seq].os_info[d2.seq].route_form_err = 1, med_disqualify_ind = 1
     ENDIF
     IF (med_disqualify_ind=0)
      med_cnt = (med_cnt+ 1)
      IF (mod(med_cnt,10)=1
       AND med_cnt > 10)
       stat = alterlist(order_list->order_info[d1.seq].os_info[d2.seq].med_info,(med_cnt+ 9))
      ENDIF
      os_no_products_ind = 0
      IF ((order_list->order_info[d1.seq].os_info[d2.seq].os_str_uom_id=0)
       AND (order_list->order_info[d1.seq].os_info[d2.seq].os_vol_uom_id=0))
       str_uom_err_output = "-", vol_uom_err_output = "-"
      ELSE
       str_uom_err_ind = uom_compare(order_list->order_info[d1.seq].os_info[d2.seq].os_str_uom_id,md
        .strength_unit_cd)
       IF (str_uom_err_ind=2)
        med_str_uom_cnvt = uom_conversion(md.strength_unit_cd)
        IF (os_conv_str_ind=0
         AND (order_list->order_info[d1.seq].os_info[d2.seq].os_str_uom_id != 0))
         os_str_uom_cnvt = uom_conversion(order_list->order_info[d1.seq].os_info[d2.seq].
          os_str_uom_id)
        ENDIF
        os_conv_str_ind = 1, str_uom_err_ind = uom_compare(cnvtreal(os_str_uom_cnvt),cnvtreal(
          med_str_uom_cnvt))
       ENDIF
       vol_uom_err_ind = uom_compare(order_list->order_info[d1.seq].os_info[d2.seq].os_vol_uom_id,md
        .volume_unit_cd)
       IF (vol_uom_err_ind=2)
        med_vol_uom_cnvt = uom_conversion(md.volume_unit_cd)
        IF (os_conv_vol_ind=0
         AND (order_list->order_info[d1.seq].os_info[d2.seq].os_vol_uom_id != 0))
         os_vol_uom_cnvt = uom_conversion(order_list->order_info[d1.seq].os_info[d2.seq].
          os_vol_uom_id)
        ENDIF
        os_conv_vol_ind = 1, vol_uom_err_ind = uom_compare(cnvtreal(os_vol_uom_cnvt),cnvtreal(
          med_vol_uom_cnvt))
       ENDIF
       IF (str_uom_err_ind IN (1, 2))
        med_nr_ind = 1, str_uom_err_output = "X"
       ENDIF
       IF (vol_uom_err_ind IN (1, 2))
        med_nr_ind = 1, vol_uom_err_output = "X"
       ENDIF
      ENDIF
      med_linked_status = syn_prod_link_chk(order_list->order_info[d1.seq].synonym_id,mi1.item_id)
      IF (med_linked_status=0)
       med_linked_disp = "LINKED"
      ELSEIF (med_linked_status=1)
       med_linked_disp = "X", med_nr_ind = 1
      ELSEIF (med_linked_status=2)
       IF ((order_list->order_info[d1.seq].os_info[d2.seq].os_str_uom_id=0)
        AND (order_list->order_info[d1.seq].os_info[d2.seq].os_vol_uom_id != 0)
        AND  NOT (md.volume_unit_cd IN (null, 0))
        AND  NOT (md.strength_unit_cd IN (null, 0)))
        med_linked_disp = "X", med_nr_ind = 1
       ELSE
        med_linked_disp = "LINKING BY EXCEPTION"
       ENDIF
      ENDIF
      IF (((med_nr_ind=1) OR ((order_list->order_info[d1.seq].os_info[d2.seq].os_route_form_err="X")
      )) )
       med_ready_display = "NOT READY"
      ELSE
       med_ready_display = "READY", os_chk_ind = 1
      ENDIF
      order_list->order_info[d1.seq].os_info[d2.seq].med_info[med_cnt].med_desc = mi1.value,
      order_list->order_info[d1.seq].os_info[d2.seq].med_info[med_cnt].med_str = md.strength,
      order_list->order_info[d1.seq].os_info[d2.seq].med_info[med_cnt].med_str_uom = strength_uom,
      order_list->order_info[d1.seq].os_info[d2.seq].med_info[med_cnt].med_vol = md.volume,
      order_list->order_info[d1.seq].os_info[d2.seq].med_info[med_cnt].med_vol_uom = volume_uom,
      order_list->order_info[d1.seq].os_info[d2.seq].med_info[med_cnt].med_form = form,
      order_list->order_info[d1.seq].os_info[d2.seq].med_info[med_cnt].med_ndc = mi2.value,
      order_list->order_info[d1.seq].os_info[d2.seq].med_info[med_cnt].str_uom_err_output =
      str_uom_err_output, order_list->order_info[d1.seq].os_info[d2.seq].med_info[med_cnt].
      vol_uom_err_output = vol_uom_err_output,
      order_list->order_info[d1.seq].os_info[d2.seq].med_info[med_cnt].med_linked_disp =
      med_linked_disp, order_list->order_info[d1.seq].os_info[d2.seq].med_info[med_cnt].
      med_ready_display = med_ready_display
     ENDIF
    FOOT  os_id
     stat = alterlist(order_list->order_info[d1.seq].os_info[d2.seq].med_info,med_cnt)
     IF (os_no_products_ind=1)
      rcnt = (rcnt+ 1), stat = alterlist(reply->rowlist,rcnt), stat = alterlist(reply->rowlist[rcnt].
       celllist,total_col),
      no_product_output = no_product_format(order_list->order_info[d1.seq].os_info[d2.seq].
       form_form_err,order_list->order_info[d1.seq].os_info[d2.seq].route_form_err,order_list->
       order_info[d1.seq].os_info[d2.seq].facility_err), reply->rowlist[rcnt].celllist[1].
      string_value = order_list->order_info[d1.seq].synonym, reply->rowlist[rcnt].celllist[2].
      double_value = order_list->order_info[d1.seq].os_info[d2.seq].os_id,
      reply->rowlist[rcnt].celllist[3].string_value = order_list->order_info[d1.seq].os_info[d2.seq].
      os_disp_line, reply->rowlist[rcnt].celllist[4].string_value = order_list->order_info[d1.seq].
      os_info[d2.seq].os_str_dose, reply->rowlist[rcnt].celllist[5].string_value = order_list->
      order_info[d1.seq].os_info[d2.seq].os_str_uom,
      reply->rowlist[rcnt].celllist[6].string_value = order_list->order_info[d1.seq].os_info[d2.seq].
      os_vol_dose, reply->rowlist[rcnt].celllist[7].string_value = order_list->order_info[d1.seq].
      os_info[d2.seq].os_vol_uom, reply->rowlist[rcnt].celllist[8].string_value = order_list->
      order_info[d1.seq].os_info[d2.seq].os_route,
      reply->rowlist[rcnt].celllist[9].string_value = order_list->order_info[d1.seq].os_info[d2.seq].
      os_form, reply->rowlist[rcnt].celllist[10].double_value = 0, reply->rowlist[rcnt].celllist[11].
      string_value = no_product_output,
      reply->rowlist[rcnt].celllist[12].string_value = " ", reply->rowlist[rcnt].celllist[13].
      string_value = " ", reply->rowlist[rcnt].celllist[14].string_value = " ",
      reply->rowlist[rcnt].celllist[15].string_value = " ", reply->rowlist[rcnt].celllist[16].
      string_value = " ", reply->rowlist[rcnt].celllist[17].string_value = " ",
      reply->rowlist[rcnt].celllist[18].string_value = " ", reply->rowlist[rcnt].celllist[19].
      string_value = " ", reply->rowlist[rcnt].celllist[20].string_value = order_list->order_info[d1
      .seq].os_info[d2.seq].os_route_form_err,
      reply->rowlist[rcnt].celllist[21].string_value = " ", reply->rowlist[rcnt].celllist[22].
      string_value = "NOT READY"
     ELSE
      FOR (x = 1 TO size(order_list->order_info[d1.seq].os_info[d2.seq].med_info,5))
        rcnt = (rcnt+ 1), stat = alterlist(reply->rowlist,rcnt), stat = alterlist(reply->rowlist[rcnt
         ].celllist,total_col),
        reply->rowlist[rcnt].celllist[1].string_value = order_list->order_info[d1.seq].synonym, reply
        ->rowlist[rcnt].celllist[2].double_value = order_list->order_info[d1.seq].os_info[d2.seq].
        os_id, reply->rowlist[rcnt].celllist[3].string_value = order_list->order_info[d1.seq].
        os_info[d2.seq].os_disp_line,
        reply->rowlist[rcnt].celllist[4].string_value = order_list->order_info[d1.seq].os_info[d2.seq
        ].os_str_dose, reply->rowlist[rcnt].celllist[5].string_value = order_list->order_info[d1.seq]
        .os_info[d2.seq].os_str_uom, reply->rowlist[rcnt].celllist[6].string_value = order_list->
        order_info[d1.seq].os_info[d2.seq].os_vol_dose,
        reply->rowlist[rcnt].celllist[7].string_value = order_list->order_info[d1.seq].os_info[d2.seq
        ].os_vol_uom, reply->rowlist[rcnt].celllist[8].string_value = order_list->order_info[d1.seq].
        os_info[d2.seq].os_route, reply->rowlist[rcnt].celllist[9].string_value = order_list->
        order_info[d1.seq].os_info[d2.seq].os_form,
        reply->rowlist[rcnt].celllist[10].double_value = os_chk_ind, reply->rowlist[rcnt].celllist[11
        ].string_value = order_list->order_info[d1.seq].os_info[d2.seq].med_info[x].med_desc, reply->
        rowlist[rcnt].celllist[12].string_value = build(order_list->order_info[d1.seq].os_info[d2.seq
         ].med_info[x].med_str),
        reply->rowlist[rcnt].celllist[13].string_value = order_list->order_info[d1.seq].os_info[d2
        .seq].med_info[x].med_str_uom, reply->rowlist[rcnt].celllist[14].string_value = build(
         order_list->order_info[d1.seq].os_info[d2.seq].med_info[x].med_vol), reply->rowlist[rcnt].
        celllist[15].string_value = order_list->order_info[d1.seq].os_info[d2.seq].med_info[x].
        med_vol_uom,
        reply->rowlist[rcnt].celllist[16].string_value = order_list->order_info[d1.seq].os_info[d2
        .seq].med_info[x].med_form, reply->rowlist[rcnt].celllist[17].string_value = order_list->
        order_info[d1.seq].os_info[d2.seq].med_info[x].med_ndc, reply->rowlist[rcnt].celllist[18].
        string_value = order_list->order_info[d1.seq].os_info[d2.seq].med_info[x].str_uom_err_output,
        reply->rowlist[rcnt].celllist[19].string_value = order_list->order_info[d1.seq].os_info[d2
        .seq].med_info[x].vol_uom_err_output, reply->rowlist[rcnt].celllist[20].string_value =
        order_list->order_info[d1.seq].os_info[d2.seq].os_route_form_err, reply->rowlist[rcnt].
        celllist[21].string_value = order_list->order_info[d1.seq].os_info[d2.seq].med_info[x].
        med_linked_disp,
        reply->rowlist[rcnt].celllist[22].string_value = order_list->order_info[d1.seq].os_info[d2
        .seq].med_info[x].med_ready_display
      ENDFOR
     ENDIF
    WITH nocounter, maxcol = 15000
   ;end select
   IF ((request->skip_volume_check_ind=0))
    IF (rcnt > 10000)
     SET reply->high_volume_flag = 2
    ELSEIF (rcnt > 5000)
     SET reply->high_volume_flag = 1
    ENDIF
   ENDIF
   IF ((reply->high_volume_flag IN (1, 2)))
    SET reply->output_filename = build("bed_aud_os_prod_scan.csv")
   ENDIF
   IF ((request->output_filename > " "))
    EXECUTE bed_rpt_file
   ENDIF
   CALL bederrorcheck("populatereply")
 END ;Subroutine
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
