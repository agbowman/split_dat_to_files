CREATE PROGRAM dcp_task_discrete_r:dba
 SET failed = "F"
 DELETE  FROM task_discrete_r tdr,
   (dummyt d  WITH seq = value(request->task_cnt))
  SET tdr.seq = 1
  PLAN (d)
   JOIN (tdr
   WHERE (tdr.reference_task_id=request->tasks[d.seq].reference_task_id))
  WITH counter
 ;end delete
 IF ((request->discrete_cnt > 0))
  FOR (x = 1 TO request->task_cnt)
    IF ((request->tasks[x].action_flag=1))
     INSERT  FROM task_discrete_r tdr,
       (dummyt d  WITH seq = value(request->discrete_cnt))
      SET tdr.reference_task_id = request->tasks[x].reference_task_id, tdr.task_assay_cd = request->
       discretes[d.seq].task_assay_cd, tdr.sequence = request->discretes[d.seq].sequence,
       tdr.required_ind = request->discretes[d.seq].required_ind, tdr.active_ind = request->
       discretes[d.seq].active_ind, tdr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       tdr.updt_id = reqinfo->updt_id, tdr.updt_task = reqinfo->updt_task, tdr.updt_cnt = 0,
       tdr.updt_applctx = reqinfo->updt_applctx
      PLAN (d)
       JOIN (tdr)
      WITH nocounter
     ;end insert
    ENDIF
  ENDFOR
 ENDIF
 UPDATE  FROM order_task_xref otr,
   (dummyt d  WITH seq = value(request->task_cnt))
  SET otr.order_task_type_flag = 2, otr.updt_cnt = (otr.updt_cnt+ 1), otr.updt_dt_tm = cnvtdatetime(
    curdate,curtime3),
   otr.updt_id = reqinfo->updt_id, otr.updt_task = reqinfo->updt_task, otr.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d)
   JOIN (otr
   WHERE (otr.reference_task_id=request->tasks[d.seq].reference_task_id))
  WITH counter
 ;end update
#exit_script
 IF (failed="F")
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
