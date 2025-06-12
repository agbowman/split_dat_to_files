CREATE PROGRAM bed_get_rli_orders_by_cntnr:dba
 FREE SET reply
 RECORD reply(
   1 order_list[*]
     2 mnemonic = vc
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
 FREE SET temprec
 RECORD temprec(
   1 olist[*]
     2 catalog_cd = f8
     2 mnemonic = vc
     2 cntnr_cnt = i4
 )
 DECLARE error_flag = vc
 DECLARE error_msg = vc
 DECLARE cntnrcnt = i4
 DECLARE ordercnt = i4
 DECLARE speccnt = i4
 DECLARE repcnt = i4
 DECLARE supplier_flag = i4
 DECLARE supplier_disp = vc
 DECLARE supplier_meaning = vc
 DECLARE cntnrparse = vc
 SET reply->status_data.status = "F"
 SET error_flag = "F"
 SET cntnrcnt = 0
 SET ordercnt = 0
 SET repcnt = 0
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
 SET cntnrcnt = size(request->cntnr_list,5)
 SET cntnrparse = " barc.rli_order_id = baro.rli_order_id"
 SET cntnrparse = concat(cntnrparse," and (barc.container_alias_id = request->cntnr_list[1].cntnr_cd"
  )
 SET cntnrparse = concat(cntnrparse," or barc.container_alias_id = request->cntnr_list[2].cntnr_cd")
 IF (cntnrcnt > 2)
  SET cntnrparse = concat(cntnrparse," or barc.container_alias_id = request->cntnr_list[3].cntnr_cd")
  IF (cntnrcnt > 3)
   SET cntnrparse = concat(cntnrparse," or barc.container_alias_id = request->cntnr_list[4].cntnr_cd"
    )
   IF (cntnrcnt > 4)
    SET cntnrparse = concat(cntnrparse,
     " or barc.container_alias_id = request->cntnr_list[5].cntnr_cd")
    IF (cntnrcnt > 5)
     SET error_flag = "T"
     SET error_msg = "More than 5 containers sent - too many"
     GO TO exit_script
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 SET cntnrparse = concat(cntnrparse,") and barc.supplier_flag = supplier_flag")
 CALL echo(build("cntnrparse = ",cntnrparse))
 SELECT INTO "nl:"
  FROM br_rli_container_reltn b,
   br_auto_rli_container barc,
   br_auto_rli_order baro
  PLAN (b
   WHERE b.operand="OR"
    AND b.supplier_flag=supplier_flag)
   JOIN (baro
   WHERE baro.rli_order_id=b.rli_order_id
    AND b.supplier_flag=supplier_flag)
   JOIN (barc
   WHERE parser(cntnrparse))
  ORDER BY baro.rli_order_id, barc.container
  HEAD REPORT
   ordercnt = 0
  HEAD baro.rli_order_id
   ordercnt = (ordercnt+ 1), stat = alterlist(temprec->olist,ordercnt), temprec->olist[ordercnt].
   catalog_cd = baro.rli_order_id,
   temprec->olist[ordercnt].mnemonic = baro.order_mnemonic, temprec->olist[ordercnt].cntnr_cnt = 0
  DETAIL
   temprec->olist[ordercnt].cntnr_cnt = (temprec->olist[ordercnt].cntnr_cnt+ 1)
  WITH nocounter
 ;end select
 CALL echorecord(temprec)
 IF (ordercnt=0)
  GO TO exit_script
 ENDIF
 FOR (ii = 1 TO ordercnt)
   IF ((temprec->olist[ii].cntnr_cnt=cntnrcnt))
    SET repcnt = (repcnt+ 1)
    SET stat = alterlist(reply->order_list,repcnt)
    SET reply->order_list[repcnt].catalog_cd = temprec->olist[ii].catalog_cd
    SET reply->order_list[repcnt].mnemonic = temprec->olist[ii].mnemonic
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSEIF (error_flag="T")
  SET reply->error_msg = concat(">> PROGRAM NAME: BED_GET_RLI_ORDERS_BY_CNTNR  ",">> ERROR MESSAGE: ",
   error_msg)
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
