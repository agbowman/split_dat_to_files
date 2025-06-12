CREATE PROGRAM dcp_get_relate_cds_by_target:dba
 RECORD request(
   1 transfer_type_cd = f8
   1 target_event_cd = f8
   1 associated_identifier_cd = f8
 )
 RECORD reply(
   1 transfer_type_cd = f8
   1 qual[*]
     2 target_event_cd = f8
     2 source_event_cd = f8
     2 associated_identifier_cd = f8
   1 status_data
     2 status = c1
 )
 DECLARE idx = i4 WITH noconstant(0)
 SET reply->transfer_type_cd = request->transfer_type_cd
 SET reply->status_data.status = "F"
 SELECT DISTINCT INTO "nl:"
  r.target_event_cd, r.source_event_cd
  FROM dcp_cf_trans_event_cd_r r
  WHERE (r.cf_transfer_type_cd=request->transfer_type_cd)
   AND (r.target_event_cd=request->target_event_cd)
   AND r.active_ind=1
  DETAIL
   idx = (idx+ 1)
   IF (mod(idx,5)=1)
    stat = alterlist(reply->qual,(idx+ 4))
   ENDIF
   reply->qual[idx].source_event_cd = r.source_event_cd, reply->qual[idx].target_event_cd = r
   .target_event_cd
  FOOT REPORT
   stat = alterlist(reply->qual,idx)
  WITH nocounter
 ;end select
 IF (idx=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(request)
 CALL echorecord(reply)
END GO
