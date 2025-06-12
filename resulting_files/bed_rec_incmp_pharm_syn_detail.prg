CREATE PROGRAM bed_rec_incmp_pharm_syn_detail
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
 FREE RECORD temp2
 RECORD temp2(
   1 o_cnt = i4
   1 olist[*]
     2 synonym_id = f8
     2 mnemonic = vc
     2 mnemonic_type_disp = vc
     2 mnemonic_key_cap = vc
     2 description = vc
     2 description_key_cap = vc
     2 no_ord_sent_ind = i2
     2 no_rx_mask_ind = i2
     2 no_oef_ind = i2
     2 no_clin_cat_syn_ind = i2
     2 no_cki_ind = i2
 )
 SET o_cnt = 0
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
 SET check_no_oes_ind = 0
 SET check_no_rfx_ind = 0
 SET check_no_oef_ind = 0
 SET check_no_clin_ind = 0
 SET check_no_cki_ind = 0
 SET no_oes_col_nbr = 0
 SET no_rfx_col_nbr = 0
 SET no_oef_col_nbr = 0
 SET no_clin_col_nbr = 0
 SET no_cki_col_nbr = 0
 SET col_cnt = (3+ plsize)
 SET stat = alterlist(reply->collist,col_cnt)
 SET reply->collist[1].header_text = "Orderable Item Description"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Synonym Name (Mnemonic)"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Synonym Type"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET bcnt = 0
 SET next_col = 3
 FOR (p = 1 TO plsize)
   IF ((request->paramlist[p].meaning="PHARMSYNMNOOES"))
    SET check_no_oes_ind = 1
    SET next_col = (next_col+ 1)
    SET no_oes_col_nbr = next_col
    SET reply->collist[next_col].header_text = "No Order Sentence"
    SET reply->collist[next_col].data_type = 1
    SET reply->collist[next_col].hide_ind = 0
    SELECT INTO "nl:"
     FROM order_catalog_synonym ocs,
      order_catalog oc,
      code_value cv,
      dummyt d,
      ord_cat_sent_r ocsr
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
       AND oc.oe_format_id IN (
      (SELECT DISTINCT
       oe_format_id
       FROM order_entry_format))
       AND oc.active_ind=1)
      JOIN (cv
      WHERE cv.code_value=ocs.mnemonic_type_cd)
      JOIN (d)
      JOIN (ocsr
      WHERE ocsr.synonym_id=ocs.synonym_id)
     ORDER BY cnvtupper(oc.description), ocs.mnemonic_key_cap
     DETAIL
      o_cnt = (o_cnt+ 1), stat = alterlist(temp->olist,o_cnt), temp->olist[o_cnt].catalog_cd = ocs
      .catalog_cd,
      temp->olist[o_cnt].synonym_id = ocs.synonym_id, temp->olist[o_cnt].mnemonic = ocs.mnemonic,
      temp->olist[o_cnt].mnemonic_key_cap = ocs.mnemonic_key_cap,
      temp->olist[o_cnt].mnemonic_type_cd = ocs.mnemonic_type_cd, temp->olist[o_cnt].
      mnemonic_type_disp = cv.display, temp->olist[o_cnt].description = oc.description,
      temp->olist[o_cnt].description_key_cap = cnvtupper(oc.description), temp->olist[o_cnt].
      oe_format_id = ocs.oe_format_id, temp->olist[o_cnt].no_ord_sent_ind = 1
     WITH nocounter, outerjoin = d, dontexist
    ;end select
   ENDIF
   IF ((request->paramlist[p].meaning="PHARMSYNMNORXMASK"))
    SET check_no_rfx_ind = 1
    SET next_col = (next_col+ 1)
    SET no_rfx_col_nbr = next_col
    SET reply->collist[next_col].header_text = "No Rx Mask"
    SET reply->collist[next_col].data_type = 1
    SET reply->collist[next_col].hide_ind = 0
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
     ORDER BY cnvtupper(oc.description), ocs.mnemonic_key_cap
     DETAIL
      IF (ocs.rx_mask=0)
       o_cnt = (o_cnt+ 1), stat = alterlist(temp->olist,o_cnt), temp->olist[o_cnt].catalog_cd = ocs
       .catalog_cd,
       temp->olist[o_cnt].synonym_id = ocs.synonym_id, temp->olist[o_cnt].mnemonic = ocs.mnemonic,
       temp->olist[o_cnt].mnemonic_key_cap = ocs.mnemonic_key_cap,
       temp->olist[o_cnt].mnemonic_type_cd = ocs.mnemonic_type_cd, temp->olist[o_cnt].
       mnemonic_type_disp = cv.display, temp->olist[o_cnt].description = oc.description,
       temp->olist[o_cnt].description_key_cap = cnvtupper(oc.description), temp->olist[o_cnt].
       oe_format_id = ocs.oe_format_id, temp->olist[o_cnt].no_rx_mask_ind = 1,
       CALL echo(build("ocsmnem: ",temp->olist[o_cnt].mnemonic_key_cap))
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->paramlist[p].meaning="PHARMSYNMNOOEF"))
    SET check_no_oef_ind = 1
    SET next_col = (next_col+ 1)
    SET no_oef_col_nbr = next_col
    SET reply->collist[next_col].header_text = "No Order Entry Format"
    SET reply->collist[next_col].data_type = 1
    SET reply->collist[next_col].hide_ind = 0
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
     ORDER BY cnvtupper(oc.description), ocs.mnemonic_key_cap
     DETAIL
      IF (ocs.oe_format_id IN (0, cprimpharm))
       o_cnt = (o_cnt+ 1), stat = alterlist(temp->olist,o_cnt), temp->olist[o_cnt].catalog_cd = ocs
       .catalog_cd,
       temp->olist[o_cnt].synonym_id = ocs.synonym_id, temp->olist[o_cnt].mnemonic = ocs.mnemonic,
       temp->olist[o_cnt].mnemonic_key_cap = ocs.mnemonic_key_cap,
       temp->olist[o_cnt].mnemonic_type_cd = ocs.mnemonic_type_cd, temp->olist[o_cnt].
       mnemonic_type_disp = cv.display, temp->olist[o_cnt].description = oc.description,
       temp->olist[o_cnt].description_key_cap = cnvtupper(oc.description), temp->olist[o_cnt].
       oe_format_id = ocs.oe_format_id, temp->olist[o_cnt].no_oef_ind = 1
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->paramlist[p].meaning="PHARMSYNMNOCLINCAT"))
    SET check_no_clin_ind = 1
    SET next_col = (next_col+ 1)
    SET no_clin_col_nbr = next_col
    SET reply->collist[next_col].header_text = "No Clinical Category (Synonym)"
    SET reply->collist[next_col].data_type = 1
    SET reply->collist[next_col].hide_ind = 0
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
     ORDER BY cnvtupper(oc.description), ocs.mnemonic_key_cap
     DETAIL
      IF (ocs.dcp_clin_cat_cd=0)
       o_cnt = (o_cnt+ 1), stat = alterlist(temp->olist,o_cnt), temp->olist[o_cnt].catalog_cd = ocs
       .catalog_cd,
       temp->olist[o_cnt].synonym_id = ocs.synonym_id, temp->olist[o_cnt].mnemonic = ocs.mnemonic,
       temp->olist[o_cnt].mnemonic_key_cap = ocs.mnemonic_key_cap,
       temp->olist[o_cnt].mnemonic_type_cd = ocs.mnemonic_type_cd, temp->olist[o_cnt].
       mnemonic_type_disp = cv.display, temp->olist[o_cnt].description = oc.description,
       temp->olist[o_cnt].description_key_cap = cnvtupper(oc.description), temp->olist[o_cnt].
       oe_format_id = ocs.oe_format_id, temp->olist[o_cnt].no_clin_cat_syn_ind = 1
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->paramlist[p].meaning="PHARMSYNMNOCKI2"))
    SET check_no_cki_ind = 1
    SET next_col = (next_col+ 1)
    SET no_cki_col_nbr = next_col
    SET reply->collist[next_col].header_text = "No CKI (Dose Range Checking)"
    SET reply->collist[next_col].data_type = 1
    SET reply->collist[next_col].hide_ind = 0
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
       AND oc.active_ind=1
       AND oc.cki="MUL.ORD*")
      JOIN (cv
      WHERE cv.code_value=ocs.mnemonic_type_cd)
     ORDER BY cnvtupper(oc.description), ocs.mnemonic_key_cap
     DETAIL
      IF (trim(ocs.cki) IN (null, " "))
       o_cnt = (o_cnt+ 1), stat = alterlist(temp->olist,o_cnt), temp->olist[o_cnt].catalog_cd = ocs
       .catalog_cd,
       temp->olist[o_cnt].synonym_id = ocs.synonym_id, temp->olist[o_cnt].mnemonic = ocs.mnemonic,
       temp->olist[o_cnt].mnemonic_key_cap = ocs.mnemonic_key_cap,
       temp->olist[o_cnt].mnemonic_type_cd = ocs.mnemonic_type_cd, temp->olist[o_cnt].
       mnemonic_type_disp = cv.display, temp->olist[o_cnt].description = oc.description,
       temp->olist[o_cnt].description_key_cap = cnvtupper(oc.description), temp->olist[o_cnt].
       oe_format_id = ocs.oe_format_id, temp->olist[o_cnt].no_cki_ind = 1
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 SET phx = 0
 IF (o_cnt > 0)
  SET stat = alterlist(temp2->olist,o_cnt)
  SELECT INTO "nl:"
   des_key = temp->olist[d.seq].description_key_cap, mnem_key = temp->olist[d.seq].mnemonic_key_cap
   FROM (dummyt d  WITH seq = o_cnt)
   PLAN (d)
   ORDER BY des_key, mnem_key
   DETAIL
    IF ((((temp->olist[d.seq].no_ord_sent_ind=1)) OR ((((temp->olist[d.seq].no_rx_mask_ind=1)) OR (((
    (temp->olist[d.seq].no_oef_ind=1)) OR ((((temp->olist[d.seq].no_clin_cat_syn_ind=1)) OR ((temp->
    olist[d.seq].no_cki_ind=1))) )) )) )) )
     phx = (phx+ 1), temp2->olist[phx].description = temp->olist[d.seq].description, temp2->olist[phx
     ].description_key_cap = temp->olist[d.seq].description_key_cap,
     temp2->olist[phx].synonym_id = temp->olist[d.seq].synonym_id, temp2->olist[phx].mnemonic = temp
     ->olist[d.seq].mnemonic, temp2->olist[phx].mnemonic_type_disp = temp->olist[d.seq].
     mnemonic_type_disp,
     temp2->olist[phx].mnemonic_key_cap = temp->olist[d.seq].mnemonic_key_cap, temp2->olist[phx].
     no_ord_sent_ind = temp->olist[d.seq].no_ord_sent_ind, temp2->olist[phx].no_rx_mask_ind = temp->
     olist[d.seq].no_rx_mask_ind,
     temp2->olist[phx].no_oef_ind = temp->olist[d.seq].no_oef_ind, temp2->olist[phx].
     no_clin_cat_syn_ind = temp->olist[d.seq].no_clin_cat_syn_ind, temp2->olist[phx].no_cki_ind =
     temp->olist[d.seq].no_cki_ind
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (phx > 0)
  SET rcnt = 0
  SELECT INTO "nl:"
   mnem = temp2->olist[d.seq].mnemonic_key_cap, ord_desc = temp2->olist[d.seq].description_key_cap,
   mnem_cd = temp2->olist[d.seq].synonym_id
   FROM (dummyt d  WITH seq = phx)
   PLAN (d)
   ORDER BY ord_desc, mnem, mnem_cd
   HEAD mnem_cd
    rcnt = (rcnt+ 1), stat = alterlist(reply->rowlist,rcnt), stat = alterlist(reply->rowlist[rcnt].
     celllist,col_cnt),
    reply->rowlist[rcnt].celllist[2].string_value = temp2->olist[d.seq].mnemonic
   DETAIL
    reply->rowlist[rcnt].celllist[1].string_value = temp2->olist[d.seq].description, reply->rowlist[
    rcnt].celllist[3].string_value = temp2->olist[d.seq].mnemonic_type_disp
    IF (check_no_oes_ind=1
     AND (temp2->olist[d.seq].no_ord_sent_ind=1))
     reply->rowlist[rcnt].celllist[no_oes_col_nbr].string_value = "X"
    ENDIF
    IF (check_no_rfx_ind=1
     AND (temp2->olist[d.seq].no_rx_mask_ind=1))
     reply->rowlist[rcnt].celllist[no_rfx_col_nbr].string_value = "X"
    ENDIF
    IF (check_no_oef_ind=1
     AND (temp2->olist[d.seq].no_oef_ind=1))
     reply->rowlist[rcnt].celllist[no_oef_col_nbr].string_value = "X"
    ENDIF
    IF (check_no_clin_ind=1
     AND (temp2->olist[d.seq].no_clin_cat_syn_ind=1))
     reply->rowlist[rcnt].celllist[no_clin_col_nbr].string_value = "X"
    ENDIF
    IF (check_no_cki_ind=1
     AND (temp2->olist[d.seq].no_cki_ind=1))
     reply->rowlist[rcnt].celllist[no_cki_col_nbr].string_value = "X"
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
 SUBROUTINE get_code_value(xcodeset,xcdf)
   SET to_return = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=xcodeset
      AND c.cdf_meaning=xcdf
      AND c.active_ind=1)
    DETAIL
     to_return = c.code_value
    WITH nocounter
   ;end select
   RETURN(to_return)
 END ;Subroutine
#exit_script
 SET reply->status_data.status = "S"
END GO
