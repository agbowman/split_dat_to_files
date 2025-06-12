CREATE PROGRAM bed_aud_bbt_prod_ord_prod_idxs:dba
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
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 DECLARE bb_orderable_proc_cs = i4 WITH protect, constant(1635)
 DECLARE activity_type_cs = i4 WITH protect, constant(106)
 DECLARE catalog_type_cs = i4 WITH protect, constant(6000)
 DECLARE prod_req_order_mean = vc WITH protect, constant("PRODUCT ORDR")
 DECLARE prod_req_order_cd = f8 WITH protect, noconstant(0.0)
 DECLARE bb_activity_type_mean = vc WITH protect, constant("BB")
 DECLARE bb_activity_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE gen_lab_cat_type_mean = vc WITH protect, constant("GENERAL LAB")
 DECLARE gen_lab_cat_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE row_nbr = i4 WITH protect, noconstant(0)
 SET gen_lab_cat_type_cd = uar_get_code_by("MEANING",catalog_type_cs,nullterm(gen_lab_cat_type_mean))
 IF (gen_lab_cat_type_cd <= 0.0)
  CALL bederror(concat("CODE_BY_MEAN_ERR(",catalog_type_cs,")"))
 ENDIF
 SET bb_activity_type_cd = uar_get_code_by("MEANING",activity_type_cs,nullterm(bb_activity_type_mean)
  )
 IF (bb_activity_type_cd <= 0.0)
  CALL bederror(concat("CODE_BY_MEAN_ERR(",activity_type_cs,")"))
 ENDIF
 SET prod_req_order_cd = uar_get_code_by("MEANING",bb_orderable_proc_cs,nullterm(prod_req_order_mean)
  )
 IF (prod_req_order_cd <= 0.0)
  CALL bederror(concat("CODE_BY_MEAN_ERR(",bb_orderable_proc_cs,")"))
 ENDIF
 SET stat = alterlist(reply->collist,4)
 SET reply->collist[1].header_text = "Product Orderable"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Product Type"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Catalog_cd"
 SET reply->collist[3].data_type = 2
 SET reply->collist[3].hide_ind = 1
 SET reply->collist[4].header_text = "Product_cd"
 SET reply->collist[4].data_type = 2
 SET reply->collist[4].hide_ind = 1
 SELECT INTO "nl:"
  FROM order_catalog oc,
   service_directory sd,
   prod_ord_prod_idx_r po,
   code_value cv
  PLAN (oc
   WHERE oc.active_ind=1
    AND oc.catalog_type_cd=gen_lab_cat_type_cd
    AND oc.activity_type_cd=bb_activity_type_cd)
   JOIN (sd
   WHERE sd.catalog_cd=oc.catalog_cd
    AND sd.bb_processing_cd=prod_req_order_cd)
   JOIN (po
   WHERE oc.catalog_cd=po.catalog_cd
    AND po.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=po.product_cd)
  ORDER BY oc.primary_mnemonic, cv.display_key
  HEAD REPORT
   row_nbr = 0
  DETAIL
   row_nbr = (row_nbr+ 1), stat = alterlist(reply->rowlist,row_nbr), stat = alterlist(reply->rowlist[
    row_nbr].celllist,4),
   reply->rowlist[row_nbr].celllist[1].string_value = oc.primary_mnemonic, reply->rowlist[row_nbr].
   celllist[2].string_value = cv.display, reply->rowlist[row_nbr].celllist[3].double_value = oc
   .catalog_cd,
   reply->rowlist[row_nbr].celllist[4].double_value = po.product_cd
  WITH nocounter
 ;end select
 CALL bederrorcheck("SELECT_ERR")
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("bbt_prod_ord_prod_idxs.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
