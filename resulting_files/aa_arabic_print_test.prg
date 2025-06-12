CREATE PROGRAM aa_arabic_print_test
 PAINT
 RECORD ptr_items(
   1 qual[*]
     2 pat_prep_ar = vc
     2 raw_text_a = vc
     2 raw_text_size_a = i4
     2 text_qual_cnt_a = i4
     2 text_qual_alloc_a = i4
     2 text_qual_a[*]
       3 line_a = vc
 )
 IF ( NOT (validate(format_text_request,0)))
  RECORD format_text_request(
    1 call_echo_ind = i2
    1 raw_text = vc
    1 temp_str = vc
    1 chars_per_line = i4
  )
 ENDIF
 IF ( NOT (validate(format_text_reply,0)))
  RECORD format_text_reply(
    1 beg_index = i4
    1 end_index = i4
    1 temp_index = i4
    1 qual_alloc = i4
    1 qual_cnt = i4
    1 qual[*]
      2 text_string = vc
  )
 ENDIF
 SET format_text_reply->qual_cnt = 0
 SET format_text_reply->qual_alloc = 0
 CALL clear(1,1)
 CALL video(i)
 CALL box(2,1,23,80)
 CALL line(4,1,80,"XH")
 CALL text(3,3,"Arabic Print Test")
 CALL text(7,10,"You will need a PERSON_ID from the PERSON table.")
 CALL text(8,10,"Tables used to determine LONG_TEXT field are:")
 CALL text(9,10,"PERSON, PERSON_INFO and LONG_TEXT.")
 CALL text(10,10,"The LONG_TEXT field will need to contain Arabic text to print.")
 CALL text(11,10,"If English text is stored, the report should be empty.")
 CALL text(12,10,"File will be created in the following location:")
 CALL text(13,10,"cer_print:AA_ARABIC_PRINT.DAT.")
 CALL text(14,10,"Use this command for printing file where XXX = Printer Name:")
 CALL text(15,10,"print /queue = XXX /setup = post cer_print:AA_ARABIC_PRINT.DAT.")
 CALL text(18,10,"Please enter a PERSON_ID or 0 to exit:  ")
 CALL video(n)
 SET v_pers_id = 0
 CALL accept(18,53,"9999999999",0)
 SET v_pers_id = cnvtint(curaccept)
 SET stat = alterlist(ptr_items->qual,1)
 IF (v_pers_id > 0)
  SET rpt_filename = "AA_ARABIC_PRINT.DAT"
  SET i = 0
  SET comment_loop_ar = 1
  SELECT INTO concat("cer_print:",rpt_filename)
   FROM (dummyt d  WITH seq = 1),
    person_info pi,
    long_text lt
   PLAN (d)
    JOIN (pi
    WHERE pi.person_id=v_pers_id
     AND pi.active_ind=1)
    JOIN (lt
    WHERE lt.long_text_id=pi.long_text_id)
   DETAIL
    cur_row = 72, row + 1, "{CPI/20}{LPI/7}{FONT/0}{FR/0}",
    CALL print(calcpos(36,cur_row)), "*** ARABIC PRINT TEST REPORT ***", row + 1,
    cur_row = (cur_row+ 21), row + 1, ptr_items->qual[1].pat_prep_ar = lt.long_text,
    ptr_items->qual[1].raw_text_a = ptr_items->qual[1].pat_prep_ar,
    CALL format_text_ar(1)
    FOR (i = comment_loop_ar TO ptr_items->qual[d.seq].text_qual_cnt_a)
      IF (cur_row > 720)
       BREAK
      ENDIF
      temp_comments = ptr_items->qual[d.seq].text_qual_a[i].line_a, "{CPI/10}{LPI/7}{FONT/44}{FR/0}",
      CALL print(calcpos(558,cur_row)),
      temp_comments, row + 1, cur_row = (cur_row+ 18),
      row + 1, comment_loop_ar = (comment_loop_ar+ 1)
    ENDFOR
    row + 1, "{CPI/20}{LPI/7}{FONT/0}{FR/0}",
    CALL print(calcpos(36,cur_row)),
    "File has been created in the following location.",
    CALL echo("File has been created in the following location."), row + 1,
    cur_row = (cur_row+ 21), row + 1, row + 1,
    "{CPI/20}{LPI/7}{FONT/0}{FR/0}",
    CALL print(calcpos(36,cur_row)), "cer_print:AA_ARABIC_PRINT.DAT",
    CALL echo("cer_print:AA_ARABIC_PRINT.DAT"), row + 1, cur_row = (cur_row+ 21),
    row + 1, row + 1, "{CPI/20}{LPI/7}{FONT/0}{FR/0}",
    CALL print(calcpos(36,cur_row)), "command for printing file where XXX = Printer Name",
    CALL echo("command for printing file where XXX = Printer Name"),
    row + 1, cur_row = (cur_row+ 21), row + 1,
    row + 1, "{CPI/20}{LPI/7}{FONT/0}{FR/0}",
    CALL print(calcpos(36,cur_row)),
    "print /queue = XXX /setup = post cer_print:AA_ARABIC_PRINT.DAT",
    CALL echo("print /queue = XXX /setup = post cer_print:AA_ARABIC_PRINT.DAT"), row + 1,
    cur_row = (cur_row+ 21), row + 1
   WITH nocounter, maxrow = 900, formfeed = post,
    dio = postscript, dio = 29, dioduplex = edge
  ;end select
 ENDIF
 CALL clear(1,1)
 SUBROUTINE format_text(null_index)
   SET format_text_request->raw_text = trim(format_text_request->raw_text,3)
   SET text_length = textlen(format_text_request->raw_text)
   SET format_text_request->temp_str = " "
   FOR (j_text = 1 TO text_length)
     SET temp_char = substring(j_text,1,format_text_request->raw_text)
     IF (temp_char=" ")
      SET temp_char = "^"
     ENDIF
     SET t_number = ichar(temp_char)
     IF (t_number != 10
      AND t_number != 13)
      SET format_text_request->temp_str = concat(format_text_request->temp_str,temp_char)
     ENDIF
     IF (t_number=13)
      SET format_text_request->temp_str = concat(format_text_request->temp_str,"^")
     ENDIF
   ENDFOR
   SET format_text_request->temp_str = replace(format_text_request->temp_str,"^"," ",0)
   SET format_text_request->raw_text = format_text_request->temp_str
   SET format_text_reply->beg_index = 0
   SET format_text_reply->end_index = 0
   SET format_text_reply->qual_cnt = 0
   SET text_len = textlen(format_text_request->raw_text)
   IF ((text_len > format_text_request->chars_per_line))
    WHILE ((text_len > format_text_request->chars_per_line))
      SET wrap_ind = 0
      SET format_text_reply->beg_index = 1
      WHILE (wrap_ind=0)
        SET format_text_reply->end_index = findstring(" ",format_text_request->raw_text,
         format_text_reply->beg_index)
        IF ((format_text_reply->end_index=0))
         SET format_text_reply->end_index = (format_text_request->chars_per_line+ 10)
        ENDIF
        IF ((format_text_reply->beg_index=1)
         AND (format_text_reply->end_index > format_text_request->chars_per_line))
         SET format_text_reply->qual_cnt = (format_text_reply->qual_cnt+ 1)
         IF ((format_text_reply->qual_cnt > format_text_reply->qual_alloc))
          SET format_text_reply->qual_alloc = (format_text_reply->qual_alloc+ 10)
          SET stat = alterlist(format_text_reply->qual,format_text_reply->qual_alloc)
         ENDIF
         SET format_text_reply->qual[format_text_reply->qual_cnt].text_string = substring(1,
          format_text_request->chars_per_line,format_text_request->raw_text)
         SET format_text_request->raw_text = substring((format_text_request->chars_per_line+ 1),(
          text_len - format_text_request->chars_per_line),format_text_request->raw_text)
         SET wrap_ind = 1
        ELSEIF ((format_text_reply->end_index > format_text_request->chars_per_line))
         SET format_text_reply->qual_cnt = (format_text_reply->qual_cnt+ 1)
         IF ((format_text_reply->qual_cnt > format_text_reply->qual_alloc))
          SET format_text_reply->qual_alloc = (format_text_reply->qual_alloc+ 10)
          SET stat = alterlist(format_text_reply->qual,format_text_reply->qual_alloc)
         ENDIF
         SET format_text_reply->qual[format_text_reply->qual_cnt].text_string = substring(1,(
          format_text_reply->beg_index - 1),format_text_request->raw_text)
         SET format_text_request->raw_text = substring(format_text_reply->beg_index,((text_len -
          format_text_reply->beg_index)+ 1),format_text_request->raw_text)
         SET wrap_ind = 1
        ENDIF
        SET format_text_reply->beg_index = (format_text_reply->end_index+ 1)
      ENDWHILE
      SET text_len = textlen(format_text_request->raw_text)
    ENDWHILE
    SET format_text_reply->qual_cnt = (format_text_reply->qual_cnt+ 1)
    IF ((format_text_reply->qual_cnt > format_text_reply->qual_alloc))
     SET format_text_reply->qual_alloc = (format_text_reply->qual_alloc+ 10)
     SET stat = alterlist(format_text_reply->qual,format_text_reply->qual_alloc)
    ENDIF
    SET format_text_reply->qual[format_text_reply->qual_cnt].text_string = format_text_request->
    raw_text
   ELSE
    SET format_text_reply->qual_cnt = (format_text_reply->qual_cnt+ 1)
    IF ((format_text_reply->qual_cnt > format_text_reply->qual_alloc))
     SET format_text_reply->qual_alloc = (format_text_reply->qual_alloc+ 10)
     SET stat = alterlist(format_text_reply->qual,format_text_reply->qual_alloc)
    ENDIF
    SET format_text_reply->qual[format_text_reply->qual_cnt].text_string = format_text_request->
    raw_text
   ENDIF
 END ;Subroutine
 SUBROUTINE inc_format_text(null_index)
  SET format_text_reply->qual_cnt = (format_text_reply->qual_cnt+ 1)
  IF ((format_text_reply->qual_cnt > format_text_reply->qual_alloc))
   SET format_text_reply->qual_alloc = (format_text_reply->qual_alloc+ 10)
   SET stat = alterlist(format_text_reply->qual,format_text_reply->qual_alloc)
  ENDIF
 END ;Subroutine
#subroutines
 SUBROUTINE format_text_ar(null_index)
   SET ptr_items->qual[null_index].text_qual_cnt_a = 0
   SET ptr_items->qual[null_index].text_qual_alloc_a = 20
   SET stat = alterlist(ptr_items->qual[null_index].text_qual_a,ptr_items->qual[null_index].
    text_qual_alloc_a)
   SET ptr_items->qual[null_index].raw_text_size_a = size(ptr_items->qual[null_index].raw_text_a)
   SET t_beg_a = 0
   SET t_beg_white_a = 0
   FOR (k = 1 TO ptr_items->qual[null_index].raw_text_size_a)
    SET t_char_a = substring(k,1,ptr_items->qual[null_index].raw_text_a)
    CASE (ichar(t_char_a))
     OF 10:
     OF 13:
      IF (t_beg_a=0)
       IF (ichar(t_char_a)=13)
        SET ptr_items->qual[null_index].text_qual_cnt_a = (ptr_items->qual[null_index].
        text_qual_cnt_a+ 1)
        IF ((ptr_items->qual[null_index].text_qual_cnt_a > ptr_items->qual[null_index].
        text_qual_alloc_a))
         SET ptr_items->qual[null_index].text_qual_alloc_a = (ptr_items->qual[null_index].
         text_qual_alloc_a+ 1)
         SET stat = alterlist(ptr_items->qual[null_index].text_qual_a,ptr_items->qual[null_index].
          text_qual_alloc_a)
        ENDIF
        SET ptr_items->qual[null_index].text_qual_a[ptr_items->qual[null_index].text_qual_cnt_a].
        line_a = ""
       ENDIF
      ELSE
       SET ptr_items->qual[null_index].text_qual_cnt_a = (ptr_items->qual[null_index].text_qual_cnt_a
       + 1)
       IF ((ptr_items->qual[null_index].text_qual_cnt_a > ptr_items->qual[null_index].
       text_qual_alloc_a))
        SET ptr_items->qual[null_index].text_qual_alloc_a = (ptr_items->qual[null_index].
        text_qual_alloc_a+ 1)
        SET stat = alterlist(ptr_items->qual[null_index].text_qual_a,ptr_items->qual[null_index].
         text_qual_alloc_a)
       ENDIF
       SET ptr_items->qual[null_index].text_qual_a[ptr_items->qual[null_index].text_qual_cnt_a].
       line_a = substring(t_beg_a,(k - t_beg_a),ptr_items->qual[null_index].raw_text_a)
       SET t_beg_a = 0
       SET t_beg_white_a = 0
      ENDIF
     ELSE
      IF (t_beg_a=0)
       SET t_beg_a = k
       IF (t_char_a IN (" ", ",", "-"))
        SET t_beg_white_a = k
       ENDIF
      ELSE
       IF (t_char_a IN (" ", ",", "-"))
        SET t_beg_white_a = k
       ENDIF
       IF (((k - t_beg_a) > 80))
        SET ptr_items->qual[null_index].text_qual_cnt_a = (ptr_items->qual[null_index].
        text_qual_cnt_a+ 1)
        IF ((ptr_items->qual[null_index].text_qual_cnt_a > ptr_items->qual[null_index].
        text_qual_alloc_a))
         SET ptr_items->qual[null_index].text_qual_alloc_a = (ptr_items->qual[null_index].
         text_qual_alloc_a+ 1)
         SET stat = alterlist(ptr_items->qual[null_index].text_qual_a,ptr_items->qual[null_index].
          text_qual_alloc_a)
        ENDIF
        IF (t_beg_white_a=0)
         SET ptr_items->qual[null_index].text_qual_a[ptr_items->qual[null_index].text_qual_cnt_a].
         line_a = substring(t_beg_a,(k - t_beg_a),ptr_items->qual[null_index].raw_text_a)
         SET t_beg_a = k
         IF (t_char_a IN (" ", ",", "-"))
          SET t_beg_white_a = k
         ENDIF
        ELSE
         SET ptr_items->qual[null_index].text_qual_a[ptr_items->qual[null_index].text_qual_cnt_a].
         line_a = substring(t_beg_a,(t_beg_white_a - t_beg_a),ptr_items->qual[null_index].raw_text_a)
         SET t_beg_a = (t_beg_white_a+ 1)
         SET t_beg_white_a = 0
        ENDIF
       ENDIF
      ENDIF
    ENDCASE
   ENDFOR
   IF (t_beg_a)
    SET ptr_items->qual[null_index].text_qual_cnt_a = (ptr_items->qual[null_index].text_qual_cnt_a+ 1
    )
    IF ((ptr_items->qual[null_index].text_qual_cnt_a > ptr_items->qual[null_index].text_qual_alloc_a)
    )
     SET ptr_items->qual[null_index].text_qual_alloc_a = (ptr_items->qual[null_index].
     text_qual_alloc_a+ 1)
     SET stat = alterlist(ptr_items->qual[null_index].text_qual_a,ptr_items->qual[null_index].
      text_qual_alloc_a)
    ENDIF
    SET ptr_items->qual[null_index].text_qual_a[ptr_items->qual[null_index].text_qual_cnt_a].line_a
     = substring(t_beg_a,(k - t_beg_a),ptr_items->qual[null_index].raw_text_a)
   ENDIF
 END ;Subroutine
END GO
