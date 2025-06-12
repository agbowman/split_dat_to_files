CREATE PROGRAM bed_get_cki_matched_items:dba
 FREE SET reply
 RECORD reply(
   1 qual[*]
     2 client_catalog_cd = vc
     2 client_description = vc
     2 client_primary_mnemonic = vc
     2 client_catalog_type = vc
     2 client_activity_type = vc
     2 client_cpt4 = vc
     2 hnam_catalog_cd = vc
     2 hnam_order_name = vc
     2 hnam_cpt4 = vc
     2 concept_cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SELECT INTO "nl:"
  FROM br_cki_match b,
   br_cki_client_data d,
   br_cki_client_data_field f1,
   br_cki_client_data_field f2
  PLAN (b
   WHERE (b.client_id=request->client_id)
    AND (b.data_type_id=request->data_type_id))
   JOIN (d
   WHERE d.client_id=b.client_id
    AND d.data_type_id=b.data_type_id)
   JOIN (f1
   WHERE f1.br_cki_client_data_id=d.br_cki_client_data_id
    AND f1.field_content=b.data_item)
   JOIN (f2
   WHERE f2.br_cki_client_data_id=f1.br_cki_client_data_id)
  ORDER BY b.data_item_name
  HEAD b.data_item_name
   cnt = (cnt+ 1), stat = alterlist(reply->qual,cnt), reply->qual[cnt].client_catalog_cd = b
   .data_item,
   reply->qual[cnt].client_description = b.data_item_name, reply->qual[cnt].hnam_catalog_cd = build(b
    .millennium_value), reply->qual[cnt].hnam_order_name = b.millennium_name,
   reply->qual[cnt].concept_cki = b.concept_cki
  DETAIL
   IF (f2.field_nbr=2)
    reply->qual[cnt].client_description = b.data_item_name
   ENDIF
   IF (f2.field_nbr=3)
    reply->qual[cnt].client_primary_mnemonic = f2.field_content
   ENDIF
   IF (f2.field_nbr=4)
    reply->qual[cnt].client_catalog_type = f2.field_content
   ENDIF
   IF (f2.field_nbr=5)
    reply->qual[cnt].client_activity_type = f2.field_content
   ENDIF
   IF (f2.field_nbr=7)
    reply->qual[cnt].client_cpt4 = f2.field_content
   ENDIF
  WITH nocounter
 ;end select
 IF (cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    cmt_cross_map c
   PLAN (d)
    JOIN (c
    WHERE (c.concept_cki=reply->qual[d.seq].concept_cki)
     AND c.target_concept_cki="CPT*")
   ORDER BY d.seq
   HEAD d.seq
    reply->qual[d.seq].hnam_cpt4 = c.target_concept_cki
   WITH nocounter, skipbedrock = 1
  ;end select
 ENDIF
 CALL echorecord(reply)
#exit_script
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
