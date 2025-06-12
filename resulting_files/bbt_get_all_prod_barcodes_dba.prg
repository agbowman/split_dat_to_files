CREATE PROGRAM bbt_get_all_prod_barcodes:dba
 RECORD reply(
   1 codabarbarcodes[*]
     2 barcode = c15
     2 code_value_cd = f8
     2 code_value_disp = vc
     2 code_value_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET serrormsg = fillstring(255," ")
 SET nerrorstatus = error(serrormsg,1)
 SELECT INTO "nl:"
  pb.product_barcode, pb.active_ind, pb.product_cd
  FROM product_barcode pb
  WHERE pb.product_barcode_id > 0.0
   AND pb.active_ind=1
  HEAD REPORT
   codabar_cnt = 0, stat = alterlist(reply->codabarbarcodes,10)
  DETAIL
   codabar_cnt = (codabar_cnt+ 1)
   IF (mod(codabar_cnt,10)=1
    AND codabar_cnt != 1)
    stat = alterlist(reply->codabarbarcodes,(codabar_cnt+ 9))
   ENDIF
   reply->codabarbarcodes[codabar_cnt].barcode = pb.product_barcode, reply->codabarbarcodes[
   codabar_cnt].code_value_cd = pb.product_cd
  FOOT REPORT
   stat = alterlist(reply->codabarbarcodes,codabar_cnt)
  WITH nocounter
 ;end select
 SET nerrorstatus = error(serrormsg,0)
 IF (nerrorstatus=0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_get_all_prod_barcodes"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "select from product_barcode"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
 ENDIF
END GO
