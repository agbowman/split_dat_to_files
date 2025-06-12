CREATE PROGRAM bbt_get_product_barcodes:dba
 RECORD reply(
   1 productlist[*]
     2 product_cd = f8
     2 barcodelist[*]
       3 isbt = i2
       3 barcode = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT
  product_cd = pi.product_cd, barcode = pb.product_barcode, side = "CODA"
  FROM product_index pi,
   product_barcode pb
  PLAN (pi
   WHERE pi.active_ind=1)
   JOIN (pb
   WHERE pb.product_cd=pi.product_cd
    AND ((pb.active_ind=1) UNION (
   (SELECT
    product_cd = pi2.product_cd, barcode = isbt.isbt_barcode, side = "ISBT"
    FROM product_index pi2,
     bb_isbt_product_type isbt
    WHERE pi2.active_ind=1
     AND isbt.product_cd=pi2.product_cd
     AND isbt.active_ind=1))) )
  ORDER BY 1
  HEAD REPORT
   prodcnt = 0, stat = alterlist(reply->productlist,150)
  HEAD product_cd
   barcodecnt = 0, prodcnt = (prodcnt+ 1)
   IF (prodcnt > size(reply->productlist,5))
    stat = alterlist(reply->productlist,(prodcnt+ 50))
   ENDIF
   reply->productlist[prodcnt].product_cd = product_cd, stat = alterlist(reply->productlist[prodcnt].
    barcodelist,5)
  DETAIL
   barcodecnt = (barcodecnt+ 1)
   IF (barcodecnt > size(reply->productlist[prodcnt].barcodelist,5))
    stat = alterlist(reply->productlist[prodcnt].barcodelist,(barcodecnt+ 5))
   ENDIF
   reply->productlist[prodcnt].barcodelist[barcodecnt].barcode = barcode
   IF (side="ISBT")
    reply->productlist[prodcnt].barcodelist[barcodecnt].isbt = 1
   ELSE
    reply->productlist[prodcnt].barcodelist[barcodecnt].isbt = 0
   ENDIF
  FOOT  product_cd
   stat = alterlist(reply->productlist[prodcnt].barcodelist,barcodecnt)
  FOOT REPORT
   stat = alterlist(reply->productlist,prodcnt)
   IF (prodcnt=0)
    reply->status_data.status = "Z"
   ELSE
    reply->status_data.status = "S"
   ENDIF
  WITH rdbunion
 ;end select
#exit_script
END GO
