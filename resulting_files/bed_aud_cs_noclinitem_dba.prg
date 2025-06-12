CREATE PROGRAM bed_aud_cs_noclinitem:dba
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
     2 activity_type_cd = f8
     2 activity_type = vc
     2 bill_item_id = f8
     2 bill_item_desc = vc
     2 no_order_ind = i2
     2 no_dta_ind = i2
     2 no_pha_ind = i2
     2 no_im_ind = i2
     2 has_cp_ind = i2
     2 has_bc_ind = i2
     2 has_price_ind = i2
 )
 SET ord_cd = get_code_value(13016,"ORD CAT")
 SET dta_cd = get_code_value(13016,"TASK ASSAY")
 SET pha_cd = get_code_value(13016,"MANF ITEM")
 SET im_cd = get_code_value(13016,"ITEM MASTER")
 SET chg_pt_cd = get_code_value(13019,"CHARGE POINT")
 SET bc_cd = get_code_value(13019,"BILL CODE")
 SET stat = alterlist(reply->collist,10)
 SET reply->collist[1].header_text = "Activity Type"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Bill Item ID"
 SET reply->collist[2].data_type = 2
 SET reply->collist[2].hide_ind = 1
 SET reply->collist[3].header_text = "Bill Item Description"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Missing Active Orderable Item"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Missing Active Assay"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Missing Active Pharmacy Product"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Missing Item Master"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Charge Processing Defined"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Bill Codes Defined"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Pricing Defined"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET totcnt = 0
 SELECT INTO "nl:"
  bicnt = count(*)
  FROM bill_item
  WHERE active_ind=1
   AND ext_parent_contributor_cd IN (ord_cd, dta_cd, pha_cd, im_cd)
   AND ext_child_reference_id=0
  DETAIL
   totcnt = bicnt
  WITH nocounter
 ;end select
 IF ((request->skip_volume_check_ind=0))
  IF (totcnt > 125000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (totcnt > 75000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET bcnt = 0
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
   .ext_description, temp->bilist[bcnt].no_order_ind = 1,
   temp->bilist[bcnt].no_dta_ind = 0, temp->bilist[bcnt].no_pha_ind = 0, temp->bilist[bcnt].no_im_ind
    = 0,
   temp->bilist[bcnt].has_cp_ind = 0, temp->bilist[bcnt].has_bc_ind = 0, temp->bilist[bcnt].
   has_price_ind = 0
  WITH nocounter, outerjoin = d, dontexist
 ;end select
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
   .ext_description, temp->bilist[bcnt].no_order_ind = 0,
   temp->bilist[bcnt].no_dta_ind = 1, temp->bilist[bcnt].no_pha_ind = 0, temp->bilist[bcnt].no_im_ind
    = 0,
   temp->bilist[bcnt].has_cp_ind = 0, temp->bilist[bcnt].has_bc_ind = 0, temp->bilist[bcnt].
   has_price_ind = 0
  WITH nocounter, outerjoin = d, dontexist
 ;end select
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
   .ext_description, temp->bilist[bcnt].no_order_ind = 0,
   temp->bilist[bcnt].no_dta_ind = 0, temp->bilist[bcnt].no_pha_ind = 1, temp->bilist[bcnt].no_im_ind
    = 0,
   temp->bilist[bcnt].has_cp_ind = 0, temp->bilist[bcnt].has_bc_ind = 0, temp->bilist[bcnt].
   has_price_ind = 0
  WITH nocounter, outerjoin = d, dontexist
 ;end select
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
   .ext_description, temp->bilist[bcnt].no_order_ind = 0,
   temp->bilist[bcnt].no_dta_ind = 0, temp->bilist[bcnt].no_pha_ind = 0, temp->bilist[bcnt].no_im_ind
    = 1,
   temp->bilist[bcnt].has_cp_ind = 0, temp->bilist[bcnt].has_bc_ind = 0, temp->bilist[bcnt].
   has_price_ind = 0
  WITH nocounter, outerjoin = d, dontexist
 ;end select
 SET no_order_cnt = 0
 SET no_dta_cnt = 0
 SET no_pha_cnt = 0
 SET no_im_cnt = 0
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
  SELECT INTO "nl:"
   bidesc = cnvtupper(temp->bilist[d.seq].bill_item_desc)
   FROM (dummyt d  WITH seq = bcnt),
    code_value cv
   PLAN (d)
    JOIN (cv
    WHERE (cv.code_value=temp->bilist[d.seq].activity_type_cd))
   ORDER BY cv.display_key, bidesc
   HEAD REPORT
    rcnt = 0
   DETAIL
    rcnt = (rcnt+ 1), stat = alterlist(reply->rowlist,rcnt), stat = alterlist(reply->rowlist[rcnt].
     celllist,10),
    reply->rowlist[rcnt].celllist[1].string_value = cv.display, reply->rowlist[rcnt].celllist[2].
    double_value = temp->bilist[d.seq].bill_item_id, reply->rowlist[rcnt].celllist[3].string_value =
    temp->bilist[d.seq].bill_item_desc
    IF ((temp->bilist[d.seq].no_order_ind=1))
     no_order_cnt = (no_order_cnt+ 1), reply->rowlist[rcnt].celllist[4].string_value = "X", reply->
     rowlist[rcnt].celllist[5].string_value = " ",
     reply->rowlist[rcnt].celllist[6].string_value = " ", reply->rowlist[rcnt].celllist[7].
     string_value = " "
    ENDIF
    IF ((temp->bilist[d.seq].no_dta_ind=1))
     no_dta_cnt = (no_dta_cnt+ 1), reply->rowlist[rcnt].celllist[4].string_value = " ", reply->
     rowlist[rcnt].celllist[5].string_value = "X",
     reply->rowlist[rcnt].celllist[6].string_value = " ", reply->rowlist[rcnt].celllist[7].
     string_value = " "
    ENDIF
    IF ((temp->bilist[d.seq].no_pha_ind=1))
     no_pha_cnt = (no_pha_cnt+ 1), reply->rowlist[rcnt].celllist[4].string_value = " ", reply->
     rowlist[rcnt].celllist[5].string_value = " ",
     reply->rowlist[rcnt].celllist[6].string_value = "X", reply->rowlist[rcnt].celllist[7].
     string_value = " "
    ENDIF
    IF ((temp->bilist[d.seq].no_im_ind=1))
     no_im_cnt = (no_im_cnt+ 1), reply->rowlist[rcnt].celllist[4].string_value = " ", reply->rowlist[
     rcnt].celllist[5].string_value = " ",
     reply->rowlist[rcnt].celllist[6].string_value = " ", reply->rowlist[rcnt].celllist[7].
     string_value = "X"
    ENDIF
    IF ((temp->bilist[d.seq].has_cp_ind=1))
     reply->rowlist[rcnt].celllist[8].string_value = "X"
    ELSE
     reply->rowlist[rcnt].celllist[8].string_value = " "
    ENDIF
    IF ((temp->bilist[d.seq].has_bc_ind=1))
     reply->rowlist[rcnt].celllist[9].string_value = "X"
    ELSE
     reply->rowlist[rcnt].celllist[9].string_value = " "
    ENDIF
    IF ((temp->bilist[d.seq].has_price_ind=1))
     reply->rowlist[rcnt].celllist[10].string_value = "X"
    ELSE
     reply->rowlist[rcnt].celllist[10].string_value = " "
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (no_order_cnt=0
  AND no_dta_cnt=0
  AND no_pha_cnt=0
  AND no_im_cnt=0)
  SET reply->run_status_flag = 1
 ELSE
  SET reply->run_status_flag = 3
 ENDIF
 SET stat = alterlist(reply->statlist,4)
 SET reply->statlist[1].total_items = totcnt
 SET reply->statlist[1].qualifying_items = no_order_cnt
 SET reply->statlist[1].statistic_meaning = "CSBINOORDER"
 IF (no_order_cnt > 0)
  SET reply->statlist[1].status_flag = 3
 ELSE
  SET reply->statlist[1].status_flag = 1
 ENDIF
 SET reply->statlist[2].total_items = totcnt
 SET reply->statlist[2].qualifying_items = no_dta_cnt
 SET reply->statlist[2].statistic_meaning = "CSBINODTA"
 IF (no_dta_cnt > 0)
  SET reply->statlist[2].status_flag = 3
 ELSE
  SET reply->statlist[2].status_flag = 1
 ENDIF
 SET reply->statlist[3].total_items = totcnt
 SET reply->statlist[3].qualifying_items = no_pha_cnt
 SET reply->statlist[3].statistic_meaning = "CSBINOPHA"
 IF (no_pha_cnt > 0)
  SET reply->statlist[3].status_flag = 3
 ELSE
  SET reply->statlist[3].status_flag = 1
 ENDIF
 SET reply->statlist[4].total_items = totcnt
 SET reply->statlist[4].qualifying_items = no_im_cnt
 SET reply->statlist[4].statistic_meaning = "CSBINOIM"
 IF (no_im_cnt > 0)
  SET reply->statlist[4].status_flag = 3
 ELSE
  SET reply->statlist[4].status_flag = 1
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
  SET reply->output_filename = build("cs_missing_clin_item_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
