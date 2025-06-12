CREATE PROGRAM dm_refresh_purge_indexes:dba
 FREE RECORD drpi_tableinfo
 RECORD drpi_tableinfo(
   1 tablename = vc
   1 indexname = vc
   1 hasvalidindexind = i2
   1 lastddltime = dq8
   1 admintableind = i2
   1 columns[*]
     2 columnname = vc
     2 datatype = vc
     2 precedence = i2
 )
 FREE RECORD drpi_curcolumns
 RECORD drpi_curcolumns(
   1 list_0[*]
     2 columnname = vc
     2 datatype = vc
     2 precedence = i2
 )
 DECLARE drpi_hasadminlinkind = i2 WITH protect, noconstant(0)
 DECLARE drpi_isadmintableind = i2 WITH protect, noconstant(0)
 DECLARE drpi_islocaltableind = i2 WITH protect, noconstant(0)
 DECLARE drpi_betterindexind = i2 WITH protect, noconstant(0)
 DECLARE drpi_adminlinkname = vc WITH protect, noconstant("")
 DECLARE drpi_periodpos = i4 WITH protect, noconstant(0)
 DECLARE drpi_columncnt = i4 WITH protect, noconstant(0)
 DECLARE drpi_curcolumncnt = i4 WITH protect, noconstant(0)
 DECLARE drpi_loop = i4 WITH protect, noconstant(0)
 DECLARE drpi_insert_indexes(null) = null
 SET drpi_tableinfo->tablename = trim(cnvtupper( $1),3)
 DELETE  FROM dm_purge_table_index dpti
  WHERE (dpti.table_name=drpi_tableinfo->tablename)
  WITH nocounter
 ;end delete
 COMMIT
 SELECT INTO "nl:"
  FROM user_tables ut
  WHERE (ut.table_name=drpi_tableinfo->tablename)
  DETAIL
   drpi_islocaltableind = 1
  WITH nocounter
 ;end select
 IF (drpi_islocaltableind=0)
  SELECT DISTINCT INTO "nl:"
   ds.db_link
   FROM dba_synonyms ds
   WHERE ds.synonym_name="DM_ENVIRONMENT"
   DETAIL
    drpi_periodpos = findstring(".WORLD",ds.db_link), drpi_adminlinkname = cnvtupper(substring(1,(
      drpi_periodpos - 1),ds.db_link)), drpi_hasadminlinkind = 1
   WITH nocounter
  ;end select
  IF (drpi_hasadminlinkind=1)
   SELECT INTO "nl:"
    FROM (value(concat("USER_TABLES@",drpi_adminlinkname)) ut)
    WHERE (ut.table_name=drpi_tableinfo->tablename)
    DETAIL
     drpi_isadmintableind = 1
    WITH nocounter
   ;end select
   IF (drpi_isadmintableind=0)
    GO TO exit_script
   ENDIF
   SET drpi_tableinfo->admintableind = 1
  ELSE
   GO TO exit_script
  ENDIF
  CALL echo("Looking for primary key indexes for admin table...")
  SELECT INTO "nl:"
   uc.index_name
   FROM (value(concat("USER_CONSTRAINTS@",drpi_adminlinkname)) uc),
    (value(concat("USER_OBJECTS@",drpi_adminlinkname)) uo),
    (value(concat("USER_IND_COLUMNS@",drpi_adminlinkname)) uic),
    (value(concat("USER_TAB_COLUMNS@",drpi_adminlinkname)) utc)
   PLAN (uc
    WHERE (uc.table_name=drpi_tableinfo->tablename)
     AND uc.constraint_type="P")
    JOIN (uo
    WHERE uo.object_name=uc.table_name
     AND uo.object_type="TABLE")
    JOIN (uic
    WHERE uic.index_name=uc.index_name)
    JOIN (utc
    WHERE utc.column_name=uic.column_name
     AND (utc.table_name=drpi_tableinfo->tablename))
   ORDER BY uc.index_name
   HEAD uc.index_name
    drpi_tableinfo->indexname = uc.index_name, drpi_tableinfo->hasvalidindexind = 1, drpi_tableinfo->
    lastddltime = uo.last_ddl_time,
    drpi_columncnt = 0
   DETAIL
    drpi_columncnt = (drpi_columncnt+ 1), stat = alterlist(drpi_tableinfo->columns,drpi_columncnt),
    drpi_tableinfo->columns[drpi_columncnt].columnname = utc.column_name
    IF (utc.data_type IN ("VARCHAR2", "CHAR"))
     drpi_tableinfo->columns[drpi_columncnt].datatype = build(drpi_tableinfo->columns[drpi_columncnt]
      .datatype,"(",cnvtstring(utc.data_length),")")
    ELSE
     drpi_tableinfo->columns[drpi_columncnt].datatype = evaluate(utc.data_type,"FLOAT","NUMBER",utc
      .data_type)
    ENDIF
    drpi_tableinfo->columns[drpi_columncnt].precedence = cnvtint(uic.column_position)
   WITH nocounter
  ;end select
  IF ((drpi_tableinfo->hasvalidindexind=1))
   CALL drpi_insert_indexes(null)
   GO TO exit_script
  ENDIF
  CALL echo("Looking for non-primary key unique indexes for admin table...")
  SELECT INTO "nl:"
   ui.index_name, uo.last_ddl_time, utc.column_name,
   utc.data_type, utc.data_length, uic.column_position
   FROM (value(concat("USER_INDEXES@",drpi_adminlinkname)) ui),
    (value(concat("USER_IND_COLUMNS@",drpi_adminlinkname)) uic),
    (value(concat("USER_OBJECTS@",drpi_adminlinkname)) uo),
    (value(concat("USER_TAB_COLUMNS@",drpi_adminlinkname)) utc)
   PLAN (ui
    WHERE (ui.table_name=drpi_tableinfo->tablename)
     AND ui.uniqueness="UNIQUE")
    JOIN (uic
    WHERE uic.index_name=ui.index_name)
    JOIN (uo
    WHERE uo.object_name=ui.table_name
     AND uo.object_type="TABLE")
    JOIN (utc
    WHERE (utc.table_name=drpi_tableinfo->tablename)
     AND utc.column_name=uic.column_name)
   ORDER BY ui.index_name, uic.column_position
   HEAD REPORT
    drpi_tableinfo->hasvalidindexind = 1, drpi_curcolumncnt = 0
   HEAD ui.index_name
    drpi_curcolumncnt = 0, drpi_betterindexind = 0
   DETAIL
    drpi_curcolumncnt = (drpi_curcolumncnt+ 1), stat = alterlist(drpi_curcolumns->list_0,
     drpi_curcolumncnt), drpi_curcolumns->list_0[drpi_curcolumncnt].columnname = utc.column_name
    IF (utc.data_type IN ("VARCHAR2", "CHAR"))
     drpi_curcolumns->list_0[drpi_curcolumncnt].datatype = build(utc.data_type,"(",cnvtstring(utc
       .data_length),")")
    ELSE
     drpi_curcolumns->list_0[drpi_curcolumncnt].datatype = evaluate(utc.data_type,"FLOAT","NUMBER",
      utc.data_type)
    ENDIF
    drpi_curcolumns->list_0[drpi_curcolumncnt].precedence = cnvtint(uic.column_position)
   FOOT  ui.index_name
    IF (size(drpi_tableinfo->columns,5)=0)
     drpi_betterindexind = 1
    ELSEIF (drpi_curcolumncnt < size(drpi_tableinfo->columns,5))
     drpi_betterindexind = 1
    ENDIF
    IF (drpi_betterindexind=1)
     drpi_tableinfo->indexname = ui.index_name, drpi_tableinfo->lastddltime = uo.last_ddl_time,
     drpi_columncnt = drpi_curcolumncnt,
     stat = alterlist(drpi_tableinfo->columns,drpi_curcolumncnt)
     FOR (drpi_loop = 1 TO drpi_curcolumncnt)
       drpi_tableinfo->columns[drpi_loop].columnname = drpi_curcolumns->list_0[drpi_loop].columnname,
       drpi_tableinfo->columns[drpi_loop].datatype = drpi_curcolumns->list_0[drpi_loop].datatype,
       drpi_tableinfo->columns[drpi_loop].precedence = drpi_curcolumns->list_0[drpi_loop].precedence
     ENDFOR
    ENDIF
   WITH nocounter
  ;end select
  IF ((drpi_tableinfo->hasvalidindexind=1))
   CALL drpi_insert_indexes(null)
  ENDIF
  GO TO exit_script
 ELSE
  CALL echo("Looking for primary key indexes...")
  SELECT INTO "nl:"
   uc.index_name
   FROM user_constraints uc,
    user_objects uo,
    user_ind_columns uic,
    user_tab_columns utc
   PLAN (uc
    WHERE (uc.table_name=drpi_tableinfo->tablename)
     AND uc.constraint_type="P")
    JOIN (uo
    WHERE uo.object_name=uc.table_name
     AND uo.object_type="TABLE")
    JOIN (uic
    WHERE uic.index_name=uc.index_name)
    JOIN (utc
    WHERE utc.column_name=uic.column_name
     AND (utc.table_name=drpi_tableinfo->tablename))
   ORDER BY uc.index_name
   HEAD uc.index_name
    drpi_tableinfo->indexname = uc.index_name, drpi_tableinfo->hasvalidindexind = 1, drpi_tableinfo->
    lastddltime = uo.last_ddl_time,
    drpi_columncnt = 0
   DETAIL
    drpi_columncnt = (drpi_columncnt+ 1), stat = alterlist(drpi_tableinfo->columns,drpi_columncnt),
    drpi_tableinfo->columns[drpi_columncnt].columnname = utc.column_name,
    drpi_tableinfo->columns[drpi_columncnt].datatype = evaluate(utc.data_type,"FLOAT","NUMBER",utc
     .data_type)
    IF (utc.data_type IN ("VARCHAR2", "CHAR"))
     drpi_tableinfo->columns[drpi_columncnt].datatype = build(drpi_tableinfo->columns[drpi_columncnt]
      .datatype,"(",cnvtstring(utc.data_length),")")
    ENDIF
    drpi_tableinfo->columns[drpi_columncnt].precedence = cnvtint(uic.column_position)
   WITH nocounter
  ;end select
  IF ((drpi_tableinfo->hasvalidindexind=1))
   CALL drpi_insert_indexes(null)
   GO TO exit_script
  ENDIF
  CALL echo("Looking for non-primary key unique indexes...")
  SELECT INTO "nl:"
   ui.index_name, uo.last_ddl_time, utc.column_name,
   utc.data_type, utc.data_length, uic.column_position
   FROM user_indexes ui,
    user_ind_columns uic,
    user_objects uo,
    user_tab_columns utc
   PLAN (ui
    WHERE (ui.table_name=drpi_tableinfo->tablename)
     AND ui.uniqueness="UNIQUE")
    JOIN (uic
    WHERE uic.index_name=ui.index_name)
    JOIN (uo
    WHERE uo.object_name=ui.table_name
     AND uo.object_type="TABLE")
    JOIN (utc
    WHERE (utc.table_name=drpi_tableinfo->tablename)
     AND utc.column_name=uic.column_name)
   ORDER BY ui.index_name, uic.column_position
   HEAD REPORT
    drpi_tableinfo->hasvalidindexind = 1, drpi_curcolumncnt = 0
   HEAD ui.index_name
    drpi_curcolumncnt = 0, drpi_betterindexind = 0
   DETAIL
    drpi_curcolumncnt = (drpi_curcolumncnt+ 1), stat = alterlist(drpi_curcolumns->list_0,
     drpi_curcolumncnt), drpi_curcolumns->list_0[drpi_curcolumncnt].columnname = utc.column_name
    IF (utc.data_type IN ("VARCHAR2", "CHAR"))
     drpi_curcolumns->list_0[drpi_curcolumncnt].datatype = build(utc.data_type,"(",cnvtstring(utc
       .data_length),")")
    ELSE
     drpi_curcolumns->list_0[drpi_curcolumncnt].datatype = evaluate(utc.data_type,"FLOAT","NUMBER",
      utc.data_type)
    ENDIF
    drpi_curcolumns->list_0[drpi_curcolumncnt].precedence = cnvtint(uic.column_position)
   FOOT  ui.index_name
    IF (size(drpi_tableinfo->columns,5)=0)
     drpi_betterindexind = 1
    ELSEIF (drpi_curcolumncnt < size(drpi_tableinfo->columns,5))
     drpi_betterindexind = 1
    ENDIF
    IF (drpi_betterindexind=1)
     drpi_tableinfo->indexname = ui.index_name, drpi_tableinfo->lastddltime = uo.last_ddl_time,
     drpi_columncnt = drpi_curcolumncnt,
     stat = alterlist(drpi_tableinfo->columns,drpi_curcolumncnt)
     FOR (drpi_loop = 1 TO drpi_curcolumncnt)
       drpi_tableinfo->columns[drpi_loop].columnname = drpi_curcolumns->list_0[drpi_loop].columnname,
       drpi_tableinfo->columns[drpi_loop].datatype = drpi_curcolumns->list_0[drpi_loop].datatype,
       drpi_tableinfo->columns[drpi_loop].precedence = drpi_curcolumns->list_0[drpi_loop].precedence
     ENDFOR
    ENDIF
   WITH nocounter
  ;end select
  IF ((drpi_tableinfo->hasvalidindexind=1))
   CALL drpi_insert_indexes(null)
  ENDIF
  GO TO exit_script
 ENDIF
 SUBROUTINE drpi_insert_indexes(null)
   DECLARE drpiii_columncnt = i4 WITH protect, noconstant(0)
   SET drpiii_columncnt = size(drpi_tableinfo->columns,5)
   INSERT  FROM dm_purge_table_index dpti,
     (dummyt d  WITH seq = value(drpiii_columncnt))
    SET dpti.table_index_id = seq(dm_clinical_seq,nextval), dpti.table_name = drpi_tableinfo->
     tablename, dpti.last_ddl_dt_tm = cnvtdatetime(drpi_tableinfo->lastddltime),
     dpti.index_name = drpi_tableinfo->indexname, dpti.column_name = drpi_tableinfo->columns[d.seq].
     columnname, dpti.data_type = drpi_tableinfo->columns[d.seq].datatype,
     dpti.precedence_nbr = drpi_tableinfo->columns[d.seq].precedence, dpti.admin_table_ind =
     drpi_tableinfo->admintableind, dpti.updt_cnt = 0,
     dpti.updt_dt_tm = cnvtdatetime(curdate,curtime3), dpti.updt_task = reqinfo->updt_task, dpti
     .updt_applctx = reqinfo->updt_applctx,
     dpti.updt_id = reqinfo->updt_id
    PLAN (d)
     JOIN (dpti)
    WITH nocounter
   ;end insert
   COMMIT
 END ;Subroutine
#exit_script
 IF (validate(b_ind_columns->validationfield,"Z") != "Z")
  SET stat = alterlist(b_ind_columns->columns,drpi_columncnt)
  FOR (drpi_loop = 1 TO drpi_columncnt)
   SET b_ind_columns->columns[drpi_loop].columnname = drpi_tableinfo->columns[drpi_loop].columnname
   SET b_ind_columns->columns[drpi_loop].datatype = drpi_tableinfo->columns[drpi_loop].datatype
  ENDFOR
 ENDIF
 FREE RECORD drpi_tableinfo
 FREE RECORD drpi_curcolumns
END GO
