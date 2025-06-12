CREATE PROGRAM dm_add_env_reltn:dba
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
 DECLARE request_size = i4 WITH protect
 DECLARE add_cnt = i4 WITH protect
 DECLARE daer_cnt = i4
 DECLARE daer_det_cnt = i4
 SET request_size = size(dera_request->env_list,5)
 FOR (add_cnt = 1 TO request_size)
   IF ((dera_request->child_env_id > 0))
    SET err_code = error(errmsg,1)
    INSERT  FROM dm_env_reltn d
     SET d.parent_env_id = dera_request->env_list[add_cnt].parent_env_id, d.child_env_id =
      dera_request->child_env_id, d.relationship_type = dera_request->env_list[add_cnt].
      relationship_type,
      d.post_link_name = dera_request->env_list[add_cnt].post_link_name, d.pre_link_name =
      dera_request->env_list[add_cnt].pre_link_name
     WITH nocounter
    ;end insert
    SET err_code = error(errmsg,0)
    IF (err_code > 0)
     SET dera_reply->err_msg = errmsg
     SET dera_reply->err_num = err_code
     GO TO exit_program
    ENDIF
    IF ((dera_request->env_list[add_cnt].relationship_type="REFERENCE MERGE"))
     SET stat = alterlist(auto_ver_request->qual,1)
     SET auto_ver_request->qual[1].rdds_event = "Add Environment Relation"
     SET auto_ver_request->qual[1].cur_environment_id = dera_request->env_list[add_cnt].parent_env_id
     SET auto_ver_request->qual[1].paired_environment_id = dera_request->env_list[add_cnt].
     child_env_id
     SET auto_ver_request->qual[1].event_reason = dera_request->env_list[add_cnt].event_reason
     EXECUTE dm_rmc_auto_verify_setup
    ENDIF
    IF ((((dera_request->env_list[add_cnt].relationship_type="AUTO CUTOVER")) OR ((dera_request->
    env_list[add_cnt].relationship_type="PLANNED CUTOVER"))) )
     SET stat = alterlist(auto_ver_request->qual,1)
     SET auto_ver_request->qual[1].rdds_event = "Auto/Planned Relationship Change"
     SET auto_ver_request->qual[1].cur_environment_id = dera_request->env_list[add_cnt].parent_env_id
     SET auto_ver_request->qual[1].paired_environment_id = dera_request->env_list[add_cnt].
     child_env_id
     SET auto_ver_request->qual[1].event_reason = dera_request->env_list[add_cnt].event_reason
     EXECUTE dm_rmc_auto_verify_setup
    ENDIF
    IF ((dera_request->env_list[add_cnt].relationship_type="RDDS MOVER CHANGES NOT LOGGED"))
     SET stat = alterlist(auto_ver_request->qual,1)
     SET auto_ver_request->qual[1].rdds_event = "Full Circle Relation Setup"
     SET auto_ver_request->qual[1].cur_environment_id = dera_request->env_list[add_cnt].parent_env_id
     SET auto_ver_request->qual[1].paired_environment_id = dera_request->env_list[add_cnt].
     child_env_id
     SET auto_ver_request->qual[1].event_reason = dera_request->env_list[add_cnt].event_reason
     EXECUTE dm_rmc_auto_verify_setup
    ENDIF
    IF ((((dera_request->env_list[add_cnt].relationship_type="PENDING TARGET AS MASTER")) OR ((
    dera_request->env_list[add_cnt].relationship_type="NO PENDING TARGET AS MASTER"))) )
     SET stat = alterlist(auto_ver_request->qual,1)
     SET auto_ver_request->qual[1].rdds_event = "PTAM Setting Change"
     SET auto_ver_request->qual[1].cur_environment_id = dera_request->env_list[add_cnt].parent_env_id
     SET auto_ver_request->qual[1].paired_environment_id = dera_request->env_list[add_cnt].
     child_env_id
     SET auto_ver_request->qual[1].event_reason = dera_request->env_list[add_cnt].event_reason
     SET stat = alterlist(auto_ver_request->qual[1].detail_qual,1)
     SET auto_ver_request->qual[1].detail_qual[1].event_detail1_txt = dera_request->env_list[add_cnt]
     .relationship_type
     EXECUTE dm_rmc_auto_verify_setup
    ENDIF
    IF ((((dera_request->env_list[add_cnt].relationship_type="BLOCK DUAL BUILD")) OR ((dera_request->
    env_list[add_cnt].relationship_type="ALLOW DUAL BUILD"))) )
     SET stat = alterlist(auto_ver_request->qual,1)
     SET auto_ver_request->qual[1].rdds_event = "Dual Build Trigger Change"
     SET auto_ver_request->qual[1].cur_environment_id = dera_request->env_list[add_cnt].child_env_id
     SET auto_ver_request->qual[1].paired_environment_id = dera_request->env_list[add_cnt].
     parent_env_id
     SET auto_ver_request->qual[1].event_reason = dera_request->env_list[add_cnt].event_reason
     SET stat = alterlist(auto_ver_request->qual[1].detail_qual,1)
     SET auto_ver_request->qual[1].detail_qual[1].event_detail1_txt = "INFO_NUMBER value"
     SET auto_ver_request->qual[1].detail_qual[1].event_detail2_txt = dera_request->env_list[add_cnt]
     .relationship_type
     IF ((dera_request->env_list[add_cnt].relationship_type="BLOCK DUAL BUILD"))
      SET auto_ver_request->qual[1].detail_qual[1].event_value = 1
     ELSE
      SET auto_ver_request->qual[1].detail_qual[1].event_value = 0
     ENDIF
     EXECUTE dm_rmc_auto_verify_setup
    ENDIF
    IF ((auto_ver_reply->status="F"))
     ROLLBACK
     SET dera_reply->err_msg = auto_ver_reply->status_msg
     SET dera_reply->err_num = auto_ver_reply->status_err_code
     GO TO exit_program
    ENDIF
    SET stat = initrec(auto_ver_request)
    SET stat = initrec(auto_ver_reply)
    COMMIT
   ELSE
    SET err_code = error(errmsg,1)
    INSERT  FROM dm_env_reltn d
     SET d.parent_env_id = dera_request->env_list[add_cnt].parent_env_id, d.child_env_id =
      dera_request->env_list[add_cnt].child_env_id, d.relationship_type = dera_request->env_list[
      add_cnt].relationship_type,
      d.post_link_name = dera_request->env_list[add_cnt].post_link_name, d.pre_link_name =
      dera_request->env_list[add_cnt].pre_link_name
     WITH nocounter
    ;end insert
    SET err_code = error(errmsg,0)
    IF (err_code > 0)
     SET dera_reply->err_msg = errmsg
     SET dera_reply->err_num = err_code
     GO TO exit_program
    ENDIF
    IF ((dera_request->env_list[add_cnt].relationship_type="REFERENCE MERGE"))
     SET stat = alterlist(auto_ver_request->qual,1)
     SET auto_ver_request->qual[1].rdds_event = "Add Environment Relation"
     SET auto_ver_request->qual[1].cur_environment_id = dera_request->env_list[add_cnt].parent_env_id
     SET auto_ver_request->qual[1].paired_environment_id = dera_request->env_list[add_cnt].
     child_env_id
     SET auto_ver_request->qual[1].event_reason = dera_request->env_list[add_cnt].event_reason
     EXECUTE dm_rmc_auto_verify_setup
    ENDIF
    IF ((((dera_request->env_list[add_cnt].relationship_type="AUTO CUTOVER")) OR ((dera_request->
    env_list[add_cnt].relationship_type="PLANNED CUTOVER"))) )
     SET stat = alterlist(auto_ver_request->qual,1)
     SET auto_ver_request->qual[1].rdds_event = "Auto/Planned Relationship Change"
     SET auto_ver_request->qual[1].cur_environment_id = dera_request->env_list[add_cnt].parent_env_id
     SET auto_ver_request->qual[1].paired_environment_id = dera_request->env_list[add_cnt].
     child_env_id
     SET auto_ver_request->qual[1].event_reason = dera_request->env_list[add_cnt].event_reason
     EXECUTE dm_rmc_auto_verify_setup
    ENDIF
    IF ((dera_request->env_list[add_cnt].relationship_type="RDDS MOVER CHANGES NOT LOGGED"))
     SET stat = alterlist(auto_ver_request->qual,1)
     SET auto_ver_request->qual[1].rdds_event = "Full Circle Relation Setup"
     SET auto_ver_request->qual[1].cur_environment_id = dera_request->env_list[add_cnt].parent_env_id
     SET auto_ver_request->qual[1].paired_environment_id = dera_request->env_list[add_cnt].
     child_env_id
     SET auto_ver_request->qual[1].event_reason = dera_request->env_list[add_cnt].event_reason
     EXECUTE dm_rmc_auto_verify_setup
    ENDIF
    IF ((((dera_request->env_list[add_cnt].relationship_type="PENDING TARGET AS MASTER")) OR ((
    dera_request->env_list[add_cnt].relationship_type="NO PENDING TARGET AS MASTER"))) )
     SET stat = alterlist(auto_ver_request->qual,1)
     SET auto_ver_request->qual[1].rdds_event = "PTAM Setting Change"
     SET auto_ver_request->qual[1].cur_environment_id = dera_request->env_list[add_cnt].parent_env_id
     SET auto_ver_request->qual[1].paired_environment_id = dera_request->env_list[add_cnt].
     child_env_id
     SET auto_ver_request->qual[1].event_reason = dera_request->env_list[add_cnt].event_reason
     SET stat = alterlist(auto_ver_request->qual[1].detail_qual,1)
     SET auto_ver_request->qual[1].detail_qual[1].event_detail1_txt = dera_request->env_list[add_cnt]
     .relationship_type
     EXECUTE dm_rmc_auto_verify_setup
    ENDIF
    IF ((((dera_request->env_list[add_cnt].relationship_type="BLOCK DUAL BUILD")) OR ((dera_request->
    env_list[add_cnt].relationship_type="ALLOW DUAL BUILD"))) )
     SET stat = alterlist(auto_ver_request->qual,1)
     SET auto_ver_request->qual[1].rdds_event = "Dual Build Trigger Change"
     SET auto_ver_request->qual[1].cur_environment_id = dera_request->env_list[add_cnt].child_env_id
     SET auto_ver_request->qual[1].paired_environment_id = dera_request->env_list[add_cnt].
     parent_env_id
     SET auto_ver_request->qual[1].event_reason = dera_request->env_list[add_cnt].event_reason
     SET stat = alterlist(auto_ver_request->qual[1].detail_qual,1)
     SET auto_ver_request->qual[1].detail_qual[1].event_detail1_txt = "DM_ENV_RELTN Change"
     SET auto_ver_request->qual[1].detail_qual[1].event_detail2_txt = dera_request->env_list[add_cnt]
     .relationship_type
     IF ((dera_request->env_list[add_cnt].relationship_type="BLOCK DUAL BUILD"))
      SET auto_ver_request->qual[1].detail_qual[1].event_value = 1
     ELSE
      SET auto_ver_request->qual[1].detail_qual[1].event_value = 0
     ENDIF
     EXECUTE dm_rmc_auto_verify_setup
    ENDIF
    IF ((auto_ver_reply->status="F"))
     ROLLBACK
     SET dera_reply->err_msg = auto_ver_reply->status_msg
     SET dera_reply->err_num = error(auto_ver_reply->status_msg,0)
     GO TO exit_program
    ENDIF
    SET stat = initrec(auto_ver_request)
    SET stat = initrec(auto_ver_reply)
    COMMIT
   ENDIF
 ENDFOR
#exit_program
END GO
