CREATE PROGRAM bed_get_ocrec_unmatch_legacy:dba
 FREE SET reply
 RECORD reply(
   1 orderables[*]
     2 id = f8
     2 short_desc = vc
     2 long_desc = vc
     2 oe_format_id = f8
     2 dept_name = vc
     2 alias = vc
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
  FROM br_oc_work b
  PLAN (b
   WHERE parser(br_string)
    AND b.status_ind=0
    AND  NOT ( EXISTS (
   (SELECT
    a.code_value
    FROM code_value_alias a
    WHERE a.code_set=200
     AND (a.contributor_source_cd=request->contributor_source_code_value)
     AND ((a.alias=b.alias1) OR (a.alias=b.alias2)) ))))
  ORDER BY b.short_desc
  HEAD b.oc_id
   cnt = (cnt+ 1), stat = alterlist(reply->orderables,cnt), reply->orderables[cnt].id = b.oc_id,
   reply->orderables[cnt].short_desc = b.short_desc, reply->orderables[cnt].long_desc = b.long_desc,
   reply->orderables[cnt].oe_format_id = b.oe_format_id,
   reply->orderables[cnt].dept_name = b.dept_name
   IF (b.alias1 > " ")
    reply->orderables[cnt].alias = b.alias1
   ELSE
    reply->orderables[cnt].alias = b.alias2
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(reply)
#exit_script
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
