CREATE PROGRAM dm_passive_comp:dba
 FREE SET list
 RECORD list(
   1 qual[*]
     2 table_name = vc
   1 count = i4
 )
 SET list->count = 0
 SET stat = alterlist(list->qual,10)
 SET sch_date = cnvtdatetime( $1)
 SELECT DISTINCT INTO "nl:"
  dm.table_name
  FROM dm_table_list dm
  ORDER BY dm.table_name
  DETAIL
   list->count = (list->count+ 1)
   IF (mod(list->count,10)=1)
    stat = alterlist(list->qual,(list->count+ 9))
   ENDIF
   list->qual[list->count].table_name = dm.table_name
  WITH nocounter
 ;end select
 SET cnt = 0
 FOR (cnt = 1 TO list->count)
   SET flag = 1
   SET new_table_ind = 0
   SET index_changed = 0
   SET null_changed = 0
   SELECT INTO "nl:"
    d.table_name
    FROM dm_tables d
    WHERE (d.table_name=list->qual[cnt].table_name)
     AND datetimediff(d.schema_date,cnvtdatetime(sch_date))=0
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET flag = 3
   ENDIF
   IF (flag=1)
    SELECT INTO "nl:"
     u.table_name
     FROM dm_user_tab_cols u
     WHERE (u.table_name=list->qual[cnt].table_name)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET new_table_ind = 1
    ENDIF
    IF (new_table_ind=1)
     SELECT INTO "nl:"
      dm.new_table_name
      FROM dm_renamed_tbls dm
      WHERE (dm.new_table_name=list->qual[cnt].table_name)
      WITH nocounter
     ;end select
     IF (curqual > 0)
      CALL echo("Table has been renamed")
      SET flag = 0
     ENDIF
    ENDIF
   ENDIF
   IF (flag=1)
    SET dm_tbs_name = fillstring(80," ")
    SET user_tbs_name = fillstring(80," ")
    SELECT DISTINCT INTO "nl:"
     dm.tablespace_name
     FROM dm_tables dm
     WHERE (dm.table_name=list->qual[cnt].table_name)
      AND datetimediff(dm.schema_date,cnvtdatetime(sch_date))=0
     DETAIL
      dm_tbs_name = dm.tablespace_name
     WITH nocounter
    ;end select
    SELECT DISTINCT INTO "nl:"
     u.tablespace_name
     FROM dba_tablespaces u
     WHERE u.tablespace_name=dm_tbs_name
      AND u.tablespace_name="D_*"
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL echo("Table space for the table is not a valid one")
     SET flag = 0
    ENDIF
   ENDIF
   IF (new_table_ind=0)
    IF (flag=1)
     SELECT DISTINCT INTO "nl:"
      u.tablespace_name
      FROM dm_user_tab_cols u
      WHERE (u.table_name=list->qual[cnt].table_name)
      DETAIL
       user_tbs_name = u.tablespace_name
      WITH nocounter
     ;end select
     IF (user_tbs_name != dm_tbs_name)
      CALL echo("Table space for table has changed")
      SET flag = 0
     ENDIF
    ENDIF
    IF (flag=1)
     FREE SET dm_list
     RECORD dm_list(
       1 c_name[*]
         2 col_name = c30
         2 ren_col_ind = i2
         2 exist_ind = i4
         2 delete_ind = i4
         2 col_seq = i4
         2 data_type = c9
         2 data_length = f8
         2 default_value = c40
         2 nullable = c1
       1 ccount = i4
     )
     FREE SET user_list
     RECORD user_list(
       1 c_name[*]
         2 col_name = c30
         2 ren_col_ind = i4
         2 col_seq = i4
         2 data_type = c9
         2 data_length = f8
         2 default_value = c40
         2 nullable = c1
       1 ccount = i4
     )
     SET stat = alterlist(dm_list->c_name,10)
     SET dm_list->ccount = 0
     SET stat = alterlist(user_list->c_name,10)
     SET user_list->ccount = 0
     SELECT INTO "nl:"
      uic.column_name, uic.data_type, uic.data_length,
      uic.nullable, uic.column_seq, default_value = substring(1,40,uic.data_default)
      FROM dm_columns uic
      WHERE (uic.table_name=list->qual[cnt].table_name)
       AND datetimediff(uic.schema_date,cnvtdatetime(sch_date))=0
      ORDER BY uic.column_name
      DETAIL
       dm_list->ccount = (dm_list->ccount+ 1)
       IF (mod(dm_list->ccount,10)=1
        AND (dm_list->ccount != 1))
        stat = alterlist(dm_list->c_name,(dm_list->ccount+ 9))
       ENDIF
       dm_list->c_name[dm_list->ccount].col_name = uic.column_name, dm_list->c_name[dm_list->ccount].
       exist_ind = 0, dm_list->c_name[dm_list->ccount].col_seq = uic.column_seq,
       dm_list->c_name[dm_list->ccount].data_type = uic.data_type, dm_list->c_name[dm_list->ccount].
       data_length = uic.data_length, dm_list->c_name[dm_list->ccount].default_value = default_value,
       dm_list->c_name[dm_list->ccount].nullable = uic.nullable
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      uic.column_name, uic.data_type, uic.data_length,
      uic.nullable, uic.column_id, default_value = substring(1,40,uic.data_default)
      FROM dm_user_tab_cols uic
      WHERE (uic.table_name=list->qual[cnt].table_name)
      ORDER BY uic.column_name
      DETAIL
       user_list->ccount = (user_list->ccount+ 1)
       IF (mod(user_list->ccount,10)=1
        AND (user_list->ccount != 1))
        stat = alterlist(user_list->c_name,(user_list->ccount+ 9))
       ENDIF
       user_list->c_name[user_list->ccount].col_name = uic.column_name, user_list->c_name[user_list->
       ccount].col_seq = uic.column_id, user_list->c_name[user_list->ccount].data_type = uic
       .data_type,
       user_list->c_name[user_list->ccount].data_length = uic.data_length, user_list->c_name[
       user_list->ccount].nullable = uic.nullable, user_list->c_name[user_list->ccount].default_value
        = default_value
      WITH nocounter
     ;end select
     IF (curqual=0)
      CALL echo("No columns selected")
      SET flag = 0
     ENDIF
    ENDIF
    IF (flag=1)
     SET nbr_ren_col = 0
     FOR (knt = 1 TO dm_list->ccount)
       SELECT INTO "nl:"
        a.old_col_name, a.new_col_name
        FROM dm_renamed_cols a
        WHERE (a.table_name=list->qual[cnt].table_name)
         AND (a.new_col_name=dm_list->c_name[knt].col_name)
        DETAIL
         FOR (knt2 = 1 TO user_list->ccount)
           IF ((user_list->c_name[knt2].col_name=a.old_col_name))
            CALL echo("Renamed column"), nbr_ren_col = (nbr_ren_col+ 1)
           ENDIF
         ENDFOR
        WITH nocounter
       ;end select
     ENDFOR
     IF (nbr_ren_col > 0)
      SET flag = 0
     ENDIF
    ENDIF
    IF (flag=1)
     SET nbr_del_col = 0
     FOR (cnt2 = 1 TO user_list->ccount)
       IF (flag=1)
        SET found = 0
        FOR (cnt1 = 1 TO dm_list->ccount)
          IF (flag=1)
           IF ((dm_list->c_name[cnt1].col_name=user_list->c_name[cnt2].col_name))
            SET found = 1
            SET dm_list->c_name[cnt1].exist_ind = 1
            IF ((dm_list->c_name[cnt1].data_type != user_list->c_name[cnt2].data_type))
             IF ((((dm_list->c_name[cnt1].data_type="FLOAT")
              AND (user_list->c_name[cnt2].data_type="NUMBER")) OR ((((dm_list->c_name[cnt1].
             data_type="VARCHAR")
              AND (user_list->c_name[cnt2].data_type="CHAR")) OR ((((dm_list->c_name[cnt1].data_type=
             "VARCHAR2")
              AND (user_list->c_name[cnt2].data_type="CHAR")) OR ((((dm_list->c_name[cnt1].data_type=
             "VARCHAR2")
              AND (user_list->c_name[cnt2].data_type="VARCHAR")) OR ((((dm_list->c_name[cnt1].
             data_type="VARCHAR")
              AND (user_list->c_name[cnt2].data_type="VARCHAR2")) OR ((((dm_list->c_name[cnt1].
             data_type="CHAR")
              AND (user_list->c_name[cnt2].data_type="VARCHAR")) OR ((dm_list->c_name[cnt1].data_type
             ="CHAR")
              AND (user_list->c_name[cnt2].data_type="VARCHAR2"))) )) )) )) )) )) )
              SET flag = 1
             ELSE
              CALL echo("Invalid Data type change")
              SET flag = 0
             ENDIF
            ENDIF
            IF (flag=1)
             IF ((dm_list->c_name[cnt1].data_type="VARCHAR")
              AND (user_list->c_name[cnt2].data_type="CHAR"))
              IF ((user_list->c_name[cnt2].data_length > dm_list->c_name[cnt1].data_length))
               CALL echo("Invalid datatype size decrease")
               SET flag = 0
              ENDIF
             ENDIF
             IF ((dm_list->c_name[cnt1].data_type="VARCHAR2")
              AND (user_list->c_name[cnt2].data_type="CHAR"))
              IF ((user_list->c_name[cnt2].data_length > dm_list->c_name[cnt1].data_length))
               CALL echo("Invalid datatype size decrease")
               SET flag = 0
              ENDIF
             ENDIF
             IF ((dm_list->c_name[cnt1].data_type="CHAR")
              AND (user_list->c_name[cnt2].data_type="VARCHAR"))
              IF ((user_list->c_name[cnt2].data_length != dm_list->c_name[cnt1].data_length))
               CALL echo("Invalid datatype size change")
               SET flag = 0
              ENDIF
             ENDIF
             IF ((dm_list->c_name[cnt1].data_type="CHAR")
              AND (user_list->c_name[cnt2].data_type="VARCHAR2"))
              IF ((user_list->c_name[cnt2].data_length != dm_list->c_name[cnt1].data_length))
               CALL echo("Invalid datatype size change")
               SET flag = 0
              ENDIF
             ENDIF
             IF ((dm_list->c_name[cnt1].data_type="VARCHAR")
              AND (user_list->c_name[cnt2].data_type="VARCHAR2"))
              IF ((user_list->c_name[cnt2].data_length > dm_list->c_name[cnt1].data_length))
               CALL echo("Invalid datatype size decrease")
               SET flag = 0
              ENDIF
             ENDIF
             IF ((dm_list->c_name[cnt1].data_type="VARCHAR2")
              AND (user_list->c_name[cnt2].data_type="VARCHAR"))
              IF ((user_list->c_name[cnt2].data_length > dm_list->c_name[cnt1].data_length))
               CALL echo("Invalid datatype size decrease")
               SET flag = 0
              ENDIF
             ENDIF
            ENDIF
            IF (flag=1)
             IF ((dm_list->c_name[cnt1].data_type != "VARCHAR2")
              AND (dm_list->c_name[cnt1].data_type != "VARCHAR")
              AND (dm_list->c_name[cnt1].data_type != "CHAR"))
              IF ((user_list->c_name[cnt2].data_length < dm_list->c_name[cnt1].data_length))
               CALL echo("Invalid datatype size increase")
               SET flag = 0
              ENDIF
             ENDIF
            ENDIF
            IF (flag=1)
             IF ((dm_list->c_name[cnt1].nullable != user_list->c_name[cnt2].nullable))
              IF ((user_list->c_name[cnt2].nullable="Y")
               AND (dm_list->c_name[cnt1].nullable="N"))
               SET null_changed = 1
               IF ((dm_list->c_name[cnt1].default_value=" "))
                CALL echo("Modified existing null col to not null w/o def value")
                SET flag = 0
               ENDIF
              ENDIF
             ENDIF
            ENDIF
           ENDIF
          ENDIF
        ENDFOR
        IF (found=0)
         SET nbr_del_col = (nbr_del_col+ 1)
         SET flag = 0
        ENDIF
       ENDIF
     ENDFOR
     IF (nbr_del_col > 0)
      CALL echo("Existing column(s) dropped !")
      SET flag = 0
     ENDIF
    ENDIF
    IF (flag=1)
     FOR (cnt3 = 1 TO dm_list->ccount)
       IF ((dm_list->c_name[cnt3].exist_ind=0))
        IF ((dm_list->c_name[cnt3].default_value=" ")
         AND (dm_list->c_name[cnt3].nullable="N"))
         CALL echo("New not null column w/o def value added")
         SET flag = 0
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
    IF (flag=1)
     FREE SET dmx_list
     RECORD dmx_list(
       1 nx_name[*]
         2 ind_name = c30
         2 tablespace_name = c30
         2 col_cnt = i4
         2 qual[*]
           3 col_name = vc
       1 icount = i4
     )
     FREE SET undx_list
     RECORD undx_list(
       1 nx_name[*]
         2 ind_name = c30
         2 add_ind = i4
         2 tablespace_name = c30
         2 col_cnt = i4
         2 qual[*]
           3 col_name = vc
       1 icount = i4
     )
     SET stat = alterlist(dmx_list->nx_name,10)
     SET dmx_list->icount = 0
     SET stat = alterlist(undx_list->nx_name,10)
     SET undx_list->icount = 0
     SET ind_name = fillstring(32," ")
     SELECT INTO "nl:"
      dic.table_name, dic.index_name, di.tablespace_name
      FROM dm_index_columns dic,
       dm_indexes di
      WHERE (di.table_name=list->qual[cnt].table_name)
       AND datetimediff(di.schema_date,cnvtdatetime(sch_date))=0
       AND di.index_name=dic.index_name
       AND di.table_name=dic.table_name
       AND di.schema_date=dic.schema_date
      ORDER BY dic.index_name, dic.column_position
      HEAD di.index_name
       dmx_list->icount = (dmx_list->icount+ 1)
       IF (mod(dmx_list->icount,10)=1
        AND (dmx_list->icount != 1))
        stat = alterlist(dmx_list->nx_name,(dmx_list->icount+ 9))
       ENDIF
       ind_name = dic.index_name, dmx_list->nx_name[dmx_list->icount].ind_name = dic.index_name,
       dmx_list->nx_name[dmx_list->icount].tablespace_name = di.tablespace_name,
       dmx_list->nx_name[dmx_list->icount].col_cnt = 0
      DETAIL
       icount = dmx_list->icount, dmx_list->nx_name[icount].col_cnt = (dmx_list->nx_name[icount].
       col_cnt+ 1), col_cnt = dmx_list->nx_name[icount].col_cnt,
       stat = alterlist(dmx_list->nx_name[icount].qual,col_cnt), dmx_list->nx_name[icount].qual[
       col_cnt].col_name = dic.column_name
      WITH nocounter
     ;end select
     SET ind_name = fillstring(32," ")
     SELECT INTO "nl:"
      dic.table_name, dic.index_name, dic.tablespace_name
      FROM dm_user_ind_columns dic
      WHERE (dic.table_name=list->qual[cnt].table_name)
      ORDER BY dic.index_name, dic.column_position
      HEAD dic.index_name
       undx_list->icount = (undx_list->icount+ 1)
       IF (mod(undx_list->icount,10)=1
        AND (undx_list->icount != 1))
        stat = alterlist(undx_list->nx_name,(undx_list->icount+ 9))
       ENDIF
       ind_name = dic.index_name, undx_list->nx_name[undx_list->icount].ind_name = dic.index_name,
       undx_list->nx_name[undx_list->icount].tablespace_name = dic.tablespace_name,
       undx_list->nx_name[undx_list->icount].col_cnt = 0
      DETAIL
       icount = undx_list->icount, undx_list->nx_name[icount].col_cnt = (undx_list->nx_name[icount].
       col_cnt+ 1), col_cnt = undx_list->nx_name[icount].col_cnt,
       stat = alterlist(undx_list->nx_name[icount].qual,col_cnt), undx_list->nx_name[icount].qual[
       col_cnt].col_name = dic.column_name
      WITH nocounter
     ;end select
     SET index_changed = 0
     FOR (knt1 = 1 TO dmx_list->icount)
       SET found = 0
       SET dm_tbs_nm = fillstring(80," ")
       FOR (knt2 = 1 TO undx_list->icount)
         IF ((undx_list->nx_name[knt2].ind_name=dmx_list->nx_name[knt1].ind_name))
          SET found = 1
          SET user_tbs_nm = fillstring(80," ")
          IF ((undx_list->nx_name[knt2].col_cnt != dmx_list->nx_name[knt1].col_cnt))
           CALL echo(concat("number of columns in index has changed ",dmx_list->nx_name[knt1].
             ind_name))
           SET index_changed = 1
          ELSE
           FOR (knt3 = 1 TO undx_list->nx_name[knt2].col_cnt)
             IF ((undx_list->nx_name[knt2].qual[knt3].col_name != dmx_list->nx_name[knt1].qual[knt3].
             col_name))
              CALL echo(concat("columns in index have changed ",dmx_list->nx_name[knt1].ind_name))
              SET index_changed = 1
             ENDIF
           ENDFOR
          ENDIF
          IF ((undx_list->nx_name[knt2].tablespace_name != dmx_list->nx_name[knt1].tablespace_name))
           SELECT INTO "nl:"
            u.tablespace_name
            FROM dba_tablespaces u
            WHERE (u.tablespace_name=dmx_list->nx_name[knt1].tablespace_name)
             AND u.tablespace_name="I_*"
            WITH nocounter
           ;end select
           IF (curqual=0)
            CALL echo("Table space for index is not a valid tablespace")
            SET flag = 1
            SET index_changed = 1
           ENDIF
          ENDIF
         ENDIF
       ENDFOR
       IF (found=0)
        SET index_changed = 1
        SELECT INTO "nl:"
         u.tablespace_name
         FROM dba_tablespaces u
         WHERE (u.tablespace_name=dmx_list->nx_name[knt1].tablespace_name)
          AND u.tablespace_name="I_*"
         WITH nocounter
        ;end select
        IF (curqual=0)
         CALL echo("Table space for index is not a valid tablespace")
         SET flag = 1
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
   IF (flag=1)
    SET refer_ind = 0
    IF (((index_changed=1) OR (null_changed=1)) )
     SELECT INTO "nl:"
      FROM dm_tables_doc dtd
      WHERE (dtd.table_name=list->qual[cnt].table_name)
      DETAIL
       refer_ind = dtd.reference_ind
      WITH nocounter
     ;end select
    ENDIF
    IF (((refer_ind=1) OR (index_changed=0
     AND null_changed=0)) )
     UPDATE  FROM dm_table_list dtl
      SET dtl.process_flg = 1
      WHERE (dtl.table_name=list->qual[cnt].table_name)
      WITH nocounter
     ;end update
    ELSE
     UPDATE  FROM dm_table_list dtl
      SET dtl.process_flg = 3
      WHERE (dtl.table_name=list->qual[cnt].table_name)
      WITH nocounter
     ;end update
    ENDIF
   ELSEIF (flag=0)
    UPDATE  FROM dm_table_list dtl
     SET dtl.process_flg = 2
     WHERE (dtl.table_name=list->qual[cnt].table_name)
     WITH nocounter
    ;end update
   ELSE
    UPDATE  FROM dm_table_list dtl
     SET dtl.process_flg = 0
     WHERE (dtl.table_name=list->qual[cnt].table_name)
     WITH nocounter
    ;end update
   ENDIF
   COMMIT
 ENDFOR
 FREE RECORD tables
 RECORD tables(
   1 t_list[*]
     2 name = c30
     2 process_flg = i2
   1 count = i4
 )
 SET tables->count = 0
 SET stat = alterlist(tables->t_list,0)
 SELECT INTO "nl:"
  FROM dm_table_list dtl
  WHERE dtl.process_flg=3
  DETAIL
   tables->count = (tables->count+ 1), stat = alterlist(tables->t_list,tables->count), tables->
   t_list[tables->count].name = dtl.table_name,
   tables->t_list[tables->count].process_flg = dtl.process_flg
  WITH nocounter
 ;end select
 CALL echo("-")
 CALL echo(build("*** Found:",tables->count," tables with process_flg=3"))
 CALL echo("***")
 SET i = 1
 WHILE ((i <= tables->count))
  IF ((tables->t_list[i].process_flg=3))
   CALL echo("-")
   CALL echo(build("***** Processing table[",i,"]:",tables->t_list[i].name," in the parents list"))
   CALL echo("*****")
   FREE RECORD children
   RECORD children(
     1 c_list[*]
       2 name = c30
     1 count = i4
   )
   SET children->count = 0
   SET stat = alterlist(children->c_list,0)
   SELECT INTO "nl:"
    FROM dm_constraints dc,
     dm_table_list dtl
    WHERE datetimediff(dc.schema_date,cnvtdatetime(sch_date))=0
     AND (dc.parent_table_name=tables->t_list[i].name)
     AND dc.table_name=dtl.table_name
     AND dtl.process_flg=1
    DETAIL
     children->count = (children->count+ 1), stat = alterlist(children->c_list,children->count),
     children->c_list[children->count].name = dc.table_name
    WITH counter
   ;end select
   CALL echo("-")
   CALL echo(build("***** Found:",children->count," children of parent:",tables->t_list[i].name,
     " in dm_table_list"))
   CALL echo("*****")
   FOR (j = 1 TO children->count)
     CALL echo("-")
     CALL echo(build("******* Flip flag for child[",j,"]:",children->c_list[j].name," of parent:",
       tables->t_list[i].name))
     UPDATE  FROM dm_table_list dtl
      SET dtl.process_flg = 3
      WHERE (dtl.table_name=children->c_list[j].name)
       AND dtl.process_flg=1
     ;end update
     COMMIT
     SET found_it = 0
     SET k = 1
     WHILE ((k <= tables->count)
      AND found_it=0)
      IF ((tables->t_list[k].name=children->c_list[j].name))
       SET found_it = 1
      ENDIF
      SET k = (k+ 1)
     ENDWHILE
     IF (found_it=0)
      CALL echo("******* Adding this child to list of parents!")
      SET tables->count = (tables->count+ 1)
      SET stat = alterlist(tables->t_list,tables->count)
      SET tables->t_list[tables->count].name = children->c_list[j].name
      SET tables->t_list[tables->count].process_flg = 3
      CALL echo(build("******* Now there are:",tables->count," tables in parents list!"))
     ELSE
      CALL echo("******* This child is already in parents list!")
      SET x = 0
     ENDIF
   ENDFOR
  ENDIF
  SET i = (i+ 1)
 ENDWHILE
END GO
