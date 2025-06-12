CREATE PROGRAM dm_ocd_passive_comp:dba
 SET debug = validate(fa_debug,0)
 RECORD reply(
   1 qual_num = i4
   1 qual[*]
     2 feature_number = i4
     2 list_num = i4
     2 tab_list[*]
       3 table_name = c30
       3 tbl_stat = c1
       3 index_cnt = i4
       3 indexes[*]
         4 name = c30
       3 column_cnt = i4
       3 columns[*]
         4 name = c30
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD dm_date
 RECORD dm_date(
   1 adm_schema_date = dq8
   1 rev_schema_date = dq8
 )
 SET reply->status_data.status = "F"
 SET feature_number = 0
 SET table_name = fillstring(30," ")
 SET index_name = fillstring(30," ")
 SET column_name = fillstring(30," ")
 SET number_of_features = request->feature_num
 SET reply->qual_num = 0
 SET stat = alterlist(reply->qual,0)
 SET rev_number = request->rev_number
 FOR (fcnt = 1 TO number_of_features)
   SET feature_number = request->feature[fcnt].feature_number
   SET number_of_tables = request->feature[fcnt].qual_num
   IF (debug=1)
    CALL echo(build("* Feature:",feature_number))
   ENDIF
   FOR (tcnt = 1 TO number_of_tables)
     SET table_name = request->feature[fcnt].qual[tcnt].table_name
     IF (debug=1)
      CALL echo(build("* Table:",table_name))
     ENDIF
     SET ref_ind = 0
     SELECT INTO "nl:"
      FROM dm_tables_doc dm
      WHERE dm.table_name=table_name
      DETAIL
       ref_ind = dm.reference_ind
      WITH nocounter
     ;end select
     IF (ref_ind=0)
      SELECT INTO "nl:"
       dft.feature_number, dft.table_name, dft.schema_dt_tm,
       dft.table_env_status
       FROM dm_feature_tables_env dft
       WHERE sqlpassthru(concat("(dft.table_name,dft.schema_dt_tm) in (select d.table_name",
         ", max(d.schema_dt_tm) from dm_feature_tables_env d where 1=1"))
        AND sqlpassthru(concat(" d.table_name='",trim(table_name),"'"))
        AND sqlpassthru(concat(" d.feature_number=",cnvtstring(feature_number),
         " group by d.table_name)"))
       DETAIL
        dm_date->adm_schema_date = dft.schema_dt_tm
       WITH nocounter
      ;end select
      IF (debug=1)
       CALL echo(build("*** ADM SCHEMA DATE:",format(dm_date->adm_schema_date,
          "DD-MMM-YYYY HH:MM:SS;;D")))
      ENDIF
      IF (curqual != 0)
       SELECT INTO "nl:"
        dsv.schema_version"##.###", dsv.schema_date
        FROM dm_schema_version dsv
        WHERE dsv.schema_version=rev_number
        DETAIL
         dm_date->rev_schema_date = dsv.schema_date
        WITH nocounter
       ;end select
       IF (debug=1)
        CALL echo(build("*** REV SCHEMA DATE:",format(dm_date->rev_schema_date,
           "DD-MMM-YYYY HH:MM:SS;;D")))
       ENDIF
       SELECT INTO "nl:"
        FROM dm_tables d
        WHERE d.table_name=table_name
         AND d.schema_date=cnvtdatetime(dm_date->rev_schema_date)
        WITH nocounter
       ;end select
       IF (curqual != 0)
        IF (debug=1)
         CALL echo(build("*** FOUND TABLE IN REV:",table_name))
        ENDIF
        FREE RECORD indexes
        RECORD indexes(
          1 count = i4
          1 index[*]
            2 name = c30
            2 dm_tname = c30
            2 dm_unique_ind = i2
            2 dm_col_cnt = i4
            2 dm_tspace = c30
            2 adm_tname = c30
            2 adm_unique_ind = i2
            2 adm_col_cnt = i4
            2 adm_tspace = c30
            2 identical_col_cnt = i4
            2 dropped_ind = i2
        )
        SET stat = alterlist(indexes->index,0)
        SET indexes->count = 0
        FOR (icnt = 1 TO request->feature[fcnt].qual[tcnt].index_num)
          SET index_name = request->feature[fcnt].qual[tcnt].index[icnt].index_name
          SELECT INTO "nl:"
           ai.index_name, ai.table_name, ai.tablespace_name,
           ai.unique_ind, y = count(*)
           FROM dm_adm_indexes ai,
            dm_adm_index_columns aic
           WHERE ai.table_name=table_name
            AND ai.index_name=index_name
            AND ai.schema_date=cnvtdatetime(dm_date->adm_schema_date)
            AND aic.index_name=ai.index_name
            AND aic.table_name=ai.table_name
            AND aic.schema_date=ai.schema_date
           GROUP BY ai.index_name, ai.table_name, ai.tablespace_name,
            ai.unique_ind
           DETAIL
            found = 0
            FOR (cnt = 1 TO indexes->count)
              IF ((indexes->index[cnt].name=ai.index_name))
               found = cnt, cnt = indexes->count
              ENDIF
            ENDFOR
            IF (found=0)
             indexes->count = (indexes->count+ 1), stat = alterlist(indexes->index,indexes->count),
             found = indexes->count,
             indexes->index[found].name = ai.index_name, indexes->index[found].adm_tname = ai
             .table_name, indexes->index[found].adm_tspace = ai.tablespace_name,
             indexes->index[found].adm_unique_ind = ai.unique_ind, indexes->index[found].dropped_ind
              = 0
            ENDIF
            indexes->index[found].adm_col_cnt = y, indexes->index[found].dm_tname = "", indexes->
            index[found].dm_tspace = "",
            indexes->index[found].dm_unique_ind = 0, indexes->index[found].dm_col_cnt = 0
           WITH nocounter
          ;end select
          SELECT INTO "nl:"
           di.index_name, di.table_name, di.tablespace_name,
           di.unique_ind, y = count(*)
           FROM dm_indexes di,
            dm_index_columns dic
           WHERE di.table_name=table_name
            AND di.schema_date=cnvtdatetime(dm_date->rev_schema_date)
            AND dic.index_name=di.index_name
            AND dic.table_name=di.table_name
            AND dic.schema_date=di.schema_date
           GROUP BY di.index_name, di.table_name, di.tablespace_name,
            di.unique_ind
           DETAIL
            found = 0
            FOR (cnt = 1 TO indexes->count)
              IF ((indexes->index[cnt].name=di.index_name))
               found = cnt, cnt = indexes->count
              ENDIF
            ENDFOR
            IF (found > 0)
             indexes->index[found].dm_tname = di.table_name, indexes->index[found].dm_tspace = di
             .tablespace_name, indexes->index[found].dm_unique_ind = di.unique_ind,
             indexes->index[found].dm_col_cnt = y
            ENDIF
           WITH nocounter
          ;end select
        ENDFOR
        SELECT INTO "nl:"
         dic.index_name, dic.table_name, y = count(*)
         FROM dm_adm_index_columns aic,
          dm_index_columns dic
         WHERE aic.table_name=table_name
          AND aic.schema_date=cnvtdatetime(dm_date->adm_schema_date)
          AND dic.index_name=aic.index_name
          AND dic.table_name=aic.table_name
          AND dic.schema_date=cnvtdatetime(dm_date->rev_schema_date)
          AND dic.column_name=aic.column_name
          AND dic.column_position=aic.column_position
         GROUP BY dic.index_name, dic.table_name
         DETAIL
          found = 0
          FOR (cnt = 1 TO indexes->count)
            IF ((indexes->index[cnt].name=dic.index_name))
             found = cnt, cnt = indexes->count, indexes->index[found].identical_col_cnt = y
            ENDIF
          ENDFOR
         WITH nocounter
        ;end select
        FOR (icnt = 1 TO indexes->count)
         IF (debug=1)
          CALL echo(build("***** Checking index:",indexes->index[icnt].name))
         ENDIF
         IF ((((indexes->index[icnt].adm_tname != indexes->index[icnt].dm_tname)) OR ((((indexes->
         index[icnt].adm_unique_ind != indexes->index[icnt].dm_unique_ind)) OR ((((indexes->index[
         icnt].adm_col_cnt != indexes->index[icnt].dm_col_cnt)) OR ((indexes->index[icnt].
         identical_col_cnt != indexes->index[icnt].dm_col_cnt))) )) )) )
          IF (debug=1)
           CALL echo("***** BAD INDEX")
          ENDIF
          SET ff = 0
          FOR (cnt = 1 TO reply->qual_num)
            IF ((reply->qual[cnt].feature_number=feature_number))
             IF (debug=1)
              CALL echo("***** Feature already in list")
             ENDIF
             SET ff = cnt
             SET cnt = reply->qual_num
            ENDIF
          ENDFOR
          IF (ff=0)
           IF (debug=1)
            CALL echo("***** Adding feature to list")
           ENDIF
           SET reply->qual_num = (reply->qual_num+ 1)
           SET ff = reply->qual_num
           SET stat = alterlist(reply->qual,ff)
           SET reply->qual[ff].feature_number = feature_number
           SET reply->qual[ff].list_num = 0
           SET stat = alterlist(reply->qual[ff].tab_list,0)
          ENDIF
          SET ft = 0
          FOR (cnt = 1 TO reply->qual[ff].list_num)
            IF ((reply->qual[ff].tab_list[cnt].table_name=table_name))
             IF (debug=1)
              CALL echo("******* Table already in list")
             ENDIF
             SET ft = cnt
             SET cnt = reply->qual[ff].list_num
            ENDIF
          ENDFOR
          IF (ft=0)
           IF (debug=1)
            CALL echo("******* Adding Table to list")
           ENDIF
           SET reply->qual[ff].list_num = (reply->qual[ff].list_num+ 1)
           SET ft = reply->qual[ff].list_num
           SET stat = alterlist(reply->qual[ff].tab_list,ft)
           SET reply->qual[ff].tab_list[ft].table_name = table_name
           IF (debug=1)
            CALL echo("*******        Table Stat I")
           ENDIF
           SET reply->qual[ff].tab_list[ft].tbl_stat = "I"
           SET reply->qual[ff].tab_list[ft].index_cnt = 0
           SET stat = alterlist(reply->qual[ff].tab_list[ft].indexes,0)
           SET reply->qual[ff].tab_list[ft].column_cnt = 0
           SET stat = alterlist(reply->qual[ff].tab_list[ft].columns,0)
          ELSE
           IF ((reply->qual[ff].tab_list[ft].tbl_stat="N"))
            SET reply->qual[ff].tab_list[ft].tbl_stat = "B"
            IF (debug=1)
             CALL echo("*******        Table Stat B")
            ENDIF
           ELSE
            SET reply->qual[ff].tab_list[ft].tbl_stat = "I"
            IF (debug=1)
             CALL echo("*******        Table Stat I")
            ENDIF
           ENDIF
          ENDIF
          SET reply->qual[ff].tab_list[ft].index_cnt = (reply->qual[ff].tab_list[ft].index_cnt+ 1)
          SET fi = reply->qual[ff].tab_list[ft].index_cnt
          SET stat = alterlist(reply->qual[ff].tab_list[ft].indexes,fi)
          SET reply->qual[ff].tab_list[ft].indexes[fi].name = indexes->index[icnt].name
         ENDIF
        ENDFOR
        FREE RECORD columns
        RECORD columns(
          1 count = i4
          1 col[*]
            2 name = c30
            2 dm_nullable = c1
            2 dm_data_type = c9
            2 dm_data_length = i4
            2 adm_nullable = c1
            2 adm_data_type = c9
            2 adm_data_length = i4
          1 adm_col_cnt = i4
          1 dm_col_cnt = i4
          1 new_table_ind = i2
        )
        SET stat = alterlist(columns->col,0)
        SET columns->count = 0
        SET columns->new_table_ind = 0
        FOR (icnt = 1 TO request->feature[fcnt].qual[tcnt].column_num)
          SET column_name = request->feature[fcnt].qual[tcnt].column[icnt].column_name
          SELECT INTO "nl:"
           ac.column_name, ac.table_name, ac.data_type,
           ac.data_length, ac.nullable
           FROM dm_adm_columns ac
           WHERE ac.table_name=table_name
            AND ac.column_name=column_name
            AND ac.schema_date=cnvtdatetime(dm_date->adm_schema_date)
           DETAIL
            found = 0
            FOR (cnt = 1 TO columns->count)
              IF ((columns->col[cnt].name=ac.column_name))
               found = cnt, cnt = columns->count
              ENDIF
            ENDFOR
            IF (found=0)
             columns->count = (columns->count+ 1), stat = alterlist(columns->col,columns->count),
             found = columns->count,
             columns->col[found].name = ac.column_name, columns->col[found].adm_data_type = ac
             .data_type, columns->col[found].adm_data_length = ac.data_length,
             columns->col[found].adm_nullable = ac.nullable
            ENDIF
            columns->adm_col_cnt = columns->count, columns->col[found].dm_data_type = "", columns->
            col[found].dm_data_length = 0,
            columns->col[found].dm_nullable = "", columns->dm_col_cnt = 0
           WITH nocounter
          ;end select
          SELECT INTO "nl:"
           dc.column_name, dc.table_name, dc.data_length,
           dc.data_type, dc.nullable
           FROM dm_columns dc
           WHERE dc.table_name=table_name
            AND dc.schema_date=cnvtdatetime(dm_date->rev_schema_date)
           ORDER BY dc.column_name
           DETAIL
            found = 0
            FOR (cnt = 1 TO columns->count)
              IF ((columns->col[cnt].name=dc.column_name))
               found = cnt, cnt = columns->count
              ENDIF
            ENDFOR
            IF (found > 0)
             columns->col[found].dm_data_type = dc.data_type, columns->col[found].dm_data_length = dc
             .data_length, columns->col[found].dm_nullable = dc.nullable,
             columns->dm_col_cnt = columns->count
            ENDIF
           WITH nocounter
          ;end select
          IF (curqual=0)
           SET columns->new_table_ind = 1
          ENDIF
        ENDFOR
        FOR (icnt = 1 TO columns->count)
         IF (debug=1)
          CALL echo(build("***** Checking column:",columns->col[icnt].name))
         ENDIF
         IF ((columns->new_table_ind=0)
          AND (columns->col[icnt].adm_nullable="N")
          AND (columns->col[icnt].dm_nullable != "N"))
          IF (debug=1)
           CALL echo("***** BAD COLUMN")
          ENDIF
          SET ff = 0
          FOR (cnt = 1 TO reply->qual_num)
            IF ((reply->qual[cnt].feature_number=feature_number))
             IF (debug=1)
              CALL echo("***** Feature already in list")
             ENDIF
             SET ff = cnt
             SET cnt = reply->qual_num
            ENDIF
          ENDFOR
          IF (ff=0)
           IF (debug=1)
            CALL echo("***** Adding Feature to list")
           ENDIF
           SET reply->qual_num = (reply->qual_num+ 1)
           SET ff = reply->qual_num
           SET stat = alterlist(reply->qual,ff)
           SET reply->qual[ff].feature_number = feature_number
           SET reply->qual[ff].list_num = 0
           SET stat = alterlist(reply->qual[ff].tab_list,0)
          ENDIF
          SET ft = 0
          FOR (cnt = 1 TO reply->qual[ff].list_num)
            IF ((reply->qual[ff].tab_list[cnt].table_name=table_name))
             IF (debug=1)
              CALL echo("***** Table already in list")
             ENDIF
             SET ft = cnt
             SET cnt = reply->qual[ff].list_num
            ENDIF
          ENDFOR
          IF (ft=0)
           IF (debug=1)
            CALL echo("***** Adding Table to list")
           ENDIF
           SET reply->qual[ff].list_num = (reply->qual[ff].list_num+ 1)
           SET ft = reply->qual[ff].list_num
           SET stat = alterlist(reply->qual[ff].tab_list,ft)
           SET reply->qual[ff].tab_list[ft].table_name = table_name
           IF (debug=1)
            CALL echo("*****        Table Stat N")
           ENDIF
           SET reply->qual[ff].tab_list[ft].tbl_stat = "N"
           SET reply->qual[ff].tab_list[ft].index_cnt = 0
           SET stat = alterlist(reply->qual[ff].tab_list[ft].indexes,0)
           SET reply->qual[ff].tab_list[ft].column_cnt = 0
           SET stat = alterlist(reply->qual[ff].tab_list[ft].columns,0)
          ELSE
           IF ((reply->qual[ff].tab_list[ft].tbl_stat="I"))
            SET reply->qual[ff].tab_list[ft].tbl_stat = "B"
            IF (debug=1)
             CALL echo("*****        Table Stat B")
            ENDIF
           ELSE
            SET reply->qual[ff].tab_list[ft].tbl_stat = "N"
            IF (debug=1)
             CALL echo("*****        Table Stat N")
            ENDIF
           ENDIF
          ENDIF
          SET reply->qual[ff].tab_list[ft].column_cnt = (reply->qual[ff].tab_list[ft].column_cnt+ 1)
          SET fc = reply->qual[ff].tab_list[ft].column_cnt
          SET stat = alterlist(reply->qual[ff].tab_list[ft].columns,fc)
          SET reply->qual[ff].tab_list[ft].columns[fc].name = columns->col[icnt].name
         ENDIF
        ENDFOR
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
 ENDFOR
 IF ((reply->qual_num=0))
  SET reply->status_data.status = "S"
  CALL echo(build("*** Status:",reply->status_data.status))
 ELSE
  SET reply->status_data.status = "Z"
  CALL echo(build("*** Status:",reply->status_data.status))
 ENDIF
 IF (debug=1)
  EXECUTE d_ocd_passive_comp
 ENDIF
#end_program
END GO
