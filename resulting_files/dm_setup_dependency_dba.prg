CREATE PROGRAM dm_setup_dependency:dba
 RECORD reply(
   1 dep_list[request->num_dep]
     2 seq = i4
     2 dependency_flg = i4
     2 dependency = c30
     2 dependency_ratio = f8
     2 status = 1c
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DELETE  FROM dm_table_dependency dtd
  WHERE (dtd.table_name=request->table_name)
  WITH nocounter
 ;end delete
 COMMIT
 SET kount = 0
 FOR (kount = 1 TO request->num_dep)
   SET reply->dep_list[kount].seq = request->dep_list[kount].seq
   SET reply->dep_list[kount].dependency_flg = request->dep_list[kount].dependency_flg
   SET reply->dep_list[kount].dependency = request->dep_list[kount].dependency
   SET reply->dep_list[kount].dependency_ratio = request->dep_list[kount].dependency_ratio
   SET reply->dep_list[kount].status = "S"
   IF ((request->dep_list[kount].dependency_flg=2))
    SELECT INTO "nl:"
     dtd.dependency
     FROM dm_table_dependency dtd
     WHERE (dtd.table_name=request->dep_list[kount].dependency)
      AND (dtd.dependency=request->table_name)
     WITH nocounter
    ;end select
    IF (curqual != 0)
     SET reply->dep_list[kount].status = "Z"
    ELSE
     SELECT INTO "nl:"
      dpc.child_table
      FROM dm_parent_child dpc
      WHERE (dpc.child_table=request->dep_list[kount].dependency)
       AND (dpc.parent_table=request->table_name)
      WITH nocounter
     ;end select
     IF (curqual != 0)
      SET reply->dep_list[kount].status = "A"
     ENDIF
    ENDIF
   ENDIF
   IF ( NOT ((reply->dep_list[kount].status IN ("Z", "A"))))
    INSERT  FROM dm_table_dependency dtd
     SET dtd.dm_table_dependency_seq = request->dep_list[kount].seq, dtd.dependency = request->
      dep_list[kount].dependency, dtd.updt_applctx = reqinfo->updt_applctx,
      dtd.updt_dt_tm = cnvtdatetime(curdate,curtime3), dtd.updt_cnt = 0, dtd.updt_id = reqinfo->
      updt_id,
      dtd.updt_task = reqinfo->updt_task, dtd.dependency_flg = request->dep_list[kount].
      dependency_flg, dtd.dependency_ratio = request->dep_list[kount].dependency_ratio,
      dtd.table_name = request->table_name
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET reply->dep_list[kount].status = "F"
     GO TO end_prg
    ENDIF
   ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
 COMMIT
#end_prg
END GO
