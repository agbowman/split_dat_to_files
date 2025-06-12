CREATE PROGRAM ccl_menu_add_items:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 menu_id = f8
 )
 SET reply->menu_id = 0.0
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET last_id = 0.0
 SET errmsg = fillstring(255," ")
 DECLARE menu_sequence = f8
 SELECT INTO "nl:"
  ms = seq(explorer_menu_seq,nextval)
  FROM dual
  DETAIL
   menu_sequence = ms
  WITH nocounter
 ;end select
 IF ((request->menu_parent_id_f8=0))
  SET request->menu_parent_id_f8 = request->menu_parent_id
 ENDIF
 INSERT  FROM explorer_menu e
  SET e.menu_id = menu_sequence, e.item_name = cnvtupper(request->item_name), e.item_desc = request->
   item_desc,
   e.item_type = request->item_type, e.menu_parent_id = request->menu_parent_id_f8, e.active_ind =
   request->active_ind,
   e.updt_dt_tm = cnvtdatetime(sysdate), e.updt_id = reqinfo->updt_id, e.updt_task = reqinfo->
   updt_task,
   e.updt_applctx = reqinfo->updt_applctx, e.updt_cnt = 0, e.ccl_group = request->ccl_group,
   e.report_service_cd = request->report_service_cd
  WITH nocounter
 ;end insert
 IF (curqual > 0)
  SET reply->status_data.status = "S"
  SET failed = "F"
  GO TO exit_script
 ELSE
  SET errcode = error(errmsg,1)
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "add"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ccl_menu_add_items"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
  GO TO endit
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
  SET reply->menu_id = menu_sequence
  GO TO endit
 ENDIF
#endit
END GO
