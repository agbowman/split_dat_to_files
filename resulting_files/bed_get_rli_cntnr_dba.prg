CREATE PROGRAM bed_get_rli_cntnr:dba
 FREE SET reply
 RECORD reply(
   1 order_list[*]
     2 mnemonic = vc
     2 catalog_cd = f8
     2 cntnr_list[*]
       3 container_alias_id = f8
       3 container_display = vc
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
 DECLARE rcnt = i4
 DECLARE ccnt = i4
 DECLARE supplier_flag = i4
 DECLARE supplier_disp = vc
 DECLARE supplier_meaning = vc
 SET reply->status_data.status = "F"
 SET error_flag = "F"
 SET ordercnt = 0
 SET rcnt = 0
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
  SET error_msg = "Unable to read br_rli_supplier for supplier"
  GO TO exit_script
 ENDIF
 SET ordercnt = size(request->oclist,5)
 IF (ordercnt > 0)
  FOR (ii = 1 TO ordercnt)
    SET stat = alterlist(reply->order_list,ii)
    SET reply->order_list[ii].catalog_cd = request->oclist[ii].catalog_cd
    SELECT INTO "nl:"
     FROM br_rli_container_reltn b,
      br_auto_rli_order baro,
      br_auto_rli_container barc,
      br_auto_rli_alias bara
     PLAN (b
      WHERE (b.rli_order_id=request->oclist[ii].catalog_cd)
       AND trim(cnvtupper(b.operand))="OR"
       AND b.supplier_flag=supplier_flag
       AND b.active_ind=1)
      JOIN (baro
      WHERE baro.rli_order_id=b.rli_order_id
       AND baro.supplier_flag=supplier_flag
       AND baro.active_ind=1)
      JOIN (barc
      WHERE barc.rli_order_id=baro.rli_order_id
       AND barc.supplier_flag=supplier_flag)
      JOIN (bara
      WHERE bara.alias_name=barc.container
       AND bara.supplier_flag=supplier_flag
       AND bara.code_set=2051)
     ORDER BY b.rli_order_id
     HEAD baro.rli_order_id
      ccnt = 0, reply->order_list[ii].mnemonic = baro.order_mnemonic
     HEAD bara.display
      ccnt = (ccnt+ 1), stat = alterlist(reply->order_list[ii].cntnr_list,ccnt), reply->order_list[ii
      ].cntnr_list[ccnt].container_alias_id = bara.alias_id,
      reply->order_list[ii].cntnr_list[ccnt].container_display = bara.display
     WITH nocounter
    ;end select
  ENDFOR
 ELSE
  SELECT INTO "nl:"
   FROM br_rli_container_reltn b,
    br_auto_rli_order baro,
    br_auto_rli_container barc,
    br_auto_rli_alias bara
   PLAN (b
    WHERE b.rli_order_id > 0
     AND trim(cnvtupper(b.operand))="OR"
     AND b.active_ind=1)
    JOIN (baro
    WHERE baro.rli_order_id=b.rli_order_id
     AND baro.supplier_flag=supplier_flag
     AND baro.active_ind=1)
    JOIN (barc
    WHERE barc.rli_order_id=baro.rli_order_id
     AND barc.supplier_flag=supplier_flag)
    JOIN (bara
    WHERE bara.alias_name=barc.container
     AND bara.supplier_flag=supplier_flag
     AND bara.code_set=2051)
   ORDER BY b.rli_order_id
   HEAD REPORT
    rcnt = 0
   HEAD baro.rli_order_id
    rcnt = (rcnt+ 1), ccnt = 0, stat = alterlist(reply->order_list,rcnt),
    reply->order_list[rcnt].catalog_cd = baro.rli_order_id, reply->order_list[rcnt].mnemonic = baro
    .order_mnemonic
   HEAD bara.display
    ccnt = (ccnt+ 1), stat = alterlist(reply->order_list[rcnt].cntnr_list,ccnt), reply->order_list[
    rcnt].cntnr_list[ccnt].container_alias_id = bara.alias_id,
    reply->order_list[rcnt].cntnr_list[ccnt].container_display = bara.display
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (error_flag="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSEIF (error_flag="T")
  SET reply->error_msg = concat(">> PROGRAM NAME: BED_GET_RLI_CNTNR  ",">> ERROR MESSAGE: ",error_msg
   )
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
