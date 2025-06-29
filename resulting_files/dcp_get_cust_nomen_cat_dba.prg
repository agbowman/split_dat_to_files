CREATE PROGRAM dcp_get_cust_nomen_cat:dba
 RECORD reply(
   1 cnt = i4
   1 qual[10]
     2 nomenclature_id = f8
     2 source_string = vc
     2 mnemonic = vc
     2 short_string = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "S"
 SET cnt = 0
 SELECT INTO "nl:"
  FROM dcp_nomencategorydef c,
   nomenclature n
  PLAN (c
   WHERE (c.category_id=request->category_id))
   JOIN (n
   WHERE c.nomenclature_id=n.nomenclature_id)
  ORDER BY c.sequence
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1
    AND cnt > 1)
    stat = alter(reply->qual,(cnt+ 9))
   ENDIF
   reply->qual[cnt].nomenclature_id = n.nomenclature_id, reply->qual[cnt].source_string = n
   .source_string, reply->qual[cnt].mnemonic = n.mnemonic,
   reply->qual[cnt].short_string = n.short_string
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ENDIF
 SET reply->cnt = cnt
#exit_script
 IF ((reply->status_data.status="F"))
  SET reply->status_data.subeventstatus[1].operationname = "GET"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_nomencategorydef"
 ENDIF
 SET stat = alter(reply->qual,cnt)
END GO
