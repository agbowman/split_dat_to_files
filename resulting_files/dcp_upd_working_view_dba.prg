CREATE PROGRAM dcp_upd_working_view:dba
 SET modify = predeclare
 RECORD reply(
   1 working_view_id = f8
   1 version_num = i4
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
 DECLARE err_msg = vc
 DECLARE y = i4 WITH noconstant(0)
 DECLARE tmp_working_view_id = f8 WITH noconstant(0.0)
 DECLARE tmp_working_view_section_id = f8 WITH noconstant(0.0)
 DECLARE tmp_wv = f8 WITH noconstant(0.0)
 DECLARE sections_to_add = i4 WITH noconstant(0)
 DECLARE items_to_add = i4 WITH noconstant(0)
 DECLARE new_id = f8 WITH noconstant(0.0)
 DECLARE working_view_id = f8 WITH noconstant(0.0)
 DECLARE failed = c1 WITH noconstant("F")
 DECLARE insertworkingview(p1=f8(ref)) = null
 DECLARE checkforexistingview(p1=f8(ref)) = null
 DECLARE updated_wv_id = f8 WITH noconstant(0.0)
 DECLARE qual_wv_id = f8 WITH noconstant(0.0)
 DECLARE mrr = vc
 DECLARE id = f8 WITH noconstant(0.0)
 DECLARE mrr_id = f8 WITH noconstant(0.0)
 DECLARE future_id = f8 WITH noconstant(0.0)
 DECLARE temp_version_num = i4 WITH noconstant(0)
 IF ((request->ensure_type="ACT"))
  SET failed = callprg(dcp_ver_working_view)
  IF (failed="T")
   GO TO exit_script
  ENDIF
  IF ((request->current_working_view=0))
   SET mrr = "wv.working_view_id = request->working_view_id"
  ELSE
   SET mrr = "wv.working_view_id = request->current_working_view"
  ENDIF
  SELECT INTO "nl:"
   FROM working_view wv
   WHERE parser(mrr)
   DETAIL
    mrr_id = wv.working_view_id, temp_version_num = wv.version_num
   WITH nocounter, forupdate(wv)
  ;end select
  IF (curqual > 0)
   UPDATE  FROM working_view wv
    SET wv.active_ind = 1, wv.active_status_dt_tm = cnvtdatetime(curdate,curtime3), wv
     .active_status_prsnl_id = reqinfo->updt_id,
     wv.updt_applctx = reqinfo->updt_applctx, wv.updt_cnt = (wv.updt_cnt+ 1), wv.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     wv.updt_id = reqinfo->updt_id, wv.updt_task = reqinfo->updt_task
    WHERE parser(mrr)
    WITH nocounter
   ;end update
   IF (error(err_msg,1) != 0)
    SET failed = "T"
    CALL log_status("UPDATE","F","WORKING_VIEW",err_msg)
    GO TO exit_script
   ELSEIF (curqual=0)
    SET err_msg = "unable to update working_view table"
    SET failed = "T"
    CALL log_status("UPDATE","F","WORKING_VIEW",err_msg)
    GO TO exit_script
   ENDIF
  ENDIF
  CALL deleteitemsandsections(mrr_id)
  CALL insertworkingview(mrr_id)
  IF ((request->version_num=0))
   SELECT INTO "nl:"
    FROM working_view wv
    WHERE wv.current_working_view=mrr_id
     AND wv.version_num=0
    DETAIL
     future_id = wv.working_view_id
    WITH nocounter
   ;end select
   IF (future_id > 0)
    CALL deleteitemsandsections(future_id)
    DELETE  FROM working_view wv
     WHERE wv.working_view_id=future_id
     WITH nocounter
    ;end delete
   ENDIF
  ENDIF
 ELSEIF ((request->ensure_type="UPD"))
  IF ((request->version_flag=1))
   SET failed = callprg(dcp_ver_working_view)
   IF (failed="T")
    GO TO exit_script
   ENDIF
  ENDIF
  IF ((request->version_num > 0))
   IF ((((request->current_working_view != 0)) OR ((request->working_view_id=0))) )
    CALL insertworkingview(working_view_id)
    SET reply->working_view_id = tmp_working_view_id
    CALL checkforexistingview(working_view_id)
    GO TO exit_script
   ENDIF
  ELSE
   SELECT INTO "nl:"
    FROM working_view wv
    WHERE (wv.working_view_id=request->working_view_id)
    WITH nocounter
   ;end select
   IF (((curqual=0) OR ((request->working_view_id=0))) )
    CALL insertworkingview(working_view_id)
    SET reply->working_view_id = tmp_working_view_id
    CALL checkforexistingview(working_view_id)
    GO TO exit_script
   ENDIF
  ENDIF
  SELECT INTO "nl:"
   FROM working_view wv
   WHERE (wv.working_view_id=request->working_view_id)
   WITH nocounter, forupdate(wv)
  ;end select
  IF (curqual > 0)
   UPDATE  FROM working_view wv
    SET wv.active_ind = request->active_ind, wv.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
     wv.active_status_prsnl_id = reqinfo->updt_id,
     wv.updt_applctx = reqinfo->updt_applctx, wv.updt_cnt = (wv.updt_cnt+ 1), wv.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     wv.updt_id = reqinfo->updt_id, wv.updt_task = reqinfo->updt_task
    WHERE (wv.working_view_id=request->working_view_id)
    WITH nocounter
   ;end update
   IF (error(err_msg,1) != 0)
    SET failed = "T"
    CALL log_status("UPDATE","F","WORKING_VIEW",err_msg)
    GO TO exit_script
   ELSEIF (curqual=0)
    SET err_msg = "unable to update working_view table"
    SET failed = "T"
    CALL log_status("UPDATE","F","WORKING_VIEW",err_msg)
    GO TO exit_script
   ENDIF
  ENDIF
  CALL deleteitemsandsections(request->working_view_id)
  SET working_view_id = request->working_view_id
  CALL insertworkingview(working_view_id)
 ELSEIF ((request->ensure_type="DEL"))
  IF ((request->version_num != 0))
   SELECT INTO "nl:"
    FROM working_view wv
    WHERE (wv.working_view_id=request->working_view_id)
    WITH nocounter, forupdate(wv)
   ;end select
   IF (curqual > 0)
    UPDATE  FROM working_view wv
     SET wv.active_ind = 0, wv.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), wv
      .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
      wv.active_status_prsnl_id = reqinfo->updt_id, wv.updt_applctx = reqinfo->updt_applctx, wv
      .updt_cnt = (wv.updt_cnt+ 1),
      wv.updt_dt_tm = cnvtdatetime(curdate,curtime3), wv.updt_id = reqinfo->updt_id, wv.updt_task =
      reqinfo->updt_task
     WHERE (wv.working_view_id=request->working_view_id)
     WITH nocounter
    ;end update
    IF (error(err_msg,1) != 0)
     SET failed = "T"
     CALL log_status("UPDATE","F","WORKING_VIEW",err_msg)
     GO TO exit_script
    ELSEIF (curqual=0)
     SET err_msg = "unable to update working_view table"
     SET failed = "T"
     CALL log_status("UPDATE","F","WORKING_VIEW",err_msg)
     GO TO exit_script
    ENDIF
   ENDIF
  ELSE
   CALL deleteitemsandsections(request->working_view_id)
   DELETE  FROM working_view wv
    WHERE (wv.working_view_id=request->working_view_id)
    WITH nocounter
   ;end delete
  ENDIF
 ENDIF
 IF ((request->version_flag=1))
  SET reply->working_view_id = tmp_working_view_id
 ELSE
  SET reply->working_view_id = request->working_view_id
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  SET reply->version_num = temp_version_num
 ENDIF
 SUBROUTINE insertworkingview(working_view_id)
   IF (working_view_id > 0)
    SET tmp_working_view_id = working_view_id
   ELSE
    SELECT INTO "nl:"
     nextseqnum = seq(carenet_seq,nextval)
     FROM dual
     DETAIL
      tmp_working_view_id = nextseqnum
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET err_msg = "unable to generate sequence for working_view table"
     SET failed = "T"
     CALL log_status("SEQUENCE","F","WORKING_VIEW",err_msg)
     GO TO exit_script
    ENDIF
    SET working_view_id = tmp_working_view_id
    INSERT  FROM working_view wv
     SET wv.working_view_id = tmp_working_view_id, wv.current_working_view = request->
      current_working_view, wv.display_name = substring(1,39,request->display_name),
      wv.position_cd = request->position_cd, wv.location_cd = request->location_cd, wv.version_num =
      request->version_num,
      wv.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), wv.end_effective_dt_tm = cnvtdatetime(
       "31-Dec-2100"), wv.active_ind = request->active_ind,
      wv.active_status_cd = reqdata->active_status_cd, wv.active_status_dt_tm = cnvtdatetime(curdate,
       curtime3), wv.active_status_prsnl_id = reqinfo->updt_id,
      wv.updt_applctx = reqinfo->updt_applctx, wv.updt_cnt = 0, wv.updt_dt_tm = cnvtdatetime(curdate,
       curtime3),
      wv.updt_id = reqinfo->updt_id, wv.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    IF (error(err_msg,1) != 0)
     SET failed = "T"
     CALL log_status("INSERT","F","WORKING_VIEW",err_msg)
     GO TO exit_script
    ELSEIF (curqual=0)
     SET err_msg = "unable to insert into working_view table"
     SET failed = "T"
     CALL log_status("INSERT","F","WORKING_VIEW",err_msg)
     GO TO exit_script
    ENDIF
   ENDIF
   SET sections_to_add = size(request->working_view_sections,5)
   FOR (y = 1 TO sections_to_add)
     SELECT INTO "nl:"
      nextseqnum = seq(carenet_seq,nextval)
      FROM dual
      DETAIL
       tmp_working_view_section_id = nextseqnum
      WITH nocounter
     ;end select
     IF (error(err_msg,1) != 0)
      SET failed = "T"
      CALL log_status("SEQUENCE","F","WORKING_VIEW_SECTION",err_msg)
      GO TO exit_script
     ELSEIF (curqual=0)
      SET err_msg = "unable to generate sequence for working_view_section table"
      SET failed = "T"
      CALL log_status("SEQUENCE","F","WORKING_VIEW_SECTION",err_msg)
      GO TO exit_script
     ENDIF
     INSERT  FROM working_view_section wvs
      SET wvs.working_view_section_id = tmp_working_view_section_id, wvs.working_view_id =
       tmp_working_view_id, wvs.event_set_name = request->working_view_sections[y].event_set_name,
       wvs.required_ind = request->working_view_sections[y].required_ind, wvs.included_ind = request
       ->working_view_sections[y].included_ind, wvs.section_type_flag = request->
       working_view_sections[y].section_type_flag,
       wvs.display_name = request->working_view_sections[y].display_name, wvs.updt_applctx = reqinfo
       ->updt_applctx, wvs.updt_cnt = 0,
       wvs.updt_dt_tm = cnvtdatetime(curdate,curtime3), wvs.updt_id = reqinfo->updt_id, wvs.updt_task
        = reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (error(err_msg,1) != 0)
      SET failed = "T"
      CALL log_status("INSERT","F","WORKING_VIEW_SECTION",err_msg)
      GO TO exit_script
     ELSEIF (curqual=0)
      SET err_msg = "unable to insert into working_view_section table"
      SET failed = "T"
      CALL log_status("INSERT","F","WORKING_VIEW_SECTION",err_msg)
      GO TO exit_script
     ENDIF
     SET items_to_add = size(request->working_view_sections[y].working_view_items,5)
     FOR (j = 1 TO items_to_add)
      INSERT  FROM working_view_item wvi
       SET wvi.working_view_item_id = seq(carenet_seq,nextval), wvi.working_view_section_id =
        tmp_working_view_section_id, wvi.primitive_event_set_name = request->working_view_sections[y]
        .working_view_items[j].primitive_event_set_name,
        wvi.parent_event_set_name = request->working_view_sections[y].working_view_items[j].
        parent_event_set_name, wvi.included_ind = request->working_view_sections[y].
        working_view_items[j].included_ind, wvi.falloff_view_minutes = request->
        working_view_sections[y].working_view_items[j].falloff_view_minutes,
        wvi.updt_applctx = reqinfo->updt_applctx, wvi.updt_cnt = 0, wvi.updt_dt_tm = cnvtdatetime(
         curdate,curtime3),
        wvi.updt_id = reqinfo->updt_id, wvi.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
      IF (error(err_msg,1) != 0)
       SET failed = "T"
       CALL log_status("INSERT","F","WORKING_VIEW_ITEM",err_msg)
       GO TO exit_script
      ELSEIF (curqual=0)
       SET err_msg = "unable to insert into working_view_item table"
       SET failed = "T"
       CALL log_status("INSERT","F","WORKING_VIEW_ITEM",err_msg)
       GO TO exit_script
      ENDIF
     ENDFOR
   ENDFOR
 END ;Subroutine
 SUBROUTINE checkforexistingview(working_view_id)
   SELECT INTO "nl:"
    FROM working_view wv
    WHERE (wv.display_name=request->display_name)
     AND (wv.position_cd=request->position_cd)
     AND (wv.location_cd=request->location_cd)
    ORDER BY wv.version_num
    DETAIL
     IF (wv.working_view_id != working_view_id)
      tmp_wv = wv.working_view_id
     ENDIF
    WITH nocounter, forupdate(wv)
   ;end select
   IF ((request->version_num=0))
    SET updated_wv_id = tmp_wv
    SET qual_wv_id = working_view_id
   ELSE
    SET updated_wv_id = working_view_id
    SET qual_wv_id = tmp_wv
   ENDIF
   IF (tmp_wv > 0)
    UPDATE  FROM working_view wv
     SET wv.current_working_view = updated_wv_id, wv.updt_applctx = reqinfo->updt_applctx, wv
      .updt_cnt = (wv.updt_cnt+ 1),
      wv.updt_dt_tm = cnvtdatetime(curdate,curtime3), wv.updt_id = reqinfo->updt_id, wv.updt_task =
      reqinfo->updt_task
     WHERE wv.working_view_id=qual_wv_id
     WITH nocounter
    ;end update
    IF (error(err_msg,1) != 0)
     SET failed = "T"
     CALL log_status("UPDATE","F","WORKING_VIEW",err_msg)
    ELSEIF (curqual=0)
     SET err_msg = "unable to update working_view table"
     SET failed = "T"
     CALL log_status("UPDATE","F","WORKING_VIEW",err_msg)
    ENDIF
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE deleteitemsandsections(id)
  DELETE  FROM working_view_item wvi
   WHERE wvi.working_view_section_id IN (
   (SELECT
    wvs.working_view_section_id
    FROM working_view_section wvs
    WHERE wvs.working_view_id=id))
   WITH nocounter
  ;end delete
  DELETE  FROM working_view_section wvs
   WHERE wvs.working_view_id=id
   WITH nocounter
  ;end delete
 END ;Subroutine
END GO
