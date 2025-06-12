CREATE PROGRAM dcp_ens_favorite:dba
 SET modify = predeclare
 RECORD reply(
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
 SET reply->status_data.status = "F"
 DECLARE tmp_graph_reltn_id = f8 WITH noconstant(0.0)
 DECLARE failed = c1 WITH noconstant("F")
 DECLARE system_ind = i2 WITH noconstant(0)
 DECLARE err_msg = vc
 IF ((request->ensure_type="DEL"))
  SELECT INTO "nl:"
   pgr.pred_graph_inst_id
   FROM pred_graph_reltn pgr
   WHERE (pgr.pred_graph_inst_id=request->pred_graph_inst_id)
   WITH nocounter, forupdate(pgr)
  ;end select
  IF (curqual=0)
   SET err_msg = "unable to lock pred_graph_reltn row for update"
   SET failed = "T"
   CALL log_status("LOCK","F","PRED_GRAPH_RELTN",err_msg)
   GO TO exit_script
  ENDIF
  UPDATE  FROM pred_graph_reltn pgr
   SET pgr.active_ind = 0, pgr.active_status_cd = reqdata->active_status_cd, pgr.active_status_dt_tm
     = cnvtdatetime(curdate,curtime3),
    pgr.active_status_prsnl_id = reqinfo->updt_id, pgr.end_effective_dt_tm = cnvtdatetime(curdate,
     curtime3), pgr.updt_applctx = reqinfo->updt_applctx,
    pgr.updt_cnt = (pgr.updt_cnt+ 1), pgr.updt_dt_tm = cnvtdatetime(curdate,curtime3), pgr.updt_id =
    reqinfo->updt_id,
    pgr.updt_task = reqinfo->updt_task
   WHERE (pgr.pred_graph_inst_id=request->pred_graph_inst_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET err_msg = "unable to update pred_graph_reltn table"
   SET failed = "T"
   CALL log_status("UPDATE","F","PRED_GRAPH_RELTN",err_msg)
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   FROM pred_graph pg
   WHERE (pg.pred_graph_inst_id=request->pred_graph_inst_id)
   DETAIL
    IF (pg.owner_identifier > 0)
     system_ind = 0
    ELSE
     system_ind = 1
    ENDIF
   WITH nocounter
  ;end select
  IF (system_ind=0)
   SELECT INTO "nl:"
    pg.pred_graph_inst_id
    FROM pred_graph pg
    WHERE (pg.pred_graph_inst_id=request->pred_graph_inst_id)
    WITH nocounter, forupdate(pg)
   ;end select
   IF (curqual=0)
    SET err_msg = "unable to lock pred_graph row for update"
    SET failed = "T"
    CALL log_status("LOCK","F","PRED_GRAPH",err_msg)
    GO TO exit_script
   ENDIF
   UPDATE  FROM pred_graph pg
    SET pg.active_ind = 0, pg.active_status_cd = reqdata->active_status_cd, pg.active_status_dt_tm =
     cnvtdatetime(curdate,curtime3),
     pg.active_status_prsnl_id = reqinfo->updt_id, pg.end_effective_dt_tm = cnvtdatetime(curdate,
      curtime3), pg.updt_applctx = reqinfo->updt_applctx,
     pg.updt_cnt = (pg.updt_cnt+ 1), pg.updt_dt_tm = cnvtdatetime(curdate,curtime3), pg.updt_id =
     reqinfo->updt_id,
     pg.updt_task = reqinfo->updt_task
    WHERE (pg.pred_graph_inst_id=request->pred_graph_inst_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET err_msg = "unable to update pred_graph table"
    SET failed = "T"
    CALL log_status("UPDATE","F","PRED_GRAPH",err_msg)
    GO TO exit_script
   ENDIF
  ENDIF
 ELSEIF ((request->ensure_type="INS"))
  INSERT  FROM pred_graph_reltn pgr
   SET pgr.pred_graph_reltn_id = seq(carenet_seq,nextval), pgr.active_ind = 1, pgr.active_status_cd
     = reqdata->active_status_cd,
    pgr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), pgr.active_status_prsnl_id = reqinfo->
    updt_id, pgr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
    pgr.end_effective_dt_tm = cnvtdatetime("31-Dec-2100"), pgr.parent_entity_id = reqinfo->updt_id,
    pgr.parent_entity_name = "PRSNL",
    pgr.pred_graph_inst_id = request->pred_graph_inst_id, pgr.updt_applctx = reqinfo->updt_applctx,
    pgr.updt_cnt = 0,
    pgr.updt_dt_tm = cnvtdatetime(curdate,curtime3), pgr.updt_id = reqinfo->updt_id, pgr.updt_task =
    reqinfo->updt_task
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET err_msg = "unable to insert favorite into pred_graph_reltn table"
   SET failed = "T"
   CALL log_status("INSERT","F","PRED_GRAPH_RELTN",err_msg)
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
