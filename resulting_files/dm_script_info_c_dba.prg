CREATE PROGRAM dm_script_info_c:dba
 FREE RECORD dm_plan_tbl
 RECORD dm_plan_tbl(
   1 plan_info[*]
     2 script_name = vc
     2 statement_id = vc
     2 id = f8
     2 parent_id = f8
     2 parent_id_ni = i2
     2 operation = vc
     2 object_name = vc
     2 options = vc
     2 optimizer = vc
     2 cost = f8
 )
 IF ( NOT (validate(plan_write,0)))
  FREE RECORD plan_write
  RECORD plan_write(
    1 qual[*]
      2 statement_id = vc
      2 script_name = vc
      2 table_name = vc
      2 select_ind = i2
      2 insert_ind = i2
      2 update_ind = i2
      2 delete_ind = i2
      2 dont_write_ind = i2
  )
 ENDIF
 FREE RECORD sql
 RECORD sql(
   1 list[*]
     2 stmt = vc
     2 cost = f8
     2 optimizer = vc
 )
 FREE RECORD ndx_usage
 RECORD ndx_usage(
   1 data[*]
     2 table_name = vc
     2 script_name = vc
     2 full_tab_ind = i2
     2 index_name = vc
     2 access_type = vc
 )
 FREE RECORD inserts
 RECORD inserts(
   1 qual[*]
     2 table_name = vc
 )
 FREE RECORD ifile
 RECORD ifile(
   1 lines[*]
     2 linestring = vc
 )
 IF ( NOT (validate(dm_script_scanner_reply,0)))
  FREE RECORD dm_script_scanner_reply
  RECORD dm_script_scanner_reply(
    1 script_name = vc
    1 fail_ind = i2
    1 err_list[*]
      2 fail_number = i4
      2 fail_message = vc
  )
 ENDIF
 IF ( NOT (validate(full_table_scan,0)))
  FREE RECORD full_table_scan
  RECORD full_table_scan(
    1 list[*]
      2 full_tab_ind = i2
      2 script_name = vc
      2 table_name = vc
  )
 ENDIF
 DECLARE dm_plan_cnt = i4 WITH public, noconstant(0)
 DECLARE dm_for_cnt = i4
 DECLARE dm_sql_cnt = i4 WITH public, noconstant(0)
 DECLARE dm_status = i2
 DECLARE dm_select_ind = i4
 DECLARE dm_insert_ind = i4
 DECLARE dm_update_ind = i4
 DECLARE dm_delete_ind = i4
 DECLARE v_ndx_use_cnt = i4
 DECLARE insert_cnt = i4
 DECLARE temp_table_name = vc
 DECLARE dm_req_name = vc
 DECLARE v_ndx_found = i4
 DECLARE tbl_name = vc
 DECLARE tmp_select_ind = i2
 DECLARE tmp_insert_ind = i2
 DECLARE tmp_update_ind = i2
 DECLARE tmp_delete_ind = i2
 DECLARE dm_unique_dat1 = vc
 DECLARE dm_unique_dat_output = vc
 DECLARE dm_unique_plan = vc
 DECLARE found_ind = i2
 DECLARE dm_seq_tmp = i4
 DECLARE high_inst = f8
 SET dm_unique_dat1 = concat(dm_unique_dat1x,trim(cnvtstring(dm_cnt),3),".dat")
 SET dm_unique_dat_output = concat(dm_unique_dat_outputx,trim(cnvtstring(dm_cnt),3),".dat")
 SET dm_unique_plan = concat(dm_unique_planx,trim(cnvtstring(dm_cnt),3),".ccl")
 SET v_ndx_use_cnt = 0
 SET plan_count = 0
 SET insert_cnt = 0
 SET dm_error_ind = 0
 SET stat = alterlist(plan_write->qual,0)
 SET stat = alterlist(dm_plan_tbl->plan_info,0)
 DELETE  FROM plan_table pt
  WHERE pt.statement_id=patstring(concat(curuser,":*"))
  WITH nocounter
 ;end delete
 SET dm_str = concat("translate into '",value(dm_unique_dat1),"' ",value(dm_script->script_list[
   dm_cnt].script_name),":DBA with query go")
 CALL parser(dm_str,1)
 CALL compile(value(dm_unique_dat1),value(dm_unique_dat_output))
 IF (error(dm_err_msg,1) != 0)
  CALL echo("**************************")
  CALL echo(build("ERROR could NOT compile object -- ",dm_script->script_list[dm_cnt].script_name))
  CALL echo(dm_err_msg)
  CALL echo("**************************")
  SET dm_script_scanner_reply->fail_ind = 0
  SET dm_error_ind = 1
  SET dm_err = (dm_err+ 1)
  SET stat = alterlist(dm_script_scanner_reply->err_list,dm_err)
  SET dm_script_scanner_reply->err_list[dm_err].fail_message = "Success"
  SET d_exception = 0
  SELECT INTO "nl:"
   FROM script_scan_exception sse
   WHERE (sse.name=dm_script->script_list[dm_cnt].script_name)
   DETAIL
    d_exception = 1
   WITH nocounter
  ;end select
  IF (d_exception=0)
   INSERT  FROM script_scan_exception sse
    SET sse.name = dm_script->script_list[dm_cnt].script_name, sse.error_text = dm_err_msg
    WITH nocounter
   ;end insert
   COMMIT
  ENDIF
  GO TO end_program
 ELSE
  SELECT INTO value(dm_unique_plan)
   FROM dual
   HEAD REPORT
    dm_str = concat("execute _",trim(dm_script->script_list[dm_cnt].script_name,3),":GROUP99 go")
   DETAIL
    row 0, "set trace rdbdebug go", row + 1,
    dm_str, row + 1, "set trace nordbdebug go"
   WITH nocounter
  ;end select
  CALL parser("rdb alter session set optimizer_mode = first_rows go")
  CALL parser("rdb alter session set optimizer_index_cost_adj = 10 go")
  CALL parser("rdb alter session set optimizer_index_caching = 90 go")
  CALL compile(value(dm_unique_plan),value(dm_unique_dat_output))
  IF (error(dm_err_msg,1) != 0)
   CALL echo("**************************")
   CALL echo(concat("ERROR 2 could NOT compile object -- ",dm_script->script_list[dm_cnt].script_name
     ))
   CALL echo(dm_err_msg)
   CALL echo("**************************")
   SET dm_error_ind = 1
   SET dm_script_scanner_reply->fail_ind = 0
   SET dm_err = (dm_err+ 1)
   SET stat = alterlist(dm_script_scanner_reply->err_list,dm_err)
   SET dm_script_scanner_reply->err_list[dm_err].fail_message = "Success"
   SET d_exception = 0
   SELECT INTO "nl:"
    FROM script_scan_exception sse
    WHERE (sse.name=dm_script->script_list[dm_cnt].script_name)
    DETAIL
     d_exception = 1
    WITH nocounter
   ;end select
   IF (d_exception=0)
    INSERT  FROM script_scan_exception sse
     SET sse.name = dm_script->script_list[dm_cnt].script_name, sse.error_text = dm_err_msg
     WITH nocounter
    ;end insert
    COMMIT
   ENDIF
   GO TO end_program
  ENDIF
  SELECT INTO "nl:"
   parent_id_null = nullind(pt.parent_id)
   FROM plan_table pt
   WHERE pt.statement_id=patstring(concat(curuser,":*"))
   ORDER BY pt.statement_id
   HEAD REPORT
    dm_plan_cnt = 0
   DETAIL
    dm_plan_cnt = (dm_plan_cnt+ 1), stat = alterlist(dm_plan_tbl->plan_info,(dm_plan_cnt+ 9)),
    dm_plan_tbl->plan_info[dm_plan_cnt].script_name = dm_script->script_list[dm_cnt].script_name,
    dm_plan_tbl->plan_info[dm_plan_cnt].statement_id = pt.statement_id, dm_plan_tbl->plan_info[
    dm_plan_cnt].id = pt.id
    IF (parent_id_null=1)
     dm_plan_tbl->plan_info[dm_plan_cnt].parent_id_ni = 1
    ELSE
     dm_plan_tbl->plan_info[dm_plan_cnt].parent_id_ni = 0, dm_plan_tbl->plan_info[dm_plan_cnt].
     parent_id = pt.parent_id
    ENDIF
    dm_plan_tbl->plan_info[dm_plan_cnt].operation = pt.operation, dm_plan_tbl->plan_info[dm_plan_cnt]
    .object_name = pt.object_name, dm_plan_tbl->plan_info[dm_plan_cnt].options = pt.options,
    dm_plan_tbl->plan_info[dm_plan_cnt].optimizer = pt.optimizer, dm_plan_tbl->plan_info[dm_plan_cnt]
    .cost = pt.cost
   FOOT REPORT
    stat = alterlist(dm_plan_tbl->plan_info,dm_plan_cnt)
   WITH nocounter
  ;end select
  ROLLBACK
  FREE DEFINE rtl2
  DEFINE rtl2 value(dm_unique_dat_output)
  SELECT INTO "nl:"
   FROM rtl2t t
   WHERE t.line > " "
   HEAD REPORT
    dm_tmp = 0, dm_found = 0, dm_sql_cnt = 0
   DETAIL
    IF (findstring("check query",t.line)=0
     AND substring(1,5,t.line) != "RDBMS")
     dm_tmp = (dm_tmp+ 1)
     IF (cnvtupper(trim(t.line,3))="RDB")
      dm_sql_cnt = (dm_sql_cnt+ 1), dm_found = 1, stat = alterlist(sql->list,dm_sql_cnt)
     ENDIF
     IF (dm_sql_cnt > 0)
      IF (dm_found=0)
       IF (textlen(sql->list[dm_sql_cnt].stmt) < 3800)
        sql->list[dm_sql_cnt].stmt = concat(sql->list[dm_sql_cnt].stmt,t.line)
       ENDIF
      ELSE
       sql->list[dm_sql_cnt].stmt = concat(trim(t.line)," ")
      ENDIF
      dm_found = 0
     ENDIF
    ENDIF
   FOOT REPORT
    stat = alterlist(sql->list,dm_sql_cnt)
   WITH nocounter
  ;end select
  FOR (xx = 1 TO dm_plan_cnt)
    SET select_ind = 0
    SET insert_ind = 0
    SET update_ind = 0
    SET delete_ind = 0
    IF ((dm_plan_tbl->plan_info[xx].operation="SELECT STATEMENT"))
     SET select_ind = 1
     SET insert_ind = 0
     SET update_ind = 0
     SET delete_ind = 0
     SET tmp_stat_id = dm_plan_tbl->plan_info[xx].statement_id
     FOR (yy = 1 TO dm_plan_cnt)
       IF ((dm_plan_tbl->plan_info[yy].statement_id=tmp_stat_id))
        IF ((dm_plan_tbl->plan_info[yy].operation="TABLE ACCESS"))
         SET dm_plan_tbl->plan_info[xx].object_name = dm_plan_tbl->plan_info[yy].object_name
         CALL add_tab_access(dm_script->script_list[dm_cnt].script_name,dm_plan_tbl->plan_info[xx].
          object_name,xx,dm_cnt,select_ind,
          insert_ind,update_ind,delete_ind)
         IF ((dm_plan_tbl->plan_info[yy].options="FULL"))
          SET v_ndx_use_cnt = (v_ndx_use_cnt+ 1)
          IF (mod(v_ndx_use_cnt,100)=1)
           SET stat = alterlist(ndx_usage->data,(v_ndx_use_cnt+ 99))
          ENDIF
          SET ndx_usage->data[v_ndx_use_cnt].table_name = dm_plan_tbl->plan_info[xx].object_name
          SET ndx_usage->data[v_ndx_use_cnt].script_name = dm_script->script_list[dm_cnt].script_name
          SET ndx_usage->data[v_ndx_use_cnt].full_tab_ind = 1
          SET full_tab_cnt = (full_tab_cnt+ 1)
          SET stat = alterlist(full_table_scan->list,full_tab_cnt)
          SET full_table_scan->list[full_tab_cnt].full_tab_ind = 1
          SET full_table_scan->list[full_tab_cnt].script_name = dm_script->script_list[dm_cnt].
          script_name
          SET full_table_scan->list[full_tab_cnt].table_name = dm_plan_tbl->plan_info[xx].object_name
         ENDIF
        ELSEIF ((dm_plan_tbl->plan_info[yy].operation="INDEX"))
         SET temp_table_name = get_tbl_by_index(value(dm_plan_tbl->plan_info[yy].object_name))
         IF (temp_table_name=" ")
          SET temp_table_name = dm_plan_tbl->plan_info[xx].object_name
         ENDIF
         SET dm_plan_tbl->plan_info[xx].object_name = temp_table_name
         CALL add_tab_access(dm_script->script_list[dm_cnt].script_name,dm_plan_tbl->plan_info[xx].
          object_name,xx,dm_cnt,select_ind,
          insert_ind,update_ind,delete_ind)
         IF ((dm_plan_tbl->plan_info[yy].options="FULL SCAN"))
          SET full_tab_cnt = (full_tab_cnt+ 1)
          SET stat = alterlist(full_table_scan->list,full_tab_cnt)
          SET full_table_scan->list[full_tab_cnt].full_tab_ind = 1
          SET full_table_scan->list[full_tab_cnt].script_name = dm_script->script_list[dm_cnt].
          script_name
          SET full_table_scan->list[full_tab_cnt].table_name = temp_table_name
         ELSE
          SET v_ndx_use_cnt = (v_ndx_use_cnt+ 1)
          IF (mod(v_ndx_use_cnt,100)=1)
           SET stat = alterlist(ndx_usage->data,(v_ndx_use_cnt+ 99))
          ENDIF
          SET ndx_usage->data[v_ndx_use_cnt].table_name = temp_table_name
          SET ndx_usage->data[v_ndx_use_cnt].script_name = dm_script->script_list[dm_cnt].script_name
          SET ndx_usage->data[v_ndx_use_cnt].full_tab_ind = 0
          SET ndx_usage->data[v_ndx_use_cnt].index_name = dm_plan_tbl->plan_info[yy].object_name
          SET ndx_usage->data[v_ndx_use_cnt].access_type = dm_plan_tbl->plan_info[yy].options
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
    ELSEIF ((dm_plan_tbl->plan_info[xx].operation="INSERT STATEMENT"))
     SET select_ind = 0
     SET insert_ind = 1
     SET update_ind = 0
     SET delete_ind = 0
     SET insert_cnt = (insert_cnt+ 1)
     SET tmp_stat_id = dm_plan_tbl->plan_info[xx].statement_id
     FOR (yy = 1 TO dm_plan_cnt)
       IF ((dm_plan_tbl->plan_info[yy].statement_id=tmp_stat_id))
        SET temp_table_name = build(char(169),cnvtstring(insert_cnt))
        SET dm_plan_tbl->plan_info[xx].object_name = temp_table_name
        CALL add_tab_access(dm_script->script_list[dm_cnt].script_name,dm_plan_tbl->plan_info[xx].
         object_name,xx,dm_cnt,select_ind,
         insert_ind,update_ind,delete_ind)
       ENDIF
     ENDFOR
    ELSEIF ((dm_plan_tbl->plan_info[xx].operation="UPDATE STATEMENT"))
     SET select_ind = 1
     SET insert_ind = 0
     SET update_ind = 0
     SET delete_ind = 0
     SET tmp_stat_id = dm_plan_tbl->plan_info[xx].statement_id
     FOR (yy = 1 TO dm_plan_cnt)
       IF ((dm_plan_tbl->plan_info[yy].statement_id=tmp_stat_id))
        IF ((dm_plan_tbl->plan_info[yy].operation="UPDATE"))
         SET update_ind = 1
         SET select_ind = 0
         SET dm_plan_tbl->plan_info[xx].object_name = dm_plan_tbl->plan_info[yy].object_name
         CALL add_tab_access(dm_script->script_list[dm_cnt].script_name,dm_plan_tbl->plan_info[xx].
          object_name,xx,dm_cnt,select_ind,
          insert_ind,update_ind,delete_ind)
         SET update_ind = 0
         SET select_ind = 1
        ENDIF
        IF ((dm_plan_tbl->plan_info[yy].operation="TABLE ACCESS"))
         SET dm_plan_tbl->plan_info[xx].object_name = dm_plan_tbl->plan_info[yy].object_name
         CALL add_tab_access(dm_script->script_list[dm_cnt].script_name,dm_plan_tbl->plan_info[xx].
          object_name,xx,dm_cnt,select_ind,
          insert_ind,update_ind,delete_ind)
         IF ((dm_plan_tbl->plan_info[yy].options="FULL"))
          SET v_ndx_use_cnt = (v_ndx_use_cnt+ 1)
          IF (mod(v_ndx_use_cnt,100)=1)
           SET stat = alterlist(ndx_usage->data,(v_ndx_use_cnt+ 99))
          ENDIF
          SET ndx_usage->data[v_ndx_use_cnt].table_name = dm_plan_tbl->plan_info[xx].object_name
          SET ndx_usage->data[v_ndx_use_cnt].script_name = dm_script->script_list[dm_cnt].script_name
          SET ndx_usage->data[v_ndx_use_cnt].full_tab_ind = 1
          SET full_tab_cnt = (full_tab_cnt+ 1)
          SET stat = alterlist(full_table_scan->list,full_tab_cnt)
          SET full_table_scan->list[full_tab_cnt].full_tab_ind = 1
          SET full_table_scan->list[full_tab_cnt].script_name = dm_script->script_list[dm_cnt].
          script_name
          SET full_table_scan->list[full_tab_cnt].table_name = dm_plan_tbl->plan_info[xx].object_name
         ENDIF
        ELSEIF ((dm_plan_tbl->plan_info[yy].operation="INDEX"))
         SET temp_table_name = get_tbl_by_index(value(dm_plan_tbl->plan_info[yy].object_name))
         IF (temp_table_name=" ")
          SET temp_table_name = dm_plan_tbl->plan_info[xx].object_name
         ENDIF
         SET dm_plan_tbl->plan_info[xx].object_name = temp_table_name
         CALL add_tab_access(dm_script->script_list[dm_cnt].script_name,dm_plan_tbl->plan_info[xx].
          object_name,xx,dm_cnt,select_ind,
          insert_ind,update_ind,delete_ind)
         SET v_ndx_use_cnt = (v_ndx_use_cnt+ 1)
         IF (mod(v_ndx_use_cnt,100)=1)
          SET stat = alterlist(ndx_usage->data,(v_ndx_use_cnt+ 99))
         ENDIF
         SET ndx_usage->data[v_ndx_use_cnt].table_name = temp_table_name
         SET ndx_usage->data[v_ndx_use_cnt].script_name = dm_script->script_list[dm_cnt].script_name
         SET ndx_usage->data[v_ndx_use_cnt].full_tab_ind = 0
         SET ndx_usage->data[v_ndx_use_cnt].index_name = dm_plan_tbl->plan_info[yy].object_name
         SET ndx_usage->data[v_ndx_use_cnt].access_type = dm_plan_tbl->plan_info[yy].options
        ENDIF
       ENDIF
     ENDFOR
    ELSEIF ((dm_plan_tbl->plan_info[xx].operation="DELETE STATEMENT"))
     SET select_ind = 1
     SET insert_ind = 0
     SET update_ind = 0
     SET delete_ind = 0
     SET tmp_stat_id = dm_plan_tbl->plan_info[xx].statement_id
     FOR (yy = 1 TO dm_plan_cnt)
       IF ((dm_plan_tbl->plan_info[yy].statement_id=tmp_stat_id))
        IF ((dm_plan_tbl->plan_info[yy].operation="DELETE"))
         SET delete_ind = 1
         SET select_ind = 0
         SET dm_plan_tbl->plan_info[xx].object_name = dm_plan_tbl->plan_info[yy].object_name
         CALL add_tab_access(dm_script->script_list[dm_cnt].script_name,dm_plan_tbl->plan_info[xx].
          object_name,xx,dm_cnt,select_ind,
          insert_ind,update_ind,delete_ind)
         SET delete_ind = 0
         SET select_ind = 1
        ENDIF
        IF ((dm_plan_tbl->plan_info[yy].operation="TABLE ACCESS"))
         SET dm_plan_tbl->plan_info[xx].object_name = dm_plan_tbl->plan_info[yy].object_name
         CALL add_tab_access(dm_script->script_list[dm_cnt].script_name,dm_plan_tbl->plan_info[xx].
          object_name,xx,dm_cnt,select_ind,
          insert_ind,update_ind,delete_ind)
         IF ((dm_plan_tbl->plan_info[yy].options="FULL"))
          SET v_ndx_use_cnt = (v_ndx_use_cnt+ 1)
          IF (mod(v_ndx_use_cnt,100)=1)
           SET stat = alterlist(ndx_usage->data,(v_ndx_use_cnt+ 99))
          ENDIF
          SET ndx_usage->data[v_ndx_use_cnt].table_name = dm_plan_tbl->plan_info[xx].object_name
          SET ndx_usage->data[v_ndx_use_cnt].script_name = dm_script->script_list[dm_cnt].script_name
          SET ndx_usage->data[v_ndx_use_cnt].full_tab_ind = 1
          SET full_tab_cnt = (full_tab_cnt+ 1)
          SET stat = alterlist(full_table_scan->list,full_tab_cnt)
          SET full_table_scan->list[full_tab_cnt].full_tab_ind = 1
          SET full_table_scan->list[full_tab_cnt].script_name = dm_script->script_list[dm_cnt].
          script_name
          SET full_table_scan->list[full_tab_cnt].table_name = dm_plan_tbl->plan_info[xx].object_name
         ENDIF
        ELSEIF ((dm_plan_tbl->plan_info[yy].operation="INDEX"))
         SET temp_table_name = get_tbl_by_index(value(dm_plan_tbl->plan_info[yy].object_name))
         IF (temp_table_name=" ")
          SET temp_table_name = dm_plan_tbl->plan_info[xx].object_name
         ENDIF
         SET dm_plan_tbl->plan_info[xx].object_name = temp_table_name
         CALL add_tab_access(dm_script->script_list[dm_cnt].script_name,dm_plan_tbl->plan_info[xx].
          object_name,xx,dm_cnt,select_ind,
          insert_ind,update_ind,delete_ind)
         SET v_ndx_use_cnt = (v_ndx_use_cnt+ 1)
         IF (mod(v_ndx_use_cnt,100)=1)
          SET stat = alterlist(ndx_usage->data,(v_ndx_use_cnt+ 99))
         ENDIF
         SET ndx_usage->data[v_ndx_use_cnt].table_name = temp_table_name
         SET ndx_usage->data[v_ndx_use_cnt].script_name = dm_script->script_list[dm_cnt].script_name
         SET ndx_usage->data[v_ndx_use_cnt].full_tab_ind = 0
         SET ndx_usage->data[v_ndx_use_cnt].index_name = dm_plan_tbl->plan_info[yy].object_name
         SET ndx_usage->data[v_ndx_use_cnt].access_type = dm_plan_tbl->plan_info[yy].options
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
  ENDFOR
  SET stat = alterlist(ndx_usage->data,v_ndx_use_cnt)
 ENDIF
 IF (insert_cnt > 0)
  SET stat = alterlist(inserts->qual,0)
  SET stat = alterlist(ifile->lines,0)
  SET line_cnt = 0
  SELECT INTO "nl:"
   log = r.line
   FROM rtl2t r
   DETAIL
    line_cnt = (line_cnt+ 1), stat = alterlist(ifile->lines,line_cnt), ifile->lines[line_cnt].
    linestring = r.line
   WITH nocounter
  ;end select
  SET tblstart = 0
  SET tblend = 0
  FOR (xx = 1 TO line_cnt)
    IF (findstring("INSERT",ifile->lines[xx].linestring,1) > 0)
     SET tblstart = findstring("(",ifile->lines[xx].linestring,1)
     SET tblend = findstring(")",ifile->lines[xx].linestring,1)
     SET count = (size(inserts->qual,5)+ 1)
     SET stat = alterlist(inserts->qual,count)
     SET tmpstr = trim(substring((tblstart+ 1),((tblend - tblstart) - 1),ifile->lines[xx].linestring),
      3)
     FOR (yy = 1 TO size(tmpstr))
       IF (substring(yy,1,tmpstr) != char(32))
        SET inserts->qual[count].table_name = build(inserts->qual[count].table_name,substring(yy,1,
          tmpstr))
       ELSE
        SET yy = (size(tmpstr)+ 1)
       ENDIF
     ENDFOR
    ENDIF
  ENDFOR
  FOR (xx = 1 TO size(inserts->qual,5))
    FOR (yy = 1 TO size(plan_write->qual,5))
      IF ((build(char(169),cnvtstring(xx))=plan_write->qual[yy].table_name))
       SET plan_write->qual[yy].table_name = inserts->qual[xx].table_name
       SET v_ndx_found = binsearch3(plan_write->qual[yy].script_name,plan_write->qual[yy].table_name)
       IF (v_ndx_found > 0)
        SET plan_write->qual[v_ndx_found].insert_ind = 1
        SET plan_write->qual[yy].dont_write_ind = 1
       ENDIF
      ENDIF
    ENDFOR
  ENDFOR
 ENDIF
 IF (dm_error_ind=0)
  SET found_ind = 0
  SELECT INTO "nl:"
   FROM dm_script_info_env dse
   WHERE (dse.script_name=dm_script->script_list[dm_cnt].script_name)
    AND (dse.environment_id=dm_script->dm_environ_id)
   ORDER BY dse.project_instance DESC
   HEAD REPORT
    high_inst = dse.project_instance
   DETAIL
    IF ((dse.project_instance=dm_script->project_instance))
     found_ind = 1
    ENDIF
   WITH nocounter
  ;end select
  IF (found_ind=1)
   UPDATE  FROM dm_script_info_env dse
    SET dse.current_instance_ind =
     IF ((dm_script->project_instance=high_inst)) 1
     ELSE 0
     ENDIF
     , dse.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE (dse.script_name=dm_script->script_list[dm_cnt].script_name)
     AND (dse.project_instance=dm_script->project_instance)
     AND (dse.environment_id=dm_script->dm_environ_id)
    WITH nocounter
   ;end update
  ELSE
   UPDATE  FROM dm_script_info_env dse
    SET dse.current_instance_ind = 0
    WHERE (dse.script_name=dm_script->script_list[dm_cnt].script_name)
     AND (dse.environment_id=dm_script->dm_environ_id)
    WITH nocounter
   ;end update
   INSERT  FROM dm_script_info_env dse
    SET dse.environment_id = dm_script->dm_environ_id, dse.script_name = dm_script->script_list[
     dm_cnt].script_name, dse.project_instance = dm_script->project_instance,
     dse.current_instance_ind = 1, dse.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end insert
  ENDIF
  DELETE  FROM dm_script_info_ndx_env dx
   WHERE (dx.environment_id=dm_script->dm_environ_id)
    AND (dx.script_name=dm_script->script_list[dm_cnt].script_name)
    AND (dx.project_instance=dm_script->project_instance)
   WITH nocounter
  ;end delete
  FOR (dm_for_cnt2 = 1 TO v_ndx_use_cnt)
    SET found_ind = 0
    SELECT INTO "nl:"
     FROM dm_script_info_ndx_env dx
     WHERE (dx.environment_id=dm_script->dm_environ_id)
      AND (dx.script_name=dm_script->script_list[dm_cnt].script_name)
      AND (dx.project_instance=dm_script->project_instance)
      AND (dx.index_name=ndx_usage->data[dm_for_cnt2].index_name)
     DETAIL
      found_ind = 1
     WITH nocounter
    ;end select
    IF ((ndx_usage->data[dm_for_cnt2].full_tab_ind=0))
     IF (found_ind=1)
      UPDATE  FROM dm_script_info_ndx_env dx
       SET dx.table_name = ndx_usage->data[dm_for_cnt2].table_name
       WHERE (dx.environment_id=dm_script->dm_environ_id)
        AND (dx.script_name=dm_script->script_list[dm_cnt].script_name)
        AND (dx.project_instance=dm_script->project_instance)
        AND (dx.index_name=ndx_usage->data[dm_for_cnt2].index_name)
       WITH nocounter
      ;end update
     ELSE
      INSERT  FROM dm_script_info_ndx_env dx
       SET dx.environment_id = dm_script->dm_environ_id, dx.script_name = dm_script->script_list[
        dm_cnt].script_name, dx.table_name = ndx_usage->data[dm_for_cnt2].table_name,
        dx.index_name = ndx_usage->data[dm_for_cnt2].index_name, dx.project_instance = dm_script->
        project_instance
       WITH nocounter
      ;end insert
     ENDIF
    ENDIF
  ENDFOR
  DELETE  FROM dm_script_info_tbl_env dst
   WHERE (dst.environment_id=dm_script->dm_environ_id)
    AND (dst.script_name=dm_script->script_list[dm_cnt].script_name)
    AND (dst.project_instance=dm_script->project_instance)
   WITH nocounter
  ;end delete
  FOR (dm_for_cnt4 = 1 TO size(plan_write->qual,5))
    IF ((plan_write->qual[dm_for_cnt4].dont_write_ind=0))
     INSERT  FROM dm_script_info_tbl_env dst
      SET dst.environment_id = dm_script->dm_environ_id, dst.script_name = dm_script->script_list[
       dm_cnt].script_name, dst.table_name = plan_write->qual[dm_for_cnt4].table_name,
       dst.project_instance = dm_script->project_instance, dst.select_ind = plan_write->qual[
       dm_for_cnt4].select_ind, dst.insert_ind = plan_write->qual[dm_for_cnt4].insert_ind,
       dst.update_ind = plan_write->qual[dm_for_cnt4].update_ind, dst.delete_ind = plan_write->qual[
       dm_for_cnt4].delete_ind, dst.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WITH counter
     ;end insert
    ENDIF
  ENDFOR
  IF (dm_plan_cnt > 0)
   SELECT INTO "nl:"
    h_plan_id = dm_plan_tbl->plan_info[d.seq].statement_id
    FROM (dummyt d  WITH seq = dm_plan_cnt)
    ORDER BY h_plan_id
    HEAD REPORT
     dm_sql_cost_cnt = 0
    DETAIL
     IF ((dm_plan_tbl->plan_info[d.seq].id=0)
      AND (dm_plan_tbl->plan_info[d.seq].parent_id_ni=1))
      dm_sql_cost_cnt = (dm_sql_cost_cnt+ 1), sql->list[dm_sql_cost_cnt].cost = dm_plan_tbl->
      plan_info[d.seq].cost, sql->list[dm_sql_cost_cnt].optimizer = dm_plan_tbl->plan_info[d.seq].
      optimizer
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
  DELETE  FROM dm_script_info_sql_env dss
   WHERE (dss.script_name=dm_script->script_list[dm_cnt].script_name)
    AND (dss.environment_id=dm_script->dm_environ_id)
    AND (dss.project_instance=dm_script->project_instance)
   WITH nocounter
  ;end delete
  FOR (dm_for_cnt3 = 1 TO dm_sql_cnt)
    SELECT INTO "nl:"
     y = seq(dm_clinical_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      dm_seq_tmp = y
     WITH format, counter
    ;end select
    INSERT  FROM dm_script_info_sql_env dss
     SET dss.environment_id = dm_script->dm_environ_id, dss.script_name = dm_script->script_list[
      dm_cnt].script_name, dss.project_instance = dm_script->project_instance,
      dss.sql_seq = dm_seq_tmp, dss.cost = sql->list[dm_for_cnt3].cost, dss.optimizer = sql->list[
      dm_for_cnt3].optimizer,
      dss.sql_stmt = substring(1,4000,sql->list[dm_for_cnt3].stmt)
     WITH nocounter
    ;end insert
    COMMIT
  ENDFOR
 ENDIF
 SET dm_str = concat("drop program _",trim(dm_script->script_list[dm_cnt].script_name,3),
  ":GROUP99 go")
 CALL parser(dm_str)
 GO TO end_program
 SUBROUTINE get_tbl_by_index(index_namein)
   SELECT INTO "nl:"
    u.table_name
    FROM user_indexes u
    WHERE u.index_name=index_namein
    DETAIL
     tbl_name = u.table_name
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET tbl_name = " "
   ENDIF
   RETURN(tbl_name)
 END ;Subroutine
 SUBROUTINE binsearch3(i_key,i_tab_name)
   DECLARE v_low = i4 WITH noconstant(0)
   DECLARE v_mid = i4 WITH noconstant(0)
   DECLARE v_high = i4
   DECLARE v_temp_ndx = i4
   SET v_high = size(plan_write->qual,5)
   WHILE (((v_high - v_low) > 1))
    SET v_mid = cnvtint(((v_high+ v_low)/ 2))
    IF ((i_key <= plan_write->qual[v_mid].script_name))
     SET v_high = v_mid
    ELSE
     SET v_low = v_mid
    ENDIF
   ENDWHILE
   IF ((i_key=plan_write->qual[v_high].script_name))
    SET v_temp_ndx = v_high
    WHILE (v_temp_ndx <= size(plan_write->qual,5))
      IF ((i_key=plan_write->qual[v_temp_ndx].script_name))
       IF ((plan_write->qual[v_temp_ndx].table_name=i_tab_name))
        RETURN(v_temp_ndx)
       ENDIF
       SET v_temp_ndx = (v_temp_ndx+ 1)
      ELSE
       SET v_temp_ndx = (size(plan_write->qual,5)+ 1)
      ENDIF
    ENDWHILE
    SET v_temp_ndx = (v_high - 1)
    WHILE (v_temp_ndx > 0)
      IF ((i_key=plan_write->qual[v_temp_ndx].script_name))
       IF ((plan_write->qual[v_temp_ndx].table_name=i_tab_name))
        RETURN(v_temp_ndx)
       ENDIF
       SET v_temp_ndx = (v_temp_ndx - 1)
      ELSE
       SET v_temp_ndx = 0
      ENDIF
    ENDWHILE
    RETURN(- (1))
   ELSE
    RETURN(- (1))
   ENDIF
 END ;Subroutine
 SUBROUTINE searchback(i_key,i_tab_name)
   DECLARE v_temp_ndx = i4
   SET v_temp_ndx = size(plan_write->qual,5)
   WHILE (v_temp_ndx > 0)
     IF ((i_key=plan_write->qual[v_temp_ndx].script_name))
      IF ((plan_write->qual[v_temp_ndx].table_name=i_tab_name))
       RETURN(v_temp_ndx)
      ENDIF
      SET v_temp_ndx = (v_temp_ndx - 1)
     ELSE
      SET v_temp_ndx = 0
     ENDIF
   ENDWHILE
   RETURN(- (1))
 END ;Subroutine
 SUBROUTINE add_tab_access(i_script_name,i_table_name,i_xx,i_p_ndx,i_select_ind,i_insert_ind,
  i_update_ind,i_delete_ind)
  SET v_ndx_found = binsearch3(i_script_name,i_table_name)
  IF ((v_ndx_found=- (1)))
   SET plan_count = (size(plan_write->qual,5)+ 1)
   SET stat = alterlist(plan_write->qual,plan_count)
   SET plan_write->qual[plan_count].script_name = i_script_name
   SET plan_write->qual[plan_count].table_name = i_table_name
   SET plan_write->qual[plan_count].select_ind = i_select_ind
   SET plan_write->qual[plan_count].insert_ind = i_insert_ind
   SET plan_write->qual[plan_count].update_ind = i_update_ind
   SET plan_write->qual[plan_count].delete_ind = i_delete_ind
   SET plan_write->qual[plan_count].dont_write_ind = 0
   SET plan_write->qual[plan_count].statement_id = dm_plan_tbl->plan_info[i_xx].statement_id
  ELSE
   IF (i_select_ind=1)
    SET plan_write->qual[v_ndx_found].select_ind = i_select_ind
   ENDIF
   IF (i_insert_ind=1)
    SET plan_write->qual[v_ndx_found].insert_ind = i_insert_ind
   ENDIF
   IF (i_update_ind=1)
    SET plan_write->qual[v_ndx_found].update_ind = i_update_ind
   ENDIF
   IF (i_delete_ind=1)
    SET plan_write->qual[v_ndx_found].delete_ind = i_delete_ind
   ENDIF
  ENDIF
 END ;Subroutine
#end_program
 FREE RECORD dm_plan_tbl
 FREE RECORD sql
 FREE RECORD ndx_usage
 FREE RECORD inserts
 FREE RECORD ifile
END GO
