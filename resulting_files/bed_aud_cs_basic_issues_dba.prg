CREATE PROGRAM bed_aud_cs_basic_issues:dba
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
 SET rx_ind = 0
 SELECT INTO "nl:"
  FROM br_name_value bnv
  PLAN (bnv
   WHERE bnv.br_nv_key1="SOLUTION_STATUS"
    AND bnv.br_name IN ("GOING_LIVE", "LIVE_IN_PROD")
    AND bnv.br_value="PHARM")
  DETAIL
   rx_ind = 1
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,11)
 SET reply->collist[1].header_text = "Activity Type"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Bill_Item_ID"
 SET reply->collist[2].data_type = 2
 SET reply->collist[2].hide_ind = 1
 SET reply->collist[3].header_text = "Bill Item Description"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Items with Charge Processing but without a Price"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Items with Charge Processing but without a CDM"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Items with Price without Charge Processing"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Items with a CDM, without Charge Processing"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Items with a CDM, without a Price"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Items with CPT4/HCPC codes not linked to Nomenclature"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Items with has bill codes with a priority of 0"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Items with a bill code with no description"
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
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
 SET bitotcnt = 0
 SELECT INTO "nl:"
  bicnt = count(*)
  FROM bill_item
  WHERE active_ind=1
  DETAIL
   bitotcnt = bicnt
  WITH nocounter
 ;end select
 IF ((request->skip_volume_check_ind=0))
  IF (bitotcnt > 60000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (bitotcnt > 30000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET bcnt = 0
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
   temp->bilist[bcnt].ext_description = bi.ext_description, temp->bilist[bcnt].cdm_no_price_ind = 1
  WITH outerjoin = d, dontexist
 ;end select
 SELECT INTO "nl:"
  FROM bill_item bi,
   price_sched_items psi,
   (dummyt d  WITH seq = 1),
   bill_item_modifier bim
  PLAN (bi
   WHERE bi.active_ind=1
    AND  NOT (bi.ext_owner_cd IN (pharmacy_cd, addgen_cd, adddef_cd, addspec_cd)))
   JOIN (psi
   WHERE psi.bill_item_id=bi.bill_item_id
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
 SET rcnt = 0
 SET cp_no_price_cnt = 0
 SET cp_no_cdm_cnt = 0
 SET price_no_cp_cnt = 0
 SET cdm_no_cp_cnt = 0
 SET cdm_no_price_cnt = 0
 SET cpthcpcs_not_linked_cnt = 0
 SET zero_pri_cnt = 0
 SET bc_no_desc_cnt = 0
 IF (bcnt > 0)
  SELECT INTO "nl:"
   bi_id = temp2->bilist[d.seq].bill_item_id
   FROM (dummyt d  WITH seq = bcnt)
   PLAN (d)
   HEAD REPORT
    rcnt = 0
   HEAD bi_id
    rcnt = (rcnt+ 1), stat = alterlist(reply->rowlist,rcnt), stat = alterlist(reply->rowlist[rcnt].
     celllist,11),
    reply->rowlist[rcnt].celllist[1].string_value = temp2->bilist[d.seq].ext_owner_disp, reply->
    rowlist[rcnt].celllist[2].double_value = temp2->bilist[d.seq].bill_item_id, reply->rowlist[rcnt].
    celllist[3].string_value = temp2->bilist[d.seq].ext_description
   DETAIL
    IF ((temp2->bilist[d.seq].cp_no_price_ind=1))
     cp_no_price_cnt = (cp_no_price_cnt+ 1), reply->rowlist[rcnt].celllist[4].string_value = "X"
    ENDIF
    IF ((temp2->bilist[d.seq].cp_no_cdm_ind=1))
     cp_no_cdm_cnt = (cp_no_cdm_cnt+ 1), reply->rowlist[rcnt].celllist[5].string_value = "X"
    ENDIF
    IF ((temp2->bilist[d.seq].price_no_cp_ind=1))
     price_no_cp_cnt = (price_no_cp_cnt+ 1), reply->rowlist[rcnt].celllist[6].string_value = "X"
    ENDIF
    IF ((temp2->bilist[d.seq].cdm_no_cp_ind=1))
     cdm_no_cp_cnt = (cdm_no_cp_cnt+ 1), reply->rowlist[rcnt].celllist[7].string_value = "X"
    ENDIF
    IF ((temp2->bilist[d.seq].cdm_no_price_ind=1))
     cdm_no_price_cnt = (cdm_no_price_cnt+ 1), reply->rowlist[rcnt].celllist[8].string_value = "X"
    ENDIF
    IF ((temp2->bilist[d.seq].cpthcpcs_not_linked_ind=1))
     cpthcpcs_not_linked_cnt = (cpthcpcs_not_linked_cnt+ 1), reply->rowlist[rcnt].celllist[9].
     string_value = "X"
    ENDIF
    IF ((temp2->bilist[d.seq].zero_pri_ind=1))
     zero_pri_cnt = (zero_pri_cnt+ 1), reply->rowlist[rcnt].celllist[10].string_value = "X"
    ENDIF
    IF ((temp2->bilist[d.seq].bc_no_desc_ind=1))
     bc_no_desc_cnt = (bc_no_desc_cnt+ 1), reply->rowlist[rcnt].celllist[11].string_value = "X"
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (cp_no_price_cnt=0
  AND cp_no_cdm_cnt=0
  AND price_no_cp_cnt=0
  AND cdm_no_cp_cnt=0
  AND cdm_no_price_cnt=0
  AND cpthcpcs_not_linked_cnt=0
  AND zero_pri_cnt=0)
  SET reply->run_status_flag = 1
 ELSE
  SET reply->run_status_flag = 3
 ENDIF
 SET stat = alterlist(reply->statlist,7)
 SET reply->statlist[1].total_items = bitotcnt
 SET reply->statlist[1].qualifying_items = cp_no_price_cnt
 SET reply->statlist[1].statistic_meaning = "CSBICPNOPRICE"
 IF (cp_no_price_cnt > 0)
  SET reply->statlist[1].status_flag = 3
 ELSE
  SET reply->statlist[1].status_flag = 1
 ENDIF
 SET reply->statlist[2].total_items = bitotcnt
 SET reply->statlist[2].qualifying_items = cp_no_cdm_cnt
 SET reply->statlist[2].statistic_meaning = "CSBICPNOCDM"
 IF (cp_no_cdm_cnt > 0)
  SET reply->statlist[2].status_flag = 3
 ELSE
  SET reply->statlist[2].status_flag = 1
 ENDIF
 SET reply->statlist[3].total_items = bitotcnt
 SET reply->statlist[3].qualifying_items = price_no_cp_cnt
 SET reply->statlist[3].statistic_meaning = "CSBIPRICENOCP"
 IF (price_no_cp_cnt > 0)
  SET reply->statlist[3].status_flag = 3
 ELSE
  SET reply->statlist[3].status_flag = 1
 ENDIF
 SET reply->statlist[4].total_items = bitotcnt
 SET reply->statlist[4].qualifying_items = cdm_no_cp_cnt
 SET reply->statlist[4].statistic_meaning = "CSBICDMNOCP"
 IF (cdm_no_cp_cnt > 0)
  SET reply->statlist[4].status_flag = 3
 ELSE
  SET reply->statlist[4].status_flag = 1
 ENDIF
 SET reply->statlist[5].total_items = bitotcnt
 SET reply->statlist[5].qualifying_items = cdm_no_price_cnt
 SET reply->statlist[5].statistic_meaning = "CSBICDMNOPRICE"
 IF (cdm_no_price_cnt > 0)
  SET reply->statlist[5].status_flag = 3
 ELSE
  SET reply->statlist[5].status_flag = 1
 ENDIF
 SET reply->statlist[6].total_items = bitotcnt
 SET reply->statlist[6].qualifying_items = cpthcpcs_not_linked_cnt
 SET reply->statlist[6].statistic_meaning = "CSBICPTNONOMEN"
 IF (cpthcpcs_not_linked_cnt > 0)
  SET reply->statlist[6].status_flag = 3
 ELSE
  SET reply->statlist[6].status_flag = 1
 ENDIF
 SET reply->statlist[7].total_items = bitotcnt
 SET reply->statlist[7].qualifying_items = zero_pri_cnt
 SET reply->statlist[7].statistic_meaning = "CSBIZEROPRI"
 IF (zero_pri_cnt > 0)
  SET reply->statlist[7].status_flag = 3
 ELSE
  SET reply->statlist[7].status_flag = 1
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
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("cs_basic_issues_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
