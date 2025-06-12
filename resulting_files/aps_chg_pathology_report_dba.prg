CREATE PROGRAM aps_chg_pathology_report:dba
 RECORD reply(
   1 case_id = f8
   1 report_qual[1]
     2 report_id = f8
   1 event_qual[*]
     2 event_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp_entities(
   1 entity_qual[*]
     2 entity_id = f8
 )
 RECORD temp_comments(
   1 comment_qual[*]
     2 long_text_id = f8
 )
 RECORD temp_items(
   1 item_qual[*]
     2 parent_entity_id = f8
     2 parent_entity_name = c32
 )
 RECORD purge_input(
   1 qual[*]
     2 blob_identifier = vc
 )
 RECORD purge_output(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET failures = 0
 SET cur_updt_cnt = 0
 SET order_id = 0.0
 SET service_resource_cd = 0.0
 SET event_id = 0.0
 SET failed = "F"
 SET errors = " "
 SET thetable = " "
 SET reply->status_data.status = "F"
 SET nbr_to_chg = cnvtint(size(request->report_qual,5))
 SET cancel_status_cd = 0.0
 SET code_value = 0.0
 SET new_comments_long_text_id = 0.00
 SET item_cnt = 0
 SET entity_cnt = 0
 SET comment_cnt = 0
 SET dicom_cnt = 0
 SET dicom_storage_cd = 0.0
 SET code_set = 25
 SET cdf_meaning = "DICOM_SIUID"
 EXECUTE cpm_get_cd_for_cdf
 SET dicom_storage_cd = code_value
 SET code_set = 1305
 SET cdf_meaning = "CANCEL"
 EXECUTE cpm_get_cd_for_cdf
 SET cancel_status_cd = code_value
 SET code_set = 48
 SET cdf_meaning = "ACTIVE"
 EXECUTE cpm_get_cd_for_cdf
 SET s_active_cd = code_value
 SET x = 1
#start_loop
 FOR (x = x TO nbr_to_chg)
   IF ((request->report_qual[x].cancel_cd > 0.0))
    SET thetable = "C"
    SELECT INTO "nl:"
     cr.*
     FROM case_report cr
     WHERE (request->report_qual[x].report_id=cr.report_id)
     DETAIL
      cur_updt_cnt = cr.updt_cnt, event_id = cr.event_id
      IF ((reply->case_id=0.0))
       reply->case_id = cr.case_id
      ENDIF
     WITH forupdate(cr)
    ;end select
    IF (curqual=0)
     SET errors = "L"
     GO TO check_error
    ENDIF
    IF ((request->report_qual[x].cr_updt_cnt != cur_updt_cnt))
     SET errors = "U"
     GO TO check_error
    ENDIF
    SET cur_updt_cnt = (cur_updt_cnt+ 1)
    UPDATE  FROM case_report cr
     SET cr.cancel_cd = request->report_qual[x].cancel_cd, cr.cancel_prsnl_id = reqinfo->updt_id, cr
      .cancel_dt_tm = cnvtdatetime(curdate,curtime),
      cr.status_cd = cancel_status_cd, cr.status_prsnl_id = reqinfo->updt_id, cr.status_dt_tm =
      cnvtdatetime(curdate,curtime),
      cr.updt_dt_tm = cnvtdatetime(curdate,curtime), cr.updt_id = reqinfo->updt_id, cr.updt_task =
      reqinfo->updt_task,
      cr.updt_applctx = reqinfo->updt_applctx, cr.updt_cnt = cur_updt_cnt
     WHERE (request->report_qual[x].report_id=cr.report_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET errors = "U"
     GO TO check_error
    ENDIF
    IF ((request->report_qual[x].synoptic_stale_ind=1))
     UPDATE  FROM case_report cr
      SET cr.synoptic_stale_dt_tm = null
      WHERE (request->report_qual[x].report_id=cr.report_id)
       AND cnvtdatetime(request->report_qual[x].synoptic_stale_dt_tm)=cr.synoptic_stale_dt_tm
       AND nullind(cr.synoptic_stale_dt_tm)=0
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET errors = "U"
      GO TO check_error
     ENDIF
    ENDIF
    IF (event_id > 0.0)
     SET stat = alterlist(reply->event_qual,(size(reply->event_qual,5)+ 1))
     SET reply->event_qual[size(reply->event_qual,5)].event_id = event_id
    ENDIF
    INSERT  FROM ap_ops_exception aoe
     SET aoe.parent_id = request->report_qual[x].report_id, aoe.action_flag = 6, aoe.active_ind = 1,
      aoe.updt_dt_tm = cnvtdatetime(curdate,curtime), aoe.updt_id = reqinfo->updt_id, aoe.updt_task
       = reqinfo->updt_task,
      aoe.updt_applctx = reqinfo->updt_applctx, aoe.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET errors = "I"
     SET thetable = "O"
     GO TO check_error
    ENDIF
    IF (curutc=1)
     INSERT  FROM ap_ops_exception_detail aoed
      SET aoed.action_flag = 6, aoed.field_meaning = "TIME_ZONE", aoed.field_nbr = curtimezoneapp,
       aoed.parent_id = request->report_qual[x].report_id, aoed.sequence = 1, aoed.updt_applctx =
       reqinfo->updt_applctx,
       aoed.updt_cnt = 0, aoed.updt_dt_tm = cnvtdatetime(curdate,curtime), aoed.updt_id = reqinfo->
       updt_id,
       aoed.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET errors = "I"
      SET thetable = "E"
      GO TO check_error
     ENDIF
    ENDIF
    SELECT INTO "nl:"
     rdi.report_detail_id, br.blob_ref_id
     FROM report_detail_image rdi,
      blob_reference br
     PLAN (rdi
      WHERE (rdi.report_id=request->report_qual[x].report_id))
      JOIN (br
      WHERE br.parent_entity_name="REPORT_DETAIL_IMAGE"
       AND br.parent_entity_id=rdi.report_detail_id
       AND br.valid_from_dt_tm < cnvtdatetime(curdate,curtime3)
       AND br.valid_until_dt_tm > cnvtdatetime(curdate,curtime3))
     HEAD REPORT
      item_cnt = 0, dicom_cnt = 0
     DETAIL
      item_cnt = (item_cnt+ 1)
      IF (mod(item_cnt,10)=1)
       stat = alterlist(temp_items->item_qual,(item_cnt+ 9))
      ENDIF
      temp_items->item_qual[item_cnt].parent_entity_id = br.blob_ref_id, temp_items->item_qual[
      item_cnt].parent_entity_name = "BLOB_REFERENCE"
      IF (br.storage_cd=dicom_storage_cd)
       dicom_cnt = (dicom_cnt+ 1)
       IF (mod(dicom_cnt,10)=1)
        stat = alterlist(purge_input->qual,(dicom_cnt+ 9))
       ENDIF
       purge_input->qual[dicom_cnt].blob_identifier = br.blob_handle
      ENDIF
     FOOT REPORT
      stat = alterlist(temp_items->item_qual,item_cnt), stat = alterlist(purge_input->qual,dicom_cnt)
     WITH nocounter
    ;end select
    SET request->report_id = request->report_qual[x].report_id
    EXECUTE aps_del_departmental_images
    IF (item_cnt > 0)
     SELECT INTO "nl:"
      afe.entity_id
      FROM ap_folder_entity afe,
       (dummyt d1  WITH seq = value(item_cnt))
      PLAN (d1)
       JOIN (afe
       WHERE (afe.parent_entity_name=temp_items->item_qual[d1.seq].parent_entity_name)
        AND (afe.parent_entity_id=temp_items->item_qual[d1.seq].parent_entity_id))
      HEAD REPORT
       entity_cnt = 0, comment_cnt = 0
      DETAIL
       entity_cnt = (entity_cnt+ 1)
       IF (mod(entity_cnt,10)=1)
        stat = alterlist(temp_entities->entity_qual,(entity_cnt+ 9))
       ENDIF
       temp_entities->entity_qual[entity_cnt].entity_id = afe.entity_id
       IF (afe.comment_id > 0)
        comment_cnt = (comment_cnt+ 1)
        IF (mod(comment_cnt,10)=1)
         stat = alterlist(temp_comments->comment_qual,(comment_cnt+ 9))
        ENDIF
        temp_comments->comment_qual[comment_cnt].long_text_id = afe.comment_id
       ENDIF
      FOOT REPORT
       stat = alterlist(temp_entities->entity_qual,entity_cnt), stat = alterlist(temp_comments->
        comment_qual,comment_cnt)
      WITH nocounter
     ;end select
    ENDIF
    IF (entity_cnt > 0)
     DELETE  FROM ap_folder_entity afe,
       (dummyt d  WITH seq = value(entity_cnt))
      SET afe.entity_id = temp_entities->entity_qual[d.seq].entity_id
      PLAN (d)
       JOIN (afe
       WHERE (afe.entity_id=temp_entities->entity_qual[d.seq].entity_id))
      WITH nocounter
     ;end delete
     IF (curqual != entity_cnt)
      SET errors = "D"
      SET thetable = "F"
      GO TO check_error
     ENDIF
     IF (comment_cnt > 0)
      DELETE  FROM long_text lt,
        (dummyt d  WITH seq = value(comment_cnt))
       SET lt.long_text_id = temp_comments->comment_qual[d.seq].long_text_id
       PLAN (d)
        JOIN (lt
        WHERE (lt.long_text_id=temp_comments->comment_qual[d.seq].long_text_id))
       WITH nocounter
      ;end delete
      IF (curqual != comment_cnt)
       SET errors = "D"
       SET thetable = "T"
       GO TO check_error
      ENDIF
     ENDIF
    ENDIF
    IF (dicom_cnt > 0)
     EXECUTE aps_add_blobs_to_purge
     IF ((purge_output->status_data.status != "S"))
      SET errors = "U"
      SET thetable = "B"
      GO TO check_error
     ENDIF
    ENDIF
    COMMIT
   ELSE
    IF ((reply->case_id=0.0))
     SET thetable = "C"
     SELECT INTO "nl:"
      cr.*
      FROM case_report cr
      WHERE (request->report_qual[x].report_id=cr.report_id)
      DETAIL
       reply->case_id = cr.case_id
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET errors = "S"
      GO TO check_error
     ENDIF
    ENDIF
    SET thetable = "R"
    SELECT INTO "nl:"
     rt.*
     FROM report_task rt
     WHERE (request->report_qual[x].report_id=rt.report_id)
     DETAIL
      cur_updt_cnt = rt.updt_cnt, order_id = rt.order_id, service_resource_cd = rt
      .service_resource_cd
     WITH forupdate(rt)
    ;end select
    IF (curqual=0)
     SET errors = "L"
     GO TO check_error
    ENDIF
    IF ((request->report_qual[x].rt_updt_cnt != cur_updt_cnt))
     IF ((request->report_qual[x].order_id=0)
      AND order_id != 0)
      IF ((service_resource_cd != request->report_qual[x].processing_location_cd)
       AND (request->report_qual[x].processing_location_cd=0))
       SET request->report_qual[x].processing_location_cd = service_resource_cd
      ENDIF
     ELSE
      SET errors = "U"
      GO TO check_error
     ENDIF
    ENDIF
    SET cur_updt_cnt = (cur_updt_cnt+ 1)
    IF ((request->report_qual[x].comments_long_text_id > 0))
     IF (textlen(trim(request->report_qual[x].comments)) > 0)
      CALL updatelongtexttable(0)
      CALL updatereporttasktable(request->report_qual[x].comments_long_text_id)
     ELSE
      CALL updatereporttasktable(0)
      CALL deletelongtextrow(0)
     ENDIF
    ELSE
     IF (textlen(trim(request->report_qual[x].comments)) > 0)
      CALL generatenewlongtextid(0)
      CALL insertnewrowtolongtexttable(0)
     ENDIF
     CALL updatereporttasktable(new_comments_long_text_id)
    ENDIF
    COMMIT
    SET new_comments_long_text_id = 0.00
   ENDIF
 ENDFOR
 GO TO exit_script
 SUBROUTINE updatelongtexttable(dummyvar)
   SET thetable = "L"
   SELECT INTO "nl:"
    lt.*
    FROM long_text lt
    WHERE (request->report_qual[x].comments_long_text_id=lt.long_text_id)
    DETAIL
     cur_updt_cnt = lt.updt_cnt
    WITH forupdate(lt)
   ;end select
   IF (curqual=0)
    SET errors = "L"
    GO TO check_error
   ENDIF
   IF ((request->report_qual[x].lt_updt_cnt != cur_updt_cnt))
    SET errors = "U"
    GO TO check_error
   ENDIF
   SET cur_updt_cnt = (cur_updt_cnt+ 1)
   UPDATE  FROM long_text lt
    SET lt.long_text = trim(request->report_qual[x].comments), lt.updt_dt_tm = cnvtdatetime(curdate,
      curtime), lt.updt_id = reqinfo->updt_id,
     lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->updt_applctx, lt.updt_cnt =
     cur_updt_cnt
    WHERE (request->report_qual[x].comments_long_text_id=lt.long_text_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET errors = "U"
    GO TO check_error
   ENDIF
 END ;Subroutine
 SUBROUTINE updatereporttasktable(longtextid)
   SET thetable = "R"
   UPDATE  FROM report_task rt
    SET rt.service_resource_cd =
     IF ((request->report_qual[x].processing_location_cd=0)) rt.service_resource_cd
     ELSE request->report_qual[x].processing_location_cd
     ENDIF
     , rt.priority_cd = request->report_qual[x].request_priority_cd, rt.responsible_resident_id =
     request->report_qual[x].responsible_resident_id,
     rt.responsible_pathologist_id = request->report_qual[x].responsible_pathologist_id, rt
     .comments_long_text_id = longtextid, rt.updt_dt_tm = cnvtdatetime(curdate,curtime),
     rt.updt_id = reqinfo->updt_id, rt.updt_task = reqinfo->updt_task, rt.updt_applctx = reqinfo->
     updt_applctx,
     rt.updt_cnt = cur_updt_cnt
    WHERE (request->report_qual[x].report_id=rt.report_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET errors = "U"
    GO TO check_error
   ENDIF
 END ;Subroutine
 SUBROUTINE deletelongtextrow(dummyvar)
   SET thetable = "L"
   DELETE  FROM long_text lt
    WHERE (lt.long_text_id=request->report_qual[x].comments_long_text_id)
    WITH nocounter
   ;end delete
   IF (curqual=0)
    SET errors = "D"
    GO TO check_error
   ENDIF
 END ;Subroutine
 SUBROUTINE generatenewlongtextid(dummyvar)
   SET thetable = "D"
   SELECT INTO "nl:"
    seq_nbr = seq(long_data_seq,nextval)
    FROM dual
    DETAIL
     new_comments_long_text_id = seq_nbr
    WITH format, counter
   ;end select
   IF (curqual=0)
    SET errors = "U"
    GO TO check_error
   ENDIF
 END ;Subroutine
 SUBROUTINE insertnewrowtolongtexttable(dummyvar)
   SET thetable = "L"
   INSERT  FROM long_text lt
    SET lt.long_text_id = new_comments_long_text_id, lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
     updt_applctx,
     lt.active_ind = 1, lt.active_status_cd = s_active_cd, lt.active_status_dt_tm = cnvtdatetime(
      curdate,curtime3),
     lt.active_status_prsnl_id = reqinfo->updt_id, lt.parent_entity_name = "REPORT_TASK", lt
     .parent_entity_id = request->report_qual[x].report_id,
     lt.long_text = request->report_qual[x].comments
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET errors = "I"
    GO TO check_error
   ENDIF
 END ;Subroutine
#check_error
 SET failures = (failures+ 1)
 IF (failures > 1)
  SET stat = alter(reply->status_data.subeventstatus,failures)
  SET stat = alter(reply->report_qual,failures)
 ENDIF
 SET reply->report_qual[failures].report_id = request->report_qual[x].report_id
 SET reply->status_data.subeventstatus[failures].operationstatus = "F"
 SET reply->status_data.subeventstatus[failures].targetobjectname = "TABLE"
 IF (thetable="C")
  SET reply->status_data.subeventstatus[failures].targetobjectvalue = "CASE_REPORT"
 ELSEIF (thetable="R")
  SET reply->status_data.subeventstatus[failures].targetobjectvalue = "REPORT_TASK"
 ELSEIF (thetable="F")
  SET reply->status_data.subeventstatus[failures].targetobjectvalue = "AP_FOLDER_ENTITY"
 ELSEIF (thetable="T")
  SET reply->status_data.subeventstatus[failures].targetobjectvalue = "LONG_TEXT (IMAGES)"
 ELSEIF (thetable="B")
  SET reply->status_data.subeventstatus[failures].targetobjectvalue = "AP_BLOB_CLEANUP"
 ELSEIF (thetable="D")
  SET reply->status_data.subeventstatus[failures].targetobjectvalue = "DUAL"
 ELSEIF (thetable="O")
  SET reply->status_data.subeventstatus[failures].targetobjectvalue = "AP_OPS_EXCEPTION"
 ELSEIF (thetable="E")
  SET reply->status_data.subeventstatus[failures].targetobjectvalue = "AP_OPS_EXCEPTION_DETAIL"
 ELSE
  SET reply->status_data.subeventstatus[failures].targetobjectvalue = "LONG_TEXT"
 ENDIF
 IF (errors="L")
  SET reply->status_data.subeventstatus[failures].operationname = "LOCK"
 ELSEIF (errors="D")
  SET reply->status_data.subeventstatus[failures].operationname = "DELETE"
 ELSEIF (errors="I")
  SET reply->status_data.subeventstatus[failures].operationname = "INSERT"
 ELSEIF (errors="S")
  SET reply->status_data.subeventstatus[failures].operationname = "SELECT"
 ELSE
  SET reply->status_data.subeventstatus[failures].operationname = "UPDATE"
 ENDIF
 SET failed = "T"
 ROLLBACK
 SET x = (x+ 1)
 GO TO start_loop
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
 ELSE
  IF (failures < nbr_to_chg)
   SET reply->status_data.status = "P"
  ENDIF
 ENDIF
END GO
