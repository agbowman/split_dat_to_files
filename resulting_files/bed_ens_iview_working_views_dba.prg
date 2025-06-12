CREATE PROGRAM bed_ens_iview_working_views:dba
 FREE SET reply
 RECORD reply(
   1 views[*]
     2 working_view_id = f8
     2 display_name = vc
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET scnt = 0
 SET icnt = 0
 SET vcnt = 0
 DECLARE active_cd = f8 WITH public, noconstant(0.0)
 DECLARE dba_cd = f8 WITH public, noconstant(0.0)
 DECLARE logerror(message=vc,details=vc) = null
 SET active_cd = uar_get_code_by("MEANING",48,"ACTIVE")
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=88
   AND c.cdf_meaning="DBA"
   AND c.active_ind=1
  HEAD REPORT
   dba_cd = c.code_value
  WITH nocounter
 ;end select
 SET vcnt = size(request->views,5)
 FOR (x = 1 TO vcnt)
   SET wv_id = 0.0
   SET stat = alterlist(reply->views,x)
   DECLARE position_code_value = f8
   SET position_code_value = dba_cd
   IF (validate(request->views[x].position_code_value))
    IF ((request->views[x].position_code_value > 0))
     SET position_code_value = request->views[x].position_code_value
    ENDIF
   ENDIF
   IF ((request->views[x].action_flag=1))
    SET version_num = 0
    IF ((request->views[x].new_version_ind > 0))
     FREE SET views
     RECORD views(
       1 qual[*]
         2 id = f8
         2 curr_work_view = f8
         2 display_name = vc
         2 position_cd = f8
         2 location_cd = f8
         2 version_num = i4
         2 beg_effective_dt_tm = dq8
         2 active_status_cd = f8
     )
     SET wcnt = 0
     SELECT INTO "nl:"
      FROM working_view w
      PLAN (w
       WHERE (w.display_name=request->views[x].display_name)
        AND w.position_cd=position_code_value)
      ORDER BY w.version_num
      DETAIL
       version_num = w.version_num, wcnt = (wcnt+ 1), stat = alterlist(views->qual,wcnt),
       views->qual[wcnt].id = w.working_view_id, views->qual[wcnt].curr_work_view = w
       .current_working_view, views->qual[wcnt].display_name = w.display_name,
       views->qual[wcnt].position_cd = w.position_cd, views->qual[wcnt].location_cd = w.location_cd,
       views->qual[wcnt].version_num = w.version_num,
       views->qual[wcnt].beg_effective_dt_tm = w.beg_effective_dt_tm, views->qual[wcnt].
       active_status_cd = w.active_status_cd
      WITH nocounter
     ;end select
     SET replacement_id = 0.0
     SELECT INTO "nl:"
      j = seq(carenet_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       replacement_id = cnvtreal(j)
      WITH format, nocounter
     ;end select
     SET existing_id = views->qual[wcnt].id
     SET ierrcode = 0
     INSERT  FROM working_view w
      SET w.working_view_id = replacement_id, w.current_working_view = existing_id, w.display_name =
       views->qual[wcnt].display_name,
       w.position_cd = views->qual[wcnt].position_cd, w.location_cd = views->qual[wcnt].location_cd,
       w.version_num = views->qual[wcnt].version_num,
       w.beg_effective_dt_tm = cnvtdatetime(views->qual[wcnt].beg_effective_dt_tm), w
       .end_effective_dt_tm = cnvtdatetime(curdate,curtime), w.active_ind = 0,
       w.active_status_dt_tm = cnvtdatetime(curdate,curtime), w.active_status_prsnl_id = reqinfo->
       updt_id, w.active_status_cd = views->qual[wcnt].active_status_cd,
       w.updt_id = reqinfo->updt_id, w.updt_dt_tm = cnvtdatetime(curdate,curtime), w.updt_task =
       reqinfo->updt_task,
       w.updt_applctx = reqinfo->updt_applctx, w.updt_cnt = 0
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      CALL logerror("Error on WV insert",serrmsg)
     ENDIF
     SET ierrcode = 0
     UPDATE  FROM working_view_section ws
      SET ws.working_view_id = replacement_id, ws.updt_id = reqinfo->updt_id, ws.updt_dt_tm =
       cnvtdatetime(curdate,curtime),
       ws.updt_task = reqinfo->updt_task, ws.updt_applctx = reqinfo->updt_applctx, ws.updt_cnt = (ws
       .updt_cnt+ 1)
      WHERE (ws.working_view_id=views->qual[wcnt].id)
      WITH nocounter
     ;end update
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      CALL logerror("Error on WVS update",serrmsg)
     ENDIF
     SET ierrcode = 0
     DELETE  FROM working_view w
      WHERE (w.working_view_id=views->qual[wcnt].id)
       AND (w.current_working_view=views->qual[wcnt].curr_work_view)
      WITH nocounter
     ;end delete
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      CALL logerror("Error on WV delete",serrmsg)
     ENDIF
     FOR (w = 1 TO (wcnt - 1))
       SET ierrcode = 0
       UPDATE  FROM working_view w
        SET w.current_working_view = views->qual[wcnt].id, w.active_status_dt_tm = cnvtdatetime(
          curdate,curtime), w.active_status_prsnl_id = reqinfo->updt_id,
         w.updt_id = reqinfo->updt_id, w.updt_dt_tm = cnvtdatetime(curdate,curtime), w.updt_task =
         reqinfo->updt_task,
         w.updt_applctx = reqinfo->updt_applctx, w.updt_cnt = (w.updt_cnt+ 1)
        WHERE (w.working_view_id=views->qual[w].id)
        WITH nocounter
       ;end update
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        CALL logerror("Error on WV update",serrmsg)
       ENDIF
     ENDFOR
    ENDIF
    IF ((request->views[x].new_version_ind=0))
     SELECT INTO "nl:"
      j = seq(carenet_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       wv_id = cnvtreal(j)
      WITH format, nocounter
     ;end select
    ELSE
     SET wv_id = existing_id
    ENDIF
    SET version_num = (version_num+ 1)
    SET ierrcode = 0
    INSERT  FROM working_view w
     SET w.working_view_id = wv_id, w.current_working_view = 0, w.display_name = request->views[x].
      display_name,
      w.position_cd = position_code_value, w.location_cd = 0, w.version_num = version_num,
      w.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), w.end_effective_dt_tm = cnvtdatetime(
       "31-DEC-2100"), w.active_ind = 1,
      w.active_status_dt_tm = cnvtdatetime(curdate,curtime), w.active_status_prsnl_id = reqinfo->
      updt_id, w.active_status_cd = active_cd,
      w.updt_id = reqinfo->updt_id, w.updt_dt_tm = cnvtdatetime(curdate,curtime), w.updt_task =
      reqinfo->updt_task,
      w.updt_applctx = reqinfo->updt_applctx, w.updt_cnt = 0
     PLAN (w)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL logerror("Error on WV insert2",serrmsg)
    ENDIF
    SET scnt = size(request->views[x].sections,5)
    FOR (y = 1 TO scnt)
      SET wvs_id = 0.0
      SELECT INTO "nl:"
       j = seq(carenet_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        wvs_id = cnvtreal(j)
       WITH format, counter
      ;end select
      SET ierrcode = 0
      INSERT  FROM working_view_section w
       SET w.working_view_section_id = wvs_id, w.working_view_id = wv_id, w.event_set_name = request
        ->views[x].sections[y].event_set_name,
        w.required_ind = request->views[x].sections[y].required_ind, w.included_ind = request->views[
        x].sections[y].included_ind, w.falloff_view_minutes = 0,
        w.updt_id = reqinfo->updt_id, w.updt_dt_tm = cnvtdatetime(curdate,curtime), w.updt_task =
        reqinfo->updt_task,
        w.updt_applctx = reqinfo->updt_applctx, w.updt_cnt = 0, w.section_type_flag = request->views[
        x].sections[y].section_type_flag,
        w.display_name = request->views[x].sections[y].display_name
       PLAN (w)
       WITH nocounter
      ;end insert
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       CALL logerror("Error on WVS insert2",serrmsg)
      ENDIF
      SET icnt = size(request->views[x].sections[y].items,5)
      IF (icnt > 0)
       IF (validate(request->views[x].sections[y].items[1].falloff_view_minutes))
        SET ierrcode = 0
        INSERT  FROM working_view_item w,
          (dummyt d  WITH seq = value(icnt))
         SET w.working_view_item_id = seq(carenet_seq,nextval), w.working_view_section_id = wvs_id, w
          .primitive_event_set_name = request->views[x].sections[y].items[d.seq].event_set_name,
          w.parent_event_set_name =
          IF ((request->views[x].sections[y].items[d.seq].parent_event_set_name > " ")) request->
           views[x].sections[y].items[d.seq].parent_event_set_name
          ELSE request->views[x].sections[y].event_set_name
          ENDIF
          , w.included_ind = request->views[x].sections[y].items[d.seq].included_ind, w.updt_id =
          reqinfo->updt_id,
          w.updt_dt_tm = cnvtdatetime(curdate,curtime), w.updt_task = reqinfo->updt_task, w
          .updt_applctx = reqinfo->updt_applctx,
          w.updt_cnt = 0, w.falloff_view_minutes = request->views[x].sections[y].items[d.seq].
          falloff_view_minutes
         PLAN (d)
          JOIN (w)
         WITH nocounter
        ;end insert
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         CALL logerror("Error on WVI insert",serrmsg)
        ENDIF
       ELSE
        SET ierrcode = 0
        INSERT  FROM working_view_item w,
          (dummyt d  WITH seq = value(icnt))
         SET w.working_view_item_id = seq(carenet_seq,nextval), w.working_view_section_id = wvs_id, w
          .primitive_event_set_name = request->views[x].sections[y].items[d.seq].event_set_name,
          w.parent_event_set_name =
          IF ((request->views[x].sections[y].items[d.seq].parent_event_set_name > " ")) request->
           views[x].sections[y].items[d.seq].parent_event_set_name
          ELSE request->views[x].sections[y].event_set_name
          ENDIF
          , w.included_ind = request->views[x].sections[y].items[d.seq].included_ind, w.updt_id =
          reqinfo->updt_id,
          w.updt_dt_tm = cnvtdatetime(curdate,curtime), w.updt_task = reqinfo->updt_task, w
          .updt_applctx = reqinfo->updt_applctx,
          w.updt_cnt = 0, w.falloff_view_minutes = 0
         PLAN (d)
          JOIN (w)
         WITH nocounter
        ;end insert
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         CALL logerror("Error on WVI insert2",serrmsg)
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
   ELSEIF ((request->views[x].action_flag=2))
    SET wv_id = request->views[x].working_view_id
    FREE SET sect
    RECORD sect(
      1 qual[*]
        2 id = f8
    )
    SET wcnt = 0
    SELECT INTO "nl:"
     FROM working_view_section w
     PLAN (w
      WHERE w.working_view_id=wv_id)
     DETAIL
      wcnt = (wcnt+ 1), stat = alterlist(sect->qual,wcnt), sect->qual[wcnt].id = w
      .working_view_section_id
     WITH nocounter
    ;end select
    IF (wcnt > 0)
     SET ierrcode = 0
     DELETE  FROM working_view_item w,
       (dummyt d  WITH seq = value(wcnt))
      SET w.seq = 1
      PLAN (d)
       JOIN (w
       WHERE (w.working_view_section_id=sect->qual[d.seq].id))
      WITH nocounter
     ;end delete
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      CALL logerror("Error on WVS delete",serrmsg)
     ENDIF
    ENDIF
    SET ierrcode = 0
    DELETE  FROM working_view_section w
     PLAN (w
      WHERE w.working_view_id=wv_id)
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL logerror("Error on WVS delete2",serrmsg)
    ENDIF
    SET scnt = size(request->views[x].sections,5)
    FOR (y = 1 TO scnt)
      SET wvs_id = 0.0
      SELECT INTO "nl:"
       j = seq(carenet_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        wvs_id = cnvtreal(j)
       WITH format, counter
      ;end select
      SET ierrcode = 0
      INSERT  FROM working_view_section w
       SET w.working_view_section_id = wvs_id, w.working_view_id = wv_id, w.event_set_name = request
        ->views[x].sections[y].event_set_name,
        w.required_ind = request->views[x].sections[y].required_ind, w.included_ind = request->views[
        x].sections[y].included_ind, w.falloff_view_minutes = 0,
        w.updt_id = reqinfo->updt_id, w.updt_dt_tm = cnvtdatetime(curdate,curtime), w.updt_task =
        reqinfo->updt_task,
        w.updt_applctx = reqinfo->updt_applctx, w.updt_cnt = 0, w.section_type_flag = request->views[
        x].sections[y].section_type_flag,
        w.display_name = request->views[x].sections[y].display_name
       PLAN (w)
       WITH nocounter
      ;end insert
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       CALL logerror("Error on WVS insert3",serrmsg)
      ENDIF
      SET icnt = size(request->views[x].sections[y].items,5)
      IF (icnt > 0)
       IF (validate(request->views[x].sections[y].items[1].falloff_view_minutes))
        SET ierrcode = 0
        INSERT  FROM working_view_item w,
          (dummyt d  WITH seq = value(icnt))
         SET w.working_view_item_id = seq(carenet_seq,nextval), w.working_view_section_id = wvs_id, w
          .primitive_event_set_name = request->views[x].sections[y].items[d.seq].event_set_name,
          w.parent_event_set_name =
          IF ((request->views[x].sections[y].items[d.seq].parent_event_set_name > " ")) request->
           views[x].sections[y].items[d.seq].parent_event_set_name
          ELSE request->views[x].sections[y].event_set_name
          ENDIF
          , w.included_ind = request->views[x].sections[y].items[d.seq].included_ind, w.updt_id =
          reqinfo->updt_id,
          w.updt_dt_tm = cnvtdatetime(curdate,curtime), w.updt_task = reqinfo->updt_task, w
          .updt_applctx = reqinfo->updt_applctx,
          w.updt_cnt = 0, w.falloff_view_minutes = request->views[x].sections[y].items[d.seq].
          falloff_view_minutes
         PLAN (d)
          JOIN (w)
         WITH nocounter
        ;end insert
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         CALL logerror("Error on WVI insert3",serrmsg)
        ENDIF
       ELSE
        SET ierrcode = 0
        INSERT  FROM working_view_item w,
          (dummyt d  WITH seq = value(icnt))
         SET w.working_view_item_id = seq(carenet_seq,nextval), w.working_view_section_id = wvs_id, w
          .primitive_event_set_name = request->views[x].sections[y].items[d.seq].event_set_name,
          w.parent_event_set_name =
          IF ((request->views[x].sections[y].items[d.seq].parent_event_set_name > " ")) request->
           views[x].sections[y].items[d.seq].parent_event_set_name
          ELSE request->views[x].sections[y].event_set_name
          ENDIF
          , w.included_ind = request->views[x].sections[y].items[d.seq].included_ind, w.updt_id =
          reqinfo->updt_id,
          w.updt_dt_tm = cnvtdatetime(curdate,curtime), w.updt_task = reqinfo->updt_task, w
          .updt_applctx = reqinfo->updt_applctx,
          w.updt_cnt = 0, w.falloff_view_minutes = 0
         PLAN (d)
          JOIN (w)
         WITH nocounter
        ;end insert
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         CALL logerror("Error on WVI insert4",serrmsg)
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
   ELSEIF ((request->views[x].action_flag=3))
    SET wv_id = request->views[x].working_view_id
    SET ierrcode = 0
    UPDATE  FROM working_view w
     SET w.end_effective_dt_tm = cnvtdatetime(curdate,curtime), w.active_ind = 0, w
      .active_status_dt_tm = cnvtdatetime(curdate,curtime),
      w.active_status_prsnl_id = reqinfo->updt_id, w.updt_id = reqinfo->updt_id, w.updt_dt_tm =
      cnvtdatetime(curdate,curtime),
      w.updt_task = reqinfo->updt_task, w.updt_applctx = reqinfo->updt_applctx, w.updt_cnt = (w
      .updt_cnt+ 1)
     PLAN (w
      WHERE w.working_view_id=wv_id)
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL logerror("Error on WV update2",serrmsg)
    ENDIF
   ELSEIF ((request->views[x].action_flag=4))
    SET wv_id = request->views[x].working_view_id
    SET ierrcode = 0
    UPDATE  FROM working_view w
     SET w.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), w.end_effective_dt_tm = cnvtdatetime(
       "31-DEC-2100"), w.active_ind = 1,
      w.active_status_dt_tm = cnvtdatetime(curdate,curtime), w.active_status_prsnl_id = reqinfo->
      updt_id, w.updt_id = reqinfo->updt_id,
      w.updt_dt_tm = cnvtdatetime(curdate,curtime), w.updt_task = reqinfo->updt_task, w.updt_applctx
       = reqinfo->updt_applctx,
      w.updt_cnt = (w.updt_cnt+ 1)
     PLAN (w
      WHERE w.working_view_id=wv_id)
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL logerror("Error on WV update3",serrmsg)
    ENDIF
   ELSEIF ((request->views[x].action_flag=5))
    SET version_num = 0
    FREE SET views
    RECORD views(
      1 qual[*]
        2 id = f8
        2 curr_work_view = f8
        2 display_name = vc
        2 position_cd = f8
        2 location_cd = f8
        2 version_num = i4
        2 beg_effective_dt_tm = dq8
        2 active_status_cd = f8
    )
    SET wcnt = 0
    SELECT INTO "nl:"
     FROM working_view w
     PLAN (w
      WHERE (w.display_name=request->views[x].display_name))
     ORDER BY w.version_num
     DETAIL
      version_num = w.version_num, wcnt = (wcnt+ 1), stat = alterlist(views->qual,wcnt),
      views->qual[wcnt].id = w.working_view_id, views->qual[wcnt].curr_work_view = w
      .current_working_view, views->qual[wcnt].display_name = w.display_name,
      views->qual[wcnt].position_cd = w.position_cd, views->qual[wcnt].location_cd = w.location_cd,
      views->qual[wcnt].version_num = w.version_num,
      views->qual[wcnt].beg_effective_dt_tm = w.beg_effective_dt_tm, views->qual[wcnt].
      active_status_cd = w.active_status_cd
     WITH nocounter
    ;end select
    IF (((wcnt=0) OR ((views->qual[1].version_num != 0))) )
     SET failed = "Y"
     GO TO exit_script
    ENDIF
    SET replacement_id = 0.0
    SELECT INTO "nl:"
     j = seq(carenet_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      replacement_id = cnvtreal(j)
     WITH format, nocounter
    ;end select
    SET existing_id = views->qual[wcnt].id
    SET ierrcode = 0
    INSERT  FROM working_view w
     SET w.working_view_id = replacement_id, w.current_working_view = existing_id, w.display_name =
      views->qual[wcnt].display_name,
      w.position_cd = views->qual[wcnt].position_cd, w.location_cd = views->qual[wcnt].location_cd, w
      .version_num = views->qual[wcnt].version_num,
      w.beg_effective_dt_tm = cnvtdatetime(views->qual[wcnt].beg_effective_dt_tm), w
      .end_effective_dt_tm = cnvtdatetime(curdate,curtime), w.active_ind = 0,
      w.active_status_dt_tm = cnvtdatetime(curdate,curtime), w.active_status_prsnl_id = reqinfo->
      updt_id, w.active_status_cd = views->qual[wcnt].active_status_cd,
      w.updt_id = reqinfo->updt_id, w.updt_dt_tm = cnvtdatetime(curdate,curtime), w.updt_task =
      reqinfo->updt_task,
      w.updt_applctx = reqinfo->updt_applctx, w.updt_cnt = 0
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL logerror("Error on WV insert3",serrmsg)
    ENDIF
    SET ierrcode = 0
    UPDATE  FROM working_view_section ws
     SET ws.working_view_id = replacement_id, ws.updt_id = reqinfo->updt_id, ws.updt_dt_tm =
      cnvtdatetime(curdate,curtime),
      ws.updt_task = reqinfo->updt_task, ws.updt_applctx = reqinfo->updt_applctx, ws.updt_cnt = (ws
      .updt_cnt+ 1)
     WHERE (ws.working_view_id=views->qual[wcnt].id)
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL logerror("Error on WVS update2",serrmsg)
    ENDIF
    SET ierrcode = 0
    DELETE  FROM working_view w
     WHERE (w.working_view_id=views->qual[wcnt].id)
      AND (w.current_working_view=views->qual[wcnt].curr_work_view)
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL logerror("Error on WV delete2",serrmsg)
    ENDIF
    FOR (w = 1 TO (wcnt - 1))
      SET ierrcode = 0
      UPDATE  FROM working_view w
       SET w.current_working_view = views->qual[wcnt].id, w.active_status_dt_tm = cnvtdatetime(
         curdate,curtime), w.active_status_prsnl_id = reqinfo->updt_id,
        w.updt_id = reqinfo->updt_id, w.updt_dt_tm = cnvtdatetime(curdate,curtime), w.updt_task =
        reqinfo->updt_task,
        w.updt_applctx = reqinfo->updt_applctx, w.updt_cnt = (w.updt_cnt+ 1)
       WHERE (w.working_view_id=views->qual[w].id)
       WITH nocounter
      ;end update
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       CALL logerror("Error on WV update4",serrmsg)
      ENDIF
    ENDFOR
    SET ierrcode = 0
    INSERT  FROM working_view w
     SET w.working_view_id = existing_id, w.current_working_view = 0, w.display_name = views->qual[1]
      .display_name,
      w.position_cd = views->qual[1].position_cd, w.location_cd = views->qual[1].location_cd, w
      .version_num = (version_num+ 1),
      w.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), w.end_effective_dt_tm = cnvtdatetime(
       "31-DEC-2100"), w.active_ind = 1,
      w.active_status_dt_tm = cnvtdatetime(curdate,curtime), w.active_status_prsnl_id = reqinfo->
      updt_id, w.active_status_cd = active_cd,
      w.updt_id = reqinfo->updt_id, w.updt_dt_tm = cnvtdatetime(curdate,curtime), w.updt_task =
      reqinfo->updt_task,
      w.updt_applctx = reqinfo->updt_applctx, w.updt_cnt = 0
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL logerror("Error on WV insert4",serrmsg)
    ENDIF
    SET ierrcode = 0
    UPDATE  FROM working_view_section ws
     SET ws.working_view_id = existing_id, ws.updt_id = reqinfo->updt_id, ws.updt_dt_tm =
      cnvtdatetime(curdate,curtime),
      ws.updt_task = reqinfo->updt_task, ws.updt_applctx = reqinfo->updt_applctx, ws.updt_cnt = (ws
      .updt_cnt+ 1)
     WHERE (ws.working_view_id=views->qual[1].id)
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL logerror("Error on WVS update3",serrmsg)
    ENDIF
    SET ierrcode = 0
    DELETE  FROM working_view w
     WHERE (w.working_view_id=views->qual[1].id)
      AND (w.current_working_view=views->qual[1].curr_work_view)
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL logerror("Error on WV delete3",serrmsg)
    ENDIF
    SET wv_id = existing_id
   ENDIF
   SET reply->views[x].working_view_id = wv_id
   SET reply->views[x].display_name = request->views[x].display_name
 ENDFOR
 SUBROUTINE logerror(message,details)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = message
   SET reply->status_data.subeventstatus[1].targetobjectvalue = details
   GO TO exit_script
 END ;Subroutine
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO
