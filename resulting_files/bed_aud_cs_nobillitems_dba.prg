CREATE PROGRAM bed_aud_cs_nobillitems:dba
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
     2 clinical_type = vc
     2 clinical_id = f8
     2 clinical_desc = vc
     2 order_nobi_ind = i2
     2 dta_nobi_ind = i2
     2 pha_nobi_ind = i2
     2 im_nobi_ind = i2
 )
 SET glb_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=106
    AND cv.cdf_meaning="GLB"
    AND cv.active_ind=1)
  DETAIL
   glb_cd = cv.code_value
  WITH nocounter
 ;end select
 SET rad_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=106
    AND cv.cdf_meaning="RADIOLOGY"
    AND cv.active_ind=1)
  DETAIL
   rad_cd = cv.code_value
  WITH nocounter
 ;end select
 SET item_master_cd = get_code_value(11001,"ITEM_MASTER")
 SET med_def_cd = get_code_value(11001,"MED_DEF")
 SET item_manf_cd = get_code_value(11001,"ITEM_MANF")
 SET desc_cd = get_code_value(11000,"DESC")
 SET stat = alterlist(reply->collist,7)
 SET reply->collist[1].header_text = "Item Type"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Clinical ID/CD"
 SET reply->collist[2].data_type = 2
 SET reply->collist[2].hide_ind = 1
 SET reply->collist[3].header_text = "Item Description"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Orderable Item without a Bill Item"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Assay Without A Bill Item"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Pharmacy Product Without A Bill Item"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Item Master Without A Bill Item"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET totcnt = 0
 SET ordtotcnt = 0
 SELECT INTO "nl:"
  ordcnt = count(*)
  FROM order_catalog
  WHERE active_ind=1
   AND  NOT (orderable_type_flag IN (3, 7, 9))
  DETAIL
   ordtotcnt = ordcnt
  WITH nocounter
 ;end select
 SET dtatotcnt = 0
 SELECT INTO "nl:"
  dtacnt = count(*)
  FROM discrete_task_assay
  WHERE active_ind=1
  DETAIL
   dtatotcnt = dtacnt
  WITH nocounter
 ;end select
 SET phatotcnt = 0
 SELECT INTO "nl:"
  phacnt = count(*)
  FROM med_product
  WHERE active_ind=1
  DETAIL
   phatotcnt = phacnt
  WITH nocounter
 ;end select
 SET imtotcnt = 0
 SELECT INTO "nl:"
  imcnt = count(*)
  FROM item_master
  DETAIL
   imtotcnt = imcnt
  WITH nocounter
 ;end select
 SET totcnt = (((ordtotcnt+ dtatotcnt)+ phatotcnt)+ imtotcnt)
 IF ((request->skip_volume_check_ind=0))
  IF (totcnt > 250000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (totcnt > 125000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET bcnt = 0
 SELECT INTO "nl:"
  desc = cnvtupper(o.description)
  FROM order_catalog o,
   (dummyt d  WITH seq = 1),
   bill_item b
  PLAN (o
   WHERE o.active_ind=1
    AND  NOT (o.orderable_type_flag IN (3, 7, 9)))
   JOIN (d)
   JOIN (b
   WHERE b.ext_parent_reference_id=o.catalog_cd
    AND b.active_ind=1)
  ORDER BY desc
  DETAIL
   bcnt = (bcnt+ 1), stat = alterlist(temp->bilist,bcnt), temp->bilist[bcnt].clinical_type = "Order",
   temp->bilist[bcnt].clinical_id = o.catalog_cd, temp->bilist[bcnt].clinical_desc = o.description,
   temp->bilist[bcnt].order_nobi_ind = 1,
   temp->bilist[bcnt].dta_nobi_ind = 0, temp->bilist[bcnt].pha_nobi_ind = 0, temp->bilist[bcnt].
   im_nobi_ind = 0
  WITH nocounter, outerjoin = d, dontexist
 ;end select
 SELECT INTO "nl:"
  desc = cnvtupper(dta.description)
  FROM discrete_task_assay dta,
   (dummyt d  WITH seq = 1),
   bill_item b
  PLAN (dta
   WHERE  NOT (dta.activity_type_cd IN (
   (SELECT
    code_value
    FROM code_value
    WHERE code_set=106
     AND definition IN ("GENERAL LAB", "RADIOLOGY"))))
    AND dta.active_ind=1)
   JOIN (d)
   JOIN (b
   WHERE b.ext_child_reference_id=dta.task_assay_cd
    AND b.active_ind=1)
  ORDER BY desc
  DETAIL
   bcnt = (bcnt+ 1), stat = alterlist(temp->bilist,bcnt), temp->bilist[bcnt].clinical_type = "Assay",
   temp->bilist[bcnt].clinical_id = dta.task_assay_cd, temp->bilist[bcnt].clinical_desc = dta
   .description, temp->bilist[bcnt].order_nobi_ind = 0,
   temp->bilist[bcnt].dta_nobi_ind = 1, temp->bilist[bcnt].pha_nobi_ind = 0, temp->bilist[bcnt].
   im_nobi_ind = 0
  WITH nocounter, outerjoin = d, dontexist
 ;end select
 SELECT INTO "nl:"
  FROM med_product mp,
   object_identifier_index oii,
   (dummyt d  WITH seq = 1),
   bill_item b
  PLAN (mp
   WHERE mp.active_ind=1)
   JOIN (oii
   WHERE oii.object_id=mp.manf_item_id
    AND oii.generic_object=0
    AND oii.object_type_cd=item_manf_cd
    AND oii.identifier_type_cd=desc_cd)
   JOIN (d)
   JOIN (b
   WHERE b.ext_parent_reference_id=mp.manf_item_id
    AND b.active_ind=1)
  ORDER BY oii.value_key
  DETAIL
   bcnt = (bcnt+ 1), stat = alterlist(temp->bilist,bcnt), temp->bilist[bcnt].clinical_type =
   "Pharmacy Product",
   temp->bilist[bcnt].clinical_id = mp.manf_item_id, temp->bilist[bcnt].clinical_desc = oii.value,
   temp->bilist[bcnt].order_nobi_ind = 0,
   temp->bilist[bcnt].dta_nobi_ind = 0, temp->bilist[bcnt].pha_nobi_ind = 1, temp->bilist[bcnt].
   im_nobi_ind = 0
  WITH nocounter, outerjoin = d, dontexist
 ;end select
 SELECT INTO "nl:"
  FROM item_master im,
   object_identifier_index oii,
   (dummyt d  WITH seq = 1),
   bill_item b
  PLAN (im)
   JOIN (oii
   WHERE oii.object_id=im.item_id
    AND oii.generic_object=0
    AND oii.object_type_cd=item_master_cd
    AND oii.identifier_type_cd=desc_cd)
   JOIN (d)
   JOIN (b
   WHERE b.ext_parent_reference_id=im.item_id
    AND b.active_ind=1)
  ORDER BY oii.value_key
  DETAIL
   bcnt = (bcnt+ 1), stat = alterlist(temp->bilist,bcnt), temp->bilist[bcnt].clinical_type =
   "Item Master",
   temp->bilist[bcnt].clinical_id = im.item_id, temp->bilist[bcnt].clinical_desc = oii.value, temp->
   bilist[bcnt].order_nobi_ind = 0,
   temp->bilist[bcnt].dta_nobi_ind = 0, temp->bilist[bcnt].pha_nobi_ind = 0, temp->bilist[bcnt].
   im_nobi_ind = 1
  WITH nocounter, outerjoin = d, dontexist
 ;end select
 SET ord_nobi_cnt = 0
 SET dta_nobi_cnt = 0
 SET pha_nobi_cnt = 0
 SET im_nobi_cnt = 0
 IF (bcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = bcnt)
   PLAN (d)
   HEAD REPORT
    rcnt = 0
   DETAIL
    rcnt = (rcnt+ 1), stat = alterlist(reply->rowlist,rcnt), stat = alterlist(reply->rowlist[rcnt].
     celllist,7),
    reply->rowlist[rcnt].celllist[1].string_value = temp->bilist[d.seq].clinical_type, reply->
    rowlist[rcnt].celllist[2].double_value = temp->bilist[d.seq].clinical_id, reply->rowlist[rcnt].
    celllist[3].string_value = temp->bilist[d.seq].clinical_desc
    IF ((temp->bilist[d.seq].order_nobi_ind=1))
     ord_nobi_cnt = (ord_nobi_cnt+ 1), reply->rowlist[rcnt].celllist[4].string_value = "X", reply->
     rowlist[rcnt].celllist[5].string_value = " ",
     reply->rowlist[rcnt].celllist[6].string_value = " ", reply->rowlist[rcnt].celllist[7].
     string_value = " "
    ENDIF
    IF ((temp->bilist[d.seq].dta_nobi_ind=1))
     dta_nobi_cnt = (dta_nobi_cnt+ 1), reply->rowlist[rcnt].celllist[4].string_value = " ", reply->
     rowlist[rcnt].celllist[5].string_value = "X",
     reply->rowlist[rcnt].celllist[6].string_value = " ", reply->rowlist[rcnt].celllist[7].
     string_value = " "
    ENDIF
    IF ((temp->bilist[d.seq].pha_nobi_ind=1))
     pha_nobi_cnt = (pha_nobi_cnt+ 1), reply->rowlist[rcnt].celllist[4].string_value = " ", reply->
     rowlist[rcnt].celllist[5].string_value = " ",
     reply->rowlist[rcnt].celllist[6].string_value = "X", reply->rowlist[rcnt].celllist[7].
     string_value = " "
    ENDIF
    IF ((temp->bilist[d.seq].im_nobi_ind=1))
     im_nobi_cnt = (im_nobi_cnt+ 1), reply->rowlist[rcnt].celllist[4].string_value = " ", reply->
     rowlist[rcnt].celllist[5].string_value = " ",
     reply->rowlist[rcnt].celllist[6].string_value = " ", reply->rowlist[rcnt].celllist[7].
     string_value = "X"
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (ord_nobi_cnt=0
  AND dta_nobi_cnt=0
  AND pha_nobi_cnt=0
  AND im_nobi_cnt=0)
  SET reply->run_status_flag = 1
 ELSE
  SET reply->run_status_flag = 3
 ENDIF
 SET stat = alterlist(reply->statlist,4)
 SET reply->statlist[1].total_items = ordtotcnt
 SET reply->statlist[1].qualifying_items = ord_nobi_cnt
 SET reply->statlist[1].statistic_meaning = "CSORDERNOBI"
 IF (ord_nobi_cnt > 0)
  SET reply->statlist[1].status_flag = 3
 ELSE
  SET reply->statlist[1].status_flag = 1
 ENDIF
 SET reply->statlist[2].total_items = dtatotcnt
 SET reply->statlist[2].qualifying_items = dta_nobi_cnt
 SET reply->statlist[2].statistic_meaning = "CSDTANOBI"
 IF (dta_nobi_cnt > 0)
  SET reply->statlist[2].status_flag = 3
 ELSE
  SET reply->statlist[2].status_flag = 1
 ENDIF
 SET reply->statlist[3].total_items = phatotcnt
 SET reply->statlist[3].qualifying_items = pha_nobi_cnt
 SET reply->statlist[3].statistic_meaning = "CSPHANOBI"
 IF (pha_nobi_cnt > 0)
  SET reply->statlist[3].status_flag = 3
 ELSE
  SET reply->statlist[3].status_flag = 1
 ENDIF
 SET reply->statlist[4].total_items = imtotcnt
 SET reply->statlist[4].qualifying_items = im_nobi_cnt
 SET reply->statlist[4].statistic_meaning = "CSIMNOBI"
 IF (im_nobi_cnt > 0)
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
  SET reply->output_filename = build("cs_missing_bill_item_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
