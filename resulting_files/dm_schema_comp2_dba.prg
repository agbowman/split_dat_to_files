CREATE PROGRAM dm_schema_comp2:dba
#validate_env
 SET dm_env_name = cnvtupper( $1)
 SET dm_schema_date = cnvtdatetime("31-DEC-1900")
 SET valid_env_ind = 0
 SET valid_schema_date_ind = 0
 SELECT INTO "nl:"
  t.schema_date
  FROM dm_schema_version t
  WHERE t.schema_date=cnvtdatetime( $2)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET dm_schema_date = cnvtdatetime( $2)
  SET valid_schema_date_ind = 1
 ELSE
  SET valid_schema_date_ind = 0
 ENDIF
 IF (valid_schema_date_ind=0)
  SELECT INTO "nl:"
   t.schema_date
   FROM dm_tables t
   WHERE t.schema_date=cnvtdatetime( $2)
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET dm_schema_date = cnvtdatetime( $2)
   SET valid_schema_date_ind = 2
  ENDIF
 ENDIF
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
      col 0, "***  PASSED IN $2 PARAMETER IS INVALID  ***", row + 1,
      col 0, "***        TERMINATING PROGRAM          ***", row + 1,
      col 0, "*******************************************", row + 1
     WITH nocounter
    ;end select
    GO TO end_program
   ENDIF
  ENDIF
 ENDIF
 EXECUTE dm_temp_check
 RECORD list(
   1 table1[*]
     2 table_name = c30
     2 col_dm_cnt = f8
     2 col_user_cnt = f8
     2 col_dm_user_cnt = f8
     2 cons_dm_cnt = f8
     2 cons_user_cnt = f8
     2 cons_dm_user_cnt = f8
     2 ind_dm_cnt = f8
     2 ind_user_cnt = f8
     2 ind_dm_user_cnt = f8
   1 table_cnt = i4
 )
 SET stat = alterlist(list->table1,100)
 SET list->table_cnt = 0
 SELECT
  IF (valid_env_ind=0)
   FROM dm_user_tab_cols tc,
    dm_columns c,
    dm_tables d
   WHERE c.table_name > " "
    AND d.table_name=c.table_name
    AND d.schema_date=c.schema_date
    AND c.schema_date=cnvtdatetime(dm_schema_date)
    AND tc.table_name=c.table_name
    AND tc.column_name=c.column_name
    AND ((tc.tablespace_name=d.tablespace_name) OR (tc.tablespace_name="D_*"))
    AND tc.data_type=c.data_type
    AND tc.data_length=c.data_length
    AND tc.nullable=c.nullable
   ORDER BY c.table_name
  ELSEIF (valid_env_ind=1
   AND valid_schema_date_ind=1)
   FROM dm_columns c,
    dm_tables t,
    dm_user_tab_cols tc
   WHERE t.table_name > " "
    AND t.schema_date=cnvtdatetime(dm_schema_date)
    AND c.table_name=t.table_name
    AND c.schema_date=cnvtdatetime(dm_schema_date)
    AND tc.table_name=c.table_name
    AND tc.column_name=c.column_name
    AND ((tc.tablespace_name=t.tablespace_name) OR (tc.tablespace_name="D_*"))
    AND tc.data_type=c.data_type
    AND tc.data_length=c.data_length
    AND tc.nullable=c.nullable
    AND t.table_name IN (
   (SELECT
    td.table_name
    FROM dm_tables_doc td,
     dm_function_dm_section_r f,
     dm_env_functions ef,
     dm_environment e
    WHERE e.environment_name=dm_env_name
     AND ef.environment_id=e.environment_id
     AND f.function_id=ef.function_id
     AND td.data_model_section=f.data_model_section))
   ORDER BY c.table_name
  ELSEIF (valid_env_ind=1
   AND valid_schema_date_ind=2)
   FROM dm_columns c,
    dm_tables t,
    dm_user_tab_cols tc
   WHERE t.table_name > " "
    AND t.schema_date=cnvtdatetime(dm_schema_date)
    AND c.table_name=t.table_name
    AND c.schema_date=cnvtdatetime(dm_schema_date)
    AND tc.table_name=c.table_name
    AND tc.column_name=c.column_name
    AND ((tc.tablespace_name=t.tablespace_name) OR (tc.tablespace_name="D_*"))
    AND tc.data_type=c.data_type
    AND tc.data_length=c.data_length
    AND tc.nullable=c.nullable
   ORDER BY c.table_name
  ELSE
  ENDIF
  INTO "nl:"
  c.table_name
  HEAD c.table_name
   dm_user_cnt = 0
  DETAIL
   IF (((trim(tc.data_default)=trim(c.data_default)) OR (trim(tc.data_default)=null
    AND trim(c.data_default)=null)) )
    dm_user_cnt = (dm_user_cnt+ 1)
   ELSEIF (((c.data_type="NUMBER") OR (c.data_type="FLOAT")) )
    IF (cnvtreal(replace(replace(tc.data_default,"("," ",0),")"," ",0))=cnvtreal(replace(replace(c
       .data_default,"("," ",0),")"," ",0)))
     dm_user_cnt = (dm_user_cnt+ 1)
    ENDIF
   ENDIF
  FOOT  c.table_name
   list->table_cnt = (list->table_cnt+ 1)
   IF (mod(list->table_cnt,100)=1
    AND (list->table_cnt != 1))
    stat = alterlist(list->table1,(list->table_cnt+ 99))
   ENDIF
   list->table1[list->table_cnt].table_name = c.table_name, list->table1[list->table_cnt].
   col_dm_user_cnt = dm_user_cnt
  WITH nocounter
 ;end select
 SELECT
  IF (valid_env_ind=0)
   FROM dm_columns c
   WHERE c.table_name > " "
    AND c.schema_date=cnvtdatetime(dm_schema_date)
   GROUP BY c.table_name
  ELSEIF (valid_env_ind=1
   AND valid_schema_date_ind=1)
   FROM dm_columns c,
    dm_tables t
   WHERE t.table_name > " "
    AND t.schema_date=cnvtdatetime(dm_schema_date)
    AND c.table_name=t.table_name
    AND c.schema_date=cnvtdatetime(dm_schema_date)
    AND t.table_name IN (
   (SELECT
    td.table_name
    FROM dm_tables_doc td,
     dm_function_dm_section_r f,
     dm_env_functions ef,
     dm_environment e
    WHERE e.environment_name=dm_env_name
     AND ef.environment_id=e.environment_id
     AND f.function_id=ef.function_id
     AND td.data_model_section=f.data_model_section))
   GROUP BY c.table_name
  ELSEIF (valid_env_ind=1
   AND valid_schema_date_ind=2)
   FROM dm_columns c,
    dm_tables t
   WHERE t.table_name > " "
    AND t.schema_date=cnvtdatetime(dm_schema_date)
    AND c.table_name=t.table_name
    AND c.schema_date=cnvtdatetime(dm_schema_date)
   GROUP BY c.table_name
  ELSE
  ENDIF
  INTO "nl:"
  c.table_name, dm_cnt = count(*)
  DETAIL
   in_list = 0
   FOR (x = 1 TO list->table_cnt)
     IF ((list->table1[x].table_name=c.table_name))
      list->table1[x].col_dm_cnt = dm_cnt, in_list = 1, x = list->table_cnt
     ENDIF
   ENDFOR
   IF (in_list=0)
    list->table_cnt = (list->table_cnt+ 1)
    IF (mod(list->table_cnt,100)=1
     AND (list->table_cnt != 1))
     stat = alterlist(list->table1,(list->table_cnt+ 99))
    ENDIF
    list->table1[list->table_cnt].table_name = c.table_name, list->table1[list->table_cnt].col_dm_cnt
     = dm_cnt
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  tc.table_name, user_cnt = count(*)
  FROM dm_user_tab_cols tc
  WHERE tc.table_name > " "
   AND tc.tablespace_name="D_*"
  GROUP BY tc.table_name
  DETAIL
   in_list = 0
   FOR (x = 1 TO list->table_cnt)
     IF ((list->table1[x].table_name=tc.table_name))
      list->table1[x].col_user_cnt = user_cnt, in_list = 1, x = list->table_cnt
     ENDIF
   ENDFOR
   IF (in_list=0)
    list->table_cnt = (list->table_cnt+ 1)
    IF (mod(list->table_cnt,100)=1
     AND (list->table_cnt != 1))
     stat = alterlist(list->table1,(list->table_cnt+ 99))
    ENDIF
    list->table1[list->table_cnt].table_name = tc.table_name, list->table1[list->table_cnt].
    col_user_cnt = user_cnt
   ENDIF
  WITH nocounter
 ;end select
 SELECT
  IF (valid_env_ind=0)
   FROM dm_user_cons_columns tc,
    dm_cons_columns c,
    dm_constraints d
   WHERE c.table_name > " "
    AND tc.table_name=c.table_name
    AND tc.column_name=c.column_name
    AND ((tc.constraint_name=c.constraint_name) OR (((tc.constraint_name=concat(trim(c
     .constraint_name),"$C")) OR (tc.constraint_name=concat(substring(1,28,c.constraint_name),"$C")
   )) ))
    AND d.schema_date=c.schema_date
    AND c.schema_date=cnvtdatetime(dm_schema_date)
    AND d.table_name=c.table_name
    AND d.constraint_name=c.constraint_name
    AND tc.constraint_type=d.constraint_type
    AND ((trim(tc.parent_table_name)=trim(d.parent_table_name)) OR (trim(tc.parent_table_name)=null
    AND trim(d.parent_table_name)=null))
    AND tc.constraint_type IN ("P", "U", "R")
    AND tc.status_ind=d.status_ind
   GROUP BY c.table_name
  ELSEIF (valid_env_ind=1
   AND valid_schema_date_ind=1)
   FROM dm_cons_columns c,
    dm_constraints cc,
    dm_user_cons_columns tc
   WHERE cc.table_name > " "
    AND cc.schema_date=cnvtdatetime(dm_schema_date)
    AND cc.constraint_type IN ("P", "U", "R")
    AND c.table_name=cc.table_name
    AND c.constraint_name=cc.constraint_name
    AND c.schema_date=cnvtdatetime(dm_schema_date)
    AND tc.table_name=c.table_name
    AND tc.column_name=c.column_name
    AND ((tc.constraint_name=c.constraint_name) OR (((tc.constraint_name=concat(trim(c
     .constraint_name),"$C")) OR (tc.constraint_name=concat(substring(1,28,c.constraint_name),"$C")
   )) ))
    AND tc.constraint_type=cc.constraint_type
    AND ((trim(tc.parent_table_name)=trim(cc.parent_table_name)) OR (trim(tc.parent_table_name)=null
    AND trim(cc.parent_table_name)=null))
    AND tc.constraint_type IN ("P", "U", "R")
    AND tc.status_ind=cc.status_ind
    AND cc.table_name IN (
   (SELECT
    td.table_name
    FROM dm_tables_doc td,
     dm_function_dm_section_r f,
     dm_env_functions ef,
     dm_environment e
    WHERE e.environment_name=dm_env_name
     AND ef.environment_id=e.environment_id
     AND f.function_id=ef.function_id
     AND td.data_model_section=f.data_model_section))
   GROUP BY c.table_name
  ELSEIF (valid_env_ind=1
   AND valid_schema_date_ind=2)
   FROM dm_cons_columns c,
    dm_constraints cc,
    dm_user_cons_columns tc
   WHERE cc.table_name > " "
    AND cc.schema_date=cnvtdatetime(dm_schema_date)
    AND cc.constraint_type IN ("P", "U", "R")
    AND c.table_name=cc.table_name
    AND c.constraint_name=cc.constraint_name
    AND c.schema_date=cnvtdatetime(dm_schema_date)
    AND tc.table_name=c.table_name
    AND tc.column_name=c.column_name
    AND ((tc.constraint_name=c.constraint_name) OR (((tc.constraint_name=concat(trim(c
     .constraint_name),"$C")) OR (tc.constraint_name=concat(substring(1,28,c.constraint_name),"$C")
   )) ))
    AND tc.constraint_type=cc.constraint_type
    AND ((trim(tc.parent_table_name)=trim(cc.parent_table_name)) OR (trim(tc.parent_table_name)=null
    AND trim(cc.parent_table_name)=null))
    AND tc.constraint_type IN ("P", "U", "R")
    AND tc.status_ind=cc.status_ind
   GROUP BY c.table_name
  ELSE
  ENDIF
  INTO "nl:"
  c.table_name, dm_user_cnt = count(*)
  DETAIL
   in_list = 0
   FOR (x = 1 TO list->table_cnt)
     IF ((list->table1[x].table_name=c.table_name))
      list->table1[x].cons_dm_user_cnt = dm_user_cnt, in_list = 1, x = list->table_cnt
     ENDIF
   ENDFOR
   IF (in_list=0)
    list->table_cnt = (list->table_cnt+ 1)
    IF (mod(list->table_cnt,100)=1
     AND (list->table_cnt != 1))
     stat = alterlist(list->table1,(list->table_cnt+ 99))
    ENDIF
    list->table1[list->table_cnt].table_name = c.table_name, list->table1[list->table_cnt].
    cons_dm_user_cnt = dm_user_cnt
   ENDIF
  WITH nocounter
 ;end select
 SELECT
  IF (valid_env_ind=0)
   FROM dm_cons_columns c
   WHERE c.table_name > " "
    AND c.schema_date=cnvtdatetime(dm_schema_date)
   GROUP BY c.table_name
  ELSEIF (valid_env_ind=1
   AND valid_schema_date_ind=1)
   FROM dm_cons_columns c,
    dm_constraints cc
   WHERE cc.table_name > " "
    AND cc.schema_date=cnvtdatetime(dm_schema_date)
    AND cc.constraint_type IN ("P", "U", "R")
    AND c.table_name=cc.table_name
    AND c.constraint_name=cc.constraint_name
    AND c.schema_date=cnvtdatetime(dm_schema_date)
    AND cc.table_name IN (
   (SELECT
    td.table_name
    FROM dm_tables_doc td,
     dm_function_dm_section_r f,
     dm_env_functions ef,
     dm_environment e
    WHERE e.environment_name=dm_env_name
     AND ef.environment_id=e.environment_id
     AND f.function_id=ef.function_id
     AND td.data_model_section=f.data_model_section))
   GROUP BY c.table_name
  ELSEIF (valid_env_ind=1
   AND valid_schema_date_ind=2)
   FROM dm_cons_columns c,
    dm_constraints cc
   WHERE cc.table_name > " "
    AND cc.schema_date=cnvtdatetime(dm_schema_date)
    AND cc.constraint_type IN ("P", "U", "R")
    AND c.table_name=cc.table_name
    AND c.constraint_name=cc.constraint_name
    AND c.schema_date=cnvtdatetime(dm_schema_date)
   GROUP BY c.table_name
  ELSE
  ENDIF
  INTO "nl:"
  c.table_name, dm_cnt = count(*)
  DETAIL
   in_list = 0
   FOR (x = 1 TO list->table_cnt)
     IF ((list->table1[x].table_name=c.table_name))
      list->table1[x].cons_dm_cnt = dm_cnt, in_list = 1, x = list->table_cnt
     ENDIF
   ENDFOR
   IF (in_list=0)
    list->table_cnt = (list->table_cnt+ 1)
    IF (mod(list->table_cnt,100)=1
     AND (list->table_cnt != 1))
     stat = alterlist(list->table1,(list->table_cnt+ 99))
    ENDIF
    list->table1[list->table_cnt].table_name = c.table_name, list->table1[list->table_cnt].
    cons_dm_cnt = dm_cnt
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  tc.table_name, user_cnt = count(*)
  FROM dm_user_cons_columns tc
  WHERE tc.table_name > " "
  GROUP BY tc.table_name
  DETAIL
   in_list = 0
   FOR (x = 1 TO list->table_cnt)
     IF ((list->table1[x].table_name=tc.table_name))
      list->table1[x].cons_user_cnt = user_cnt, in_list = 1, x = list->table_cnt
     ENDIF
   ENDFOR
   IF (in_list=0)
    list->table_cnt = (list->table_cnt+ 1)
    IF (mod(list->table_cnt,100)=1
     AND (list->table_cnt != 1))
     stat = alterlist(list->table1,(list->table_cnt+ 99))
    ENDIF
    list->table1[list->table_cnt].table_name = tc.table_name, list->table1[list->table_cnt].
    cons_user_cnt = user_cnt
   ENDIF
  WITH nocounter
 ;end select
 SELECT
  IF (valid_env_ind=0)
   FROM dm_user_ind_columns tc,
    dm_index_columns c,
    dm_indexes i
   WHERE c.table_name > " "
    AND tc.table_name=c.table_name
    AND tc.column_name=c.column_name
    AND ((tc.index_name=c.index_name) OR (((tc.index_name=concat(trim(c.index_name),"$C")) OR (tc
   .index_name=concat(substring(1,28,c.index_name),"$C"))) ))
    AND i.schema_date=c.schema_date
    AND c.schema_date=cnvtdatetime(dm_schema_date)
    AND i.table_name=c.table_name
    AND i.index_name=c.index_name
    AND ((tc.tablespace_name=i.tablespace_name) OR (tc.tablespace_name="I_*"))
    AND tc.column_position=c.column_position
   ORDER BY c.table_name
  ELSEIF (valid_env_ind=1
   AND valid_schema_date_ind=1)
   FROM dm_index_columns c,
    dm_indexes i,
    dm_user_ind_columns tc
   WHERE i.table_name > " "
    AND i.schema_date=cnvtdatetime(dm_schema_date)
    AND c.table_name=i.table_name
    AND c.index_name=i.index_name
    AND c.schema_date=cnvtdatetime(dm_schema_date)
    AND tc.table_name=c.table_name
    AND tc.column_name=c.column_name
    AND ((tc.index_name=c.index_name) OR (((tc.index_name=concat(trim(c.index_name),"$C")) OR (tc
   .index_name=concat(substring(1,28,c.index_name),"$C"))) ))
    AND ((tc.tablespace_name=i.tablespace_name) OR (tc.tablespace_name="I_*"))
    AND tc.column_position=c.column_position
    AND i.table_name IN (
   (SELECT
    td.table_name
    FROM dm_tables_doc td,
     dm_function_dm_section_r f,
     dm_env_functions ef,
     dm_environment e
    WHERE e.environment_name=dm_env_name
     AND ef.environment_id=e.environment_id
     AND f.function_id=ef.function_id
     AND td.data_model_section=f.data_model_section))
   ORDER BY c.table_name
  ELSEIF (valid_env_ind=1
   AND valid_schema_date_ind=2)
   FROM dm_index_columns c,
    dm_indexes i,
    dm_user_ind_columns tc
   WHERE i.table_name > " "
    AND i.schema_date=cnvtdatetime(dm_schema_date)
    AND c.table_name=i.table_name
    AND c.index_name=i.index_name
    AND c.schema_date=cnvtdatetime(dm_schema_date)
    AND tc.table_name=c.table_name
    AND tc.column_name=c.column_name
    AND ((tc.index_name=c.index_name) OR (((tc.index_name=concat(trim(c.index_name),"$C")) OR (tc
   .index_name=concat(substring(1,28,c.index_name),"$C"))) ))
    AND ((tc.tablespace_name=i.tablespace_name) OR (tc.tablespace_name="I_*"))
    AND tc.column_position=c.column_position
   ORDER BY c.table_name
  ELSE
  ENDIF
  INTO "nl:"
  c.table_name
  HEAD c.table_name
   dm_user_cnt = 0
  DETAIL
   IF (i.index_name=tc.index_name)
    IF (i.unique_ind=0
     AND tc.uniqueness="NONUNIQUE")
     dm_user_cnt = (dm_user_cnt+ 1)
    ELSEIF (i.unique_ind=1
     AND tc.uniqueness="UNIQUE")
     dm_user_cnt = (dm_user_cnt+ 1)
    ENDIF
   ENDIF
  FOOT  c.table_name
   in_list = 0
   FOR (x = 1 TO list->table_cnt)
     IF ((list->table1[x].table_name=c.table_name))
      list->table1[x].ind_dm_user_cnt = dm_user_cnt, in_list = 1, x = list->table_cnt
     ENDIF
   ENDFOR
   IF (in_list=0)
    list->table_cnt = (list->table_cnt+ 1)
    IF (mod(list->table_cnt,100)=1
     AND (list->table_cnt != 1))
     stat = alterlist(list->table1,(list->table_cnt+ 99))
    ENDIF
    list->table1[list->table_cnt].table_name = c.table_name, list->table1[list->table_cnt].
    ind_dm_user_cnt = dm_user_cnt
   ENDIF
  WITH nocounter
 ;end select
 SELECT
  IF (valid_env_ind=0)
   FROM dm_index_columns c
   WHERE c.table_name > " "
    AND c.schema_date=cnvtdatetime(dm_schema_date)
   GROUP BY c.table_name
  ELSEIF (valid_env_ind=1
   AND valid_schema_date_ind=1)
   FROM dm_index_columns c,
    dm_indexes i
   WHERE i.table_name > " "
    AND i.schema_date=cnvtdatetime(dm_schema_date)
    AND c.table_name=i.table_name
    AND c.index_name=i.index_name
    AND c.schema_date=cnvtdatetime(dm_schema_date)
    AND i.table_name IN (
   (SELECT
    td.table_name
    FROM dm_tables_doc td,
     dm_function_dm_section_r f,
     dm_env_functions ef,
     dm_environment e
    WHERE e.environment_name=dm_env_name
     AND ef.environment_id=e.environment_id
     AND f.function_id=ef.function_id
     AND td.data_model_section=f.data_model_section))
   GROUP BY c.table_name
  ELSEIF (valid_env_ind=1
   AND valid_schema_date_ind=2)
   FROM dm_index_columns c,
    dm_indexes i
   WHERE i.table_name > " "
    AND i.schema_date=cnvtdatetime(dm_schema_date)
    AND c.table_name=i.table_name
    AND c.index_name=i.index_name
    AND c.schema_date=cnvtdatetime(dm_schema_date)
   GROUP BY c.table_name
  ELSE
  ENDIF
  INTO "nl:"
  c.table_name, dm_cnt = count(*)
  DETAIL
   in_list = 0
   FOR (x = 1 TO list->table_cnt)
     IF ((list->table1[x].table_name=c.table_name))
      list->table1[x].ind_dm_cnt = dm_cnt, in_list = 1, x = list->table_cnt
     ENDIF
   ENDFOR
   IF (in_list=0)
    list->table_cnt = (list->table_cnt+ 1)
    IF (mod(list->table_cnt,100)=1
     AND (list->table_cnt != 1))
     stat = alterlist(list->table1,(list->table_cnt+ 99))
    ENDIF
    list->table1[list->table_cnt].table_name = c.table_name, list->table1[list->table_cnt].ind_dm_cnt
     = dm_cnt
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  tc.table_name, user_cnt = count(*)
  FROM dm_user_ind_columns tc
  WHERE tc.table_name > " "
  GROUP BY tc.table_name
  DETAIL
   in_list = 0
   FOR (x = 1 TO list->table_cnt)
     IF ((list->table1[x].table_name=tc.table_name))
      list->table1[x].ind_user_cnt = user_cnt, in_list = 1, x = list->table_cnt
     ENDIF
   ENDFOR
   IF (in_list=0)
    list->table_cnt = (list->table_cnt+ 1)
    IF (mod(list->table_cnt,100)=1
     AND (list->table_cnt != 1))
     stat = alterlist(list->table1,(list->table_cnt+ 99))
    ENDIF
    list->table1[list->table_cnt].table_name = tc.table_name, list->table1[list->table_cnt].
    ind_user_cnt = user_cnt
   ENDIF
  WITH nocounter
 ;end select
 DELETE  FROM dm_table_list
  WHERE 1=1
 ;end delete
 COMMIT
 FOR (x = 1 TO list->table_cnt)
  IF ((((list->table1[x].col_dm_cnt != list->table1[x].col_user_cnt)) OR ((((list->table1[x].
  col_dm_cnt != list->table1[x].col_dm_user_cnt)) OR ((((list->table1[x].col_user_cnt != list->
  table1[x].col_dm_user_cnt)) OR ((((list->table1[x].cons_dm_cnt != list->table1[x].cons_user_cnt))
   OR ((((list->table1[x].cons_dm_cnt != list->table1[x].cons_dm_user_cnt)) OR ((((list->table1[x].
  cons_user_cnt != list->table1[x].cons_dm_user_cnt)) OR ((((list->table1[x].ind_dm_cnt != list->
  table1[x].ind_user_cnt)) OR ((((list->table1[x].ind_dm_cnt != list->table1[x].ind_dm_user_cnt)) OR
  ((list->table1[x].ind_user_cnt != list->table1[x].ind_dm_user_cnt))) )) )) )) )) )) )) )) )
   IF ((list->table1[x].table_name != "DM_USER_CONS_COLUMNS")
    AND (list->table1[x].table_name != "DM_USER_TAB_COLS")
    AND (list->table1[x].table_name != "DM_USER_IND_COLUMNS")
    AND (list->table1[x].table_name != "DM_DM_CONS_COLUMNS")
    AND (list->table1[x].table_name != "DM_DM_COLUMNS")
    AND (list->table1[x].table_name != "DM_DM_IND_COLUMNS")
    AND (list->table1[x].col_dm_cnt != 0))
    INSERT  FROM dm_table_list
     (table_name, updt_applctx, updt_dt_tm,
     updt_cnt, updt_id, updt_task)
     VALUES(list->table1[x].table_name, 0, cnvtdatetime(curdate,curtime3),
     0, 0, 0)
    ;end insert
   ENDIF
  ENDIF
  IF (mod(x,10)=1)
   COMMIT
  ENDIF
 ENDFOR
 COMMIT
 EXECUTE dm_passive_comp  $2
#end_program
END GO
