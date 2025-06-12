CREATE PROGRAM bed_get_ocrec_mil_orderables:dba
 FREE SET reply
 RECORD reply(
   1 orderables[*]
     2 code_value = f8
     2 mnemonic = vc
     2 activity_type
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 subactivity_type
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 concept_cki = vc
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
 DECLARE oc_string = vc
 SET oc_string = "oc.catalog_type_cd = request->catalog_type_code_value"
 IF ((request->activity_type_code_value > 0))
  SET oc_string = concat(trim(oc_string),
   " and oc.activity_type_cd = request->activity_type_code_value")
 ENDIF
 SELECT INTO "nl:"
  FROM order_catalog oc,
   code_value c1,
   code_value c2
  PLAN (oc
   WHERE parser(oc_string)
    AND  NOT (oc.orderable_type_flag IN (2, 6))
    AND oc.active_ind=1)
   JOIN (c1
   WHERE c1.code_value=oc.activity_type_cd)
   JOIN (c2
   WHERE c2.code_value=oc.activity_subtype_cd)
  ORDER BY oc.primary_mnemonic
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->orderables,cnt), reply->orderables[cnt].code_value = oc
   .catalog_cd,
   reply->orderables[cnt].mnemonic = oc.primary_mnemonic, reply->orderables[cnt].activity_type.
   code_value = oc.activity_type_cd, reply->orderables[cnt].activity_type.display = c1.display,
   reply->orderables[cnt].activity_type.mean = c1.cdf_meaning, reply->orderables[cnt].
   subactivity_type.code_value = oc.activity_subtype_cd, reply->orderables[cnt].subactivity_type.
   display = c2.display,
   reply->orderables[cnt].subactivity_type.mean = c2.cdf_meaning, reply->orderables[cnt].concept_cki
    = oc.concept_cki
  WITH nocounter
 ;end select
 CALL echorecord(reply)
#exit_script
 IF (rcnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
