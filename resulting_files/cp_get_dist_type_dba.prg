CREATE PROGRAM cp_get_dist_type:dba
 RECORD reply(
   1 dischg_ind = i2
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
  cd.dist_type
  FROM chart_distribution cd
  WHERE (cd.distribution_id=request->distribution_id)
   AND cd.active_ind=1
  DETAIL
   IF (cd.dist_type IN (2, 3))
    reply->dischg_ind = 1
   ELSE
    reply->dischg_ind = 0
   ENDIF
   reply->dist_descr = cd.dist_descr
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
