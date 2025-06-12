CREATE PROGRAM cp_get_orc_mnemonic
 RECORD reply(
   1 qual[*]
     2 synonym_id = f8
     2 mnemonic = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET x = 0
 SET synonym_cnt = size(request->qual,5)
 IF (synonym_cnt != 0)
  SELECT INTO "nl:"
   o.synonym_id, o.mnemonic
   FROM order_catalog_synonym o,
    (dummyt d1  WITH seq = value(synonym_cnt))
   PLAN (d1)
    JOIN (o
    WHERE (o.synonym_id=request->qual[d1.seq].synonym_id))
   DETAIL
    x = (x+ 1), stat = alterlist(reply->qual,x), reply->qual[x].synonym_id = o.synonym_id,
    reply->qual[x].mnemonic = o.mnemonic
   WITH nocounter
  ;end select
 ENDIF
 IF (x > 0)
  SET failed = "S"
 ELSE
  SET failed = "Z"
 ENDIF
#exit_script
 SET reply->status_data.status = failed
END GO
