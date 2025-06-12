CREATE PROGRAM cr_del_dists:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DELETE  FROM chart_distribution cd,
   (dummyt d  WITH seq = value(size(request->distributions,5)))
  SET cd.seq = 1
  PLAN (d)
   JOIN (cd
   WHERE (cd.distribution_id=request->distributions[d.seq].id))
  WITH nocounter
 ;end delete
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
END GO
