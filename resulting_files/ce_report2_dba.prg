CREATE PROGRAM ce_report2:dba
 PAINT
 FOR (myvar = 2 TO 15)
   CALL clear(myvar,2,75)
 ENDFOR
 CALL text(4,2,"Enter output device: ")
 CALL text(5,2,"Enter Source Feed: ")
 CALL text(6,2,"Enter start date: ")
 CALL text(7,2,"Enter end date: ")
 CALL text(8,2,"Enter event display: ")
 CALL text(9,2,"Print blobs (Y/N): ")
 CALL accept(4,23,"p(30);cu","FORMS")
 SET odev = curaccept
 SET help =
 SELECT INTO "nl:"
  c.display_key
  FROM code_value c
  PLAN (c
   WHERE c.code_set=73)
  WITH nocounter
 ;end select
 CALL accept(5,23,"p(40);cu","*")
 SET help = off
 SET cont_source = curaccept
 CALL accept(6,23,"99dpppd9999;c","01-JAN-1900")
 SET sdate = concat(curaccept," 0000")
 CALL accept(7,23,"99dpppd9999;c",format(curdate,"dd-mmm-yyyy;;d"))
 SET edate = concat(curaccept," 2400")
 SET help =
 SELECT INTO "nl:"
  c.display_key
  FROM code_value c
  PLAN (c
   WHERE c.code_set=72
    AND c.display_key=patstring(cnvtupper(curaccept)))
  WITH nocounter
 ;end select
 CALL accept(8,23,"p(40);cup","*")
 SET event_name = curaccept
 SET help = off
 CALL accept(9,23,"p;cu","N"
  WHERE curaccept IN ("Y", "N"))
 SET do_blob = curaccept
 SET comp_cd = 0.0
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  PLAN (c
   WHERE c.code_set=120
    AND c.cdf_meaning="OCFCOMP"
    AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND c.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  DETAIL
   comp_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO trim(odev)
  type = decode(p.seq,"P ",n.seq,"N ",r.seq,
   "R ",b.seq,"B ",br.seq,"BR"), evnt_typ = decode(p.seq,concat(format(c.event_id,"#############;rp0"
     ),"P "),n.seq,concat(format(c.event_id,"#############;rp0"),"N "),r.seq,
   concat(format(c.event_id,"#############;rp0"),"R "),b.seq,concat(format(c.event_id,
     "#############;rp0"),"B "),br.seq,concat(format(c.event_id,"#############;rp0"),"BR")), b
  .valid_until_dt_tm,
  r.string_result_text, c.normal_low, c.normal_high,
  pr.name_full_formatted, p.action_type_cd, cv5.display,
  cv4.display, cv2.display, c.event_start_dt_tm,
  c.event_end_dt_tm, cv3.display, cv1.display,
  c.event_id, c.event_cd, cv.display,
  c.result_val, br.succession_type_cd, br.sub_series_ref_nbr,
  c.series_ref_nbr, b.blob_length, c.contributor_system_cd,
  c.parent_event_id, cv6.display, cv7.display,
  b_text = substring(1,10000,b.blob_contents)
  FROM clinical_event c,
   code_value cv,
   code_value cv1,
   ce_event_prsnl p,
   ce_event_note n,
   ce_string_result r,
   ce_blob_result br,
   (dummyt d  WITH seq = 1),
   ce_blob b,
   prsnl pr,
   code_value cv2,
   code_value cv3,
   code_value cv4,
   code_value cv5,
   code_value cv6,
   code_value cv7
  PLAN (c
   WHERE c.encntr_id=enbr1
    AND c.event_start_dt_tm BETWEEN cnvtdatetime(sdate) AND cnvtdatetime(edate))
   JOIN (cv
   WHERE c.event_cd=cv.code_value
    AND cv.display_key=patstring(event_name))
   JOIN (cv6
   WHERE c.normalcy_cd=cv6.code_value)
   JOIN (cv7
   WHERE c.result_units_cd=cv7.code_value)
   JOIN (cv1
   WHERE c.contributor_system_cd=cv1.code_value
    AND cv1.display_key=patstring(cont_source))
   JOIN (d
   WHERE 1=d.seq)
   JOIN (((p
   WHERE c.event_id=p.event_id)
   JOIN (pr
   WHERE p.action_prsnl_id=pr.person_id)
   JOIN (cv4
   WHERE p.action_type_cd=cv4.code_value)
   ) ORJOIN ((((n
   WHERE c.event_id=n.event_id)
   JOIN (cv2
   WHERE n.note_type_cd=cv2.code_value)
   ) ORJOIN ((((r
   WHERE c.event_id=r.event_id)
   ) ORJOIN ((((br
   WHERE c.event_id=br.event_id)
   JOIN (cv5
   WHERE br.succession_type_cd=cv5.code_value)
   ) ORJOIN ((b
   WHERE c.event_id=b.event_id)
   JOIN (cv3
   WHERE b.compression_cd=cv3.code_value)
   )) )) )) ))
  ORDER BY c.parent_event_id, evnt_typ, cv.display
  HEAD REPORT
   under = fillstring(131,"="), undertoo = fillstring(131,"-")
  HEAD PAGE
   row 1, col 32, "C L I N I C A L   E V E N T   R E P O R T   B Y   E N C O U N T E R",
   row + 1, col 0, "Name: ",
   CALL print(trim(substring(1,100,name_full_formatted))), col 109, " Date: ",
   curdate"dd-mmm-yyyy;;d", row + 1, col 0,
   "Person Id: ", pat_id"#############;r", col 110,
   "Time: ", curtime"hh:mm;;m", row + 1,
   col 0, " Enounter: ", enbr1"#############;r",
   col 110, "Page: ", curpage"###;r",
   row + 1, col 0, under,
   row + 1
  HEAD c.event_id
   IF (row > 51)
    BREAK
   ENDIF
   row + 1, col 0, "    Parent ID: ",
   col 15, c.parent_event_id"############;r", col 40,
   "     Event ID: ", col 55, c.event_id"############;r",
   row + 1, col 0, "     Event CD: ",
   col 15, c.event_cd"############;r", col 40,
   "   Event Disp: ", col 55, cv.display,
   row + 1, col 0, "  Start Dt Tm: ",
   col 15, c.event_start_dt_tm"dd-mmm-yyyy hhmm;;q", col 40,
   "    End Dt Tm: ", c.event_end_dt_tm"dd-mmm-yyyy hhmm;;q", row + 1,
   col 0, "  Cont Sys CD: ", col 15,
   c.contributor_system_cd"############;r", col 40, "     Sys Disp: ",
   col 55, cv1.display, row + 1,
   col 0, "       Result: ", result = substring(1,110,c.result_val),
   result, row + 1, col 0,
   "   Normal Low: ", col 15,
   CALL print(trim(c.normal_low)),
   col 40, "  Normal High: ", col 55,
   CALL print(trim(c.normal_high)), row + 1, col 0,
   " Result Units: ", col 15,
   CALL print(trim(cv7.description)),
   col 40, "  Normalcy CD: ", col 55,
   CALL print(trim(cv6.display)), row + 1, col 0
   IF (c.series_ref_nbr > " ")
    "      Ref Nbr: ", c.series_ref_nbr
   ENDIF
  HEAD evnt_typ
   row + 1, col 0
   IF (type="P ")
    IF (row > 54)
     BREAK
    ENDIF
    col 0, "CE_EVENT_PRSNL Entry", row + 1,
    col 0, "--------------------", row + 1,
    col 0, " Actn Type CD: ", col 15,
    p.action_type_cd"############;r", col 40, "  Action Disp: ",
    col 55, cv4.display, row + 1,
    col 0, "     Prsnl ID: ", col 15,
    p.action_prsnl_id"###########;r", col 40, "         Name: ",
    CALL print(trim(substring(1,100,pr.name_full_formatted))), row + 1, col 0,
    " Action DT TM: ", p.action_dt_tm"dd-mmm-yyyy hhmm;;q", row + 1
   ELSEIF (type="N ")
    IF (row > 57)
     BREAK
    ENDIF
    col 0, "CE_EVENT_NOTE Entry", row + 1,
    col 0, "--------------------", row + 1,
    col 0, " Note Type CD: ", n.note_type_cd"############;r",
    col 40, "    Note Type: ", col 55,
    cv2.display, row + 1
   ELSEIF (type="R ")
    IF (row > 57)
     BREAK
    ENDIF
    col 0, "CE_STRING_RESULT Entry", row + 1,
    col 0, "--------------------", row + 1,
    col 0, "String Result: ", col 15,
    CALL print(trim(substring(1,110,r.string_result_text))), row + 1
   ELSEIF (type="B ")
    IF (row > 54)
     BREAK
    ENDIF
    col 0, "CE_BLOB Entry", row + 1,
    col 0, "--------------------", row + 1,
    col 0, "      Comp CD: ", col 15,
    b.compression_cd"############;r", col 40, " Comp CD Disp: ",
    col 55, cv3.display, row + 1,
    col 0, "  Blob Length: ", col 15,
    b.blob_length"############;r", col 40, "  Valid Until: ",
    b.valid_until_dt_tm"dd-mmm-yyyy hhmm;;q", row + 1
    IF (do_blob="Y")
     IF (b.compression_cd=comp_cd)
      blob_out = fillstring(10000," "), blob_out2 = fillstring(10000," "), blob_out3 = fillstring(
       10000," "),
      blob_ret_len = 0, blob_ret_len2 = 0,
      CALL uar_ocf_uncompress(b_text,10000,blob_out,100000,blob_ret_len),
      CALL uar_rtf(blob_out,blob_ret_len,blob_out2,10000,blob_ret_len2,1), x1 = size(trim(blob_out2)),
      blob_out3 = trim(substring(1,x1,blob_out2),2)
     ELSE
      blob_out3 = fillstring(10000," "), x1 = size(trim(b_text)), blob_out3 = trim(substring(1,(x1 -
        8),b_text),2)
     ENDIF
     mysize = x1, text_line = fillstring(110," "), startpos = 1,
     endpos = 110, done = "F"
     WHILE (done="F")
       endpos = minval(mysize,(startpos+ 110)), numchars = minval(110,((mysize - startpos)+ 1)),
       text_line = substring(startpos,numchars,blob_out3),
       doneit = "F", curpos = numchars, new_pos = findstring("->",text_line)
       IF (new_pos > 0)
        curpos = (new_pos - 1), doneit = "T", text_line = substring(startpos,curpos,blob_out3),
        numchars = (curpos+ 2), endpos = numchars
       ELSE
        WHILE (doneit="F"
         AND endpos < mysize)
          IF (substring(curpos,1,text_line) IN (" ", ",", ".", ":", ";"))
           doneit = "T", numchars = curpos, text_line = substring(startpos,numchars,blob_out3)
          ELSE
           curpos = (curpos - 1)
          ENDIF
        ENDWHILE
       ENDIF
       IF (trim(text_line,2) > " ")
        row + 1, col 0,
        CALL print(trim(text_line))
       ENDIF
       startpos = (startpos+ numchars)
       IF (endpos >= mysize)
        done = "T"
       ENDIF
     ENDWHILE
    ENDIF
   ELSEIF (type="BR")
    IF (row > 57)
     BREAK
    ENDIF
    col 0, "CE_BLOB_RESULT Entry", row + 1,
    col 0, "--------------------", row + 1,
    col 0, "Successn Type: ", br.succession_type_cd,
    col 40, "Suc Type Disp: ", col 55,
    cv5.display, row + 1
   ENDIF
  DETAIL
   row + 0
  FOOT  c.event_id
   col 0, undertoo
  WITH counter, outerjoin = d, maxcol = 10500
 ;end select
END GO
