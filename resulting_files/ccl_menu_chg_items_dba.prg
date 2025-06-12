CREATE PROGRAM ccl_menu_chg_items:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ((request->menu_id_f8=0))
  SET request->menu_id_f8 = request->menu_id
 ENDIF
 IF ((request->menu_parent_id_f8=0))
  SET request->menu_parent_id_f8 = request->menu_parent_id
 ENDIF
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET errmsg = fillstring(255," ")
 UPDATE  FROM explorer_menu e
  SET e.menu_parent_id = request->menu_parent_id_f8, e.item_name = cnvtupper(request->item_name), e
   .item_desc = request->item_desc,
   e.active_ind = request->active_ind, e.updt_dt_tm = cnvtdatetime(sysdate), e.updt_id = reqinfo->
   updt_id,
   e.updt_task = reqinfo->updt_task, e.updt_applctx = reqinfo->updt_applctx, e.updt_cnt = (e.updt_cnt
   + 1),
   e.ccl_group = request->ccl_group, e.report_service_cd = request->report_service_cd
  WHERE (e.menu_id=request->menu_id_f8)
  WITH nocounter
 ;end update
 CALL echo("before set status")
 CALL echo(concat("curqual=",cnvtstring(curqual)))
 IF (curqual > 0)
  SET reply->status_data.status = "S"
  SET failed = "F"
  GO TO exit_chg_items
 ELSE
  SET errcode = error(errmsg,1)
  SET failed = "T"
  GO TO exit_chg_items
 ENDIF
#exit_chg_items
 IF (failed="T")
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "change"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ccl_menu_chg_items"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
  GO TO endit
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
  GO TO endit
 ENDIF
#endit
END GO
