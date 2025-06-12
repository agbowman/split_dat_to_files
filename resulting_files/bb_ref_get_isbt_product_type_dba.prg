CREATE PROGRAM bb_ref_get_isbt_product_type:dba
 RECORD reply(
   1 product_type_list[*]
     2 bb_isbt_product_type_id = f8
     2 product_cd = f8
     2 isbt_barcode = c15
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE ncnt = i2
 SET ncnt = 0
 SET serrormsg = fillstring(255," ")
 SET serror_check = error(serrormsg,1)
 SET stat = alterlist(reply->product_type_list,10)
 SELECT INTO "nl:"
  *
  FROM bb_isbt_product_type bipt
  PLAN (bipt
   WHERE bipt.active_ind=1)
  DETAIL
   ncnt += 1
   IF (mod(ncnt,10)=1
    AND ncnt != 1)
    stat = alterlist(reply->product_type_list,(ncnt+ 10))
   ENDIF
   reply->product_type_list[ncnt].bb_isbt_product_type_id = bipt.bb_isbt_product_type_id, reply->
   product_type_list[ncnt].product_cd = bipt.product_cd, reply->product_type_list[ncnt].isbt_barcode
    = bipt.isbt_barcode,
   reply->product_type_list[ncnt].updt_cnt = bipt.updt_cnt
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->product_type_list,ncnt)
 SET serror_check = error(serrormsg,0)
 IF (serror_check=0)
  IF (curqual > 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
 ENDIF
#exit_script
END GO
