CREATE PROGRAM bed_rec_missin_bill_itm_detail:dba
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
 SET plsize = size(request->paramlist,5)
 DECLARE short_desc = vc
 SET stat = alterlist(reply->res_collist,2)
 SET reply->res_collist[1].header_text = "Check Name"
 SET reply->res_collist[2].header_text = "Resolution"
 SET stat = alterlist(reply->res_rowlist,1)
 SET stat = alterlist(reply->res_rowlist[1].res_celllist,2)
 SET reply->res_rowlist[1].res_celllist[1].cell_text = "All Checks"
 SET reply->res_rowlist[1].res_celllist[2].cell_text = build(
  'For all checks evaluated by this report refer to the "Configure" section of Charge Services in',
  " the Reference Pages for information about how to run the appropriate load script for the affected",
  " orderable item, assay, pharmacy product, or item master.")
 SET med_def_cd = get_code_value(11001,"MED_DEF")
 SET item_master_cd = get_code_value(11001,"ITEM_MASTER")
 SET item_manf_cd = get_code_value(11001,"ITEM_MANF")
 SET desc_cd = get_code_value(11000,"DESC")
 SET disp_cd = get_code_value(11000,"DESC_SHORT")
 SET col_cnt = 4
 SET stat = alterlist(reply->collist,col_cnt)
 SET reply->collist[1].header_text = "Check Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Activity Type"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Item Display"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Item Description"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 FOR (p = 1 TO plsize)
   IF ((request->paramlist[p].meaning="ORDITMNOBILLITM"))
    SET short_desc = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl
     PLAN (b
      WHERE b.rec_mean="ORDITMNOBILLITM")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
     DETAIL
      short_desc = trim(b.short_desc)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     desc = cnvtupper(o.description)
     FROM order_catalog o,
      code_value cv,
      (dummyt d  WITH seq = 1),
      bill_item b
     PLAN (o
      WHERE o.active_ind=1
       AND  NOT (o.orderable_type_flag IN (3, 7, 9)))
      JOIN (cv
      WHERE cv.code_value=o.activity_type_cd
       AND cv.active_ind=1)
      JOIN (d)
      JOIN (b
      WHERE b.ext_parent_reference_id=o.catalog_cd
       AND b.active_ind=1)
     ORDER BY desc
     DETAIL
      row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat
       = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
      reply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, reply->rowlist[row_tot_cnt].
      celllist[2].string_value = cv.display, reply->rowlist[row_tot_cnt].celllist[3].string_value = o
      .primary_mnemonic,
      reply->rowlist[row_tot_cnt].celllist[4].string_value = o.description
     WITH nocounter, outerjoin = d, dontexist
    ;end select
   ENDIF
   IF ((request->paramlist[p].meaning="ASSAYSNOBILLITM"))
    SET short_desc = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl
     PLAN (b
      WHERE b.rec_mean="ASSAYSNOBILLITM")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
     DETAIL
      short_desc = trim(b.short_desc)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     desc = cnvtupper(dta.description)
     FROM discrete_task_assay dta,
      code_value cv,
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
      JOIN (cv
      WHERE cv.code_value=dta.activity_type_cd
       AND cv.active_ind=1)
      JOIN (d)
      JOIN (b
      WHERE b.ext_child_reference_id=dta.task_assay_cd
       AND b.active_ind=1)
     ORDER BY desc
     DETAIL
      row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat
       = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
      reply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, reply->rowlist[row_tot_cnt].
      celllist[2].string_value = cv.display, reply->rowlist[row_tot_cnt].celllist[3].string_value =
      dta.mnemonic,
      reply->rowlist[row_tot_cnt].celllist[4].string_value = dta.description
     WITH nocounter, outerjoin = d, dontexist
    ;end select
   ENDIF
   IF ((request->paramlist[p].meaning="PHARMITMNOBILLITM"))
    SET short_desc = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl
     PLAN (b
      WHERE b.rec_mean="PHARMITMNOBILLITM")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
     DETAIL
      short_desc = trim(b.short_desc)
     WITH nocounter
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
       AND oii.identifier_type_cd=desc_cd
       AND oii.active_ind=1)
      JOIN (d)
      JOIN (b
      WHERE b.ext_parent_reference_id=mp.manf_item_id
       AND b.active_ind=1)
     ORDER BY oii.value_key
     DETAIL
      row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat
       = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
      reply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, reply->rowlist[row_tot_cnt].
      celllist[2].string_value = "Pharmacy", reply->rowlist[row_tot_cnt].celllist[3].string_value =
      " ",
      reply->rowlist[row_tot_cnt].celllist[4].string_value = oii.value
     WITH nocounter, outerjoin = d, dontexist
    ;end select
   ENDIF
   IF ((request->paramlist[p].meaning="MASTERITMNOBILLITM"))
    SET short_desc = ""
    SELECT INTO "nl:"
     FROM br_rec b,
      br_long_text bl
     PLAN (b
      WHERE b.rec_mean="MASTERITMNOBILLITM")
      JOIN (bl
      WHERE bl.long_text_id=b.recommendation_txt_id)
     DETAIL
      short_desc = trim(b.short_desc)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM item_master im,
      object_identifier_index oii,
      object_identifier_index oidi,
      (dummyt d  WITH seq = 1),
      bill_item b
     PLAN (im)
      JOIN (oii
      WHERE oii.object_id=im.item_id
       AND oii.generic_object=0
       AND oii.object_type_cd=item_master_cd
       AND oii.identifier_type_cd=desc_cd
       AND oii.active_ind=1)
      JOIN (oidi
      WHERE oidi.object_id=im.item_id
       AND oidi.generic_object=0
       AND oidi.object_type_cd=item_master_cd
       AND oidi.identifier_type_cd=disp_cd
       AND oidi.active_ind=1)
      JOIN (d)
      JOIN (b
      WHERE b.ext_parent_reference_id=im.item_id
       AND b.active_ind=1)
     ORDER BY oii.value_key
     DETAIL
      row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat
       = alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
      reply->rowlist[row_tot_cnt].celllist[1].string_value = short_desc, reply->rowlist[row_tot_cnt].
      celllist[2].string_value = "Supplies", reply->rowlist[row_tot_cnt].celllist[3].string_value =
      oidi.value,
      reply->rowlist[row_tot_cnt].celllist[4].string_value = oii.value
     WITH nocounter, outerjoin = d, dontexist
    ;end select
   ENDIF
 ENDFOR
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
