CREATE PROGRAM bed_get_rli_current_orders:dba
 FREE SET reply
 RECORD reply(
   1 order_list[*]
     2 alias = vc
     2 mnemonic = vc
     2 supplier_mnemonic = vc
     2 catalog_cd = f8
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE error_flag = vc
 DECLARE error_msg = vc
 DECLARE ordercnt = i4
 DECLARE supplier_flag = i4
 DECLARE supplier_disp = vc
 DECLARE supplier_meaning = vc
 DECLARE supplier_source_cd = f8
 DECLARE ancillary_cd = f8
 SET reply->status_data.status = "F"
 SET error_flag = "F"
 SET ordercnt = 0
 SET supplier_source_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=6011
    AND c.cdf_meaning="ANCILLARY"
    AND c.active_ind=1)
  DETAIL
   ancillary_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM br_rli_supplier brs
  PLAN (brs
   WHERE (brs.supplier_flag=request->supplier_flag))
  DETAIL
   supplier_flag = brs.supplier_flag, supplier_disp = brs.supplier_name, supplier_meaning = brs
   .supplier_meaning
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "T"
  SET error_msg = "Unable to read br_rli_supplier table for supplier"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.display_key=cnvtupper(cnvtalphanum(supplier_meaning))
    AND cv.code_set=73)
  DETAIL
   supplier_source_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "T"
  SET error_msg = "Unable to read contributor source code value for supplier"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM order_catalog o,
   order_catalog_synonym ocs,
   code_value_alias cva
  PLAN (cva
   WHERE cva.code_set=200
    AND cva.contributor_source_cd=supplier_source_cd)
   JOIN (o
   WHERE o.catalog_cd=cva.code_value
    AND o.active_ind=1)
   JOIN (ocs
   WHERE ocs.catalog_cd=o.catalog_cd
    AND ocs.mnemonic_type_cd=ancillary_cd)
  DETAIL
   ordercnt = (ordercnt+ 1), stat = alterlist(reply->order_list,ordercnt), reply->order_list[ordercnt
   ].alias = cva.alias,
   reply->order_list[ordercnt].mnemonic = o.primary_mnemonic, reply->order_list[ordercnt].
   supplier_mnemonic = ocs.mnemonic, reply->order_list[ordercnt].catalog_cd = o.catalog_cd
  WITH nocounter
 ;end select
 IF (ordercnt=0)
  SET error_msg = concat("No orders found for supplier: ",supplier_disp)
 ENDIF
#exit_script
 IF (error_flag="F")
  SET reqinfo->commit_ind = 1
  IF (ordercnt=0)
   SET reply->status_data.status = "Z"
   SET reply->error_msg = error_msg
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ELSEIF (error_flag="T")
  SET reply->error_msg = concat(">> PROGRAM NAME: BED_GET_RLI_CURRENT_ORDERS  ",">> ERROR MESSAGE: ",
   error_msg)
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
