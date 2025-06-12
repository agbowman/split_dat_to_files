CREATE PROGRAM dcp_del_assignment:dba
 RECORD internal(
   1 assign_list[*]
     2 assign_prsnl_list[*]
       3 status = i1
 )
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET assign_to_chg = size(request->assign_list,5)
 SET stat = alterlist(internal->assign_list,assign_to_chg)
 SET failures = 0
 SET max_prsnl = 0
 SET total_prsnl = 0
 FOR (i = 1 TO assign_to_chg)
   SET prsnl_to_chg = size(request->assign_list[i].assign_prsnl_list,5)
   SET total_prsnl += prsnl_to_chg
   IF (prsnl_to_chg > max_prsnl)
    SET max_prsnl = prsnl_to_chg
   ENDIF
   SET stat = alterlist(internal->assign_list[i].assign_prsnl_list,prsnl_to_chg)
 ENDFOR
 IF (assign_to_chg > 0
  AND max_prsnl > 0)
  SELECT INTO "nl:"
   taa.*
   FROM task_activity_assignment taa,
    (dummyt d1  WITH seq = value(assign_to_chg)),
    (dummyt d2  WITH seq = value(max_prsnl))
   PLAN (d1)
    JOIN (d2
    WHERE d2.seq <= size(request->assign_list[d1.seq].assign_prsnl_list,5))
    JOIN (taa
    WHERE (taa.task_id=request->assign_list[d1.seq].task_id)
     AND (taa.assign_prsnl_id=request->assign_list[d1.seq].assign_prsnl_list[d2.seq].assign_prsnl_id)
     AND taa.active_ind=1
     AND taa.beg_eff_dt_tm <= cnvtdatetime(sysdate)
     AND taa.end_eff_dt_tm > cnvtdatetime(sysdate))
   DETAIL
    IF ((taa.updt_cnt=request->assign_list[d1.seq].assign_prsnl_list[d2.seq].updt_cnt))
     internal->assign_list[d1.seq].assign_prsnl_list[d2.seq].status = 1
    ENDIF
   WITH nocounter, forupdatewait(taa)
  ;end select
  UPDATE  FROM task_activity_assignment taa,
    (dummyt d1  WITH seq = value(assign_to_chg)),
    (dummyt d2  WITH seq = value(max_prsnl))
   SET taa.active_ind = 0, taa.end_eff_dt_tm = cnvtdatetime(sysdate), taa.updt_dt_tm = cnvtdatetime(
     sysdate),
    taa.updt_id = reqinfo->updt_id, taa.updt_task = reqinfo->updt_task, taa.updt_cnt = (taa.updt_cnt
    + 1),
    taa.updt_applctx = reqinfo->updt_applctx
   PLAN (d1)
    JOIN (d2
    WHERE d2.seq <= size(request->assign_list[d1.seq].assign_prsnl_list,5)
     AND (internal->assign_list[d1.seq].assign_prsnl_list[d2.seq].status=1))
    JOIN (taa
    WHERE (taa.task_id=request->assign_list[d1.seq].task_id)
     AND (taa.assign_prsnl_id=request->assign_list[d1.seq].assign_prsnl_list[d2.seq].assign_prsnl_id)
     AND taa.active_ind=1)
   WITH nocounter, status(internal->assign_list[d1.seq].assign_prsnl_list[d2.seq].status)
  ;end update
 ENDIF
 IF (curqual != total_prsnl)
  FOR (x = 1 TO assign_to_chg)
   SET prsnl_to_chg = size(request->assign_list[x].assign_prsnl_list,5)
   FOR (y = 1 TO prsnl_to_chg)
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
