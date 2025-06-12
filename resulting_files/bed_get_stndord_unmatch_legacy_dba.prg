CREATE PROGRAM bed_get_stndord_unmatch_legacy:dba
 FREE SET reply
 RECORD reply(
   1 orderables[*]
     2 id = f8
     2 short_desc = vc
     2 long_desc = vc
     2 facility = vc
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
 SELECT INTO "nl:"
  FROM br_oc_work b
  PLAN (b
   WHERE (b.catalog_type=request->department_name)
    AND b.status_ind=0)
  ORDER BY b.short_desc
  HEAD b.oc_id
   cnt = (cnt+ 1), stat = alterlist(reply->orderables,cnt), reply->orderables[cnt].id = b.oc_id,
   reply->orderables[cnt].short_desc = b.short_desc, reply->orderables[cnt].long_desc = b.long_desc,
   reply->orderables[cnt].facility = b.facility
  WITH nocounter
 ;end select
 CALL echorecord(reply)
#exit_script
 SET reply->status_data.status = "S"
END GO
