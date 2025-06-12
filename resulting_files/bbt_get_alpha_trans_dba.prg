CREATE PROGRAM bbt_get_alpha_trans:dba
 RECORD reply(
   1 qual[*]
     2 alpha_translation_id = f8
     2 alpha_barcode_value = c5
     2 alpha_translation_value = c5
     2 updt_cnt = i4
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
 SET count1 = 0
 SET qual_cnt = 0
 SET stat = alterlist(reply->qual,10)
 SELECT INTO "nl:"
  bba.alpha_translation_id, bba.alpha_barcode_value, bba.alpha_translation_value,
  bba.updt_cnt, bba.active_ind
  FROM bb_alpha_translation bba
  DETAIL
   qual_cnt = (qual_cnt+ 1)
   IF (mod(qual_cnt,10)=1
    AND qual_cnt != 1)
    stat = alterlist(reply->qual,(qual_cnt+ 9))
   ENDIF
   reply->qual[qual_cnt].alpha_translation_id = bba.alpha_translation_id, reply->qual[qual_cnt].
   alpha_barcode_value = bba.alpha_barcode_value, reply->qual[qual_cnt].alpha_translation_value = bba
   .alpha_translation_value,
   reply->qual[qual_cnt].updt_cnt = bba.updt_cnt, reply->qual[qual_cnt].active_ind = bba.active_ind
  FOOT REPORT
   stat = alterlist(reply->qual,qual_cnt)
  WITH nocounter
 ;end select
 SET count1 = (count1+ 1)
 IF (count1 != 1)
  SET stat = alter(reply->status_data.subeventstatus,count1)
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "select alpha_translations"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bbt_get_alpha_trans"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "No alpha translations found for the requested organization"
 ELSE
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[1].operationname = "select organizations"
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bbt_get_alpha_trans"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "SUCCESS"
 ENDIF
 FOR (x = 1 TO count1)
   CALL echo(reply->status_data.status)
   CALL echo(reply->status_data.subeventstatus[1].operationname)
   CALL echo(reply->status_data.subeventstatus[1].operationstatus)
   CALL echo(reply->status_data.subeventstatus[1].targetobjectname)
   CALL echo(reply->status_data.subeventstatus[1].targetobjectvalue)
 ENDFOR
 CALL echo("     ")
 FOR (x = 1 TO qual_cnt)
   CALL echo(build(reply->qual[x].alpha_translation_id,"/",reply->qual[x].alpha_barcode_value,"/",
     reply->qual[x].alpha_translation_value,
     "/",reply->qual[x].updt_cnt,"/",reply->qual[x].active_ind))
 ENDFOR
END GO
