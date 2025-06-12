CREATE PROGRAM bed_get_rli_orders_by_crit
 FREE SET reply
 RECORD reply(
   1 order_list[*]
     2 alias = vc
     2 mnemonic = vc
     2 catalog_cd = f8
     2 ref_lab_mnemonic = vc
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
 DECLARE ocstring = vc
 DECLARE aliasstring = vc
 DECLARE pstring = vc
 DECLARE supplier_flag = i4
 DECLARE supplier_disp = vc
 DECLARE supplier_meaning = vc
 SET reply->status_data.status = "F"
 SET error_flag = "F"
 SET ordercnt = 0
 SET supplier_flag = request->supplier_flag
 SET ocstring = "baro.supplier_flag = supplier_flag "
 SET ocstring = concat(ocstring," and baro.active_ind = 1 ")
 SET ocstring = concat(ocstring," and baro.parent_order_id = 0.0 ")
 IF ((request->desc > " "))
  SET ocstring = concat(ocstring," and cnvtupper(baro.order_mnemonic) = '",cnvtupper(request->desc),
   "*'")
 ENDIF
 SELECT INTO "nl:"
  FROM br_rli_supplier brs
  PLAN (brs
   WHERE brs.supplier_flag=supplier_flag)
  DETAIL
   supplier_disp = brs.supplier_name, supplier_meaning = brs.supplier_meaning
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "T"
  SET error_msg = "Unable to read br_rli_supplier table"
  GO TO exit_script
 ENDIF
 IF ((request->desc > " "))
  SELECT INTO "nl:"
   FROM br_auto_rli_order baro,
    dummyt d1,
    br_rli_client_orders b
   PLAN (baro
    WHERE parser(ocstring))
    JOIN (d1)
    JOIN (b
    WHERE b.alias=baro.alias_name
     AND (b.supplier_flag=request->supplier_flag)
     AND b.active_ind=1)
   DETAIL
    ordercnt = (ordercnt+ 1), stat = alterlist(reply->order_list,ordercnt), reply->order_list[
    ordercnt].alias = baro.alias_name,
    reply->order_list[ordercnt].mnemonic = baro.order_mnemonic, reply->order_list[ordercnt].
    catalog_cd = baro.rli_order_id, reply->order_list[ordercnt].ref_lab_mnemonic = baro
    .supplier_mnemonic
   WITH nocounter, outerjoin = d1, dontexist
  ;end select
 ELSE
  SET aliasstring = concat("'",trim(request->alias),"*'")
  SET pstring = concat(ocstring," and baro.alias_name = ",aliasstring)
  CALL echo(build("aliasstring = ",aliasstring))
  CALL echo(build("pstring = ",pstring))
  SELECT INTO "nl:"
   FROM br_auto_rli_order baro,
    dummyt d1,
    br_rli_client_orders b
   PLAN (baro
    WHERE parser(pstring))
    JOIN (d1)
    JOIN (b
    WHERE b.alias=baro.alias_name
     AND (b.supplier_flag=request->supplier_flag)
     AND b.active_ind=1)
   DETAIL
    ordercnt = (ordercnt+ 1), stat = alterlist(reply->order_list,ordercnt), reply->order_list[
    ordercnt].alias = baro.alias_name,
    reply->order_list[ordercnt].mnemonic = baro.order_mnemonic, reply->order_list[ordercnt].
    catalog_cd = baro.rli_order_id, reply->order_list[ordercnt].ref_lab_mnemonic = baro
    .supplier_mnemonic
   WITH nocounter, outerjoin = d1, dontexist,
    maxcol = 500
  ;end select
 ENDIF
#exit_script
 IF (error_flag="F")
  IF (ordercnt > 0)
   SET reply->status_data.status = "S"
   SET reqinfo->commit_ind = 1
  ELSE
   SET reply->status_data.status = "Z"
   SET reply->error_msg = "No orders found matching search criteria"
   SET reqinfo->commit_ind = 0
  ENDIF
 ELSEIF (error_flag="T")
  SET reply->error_msg = concat(">> PROGRAM NAME: BED_GET_RLI_ORDERS_BY_CRIT  ",">> ERROR MESSAGE: ",
   error_msg)
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
