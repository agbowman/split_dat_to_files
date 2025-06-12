CREATE PROGRAM bed_rec_missin_clin_itm_detail:dba
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
     2 activity_type_cd = f8
     2 bill_item_id = f8
     2 activity_type = vc
     2 bill_item_desc = vc
     2 no_order_ind = i2
     2 no_dta_ind = i2
     2 no_pha_ind = i2
     2 no_im_ind = i2
     2 has_cp_ind = i2
     2 has_bc_ind = i2
     2 has_price_ind = i2
 )
 RECORD temp2(
   1 bilist[*]
     2 activity_type_cd = f8
     2 bill_item_id = f8
     2 activity_type = vc
     2 bill_item_desc = vc
     2 no_order_ind = i2
     2 no_dta_ind = i2
     2 no_pha_ind = i2
     2 no_im_ind = i2
     2 has_cp_ind = i2
     2 has_bc_ind = i2
     2 has_price_ind = i2
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
 SET ord_cd = get_code_value(13016,"ORD CAT")
 SET dta_cd = get_code_value(13016,"TASK ASSAY")
 SET pha_cd = get_code_value(13016,"MANF ITEM")
 SET im_cd = get_code_value(13016,"ITEM MASTER")
 SET chg_pt_cd = get_code_value(13019,"CHARGE POINT")
 SET bc_cd = get_code_value(13019,"BILL CODE")
 SET check_no_ord_ind = 0
 SET check_no_dta_ind = 0
 SET check_no_pharm_ind = 0
 SET check_no_im_ind = 0
 SET no_ord_col_nbr = 0
 SET no_dta_col_nbr = 0
 SET no_pharm_col_nbr = 0
 SET no_im_col_nbr = 0
 SET has_cp_col_nbr = 0
 SET has_bc_col_nbr = 0
 SET has_price_col_nbr = 0
 SET col_cnt = (5+ plsize)
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
   IF ((request->paramlist[p].meaning="BILLITMMISSINGORD"))
    SET check_no_ord_ind = 1
    SET next_col = (next_col+ 1)
    SET no_ord_col_nbr = next_col
    SET reply->collist[next_col].header_text = "Inactive or Missing Orderable Items"
    SET reply->collist[next_col].data_type = 1
    SET reply->collist[next_col].hide_ind = 0
    SELECT INTO "nl:"
     FROM bill_item b,
      (dummyt d  WITH seq = 1),
      order_catalog o
     PLAN (b
      WHERE b.active_ind=1
       AND b.ext_parent_contributor_cd=ord_cd
       AND b.ext_child_reference_id=0
       AND  NOT (b.ext_parent_reference_id IN (313082, 313394, 313398, 313400, 313404,
      313406, 313410, 313412, 313416, 313418,
      313422, 313428, 644535, 670254, 670257,
      670259, 670261, 670263, 670265)))
      JOIN (d)
      JOIN (o
      WHERE o.catalog_cd=b.ext_parent_reference_id
       AND o.active_ind=1)
     DETAIL
      bcnt = (bcnt+ 1), stat = alterlist(temp->bilist,bcnt), temp->bilist[bcnt].activity_type_cd = b
      .ext_owner_cd,
      temp->bilist[bcnt].bill_item_id = b.bill_item_id, temp->bilist[bcnt].bill_item_desc = b
      .ext_description, temp->bilist[bcnt].no_order_ind = 1
     WITH nocounter, outerjoin = d, dontexist
    ;end select
   ENDIF
   IF ((request->paramlist[p].meaning="BILLITMMISSINGASSAY"))
    SET check_no_dta_ind = 1
    SET next_col = (next_col+ 1)
    SET no_dta_col_nbr = next_col
    SET reply->collist[next_col].header_text = "Inactive or Missing Assays"
    SET reply->collist[next_col].data_type = 1
    SET reply->collist[next_col].hide_ind = 0
    SELECT INTO "nl:"
     FROM bill_item b,
      (dummyt d  WITH seq = 1),
      discrete_task_assay dta
     PLAN (b
      WHERE b.active_ind=1
       AND b.ext_child_contributor_cd=dta_cd
       AND b.ext_parent_reference_id=0)
      JOIN (d)
      JOIN (dta
      WHERE dta.task_assay_cd=b.ext_child_reference_id
       AND dta.active_ind=1)
     DETAIL
      bcnt = (bcnt+ 1), stat = alterlist(temp->bilist,bcnt), temp->bilist[bcnt].activity_type_cd = b
      .ext_owner_cd,
      temp->bilist[bcnt].bill_item_id = b.bill_item_id, temp->bilist[bcnt].bill_item_desc = b
      .ext_description, temp->bilist[bcnt].no_dta_ind = 1
     WITH nocounter, outerjoin = d, dontexist
    ;end select
   ENDIF
   IF ((request->paramlist[p].meaning="BILLITMMISSINGPHARM"))
    SET check_no_pharm_ind = 1
    SET next_col = (next_col+ 1)
    SET no_pharm_col_nbr = next_col
    SET reply->collist[next_col].header_text = "Inactive or Missing Pharmacy Formulary Items"
    SET reply->collist[next_col].data_type = 1
    SET reply->collist[next_col].hide_ind = 0
    SELECT INTO "nl:"
     FROM bill_item b,
      (dummyt d  WITH seq = 1),
      med_product m
     PLAN (b
      WHERE b.active_ind=1
       AND b.ext_parent_contributor_cd=pha_cd)
      JOIN (d)
      JOIN (m
      WHERE m.manf_item_id=b.ext_parent_reference_id
       AND m.active_ind=1)
     DETAIL
      bcnt = (bcnt+ 1), stat = alterlist(temp->bilist,bcnt), temp->bilist[bcnt].activity_type_cd = b
      .ext_owner_cd,
      temp->bilist[bcnt].bill_item_id = b.bill_item_id, temp->bilist[bcnt].bill_item_desc = b
      .ext_description, temp->bilist[bcnt].no_pha_ind = 1
     WITH nocounter, outerjoin = d, dontexist
    ;end select
   ENDIF
   IF ((request->paramlist[p].meaning="BILLITMMISSINGMASTER"))
    SET check_no_im_ind = 1
    SET next_col = (next_col+ 1)
    SET no_im_col_nbr = next_col
    SET reply->collist[next_col].header_text = "Inactive or Missing Item Master Items"
    SET reply->collist[next_col].data_type = 1
    SET reply->collist[next_col].hide_ind = 0
    SELECT INTO "nl:"
     FROM bill_item b,
      (dummyt d  WITH seq = 1),
      item_master i
     PLAN (b
      WHERE b.active_ind=1
       AND b.ext_parent_contributor_cd=im_cd)
      JOIN (d)
      JOIN (i
      WHERE i.item_id=b.ext_parent_reference_id)
     DETAIL
      bcnt = (bcnt+ 1), stat = alterlist(temp->bilist,bcnt), temp->bilist[bcnt].activity_type_cd = b
      .ext_owner_cd,
      temp->bilist[bcnt].bill_item_id = b.bill_item_id, temp->bilist[bcnt].bill_item_desc = b
      .ext_description, temp->bilist[bcnt].no_im_ind = 1
     WITH nocounter, outerjoin = d, dontexist
    ;end select
   ENDIF
   SELECT INTO "nl:"
    FROM bill_item b,
     item_master i,
     item_definition id
    PLAN (b
     WHERE b.active_ind=1
      AND b.ext_parent_contributor_cd=im_cd)
     JOIN (i
     WHERE i.item_id=b.ext_parent_reference_id)
     JOIN (id
     WHERE id.item_id=i.item_id)
    DETAIL
     IF (id.active_ind != 1)
      bcnt = (bcnt+ 1), stat = alterlist(temp->bilist,bcnt), temp->bilist[bcnt].activity_type_cd = b
      .ext_owner_cd,
      temp->bilist[bcnt].bill_item_id = b.bill_item_id, temp->bilist[bcnt].bill_item_desc = b
      .ext_description, temp->bilist[bcnt].no_im_ind = 1
     ENDIF
    WITH nocounter
   ;end select
 ENDFOR
 SET bidx = 0
 IF (bcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = bcnt),
    bill_item_modifier bim
   PLAN (d)
    JOIN (bim
    WHERE (bim.bill_item_id=temp->bilist[d.seq].bill_item_id)
     AND bim.bill_item_type_cd IN (chg_pt_cd, bc_cd))
   DETAIL
    IF (bim.bill_item_type_cd=chg_pt_cd)
     temp->bilist[d.seq].has_cp_ind = 1
    ELSEIF (bim.bill_item_type_cd=bc_cd)
     temp->bilist[d.seq].has_bc_ind = 1
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = bcnt),
    price_sched_items psi
   PLAN (d)
    JOIN (psi
    WHERE (psi.bill_item_id=temp->bilist[d.seq].bill_item_id))
   DETAIL
    temp->bilist[d.seq].has_price_ind = 1
   WITH nocounter
  ;end select
  SET next_col = (next_col+ 1)
  SET has_cp_col_nbr = next_col
  SET reply->collist[next_col].header_text = "Charge Processing Defined"
  SET reply->collist[next_col].data_type = 1
  SET reply->collist[next_col].hide_ind = 0
  SET next_col = (next_col+ 1)
  SET has_bc_col_nbr = next_col
  SET reply->collist[next_col].header_text = "Bill Codes Defined"
  SET reply->collist[next_col].data_type = 1
  SET reply->collist[next_col].hide_ind = 0
  SET next_col = (next_col+ 1)
  SET has_price_col_nbr = next_col
  SET reply->collist[next_col].header_text = "Pricing Defined"
  SET reply->collist[next_col].data_type = 1
  SET reply->collist[next_col].hide_ind = 0
  SET stat = alterlist(temp2->bilist,bcnt)
  SELECT INTO "nl:"
   bi_id = temp->bilist[d.seq].bill_item_id, item_disp = cnvtupper(temp->bilist[d.seq].bill_item_desc
    )
   FROM (dummyt d  WITH seq = bcnt),
    code_value cv
   PLAN (d)
    JOIN (cv
    WHERE (cv.code_value=temp->bilist[d.seq].activity_type_cd))
   ORDER BY cv.display_key, item_disp, bi_id
   DETAIL
    IF ((((temp->bilist[d.seq].no_order_ind=1)) OR ((((temp->bilist[d.seq].no_dta_ind=1)) OR ((((temp
    ->bilist[d.seq].no_pha_ind=1)) OR ((((temp->bilist[d.seq].no_im_ind=1)) OR ((((temp->bilist[d.seq
    ].has_cp_ind=1)) OR ((((temp->bilist[d.seq].has_bc_ind=1)) OR ((temp->bilist[d.seq].has_price_ind
    =1))) )) )) )) )) )) )
     bidx = (bidx+ 1), temp2->bilist[bidx].activity_type_cd = temp->bilist[d.seq].activity_type_cd,
     temp2->bilist[bidx].bill_item_id = temp->bilist[d.seq].bill_item_id,
     temp2->bilist[bidx].bill_item_desc = temp->bilist[d.seq].bill_item_desc, temp2->bilist[bidx].
     activity_type = cv.display, temp2->bilist[bidx].no_order_ind = temp->bilist[d.seq].no_order_ind,
     temp2->bilist[bidx].no_dta_ind = temp->bilist[d.seq].no_dta_ind, temp2->bilist[bidx].no_pha_ind
      = temp->bilist[d.seq].no_pha_ind, temp2->bilist[bidx].no_im_ind = temp->bilist[d.seq].no_im_ind,
     temp2->bilist[bidx].has_cp_ind = temp->bilist[d.seq].has_cp_ind, temp2->bilist[bidx].has_bc_ind
      = temp->bilist[d.seq].has_bc_ind, temp2->bilist[bidx].has_price_ind = temp->bilist[d.seq].
     has_price_ind
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (bidx > 0)
  SELECT INTO "nl:"
   bi_id = temp2->bilist[d.seq].bill_item_id
   FROM (dummyt d  WITH seq = bidx)
   PLAN (d)
   HEAD REPORT
    rcnt = 0
   HEAD bi_id
    rcnt = (rcnt+ 1), stat = alterlist(reply->rowlist,rcnt), stat = alterlist(reply->rowlist[rcnt].
     celllist,col_cnt),
    reply->rowlist[rcnt].celllist[1].string_value = temp2->bilist[d.seq].activity_type, reply->
    rowlist[rcnt].celllist[2].string_value = temp2->bilist[d.seq].bill_item_desc
   DETAIL
    IF (check_no_ord_ind=1
     AND (temp2->bilist[d.seq].no_order_ind=1))
     reply->rowlist[rcnt].celllist[no_ord_col_nbr].string_value = "X"
    ENDIF
    IF (check_no_dta_ind=1
     AND (temp2->bilist[d.seq].no_dta_ind=1))
     reply->rowlist[rcnt].celllist[no_dta_col_nbr].string_value = "X"
    ENDIF
    IF (check_no_pharm_ind=1
     AND (temp2->bilist[d.seq].no_pha_ind=1))
     reply->rowlist[rcnt].celllist[no_pharm_col_nbr].string_value = "X"
    ENDIF
    IF (check_no_im_ind=1
     AND (temp2->bilist[d.seq].no_im_ind=1))
     reply->rowlist[rcnt].celllist[no_im_col_nbr].string_value = "X"
    ENDIF
    IF ((temp2->bilist[d.seq].has_cp_ind=1))
     reply->rowlist[rcnt].celllist[has_cp_col_nbr].string_value = "X"
    ENDIF
    IF ((temp2->bilist[d.seq].has_bc_ind=1))
     reply->rowlist[rcnt].celllist[has_bc_col_nbr].string_value = "X"
    ENDIF
    IF ((temp2->bilist[d.seq].has_price_ind=1))
     reply->rowlist[rcnt].celllist[has_price_col_nbr].string_value = "X"
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
