CREATE PROGRAM dm_ddl_gen_main:dba
 FREE RECORD ddl_gen
 RECORD ddl_gen(
   1 file_name = vc
   1 file_size = vc
   1 txt = vc
 )
 SET environment_id =  $1
 SET schema_date = cnvtdatetime("31-DEC-1900")
 SET filename2 =  $2
 SET filename3 = concat( $2,"3")
 SET tablespaces_only =  $3
 SET valid_env_ind = 0
 SET valid_schema_date_ind = 0
 SET ddl_failed = 0
 SET valid_env_ind = 0
 SELECT INTO "nl:"
  de.environment_id
  FROM dm_environment de
  PLAN (de
   WHERE de.environment_id=environment_id)
  DETAIL
   valid_env_ind = 1
  WITH nocounter
 ;end select
 SET valid_schema_date_ind = 0
 SELECT INTO "nl:"
  de.environment_id, dsv.schema_date
  FROM dm_environment de,
   dm_schema_version dsv
  PLAN (de
   WHERE de.environment_id=environment_id)
   JOIN (dsv
   WHERE dsv.schema_version=de.schema_version)
  DETAIL
   schema_date = dsv.schema_date, valid_schema_date_ind = 1
  WITH nocounter
 ;end select
 IF (valid_env_ind=0)
  SELECT INTO value(filename3)
   *
   FROM dual
   DETAIL
    col 0, "********************************************", row + 1,
    col 0, "*** INVALID ENVIRONMENT ID ENTERED       ***", row + 1,
    col 0, "***        TERMINATING PROGRAM           ***", row + 1,
    col 0, "***        DATE: ", curdate"DD-MMM-YYYY;;D",
    curtime"hh:mm;;m", "       ***", row + 1,
    col 0, "********************************************", row + 1
   WITH format = variable, noheading, formfeed = none,
    maxcol = 512, maxrow = 1
  ;end select
  SET ddl_failed = 1
  GO TO end_program
 ENDIF
 SELECT INTO "nl:"
  f.function_id
  FROM dm_env_functions f
  WHERE f.environment_id=environment_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SELECT INTO value(filename3)
   *
   FROM dual
   DETAIL
    col 0, "********************************************", row + 1,
    col 0, "*** NO PRODUCTS SELECTED FOR ENVIRONMENT ***", row + 1,
    col 0, "***        TERMINATING PROGRAM           ***", row + 1,
    col 0, "***        DATE: ", curdate"DD-MMM-YYYY;;D",
    curtime"hh:mm;;m", "       ***", row + 1,
    col 0, "********************************************", row + 1
   WITH format = variable, noheading, formfeed = none,
    maxcol = 512, maxrow = 1
  ;end select
  SET ddl_failed = 1
  GO TO end_program
 ENDIF
 SET db_block_size = 0.0
 SET db_5block_size = 0.0
 SELECT INTO "nl:"
  v.value
  FROM v$parameter v
  WHERE v.name="db_block_size"
  DETAIL
   db_block_size = cnvtreal(v.value), db_5block_size = (cnvtreal(v.value) * 5.0)
  WITH nocounter
 ;end select
 RECORD table_list(
   1 table_name[*]
     2 tname = c30
 )
 SET tbl_cnt = 0
 SELECT INTO value(filename2)
  d.*
  FROM dual d
  DETAIL
   "set message 0 go", row + 1, "select into ",
   filename3, " d.* from dual d", row + 1,
   "detail", row + 1, "'DM_DDL_GEN Error Log', row+1",
   row + 1, "with  format = variable, noheading, formfeed = NONE, maxcol=512, maxrow=1 go", row + 1,
   "set msg=fillstring(132,' ') go", row + 1, "set msgnum=0 go",
   row + 1, "select into 'nl:' msgnum=error(msg,1) with nocounter go", row + 1
  WITH format = variable, noheading, maxcol = 512,
   maxrow = 1, formfeed = none
 ;end select
 SET oracle_ver = 7
 SELECT INTO "NL:"
  p.*
  FROM product_component_version p
  WHERE cnvtupper(p.product)="ORACLE*"
  DETAIL
   oracle_ver = cnvtint(substring(1,(findstring(".",p.version) - 1),p.version))
  WITH nocounter
 ;end select
 IF (cursys != "AIX")
  SELECT INTO value(filename2)
   def.tablespace_name, def.file_size, def.file_name,
   de.root_dir_name, de.database_name, def.size_sequence,
   def.disk_name, def.tablespace_exist_ind
   FROM dm_environment de,
    dm_env_files def
   PLAN (de
    WHERE de.environment_id=environment_id)
    JOIN (def
    WHERE def.environment_id=de.environment_id
     AND ((def.file_type="DATA") OR (def.file_type="INDEX")) )
   ORDER BY def.tablespace_name, def.file_name
   HEAD def.tablespace_name
    tspace_total_size = 0.0, row + 1,
    ";****************************************************************************",
    row + 1, ";", def.tablespace_name,
    row + 1, ";****************************************************************************", row + 1,
    "select into 'nl:' msgnum=error(msg,1) with nocounter go", row + 1
    IF (def.tablespace_exist_ind=0)
     "rdb CREATE TABLESPACE ", def.tablespace_name, " DATAFILE ",
     row_count = 0
    ENDIF
   DETAIL
    IF (def.tablespace_exist_ind=0)
     IF (row_count > 0)
      ","
     ENDIF
     row_count = (row_count+ 1), row + 1, col 5
    ELSE
     "rdb ALTER TABLESPACE ", def.tablespace_name, " ADD DATAFILE ",
     row + 1, col 5
    ENDIF
    ddl_gen->file_name = build("'",def.disk_name,":[",de.root_dir_name,".DB_",
     de.database_name,"]",def.file_name,".dbs","'"), ddl_gen->file_name, row + 1
    IF (def.file_size > 10000000)
     ddl_gen->file_size = concat(trim(cnvtstring((def.file_size/ (1024 * 1024)))),"M")
    ELSE
     ddl_gen->file_size = cnvtstring(def.file_size)
    ENDIF
    col 5, " SIZE ", ddl_gen->file_size
    IF (def.tablespace_exist_ind=1)
     row + 1, "go", row + 1
    ENDIF
    tspace_total_size = (tspace_total_size+ def.file_size)
   FOOT  def.tablespace_name
    IF (def.tablespace_exist_ind=0)
     tspace_defaults = (ceil((tspace_total_size/ (500 * db_block_size))) * db_block_size),
     tspace_defaults = (tspace_defaults/ 1024), row + 1,
     " DEFAULT STORAGE ( PCTINCREASE 0 INITIAL ", tspace_defaults"########", "K NEXT ",
     tspace_defaults"########", "K)", row + 1
     IF (oracle_ver >= 8)
      "EXTENT MANAGEMENT DICTIONARY", row + 1
     ENDIF
     "go"
    ENDIF
    row + 1, "select into 'nl:' msgnum=error(msg,1) with nocounter go", row + 1,
    "select into ", filename3, " d.* from dual d",
    row + 1, "detail", row + 1,
    "if (msg!=' ')", row + 1, "'Error occurred in create tablespace ",
    def.tablespace_name, "', row+1", row + 1,
    "msg, row+3", row + 1, "endif",
    row + 1, "with  format = variable, noheading, formfeed = NONE, maxcol=512, maxrow=1, append go",
    row + 1
   WITH format = variable, noheading, maxcol = 512,
    maxrow = 1, formfeed = none, append
  ;end select
 ENDIF
 IF (tablespaces_only=0)
  SELECT INTO value(filename2)
   ds.sequence_name, ds.min_value, ds.max_value,
   ds.increment_by, ds.cycle
   FROM dm_sequences ds
   ORDER BY ds.sequence_name
   DETAIL
    row + 1, ";****************************************************************************", row + 1,
    ";", ds.sequence_name, row + 1,
    ";****************************************************************************", row + 1,
    "rdb CREATE SEQUENCE ",
    ds.sequence_name, row + 1, " INCREMENT BY ",
    ds.increment_by, " START WITH ", min_value = cnvtstring(ds.min_value),
    min_value
    IF (ds.cycle="Y")
     max_value = cnvtstring(ds.max_value), "MAXVALUE ", max_value,
     " CYCLE"
    ENDIF
    row + 1, "go", ";",
    row + 1
   WITH format = variable, noheading, append,
    maxrow = 1, formfeed = none
  ;end select
  SELECT INTO "nl:"
   dt.table_name
   FROM dm_tables dt
   WHERE dt.schema_date=cnvtdatetime(schema_date)
    AND dt.table_name IN (
   (SELECT
    td.table_name
    FROM dm_tables_doc td,
     dm_function_dm_section_r f,
     dm_env_functions ef,
     dm_environment e
    WHERE e.environment_id=environment_id
     AND ef.environment_id=e.environment_id
     AND f.function_id=ef.function_id
     AND td.data_model_section=f.data_model_section))
   DETAIL
    tbl_cnt = (tbl_cnt+ 1), stat = alterlist(table_list->table_name,tbl_cnt), table_list->table_name[
    tbl_cnt].tname = dt.table_name
   WITH nocounter
  ;end select
  SET default_data = fillstring(40," ")
  SELECT INTO value(filename2)
   dc.column_name, dc.data_type, dc.data_length,
   dc.nullable, dc.column_seq, dt.tablespace_name,
   dt.table_name, det.initial_extent, det.next_extent,
   dt.pct_increase, dt.pct_used, dt.pct_free,
   default_data = substring(1,40,dc.data_default), default_data_null_ind = nullind(dc.data_default)
   FROM dm_env_table det,
    dm_tables dt,
    dm_columns dc,
    (dummyt d  WITH seq = value(tbl_cnt))
   PLAN (d)
    JOIN (dt
    WHERE (dt.table_name=table_list->table_name[d.seq].tname)
     AND dt.schema_date=cnvtdatetime(schema_date))
    JOIN (dc
    WHERE dc.table_name=dt.table_name
     AND dc.schema_date=dt.schema_date)
    JOIN (det
    WHERE det.table_name=dt.table_name
     AND det.environment_id=environment_id)
   ORDER BY dc.table_name, dc.column_seq
   HEAD REPORT
    init = fillstring(12," "), next = fillstring(12," ")
   HEAD dt.table_name
    row + 1, ";****************************************************************************", row + 1,
    ";", dt.table_name, row + 1,
    ";****************************************************************************", row + 1,
    "select into 'nl:' msgnum=error(msg,1) with nocounter go",
    row + 1, row + 1, "rdb CREATE TABLE ",
    dt.table_name, row + 1, "("
   DETAIL
    IF (dc.column_seq > 1)
     ","
    ENDIF
    row + 1, col 2, dc.column_name,
    " ", dc.data_type
    IF (((dc.data_type="VARCHAR2") OR (((dc.data_type="CHAR") OR (dc.data_type="VARCHAR")) )) )
     "(", dc.data_length, ")"
    ENDIF
    IF (default_data_null_ind=0)
     " DEFAULT ", default_data
    ENDIF
    IF (dc.nullable="N")
     " NOT NULL "
    ENDIF
   FOOT  dt.table_name
    row + 1, ")", row + 1,
    "TABLESPACE ", dt.tablespace_name, row + 1,
    " PCTFREE ", dt.pct_free, " PCTUSED ",
    dt.pct_used, col 10, row + 1,
    " STORAGE ( PCTINCREASE 0 "
    IF (det.initial_extent > 0)
     IF ((det.initial_extent > (2000000 * 1024)))
      init = "2000000K"
     ELSEIF ((det.initial_extent > (1024 * 1024)))
      init = build(cnvtstring(round((det.initial_extent/ 1024),0)),"K")
     ELSE
      init = cnvtstring(round(det.initial_extent,0))
     ENDIF
     " INITIAL ", init
     IF ((det.next_extent > (2000000 * 1024)))
      next = "2000000K"
     ELSEIF ((det.next_extent > (1024 * 1024)))
      next = build(cnvtstring(round((det.next_extent/ 1024),0)),"K")
     ELSE
      next = cnvtstring(round(det.next_extent,0))
     ENDIF
     " NEXT ", next
    ENDIF
    ")", row + 1, "go",
    row + 2, "select into 'nl:' msgnum=error(msg,1) with nocounter go", row + 1,
    "select into ", filename3, " d.* from dual d",
    row + 1, "detail", row + 1,
    "if (msg!=' ')", row + 1, "'Error occurred in create table ",
    dt.table_name, "', row+1", row + 1,
    "msg, row+3", row + 1, "endif",
    row + 1, "with  format = variable, noheading, formfeed = NONE, maxcol=512, maxrow=1, append go",
    row + 2,
    "execute oragen3 '", dt.table_name, "' GO",
    row + 2
   WITH format = variable, noheading, append,
    maxrow = 1, formfeed = none, maxcol = 512
  ;end select
  SELECT INTO value(filename2)
   di.index_name, di.table_name, di.tablespace_name,
   di.pct_increase, di.pct_free, di.unique_ind,
   dic.column_name, dic.column_position, dei.initial_extent,
   dei.next_extent
   FROM dm_env_index dei,
    dm_indexes di,
    dm_index_columns dic,
    (dummyt d  WITH seq = value(tbl_cnt))
   PLAN (d)
    JOIN (di
    WHERE (di.table_name=table_list->table_name[d.seq].tname)
     AND di.schema_date=cnvtdatetime(schema_date))
    JOIN (dic
    WHERE dic.index_name=di.index_name
     AND dic.schema_date=di.schema_date)
    JOIN (dei
    WHERE dei.index_name=dic.index_name
     AND dei.environment_id=environment_id)
   ORDER BY di.table_name, di.index_name, dic.column_position
   HEAD REPORT
    init = fillstring(12," "), next = fillstring(12," ")
   HEAD di.index_name
    row + 1, ";****************************************************************************", row + 1,
    ";", di.table_name, ".",
    di.index_name, row + 1,
    ";****************************************************************************",
    row + 1, "select into 'nl:' msgnum=error(msg,1) with nocounter go", row + 1,
    "RDB CREATE "
    IF (di.unique_ind=1)
     "UNIQUE "
    ENDIF
    "INDEX ", di.index_name, row + 1,
    "  ON ", di.table_name, row + 1,
    "  ("
   DETAIL
    IF (dic.column_position > 1)
     ","
    ENDIF
    row + 1, col 5, dic.column_name
   FOOT  di.index_name
    row + 1, "  )", row + 1,
    col 20, " TABLESPACE ", di.tablespace_name,
    row + 1, " PCTFREE ", di.pct_free,
    col 10, row + 1, " STORAGE ( PCTINCREASE 0 "
    IF (dei.initial_extent > 0)
     IF ((dei.initial_extent > (2000000 * 1024)))
      init = "2000000K"
     ELSEIF ((dei.initial_extent > (1024 * 1024)))
      init = build(cnvtstring(round((dei.initial_extent/ 1024),0)),"K")
     ELSE
      init = cnvtstring(round(dei.initial_extent,0))
     ENDIF
     " INITIAL ", init
     IF ((dei.next_extent > (2000000 * 1024)))
      next = "2000000K"
     ELSEIF ((dei.next_extent > (1024 * 1024)))
      next = build(cnvtstring(round((dei.next_extent/ 1024),0)),"K")
     ELSE
      next = cnvtstring(round(dei.next_extent,0))
     ENDIF
     " NEXT ", next
    ENDIF
    ")", row + 1, "go",
    row + 2, "select into 'nl:' msgnum=error(msg,1) with nocounter go", row + 1,
    "select into ", filename3, " d.* from dual d",
    row + 1, "detail", row + 1,
    "if (msg!=' ')", row + 1, "'Error occurred in create index ",
    di.index_name, "', row+1", row + 1,
    "msg, row+3", row + 1, "endif",
    row + 1, "with  format = variable, noheading, formfeed = NONE, maxcol=512, maxrow=1, append go",
    row + 1,
    row + 2
   WITH format = variable, noheading, append,
    maxrow = 1, formfeed = none
  ;end select
  SELECT INTO value(filename2)
   dc.table_name, dc.constraint_name, dcc.column_name,
   dcc.position, dc.status_ind
   FROM dm_constraints dc,
    dm_cons_columns dcc,
    (dummyt d  WITH seq = value(tbl_cnt))
   PLAN (d)
    JOIN (dc
    WHERE (dc.table_name=table_list->table_name[d.seq].tname)
     AND dc.schema_date=cnvtdatetime(schema_date)
     AND dc.constraint_type="P")
    JOIN (dcc
    WHERE dcc.constraint_name=dc.constraint_name
     AND dcc.table_name=dc.table_name
     AND dcc.schema_date=dc.schema_date)
   ORDER BY dc.table_name, dc.constraint_name, dcc.position
   HEAD dc.constraint_name
    row + 1, ";****************************************************************************", row + 1,
    ";", dc.table_name, ".",
    dc.constraint_name, row + 1,
    ";****************************************************************************",
    row + 1, "select into 'nl:' msgnum=error(msg,1) with nocounter go", row + 1,
    "RDB ALTER TABLE ", dc.table_name, row + 1,
    "  ADD CONSTRAINT ", dc.constraint_name, row + 1,
    "  PRIMARY KEY", row + 1, "  ("
   DETAIL
    IF (dcc.position > 1)
     ","
    ENDIF
    row + 1, col 5, dcc.column_name
   FOOT  dc.constraint_name
    row + 1, "  )"
    IF (dc.status_ind=0)
     " DISABLE"
    ENDIF
    row + 1, "go", row + 2,
    "select into 'nl:' msgnum=error(msg,1) with nocounter go", row + 1, "select into ",
    filename3, " d.* from dual d", row + 1,
    "detail", row + 1, "if (msg!=' ')",
    row + 1, "'Error occurred in create constraint ", dc.constraint_name,
    "', row+1", row + 1, "msg, row+3",
    row + 1, "endif", row + 1,
    "with  format = variable, noheading, formfeed = NONE, maxcol=512, maxrow=1, append go", row + 2
   WITH format = variable, noheading, append,
    maxrow = 1, formfeed = none
  ;end select
  SELECT INTO value(filename2)
   dc.table_name, dc.constraint_name, dcc.column_name,
   dcc.position, dc.status_ind
   FROM dm_constraints dc,
    dm_cons_columns dcc,
    (dummyt d  WITH seq = value(tbl_cnt))
   PLAN (d)
    JOIN (dc
    WHERE (dc.table_name=table_list->table_name[d.seq].tname)
     AND dc.schema_date=cnvtdatetime(schema_date)
     AND dc.constraint_type="U")
    JOIN (dcc
    WHERE dcc.constraint_name=dc.constraint_name
     AND dcc.table_name=dc.table_name
     AND dcc.schema_date=dc.schema_date)
   ORDER BY dc.table_name, dc.constraint_name, dcc.position
   HEAD dc.constraint_name
    row + 1, ";****************************************************************************", row + 1,
    ";", dc.table_name, ".",
    dc.constraint_name, row + 1,
    ";****************************************************************************",
    row + 1, "select into 'nl:' msgnum=error(msg,1) with nocounter go", row + 1,
    "RDB ALTER TABLE ", dc.table_name, row + 1,
    "  ADD CONSTRAINT ", dc.constraint_name, row + 1,
    "  UNIQUE ", row + 1, "  ("
   DETAIL
    IF (dcc.position > 1)
     ","
    ENDIF
    row + 1, col 5, dcc.column_name
   FOOT  dc.constraint_name
    row + 1, "  )"
    IF (dc.status_ind=0)
     " DISABLE"
    ENDIF
    row + 1, "go", row + 2,
    "select into 'nl:' msgnum=error(msg,1) with nocounter go", row + 1, "select into ",
    filename3, " d.* from dual d", row + 1,
    "detail", row + 1, "if (msg!=' ')",
    row + 1, "'Error occurred in create unique constraint ", dc.constraint_name,
    "', row+1", row + 1, "msg, row+3",
    row + 1, "endif", row + 1,
    "with  format = variable, noheading, formfeed = NONE, maxcol=512, maxrow=1, append go", row + 2
   WITH format = variable, noheading, append,
    maxrow = 1, formfeed = none
  ;end select
  FREE RECORD txt
  RECORD txt(
    1 txt = vc
    1 col_name = vc
  )
  SELECT INTO value(filename2)
   dc.table_name, dc.constraint_name, dc.parent_table_name,
   dc.parent_table_columns, dcc.column_name, dcc.position,
   dc.status_ind
   FROM dm_constraints dc,
    dm_cons_columns dcc,
    (dummyt d  WITH seq = value(tbl_cnt))
   PLAN (d)
    JOIN (dc
    WHERE (dc.table_name=table_list->table_name[d.seq].tname)
     AND dc.schema_date=cnvtdatetime(schema_date)
     AND dc.constraint_type="R")
    JOIN (dcc
    WHERE dcc.constraint_name=dc.constraint_name
     AND dcc.table_name=dc.table_name
     AND dcc.schema_date=dc.schema_date)
   ORDER BY dc.table_name, dc.constraint_name, dcc.position
   HEAD dc.constraint_name
    row + 1, ";****************************************************************************", row + 1,
    ";", dc.table_name, ".",
    dc.constraint_name, row + 1,
    ";****************************************************************************",
    row + 1, "select into 'nl:' msgnum=error(msg,1) with nocounter go", row + 1,
    "RDB ALTER TABLE ", dc.table_name, row + 1,
    "  ADD CONSTRAINT ", dc.constraint_name, row + 1,
    "  FOREIGN KEY", row + 1, "  ("
   DETAIL
    IF (dcc.position > 1)
     ","
    ENDIF
    row + 1, col 5, dcc.column_name
   FOOT  dc.constraint_name
    row + 1, "  )", row + 1,
    "  REFERENCES ", dc.parent_table_name, row + 1,
    len = size(trim(dc.parent_table_columns,3)), cons_i = 1, found = findstring(",",dc
     .parent_table_columns,cons_i)
    IF (found > 0)
     WHILE (found > 0)
       txt->col_name = substring(cons_i,(found - cons_i),dc.parent_table_columns)
       IF (cons_i=1)
        txt->txt = concat("(",txt->col_name)
       ELSE
        txt->txt = concat(",",txt->col_name)
       ENDIF
       "    ", txt->txt, row + 1,
       cons_i = (found+ 1), found = findstring(",",dc.parent_table_columns,cons_i)
     ENDWHILE
     txt->col_name = substring(cons_i,len,dc.parent_table_columns), txt->txt = concat(",",txt->
      col_name,")"), "    ",
     txt->txt, row + 1
    ELSE
     txt->txt = concat("(",trim(dc.parent_table_columns,3),")"), "    ", txt->txt,
     row + 1
    ENDIF
    IF (dc.status_ind=0)
     " DISABLE"
    ENDIF
    row + 1, "go", row + 2,
    "select into 'nl:' msgnum=error(msg,1) with nocounter go", row + 1, "select into ",
    filename3, " d.* from dual d", row + 1,
    "detail", row + 1, "if (msg!=' ')",
    row + 1, "'Error occurred in create fk constraint ", dc.constraint_name,
    "', row+1", row + 1, "msg, row+3",
    row + 1, "endif", row + 1,
    "with  format = variable, noheading, formfeed = NONE, maxcol=512, maxrow=1, append go", row + 1,
    row + 2
   WITH format = variable, noheading, append,
    maxrow = 1, formfeed = none, maxcol = 512
  ;end select
 ENDIF
#end_program
 IF (ddl_failed=1)
  SELECT
   *
   FROM dual
   DETAIL
    col 0, "*******************************************", row + 1,
    col 0, "***    DM_DDL_GEN ENCOUNTERED ERRORS    ***", row + 1,
    col 0, "***  SEE CCLUSERDIR:", filename3,
    ".DAT ***", row + 1, col 0,
    "***        TERMINATING PROGRAM          ***", row + 1, col 0,
    "*******************************************", row + 1
   WITH nocounter
  ;end select
 ENDIF
END GO
