CREATE PROGRAM dm_ddl_from_table:dba
 SET trace = nocost
 SET message = noinformation
 DECLARE input_param = vc
 DECLARE init_extent = vc
 DECLARE next_extent = vc
 DECLARE pct_free = vc
 DECLARE pct_used = vc
 DECLARE default_value_str = vc
 DECLARE fk_str = vc
 DECLARE found_str = i4
 DECLARE start_pos = i4
 DECLARE table_cnt = i4
 DECLARE valid_table_status = i4
 DECLARE table_pk = vc
 SET table_cnt = 0
 FREE SET tablespace
 RECORD tablespace(
   1 tables[*]
     2 table_name = vc
 )
 SET input_param = cnvtupper(trim( $1))
 SET start_pos = 1
 SET found_str = 1
 WHILE (found_str > 0)
  SET found_str = findstring(",",input_param,start_pos)
  IF (found_str > 0)
   SET table_cnt = (table_cnt+ 1)
   SET stat = alterlist(tablespace->tables,table_cnt)
   SET tablespace->tables[table_cnt].table_name = substring(start_pos,(found_str - start_pos),
    input_param)
   SET start_pos = (found_str+ 1)
  ELSE
   SET table_cnt = (table_cnt+ 1)
   SET stat = alterlist(tablespace->tables,table_cnt)
   SET tablespace->tables[table_cnt].table_name = substring(start_pos,((size(input_param,1) -
    start_pos)+ 1),input_param)
  ENDIF
 ENDWHILE
 FOR (x = 1 TO table_cnt)
   FREE SET filename1
   SET filename1 = concat(tablespace->tables[x].table_name,".sql")
   FREE SET v_table_name
   SET v_table_name = tablespace->tables[x].table_name
   SELECT INTO "nl:"
    dc.table_name
    FROM user_tab_columns dc
    WHERE dc.table_name=v_table_name
   ;end select
   IF (curqual=0)
    CALL echo(build("!!!Could not find table (",v_table_name,")!!!"))
    SET valid_table_status = 0
   ELSE
    SET valid_table_status = 1
   ENDIF
   IF (valid_table_status)
    CALL echo(build("Creating File (",filename1,")"))
    SELECT INTO value(filename1)
     uic.column_name, uic.data_type, uic.data_length,
     uic.nullable, uic.column_id, uic.table_name,
     default_value = substring(1,40,uic.data_default)
     FROM user_tab_columns uic
     WHERE table_name=v_table_name
     ORDER BY uic.column_id
     HEAD REPORT
      "/***************************************************************************", row + 1,
      "* this section creates the target table",
      row + 1, "***************************************************************************/", row +
      1,
      "/*DROP TABLE ", uic.table_name, " GO */",
      row + 1, "CREATE TABLE ", uic.table_name,
      row + 1, col 10, "("
     DETAIL
      IF (uic.column_id > 1)
       ","
      ENDIF
      row + 1, col 10, uic.column_name,
      col 50, uic.data_type
      IF (((uic.data_type="VARCHAR2") OR (((uic.data_type="CHAR") OR (uic.data_type="VARCHAR")) )) )
       col 60, "(", col 61,
       uic.data_length"####;;I", col 66, ")"
      ENDIF
      IF (default_value != fillstring(40," "))
       default_value_str = trim(default_value), " DEFAULT ", default_value_str
      ENDIF
      IF (uic.nullable="N")
       " NOT NULL"
      ENDIF
     FOOT REPORT
      row + 1, col 10, ")"
     WITH nocounter, format = stream, noheading,
      formfeed = none, maxcol = 512, maxrow = 1
    ;end select
    SELECT INTO value(filename1)
     ut.pct_free, ut.pct_used, ut.tablespace_name,
     ut.initial_extent, ut.next_extent
     FROM user_tables ut
     WHERE table_name=v_table_name
     HEAD REPORT
      pct_free = cnvtstring(ut.pct_free), col 10, "PCTFREE ",
      pct_free, row + 1, pct_used = cnvtstring(ut.pct_used),
      col 10, "PCTUSED ", pct_used,
      row + 1, col 10, "TABLESPACE ",
      ut.tablespace_name, row + 1, col 10,
      "STORAGE ("
     DETAIL
      row + 1, init_extent = concat("INITIAL ",trim(cnvtstring((ut.initial_extent/ 1024),11,0)),"K"),
      col 15,
      init_extent, row + 1, next_extent = concat("NEXT ",trim(cnvtstring((ut.next_extent/ 1024),11,0)
        ),"K"),
      col 15, next_extent, row + 1,
      col 10, ")"
     FOOT REPORT
      row + 1, ";", row + 1
     WITH nocounter, append, format = stream,
      noheading, formfeed = none, maxcol = 512,
      maxrow = 1
    ;end select
    IF (curqual=0)
     SELECT INTO value(filename1)
      HEAD REPORT
       "/*No data found on user_table for */", row + 1,
       "/*PCTFREE, PCTUSED, TABLESPACE, or STORAGE */",
       row + 1
      FOOT REPORT
       ";", row + 1
      WITH nocounter, append, format = stream,
       noheading, formfeed = none, maxcol = 512,
       maxrow = 1
     ;end select
    ENDIF
    SELECT INTO value(filename1)
     uc.constraint_name, uc.table_name, ucc.column_name,
     ucc.position, ui.tablespace_name, ui.initial_extent,
     ui.next_extent, uc.status
     FROM user_indexes ui,
      user_cons_columns ucc,
      user_constraints uc
     WHERE uc.owner=ucc.owner
      AND uc.constraint_name=ui.index_name
      AND ucc.constraint_name=uc.constraint_name
      AND ucc.table_name=uc.table_name
      AND uc.table_name=v_table_name
      AND uc.constraint_type="P"
     ORDER BY uc.table_name, ucc.position
     HEAD REPORT
      "/***************************************************************************", row + 1,
      "* this section creates the primary key on the target table",
      row + 1, "***************************************************************************/", row +
      1
     HEAD uc.table_name
      table_pk = uc.constraint_name, "ALTER TABLE ", uc.table_name,
      row + 1, col 10, "ADD CONSTRAINT ",
      uc.constraint_name, row + 1, col 15,
      "PRIMARY KEY ("
     DETAIL
      IF (ucc.position > 1)
       ","
      ENDIF
      row + 1, col 20, ucc.column_name
     FOOT  uc.table_name
      row + 1, col 15, ")",
      row + 1, col 15, "USING INDEX TABLESPACE ",
      ui.tablespace_name, " "
      IF (uc.status="DISABLED")
       "DISABLE"
      ENDIF
      row + 1, col 15, "STORAGE (",
      row + 1, init_extent = concat("INITIAL ",trim(cnvtstring((ui.initial_extent/ 1024),11,0)),"K"),
      col 20,
      init_extent, row + 1, next_extent = concat("NEXT ",trim(cnvtstring((ui.next_extent/ 1024),11,0)
        ),"K"),
      col 20, next_extent, row + 1,
      col 15, ")", row + 1,
      ";"
     WITH nocounter, format = stream, noheading,
      append, formfeed = none, maxcol = 512,
      maxrow = 1
    ;end select
    SET fk_str = ""
    SELECT INTO value(filename1)
     c.column_name, c.position, b.table_name,
     c.constraint_name, a.table_name, b.status
     FROM user_cons_columns c,
      user_constraints a,
      user_constraints b
     WHERE b.constraint_type="R"
      AND b.r_constraint_name=a.constraint_name
      AND b.owner=a.owner
      AND b.constraint_name=c.constraint_name
      AND b.owner=c.owner
      AND b.table_name=v_table_name
     ORDER BY c.constraint_name, c.position
     HEAD REPORT
      "/***************************************************************************", row + 1,
      "* this section recreates the foreign key constraints on this table",
      row + 1, "***************************************************************************/", row +
      1
     HEAD c.constraint_name
      "ALTER TABLE ", b.table_name, row + 1,
      col 10, "ADD CONSTRAINT ", c.constraint_name,
      row + 1, col 15, "FOREIGN KEY ("
     DETAIL
      IF (c.position > 1)
       fk_str = concat(fk_str,",",c.column_name)
      ELSE
       fk_str = c.column_name
      ENDIF
     FOOT  c.constraint_name
      fk_str, ")", row + 1,
      col 10, "REFERENCES ", a.table_name,
      "(", fk_str, ")"
      IF (b.status="DISABLED")
       " DISABLE"
      ENDIF
      ";", row + 1
     WITH nocounter, format = stream, noheading,
      append, formfeed = none, maxcol = 512,
      maxrow = 1
    ;end select
    SELECT INTO value(filename1)
     ai.table_name, ai.table_owner, ai.tablespace_name,
     ai.index_name, ai.uniqueness, aic.column_name,
     aic.column_position, aic.column_length
     FROM (sys.all_indexes ai),
      (sys.all_ind_columns aic)
     WHERE ai.table_name=v_table_name
      AND ai.table_owner="V500"
      AND ai.index_name=aic.index_name
      AND ai.index_name != table_pk
      AND ai.table_name=aic.table_name
      AND ai.table_owner=aic.table_owner
     ORDER BY ai.index_name, aic.column_position
     HEAD REPORT
      "/***************************************************************************", row + 1,
      "* this section creates the indexes on this table",
      row + 1, "***************************************************************************/"
     HEAD ai.index_name
      row + 1, "CREATE "
      IF (ai.uniqueness="UNIQUE")
       ai.uniqueness
      ENDIF
      " INDEX ", ai.index_name, row + 1,
      col 10, "ON ", ai.table_name,
      "("
     DETAIL
      IF (aic.column_position > 1)
       ","
      ENDIF
      row + 1, col 15, aic.column_name
     FOOT  ai.index_name
      row + 1, col 10, ")",
      row + 1, col 10, "TABLESPACE ",
      ai.tablespace_name, row + 1, col 10,
      "STORAGE (", row + 1, init_extent = concat("INITIAL ",trim(cnvtstring((ai.initial_extent/ 1024),
         11,0)),"K"),
      col 15, init_extent, row + 1,
      next_extent = concat("NEXT ",trim(cnvtstring((ai.next_extent/ 1024),11,0)),"K"), col 15,
      next_extent,
      row + 1, col 10, ")",
      row + 1, ";", row + 1
     WITH nocounter, format = stream, noheading,
      append, formfeed = none, maxcol = 512,
      maxrow = 1
    ;end select
   ENDIF
 ENDFOR
#exit_script
END GO
