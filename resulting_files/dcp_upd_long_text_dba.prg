CREATE PROGRAM dcp_upd_long_text:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET upd_cnt = 0
 SELECT INTO "nl:"
  l.long_text_id
  FROM long_text l
  WHERE (l.long_text_id=request->long_text_id)
  DETAIL
   upd_cnt = l.updt_cnt
  WITH forupdate(l)
 ;end select
 IF (((curqual=0) OR ((upd_cnt != request->long_text_upd_cnt))) )
  SET reply->status_data.subeventstatus[1].targetobjectname = "long_text"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "locking"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable update long text table"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 UPDATE  FROM long_text lt
  SET lt.long_text = request->long_text, lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_dt_tm = cnvtdatetime
   (curdate,curtime3),
   lt.updt_id = reqinfo->updt_id, lt.updt_applctx = reqinfo->updt_applctx, lt.updt_task = reqinfo->
   updt_task
  WHERE (lt.long_text_id=request->long_text_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "long_text table"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "update"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to insert into table"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 IF (trim(request->parent_entity_name)="ORDERCATALOG")
  UPDATE  FROM order_catalog oc
   SET oc.ref_text_mask = request->ref_text_mask, oc.prep_info_flag = request->prep_info_flag, oc
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    oc.updt_id = reqinfo->updt_id, oc.updt_task = reqinfo->updt_task, oc.updt_applctx = reqinfo->
    updt_applctx,
    oc.updt_cnt = (oc.updt_cnt+ 1)
   WHERE (oc.catalog_cd=request->parent_entity_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].targetobjectname = "order_catalog table"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "insert"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to insert into table"
   SET failed = "T"
   GO TO exit_script
  ENDIF
  UPDATE  FROM order_catalog_synonym ocs
   SET ocs.ref_text_mask = request->ref_text_mask, ocs.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    ocs.updt_id = reqinfo->updt_id,
    ocs.updt_task = reqinfo->updt_task, ocs.updt_applctx = reqinfo->updt_applctx, ocs.updt_cnt = (ocs
    .updt_cnt+ 1)
   WHERE (ocs.catalog_cd=request->parent_entity_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].targetobjectname = "order_catalog_synonym table"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "insert"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to insert into table"
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failed="F")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
END GO
