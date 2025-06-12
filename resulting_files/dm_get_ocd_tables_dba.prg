CREATE PROGRAM dm_get_ocd_tables:dba
 FREE SET reply
 RECORD reply(
   1 qual[*]
     2 table_name = vc
     2 feature_number = i4
   1 count = i4
 )
 SET reply->status_data.status = "F"
 SET onumber = request->ocd_number
 SET reply->count = 0
 SELECT DISTINCT INTO "nl:"
  d.table_name, d.feature_number
  FROM dm_afd_tables d
  WHERE d.alpha_feature_nbr=onumber
  ORDER BY d.table_name
  DETAIL
   reply->count = (reply->count+ 1), stat = alterlist(reply->qual,reply->count), reply->qual[reply->
   count].table_name = d.table_name,
   reply->qual[reply->count].feature_number = d.feature_number
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
END GO
