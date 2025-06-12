CREATE PROGRAM dm2_arc_rest_person:dba
 IF ((validate(request->person_id,- (1))=- (1)))
  RECORD request(
    1 person_id = f8
    1 wait_ind = i2
  )
 ENDIF
 IF (validate(reply->status_data.status,"X")="X")
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
 CALL echo("********** DM2_ARC_REST_PERSON ************")
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
 DECLARE dm2_asynch_pre(i_appid=i4,i_taskid=i4,i_reqid=i4,o_happ=i4(ref),o_htask=i4(ref),
  o_hreq=i4(ref)) = i4
 SUBROUTINE dm2_asynch_pre(i_appid,i_taskid,i_reqid,o_happ,o_htask,o_hreq)
   DECLARE s_iret = i2
   SET o_happ = uar_crmgetapphandle()
   IF (o_happ=0)
    SET s_iret = uar_crmbeginapp(i_appid,o_happ)
    CALL echo(s_iret)
    IF (s_iret=0)
     CALL echo(build("Application Handle is: ",o_happ))
     SET s_iret = uar_crmbegintask(o_happ,i_taskid,o_htask)
     IF (((s_iret=0) OR (o_htask != 0)) )
      CALL echo(build("Task Handle is: ",o_htask))
      SET s_iret = uar_crmbeginreq(o_htask,0,i_reqid,o_hreq)
      CALL echo(build("o_hReq = ",o_hreq))
      IF (((s_iret=0) OR (o_hreq != 0)) )
       CALL echo(build("Request Handle is: ",o_hreq))
       RETURN(1)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (o_hreq > 0)
    SET s_iret = uar_crmendreq(o_hreq)
   ENDIF
   IF (o_htask > 0)
    SET s_iret = uar_crmendtask(o_htask)
   ENDIF
   IF (o_happ > 0)
    SET s_iret = uar_crmendapp(o_happ)
   ENDIF
   RETURN(0)
 END ;Subroutine
 DECLARE dm2_asynch_post(i_happ=i4,i_htask=i4,i_hreq=i4) = i4
 SUBROUTINE dm2_asynch_post(i_happ,i_htask,i_hreq)
   DECLARE s_iret = i2
   IF (i_hreq > 0)
    SET s_iret = uar_crmendreq(i_hreq)
   ENDIF
   IF (i_htask > 0)
    SET s_iret = uar_crmendtask(i_htask)
   ENDIF
   IF (i_happ > 0)
    SET s_iret = uar_crmendapp(i_happ)
   ENDIF
   RETURN(1)
 END ;Subroutine
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
 SET reply->status_data.status = "S"
 DECLARE v_archive_env_id = f8
 DECLARE v_archive_status = vc
 DECLARE v_status_cd = f8
 DECLARE being_restored_cnt = i4 WITH noconstant(0), private
 DECLARE v_happ = i4
 DECLARE v_htask = i4
 DECLARE v_hreq = i4
 DECLARE v_ret = i4
 DECLARE v_handle = vc
 DECLARE v_arc_emsg = vc
 DECLARE damp_run(i_hreq=i4) = i4
 DECLARE dm_arc_app_status(gas_appl_id=vc) = c1
#get_status_code
 SELECT INTO "nl:"
  p.archive_env_id
  FROM person p
  WHERE (p.person_id=request->person_id)
  DETAIL
   v_archive_env_id = p.archive_env_id, v_status_cd = p.archive_status_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.targetobjectvalue = build("ERROR: Could not find person ",
   request->person_id," on the person table")
 ELSE
  IF (v_status_cd=0)
   GO TO end_program
  ENDIF
  SET v_archive_status = uar_get_code_meaning(v_status_cd)
  IF (v_archive_status <= " ")
   SELECT INTO "nl:"
    FROM code_value c
    WHERE c.code_set=391571
     AND c.code_value=v_status_cd
    DETAIL
     v_archive_status = c.cdf_meaning
    WITH nocounter
   ;end select
   IF (arc_error_check("An error occurred while retrieving code_value: ","RESTORE","PERSON")=1)
    GO TO end_program
   ENDIF
  ENDIF
  IF (((v_archive_status="BEINGRESTORE") OR (v_archive_status="BEINGARCHIVE")) )
   SELECT INTO "nl:"
    FROM dm_arc_log dal
    WHERE dal.archive_entity_name="PERSON"
     AND (dal.archive_entity_id=request->person_id)
     AND dal.direction=substring(6,7,v_archive_status)
     AND dal.run_secs = null
     AND (dal.log_dt_tm=
    (SELECT
     max(dal2.log_dt_tm)
     FROM dm_arc_log dal2
     WHERE dal2.archive_entity_name=dal.archive_entity_name
      AND dal2.direction=dal.direction
      AND dal2.archive_entity_id=dal.archive_entity_id))
    DETAIL
     v_handle = dal.rdbhandle
    WITH nocounter
   ;end select
   IF (arc_error_check("An error occurred while validating currdbhandle: ","RESTORE","PERSON")=1)
    GO TO end_program
   ENDIF
   IF (curqual > 0
    AND dm_arc_app_status(v_handle)="A")
    CALL pause(2)
    SET being_restored_cnt = (being_restored_cnt+ 1)
    IF (being_restored_cnt > 300)
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus.targetobjectvalue =
     "ERROR: Could not restore person after 10 minutes, timing out"
     GO TO end_program
    ELSE
     GO TO get_status_code
    ENDIF
   ENDIF
  ENDIF
  IF (v_archive_env_id=0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus.targetobjectvalue = build(
    "ERROR: The archive_env_id for person ",request->person_id," is invalid, is equal to zero")
  ELSE
   SET stat = alterlist(damp_request->restore,1)
   SET damp_request->restore[1].person_id = request->person_id
   SET damp_request->restore[1].archive_env_id = v_archive_env_id
   UPDATE  FROM person p
    SET p.archive_status_cd = pers_arc->being_restored, p.archive_status_dt_tm = cnvtdatetime(curdate,
      curtime3), p.updt_cnt = (p.updt_cnt+ 1),
     p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
     updt_applctx,
     p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE (p.person_id=damp_request->restore[1].person_id)
    WITH nocounter
   ;end update
   IF (arc_error_check("An error occurred while updating person to BEINGRESTOREd: ","RESTORE",
    "PERSON")=1)
    GO TO end_program
   ELSE
    COMMIT
   ENDIF
   INSERT  FROM dm_arc_log d
    SET d.dm_arc_log_id = seq(archive_seq,nextval), d.log_dt_tm = cnvtdatetime(curdate,curtime3), d
     .direction = "RESTORE",
     d.archive_entity_name = "PERSON", d.archive_entity_id = damp_request->restore[1].person_id, d
     .instigator_applctx = reqinfo->updt_app,
     d.instigator_task = reqinfo->updt_task, d.instigator_req = reqinfo->updt_req, d.instigator_id =
     reqinfo->updt_id,
     d.instigator_applctx = reqinfo->updt_applctx, d.rdbhandle = currdbhandle, d.updt_cnt = 0,
     d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->
     updt_applctx,
     d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end insert
   IF (arc_error_check("An error occurred while inserting into dm_arc_log: ","RESTORE","PERSON")=1)
    GO TO end_program
   ELSE
    COMMIT
   ENDIF
   IF ((request->wait_ind=1))
    CALL echo("****** CALLING DM2_ARC_MOVE_PERSON *******")
    EXECUTE dm2_arc_move_person  WITH replace("REQUEST","DAMP_REQUEST"), replace("REPLY","DAMP_REPLY"
     )
    CALL echo("****** ENDING DM2_ARC_MOVE_PERSON ********")
    SET reply->status_data.subeventstatus.targetobjectvalue = damp_reply->status_data.subeventstatus.
    targetobjectvalue
    SET reply->status_data.status = damp_reply->status_data.status
   ELSE
    SET v_ret = dm2_asynch_pre(5000,5000,4320005,v_happ,v_htask,
     v_hreq)
    SET v_ret = damp_run(v_hreq)
    IF (v_ret=0)
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus.targetobjectvalue =
     "ERROR: unable to run asynch request 4320005"
    ENDIF
    SET v_ret = dm2_asynch_post(v_happ,v_htask,v_hreq)
    IF (v_ret=0)
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus.targetobjectvalue = "ERROR: asycnh call failed"
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 SUBROUTINE damp_run(i_hreq)
   DECLARE s_hreqstruct = i4
   DECLARE s_srvstat = i4
   DECLARE s_iret = i4
   DECLARE s_hreply = i4
   DECLARE s_hlist = i4
   SET s_hreqstruct = uar_crmgetrequest(i_hreq)
   FOR (r_ndx = 1 TO size(damp_request->restore,5))
     SET s_hlist = uar_srvadditem(s_hreqstruct,"restore")
     SET s_srvstat = uar_srvsetdouble(s_hlist,"person_id",damp_request->restore[r_ndx].person_id)
     SET s_srvstat = uar_srvsetdouble(s_hlist,"archive_env_id",damp_request->restore[r_ndx].
      archive_env_id)
   ENDFOR
   FOR (a_ndx = 1 TO size(damp_request->archive,5))
    SET s_hlist = uar_srvadditem(s_hreqstruct,"archive")
    SET s_srvstat = uar_srvsetdouble(s_hlist,"person_id",damp_request->archive[a_ndx].person_id)
   ENDFOR
   SET s_iret = uar_crmperform(i_hreq)
   RETURN(s_iret)
 END ;Subroutine
 SUBROUTINE dm_arc_app_status(arc_appl_id)
   DECLARE arc_error_status = c1 WITH protect, constant("E")
   DECLARE arc_active_status = c1 WITH protect, constant("A")
   DECLARE arc_inactive_status = c1 WITH protect, constant("I")
   DECLARE arc_text = vc WITH protect, noconstant(" ")
   DECLARE arc_currdblink = vc WITH protect, noconstant(cnvtupper(trim(currdblink,3)))
   DECLARE arc_appl_id_cvt = vc WITH protect, noconstant(" ")
   IF (currdb="DB2UDB")
    SET arc_appl_id_cvt = replace(trim(arc_appl_id,3),"*","\*",0)
    SELECT INTO "nl:"
     FROM dm2_user_views
     WHERE view_name="DM2_SNAP_APPL_INFO"
     WITH nocounter
    ;end select
    IF (error(v_arc_emsg,1) != 0)
     ROLLBACK
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus.targetobjectvalue =
     "DM2_ARC_REST_PERSON: Selecting from dm2_user_views in subroutine DM_ARC_APP_STATUS"
     RETURN(arc_error_status)
    ENDIF
    IF (curqual=0)
     SET arc_text = concat("RDB ASIS (^ ","CREATE VIEW DM2_SNAP_APPL_INFO AS ",
      " ( SELECT * FROM TABLE(SNAPSHOT_APPL_INFO('",arc_currdblink,"',-1 )) AS SNAPSHOT_APPL_INFO )",
      " ^) GO ")
     CALL parser(arc_text)
     IF (error(v_arc_emsg,1) != 0)
      ROLLBACK
      RETURN(arc_error_status)
     ELSE
      COMMIT
      EXECUTE oragen3 "DM2_SNAP_APPL_INFO"
      IF (error(v_arc_emsg,1) != 0)
       ROLLBACK
       SET reply->status_data.status = "F"
       SET reply->status_data.subeventstatus.targetobjectvalue = concat("DM2_ARC_REST_PERSON: ",
        v_arc_emsg)
       RETURN(arc_error_status)
      ENDIF
     ENDIF
    ENDIF
    SELECT INTO "nl:"
     FROM dtable
     WHERE table_name="DM2_SNAP_APPL_INFO"
     WITH nocounter
    ;end select
    IF (error(v_arc_emsg,1) != 0)
     ROLLBACK
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus.targetobjectvalue =
     "DM2_ARC_REST_PERSON: Selecting from dtable in subroutine DM_ARC_APP_STATUS"
     RETURN(arc_error_status)
    ENDIF
    IF (curqual != 1)
     EXECUTE oragen3 "DM2_SNAP_APPL_INFO"
     IF (error(v_arc_emsg,1) != 0)
      ROLLBACK
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus.targetobjectvalue = concat("DM2_ARC_REST_PERSON: ",
       v_arc_emsg)
      RETURN(arc_error_status)
     ENDIF
    ENDIF
    SET arc_text = concat('select into "nl:" from DM2_SNAP_APPL_INFO where appl_id = "',
     arc_appl_id_cvt,'" with nocounter go')
    CALL parser(arc_text)
    IF (error(v_arc_emsg,1) != 0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(arc_error_status)
    ENDIF
    IF (curqual=1)
     RETURN(arc_active_status)
    ELSE
     RETURN(arc_inactive_status)
    ENDIF
   ELSEIF (currdb="SQLSRV")
    DECLARE arc_str_loc1 = i4 WITH protect, noconstant(0)
    DECLARE arc_str_loc2 = i4 WITH protect, noconstant(0)
    DECLARE arc_str_loc3 = i4 WITH protect, noconstant(0)
    DECLARE arc_spid = i4 WITH protect, noconstant(0)
    DECLARE arc_login_date = vc WITH protect, noconstant(" ")
    DECLARE arc_login_time = i4 WITH protect, noconstant(0)
    SET arc_str_loc1 = findstring("-",trim(arc_appl_id,3),1,0)
    SET arc_str_loc2 = findstring(" ",trim(arc_appl_id,3),1,1)
    SET arc_str_loc3 = findstring(":",trim(arc_appl_id,3),1,1)
    IF (((arc_str_loc1=0) OR (((arc_str_loc2=0) OR (arc_str_loc3=0)) )) )
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus.targetobjectvalue =
     "DM2_ARC_REST_PERSON: Invalid application handle"
     RETURN(arc_error_status)
    ELSE
     SET arc_spid = cnvtint(build(substring(1,(arc_str_loc1 - 1),trim(arc_appl_id,3))))
     SET arc_login_date = cnvtupper(cnvtalphanum(substring((arc_str_loc1+ 1),(arc_str_loc2 -
        arc_str_loc1),trim(arc_appl_id,3))))
     SET arc_login_time = cnvtint(cnvtalphanum(substring(arc_str_loc2,(arc_str_loc3 - arc_str_loc2),
        trim(arc_appl_id,3))))
    ENDIF
    SELECT INTO "nl:"
     FROM sysprocesses p
     WHERE p.spid=arc_spid
      AND p.login_time=cnvtdatetime(cnvtdate2(arc_login_date,"DDMMMYYYY"),arc_login_time)
     WITH nocounter
    ;end select
    IF (error(v_arc_emsg,1) != 0)
     ROLLBACK
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus.targetobjectvalue =
     "DM2_ARC_REST_PERSON: Selecting from sysprocesses in subroutine DM_ARC_APP_STATUS"
     RETURN(arc_error_status)
    ELSEIF (curqual=0)
     RETURN(arc_inactive_status)
    ELSE
     RETURN(arc_active_status)
    ENDIF
   ELSE
    SELECT INTO "nl:"
     FROM v$session s
     WHERE s.audsid=cnvtint(arc_appl_id)
     WITH nocounter
    ;end select
    IF (error(v_arc_emsg,1) != 0)
     ROLLBACK
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus.targetobjectvalue =
     "DM2_ARC_REST_PERSON: Selecting from v$session in subroutine DM_ARC_APP_STATUS"
     RETURN(arc_error_status)
    ELSEIF (curqual=0)
     RETURN(arc_inactive_status)
    ELSE
     RETURN(arc_active_status)
    ENDIF
   ENDIF
 END ;Subroutine
#end_program
 FREE RECORD damp_request
 FREE RECORD damp_reply
END GO
