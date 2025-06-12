CREATE PROGRAM dcp_del_all_assignments:dba
 RECORD internal(
   1 status_list[*]
     2 select_status = i1
     2 updt_status = i1
 )
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET nbr_to_chg = size(request->task_list,5)
 SET stat = alterlist(internal->status_list,nbr_to_chg)
 SET failures = 0
 IF (nbr_to_chg > 0)
  SELECT INTO "nl:"
   taa.*
   FROM task_activity_assignment taa,
    (dummyt d  WITH seq = value(nbr_to_chg))
   PLAN (d)
    JOIN (taa
    WHERE (taa.task_id=request->task_list[d.seq].task_id)
     AND taa.active_ind=1
     AND taa.beg_eff_dt_tm <= cnvtdatetime(sysdate)
     AND taa.end_eff_dt_tm > cnvtdatetime(sysdate))
   DETAIL
    IF ((taa.task_id=request->task_list[d.seq].task_id))
     internal->status_list[d.seq].select_status = 1
    ENDIF
   WITH nocounter
  ;end select
  UPDATE  FROM task_activity_assignment taa,
    (dummyt d  WITH seq = value(nbr_to_chg))
   SET taa.active_ind = 0, taa.end_eff_dt_tm = cnvtdatetime(sysdate), taa.updt_dt_tm = cnvtdatetime(
     sysdate),
    taa.updt_id = reqinfo->updt_id, taa.updt_task = reqinfo->updt_task, taa.updt_cnt = (taa.updt_cnt
    + 1),
    taa.updt_applctx = reqinfo->updt_applctx
   PLAN (d
    WHERE (internal->status_list[d.seq].select_status=1))
    JOIN (taa
    WHERE (taa.task_id=request->task_list[d.seq].task_id)
     AND taa.active_ind=1)
   WITH nocounter, status(internal->status_list[d.seq].updt_status)
  ;end update
 ENDIF
 IF (curqual != nbr_to_chg)
  FOR (x = 1 TO nbr_to_chg)
    IF ((internal->status_list[x].select_status=1)
     AND (internal->status_list[x].updt_status=0))
     SET failures += 1
     IF (failures > 0)
      SET stat = alterlist(reply->task_list,failures)
     ENDIF
     SET reply->task_list[failures].task_id = request->task_list[x].task_id
    ENDIF
  ENDFOR
 ENDIF
 IF (failures=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSEIF (failures != nbr_to_chg)
  SET reply->status_data.status = "P"
  SET reqinfo->commit_ind = 1
 ENDIF
#exit_script
END GO
