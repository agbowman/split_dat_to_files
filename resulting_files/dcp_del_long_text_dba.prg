CREATE PROGRAM dcp_del_long_text:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 DECLARE parent_entity_id = f8 WITH noconstant(0.0)
 DECLARE parent_entity_name = vc
 DECLARE text_type_cd = f8 WITH noconstant(0.0)
 DECLARE refr_text_id = f8 WITH noconstant(0.0)
 DECLARE long_blob_id = f8 WITH noconstant(0.0)
 SET failed = "F"
 SET reply->status_data.status = "F"
 DELETE  FROM long_text lt
  WHERE (lt.long_text_id=request->long_text_id)
  WITH nocounter
 ;end delete
 SELECT INTO "nl:"
  FROM ref_text_reltn rtl
  WHERE (rtl.refr_text_id=request->refr_text_id)
  DETAIL
   parent_entity_name = rtl.parent_entity_name, parent_entity_id = rtl.parent_entity_id, text_type_cd
    = rtl.text_type_cd
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM ref_text_reltn rtl
  WHERE rtl.parent_entity_name=parent_entity_name
   AND rtl.parent_entity_id=parent_entity_id
   AND rtl.text_type_cd=text_type_cd
   AND (rtl.refr_text_id != request->refr_text_id)
  DETAIL
   refr_text_id = rtl.refr_text_id
  WITH nocounter
 ;end select
 IF (refr_text_id > 0)
  SELECT
   *
   FROM ref_text rt
   WHERE rt.refr_text_id=refr_text_id
    AND rt.text_entity_name="LONG_BLOB"
   DETAIL
    long_blob_id = rt.text_entity_id
   WITH nocounter
  ;end select
 ENDIF
 IF (long_blob_id > 0)
  DELETE  FROM long_blob lb
   WHERE lb.long_blob_id=long_blob_id
   WITH nocounter
  ;end delete
 ENDIF
 DELETE  FROM ref_text rt
  WHERE (rt.refr_text_id=request->refr_text_id)
  WITH nocounter
 ;end delete
 DELETE  FROM ref_text_reltn rtr
  WHERE (rtr.refr_text_id=request->refr_text_id)
  WITH nocounter
 ;end delete
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "dcp_del_long_text"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "delete"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "failed to delete"
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
