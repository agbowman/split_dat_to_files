CREATE PROGRAM dcp_upd_ref_text:dba
 SET modify = predeclare
 RECORD reply(
   1 ref_text_reltn_id = f8
   1 ref_text_id = f8
   1 long_blob_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE log_status(operationname=vc,operationstatus=vc,targetobjectname=vc,targetobjectvalue=vc) =
 null
 DECLARE log_count = i4 WITH noconstant(0)
 SUBROUTINE log_status(operationname,operationstatus,targetobjectname,targetobjectvalue)
   IF ( NOT (validate(reply,0)))
    RETURN
   ENDIF
   SET log_count = size(reply->status_data.subeventstatus,5)
   IF (log_count=1)
    IF (trim(reply->status_data.subeventstatus[1].targetobjectname) > "")
     SET log_count = (log_count+ 1)
    ENDIF
   ELSE
    SET log_count = (log_count+ 1)
   ENDIF
   SET stat = alter(reply->status_data.subeventstatus,log_count)
   SET reply->status_data.subeventstatus[log_count].operationname = operationname
   SET reply->status_data.subeventstatus[log_count].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[log_count].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[log_count].targetobjectvalue = targetobjectvalue
 END ;Subroutine
 DECLARE ref_text_id = f8 WITH noconstant(0.0)
 DECLARE ref_text_reltn_id = f8 WITH noconstant(0.0)
 DECLARE long_blob_id = f8 WITH noconstant(0.0)
 DECLARE blob_id = f8 WITH noconstant(0.0)
 DECLARE failed = c1
 DECLARE err_msg = vc
 SET reply->status_data.status = "F"
 SET failed = "F"
 IF ((request->parent_entity_name="CHARTGUIDE"))
  SET request->parent_entity_name = "DISCRETE_TASK_ASSAY"
 ENDIF
 IF ((request->long_blob > ""))
  SELECT INTO "nl:"
   nextseqnum = seq(reference_seq,nextval)
   FROM dual
   DETAIL
    ref_text_id = nextseqnum
   WITH format, nocounter
  ;end select
  IF (curqual=0)
   SET err_msg = "unable to generate sequence for ref_text table"
   SET failed = "T"
   CALL log_status("SEQUENCE","F","REF_TEXT",err_msg)
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   nextseqnum = seq(long_data_seq,nextval)
   FROM dual
   DETAIL
    long_blob_id = nextseqnum
   WITH format, nocounter
  ;end select
  IF (curqual=0)
   SET err_msg = "unable to generate sequence for long_blob table"
   SET failed = "T"
   CALL log_status("SEQUENCE","F","LONG_BLOB",err_msg)
   GO TO exit_script
  ENDIF
  INSERT  FROM long_blob lb
   SET lb.long_blob = request->long_blob, lb.long_blob_id = long_blob_id, lb.parent_entity_id =
    ref_text_id,
    lb.parent_entity_name = "REF_TEXT", lb.active_ind = 1, lb.active_status_cd = reqdata->
    active_status_cd,
    lb.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lb.active_status_prsnl_id = reqinfo->
    updt_id, lb.updt_applctx = reqinfo->updt_applctx,
    lb.updt_cnt = 0, lb.updt_dt_tm = cnvtdatetime(curdate,curtime3), lb.updt_id = reqinfo->updt_id,
    lb.updt_task = reqinfo->updt_task
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET err_msg = "unable to insert reference text into long_blob table"
   SET failed = "T"
   CALL log_status("INSERT","F","LONG_BLOB",err_msg)
   GO TO exit_script
  ENDIF
 ENDIF
 IF (long_blob_id > 0)
  INSERT  FROM ref_text rt
   SET rt.refr_text_id = ref_text_id, rt.text_type_cd = request->text_type_cd, rt.text_entity_name =
    "LONG_BLOB",
    rt.text_entity_id = long_blob_id, rt.text_type_flag = 0, rt.active_ind = 1,
    rt.updt_dt_tm = cnvtdatetime(curdate,curtime3), rt.updt_id = reqinfo->updt_id, rt.updt_task =
    reqinfo->updt_task,
    rt.updt_applctx = reqinfo->updt_applctx, rt.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET err_msg = "unable to insert into ref_text table"
   SET failed = "T"
   CALL log_status("INSERT","F","REF_TEXT",err_msg)
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->ref_text_reltn_id > 0))
  SELECT INTO "nl:"
   FROM ref_text_reltn rtr1
   WHERE (rtr1.parent_entity_name=request->parent_entity_name)
    AND (rtr1.parent_entity_id=request->parent_entity_id)
    AND (rtr1.text_type_cd=request->text_type_cd)
    AND rtr1.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
   DETAIL
    request->ref_text_reltn_id = rtr1.ref_text_reltn_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   rtr.*
   FROM ref_text_reltn rtr
   WHERE (rtr.ref_text_reltn_id=request->ref_text_reltn_id)
   WITH nocounter, forupdate(rtr)
  ;end select
  IF (curqual=0)
   SET err_msg = concat("unable to lock ref_text_reltn row for update",cnvtstring(request->
     ref_text_reltn_id))
   SET failed = "T"
   CALL log_status("LOCK","F","REF_TEXT_RELTN",err_msg)
   GO TO exit_script
  ENDIF
  UPDATE  FROM ref_text_reltn rtr
   SET rtr.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), rtr.active_ind = 0, rtr.updt_cnt = (
    rtr.updt_cnt+ 1),
    rtr.updt_applctx = reqinfo->updt_applctx, rtr.updt_dt_tm = cnvtdatetime(curdate,curtime3), rtr
    .updt_id = reqinfo->updt_id,
    rtr.updt_task = reqinfo->updt_task
   WHERE (rtr.ref_text_reltn_id=request->ref_text_reltn_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET err_msg = concat("unable to update ref_text_reltn table",cnvtstring(request->ref_text_reltn_id
     ))
   SET failed = "T"
   CALL log_status("UPDATE","F","REF_TEXT_RELTN",err_msg)
   GO TO exit_script
  ENDIF
 ENDIF
 IF (ref_text_id > 0)
  SELECT INTO "nl:"
   nextseqnum = seq(reference_seq,nextval)
   FROM dual
   DETAIL
    ref_text_reltn_id = nextseqnum
   WITH format, nocounter
  ;end select
  INSERT  FROM ref_text_reltn rtr
   SET rtr.ref_text_reltn_id = ref_text_reltn_id, rtr.parent_entity_name = request->
    parent_entity_name, rtr.parent_entity_id = request->parent_entity_id,
    rtr.refr_text_id = ref_text_id, rtr.text_type_cd = request->text_type_cd, rtr.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    rtr.updt_id = reqinfo->updt_id, rtr.updt_task = reqinfo->updt_task, rtr.updt_applctx = reqinfo->
    updt_applctx,
    rtr.updt_cnt = 0, rtr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), rtr
    .end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
    rtr.active_ind = 1
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET err_msg = "unable to insert into ref_text_reltn table"
   SET failed = "T"
   CALL log_status("INSERT","F","REF_TEXT_RELTN",err_msg)
   GO TO exit_script
  ENDIF
 ENDIF
 IF (trim(request->parent_entity_name)="ORDERCATALOG")
  SELECT INTO "nl:"
   oc.*
   FROM order_catalog oc
   WHERE (oc.catalog_cd=request->parent_entity_id)
   WITH nocounter, forupdate(oc)
  ;end select
  IF (curqual=0)
   SET err_msg = concat("unable to lock order_catalog row for update",cnvtstring(request->
     parent_entity_id))
   SET failed = "T"
   CALL log_status("LOCK","F","ORDER_CATALOG",err_msg)
   GO TO exit_script
  ENDIF
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
   SET err_msg = concat("unable to update into order_catalog table",cnvtstring(request->
     parent_entity_id))
   SET failed = "T"
   CALL log_status("INSERT","F","ORDER_CATALOG",err_msg)
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   ocs.*
   FROM order_catalog ocs
   WHERE (ocs.catalog_cd=request->parent_entity_id)
   WITH nocounter, forupdate(ocs)
  ;end select
  IF (curqual=0)
   SET err_msg = concat("unable to lock order_catalog_synonym row for update",cnvtstring(request->
     parent_entity_id))
   SET failed = "T"
   CALL log_status("LOCK","F","ORDER_CATALOG_SYNONYM",err_msg)
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
   SET err_msg = concat("unable to update into order_catalog_synonym table",cnvtstring(request->
     parent_entity_id))
   SET failed = "T"
   CALL log_status("INSERT","F","ORDER_CATALOG_SYNONYM",err_msg)
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  SET reply->ref_text_reltn_id = ref_text_reltn_id
  SET reply->ref_text_id = ref_text_id
  SET reply->long_blob_id = long_blob_id
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
