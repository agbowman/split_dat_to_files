CREATE PROGRAM bed_rec_incmp_rx_mnem_detail:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 paramlist[*]
      2 meaning = vc
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
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 res_collist[*]
      2 header_text = vc
    1 res_rowlist[*]
      2 res_celllist[*]
        3 cell_text = vc
  )
 ENDIF
 FREE RECORD temp
 RECORD temp(
   1 o_cnt = i4
   1 olist[*]
     2 catalog_cd = f8
     2 item_id = f8
     2 synonym_id = f8
     2 formulary_product = vc
     2 formulary_product_key_cap = vc
     2 primary_mnemonic = vc
     2 primary_mnemonic_key_cap = vc
     2 rx_mnemonic = vc
     2 oe_format_id = f8
     2 no_rx_mask_ind = i2
     2 no_oef_ind = i2
 )
 SET cdesc = 0.0
 SET crxm = 0.0
 SET corder = 0.0
 SET csystem = 0.0
 SET cinpatient = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=11000
    AND cv.cdf_meaning="DESC"
    AND cv.active_ind=1)
  DETAIL
   cdesc = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6011
    AND cv.cdf_meaning="RXMNEMONIC"
    AND cv.active_ind=1)
  DETAIL
   crxm = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6003
    AND cv.cdf_meaning="ORDER"
    AND cv.active_ind=1)
  DETAIL
   corder = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=4062
    AND cv.cdf_meaning="SYSTEM"
    AND cv.active_ind=1)
  DETAIL
   csystem = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=4500
    AND cv.cdf_meaning="INPATIENT"
    AND cv.active_ind=1)
  DETAIL
   cinpatient = cv.code_value
  WITH nocounter
 ;end select
 SET plsize = size(request->paramlist,5)
 SET stat = alterlist(reply->res_collist,2)
 SET reply->res_collist[1].header_text = "Check Name"
 SET reply->res_collist[2].header_text = "Resolution"
 SET stat = alterlist(reply->res_rowlist,plsize)
 FOR (p = 1 TO plsize)
   SELECT INTO "nl:"
    FROM br_rec b,
     br_long_text bl2
    PLAN (b
     WHERE (b.rec_mean=request->paramlist[p].meaning))
     JOIN (bl2
     WHERE bl2.long_text_id=b.resolution_txt_id)
    DETAIL
     stat = alterlist(reply->res_rowlist[p].res_celllist,2), reply->res_rowlist[p].res_celllist[1].
     cell_text = b.short_desc, reply->res_rowlist[p].res_celllist[2].cell_text = bl2.long_text
    WITH nocounter
   ;end select
 ENDFOR
 SET check_no_rx_ind = 0
 SET check_no_oef_ind = 0
 SET no_rx_col_nbr = 0
 SET no_oef_col_nbr = 0
 SET rx_mnem_col_nbr = 0
 SET col_cnt = (3+ plsize)
 SET stat = alterlist(reply->collist,col_cnt)
 SET reply->collist[1].header_text = "Formulary Product"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Primary Mnemonic"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Rx Mnemonic"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET temp->o_cnt = 0
 SET o_cnt = 0
 SET next_col = 3
 FOR (p = 1 TO plsize)
  IF ((request->paramlist[p].meaning="RXMNEMMISSINGRXMASK"))
   SET check_no_rx_ind = 1
   SET next_col = (next_col+ 1)
   SET no_rx_col_nbr = next_col
   SET reply->collist[next_col].header_text = "No Rx Mask"
   SET reply->collist[next_col].data_type = 1
   SET reply->collist[next_col].hide_ind = 0
   SELECT INTO "nl:"
    FROM order_catalog_item_r ocir,
     order_catalog oc,
     item_definition id,
     med_identifier mi,
     order_catalog_synonym ocs,
     med_def_flex mdf
    PLAN (ocir)
     JOIN (oc
     WHERE oc.catalog_cd=ocir.catalog_cd
      AND oc.active_ind=1)
     JOIN (id
     WHERE id.item_id=ocir.item_id
      AND id.active_ind=1)
     JOIN (mdf
     WHERE mdf.item_id=ocir.item_id
      AND mdf.flex_type_cd=csystem
      AND mdf.pharmacy_type_cd=cinpatient)
     JOIN (mi
     WHERE mi.item_id=id.item_id
      AND mi.med_product_id=0
      AND mi.med_identifier_type_cd=cdesc
      AND mi.active_ind=1
      AND mi.primary_ind=1
      AND mi.pharmacy_type_cd=cinpatient)
     JOIN (ocs
     WHERE ocs.item_id=ocir.item_id
      AND ocs.mnemonic_type_cd=crxm
      AND ocs.active_ind=1)
    DETAIL
     IF (ocs.rx_mask=0)
      o_cnt = (o_cnt+ 1), temp->o_cnt = o_cnt, stat = alterlist(temp->olist,o_cnt),
      temp->olist[o_cnt].item_id = ocir.item_id, temp->olist[o_cnt].catalog_cd = oc.catalog_cd, temp
      ->olist[o_cnt].synonym_id = ocs.synonym_id,
      temp->olist[o_cnt].primary_mnemonic = oc.primary_mnemonic, temp->olist[o_cnt].
      primary_mnemonic_key_cap = cnvtupper(oc.primary_mnemonic), temp->olist[o_cnt].formulary_product
       = substring(1,75,mi.value),
      temp->olist[o_cnt].formulary_product_key_cap = cnvtupper(substring(1,75,mi.value)), temp->
      olist[o_cnt].oe_format_id = ocs.oe_format_id, temp->olist[o_cnt].rx_mnemonic = ocs.mnemonic,
      temp->olist[o_cnt].no_rx_mask_ind = 1
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
  IF ((request->paramlist[p].meaning="RXMNEMMISSINGOEF"))
   SET check_no_oef_ind = 1
   SET next_col = (next_col+ 1)
   SET no_oef_col_nbr = next_col
   SET reply->collist[next_col].header_text = "No Order Entry Format"
   SET reply->collist[next_col].data_type = 1
   SET reply->collist[next_col].hide_ind = 0
   SELECT INTO "nl:"
    FROM order_catalog_item_r ocir,
     order_catalog oc,
     item_definition id,
     med_identifier mi,
     order_catalog_synonym ocs,
     med_def_flex mdf
    PLAN (ocir)
     JOIN (oc
     WHERE oc.catalog_cd=ocir.catalog_cd
      AND oc.active_ind=1)
     JOIN (id
     WHERE id.item_id=ocir.item_id
      AND id.active_ind=1)
     JOIN (mdf
     WHERE mdf.item_id=ocir.item_id
      AND mdf.flex_type_cd=csystem
      AND mdf.pharmacy_type_cd=cinpatient)
     JOIN (mi
     WHERE mi.item_id=id.item_id
      AND mi.med_product_id=0
      AND mi.med_identifier_type_cd=cdesc
      AND mi.active_ind=1
      AND mi.primary_ind=1
      AND mi.pharmacy_type_cd=cinpatient)
     JOIN (ocs
     WHERE ocs.item_id=ocir.item_id
      AND ocs.mnemonic_type_cd=crxm
      AND ocs.active_ind=1)
    DETAIL
     IF (ocs.oe_format_id=0)
      o_cnt = (o_cnt+ 1), temp->o_cnt = o_cnt, stat = alterlist(temp->olist,o_cnt),
      temp->olist[o_cnt].item_id = ocir.item_id, temp->olist[o_cnt].catalog_cd = oc.catalog_cd, temp
      ->olist[o_cnt].synonym_id = ocs.synonym_id,
      temp->olist[o_cnt].primary_mnemonic = oc.primary_mnemonic, temp->olist[o_cnt].
      primary_mnemonic_key_cap = cnvtupper(oc.primary_mnemonic), temp->olist[o_cnt].formulary_product
       = substring(1,75,mi.value),
      temp->olist[o_cnt].formulary_product_key_cap = cnvtupper(substring(1,75,mi.value)), temp->
      olist[o_cnt].oe_format_id = ocs.oe_format_id, temp->olist[o_cnt].no_oef_ind = 1,
      temp->olist[o_cnt].rx_mnemonic = ocs.mnemonic
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ENDFOR
 SET row_nbr = 0
 IF ((temp->o_cnt > 0))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = temp->o_cnt)
   PLAN (d)
   ORDER BY temp->olist[d.seq].formulary_product_key_cap, temp->olist[d.seq].primary_mnemonic_key_cap
   DETAIL
    IF ((((temp->olist[d.seq].no_rx_mask_ind=1)) OR ((temp->olist[d.seq].no_oef_ind=1))) )
     row_nbr = (row_nbr+ 1), stat = alterlist(reply->rowlist,row_nbr), stat = alterlist(reply->
      rowlist[row_nbr].celllist,col_cnt),
     reply->rowlist[row_nbr].celllist[1].string_value = temp->olist[d.seq].formulary_product, reply->
     rowlist[row_nbr].celllist[2].string_value = temp->olist[d.seq].primary_mnemonic, reply->rowlist[
     row_nbr].celllist[3].string_value = temp->olist[d.seq].rx_mnemonic
     IF (check_no_rx_ind=1
      AND (temp->olist[d.seq].no_rx_mask_ind=1))
      reply->rowlist[row_nbr].celllist[no_rx_col_nbr].string_value = "X"
     ENDIF
     IF (check_no_oef_ind=1
      AND (temp->olist[d.seq].no_oef_ind=1))
      reply->rowlist[row_nbr].celllist[no_oef_col_nbr].string_value = "X"
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
END GO
