CREATE PROGRAM dm_rename_column:dba
 SET object_number = 0.0
 SET column_number = 0.0
 SET table_name =  $1
 SET old_column_name =  $2
 SET new_column_name =  $3
 SET rstring = fillstring(100," ")
 SELECT INTO "NL:"
  so.obj#, sc.col#
  FROM (sys.col$ sc),
   (sys.obj$ so),
   all_users au
  WHERE so.name=table_name
   AND sc.name=old_column_name
   AND so.obj#=sc.obj#
   AND au.user_id=so.owner#
   AND au.username=currdbuser
  DETAIL
   object_number = so.obj#, column_number = sc.col#
  WITH nocounter
 ;end select
 IF (curqual > 0)
  UPDATE  FROM (sys.col$ sc)
   SET sc.name = new_column_name
   WHERE sc.obj#=object_number
    AND sc.col#=column_number
   WITH nocounter
  ;end update
  COMMIT
  RDB alter system flush shared_pool
  END ;Rdb
 ENDIF
END GO
