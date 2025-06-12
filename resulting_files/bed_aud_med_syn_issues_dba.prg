CREATE PROGRAM bed_aud_med_syn_issues:dba
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
     2 synonym_id = f8
     2 mnemonic = vc
     2 mnemonic_key_cap = vc
     2 mnemonic_type_cd = f8
     2 mnemonic_type_disp = vc
     2 description = vc
     2 description_key_cap = vc
     2 oe_format_id = f8
     2 no_ord_sent_ind = i2
     2 no_rx_mask_ind = i2
     2 no_oef_ind = i2
     2 no_clin_cat_syn_ind = i2
     2 no_cki_ind = i2
 )
 SET corder = 0.0
 SET cpharm = 0.0
 SET cprimpharm = 0.0
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
   WHERE cv.code_set=6000
    AND cv.cdf_meaning="PHARMACY"
    AND cv.active_ind=1)
  DETAIL
   cpharm = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_entry_format oef
  PLAN (oef
   WHERE oef.action_type_cd=corder
    AND cnvtupper(oef.oe_format_name)="PRIMARY PHARMACY")
  DETAIL
   cprimpharm = oef.oe_format_id
  WITH nocounter
 ;end select
 SET high_volume_cnt = 0
 SELECT INTO "nl:"
  hv_cnt = count(*)
  FROM order_catalog_synonym ocs
  PLAN (ocs
   WHERE ocs.catalog_type_cd=cpharm
    AND ocs.active_ind=1
    AND ocs.hide_flag != 1
    AND ocs.mnemonic_type_cd IN (
   (SELECT
    code_value
    FROM code_value
    WHERE code_set=6011
     AND cdf_meaning IN ("BRANDNAME", "DCP", "DISPDRUG", "GENERICTOP", "IVNAME",
    "PRIMARY", "TRADETOP")))
    AND ocs.synonym_id IN (
   (SELECT DISTINCT
    synonym_id
    FROM ocs_facility_r)))
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
  FROM order_catalog_synonym ocs,
   order_catalog oc,
   code_value cv
  PLAN (ocs
   WHERE ocs.catalog_type_cd=cpharm
    AND ocs.active_ind=1
    AND ocs.hide_flag != 1
    AND ocs.mnemonic_type_cd IN (
   (SELECT
    code_value
    FROM code_value
    WHERE code_set=6011
     AND cdf_meaning IN ("BRANDNAME", "DCP", "DISPDRUG", "GENERICTOP", "IVNAME",
    "PRIMARY", "TRADETOP")))
    AND ocs.synonym_id IN (
   (SELECT DISTINCT
    synonym_id
    FROM ocs_facility_r)))
   JOIN (oc
   WHERE oc.catalog_cd=ocs.catalog_cd
    AND oc.orderable_type_flag IN (0, 1)
    AND oc.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=ocs.mnemonic_type_cd)
  HEAD REPORT
   o_cnt = 0
  DETAIL
   o_cnt = (o_cnt+ 1), temp->o_cnt = o_cnt, stat = alterlist(temp->olist,o_cnt),
   temp->olist[o_cnt].catalog_cd = ocs.catalog_cd, temp->olist[o_cnt].synonym_id = ocs.synonym_id,
   temp->olist[o_cnt].mnemonic = ocs.mnemonic,
   temp->olist[o_cnt].mnemonic_key_cap = ocs.mnemonic_key_cap, temp->olist[o_cnt].mnemonic_type_cd =
   ocs.mnemonic_type_cd, temp->olist[o_cnt].mnemonic_type_disp = cv.display,
   temp->olist[o_cnt].description = oc.description, temp->olist[o_cnt].description_key_cap =
   cnvtupper(oc.description), temp->olist[o_cnt].oe_format_id = ocs.oe_format_id,
   temp->olist[o_cnt].no_ord_sent_ind = 1
   IF (ocs.rx_mask=0)
    temp->olist[o_cnt].no_rx_mask_ind = 1
   ELSE
    temp->olist[o_cnt].no_rx_mask_ind = 0
   ENDIF
   IF (ocs.oe_format_id IN (0, cprimpharm))
    temp->olist[o_cnt].no_oef_ind = 1
   ELSE
    temp->olist[o_cnt].no_oef_ind = 0
   ENDIF
   IF (ocs.dcp_clin_cat_cd=0)
    temp->olist[o_cnt].no_clin_cat_syn_ind = 1
   ELSE
    temp->olist[o_cnt].no_clin_cat_syn_ind = 0
   ENDIF
   IF (trim(ocs.cki) IN (null, " "))
    temp->olist[o_cnt].no_cki_ind = 1
   ELSE
    temp->olist[o_cnt].no_cki_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,9)
 SET reply->collist[1].header_text = "Description"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Mnemonic"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "No Order Sentence"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "No RX Mask"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "No Order Entry Format"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "No Clinical Category (synonym)"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "No CKI (Dose Range Checking)"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "synonym_id"
 SET reply->collist[8].data_type = 2
 SET reply->collist[8].hide_ind = 1
 SET reply->collist[9].header_text = "catalog_cd"
 SET reply->collist[9].data_type = 2
 SET reply->collist[9].hide_ind = 1
 IF ((temp->o_cnt=0))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = temp->o_cnt),
   ord_cat_sent_r ocsr
  PLAN (d)
   JOIN (ocsr
   WHERE (ocsr.synonym_id=temp->olist[d.seq].synonym_id))
  DETAIL
   temp->olist[d.seq].no_ord_sent_ind = 0
  WITH nocounter
 ;end select
 SET row_nbr = 0
 SET no_ord_sent_cnt = 0
 SET no_rx_mask_cnt = 0
 SET no_oef_cnt = 0
 SET no_clin_cat_syn_cnt = 0
 SET no_cki_cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = temp->o_cnt)
  PLAN (d)
  ORDER BY temp->olist[d.seq].description_key_cap, temp->olist[d.seq].mnemonic_key_cap
  DETAIL
   IF ((((temp->olist[d.seq].no_ord_sent_ind=1)) OR ((((temp->olist[d.seq].no_rx_mask_ind=1)) OR ((((
   temp->olist[d.seq].no_oef_ind=1)) OR ((((temp->olist[d.seq].no_clin_cat_syn_ind=1)) OR ((temp->
   olist[d.seq].no_cki_ind=1))) )) )) )) )
    row_nbr = (row_nbr+ 1), stat = alterlist(reply->rowlist,row_nbr), stat = alterlist(reply->
     rowlist[row_nbr].celllist,9),
    reply->rowlist[row_nbr].celllist[1].string_value = temp->olist[d.seq].description, reply->
    rowlist[row_nbr].celllist[2].string_value = temp->olist[d.seq].mnemonic
    IF ((temp->olist[d.seq].no_ord_sent_ind=1))
     no_ord_sent_cnt = (no_ord_sent_cnt+ 1), reply->rowlist[row_nbr].celllist[3].string_value = "X"
    ELSE
     reply->rowlist[row_nbr].celllist[3].string_value = " "
    ENDIF
    IF ((temp->olist[d.seq].no_rx_mask_ind=1))
     no_rx_mask_cnt = (no_rx_mask_cnt+ 1), reply->rowlist[row_nbr].celllist[4].string_value = "X"
    ELSE
     reply->rowlist[row_nbr].celllist[4].string_value = " "
    ENDIF
    IF ((temp->olist[d.seq].no_oef_ind=1))
     no_oef_cnt = (no_oef_cnt+ 1), reply->rowlist[row_nbr].celllist[5].string_value = "X"
    ELSE
     reply->rowlist[row_nbr].celllist[5].string_value = " "
    ENDIF
    IF ((temp->olist[d.seq].no_clin_cat_syn_ind=1))
     no_clin_cat_syn_cnt = (no_clin_cat_syn_cnt+ 1), reply->rowlist[row_nbr].celllist[6].string_value
      = "X"
    ELSE
     reply->rowlist[row_nbr].celllist[6].string_value = " "
    ENDIF
    IF ((temp->olist[d.seq].no_cki_ind=1))
     no_cki_cnt = (no_cki_cnt+ 1), reply->rowlist[row_nbr].celllist[7].string_value = "X"
    ELSE
     reply->rowlist[row_nbr].celllist[7].string_value = " "
    ENDIF
    reply->rowlist[row_nbr].celllist[8].double_value = temp->olist[d.seq].synonym_id, reply->rowlist[
    row_nbr].celllist[9].double_value = temp->olist[d.seq].catalog_cd
   ENDIF
  WITH nocounter
 ;end select
 IF (no_rx_mask_cnt=0
  AND no_oef_cnt=0
  AND no_cki_cnt=0)
  SET reply->run_status_flag = 1
 ELSE
  SET reply->run_status_flag = 3
 ENDIF
 SET stat = alterlist(reply->statlist,3)
 SET reply->statlist[1].total_items = high_volume_cnt
 SET reply->statlist[1].qualifying_items = no_rx_mask_cnt
 SET reply->statlist[1].statistic_meaning = "RXORCNORXMASK"
 IF (no_rx_mask_cnt > 0)
  SET reply->statlist[1].status_flag = 3
 ELSE
  SET reply->statlist[1].status_flag = 1
 ENDIF
 SET reply->statlist[2].total_items = high_volume_cnt
 SET reply->statlist[2].qualifying_items = no_oef_cnt
 SET reply->statlist[2].statistic_meaning = "RXORCNOOEF"
 IF (no_oef_cnt > 0)
  SET reply->statlist[2].status_flag = 3
 ELSE
  SET reply->statlist[2].status_flag = 1
 ENDIF
 SET reply->statlist[3].total_items = high_volume_cnt
 SET reply->statlist[3].qualifying_items = no_cki_cnt
 SET reply->statlist[3].statistic_meaning = "RXORCNOCKI"
 IF (no_cki_cnt > 0)
  SET reply->statlist[3].status_flag = 3
 ELSE
  SET reply->statlist[3].status_flag = 1
 ENDIF
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("med_syn_issues_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
