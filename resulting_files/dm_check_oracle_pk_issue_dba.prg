CREATE PROGRAM dm_check_oracle_pk_issue:dba
 RECORD tmptable(
   1 tbls[*]
     2 table_name = vc
     2 pk_name = vc
 )
 RECORD pk_cols(
   1 qual[*]
     2 table_name = vc
     2 pk_name = vc
     2 column_name = vc
     2 position = i4
 )
 RECORD ind(
   1 qual[*]
     2 index_name = vc
     2 found = i2
     2 cols[*]
       3 column_name = vc
       3 position = i4
 )
 DECLARE tmpstr = vc
 DECLARE compareit(intmp=vc) = i2
 SUBROUTINE compareit(intmp)
  DECLARE matchcnt = i2 WITH private
  FOR (sub_yy = 1 TO size(ind->qual,5))
    SET matchcnt = 0
    FOR (sub_xx = 1 TO size(ind->qual[sub_yy].cols,5))
      FOR (sub_zz = 1 TO size(pk_cols->qual,5))
        IF ((pk_cols->qual[sub_zz].column_name=ind->qual[sub_yy].cols[sub_xx].column_name))
         SET matchcnt = (matchcnt+ 1)
        ENDIF
      ENDFOR
    ENDFOR
    IF (matchcnt=size(pk_cols->qual,5))
     FOR (sub_yy1 = 1 TO size(ind->qual,5))
       FOR (sub_xx1 = 1 TO size(ind->qual[sub_yy1].cols,5))
         FOR (sub_zz1 = 1 TO size(pk_cols->qual,5))
           IF ((pk_cols->qual[sub_zz1].column_name=ind->qual[sub_yy1].cols[sub_xx1].column_name)
            AND (pk_cols->qual[sub_zz1].pk_name != ind->qual[sub_yy1].index_name))
            IF ((ind->qual[sub_yy1].cols[sub_xx1].position=1))
             SET ind->qual[sub_yy1].found = 1
            ENDIF
           ENDIF
         ENDFOR
       ENDFOR
     ENDFOR
    ENDIF
    IF ((ind->qual[sub_yy].found=1))
     SELECT INTO "DM_CHECK_ORACLE_PK_ISSUE.LOG"
      FROM dummyt d
      FOOT REPORT
       FOR (sub_aa1 = 1 TO size(pk_cols->qual,5))
         IF (sub_aa1=1)
          tmpstr = concat("TABLE_NAME:",pk_cols->qual[sub_aa1].table_name), tmpstr, row + 1,
          tmpstr = concat("  PK_NAME:",pk_cols->qual[sub_aa1].pk_name), tmpstr, row + 1
         ENDIF
         tmpstr = concat("     PK_COLUMN:",pk_cols->qual[sub_aa1].column_name," ","     PK_POSITION:",
          trim(cnvtstring(pk_cols->qual[sub_aa1].position),3)), tmpstr, row + 1
       ENDFOR
       FOR (sub_aa1 = 1 TO size(ind->qual[sub_yy].cols,5))
         IF (sub_aa1=1)
          tmpstr = concat("  INDEX_NAME:",ind->qual[sub_yy].index_name), tmpstr, row + 1
         ENDIF
         tmpstr = concat("     IND_COLUMN:",ind->qual[sub_yy].cols[sub_aa1].column_name," ",
          "     IND_POSITION:",trim(cnvtstring(ind->qual[sub_yy].cols[sub_aa1].position),3)), tmpstr,
         row + 1
       ENDFOR
      WITH nocounter, append, format = variable,
       formfeed = none, maxcol = 8000, maxrow = 1
     ;end select
    ENDIF
  ENDFOR
 END ;Subroutine
 SET message = noinformation
 SET trace = nocost
 CALL echo("Starting log file...")
 SELECT INTO "DM_CHECK_ORACLE_PK_ISSUE.LOG"
  FROM dummyt d
  FOOT REPORT
   "Log file:"
  WITH nocounter, format = variable, formfeed = none,
   maxcol = 8000, maxrow = 1
 ;end select
 CALL echo("Grabbing tables...")
 SET count = 0
 SELECT INTO "nl:"
  t.table_name
  FROM user_tables t
  DETAIL
   count = (count+ 1)
   IF (count > size(tmptable->tbls,5))
    stat = alterlist(tmptable->tbls,(count+ 1000))
   ENDIF
   tmptable->tbls[count].table_name = t.table_name
  WITH nocounter
 ;end select
 SET stat = alterlist(tmptable->tbls,count)
 CALL echo("Grabbing primary key constraints...")
 SELECT INTO "nl:"
  z.constraint_name
  FROM user_constraints z,
   (dummyt d  WITH seq = value(size(tmptable->tbls,5)))
  PLAN (d)
   JOIN (z
   WHERE (z.table_name=tmptable->tbls[d.seq].table_name)
    AND z.constraint_type="P")
  DETAIL
   tmptable->tbls[d.seq].pk_name = z.constraint_name
  WITH nocounter
 ;end select
 FOR (xx = 1 TO size(tmptable->tbls,5))
   CALL echo(concat("Comparing ",trim(cnvtstring(xx),3)," of ",trim(cnvtstring(size(tmptable->tbls,5)
       ),3)," ",
     tmptable->tbls[xx].table_name))
   SET stat = alterlist(pk_cols->qual,0)
   SET stat = alterlist(ind->qual,0)
   SET count = 0
   SELECT INTO "nl:"
    c.column_name, c.position
    FROM user_cons_columns c
    WHERE (c.table_name=tmptable->tbls[xx].table_name)
     AND (c.constraint_name=tmptable->tbls[xx].pk_name)
    ORDER BY c.position
    DETAIL
     count = (count+ 1), stat = alterlist(pk_cols->qual,count), pk_cols->qual[count].table_name =
     tmptable->tbls[xx].table_name,
     pk_cols->qual[count].pk_name = tmptable->tbls[xx].pk_name, pk_cols->qual[count].column_name = c
     .column_name, pk_cols->qual[count].position = c.position
    WITH nocounter
   ;end select
   SET count = 0
   SELECT INTO "nl:"
    c.index_name
    FROM user_indexes c
    WHERE (c.table_name=tmptable->tbls[xx].table_name)
    DETAIL
     count = (count+ 1), stat = alterlist(ind->qual,count), ind->qual[count].index_name = c
     .index_name
    WITH nocounter
   ;end select
   IF (size(ind->qual,5) > 0)
    SELECT INTO "nl:"
     z.table_name, z.index_name
     FROM user_ind_columns z,
      (dummyt d  WITH seq = value(size(ind->qual,5)))
     PLAN (d)
      JOIN (z
      WHERE (z.table_name=tmptable->tbls[xx].table_name)
       AND (z.index_name=ind->qual[d.seq].index_name))
     ORDER BY z.column_position
     HEAD z.index_name
      count = 0
     DETAIL
      count = (count+ 1), stat = alterlist(ind->qual[d.seq].cols,count), ind->qual[d.seq].cols[count]
      .column_name = z.column_name,
      ind->qual[d.seq].cols[count].position = z.column_position
     WITH nocounter
    ;end select
    CALL compareit("tmp")
   ENDIF
 ENDFOR
 CALL echo("+")
 CALL echo("------------------------------------------")
 CALL echo("Check output file 'DM_CHECK_ORACLE_PK_ISSUE.LOG'.")
 CALL echo("------------------------------------------")
 CALL echo("+")
END GO
