CREATE PROGRAM bsc_get_ingred_event_codes:dba
 SET modify = predeclare
 RECORD reply(
   1 order_list[*]
     2 order_id = f8
     2 med_order_type_cd = f8
     2 catalog_type_cd = f8
     2 ingred_list[*]
       3 synonym_id = f8
       3 catalog_cd = f8
       3 event_cd = f8
       3 ingredient_type_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE ocnt = i4 WITH protect, noconstant(0)
 DECLARE icnt = i4 WITH protect, noconstant(0)
 DECLARE nbr_to_get = i4 WITH protect, noconstant(size(request->order_list,5))
 DECLARE last_mod = c12 WITH private, noconstant(fillstring(12," "))
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  o.order_id, oi.order_id, oi.comp_sequence
  FROM (dummyt d  WITH seq = value(nbr_to_get)),
   order_ingredient oi,
   orders o,
   code_value_event_r cver
  PLAN (d)
   JOIN (o
   WHERE (o.order_id=request->order_list[d.seq].order_id))
   JOIN (oi
   WHERE (oi.order_id=request->order_list[d.seq].order_id)
    AND oi.action_sequence=o.last_ingred_action_sequence)
   JOIN (cver
   WHERE cver.parent_cd=outerjoin(oi.catalog_cd))
  ORDER BY oi.order_id, oi.comp_sequence
  HEAD REPORT
   ocnt = 0
  HEAD oi.order_id
   icnt = 0, ocnt = (ocnt+ 1)
   IF (ocnt > size(reply->order_list,5))
    stat = alterlist(reply->order_list,(ocnt+ 10))
   ENDIF
   reply->order_list[ocnt].order_id = oi.order_id, reply->order_list[ocnt].med_order_type_cd = o
   .med_order_type_cd, reply->order_list[ocnt].catalog_type_cd = o.catalog_type_cd
  HEAD oi.comp_sequence
   icnt = (icnt+ 1)
   IF (icnt > size(reply->order_list[ocnt].ingred_list,5))
    stat = alterlist(reply->order_list[ocnt].ingred_list,(icnt+ 5))
   ENDIF
   reply->order_list[ocnt].ingred_list[icnt].synonym_id = oi.synonym_id, reply->order_list[ocnt].
   ingred_list[icnt].catalog_cd = oi.catalog_cd, reply->order_list[ocnt].ingred_list[icnt].event_cd
    = cver.event_cd,
   reply->order_list[ocnt].ingred_list[icnt].ingredient_type_flag = oi.ingredient_type_flag
  FOOT  oi.order_id
   stat = alterlist(reply->order_list[ocnt].ingred_list,icnt)
  FOOT REPORT
   stat = alterlist(reply->order_list,ocnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "000 05/19/08"
 SET modify = nopredeclare
END GO
