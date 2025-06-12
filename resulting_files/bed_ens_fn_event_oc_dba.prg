CREATE PROGRAM bed_ens_fn_event_oc:dba
 FREE SET reply
 RECORD reply(
   1 error_message = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 SET catalog_cnt = size(request->catalog_types,5)
 SET oc_cnt = size(request->orderables,5)
 IF ((request->action_flag=2))
  UPDATE  FROM track_event t
   SET t.hide_event_ind = request->hide_ind, t.updt_dt_tm = cnvtdatetime(curdate,curtime3), t.updt_id
     = reqinfo->updt_id,
    t.updt_task = reqinfo->updt_task, t.updt_cnt = (t.updt_cnt+ 1), t.updt_applctx = reqinfo->
    updt_applctx
   WHERE (t.track_event_id=request->track_event_id)
    AND t.active_ind=1
    AND (t.tracking_group_cd=request->trk_group_code_value)
   WITH nocounter
  ;end update
 ENDIF
 FOR (x = 1 TO oc_cnt)
   IF ((request->orderables[x].action_flag=1))
    INSERT  FROM track_ord_event_reltn t
     SET t.track_group_cd = request->trk_group_code_value, t.track_event_id = request->track_event_id,
      t.cat_or_cattype_cd = request->orderables[x].code_value,
      t.association_type_cd = 0, t.updt_dt_tm = cnvtdatetime(curdate,curtime3), t.updt_id = reqinfo->
      updt_id,
      t.updt_task = reqinfo->updt_task, t.updt_cnt = 0, t.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to insert orderable = ",cnvtstring(request->orderables[x].
       code_value)," into track_ord_event_reltn table for track_event =  ",cnvtstring(request->
       track_event_id))
     GO TO exit_script
    ENDIF
    SET catalog_type_code_value = 0.0
    SELECT INTO "NL:"
     FROM order_catalog oc
     WHERE (oc.catalog_cd=request->orderables[x].code_value)
     DETAIL
      catalog_type_code_value = oc.catalog_type_cd
     WITH nocounter
    ;end select
    SELECT INTO "NL:"
     FROM track_ord_trigger t
     WHERE t.parent_cd=catalog_type_code_value
      AND (t.child_cd=request->orderables[x].code_value)
      AND (t.track_group_cd=request->trk_group_code_value)
     WITH nocouter
    ;end select
    IF (curqual=0)
     INSERT  FROM track_ord_trigger t
      SET t.parent_cd = catalog_type_code_value, t.child_cd = request->orderables[x].code_value, t
       .trigger_ind = 1,
       t.track_group_cd = request->trk_group_code_value, t.updt_dt_tm = cnvtdatetime(curdate,curtime3
        ), t.updt_id = reqinfo->updt_id,
       t.updt_task = reqinfo->updt_task, t.updt_cnt = 0, t.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Unable to insert orderable = ",cnvtstring(request->orderables[x].
        code_value)," into track_ord_trigger table for parent =  ",cnvtstring(catalog_type_code_value
        ))
      GO TO exit_script
     ENDIF
    ENDIF
   ELSEIF ((request->orderables[x].action_flag=3))
    DELETE  FROM track_ord_event_reltn t
     WHERE (t.track_group_cd=request->trk_group_code_value)
      AND (t.track_event_id=request->track_event_id)
      AND (t.cat_or_cattype_cd=request->orderables[x].code_value)
      AND t.association_type_cd=0
     WITH nocounter
    ;end delete
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to delete orderable = ",cnvtstring(request->orderables[x].
       code_value)," from track_ord_event_reltn table for track_event =  ",cnvtstring(request->
       track_event_id))
     GO TO exit_script
    ENDIF
    SET catalog_type_code_value = 0.0
    SELECT INTO "NL:"
     FROM order_catalog oc
     WHERE (oc.catalog_cd=request->orderables[x].code_value)
     DETAIL
      catalog_type_code_value = oc.catalog_type_cd
     WITH nocounter
    ;end select
    SELECT INTO "NL:"
     FROM track_ord_event_reltn t
     WHERE (t.track_group_cd=request->trk_group_code_value)
      AND (t.cat_or_cattype_cd=request->orderables[x].code_value)
      AND t.association_type_cd=0
     WITH nocounter
    ;end select
    IF (curqual=0)
     DELETE  FROM track_ord_trigger t
      WHERE t.parent_cd=catalog_type_code_value
       AND (t.child_cd=request->orderables[x].code_value)
       AND (t.track_group_cd=request->trk_group_code_value)
      WITH nocouter
     ;end delete
    ENDIF
   ENDIF
 ENDFOR
 FOR (x = 1 TO catalog_cnt)
   IF ((request->catalog_types[x].action_flag=1))
    INSERT  FROM track_ord_event_reltn t
     SET t.track_group_cd = request->trk_group_code_value, t.track_event_id = request->track_event_id,
      t.cat_or_cattype_cd = request->catalog_types[x].code_value,
      t.association_type_cd = 0, t.updt_dt_tm = cnvtdatetime(curdate,curtime3), t.updt_id = reqinfo->
      updt_id,
      t.updt_task = reqinfo->updt_task, t.updt_cnt = 0, t.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to insert catalog type = ",cnvtstring(request->catalog_types[x].
       code_value)," into track_ord_event_reltn table for track_event =  ",cnvtstring(request->
       track_event_id))
     GO TO exit_script
    ENDIF
    SELECT INTO "NL:"
     FROM track_ord_trigger t
     WHERE t.parent_cd=0
      AND (t.child_cd=request->catalog_types[x].code_value)
      AND (t.track_group_cd=request->trk_group_code_value)
     WITH nocouter
    ;end select
    IF (curqual=0)
     INSERT  FROM track_ord_trigger t
      SET t.parent_cd = 0.0, t.child_cd = request->catalog_types[x].code_value, t.trigger_ind = 1,
       t.track_group_cd = request->trk_group_code_value, t.updt_dt_tm = cnvtdatetime(curdate,curtime3
        ), t.updt_id = reqinfo->updt_id,
       t.updt_task = reqinfo->updt_task, t.updt_cnt = 0, t.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Unable to insert catalog type = ",cnvtstring(request->catalog_types[x].
        code_value)," into track_ord_trigger table.")
      GO TO exit_script
     ENDIF
    ENDIF
   ELSEIF ((request->catalog_types[x].action_flag=3))
    DELETE  FROM track_ord_event_reltn t
     WHERE (t.track_group_cd=request->trk_group_code_value)
      AND (t.track_event_id=request->track_event_id)
      AND (t.cat_or_cattype_cd=request->catalog_types[x].code_value)
      AND t.association_type_cd=0
     WITH nocounter
    ;end delete
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to delete catalog type = ",cnvtstring(request->catalog_types[x].
       code_value)," from track_ord_event_reltn table for track_event =  ",cnvtstring(request->
       track_event_id))
     GO TO exit_script
    ENDIF
    SELECT INTO "NL:"
     FROM track_ord_event_reltn t
     WHERE (t.track_group_cd=request->trk_group_code_value)
      AND (t.cat_or_cattype_cd=request->catalog_types[x].code_value)
      AND t.association_type_cd=0
     WITH nocounter
    ;end select
    IF (curqual=0)
     DELETE  FROM track_ord_trigger t
      WHERE (t.track_group_cd=request->trk_group_code_value)
       AND (t.child_cd=request->catalog_types[x].code_value)
      WITH nocounter
     ;end delete
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  CALL echo(error_msg)
  SET reply->status_data.status = "F"
  SET reply->error_message = error_msg
 ENDIF
 CALL echorecord(reply)
END GO
