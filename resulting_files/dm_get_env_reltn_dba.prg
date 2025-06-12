CREATE PROGRAM dm_get_env_reltn:dba
 DECLARE get_cnt = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 DECLARE kid_cnt = i4 WITH protect, noconstant(0)
 SET err_code = error(errmsg,1)
 SELECT INTO "nl:"
  der.child_env_id, de.environment_name
  FROM dm_env_reltn der,
   dm_environment de
  WHERE de.environment_id=der.parent_env_id
   AND der.relationship_type=patstring(derg_request->relationship_type)
   AND (der.child_env_id=derg_request->env_id)
  DETAIL
   get_cnt = (get_cnt+ 1)
   IF (mod(get_cnt,10)=1)
    stat = alterlist(derg_reply->parent_env_list,(get_cnt+ 9))
   ENDIF
   derg_reply->parent_env_list[get_cnt].env_id = der.parent_env_id, derg_reply->parent_env_list[
   get_cnt].env_name = de.environment_name, derg_reply->parent_env_list[get_cnt].post_link_name = der
   .post_link_name,
   derg_reply->parent_env_list[get_cnt].pre_link_name = der.pre_link_name
  FOOT REPORT
   stat = alterlist(derg_reply->parent_env_list,get_cnt)
  WITH nocounter
 ;end select
 SET err_code = error(errmsg,0)
 IF (err_code > 0)
  SET derg_reply->err_num = 1
  SET derg_reply->err_msg = errmsg
  GO TO exit_program
 ENDIF
 SET err_code = error(errmsg,1)
 SELECT INTO "nl:"
  der.child_env_id, de.environment_name
  FROM dm_env_reltn der,
   dm_environment de
  WHERE de.environment_id=der.child_env_id
   AND der.relationship_type=patstring(derg_request->relationship_type)
   AND (der.parent_env_id=derg_request->env_id)
  DETAIL
   kid_cnt = (kid_cnt+ 1)
   IF (mod(kid_cnt,10)=1)
    stat = alterlist(derg_reply->child_env_list,(kid_cnt+ 9))
   ENDIF
   derg_reply->child_env_list[kid_cnt].env_id = der.child_env_id, derg_reply->child_env_list[kid_cnt]
   .env_name = de.environment_name, derg_reply->child_env_list[kid_cnt].post_link_name = der
   .post_link_name,
   derg_reply->child_env_list[kid_cnt].pre_link_name = der.pre_link_name
  FOOT REPORT
   stat = alterlist(derg_reply->child_env_list,kid_cnt)
  WITH nocounter
 ;end select
 SET err_code = error(errmsg,0)
 IF (err_code > 0)
  SET derg_reply->err_num = 1
  SET derg_reply->err_msg = errmsg
  GO TO exit_program
 ENDIF
#exit_program
END GO
