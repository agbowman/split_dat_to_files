CREATE PROGRAM dm_get_dependency:dba
 RECORD reply(
   1 num_dep = i4
   1 status = c1
   1 dep_list[*]
     2 seq = i4
     2 dependency_flg = i4
     2 dependency = c30
     2 dependency_ratio = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->num_dep = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  *
  FROM dm_table_dependency dtd
  WHERE (dtd.table_name=request->table_name)
  ORDER BY dtd.dm_table_dependency_seq
  DETAIL
   reply->num_dep = (reply->num_dep+ 1), stat = alterlist(reply->dep_list,reply->num_dep), reply->
   dep_list[reply->num_dep].seq = dtd.dm_table_dependency_seq,
   reply->dep_list[reply->num_dep].dependency = dtd.dependency, reply->dep_list[reply->num_dep].
   dependency_flg = dtd.dependency_flg, reply->dep_list[reply->num_dep].dependency_ratio = dtd
   .dependency_ratio
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  GO TO end_prg
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 COMMIT
#end_prg
END GO
