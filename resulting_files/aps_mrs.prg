CREATE PROGRAM aps_mrs
 RECORD tmptext(
   1 qual[*]
     2 text = vc
 )
 DECLARE format = i2
 DECLARE line_len = i2
 DECLARE outbuffer = c32000
 DECLARE rtftext = c32000
 DECLARE nortftext = c32000
 SET format = 0
 SET line_len = 0
 SUBROUTINE rtf_to_text(rtftext,format,line_len)
   SET all_len = 0
   SET start = 0
   SET len = 0
   SET pos = 0
   SET linecnt = 0
   SET inbuffer = fillstring(32000," ")
   SET outbufferlen = 0
   SET bfl = 0
   SET bfl2 = 1
   SET outbuffer = fillstring(32000," ")
   SET nortftext = fillstring(32000," ")
   SET inbuffer = trim(rtftext)
   CALL uar_rtf2(inbuffer,size(inbuffer),outbuffer,size(outbuffer),outbufferlen,
    bfl)
   SET nortftext = trim(outbuffer)
   SET stat = alterlist(tmptext->qual,0)
   SET crchar = concat(char(13),char(10))
   IF (format > 0)
    SET all_len = cnvtint(size(trim(outbuffer)))
    SET tot_len = 0
    SET start = 1
    SET bigfirst = "Y"
    SET crstart = start
    WHILE (all_len > tot_len)
      SET crpos = crstart
      SET crfirst = "Y"
      SET loaded = "N"
      WHILE ((crpos <= ((crstart+ line_len)+ 1))
       AND loaded="N"
       AND all_len > tot_len)
       IF ((crpos=((crstart+ line_len)+ 1))
        AND crfirst="N")
        SET start = crstart
        SET first = "Y"
        SET pos = ((start+ line_len) - 1)
        IF (bigfirst="Y"
         AND pos >= all_len)
         SET pos = start
        ENDIF
        SET bigfirst = "N"
        WHILE (pos >= start
         AND all_len > tot_len)
          IF (pos=start)
           SET pos = ((start+ line_len) - 1)
           SET linecnt = (linecnt+ 1)
           SET stat = alterlist(tmptext->qual,linecnt)
           SET len = ((pos - start)+ 1)
           SET tmptext->qual[linecnt].text = substring(start,len,outbuffer)
           SET start = (pos+ 1)
           SET crstart = (pos+ 1)
           SET pos = 0
           SET tot_len = ((tot_len+ len) - 1)
           SET loaded = "Y"
          ELSE
           IF (substring(pos,1,outbuffer)=" ")
            SET len = (pos - start)
            IF (cnvtint(size(trim(substring(start,len,outbuffer)))) > 0)
             SET linecnt = (linecnt+ 1)
             SET stat = alterlist(tmptext->qual,linecnt)
             SET tmptext->qual[linecnt].text = substring(start,len,outbuffer)
             SET loaded = "Y"
            ENDIF
            SET start = (pos+ 1)
            SET crstart = (pos+ 1)
            SET pos = 0
            SET tot_len = (tot_len+ len)
           ELSE
            IF (first="Y")
             SET first = "N"
             SET tot_len = (tot_len+ 1)
            ENDIF
            SET pos = (pos - 1)
           ENDIF
          ENDIF
        ENDWHILE
       ELSE
        SET crfirst = "N"
        IF (substring(crpos,1,outbuffer)=crchar)
         SET crlen = (crpos - crstart)
         SET linecnt = (linecnt+ 1)
         SET stat = alterlist(tmptext->qual,linecnt)
         SET tmptext->qual[linecnt].text = substring(crstart,crlen,outbuffer)
         SET loaded = "Y"
         SET crstart = (crpos+ textlen(crchar))
         SET tot_len = (tot_len+ crlen)
        ENDIF
       ENDIF
       SET crpos = (crpos+ 1)
      ENDWHILE
    ENDWHILE
   ENDIF
   SET rtftext = fillstring(32000," ")
   SET inbuffer = fillstring(32000," ")
 END ;Subroutine
 DECLARE outbufmaxsiz = i2
 DECLARE tblobin = c32000
 DECLARE tblobout = c32000
 DECLARE blobin = c32000
 DECLARE blobout = c32000
 SUBROUTINE decompress_text(tblobin)
   SET tblobout = fillstring(32000," ")
   SET blobout = fillstring(32000," ")
   SET outbufmaxsiz = 0
   SET blobin = trim(tblobin)
   CALL uar_ocf_uncompress(blobin,size(blobin),blobout,size(blobout),outbufmaxsiz)
   SET tblobout = blobout
   SET tblobin = fillstring(32000," ")
   SET blobin = fillstring(32000," ")
 END ;Subroutine
 SELECT
  lb.*
  FROM long_blob lb
  WHERE lb.long_blob_id=19294
  DETAIL
   tblobin = lb.long_blob,
   CALL decompress_text(tblobin),
   CALL rtf_to_text(tblobout,1,112)
   FOR (z = 1 TO size(tmptext->qual,5))
     row + 1, col 10, "-------------- signature line = ",
     col + 1, tmptext->qual[z].text
   ENDFOR
 ;end select
END GO
