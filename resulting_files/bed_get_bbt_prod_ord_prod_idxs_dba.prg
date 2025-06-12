CREATE PROGRAM bed_get_bbt_prod_ord_prod_idxs:dba
 RECORD reply(
   1 prodindex_list[*]
     2 prodindex_code_value = f8
     2 prodindex_display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE prod_idx_cnt = i4 WITH protect, noconstant(0)
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
 SELECT INTO "nl:"
  FROM prod_ord_prod_idx_r po
  PLAN (po
   WHERE (po.catalog_cd=request->order_catalog_code_value)
    AND po.active_ind=1)
  DETAIL
   prod_idx_cnt = (prod_idx_cnt+ 1), stat = alterlist(reply->prodindex_list,prod_idx_cnt), reply->
   prodindex_list[prod_idx_cnt].prodindex_code_value = po.product_cd,
   reply->prodindex_list[prod_idx_cnt].prodindex_display = uar_get_code_display(po.product_cd)
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
END GO
