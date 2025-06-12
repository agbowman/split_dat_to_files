CREATE PROGRAM bhs_wet_read_report_fmc:dba
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 IF (validate(_separator)=0)
  SET _separator = " "
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 15
 ENDIF
 SELECT INTO  $OUTDEV
  i.patient_name, i.accession, i.study_description,
  physician = p.name_full_formatted, r.updt_dt_tm"@SHORTDATETIME", action = uar_get_code_display(r
   .activity_cd),
  r.read_text
  FROM im_acquired_study i,
   rad_init_read r,
   prsnl p
  PLAN (i
   WHERE i.acquired_dt_tm BETWEEN cnvtdatetime((curdate - 7),0) AND cnvtdatetime((curdate - 1),235959
    )
    AND i.institution_name="Franklin Medical Center")
   JOIN (r
   WHERE r.parent_entity_id=i.im_acquired_study_id)
   JOIN (p
   WHERE p.person_id=r.updt_id)
  ORDER BY i.patient_name, i.accession, r.updt_dt_tm
  HEAD REPORT
   m_numlines = 0,
   SUBROUTINE cclrtf_print(par_flag,par_xpixel,par_yoffset,par_numcol,par_blob,par_bloblen,par_check)
     m_output_buffer_len = 0, blob_out = fillstring(30000," "), blob_buf = fillstring(200," "),
     m_linefeed = concat(char(10)), numlines = 0, textindex = 0,
     numcol = par_numcol, whiteflag = 0, yincrement = 12,
     yoffset = 0,
     CALL uar_rtf(par_blob,par_bloblen,blob_out,size(blob_out),m_output_buffer_len,par_flag),
     m_output_buffer_len = minval(m_output_buffer_len,size(trim(blob_out)))
     IF (m_output_buffer_len > 0)
      m_cc = 1
      WHILE (m_cc)
       m_cc2 = findstring(m_linefeed,blob_out,m_cc),
       IF (m_cc2)
        blob_len = (m_cc2 - m_cc)
        IF (blob_len <= par_numcol)
         m_blob_buf = substring(m_cc,blob_len,blob_out), yoffset = (y_pos+ par_yoffset)
         IF (par_check)
          CALL print(calcpos(par_xpixel,yoffset)),
          CALL print(trim(check(m_blob_buf)))
         ELSE
          CALL print(calcpos(par_xpixel,yoffset)),
          CALL print(trim(m_blob_buf))
         ENDIF
         par_yoffset = (par_yoffset+ yincrement), numlines = (numlines+ 1), row + 1
        ELSE
         m_blobbuf = substring(m_cc,blob_len,blob_out),
         CALL cclrtf_printline(par_numcol,blob_out,blob_len,par_check)
        ENDIF
        IF (m_cc2 >= m_output_buffer_len)
         m_cc = 0
        ELSE
         m_cc = (m_cc2+ 1)
        ENDIF
       ELSE
        blob_len = ((m_output_buffer_len - m_cc)+ 1), m_blobbuf = substring(m_cc,blob_len,blob_out),
        CALL cclrtf_printline(par_numcol,blob_out,blob_len,par_check),
        m_cc = 0
       ENDIF
      ENDWHILE
     ENDIF
     m_numlines = numlines
   END ;Subroutine report
   ,
   SUBROUTINE cclrtf_printline(par_numcol,blob_out,blob_len,par_check)
     textindex = 0, numcol = par_numcol, whiteflag = 0,
     printcol = 0, rownum = 0, lastline = 0,
     m_linefeed = concat(char(10))
     WHILE (blob_len > 0)
       IF (blob_len <= par_numcol)
        numcol = blob_len, lastline = 1
       ENDIF
       textindex = (m_cc+ par_numcol)
       IF (lastline=0)
        whiteflag = 0
        WHILE (whiteflag=0)
         IF (((substring(textindex,1,blob_out)=" ") OR (substring(textindex,1,blob_out)=m_linefeed))
         )
          whiteflag = 1
         ELSE
          textindex = (textindex - 1)
         ENDIF
         ,
         IF (((textindex=m_cc) OR (textindex=0)) )
          textindex = (m_cc+ par_numcol), whiteflag = 1
         ENDIF
        ENDWHILE
        numcol = ((textindex - m_cc)+ 1)
       ENDIF
       m_blob_buf = substring(m_cc,numcol,blob_out)
       IF (m_blob_buf > " ")
        numlines = (numlines+ 1), yoffset = (y_pos+ par_yoffset)
        IF (par_check)
         CALL print(calcpos(par_xpixel,yoffset)),
         CALL print(trim(check(m_blob_buf)))
        ELSE
         CALL print(calcpos(par_xpixel,yoffset)),
         CALL print(trim(m_blob_buf))
        ENDIF
        par_yoffset = (par_yoffset+ yincrement), row + 1
       ELSE
        blob_len = 0
       ENDIF
       m_cc = (m_cc+ numcol)
       IF (blob_len > numcol)
        blob_len = (blob_len - numcol)
       ELSE
        blob_len = 0
       ENDIF
     ENDWHILE
   END ;Subroutine report
   ,
   y_pos = 18, printpsheader = 0, col 0,
   "{PS/792 0 translate 90 rotate/}", row + 1,
   SUBROUTINE offset(yval)
     CALL print(format((y_pos+ yval),"###"))
   END ;Subroutine report
   ,
   row + 1, y_val = ((792 - y_pos) - 21), "{PS/newpath 2 setlinewidth 216 ",
   y_val, " moveto 326 0 rlineto 0 42 neg rlineto ", " 326 neg 0 rlineto closepath stroke 216 ",
   y_val, " moveto /}", row + 1,
   "{F/9}{CPI/9}", row + 1,
   CALL print(calcpos(331,(y_pos+ 19))),
   "Wet Read Report", row + 1, row + 1,
   "{F/5}{CPI/11}",
   CALL print(calcpos(36,(y_pos+ 55))), "Report Date:",
   row + 1, "{F/0}{CPI/14}", row + 1,
   CALL print(calcpos(108,(y_pos+ 55))), curdate, row + 1,
   y_pos = (y_pos+ 68)
  HEAD PAGE
   IF (curpage > 1)
    y_pos = 18
   ENDIF
   IF (printpsheader)
    col 0, "{PS/792 0 translate 90 rotate/}", row + 1
   ENDIF
   printpsheader = 1
  HEAD i.patient_name
   IF (((y_pos+ 111) >= 612))
    y_pos = 0, BREAK
   ENDIF
   row + 1, "{F/5}{CPI/11}",
   CALL print(calcpos(36,(y_pos+ 11))),
   "Patient:", row + 1, "{F/0}{CPI/14}",
   CALL print(calcpos(72,(y_pos+ 11))), i.patient_name, row + 1,
   y_pos = (y_pos+ 12)
  HEAD i.accession
   IF (((y_pos+ 111) >= 612))
    y_pos = 0, BREAK
   ENDIF
   row + 1, "{F/5}{CPI/11}",
   CALL print(calcpos(72,(y_pos+ 11))),
   "Accession:", row + 1, "{F/0}{CPI/14}",
   CALL print(calcpos(126,(y_pos+ 11))), i.accession,
   CALL print(calcpos(288,(y_pos+ 11))),
   i.study_description, row + 1, y_pos = (y_pos+ 12)
  HEAD r.updt_dt_tm
   y_pos = (y_pos+ 0)
  DETAIL
   IF (((y_pos+ 97) >= 612))
    y_pos = 0, BREAK
   ENDIF
   action1 = substring(1,15,action), row + 1, "{F/0}{CPI/14}",
   CALL print(calcpos(90,(y_pos+ 11))), r.updt_dt_tm, row + 1,
   CALL print(calcpos(216,(y_pos+ 11))), physician, row + 1,
   CALL print(calcpos(360,(y_pos+ 11))), action1,
   CALL print(calcpos(450,(y_pos+ 11))),
   "Text:",
   CALL cclrtf_print(0,486,11,30,r.read_text,200,1), row + 1,
   y_val = ((792 - y_pos) - 21), "{PS/newpath 1 setlinewidth  648 ", y_val,
   " moveto  719 ", y_val, " lineto stroke 648 ",
   y_val, " moveto/}", y_pos = (y_pos+ (m_numlines * 12)),
   y_pos = (y_pos+ 13)
  FOOT  r.updt_dt_tm
   y_pos = (y_pos+ 0)
  FOOT  i.accession
   y_pos = (y_pos+ 0)
  FOOT  i.patient_name
   y_pos = (y_pos+ 0)
  FOOT PAGE
   y_pos = 546, row + 1, "{F/0}{CPI/14}",
   row + 1,
   CALL print(calcpos(72,(y_pos+ 11))), curprog,
   row + 1,
   CALL print(calcpos(360,(y_pos+ 11))), "Page:",
   row + 1,
   CALL print(calcpos(396,(y_pos+ 11))), curpage"##"
  WITH maxrec = 100, maxcol = 300, maxrow = 500,
   landscape, dio = 08, noheading,
   format = variable, time = value(maxsecs)
 ;end select
END GO
