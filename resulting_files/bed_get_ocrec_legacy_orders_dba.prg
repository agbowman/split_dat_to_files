CREATE PROGRAM bed_get_ocrec_legacy_orders:dba
 FREE SET reply
 RECORD reply(
   1 orderables[*]
     2 legacy
       3 id = f8
       3 short_desc = vc
       3 long_desc = vc
       3 alias = vc
     2 millennium
       3 code_value = f8
       3 mnemonic = vc
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
 DECLARE br_string = vc
 SET br_string = "b.catalog_type = request->catalog_type"
 IF ((request->activity_type > " "))
  SET br_string = concat(br_string," and b.activity_type = request->activity_type")
 ENDIF
 IF ((request->facility > " "))
  SET br_string = concat(br_string," and b.facility = request->facility")
 ENDIF
 SELECT INTO "nl:"
  FROM br_oc_work b,
   dummyt d,
   code_value_alias a,
   order_catalog o
  PLAN (b
   WHERE parser(br_string)
    AND b.status_ind=0)
   JOIN (d)
   JOIN (a
   WHERE a.code_set=200
    AND (a.contributor_source_cd=request->contributor_source_code_value)
    AND ((a.alias=b.alias1) OR (a.alias=b.alias2)) )
   JOIN (o
   WHERE o.catalog_cd=a.code_value)
  ORDER BY b.short_desc
  HEAD b.oc_id
   cnt = (cnt+ 1), stat = alterlist(reply->orderables,cnt), reply->orderables[cnt].legacy.id = b
   .oc_id,
   reply->orderables[cnt].legacy.short_desc = b.short_desc, reply->orderables[cnt].legacy.long_desc
    = b.long_desc
   IF (b.alias1 > " ")
    reply->orderables[cnt].legacy.alias = b.alias1
   ELSE
    reply->orderables[cnt].legacy.alias = b.alias2
   ENDIF
   reply->orderables[cnt].millennium.code_value = o.catalog_cd, reply->orderables[cnt].millennium.
   mnemonic = o.primary_mnemonic, reply->orderables[cnt].millennium.concept_cki = o.concept_cki
  WITH nocounter, outerjoin = d
 ;end select
 CALL echorecord(reply)
#exit_script
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
