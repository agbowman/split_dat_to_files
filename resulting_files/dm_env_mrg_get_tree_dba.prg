CREATE PROGRAM dm_env_mrg_get_tree:dba
 RECORD reply(
   1 list[*]
     2 minor_table = c30
     2 child_table = c30
     2 level_ind = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DELETE  FROM dm_pc_temp
  WHERE 1=1
 ;end delete
 COMMIT
 SET parser_buf = fillstring(132," ")
 SET parser_buf = concat('RDB ASIS(" begin DM_TREE_LIST(',"'",trim(request->major_table),"'); end;",
  '") go')
 CALL parser(parser_buf,1)
 COMMIT
 SET cnt = 0
 SET stat = 0
 SELECT INTO "nl:"
  FROM dm_pc_temp d
  ORDER BY d.sequence
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->list,cnt), reply->list[cnt].minor_table = d.minor_table,
   reply->list[cnt].child_table = d.child_table, reply->list[cnt].level_ind = d.level_ind
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET stat = 0
END GO
