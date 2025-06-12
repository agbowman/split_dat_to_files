CREATE PROGRAM bbt_get_gtin:dba
 RECORD reply(
   1 qual[*]
     2 bb_gs1_gtin_id = f8
     2 manufacturer_id = f8
     2 product_cd = f8
     2 gtin_txt = vc
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET gtin_entry_cnt = 0
 DECLARE where1 = vc
 SET where1 = "bgg.bb_gs1_gtin_id > 0.0 "
 IF (trim(request->gtin_txt) > " ")
  SET where1 = concat(where1," and bgg.gtin_txt = CNVTUPPER(request->gtin_txt)")
 ENDIF
 SELECT INTO "nl:"
  FROM bb_gs1_gtin bgg
  WHERE parser(where1)
   AND ((bgg.active_ind=1) OR ((request->return_inactive_ind > 0)))
   AND (((request->bb_gs1_gtin_id > 0.0)
   AND (bgg.bb_gs1_gtin_id=request->bb_gs1_gtin_id)) OR ((request->bb_gs1_gtin_id=0.0)))
   AND (((request->manufacturer_id > 0.0)
   AND (bgg.manufacturer_id=request->manufacturer_id)) OR ((request->manufacturer_id=0.0)))
   AND (((request->product_cd > 0.0)
   AND (bgg.product_cd=request->product_cd)) OR ((request->product_cd=0.0)))
  ORDER BY bgg.bb_gs1_gtin_id DESC
  HEAD REPORT
   gtin_entry_cnt = 0
  DETAIL
   gtin_entry_cnt += 1
   IF (mod(gtin_entry_cnt,5)=1)
    stat = alterlist(reply->qual,(gtin_entry_cnt+ 4))
   ENDIF
   reply->qual[gtin_entry_cnt].bb_gs1_gtin_id = bgg.bb_gs1_gtin_id, reply->qual[gtin_entry_cnt].
   manufacturer_id = bgg.manufacturer_id, reply->qual[gtin_entry_cnt].product_cd = bgg.product_cd,
   reply->qual[gtin_entry_cnt].gtin_txt = cnvtupper(bgg.gtin_txt), reply->qual[gtin_entry_cnt].
   active_ind = bgg.active_ind
  FOOT REPORT
   stat = alterlist(reply->qual,gtin_entry_cnt)
  WITH nocounter
 ;end select
#end_script
 IF (gtin_entry_cnt=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "NO GTIN ENTRIES"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
