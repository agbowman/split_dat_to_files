CREATE PROGRAM bed_get_oc_options:dba
 FREE SET reply
 RECORD reply(
   1 oc_list[*]
     2 catalog_code_value = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE facility = vc
 SELECT INTO "NL:"
  FROM br_oc_work b
  WHERE (b.oc_id=request->legacy_oc_id)
  DETAIL
   facility = b.facility
  WITH nocounter
 ;end select
 SET oc_cnt = size(request->oc_list,5)
 SET stat = alterlist(reply->oc_list,oc_cnt)
 SET tot_cnt = 0
 IF (oc_cnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = oc_cnt),
   br_oc_work b
  PLAN (d)
   JOIN (b
   WHERE b.facility=facility
    AND (b.match_orderable_cd=request->oc_list[d.seq].catalog_code_value))
  DETAIL
   tot_cnt = (tot_cnt+ 1), reply->oc_list[tot_cnt].catalog_code_value = request->oc_list[d.seq].
   catalog_code_value
  WITH nocounter, outerjoin = d, dontexist
 ;end select
 SET stat = alterlist(reply->oc_list,tot_cnt)
#exit_script
 IF (tot_cnt=0)
  SET reply->status_data.status = "Z"
 ELSEIF (tot_cnt > 0)
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
