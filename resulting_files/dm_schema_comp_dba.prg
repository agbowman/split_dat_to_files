CREATE PROGRAM dm_schema_comp:dba
 SET dm_mode = cnvtupper( $1)
 IF (dm_mode != "C"
  AND dm_mode != "L"
  AND dm_mode != "I"
  AND dm_mode != "X"
  AND dm_mode != "N"
  AND dm_mode != "O"
  AND dm_mode != "T"
  AND dm_mode != "B"
  AND dm_mode != "F"
  AND dm_mode != "E"
  AND dm_mode != "A"
  AND dm_mode != "Z"
  AND dm_mode != "D"
  AND dm_mode != "M")
  SELECT
   *
   FROM dual
   DETAIL
    col 0, "Parameter 1: 'C' = Check Mode, 'D' = Debug Mode", row + 1,
    col 0, "             'I' = Check Mode Indexes Only", row + 1,
    col 0, "             'X' = Debug Mode Indexes Only", row + 1,
    col 0, "             'N' = Check Mode Constraints Only", row + 1,
    col 0, "             'O' = Debug Mode Constraints Only", row + 1,
    col 0, "             'T' = Check Mode Tables Only", row + 1,
    col 0, "             'B' = Debug Mode Tables Only", row + 1,
    col 0, "Parameter 2: 'NONE' or Environment Name", row + 1,
    col 0, "Parameter 3: Schema Date (example '29-oct-1996')", row + 2,
    col 0, "Example:     DM_SCHEMA_COMP 'C', 'PROD', '29-OCT-1996' GO", row + 1
   WITH nocounter
  ;end select
 ENDIF
#validate_env
 SET dm_env_name = fillstring(6," ")
 IF (((dm_mode="A") OR (dm_mode="Z")) )
  SET dm_table_name = cnvtupper( $2)
  SET dm_env_name = " "
  SET dm_data_model = " "
 ELSEIF (dm_mode="M")
  SET dm_table_name = " "
  SET dm_env_name = " "
  SET dm_data_model = cnvtupper( $2)
 ELSE
  SET dm_table_name = " "
  SET dm_env_name = cnvtupper( $2)
  SET dm_data_model = " "
 ENDIF
 SET dm_schema_date = cnvtdatetime("31-DEC-1900 00:00")
 SET valid_env_ind = 0
 SET valid_schema_date_ind = 0
 SET valid_table_ind = 0
 SET valid_data_mod_ind = 0
 SET dm_diff_cnt = 0
 SELECT
  IF (((dm_mode="A") OR (dm_mode="Z")) )
   FROM dm_adm_tables t
  ELSE
   FROM dm_tables t
  ENDIF
  INTO "nl:"
  t.schema_date
  WHERE t.schema_date=cnvtdatetime( $3)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET dm_schema_date = cnvtdatetime( $3)
  SET valid_schema_date_ind = 1
 ELSE
  SET valid_schema_date_ind = 0
 ENDIF
 IF (((dm_mode="A") OR (dm_mode="Z")) )
  SELECT INTO "nl:"
   t.table_name
   FROM dm_adm_tables t
   WHERE t.table_name=dm_table_name
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET valid_table_ind = 1
  ELSE
   SET valid_table_ind = 0
  ENDIF
  IF (((valid_table_ind=0) OR (valid_schema_date_ind=0)) )
   IF (dm_mode="A")
    SET feature_table_list->param_error = 1
   ELSE
    SELECT
     *
     FROM dual
     DETAIL
      col 0, "*******************************************", row + 1,
      col 0, "*** INVALID TABLE NAME OR SCHEMA DATE   ***", row + 1,
      col 0, "***        TERMINATING PROGRAM          ***", row + 1,
      col 0, "*******************************************", row + 1
     WITH nocounter
    ;end select
   ENDIF
   GO TO end_program
  ENDIF
 ELSEIF (dm_mode="M")
  SELECT INTO "nl:"
   d.data_model_section
   FROM dm_tables_doc d
   WHERE d.data_model_section=dm_data_model
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET valid_data_mod_ind = 1
  ELSE
   SET valid_data_mod_ind = 0
  ENDIF
  IF (((valid_data_mod_ind=0) OR (valid_schema_date_ind=0)) )
   SELECT
    *
    FROM dual
    DETAIL
     col 0, "*******************************************", row + 1,
     col 0, "*** INVALID DATA MODEL SECTION OR       ***", row + 1,
     col 0, "*** SCHEMA_DATE TERMINATING PROGRAM     ***", row + 1,
     col 0, "*******************************************", row + 1
    WITH nocounter
   ;end select
   GO TO end_program
  ENDIF
 ELSE
  SELECT INTO "nl:"
   e.environment_name
   FROM dm_environment e
   WHERE e.environment_name=dm_env_name
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET valid_env_ind = 1
  ELSE
   SET valid_env_ind = 0
  ENDIF
  IF (valid_env_ind=1)
   SELECT INTO "nl:"
    f.function_id
    FROM dm_env_functions f,
     dm_environment e
    WHERE e.environment_name=dm_env_name
     AND f.environment_id=e.environment_id
    WITH nocounter
   ;end select
   IF (curqual=0)
    SELECT
     *
     FROM dual
     DETAIL
      col 0, "********************************************", row + 1,
      col 0, "*** NO PRODUCTS SELECTED FOR ENVIRONMENT ***", row + 1,
      col 0, "***        TERMINATING PROGRAM           ***", row + 1,
      col 0, "********************************************", row + 1
     WITH nocounter
    ;end select
    GO TO end_program
   ENDIF
  ENDIF
  IF (valid_env_ind=0
   AND valid_schema_date_ind=0)
   SELECT
    *
    FROM dual
    DETAIL
     col 0, "*******************************************", row + 1,
     col 0, "*** INVALID ENVIRONMENT AND SCHEMA_DATE ***", row + 1,
     col 0, "***        TERMINATING PROGRAM          ***", row + 1,
     col 0, "*******************************************", row + 1
    WITH nocounter
   ;end select
   GO TO end_program
  ENDIF
  IF (valid_env_ind=1)
   IF (valid_schema_date_ind=0)
    SELECT INTO "nl:"
     sv.schema_date
     FROM dm_schema_version sv,
      dm_environment e
     WHERE e.environment_name=dm_env_name
      AND sv.schema_version=e.schema_version
     DETAIL
      dm_schema_date = sv.schema_date
     WITH nocounter
    ;end select
    IF (curqual=0)
     SELECT
      *
      FROM dual
      DETAIL
       col 0, "*******************************************", row + 1,
       col 0, "***  ENVIRONMENT IS VALID, BUT SCHEMA   ***", row + 1,
       col 0, "***  DATE FOR THE ENVIRONMENT AND THE   ***", row + 1,
       col 0, "***  PASSED IN $3 PARAMETER IS INVALID  ***", row + 1,
       col 0, "***        TERMINATING PROGRAM          ***", row + 1,
       col 0, "*******************************************", row + 1
      WITH nocounter
     ;end select
     GO TO end_program
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 IF (((dm_mode="F") OR (dm_mode="E")) )
  SELECT INTO "dm_schema_user_diff"
   *
   FROM dual
   DETAIL
    col 0, x = fillstring(100," "), x,
    row + 1
   WITH nocounter, maxcol = 101, noheading,
    noformat, noformfeed, maxrow = 1
  ;end select
  SELECT INTO "dm_schema_date_diff"
   *
   FROM dual
   DETAIL
    col 0, x = fillstring(100," "), x,
    row + 1
   WITH nocounter, maxcol = 101, noheading,
    noformat, noformfeed, maxrow = 1
  ;end select
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
 IF (((dm_mode="A") OR (dm_mode="Z")) )
  SET all_table_list->table_count = (all_table_list->table_count+ 1)
  SET all_table_list->table_name[all_table_list->table_count].tname = dm_table_name
 ELSE
  IF (((dm_mode="D") OR (((dm_mode="X") OR (((dm_mode="Z") OR (((dm_mode="B") OR (((dm_mode="L") OR (
  ((dm_mode="F") OR (dm_mode="O")) )) )) )) )) )) )
   SELECT INTO "nl:"
    ui.table_name
    FROM dm_table_list ui
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
  ELSEIF (dm_mode="M")
   SELECT INTO "nl:"
    t.table_name
    FROM dm_tables t,
     dm_tables_doc td
    WHERE td.data_model_section=dm_data_model
     AND t.schema_date=cnvtdatetime(dm_schema_date)
     AND t.table_name=td.table_name
    DETAIL
     all_table_list->table_count = (all_table_list->table_count+ 1)
     IF (mod(all_table_list->table_count,10)=1
      AND (all_table_list->table_count != 1))
      stat = alterlist(all_table_list->table_name,(all_table_list->table_count+ 9))
     ENDIF
     all_table_list->table_name[all_table_list->table_count].tname = t.table_name
    WITH nocounter
   ;end select
  ELSE
   IF (valid_env_ind=0)
    SELECT INTO "nl:"
     ui.table_name
     FROM dm_tables ui
     WHERE ui.schema_date=cnvtdatetime(dm_schema_date)
     DETAIL
      all_table_list->table_count = (all_table_list->table_count+ 1)
      IF (mod(all_table_list->table_count,10)=1
       AND (all_table_list->table_count != 1))
       stat = alterlist(all_table_list->table_name,(all_table_list->table_count+ 9))
      ENDIF
      all_table_list->table_name[all_table_list->table_count].tname = ui.table_name
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     t.table_name
     FROM dm_tables t,
      dm_tables_doc td,
      dm_function_dm_section_r f,
      dm_env_functions ef,
      dm_environment e
     WHERE e.environment_name=dm_env_name
      AND ef.environment_id=e.environment_id
      AND f.function_id=ef.function_id
      AND td.data_model_section=f.data_model_section
      AND t.table_name=td.table_name
      AND t.schema_date=cnvtdatetime(dm_schema_date)
     DETAIL
      all_table_list->table_count = (all_table_list->table_count+ 1)
      IF (mod(all_table_list->table_count,10)=1
       AND (all_table_list->table_count != 1))
       stat = alterlist(all_table_list->table_name,(all_table_list->table_count+ 9))
      ENDIF
      all_table_list->table_name[all_table_list->table_count].tname = t.table_name
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
 ENDIF
 SET column_count1 = 0
 SET column_count = 0
 SET column_str = fillstring(200," ")
 SET from_column[500] = fillstring(200," ")
 SET to_column[500] = fillstring(200," ")
 SET i = initarray(from_column,fillstring(200," "))
 SET i = initarray(to_column,fillstring(200," "))
 SET cnt = 0
 FOR (cnt = 1 TO all_table_list->table_count)
   SET i = initarray(from_column,fillstring(200," "))
   SET i = initarray(to_column,fillstring(200," "))
   SET tspace_name = fillstring(32," ")
   SET uspace_name = fillstring(32," ")
   IF (((dm_mode="C") OR (((dm_mode="L") OR (((dm_mode="F") OR (((dm_mode="E") OR (((dm_mode="Z") OR
   (((dm_mode="A") OR (((dm_mode="D") OR (((dm_mode="T") OR (((dm_mode="B") OR (dm_mode="M")) )) ))
   )) )) )) )) )) )) )
    SET column_count1 = 0
    SELECT
     IF (((dm_mode="A") OR (dm_mode="Z")) )
      FROM dm_adm_columns uic,
       dm_adm_tables uc
     ELSE
      FROM dm_columns uic,
       dm_tables uc
     ENDIF
     INTO "nl:"
     uic.column_name, uic.data_type, uic.data_length,
     uic.nullable, uic.column_seq, uic.nullable,
     uc.tablespace_name, uc.table_name, default_value = substring(1,40,uic.data_default)
     WHERE (uc.table_name=all_table_list->table_name[cnt].tname)
      AND uc.schema_date=cnvtdatetime(dm_schema_date)
      AND uc.table_name=uic.table_name
      AND uc.schema_date=uic.schema_date
     ORDER BY uc.table_name, uic.column_name
     DETAIL
      column_str = fillstring(200," ")
      IF (((dm_mode="F") OR (dm_mode="E")) )
       column_str = build(uc.table_name,":",uic.column_name," ",uic.data_type)
      ELSE
       column_str = concat(trim(uic.column_name)," ",trim(uic.data_type))
      ENDIF
      IF (((uic.data_type="VARCHAR2") OR (((uic.data_type="CHAR") OR (uic.data_type="VARCHAR")) )) )
       column_str = build(column_str,cnvtstring(uic.data_length))
      ENDIF
      IF (default_value != fillstring(40," "))
       IF (((uic.data_type="NUMBER") OR (uic.data_type="FLOAT")) )
        IF (findstring(".",uic.data_default) > 0)
         column_str = build(column_str," DEFAULT ",cnvtreal(replace(replace(uic.data_default,"("," ",
             0),")"," ",0)))
        ELSE
         column_str = build(column_str," DEFAULT ",cnvtint(replace(replace(uic.data_default,"("," ",0
             ),")"," ",0)))
        ENDIF
       ELSE
        column_str = build(column_str," DEFAULT ",cnvtupper(default_value))
       ENDIF
      ENDIF
      IF (uic.nullable="N")
       column_str = build(column_str," NOT NULL")
      ENDIF
      column_count1 = (column_count1+ 1), to_column[column_count1] = column_str
     FOOT  uc.table_name
      column_count1 = (column_count1+ 1), tspace_name = uc.tablespace_name, to_column[column_count1]
       = build("TABLE NAME: ",uc.table_name)
     WITH nocounter
    ;end select
    SET column_count = 0
    SELECT INTO "nl:"
     uic.column_name, uic.data_type, uic.data_length,
     uic.nullable, uic.column_id, uic.nullable,
     uc.tablespace_name, uc.table_name, default_value = substring(1,40,uic.data_default)
     FROM user_tab_columns uic,
      user_tables uc
     WHERE (uc.table_name=all_table_list->table_name[cnt].tname)
      AND uc.table_name=uic.table_name
     ORDER BY uc.table_name, uic.column_name
     DETAIL
      column_str = fillstring(200," ")
      IF (((dm_mode="F") OR (dm_mode="E")) )
       column_str = build(uc.table_name,":",uic.column_name," ",uic.data_type)
      ELSE
       column_str = concat(trim(uic.column_name)," ",trim(uic.data_type))
      ENDIF
      IF (((uic.data_type="VARCHAR2") OR (((uic.data_type="CHAR") OR (uic.data_type="VARCHAR")) )) )
       column_str = build(column_str,cnvtstring(uic.data_length))
      ENDIF
      IF (default_value != fillstring(40," "))
       IF (((uic.data_type="NUMBER") OR (uic.data_type="FLOAT")) )
        IF (findstring(".",uic.data_default) > 0)
         column_str = build(column_str," DEFAULT ",cnvtreal(replace(replace(uic.data_default,"("," ",
             0),")"," ",0)))
        ELSE
         column_str = build(column_str," DEFAULT ",cnvtint(replace(replace(uic.data_default,"("," ",0
             ),")"," ",0)))
        ENDIF
       ELSE
        column_str = build(column_str," DEFAULT ",cnvtupper(default_value))
       ENDIF
      ENDIF
      IF (uic.nullable="N")
       column_str = build(column_str," NOT NULL")
      ENDIF
      column_count = (column_count+ 1), from_column[column_count] = column_str
     FOOT  uc.table_name
      column_count = (column_count+ 1), uspace_name = uc.tablespace_name, from_column[column_count]
       = build("TABLE NAME: ",uc.table_name)
     WITH nocounter
    ;end select
    IF (((tspace_name != uspace_name) OR (substring(1,2,tspace_name) != "D_")) )
     IF (substring(1,2,uspace_name) != "D_")
      SET column_count1 = (column_count1+ 1)
      SET to_column[column_count1] = build("TABLESPACE : ",tspace_name)
      SET column_count = (column_count+ 1)
      SET from_column[column_count] = build("TABLESPACE: ",uspace_name)
     ENDIF
    ENDIF
    IF (column_count1 > column_count)
     SET column_count = column_count1
    ENDIF
    SET problem = 0
    IF (((dm_mode="D") OR (((dm_mode="Z") OR (dm_mode="B")) )) )
     SELECT
      *
      FROM dual
      DETAIL
       problem = 0, i = 0
       FOR (i = 1 TO column_count)
         IF ((from_column[i] != to_column[i]))
          problem = 1, dm_diff_cnt = (dm_diff_cnt+ 1), col 0,
          "**"
         ENDIF
         col 3, a = substring(1,70,from_column[i]), a,
         "   ", b = substring(1,70,to_column[i]), b,
         row + 1
       ENDFOR
       IF (problem=1)
        table_list->table_count = (table_list->table_count+ 1)
        IF (mod(table_list->table_count,10)=1
         AND (table_list->table_count != 1))
         stat = alterlist(table_list->table_name,(table_list->table_count+ 9))
        ENDIF
        table_list->table_name[table_list->table_count].tname = all_table_list->table_name[cnt].tname
       ENDIF
      WITH nocounter, maxcol = 200
     ;end select
    ELSE
     IF (((dm_mode="F") OR (dm_mode="E")) )
      SELECT INTO "dm_schema_user_diff"
       *
       FROM dual
       DETAIL
        i = 0
        FOR (i = 1 TO column_count)
          col 0, a = substring(1,100,from_column[i]), a,
          row + 1
        ENDFOR
       WITH nocounter, maxcol = 101, noheading,
        noformat, noformfeed, maxrow = 1,
        append
      ;end select
      SELECT INTO "dm_schema_date_diff"
       *
       FROM dual
       DETAIL
        i = 0
        FOR (i = 1 TO column_count)
          col 0, a = substring(1,100,to_column[i]), a,
          row + 1
        ENDFOR
       WITH nocounter, maxcol = 101, noheading,
        noformat, noformfeed, maxrow = 1,
        append
      ;end select
     ELSE
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
         table_list->table_name[table_list->table_count].tname = all_table_list->table_name[cnt].
         tname
        ENDIF
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
   ENDIF
   IF (((dm_mode="C") OR (((dm_mode="L") OR (((dm_mode="F") OR (((dm_mode="E") OR (((dm_mode="N") OR
   (((dm_mode="O") OR (((dm_mode="Z") OR (((dm_mode="A") OR (((dm_mode="D") OR (dm_mode="M")) )) ))
   )) )) )) )) )) )) )
    SET column_count1 = 0
    SET column_count = 0
    SET i = initarray(from_column,fillstring(200," "))
    SET i = initarray(to_column,fillstring(200," "))
    SET column_count1 = 0
    SELECT
     IF (((dm_mode="A") OR (dm_mode="Z")) )
      FROM dm_adm_cons_columns dcc,
       dm_adm_constraints dc
     ELSE
      FROM dm_cons_columns dcc,
       dm_constraints dc
     ENDIF
     INTO "nl:"
     dc.table_name, dc.constraint_name, dc.constraint_type,
     dc.parent_table_name, dc.status_ind, dcc.column_name,
     dcc.position
     WHERE (dc.table_name=all_table_list->table_name[cnt].tname)
      AND dc.schema_date=cnvtdatetime(dm_schema_date)
      AND dc.constraint_type IN ("P", "U")
      AND dc.constraint_name=dcc.constraint_name
      AND dc.table_name=dcc.table_name
      AND dc.schema_date=dcc.schema_date
     ORDER BY dc.table_name, dc.constraint_name, dcc.column_name
     DETAIL
      column_str = fillstring(200," ")
      IF (((dm_mode="F") OR (dm_mode="E")) )
       column_str = concat(dc.table_name,":",dc.constraint_name,dcc.column_name)
      ELSE
       column_str = concat(dc.constraint_name,dcc.column_name)
      ENDIF
      column_count1 = (column_count1+ 1), to_column[column_count1] = column_str
     FOOT  dc.constraint_name
      column_count1 = (column_count1+ 1), to_column[column_count1] = dc.constraint_type
      IF (((dc.constraint_type="P") OR (dc.constraint_type="U")) )
       column_count1 = (column_count1+ 1), to_column[column_count1] = fillstring(30," ")
      ELSE
       column_count1 = (column_count1+ 1), to_column[column_count1] = dc.parent_table_name
      ENDIF
      IF (dm_mode != "A"
       AND dm_mode != "Z")
       IF (dc.status_ind=1)
        column_count1 = (column_count1+ 1), to_column[column_count1] = "ENABLED"
       ELSE
        column_count1 = (column_count1+ 1), to_column[column_count1] = "DISABLED"
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    SELECT
     IF (((dm_mode="A") OR (dm_mode="Z")) )
      FROM dm_adm_cons_columns dcc,
       dm_adm_constraints dc
     ELSE
      FROM dm_cons_columns dcc,
       dm_constraints dc
     ENDIF
     INTO "nl:"
     dc.table_name, dc.constraint_name, dc.constraint_type,
     dc.parent_table_name, dc.status_ind, dcc.column_name,
     dcc.position
     WHERE (dc.table_name=all_table_list->table_name[cnt].tname)
      AND dc.schema_date=cnvtdatetime(dm_schema_date)
      AND dc.constraint_type="R"
      AND dc.constraint_name=dcc.constraint_name
      AND dc.table_name=dcc.table_name
      AND dc.schema_date=dcc.schema_date
     ORDER BY dc.table_name, dc.constraint_name, dcc.column_name
     DETAIL
      column_str = fillstring(200," ")
      IF (((dm_mode="F") OR (dm_mode="E")) )
       column_str = concat(dc.table_name,":",dc.constraint_name,dcc.column_name)
      ELSE
       column_str = concat(dc.constraint_name,dcc.column_name)
      ENDIF
      column_count1 = (column_count1+ 1), to_column[column_count1] = column_str
     FOOT  dc.constraint_name
      column_count1 = (column_count1+ 1), to_column[column_count1] = dc.constraint_type
      IF (((dc.constraint_type="P") OR (dc.constraint_type="U")) )
       column_count1 = (column_count1+ 1), to_column[column_count1] = fillstring(30," ")
      ELSE
       column_count1 = (column_count1+ 1), to_column[column_count1] = dc.parent_table_name
      ENDIF
      IF (dm_mode != "A"
       AND dm_mode != "Z")
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
      column_str = fillstring(200," ")
      IF (((dm_mode="F") OR (dm_mode="E")) )
       column_str = concat(uc.table_name,":",uc.constraint_name,ucc.column_name)
      ELSE
       column_str = concat(uc.constraint_name,ucc.column_name)
      ENDIF
      column_count = (column_count+ 1), from_column[column_count] = column_str
     FOOT  uc.constraint_name
      column_count = (column_count+ 1), from_column[column_count] = uc.constraint_type
      IF (((uc.constraint_type="P") OR (uc.constraint_type="U")) )
       column_count = (column_count+ 1), from_column[column_count] = fillstring(30," ")
      ELSE
       column_count = (column_count+ 1), from_column[column_count] = fillstring(30," ")
      ENDIF
      IF (dm_mode != "A"
       AND dm_mode != "Z")
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
       .constraint_name),"$C")) OR (uc.constraint_name=concat(substring(1,28,ucc.constraint_name),
      "$C"))) ))
     ORDER BY uc.table_name, uc.constraint_name, ucc.column_name
     DETAIL
      column_str = fillstring(200," ")
      IF (((dm_mode="F") OR (dm_mode="E")) )
       column_str = concat(uc.table_name,":",uc.constraint_name,ucc.column_name)
      ELSE
       column_str = concat(uc.constraint_name,ucc.column_name)
      ENDIF
      column_count = (column_count+ 1), from_column[column_count] = column_str
     FOOT  uc.constraint_name
      column_count = (column_count+ 1), from_column[column_count] = uc.constraint_type
      IF (((uc.constraint_type="P") OR (uc.constraint_type="U")) )
       column_count = (column_count+ 1), from_column[column_count] = fillstring(30," ")
      ELSE
       column_count = (column_count+ 1), from_column[column_count] = parent_table_name
      ENDIF
      IF (dm_mode != "A"
       AND dm_mode != "Z")
       column_count = (column_count+ 1), from_column[column_count] = uc.status
      ENDIF
     WITH nocounter
    ;end select
    IF (column_count1 > column_count)
     SET column_count = column_count1
    ENDIF
    SET problem = 0
    IF (((dm_mode="D") OR (((dm_mode="Z") OR (dm_mode="O")) )) )
     SET str = fillstring(100," ")
     SET str0 = fillstring(100," ")
     SET str1 = fillstring(100," ")
     SET str2 = fillstring(100," ")
     SELECT
      *
      FROM dual
      DETAIL
       pos = 0, pos1 = 0, problem = 0,
       i = 0
       FOR (i = 1 TO column_count)
         IF ((from_column[i] != to_column[i]))
          problem = 1, dm_diff_cnt = (dm_diff_cnt+ 1), str = substring(1,65,from_column[i]),
          pos = findstring("$C",str), str0 = substring(1,65,to_column[i]), pos1 = findstring("$C",
           str0)
          IF (((pos != 0) OR (pos1 != 0)) )
           IF (pos1 != 0)
            pos = pos1
           ENDIF
           str1 = substring(1,(pos - 1),from_column[i]), str2 = substring(1,(pos - 1),to_column[i])
           IF (str1 != str2)
            col 0, "**"
           ELSE
            problem = 0, dm_diff_cnt = (dm_diff_cnt - 1)
           ENDIF
          ELSE
           col 0, "**"
          ENDIF
         ENDIF
         col 3, a = substring(1,65,from_column[i]), a,
         "   ", b = substring(1,65,to_column[i]), b,
         row + 1
       ENDFOR
      WITH nocounter, maxcol = 200
     ;end select
    ELSE
     IF (((dm_mode="F") OR (dm_mode="E")) )
      SELECT INTO "dm_schema_user_diff"
       *
       FROM dual
       DETAIL
        i = 0
        FOR (i = 1 TO column_count)
          col 0, a = substring(1,100,from_column[i]), a,
          row + 1
        ENDFOR
       WITH nocounter, maxcol = 101, noheading,
        noformat, noformfeed, maxrow = 1,
        append
      ;end select
      SELECT INTO "dm_schema_date_diff"
       *
       FROM dual
       DETAIL
        i = 0
        FOR (i = 1 TO column_count)
          col 0, a = substring(1,100,to_column[i]), a,
          row + 1
        ENDFOR
       WITH nocounter, maxcol = 101, noheading,
        noformat, noformfeed, maxrow = 1,
        append
      ;end select
     ELSE
      SET str = fillstring(100," ")
      SET str0 = fillstring(100," ")
      SET str1 = fillstring(100," ")
      SET str2 = fillstring(100," ")
      SELECT INTO "nl:"
       *
       FROM dual
       DETAIL
        pos = 0, pos1 = 0, problem = 0,
        i = 0
        FOR (i = 1 TO column_count)
          IF ((from_column[i] != to_column[i]))
           problem = 1, dm_diff_cnt = (dm_diff_cnt+ 1), str = substring(1,65,from_column[i]),
           pos = findstring("$C",str), str0 = substring(1,65,to_column[i]), pos1 = findstring("$C",
            str0)
           IF (((pos != 0) OR (pos1 != 0)) )
            IF (pos1 != 0)
             pos = pos1
            ENDIF
            str1 = substring(1,(pos - 1),from_column[i]), str2 = substring(1,(pos - 1),to_column[i])
            IF (str1=str2)
             problem = 0, dm_diff_cnt = (dm_diff_cnt - 1)
            ENDIF
           ENDIF
          ENDIF
        ENDFOR
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
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
   ENDIF
   IF (((dm_mode="I") OR (((dm_mode="L") OR (((dm_mode="F") OR (((dm_mode="E") OR (((dm_mode="X") OR
   (((dm_mode="C") OR (((dm_mode="A") OR (((dm_mode="Z") OR (((dm_mode="D") OR (dm_mode="M")) )) ))
   )) )) )) )) )) )) )
    SET column_count1 = 0
    SET column_count = 0
    SET i = initarray(from_column,fillstring(200," "))
    SET i = initarray(to_column,fillstring(200," "))
    SET from_tspace[500] = fillstring(200," ")
    SET to_tspace[500] = fillstring(200," ")
    SET tspace_count1 = 0
    SET tspace_count = 0
    SET i = initarray(from_tspace,fillstring(200," "))
    SET i = initarray(to_tspace,fillstring(200," "))
    SET column_count1 = 0
    SET ispace_name = fillstring(32," ")
    SET uispace_name = fillstring(32," ")
    SELECT
     IF (((dm_mode="A") OR (dm_mode="Z")) )
      FROM dm_adm_index_columns dic,
       dm_adm_indexes di
     ELSE
      FROM dm_index_columns dic,
       dm_indexes di
     ENDIF
     INTO "nl:"
     dic.table_name, dic.index_name, dic.column_name,
     dic.column_position, di.tablespace_name, di.unique_ind
     FROM dm_index_columns dic,
      dm_indexes di
     WHERE (di.table_name=all_table_list->table_name[cnt].tname)
      AND di.schema_date=cnvtdatetime(dm_schema_date)
      AND ((di.index_name=dic.index_name) OR (di.index_name=concat(trim(dic.index_name),"$C")))
      AND di.table_name=dic.table_name
      AND di.schema_date=dic.schema_date
     ORDER BY dic.table_name, dic.index_name, dic.column_name
     DETAIL
      column_str = fillstring(200," ")
      IF (((dm_mode="F") OR (dm_mode="E")) )
       column_str = concat(dic.table_name,":",dic.index_name,dic.column_name)
      ELSE
       column_str = concat(dic.index_name,dic.column_name)
      ENDIF
      column_count1 = (column_count1+ 1), to_column[column_count1] = column_str
     FOOT  dic.index_name
      ustr = fillstring(15," ")
      IF (di.unique_ind=0)
       ustr = "NONUNIQUE"
      ELSE
       ustr = "UNIQUE"
      ENDIF
      column_count1 = (column_count1+ 1)
      IF (((dm_mode="F") OR (dm_mode="E")) )
       to_column[column_count1] = concat(dic.table_name,":",trim(dic.index_name),"-",ustr)
      ELSE
       to_column[column_count1] = concat(trim(dic.index_name),"-",trim(ustr))
      ENDIF
      ispace_name = di.tablespace_name, column_count1 = (column_count1+ 1), to_column[column_count1]
       = build(dic.index_name,":",di.tablespace_name),
      tspace_count1 = (tspace_count1+ 1), to_tspace[tspace_count1] = build(dic.index_name,":",di
       .tablespace_name)
     WITH nocounter
    ;end select
    SET column_count = 0
    SELECT INTO "nl:"
     uic.table_name, uic.index_name, uic.column_name,
     uic.column_position, ui.tablespace_name, ui.uniqueness
     FROM user_ind_columns uic,
      user_indexes ui
     WHERE ui.table_owner=currdbuser
      AND (ui.table_name=all_table_list->table_name[cnt].tname)
      AND ((ui.index_name=uic.index_name) OR (((ui.index_name=concat(trim(uic.index_name),"$C")) OR (
     ui.index_name=concat(substring(1,28,uic.index_name),"$C"))) ))
      AND ui.table_name=uic.table_name
     ORDER BY uic.table_name, uic.index_name, uic.column_name
     DETAIL
      column_str = fillstring(200," ")
      IF (((dm_mode="F") OR (dm_mode="E")) )
       column_str = concat(uic.table_name,":",uic.index_name,uic.column_name)
      ELSE
       column_str = concat(uic.index_name,uic.column_name)
      ENDIF
      column_count = (column_count+ 1), from_column[column_count] = column_str
     FOOT  uic.index_name
      column_count = (column_count+ 1)
      IF (((dm_mode="F") OR (dm_mode="E")) )
       from_column[column_count] = concat(uic.table_name,":",trim(uic.index_name),"-",ui.uniqueness)
      ELSE
       from_column[column_count] = concat(trim(uic.index_name),"-",trim(ui.uniqueness))
      ENDIF
      uispace_name = ui.tablespace_name, column_count = (column_count+ 1), from_column[column_count]
       = build(uic.index_name,":",ui.tablespace_name),
      tspace_count = (tspace_count+ 1), from_tspace[tspace_count] = build(uic.index_name,":",ui
       .tablespace_name)
     WITH nocounter
    ;end select
    IF (column_count1 > column_count)
     SET column_count = column_count1
    ENDIF
    SET problem = 0
    IF (((dm_mode="D") OR (((dm_mode="Z") OR (dm_mode="X")) )) )
     SET str = fillstring(100," ")
     SET str0 = fillstring(100," ")
     SET str1 = fillstring(100," ")
     SET str2 = fillstring(100," ")
     SELECT
      *
      FROM dual
      DETAIL
       i = 0
       FOR (i = 1 TO column_count)
         exist = 0, existp = 0, pos = 0,
         pos1 = 0, problem = 0
         IF (((findstring(":",from_column[i]) != 0) OR (findstring(":",to_column[i]) != 0)) )
          exist = 1
         ENDIF
         IF ((from_column[i] != to_column[i]))
          problem = 1, dm_diff_cnt = (dm_diff_cnt+ 1), str = substring(1,65,from_column[i]),
          pos = findstring("$C",str), str0 = substring(1,65,to_column[i]), pos1 = findstring("$C",
           str0)
          IF (((pos != 0) OR (pos1 != 0
           AND exist=0)) )
           IF (pos1 != 0)
            pos = pos1
           ENDIF
           str1 = substring(1,(pos - 1),from_column[i]), str2 = substring(1,(pos - 1),to_column[i])
           IF (str1 != str2)
            col 0, "**"
           ELSE
            problem = 0, dm_diff_cnt = (dm_diff_cnt - 1)
           ENDIF
          ELSE
           IF (exist=1)
            IF (substring(1,65,from_column[i]) != "*:I_*")
             existp = 1, col 0, "**"
            ELSEIF (substring(1,65,to_column[i]) != "*:I_*")
             existp = 1, col 0, "**"
            ELSE
             existp = 0, problem = 0, dm_diff_cnt = (dm_diff_cnt - 1)
            ENDIF
           ELSE
            col 0, "**"
           ENDIF
          ENDIF
         ENDIF
         IF (exist=0)
          col 3, a = substring(1,65,from_column[i]), a,
          "   ", b = substring(1,65,to_column[i]), b,
          row + 1
         ELSEIF (exist=1
          AND problem=1
          AND existp=1)
          col 3, a = substring(1,65,from_column[i]), a,
          "   ", b = substring(1,65,to_column[i]), b,
          row + 1
         ENDIF
       ENDFOR
      WITH nocounter, maxcol = 200
     ;end select
    ELSE
     IF (((dm_mode="F") OR (dm_mode="E")) )
      SELECT INTO "dm_schema_user_diff"
       *
       FROM dual
       DETAIL
        i = 0
        FOR (i = 1 TO column_count)
          col 0, a = substring(1,100,from_column[i]), a,
          row + 1
        ENDFOR
        col 0, "----Tablespace----", row + 1,
        i = 0
        FOR (i = 1 TO tspace_count)
          col 0, a = substring(1,65,from_tspace[i]), a,
          row + 1
        ENDFOR
       WITH nocounter, maxcol = 101, noheading,
        noformat, noformfeed, maxrow = 1,
        append
      ;end select
      SELECT INTO "dm_schema_date_diff"
       *
       FROM dual
       DETAIL
        i = 0
        FOR (i = 1 TO column_count)
          col 0, a = substring(1,100,to_column[i]), a,
          row + 1
        ENDFOR
        col 0, "----Tablespace----", row + 1,
        i = 0
        FOR (i = 1 TO tspace_count)
          col 0, b = substring(1,65,to_tspace[i]), b,
          row + 1
        ENDFOR
       WITH nocounter, maxcol = 101, noheading,
        noformat, noformfeed, maxrow = 1,
        append
      ;end select
     ELSE
      SET str = fillstring(100," ")
      SET str0 = fillstring(100," ")
      SET str1 = fillstring(100," ")
      SET str2 = fillstring(100," ")
      SELECT INTO "nl:"
       *
       FROM dual
       DETAIL
        pos = 0, pos1 = 0, problem = 0,
        i = 0
        FOR (i = 1 TO column_count)
          IF ((from_column[i] != to_column[i]))
           problem = 1, dm_diff_cnt = (dm_diff_cnt+ 1), str = substring(1,65,from_column[i]),
           pos = findstring("$C",str), str0 = substring(1,65,to_column[i]), pos1 = findstring("$C",
            str0)
           IF (((pos != 0) OR (pos1 != 0)) )
            IF (pos1 != 0)
             pos = pos1
            ENDIF
            str1 = substring(1,(pos - 1),from_column[i]), str2 = substring(1,(pos - 1),to_column[i])
            IF (str1=str2)
             problem = 0, dm_diff_cnt = (dm_diff_cnt - 1)
            ENDIF
           ENDIF
          ENDIF
        ENDFOR
       WITH nocounter
      ;end select
      IF (tspace_count1 > tspace_count)
       SET tspace_count = tspace_count1
      ENDIF
      SELECT INTO "nl:"
       *
       FROM dual
       DETAIL
        i = 0
        FOR (i = 1 TO tspace_count)
          IF ((from_tspace[i] != to_tspace[i]))
           pos = findstring(":",substring(1,65,from_tspace[i])), str = substring(1,(pos - 1),
            from_tspace[i]), pos1 = findstring(":",substring(1,65,to_tspace[i])),
           str0 = substring(1,(pos1 - 1),to_tspace[i])
           IF (str=str0)
            IF (((substring(1,65,from_tspace[i]) != "*:I_*") OR (substring(1,65,to_tspace[i]) !=
            "*:I_*")) )
             problem = 1, dm_diff_cnt = (dm_diff_cnt+ 1), col 0,
             "**"
            ENDIF
           ELSE
            problem = 1, dm_diff_cnt = (dm_diff_cnt+ 1), col 0,
            "**"
           ENDIF
          ENDIF
          col 3, a = substring(1,65,from_tspace[i]), a,
          "   ", b = substring(1,65,to_tspace[i]), b,
          row + 1
        ENDFOR
       WITH nocounter, maxcol = 200
      ;end select
     ENDIF
    ENDIF
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
   ENDIF
 ENDFOR
 IF (dm_mode="A")
  SET feature_table_list->nbr_errors = dm_diff_cnt
 ELSE
  IF (dm_mode="Z")
   SELECT
    *
    FROM dual
    DETAIL
     col 0, "********************************************", row + 1,
     col 0, "*** Table:        ", dm_table_name,
     row + 1, col 0, "*** Schema Date:  ",
     dm_schema_date"dd-mmm-yyyy;;d", row + 1, col 0,
     "*** Nbr of Diffs: ", dm_diff_cnt"######", row + 1,
     col 0, "********************************************", row + 1
    WITH nocounter
   ;end select
  ELSEIF (dm_mode="M")
   SELECT
    *
    FROM dual
    DETAIL
     FOR (x = 1 TO table_list->table_count)
      table_list->table_name[x].tname,row + 1
     ENDFOR
    WITH nocounter
   ;end select
  ELSE
   IF (((dm_mode="C") OR (((dm_mode="L") OR (((dm_mode="I") OR (((dm_mode="N") OR (dm_mode="T")) ))
   )) )) )
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
   ENDIF
  ENDIF
 ENDIF
#end_program
END GO
