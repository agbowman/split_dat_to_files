CREATE PROGRAM dm_gen_schema_report:dba
 IF (((validate(curdb->tbl_cnt,- (1)) < 0) OR (validate(tgtdb->tbl_cnt,- (1)) < 0)) )
  CALL echo("*** Global schema record struct not found")
  GO TO end_program
 ENDIF
 IF (validate(fs_proc->id,- (1)) < 0)
  CALL echo("*** Global Fix Schema record struct not found")
  GO TO end_program
 ENDIF
 IF ((tgtdb->tbl_cnt=0))
  CALL echo("*** No tables found in target schema")
  GO TO end_program
 ENDIF
 SET str68 = fillstring(68," ")
 SET str60 = fillstring(60," ")
 SET diff_count = 0
 SELECT INTO value(fs_proc->diff_filename)
  FROM dual
  DETAIL
   "Schema Difference Report", row + 1, "------------------------",
   row + 1, row + 1
   FOR (t_tbl = 1 TO tgtdb->tbl_cnt)
     IF ((tgtdb->tbl[t_tbl].new_ind=1))
      row + 1, "--- New Table ", tgtdb->tbl[t_tbl].tbl_name,
      " ---", row + 1, row + 1
      IF ((tgtdb->tbl[t_tbl].reference_ind=1))
       "This is a reference table", row + 1
      ELSE
       "This is an activity table", row + 1
      ENDIF
      row + 1, col 2, "Column Name",
      col 35, "Type", col 45,
      "Length", col 53, "Nullable",
      col 63, "Default", row + 1
      FOR (t_col = 1 TO tgtdb->tbl[t_tbl].tbl_col_cnt)
        col 2, tgtdb->tbl[t_tbl].tbl_col[t_col].col_name, col 35,
        tgtdb->tbl[t_tbl].tbl_col[t_col].data_type, col 46, tgtdb->tbl[t_tbl].tbl_col[t_col].
        data_length"#####",
        col 56, tgtdb->tbl[t_tbl].tbl_col[t_col].nullable, str68 = substring(1,68,tgtdb->tbl[t_tbl].
         tbl_col[t_col].data_default),
        col 63, str68, row + 1
      ENDFOR
      "Tablespace ", tgtdb->tbl[t_tbl].tspace_name, row + 1,
      row + 1
      FOR (t_ind = 1 TO tgtdb->tbl[t_tbl].ind_cnt)
        "New "
        IF ((tgtdb->tbl[t_tbl].ind[t_ind].unique_ind=1))
         "Unique "
        ENDIF
        "index ", tgtdb->tbl[t_tbl].ind[t_ind].ind_name, " on table ",
        tgtdb->tbl[t_tbl].tbl_name, row + 1, col 2,
        "Column Name", row + 1
        FOR (ic = 1 TO tgtdb->tbl[t_tbl].ind[t_ind].ind_col_cnt)
          col 2, tgtdb->tbl[t_tbl].ind[t_ind].ind_col[ic].col_name, row + 1
        ENDFOR
        "Tablespace ", tgtdb->tbl[t_tbl].ind[t_ind].tspace_name, row + 1,
        row + 1
      ENDFOR
      FOR (t_cons = 1 TO tgtdb->tbl[t_tbl].cons_cnt)
        "New "
        IF ((tgtdb->tbl[t_tbl].cons[t_cons].cons_type="P"))
         "Primary Key "
        ELSEIF ((tgtdb->tbl[t_tbl].cons[t_cons].cons_type="U"))
         "Unique "
        ELSEIF ((tgtdb->tbl[t_tbl].cons[t_cons].cons_type="R"))
         "Foreign Key "
        ENDIF
        "constraint ", tgtdb->tbl[t_tbl].cons[t_cons].cons_name, " on table ",
        tgtdb->tbl[t_tbl].tbl_name, row + 1, col 2,
        "Column Name", row + 1
        FOR (ic = 1 TO tgtdb->tbl[t_tbl].cons[t_cons].cons_col_cnt)
          col 2, tgtdb->tbl[t_tbl].cons[t_cons].cons_col[ic].col_name, row + 1
        ENDFOR
        IF ((tgtdb->tbl[t_tbl].cons[t_cons].cons_type="R"))
         "References table ", tgtdb->tbl[t_tbl].cons[t_cons].parent_table, row + 1
        ENDIF
        IF ((tgtdb->tbl[t_tbl].cons[t_cons].downtime_ind=1))
         "NOTE: The above constraint will be placed in downtime.", row + 1
        ENDIF
        row + 1
      ENDFOR
      row + 1, "--- End of differences for table ", tgtdb->tbl[t_tbl].tbl_name,
      " ---", row + 1, row + 1
     ELSEIF ((((tgtdb->tbl[t_tbl].diff_ind=1)) OR ((tgtdb->tbl[t_tbl].warn_ind=1))) )
      c_tbl = tgtdb->tbl[t_tbl].cur_idx
      IF (c_tbl > 0)
       row + 1, "--- Table ", tgtdb->tbl[t_tbl].tbl_name,
       " ---", row + 1, row + 1
       IF ((tgtdb->tbl[t_tbl].reference_ind=1))
        "This is a reference table", row + 1
       ELSE
        "This is an activity table", row + 1
       ENDIF
       row + 1, row + 1
       IF ((curdb->tbl[c_tbl].bad_tspace_ind=1))
        "WARNING: Table ", tgtdb->tbl[t_tbl].tbl_name, " is in an invalid tablespace",
        row + 1, "Tablespace ", curdb->tbl[c_tbl].tspace_name,
        row + 1, "This is only a warning. This schema change will not be implemented.", row + 1,
        row + 1
       ENDIF
       diff_cols = 0
       FOR (t_col = 1 TO tgtdb->tbl[t_tbl].tbl_col_cnt)
         IF ((((tgtdb->tbl[t_tbl].tbl_col[t_col].diff_dtype_ind > 0)) OR ((((tgtdb->tbl[t_tbl].
         tbl_col[t_col].diff_dlength_ind > 0)) OR ((((tgtdb->tbl[t_tbl].tbl_col[t_col].
         diff_nullable_ind > 0)) OR ((tgtdb->tbl[t_tbl].tbl_col[t_col].diff_default_ind > 0))) )) ))
         )
          c_col = tgtdb->tbl[t_tbl].tbl_col[t_col].cur_idx
          IF (c_col > 0)
           IF (diff_cols=0)
            "The following columns are different on table ", tgtdb->tbl[t_tbl].tbl_name, row + 1,
            col 10, "Column Name", col 43,
            "Type", col 53, "Length",
            col 61, "Nullable", col 71,
            "Default", row + 1
           ENDIF
           diff_cols = 1, col 0, "Current",
           col 10, curdb->tbl[c_tbl].tbl_col[c_col].col_name, col 43,
           curdb->tbl[c_tbl].tbl_col[c_col].data_type, col 54, curdb->tbl[c_tbl].tbl_col[c_col].
           data_length"#####",
           col 64, curdb->tbl[c_tbl].tbl_col[c_col].nullable, str60 = substring(1,60,curdb->tbl[c_tbl
            ].tbl_col[c_col].data_default),
           col 71, str60, row + 1,
           col 0, "Target", col 10,
           tgtdb->tbl[t_tbl].tbl_col[t_col].col_name, col 43, tgtdb->tbl[t_tbl].tbl_col[t_col].
           data_type,
           col 54, tgtdb->tbl[t_tbl].tbl_col[t_col].data_length"#####", col 64,
           tgtdb->tbl[t_tbl].tbl_col[t_col].nullable, str60 = substring(1,60,tgtdb->tbl[t_tbl].
            tbl_col[t_col].data_default), col 71,
           str60, row + 1
           IF ((tgtdb->tbl[t_tbl].tbl_col[t_col].diff_dtype_ind=2))
            col 0, "WARNING: The above data type change is invalid; it will not be implemented.", row
             + 1
           ENDIF
           IF ((tgtdb->tbl[t_tbl].tbl_col[t_col].diff_dlength_ind=2))
            col 0, "WARNING: The above data length change is invalid; it will not be implemented.",
            row + 1
           ENDIF
           IF ((tgtdb->tbl[t_tbl].tbl_col[t_col].downtime_ind=1))
            IF ((tgtdb->tbl[t_tbl].tbl_col[t_col].null_to_notnull_ind=1))
             col 0, "NOTE: The above nullability change requires downtime.", row + 1
            ELSEIF ((tgtdb->tbl[t_tbl].tbl_col[t_col].diff_dtype_ind=1))
             col 0, "NOTE: The above datatype change requires downtime.", row + 1
            ELSE
             col 0, "NOTE: The above nullability change will be made in downtime.", row + 1
            ENDIF
           ENDIF
           row + 1
          ENDIF
         ENDIF
       ENDFOR
       IF (diff_cols > 0)
        row + 1
       ENDIF
       new_cols = 0
       FOR (t_col = 1 TO tgtdb->tbl[t_tbl].tbl_col_cnt)
         IF ((tgtdb->tbl[t_tbl].tbl_col[t_col].new_ind=1))
          IF (new_cols=0)
           "New column(s) on table ", tgtdb->tbl[t_tbl].tbl_name, row + 1,
           col 10, "Column Name", col 43,
           "Type", col 53, "Length",
           col 61, "Nullable", col 71,
           "Default", row + 1
          ENDIF
          new_cols = 1, col 10, tgtdb->tbl[t_tbl].tbl_col[t_col].col_name,
          col 43, tgtdb->tbl[t_tbl].tbl_col[t_col].data_type, col 54,
          tgtdb->tbl[t_tbl].tbl_col[t_col].data_length"#####", col 64, tgtdb->tbl[t_tbl].tbl_col[
          t_col].nullable,
          str60 = substring(1,60,tgtdb->tbl[t_tbl].tbl_col[t_col].data_default), col 71, str60,
          row + 1
          IF ((tgtdb->tbl[t_tbl].tbl_col[t_col].downtime_ind=1))
           col 0, "NOTE: Adding the above new column requires downtime.", row + 1
          ENDIF
         ENDIF
       ENDFOR
       IF (new_cols > 0)
        row + 1
       ENDIF
       FOR (t_ind = 1 TO tgtdb->tbl[t_tbl].ind_cnt)
         IF ((tgtdb->tbl[t_tbl].ind[t_ind].new_ind=1))
          "New "
          IF ((tgtdb->tbl[t_tbl].ind[t_ind].unique_ind=1))
           "unique "
          ENDIF
          "index ", tgtdb->tbl[t_tbl].ind[t_ind].ind_name, " on table ",
          tgtdb->tbl[t_tbl].tbl_name, row + 1, col 2,
          "Column Name", row + 1
          FOR (tc = 1 TO tgtdb->tbl[t_tbl].ind[t_ind].ind_col_cnt)
            col 2, tgtdb->tbl[t_tbl].ind[t_ind].ind_col[tc].col_name, row + 1
          ENDFOR
          "Tablespace ", tgtdb->tbl[t_tbl].ind[t_ind].tspace_name, row + 1
          IF ((tgtdb->tbl[t_tbl].ind[t_ind].downtime_ind=1))
           "NOTE: The index build above requires downtime.", row + 1
          ENDIF
          row + 1
         ELSE
          c_ind = tgtdb->tbl[t_tbl].ind[t_ind].cur_idx
          IF (c_ind > 0)
           IF ((curdb->tbl[c_tbl].ind[c_ind].bad_tspace_ind=1))
            "WARNING: Index ", tgtdb->tbl[t_tbl].ind[t_ind].ind_name, " on table ",
            tgtdb->tbl[t_tbl].tbl_name, row + 1, "is in an invalid tablespace. Tablespace: ",
            curdb->tbl[c_tbl].ind[c_ind].tspace_name, row + 1,
            "This is only a warning. This schema change will not be implemented.",
            row + 1, row + 1
           ENDIF
           IF ((((tgtdb->tbl[t_tbl].ind[t_ind].diff_col_ind=1)) OR ((((tgtdb->tbl[t_tbl].ind[t_ind].
           diff_unique_ind=1)) OR ((((tgtdb->tbl[t_tbl].ind[t_ind].diff_name_ind=1)) OR ((tgtdb->tbl[
           t_tbl].ind[t_ind].diff_cons_ind=1))) )) )) )
            "Modify index ", tgtdb->tbl[t_tbl].ind[t_ind].ind_name, " on table ",
            tgtdb->tbl[t_tbl].tbl_name, row + 1
            IF ((tgtdb->tbl[t_tbl].ind[t_ind].diff_name_ind=1))
             "(Replaces index ", curdb->tbl[c_tbl].ind[c_ind].ind_name, ")",
             row + 1
            ENDIF
            IF ((tgtdb->tbl[t_tbl].ind[t_ind].diff_cons_ind=1)
             AND (tgtdb->tbl[t_tbl].ind[t_ind].diff_col_ind=0)
             AND (tgtdb->tbl[t_tbl].ind[t_ind].diff_unique_ind=0)
             AND (tgtdb->tbl[t_tbl].ind[t_ind].diff_name_ind=0))
             "(Due to constraint change)", row + 1
            ENDIF
            col 15, "Current", col 50,
            "Target", row + 1, max_ind_col = greatest(tgtdb->tbl[t_tbl].ind[t_ind].ind_col_cnt,curdb
             ->tbl[c_tbl].ind[c_ind].ind_col_cnt)
            FOR (ci = 1 TO max_ind_col)
              col 5, ci"###"
              IF ((ci <= curdb->tbl[c_tbl].ind[c_ind].ind_col_cnt))
               col 15, curdb->tbl[c_tbl].ind[c_ind].ind_col[ci].col_name
              ENDIF
              IF ((ci <= tgtdb->tbl[t_tbl].ind[t_ind].ind_col_cnt))
               col 50, tgtdb->tbl[t_tbl].ind[t_ind].ind_col[ci].col_name
              ENDIF
              row + 1
            ENDFOR
            col 0, "Uniqueness"
            IF ((curdb->tbl[c_tbl].ind[c_ind].unique_ind=1))
             col 15, "UNIQUE"
            ELSE
             col 15, "NON UNIQUE"
            ENDIF
            IF ((tgtdb->tbl[t_tbl].ind[t_ind].unique_ind=1))
             col 50, "UNIQUE"
            ELSE
             col 50, "NON UNIQUE"
            ENDIF
            row + 1
            IF ((tgtdb->tbl[t_tbl].ind[t_ind].downtime_ind=1))
             "NOTE: The index build above requires downtime.", row + 1
            ENDIF
            row + 1
           ENDIF
          ENDIF
         ENDIF
       ENDFOR
       FOR (t_cons = 1 TO tgtdb->tbl[t_tbl].cons_cnt)
         t_cons_type = 0
         IF ((tgtdb->tbl[t_tbl].cons[t_cons].cons_type IN ("P", "U")))
          t_cons_type = 1
         ELSEIF ((tgtdb->tbl[t_tbl].cons[t_cons].cons_type="R"))
          t_cons_type = 2
         ENDIF
         IF ((tgtdb->tbl[t_tbl].cons[t_cons].new_ind=1))
          "New "
          IF ((tgtdb->tbl[t_tbl].cons[t_cons].cons_type="P"))
           "primary key "
          ELSEIF ((tgtdb->tbl[t_tbl].cons[t_cons].cons_type="U"))
           "unique "
          ELSEIF ((tgtdb->tbl[t_tbl].cons[t_cons].cons_type="R"))
           "foreign key "
          ENDIF
          "constraint ", tgtdb->tbl[t_tbl].cons[t_cons].cons_name, " on table ",
          tgtdb->tbl[t_tbl].tbl_name, row + 1, col 2,
          "Column Name", row + 1
          FOR (tc = 1 TO tgtdb->tbl[t_tbl].cons[t_cons].cons_col_cnt)
            col 2, tgtdb->tbl[t_tbl].cons[t_cons].cons_col[tc].col_name, row + 1
          ENDFOR
          IF ((tgtdb->tbl[t_tbl].cons[t_cons].cons_type="R"))
           col 0, "References ", tgtdb->tbl[t_tbl].cons[t_cons].parent_table,
           row + 1
          ENDIF
          IF ((tgtdb->tbl[t_tbl].cons[t_cons].downtime_ind=1))
           "NOTE: The above constraint will be placed in downtime.", row + 1
          ENDIF
          row + 1
         ELSE
          c_cons = tgtdb->tbl[t_tbl].cons[t_cons].cur_idx
          IF (c_cons > 0)
           IF ((((tgtdb->tbl[t_tbl].cons[t_cons].diff_col_ind=1)) OR ((((tgtdb->tbl[t_tbl].cons[
           t_cons].diff_status_ind=1)) OR ((((tgtdb->tbl[t_tbl].cons[t_cons].diff_parent_ind=1)) OR (
           (((tgtdb->tbl[t_tbl].cons[t_cons].diff_name_ind=1)) OR ((tgtdb->tbl[t_tbl].cons[t_cons].
           diff_ind_ind=1))) )) )) )) )
            "Modify "
            IF ((tgtdb->tbl[t_tbl].cons[t_cons].cons_type="P"))
             "primary key "
            ELSEIF ((tgtdb->tbl[t_tbl].cons[t_cons].cons_type="U"))
             "unique "
            ELSEIF ((tgtdb->tbl[t_tbl].cons[t_cons].cons_type="R"))
             "foreign key "
            ENDIF
            "constraint ", tgtdb->tbl[t_tbl].cons[t_cons].cons_name, " on table ",
            tgtdb->tbl[t_tbl].tbl_name, row + 1
            IF ((tgtdb->tbl[t_tbl].cons[t_cons].diff_name_ind=1))
             "(Replaces constraint ", curdb->tbl[c_tbl].cons[c_cons].cons_name, ")",
             row + 1
            ENDIF
            IF ((tgtdb->tbl[t_tbl].cons[t_cons].diff_ind_ind=1)
             AND (tgtdb->tbl[t_tbl].cons[t_cons].diff_col_ind=0)
             AND (tgtdb->tbl[t_tbl].cons[t_cons].diff_status_ind=0)
             AND (tgtdb->tbl[t_tbl].cons[t_cons].diff_parent_ind=0)
             AND (tgtdb->tbl[t_tbl].cons[t_cons].diff_name_ind=0))
             "(Due to index change)", row + 1
            ENDIF
            col 15, "Current", col 50,
            "Target", row + 1, max_cons_col = greatest(tgtdb->tbl[t_tbl].cons[t_cons].cons_col_cnt,
             curdb->tbl[c_tbl].cons[c_cons].cons_col_cnt)
            FOR (cc = 1 TO max_cons_col)
              col 5, cc"###"
              IF ((cc <= curdb->tbl[c_tbl].cons[c_cons].cons_col_cnt))
               col 15, curdb->tbl[c_tbl].cons[c_cons].cons_col[cc].col_name
              ENDIF
              IF ((cc <= tgtdb->tbl[t_tbl].cons[t_cons].cons_col_cnt))
               col 50, tgtdb->tbl[t_tbl].cons[t_cons].cons_col[cc].col_name
              ENDIF
              row + 1
            ENDFOR
            IF ((curdb->tbl[c_tbl].cons[c_cons].cons_type="R"))
             col 0, "References", col 15,
             curdb->tbl[c_tbl].cons[c_cons].parent_table
            ENDIF
            IF ((tgtdb->tbl[t_tbl].cons[t_cons].cons_type="R"))
             col 0, "References", col 50,
             tgtdb->tbl[t_tbl].cons[t_cons].parent_table
            ENDIF
            IF ((((curdb->tbl[c_tbl].cons[c_cons].cons_type="R")) OR ((tgtdb->tbl[t_tbl].cons[t_cons]
            .cons_type="R"))) )
             row + 1
            ENDIF
            col 0, "Status"
            IF ((curdb->tbl[c_tbl].cons[c_cons].status_ind=1))
             col 15, "ENABLED"
            ELSE
             col 15, "DISABLED"
            ENDIF
            IF ((tgtdb->tbl[t_tbl].cons[t_cons].status_ind=1))
             col 50, "ENABLED"
            ELSE
             col 50, "DISABLED"
            ENDIF
            row + 1
            IF ((tgtdb->tbl[t_tbl].cons[t_cons].downtime_ind=1))
             "NOTE: The above constraint change will be made in downtime.", row + 1
            ENDIF
            row + 1
           ENDIF
          ENDIF
         ENDIF
         row + 1
       ENDFOR
      ENDIF
      row + 1, "--- End of differences for table ", tgtdb->tbl[t_tbl].tbl_name,
      " ---", row + 1, row + 1
     ENDIF
   ENDFOR
  WITH nocounter, format = variable, formfeed = none,
   noheading, maxcol = 132
 ;end select
#end_program
END GO
