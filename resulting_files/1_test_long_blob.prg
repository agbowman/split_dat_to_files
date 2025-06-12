CREATE PROGRAM 1_test_long_blob
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 DECLARE longblob_ocfcomp_var = f8 WITH constant(uar_get_code_by("MEANING",120,"OCFCOMP")), protect
 DECLARE longblob_nocomp_var = f8 WITH constant(uar_get_code_by("MEANING",120,"NOCOMP")), protect
 DECLARE longblob_out = vc
 DECLARE output_longblob = vc
 DECLARE longblob_size = i4
 SELECT INTO  $OUTDEV
  c.event_id, l.parent_entity_id, c.compression_cd,
  c_compression_disp = uar_get_code_display(c.compression_cd), l.long_blob, len_longblob = size(l
   .long_blob)
  FROM ce_event_note c,
   long_blob l
  PLAN (c
   WHERE c.compression_cd IN (longblob_nocomp_var, longblob_ocfcomp_var))
   JOIN (l
   WHERE c.ce_event_note_id=l.parent_entity_id
    AND l.parent_entity_name="CE_EVENT_NOTE"
    AND l.active_status_prsnl_id=1
    AND c.event_id IN (1521166351))
  HEAD REPORT
   m_numlines = 0,
   SUBROUTINE cclrtf_print(par_flag,par_startcol,par_numcol,par_blob,par_bloblen,par_check)
     m_output_buffer_len = 0, blob_out = fillstring(32768," "), blob_buf = fillstring(200," "),
     blob_len = 0, m_linefeed = concat(char(10)), textindex = 0,
     numcol = par_numcol, whiteflag = 0,
     CALL uar_rtf(par_blob,par_bloblen,blob_out,size(blob_out),m_output_buffer_len,par_flag),
     m_output_buffer_len = minval(m_output_buffer_len,size(trim(blob_out)))
     IF (m_output_buffer_len > 0)
      m_cc = 1
      WHILE (m_cc > 0)
       m_cc2 = findstring(m_linefeed,blob_out,m_cc),
       IF (m_cc2)
        blob_len = (m_cc2 - m_cc)
        IF (blob_len <= par_numcol)
         m_blob_buf = substring(m_cc,blob_len,blob_out), col par_startcol
         IF (par_check)
          CALL print(trim(check(m_blob_buf)))
         ELSE
          CALL print(trim(m_blob_buf))
         ENDIF
         row + 1
        ELSE
         m_blobbuf = substring(m_cc,blob_len,blob_out),
         CALL cclrtf_printline(par_startcol,par_numcol,m_blobbuf,blob_len,par_check), row + 1
        ENDIF
        IF (m_cc2 >= m_output_buffer_len)
         m_cc = 0
        ELSE
         m_cc = (m_cc2+ 1)
        ENDIF
       ELSE
        blob_len = ((m_output_buffer_len - m_cc)+ 1), m_blobbuf = substring(m_cc,blob_len,blob_out),
        CALL cclrtf_printline(par_startcol,par_numcol,m_blobbuf,blob_len,par_check),
        m_cc = 0
       ENDIF
      ENDWHILE
     ENDIF
   END ;Subroutine report
   ,
   SUBROUTINE cclrtf_printline(par_startcol,par_numcol,blob_out,blob_len,par_check)
     textindex = 0, numcol = par_numcol, whiteflag = 0,
     lastline = 0, m_linefeed = concat(char(10)), m_maxchar = concat(char(128)),
     m_find = 0
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
        col par_startcol
        IF (par_check)
         CALL print(trim(check(m_blob_buf)))
        ELSE
         CALL print(trim(m_blob_buf))
        ENDIF
        row + 1
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
  DETAIL
   longblob_out = notrim(fillstring(32768," ")), output_longblob = notrim(fillstring(32768," "))
   IF (c.compression_cd=longblob_ocfcomp_var)
    uncompsize_longblob = 0, long_blob_un = uar_ocf_uncompress(l.long_blob,len_longblob,longblob_out,
     size(longblob_out),uncompsize_longblob), stat = uar_rtf2(longblob_out,uncompsize_longblob,
     output_longblob,size(output_longblob),longblob_size,
     0),
    output_longblob = substring(1,longblob_size,output_longblob)
   ELSE
    output_longblob = l.long_blob
   ENDIF
   col 05, c.event_id, col 20,
   c_compression_disp, col 30, l.parent_entity_id,
   col 110, l.parent_entity_name, row + 1,
   CALL cclrtf_print(0,13,80,output_longblob,size(output_longblob),1), row + 1
  WITH maxrec = 100, noheading, format = variable,
   maxcol = 3000, maxrow = 1
 ;end select
END GO
