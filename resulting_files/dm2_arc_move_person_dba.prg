CREATE PROGRAM dm2_arc_move_person:dba
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
 IF ((validate(v_last_schema,- (1))=- (1)))
  DECLARE v_last_schema = f8
 ENDIF
 IF ((validate(v_last_gen,- (1))=- (1)))
  DECLARE v_last_gen = f8
 ENDIF
 DECLARE v_start_dt_tm = f8
 DECLARE damp_errmsg = vc
 DECLARE run_secs = i4
 DECLARE v_link_db = i4
 DECLARE v_archive_entity_id = f8
 DECLARE v_temp_str = vc
 DECLARE v_dm_arc_act_link = vc
 DECLARE v_exp_ndx = i4
 DECLARE v_str = vc
 DECLARE temp_size = i4
 DECLARE v_arc_logname = vc
 DECLARE v_arc_date = vc
 DECLARE arc_ora_err = vc
 DECLARE v_num_dup_rows = f8
 DECLARE dup_error(s_ind=i4,t_str=vc,i_pre=vc,i_post=vc,i_case=i2) = i4
 DECLARE arc_binsearch(i_key=vc) = i4
 IF ((validate(debug_mover->debug_level,- (99))=- (99)))
  FREE RECORD debug_mover
  RECORD debug_mover(
    1 debug_level = i2
  )
  SET debug_mover->debug_level = 0
 ENDIF
 IF ((validate(ps_request->v_archive_entity_id,- (99))=- (99)))
  FREE RECORD ps_request
  RECORD ps_request(
    1 v_archive_entity_id = f8
    1 s_ndx = i4
  )
 ENDIF
 IF ((validate(ps_reply->v_temp_cnt,- (99))=- (99)))
  FREE RECORD ps_reply
  RECORD ps_reply(
    1 v_temp_cnt = i4
  )
 ENDIF
 IF ((validate(child_request->s_ndx,- (99))=- (99)))
  FREE RECORD child_request
  RECORD child_request(
    1 s_ndx = i4
    1 temp_size = i4
    1 v_link_db = i4
    1 v_archive_entity_id = f8
  )
 ENDIF
 IF ((validate(child_->curqual,- (99))=- (99)))
  FREE RECORD child_reply
  RECORD child_reply(
    1 curqual = i4
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
 IF ((debug_mover->debug_level > 1))
  SET v_arc_logname = concat("arc_debug_log_",cnvtstring(curtime3),".dat")
  SET v_arc_date = format(cnvtdatetime(curdate,curtime3),"DD-MMM-YYYY HH:MM:SS;;d")
  SELECT INTO value(v_arc_logname)
   FROM dummyt
   DETAIL
    col 0, "Begin Move Person", row + 1,
    v_arc_date
   WITH nocounter
  ;end select
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
  GO TO exit_arc_move_person
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 FREE RECORD rowcnt
 RECORD rowcnt(
   1 restore[size(pers_arc->statements,5)]
     2 cnt = i4
   1 archive[size(pers_arc->statements,5)]
     2 cnt = i4
 )
 IF ((debug_mover->debug_level > 1))
  CALL echo("STARTING MOVE_PERSON")
  CALL echorecord(request)
 ENDIF
 EXECUTE dm2_set_context "FIRE_EA_TRG", "NO"
 EXECUTE dm2_set_context "FIRE_CMB_TRG", "NO"
 EXECUTE dm2_set_context "FIRE_ACTIND_TRG", "NO"
 FOR (r_ndx = 1 TO size(request->restore,5))
   IF ((debug_mover->debug_level > 1))
    CALL echo(build("****start RESTORE person number ",r_ndx,"****"))
    CALL echo(build("current memory = ",curmem))
   ENDIF
   SET v_start_dt_tm = cnvtdatetime(curdate,curtime3)
   SET v_archive_entity_id = request->restore[r_ndx].person_id
   SET v_link_db = db_search(request->restore[r_ndx].archive_env_id)
   IF (v_link_db <= 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus.targetobjectvalue = concat("The archive environment id ",
     build(request->restore.archive_env_id),
     " that the person was supposed to be stored in was not found")
    CALL arc_log_insert("An error occurred during an restore insert into the archive DB: ",reply->
     status_data.subeventstatus.targetobjectvalue,"RESTORE","PERSON",0.0,
     null)
    COMMIT
   ELSE
    SET v_dm_arc_act_link = build(nullterm(pers_arc->arc_db[v_link_db].pre_link_name),
     "dm_arc_activity",nullterm(pers_arc->arc_db[v_link_db].post_link_name))
    IF ((request->restore[r_ndx].all_tab_ind=0))
     FREE RECORD arc_tab
     RECORD arc_tab(
       1 data[*]
         2 table_name = vc
     )
     CALL parser("select into 'nl:' ",0)
     CALL parser(" t.table_name ",0)
     CALL parser(concat(" from ",v_dm_arc_act_link," t "),0)
     CALL parser(" where ",0)
     CALL parser(
      "expand(v_exp_ndx,1,size(pers_arc->statements,5),t.table_name,pers_arc->statements[v_exp_ndx].table_name) ",
      0)
     CALL parser(" and t.archive_entity_name = 'PERSON'",0)
     CALL parser(" and t.archive_entity_id = v_archive_entity_id",0)
     CALL parser(" order by t.table_name",0)
     CALL parser(" head report",0)
     CALL parser(" cnt = 0",0)
     CALL parser(" detail",0)
     CALL parser(" cnt = cnt + 1",0)
     CALL parser(" if (mod(cnt,10)=1)",0)
     CALL parser(" stat = alterlist(arc_tab->data,cnt+9)",0)
     CALL parser(" endif",0)
     CALL parser(" arc_tab->data[cnt].table_name = t.table_name",0)
     CALL parser(" foot report",0)
     CALL parser(" stat = alterlist(arc_tab->data,cnt)",0)
     CALL parser(" with nocounter go",1)
    ENDIF
    FOR (s_ndx = 1 TO size(pers_arc->statements,5))
      SET ps_reply->v_temp_cnt = 0
      SET ps_request->s_ndx = s_ndx
      IF ((request->restore[r_ndx].all_tab_ind=0))
       SET ps_reply->v_temp_cnt = arc_binsearch(pers_arc->statements[s_ndx].table_name)
      ELSE
       EXECUTE dm2_arc_rest_select  WITH replace("REPLY","PS_REPLY"), replace("REQUEST","PS_REQUEST")
       IF (arc_error_check("An error occurred during a preselect from the clinical DB: ","RESTORE",
        "PERSON")=1)
        SET reply->status_data.status = "F"
        SET reply->status_data.subeventstatus.targetobjectvalue = build(
         "Error during restore preselects for person_id = ",request->archive[a_ndx].person_id)
        GO TO exit_arc_move_person
       ENDIF
      ENDIF
      IF ((ps_reply->v_temp_cnt > 0))
       SET temp_size = size(pers_arc->statements[s_ndx].restore_insert,5)
       SET child_request->s_ndx = s_ndx
       SET child_request->v_link_db = v_link_db
       SET child_request->temp_size = temp_size
       SET child_request->v_archive_entity_id = v_archive_entity_id
       EXECUTE dm2_arc_restore_insert  WITH replace("REQUEST","CHILD_REQUEST"), replace("REPLY",
        "CHILD_REPLY")
       SET rowcnt->restore[s_ndx].cnt = child_reply->curqual
       IF ((debug_mover->debug_level > 1))
        CALL echo(build("current memory = ",curmem))
       ENDIF
       IF (error(arc_ora_err,0) != 0)
        IF (cnvtint(substring((findstring("ORA",arc_ora_err)+ 4),5,arc_ora_err))=1)
         SET v_num_dup_rows = 0
         SET stat = dup_error(s_ndx,pers_arc->statements[s_ndx].table_name,"","",1)
         SET rowcnt->restore[s_ndx].cnt = v_num_dup_rows
         IF ((debug_mover->debug_level > 1))
          CALL echo(build("v_num_dup_rows=",v_num_dup_rows))
          CALL echo(build("rowcnt.restore.cnt=",rowcnt->restore[s_ndx].cnt))
         ENDIF
         IF (stat=0)
          SET reply->status_data.status = "F"
          SET reply->status_data.subeventstatus.targetobjectvalue = concat(
           "Error during restore deletes for person_id = ",build(request->restore[r_ndx].person_id))
          GO TO exit_arc_move_person
         ENDIF
        ELSE
         ROLLBACK
         CALL arc_log_insert("An error occurred during an restore insert into the archive DB: ",
          arc_ora_err,"RESTORE","PERSON",0.0,
          null)
         COMMIT
         SET reply->status_data.status = "F"
         SET reply->status_data.subeventstatus.targetobjectvalue = concat(
          "Error during restore insert for person_id = ",build(request->restore[r_ndx].person_id))
         GO TO exit_arc_move_person
        ENDIF
       ENDIF
      ELSE
       SET rowcnt->restore[s_ndx].cnt = 0
      ENDIF
    ENDFOR
    IF ((reply->status_data.status != "F"))
     FOR (s_ndx = 1 TO size(pers_arc->statements,5))
       IF ((rowcnt->restore[s_ndx].cnt > 0))
        SET temp_size = size(pers_arc->statements[s_ndx].restore_delete,5)
        SET child_request->s_ndx = s_ndx
        SET child_request->v_link_db = v_link_db
        SET child_request->temp_size = temp_size
        SET child_request->v_archive_entity_id = v_archive_entity_id
        EXECUTE dm2_arc_restore_delete  WITH replace("REQUEST","CHILD_REQUEST"), replace("REPLY",
         "CHILD_REPLY")
        IF ((child_reply->curqual != rowcnt->restore[s_ndx].cnt))
         ROLLBACK
         SET reply->status_data.status = "F"
         SET reply->status_data.subeventstatus.targetobjectvalue = concat(
          "Did not delete the same # of rows that we inserted for person_id ",build(request->restore[
           r_ndx].person_id)," and table ",pers_arc->statements[s_ndx].table_name)
         CALL arc_log_insert("",substring(1,250,reply->status_data.subeventstatus.targetobjectvalue),
          "RESTORE","PERSON",0.0,
          null)
         COMMIT
         GO TO exit_arc_move_person
        ELSEIF (arc_error_check("An error occurred during a restore delete from the archive DB: ",
         "RESTORE","PERSON")=1)
         SET reply->status_data.status = "F"
         SET reply->status_data.subeventstatus.targetobjectvalue = concat(
          "Error during restore deletes for person_id = ",build(request->restore[r_ndx].person_id))
         GO TO exit_arc_move_person
        ENDIF
       ENDIF
     ENDFOR
     DELETE  FROM (parser(v_dm_arc_act_link))
      WHERE archive_entity_id=v_archive_entity_id
       AND archive_entity_name="PERSON"
      WITH nocounter
     ;end delete
     IF ((debug_mover->debug_level > 1))
      CALL echo(build("****delete data from arc_activity_table for statement number ",s_ndx,"****"))
      CALL echo(build("current memory = ",curmem))
     ENDIF
    ENDIF
    IF ((reply->status_data.status != "F"))
     UPDATE  FROM person
      SET archive_status_cd = 0, archive_env_id = 0, archive_status_dt_tm = cnvtdatetime(curdate,
        curtime3),
       last_accessed_dt_tm = cnvtdatetime(curdate,curtime3), updt_cnt = (updt_cnt+ 1), updt_id =
       reqinfo->updt_id,
       updt_task = reqinfo->updt_task, updt_applctx = reqinfo->updt_applctx, updt_dt_tm =
       cnvtdatetime(curdate,curtime3),
       next_restore_dt_tm = null
      WHERE (person_id=request->restore[r_ndx].person_id)
      WITH nocounter
     ;end update
     IF (arc_error_check(concat(
       "An error occurred during a restore update of person data into the clinical DB for person_id = ",
       build(request->restore[r_ndx].person_id),": "),"RESTORE","PERSON")=1)
      GO TO exit_arc_move_person
     ELSE
      COMMIT
     ENDIF
     SET run_secs = cnvtint(datetimediff(cnvtdatetime(curdate,curtime3),cnvtdatetime(v_start_dt_tm),5
       ))
     UPDATE  FROM dm_arc_log d
      SET d.log_dt_tm = cnvtdatetime(curdate,curtime3), d.direction = "RESTORE", d.run_secs =
       run_secs,
       d.instigator_app = reqinfo->updt_app, d.instigator_task = reqinfo->updt_task, d.instigator_req
        = reqinfo->updt_req,
       d.instigator_id = reqinfo->updt_id, d.instigator_applctx = reqinfo->updt_applctx, d.rdbhandle
        = currdbhandle,
       d.updt_cnt = (updt_cnt+ 1), d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task,
       d.updt_applctx = reqinfo->updt_applctx, d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WHERE d.archive_entity_name="PERSON"
       AND (d.archive_entity_id=request->restore[r_ndx].person_id)
       AND d.direction="RESTORE"
       AND d.run_secs=null
      WITH nocounter
     ;end update
     IF ((debug_mover->debug_level > 1))
      CALL echo(concat("run_secs = ",cnvtstring(run_secs)))
     ENDIF
     IF (curqual=0)
      CALL arc_log_insert("","","RESTORE","PERSON",request->restore[r_ndx].person_id,
       run_secs)
     ENDIF
     IF (arc_error_check(concat("when updating the direction column for person_id = ",cnvtstring(
        request->restore[r_ndx].person_id)),"RESTORE","PERSON")=1)
      GO TO exit_arc_move_person
     ELSE
      COMMIT
     ENDIF
    ENDIF
   ENDIF
   IF ((debug_mover->debug_level > 1))
    CALL echo(build("****finished person number ",r_ndx,"****"))
    CALL echo(build("current memory = ",curmem))
   ENDIF
 ENDFOR
 EXECUTE dm2_set_context "FIRE_EA_TRG", "YES"
 EXECUTE dm2_set_context "FIRE_CMB_TRG", "YES"
 EXECUTE dm2_set_context "FIRE_ACTIND_TRG", "YES"
 SET v_dm_arc_act_link = build(nullterm(pers_arc->active_pre_link_name),"dm_arc_activity",nullterm(
   pers_arc->active_post_link_name))
 FOR (a_ndx = 1 TO size(request->archive,5))
   IF ((debug_mover->debug_level=0))
    IF (update_time_window(null)=0)
     GO TO exit_arc_move_person
    ENDIF
    IF (((outside_time_window(null)=1) OR (stop_at_next_check(request->mover_name)=1)) )
     SET reply->status_data.status = "Q"
     GO TO exit_arc_move_person
    ENDIF
   ENDIF
   IF ((debug_mover->debug_level > 1))
    CALL echo(build("****start person number ",a_ndx,"****"))
    CALL echo(build("current memory = ",curmem))
   ENDIF
   SET v_start_dt_tm = cnvtdatetime(curdate,curtime3)
   SET v_archive_entity_id = request->archive[a_ndx].person_id
   SET ps_request->v_archive_entity_id = v_archive_entity_id
   IF ((debug_mover->debug_level > 1))
    CALL echo("Beginning inserts into archive db")
   ENDIF
   FOR (s_ndx = 1 TO size(pers_arc->statements,5))
     SET ps_reply->v_temp_cnt = 0
     SET ps_request->s_ndx = s_ndx
     IF ((debug_mover->debug_level > 1))
      CALL echo(build("calling preselect number ",s_ndx))
      CALL echo(build("Current memory = ",curmem))
     ENDIF
     EXECUTE dm2_arc_select  WITH replace("REPLY","PS_REPLY"), replace("REQUEST","PS_REQUEST")
     IF (arc_error_check("An error occurred during a preselect from the archive DB: ","ARCHIVE",
      "PERSON")=1)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus.targetobjectvalue = build(
       "Error during preselects for person_id = ",request->archive[a_ndx].person_id)
      GO TO exit_arc_move_person
     ENDIF
     IF ((debug_mover->debug_level > 1))
      CALL echo(build("end preselect number ",s_ndx))
      CALL echo(build("Current memory = ",curmem))
     ENDIF
     IF ((ps_reply->v_temp_cnt > 0))
      SET temp_size = size(pers_arc->statements[s_ndx].archive_insert,5)
      SET child_request->s_ndx = s_ndx
      SET child_request->v_link_db = v_link_db
      SET child_request->temp_size = temp_size
      SET child_request->v_archive_entity_id = v_archive_entity_id
      EXECUTE dm2_archive_insert  WITH replace("REQUEST","CHILD_REQUEST"), replace("REPLY",
       "CHILD_REPLY")
      SET rowcnt->archive[s_ndx].cnt = child_reply->curqual
      IF ((debug_mover->debug_level > 1))
       CALL echo(concat("table: ",pers_arc->statements[s_ndx].table_name,"   curqual = ",build(
          child_reply->curqual)))
       CALL echo(build("current memory = ",curmem))
      ENDIF
      IF (error(arc_ora_err,0) != 0)
       IF (cnvtint(substring((findstring("ORA",arc_ora_err)+ 4),5,arc_ora_err))=1)
        SET v_num_dup_rows = 0
        SET stat = dup_error(s_ndx,pers_arc->statements[s_ndx].table_name,pers_arc->
         active_pre_link_name,pers_arc->active_post_link_name,2)
        SET rowcnt->archive[s_ndx].cnt = v_num_dup_rows
        IF ((debug_mover->debug_level > 1))
         CALL echo(build("v_num_dup_rows=",v_num_dup_rows))
         CALL echo(build("rowcnt.archive.cnt=",rowcnt->archive[s_ndx].cnt))
        ENDIF
        IF (stat=0)
         SET reply->status_data.status = "F"
         SET reply->status_data.subeventstatus.targetobjectvalue = concat(
          "Error during archive inserts for person_id = ",build(request->archive[a_ndx].person_id))
         GO TO exit_arc_move_person
        ENDIF
       ELSE
        ROLLBACK
        CALL arc_log_insert("An error occurred during an archive insert into the archive DB: ",
         arc_ora_err,"ARCHIVE","PERSON",0.0,
         null)
        COMMIT
        SET reply->status_data.status = "F"
        SET reply->status_data.subeventstatus.targetobjectvalue = build(
         "Error during archive insert for person_id = ",request->archive[a_ndx].person_id)
        GO TO exit_arc_move_person
       ENDIF
      ENDIF
     ELSE
      SET rowcnt->archive[s_ndx].cnt = 0
     ENDIF
   ENDFOR
   IF ((debug_mover->debug_level > 1))
    CALL echo("finished inserting into archive db")
    CALL echo(build("Final current memory = ",curmem))
   ENDIF
   IF ((reply->status_data.status != "F"))
    IF ((debug_mover->debug_level > 1))
     CALL echo("Begin Clinical deletes")
    ENDIF
    FOR (s_ndx = 1 TO size(pers_arc->statements,5))
      IF ((rowcnt->archive[s_ndx].cnt > 0))
       SET temp_size = size(pers_arc->statements[s_ndx].archive_delete,5)
       SET child_request->s_ndx = s_ndx
       SET child_request->v_link_db = v_link_db
       SET child_request->temp_size = temp_size
       SET child_request->v_archive_entity_id = v_archive_entity_id
       EXECUTE dm2_archive_delete  WITH replace("REQUEST","CHILD_REQUEST"), replace("REPLY",
        "CHILD_REPLY")
       IF ((child_reply->curqual != rowcnt->archive[s_ndx].cnt))
        ROLLBACK
        SET reply->status_data.status = "F"
        SET reply->status_data.subeventstatus.targetobjectvalue = concat(
         "Did not delete the same # of rows that we inserted for person_id ",build(request->archive[
          a_ndx].person_id)," and for delete string for tablename =  ",pers_arc->statements[s_ndx].
         table_name)
        CALL arc_log_insert("",reply->status_data.subeventstatus.targetobjectvalue,"ARCHIVE","PERSON",
         0.0,
         null)
        COMMIT
        GO TO exit_arc_move_person
       ELSEIF (arc_error_check(concat(
         "An error occurred during an archive delete from the clinical DB for person_id = ",
         cnvtstring(v_archive_entity_id),": "),"ARCHIVE","PERSON")=1)
        SET reply->status_data.status = "F"
        SET reply->status_data.subeventstatus.targetobjectvalue = build(
         "Error during archive deletes for person_id = ",request->archive[a_ndx].person_id)
        GO TO exit_arc_move_person
       ENDIF
       INSERT  FROM (parser(v_dm_arc_act_link))
        SET archive_entity_id = v_archive_entity_id, table_name = pers_arc->statements[s_ndx].
         table_name, num_rows = rowcnt->archive[s_ndx].cnt,
         archive_entity_name = "PERSON", updt_cnt = 0, updt_id = reqinfo->updt_id,
         updt_task = reqinfo->updt_task, updt_applctx = reqinfo->updt_applctx, updt_dt_tm =
         cnvtdatetime(curdate,curtime3)
        WITH nocounter
       ;end insert
       IF (error(arc_ora_err,0) != 0)
        IF (findstring("ORA-00001",arc_ora_err))
         SET stat = 0
        ELSE
         ROLLBACK
         SET reply->status_data.subeventstatus.targetobjectvalue = arc_ora_err
         SET reply->status_data.status = "F"
         CALL arc_log_insert("An error occurred during an insert into the arc_acivity table ",
          arc_ora_err,"ARCHIVE","PERSON",0.0,
          null)
         COMMIT
         GO TO exit_arc_move_person
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   IF ((debug_mover->debug_level > 1))
    CALL echo("End of deletes")
    CALL echo(build("Current memory after deletes = ",curmem))
   ENDIF
   IF ((reply->status_data.status != "F"))
    UPDATE  FROM person p
     SET p.archive_status_cd = pers_arc->archived, p.archive_env_id = pers_arc->active_archive_env_id,
      p.archive_status_dt_tm = cnvtdatetime(curdate,curtime3)
     WHERE (p.person_id=request->archive[a_ndx].person_id)
     WITH nocounter
    ;end update
    IF (arc_error_check(concat(
      "An error occurred during an archive update of person data into the clinical DB for person_id = ",
      cnvtstring(v_archive_entity_id),": "),"ARCHIVE","PERSON")=1)
     GO TO exit_arc_move_person
    ELSE
     IF ((debug_mover->debug_level > 1))
      CALL echo("******person table updated!*******")
     ENDIF
     COMMIT
    ENDIF
    SET run_secs = cnvtint(datetimediff(cnvtdatetime(curdate,curtime3),v_start_dt_tm,5))
    UPDATE  FROM dm_arc_log d
     SET d.log_dt_tm = cnvtdatetime(curdate,curtime3), d.direction = "ARCHIVE", d.run_secs = run_secs,
      d.instigator_app = reqinfo->updt_app, d.instigator_task = reqinfo->updt_task, d.instigator_req
       = reqinfo->updt_req,
      d.instigator_id = reqinfo->updt_id, d.instigator_applctx = reqinfo->updt_applctx, d.rdbhandle
       = currdbhandle,
      d.updt_cnt = (d.updt_cnt+ 1), d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task,
      d.updt_applctx = reqinfo->updt_applctx, d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WHERE d.archive_entity_name="PERSON"
      AND (d.archive_entity_id=request->archive[a_ndx].person_id)
      AND d.direction="ARCHIVE"
      AND d.run_secs=null
     WITH nocounter
    ;end update
    IF (curqual=0)
     CALL arc_log_insert("","","ARCHIVE","PERSON",request->archive[a_ndx].person_id,
      run_secs)
    ENDIF
    IF (arc_error_check(concat("when updating the direction column for person_id = ",cnvtstring(
       request->archive[a_ndx].person_id)),"ARCHIVE","PERSON")=1)
     ROLLBACK
     GO TO exit_arc_move_person
    ELSE
     COMMIT
    ENDIF
   ENDIF
   IF ((debug_mover->debug_level > 1))
    CALL echo(concat("Finished moving person number ",cnvtstring(a_ndx)," of ",cnvtstring(size(
        request->archive,5))," persons"))
   ENDIF
   IF (curmem < 3000)
    SET reply->status_data.status = "C"
    GO TO exit_arc_move_person
   ENDIF
 ENDFOR
 IF ((debug_mover->debug_level > 1))
  CALL echo("End Move Person without errors")
 ENDIF
 SUBROUTINE dup_error(s_ind,t_str,i_pre,i_post,i_case)
   DECLARE s_size = i4
   DECLARE found = i2
   DECLARE temp_str = vc
   DECLARE s_start = i4
   SET found = 0
   CASE (i_case)
    OF 1:
     IF (((t_str="CLINICAL_EVENT") OR (t_str="CE_SUSCEP_FOOTNOTE")) )
      SET s_size = size(pers_arc->statements[s_ind].restore_insert,5)
      WHILE (found=0
       AND s_size > 0)
       SET found = findstring("REFERENCE_NBR",pers_arc->statements[s_ind].restore_insert[s_size],1,1)
       IF (found > 0)
        SET found = s_size
       ELSE
        SET s_size = (s_size - 1)
       ENDIF
      ENDWHILE
      SET s_size = size(pers_arc->statements[s_ind].restore_insert,5)
      FOR (cnt = 0 TO (s_size - 2))
        IF (cnt=found)
         SET s_start = findstring("REFERENCE_NBR",pers_arc->statements[s_ind].restore_insert[cnt],1,1
          )
         SET temp_str = build(substring(1,(s_start - 1),pers_arc->statements[s_ind].restore_insert[
           cnt]),replace(substring(s_start,132,pers_arc->statements[s_ind].restore_insert[cnt]),
           "REFERENCE_NBR",build('concat(trim(REFERENCE_NBR,3),"',build("-ARC",format(curdate,
              "YYYYMMDD;;d")),'")'),1))
         SET temp_str = replace(replace(temp_str,"v_archive_entity_id",build(v_archive_entity_id)),
          "V_ARCHIVE_ENTITY_ID",build(v_archive_entity_id))
         CALL parser(temp_str,0)
        ELSE
         CALL parser(replace(replace(pers_arc->statements[s_ind].restore_insert[cnt],
            "v_archive_entity_id",build(v_archive_entity_id)),"V_ARCHIVE_ENTITY_ID",build(
            v_archive_entity_id)),0)
        ENDIF
      ENDFOR
      IF (findstring(") go",pers_arc->statements[s_ind].restore_insert[s_size]) > 0)
       IF (((s_size - 1)=found))
        SET s_start = findstring("REFERENCE_NBR",pers_arc->statements[s_ind].restore_insert[(s_size
          - 1)],1,1)
        SET temp_str = build(substring(1,(s_start - 1),pers_arc->statements[s_ind].restore_insert[(
          s_size - 1)]),replace(substring(s_start,132,pers_arc->statements[s_ind].restore_insert[(
           s_size - 1)]),"REFERENCE_NBR",build('concat(trim(REFERENCE_NBR,3),"',build("-ARC",format(
             curdate,"YYYYMMDD;;d")),'")'),1))
        SET temp_str = replace(replace(temp_str,"v_archive_entity_id",build(v_archive_entity_id)),
         "V_ARCHIVE_ENTITY_ID",build(v_archive_entity_id))
        CALL parser(temp_str,0)
       ELSE
        CALL parser(replace(replace(pers_arc->statements[s_ind].restore_insert[(s_size - 1)],
           "v_archive_entity_id",build(v_archive_entity_id)),"V_ARCHIVE_ENTITY_ID",build(
           v_archive_entity_id)),0)
       ENDIF
       IF (s_size=found)
        SET s_start = findstring("REFERENCE_NBR",pers_arc->statements[s_ind].restore_insert[s_size],1,
         1)
        SET temp_str = replace(build(substring(1,(s_start - 1),pers_arc->statements[s_ind].
           restore_insert[(s_size - 1)]),replace(substring(s_start,132,pers_arc->statements[s_ind].
            restore_insert[(s_size - 1)]),"REFERENCE_NBR",build('concat(trim(REFERENCE_NBR,3),"',
            build("-ARC",format(curdate,"YYYYMMDD;;d")),'")'),1)),") go",concat(
          " and list (reference_nbr, valid_until_dt_tm, contributor_system_cd) in ",
          " (select reference_nbr, valid_until_dt_tm, contributor_system_cd "," from ",trim(i_pre,3),
          trim(t_str,3),
          trim(i_post,3),")) go"),1)
        SET temp_str = replace(replace(temp_str,"v_archive_entity_id",build(v_archive_entity_id)),
         "V_ARCHIVE_ENTITY_ID",build(v_archive_entity_id))
        CALL parser(temp_str,1)
       ELSE
        SET temp_str = replace(pers_arc->statements[s_ind].restore_insert[s_size],") go",concat(
          " and list (reference_nbr, valid_until_dt_tm, contributor_system_cd) in ",
          " (select reference_nbr, valid_until_dt_tm, contributor_system_cd "," from ",trim(i_pre,3),
          trim(t_str,3),
          trim(i_post,3),")) go"),1)
        SET temp_str = replace(replace(temp_str,"v_archive_entity_id",build(v_archive_entity_id)),
         "V_ARCHIVE_ENTITY_ID",build(v_archive_entity_id))
        CALL parser(temp_str,1)
       ENDIF
      ELSE
       IF (((s_size - 1)=found))
        SET s_start = findstring("REFERENCE_NBR",pers_arc->statements[s_ind].restore_insert[(s_size
          - 1)],1,1)
        SET temp_str = replace(build(substring(1,(s_start - 1),pers_arc->statements[s_ind].
           restore_insert[(s_size - 1)]),replace(substring(s_start,132,pers_arc->statements[s_ind].
            restore_insert[(s_size - 1)]),"REFERENCE_NBR",build('concat(trim(REFERENCE_NBR,3),"',
            build("-ARC",format(curdate,"YYYYMMDD;;d")),'")'),1)),")","",2)
        SET temp_str = replace(replace(temp_str,"v_archive_entity_id",build(v_archive_entity_id)),
         "V_ARCHIVE_ENTITY_ID",build(v_archive_entity_id))
        CALL parser(temp_str,0)
       ELSE
        SET temp_str = replace(pers_arc->statements[s_ndx].restore_insert[(s_size - 1)].stmt,")","",2
         )
        SET temp_str = replace(replace(temp_str,"v_archive_entity_id",build(v_archive_entity_id)),
         "V_ARCHIVE_ENTITY_ID",build(v_archive_entity_id))
        CALL parser(temp_str,0)
       ENDIF
       IF (s_size=found)
        SET s_start = findstring("REFERENCE_NBR",pers_arc->statements[s_ind].restore_insert[s_size],1,
         1)
        SET temp_str = replace(build(substring(1,(s_start - 1),pers_arc->statements[s_ind].
           restore_insert[(s_size - 1)]),replace(substring(s_start,132,pers_arc->statements[s_ind].
            restore_insert[(s_size - 1)]),"REFERENCE_NBR",build('concat(trim(REFERENCE_NBR,3),"',
            build("-ARC",format(curdate,"YYYYMMDD;;d")),'")'),1)),"go",concat(
          " and list (reference_nbr, valid_until_dt_tm, contributor_system_cd) in ",
          " (select reference_nbr, valid_until_dt_tm, contributor_system_cd "," from ",trim(i_pre,3),
          trim(t_str,3),
          trim(i_post,3),")) go"),1)
        SET temp_str = replace(replace(temp_str,"v_archive_entity_id",build(v_archive_entity_id)),
         "V_ARCHIVE_ENTITY_ID",build(v_archive_entity_id))
        CALL parser(temp_str,1)
       ELSE
        SET temp_str = replace(pers_arc->statements[s_ind].restore_insert[s_size],"go",concat(
          " and list (reference_nbr, valid_until_dt_tm, contributor_system_cd) in ",
          " (select reference_nbr, valid_until_dt_tm, contributor_system_cd "," from ",trim(i_pre,3),
          trim(t_str,3),
          trim(i_post,3),")) go"),1)
        SET temp_str = replace(replace(temp_str,"v_archive_entity_id",build(v_archive_entity_id)),
         "V_ARCHIVE_ENTITY_ID",build(v_archive_entity_id))
        CALL parser(temp_str,1)
       ENDIF
      ENDIF
      SET v_num_dup_rows = curqual
      IF (error(arc_ora_err,0) != 0)
       ROLLBACK
       SET reply->status_data.subeventstatus.targetobjectvalue = arc_ora_err
       SET reply->status_data.status = "F"
       CALL arc_log_insert("An error occurred during an archive insert into the archive DB: ",
        arc_ora_err,"RESTORE","PERSON",0.0,
        null)
       COMMIT
       RETURN(0)
      ELSE
       SET s_size = size(pers_arc->statements[s_ind].restore_insert,5)
       FOR (cnt = 0 TO (s_size - 2))
        SET temp_str = replace(replace(pers_arc->statements[s_ind].restore_insert[cnt],
          "v_archive_entity_id",build(v_archive_entity_id)),"V_ARCHIVE_ENTITY_ID",build(
          v_archive_entity_id))
        CALL parser(temp_str,0)
       ENDFOR
       IF (findstring(") go",pers_arc->statements[s_ind].restore_insert[s_size]) > 0)
        SET temp_str = replace(replace(pers_arc->statements[s_ind].restore_insert[(s_size - 1)],
          "v_archive_entity_id",build(v_archive_entity_id)),"V_ARCHIVE_ENTITY_ID",build(
          v_archive_entity_id))
        CALL parser(temp_str,0)
        SET temp_str = replace(pers_arc->statements[s_ind].restore_insert[s_size],") go",concat(
          " and list (reference_nbr, valid_until_dt_tm, contributor_system_cd) NOT in ",
          " (select reference_nbr, valid_until_dt_tm, contributor_system_cd "," from ",trim(i_pre,3),
          trim(t_str,3),
          trim(i_post,3),")) go"),1)
        SET temp_str = replace(replace(temp_str,"v_archive_entity_id",build(v_archive_entity_id)),
         "V_ARCHIVE_ENTITY_ID",build(v_archive_entity_id))
        CALL parser(temp_str,1)
       ELSE
        SET temp_str = replace(pers_arc->statements[s_ndx].restore_insert[(s_size - 1)].stmt,")","",2
         )
        SET temp_str = replace(replace(temp_str,"v_archive_entity_id",build(v_archive_entity_id)),
         "V_ARCHIVE_ENTITY_ID",build(v_archive_entity_id))
        CALL parser(temp_str,0)
        SET temp_str = replace(pers_arc->statements[s_ind].restore_insert[s_size],"go",concat(
          " and list (reference_nbr, valid_until_dt_tm, contributor_system_cd) NOT in ",
          " (select reference_nbr, valid_until_dt_tm, contributor_system_cd "," from ",trim(i_pre,3),
          trim(t_str,3),
          trim(i_post,3),")) go"),1)
        SET temp_str = replace(replace(temp_str,"v_archive_entity_id",build(v_archive_entity_id)),
         "V_ARCHIVE_ENTITY_ID",build(v_archive_entity_id))
        CALL parser(temp_str,1)
       ENDIF
       IF (error(arc_ora_err,0) != 0)
        ROLLBACK
        SET reply->status_data.subeventstatus.targetobjectvalue = arc_ora_err
        SET reply->status_data.status = "F"
        CALL arc_log_insert("An error occurred during an archive insert into the archive DB: ",
         arc_ora_err,"RESTORE","PERSON",0.0,
         null)
        COMMIT
        RETURN(0)
       ELSE
        SET v_num_dup_rows = (v_num_dup_rows+ curqual)
        IF ((debug_mover->debug_level > 1))
         CALL echo(build("SUB: v_num_dup_rows=",v_num_dup_rows))
        ENDIF
        RETURN(1)
       ENDIF
      ENDIF
     ELSE
      ROLLBACK
      SET reply->status_data.subeventstatus.targetobjectvalue = arc_ora_err
      SET reply->status_data.status = "F"
      CALL arc_log_insert(concat("Duplicate value error for person_id = ",build(request->archive[
         r_ndx].person_id)," : "),arc_ora_err,"RESTORE","PERSON",0.0,
       null)
      COMMIT
      RETURN(0)
     ENDIF
    OF 2:
     IF (((t_str="CLINICAL_EVENT") OR (t_str="CE_SUSCEP_FOOTNOTE")) )
      SET s_size = size(pers_arc->statements[s_ind].archive_insert,5)
      WHILE (found=0
       AND s_size > 0)
       SET found = findstring("REFERENCE_NBR",pers_arc->statements[s_ind].archive_insert[s_size],1,1)
       IF (found > 0)
        SET found = s_size
       ELSE
        SET s_size = (s_size - 1)
       ENDIF
      ENDWHILE
      SET s_size = size(pers_arc->statements[s_ind].archive_insert,5)
      FOR (cnt = 0 TO (s_size - 2))
        IF (cnt=found)
         SET s_start = findstring("REFERENCE_NBR",pers_arc->statements[s_ind].archive_insert[cnt],1,1
          )
         SET temp_str = build(substring(1,(s_start - 1),pers_arc->statements[s_ind].archive_insert[
           cnt]),replace(substring(s_start,132,pers_arc->statements[s_ind].archive_insert[cnt]),
           "REFERENCE_NBR",build('concat(trim(REFERENCE_NBR,3),"',build("-ARC",format(curdate,
              "YYYYMMDD;;d")),'")'),1))
         SET temp_str = replace(replace(temp_str,"v_archive_entity_id",build(v_archive_entity_id)),
          "V_ARCHIVE_ENTITY_ID",build(v_archive_entity_id))
         CALL parser(temp_str,0)
        ELSE
         CALL parser(replace(replace(pers_arc->statements[s_ind].archive_insert[cnt],
            "v_archive_entity_id",build(v_archive_entity_id)),"V_ARCHIVE_ENTITY_ID",build(
            v_archive_entity_id)),0)
        ENDIF
      ENDFOR
      IF (findstring(") go",pers_arc->statements[s_ind].archive_insert[s_size]) > 0)
       IF (((s_size - 1)=found))
        SET s_start = findstring("REFERENCE_NBR",pers_arc->statements[s_ind].archive_insert[(s_size
          - 1)],1,1)
        SET temp_str = build(substring(1,(s_start - 1),pers_arc->statements[s_ind].archive_insert[(
          s_size - 1)]),replace(substring(s_start,132,pers_arc->statements[s_ind].archive_insert[(
           s_size - 1)]),"REFERENCE_NBR",build('concat(trim(REFERENCE_NBR,3),"',build("-ARC",format(
             curdate,"YYYYMMDD;;d")),'")'),1))
        SET temp_str = replace(replace(temp_str,"v_archive_entity_id",build(v_archive_entity_id)),
         "V_ARCHIVE_ENTITY_ID",build(v_archive_entity_id))
        CALL parser(temp_str,0)
       ELSE
        CALL parser(replace(replace(pers_arc->statements[s_ind].archive_insert[(s_size - 1)],
           "v_archive_entity_id",build(v_archive_entity_id)),"V_ARCHIVE_ENTITY_ID",build(
           v_archive_entity_id)),0)
       ENDIF
       IF (s_size=found)
        SET s_start = findstring("REFERENCE_NBR",pers_arc->statements[s_ind].archive_insert[s_size],1,
         1)
        SET temp_str = replace(build(substring(1,(s_start - 1),pers_arc->statements[s_ind].
           archive_insert[(s_size - 1)]),replace(substring(s_start,132,pers_arc->statements[s_ind].
            archive_insert[(s_size - 1)]),"REFERENCE_NBR",build('concat(trim(REFERENCE_NBR,3),"',
            build("-ARC",format(curdate,"YYYYMMDD;;d")),'")'),1)),") go",concat(
          " and list (reference_nbr, valid_until_dt_tm, contributor_system_cd) in ",
          " (select reference_nbr, valid_until_dt_tm, contributor_system_cd "," from ",trim(i_pre,3),
          trim(t_str,3),
          trim(i_post,3),")) go"),1)
        SET temp_str = replace(replace(temp_str,"v_archive_entity_id",build(v_archive_entity_id)),
         "V_ARCHIVE_ENTITY_ID",build(v_archive_entity_id))
        CALL parser(temp_str,1)
       ELSE
        SET temp_str = replace(pers_arc->statements[s_ind].archive_insert[s_size],") go",concat(
          " and list (reference_nbr, valid_until_dt_tm, contributor_system_cd) in ",
          " (select reference_nbr, valid_until_dt_tm, contributor_system_cd "," from ",trim(i_pre,3),
          trim(t_str,3),
          trim(i_post,3),")) go"),1)
        SET temp_str = replace(replace(temp_str,"v_archive_entity_id",build(v_archive_entity_id)),
         "V_ARCHIVE_ENTITY_ID",build(v_archive_entity_id))
        CALL parser(temp_str,1)
       ENDIF
      ELSE
       IF (((s_size - 1)=found))
        SET s_start = findstring("REFERENCE_NBR",pers_arc->statements[s_ind].archive_insert[(s_size
          - 1)],1,1)
        SET temp_str = replace(build(substring(1,(s_start - 1),pers_arc->statements[s_ind].
           archive_insert[(s_size - 1)]),replace(substring(s_start,132,pers_arc->statements[s_ind].
            archive_insert[(s_size - 1)]),"REFERENCE_NBR",build('concat(trim(REFERENCE_NBR,3),"',
            build("-ARC",format(curdate,"YYYYMMDD;;d")),'")'),1)),")","",2)
        SET temp_str = replace(replace(temp_str,"v_archive_entity_id",build(v_archive_entity_id)),
         "V_ARCHIVE_ENTITY_ID",build(v_archive_entity_id))
        CALL parser(temp_str,0)
       ELSE
        SET temp_str = replace(pers_arc->statements[s_ndx].archive_insert[(s_size - 1)].stmt,")","",2
         )
        SET temp_str = replace(replace(temp_str,"v_archive_entity_id",build(v_archive_entity_id)),
         "V_ARCHIVE_ENTITY_ID",build(v_archive_entity_id))
        CALL parser(temp_str,0)
       ENDIF
       IF (s_size=found)
        SET s_start = findstring("REFERENCE_NBR",pers_arc->statements[s_ind].archive_insert[s_size],1,
         1)
        SET temp_str = replace(build(substring(1,(s_start - 1),pers_arc->statements[s_ind].
           archive_insert[(s_size - 1)]),replace(substring(s_start,132,pers_arc->statements[s_ind].
            archive_insert[(s_size - 1)]),"REFERENCE_NBR",build('concat(trim(REFERENCE_NBR,3),"',
            build("-ARC",format(curdate,"YYYYMMDD;;d")),'")'),1)),"go",concat(
          " and list (reference_nbr, valid_until_dt_tm, contributor_system_cd) in ",
          " (select reference_nbr, valid_until_dt_tm, contributor_system_cd "," from ",trim(i_pre,3),
          trim(t_str,3),
          trim(i_post,3),")) go"),1)
        SET temp_str = replace(replace(temp_str,"v_archive_entity_id",build(v_archive_entity_id)),
         "V_ARCHIVE_ENTITY_ID",build(v_archive_entity_id))
        CALL parser(temp_str,1)
       ELSE
        SET temp_str = replace(pers_arc->statements[s_ind].archive_insert[s_size],"go",concat(
          " and list (reference_nbr, valid_until_dt_tm, contributor_system_cd) in ",
          " (select reference_nbr, valid_until_dt_tm, contributor_system_cd "," from ",trim(i_pre,3),
          trim(t_str,3),
          trim(i_post,3),")) go"),1)
        SET temp_str = replace(replace(temp_str,"v_archive_entity_id",build(v_archive_entity_id)),
         "V_ARCHIVE_ENTITY_ID",build(v_archive_entity_id))
        CALL parser(temp_str,1)
       ENDIF
      ENDIF
      SET v_num_dup_rows = curqual
      IF (error(arc_ora_err,0) != 0)
       ROLLBACK
       SET reply->status_data.subeventstatus.targetobjectvalue = arc_ora_err
       SET reply->status_data.status = "F"
       CALL arc_log_insert("An error occurred during an archive insert into the archive DB: ",
        arc_ora_err,"ARCHIVE","PERSON",0.0,
        null)
       COMMIT
       RETURN(0)
      ELSE
       SET s_size = size(pers_arc->statements[s_ind].archive_insert,5)
       FOR (cnt = 0 TO (s_size - 2))
        SET temp_str = replace(replace(pers_arc->statements[s_ind].archive_insert[cnt],
          "v_archive_entity_id",build(v_archive_entity_id)),"V_ARCHIVE_ENTITY_ID",build(
          v_archive_entity_id))
        CALL parser(temp_str,0)
       ENDFOR
       IF (findstring(") go",pers_arc->statements[s_ind].archive_insert[s_size]) > 0)
        SET temp_str = replace(replace(pers_arc->statements[s_ind].archive_insert[(s_size - 1)],
          "v_archive_entity_id",build(v_archive_entity_id)),"V_ARCHIVE_ENTITY_ID",build(
          v_archive_entity_id))
        CALL parser(temp_str,0)
        SET temp_str = replace(pers_arc->statements[s_ind].archive_insert[s_size],") go",concat(
          " and list (reference_nbr, valid_until_dt_tm, contributor_system_cd) NOT in ",
          " (select reference_nbr, valid_until_dt_tm, contributor_system_cd "," from ",trim(i_pre,3),
          trim(t_str,3),
          trim(i_post,3),")) go"),1)
        SET temp_str = replace(replace(temp_str,"v_archive_entity_id",build(v_archive_entity_id)),
         "V_ARCHIVE_ENTITY_ID",build(v_archive_entity_id))
        CALL parser(temp_str,1)
       ELSE
        SET temp_str = replace(pers_arc->statements[s_ndx].archive_insert[(s_size - 1)].stmt,")","",2
         )
        SET temp_str = replace(replace(temp_str,"v_archive_entity_id",build(v_archive_entity_id)),
         "V_ARCHIVE_ENTITY_ID",build(v_archive_entity_id))
        CALL parser(temp_str,0)
        SET temp_str = replace(pers_arc->statements[s_ind].archive_insert[s_size],"go",concat(
          " and list (reference_nbr, valid_until_dt_tm, contributor_system_cd) NOT in ",
          " (select reference_nbr, valid_until_dt_tm, contributor_system_cd "," from ",trim(i_pre,3),
          trim(t_str,3),
          trim(i_post,3),")) go"),1)
        SET temp_str = replace(replace(temp_str,"v_archive_entity_id",build(v_archive_entity_id)),
         "V_ARCHIVE_ENTITY_ID",build(v_archive_entity_id))
        CALL parser(temp_str,1)
       ENDIF
       IF (error(arc_ora_err,0) != 0)
        ROLLBACK
        SET reply->status_data.subeventstatus.targetobjectvalue = arc_ora_err
        SET reply->status_data.status = "F"
        CALL arc_log_insert("An error occurred during an archive insert into the archive DB: ",
         arc_ora_err,"ARCHIVE","PERSON",0.0,
         null)
        COMMIT
        RETURN(0)
       ELSE
        SET v_num_dup_rows = (v_num_dup_rows+ curqual)
        IF ((debug_mover->debug_level > 1))
         CALL echo(build("SUB: v_num_dup_rows=",v_num_dup_rows))
        ENDIF
        RETURN(1)
       ENDIF
      ENDIF
     ELSE
      ROLLBACK
      SET reply->status_data.subeventstatus.targetobjectvalue = arc_ora_err
      SET reply->status_data.status = "F"
      CALL arc_log_insert(build("Duplicate value error for person_id = ",build(request->archive[r_ndx
         ].person_id)," : "),arc_ora_err,"ARCHIVE","PERSON",0.0,
       null)
      COMMIT
      RETURN(0)
     ENDIF
   ENDCASE
 END ;Subroutine
 SUBROUTINE arc_binsearch(i_key)
   DECLARE v_low = i4 WITH noconstant(0)
   DECLARE v_mid = i4 WITH noconstant(0)
   DECLARE v_high = i4
   SET v_high = size(arc_tab->data,5)
   WHILE (((v_high - v_low) > 1))
    SET v_mid = cnvtint(((v_high+ v_low)/ 2))
    IF ((i_key <= arc_tab->data[v_mid].table_name))
     SET v_high = v_mid
    ELSE
     SET v_low = v_mid
    ENDIF
   ENDWHILE
   IF (trim(i_key,3)=trim(arc_tab->data[v_high].table_name,3))
    RETURN(v_high)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
#exit_arc_move_person
 IF ((debug_mover->debug_level > 1))
  CALL datlog("End Move Person (post exit label)")
 ENDIF
 FREE RECORD rowcnt
 FREE RECORD ps_request
 FREE RECORD ps_reply
 FREE RECORD child_request
 FREE RECORD child_reply
 FREE RECORD arc_tab
END GO
