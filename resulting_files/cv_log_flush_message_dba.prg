CREATE PROGRAM cv_log_flush_message:dba
 IF ((validate(cv_log_error_file,- (1))=- (1)))
  CALL echo("cv_log_error_file is not defined")
 ELSE
  IF (cv_log_error_file=1)
   IF (validate(reqdata->loglevel,0) > 2)
    SELECT INTO value(cv_log_file_name)
     FROM dual d
     HEAD REPORT
      left_margin = 12, right_margin = 80, spaces = 32,
      lf = 10, cr = 13, tab = 9,
      tabptr = 0, line = fillstring(125,"-"), print_text = fillstring(10000," "),
      text = fillstring(100," "), copiedtext = fillstring(108," "), tabspace = fillstring(4," "),
      max_text_len = 0, ptr = 0, start_col = 0,
      start_pos = 0, last_space_pos = 0, last_new_line = 0,
      text_len = 0, print_max_row = maxrow, print_dio_ind = 0,
      adjusted_initial_start_col = 4, cnt = 0,
      MACRO (print_comments_routine)
       IF (adjusted_initial_start_col=0)
        start_col = left_margin
       ELSE
        start_col = adjusted_initial_start_col
       ENDIF
       tabspace = "   ", start_pos = 0, last_space_pos = 0,
       text_len = 0, text = "", ptr = 1,
       max_text_len = size(trim(print_text),3), cnt = 0
       WHILE (ptr <= max_text_len)
         text_char = substring(ptr,1,print_text)
         IF (ichar(text_char) < spaces)
          IF (((ichar(text_char)=cr) OR (ichar(text_char) != lf
           AND ichar(text_char) != tab)) )
           IF (start_pos > 0)
            text = substring(start_pos,text_len,print_text), col start_col, text,
            cnt = (cnt+ 1), stat = alterlist(temp_text->qual,cnt), temp_text->qual[cnt].text = text
            IF (tabptr > 0)
             copiedtext = build(char(9),substring(start_pos,text_len,print_text)), tabptr = 0, col
             start_col,
             copiedtext, cnt = (cnt+ 1), stat = alterlist(temp_text->qual,cnt),
             temp_text->qual[cnt].text = copiedtext, copiedtext = ""
            ELSE
             tabptr = 0, col start_col, text,
             cnt = (cnt+ 1), stat = alterlist(temp_text->qual,cnt), temp_text->qual[cnt].text =
             copiedtext
            ENDIF
           ELSE
            col start_col, " "
           ENDIF
           IF (last_new_line=0)
            row + 1, last_new_line = 1
            IF ((row >= (print_max_row - 2)))
             BREAK
            ENDIF
           ELSE
            last_new_line = 0
           ENDIF
           IF (print_dio_ind=1)
            start_col = (left_margin - 1)
           ELSE
            start_col = left_margin
           ENDIF
           start_pos = 0, last_space_pos = 0, text_len = 0,
           text = ""
          ENDIF
          IF (((ichar(text_char) != cr) OR (ichar(text_char)=lf
           AND ichar(text_char) != tab)) )
           last_new_line = 0
           IF (text_len > 0)
            text = substring(start_pos,text_len,print_text), cnt = (cnt+ 1), stat = alterlist(
             temp_text->qual,cnt),
            temp_text->qual[cnt].text = text
            IF (tabptr > 0)
             copiedtext = concat(tabspace,substring(start_pos,text_len,print_text)), tabptr = 0, col
             start_col,
             copiedtext, cnt = (cnt+ 1), stat = alterlist(temp_text->qual,cnt),
             temp_text->qual[cnt].text = copiedtext, copiedtext = ""
            ELSE
             tabptr = 0, col start_col, text,
             cnt = (cnt+ 1), stat = alterlist(temp_text->qual,cnt), temp_text->qual[cnt].text =
             copiedtext
            ENDIF
            start_col = (size(text,2)+ left_margin)
           ENDIF
           start_col = (start_col+ 1)
           IF (start_col >= right_margin)
            row + 1
            IF (print_dio_ind=1)
             start_col = (left_margin - 1)
            ELSE
             start_col = left_margin
            ENDIF
           ENDIF
           IF ((row >= (print_max_row - 2)))
            BREAK
           ENDIF
           start_pos = (ptr+ 1), last_space_pos = 0, text_len = 0,
           text = ""
          ENDIF
          IF (ichar(text_char)=tab)
           tabptr = ptr
          ENDIF
         ELSEIF (ichar(text_char) >= spaces)
          IF (start_pos=0)
           start_pos = ptr
          ENDIF
          IF (ichar(text_char)=spaces)
           last_space_pos = ptr
          ENDIF
          text_len = (text_len+ 1)
          IF (((start_col+ text_len) >= right_margin))
           IF (last_space_pos > 0)
            text_len = ((last_space_pos - start_pos)+ 1), ptr = last_space_pos
           ENDIF
           text = substring(start_pos,text_len,print_text)
           IF (tabptr > 0)
            copiedtext = concat(tabspace,substring(start_pos,(text_len+ 4),print_text)), tabptr = 0,
            col start_col,
            copiedtext, cnt = (cnt+ 1), stat = alterlist(temp_text->qual,cnt),
            temp_text->qual[cnt].text = copiedtext, copiedtext = ""
           ELSE
            tabptr = 0, col start_col, text,
            cnt = (cnt+ 1), stat = alterlist(temp_text->qual,cnt), temp_text->qual[cnt].text = text
           ENDIF
           col start_col, text, row + 1,
           start_col = left_margin, start_pos = 0, last_space_pos = 0,
           text_len = 0, text = ""
           IF ((row >= (print_max_row - 2)))
            BREAK
           ENDIF
          ENDIF
         ELSE
          text_len = (text_len+ 1)
         ENDIF
         ptr = (ptr+ 1)
       ENDWHILE
       IF (text_len > 0)
        text = substring(start_pos,text_len,print_text), col start_col, text,
        cnt = (cnt+ 1), stat = alterlist(temp_text->qual,cnt), temp_text->qual[cnt].text = text,
        row + 1, start_col = left_margin, start_pos = 0,
        last_space_pos = 0, text_len = 0, text = ""
        IF ((row >= (print_max_row - 2)))
         BREAK
        ENDIF
       ENDIF
       print_text = fillstring(10000," ")
      ENDMACRO
     DETAIL
      print_text = cv_log_error_string, print_comments_routine
     WITH append, nocounter
    ;end select
    SET cv_log_error_string = fillstring(32000," ")
   ELSE
    CALL echo(build("Skipping writing the File due to loglevel =",reqdata->loglevel))
   ENDIF
  ELSE
   CALL echo("Skipping file write because cv_log_error_file is off")
  ENDIF
 ENDIF
 DECLARE cv_log_flush_message_vrsn = vc WITH constant("MOD 003 MH9140 10/27/04"), private
END GO
