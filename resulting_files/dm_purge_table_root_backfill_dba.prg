CREATE PROGRAM dm_purge_table_root_backfill:dba
 FOR (i = 1 TO size(requestin->list_0,5))
  SELECT INTO "nl:"
   FROM dm_purge_table dpt
   WHERE dpt.template_nbr=cnvtreal(requestin->list_0[i].template_nbr)
    AND dpt.child_table=null
   WITH nocounter
  ;end select
  IF (curqual=0)
   INSERT  FROM dm_purge_table dpt
    SET dpt.template_nbr = cnvtreal(requestin->list_0[i].template_nbr), dpt.parent_table = requestin
     ->list_0[i].parent_table, dpt.schema_dt_tm =
     (SELECT
      max(dpt2.schema_dt_tm)
      FROM dm_purge_template dpt2
      WHERE dpt2.template_nbr=cnvtreal(requestin->list_0[i].template_nbr)),
     dpt.updt_task = reqinfo->updt_task, dpt.updt_id = reqinfo->updt_id, dpt.updt_applctx = reqinfo->
     updt_applctx,
     dpt.updt_dt_tm = cnvtdatetime(curdate,curtime3), dpt.updt_cnt = 0
    WITH nocounter
   ;end insert
  ELSE
   UPDATE  FROM dm_purge_table dpt
    SET dpt.template_nbr = cnvtreal(requestin->list_0[i].template_nbr), dpt.parent_table = requestin
     ->list_0[i].parent_table, dpt.schema_dt_tm =
     (SELECT
      max(dpt2.schema_dt_tm)
      FROM dm_purge_template dpt2
      WHERE dpt2.template_nbr=cnvtreal(requestin->list_0[i].template_nbr)),
     dpt.updt_task = reqinfo->updt_task, dpt.updt_id = reqinfo->updt_id, dpt.updt_applctx = reqinfo->
     updt_applctx,
     dpt.updt_dt_tm = cnvtdatetime(curdate,curtime3), dpt.updt_cnt = 0
    WHERE dpt.template_nbr=cnvtreal(requestin->list_0[i].template_nbr)
     AND dpt.child_table=null
    WITH nocounter
   ;end update
  ENDIF
 ENDFOR
END GO
