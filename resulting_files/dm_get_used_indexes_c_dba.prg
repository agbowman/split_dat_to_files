CREATE PROGRAM dm_get_used_indexes_c:dba
 DECLARE dgui_short_stmts(sbr_text=vc) = null
 DECLARE delim_check(sbr_vc_string=vc) = i2
 SUBROUTINE dgui_short_stmts(sbr_text)
   DECLARE pnt = i4
   DECLARE text_str = vc
   DECLARE seg_cnt = i4
   DECLARE dgui_done = i2
   DECLARE str_len = i4
   DECLARE delim_check_ind = i2
   SET str_len = 110
   SET text_str = sbr_text
   SET seg_cnt = 0
   SET stat = alterlist(dgui_short_stmts->qual,0)
   IF (size(text_str) > 125)
    SET dgui_done = 0
    WHILE (dgui_done != 1)
      SET pnt = 0
      SET pnt = findstring(" ",text_str,str_len,0)
      IF (((pnt=0) OR (pnt > 132)) )
       SET pnt = findstring(",",text_str,str_len,0)
      ENDIF
      IF (pnt > 0
       AND pnt <= 132)
       SET delim_check_ind = delim_check(substring(1,pnt,text_str))
       IF (delim_check_ind=1)
        SET str_len = (str_len - 10)
       ELSE
        SET seg_cnt = (seg_cnt+ 1)
        SET stat = alterlist(dgui_short_stmts->qual,seg_cnt)
        SET dgui_short_stmts->qual[seg_cnt].stmt = trim(substring(1,pnt,text_str))
        SET text_str = substring((pnt+ 1),size(text_str),text_str)
        SET str_len = 110
        IF (size(text_str) <= 110)
         SET seg_cnt = (seg_cnt+ 1)
         SET stat = alterlist(dgui_short_stmts->qual,seg_cnt)
         SET dgui_short_stmts->qual[seg_cnt].stmt = text_str
         SET dgui_done = 1
        ENDIF
       ENDIF
      ELSE
       SET str_len = (str_len - 10)
      ENDIF
      IF (str_len < 10)
       SET stat = alterlist(dgui_short_stmts->qual,1)
       SET dgui_short_stmts->qual[1].stmt = "ERROR"
       SET dgui_done = 1
      ENDIF
    ENDWHILE
   ELSE
    SET seg_cnt = (seg_cnt+ 1)
    SET stat = alterlist(dgui_short_stmts->qual,seg_cnt)
    SET dgui_short_stmts->qual[seg_cnt].stmt = text_str
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE delim_check(sbr_vc_string)
   DECLARE delim_loop = i4
   DECLARE dtick_cnt = i4
   DECLARE tick_cnt = i4
   DECLARE carrot_cnt = i4
   DECLARE delim_cnt = i4
   DECLARE high_val = i4 WITH constant(135)
   SET delim_cnt = 0
   SET delim_loop = 2
   WHILE (delim_loop=2)
     SET dtick_cnt = 0
     SET tick_cnt = 0
     SET carrot_cnt = 0
     SET dtick_cnt = findstring('"',sbr_vc_string,(delim_cnt+ 1),0)
     SET tick_cnt = findstring("'",sbr_vc_string,(delim_cnt+ 1),0)
     SET carrot_cnt = findstring("^",sbr_vc_string,(delim_cnt+ 1),0)
     IF (dtick_cnt=0)
      SET dtick_cnt = high_val
     ENDIF
     IF (tick_cnt=0)
      SET tick_cnt = high_val
     ENDIF
     IF (carrot_cnt=0)
      SET carrot_cnt = high_val
     ENDIF
     SET delim_cnt = minval(dtick_cnt,tick_cnt,carrot_cnt)
     IF (delim_cnt=high_val)
      SET delim_loop = 0
     ELSE
      SET delim_cnt = findstring(substring(delim_cnt,1,sbr_vc_string),sbr_vc_string,(delim_cnt+ 1),0)
      IF (delim_cnt=0)
       SET delim_loop = 1
      ENDIF
     ENDIF
   ENDWHILE
   RETURN(delim_loop)
 END ;Subroutine
 IF (currdb="ORACLE")
  CALL dgui_short_stmts(sql_text->qual[dgui_loop].stmt)
  IF ((dgui_short_stmts->qual[1].stmt != "ERROR"))
   SET dgui->f_name = concat(dgui->unique_vc,".sql")
   SELECT INTO value(dgui->f_name)
    *
    FROM dual
    DETAIL
     col 0, "EXPLAIN PLAN SET STATEMENT_ID = '", dgui->unique_vc,
     "' INTO DM_SQL_PLAN FOR ", row + 1
     FOR (dgui_short = 1 TO size(dgui_short_stmts->qual,5))
       col 0, dgui_short_stmts->qual[dgui_short].stmt, row + 1
     ENDFOR
     col 0, ";", row + 1,
     "COMMIT;", row + 2
    WITH nocounter, maxcol = 32000
   ;end select
   CALL parser(concat('rdb read "',dgui->unique_vc,'.sql" end go'),1)
  ELSE
   CALL echo(
    "Couldn't shorten the following SQL statement, it will not have an explain plan done on it")
   FOR (dgui_short = 1 TO size(dgui_short_stmts->qual,5))
     CALL echo(dgui_short_stmts->qual[dgui_short].stmt)
   ENDFOR
  ENDIF
 ELSE
  SET stat = alterlist(dgui_short_stmts->qual,1)
  SET dgui_short_stmts->qual[1].stmt = sql_text->qual[dgui_loop].stmt
  SET dgui->tv_str = concat("db2 connect to ",cnvtupper(currdbname)," user ",cnvtupper(currdbuser),
   " using ",
   dgui->pword)
  IF (push_dcl(dgui->tv_str)=0)
   GO TO exit_script
  ENDIF
  SET dgui->f_name = concat(dgui->unique_vc,".sql")
  SET dgui->tv_str = concat(" -tvf ",dgui->f_name)
  SELECT INTO value(dgui->f_name)
   *
   FROM dual
   DETAIL
    "EXPLAIN PLAN SET QUERYTAG = '", dgui->unique_vc, "' FOR ",
    row + 1, col 0, sql_text->qual[dgui_loop].stmt,
    ";", row + 1, "COMMIT;"
   WITH nocounter, maxcol = 32000
  ;end select
  IF (push_dcl(concat("db2 -tvf ",dgui->f_name))=0)
   CALL echo(sql_text->qual[dgui_loop].stmt)
  ENDIF
 ENDIF
END GO
