CREATE PROGRAM dm_afd_schema_comp:dba
 SET dm_diff_cnt = 0
 SET envid = 0
 SELECT INTO "nl:"
  d.environment_id
  FROM dm_environment d
  WHERE d.environment_name=env_name
  DETAIL
   envid = d.environment_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("Invalid Environment Name")
  GO TO end_program
 ENDIF
 FREE SET all_table_list
 RECORD all_table_list(
   1 table_name[*]
     2 tname = c32
   1 table_count = i4
 )
 SET stat = alterlist(all_table_list->table_name,10)
 SET all_table_list->table_count = 0
 FREE SET table_list
 RECORD table_list(
   1 table_name[*]
     2 tname = c32
   1 table_count = i4
 )
 SET stat = alterlist(table_list->table_name,10)
 SET table_list->table_count = 0
 SELECT INTO "nl:"
  ui.table_name
  FROM dm_afd_tables ui,
   dm_alpha_features_env da
  WHERE (ui.alpha_feature_nbr=request->afdnumber)
   AND ui.alpha_feature_nbr=da.alpha_feature_nbr
   AND da.status != "SUCCESS"
   AND da.environment_id=envid
  ORDER BY ui.table_name
  DETAIL
   all_table_list->table_count = (all_table_list->table_count+ 1)
   IF (mod(all_table_list->table_count,10)=1
    AND (all_table_list->table_count != 1))
    stat = alterlist(all_table_list->table_name,(all_table_list->table_count+ 9))
   ENDIF
   all_table_list->table_name[all_table_list->table_count].tname = ui.table_name
  WITH nocounter
 ;end select
 SET from_column[500] = fillstring(200," ")
 SET to_column[500] = fillstring(200," ")
 SET cnt = 0
 FOR (cnt = 1 TO all_table_list->table_count)
   SET column_count1 = 0
   SET column_count = 0
   SET i = initarray(from_column,fillstring(200," "))
   SET i = initarray(to_column,fillstring(200," "))
   SELECT INTO "nl:"
    uic.column_name, uic.data_type, uic.data_length,
    uic.nullable, uic.column_seq, uic.nullable,
    uc.tablespace_name, uc.table_name, default_value = substring(1,40,uic.data_default)
    FROM dm_afd_columns uic,
     dm_afd_tables uc
    WHERE (uc.table_name=all_table_list->table_name[cnt].tname)
     AND uc.table_name=uic.table_name
    ORDER BY uc.table_name, uic.column_name
    DETAIL
     column_str = fillstring(200," "), column_str = build(uic.column_name," ",uic.data_type)
     IF (((uic.data_type="VARCHAR2") OR (((uic.data_type="CHAR") OR (uic.data_type="VARCHAR")) )) )
      column_str = build(column_str,cnvtstring(uic.data_length))
     ENDIF
     IF (default_value != fillstring(40," "))
      column_str = build(column_str," DEFAULT ",cnvtupper(default_value))
     ENDIF
     IF (uic.nullable="N")
      column_str = build(column_str," NOT NULL")
     ENDIF
     column_count1 = (column_count1+ 1), to_column[column_count1] = column_str
    FOOT  uc.table_name
     column_count1 = (column_count1+ 1), to_column[column_count1] = uc.tablespace_name, column_count1
      = (column_count1+ 1),
     to_column[column_count1] = build("TABLE NAME: ",uc.table_name)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    uic.column_name, uic.data_type, uic.data_length,
    uic.nullable, uic.column_id, uic.nullable,
    uc.tablespace_name, uc.table_name, default_value = substring(1,40,uic.data_default)
    FROM user_tab_columns uic,
     user_tables uc
    WHERE (uc.table_name=all_table_list->table_name[cnt].tname)
     AND uc.table_name=uic.table_name
     AND uc.tablespace_name="D_*"
    ORDER BY uc.table_name, uic.column_name
    DETAIL
     column_str = fillstring(200," "), column_str = build(uic.column_name,uic.data_type)
     IF (((uic.data_type="VARCHAR2") OR (((uic.data_type="CHAR") OR (uic.data_type="VARCHAR")) )) )
      column_str = build(column_str,cnvtstring(uic.data_length))
     ENDIF
     IF (default_value != fillstring(40," "))
      column_str = build(column_str," DEFAULT ",cnvtupper(default_value))
     ENDIF
     IF (uic.nullable="N")
      column_str = build(column_str," NOT NULL")
     ENDIF
     column_count = (column_count+ 1), from_column[column_count] = column_str
    FOOT  uc.table_name
     column_count = (column_count+ 1), from_column[column_count] = uc.tablespace_name, column_count
      = (column_count+ 1),
     from_column[column_count] = build("TABLE NAME: ",uc.table_name)
    WITH nocounter
   ;end select
   IF (column_count1 > column_count)
    SET column_count = column_count1
   ENDIF
   SET problem = 0
   SELECT INTO "nl:"
    *
    FROM dual
    DETAIL
     problem = 0, i = 0
     FOR (i = 1 TO column_count)
       IF ((from_column[i] != to_column[i]))
        problem = 1, dm_diff_cnt = (dm_diff_cnt+ 1)
       ENDIF
     ENDFOR
     IF (problem=1)
      table_list->table_count = (table_list->table_count+ 1)
      IF (mod(table_list->table_count,10)=1
       AND (table_list->table_count != 1))
       stat = alterlist(table_list->table_name,(table_list->table_count+ 9))
      ENDIF
      table_list->table_name[table_list->table_count].tname = all_table_list->table_name[cnt].tname
     ENDIF
    WITH nocounter
   ;end select
   SET column_count1 = 0
   SET column_count = 0
   SET i = initarray(from_column,fillstring(200," "))
   SET i = initarray(to_column,fillstring(200," "))
   SELECT INTO "nl:"
    dc.table_name, dc.constraint_name, dc.constraint_type,
    dc.parent_table_name, dc.status_ind, dcc.column_name,
    dcc.position
    FROM dm_afd_cons_columns dcc,
     dm_afd_constraints dc
    WHERE (dc.table_name=all_table_list->table_name[cnt].tname)
     AND dc.constraint_type IN ("P", "U")
     AND dc.constraint_name=dcc.constraint_name
     AND dc.table_name=dcc.table_name
    ORDER BY dc.table_name, dc.constraint_name, dcc.column_name
    DETAIL
     column_str = fillstring(200," "), column_str = concat(dc.constraint_name,dcc.column_name),
     column_count1 = (column_count1+ 1),
     to_column[column_count1] = column_str
    FOOT  dc.constraint_name
     column_count1 = (column_count1+ 1), to_column[column_count1] = dc.constraint_type
     IF (((dc.constraint_type="P") OR (dc.constraint_type="U")) )
      column_count1 = (column_count1+ 1), to_column[column_count1] = fillstring(30," ")
     ELSE
      column_count1 = (column_count1+ 1), to_column[column_count1] = dc.parent_table_name
     ENDIF
     IF (dc.constraint_type="R")
      column_count1 = (column_count1+ 1), to_column[column_count1] = fillstring(30," ")
     ELSE
      IF (dc.status_ind=1)
       column_count1 = (column_count1+ 1), to_column[column_count1] = "ENABLED"
      ELSE
       column_count1 = (column_count1+ 1), to_column[column_count1] = "DISABLED"
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    dc.table_name, dc.constraint_name, dc.constraint_type,
    dc.parent_table_name, dc.status_ind, dcc.column_name,
    dcc.position
    FROM dm_afd_cons_columns dcc,
     dm_afd_constraints dc
    WHERE (dc.table_name=all_table_list->table_name[cnt].tname)
     AND dc.constraint_type="R"
     AND dc.constraint_name=dcc.constraint_name
     AND dc.table_name=dcc.table_name
    ORDER BY dc.table_name, dc.constraint_name, dcc.column_name
    DETAIL
     column_str = fillstring(200," "), column_str = concat(dc.constraint_name,dcc.column_name),
     column_count1 = (column_count1+ 1),
     to_column[column_count1] = column_str
    FOOT  dc.constraint_name
     column_count1 = (column_count1+ 1), to_column[column_count1] = dc.constraint_type
     IF (((dc.constraint_type="P") OR (dc.constraint_type="U")) )
      column_count1 = (column_count1+ 1), to_column[column_count1] = fillstring(30," ")
     ELSE
      column_count1 = (column_count1+ 1), to_column[column_count1] = dc.parent_table_name
     ENDIF
     IF (dc.constraint_type="R")
      column_count1 = (column_count1+ 1), to_column[column_count1] = fillstring(30," ")
     ELSE
      IF (dc.status_ind=1)
       column_count1 = (column_count1+ 1), to_column[column_count1] = "ENABLED"
      ELSE
       column_count1 = (column_count1+ 1), to_column[column_count1] = "DISABLED"
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SET column_count = 0
   SELECT INTO "nl:"
    uc.table_name, uc.constraint_name, uc.constraint_type,
    uc.status, ucc.column_name, ucc.position
    FROM user_cons_columns ucc,
     user_constraints uc
    PLAN (uc
     WHERE uc.owner=currdbuser
      AND (uc.table_name=all_table_list->table_name[cnt].tname)
      AND uc.constraint_type IN ("P", "U"))
     JOIN (ucc
     WHERE ucc.owner=currdbuser
      AND uc.table_name=ucc.table_name
      AND ((uc.constraint_name=ucc.constraint_name) OR (((uc.constraint_name=concat(trim(ucc
       .constraint_name),"$C")) OR (uc.constraint_name=concat(substring(1,28,ucc.constraint_name),
      "$C"))) )) )
    ORDER BY uc.table_name, uc.constraint_name, ucc.column_name
    DETAIL
     column_str = fillstring(200," "), column_str = concat(uc.constraint_name,ucc.column_name),
     column_count = (column_count+ 1),
     from_column[column_count] = column_str
    FOOT  uc.constraint_name
     column_count = (column_count+ 1), from_column[column_count] = uc.constraint_type
     IF (((uc.constraint_type="P") OR (uc.constraint_type="U")) )
      column_count = (column_count+ 1), from_column[column_count] = fillstring(30," ")
     ELSE
      column_count = (column_count+ 1), from_column[column_count] = fillstring(30," ")
     ENDIF
     IF (uc.constraint_type="R")
      column_count = (column_count+ 1), from_column[column_count] = fillstring(30," ")
     ELSE
      column_count = (column_count+ 1), from_column[column_count] = uc.status
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    uc.table_name, uc.constraint_name, uc.constraint_type,
    uc.status, parent_table_name = uc2.table_name, ucc.column_name,
    ucc.position
    FROM user_cons_columns ucc,
     user_constraints uc2,
     user_constraints uc
    WHERE uc.owner=currdbuser
     AND (uc.table_name=all_table_list->table_name[cnt].tname)
     AND uc.constraint_type="R"
     AND uc2.owner=currdbuser
     AND ((uc2.constraint_name=uc.r_constraint_name) OR (((uc2.constraint_name=concat(trim(uc
      .r_constraint_name),"$C")) OR (uc2.constraint_name=concat(substring(1,28,uc.r_constraint_name),
     "$C"))) ))
     AND ucc.owner=currdbuser
     AND uc.table_name=ucc.table_name
     AND ((uc.constraint_name=ucc.constraint_name) OR (((uc.constraint_name=concat(trim(ucc
      .constraint_name),"$C")) OR (uc.constraint_name=concat(substring(1,28,ucc.constraint_name),"$C"
     ))) ))
    ORDER BY uc.table_name, uc.constraint_name, ucc.column_name
    DETAIL
     column_str = fillstring(200," "), column_str = concat(uc.constraint_name,ucc.column_name),
     column_count = (column_count+ 1),
     from_column[column_count] = column_str
    FOOT  uc.constraint_name
     column_count = (column_count+ 1), from_column[column_count] = uc.constraint_type
     IF (((uc.constraint_type="P") OR (uc.constraint_type="U")) )
      column_count = (column_count+ 1), from_column[column_count] = fillstring(30," ")
     ELSE
      column_count = (column_count+ 1), from_column[column_count] = parent_table_name
     ENDIF
     IF (uc.constraint_type="R")
      column_count = (column_count+ 1), from_column[column_count] = fillstring(30," ")
     ELSE
      column_count = (column_count+ 1), from_column[column_count] = uc.status
     ENDIF
    WITH nocounter
   ;end select
   IF (column_count1 > column_count)
    SET column_count = column_count1
   ENDIF
   SET problem = 0
   SELECT INTO "nl:"
    *
    FROM dual
    DETAIL
     problem = 0, i = 0
     FOR (i = 1 TO column_count)
       IF ((from_column[i] != to_column[i]))
        problem = 1, dm_diff_cnt = (dm_diff_cnt+ 1)
       ENDIF
     ENDFOR
    WITH nocounter
   ;end select
   IF (problem=1)
    SET in_list = 0
    SELECT INTO "nl:"
     *
     FROM dual
     DETAIL
      FOR (x = 1 TO table_list->table_count)
        IF ((all_table_list->table_name[cnt].tname=table_list->table_name[x].tname))
         in_list = 1
        ENDIF
      ENDFOR
     WITH nocounter
    ;end select
    IF (in_list=0)
     SET table_list->table_count = (table_list->table_count+ 1)
     IF (mod(table_list->table_count,10)=1
      AND (table_list->table_count != 1))
      SET stat = alterlist(table_list->table_name,(table_list->table_count+ 9))
     ENDIF
     SET table_list->table_name[table_list->table_count].tname = all_table_list->table_name[cnt].
     tname
    ENDIF
   ENDIF
   SET column_count1 = 0
   SET column_count = 0
   SET i = initarray(from_column,fillstring(200," "))
   SET i = initarray(to_column,fillstring(200," "))
   SELECT INTO "nl:"
    dic.table_name, dic.index_name, dic.column_name,
    dic.column_position, di.tablespace_name
    FROM dm_afd_index_columns dic,
     dm_afd_indexes di
    WHERE (di.table_name=all_table_list->table_name[cnt].tname)
     AND ((di.index_name=dic.index_name) OR (di.index_name=concat(trim(dic.index_name),"$C")))
     AND di.table_name=dic.table_name
    ORDER BY dic.table_name, dic.index_name, dic.column_name
    DETAIL
     column_str = fillstring(200," "), column_str = concat(dic.index_name,dic.column_name),
     column_count1 = (column_count1+ 1),
     to_column[column_count1] = column_str
    FOOT  dic.index_name
     column_count1 = (column_count1+ 1), to_column[column_count1] = di.tablespace_name
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    uic.table_name, uic.index_name, uic.column_name,
    uic.column_position, ui.tablespace_name
    FROM user_ind_columns uic,
     user_indexes ui
    WHERE ui.table_owner=currdbuser
     AND (ui.table_name=all_table_list->table_name[cnt].tname)
     AND ui.tablespace_name="I_*"
     AND ((ui.index_name=uic.index_name) OR (((ui.index_name=concat(trim(uic.index_name),"$C")) OR (
    ui.index_name=concat(substring(1,28,uic.index_name),"$C"))) ))
     AND ui.table_name=uic.table_name
    ORDER BY uic.table_name, uic.index_name, uic.column_name
    DETAIL
     column_str = fillstring(200," "), column_str = concat(uic.index_name,uic.column_name),
     column_count = (column_count+ 1),
     from_column[column_count] = column_str
    FOOT  uic.index_name
     column_count = (column_count+ 1), from_column[column_count] = ui.tablespace_name
    WITH nocounter
   ;end select
   IF (column_count1 > column_count)
    SET column_count = column_count1
   ENDIF
   SET problem = 0
   SELECT INTO "nl:"
    *
    FROM dual
    DETAIL
     problem = 0, i = 0
     FOR (i = 1 TO column_count)
       IF ((from_column[i] != to_column[i]))
        problem = 1, dm_diff_cnt = (dm_diff_cnt+ 1)
       ENDIF
     ENDFOR
    WITH nocounter
   ;end select
   IF (problem=1)
    SET in_list = 0
    SELECT INTO "nl:"
     *
     FROM dual
     DETAIL
      FOR (x = 1 TO table_list->table_count)
        IF ((all_table_list->table_name[cnt].tname=table_list->table_name[x].tname))
         in_list = 1
        ENDIF
      ENDFOR
     WITH nocounter
    ;end select
    IF (in_list=0)
     SET table_list->table_count = (table_list->table_count+ 1)
     IF (mod(table_list->table_count,10)=1
      AND (table_list->table_count != 1))
      SET stat = alterlist(table_list->table_name,(table_list->table_count+ 9))
     ENDIF
     SET table_list->table_name[table_list->table_count].tname = all_table_list->table_name[cnt].
     tname
    ENDIF
   ENDIF
 ENDFOR
 DELETE  FROM dm_table_list
  WHERE 1=1
 ;end delete
 COMMIT
 CALL echo("Inserting values into DM_TABLE_LIST...")
 FOR (x = 1 TO table_list->table_count)
  INSERT  FROM dm_table_list
   (table_name, updt_applctx, updt_dt_tm,
   updt_cnt, updt_id, updt_task)
   VALUES(table_list->table_name[x].tname, 0, cnvtdatetime(curdate,curtime3),
   0, 0, 0)
  ;end insert
  COMMIT
 ENDFOR
 SELECT INTO "nl:"
  d.table_name
  FROM dm_table_list d
  WITH nocounter
 ;end select
 IF (curqual > 0)
  UPDATE  FROM dm_alpha_features_env e
   SET e.status = "FAILED"
   WHERE (e.alpha_feature_nbr=request->afdnumber)
    AND e.environment_id=envid
   WITH nocounter
  ;end update
 ELSE
  UPDATE  FROM dm_alpha_features_env a
   SET a.status = "SUCCESS", a.end_dt_tm = cnvtdatetime(curdate,curtime3)
   WHERE (a.alpha_feature_nbr=request->afdnumber)
    AND a.environment_id=envid
   WITH nocounter
  ;end update
 ENDIF
 COMMIT
#end_program
END GO
