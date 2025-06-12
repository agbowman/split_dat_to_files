CREATE PROGRAM dm_check_pass_copy:dba
 SET emsg = fillstring(132," ")
 SET ecode = 0
 SET icode = 0
 SET imsg = fillstring(132," ")
 FREE SET reply
 RECORD reply(
   1 ren_table = c1
   1 tablespace_name = c1
   1 ren_column = c1
   1 del_column = c1
   1 del_col[*]
     2 col_name = c30
   1 data_type = c1
   1 data_type_col[*]
     2 col_name = c30
   1 data_length = c1
   1 data_length_col[*]
     2 col_name = c30
   1 not_null_column = c1
   1 not_null_col[*]
     2 col_name = c30
   1 non_ref_index = c1
   1 index_col[*]
     2 col_name = c30
   1 ccl_error = c1
   1 ops_event = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF (trim(request->table_name)="")
  SET ierror = 1
  SET imsg = "Empty table in request record"
  GO TO exit_script
 ENDIF
 SET reply->ren_table = "S"
 SET reply->tablespace_name = "S"
 SET reply->ren_column = "S"
 SET reply->del_column = "S"
 SET reply->data_type = "S"
 SET reply->data_length = "S"
 SET reply->not_null_column = "S"
 SET reply->non_ref_index = "S"
 SET reply->ccl_error = "S"
 SET dm_table_name = request->table_name
 SET dm_tablespace_name = fillstring(30," ")
 SET v_index_name = fillstring(32," ")
 SET err_index_name = "S"
 SET err_ind_col = "S"
 SET err_ind_pos = "S"
 SET err_ind_tbls = "S"
 SET new_table_ind = 0
 FREE SET maxdate
 RECORD maxdate(
   1 var_dt_tm = dq8
 )
 SET maxdate->var_dt_tm = 0
 FREE SET maxvalid_date
 RECORD max_valid_date(
   1 max_date[*]
     2 var_dt_tm = dq8
   1 date_count = i4
 )
 SET max_valid_date->date_count = 0
 SELECT INTO "nl:"
  a.schema_date
  FROM dm_adm_tables a
  WHERE a.table_name=dm_table_name
  ORDER BY schema_date DESC
  DETAIL
   max_valid_date->date_count = (max_valid_date->date_count+ 1), stat = alterlist(max_valid_date->
    max_date,max_valid_date->date_count), max_valid_date->max_date[max_valid_date->date_count].
   var_dt_tm = a.schema_date
  WITH nocounter
 ;end select
 SET found = 0
 SELECT INTO "nl:"
  a.feature_number, a.feature_status, b.table_name,
  b.schema_dt_tm
  FROM dm_features a,
   dm_feature_tables_env b
  WHERE b.table_name=dm_table_name
   AND a.feature_status >= "2C"
   AND a.feature_status != "2F"
   AND a.feature_status != "3F"
   AND a.feature_number=b.feature_number
  ORDER BY b.schema_dt_tm DESC, a.feature_number DESC
  DETAIL
   FOR (i = 1 TO max_valid_date->date_count)
     IF ((max_valid_date->max_date[i].var_dt_tm=b.schema_dt_tm))
      IF ((b.schema_dt_tm > maxdate->var_dt_tm))
       maxdate->var_dt_tm = b.schema_dt_tm
      ENDIF
      found = 1
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
 IF (found=0)
  SET new_table_ind = 1
 ENDIF
 IF (new_table_ind=1)
  SELECT DISTINCT INTO "nl:"
   a.tablespace_name
   FROM user_tables a
   WHERE a.table_name=dm_table_name
   DETAIL
    dm_tablespace_name = a.tablespace_name
   WITH nocounter
  ;end select
  SET found = 0
  SELECT DISTINCT INTO "nl:"
   a.tablespace_name
   FROM dm_adm_tables a
   DETAIL
    IF (dm_tablespace_name=a.tablespace_name)
     found = 1
    ENDIF
   WITH nocounter
  ;end select
  IF (found=0)
   CALL echo("New table added to new tablespace")
   SET reply->tablespace_name = "F"
  ENDIF
 ELSE
  SET found = 0
  SELECT INTO "nl:"
   a.tablespace_name, b.tablespace_name
   FROM user_tables a,
    dm_adm_tables b
   WHERE a.table_name=dm_table_name
    AND a.table_name=b.table_name
    AND b.schema_date=cnvtdatetime(maxdate->var_dt_tm)
   DETAIL
    IF (a.tablespace_name=b.tablespace_name)
     found = 1
    ENDIF
   WITH nocounter
  ;end select
  IF (found=0)
   CALL echo("Tablespace name changed")
   SET reply->tablespace_name = "F"
  ENDIF
 ENDIF
 IF (new_table_ind=1)
  SELECT INTO "nl:"
   a.old_table_name, a.new_table_name
   FROM dm_renamed_tbls a
   WHERE a.new_table_name=dm_table_name
   WITH nocounter
  ;end select
  IF (curqual != 0)
   CALL echo("Renamed table")
   SET reply->ren_table = "F"
  ENDIF
  GO TO check_indexes
 ENDIF
 FREE SET all_column_list
 RECORD all_column_list(
   1 column_name[*]
     2 col_name = c30
     2 ren_col_ind = i4
     2 delete_ind = i4
     2 col_seq = i4
     2 data_type = c9
     2 data_length = f8
     2 default_value = c40
     2 nullable = c1
   1 column_count = i4
 )
 FREE SET user_column_list
 RECORD user_column_list(
   1 column_name[*]
     2 col_name = c30
     2 ren_col_ind = i4
     2 exist_ind = i4
     2 col_seq = i4
     2 data_type = c9
     2 data_length = f8
     2 default_value = c40
     2 nullable = c1
   1 column_count = i4
 )
 FREE SET all_index_list
 RECORD all_index_list(
   1 index_name[*]
     2 ind_name = c30
     2 tablespace_name = c30
     2 column_count = i4
   1 index_count = i4
 )
 FREE SET user_index_list
 RECORD user_index_list(
   1 index_name[*]
     2 ind_name = c30
     2 add_ind = i4
     2 tablespace_name = c30
     2 column_count = i4
   1 index_count = i4
 )
 SET stat = alterlist(all_column_list->column_name,10)
 SET all_column_list->column_count = 0
 SET stat = alterlist(user_column_list->column_name,10)
 SET user_column_list->column_count = 0
 SELECT INTO "nl:"
  uic.column_name, uic.data_type, uic.data_length,
  uic.nullable, uic.column_seq, uc.tablespace_name,
  uc.table_name, default_value = substring(1,40,uic.data_default)
  FROM dm_adm_columns uic,
   dm_adm_tables uc
  WHERE uc.table_name=dm_table_name
   AND uc.schema_date=cnvtdatetime(maxdate->var_dt_tm)
   AND uc.table_name=uic.table_name
   AND uc.schema_date=uic.schema_date
  ORDER BY uic.column_name
  DETAIL
   all_column_list->column_count = (all_column_list->column_count+ 1)
   IF (mod(all_column_list->column_count,10)=1
    AND (all_column_list->column_count != 1))
    stat = alterlist(all_column_list->column_name,(all_column_list->column_count+ 9))
   ENDIF
   all_column_list->column_name[all_column_list->column_count].col_name = uic.column_name,
   all_column_list->column_name[all_column_list->column_count].delete_ind = 0, all_column_list->
   column_name[all_column_list->column_count].ren_col_ind = 0,
   all_column_list->column_name[all_column_list->column_count].col_seq = uic.column_seq,
   all_column_list->column_name[all_column_list->column_count].data_type = uic.data_type,
   all_column_list->column_name[all_column_list->column_count].data_length = uic.data_length,
   all_column_list->column_name[all_column_list->column_count].default_value = default_value,
   all_column_list->column_name[all_column_list->column_count].nullable = uic.nullable,
   CALL echo(all_column_list->column_name[all_column_list->column_count].col_name),
   CALL echo(all_column_list->column_name[all_column_list->column_count].data_type),
   CALL echo(all_column_list->column_name[all_column_list->column_count].data_length),
   CALL echo(all_column_list->column_name[all_column_list->column_count].default_value)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("No columns selected")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  uic.column_name, uic.data_type, uic.data_length,
  uic.nullable, uic.column_id, uc.tablespace_name,
  uc.table_name, default_value = substring(1,40,uic.data_default)
  FROM user_tab_columns uic,
   user_tables uc
  WHERE uc.table_name=dm_table_name
   AND uc.table_name=uic.table_name
  ORDER BY uic.column_name
  DETAIL
   user_column_list->column_count = (user_column_list->column_count+ 1)
   IF (mod(user_column_list->column_count,10)=1
    AND (user_column_list->column_count != 1))
    stat = alterlist(user_column_list->column_name,(user_column_list->column_count+ 9))
   ENDIF
   user_column_list->column_name[user_column_list->column_count].col_name = uic.column_name,
   user_column_list->column_name[user_column_list->column_count].ren_col_ind = 0, user_column_list->
   column_name[user_column_list->column_count].exist_ind = 0,
   user_column_list->column_name[user_column_list->column_count].col_seq = uic.column_id,
   user_column_list->column_name[user_column_list->column_count].data_type = uic.data_type,
   user_column_list->column_name[user_column_list->column_count].data_length = uic.data_length,
   user_column_list->column_name[user_column_list->column_count].default_value = default_value,
   user_column_list->column_name[user_column_list->column_count].nullable = uic.nullable,
   CALL echo(user_column_list->column_name[user_column_list->column_count].col_name),
   CALL echo(user_column_list->column_name[user_column_list->column_count].data_type),
   CALL echo(user_column_list->column_name[user_column_list->column_count].data_length),
   CALL echo(trim(user_column_list->column_name[user_column_list->column_count].default_value))
  WITH nocounter
 ;end select
 SET nbr_ren_col = 0
 FOR (cnt = 1 TO user_column_list->column_count)
   SELECT INTO "nl:"
    a.old_col_name, a.new_col_name
    FROM dm_renamed_cols a
    WHERE a.table_name=dm_table_name
     AND (a.new_col_name=user_column_list->column_name[cnt].col_name)
    DETAIL
     FOR (count = 1 TO all_column_list->column_count)
       IF ((all_column_list->column_name[count].col_name=a.old_col_name))
        all_column_list->column_name[count].ren_col_ind = 1, nbr_ren_col = (nbr_ren_col+ 1),
        user_column_list->column_name[cnt].ren_col_ind = 1
       ENDIF
     ENDFOR
    WITH nocounter
   ;end select
 ENDFOR
 IF (nbr_ren_col > 0)
  CALL echo(concat("Table has ",cnvtstring(nbr_ren_col)," renamed columns"))
  SET reply->ren_column = "F"
 ENDIF
 SET nbr_del_col = 0
 SET nbr_data_type = 0
 SET nbr_data_length = 0
 SET nbr_not_null = 0
 FOR (cnt1 = 1 TO all_column_list->column_count)
   IF ((all_column_list->column_name[cnt1].ren_col_ind=0))
    SET found = 0
    FOR (cnt2 = 1 TO user_column_list->column_count)
      IF ((all_column_list->column_name[cnt1].col_name=user_column_list->column_name[cnt2].col_name)
       AND (user_column_list->column_name[cnt2].ren_col_ind != 1))
       SET found = 1
       SET user_column_list->column_name[cnt2].exist_ind = 1
       IF ((all_column_list->column_name[cnt1].data_type != user_column_list->column_name[cnt2].
       data_type))
        IF ((all_column_list->column_name[cnt1].data_type="NUMBER")
         AND (user_column_list->column_name[cnt2].data_type="FLOAT"))
         SET reply->data_type = "S"
        ELSEIF ((all_column_list->column_name[cnt1].data_type="CHAR")
         AND (((user_column_list->column_name[cnt2].data_type="VARCHAR")) OR ((user_column_list->
        column_name[cnt2].data_type="VARCHAR2")))
         AND (user_column_list->column_name[cnt2].data_length >= all_column_list->column_name[cnt1].
        data_length))
         SET reply->data_type = "S"
        ELSEIF ((all_column_list->column_name[cnt1].data_type="VARCHAR")
         AND (user_column_list->column_name[cnt2].data_type="CHAR")
         AND (user_column_list->column_name[cnt2].data_length=all_column_list->column_name[cnt1].
        data_length))
         SET reply->data_type = "S"
        ELSEIF ((all_column_list->column_name[cnt1].data_type="VARCHAR")
         AND (user_column_list->column_name[cnt2].data_type="VARCHAR2")
         AND (user_column_list->column_name[cnt2].data_length >= all_column_list->column_name[cnt1].
        data_length))
         SET reply->data_type = "S"
        ELSEIF ((all_column_list->column_name[cnt1].data_type="VARCHAR2")
         AND (user_column_list->column_name[cnt2].data_type="CHAR")
         AND (user_column_list->column_name[cnt2].data_length=all_column_list->column_name[cnt1].
        data_length))
         SET reply->data_type = "S"
        ELSEIF ((all_column_list->column_name[cnt1].data_type="VARCHAR2")
         AND (user_column_list->column_name[cnt2].data_type="VARCHAR")
         AND (user_column_list->column_name[cnt2].data_length >= all_column_list->column_name[cnt1].
        data_length))
         SET reply->data_type = "S"
        ELSE
         CALL echo("Data type error")
         SET nbr_data_type = (nbr_data_type+ 1)
         SET stat = alterlist(reply->data_type_col,nbr_data_type)
         SET reply->data_type_col[nbr_data_type].col_name = user_column_list->column_name[cnt2].
         col_name
        ENDIF
       ELSEIF ((((all_column_list->column_name[cnt1].data_type="VARCHAR2")) OR ((((all_column_list->
       column_name[cnt1].data_type="VARCHAR")) OR ((((all_column_list->column_name[cnt1].data_type=
       "CHAR")) OR ((all_column_list->column_name[cnt1].data_type="NUMBER"))) )) )) )
        IF ((user_column_list->column_name[cnt2].data_length < all_column_list->column_name[cnt1].
        data_length))
         CALL echo("VARCHAR2 or NUMBER data type with decreased size.")
         SET nbr_data_length = (nbr_data_length+ 1)
         SET stat = alterlist(reply->data_length_col,nbr_data_length)
         SET reply->data_length_col[nbr_data_length].col_name = user_column_list->column_name[cnt2].
         col_name
        ENDIF
       ENDIF
       IF ((all_column_list->column_name[cnt1].nullable="Y")
        AND (user_column_list->column_name[cnt2].nullable="N")
        AND (user_column_list->column_name[cnt2].default_value=fillstring(40," ")))
        SET nbr_not_null = (nbr_not_null+ 1)
        SET stat = alterlist(reply->not_null_col,nbr_not_null)
        SET reply->not_null_col[nbr_not_null].col_name = user_column_list->column_name[cnt2].col_name
       ENDIF
      ENDIF
    ENDFOR
    IF (found=0)
     SET nbr_del_col = (nbr_del_col+ 1)
     SET all_column_list->column_name[cnt1].delete_ind = 1
     SET stat = alterlist(reply->del_col,nbr_del_col)
     SET reply->del_col[nbr_del_col].col_name = all_column_list->column_name[cnt1].col_name
    ENDIF
   ENDIF
 ENDFOR
 IF (nbr_del_col > 0)
  CALL echo(concat("Table has ",cnvtstring(nbr_del_col)," deleted columns"))
  SET reply->del_column = "F"
 ENDIF
 IF (nbr_data_type > 0)
  CALL echo(concat("Table has ",cnvtstring(nbr_data_type)," data type errors"))
  SET reply->data_type = "F"
 ENDIF
 IF (nbr_data_length > 0)
  CALL echo(concat("Table has ",cnvtstring(nbr_data_length)," data length errors"))
  SET reply->data_length = "F"
 ENDIF
 FOR (cnt3 = 1 TO user_column_list->column_count)
   IF ((user_column_list->column_name[cnt3].ren_col_ind != 1)
    AND (user_column_list->column_name[cnt3].exist_ind != 1))
    CALL echo(concat("CNT3 DEFAULT: ",user_column_list->column_name[cnt3].default_value))
    IF ((user_column_list->column_name[cnt3].nullable="N")
     AND (user_column_list->column_name[cnt3].default_value=fillstring(40," ")))
     CALL echo("New NOT NULL column added without default value")
     SET nbr_not_null = (nbr_not_null+ 1)
     SET stat = alterlist(reply->not_null_col,nbr_not_null)
     SET reply->not_null_col[nbr_not_null].col_name = user_column_list->column_name[cnt3].col_name
    ENDIF
   ENDIF
 ENDFOR
 IF (nbr_not_null > 0)
  CALL echo(concat("Table has ",cnvtstring(nbr_not_null)," NOT NULL columns"))
  SET reply->not_null_column = "F"
 ENDIF
#check_indexes
 FREE SET all_index_list
 RECORD all_index_list(
   1 index_name[*]
     2 ind_name = c30
     2 tablespace_name = c30
     2 column_count = i4
   1 index_count = i4
 )
 FREE SET user_index_list
 RECORD user_index_list(
   1 index_name[*]
     2 ind_name = c30
     2 add_ind = i4
     2 tablespace_name = c30
     2 column_count = i4
   1 index_count = i4
 )
 FREE SET tablespace_list
 RECORD tablespace_list(
   1 tablespace_name[*]
     2 tblspace_name = c30
   1 tablespace_count = i4
 )
 SET tablespace_list->tablespace_count = 0
 SET stat = alterlist(tablespace_list->tablespace_name,10)
 SELECT DISTINCT INTO "nl:"
  a.tablespace_name
  FROM dm_adm_indexes a
  DETAIL
   tablespace_list->tablespace_count = (tablespace_list->tablespace_count+ 1)
   IF (mod(tablespace_list->tablespace_count,10)=1
    AND (tablespace_list->tablespace_count != 1))
    stat = alterlist(tablespace_list->tablespace_name,(tablespace_list->tablespace_count+ 9))
   ENDIF
   tablespace_list->tablespace_name[tablespace_list->tablespace_count].tblspace_name = a
   .tablespace_name,
   CALL echo(concat("TABLESPACE :",tablespace_list->tablespace_name[tablespace_list->tablespace_count
    ].tblspace_name))
  WITH nocounter
 ;end select
 SET stat = alterlist(all_index_list->index_name,10)
 SET all_index_list->index_count = 0
 SET stat = alterlist(user_index_list->index_name,10)
 SET user_index_list->index_count = 0
 SELECT INTO "nl:"
  di.index_name, di.tablespace_name
  FROM dm_adm_indexes di
  WHERE di.table_name=dm_table_name
   AND di.schema_date=cnvtdatetime(maxdate->var_dt_tm)
  ORDER BY di.index_name
  DETAIL
   all_index_list->index_count = (all_index_list->index_count+ 1)
   IF (mod(all_index_list->index_count,10)=1
    AND (all_index_list->index_count != 1))
    stat = alterlist(all_index_list->index_name,(all_index_list->index_count+ 9))
   ENDIF
   all_index_list->index_name[all_index_list->index_count].ind_name = di.index_name, all_index_list->
   index_name[all_index_list->index_count].tablespace_name = di.tablespace_name
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  di.index_name, di.tablespace_name
  FROM user_indexes di
  WHERE di.table_name=dm_table_name
  ORDER BY di.index_name
  DETAIL
   user_index_list->index_count = (user_index_list->index_count+ 1)
   IF (mod(user_index_list->index_count,10)=1
    AND (user_index_list->index_count != 1))
    stat = alterlist(user_index_list->index_name,(user_index_list->index_count+ 9))
   ENDIF
   user_index_list->index_name[user_index_list->index_count].ind_name = di.index_name,
   user_index_list->index_name[user_index_list->index_count].tablespace_name = di.tablespace_name
  WITH nocounter
 ;end select
 SET nbr_ind_errors = 0
 SET nbr_ind_tbls = 0
 SET nbr_ind_col = 0
 SET nbr_ind_pos = 0
 SET nbr_ind_name = 0
 SET nbr_ind_add = 0
 CALL echo("USER")
 CALL echo(cnvtstring(user_index_list->index_count))
 FOR (cntu = 1 TO user_index_list->index_count)
   SET found = 0
   SET nbr_ind_name = 0
   SET nbr_ind_pos = 0
   CALL echo("ALL")
   CALL echo(cnvtstring(all_index_list->index_count))
   FOR (cnta = 1 TO all_index_list->index_count)
    CALL echo(cnvtstring(all_index_list->index_count))
    IF ((user_index_list->index_name[cntu].ind_name=all_index_list->index_name[cnta].ind_name))
     SET found = 1
     IF ((user_index_list->index_name[cntu].tablespace_name != all_index_list->index_name[cnta].
     tablespace_name))
      CALL echo("Existing index with a changed tablespace")
      SET nbr_ind_errors = (nbr_ind_errors+ 1)
      SET stat = alterlist(reply->index_col,nbr_ind_errors)
      SET reply->index_col[nbr_ind_errors].col_name = user_index_list->index_name[cntu].ind_name
     ENDIF
    ENDIF
   ENDFOR
   IF (found=0)
    SET found_tbls = 0
    FOR (cntbl = 1 TO tablespace_list->tablespace_count)
      IF ((user_index_list->index_name[cntu].tablespace_name=tablespace_list->tablespace_name[cntbl].
      tblspace_name))
       SET found_tbls = 1
      ENDIF
    ENDFOR
    IF (found_tbls=0)
     CALL echo("Added new index to a non-existing tablespace")
     SET nbr_ind_errors = (nbr_ind_errors+ 1)
     SET nbr_ind_add = (nbr_ind_add+ 1)
     SET stat = alterlist(reply->index_col,nbr_ind_errors)
     SET reply->index_col[nbr_ind_errors].col_name = user_index_list->index_name[cntu].ind_name
    ENDIF
   ENDIF
 ENDFOR
 IF (nbr_ind_errors > 0)
  SET reply->non_ref_index = "F"
 ENDIF
#exit_script
 SELECT
  d.*
  FROM dual d
  DETAIL
   "Deleted columns ", row + 1, reply->del_column,
   row + 1
   FOR (i = 1 TO nbr_del_col)
     i, reply->del_col[i].col_name, row + 1
   ENDFOR
  WITH nocounter
 ;end select
 SET ecode = error(emsg,1)
 IF (icode != 0)
  SET reply->status_data.status = "F"
  SET reply->ops_event = imsg
 ENDIF
 IF (ecode != 0)
  SET reply->ccl_error = "F"
  SET reply->status_data.status = "F"
  SET reply->ops_event = emsg
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
