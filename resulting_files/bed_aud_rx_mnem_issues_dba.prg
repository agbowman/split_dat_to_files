CREATE PROGRAM bed_aud_rx_mnem_issues:dba
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
 SET high_volume_cnt = 0
 SELECT INTO "nl:"
  hv_cnt = count(*)
  FROM order_catalog_item_r ocir
  PLAN (ocir)
  DETAIL
   high_volume_cnt = hv_cnt
  WITH nocounter
 ;end select
 CALL echo(high_volume_cnt)
 IF ((request->skip_volume_check_ind=0))
  IF (high_volume_cnt > 20000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 10000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET temp->o_cnt = 0
 SELECT INTO "nl:"
  FROM order_catalog_item_r ocir,
   order_catalog oc,
   item_definition id,
   med_identifier mi,
   order_catalog_synonym ocs,
   med_def_flex mdf
  PLAN (ocir)
   JOIN (oc
   WHERE oc.catalog_cd=ocir.catalog_cd)
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
    AND ocs.mnemonic_type_cd=crxm)
  HEAD REPORT
   o_cnt = 0
  DETAIL
   o_cnt = (o_cnt+ 1), temp->o_cnt = o_cnt, stat = alterlist(temp->olist,o_cnt),
   temp->olist[o_cnt].item_id = ocir.item_id, temp->olist[o_cnt].catalog_cd = oc.catalog_cd, temp->
   olist[o_cnt].synonym_id = ocs.synonym_id,
   temp->olist[o_cnt].primary_mnemonic = oc.primary_mnemonic, temp->olist[o_cnt].
   primary_mnemonic_key_cap = cnvtupper(oc.primary_mnemonic), temp->olist[o_cnt].formulary_product =
   substring(1,75,mi.value),
   temp->olist[o_cnt].formulary_product_key_cap = cnvtupper(substring(1,75,mi.value)), temp->olist[
   o_cnt].oe_format_id = ocs.oe_format_id, temp->olist[o_cnt].rx_mnemonic = ocs.mnemonic
   IF (ocs.rx_mask=0)
    temp->olist[o_cnt].no_rx_mask_ind = 1
   ELSE
    temp->olist[o_cnt].no_rx_mask_ind = 0
   ENDIF
   IF (ocs.oe_format_id=0)
    temp->olist[o_cnt].no_oef_ind = 1
   ELSE
    temp->olist[o_cnt].no_oef_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,8)
 SET reply->collist[1].header_text = "Formulary Product"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Primary Mnemonic"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "No RX Mask"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "No Order Entry Format"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "RX Mnemonic"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "item_id"
 SET reply->collist[6].data_type = 2
 SET reply->collist[6].hide_ind = 1
 SET reply->collist[7].header_text = "catalog_cd"
 SET reply->collist[7].data_type = 2
 SET reply->collist[7].hide_ind = 1
 SET reply->collist[8].header_text = "synonym_id"
 SET reply->collist[8].data_type = 2
 SET reply->collist[8].hide_ind = 1
 IF ((temp->o_cnt=0))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = temp->o_cnt),
   order_entry_format oef
  PLAN (d
   WHERE (temp->olist[d.seq].oe_format_id > 0))
   JOIN (oef
   WHERE (oef.oe_format_id=temp->olist[d.seq].oe_format_id)
    AND oef.action_type_cd=corder)
  DETAIL
   temp->olist[d.seq].no_oef_ind = 0
  WITH nocounter, outerjoin = d, dontexist
 ;end select
 SET row_nbr = 0
 SET no_rx_mask_cnt = 0
 SET no_oef_cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = temp->o_cnt)
  PLAN (d)
  ORDER BY temp->olist[d.seq].formulary_product_key_cap, temp->olist[d.seq].primary_mnemonic_key_cap
  DETAIL
   IF ((((temp->olist[d.seq].no_rx_mask_ind=1)) OR ((temp->olist[d.seq].no_oef_ind=1))) )
    row_nbr = (row_nbr+ 1), stat = alterlist(reply->rowlist,row_nbr), stat = alterlist(reply->
     rowlist[row_nbr].celllist,8),
    reply->rowlist[row_nbr].celllist[1].string_value = temp->olist[d.seq].formulary_product, reply->
    rowlist[row_nbr].celllist[2].string_value = temp->olist[d.seq].primary_mnemonic
    IF ((temp->olist[d.seq].no_rx_mask_ind=1))
     no_rx_mask_cnt = (no_rx_mask_cnt+ 1), reply->rowlist[row_nbr].celllist[3].string_value = "X"
    ELSE
     reply->rowlist[row_nbr].celllist[3].string_value = " "
    ENDIF
    IF ((temp->olist[d.seq].no_oef_ind=1))
     no_oef_cnt = (no_oef_cnt+ 1), reply->rowlist[row_nbr].celllist[4].string_value = "X"
    ELSE
     reply->rowlist[row_nbr].celllist[4].string_value = " "
    ENDIF
    reply->rowlist[row_nbr].celllist[5].string_value = temp->olist[d.seq].rx_mnemonic, reply->
    rowlist[row_nbr].celllist[6].double_value = temp->olist[d.seq].item_id, reply->rowlist[row_nbr].
    celllist[7].double_value = temp->olist[d.seq].catalog_cd,
    reply->rowlist[row_nbr].celllist[8].double_value = temp->olist[d.seq].synonym_id
   ENDIF
  WITH nocounter
 ;end select
 IF (no_oef_cnt=0
  AND no_rx_mask_cnt=0)
  SET reply->run_status_flag = 1
 ELSE
  SET reply->run_status_flag = 3
 ENDIF
 SET stat = alterlist(reply->statlist,2)
 SET reply->statlist[1].total_items = high_volume_cnt
 SET reply->statlist[1].qualifying_items = no_oef_cnt
 SET reply->statlist[1].statistic_meaning = "RXMNEMNOOEF"
 IF (no_oef_cnt > 0)
  SET reply->statlist[1].status_flag = 3
 ELSE
  SET reply->statlist[1].status_flag = 1
 ENDIF
 SET reply->statlist[2].total_items = high_volume_cnt
 SET reply->statlist[2].qualifying_items = no_rx_mask_cnt
 SET reply->statlist[2].statistic_meaning = "RXMNEMNORXMASK"
 IF (no_rx_mask_cnt > 0)
  SET reply->statlist[2].status_flag = 3
 ELSE
  SET reply->statlist[2].status_flag = 1
 ENDIF
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("rx_mnem_issues_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
