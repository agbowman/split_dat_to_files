CREATE PROGRAM dm_compare_schema:dba
 IF (((validate(curdb->tbl_cnt,- (1)) < 0) OR (validate(tgtdb->tbl_cnt,- (1)) < 0)) )
  CALL echo("*** Global record struct not found")
  GO TO end_program
 ENDIF
 IF ((tgtdb->tbl_cnt=0))
  CALL echo("*** No tables found in target schema")
  GO TO end_program
 ENDIF
 SET tgtdb->diff_ind = 0
 SET tgtdb->warn_ind = 0
 SET tgtdb->downtime_ind = 0
 FOR (t_tbl = 1 TO tgtdb->tbl_cnt)
   SET tgtdb->tbl[t_tbl].diff_ind = 0
   SET tgtdb->tbl[t_tbl].warn_ind = 0
   SET tgtdb->tbl[t_tbl].downtime_ind = 0
   SET tgtdb->tbl[t_tbl].uptime_ind = 0
   SET tgtdb->tbl[t_tbl].combine_ind = 0
   SET tgtdb->tbl[t_tbl].active_trigger_ind = 0
   SET tgtdb->tbl[t_tbl].zero_row_ind = 0
   SET tgtdb->tbl[t_tbl].synonym_ind = 1
   SET tgtdb->tbl[t_tbl].cur_idx = 0
   SET schema_diff = 0
   SET schema_warn = 0
   SET schema_downtime = 0
   SET schema_uptime = 0
   SET combine_ind = 0
   SET c_tbl = 0
   FOR (t = 1 TO curdb->tbl_cnt)
     IF ((curdb->tbl[t].tbl_name=tgtdb->tbl[t_tbl].tbl_name))
      SET c_tbl = t
      SET t = curdb->tbl_cnt
     ENDIF
   ENDFOR
   IF (c_tbl=0)
    SET tgtdb->tbl[t_tbl].new_ind = 1
    SET tgtdb->tbl[t_tbl].cur_idx = 0
    SET schema_uptime = 1
    FOR (t_col = 1 TO tgtdb->tbl[t_tbl].tbl_col_cnt)
      IF ((tgtdb->tbl[t_tbl].tbl_col[t_col].data_default IN ("NULL", " ", "")))
       SET tgtdb->tbl[t_tbl].tbl_col[t_col].data_default = "NULL"
      ENDIF
      IF ((tgtdb->tbl[t_tbl].tbl_col[t_col].data_type IN ("NUMBER", "FLOAT", "DATE"))
       AND findstring("(",tgtdb->tbl[t_tbl].tbl_col[t_col].data_default)=1)
       SET tgtdb->tbl[t_tbl].tbl_col[t_col].data_default = trim(replace(tgtdb->tbl[t_tbl].tbl_col[
         t_col].data_default,"("," ",1),3)
       SET tgtdb->tbl[t_tbl].tbl_col[t_col].data_default = trim(replace(tgtdb->tbl[t_tbl].tbl_col[
         t_col].data_default,")"," ",2),3)
      ENDIF
      IF (findstring("'",tgtdb->tbl[t_tbl].tbl_col[t_col].data_default) != 1)
       SET tgtdb->tbl[t_tbl].tbl_col[t_col].data_default = cnvtupper(tgtdb->tbl[t_tbl].tbl_col[t_col]
        .data_default)
      ENDIF
    ENDFOR
    FOR (t_ind = 1 TO tgtdb->tbl[t_tbl].ind_cnt)
      SET tgtdb->tbl[t_tbl].ind[t_ind].new_ind = 1
      SET tgtdb->tbl[t_tbl].ind[t_ind].build_ind = 1
      SET tgtdb->tbl[t_tbl].ind[t_ind].cur_idx = 0
    ENDFOR
    FOR (t_cons = 1 TO tgtdb->tbl[t_tbl].cons_cnt)
      SET tgtdb->tbl[t_tbl].cons[t_cons].new_ind = 1
      SET tgtdb->tbl[t_tbl].cons[t_cons].build_ind = 1
      SET tgtdb->tbl[t_tbl].cons[t_cons].cur_idx = 0
      IF ((tgtdb->tbl[t_tbl].cons[t_cons].cons_type="R")
       AND (tgtdb->tbl[t_tbl].cons[t_cons].parent_table IN ("PERSON", "ENCOUNTER")))
       SET combine_ind = 1
      ENDIF
    ENDFOR
   ELSE
    SET tgtdb->tbl[t_tbl].new_ind = 0
    SET tgtdb->tbl[t_tbl].cur_idx = c_tbl
    IF ( NOT (substring(1,2,curdb->tbl[c_tbl].tspace_name) IN ("D_", "I_")))
     SET curdb->tbl[c_tbl].bad_tspace_ind = 1
     SET schema_warn = 1
    ELSE
     SET curdb->tbl[c_tbl].bad_tspace_ind = 0
     IF ((tgtdb->tbl[t_tbl].tspace_name != curdb->tbl[c_tbl].tspace_name))
      SET tgtdb->tbl[t_tbl].diff_tspace_ind = 1
      SET tgtdb->tbl[t_tbl].tgt_tspace_name = tgtdb->tbl[t_tbl].tspace_name
      SET tgtdb->tbl[t_tbl].tspace_name = curdb->tbl[c_tbl].tspace_name
     ELSE
      SET tgtdb->tbl[t_tbl].diff_tspace_ind = 0
     ENDIF
    ENDIF
    FOR (t_col = 1 TO tgtdb->tbl[t_tbl].tbl_col_cnt)
      SET tgtdb->tbl[t_tbl].tbl_col[t_col].cur_idx = 0
      IF ((tgtdb->tbl[t_tbl].tbl_col[t_col].data_type IN ("NUMBER", "FLOAT", "DATE"))
       AND findstring("(",tgtdb->tbl[t_tbl].tbl_col[t_col].data_default)=1)
       SET tgtdb->tbl[t_tbl].tbl_col[t_col].data_default = trim(replace(tgtdb->tbl[t_tbl].tbl_col[
         t_col].data_default,"("," ",1),3)
       SET tgtdb->tbl[t_tbl].tbl_col[t_col].data_default = trim(replace(tgtdb->tbl[t_tbl].tbl_col[
         t_col].data_default,")"," ",2),3)
      ENDIF
      IF ((tgtdb->tbl[t_tbl].tbl_col[t_col].data_default IN ("NULL", " ", "")))
       SET tgtdb->tbl[t_tbl].tbl_col[t_col].data_default = "NULL"
      ENDIF
      IF (findstring("'",tgtdb->tbl[t_tbl].tbl_col[t_col].data_default) != 1)
       SET tgtdb->tbl[t_tbl].tbl_col[t_col].data_default = cnvtupper(tgtdb->tbl[t_tbl].tbl_col[t_col]
        .data_default)
      ENDIF
      IF ((tgtdb->tbl[t_tbl].tbl_col[t_col].data_type="DATE")
       AND findstring(" ",tgtdb->tbl[t_tbl].tbl_col[t_col].data_default) > 0)
       SET tgtdb->tbl[t_tbl].tbl_col[t_col].data_default = dm_strip_char(tgtdb->tbl[t_tbl].tbl_col[
        t_col].data_default," ",0)
      ENDIF
      SET c_col = 0
      FOR (c = 1 TO curdb->tbl[c_tbl].tbl_col_cnt)
        IF ((curdb->tbl[c_tbl].tbl_col[c].col_name=tgtdb->tbl[t_tbl].tbl_col[t_col].col_name))
         SET c_col = c
         SET c = curdb->tbl[c_tbl].tbl_col_cnt
        ENDIF
      ENDFOR
      IF (c_col=0)
       SET tgtdb->tbl[t_tbl].tbl_col[t_col].new_ind = 1
       SET tgtdb->tbl[t_tbl].tbl_col[t_col].cur_idx = 0
       SET schema_diff = 1
       IF ((tgtdb->tbl[t_tbl].tbl_col[t_col].nullable="N"))
        SET tgtdb->tbl[t_tbl].tbl_col[t_col].null_to_notnull_ind = 1
        IF ((tgtdb->tbl[t_tbl].reference_ind=0))
         SET tgtdb->tbl[t_tbl].tbl_col[t_col].downtime_ind = 1
         SET schema_downtime = 1
         SET schema_uptime = 1
        ELSE
         SET schema_uptime = 1
        ENDIF
        IF ((tgtdb->tbl[t_tbl].tbl_col[t_col].data_default IN ("NULL", " ", "")))
         IF ((((tgtdb->tbl[t_tbl].tbl_col[t_col].data_type="NUMBER")) OR ((tgtdb->tbl[t_tbl].tbl_col[
         t_col].data_type="FLOAT"))) )
          SET tgtdb->tbl[t_tbl].tbl_col[t_col].data_default = "0"
         ELSEIF ((tgtdb->tbl[t_tbl].tbl_col[t_col].data_type="DATE"))
          SET tgtdb->tbl[t_tbl].tbl_col[t_col].data_default = "TO_DATE('1/1/1900','MM/DD/YYYY')"
         ELSE
          SET tgtdb->tbl[t_tbl].tbl_col[t_col].data_default = "' '"
         ENDIF
        ENDIF
       ELSE
        SET schema_uptime = 1
       ENDIF
       FOR (tc = 1 TO tgtdb->tbl[t_tbl].cons_cnt)
         IF ((tgtdb->tbl[t_tbl].cons[tc].cons_type="R")
          AND (tgtdb->tbl[t_tbl].cons[tc].parent_table IN ("PERSON", "ENCOUNTER"))
          AND (tgtdb->tbl[t_tbl].cons[tc].cons_col[1].col_name=tgtdb->tbl[t_tbl].tbl_col[t_col].
         col_name))
          SET combine_ind = 1
         ENDIF
       ENDFOR
      ELSE
       SET tgtdb->tbl[t_tbl].tbl_col[t_col].new_ind = 0
       SET tgtdb->tbl[t_tbl].tbl_col[t_col].cur_idx = c_col
       IF ((curdb->tbl[c_tbl].tbl_col[c_col].data_type != tgtdb->tbl[t_tbl].tbl_col[t_col].data_type)
       )
        IF ((((curdb->tbl[c_tbl].tbl_col[c_col].data_type="NUMBER")
         AND (tgtdb->tbl[t_tbl].tbl_col[t_col].data_type="FLOAT")) OR ((((curdb->tbl[c_tbl].tbl_col[
        c_col].data_type="VARCHAR2")
         AND (tgtdb->tbl[t_tbl].tbl_col[t_col].data_type="CHAR")) OR ((curdb->tbl[c_tbl].tbl_col[
        c_col].data_type="CHAR")
         AND (tgtdb->tbl[t_tbl].tbl_col[t_col].data_type="VARCHAR2"))) )) )
         SET tgtdb->tbl[t_tbl].tbl_col[t_col].diff_dtype_ind = 1
         SET schema_diff = 1
         SET schema_uptime = 1
        ELSE
         SET tgtdb->tbl[t_tbl].tbl_col[t_col].diff_dtype_ind = 2
         SET schema_warn = 1
        ENDIF
       ELSE
        SET tgtdb->tbl[t_tbl].tbl_col[t_col].diff_dtype_ind = 0
       ENDIF
       IF ((curdb->tbl[c_tbl].tbl_col[c_col].data_length != tgtdb->tbl[t_tbl].tbl_col[t_col].
       data_length)
        AND (((tgtdb->tbl[t_tbl].tbl_col[t_col].data_type="VARCHAR2")) OR ((((tgtdb->tbl[t_tbl].
       tbl_col[t_col].data_type="VARCHAR")) OR ((((tgtdb->tbl[t_tbl].tbl_col[t_col].data_type="CHAR")
       ) OR ((tgtdb->tbl[t_tbl].tbl_col[t_col].data_type="RAW"))) )) )) )
        IF ((curdb->tbl[c_tbl].tbl_col[c_col].data_length < tgtdb->tbl[t_tbl].tbl_col[t_col].
        data_length))
         SET tgtdb->tbl[t_tbl].tbl_col[t_col].diff_dlength_ind = 1
         SET schema_diff = 1
         SET schema_uptime = 1
        ELSE
         SET tgtdb->tbl[t_tbl].tbl_col[t_col].diff_dlength_ind = 2
         SET schema_warn = 1
        ENDIF
       ELSE
        SET tgtdb->tbl[t_tbl].tbl_col[t_col].diff_dlength_ind = 0
       ENDIF
       IF ((curdb->tbl[c_tbl].tbl_col[c_col].nullable != tgtdb->tbl[t_tbl].tbl_col[t_col].nullable))
        SET tgtdb->tbl[t_tbl].tbl_col[t_col].diff_nullable_ind = 1
        SET schema_diff = 1
        IF ((curdb->tbl[c_tbl].tbl_col[c_col].nullable="Y")
         AND (tgtdb->tbl[t_tbl].tbl_col[t_col].nullable="N"))
         SET tgtdb->tbl[t_tbl].tbl_col[t_col].null_to_notnull_ind = 1
         IF ((tgtdb->tbl[t_tbl].reference_ind=0))
          SET tgtdb->tbl[t_tbl].tbl_col[t_col].downtime_ind = 1
          SET schema_downtime = 1
          SET schema_uptime = 1
         ELSE
          SET schema_uptime = 1
         ENDIF
         IF ((tgtdb->tbl[t_tbl].tbl_col[t_col].data_default IN ("NULL", " ", "")))
          IF ((((tgtdb->tbl[t_tbl].tbl_col[t_col].data_type="NUMBER")) OR ((tgtdb->tbl[t_tbl].
          tbl_col[t_col].data_type="FLOAT"))) )
           SET tgtdb->tbl[t_tbl].tbl_col[t_col].data_default = "0"
          ELSEIF ((tgtdb->tbl[t_tbl].tbl_col[t_col].data_type="DATE"))
           SET tgtdb->tbl[t_tbl].tbl_col[t_col].data_default = "TO_DATE('1/1/1900','MM/DD/YYYY')"
          ELSE
           SET tgtdb->tbl[t_tbl].tbl_col[t_col].data_default = "' '"
          ENDIF
         ENDIF
        ELSEIF ((curdb->tbl[c_tbl].tbl_col[c_col].nullable="N")
         AND (tgtdb->tbl[t_tbl].tbl_col[t_col].nullable="Y"))
         SET tgtdb->tbl[t_tbl].tbl_col[t_col].null_to_notnull_ind = 0
         SET pk_col_ind = 0
         FOR (c_cons = 1 TO curdb->tbl[c_tbl].cons_cnt)
           IF ((curdb->tbl[c_tbl].cons[c_cons].cons_type="P"))
            FOR (ci = 1 TO curdb->tbl[c_tbl].cons[c_cons].cons_col_cnt)
              IF ((curdb->tbl[c_tbl].cons[c_cons].cons_col[ci].col_name=curdb->tbl[c_tbl].tbl_col[
              c_col].col_name))
               SET pk_col_ind = ci
              ENDIF
            ENDFOR
           ENDIF
         ENDFOR
         IF (pk_col_ind > 0
          AND (tgtdb->tbl[t_tbl].reference_ind=0))
          SET tgtdb->tbl[t_tbl].tbl_col[t_col].downtime_ind = 1
          SET schema_downtime = 1
         ELSE
          SET tgtdb->tbl[t_tbl].tbl_col[t_col].downtime_ind = 0
          SET schema_uptime = 1
         ENDIF
        ENDIF
       ELSE
        SET tgtdb->tbl[t_tbl].tbl_col[t_col].diff_nullable_ind = 0
       ENDIF
       IF ((curdb->tbl[c_tbl].tbl_col[c_col].data_type IN ("NUMBER", "FLOAT", "DATE"))
        AND findstring("(",curdb->tbl[c_tbl].tbl_col[c_col].data_default)=1)
        SET curdb->tbl[c_tbl].tbl_col[c_col].data_default = trim(replace(curdb->tbl[c_tbl].tbl_col[
          c_col].data_default,"("," ",1),3)
        SET curdb->tbl[c_tbl].tbl_col[c_col].data_default = trim(replace(curdb->tbl[c_tbl].tbl_col[
          c_col].data_default,")"," ",2),3)
       ENDIF
       IF ((curdb->tbl[c_tbl].tbl_col[c_col].data_default IN ("NULL", " ", "")))
        SET curdb->tbl[c_tbl].tbl_col[c_col].data_default = "NULL"
       ENDIF
       IF (findstring("'",curdb->tbl[c_tbl].tbl_col[c_col].data_default) != 1)
        SET curdb->tbl[c_tbl].tbl_col[c_col].data_default = cnvtupper(curdb->tbl[c_tbl].tbl_col[c_col
         ].data_default)
       ENDIF
       IF ((curdb->tbl[c_tbl].tbl_col[c_col].data_type="DATE")
        AND findstring(" ",curdb->tbl[c_tbl].tbl_col[c_col].data_default) > 0)
        SET curdb->tbl[c_tbl].tbl_col[c_col].data_default = dm_strip_char(curdb->tbl[c_tbl].tbl_col[
         c_col].data_default," ",0)
       ENDIF
       SET num_type = 0
       SET t_num_def = 0.000
       SET c_num_def = 0.000
       IF ((tgtdb->tbl[t_tbl].tbl_col[t_col].data_type IN ("NUMBER", "FLOAT")))
        SET t_num_def = cnvtreal(tgtdb->tbl[t_tbl].tbl_col[t_col].data_default)
        SET num_type = 1
       ENDIF
       IF ((curdb->tbl[c_tbl].tbl_col[c_col].data_type IN ("NUMBER", "FLOAT")))
        SET c_num_def = cnvtreal(curdb->tbl[c_tbl].tbl_col[c_col].data_default)
       ENDIF
       IF (num_type=1
        AND (tgtdb->tbl[t_tbl].tbl_col[t_col].data_default != "NULL")
        AND (curdb->tbl[c_tbl].tbl_col[c_col].data_default != "NULL"))
        IF (c_num_def != t_num_def)
         SET tgtdb->tbl[t_tbl].tbl_col[t_col].diff_default_ind = 1
         SET schema_diff = 1
         SET schema_uptime = 1
        ELSE
         SET tgtdb->tbl[t_tbl].tbl_col[t_col].diff_default_ind = 0
        ENDIF
       ELSEIF ((curdb->tbl[c_tbl].tbl_col[c_col].data_default != tgtdb->tbl[t_tbl].tbl_col[t_col].
       data_default))
        IF ((tgtdb->tbl[t_tbl].tbl_col[t_col].nullable="N")
         AND (tgtdb->tbl[t_tbl].tbl_col[t_col].data_default="NULL"))
         SET tgtdb->tbl[t_tbl].tbl_col[t_col].diff_default_ind = 0
        ELSE
         SET tgtdb->tbl[t_tbl].tbl_col[t_col].diff_default_ind = 1
         SET schema_diff = 1
         SET schema_uptime = 1
        ENDIF
       ELSE
        SET tgtdb->tbl[t_tbl].tbl_col[t_col].diff_default_ind = 0
       ENDIF
      ENDIF
    ENDFOR
    FOR (t_ind = 1 TO tgtdb->tbl[t_tbl].ind_cnt)
      SET tgtdb->tbl[t_tbl].ind[t_ind].cur_idx = 0
      SET fnd_ind = 0
      SET c_ind = 0
      FOR (i = 1 TO curdb->tbl[c_tbl].ind_cnt)
        IF ((curdb->tbl[c_tbl].ind[i].ind_name=tgtdb->tbl[t_tbl].ind[t_ind].ind_name))
         SET c_ind = i
         SET i = curdb->tbl[c_tbl].ind_cnt
        ENDIF
      ENDFOR
      SET reorg_ind = 0
      IF (c_ind=0)
       FOR (i = 1 TO curdb->tbl[c_tbl].ind_cnt)
         IF ((curdb->tbl[c_tbl].ind[i].ind_name=build(tgtdb->tbl[t_tbl].ind[t_ind].ind_name,"$C")))
          SET c_ind = i
          SET i = curdb->tbl[c_tbl].ind_cnt
          SET reorg_ind = 1
         ENDIF
       ENDFOR
      ENDIF
      FOR (fi = 1 TO curdb->tbl[c_tbl].ind_cnt)
       SET match_cols = 0
       IF ((curdb->tbl[c_tbl].ind[fi].ind_col_cnt=tgtdb->tbl[t_tbl].ind[t_ind].ind_col_cnt))
        FOR (ci = 1 TO curdb->tbl[c_tbl].ind[fi].ind_col_cnt)
          IF ((curdb->tbl[c_tbl].ind[fi].ind_col[ci].col_name=tgtdb->tbl[t_tbl].ind[t_ind].ind_col[ci
          ].col_name))
           SET match_cols = (match_cols+ 1)
          ELSE
           SET ci = curdb->tbl[c_tbl].ind[fi].ind_col_cnt
          ENDIF
        ENDFOR
        IF ((match_cols=tgtdb->tbl[t_tbl].ind[t_ind].ind_col_cnt))
         SET fnd_ind = fi
         SET fi = curdb->tbl[c_tbl].ind_cnt
        ENDIF
       ENDIF
      ENDFOR
      IF (c_ind > 0
       AND fnd_ind > 0
       AND c_ind != fnd_ind)
       SET curdb->tbl[c_tbl].ind[fnd_ind].drop_ind = 1
      ENDIF
      IF (c_ind=0
       AND fnd_ind > 0)
       SET c_ind = fnd_ind
      ENDIF
      IF (c_ind=0)
       SET tgtdb->tbl[t_tbl].ind[t_ind].new_ind = 1
       SET tgtdb->tbl[t_tbl].ind[t_ind].cur_idx = 0
       SET tgtdb->tbl[t_tbl].ind[t_ind].build_ind = 1
       IF ((tgtdb->tbl[t_tbl].reference_ind=0))
        SET tgtdb->tbl[t_tbl].ind[t_ind].downtime_ind = 1
        SET schema_downtime = 1
       ELSE
        SET schema_uptime = 1
       ENDIF
       SET schema_diff = 1
      ELSE
       SET tgtdb->tbl[t_tbl].ind[t_ind].new_ind = 0
       SET tgtdb->tbl[t_tbl].ind[t_ind].cur_idx = c_ind
       IF ( NOT (substring(1,2,curdb->tbl[c_tbl].ind[c_ind].tspace_name) IN ("D_", "I_")))
        SET curdb->tbl[c_tbl].ind[c_ind].bad_tspace_ind = 1
        SET schema_warn = 1
       ELSE
        SET curdb->tbl[c_tbl].ind[c_ind].bad_tspace_ind = 0
        IF ((tgtdb->tbl[t_tbl].ind[t_ind].tspace_name != curdb->tbl[c_tbl].ind[c_ind].tspace_name))
         SET tgtdb->tbl[t_tbl].ind[t_ind].diff_tspace_ind = 1
         SET tgtdb->tbl[t_tbl].ind[t_ind].tgt_tspace_name = tgtdb->tbl[t_tbl].ind[t_ind].tspace_name
         SET tgtdb->tbl[t_tbl].ind[t_ind].tspace_name = curdb->tbl[c_tbl].ind[c_ind].tspace_name
        ELSE
         SET tgtdb->tbl[t_tbl].ind[t_ind].diff_tspace_ind = 0
        ENDIF
       ENDIF
       IF ((curdb->tbl[c_tbl].ind[c_ind].ind_name != tgtdb->tbl[t_tbl].ind[t_ind].ind_name)
        AND reorg_ind=0)
        SET tgtdb->tbl[t_tbl].ind[t_ind].diff_name_ind = 1
       ELSE
        SET tgtdb->tbl[t_tbl].ind[t_ind].diff_name_ind = 0
       ENDIF
       IF ((curdb->tbl[c_tbl].ind[c_ind].unique_ind != tgtdb->tbl[t_tbl].ind[t_ind].unique_ind))
        SET tgtdb->tbl[t_tbl].ind[t_ind].diff_unique_ind = 1
       ELSE
        SET tgtdb->tbl[t_tbl].ind[t_ind].diff_unique_ind = 0
       ENDIF
       IF ((curdb->tbl[c_tbl].ind[c_ind].ind_col_cnt != tgtdb->tbl[t_tbl].ind[t_ind].ind_col_cnt))
        SET tgtdb->tbl[t_tbl].ind[t_ind].diff_col_ind = 1
       ELSE
        SET match_cols = 0
        FOR (ci = 1 TO curdb->tbl[c_tbl].ind[c_ind].ind_col_cnt)
          IF ((curdb->tbl[c_tbl].ind[c_ind].ind_col[ci].col_name=tgtdb->tbl[t_tbl].ind[t_ind].
          ind_col[ci].col_name))
           SET match_cols = (match_cols+ 1)
          ELSE
           SET ci = curdb->tbl[c_tbl].ind[c_ind].ind_col_cnt
          ENDIF
        ENDFOR
        IF ((match_cols != tgtdb->tbl[t_tbl].ind[t_ind].ind_col_cnt))
         SET tgtdb->tbl[t_tbl].ind[t_ind].diff_col_ind = 1
        ELSE
         SET tgtdb->tbl[t_tbl].ind[t_ind].diff_col_ind = 0
        ENDIF
       ENDIF
       IF ((((tgtdb->tbl[t_tbl].ind[t_ind].diff_name_ind=1)) OR ((((tgtdb->tbl[t_tbl].ind[t_ind].
       diff_unique_ind=1)) OR ((tgtdb->tbl[t_tbl].ind[t_ind].diff_col_ind=1))) )) )
        SET tgtdb->tbl[t_tbl].ind[t_ind].build_ind = 1
        SET schema_diff = 1
        SET curdb->tbl[c_tbl].ind[c_ind].drop_ind = 1
        IF ((tgtdb->tbl[t_tbl].reference_ind=0))
         SET tgtdb->tbl[t_tbl].ind[t_ind].downtime_ind = 1
         SET curdb->tbl[c_tbl].ind[c_ind].downtime_ind = 1
         SET schema_downtime = 1
        ELSE
         SET schema_uptime = 1
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
    FOR (t_cons = 1 TO tgtdb->tbl[t_tbl].cons_cnt)
      SET tgtdb->tbl[t_tbl].cons[t_cons].cur_idx = 0
      SET t_cons_type = 0
      SET t_parent_table = fillstring(30," ")
      IF ((tgtdb->tbl[t_tbl].cons[t_cons].cons_type IN ("P", "U")))
       SET t_cons_type = 1
       SET t_parent_table = "N/A"
      ELSEIF ((tgtdb->tbl[t_tbl].cons[t_cons].cons_type="R"))
       SET t_cons_type = 2
       SET t_parent_table = tgtdb->tbl[t_tbl].cons[t_cons].parent_table
      ENDIF
      SET fnd_cons = 0
      SET c_cons = 0
      FOR (c = 1 TO curdb->tbl[c_tbl].cons_cnt)
        IF ((curdb->tbl[c_tbl].cons[c].cons_name=tgtdb->tbl[t_tbl].cons[t_cons].cons_name))
         SET c_cons = c
         SET c = curdb->tbl[c_tbl].cons_cnt
        ENDIF
      ENDFOR
      SET reorg_ind = 0
      IF (c_cons=0)
       FOR (i = 1 TO curdb->tbl[c_tbl].cons_cnt)
         IF ((curdb->tbl[c_tbl].cons[i].cons_name=build(tgtdb->tbl[t_tbl].cons[t_cons].cons_name,"$C"
          )))
          SET c_cons = i
          SET i = curdb->tbl[c_tbl].cons_cnt
          SET reorg_ind = 1
         ENDIF
       ENDFOR
      ENDIF
      FOR (fi = 1 TO curdb->tbl[c_tbl].cons_cnt)
        SET c_cons_type = 0
        SET c_parent_table = fillstring(30," ")
        IF ((curdb->tbl[c_tbl].cons[fi].cons_type IN ("P", "U")))
         SET c_cons_type = 1
         SET c_parent_table = "N/A"
        ELSEIF ((curdb->tbl[c_tbl].cons[fi].cons_type="R"))
         SET c_cons_type = 2
         SET c_parent_table = curdb->tbl[c_tbl].cons[fi].parent_table
        ENDIF
        SET match_cols = 0
        IF ((curdb->tbl[c_tbl].cons[fi].cons_col_cnt=tgtdb->tbl[t_tbl].cons[t_cons].cons_col_cnt)
         AND t_cons_type=c_cons_type
         AND t_parent_table=c_parent_table)
         FOR (ci = 1 TO curdb->tbl[c_tbl].cons[fi].cons_col_cnt)
           IF ((curdb->tbl[c_tbl].cons[fi].cons_col[ci].col_name=tgtdb->tbl[t_tbl].cons[t_cons].
           cons_col[ci].col_name))
            SET match_cols = (match_cols+ 1)
           ELSE
            SET ci = curdb->tbl[c_tbl].cons[fi].cons_col_cnt
           ENDIF
         ENDFOR
         IF ((match_cols=tgtdb->tbl[t_tbl].cons[t_cons].cons_col_cnt))
          SET fnd_cons = fi
          SET fi = curdb->tbl[c_tbl].cons_cnt
         ENDIF
        ENDIF
      ENDFOR
      IF (c_cons > 0
       AND fnd_cons > 0
       AND c_cons != fnd_cons)
       SET curdb->tbl[c_tbl].cons[fnd_cons].drop_ind = 1
      ENDIF
      IF (c_cons=0
       AND fnd_cons > 0)
       SET c_cons = fnd_cons
      ENDIF
      IF (c_cons=0)
       SET tgtdb->tbl[t_tbl].cons[t_cons].new_ind = 1
       SET tgtdb->tbl[t_tbl].cons[t_cons].cur_idx = 0
       SET tgtdb->tbl[t_tbl].cons[t_cons].build_ind = 1
       IF ((tgtdb->tbl[t_tbl].reference_ind=0)
        AND t_cons_type=1)
        SET tgtdb->tbl[t_tbl].cons[t_cons].downtime_ind = 1
        SET schema_downtime = 1
       ELSE
        SET schema_uptime = 1
       ENDIF
       SET schema_diff = 1
      ELSE
       SET tgtdb->tbl[t_tbl].cons[t_cons].new_ind = 0
       SET tgtdb->tbl[t_tbl].cons[t_cons].cur_idx = c_cons
       IF ((curdb->tbl[c_tbl].cons[c_cons].cons_name != tgtdb->tbl[t_tbl].cons[t_cons].cons_name)
        AND reorg_ind=0)
        SET tgtdb->tbl[t_tbl].cons[t_cons].diff_name_ind = 1
       ELSE
        SET tgtdb->tbl[t_tbl].cons[t_cons].diff_name_ind = 0
       ENDIF
       IF ((curdb->tbl[c_tbl].cons[c_cons].status_ind != tgtdb->tbl[t_tbl].cons[t_cons].status_ind))
        SET tgtdb->tbl[t_tbl].cons[t_cons].diff_status_ind = 1
       ELSE
        SET tgtdb->tbl[t_tbl].cons[t_cons].diff_status_ind = 0
       ENDIF
       IF ((curdb->tbl[c_tbl].cons[c_cons].parent_table != tgtdb->tbl[t_tbl].cons[t_cons].
       parent_table)
        AND (tgtdb->tbl[t_tbl].cons[t_cons].cons_type="R"))
        SET tgtdb->tbl[t_tbl].cons[t_cons].diff_parent_ind = 1
       ELSE
        SET tgtdb->tbl[t_tbl].cons[t_cons].diff_parent_ind = 0
       ENDIF
       IF ((curdb->tbl[c_tbl].cons[c_cons].cons_col_cnt != tgtdb->tbl[t_tbl].cons[t_cons].
       cons_col_cnt))
        SET tgtdb->tbl[t_tbl].cons[t_cons].diff_col_ind = 1
       ELSE
        SET match_cols = 0
        FOR (ci = 1 TO curdb->tbl[c_tbl].cons[c_cons].cons_col_cnt)
          IF ((curdb->tbl[c_tbl].cons[c_cons].cons_col[ci].col_name=tgtdb->tbl[t_tbl].cons[t_cons].
          cons_col[ci].col_name))
           SET match_cols = (match_cols+ 1)
          ELSE
           SET ci = curdb->tbl[c_tbl].cons[c_cons].cons_col_cnt
          ENDIF
        ENDFOR
        IF ((match_cols != tgtdb->tbl[t_tbl].cons[t_cons].cons_col_cnt))
         SET tgtdb->tbl[t_tbl].cons[t_cons].diff_col_ind = 1
        ELSE
         SET tgtdb->tbl[t_tbl].cons[t_cons].diff_col_ind = 0
        ENDIF
       ENDIF
       IF ((((tgtdb->tbl[t_tbl].cons[t_cons].diff_name_ind=1)) OR ((((tgtdb->tbl[t_tbl].cons[t_cons].
       diff_parent_ind=1)) OR ((tgtdb->tbl[t_tbl].cons[t_cons].diff_col_ind=1))) )) )
        SET tgtdb->tbl[t_tbl].cons[t_cons].build_ind = 1
        SET schema_diff = 1
        SET curdb->tbl[c_tbl].cons[c_cons].drop_ind = 1
        IF ((tgtdb->tbl[t_tbl].reference_ind=0)
         AND t_cons_type=1)
         SET tgtdb->tbl[t_tbl].cons[t_cons].downtime_ind = 1
         SET curdb->tbl[c_tbl].cons[c_cons].downtime_ind = 1
         SET schema_downtime = 1
        ELSE
         SET schema_uptime = 1
        ENDIF
       ENDIF
       IF ((tgtdb->tbl[t_tbl].cons[t_cons].diff_status_ind=1))
        SET schema_diff = 1
        SET schema_uptime = 1
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   IF (schema_diff=1)
    SET tgtdb->tbl[t_tbl].diff_ind = 1
   ENDIF
   IF (schema_warn=1)
    SET tgtdb->tbl[t_tbl].warn_ind = 1
   ENDIF
   IF (combine_ind=1
    AND (fs_proc->inhouse_ind=0))
    SET tgtdb->tbl[t_tbl].combine_ind = 1
    FOR (t_ind = 1 TO tgtdb->tbl[t_tbl].ind_cnt)
      IF ((tgtdb->tbl[t_tbl].ind[t_ind].build_ind=1))
       SET tgtdb->tbl[t_tbl].ind[t_ind].downtime_ind = 1
       IF (c_tbl > 0
        AND (tgtdb->tbl[t_tbl].ind[t_ind].cur_idx > 0))
        SET cdb_idx = tgtdb->tbl[t_tbl].ind[t_ind].cur_idx
        SET curdb->tbl[c_tbl].ind[cdb_idx].downtime_ind = 1
       ENDIF
      ENDIF
    ENDFOR
    FOR (t_cons = 1 TO tgtdb->tbl[t_tbl].cons_cnt)
      IF ((tgtdb->tbl[t_tbl].cons[t_cons].build_ind=1))
       SET tgtdb->tbl[t_tbl].cons[t_cons].downtime_ind = 1
       IF (c_tbl > 0
        AND (tgtdb->tbl[t_tbl].cons[t_cons].cur_idx > 0))
        SET cdb_idx = tgtdb->tbl[t_tbl].cons[t_cons].cur_idx
        SET curdb->tbl[c_tbl].cons[cdb_idx].downtime_ind = 1
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   IF ((((tgtdb->tbl[t_tbl].diff_ind=1)) OR ((tgtdb->tbl[t_tbl].new_ind=1))) )
    SET tgtdb->diff_ind = 1
   ENDIF
   IF ((tgtdb->tbl[t_tbl].warn_ind=1))
    SET tgtdb->warn_ind = 1
   ENDIF
   IF ((tgtdb->tbl[t_tbl].downtime_ind=1))
    SET tgtdb->downtime_ind = 1
   ENDIF
 ENDFOR
 FOR (c_tbl = 1 TO curdb->tbl_cnt)
   FOR (c_ind = 1 TO curdb->tbl[c_tbl].ind_cnt)
     IF ((curdb->tbl[c_tbl].ind[c_ind].drop_ind=1))
      SET pk_name = fillstring(30," ")
      SET pk_type = fillstring(1," ")
      SET fnd_pk = 0
      FOR (cc = 1 TO curdb->tbl[c_tbl].cons_cnt)
        IF ((curdb->tbl[c_tbl].cons[cc].cons_type IN ("P", "U"))
         AND (curdb->tbl[c_tbl].cons[cc].cons_col_cnt=curdb->tbl[c_tbl].ind[c_ind].ind_col_cnt))
         SET match_cols = 0
         FOR (ci = 1 TO curdb->tbl[c_tbl].cons[cc].cons_col_cnt)
           IF ((curdb->tbl[c_tbl].cons[cc].cons_col[ci].col_name=curdb->tbl[c_tbl].ind[c_ind].
           ind_col[ci].col_name))
            SET match_cols = (match_cols+ 1)
           ELSE
            SET ci = curdb->tbl[c_tbl].cons[cc].cons_col_cnt
           ENDIF
         ENDFOR
         IF ((match_cols=curdb->tbl[c_tbl].ind[c_ind].ind_col_cnt))
          SET fnd_pk = cc
          SET cc = curdb->tbl[c_tbl].cons_cnt
         ENDIF
        ENDIF
      ENDFOR
      IF (fnd_pk > 0)
       SET curdb->tbl[c_tbl].cons[fnd_pk].drop_ind = 1
       IF ((curdb->tbl[c_tbl].ind[c_ind].downtime_ind=1))
        SET curdb->tbl[c_tbl].cons[fnd_pk].downtime_ind = 1
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
 ENDFOR
 FOR (c_tbl = 1 TO curdb->tbl_cnt)
   FOR (c_cons = 1 TO curdb->tbl[c_tbl].cons_cnt)
     IF ((curdb->tbl[c_tbl].cons[c_cons].drop_ind=1)
      AND (curdb->tbl[c_tbl].cons[c_cons].cons_type="P"))
      SET pk_name = fillstring(30," ")
      SET pk_name = curdb->tbl[c_tbl].cons[c_cons].cons_name
      SET pk_downtime_ind = curdb->tbl[c_tbl].cons[c_cons].downtime_ind
      SET fk_cnt = 0
      FOR (ti = 1 TO curdb->tbl_cnt)
        FOR (ci = 1 TO curdb->tbl[ti].cons_cnt)
          IF ((curdb->tbl[ti].cons[ci].cons_type="R")
           AND (curdb->tbl[ti].cons[ci].r_constraint_name=pk_name))
           SET fnd_fk = 0
           FOR (fi = 1 TO curdb->tbl[c_tbl].cons[c_cons].fk_cnt)
             IF ((curdb->tbl[c_tbl].cons[c_cons].fk[fi].tbl_name=curdb->tbl[ti].tbl_name)
              AND (curdb->tbl[c_tbl].cons[c_cons].fk[fi].cons_name=curdb->tbl[ti].cons[ci].cons_name)
             )
              SET fnd_fk = fi
              SET fi = curdb->tbl[c_tbl].cons[c_cons].fk_cnt
             ENDIF
           ENDFOR
           IF (fnd_fk=0)
            SET curdb->tbl[c_tbl].cons[c_cons].fk_cnt = (curdb->tbl[c_tbl].cons[c_cons].fk_cnt+ 1)
            SET fk_cnt = curdb->tbl[c_tbl].cons[c_cons].fk_cnt
            SET stat = alterlist(curdb->tbl[c_tbl].cons[c_cons].fk,fk_cnt)
            SET curdb->tbl[c_tbl].cons[c_cons].fk[fk_cnt].tbl_name = curdb->tbl[ti].tbl_name
            SET curdb->tbl[c_tbl].cons[c_cons].fk[fk_cnt].cons_name = curdb->tbl[ti].cons[ci].
            cons_name
            SET curdb->tbl[c_tbl].cons[c_cons].fk[fk_cnt].tbl_ndx = ti
            SET curdb->tbl[c_tbl].cons[c_cons].fk[fk_cnt].cons_ndx = ci
           ENDIF
          ENDIF
        ENDFOR
      ENDFOR
     ENDIF
   ENDFOR
 ENDFOR
 FOR (t_tbl = 1 TO tgtdb->tbl_cnt)
   FOR (t_ind = 1 TO tgtdb->tbl[t_tbl].ind_cnt)
     IF ((tgtdb->tbl[t_tbl].ind[t_ind].build_ind=1)
      AND (tgtdb->tbl[t_tbl].ind[t_ind].unique_ind=1))
      SET t_cons = 0
      FOR (ti = 1 TO tgtdb->tbl[t_tbl].cons_cnt)
       SET match_cols = 0
       IF ((tgtdb->tbl[t_tbl].ind[t_ind].ind_col_cnt=tgtdb->tbl[t_tbl].cons[ti].cons_col_cnt)
        AND (tgtdb->tbl[t_tbl].cons[ti].cons_type IN ("P", "U")))
        FOR (ci = 1 TO tgtdb->tbl[t_tbl].ind[t_ind].ind_col_cnt)
          IF ((tgtdb->tbl[t_tbl].ind[t_ind].ind_col[ci].col_name=tgtdb->tbl[t_tbl].cons[ti].cons_col[
          ci].col_name))
           SET match_cols = (match_cols+ 1)
          ELSE
           SET ci = tgtdb->tbl[t_tbl].ind[t_ind].ind_col_cnt
          ENDIF
        ENDFOR
        IF ((match_cols=tgtdb->tbl[t_tbl].ind[t_ind].ind_col_cnt))
         SET t_cons = ti
         SET ti = tgtdb->tbl[t_tbl].cons_cnt
        ENDIF
       ENDIF
      ENDFOR
      IF (t_cons > 0)
       IF ((tgtdb->tbl[t_tbl].cons[t_cons].build_ind=0))
        SET tgtdb->tbl[t_tbl].cons[t_cons].diff_ind_ind = 1
        SET tgtdb->tbl[t_tbl].cons[t_cons].build_ind = 1
        IF ((tgtdb->tbl[t_tbl].reference_ind=0))
         SET tgtdb->tbl[t_tbl].cons[t_cons].downtime_ind = 1
        ELSE
         SET tgtdb->tbl[t_tbl].cons[t_cons].downtime_ind = 0
        ENDIF
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
 ENDFOR
 FOR (t_tbl = 1 TO tgtdb->tbl_cnt)
   FOR (t_cons = 1 TO tgtdb->tbl[t_tbl].cons_cnt)
     IF ((tgtdb->tbl[t_tbl].cons[t_cons].cons_type IN ("P", "U"))
      AND (tgtdb->tbl[t_tbl].cons[t_cons].build_ind=1))
      SET pk_name = fillstring(30," ")
      SET pk_type = fillstring(1," ")
      SET pk_downtime_ind = 0
      SET pk_name = tgtdb->tbl[t_tbl].cons[t_cons].cons_name
      SET pk_type = tgtdb->tbl[t_tbl].cons[t_cons].cons_type
      SET pk_downtime_ind = tgtdb->tbl[t_tbl].cons[t_cons].downtime_ind
      SET fk_cnt = 0
      SET t_ind = 0
      FOR (ti = 1 TO tgtdb->tbl[t_tbl].ind_cnt)
       SET match_cols = 0
       IF ((tgtdb->tbl[t_tbl].cons[t_cons].cons_col_cnt=tgtdb->tbl[t_tbl].ind[ti].ind_col_cnt)
        AND (tgtdb->tbl[t_tbl].ind[ti].unique_ind=1))
        FOR (ci = 1 TO tgtdb->tbl[t_tbl].cons[t_cons].cons_col_cnt)
          IF ((tgtdb->tbl[t_tbl].cons[t_cons].cons_col[ci].col_name=tgtdb->tbl[t_tbl].ind[ti].
          ind_col[ci].col_name))
           SET match_cols = (match_cols+ 1)
          ELSE
           SET ci = tgtdb->tbl[t_tbl].cons[t_cons].cons_col_cnt
          ENDIF
        ENDFOR
        IF ((match_cols=tgtdb->tbl[t_tbl].cons[t_cons].cons_col_cnt))
         SET t_ind = ti
         SET ti = tgtdb->tbl[t_tbl].ind_cnt
        ENDIF
       ENDIF
      ENDFOR
      IF (t_ind > 0)
       IF ((tgtdb->tbl[t_tbl].ind[t_ind].build_ind=0))
        SET tgtdb->tbl[t_tbl].ind[t_ind].diff_cons_ind = 1
        SET tgtdb->tbl[t_tbl].ind[t_ind].build_ind = 1
        IF ((tgtdb->tbl[t_tbl].reference_ind=0))
         SET tgtdb->tbl[t_tbl].ind[t_ind].downtime_ind = 1
        ELSE
         SET tgtdb->tbl[t_tbl].ind[t_ind].downtime_ind = 0
        ENDIF
       ENDIF
      ENDIF
      IF (pk_type="P")
       FOR (ti = 1 TO tgtdb->tbl_cnt)
         FOR (ci = 1 TO tgtdb->tbl[ti].cons_cnt)
           IF ((tgtdb->tbl[ti].cons[ci].cons_type="R")
            AND (tgtdb->tbl[ti].cons[ci].r_constraint_name=pk_name))
            SET fnd_fk = 0
            FOR (fi = 1 TO tgtdb->tbl[t_tbl].cons[t_cons].fk_cnt)
              IF ((tgtdb->tbl[t_tbl].cons[t_cons].fk[fi].tbl_ndx=ti)
               AND (tgtdb->tbl[t_tbl].cons[t_cons].fk[fi].cons_ndx=ci))
               SET fnd_fk = fi
               SET fi = tgtdb->tbl[t_tbl].cons[t_cons].fk_cnt
              ENDIF
            ENDFOR
            IF (fnd_fk=0)
             SET fk_cnt = (fk_cnt+ 1)
             SET tgtdb->tbl[t_tbl].cons[t_cons].fk_cnt = fk_cnt
             SET stat = alterlist(tgtdb->tbl[t_tbl].cons[t_cons].fk,fk_cnt)
             SET tgtdb->tbl[t_tbl].cons[t_cons].fk[fk_cnt].tbl_ndx = ti
             SET tgtdb->tbl[t_tbl].cons[t_cons].fk[fk_cnt].cons_ndx = ci
             IF (pk_downtime_ind=1)
              SET tgtdb->tbl[ti].cons[ci].downtime_ind = 1
              SET tgtdb->tbl[ti].downtime_ind = 1
             ENDIF
            ENDIF
           ENDIF
         ENDFOR
       ENDFOR
      ENDIF
     ENDIF
   ENDFOR
 ENDFOR
 FOR (t_tbl = 1 TO tgtdb->tbl_cnt)
   SET tgtdb->tbl[t_tbl].downtime_ind = 0
   SET tgtdb->tbl[t_tbl].uptime_ind = 0
   IF ((tgtdb->tbl[t_tbl].combine_ind=1))
    SET tgtdb->tbl[t_tbl].downtime_ind = 1
    SET tgtdb->tbl[t_tbl].uptime_ind = 0
   ELSE
    IF ((tgtdb->tbl[t_tbl].new_ind=1))
     SET tgtdb->tbl[t_tbl].uptime_ind = 1
    ELSE
     FOR (t_col = 1 TO tgtdb->tbl[t_tbl].tbl_col_cnt)
       IF ((tgtdb->tbl[t_tbl].tbl_col[t_col].new_ind=1))
        IF ((tgtdb->tbl[t_tbl].tbl_col[t_col].downtime_ind=1))
         SET tgtdb->tbl[t_tbl].downtime_ind = 1
         SET tgtdb->tbl[t_tbl].uptime_ind = 1
        ELSE
         SET tgtdb->tbl[t_tbl].uptime_ind = 1
        ENDIF
       ELSE
        IF ((((tgtdb->tbl[t_tbl].tbl_col[t_col].diff_dtype_ind=1)) OR ((((tgtdb->tbl[t_tbl].tbl_col[
        t_col].diff_dlength_ind=1)) OR ((tgtdb->tbl[t_tbl].tbl_col[t_col].diff_default_ind=1))) )) )
         SET tgtdb->tbl[t_tbl].uptime_ind = 1
        ENDIF
        IF ((tgtdb->tbl[t_tbl].tbl_col[t_col].diff_nullable_ind=1))
         IF ((tgtdb->tbl[t_tbl].tbl_col[t_col].null_to_notnull_ind=1))
          IF ((tgtdb->tbl[t_tbl].tbl_col[t_col].downtime_ind=1))
           SET tgtdb->tbl[t_tbl].downtime_ind = 1
           SET tgtdb->tbl[t_tbl].uptime_ind = 1
          ELSE
           SET tgtdb->tbl[t_tbl].uptime_ind = 1
          ENDIF
         ELSE
          IF ((tgtdb->tbl[t_tbl].tbl_col[t_col].downtime_ind=1))
           SET tgtdb->tbl[t_tbl].downtime_ind = 1
          ELSE
           SET tgtdb->tbl[t_tbl].uptime_ind = 1
          ENDIF
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
     FOR (t_ind = 1 TO tgtdb->tbl[t_tbl].ind_cnt)
       IF ((tgtdb->tbl[t_tbl].ind[t_ind].build_ind=1))
        IF ((tgtdb->tbl[t_tbl].ind[t_ind].downtime_ind=1))
         SET tgtdb->tbl[t_tbl].downtime_ind = 1
        ELSE
         SET tgtdb->tbl[t_tbl].uptime_ind = 1
        ENDIF
       ENDIF
     ENDFOR
     FOR (t_cons = 1 TO tgtdb->tbl[t_tbl].cons_cnt)
       IF ((tgtdb->tbl[t_tbl].cons[t_cons].build_ind=1))
        IF ((tgtdb->tbl[t_tbl].cons[t_cons].downtime_ind=1))
         SET tgtdb->tbl[t_tbl].downtime_ind = 1
        ELSE
         SET tgtdb->tbl[t_tbl].uptime_ind = 1
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
   IF ((tgtdb->tbl[t_tbl].downtime_ind=1))
    SET tgtdb->downtime_ind = 1
   ENDIF
 ENDFOR
 EXECUTE dm_get_target_tspace
 FOR (t_tsp = 1 TO tgtdb->tspace_cnt)
   SET c_tsp = 0
   FOR (ci = 1 TO curdb->tspace_cnt)
     IF ((curdb->tspace[ci].tspace_name=tgtdb->tspace[t_tsp].tspace_name))
      SET c_tsp = ci
      SET ci = curdb->tspace_cnt
     ENDIF
   ENDFOR
   IF (c_tsp=0)
    SET tgtdb->tspace[t_tsp].new_ind = 1
    SET tgtdb->tspace[t_tsp].cur_idx = 0
   ELSE
    SET tgtdb->tspace[t_tsp].new_ind = 0
    SET tgtdb->tspace[t_tsp].cur_idx = c_tsp
   ENDIF
 ENDFOR
 IF ((fs_proc->ocd_ind=0))
  FOR (t_tbl = 1 TO tgtdb->tbl_cnt)
    SET tgtdb->tbl[t_tbl].zero_row_ind = 0
    FREE RECORD zrow_reply
    RECORD zrow_reply(
      1 status = c1
      1 zero_row_ind = i2
    )
    EXECUTE dm_chk_for_zero_row tgtdb->tbl[t_tbl].tbl_name
    IF ((zrow_reply->status="S"))
     SET tgtdb->tbl[t_tbl].zero_row_ind = zrow_reply->zero_row_ind
    ENDIF
    SET tgtdb->tbl[t_tbl].active_trigger_ind = 0
    FREE RECORD act_reply
    RECORD act_reply(
      1 status = c1
      1 active_trigger_ind = i2
    )
    EXECUTE dm_chk_for_active_trigger tgtdb->tbl[t_tbl].tbl_name
    IF ((act_reply->status="S"))
     SET tgtdb->tbl[t_tbl].active_trigger_ind = act_reply->active_trigger_ind
    ENDIF
  ENDFOR
  EXECUTE dm_chk_for_synonym "ALLTABLES"
 ENDIF
 SUBROUTINE dm_strip_char(dsc_orig_str,dsc_strip_char,dsc_strip_mode)
   FREE RECORD dsc_str
   RECORD dsc_str(
     1 dsc_target_str = vc
   )
   SET dsc_orig_len = 0
   SET dsc_orig_len = textlen(dsc_orig_str)
   SET dsc_str->dsc_target_str = fillstring(value(dsc_orig_len)," ")
   SET dsc_target_char = " "
   SET dsc_first_char = 1
   FOR (dsc_pos = 1 TO dsc_orig_len)
    SET dsc_target_char = substring(dsc_pos,1,dsc_orig_str)
    IF (findstring(dsc_target_char,dsc_strip_char)=0)
     IF (dsc_first_char=1)
      SET dsc_str->dsc_target_str = notrim(dsc_target_char)
      SET dsc_first_char = 0
     ELSE
      SET dsc_str->dsc_target_str = notrim(concat(dsc_str->dsc_target_str,dsc_target_char))
     ENDIF
    ENDIF
   ENDFOR
   RETURN(trim(dsc_str->dsc_target_str))
 END ;Subroutine
#end_program
END GO
