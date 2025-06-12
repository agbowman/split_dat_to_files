CREATE PROGRAM bbt_get_bb_nomenclatures:dba
 RECORD reply(
   1 qual[*]
     2 nomenclature_id = f8
     2 display = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET count1 = 0
 SET failed = "T"
 SET reply->status_data.status = "F"
 SET cv_cnt = 0
 SET source_cd = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET cdf_meaning = "BLOOD BANK"
 SET stat = uar_get_meaning_by_codeset(400,cdf_meaning,1,source_cd)
 CALL echo(source_cd)
 SELECT INTO "nl:"
  n.nomenclature_id, n.short_string
  FROM nomenclature n
  WHERE n.source_vocabulary_cd=source_cd
  ORDER BY n.short_string
  HEAD REPORT
   cv_cnt = 0, stat = alterlist(reply->qual,10)
  HEAD n.short_string
   cv_cnt = (cv_cnt+ 1)
   IF (mod(cv_cnt,10)=1
    AND cv_cnt != 1)
    stat = alterlist(reply->qual,(cv_cnt+ 9))
   ENDIF
   reply->qual[cv_cnt].nomenclature_id = n.nomenclature_id, reply->qual[cv_cnt].display = n
   .short_string
  FOOT REPORT
   stat = alterlist(reply->qual,cv_cnt), failed = "F"
  WITH nocounter
 ;end select
 SET count1 = (count1+ 1)
 IF (count1 > 1)
  SET stat = alterlist(reply->status_data.subeventstatus,count1)
 ENDIF
 SET reply->status_data.subeventstatus[count1].operationname = "Get Blood Bank Nomenclatures"
 SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_get_bb_nomenclatures"
 IF (failed="F")
  IF (size(reply->qual,5) > 0)
   SET reply->status_data.status = "S"
   SET reply->status_data.subeventstatus[count1].operationstatus = "S"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = "SUCCESS"
  ELSE
   SET reply->status_data.status = "Z"
   SET reply->status_data.subeventstatus[count1].operationstatus = "S"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = "ZERO"
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "Select on code_value/code_value_extension failed"
 ENDIF
END GO
