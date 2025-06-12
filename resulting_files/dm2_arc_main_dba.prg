CREATE PROGRAM dm2_arc_main:dba
 DECLARE v_info_domain = vc
 DECLARE v_num_movers = i2
 DECLARE v_happ = i4
 DECLARE v_htask = i4
 DECLARE v_hreq = i4
 DECLARE dapm_run(i_hreq=i4) = i4
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
 IF (outside_time_window(null)=1)
  GO TO arc_main_exit
 ENDIF
 IF ((pers_arc->status="F"))
  SET reply->status_data.status = "F"
  GO TO arc_main_exit
 ENDIF
 IF (validate(dapm_request->mover_name,"0")="0")
  FREE RECORD dapm_request
  RECORD dapm_request(
    1 mover_name = vc
  )
 ENDIF
 IF (validate(dapm_reply->status_data.status,"X")="X")
  FREE RECORD dapm_reply
  RECORD dapm_reply(
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
 IF ((request->batch_selection="PERSON"))
  SET v_num_movers = pers_arc->num_movers
 ENDIF
 SET v_info_domain = concat("ARCHIVE-",request->batch_selection)
 FOR (mov_ndx = 1 TO v_num_movers)
   SET dapm_request->mover_name = build("ARCHIVE MOVER",mov_ndx)
   SELECT INTO "nl:"
    di.info_name
    FROM dm_info di
    WHERE di.info_domain=v_info_domain
     AND (di.info_name=dapm_request->mover_name)
     AND di.info_date > cnvtlookbehind("12,H")
     AND di.info_char IN ("FINISHED - NONE LEFT", "RUNNING")
    WITH nocounter, forupdate(di)
   ;end select
   IF (arc_error_check(
    "An error occurred while checking if a new mover can be started in dm2_arc_main: ","ARCHIVE",
    "PERSON"))
    GO TO arc_main_exit
   ENDIF
   IF (curqual=0)
    DELETE  FROM dm_info di
     WHERE di.info_domain=v_info_domain
      AND (di.info_name=dapm_request->mover_name)
    ;end delete
    IF (arc_error_check("while deleting a mover row: ","ARCHIVE","PERSON"))
     GO TO arc_main_exit
    ENDIF
    INSERT  FROM dm_info di
     SET di.info_domain = v_info_domain, di.info_name = dapm_request->mover_name, di.info_char =
      "RUNNING",
      di.info_date = cnvtdatetime(curdate,curtime3), di.updt_id = reqinfo->updt_id, di.updt_task =
      reqinfo->updt_task,
      di.updt_applctx = reqinfo->updt_applctx, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di
      .updt_cnt = 0
    ;end insert
    IF (arc_error_check("when restarting a mover: ","ARCHIVE","PERSON"))
     GO TO arc_main_exit
    ELSE
     COMMIT
    ENDIF
    SET v_ret = dm2_asynch_pre(5000,5000,4320001,v_happ,v_htask,
     v_hreq)
    SET v_ret = dapm_run(v_hreq)
    SET v_ret = dm2_asynch_post(v_happ,v_htask,v_hreq)
    IF (v_ret=0)
     GO TO arc_main_exit
    ENDIF
    IF (arc_error_check("while restarting a mover asynchronously: ","ARCHIVE","PERSON"))
     GO TO arc_main_exit
    ENDIF
   ENDIF
 ENDFOR
 SUBROUTINE dapm_run(i_hreq)
   DECLARE s_hreqstruct = i4
   DECLARE s_srvstat = f8
   DECLARE s_iret = i4
   DECLARE s_hreply = i4
   DECLARE s_hlist = i4
   DECLARE s_hstatusdata = i4
   DECLARE s_hitem = i4
   SET s_hreqstruct = uar_crmgetrequest(i_hreq)
   CALL uar_srvsetstring(s_hreqstruct,"mover_name",dapm_request->mover_name)
   SET s_iret = uar_crmperform(i_hreq)
   IF (s_iret != 0)
    ROLLBACK
    CALL arc_log_insert("while trying to execute an asynch request: ",build("Fail on perform: ",
      cnvtstring(i_hreq)),"ARCHIVE","PERSON",0.0,
     0)
    COMMIT
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
#arc_main_exit
 FREE RECORD pers_arc
 FREE RECORD damp_request
 FREE RECORD damp_reply
END GO
