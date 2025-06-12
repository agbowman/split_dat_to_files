CREATE PROGRAM bed_get_concki_mil_orders:dba
 FREE SET reply
 RECORD reply(
   1 orderables[*]
     2 code_value = f8
     2 mnemonic = vc
     2 description = vc
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
    AND o.concept_cki IN ("", " ", null)
    AND  NOT (o.orderable_type_flag IN (2, 6))
    AND o.active_ind=1)
  ORDER BY o.primary_mnemonic
  HEAD o.primary_mnemonic
   cnt = (cnt+ 1), stat = alterlist(reply->orderables,cnt), reply->orderables[cnt].code_value = o
   .catalog_cd,
   reply->orderables[cnt].mnemonic = o.primary_mnemonic, reply->orderables[cnt].description = o
   .description
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
