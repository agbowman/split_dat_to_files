CREATE PROGRAM djh_l_nurse_studs_w_orgs
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 SET _separator = ""
 IF (validate(isodbc,0)=0)
  SET _separator = " "
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 15
 ENDIF
 SELECT DISTINCT INTO  $OUTDEV
  pr.name_full_formatted, pr.username, p.active_ind,
  pr.beg_effective_dt_tm, p.beg_effective_dt_tm, pr.end_effective_dt_tm,
  p.end_effective_dt_tm, p.organization_id, p.person_id,
  p.prsnl_org_reltn_id, o.organization_id, o.org_name,
  pr.active_ind, pr.position_cd, pr_position_disp = uar_get_code_display(pr.position_cd),
  pr.updt_dt_tm, pr.create_dt_tm
  FROM prsnl_org_reltn p,
   organization o,
   prsnl pr
  PLAN (p)
   JOIN (o
   WHERE p.organization_id=o.organization_id)
   JOIN (pr
   WHERE pr.person_id=p.person_id
    AND pr.active_ind=1
    AND pr.position_cd=457
    AND pr.create_dt_tm >= cnvtdatetime(cnvtdate(082105),0))
  ORDER BY pr.name_full_formatted, p.person_id, o.org_name
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
   y_pos = 18,
   SUBROUTINE offset(yval)
     CALL print(format((y_pos+ yval),"###"))
   END ;Subroutine report
   , "{F/0}{CPI/14}",
   lncntr = 0, row + 1, "{F/1}{CPI/11}",
   CALL print(calcpos(185,(y_pos+ 36))), "List All Nurse Students and ORGS", row + 1,
   y_pos = (y_pos+ 50)
  HEAD PAGE
   IF (curpage > 1)
    y_pos = 18
   ENDIF
   pr_position_disp1 = substring(1,30,pr_position_disp),
   CALL print(calcpos(20,(y_pos+ 14))), "Person Name",
   row + 1, y_val = ((792 - y_pos) - 38), "{PS/newpath 2 setlinewidth   20 ",
   y_val, " moveto  556 ", y_val,
   " lineto stroke 20 ", y_val, " moveto/}",
   row + 1, "{F/0}{CPI/14}", fposcd = format(pr.position_cd,"##########"),
   row + 1,
   CALL print(calcpos(175,(y_pos+ 11))), fposcd,
   row + 1,
   CALL print(calcpos(254,(y_pos+ 12))), pr_position_disp1,
   CALL print(calcpos(532,(y_pos+ 12))), "ln #", row + 1,
   y_pos = (y_pos+ 18)
  HEAD p.person_id
   IF (((y_pos+ 77) >= 792))
    y_pos = 0, BREAK
   ENDIF
   bmc = "   ", bmcip = "     ", bhs = "   ",
   cctr = "    ", fmc = "   ", fmcip = "     ",
   mlh = "   ", y_pos = (y_pos+ 12)
  DETAIL
   IF (((y_pos+ 108) >= 792))
    y_pos = 0, BREAK
   ENDIF
   prsnid = format(p.person_id,"#########"), orgid = format(o.organization_id,"#########")
   IF (o.organization_id=589743)
    bhs = "BHS"
   ELSEIF (o.organization_id=589744)
    bmc = "BMC"
   ELSEIF (o.organization_id=589763)
    bmcip = "BMCIP"
   ELSEIF (o.organization_id=738833)
    cctr = "CCTR"
   ELSEIF (o.organization_id=589745)
    fmc = "FMC"
   ELSEIF (o.organization_id=589764)
    fmcip = "FMCIP"
   ELSEIF (o.organization_id=589746)
    mlh = "MLH"
   ENDIF
  FOOT  p.person_id
   IF (((y_pos+ 77) >= 792))
    y_pos = 0, BREAK
   ENDIF
   name_full_formatted1 = substring(1,30,pr.name_full_formatted), username1 = substring(1,12,pr
    .username), row + 1,
   "{F/0}{CPI/14}",
   CALL print(calcpos(20,(y_pos+ 11))), name_full_formatted1,
   CALL print(calcpos(180,(y_pos+ 11))), username1, row + 1,
   CALL print(calcpos(247,(y_pos+ 11))), bhs, row + 1,
   CALL print(calcpos(265,(y_pos+ 11))), bmc, row + 1,
   CALL print(calcpos(282,(y_pos+ 11))), bmcip, row + 1,
   CALL print(calcpos(311,(y_pos+ 11))), cctr, row + 1,
   CALL print(calcpos(334,(y_pos+ 11))), fmc, row + 1,
   CALL print(calcpos(352,(y_pos+ 11))), fmcip, row + 1,
   CALL print(calcpos(382,(y_pos+ 11))), mlh, lncntr = (lncntr+ 1),
   row + 1,
   CALL print(calcpos(496,(y_pos+ 11))), lncntr
  FOOT PAGE
   y_pos = 726, row + 1,
   CALL print(calcpos(25,(y_pos+ 12))),
   curprog, row + 1, "{F/0}{CPI/14}",
   CALL print(calcpos(324,(y_pos+ 11))), "Page:", row + 1,
   CALL print(calcpos(344,(y_pos+ 11))), curpage
  WITH maxcol = 300, maxrow = 500, dio = 08,
   noheading, format = variable, time = value(maxsecs)
 ;end select
END GO
