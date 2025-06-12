CREATE PROGRAM dm_del_env_reltn:dba
 IF ( NOT (validate(auto_ver_request,0)))
  FREE RECORD auto_ver_request
  RECORD auto_ver_request(
    1 qual[*]
      2 rdds_event = vc
      2 event_reason = vc
      2 cur_environment_id = f8
      2 paired_environment_id = f8
      2 detail_qual[*]
        3 event_detail1_txt = vc
        3 event_detail2_txt = vc
        3 event_detail3_txt = vc
        3 event_value = f8
  )
  FREE RECORD auto_ver_reply
  RECORD auto_ver_reply(
    1 status = c1
    1 status_msg = vc
  )
 ENDIF
 DECLARE errmsg = vc WITH protect
 DECLARE err_code = i4 WITH protect, noconstant(0)
 DECLARE del_cnt = i4 WITH protect
 DECLARE del_env_is_parent = i2 WITH protect, noconstant(0)
 DECLARE del_local_env_id = f8 WITH protect, noconstant(0.0)
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name="DM_ENV_ID"
  DETAIL
   del_local_env_id = di.info_number
  WITH nocounter
 ;end select
 SET err_code = error(errmsg,0)
 IF (err_code > 0)
  SET derd_reply->err_msg = errmsg
  SET derd_reply->err_num = err_code
  GO TO exit_program
 ENDIF
 FOR (del_cnt = 1 TO size(derd_request->env_list,5))
   SET del_env_is_parent = 0
   IF ((del_local_env_id=derd_request->env_list[del_cnt].parent_env_id))
    SET del_env_is_parent = 1
   ENDIF
   IF ((derd_request->child_env_id > 0))
    SET err_code = error(errmsg,1)
    DELETE  FROM dm_env_reltn d
     WHERE (d.parent_env_id=derd_request->env_list[del_cnt].parent_env_id)
      AND (d.child_env_id=derd_request->child_env_id)
      AND d.relationship_type=patstring(derd_request->env_list[del_cnt].relationship_type)
     WITH nocounter
    ;end delete
    SET err_code = error(errmsg,0)
    IF (err_code > 0)
     SET derd_reply->err_msg = errmsg
     SET derd_reply->err_num = err_code
     GO TO exit_program
    ENDIF
    IF ((derd_request->env_list[del_cnt].relationship_type="REFERENCE MERGE"))
     IF (del_env_is_parent=1)
      UPDATE  FROM dm_info di
       SET di.info_number = derd_request->child_env_id, di.info_char = trim(cnvtstring(derd_request->
          env_list[del_cnt].parent_env_id,20)), di.updt_cnt = (di.updt_cnt+ 1),
        di.info_date = cnvtdatetime(curdate,curtime3), di.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        di.updt_id = reqinfo->updt_id,
        di.updt_applctx = reqinfo->updt_applctx, di.updt_task = reqinfo->updt_task
       WHERE di.info_domain="RDDS CONFIGURATION"
        AND di.info_name=concat("RELTN_ACTIVE:",trim(cnvtstring(derd_request->child_env_id,20)))
       WITH nocounter
      ;end update
      SET err_code = error(errmsg,0)
      IF (err_code > 0)
       SET derd_reply->err_msg = errmsg
       SET derd_reply->err_num = err_code
       GO TO exit_program
      ELSE
       IF (curqual=0)
        INSERT  FROM dm_info di
         SET di.info_domain = "RDDS CONFIGURATION", di.info_name = concat("RELTN_ACTIVE:",trim(
            cnvtstring(derd_request->child_env_id,20))), di.info_char = trim(cnvtstring(derd_request
            ->env_list[del_cnt].parent_env_id,20)),
          di.info_number = derd_request->child_env_id, di.info_date = cnvtdatetime(curdate,curtime3),
          di.updt_dt_tm = cnvtdatetime(curdate,curtime3),
          di.updt_id = reqinfo->updt_id, di.updt_applctx = reqinfo->updt_applctx, di.updt_task =
          reqinfo->updt_task,
          di.updt_cnt = 0
         WITH nocounter
        ;end insert
        SET err_code = error(errmsg,0)
        IF (err_code > 0)
         SET derd_reply->err_msg = errmsg
         SET derd_reply->err_num = err_code
         GO TO exit_program
        ENDIF
       ENDIF
      ENDIF
     ENDIF
     SET stat = alterlist(auto_ver_request->qual,1)
     SET auto_ver_request->qual[1].rdds_event = "Drop Environment Relation"
     SET auto_ver_request->qual[1].cur_environment_id = derd_request->env_list[del_cnt].parent_env_id
     SET auto_ver_request->qual[1].paired_environment_id = derd_request->child_env_id
     EXECUTE dm_rmc_auto_verify_setup
     IF ((auto_ver_reply->status="F"))
      ROLLBACK
      SET derd_reply->err_msg = auto_ver_reply->status_msg
      SET derd_reply->err_num = error(auto_ver_reply->status_msg,0)
      GO TO exit_program
     ENDIF
    ENDIF
    COMMIT
   ELSE
    SET err_code = error(errmsg,1)
    DELETE  FROM dm_env_reltn d
     WHERE (d.parent_env_id=derd_request->env_list[del_cnt].parent_env_id)
      AND (d.child_env_id=derd_request->env_list[del_cnt].child_env_id)
      AND d.relationship_type=patstring(derd_request->env_list[del_cnt].relationship_type)
     WITH nocounter
    ;end delete
    SET err_code = error(errmsg,0)
    IF (err_code > 0)
     SET derd_reply->err_msg = errmsg
     SET derd_reply->err_num = err_code
     GO TO exit_program
    ENDIF
    IF ((derd_request->env_list[del_cnt].relationship_type="REFERENCE MERGE"))
     IF (del_env_is_parent=1)
      UPDATE  FROM dm_info di
       SET di.info_number = derd_request->env_list[del_cnt].child_env_id, di.info_char = trim(
         cnvtstring(derd_request->env_list[del_cnt].parent_env_id,20)), di.updt_cnt = (di.updt_cnt+ 1
        ),
        di.info_date = cnvtdatetime(curdate,curtime3), di.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        di.updt_id = reqinfo->updt_id,
        di.updt_applctx = reqinfo->updt_applctx, di.updt_task = reqinfo->updt_task
       WHERE di.info_domain="RDDS CONFIGURATION"
        AND di.info_name=concat("RELTN_ACTIVE:",trim(cnvtstring(derd_request->env_list[del_cnt].
          child_env_id,20)))
       WITH nocounter
      ;end update
      SET err_code = error(errmsg,0)
      IF (err_code > 0)
       SET derd_reply->err_msg = errmsg
       SET derd_reply->err_num = err_code
       GO TO exit_program
      ELSE
       IF (curqual=0)
        INSERT  FROM dm_info di
         SET di.info_domain = "RDDS CONFIGURATION", di.info_name = concat("RELTN_ACTIVE:",trim(
            cnvtstring(derd_request->env_list[del_cnt].child_env_id,20))), di.info_char = trim(
           cnvtstring(derd_request->env_list[del_cnt].parent_env_id,20)),
          di.info_number = derd_request->env_list[del_cnt].child_env_id, di.info_date = cnvtdatetime(
           curdate,curtime3), di.updt_dt_tm = cnvtdatetime(curdate,curtime3),
          di.updt_id = reqinfo->updt_id, di.updt_applctx = reqinfo->updt_applctx, di.updt_task =
          reqinfo->updt_task,
          di.updt_cnt = 0
         WITH nocounter
        ;end insert
        SET err_code = error(errmsg,0)
        IF (err_code > 0)
         SET derd_reply->err_msg = errmsg
         SET derd_reply->err_num = err_code
         GO TO exit_program
        ENDIF
       ENDIF
       COMMIT
      ENDIF
     ENDIF
     SET stat = alterlist(auto_ver_request->qual,1)
     SET auto_ver_request->qual[1].rdds_event = "Drop Environment Relation"
     SET auto_ver_request->qual[1].cur_environment_id = derd_request->env_list[del_cnt].parent_env_id
     SET auto_ver_request->qual[1].paired_environment_id = derd_request->env_list[del_cnt].
     child_env_id
     EXECUTE dm_rmc_auto_verify_setup
     IF ((auto_ver_reply->status="F"))
      ROLLBACK
      SET derd_reply->err_msg = auto_ver_reply->status_msg
      SET derd_reply->err_num = auto_ver_reply->status_err_code
      GO TO exit_program
     ENDIF
    ENDIF
    COMMIT
   ENDIF
 ENDFOR
#exit_program
 SET stat = initrec(auto_ver_request)
 SET stat = initrec(auto_ver_reply)
END GO
