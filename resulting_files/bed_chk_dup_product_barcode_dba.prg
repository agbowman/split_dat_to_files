CREATE PROGRAM bed_chk_dup_product_barcode:dba
 FREE SET reply
 RECORD reply(
   1 barcode = vc
   1 dup_ind = i2
   1 product_display = vc
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE barcode = vc
 DECLARE found = vc
 DECLARE product_display = vc
 DECLARE error_msg = vc
 SET error_flag = "F"
 SET reply->status_data.status = "F"
 SET found = "N"
 SET barcode = fillstring(15," ")
 SET barcode = request->barcode
 SET product_display = fillstring(30," ")
 SET reply->barcode = barcode
 SET reply->dup_ind = 0
 SELECT INTO "nl:"
  FROM product_barcode pb,
   code_value cv
  PLAN (pb
   WHERE pb.product_barcode=barcode
    AND pb.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=pb.product_cd
    AND cv.code_set=1604
    AND cv.active_ind=1)
  DETAIL
   found = "Y", product_display = cv.display
  WITH nocounter
 ;end select
 IF (found="Y")
  SET reply->dup_ind = 1
  SET reply->product_display = trim(product_display)
 ENDIF
#exit_script
 IF (error_flag="T")
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat(" >> PROGRAM NAME: BED_CHK_DUP_PRODUCT_BARCODE >> ERROR MESSAGE: ",
   error_msg)
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
