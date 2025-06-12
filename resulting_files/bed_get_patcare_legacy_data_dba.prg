CREATE PROGRAM bed_get_patcare_legacy_data:dba
 FREE SET reply
 RECORD reply(
   1 orderables[*]
     2 id = f8
     2 short_desc = vc
     2 long_desc = vc
     2 facility = vc
     2 remove_ind = i2
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
 SET dcnt = 0
 SET dcnt = size(request->departments,5)
 IF (dcnt=0)
  GO TO exit_script
 ENDIF
 DECLARE br_string = vc
 SET br_string = " b.match_orderable_cd = 0"
 IF ((request->include_remove_ind=0))
  SET br_string = concat(br_string," and b.status_ind != 3")
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(dcnt)),
   br_oc_work b
  PLAN (d)
   JOIN (b
   WHERE (b.catalog_type=request->departments[d.seq].name)
    AND parser(br_string))
  ORDER BY b.short_desc
  HEAD b.oc_id
   cnt = (cnt+ 1), stat = alterlist(reply->orderables,cnt), reply->orderables[cnt].id = b.oc_id,
   reply->orderables[cnt].short_desc = b.short_desc, reply->orderables[cnt].long_desc = b.long_desc,
   reply->orderables[cnt].facility = b.facility
   IF (b.status_ind=3)
    reply->orderables[cnt].remove_ind = 1
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
