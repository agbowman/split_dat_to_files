CREATE PROGRAM bed_rec_incmp_bill_itm_detail:dba
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
 RECORD temp(
   1 bilist[*]
     2 bill_item_id = f8
     2 ext_parent_reference_id = f8
     2 ext_child_reference_id = f8
     2 ext_owner_cd = f8
     2 ext_owner_disp = vc
     2 ext_description = vc
     2 cp_no_price_ind = i2
     2 cp_no_cdm_ind = i2
     2 price_no_cp_ind = i2
     2 cdm_no_cp_ind = i2
     2 cdm_no_price_ind = i2
     2 cpthcpcs_not_linked_ind = i2
     2 zero_pri_ind = i2
     2 bc_no_desc_ind = i2
 )
 RECORD temp2(
   1 bilist[*]
     2 bill_item_id = f8
     2 ext_parent_reference_id = f8
     2 ext_child_reference_id = f8
     2 ext_owner_cd = f8
     2 ext_owner_disp = vc
     2 ext_description = vc
     2 cp_no_price_ind = i2
     2 cp_no_cdm_ind = i2
     2 price_no_cp_ind = i2
     2 cdm_no_cp_ind = i2
     2 cdm_no_price_ind = i2
     2 cpthcpcs_not_linked_ind = i2
     2 zero_pri_ind = i2
     2 bc_no_desc_ind = i2
 )
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
 SET pharmacy_cd = get_code_value(106,"PHARMACY")
 SET addgen_cd = get_code_value(106,"AFC ADD GEN")
 SET adddef_cd = get_code_value(106,"AFC ADD DEF")
 SET addspec_cd = get_code_value(106,"AFC ADD SPEC")
 SET manfitem_cd = get_code_value(13016,"MANF ITEM")
 SET meddefflex_cd = get_code_value(13016,"MED DEF FLEX")
 SET chg_point_cd = get_code_value(13019,"CHARGE POINT")
 SET bill_code_cd = get_code_value(13019,"BILL CODE")
 SET alpha_level_cd = get_code_value(13020,"ALPHA")
 SET group_level_cd = get_code_value(13020,"GROUP")
 SET both_level_cd = get_code_value(13020,"BOTH")
 SET clear_point_cd = get_code_value(13029,"CLEAR")
 SET check_cdm_no_cp_ind = 0
 SET check_cp_no_price_ind = 0
 SET check_cdm_no_price_ind = 0
 SET check_price_no_cp_ind = 0
 SET check_billcd_zero_ind = 0
 SET check_cpt_no_nmcltr_ind = 0
 SET check_cp_no_cdm_ind = 0
 SET check_billcd_no_desc_ind = 0
 SET cdm_no_cp_col_nbr = 0
 SET cp_no_price_col_nbr = 0
 SET cdm_no_price_col_nbr = 0
 SET price_no_cp_col_nbr = 0
 SET billcd_zero_col_nbr = 0
 SET cpt_no_nmcltr_col_nbr = 0
 SET cp_no_cdm_col_nbr = 0
 SET billcd_no_desc_col_nbr = 0
 SET col_cnt = (2+ plsize)
 SET stat = alterlist(reply->collist,col_cnt)
 SET reply->collist[1].header_text = "Activity Type"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Bill Item Description"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET bcnt = 0
 SET next_col = 2
 FOR (p = 1 TO plsize)
   IF ((request->paramlist[p].meaning="BILLITMCPNOPRICE"))
    SET check_cp_no_price_ind = 1
    SET next_col = (next_col+ 1)
    SET cp_no_price_col_nbr = next_col
    SET reply->collist[next_col].header_text = "Charge Processing Without a Price"
    SET reply->collist[next_col].data_type = 1
    SET reply->collist[next_col].hide_ind = 0
    SELECT INTO "nl:"
     FROM bill_item bi,
      bill_item_modifier bim,
      (dummyt d  WITH seq = 1),
      price_sched_items psi
     PLAN (bi
      WHERE bi.active_ind=1
       AND bi.ext_owner_cd != pharmacy_cd)
      JOIN (bim
      WHERE bim.bill_item_id=bi.bill_item_id
       AND bim.bill_item_type_cd=chg_point_cd
       AND bim.active_ind=1
       AND ((bim.key4_id IN (group_level_cd, both_level_cd)) OR (bim.key4_id=alpha_level_cd
       AND bim.key2_id != clear_point_cd)) )
      JOIN (d)
      JOIN (psi
      WHERE psi.bill_item_id=bi.bill_item_id
       AND psi.active_ind=1
       AND psi.beg_effective_dt_tm < cnvtdatetime(curdate,000000)
       AND psi.end_effective_dt_tm > cnvtdatetime(curdate,235959))
     DETAIL
      bcnt = (bcnt+ 1), stat = alterlist(temp->bilist,bcnt), temp->bilist[bcnt].bill_item_id = bi
      .bill_item_id,
      temp->bilist[bcnt].ext_parent_reference_id = bi.ext_parent_reference_id, temp->bilist[bcnt].
      ext_child_reference_id = bi.ext_child_reference_id, temp->bilist[bcnt].ext_owner_cd = bi
      .ext_owner_cd,
      temp->bilist[bcnt].ext_description = bi.ext_description, temp->bilist[bcnt].cp_no_price_ind = 1
     WITH outerjoin = d, dontexist
    ;end select
   ENDIF
   IF ((request->paramlist[p].meaning="BILLITMCPNOCDM"))
    SET check_cp_no_cdm_ind = 1
    SET next_col = (next_col+ 1)
    SET cp_no_cdm_col_nbr = next_col
    SET reply->collist[next_col].header_text = "Charge Processing Without a CDM"
    SET reply->collist[next_col].data_type = 1
    SET reply->collist[next_col].hide_ind = 0
    SELECT INTO "nl:"
     FROM bill_item_modifier bim1,
      bill_item bi,
      (dummyt d  WITH seq = 1),
      bill_item_modifier bim2,
      code_value cv
     PLAN (bim1
      WHERE bim1.bill_item_type_cd=chg_point_cd
       AND bim1.active_ind=1
       AND ((bim1.key4_id IN (group_level_cd, both_level_cd)) OR (bim1.key4_id=alpha_level_cd
       AND bim1.key2_id != clear_point_cd)) )
      JOIN (bi
      WHERE bi.bill_item_id=bim1.bill_item_id
       AND bi.active_ind=1)
      JOIN (d)
      JOIN (bim2
      WHERE bim2.bill_item_id=bim1.bill_item_id
       AND bim2.active_ind=1
       AND bim2.beg_effective_dt_tm < cnvtdatetime(curdate,000000)
       AND bim2.end_effective_dt_tm > cnvtdatetime(curdate,235959))
      JOIN (cv
      WHERE cv.code_value=bim2.key1_id
       AND cv.code_set=14002
       AND cv.cdf_meaning="CDM_SCHED"
       AND cv.active_ind=1)
     DETAIL
      bcnt = (bcnt+ 1), stat = alterlist(temp->bilist,bcnt), temp->bilist[bcnt].bill_item_id = bi
      .bill_item_id,
      temp->bilist[bcnt].ext_parent_reference_id = bi.ext_parent_reference_id, temp->bilist[bcnt].
      ext_child_reference_id = bi.ext_child_reference_id, temp->bilist[bcnt].ext_owner_cd = bi
      .ext_owner_cd,
      temp->bilist[bcnt].ext_description = bi.ext_description, temp->bilist[bcnt].cp_no_cdm_ind = 1
     WITH outerjoin = d, dontexist
    ;end select
   ENDIF
   IF ((request->paramlist[p].meaning="BILLITMPRICENOCP"))
    SET check_price_no_cp_ind = 1
    SET next_col = (next_col+ 1)
    SET price_no_cp_col_nbr = next_col
    SET reply->collist[next_col].header_text = "Price Without Charge Processing"
    SET reply->collist[next_col].data_type = 1
    SET reply->collist[next_col].hide_ind = 0
    SELECT INTO "nl:"
     FROM bill_item bi,
      price_sched_items psi,
      (dummyt d  WITH seq = 1),
      bill_item_modifier bim
     PLAN (bi
      WHERE bi.active_ind=1
       AND  NOT (bi.ext_owner_cd IN (pharmacy_cd, addgen_cd, adddef_cd, addspec_cd)))
      JOIN (psi
      WHERE psi.price_sched_id > 0
       AND psi.bill_item_id=bi.bill_item_id
       AND psi.beg_effective_dt_tm < cnvtdatetime(curdate,000000)
       AND psi.end_effective_dt_tm > cnvtdatetime(curdate,235959))
      JOIN (d)
      JOIN (bim
      WHERE bim.bill_item_id=bi.bill_item_id
       AND bim.bill_item_type_cd=chg_point_cd
       AND bim.active_ind=1)
     DETAIL
      bcnt = (bcnt+ 1), stat = alterlist(temp->bilist,bcnt), temp->bilist[bcnt].bill_item_id = bi
      .bill_item_id,
      temp->bilist[bcnt].ext_parent_reference_id = bi.ext_parent_reference_id, temp->bilist[bcnt].
      ext_child_reference_id = bi.ext_child_reference_id, temp->bilist[bcnt].ext_owner_cd = bi
      .ext_owner_cd,
      temp->bilist[bcnt].ext_description = bi.ext_description, temp->bilist[bcnt].price_no_cp_ind = 1
     WITH outerjoin = d, dontexist
    ;end select
   ENDIF
   IF ((request->paramlist[p].meaning="BILLITMCDMNOCP"))
    SET check_cdm_no_cp_ind = 1
    SET next_col = (next_col+ 1)
    SET cdm_no_cp_col_nbr = next_col
    SET reply->collist[next_col].header_text = "CDM Without Charge Processing"
    SET reply->collist[next_col].data_type = 1
    SET reply->collist[next_col].hide_ind = 0
    SELECT INTO "nl:"
     FROM code_value cv,
      bill_item_modifier bim1,
      bill_item bi,
      (dummyt d  WITH seq = 1),
      bill_item_modifier bim2
     PLAN (cv
      WHERE cv.code_set=14002
       AND cv.cdf_meaning="CDM_SCHED"
       AND cv.active_ind=1)
      JOIN (bim1
      WHERE bim1.key1_id=cv.code_value
       AND bim1.active_ind=1
       AND bim1.beg_effective_dt_tm < cnvtdatetime(curdate,000000)
       AND bim1.end_effective_dt_tm > cnvtdatetime(curdate,235959))
      JOIN (bi
      WHERE bi.bill_item_id=bim1.bill_item_id
       AND  NOT (bi.ext_owner_cd IN (pharmacy_cd, addgen_cd, adddef_cd, addspec_cd))
       AND bi.active_ind=1)
      JOIN (d)
      JOIN (bim2
      WHERE bim2.bill_item_id=bi.bill_item_id
       AND bim2.bill_item_type_cd=chg_point_cd
       AND ((bim2.key4_id IN (group_level_cd, both_level_cd)) OR (bim2.key4_id=alpha_level_cd
       AND bim2.key2_id != clear_point_cd)) )
     DETAIL
      bcnt = (bcnt+ 1), stat = alterlist(temp->bilist,bcnt), temp->bilist[bcnt].bill_item_id = bi
      .bill_item_id,
      temp->bilist[bcnt].ext_parent_reference_id = bi.ext_parent_reference_id, temp->bilist[bcnt].
      ext_child_reference_id = bi.ext_child_reference_id, temp->bilist[bcnt].ext_owner_cd = bi
      .ext_owner_cd,
      temp->bilist[bcnt].ext_description = bi.ext_description, temp->bilist[bcnt].cdm_no_cp_ind = 1
     WITH outerjoin = d, dontexist
    ;end select
   ENDIF
   IF ((request->paramlist[p].meaning="BILLITMCDMNOPRICE"))
    SET check_cdm_no_price_ind = 1
    SET next_col = (next_col+ 1)
    SET cdm_no_price_col_nbr = next_col
    SET reply->collist[next_col].header_text = "CDM Without a Price"
    SET reply->collist[next_col].data_type = 1
    SET reply->collist[next_col].hide_ind = 0
    SELECT INTO "nl:"
     FROM code_value cv,
      bill_item_modifier bim,
      bill_item bi,
      (dummyt d  WITH seq = 1),
      price_sched_items psi
     PLAN (cv
      WHERE cv.code_set=14002
       AND cv.cdf_meaning="CDM_SCHED"
       AND cv.active_ind=1)
      JOIN (bim
      WHERE bim.key1_id=cv.code_value
       AND bim.active_ind=1
       AND bim.beg_effective_dt_tm < cnvtdatetime(curdate,000000)
       AND bim.end_effective_dt_tm > cnvtdatetime(curdate,235959))
      JOIN (bi
      WHERE bi.bill_item_id=bim.bill_item_id
       AND bi.active_ind=1
       AND bi.ext_owner_cd != pharmacy_cd)
      JOIN (d)
      JOIN (psi
      WHERE psi.bill_item_id=bi.bill_item_id
       AND psi.beg_effective_dt_tm < cnvtdatetime(curdate,000000)
       AND psi.end_effective_dt_tm > cnvtdatetime(curdate,235959))
     DETAIL
      bcnt = (bcnt+ 1), stat = alterlist(temp->bilist,bcnt), temp->bilist[bcnt].bill_item_id = bi
      .bill_item_id,
      temp->bilist[bcnt].ext_parent_reference_id = bi.ext_parent_reference_id, temp->bilist[bcnt].
      ext_child_reference_id = bi.ext_child_reference_id, temp->bilist[bcnt].ext_owner_cd = bi
      .ext_owner_cd,
      temp->bilist[bcnt].ext_description = bi.ext_description, temp->bilist[bcnt].cdm_no_price_ind =
      1
     WITH outerjoin = d, dontexist
    ;end select
   ENDIF
   IF ((request->paramlist[p].meaning="BILLITMCPTNONMCLTR"))
    SET check_cpt_no_nmcltr_ind = 1
    SET next_col = (next_col+ 1)
    SET cpt_no_nmcltr_col_nbr = next_col
    SET reply->collist[next_col].header_text = "CPT4/HCPCS Codes not Linked to Nomenclature"
    SET reply->collist[next_col].data_type = 1
    SET reply->collist[next_col].hide_ind = 0
    SELECT INTO "nl:"
     FROM code_value cv,
      bill_item_modifier bim,
      bill_item bi
     PLAN (cv
      WHERE cv.code_set=14002
       AND cv.cdf_meaning IN ("CPT4", "HCPCS")
       AND cv.active_ind=1)
      JOIN (bim
      WHERE bim.key1_id=cv.code_value
       AND bim.active_ind=1
       AND bim.key3_id IN (0, null)
       AND bim.beg_effective_dt_tm < cnvtdatetime(curdate,000000)
       AND bim.end_effective_dt_tm > cnvtdatetime(curdate,235959))
      JOIN (bi
      WHERE bi.bill_item_id=bim.bill_item_id
       AND bi.active_ind=1)
     DETAIL
      bcnt = (bcnt+ 1), stat = alterlist(temp->bilist,bcnt), temp->bilist[bcnt].bill_item_id = bi
      .bill_item_id,
      temp->bilist[bcnt].ext_parent_reference_id = bi.ext_parent_reference_id, temp->bilist[bcnt].
      ext_child_reference_id = bi.ext_child_reference_id, temp->bilist[bcnt].ext_owner_cd = bi
      .ext_owner_cd,
      temp->bilist[bcnt].ext_description = bi.ext_description, temp->bilist[bcnt].
      cpthcpcs_not_linked_ind = 1
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->paramlist[p].meaning="BILLITMBILLCDZERO"))
    SET check_billcd_zero_ind = 1
    SET next_col = (next_col+ 1)
    SET billcd_zero_col_nbr = next_col
    SET reply->collist[next_col].header_text = "Bill codes with Priority of 0(Zero)"
    SET reply->collist[next_col].data_type = 1
    SET reply->collist[next_col].hide_ind = 0
    SELECT INTO "nl:"
     FROM bill_item_modifier bim,
      bill_item bi
     PLAN (bim
      WHERE bim.bim1_int IN (0, null)
       AND bim.bill_item_type_cd=bill_code_cd
       AND bim.active_ind=1)
      JOIN (bi
      WHERE bi.bill_item_id=bim.bill_item_id)
     DETAIL
      bcnt = (bcnt+ 1), stat = alterlist(temp->bilist,bcnt), temp->bilist[bcnt].bill_item_id = bi
      .bill_item_id,
      temp->bilist[bcnt].ext_parent_reference_id = bi.ext_parent_reference_id, temp->bilist[bcnt].
      ext_child_reference_id = bi.ext_child_reference_id, temp->bilist[bcnt].ext_owner_cd = bi
      .ext_owner_cd,
      temp->bilist[bcnt].ext_description = bi.ext_description, temp->bilist[bcnt].zero_pri_ind = 1
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->paramlist[p].meaning="BILLITMBILLCDNODESC"))
    SET check_billcd_no_desc_ind = 1
    SET next_col = (next_col+ 1)
    SET billcd_no_desc_col_nbr = next_col
    SET reply->collist[next_col].header_text = "Bill Codes with No Description"
    SET reply->collist[next_col].data_type = 1
    SET reply->collist[next_col].hide_ind = 0
    SELECT INTO "nl:"
     FROM bill_item_modifier bim,
      bill_item bi
     PLAN (bim
      WHERE bim.bill_item_type_cd=bill_code_cd
       AND bim.active_ind=1
       AND bim.key7 IN ("", " ", null)
       AND  NOT (bim.key6 IN ("", " ", null)))
      JOIN (bi
      WHERE bi.bill_item_id=bim.bill_item_id)
     DETAIL
      bcnt = (bcnt+ 1), stat = alterlist(temp->bilist,bcnt), temp->bilist[bcnt].bill_item_id = bi
      .bill_item_id,
      temp->bilist[bcnt].ext_parent_reference_id = bi.ext_parent_reference_id, temp->bilist[bcnt].
      ext_child_reference_id = bi.ext_child_reference_id, temp->bilist[bcnt].ext_owner_cd = bi
      .ext_owner_cd,
      temp->bilist[bcnt].ext_description = bi.ext_description, temp->bilist[bcnt].bc_no_desc_ind = 1
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 IF (bcnt > 0)
  SET stat = alterlist(temp2->bilist,bcnt)
  SELECT INTO "nl:"
   bi_id = temp->bilist[d.seq].bill_item_id, item_disp = cnvtupper(temp->bilist[d.seq].
    ext_description)
   FROM (dummyt d  WITH seq = bcnt),
    code_value cv
   PLAN (d)
    JOIN (cv
    WHERE (cv.code_value=temp->bilist[d.seq].ext_owner_cd))
   ORDER BY cv.display_key, item_disp, bi_id
   HEAD REPORT
    bidx = 0
   DETAIL
    bidx = (bidx+ 1), temp2->bilist[bidx].bill_item_id = temp->bilist[d.seq].bill_item_id, temp2->
    bilist[bidx].ext_parent_reference_id = temp->bilist[d.seq].ext_parent_reference_id,
    temp2->bilist[bidx].ext_child_reference_id = temp->bilist[d.seq].ext_child_reference_id, temp2->
    bilist[bidx].ext_owner_cd = temp->bilist[d.seq].ext_owner_cd, temp2->bilist[bidx].ext_owner_disp
     = cv.display,
    temp2->bilist[bidx].ext_description = temp->bilist[d.seq].ext_description, temp2->bilist[bidx].
    cp_no_price_ind = temp->bilist[d.seq].cp_no_price_ind, temp2->bilist[bidx].cp_no_cdm_ind = temp->
    bilist[d.seq].cp_no_cdm_ind,
    temp2->bilist[bidx].price_no_cp_ind = temp->bilist[d.seq].price_no_cp_ind, temp2->bilist[bidx].
    cdm_no_cp_ind = temp->bilist[d.seq].cdm_no_cp_ind, temp2->bilist[bidx].cdm_no_price_ind = temp->
    bilist[d.seq].cdm_no_price_ind,
    temp2->bilist[bidx].cpthcpcs_not_linked_ind = temp->bilist[d.seq].cpthcpcs_not_linked_ind, temp2
    ->bilist[bidx].zero_pri_ind = temp->bilist[d.seq].zero_pri_ind, temp2->bilist[bidx].
    bc_no_desc_ind = temp->bilist[d.seq].bc_no_desc_ind
   WITH nocounter
  ;end select
 ENDIF
 IF (bcnt > 0)
  SELECT INTO "nl:"
   bi_id = temp2->bilist[d.seq].bill_item_id
   FROM (dummyt d  WITH seq = bcnt)
   PLAN (d)
   HEAD REPORT
    rcnt = 0
   HEAD bi_id
    rcnt = (rcnt+ 1), stat = alterlist(reply->rowlist,rcnt), stat = alterlist(reply->rowlist[rcnt].
     celllist,col_cnt),
    reply->rowlist[rcnt].celllist[1].string_value = temp2->bilist[d.seq].ext_owner_disp, reply->
    rowlist[rcnt].celllist[2].string_value = temp2->bilist[d.seq].ext_description
   DETAIL
    IF (check_cp_no_price_ind=1
     AND (temp2->bilist[d.seq].cp_no_price_ind=1))
     reply->rowlist[rcnt].celllist[cp_no_price_col_nbr].string_value = "X"
    ENDIF
    IF (check_cp_no_cdm_ind=1
     AND (temp2->bilist[d.seq].cp_no_cdm_ind=1))
     reply->rowlist[rcnt].celllist[cp_no_cdm_col_nbr].string_value = "X"
    ENDIF
    IF (check_price_no_cp_ind=1
     AND (temp2->bilist[d.seq].price_no_cp_ind=1))
     reply->rowlist[rcnt].celllist[price_no_cp_col_nbr].string_value = "X"
    ENDIF
    IF (check_cdm_no_cp_ind=1
     AND (temp2->bilist[d.seq].cdm_no_cp_ind=1))
     reply->rowlist[rcnt].celllist[cdm_no_cp_col_nbr].string_value = "X"
    ENDIF
    IF (check_cdm_no_price_ind=1
     AND (temp2->bilist[d.seq].cdm_no_price_ind=1))
     reply->rowlist[rcnt].celllist[cdm_no_price_col_nbr].string_value = "X"
    ENDIF
    IF (check_cpt_no_nmcltr_ind=1
     AND (temp2->bilist[d.seq].cpthcpcs_not_linked_ind=1))
     reply->rowlist[rcnt].celllist[cpt_no_nmcltr_col_nbr].string_value = "X"
    ENDIF
    IF (check_billcd_zero_ind=1
     AND (temp2->bilist[d.seq].zero_pri_ind=1))
     reply->rowlist[rcnt].celllist[billcd_zero_col_nbr].string_value = "X"
    ENDIF
    IF (check_billcd_no_desc_ind=1
     AND (temp2->bilist[d.seq].bc_no_desc_ind=1))
     reply->rowlist[rcnt].celllist[billcd_no_desc_col_nbr].string_value = "X"
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
 CALL echorecord(reply)
END GO
