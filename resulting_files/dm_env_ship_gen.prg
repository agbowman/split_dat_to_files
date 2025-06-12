CREATE PROGRAM dm_env_ship_gen
 SET tempstr = fillstring(40," ")
 SELECT INTO "dm_env_ship_create.ccl"
  uic.column_name, uic.data_type, uic.data_length,
  uic.nullable, uic.column_id, uc.tablespace_name,
  uc.table_name, default_value = substring(1,40,uic.data_default)
  FROM user_tab_columns uic,
   user_tables uc
  WHERE uc.table_name IN ("DM_ENVIRONMENT", "DM_ENV_CONTROL_FILES", "DM_ENV_FILES", "DM_ENV_INDEX",
  "DM_ENV_REDO_LOGS",
  "DM_ENV_ROLLBACK_SEGMENTS", "DM_ENV_TABLE", "DM_ENV_FUNCTIONS")
   AND uc.table_name=uic.table_name
   AND uic.column_name != "ENVIRONMENT_NAME"
  ORDER BY uc.table_name, uic.column_id
  HEAD uc.table_name
   "rdb DROP TABLE "
   IF (uc.table_name="DM_ENV_CONTROL_FILES")
    tempstr = "DM_ENV_CON_FILES_SHIP"
   ELSEIF (uc.table_name="DM_ENV_ROLLBACK_SEGMENTS")
    tempstr = "DM_ENV_ROLL_SEGS_SHIP"
   ELSE
    tempstr = build(uc.table_name,"_SHIP")
   ENDIF
   tempstr, " CASCADE CONSTRAINTS", row + 1,
   "GO", row + 1, row + 1,
   "rdb CREATE TABLE "
   IF (uc.table_name="DM_ENV_CONTROL_FILES")
    tempstr = "DM_ENV_CON_FILES_SHIP"
   ELSEIF (uc.table_name="DM_ENV_ROLLBACK_SEGMENTS")
    tempstr = "DM_ENV_ROLL_SEGS_SHIP"
   ELSE
    tempstr = build(uc.table_name,"_SHIP")
   ENDIF
   tempstr, row + 1, col 10,
   "("
  DETAIL
   IF (uic.column_id > 1)
    ","
   ENDIF
   row + 1, col 10
   IF (uic.column_name="ENVIRONMENT_ID")
    "ENVIRONMENT_NAME VARCHAR2(20) NOT NULL"
   ELSE
    uic.column_name, col 50, uic.data_type
    IF (((uic.data_type="VARCHAR2") OR (((uic.data_type="CHAR") OR (uic.data_type="VARCHAR")) )) )
     col 60, "(", col 61,
     uic.data_length"####;;I", col 66, ")"
    ENDIF
    IF (default_value != " ")
     " DEFAULT ", tempstr = build(default_value), tempstr
    ENDIF
    IF (uic.nullable="N")
     " NOT NULL"
    ENDIF
   ENDIF
  FOOT  uc.table_name
   row + 1, col 10, ")",
   row + 1, col 10, "TABLESPACE ",
   uc.tablespace_name, row + 1, "go",
   row + 1, "execute oragen3 '"
   IF (uc.table_name="DM_ENV_CONTROL_FILES")
    tempstr = "DM_ENV_CON_FILES_SHIP"
   ELSEIF (uc.table_name="DM_ENV_ROLLBACK_SEGMENTS")
    tempstr = "DM_ENV_ROLL_SEGS_SHIP"
   ELSE
    tempstr = build(uc.table_name,"_SHIP")
   ENDIF
   tempstr, "' GO", row + 1
  WITH format = stream, noheading, formfeed = none,
   maxcol = 512, maxrow = 1
 ;end select
 SELECT INTO "dm_env_ship_create.ccl"
  uc.constraint_name, uc.table_name, ucc.column_name,
  ucc.position, ui.tablespace_name, uc.status
  FROM user_indexes ui,
   user_cons_columns ucc,
   user_constraints uc
  WHERE uc.owner=ucc.owner
   AND uc.constraint_name=ui.index_name
   AND ucc.constraint_name=uc.constraint_name
   AND ucc.table_name=uc.table_name
   AND uc.table_name IN ("DM_ENVIRONMENT", "DM_ENV_CONTROL_FILES", "DM_ENV_FILES", "DM_ENV_INDEX",
  "DM_ENV_REDO_LOGS",
  "DM_ENV_ROLLBACK_SEGMENTS", "DM_ENV_TABLE", "DM_ENV_FUNCTIONS")
   AND uc.constraint_type="P"
  ORDER BY uc.table_name, uc.constraint_name, ucc.position
  HEAD uc.constraint_name
   "RDB ALTER TABLE ", col 20
   IF (uc.table_name="DM_ENV_CONTROL_FILES")
    tempstr = "DM_ENV_CON_FILES_SHIP"
   ELSEIF (uc.table_name="DM_ENV_ROLLBACK_SEGMENTS")
    tempstr = "DM_ENV_ROLL_SEGS_SHIP"
   ELSE
    tempstr = build(uc.table_name,"_SHIP")
   ENDIF
   tempstr, row + 1, col 20,
   " ADD CONSTRAINT ", tempstr = build(uc.constraint_name,"_SHIP"), tempstr,
   row + 1, col 30, " PRIMARY KEY ("
  DETAIL
   IF (ucc.position > 1)
    ","
   ENDIF
   row + 1
   IF (ucc.column_name="ENVIRONMENT_ID")
    "ENVIRONMENT_NAME"
   ELSE
    ucc.column_name
   ENDIF
  FOOT  uc.table_name
   row + 1, col 10, ")",
   row + 1, col 10, " USING INDEX TABLESPACE ",
   ui.tablespace_name, " "
   IF (uc.status="DISABLED")
    "DISABLE"
   ENDIF
   row + 1, "go", row + 1
  WITH format = stream, noheading, append,
   formfeed = none, maxcol = 512, maxrow = 1
 ;end select
 SELECT INTO "dm_env_ship_create.ccl"
  uic.column_name, uic.column_position, ui.table_name,
  ui.index_name, ui.tablespace_name, ui.uniqueness
  FROM user_ind_columns uic,
   user_indexes ui,
   user_constraints uc,
   (dummyt d  WITH seq = 1)
  PLAN (ui
   WHERE ui.table_name IN ("DM_ENVIRONMENT", "DM_ENV_CONTROL_FILES", "DM_ENV_FILES", "DM_ENV_INDEX",
   "DM_ENV_REDO_LOGS",
   "DM_ENV_ROLLBACK_SEGMENTS", "DM_ENV_TABLE", "DM_ENV_FUNCTIONS"))
   JOIN (uic
   WHERE uic.index_name=ui.index_name
    AND uic.column_name != "ENVIRONMENT_NAME")
   JOIN (d
   WHERE d.seq=1)
   JOIN (uc
   WHERE ui.index_name=uc.constraint_name)
  ORDER BY ui.table_name, ui.index_name, uic.column_position
  HEAD ui.index_name
   row + 1, "RDB CREATE "
   IF (ui.uniqueness="UNIQUE")
    ui.uniqueness
   ENDIF
   " INDEX ", tempstr = build(ui.index_name,"_SHIP"), tempstr,
   row + 1, col 20, "ON "
   IF (ui.table_name="DM_ENV_CONTROL_FILES")
    tempstr = "DM_ENV_CON_FILES_SHIP"
   ELSEIF (ui.table_name="DM_ENV_ROLLBACK_SEGMENTS")
    tempstr = "DM_ENV_ROLL_SEGS_SHIP"
   ELSE
    tempstr = build(ui.table_name,"_SHIP")
   ENDIF
   tempstr, row + 1, col 30,
   "("
  DETAIL
   IF (uic.column_position > 1)
    ","
   ENDIF
   row + 1, col 30
   IF (uic.column_name="ENVIRONMENT_ID")
    "ENVIRONMENT_NAME"
   ELSE
    uic.column_name
   ENDIF
  FOOT  ui.index_name
   row + 1, col 30, ")",
   row + 1, col 20, " TABLESPACE ",
   ui.tablespace_name, row + 1, "go",
   row + 1
  WITH outerjoin = d, dontexist, format = stream,
   noheading, append, formfeed = none,
   maxcol = 512, maxrow = 1
 ;end select
 RECORD col_list(
   1 col_count = i4
   1 col[50]
     2 col_name = vc
 )
 SET col_list->col_count = 0
 SELECT INTO "dm_env_ship_load.prg"
  uic.column_name, uic.data_type, uic.data_length,
  uic.nullable, uic.column_id, uc.tablespace_name,
  uc.table_name, default_value = substring(1,40,uic.data_default)
  FROM user_tab_columns uic,
   user_tables uc
  WHERE uc.table_name IN ("DM_ENVIRONMENT", "DM_ENV_CONTROL_FILES", "DM_ENV_FILES", "DM_ENV_INDEX",
  "DM_ENV_REDO_LOGS",
  "DM_ENV_ROLLBACK_SEGMENTS", "DM_ENV_TABLE", "DM_ENV_FUNCTIONS")
   AND uc.table_name=uic.table_name
   AND uic.column_name != "ENVIRONMENT_NAME"
  ORDER BY uc.table_name, uic.column_id
  HEAD REPORT
   "drop program dm_env_ship_load:dba go", row + 1, "create program dm_env_ship_load:dba",
   row + 3, 'set env_name=fillstring(20," ")', row + 1,
   'select into "nl:"', row + 1, "		dm.environment_name",
   row + 1, "  from dm_environment dm", row + 1,
   " where dm.environment_id = $1", row + 1, "detail",
   row + 1, "	env_name=dm.environment_name", row + 1,
   "with nocounter", row + 3
  HEAD uc.table_name
   col_list->col_count = 0
   IF (uc.table_name="DM_ENV_CONTROL_FILES")
    tempstr = "DM_ENV_CON_FILES_SHIP"
   ELSEIF (uc.table_name="DM_ENV_ROLLBACK_SEGMENTS")
    tempstr = "DM_ENV_ROLL_SEGS_SHIP"
   ELSE
    tempstr = build(uc.table_name,"_SHIP")
   ENDIF
   "delete from ", tempstr, " de",
   row + 1, "where trim(de.environment_name) = trim(env_name)", row + 1,
   "with nocounter", row + 2, "insert into ",
   tempstr, "(", row + 1
  DETAIL
   col_list->col_count = (col_list->col_count+ 1), col_list->col[col_list->col_count].col_name = uic
   .column_name
   IF (uic.column_id > 1)
    ","
   ENDIF
   row + 1, col 10
   IF (uic.column_name="ENVIRONMENT_ID")
    "ENVIRONMENT_NAME"
   ELSE
    uic.column_name
   ENDIF
  FOOT  uc.table_name
   row + 1, col 10, ")",
   row + 1, "(select", row + 1
   FOR (i = 1 TO col_list->col_count)
    IF (i > 1)
     ",", row + 1
    ENDIF
    ,
    IF ((col_list->col[i].col_name="ENVIRONMENT_ID"))
     "env_name"
    ELSE
     "dm.", col_list->col[i].col_name
    ENDIF
   ENDFOR
   row + 1, "from ", uc.table_name,
   " dm", row + 1, "where dm.environment_id = $1)",
   row + 1, "commit", row + 1,
   row + 1
  FOOT REPORT
   "end", row + 1, "go",
   row + 1
  WITH format = stream, noheading, formfeed = none,
   maxcol = 512, maxrow = 1
 ;end select
 SELECT INTO "dm_env_ship_unload.prg"
  uic.column_name, uic.data_type, uic.data_length,
  uic.nullable, uic.column_id, uc.tablespace_name,
  uc.table_name, default_value = substring(1,40,uic.data_default)
  FROM user_tab_columns uic,
   user_tables uc
  WHERE uc.table_name IN ("DM_ENVIRONMENT", "DM_ENV_CONTROL_FILES", "DM_ENV_FILES", "DM_ENV_INDEX",
  "DM_ENV_REDO_LOGS",
  "DM_ENV_ROLLBACK_SEGMENTS", "DM_ENV_TABLE", "DM_ENV_FUNCTIONS")
   AND uc.table_name=uic.table_name
  ORDER BY uc.table_name, uic.column_id
  HEAD REPORT
   "drop program dm_env_ship_unload:dba go", row + 1, "create program dm_env_ship_unload:dba",
   row + 3, 'set env_name=fillstring(20," ")', row + 1,
   "record env_list", row + 1, "(",
   row + 1, "1 env_cnt = i4", row + 1,
   "1 env_list[50]", row + 1, "2 env_name = vc",
   row + 1, "2 env_id = i4", row + 1,
   ")", row + 3, "set env_list->env_cnt=0",
   row + 1, 'select into "nl:"', row + 1,
   "		dm.environment_name", row + 1, "  from dm_environment_ship dm",
   row + 1, "detail", row + 1,
   "    env_list->env_cnt=env_list->env_cnt+1", row + 1,
   "	 env_list->env_list[env_list->env_cnt]->env_name=dm.environment_name",
   row + 1, "with nocounter", row + 3,
   'select into "nl:"', row + 1, "		dm.environment_name, dm.environment_id",
   row + 1, "   from dm_environment dm,       ", row + 1,
   "        (dummyt d with seq = value(env_list->env_cnt))", row + 1, "   plan d",
   row + 1, "   join dm where trim(dm.environment_name) = trim(env_list->env_list[d.seq]->env_name)",
   row + 1,
   "detail", row + 1, "	env_list->env_list[d.seq]->env_id=dm.environment_id",
   row + 1, "with nocounter", row + 3,
   "for (i=1 to env_list->env_cnt)", row + 1, "	if (env_list->env_list[i]->env_id=0)",
   row + 1, '		select into "nl:"', row + 1,
   "			   y=seq(dm_seq,nextval)	", row + 1, "		  from dual",
   row + 1, "		detail", row + 1,
   "			env_list->env_list[i]->env_id=y", row + 1, "		with nocounter",
   row + 1, "	endif", row + 1,
   "endfor", row + 3
  HEAD uc.table_name
   col_list->col_count = 0
  DETAIL
   col_list->col_count = (col_list->col_count+ 1), col_list->col[col_list->col_count].col_name = uic
   .column_name
  FOOT  uc.table_name
   "for (i=1 to env_list->env_cnt)", row + 2, '	call echo(concat("deleting from ',
   uc.table_name, ' env = ", ', "env_list->env_list[i]->env_name))",
   row + 2, "	delete from ", uc.table_name,
   " dm", row + 1, "	 where dm.environment_id = env_list->env_list[i]->env_id",
   row + 1, "	with nocounter", row + 2,
   "	insert into ", uc.table_name, "(",
   row + 1
   FOR (j = 1 TO col_list->col_count)
     IF (j > 1)
      ",", row + 1
     ENDIF
     "			", col_list->col[j].col_name
   ENDFOR
   row + 1, ")", row + 1,
   "	(select ", row + 1
   FOR (j = 1 TO col_list->col_count)
    IF (j > 1)
     ",", row + 1
    ENDIF
    ,
    IF ((col_list->col[j].col_name="ENVIRONMENT_ID"))
     "			env_list->env_list[i]->env_id"
    ELSEIF ((col_list->col[j].col_name="ENVIRONMENT_NAME"))
     "			env_list->env_list[i]->env_name"
    ELSE
     "			dmt.", col_list->col[j].col_name
    ENDIF
   ENDFOR
   row + 1
   IF (uc.table_name="DM_ENV_CONTROL_FILES")
    tempstr = "DM_ENV_CON_FILES_SHIP"
   ELSEIF (uc.table_name="DM_ENV_ROLLBACK_SEGMENTS")
    tempstr = "DM_ENV_ROLL_SEGS_SHIP"
   ELSE
    tempstr = build(uc.table_name,"_SHIP")
   ENDIF
   "		from ", tempstr, " DMT",
   row + 1, "	   where trim(dmt.environment_name) = trim(env_list->env_list[i]->env_name))", row + 2,
   "endfor", row + 3, row + 1,
   row + 1
  FOOT REPORT
   "end", row + 1, "go",
   row + 1
  WITH format = stream, noheading, formfeed = none,
   maxcol = 512, maxrow = 1
 ;end select
END GO
