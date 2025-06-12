CREATE PROGRAM dcp_add_assignment:dba
 RECORD internal(
   1 assign_list[*]
     2 assign_prsnl_list[*]
       3 status = i1
 )
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET assign_to_add = size(request->assign_list,5)
 SET stat = alterlist(internal->assign_list,assign_to_add)
 SET failures = 0
 SET max_prsnl = 0
 SET total_prsnl = 0
 FOR (i = 1 TO assign_to_add)
   SET prsnl_to_add = size(request->assign_list[i].assign_prsnl_list,5)
   SET total_prsnl += prsnl_to_add
   IF (prsnl_to_add > max_prsnl)
    SET max_prsnl = prsnl_to_add
   ENDIF
   SET stat = alterlist(internal->assign_list[i].assign_prsnl_list,prsnl_to_add)
 ENDFOR
 IF (assign_to_add > 0
  AND max_prsnl > 0)
  INSERT  FROM task_activity_assignment taa,
    (dummyt d1  WITH seq = value(assign_to_add)),
    (dummyt d2  WITH seq = value(max_prsnl))
   SET taa.seq = 1, taa.task_activity_assign_id = seq(carenet_seq,nextval), taa.task_id = request->
    assign_list[d1.seq].task_id,
    taa.assign_prsnl_id = request->assign_list[d1.seq].assign_prsnl_list[d2.seq].assign_prsnl_id, taa
    .active_ind = 1, taa.beg_eff_dt_tm = cnvtdatetime(sysdate),
    taa.end_eff_dt_tm = cnvtdatetime("31-Dec-2100"), taa.updt_dt_tm = cnvtdatetime(sysdate), taa
    .updt_id = reqinfo->updt_id,
    taa.updt_task = reqinfo->updt_task, taa.updt_cnt = 0, taa.updt_applctx = reqinfo->updt_applctx
   PLAN (d1)
    JOIN (d2
    WHERE d2.seq <= size(request->assign_list[d1.seq].assign_prsnl_list,5))
    JOIN (taa)
   WITH nocounter, status(internal->assign_list[d1.seq].assign_prsnl_list[d2.seq].status)
  ;end insert
 ENDIF
 IF (curqual != total_prsnl)
  FOR (x = 1 TO assign_to_add)
   SET prsnl_to_add = size(request->assign_list[x].assign_prsnl_list,5)
   FOR (y = 1 TO prsnl_to_add)
     IF ((internal->assign_list[x].assign_prsnl_list[y].status=0))
      SET failures += 1
      IF (failures > 0)
       SET stat = alterlist(reply->task_list,failures)
      ENDIF
      SET reply->task_list[failures].task_id = request->assign_list[x].task_id
      SET reply->task_list[failures].assign_prsnl_id = request->assign_list[x].assign_prsnl_list[y].
      assign_prsnl_id
     ENDIF
   ENDFOR
  ENDFOR
 ENDIF
 IF (failures=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSEIF (failures != total_prsnl)
  SET reply->status_data.status = "P"
  SET reqinfo->commit_ind = 1
 ENDIF
#exit_script
END GO
