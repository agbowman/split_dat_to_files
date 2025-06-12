CREATE PROGRAM dep_end_state:dba
 FREE RECORD target_es
 RECORD target_es(
   1 null_commit_dt_tms[*]
     2 end_state_id = f8
     2 end_state_name = vc
     2 platform_cd = f8
 )
 SET current_ind = 1
 SET target_ind = 0
 DECLARE current_commit_dt_tm = dq8 WITH protect, noconstant
 SET readme_data->status = "F"
 SET readme_data->message = "Beginning readme to update dep_end_state"
 SELECT INTO "nl:"
  FROM dep_end_state des,
   (dummyt d1  WITH seq = value(size(requestin->list_0,5)))
  PLAN (d1)
   JOIN (des
   WHERE cnvtlower(des.end_state_name)=cnvtlower(requestin->list_0[d1.seq].end_state_name)
    AND des.platform_cd=cnvtreal(requestin->list_0[d1.seq].platform_cd)
    AND des.dep_env_id=dep_env_id)
  DETAIL
   requestin->list_0[d1.seq].exists_ind = "1"
  WITH nocounter
 ;end select
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during dep_end_state SELECT:",string_struct_c->
   ms_err_msg)
  GO TO enditnow
 ENDIF
 INSERT  FROM dep_end_state des,
   (dummyt d1  WITH seq = value(size(requestin->list_0,5)))
  SET des.end_state_id = seq(dm_seq,nextval), des.end_state_name = cnvtlower(requestin->list_0[d1.seq
    ].end_state_name), des.platform_cd = cnvtreal(requestin->list_0[d1.seq].platform_cd),
   des.is_id = cnvtreal(requestin->list_0[d1.seq].is_id), des.dep_env_id = dep_env_id, des
   .last_update_dt_tm = sysdate,
   des.last_commit_dt_tm = sysdate, des.current_ind = 0, des.exclude_ind = cnvtreal(requestin->
    list_0[d1.seq].exclude_ind)
  PLAN (d1
   WHERE (requestin->list_0[d1.seq].exists_ind != "1"))
   JOIN (des)
  WITH nocounter
 ;end insert
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during dep_end_state INSERT current_ind 0:",
   string_struct_c->ms_err_msg)
  GO TO enditnow
 ENDIF
 INSERT  FROM dep_end_state des,
   (dummyt d1  WITH seq = value(size(requestin->list_0,5)))
  SET des.end_state_id = seq(dm_seq,nextval), des.end_state_name = cnvtlower(requestin->list_0[d1.seq
    ].end_state_name), des.platform_cd = cnvtreal(requestin->list_0[d1.seq].platform_cd),
   des.is_id = cnvtreal(requestin->list_0[d1.seq].is_id), des.dep_env_id = dep_env_id, des
   .last_update_dt_tm = sysdate,
   des.last_commit_dt_tm = sysdate, des.current_ind = 1, des.exclude_ind = cnvtreal(requestin->
    list_0[d1.seq].exclude_ind)
  PLAN (d1
   WHERE (requestin->list_0[d1.seq].exists_ind != "1"))
   JOIN (des)
  WITH nocounter
 ;end insert
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during dep_end_state INSERT current_ind 1:",
   string_struct_c->ms_err_msg)
  GO TO enditnow
 ENDIF
 UPDATE  FROM dep_end_state des,
   (dummyt d1  WITH seq = value(size(requestin->list_0,5)))
  SET des.exclude_ind = cnvtreal(requestin->list_0[d1.seq].exclude_ind)
  PLAN (d1
   WHERE (requestin->list_0[d1.seq].exists_ind="1"))
   JOIN (des
   WHERE cnvtlower(des.end_state_name)=cnvtlower(requestin->list_0[d1.seq].end_state_name)
    AND des.platform_cd=cnvtreal(requestin->list_0[d1.seq].platform_cd)
    AND des.dep_env_id=dep_env_id)
  WITH nocounter
 ;end update
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during dep_end_state UPDATE:",string_struct_c->
   ms_err_msg)
  GO TO enditnow
 ENDIF
 SELECT INTO "nl:"
  des.end_state_id, des.end_state_name, des.platform_cd
  FROM dep_end_state des
  WHERE des.dep_env_id=dep_env_id
   AND des.current_ind=target_ind
   AND des.last_commit_dt_tm=null
  HEAD REPORT
   stat = alterlist(target_es->null_commit_dt_tms,1000), count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,1000)=1
    AND count1 > 1000)
    stat = alterlist(target_es->null_commit_dt_tms,(count1+ 999))
   ENDIF
   target_es->null_commit_dt_tms[count1].end_state_id = des.end_state_id, target_es->
   null_commit_dt_tms[count1].end_state_name = des.end_state_name, target_es->null_commit_dt_tms[
   count1].platform_cd = des.platform_cd
  FOOT REPORT
   stat = alterlist(target_es->null_commit_dt_tms,count1)
  WITH nocounter
 ;end select
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat(
   "Failure during dep_end_state SELECT null target last_commit_dt_tm:",string_struct_c->ms_err_msg)
  GO TO enditnow
 ENDIF
 SET target_length = size(target_es->null_commit_dt_tms,5)
 FOR (target_index = 1 TO target_length)
   SELECT INTO "nl:"
    des.last_commit_dt_tm
    FROM dep_end_state des
    WHERE des.dep_env_id=dep_env_id
     AND des.current_ind=current_ind
     AND (des.end_state_name=target_es->null_commit_dt_tms[target_index].end_state_name)
     AND (des.platform_cd=target_es->null_commit_dt_tms[target_index].platform_cd)
    DETAIL
     current_commit_dt_tm = cnvtdatetime(des.last_commit_dt_tm)
    WITH nocounter
   ;end select
   IF (error(string_struct_c->ms_err_msg,0) != 0)
    SET readme_data->message = concat(
     "Failure during dep_end_state SELECT current last_commit_dt_tm:",string_struct_c->ms_err_msg)
    GO TO enditnow
   ENDIF
   IF (curqual != 0)
    UPDATE  FROM dep_end_state des
     SET des.last_commit_dt_tm = cnvtdatetime(current_commit_dt_tm)
     WHERE (des.end_state_id=target_es->null_commit_dt_tms[target_index].end_state_id)
     WITH nocounter
    ;end update
    IF (error(string_struct_c->ms_err_msg,0) != 0)
     SET readme_data->message = concat(
      "Failure during dep_end_state UPDATE target last_commit_dt_tm:",string_struct_c->ms_err_msg)
     GO TO enditnow
    ENDIF
   ENDIF
 ENDFOR
 SET readme_data->status = "S"
 SET readme_data->message =
 "EUC dep_end_state exclude indicator and target last_commit_dt_tm inserted successfully"
#enditnow
 IF ((readme_data->status="S"))
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
END GO
