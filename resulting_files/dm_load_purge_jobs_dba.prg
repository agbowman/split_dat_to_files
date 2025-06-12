CREATE PROGRAM dm_load_purge_jobs:dba
 RECORD reply(
   1 list[*]
     2 job_id = f8
     2 active_ind = i2
     2 description = vc
     2 parent_table = c30
     2 from_clause = vc
     2 where_clause = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET index = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  pj.job_id, pj.active_ind, pj.description,
  pj.parent_table, pj.from_clause, pj.where_clause
  FROM dm_purge_job pj
  ORDER BY pj.job_id
  DETAIL
   index = (index+ 1), stat = alterlist(reply->list,index), reply->list[index].job_id = pj.job_id,
   reply->list[index].active_ind = pj.active_ind, reply->list[index].description = pj.description,
   reply->list[index].parent_table = pj.parent_table,
   reply->list[index].from_clause = pj.from_clause, reply->list[index].where_clause = pj.where_clause
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ENDIF
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
