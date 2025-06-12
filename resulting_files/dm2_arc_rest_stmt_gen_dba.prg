CREATE PROGRAM dm2_arc_rest_stmt_gen:dba
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
 CALL echo("**************Start of dm_stmt_gen************************")
 IF ((validate(reply->test_ind,- (1))=- (1)))
  RECORD reply(
    1 test_ind = i2
    1 tabs[*]
      2 table_name = vc
      2 constraint_name = vc
      2 arc_del = vc
      2 rest_del = vc
      2 arc_ins = vc
      2 rest_ins = vc
      2 column_list = vc
      2 parent_table = vc
      2 child_table = vc
      2 parent_column = vc
      2 child_column = vc
      2 child_where = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD ap
 RECORD ap(
   1 tabs[*]
     2 parent_table = vc
     2 parent_table_db = vc
     2 parent_column = vc
     2 all_columns = vc
     2 child_table = vc
     2 child_table_db = vc
     2 child_column = vc
     2 child_where = vc
     2 where_str = vc
     2 where_str_db = vc
     2 found_ind = i2
     2 exclude_ind = i2
     2 constraint_name = vc
 )
 FREE RECORD curtab
 RECORD curtab(
   1 tab[*]
     2 parent_table = vc
     2 parent_table_db = vc
     2 parent_column = vc
     2 child_table = vc
     2 child_table_db = vc
     2 child_column = vc
     2 child_where = vc
     2 from_str = vc
     2 from_str_db = vc
     2 where_str = vc
     2 where_str_db = vc
     2 select_str = vc
     2 select_str_db = vc
 )
 DECLARE binsearch(i_key=vc) = i4
 DECLARE req_search(i_table_name=vc,i_constraint_name=vc) = i4
 DECLARE add_tab(i_found_ndx=i4,i_cur_ndx=i4,i_cur_count=i4(ref),i_end_paren=vc(ref)) = null
 DECLARE v_found_ndx = i4 WITH noconstant(0)
 DECLARE v_req_ndx = i4 WITH noconstant(0)
 DECLARE v_end_paren = vc
 DECLARE v_reply_cnt = i4 WITH noconstant(0)
 DECLARE v_start_pos = i4
 DECLARE v_select_str = vc
 DECLARE v_select_str_db = vc
 SELECT DISTINCT INTO "nl:"
  dac.parent_table, dac.parent_column, dac.child_table,
  dac.child_column, dac.exclude_ind, dac.constraint_name,
  dac.long_col_ind
  FROM dm_arc_constraints dac
  WHERE  EXISTS (
  (SELECT
   "x"
   FROM dm2_user_tables dut
   WHERE dut.table_name=dac.child_table))
  ORDER BY dac.child_table
  HEAD REPORT
   row_cnt = 0
  DETAIL
   row_cnt = (row_cnt+ 1)
   IF (mod(row_cnt,50)=1)
    stat = alterlist(ap->tabs,(row_cnt+ 49))
   ENDIF
   ap->tabs[row_cnt].parent_table = trim(dac.parent_table,3), ap->tabs[row_cnt].parent_column = trim(
    dac.parent_column,3), ap->tabs[row_cnt].child_table = trim(dac.child_table,3),
   ap->tabs[row_cnt].child_column = trim(dac.child_column,3), ap->tabs[row_cnt].exclude_ind =
   greatest(dac.exclude_ind,dac.long_col_ind), ap->tabs[row_cnt].constraint_name = dac
   .constraint_name
   IF ((ap->tabs[row_cnt].exclude_ind=1))
    ap->tabs[row_cnt].child_table_db = ap->tabs[row_cnt].child_table
   ELSE
    ap->tabs[row_cnt].child_table_db = build(":pre_link:",dac.child_table,":post_link:")
   ENDIF
   IF (trim(dac.child_where,3)="")
    ap->tabs[row_cnt].child_where = " "
   ELSE
    ap->tabs[row_cnt].child_where = trim(dac.child_where,3)
   ENDIF
  FOOT REPORT
   stat = alterlist(ap->tabs,row_cnt)
  WITH nocounter
 ;end select
 IF (arc_error_check("An error occurred while retrieving distinct child tables: ","ARCHIVE","PERSON")
 =1)
  GO TO end_program
 ENDIF
 FOR (ap_ndx = 1 TO size(ap->tabs,5))
  SET v_found_ndx = binsearch(ap->tabs[ap_ndx].parent_table)
  IF ((ap->tabs[v_found_ndx].exclude_ind=1))
   SET ap->tabs[ap_ndx].parent_table_db = ap->tabs[ap_ndx].parent_table
  ELSE
   SET ap->tabs[ap_ndx].parent_table_db = build(":pre_link:",ap->tabs[ap_ndx].parent_table,
    ":post_link:")
  ENDIF
 ENDFOR
 FOR (t_ndx = 1 TO size(ap->tabs,5))
  SET v_req_ndx = req_search(ap->tabs[t_ndx].child_table,ap->tabs[t_ndx].constraint_name)
  IF ((((request->all_tab_ind=1)) OR (v_req_ndx > 0)) )
   SELECT INTO "nl:"
    utc.column_name
    FROM dm2_user_tab_columns utc
    WHERE (utc.table_name=ap->tabs[t_ndx].child_table)
     AND utc.column_name != "SEQ"
    DETAIL
     ap->tabs[t_ndx].all_columns = build(ap->tabs[t_ndx].all_columns,",",utc.column_name)
    FOOT REPORT
     ap->tabs[t_ndx].all_columns = substring(2,textlen(ap->tabs[t_ndx].all_columns),ap->tabs[t_ndx].
      all_columns)
    WITH nocounter
   ;end select
   IF (arc_error_check("An error occurred while retrieving source table columns: ","ARCHIVE","PERSON"
    )=1)
    GO TO end_program
   ENDIF
   CALL echo(build("t_ndx=",t_ndx,".of.",size(ap->tabs,5)))
   SET stat = alterlist(curtab->tab,1)
   SET curtab->tab[1].child_table = ap->tabs[t_ndx].child_table
   SET curtab->tab[1].child_table_db = ap->tabs[t_ndx].child_table_db
   SET curtab->tab[1].child_column = ap->tabs[t_ndx].child_column
   SET curtab->tab[1].child_where = ap->tabs[t_ndx].child_where
   SET curtab->tab[1].parent_table = ap->tabs[t_ndx].parent_table
   SET curtab->tab[1].parent_table_db = ap->tabs[t_ndx].parent_table_db
   SET curtab->tab[1].parent_column = ap->tabs[t_ndx].parent_column
   SET curtab->tab[1].from_str = ap->tabs[t_ndx].child_table
   SET curtab->tab[1].from_str_db = ap->tabs[t_ndx].child_table_db
   SET curtab->tab[1].where_str = " "
   SET curtab->tab[1].where_str_db = " "
   SET cur_ndx = 1
   SET cur_count = 1
   SET v_end_paren = ""
   WHILE (cur_ndx <= cur_count)
    IF (cur_count > 10)
     SET cur_ndx = (cur_count+ 2)
    ELSE
     IF ((curtab->tab[cur_ndx].parent_table=request->batch_selection))
      SET ap->tabs[t_ndx].found_ind = 1
      IF (cur_ndx=1)
       SET v_select_str = concat(curtab->tab[cur_ndx].child_table," where ",evaluate(curtab->tab[
         cur_ndx].child_where," "," ",concat(substring(6,textlen(curtab->tab[cur_ndx].child_where),
           curtab->tab[cur_ndx].child_where)," and ")),curtab->tab[cur_ndx].child_column,
        "=v_archive_entity_id")
       SET v_select_str_db = concat(curtab->tab[cur_ndx].child_table_db," where ",evaluate(curtab->
         tab[cur_ndx].child_where," "," ",concat(substring(6,textlen(curtab->tab[cur_ndx].child_where
            ),curtab->tab[cur_ndx].child_where)," and ")),curtab->tab[cur_ndx].child_column,
        "=v_archive_entity_id")
      ELSE
       SET v_select_str = concat(curtab->tab[cur_ndx].select_str," where ",evaluate(curtab->tab[
         cur_ndx].child_where," "," ",concat(trim(substring(6,textlen(curtab->tab[cur_ndx].
             child_where),curtab->tab[cur_ndx].child_where),3)," and ")),curtab->tab[cur_ndx].
        child_column,"=v_archive_entity_id",
        trim(v_end_paren,3))
       SET v_select_str_db = concat(curtab->tab[cur_ndx].select_str_db," where ",evaluate(curtab->
         tab[cur_ndx].child_where," "," ",concat(substring(6,textlen(curtab->tab[cur_ndx].child_where
            ),curtab->tab[cur_ndx].child_where)," and ")),curtab->tab[cur_ndx].child_column,
        "=v_archive_entity_id",
        trim(v_end_paren,3))
      ENDIF
      SET v_reply_cnt = (v_reply_cnt+ 1)
      IF (mod(v_reply_cnt,30)=1)
       SET stat = alterlist(reply->tabs,(v_reply_cnt+ 29))
      ENDIF
      IF (v_req_ndx=0)
       SET reply->tabs[v_reply_cnt].constraint_name = " "
      ELSE
       SET reply->tabs[v_reply_cnt].constraint_name = request->tabs[v_req_ndx].constraint_name
      ENDIF
      SET reply->tabs[v_reply_cnt].column_list = ap->tabs[t_ndx].all_columns
      SET reply->tabs[v_reply_cnt].parent_table = ap->tabs[t_ndx].parent_table
      SET reply->tabs[v_reply_cnt].child_table = ap->tabs[t_ndx].child_table
      SET reply->tabs[v_reply_cnt].parent_column = ap->tabs[t_ndx].parent_column
      SET reply->tabs[v_reply_cnt].child_column = ap->tabs[t_ndx].child_column
      SET reply->tabs[v_reply_cnt].child_where = ap->tabs[t_ndx].child_where
      SET reply->tabs[v_reply_cnt].rest_ins = trim(concat("insert into ",trim(ap->tabs[t_ndx].
         child_table,3)," (:cols:) (","select :cols: from ",replace(replace(v_select_str_db,'"',"'",0
          ),"^",'"',0),
        ")"," go"),3)
      SET v_start_pos = findstring(" where",v_select_str)
      SET reply->tabs[v_reply_cnt].rest_del = trim(concat("delete from ",build(":pre_link:",substring
         (1,(v_start_pos - 1),v_select_str),":post_link:"),replace(replace(substring(v_start_pos,
           textlen(v_select_str),v_select_str),'"',"'",0),"^",'"',0)," go"),3)
      SET reply->tabs[v_reply_cnt].arc_ins = trim(concat("insert into ",ap->tabs[t_ndx].
        child_table_db," (:cols:) (","select :cols: from ",replace(replace(v_select_str,'"',"'",0),
         "^",'"',0),
        ")"," go"),3)
      SET reply->tabs[v_reply_cnt].arc_del = trim(concat("delete from ",replace(replace(replace(
           replace(v_select_str_db,'"',"'",0),"^",'"',0),":pre_link:","",1),":post_link:","",1)," go"
        ),3)
     ELSE
      SET v_found_ndx = binsearch(curtab->tab[cur_ndx].parent_table)
      IF ((v_found_ndx != - (1)))
       CALL add_tab(v_found_ndx,cur_ndx,cur_count,v_end_paren)
       SET v_check_ndx = (v_found_ndx - 1)
       WHILE (v_check_ndx <= size(ap->tabs,5)
        AND (curtab->tab[cur_ndx].parent_table=ap->tabs[v_check_ndx].child_table))
        CALL add_tab(v_check_ndx,cur_ndx,cur_count,v_end_paren)
        SET v_check_ndx = (v_check_ndx - 1)
       ENDWHILE
       SET v_check_ndx = (v_found_ndx+ 1)
       WHILE (v_check_ndx <= size(ap->tabs,5)
        AND (curtab->tab[cur_ndx].parent_table=ap->tabs[v_check_ndx].child_table))
        CALL add_tab(v_check_ndx,cur_ndx,cur_count,v_end_paren)
        SET v_check_ndx = (v_check_ndx+ 1)
       ENDWHILE
      ENDIF
     ENDIF
    ENDIF
    SET cur_ndx = (cur_ndx+ 1)
   ENDWHILE
   IF ((ap->tabs[t_ndx].found_ind=0))
    IF (arc_error_check("Parent entity not found in child table: ","ARCHIVE","PERSON")=1)
     GO TO end_program
    ENDIF
   ENDIF
  ENDIF
 ENDFOR
 SET stat = alterlist(reply->tabs,v_reply_cnt)
 SUBROUTINE binsearch(i_key)
   DECLARE v_low = i4 WITH noconstant(0)
   DECLARE v_mid = i4 WITH noconstant(0)
   DECLARE v_high = i4
   SET v_high = size(ap->tabs,5)
   WHILE (((v_high - v_low) > 1))
    SET v_mid = cnvtint(((v_high+ v_low)/ 2))
    IF ((i_key <= ap->tabs[v_mid].child_table))
     SET v_high = v_mid
    ELSE
     SET v_low = v_mid
    ENDIF
   ENDWHILE
   IF (trim(i_key,3)=trim(ap->tabs[v_high].child_table,3))
    RETURN(v_high)
   ELSE
    RETURN(- (1))
   ENDIF
 END ;Subroutine
 SUBROUTINE req_search(i_table_name,i_constraint_name)
   DECLARE s_req_ndx = i4 WITH noconstant(0)
   FOR (tn_ndx = 1 TO size(request->tabs,5))
     IF ((request->tabs[tn_ndx].table_name=i_table_name)
      AND (request->tabs[tn_ndx].constraint_name=i_constraint_name))
      SET s_req_ndx = tn_ndx
      SET tn_ndx = (size(request->tabs,5)+ 1)
     ENDIF
   ENDFOR
   RETURN(s_req_ndx)
 END ;Subroutine
 SUBROUTINE add_tab(i_found_ndx,i_cur_ndx,i_cur_count,i_end_paren)
   DECLARE s_found = i2
   DECLARE s_zero_row = vc
   SET s_found = 0
   FOR (ct_ndx = 1 TO size(curtab->tab,5))
     IF ((curtab->tab[ct_ndx].child_table=ap->tabs[i_cur_ndx].parent_table))
      SET s_found = (s_found+ 1)
     ENDIF
   ENDFOR
   IF (s_found=0)
    SET i_cur_count = (i_cur_count+ 1)
    SET stat = alterlist(curtab->tab,i_cur_count)
    SET curtab->tab[i_cur_count].parent_table = ap->tabs[i_found_ndx].parent_table
    SET curtab->tab[i_cur_count].parent_table_db = ap->tabs[i_found_ndx].parent_table_db
    SET curtab->tab[i_cur_count].parent_column = ap->tabs[i_found_ndx].parent_column
    SET curtab->tab[i_cur_count].child_table = ap->tabs[i_found_ndx].child_table
    SET curtab->tab[i_cur_count].child_table_db = ap->tabs[i_found_ndx].child_table_db
    SET curtab->tab[i_cur_count].child_column = ap->tabs[i_found_ndx].child_column
    SET curtab->tab[i_cur_count].child_where = ap->tabs[i_found_ndx].child_where
    SET curtab->tab[i_cur_count].from_str = concat(curtab->tab[i_cur_ndx].from_str,",",ap->tabs[
     i_found_ndx].child_table)
    SET curtab->tab[i_cur_count].from_str_db = concat(curtab->tab[i_cur_ndx].from_str_db,",",ap->
     tabs[i_found_ndx].child_table_db)
    IF ((curtab->tab[i_cur_ndx].child_column="*_ID")
     AND (curtab->tab[i_cur_ndx].child_column != "*,*"))
     SET s_zero_row = concat(curtab->tab[i_cur_ndx].child_column,"!=0 and ")
    ELSE
     SET s_zero_row = " "
    ENDIF
    SET curtab->tab[i_cur_count].where_str = concat(evaluate(curtab->tab[i_cur_ndx].child_where," ",
      " ",concat(substring(6,textlen(curtab->tab[i_cur_ndx].child_where),curtab->tab[i_cur_ndx].
        child_where)," and ")),s_zero_row," list (",curtab->tab[i_cur_ndx].child_column,")")
    SET curtab->tab[i_cur_count].where_str_db = concat(evaluate(curtab->tab[i_cur_ndx].child_where,
      " "," ",concat(substring(6,textlen(curtab->tab[i_cur_ndx].child_where),curtab->tab[i_cur_ndx].
        child_where)," and ")),s_zero_row," list (",curtab->tab[i_cur_ndx].child_column,")")
    IF (i_cur_ndx=1)
     SET curtab->tab[i_cur_count].select_str = concat(trim(curtab->tab[i_cur_ndx].child_table,3),
      " where ",curtab->tab[i_cur_count].where_str," in (select ",curtab->tab[i_cur_ndx].
      parent_column,
      " from  ",trim(curtab->tab[i_cur_ndx].parent_table,3))
     SET curtab->tab[i_cur_count].select_str_db = concat(trim(curtab->tab[i_cur_ndx].child_table_db,3
       )," where ",curtab->tab[i_cur_count].where_str_db," in (select ",curtab->tab[i_cur_ndx].
      parent_column,
      " from  ",trim(curtab->tab[i_cur_ndx].parent_table_db,3))
     SET i_end_paren = ")"
    ELSE
     SET curtab->tab[i_cur_count].select_str = concat(curtab->tab[i_cur_ndx].select_str," where ",
      curtab->tab[i_cur_count].where_str," in (select ",curtab->tab[i_cur_ndx].parent_column,
      " from  ",trim(curtab->tab[i_cur_ndx].parent_table,3))
     SET curtab->tab[i_cur_count].select_str_db = concat(curtab->tab[i_cur_ndx].select_str_db,
      " where ",curtab->tab[i_cur_count].where_str_db," in (select ",curtab->tab[i_cur_ndx].
      parent_column,
      " from  ",trim(curtab->tab[i_cur_ndx].parent_table_db,3))
     SET i_end_paren = build(")",i_end_paren)
    ENDIF
   ENDIF
 END ;Subroutine
#end_program
 FREE RECORD ap
 FREE RECORD curtab
 CALL echo("**************End of dm_stmt_gen************************")
END GO
