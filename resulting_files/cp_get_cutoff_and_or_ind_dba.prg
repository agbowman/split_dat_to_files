CREATE PROGRAM cp_get_cutoff_and_or_ind:dba
 RECORD reply(
   1 cutoff_and_or_ind = i2
   1 dist_descr = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  cd.cutoff_and_or_ind
  FROM chart_distribution cd
  WHERE (cd.distribution_id=request->distribution_id)
   AND cd.active_ind=1
  DETAIL
   reply->cutoff_and_or_ind = cd.cutoff_and_or_ind, reply->dist_descr = cd.dist_descr
  WITH nocounter
 ;end select
#exit_script
 IF (curqual=0)
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "Z"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
