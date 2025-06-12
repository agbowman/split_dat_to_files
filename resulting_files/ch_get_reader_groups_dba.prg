CREATE PROGRAM ch_get_reader_groups:dba
 RECORD reply(
   1 qual[*]
     2 reader_group = c15
     2 dist_list[*]
       3 distribution_id = f8
       3 distribution_descr = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SELECT INTO "nl:"
  cd.reader_group
  FROM chart_distribution cd
  WHERE trim(cd.reader_group) > " "
   AND cd.active_ind=1
  ORDER BY cd.reader_group, cd.dist_descr
  HEAD REPORT
   reader_cnt = 0, dist_cnt = 0
  HEAD cd.reader_group
   reader_cnt = (reader_cnt+ 1), stat = alterlist(reply->qual,reader_cnt), reply->qual[reader_cnt].
   reader_group = cd.reader_group,
   dist_cnt = 0
  DETAIL
   dist_cnt = (dist_cnt+ 1), stat = alterlist(reply->qual[reader_cnt].dist_list,dist_cnt), reply->
   qual[reader_cnt].dist_list[dist_cnt].distribution_id = cd.distribution_id,
   reply->qual[reader_cnt].dist_list[dist_cnt].distribution_descr = cd.dist_descr
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
