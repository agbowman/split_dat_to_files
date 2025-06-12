CREATE PROGRAM cps_get_order_name:dba
 RECORD reply(
   1 order_name = vc
   1 order_qual = i4
   1 orders[*]
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
 IF ((request->synonym_id > 0))
  SELECT INTO "NL:"
   FROM order_catalog_synonym o
   PLAN (o
    WHERE (o.synonym_id=request->synonym_id))
   DETAIL
    reply->order_name = o.mnemonic
   WITH nocounter
  ;end select
 ELSE
  SET find_order = 0
  SELECT INTO "NL:"
   FROM order_catalog o
   PLAN (o
    WHERE (o.catalog_cd=request->catalog_cd))
   DETAIL
    IF ((o.primary_mnemonic != request->hna_order_mnemonic))
     find_order = 1
    ELSE
     reply->order_name = o.primary_mnemonic
    ENDIF
   WITH nocounter
  ;end select
  IF (find_order=1)
   SET count1 = 0
   SELECT INTO "NL:"
    FROM order_catalog_synonym o
    PLAN (o
     WHERE (o.catalog_cd=request->catalog_cd))
    ORDER BY o.mnemonic
    DETAIL
     count1 = (count1+ 1)
     IF (count1 >= size(reply->orders,5))
      stat = alterlist(reply->orders,(count1+ 10))
     ENDIF
     reply->orders[count1].synonym_id = o.synonym_id, reply->orders[count1].mnemonic = o.mnemonic
    FOOT REPORT
     stat = alterlist(reply->orders,count1), reply->order_qual = count1
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF ((((reply->order_name > " ")) OR ((reply->order_qual > 0))) )
  SET reply->status_data.status = "S"
 ENDIF
END GO
