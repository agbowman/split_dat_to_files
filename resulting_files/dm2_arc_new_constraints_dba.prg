CREATE PROGRAM dm2_arc_new_constraints:dba
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
 IF ((validate(darsg_request->all_tab_ind,- (1))=- (1)))
  FREE RECORD darsg_request
  RECORD darsg_request(
    1 batch_selection = vc
    1 all_tab_ind = i2
    1 tabs[*]
      2 table_name = vc
      2 constraint_name = vc
  )
 ENDIF
 IF ((validate(darsg_reply->test_ind,- (1))=- (1)))
  FREE RECORD darsg_reply
  RECORD darsg_reply(
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
 FREE RECORD arc_cons
 RECORD arc_cons(
   1 data[*]
     2 child_constraint = vc
     2 child_table = vc
     2 parent_table = vc
     2 parent_constraint = vc
     2 child_column = vc
     2 parent_column = vc
 )
 DECLARE v_parent_column = vc
 DECLARE v_child_column = vc
 DECLARE v_long_col_ind = i2
 IF ((request->all_tab_ind=0))
  SELECT INTO "nl:"
   ucc.constraint_name, ucc.table_name, ucc.column_name,
   ucc.position
   FROM user_cons_columns ucc
   WHERE ucc.constraint_name=patstring(build(request->cons_prefix,"*"))
    AND  NOT ( EXISTS (
   (SELECT
    "x"
    FROM dm_arc_constraints dac
    WHERE dac.constraint_name=ucc.constraint_name
     AND (dac.archive_entity_name=request->batch_selection))))
   ORDER BY ucc.constraint_name, ucc.position
   HEAD REPORT
    cons_cnt = 0
   HEAD ucc.constraint_name
    cons_cnt = (cons_cnt+ 1)
    IF (mod(cons_cnt,10)=1)
     stat = alterlist(arc_cons->data,(cons_cnt+ 9))
    ENDIF
    arc_cons->data[cons_cnt].child_table = ucc.table_name, arc_cons->data[cons_cnt].child_constraint
     = ucc.constraint_name, v_child_column = ""
   DETAIL
    IF (v_child_column="")
     v_child_column = ucc.column_name
    ELSE
     v_child_column = concat(trim(v_child_column,3),",",trim(ucc.column_name))
    ENDIF
   FOOT  ucc.constraint_name
    arc_cons->data[cons_cnt].child_column = v_child_column
   FOOT REPORT
    stat = alterlist(arc_cons->data,cons_cnt)
   WITH nocounter
  ;end select
  IF (arc_error_check("An error occurred while retrieving constraints: ","ARCHIVE","PERSON")=1)
   GO TO end_program
  ENDIF
  FOR (cons_ndx = 1 TO size(arc_cons->data,5))
    SELECT INTO "nl:"
     uc.table_name, uc.constraint_name
     FROM user_constraints uc
     WHERE uc.owner="V500"
      AND (uc.constraint_name=
     (SELECT
      uc2.r_constraint_name
      FROM user_constraints uc2
      WHERE (uc2.constraint_name=arc_cons->data[cons_ndx].child_constraint)
       AND uc2.owner="V500"))
     DETAIL
      arc_cons->data[cons_ndx].parent_table = uc.table_name, arc_cons->data[cons_ndx].
      parent_constraint = uc.constraint_name
     WITH nocounter
    ;end select
    IF (arc_error_check("An error occurred while retrieving parent table and constraint names: ",
     "ARCHIVE","PERSON")=1)
     GO TO end_program
    ENDIF
    SELECT INTO "nl:"
     ucc.column_name, ucc.position
     FROM user_cons_columns ucc
     WHERE ucc.owner="V500"
      AND (ucc.constraint_name=arc_cons->data[cons_ndx].parent_constraint)
     ORDER BY ucc.position
     DETAIL
      IF ((arc_cons->data[cons_ndx].parent_column=""))
       arc_cons->data[cons_ndx].parent_column = trim(ucc.column_name,3)
      ELSE
       arc_cons->data[cons_ndx].parent_column = concat(trim(arc_cons->data[cons_ndx].parent_column,3),
        ",",trim(ucc.column_name,3))
      ENDIF
     WITH nocounter
    ;end select
    IF (arc_error_check("An error occurred while retrieving parent columns: ","ARCHIVE","PERSON")=1)
     GO TO end_program
    ENDIF
    INSERT  FROM dm_arc_constraints
     SET parent_table = arc_cons->data[cons_ndx].parent_table, parent_column = arc_cons->data[
      cons_ndx].parent_column, child_table = arc_cons->data[cons_ndx].child_table,
      child_column = arc_cons->data[cons_ndx].child_column, constraint_name = arc_cons->data[cons_ndx
      ].child_constraint, archive_entity_name = request->batch_selection,
      active_ind = 1, exclude_ind = 0, dm_arc_constraints_id = seq(dm_clinical_seq,nextval),
      updt_id = reqinfo->updt_id, updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_task = reqinfo->
      updt_task,
      updt_applctx = reqinfo->updt_applctx, updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (arc_error_check("An error occurred while inserting into dm_arc_constraints: ","ARCHIVE",
     "PERSON")=1)
     GO TO end_program
    ELSE
     COMMIT
    ENDIF
  ENDFOR
  SET stat = alterlist(darsg_request->tabs,size(arc_cons->data,5))
  SET darsg_request->batch_selection = request->batch_selection
  SET darsg_request->all_tab_ind = 0
  FOR (ac_ndx = 1 TO size(arc_cons->data,5))
   SET darsg_request->tabs[ac_ndx].table_name = arc_cons->data[ac_ndx].child_table
   SET darsg_request->tabs[ac_ndx].constraint_name = arc_cons->data[ac_ndx].child_constraint
  ENDFOR
 ELSE
  SET darsg_request->batch_selection = request->batch_selection
  SET darsg_request->all_tab_ind = 1
 ENDIF
 IF ((((darsg_request->all_tab_ind=1)) OR (size(darsg_request->tabs,5) > 0)) )
  SET reply->found_ind = 1
  EXECUTE dm2_arc_rest_stmt_gen  WITH replace("REQUEST","DARSG_REQUEST"), replace("REPLY",
   "DARSG_REPLY")
  IF ((darsg_reply->status_data.status="F"))
   SET reply->status_data.status = "F"
   GO TO end_program
  ENDIF
  FOR (rep_ndx = 1 TO size(darsg_reply->tabs,5))
    SELECT INTO "nl:"
     FROM user_tab_columns ut
     WHERE (ut.table_name=darsg_reply->tabs[rep_ndx].child_table)
      AND ut.data_type IN ("LONG", "LONG RAW", "RAW")
     WITH nocounter
    ;end select
    IF (curqual > 0)
     SET v_long_col_ind = 1
    ELSE
     SET v_long_col_ind = 0
    ENDIF
    IF (trim(darsg_reply->tabs[rep_ndx].child_where,3)="")
     UPDATE  FROM dm_arc_constraints dac
      SET dac.arc_delete = darsg_reply->tabs[rep_ndx].arc_del, dac.arc_insert = darsg_reply->tabs[
       rep_ndx].arc_ins, dac.rest_delete = darsg_reply->tabs[rep_ndx].rest_del,
       dac.rest_insert = darsg_reply->tabs[rep_ndx].rest_ins, dac.column_list = darsg_reply->tabs[
       rep_ndx].column_list, dac.long_col_ind = v_long_col_ind
      WHERE (dac.child_table=darsg_reply->tabs[rep_ndx].child_table)
       AND (dac.child_column=darsg_reply->tabs[rep_ndx].child_column)
       AND (dac.parent_table=darsg_reply->tabs[rep_ndx].parent_table)
       AND (dac.parent_column=darsg_reply->tabs[rep_ndx].parent_column)
       AND (dac.archive_entity_name=request->batch_selection)
      WITH nocounter
     ;end update
    ELSE
     UPDATE  FROM dm_arc_constraints dac
      SET dac.arc_delete = darsg_reply->tabs[rep_ndx].arc_del, dac.arc_insert = darsg_reply->tabs[
       rep_ndx].arc_ins, dac.rest_delete = darsg_reply->tabs[rep_ndx].rest_del,
       dac.rest_insert = darsg_reply->tabs[rep_ndx].rest_ins, dac.column_list = darsg_reply->tabs[
       rep_ndx].column_list, dac.long_col_ind = v_long_col_ind
      WHERE (dac.child_table=darsg_reply->tabs[rep_ndx].child_table)
       AND (dac.child_column=darsg_reply->tabs[rep_ndx].child_column)
       AND (dac.parent_table=darsg_reply->tabs[rep_ndx].parent_table)
       AND (dac.parent_column=darsg_reply->tabs[rep_ndx].parent_column)
       AND (dac.child_where=darsg_reply->tabs[rep_ndx].child_where)
       AND (dac.archive_entity_name=request->batch_selection)
      WITH nocounter
     ;end update
    ENDIF
    IF (curqual=0)
     INSERT  FROM dm_arc_constraints
      (parent_table, parent_column, child_table,
      child_column, child_where, constraint_name,
      archive_entity_name, active_ind, exclude_ind,
      dm_arc_constraints_id, updt_id, updt_dt_tm,
      updt_task, updt_applctx, updt_cnt,
      arc_delete, arc_insert, rest_delete,
      rest_insert, column_list, long_col_ind)
      VALUES(darsg_reply->tabs[rep_ndx].parent_table, darsg_reply->tabs[rep_ndx].parent_column,
      darsg_reply->tabs[rep_ndx].child_table,
      darsg_reply->tabs[rep_ndx].child_column, darsg_reply->tabs[rep_ndx].child_where, darsg_reply->
      tabs[rep_ndx].constraint_name,
      request->batch_selection, 1, 0,
      seq(dm_clinical_seq,nextval), reqinfo->updt_id, cnvtdatetime(curdate,curtime3),
      reqinfo->updt_task, reqinfo->updt_applctx, 0,
      darsg_reply->tabs[rep_ndx].arc_del, darsg_reply->tabs[rep_ndx].arc_ins, darsg_reply->tabs[
      rep_ndx].rest_del,
      darsg_reply->tabs[rep_ndx].rest_ins, darsg_reply->tabs[rep_ndx].column_list, v_long_col_ind)
     ;end insert
    ENDIF
    IF (arc_error_check("An error occurred while inserting into dm_arc_constraints: ","ARCHIVE",
     "PERSON")=1)
     GO TO end_program
    ELSE
     COMMIT
    ENDIF
  ENDFOR
 ENDIF
#end_program
 FREE RECORD darsg_request
 FREE RECORD darsg_reply
END GO
