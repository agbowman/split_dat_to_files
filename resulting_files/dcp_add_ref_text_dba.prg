CREATE PROGRAM dcp_add_ref_text:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE failed = c1 WITH noconstant("F")
 SET reply->status_data.status = "F"
 DECLARE ref_text_id = f8 WITH noconstant(0.0)
 DECLARE ref_text_reltn_id = f8 WITH noconstant(0.0)
 DECLARE long_text_id = f8 WITH noconstant(0.0)
 IF ((request->parent_entity_name="CHARTGUIDE"))
  SET request->parent_entity_name = "DISCRETE_TASK_ASSAY"
 ENDIF
 SELECT INTO "nl:"
  j = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   ref_text_id = cnvtreal(j)
  WITH format, nocounter
 ;end select
 SELECT INTO "nl:"
  j = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   ref_text_reltn_id = cnvtreal(j)
  WITH format, nocounter
 ;end select
 SELECT INTO "nl:"
  j = seq(long_data_seq,nextval)
  FROM dual
  DETAIL
   long_text_id = cnvtreal(j)
  WITH format, nocounter
 ;end select
 INSERT  FROM long_text lt
  SET lt.long_text_id = long_text_id, lt.parent_entity_name = "REF_TEXT", lt.parent_entity_id =
   ref_text_id,
   lt.long_text = request->text_info, lt.active_ind = 1, lt.active_status_cd = reqdata->
   active_status_cd,
   lt.active_status_prsnl_id = reqinfo->updt_id, lt.active_status_dt_tm = cnvtdatetime(curdate,
    curtime3), lt.updt_cnt = 0,
   lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt.updt_id = reqinfo->updt_id, lt.updt_applctx =
   reqinfo->updt_applctx,
   lt.updt_task = reqinfo->updt_task
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "long_text table"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "insert"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to insert into table"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 INSERT  FROM ref_text rt
  SET rt.refr_text_id = ref_text_id, rt.text_type_cd = request->text_type_cd, rt.text_entity_name =
   "LONG_TEXT",
   rt.text_entity_id = long_text_id, rt.text_type_flag = 0, rt.active_ind = 1,
   rt.updt_dt_tm = cnvtdatetime(curdate,curtime3), rt.updt_id = reqinfo->updt_id, rt.updt_task =
   reqinfo->updt_task,
   rt.updt_applctx = reqinfo->updt_applctx, rt.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "ref_text table"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "insert"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to insert into table"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 INSERT  FROM ref_text_reltn rtr
  SET rtr.ref_text_reltn_id = ref_text_reltn_id, rtr.parent_entity_name = request->parent_entity_name,
   rtr.parent_entity_id = request->parent_entity_id,
   rtr.refr_text_id = ref_text_id, rtr.text_type_cd = request->text_type_cd, rtr.updt_dt_tm =
   cnvtdatetime(curdate,curtime3),
   rtr.updt_id = reqinfo->updt_id, rtr.updt_task = reqinfo->updt_task, rtr.updt_applctx = reqinfo->
   updt_applctx,
   rtr.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "ref_text_reltn table"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "insert"
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
