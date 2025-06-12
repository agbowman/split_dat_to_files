CREATE PROGRAM dm2_arc_person_mover:dba
 DECLARE arc_error_check(error_header=vc,direction=vc,archive_entity_name=vc) = i2
 DECLARE arc_log_insert(error_header=vc,errormsg=vc,direction=vc,archive_entity_name=vc,
  archive_entity_id=f8,
  run_secs=i4) = null
 DECLARE outside_time_window(null) = i2
 DECLARE stop_at_next_check(mover_name=vc) = i2
 DECLARE arc_replace(stmt_str=vc,link_ind=i2,list_ind=i2,entity_ind=i2,pre_link=vc,
  post_link=vc,entity_id=f8) = vc
 DECLARE update_time_window(null) = i2
 IF (validate(errormsg,"-1")="-1")
  DECLARE errormsg = vc
 ENDIF
 SUBROUTINE arc_error_check(error_header,direction,archive_entity_name)
   IF (error(errormsg,0) != 0)
    ROLLBACK
    SET reply->status_data.subeventstatus.targetobjectvalue = errormsg
    SET reply->status_data.status = "F"
    CALL arc_log_insert(error_header,errormsg,direction,archive_entity_name,0.0,
     null)
    COMMIT
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE arc_log_insert(error_header,errormsg,direction,archive_entity_name,archive_entity_id,
  run_secs)
   INSERT  FROM dm_arc_log d
    SET d.dm_arc_log_id = seq(archive_seq,nextval), d.archive_entity_id = archive_entity_id, d
     .run_secs = run_secs,
     d.log_dt_tm = cnvtdatetime(curdate,curtime3), d.direction = direction, d.err_msg = trim(
      substring(1,255,concat(curprog,": ",error_header," ",errormsg))),
     d.archive_entity_name = archive_entity_name, d.instigator_app = reqinfo->updt_app, d
     .instigator_task = reqinfo->updt_task,
     d.instigator_req = reqinfo->updt_req, d.instigator_id = reqinfo->updt_id, d.instigator_applctx
      = reqinfo->updt_applctx,
     d.rdbhandle = currdbhandle, d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task,
     d.updt_applctx = reqinfo->updt_applctx, d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d
     .updt_cnt = 0
    WITH nocounter
   ;end insert
 END ;Subroutine
 SUBROUTINE outside_time_window(null)
   IF ( NOT ((((pers_arc->start_time > pers_arc->stop_time)
    AND (((cnvtmin(curtime) < pers_arc->stop_time)) OR ((cnvtmin(curtime) > pers_arc->start_time))) )
    OR ((((pers_arc->start_time < pers_arc->stop_time)
    AND (cnvtmin(curtime) < pers_arc->stop_time)
    AND (cnvtmin(curtime) > pers_arc->start_time)) OR ((pers_arc->start_time=pers_arc->stop_time)))
   )) ))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE stop_at_next_check(mover_name)
   DECLARE s_mover_state = vc
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="ARCHIVE-PERSON"
     AND d.info_name=mover_name
    DETAIL
     s_mover_state = d.info_char
    WITH nocounter
   ;end select
   IF (arc_error_check("An error occurred while selecting from dm_info: ","ARCHIVE","PERSON")=1)
    RETURN(1)
   ENDIF
   IF (s_mover_state="STOP AT NEXT CHECK")
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE arc_replace(arc_stmt_str,arc_link_ind,arc_list_ind,arc_entity_ind,arc_pre_link,
  arc_post_link,arc_entity_id)
   DECLARE s_arc_return_str = vc
   SET s_arc_return_str = arc_stmt_str
   IF (arc_link_ind=1)
    SET s_arc_return_str = replace(s_arc_return_str,":pre_link:",nullterm(arc_pre_link),0)
    SET s_arc_return_str = replace(s_arc_return_str,":post_link:",nullterm(arc_post_link),0)
   ENDIF
   IF (arc_list_ind=1)
    SET s_arc_return_str = replace(s_arc_return_str,"list","",0)
   ENDIF
   IF (arc_entity_ind=1)
    SET s_arc_return_str = replace(s_arc_return_str,"v_archive_entity_id",build(arc_entity_id),0)
    SET s_arc_return_str = replace(s_arc_return_str,"V_ARCHIVE_ENTITY_ID",build(arc_entity_id),0)
   ENDIF
   RETURN(s_arc_return_str)
 END ;Subroutine
 SUBROUTINE update_time_window(null)
  SELECT INTO "nl:"
   di.info_name, di.info_number
   FROM dm_arc_info di
   WHERE di.info_domain="ARCHIVE-PERSON"
    AND cnvtdatetime(curdate,curtime3) BETWEEN beg_effective_dt_tm AND end_effective_dt_tm
   DETAIL
    CASE (di.info_name)
     OF "START AFTER TIME":
      pers_arc->start_time = di.info_number
     OF "STOP BY TIME":
      pers_arc->stop_time = di.info_number
    ENDCASE
   WITH nocounter
  ;end select
  IF (arc_error_check("In dm2_arc_person.inc when retrieving dm_arc_info rows: ","ARCHIVE","PERSON")=
  1)
   RETURN(0)
  ELSE
   RETURN(1)
  ENDIF
 END ;Subroutine
 IF (validate(danc_request->batch_selection,"-1")="-1")
  FREE RECORD danc_request
  RECORD danc_request(
    1 batch_selection = vc
    1 cons_prefix = vc
    1 all_tab_ind = i2
  )
 ENDIF
 IF ((validate(danc_reply->found_ind,- (1))=- (1)))
  FREE RECORD danc_reply
  RECORD danc_reply(
    1 found_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF ((validate(damp_request->restore,- (1))=- (1)))
  RECORD damp_request(
    1 restore[*]
      2 person_id = f8
      2 archive_env_id = f8
      2 all_tab_ind = i2
    1 archive[*]
      2 person_id = f8
      2 archive_env_id = f8
    1 mover_name = vc
  )
 ENDIF
 IF (validate(damp_reply->status_data.status,"X")="X")
  RECORD damp_reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF (validate(reply->status_data.status,"X")="X")
  FREE RECORD reply
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE v_last_schema = f8
 DECLARE v_last_gen = f8
 DECLARE v_last_date = f8
 DECLARE v_beg_date = f8
 DECLARE v_prog_start = dq8
 DECLARE v_continue_restore = i2
 DECLARE v_exp_ndx = i4
 DECLARE v_ora_err = vc
 DECLARE c_day_range = i4 WITH constant(5)
 DECLARE c_max_per_query = i4 WITH constant(30)
 SET v_prog_start = sysdate
 SELECT INTO "nl:"
  i.info_date
  FROM dm_info i
  WHERE i.info_name="USERLASTUPDT"
   AND i.info_domain="DATA MANAGEMENT"
  DETAIL
   v_last_schema = i.info_date
  WITH nocounter
 ;end select
 IF (arc_error_check("An error occurred while retrieving last schema applied date: ","ARCHIVE",
  "PERSON")=1)
  GO TO end_program
 ENDIF
 SELECT INTO "nl:"
  di.info_date
  FROM dm_info di
  WHERE di.info_domain="ARCHIVE-PERSON"
   AND di.info_name="LAST NEW CONSTRAINTS GEN"
  DETAIL
   v_last_gen = di.info_date
  WITH nocounter
 ;end select
 IF (arc_error_check("An error occurred while retrieving last constraints gen date: ","ARCHIVE",
  "PERSON")=1)
  GO TO end_program
 ENDIF
 IF (((curqual=0) OR (v_last_gen < v_last_schema)) )
  SET danc_request->batch_selection = "PERSON"
  SET danc_request->cons_prefix = "XARC"
  SET danc_request->all_tab_ind = 0
  EXECUTE dm2_arc_new_constraints  WITH replace("REQUEST","DANC_REQUEST"), replace("REPLY",
   "DANC_REPLY")
  IF ((danc_reply->status_data.status="F"))
   SET reply->status_data.status = "F"
   GO TO end_program
  ENDIF
  IF ((danc_reply->found_ind=1))
   FREE RECORD pers_arc
   UPDATE  FROM dm_info d
    SET d.info_date = cnvtdatetime(curdate,curtime3), d.updt_cnt = (d.updt_cnt+ 1), d.updt_id =
     reqinfo->updt_id,
     d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->updt_applctx, d.updt_dt_tm =
     cnvtdatetime(curdate,curtime3)
    WHERE d.info_domain="ARCHIVE-PERSON"
     AND d.info_name="LAST NEW CONSTRAINTS GEN"
    WITH nocounter
   ;end update
   IF (arc_error_check("An error occurred while updating dm_info: ","ARCHIVE","PERSON")=1)
    GO TO end_program
   ELSEIF (curqual=0)
    INSERT  FROM dm_info d
     SET d.info_domain = "ARCHIVE-PERSON", d.info_name = "LAST NEW CONSTRAINTS GEN", d.info_date =
      cnvtdatetime(curdate,curtime3),
      d.updt_cnt = 0, d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task,
      d.updt_applctx = reqinfo->updt_applctx, d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
    IF (arc_error_check("An error occurred while inserting into dm_info: ","ARCHIVE","PERSON")=1)
     GO TO end_program
    ELSE
     COMMIT
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 IF ((reqinfo->updt_task=0))
  SET reqinfo->updt_task = 4320001
 ENDIF
 IF ((validate(pers_arc->stale_days,- (1))=- (1)))
  RECORD pers_arc(
    1 stale_days = f8
    1 next_restore_offset = f8
    1 active_archive_env_id = f8
    1 start_time = i4
    1 stop_time = i4
    1 num_movers = f8
    1 being_restored = f8
    1 being_archived = f8
    1 archived = f8
    1 statements[*]
      2 table_name = vc
      2 archive_insert[*]
        3 stmt = vc
        3 link_ind = i2
        3 arc_entity_ind = i2
        3 list_ind = i2
        3 from_ind = i2
      2 archive_delete[*]
        3 stmt = vc
        3 link_ind = i2
        3 arc_entity_ind = i2
        3 list_ind = i2
      2 restore_insert[*]
        3 stmt = vc
        3 link_ind = i2
        3 arc_entity_ind = i2
        3 list_ind = i2
        3 from_ind = i2
      2 restore_delete[*]
        3 stmt = vc
        3 link_ind = i2
        3 arc_entity_ind = i2
        3 list_ind = i2
    1 active_pre_link_name = vc
    1 active_post_link_name = vc
    1 arc_db[*]
      2 post_link_name = vc
      2 pre_link_name = vc
      2 env_id = f8
    1 status = c1
  )
  DECLARE arc_set_indicators(i_arc_stmt=vc,link_ind=i2(ref),arc_entity_ind=i2(ref),list_ind=i2(ref))
   = i2
  DECLARE v_start_str = vc
  DECLARE v_arc_cv = i2
  DECLARE v_full_str1 = vc
  DECLARE v_full_str2 = vc
  DECLARE v_full_str3 = vc
  DECLARE v_full_str4 = vc
  SET v_arc_cv = 0
  SET pers_arc->being_restored = uar_get_code_by("MEANING",391571,"BEINGRESTORE")
  IF ((pers_arc->being_restored=0))
   SET v_arc_cv = 1
  ENDIF
  SET pers_arc->being_archived = uar_get_code_by("MEANING",391571,"BEINGARCHIVE")
  IF ((pers_arc->being_archived=0))
   SET v_arc_cv = 1
  ENDIF
  SET pers_arc->archived = uar_get_code_by("MEANING",391571,"ARCHIVED")
  IF ((pers_arc->archived=0))
   SET v_arc_cv = 1
  ENDIF
  IF (v_arc_cv=1)
   SELECT INTO "nl:"
    FROM code_value c
    WHERE c.code_set=391571
    DETAIL
     CASE (c.cdf_meaning)
      OF "BEINGRESTORE":
       pers_arc->being_restored = c.code_value
      OF "BEINGARCHIVE":
       pers_arc->being_archived = c.code_value
      OF "ARCHIVED":
       pers_arc->archived = c.code_value
     ENDCASE
    WITH nocounter
   ;end select
   IF (((arc_error_check("In dm2_arc_person.inc when retrieving code_values: ","ARCHIVE","PERSON")=1)
    OR ((((pers_arc->being_restored=0)) OR ((((pers_arc->being_archived=0)) OR ((pers_arc->archived=0
   ))) )) )) )
    SET pers_arc->status = "F"
    GO TO arc_person_exit
   ENDIF
  ENDIF
  SELECT INTO "nl:"
   di.info_number
   FROM dm_info di
   WHERE di.info_domain="ARCHIVE-PERSON"
    AND di.info_name="NUM MOVERS"
   DETAIL
    pers_arc->num_movers = di.info_number
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   di.info_name, di.info_number
   FROM dm_arc_info di
   WHERE di.info_domain="ARCHIVE-PERSON"
    AND cnvtdatetime(curdate,curtime3) BETWEEN beg_effective_dt_tm AND end_effective_dt_tm
   DETAIL
    CASE (di.info_name)
     OF "STALE DAYS":
      pers_arc->stale_days = di.info_number
     OF "NEXT RESTORE OFFSET":
      pers_arc->next_restore_offset = di.info_number
     OF "ACTIVE ARCHIVE":
      pers_arc->active_archive_env_id = di.info_number
     OF "START AFTER TIME":
      pers_arc->start_time = di.info_number
     OF "STOP BY TIME":
      pers_arc->stop_time = di.info_number
    ENDCASE
   WITH nocounter
  ;end select
  IF (arc_error_check("In dm2_arc_person.inc when retrieving dm_arc_info rows: ","ARCHIVE","PERSON")=
  1)
   SET pers_arc->status = "F"
   GO TO arc_person_exit
  ELSEIF (curqual=0)
   CALL arc_log_insert("In dm2_arc_person.inc: ","No Person Archive records found in DM_INFO",
    "ARCHIVE","PERSON",0.0,
    null)
   SET pers_arc->status = "F"
   GO TO arc_person_exit
  ELSEIF ((pers_arc->stale_days < 365))
   CALL arc_log_insert("In dm2_arc_person.inc: ",build("STALE_DAYS must be > 365, current value is: ",
     pers_arc->stale_days),"ARCHIVE","PERSON",0.0,
    null)
   SET pers_arc->status = "F"
   GO TO arc_person_exit
  ELSEIF ((pers_arc->next_restore_offset < 0))
   CALL arc_log_insert("In dm2_arc_person.inc: ",build(
     "NEXT_RESTORE_OFFSET must be > 0, current value is: ",pers_arc->next_restore_offset),"ARCHIVE",
    "PERSON",0.0,
    null)
   SET pers_arc->status = "F"
   GO TO arc_person_exit
  ENDIF
  SELECT INTO "nl:"
   er.child_env_id, er.post_link_name, er.pre_link_name
   FROM dm_arc_env er
   WHERE (er.env_id=pers_arc->active_archive_env_id)
   DETAIL
    pers_arc->active_pre_link_name = er.pre_link_name, pers_arc->active_post_link_name = er
    .post_link_name
   WITH nocounter
  ;end select
  IF (arc_error_check("In dm2_arc_person.inc when retrieving dm_arc_env rows: ","ARCHIVE","PERSON")=1
  )
   SET pers_arc->status = "F"
   GO TO arc_person_exit
  ELSEIF (curqual=0)
   CALL arc_log_insert("In dm2_arc_person.inc: ","active_archive_env_id not in DM_ARC_ENV","ARCHIVE",
    "PERSON",0.0,
    null)
   SET pers_arc->status = "F"
   GO TO arc_person_exit
  ENDIF
  SELECT INTO "nl:"
   er.post_link_name, er.pre_link_name, er.child_env_id
   FROM dm_arc_env er
   WHERE env_id > 0
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(pers_arc->arc_db,cnt), pers_arc->arc_db[cnt].env_id = er.env_id,
    pers_arc->arc_db[cnt].pre_link_name = er.pre_link_name, pers_arc->arc_db[cnt].post_link_name = er
    .post_link_name
   WITH nocounter
  ;end select
  IF (arc_error_check("In dm2_arc_person.inc when retrieving dm_env_reltn rows: ","ARCHIVE","PERSON")
  =1)
   SET pers_arc->status = "F"
   GO TO arc_person_exit
  ELSEIF (curqual=0)
   CALL arc_log_insert("In dm2_arc_person.inc: ","No Archive DB's found","ARCHIVE","PERSON",0.0,
    null)
   SET pers_arc->status = "F"
   GO TO arc_person_exit
  ELSEIF ((pers_arc->active_pre_link_name=""))
   IF ((pers_arc->active_post_link_name=""))
    CALL arc_log_insert("In dm2_arc_person.inc: ",concat(
      "Missing ACTIVE_[PRE,POST]_LINK_NAME for env_id: ",cnvtstring(pers_arc->active_archive_env_id)),
     "ARCHIVE","PERSON",0.0,
     null)
    GO TO arc_person_exit
   ENDIF
  ENDIF
  SELECT INTO "nl:"
   FROM dm_arc_constraints dac,
    user_tables ut
   WHERE dac.exclude_ind=0
    AND dac.long_col_ind=0
    AND dac.child_table=ut.table_name
    AND dac.arc_insert > " "
    AND dac.arc_delete > " "
    AND dac.rest_insert > " "
    AND dac.rest_delete > " "
   HEAD REPORT
    v_table_cnt = 0
   DETAIL
    v_full_str1 = trim(replace(dac.arc_insert,":cols:",trim(dac.column_list,3),0),3), v_full_str2 =
    dac.arc_delete, v_full_str3 = replace(dac.rest_insert,":cols:",trim(dac.column_list,3),0),
    v_full_str4 = dac.rest_delete, v_table_cnt = (v_table_cnt+ 1)
    IF (mod(v_table_cnt,10)=1)
     stat = alterlist(pers_arc->statements,(v_table_cnt+ 9))
    ENDIF
    v_from_ind = 0, v_start_pos = 1, v_end_pos = 0,
    v_ai_cnt = 0, v_continue = 1
    WHILE (v_continue=1)
      link_ind = 0, arc_entity_ind = 0, list_ind = 0,
      v_start_str = trim(substring(v_start_pos,130,v_full_str1),3)
      IF (findstring(",",v_start_str,1,1) > findstring(" ",v_start_str,1,1))
       v_end_pos = findstring(",",v_start_str,1,1)
      ELSE
       v_end_pos = findstring(" ",v_start_str,1,1)
      ENDIF
      IF (v_end_pos <= 1)
       v_continue = 0, v_end_pos = 3
      ENDIF
      v_ai_cnt = (v_ai_cnt+ 1)
      IF (mod(v_ai_cnt,10)=1)
       stat = alterlist(pers_arc->statements[v_table_cnt].archive_insert,(v_ai_cnt+ 9))
      ENDIF
      pers_arc->statements[v_table_cnt].archive_insert[v_ai_cnt].stmt = substring(v_start_pos,
       v_end_pos,v_full_str1),
      CALL arc_set_indicators(pers_arc->statements[v_table_cnt].archive_insert[v_ai_cnt].stmt,
      link_ind,arc_entity_ind,list_ind), pers_arc->statements[v_table_cnt].archive_insert[v_ai_cnt].
      link_ind = link_ind,
      pers_arc->statements[v_table_cnt].archive_insert[v_ai_cnt].arc_entity_ind = arc_entity_ind,
      pers_arc->statements[v_table_cnt].archive_insert[v_ai_cnt].list_ind = list_ind
      IF (v_from_ind=0
       AND findstring("from",pers_arc->statements[v_table_cnt].archive_insert[v_ai_cnt].stmt,1) > 0)
       pers_arc->statements[v_table_cnt].archive_insert[v_ai_cnt].from_ind = 1, v_from_ind = 1
      ENDIF
      v_start_pos = (v_start_pos+ v_end_pos)
    ENDWHILE
    v_start_pos = 1, v_end_pos = 0, v_ad_cnt = 0,
    v_continue = 1
    WHILE (v_continue=1)
      link_ind = 0, arc_entity_ind = 0, list_ind = 0,
      v_start_str = substring(v_start_pos,130,v_full_str2)
      IF (findstring(",",v_start_str,1,1) > findstring(" ",v_start_str,1,1))
       v_end_pos = findstring(",",v_start_str,1,1)
      ELSE
       v_end_pos = findstring(" ",v_start_str,1,1)
      ENDIF
      IF (v_end_pos <= 1)
       v_continue = 0, v_end_pos = 3
      ENDIF
      v_ad_cnt = (v_ad_cnt+ 1)
      IF (mod(v_ad_cnt,10)=1)
       stat = alterlist(pers_arc->statements[v_table_cnt].archive_delete,(v_ad_cnt+ 9))
      ENDIF
      pers_arc->statements[v_table_cnt].archive_delete[v_ad_cnt].stmt = substring(v_start_pos,
       v_end_pos,v_full_str2),
      CALL arc_set_indicators(pers_arc->statements[v_table_cnt].archive_delete[v_ad_cnt].stmt,
      link_ind,arc_entity_ind,list_ind), pers_arc->statements[v_table_cnt].archive_delete[v_ad_cnt].
      link_ind = link_ind,
      pers_arc->statements[v_table_cnt].archive_delete[v_ad_cnt].arc_entity_ind = arc_entity_ind,
      pers_arc->statements[v_table_cnt].archive_delete[v_ad_cnt].list_ind = list_ind, v_start_pos = (
      v_start_pos+ v_end_pos)
    ENDWHILE
    v_from_ind = 0, v_start_pos = 1, v_end_pos = 0,
    v_ri_cnt = 0, v_continue = 1
    WHILE (v_continue=1)
      link_ind = 0, arc_entity_ind = 0, list_ind = 0,
      v_start_str = substring(v_start_pos,130,v_full_str3)
      IF (findstring(",",v_start_str,1,1) > findstring(" ",v_start_str,1,1))
       v_end_pos = findstring(",",v_start_str,1,1)
      ELSE
       v_end_pos = findstring(" ",v_start_str,1,1)
      ENDIF
      IF (v_end_pos <= 1)
       v_continue = 0, v_end_pos = 3
      ENDIF
      v_ri_cnt = (v_ri_cnt+ 1)
      IF (mod(v_ri_cnt,10)=1)
       stat = alterlist(pers_arc->statements[v_table_cnt].restore_insert,(v_ri_cnt+ 9))
      ENDIF
      pers_arc->statements[v_table_cnt].restore_insert[v_ri_cnt].stmt = substring(v_start_pos,
       v_end_pos,v_full_str3),
      CALL arc_set_indicators(pers_arc->statements[v_table_cnt].restore_insert[v_ri_cnt].stmt,
      link_ind,arc_entity_ind,list_ind), pers_arc->statements[v_table_cnt].restore_insert[v_ri_cnt].
      link_ind = link_ind,
      pers_arc->statements[v_table_cnt].restore_insert[v_ri_cnt].arc_entity_ind = arc_entity_ind,
      pers_arc->statements[v_table_cnt].restore_insert[v_ri_cnt].list_ind = list_ind
      IF (v_from_ind=0
       AND findstring("from",pers_arc->statements[v_table_cnt].restore_insert[v_ri_cnt].stmt,1) > 0)
       pers_arc->statements[v_table_cnt].restore_insert[v_ri_cnt].from_ind = 1, v_from_ind = 1
      ENDIF
      v_start_pos = (v_start_pos+ v_end_pos)
    ENDWHILE
    v_start_pos = 1, v_end_pos = 0, v_rd_cnt = 0,
    v_continue = 1
    WHILE (v_continue=1)
      link_ind = 0, arc_entity_ind = 0, list_ind = 0,
      v_start_str = substring(v_start_pos,130,v_full_str4)
      IF (findstring(",",v_start_str,1,1) > findstring(" ",v_start_str,1,1))
       v_end_pos = findstring(",",v_start_str,1,1)
      ELSE
       v_end_pos = findstring(" ",v_start_str,1,1)
      ENDIF
      IF (v_end_pos <= 1)
       v_continue = 0, v_end_pos = 3
      ENDIF
      v_rd_cnt = (v_rd_cnt+ 1)
      IF (mod(v_rd_cnt,10)=1)
       stat = alterlist(pers_arc->statements[v_table_cnt].restore_delete,(v_rd_cnt+ 9))
      ENDIF
      pers_arc->statements[v_table_cnt].restore_delete[v_rd_cnt].stmt = substring(v_start_pos,
       v_end_pos,v_full_str4),
      CALL arc_set_indicators(pers_arc->statements[v_table_cnt].restore_delete[v_rd_cnt].stmt,
      link_ind,arc_entity_ind,list_ind), pers_arc->statements[v_table_cnt].restore_delete[v_rd_cnt].
      link_ind = link_ind,
      pers_arc->statements[v_table_cnt].restore_delete[v_rd_cnt].arc_entity_ind = arc_entity_ind,
      pers_arc->statements[v_table_cnt].restore_delete[v_rd_cnt].list_ind = list_ind, v_start_pos = (
      v_start_pos+ v_end_pos)
    ENDWHILE
    stat = alterlist(pers_arc->statements[v_table_cnt].archive_insert,v_ai_cnt), stat = alterlist(
     pers_arc->statements[v_table_cnt].archive_delete,v_ad_cnt), stat = alterlist(pers_arc->
     statements[v_table_cnt].restore_insert,v_ri_cnt),
    stat = alterlist(pers_arc->statements[v_table_cnt].restore_delete,v_rd_cnt), pers_arc->
    statements[v_table_cnt].table_name = substring((findstring(":pre_link:",dac.arc_insert)+ 10),((
     findstring(":post_link:",dac.arc_insert) - findstring(":pre_link:",dac.arc_insert)) - 10),dac
     .arc_insert)
   FOOT REPORT
    stat = alterlist(pers_arc->statements,v_table_cnt)
   WITH nocounter
  ;end select
  IF (arc_error_check("In dm2_arc_person.inc when retrieving dm_arc_constraints rows: ","ARCHIVE",
   "PERSON")=1)
   SET pers_arc->status = "F"
   GO TO arc_person_exit
  ELSEIF (curqual=0)
   CALL arc_log_insert("In dm2_arc_person.inc: ",
    "No Insert and Delete statements found in dm_arc_constraints","ARCHIVE","PERSON",0.0,
    null)
   SET pers_arc->status = "F"
   GO TO arc_person_exit
  ENDIF
 ENDIF
 SET pers_arc->status = "S"
 SUBROUTINE db_search(i_db_env_id)
   DECLARE s_env_ndx = i4 WITH noconstant(0)
   FOR (tn_ndx = 1 TO size(pers_arc->arc_db,5))
     IF ((pers_arc->arc_db[tn_ndx].env_id=i_db_env_id))
      SET s_env_ndx = tn_ndx
      SET tn_ndx = (size(pers_arc->arc_db,5)+ 1)
     ENDIF
   ENDFOR
   RETURN(s_env_ndx)
 END ;Subroutine
 SUBROUTINE arc_set_indicators(i_arc_stmt,link_ind,arc_entity_ind,list_ind)
   IF (findstring("pre_link",i_arc_stmt,1) > 0)
    SET link_ind = 1
   ENDIF
   IF (((findstring("v_archive_entity_id",i_arc_stmt,1) > 0) OR (findstring("V_ARCHIVE_ENTITY_ID",
    i_arc_stmt,1) > 0)) )
    SET arc_entity_ind = 1
   ENDIF
   IF (findstring("list",i_arc_stmt,1) > 0)
    SET list_ind = 1
   ENDIF
 END ;Subroutine
#arc_person_exit
 IF ((pers_arc->status="F"))
  SET reply->status_data.status = "F"
  GO TO end_program
 ENDIF
 FREE RECORD temp_pers
 RECORD temp_pers(
   1 arc[*]
     2 person_id = f8
     2 archive_env_id = f8
     2 archive_ind = i2
 )
 UPDATE  FROM person p
  SET p.next_restore_dt_tm = null
  WHERE p.archive_status_cd=0
   AND p.archive_env_id=0
   AND p.next_restore_dt_tm <= datetimeadd(cnvtdatetime(curdate,curtime3),- ((1 * pers_arc->
   next_restore_offset)))
  WITH nocounter
 ;end update
 IF (arc_error_check("An error occurred while updating next restore dt on person: ","ARCHIVE",
  "PERSON")=1)
  GO TO end_program
 ENDIF
 SET v_continue_restore = 1
 WHILE (v_continue_restore=1)
   SELECT INTO "nl:"
    p.person_id, p.archive_env_id
    FROM person p
    WHERE (((p.archive_status_cd=pers_arc->archived)
     AND p.next_restore_dt_tm >= datetimeadd(cnvtdatetime(curdate,curtime3),- ((1 * pers_arc->
     next_restore_offset)))) OR ((p.archive_status_cd=pers_arc->being_restored)
     AND p.archive_status_dt_tm < cnvtlookbehind("12,H",cnvtdatetime(curdate,curtime3))))
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1)
     IF (mod(cnt,50)=1)
      stat = alterlist(damp_request->restore,(cnt+ 49))
     ENDIF
     damp_request->restore[cnt].person_id = p.person_id, damp_request->restore[cnt].archive_env_id =
     p.archive_env_id
    FOOT REPORT
     stat = alterlist(damp_request->restore,cnt)
    WITH forupdate(p), maxqual(p,value(c_max_per_query))
   ;end select
   IF (error(v_ora_err,0) != 0)
    ROLLBACK
    IF (findstring("ORA-00054",v_ora_err)=0)
     CALL arc_log_insert("An error occurred while selecting from person: ",v_ora_err,"ARCHIVE",
      "PERSON",0.0,
      null)
     GO TO end_program
    ENDIF
   ENDIF
   IF (curqual > 0)
    UPDATE  FROM person p
     SET p.archive_status_cd = pers_arc->being_restored, p.archive_status_dt_tm = cnvtdatetime(
       curdate,curtime3), p.updt_cnt = (p.updt_cnt+ 1),
      p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
      updt_applctx,
      p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WHERE expand(v_exp_ndx,1,size(damp_request->restore,5),p.person_id,damp_request->restore[
      v_exp_ndx].person_id)
     WITH nocounter
    ;end update
    IF (arc_error_check("An error occurred while updating persons to BEINGRESTOREd: ","ARCHIVE",
     "PERSON")=1)
     GO TO end_program
    ENDIF
    INSERT  FROM dm_arc_log d,
      (dummyt du  WITH seq = size(damp_request->restore,5))
     SET d.dm_arc_log_id = seq(archive_seq,nextval), d.log_dt_tm = cnvtdatetime(curdate,curtime3), d
      .direction = "RESTORE",
      d.archive_entity_name = "PERSON", d.archive_entity_id = damp_request->restore[du.seq].person_id,
      d.err_msg = concat(request->mover_name," start time: ",format(cnvtdatetime(curdate,curtime3),
        ";;q")),
      d.instigator_applctx = reqinfo->updt_app, d.instigator_task = reqinfo->updt_task, d
      .instigator_req = reqinfo->updt_req,
      d.instigator_id = reqinfo->updt_id, d.instigator_applctx = reqinfo->updt_applctx, d.rdbhandle
       = currdbhandle,
      d.updt_cnt = 0, d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task,
      d.updt_applctx = reqinfo->updt_applctx, d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     PLAN (du)
      JOIN (d)
     WITH nocounter
    ;end insert
    IF (arc_error_check("An error occurred while inserting into dm_arc_log: ","ARCHIVE","PERSON")=1)
     GO TO end_program
    ELSE
     COMMIT
    ENDIF
    SET damp_request->mover_name = request->mover_name
    EXECUTE dm2_arc_move_person  WITH replace("REQUEST","DAMP_REQUEST"), replace("REPLY","DAMP_REPLY"
     )
    IF ((damp_reply->status_data.status="F"))
     SET reply->status_data.status = "F"
     GO TO finish_mover
    ELSEIF ((((damp_reply->status_data.status="Q")) OR ((damp_reply->status_data.status="C"))) )
     GO TO finish_mover
    ENDIF
    IF (((outside_time_window(null)=1) OR (stop_at_next_check(request->mover_name)=1)) )
     GO TO end_program
    ENDIF
   ELSE
    SET v_continue_restore = 0
   ENDIF
 ENDWHILE
 SET stat = alterlist(damp_request->archive,0)
 SET v_last_date = datetimeadd(cnvtdatetime(curdate,curtime3),- ((1 * pers_arc->stale_days)))
 SET stat = alterlist(damp_request->restore,0)
 SELECT INTO "nl:"
  min_date = min(p.last_accessed_dt_tm)
  FROM person p
  WHERE ((p.last_accessed_dt_tm < cnvtdatetime(v_last_date)
   AND p.archive_status_cd=0
   AND ((((p.updt_dt_tm+ 0) < datetimeadd(cnvtdatetime(curdate,curtime3),- (30)))
   AND p.updt_task=4320001) OR (p.updt_task != 4320001)) ) OR ((p.archive_status_cd=pers_arc->
  being_archived)
   AND p.archive_status_dt_tm < cnvtlookbehind("12,H",cnvtdatetime(curdate,curtime3))))
  DETAIL
   v_beg_date = min_date
  WITH nocounter
 ;end select
 IF (((arc_error_check("An error occurred while selecting from person: ","ARCHIVE","PERSON")=1) OR (
 v_beg_date=0)) )
  UPDATE  FROM dm_info d
   SET d.info_number = 0, d.info_char = "FINISHED - NONE LEFT", d.info_date = cnvtdatetime(curdate,
     curtime3),
    d.updt_cnt = (d.updt_cnt+ 1), d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task,
    d.updt_applctx = reqinfo->updt_applctx, d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   WHERE d.info_domain="ARCHIVE-PERSON"
    AND (d.info_name=request->mover_name)
   WITH nocounter
  ;end update
  GO TO end_program
 ENDIF
 WHILE (v_beg_date < v_last_date
  AND outside_time_window(null)=0
  AND stop_at_next_check(request->mover_name)=0)
   SET stat = alterlist(temp_pers->arc,0)
   SET v_end_date = least(datetimeadd(v_beg_date,c_day_range),v_last_date)
   SELECT INTO "nl:"
    p.person_id, p.archive_env_id, p.archive_status_cd
    FROM person p
    WHERE ((p.archive_env_id=0
     AND p.archive_status_cd=0
     AND p.last_accessed_dt_tm BETWEEN cnvtdatetime(v_beg_date) AND cnvtdatetime(v_end_date)
     AND ((((p.updt_dt_tm+ 0) < datetimeadd(cnvtdatetime(curdate,curtime3),- (30)))
     AND updt_task=4320001) OR (updt_task != 4320001)) ) OR ((p.archive_status_cd=pers_arc->
    being_archived)
     AND p.archive_status_dt_tm < cnvtlookbehind("12,H",cnvtdatetime(curdate,curtime3))))
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1)
     IF (mod(cnt,c_max_per_query)=1)
      stat = alterlist(temp_pers->arc,((cnt+ c_max_per_query) - 1))
     ENDIF
     temp_pers->arc[cnt].person_id = p.person_id, temp_pers->arc[cnt].archive_env_id = p
     .archive_env_id, temp_pers->arc[cnt].archive_ind = 1
    FOOT REPORT
     stat = alterlist(temp_pers->arc,cnt)
    WITH forupdate(p), nocounter, maxqual(p,value(c_max_per_query))
   ;end select
   IF (error(v_ora_err,0) != 0)
    ROLLBACK
    IF (findstring("ORA-00054",v_ora_err)=0)
     CALL arc_log_insert("An error occurred while selecting from person: ",v_ora_err,"ARCHIVE",
      "PERSON",0.0,
      null)
     GO TO end_program
    ENDIF
   ENDIF
   DECLARE dapc1_cv = f8 WITH noconstant(0.0)
   SET dapc1_cv = uar_get_code_by("MEANING",14270,"RESOLVED")
   IF (arc_error_check("Querying code_value table - ","ARCHIVE","PERSON")=0
    AND dapc1_cv != 0.0
    AND size(temp_pers->arc,5) > 0)
    SELECT INTO "nl:"
     FROM mammo_study ms,
      (dummyt d  WITH seq = value(size(temp_pers->arc,5))),
      mammo_follow_up mfu
     PLAN (d)
      JOIN (ms
      WHERE (ms.person_id=temp_pers->arc[d.seq].person_id))
      JOIN (mfu
      WHERE mfu.study_id=ms.study_id
       AND mfu.case_status_cd=dapc1_cv)
     DETAIL
      temp_pers->arc[d.seq].archive_ind = 0
     WITH nocounter
    ;end select
    IF (arc_error_check("Find all the resolved cases - ","ARCHIVE","PERSON")=0)
     SELECT INTO "nl:"
      FROM exam_data ed,
       rad_int_case_r r,
       (dummyt d  WITH seq = value(size(temp_pers->arc,5)))
      PLAN (d)
       JOIN (ed
       WHERE (ed.person_id=temp_pers->arc[d.seq].person_id))
       JOIN (r
       WHERE r.seq_exam_id=ed.seq_exam_id)
      DETAIL
       temp_pers->arc[d.seq].archive_ind = 0
      WITH nocounter
     ;end select
     CALL arc_error_check("Find all the interesting cases -","ARCHIVE","PERSON")
    ENDIF
   ENDIF
   IF ((validate(apc_order_id,- (1))=- (1)))
    DECLARE apc_order_id = f8 WITH noconstant(0.0)
   ENDIF
   FOR (apc_lp = 1 TO size(temp_pers->arc,5))
     SELECT INTO "nl:"
      o.person_id
      FROM eco_queue eq,
       orders o
      PLAN (o
       WHERE (o.person_id=temp_pers->arc[apc_lp].person_id))
       JOIN (eq
       WHERE eq.order_id=o.order_id)
      DETAIL
       temp_pers->arc[apc_lp].archive_ind = 0, apc_order_id = o.order_id
      WITH nocounter, maxqual(eq,1)
     ;end select
     IF (curqual > 0)
      INSERT  FROM dm_arc_log d
       SET d.dm_arc_log_id = seq(archive_seq,nextval), d.archive_entity_id = temp_pers->arc[apc_lp].
        person_id, d.run_secs = 0,
        d.log_dt_tm = cnvtdatetime(curdate,curtime3), d.direction = "ARCHIVE", d.err_msg = trim(
         concat("Info: Person found with at least one continuing order: ",cnvtstring(apc_order_id))),
        d.archive_entity_name = "PERSON", d.instigator_app = reqinfo->updt_app, d.instigator_task =
        reqinfo->updt_task,
        d.instigator_req = reqinfo->updt_req, d.instigator_id = reqinfo->updt_id, d
        .instigator_applctx = reqinfo->updt_applctx,
        d.rdbhandle = currdbhandle, d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task,
        d.updt_applctx = reqinfo->updt_applctx, d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d
        .updt_cnt = 0
       WITH nocounter
      ;end insert
     ENDIF
     CALL arc_error_check("Looking for future continuing orders -","ARCHIVE","PERSON")
   ENDFOR
   SET v_arc_cnt = 0
   SET stat = alterlist(damp_request->archive,size(temp_pers->arc,5))
   FOR (arc_ndx = 1 TO size(temp_pers->arc,5))
     IF ((temp_pers->arc[arc_ndx].archive_ind=1))
      SET v_arc_cnt = (v_arc_cnt+ 1)
      SET damp_request->archive[v_arc_cnt].person_id = temp_pers->arc[arc_ndx].person_id
      SET damp_request->archive[v_arc_cnt].archive_env_id = temp_pers->arc[arc_ndx].archive_env_id
     ELSE
      UPDATE  FROM person p
       SET p.updt_cnt = (p.updt_cnt+ 1), p.updt_id = reqinfo->updt_id, p.updt_task = 4320001,
        p.updt_applctx = reqinfo->updt_applctx, p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
       WHERE (p.person_id=temp_pers->arc[arc_ndx].person_id)
       WITH nocounter
      ;end update
      IF (arc_error_check("An error occurred while updating person: ","ARCHIVE","PERSON")=1)
       ROLLBACK
       GO TO end_program
      ELSE
       COMMIT
      ENDIF
     ENDIF
   ENDFOR
   IF (v_arc_cnt > 0)
    SET stat = alterlist(damp_request->archive,v_arc_cnt)
    UPDATE  FROM person p
     SET p.archive_status_cd = pers_arc->being_archived, p.archive_status_dt_tm = cnvtdatetime(
       curdate,curtime3), p.updt_cnt = (p.updt_cnt+ 1),
      p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
      updt_applctx,
      p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WHERE expand(v_exp_ndx,1,size(damp_request->archive,5),p.person_id,damp_request->archive[
      v_exp_ndx].person_id)
     WITH nocounter
    ;end update
    IF (arc_error_check("An error occurred while updating person to BEINGARCHIVEd: ","ARCHIVE",
     "PERSON")=1)
     GO TO end_program
    ELSE
     COMMIT
    ENDIF
    INSERT  FROM dm_arc_log d,
      (dummyt du  WITH seq = size(damp_request->archive,5))
     SET d.dm_arc_log_id = seq(archive_seq,nextval), d.log_dt_tm = cnvtdatetime(curdate,curtime3), d
      .direction = "ARCHIVE",
      d.archive_entity_name = "PERSON", d.archive_entity_id = damp_request->archive[du.seq].person_id,
      d.err_msg = concat(request->mover_name," start time: ",format(cnvtdatetime(curdate,curtime3),
        ";;q")),
      d.instigator_app = reqinfo->updt_app, d.instigator_task = reqinfo->updt_task, d.instigator_req
       = reqinfo->updt_req,
      d.instigator_id = reqinfo->updt_id, d.instigator_applctx = reqinfo->updt_applctx, d.rdbhandle
       = currdbhandle,
      d.updt_cnt = 0, d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task,
      d.updt_applctx = reqinfo->updt_applctx, d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     PLAN (du)
      JOIN (d)
     WITH nocounter
    ;end insert
    IF (arc_error_check("An error occurred while inserting into dm_arc_log: ","ARCHIVE","PERSON")=1)
     GO TO end_program
    ELSE
     COMMIT
    ENDIF
    SET damp_request->mover_name = request->mover_name
    EXECUTE dm2_arc_move_person  WITH replace("REQUEST","DAMP_REQUEST"), replace("REPLY","DAMP_REPLY"
     )
    IF ((damp_reply->status_data.status="F"))
     SET reply->status_data.status = "F"
     GO TO finish_mover
    ELSEIF ((((damp_reply->status_data.status="Q")) OR ((damp_reply->status_data.status="C"))) )
     GO TO finish_mover
    ENDIF
    IF (size(temp_pers->arc,5) < c_max_per_query)
     SET v_beg_date = v_end_date
    ENDIF
   ELSE
    SET v_beg_date = v_end_date
   ENDIF
 ENDWHILE
#finish_mover
 UPDATE  FROM dm_info d
  SET d.info_number = 0, d.info_char =
   IF (v_beg_date >= v_last_date) "FINISHED - NONE LEFT"
   ELSE "FINISHED"
   ENDIF
   , d.info_date = cnvtdatetime(curdate,curtime3),
   d.updt_cnt = (d.updt_cnt+ 1), d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task,
   d.updt_applctx = reqinfo->updt_applctx, d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  WHERE d.info_domain="ARCHIVE-PERSON"
   AND (d.info_name=request->mover_name)
  WITH nocounter
 ;end update
 IF (arc_error_check("An error occurred while updating dm_info: ","ARCHIVE","PERSON")=1)
  GO TO end_program
 ELSE
  COMMIT
 ENDIF
 SUBROUTINE running_too_long(null)
   IF (datetimediff(sysdate,v_prog_start,3) >= 1.0)
    UPDATE  FROM dm_info d
     SET d.info_number = 0, d.info_char = "CYCLING", d.info_date = cnvtdatetime(curdate,curtime3),
      d.updt_cnt = (d.updt_cnt+ 1), d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task,
      d.updt_applctx = reqinfo->updt_applctx, d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WHERE d.info_domain="ARCHIVE-PERSON"
      AND (d.info_name=request->mover_name)
     WITH nocounter
    ;end update
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
#end_program
 FREE RECORD temp_pers
 FREE RECORD danc_request
 FREE RECORD danc_reply
 FREE RECORD damp_request
 FREE RECORD damp_reply
END GO
