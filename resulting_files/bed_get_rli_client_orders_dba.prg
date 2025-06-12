CREATE PROGRAM bed_get_rli_client_orders:dba
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
 DECLARE ancillary_cd = f8
 DECLARE supplier_disp = vc
 SET reply->status_data.status = "F"
 SET error_flag = "F"
 SET ordercnt = 0
 SELECT INTO "nl:"
  FROM br_rli_supplier brs
  PLAN (brs
   WHERE (brs.supplier_flag=request->supplier_flag))
  DETAIL
   supplier_disp = brs.supplier_name
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM br_rli_client_orders b,
   br_auto_rli_order baro
  PLAN (b
   WHERE (b.supplier_flag=request->supplier_flag)
    AND b.active_ind=1
    AND b.status_flag=1)
   JOIN (baro
   WHERE baro.alias_name=b.alias
    AND (baro.supplier_flag=request->supplier_flag)
    AND baro.parent_order_id=0.0)
  DETAIL
   ordercnt = (ordercnt+ 1), stat = alterlist(reply->order_list,ordercnt), reply->order_list[ordercnt
   ].alias = b.alias,
   reply->order_list[ordercnt].mnemonic = baro.order_mnemonic, reply->order_list[ordercnt].
   supplier_mnemonic = baro.supplier_mnemonic, reply->order_list[ordercnt].catalog_cd = baro
   .rli_order_id
  WITH nocounter
 ;end select
 IF (ordercnt=0)
  SET error_msg = concat("No orders found for supplier: ",supplier_disp)
 ENDIF
#exit_script
 IF (error_flag="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSEIF (error_flag="T")
  SET reply->error_msg = concat(">> PROGRAM NAME: BED_GET_RLI_CLIENT_ORDERS  ",">> ERROR MESSAGE: ",
   error_msg)
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
