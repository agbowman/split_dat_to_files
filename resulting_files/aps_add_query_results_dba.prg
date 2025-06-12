CREATE PROGRAM aps_add_query_results:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET nbr_results_to_insert = cnvtint(size(request->qual,5))
 INSERT  FROM ap_query_result aqr,
   (dummyt d  WITH seq = value(nbr_results_to_insert))
  SET aqr.query_result_id = seq(pathnet_seq,nextval), aqr.case_query_id = request->case_query_id, aqr
   .accession_nbr = request->qual[d.seq].accession_nbr,
   aqr.updt_dt_tm = cnvtdatetime(curdate,curtime3), aqr.updt_id = reqinfo->updt_id, aqr.updt_task =
   reqinfo->updt_task,
   aqr.updt_applctx = reqinfo->updt_applctx, aqr.updt_cnt = 0
  PLAN (d)
   JOIN (aqr
   WHERE 1=0)
  WITH nocounter, outerjoin = d, dontexist
 ;end insert
 IF (curqual != nbr_results_to_insert)
  SET stat = alter(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "Insert"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_QUERY_RESULT"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
