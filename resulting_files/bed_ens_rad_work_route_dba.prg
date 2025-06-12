CREATE PROGRAM bed_ens_rad_work_route:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp_oc
 RECORD temp_oc(
   1 oc_list[*]
     2 catalog_cd = f8
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET active_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning="ACTIVE"
   AND cv.active_ind=1
  DETAIL
   active_cd = cv.code_value
  WITH nocounter
 ;end select
 SET inactive_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning="INACTIVE"
   AND cv.active_ind=1
  DETAIL
   inactive_cd = cv.code_value
  WITH nocounter
 ;end select
 SET datetime_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=289
   AND cv.cdf_meaning="11"
   AND cv.active_ind=1
  DETAIL
   datetime_cd = cv.code_value
  WITH nocounter
 ;end select
 SET ecnt = 0
 SET ecnt = size(request->exams,5)
 FOR (e = 1 TO ecnt)
   SET rcnt = 0
   SET rcnt = size(request->exams[e].exam_rooms,5)
   SET updt_oc = 0
   FOR (r = 1 TO rcnt)
     IF ((request->exams[e].exam_rooms[r].action_flag=1))
      INSERT  FROM assay_resource_list arl
       SET arl.service_resource_cd = request->exams[e].exam_rooms[r].code_value, arl.task_assay_cd =
        request->exams[e].code_value, arl.active_ind = 1,
        arl.resource_group_cd = 0, arl.resource_route_flag = null, arl.primary_ind = request->exams[e
        ].exam_rooms[r].default_ind,
        arl.sequence = request->exams[e].exam_rooms[r].sequence, arl.script_name = " ", arl
        .updt_dt_tm = cnvtdatetime(curdate,curtime3),
        arl.updt_id = reqinfo->updt_id, arl.updt_task = reqinfo->updt_task, arl.updt_cnt = 0,
        arl.updt_applctx = reqinfo->updt_applctx, arl.active_status_cd = active_cd, arl
        .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
        arl.active_status_prsnl_id = reqinfo->updt_id, arl.beg_effective_dt_tm = cnvtdatetime(curdate,
         curtime3), arl.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = "Unable to insert into assay_resource_list"
       GO TO exit_script
      ENDIF
      SET row_found = 0
      SELECT INTO "NL:"
       FROM assay_processing_r apr
       WHERE (apr.service_resource_cd=request->exams[e].exam_rooms[r].code_value)
        AND (apr.task_assay_cd=request->exams[e].code_value)
        AND apr.active_ind=0
       DETAIL
        row_found = 1
       WITH nocounter
      ;end select
      IF (row_found=1)
       UPDATE  FROM assay_processing_r apr
        SET apr.active_ind = 1, apr.active_status_cd = active_cd, apr.active_status_dt_tm =
         cnvtdatetime(curdate,curtime3),
         apr.active_status_prsnl_id = reqinfo->updt_id, apr.updt_cnt = (apr.updt_cnt+ 1), apr
         .updt_dt_tm = cnvtdatetime(curdate,curtime3),
         apr.updt_id = reqinfo->updt_id, apr.updt_task = reqinfo->updt_task, apr.updt_applctx =
         reqinfo->updt_applctx
        WHERE (apr.service_resource_cd=request->exams[e].exam_rooms[r].code_value)
         AND (apr.task_assay_cd=request->exams[e].code_value)
        WITH nocounter
       ;end update
       IF (curqual=0)
        SET error_flag = "Y"
        SET error_msg = "Unable to update into assay_processing_r"
        GO TO exit_script
       ENDIF
      ELSE
       INSERT  FROM assay_processing_r apr
        SET apr.task_assay_cd = request->exams[e].code_value, apr.service_resource_cd = request->
         exams[e].exam_rooms[r].code_value, apr.upld_assay_alias = null,
         apr.process_sequence = null, apr.active_ind = 1, apr.default_result_type_cd = datetime_cd,
         apr.default_result_template_id = 0, apr.qc_result_type_cd = 0, apr.qc_sequence = 0,
         apr.updt_cnt = 0, apr.updt_dt_tm = cnvtdatetime(curdate,curtime3), apr.updt_task = reqinfo->
         updt_task,
         apr.updt_id = reqinfo->updt_id, apr.updt_applctx = reqinfo->updt_applctx, apr.downld_ind = 0,
         apr.post_zero_result_ind = null, apr.display_sequence = 0, apr.dnld_assay_alias = null,
         apr.code_set = 0, apr.active_status_cd = active_cd, apr.active_status_dt_tm = cnvtdatetime(
          curdate,curtime3),
         apr.active_status_prsnl_id = reqinfo->updt_id, apr.loaded_service_resource_cd = 0
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET error_flag = "Y"
        SET error_msg = "Unable to insert into assay_processing_r"
        GO TO exit_script
       ENDIF
      ENDIF
      SET row_found = 0
      SELECT INTO "NL:"
       FROM assay_resource_translation art
       WHERE (art.service_resource_cd=request->exams[e].exam_rooms[r].code_value)
        AND (art.task_assay_cd=request->exams[e].code_value)
        AND art.active_ind=0
       DETAIL
        row_found = 1
       WITH nocounter
      ;end select
      IF (row_found=1)
       UPDATE  FROM assay_resource_translation art
        SET art.active_ind = 1, art.active_status_cd = active_cd, art.active_status_dt_tm =
         cnvtdatetime(curdate,curtime3),
         art.active_status_prsnl_id = reqinfo->updt_id, art.updt_cnt = (art.updt_cnt+ 1), art
         .updt_dt_tm = cnvtdatetime(curdate,curtime3),
         art.updt_id = reqinfo->updt_id, art.updt_task = reqinfo->updt_task, art.updt_applctx =
         reqinfo->updt_applctx
        WHERE (art.service_resource_cd=request->exams[e].exam_rooms[r].code_value)
         AND (art.task_assay_cd=request->exams[e].code_value)
        WITH nocounter
       ;end update
       IF (curqual=0)
        SET error_flag = "Y"
        SET error_msg = "Unable to update into assay_resource_translation"
        GO TO exit_script
       ENDIF
      ELSE
       INSERT  FROM assay_resource_translation art
        SET art.task_assay_cd = request->exams[e].code_value, art.service_resource_cd = request->
         exams[e].exam_rooms[r].code_value, art.upld_assay_alias = " ",
         art.active_ind = 1, art.updt_cnt = 0, art.updt_dt_tm = cnvtdatetime(curdate,curtime3),
         art.updt_task = reqinfo->updt_task, art.updt_id = reqinfo->updt_id, art.updt_applctx =
         reqinfo->updt_applctx,
         art.post_zero_result_ind = null, art.process_sequence = null, art.active_status_cd =
         active_cd,
         art.active_status_dt_tm = cnvtdatetime(curdate,curtime3), art.active_status_prsnl_id =
         reqinfo->updt_id, art.loaded_service_resource_cd = 0
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET error_flag = "Y"
        SET error_msg = "Unable to insert into assay_resource_translation"
        GO TO exit_script
       ENDIF
      ENDIF
      IF (updt_oc=0)
       SET updt_oc = 1
       SET temp_oc_count = 0
       SELECT INTO "NL:"
        FROM profile_task_r ptr,
         order_catalog oc
        PLAN (ptr
         WHERE ptr.active_ind=1
          AND (ptr.task_assay_cd=request->exams[e].code_value))
         JOIN (oc
         WHERE oc.catalog_cd=ptr.catalog_cd
          AND ((oc.resource_route_lvl != 2) OR (oc.resource_route_lvl=null)) )
        DETAIL
         temp_oc_count = (temp_oc_count+ 1), stat = alterlist(temp_oc->oc_list,temp_oc_count),
         temp_oc->oc_list[temp_oc_count].catalog_cd = oc.catalog_cd
        WITH nocounter
       ;end select
       IF (temp_oc_count > 0)
        FOR (z = 1 TO temp_oc_count)
          UPDATE  FROM order_catalog oc
           SET oc.resource_route_lvl = 2, oc.updt_dt_tm = cnvtdatetime(curdate,curtime3), oc.updt_id
             = reqinfo->updt_id,
            oc.updt_task = reqinfo->updt_task, oc.updt_cnt = (oc.updt_cnt+ 1), oc.updt_applctx =
            reqinfo->updt_applctx
           WHERE (oc.catalog_cd=temp_oc->oc_list[z].catalog_cd)
           WITH nocounter
          ;end update
        ENDFOR
       ENDIF
      ENDIF
     ELSEIF ((request->exams[e].exam_rooms[r].action_flag=2))
      UPDATE  FROM assay_resource_list arl
       SET arl.sequence = request->exams[e].exam_rooms[r].sequence, arl.primary_ind = request->exams[
        e].exam_rooms[r].default_ind, arl.updt_cnt = (arl.updt_cnt+ 1),
        arl.updt_dt_tm = cnvtdatetime(curdate,curtime3), arl.updt_id = reqinfo->updt_id, arl
        .updt_task = reqinfo->updt_task,
        arl.updt_applctx = reqinfo->updt_applctx
       WHERE (arl.service_resource_cd=request->exams[e].exam_rooms[r].code_value)
        AND (arl.task_assay_cd=request->exams[e].code_value)
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = "Unable to update into assay_resource_list"
       GO TO exit_script
      ENDIF
      IF (updt_oc=0)
       SET updt_oc = 1
       SET temp_oc_count = 0
       SELECT INTO "NL:"
        FROM profile_task_r ptr,
         order_catalog oc
        PLAN (ptr
         WHERE ptr.active_ind=1
          AND (ptr.task_assay_cd=request->exams[e].code_value))
         JOIN (oc
         WHERE oc.catalog_cd=ptr.catalog_cd
          AND ((oc.resource_route_lvl != 2) OR (oc.resource_route_lvl=null)) )
        DETAIL
         temp_oc_count = (temp_oc_count+ 1), stat = alterlist(temp_oc->oc_list,temp_oc_count),
         temp_oc->oc_list[temp_oc_count].catalog_cd = oc.catalog_cd
        WITH nocounter
       ;end select
       IF (temp_oc_count > 0)
        FOR (z = 1 TO temp_oc_count)
          UPDATE  FROM order_catalog oc
           SET oc.resource_route_lvl = 2, oc.updt_dt_tm = cnvtdatetime(curdate,curtime3), oc.updt_id
             = reqinfo->updt_id,
            oc.updt_task = reqinfo->updt_task, oc.updt_cnt = (oc.updt_cnt+ 1), oc.updt_applctx =
            reqinfo->updt_applctx
           WHERE (oc.catalog_cd=temp_oc->oc_list[z].catalog_cd)
           WITH nocounter
          ;end update
        ENDFOR
       ENDIF
      ENDIF
     ELSEIF ((request->exams[e].exam_rooms[r].action_flag=3))
      DELETE  FROM assay_resource_list arl
       WHERE (arl.service_resource_cd=request->exams[e].exam_rooms[r].code_value)
        AND (arl.task_assay_cd=request->exams[e].code_value)
       WITH nocounter
      ;end delete
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = "Unable to delete from assay_resource_list"
       GO TO exit_script
      ENDIF
      UPDATE  FROM assay_processing_r apr
       SET apr.active_ind = 0, apr.active_status_cd = inactive_cd, apr.active_status_dt_tm =
        cnvtdatetime(curdate,curtime3),
        apr.active_status_prsnl_id = reqinfo->updt_id, apr.updt_cnt = (apr.updt_cnt+ 1), apr
        .updt_dt_tm = cnvtdatetime(curdate,curtime3),
        apr.updt_id = reqinfo->updt_id, apr.updt_task = reqinfo->updt_task, apr.updt_applctx =
        reqinfo->updt_applctx
       WHERE (apr.service_resource_cd=request->exams[e].exam_rooms[r].code_value)
        AND (apr.task_assay_cd=request->exams[e].code_value)
       WITH nocounter
      ;end update
      UPDATE  FROM assay_resource_translation art
       SET art.active_ind = 0, art.active_status_cd = inactive_cd, art.active_status_dt_tm =
        cnvtdatetime(curdate,curtime3),
        art.active_status_prsnl_id = reqinfo->updt_id, art.updt_cnt = (art.updt_cnt+ 1), art
        .updt_dt_tm = cnvtdatetime(curdate,curtime3),
        art.updt_id = reqinfo->updt_id, art.updt_task = reqinfo->updt_task, art.updt_applctx =
        reqinfo->updt_applctx
       WHERE (art.service_resource_cd=request->exams[e].exam_rooms[r].code_value)
        AND (art.task_assay_cd=request->exams[e].code_value)
       WITH nocounter
      ;end update
     ENDIF
   ENDFOR
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_RAD_WORK_ROUTE","  >> ERROR MSG: ",
   error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
