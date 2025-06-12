CREATE PROGRAM bed_get_concki_rev_matches:dba
 FREE SET reply
 RECORD reply(
   1 orderables[*]
     2 millennium
       3 code_value = f8
       3 mnemonic = vc
       3 description = vc
       3 concept_cki = vc
     2 bedrock
       3 code_value = f8
       3 mnemonic = vc
       3 description = vc
       3 concept_cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 DECLARE o_string = vc
 SET o_string = build("o.catalog_type_cd = ",request->catalog_type_code_value)
 IF ((request->activity_type_code_value > 0))
  SET o_string = build(o_string," and o.activity_type_cd = ",request->activity_type_code_value)
 ENDIF
 SELECT INTO "nl:"
  FROM order_catalog o
  PLAN (o
   WHERE parser(o_string)
    AND o.concept_cki > " ")
  ORDER BY o.primary_mnemonic
  HEAD o.primary_mnemonic
   cnt = (cnt+ 1), stat = alterlist(reply->orderables,cnt), reply->orderables[cnt].millennium.
   code_value = o.catalog_cd,
   reply->orderables[cnt].millennium.mnemonic = o.primary_mnemonic, reply->orderables[cnt].millennium
   .description = o.description, reply->orderables[cnt].millennium.concept_cki = o.concept_cki
  WITH nocounter
 ;end select
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   br_auto_order_catalog c
  PLAN (d)
   JOIN (c
   WHERE (c.concept_cki=reply->orderables[d.seq].millennium.concept_cki))
  ORDER BY d.seq
  HEAD d.seq
   reply->orderables[d.seq].bedrock.code_value = c.catalog_cd, reply->orderables[d.seq].bedrock.
   mnemonic = c.primary_mnemonic, reply->orderables[d.seq].bedrock.description = c.description,
   reply->orderables[d.seq].bedrock.concept_cki = c.concept_cki
  WITH nocounter, skipbedrock = 1
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
