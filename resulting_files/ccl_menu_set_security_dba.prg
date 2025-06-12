CREATE PROGRAM ccl_menu_set_security:dba
 SET failed = "F"
 SET addnum = size(request->app_groups,5)
 IF ((request->menu_id_f8=0))
  SET request->menu_id_f8 = request->menu_id
 ENDIF
 DELETE  FROM explorer_menu_security e
  WHERE (e.menu_id=request->menu_id_f8)
  WITH nocounter
 ;end delete
 SET num_recs_deleted = curqual
 IF ((request->app_groups[1].app_group_cd_f8=0))
  SET request->app_groups[1].app_group_cd_f8 = request->app_groups[1].app_group_cd
 ENDIF
 IF ((request->app_groups[1].app_group_cd_f8 > 0))
  INSERT  FROM explorer_menu_security e,
    (dummyt d  WITH seq = value(addnum))
   SET e.menu_id = request->menu_id_f8, e.app_group_cd = request->app_groups[d.seq].app_group_cd_f8,
    e.updt_dt_tm = cnvtdatetime(sysdate),
    e.updt_id = reqinfo->updt_id, e.updt_task = reqinfo->updt_task, e.updt_applctx = reqinfo->
    updt_applctx,
    e.updt_cnt = 0
   PLAN (d)
    JOIN (e)
   WITH nocounter
  ;end insert
 ENDIF
 IF ((request->app_groups[1].app_group_cd_f8=0)
  AND num_recs_deleted > 0)
  SET failed = "F"
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
