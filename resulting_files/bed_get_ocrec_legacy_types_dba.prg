CREATE PROGRAM bed_get_ocrec_legacy_types:dba
 FREE SET reply
 RECORD reply(
   1 catalog_types[*]
     2 display = vc
     2 activity_types[*]
       3 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET ccnt = 0
 SET acnt = 0
 DECLARE b_string = vc
 SET b_string = "(b.alias1 = a.alias or b.alias2 = a.alias)"
 IF ((request->facility > " "))
  SET b_string = concat(b_string," and b.facility = request->facility")
 ENDIF
 SELECT INTO "nl:"
  FROM code_value_alias a,
   br_oc_work b
  PLAN (a
   WHERE a.code_set=200
    AND (a.contributor_source_cd=request->contributor_source_code_value))
   JOIN (b
   WHERE parser(b_string))
  ORDER BY b.catalog_type, b.activity_type
  HEAD b.catalog_type
   acnt = 0, ccnt = (ccnt+ 1), stat = alterlist(reply->catalog_types,ccnt),
   reply->catalog_types[ccnt].display = b.catalog_type
  HEAD b.activity_type
   acnt = (acnt+ 1), stat = alterlist(reply->catalog_types[ccnt].activity_types,acnt), reply->
   catalog_types[ccnt].activity_types[acnt].display = b.activity_type
  WITH nocounter
 ;end select
 CALL echorecord(reply)
#exit_script
 IF (ccnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
