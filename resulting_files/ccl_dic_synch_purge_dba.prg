CREATE PROGRAM ccl_dic_synch_purge:dba
 DECLARE delcnt = i2
 SET purge_begin_dt_tm = cnvtdatetime(sysdate)
 DECLARE ccl_node = c20
 SET ccl_node = cnvtupper(logical("JOU_INSTANCE"))
 RECORD node_data(
   1 list[*]
     2 node_name = c20
     2 object_purge_days = i4
     2 backup_purge_days = i4
 )
 SELECT INTO "nl:"
  csd.node_name, csd.object_purge_days, csd.backup_purge_days
  FROM ccl_synch_data csd
  DETAIL
   delcnt += 1
   IF (mod(delcnt,10)=1)
    stat = alterlist(node_data->list,(delcnt+ 9))
   ENDIF
   node_data->list[delcnt].node_name = csd.node_name, node_data->list[delcnt].object_purge_days = csd
   .object_purge_days, node_data->list[delcnt].backup_purge_days = csd.backup_purge_days
  FOOT REPORT
   stat = alterlist(node_data->list,delcnt)
  WITH nocounter
 ;end select
 DELETE  FROM ccl_synch_cmp c
  WHERE 1=1
 ;end delete
 DELETE  FROM ccl_synch_objects cso,
   (dummyt d  WITH seq = value(delcnt))
  SET cso.seq = 1
  PLAN (d)
   JOIN (cso
   WHERE (cso.node_name=node_data->list[d.seq].node_name)
    AND cso.updt_dt_tm <= cnvtdatetime((curdate - node_data->list[d.seq].object_purge_days),curtime3)
   )
  WITH counter
 ;end delete
 IF (curqual > 0)
  COMMIT
 ENDIF
 DELETE  FROM ccl_synch_backup cso,
   (dummyt d  WITH seq = value(delcnt))
  SET cso.seq = 1
  PLAN (d)
   JOIN (cso
   WHERE (cso.node_name=node_data->list[d.seq].node_name)
    AND cso.updt_dt_tm <= cnvtdatetime((curdate - node_data->list[d.seq].backup_purge_days),curtime3)
   )
  WITH counter
 ;end delete
 IF (curqual > 0)
  COMMIT
 ENDIF
 INSERT  FROM ccl_synch_audit c
  SET c.ccl_synch_audit_id = seq(ccl_dic_synch_seq,nextval), c.node_name = ccl_node, c.operation =
   "PURGE",
   c.begin_dt_tm = cnvtdatetime(purge_begin_dt_tm), c.end_dt_tm = cnvtdatetime(sysdate), c.updt_dt_tm
    = cnvtdatetime(sysdate),
   c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->
   updt_applctx,
   c.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual > 0)
  COMMIT
 ENDIF
END GO
