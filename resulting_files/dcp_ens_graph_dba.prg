CREATE PROGRAM dcp_ens_graph:dba
 SET modify = predeclare
 RECORD reply(
   1 pred_graph_id = f8
   1 pred_graph_inst_id = f8
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
 DECLARE item_counter = i4 WITH noconstant(0)
 DECLARE prop_counter = i4 WITH noconstant(0)
 DECLARE tmp_graph_inst_id = f8 WITH noconstant(0.0)
 DECLARE tmp_graph_id = f8 WITH noconstant(0.0)
 DECLARE failed = c1 WITH noconstant("F")
 DECLARE cur_updt_cnt = i4 WITH noconstant(0)
 DECLARE items_to_add = i4 WITH noconstant(size(request->items,5))
 DECLARE prop_to_add = i4 WITH noconstant(0)
 DECLARE reltn_to_add = i4 WITH noconstant(size(request->associations,5))
 DECLARE w = i4 WITH noconstant(0)
 DECLARE j = i4 WITH noconstant(0)
 DECLARE y = i4 WITH noconstant(0)
 DECLARE z = i4 WITH noconstant(0)
 DECLARE current_graph_item_id = f8 WITH noconstant(0.0)
 DECLARE err_msg = vc
 DECLARE ownerident = f8 WITH noconstant(0.0)
 IF ((request->ensure_type="UPT"))
  SELECT INTO "nl:"
   nextseqnum = seq(carenet_seq,nextval)
   FROM dual
   DETAIL
    tmp_graph_inst_id = cnvtreal(nextseqnum)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET err_msg = "unable to generate sequence for pred_graph table"
   SET failed = "T"
   CALL log_status("SEQUENCE","F","PRED_GRAPH",err_msg)
   GO TO exit_script
  ENDIF
  IF ((request->pred_graph_inst_id=0))
   SELECT INTO "nl:"
    nextseqnum = seq(carenet_seq,nextval)
    FROM dual
    DETAIL
     tmp_graph_id = cnvtreal(nextseqnum)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET err_msg = "unable to generate sequence for pred_graph table"
    SET failed = "T"
    CALL log_status("SEQUENCE","F","PRED_GRAPH",err_msg)
    GO TO exit_script
   ENDIF
  ENDIF
 ELSE
  SET tmp_graph_inst_id = request->pred_graph_inst_id
 ENDIF
 IF ((((request->ensure_type="DEL")) OR ((request->ensure_type="UPT")
  AND (request->pred_graph_inst_id > 0))) )
  SELECT INTO "nl:"
   pg.pred_graph_inst_id
   FROM pred_graph pg
   WHERE (pg.pred_graph_inst_id=request->pred_graph_inst_id)
   DETAIL
    tmp_graph_id = pg.pred_graph_id
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
  SELECT INTO "nl:"
   pgr.pred_graph_reltn_id
   FROM pred_graph_reltn pgr
   WHERE (pgr.pred_graph_inst_id=request->pred_graph_inst_id)
   WITH nocounter, forupdate(pgr)
  ;end select
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
 ENDIF
 IF ((request->ensure_type="UPT"))
  IF ((request->system_ind=1))
   SET ownerident = 0
  ELSE
   SET ownerident = reqinfo->updt_id
  ENDIF
  INSERT  FROM pred_graph pg
   SET pg.pred_graph_inst_id = tmp_graph_inst_id, pg.active_ind = 1, pg.active_status_cd = reqdata->
    active_status_cd,
    pg.active_status_dt_tm = cnvtdatetime(curdate,curtime3), pg.active_status_prsnl_id = reqinfo->
    updt_id, pg.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
    pg.end_effective_dt_tm = cnvtdatetime("31-Dec-2100"), pg.graph_type_cd = request->
    pred_graph_type_cd, pg.pred_graph_id = tmp_graph_id,
    pg.pred_graph_name = substring(1,254,request->name), pg.owner_identifier = ownerident, pg
    .updt_applctx = reqinfo->updt_applctx,
    pg.updt_cnt = 0, pg.updt_dt_tm = cnvtdatetime(curdate,curtime3), pg.updt_id = reqinfo->updt_id,
    pg.updt_task = reqinfo->updt_task
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET err_msg = "unable to insert into pred_graph table"
   SET failed = "T"
   CALL log_status("INSERT","F","PRED_GRAPH",err_msg)
   GO TO exit_script
  ENDIF
  FOR (j = 1 TO items_to_add)
    SELECT INTO "nl:"
     nextseqnum = seq(carenet_seq,nextval)
     FROM dual
     DETAIL
      current_graph_item_id = cnvtreal(nextseqnum)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET err_msg = "unable to generate sequence for pred_graph_item table"
     SET failed = "T"
     CALL log_status("SEQUENCE","F","PRED_GRAPH_ITEM",err_msg)
     GO TO exit_script
    ENDIF
    INSERT  FROM pred_graph_item pgi
     SET pgi.pred_graph_item_id = current_graph_item_id, pgi.event_cd = request->items[j].event_cd,
      pgi.event_set_name = substring(1,39,request->items[j].event_set_name),
      pgi.pred_graph_inst_id = tmp_graph_inst_id, pgi.updt_applctx = reqinfo->updt_applctx, pgi
      .updt_cnt = 0,
      pgi.updt_dt_tm = cnvtdatetime(curdate,curtime3), pgi.updt_id = reqinfo->updt_id, pgi.updt_task
       = reqinfo->updt_task
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET err_msg = "unable to insert into pred_graph_item table"
     SET failed = "T"
     CALL log_status("INSERT","F","PRED_GRAPH_ITEM",err_msg)
     GO TO exit_script
    ENDIF
    SET prop_to_add = size(request->items[j].prop,5)
    FOR (y = 1 TO prop_to_add)
     INSERT  FROM pred_graph_item_prop pgip
      SET pgip.pred_graph_item_prop_id = seq(carenet_seq,nextval), pgip.pred_graph_item_id =
       current_graph_item_id, pgip.prop_name = substring(1,99,request->items[j].prop[y].prop_name),
       pgip.prop_value = substring(1,254,request->items[j].prop[y].prop_value), pgip.updt_applctx =
       reqinfo->updt_applctx, pgip.updt_cnt = 0,
       pgip.updt_dt_tm = cnvtdatetime(curdate,curtime3), pgip.updt_id = reqinfo->updt_id, pgip
       .updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET err_msg = "unable to insert into pred_graph_item_prop table"
      SET failed = "T"
      CALL log_status("INSERT","F","PRED_GRAPH_ITEM_PROP",err_msg)
      GO TO exit_script
     ENDIF
    ENDFOR
  ENDFOR
  FOR (z = 1 TO reltn_to_add)
   INSERT  FROM pred_graph_reltn pgr
    SET pgr.active_ind = 1, pgr.active_status_cd = reqdata->active_status_cd, pgr.active_status_dt_tm
      = cnvtdatetime(curdate,curtime3),
     pgr.active_status_prsnl_id = reqinfo->updt_id, pgr.beg_effective_dt_tm = cnvtdatetime(curdate,
      curtime3), pgr.end_effective_dt_tm = cnvtdatetime("31-Dec-2100"),
     pgr.parent_entity_id = request->associations[z].parent_entity_id, pgr.parent_entity_name =
     substring(1,29,request->associations[z].parent_entity_name), pgr.pred_graph_inst_id =
     tmp_graph_inst_id,
     pgr.pred_graph_reltn_id = seq(carenet_seq,nextval), pgr.updt_applctx = reqinfo->updt_applctx,
     pgr.updt_cnt = 0,
     pgr.updt_dt_tm = cnvtdatetime(curdate,curtime3), pgr.updt_id = reqinfo->updt_id, pgr.updt_task
      = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET err_msg = "unable to insert into pred_graph_reltn table"
    SET failed = "T"
    CALL log_status("INSERT","F","PRED_GRAPH_RELTN",err_msg)
    GO TO exit_script
   ENDIF
  ENDFOR
 ENDIF
 SET reply->pred_graph_id = tmp_graph_id
 SET reply->pred_graph_inst_id = tmp_graph_inst_id
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
