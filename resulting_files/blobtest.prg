CREATE PROGRAM blobtest
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SET ocfcd = 0.0
 SET stat = uar_get_meaning_by_codeset(120,"OCFCOMP",1,ocfcd)
 SET blobout = fillstring(32768," ")
 SELECT INTO  $OUTDEV
  tlen = textlen(c.blob_contents), blobin = trim(c.blob_contents)
  FROM ce_blob c,
   dummyt d
  PLAN (c
   WHERE c.compression_cd=ocfcd)
   JOIN (d
   WHERE assign(blobout,fillstring(32768," "))
    AND uar_ocf_uncompress(c.blob_contents,textlen(c.blob_contents),blobout,size(blobout),32768) >= 0
    AND c.event_id=1522967960
    AND blobout="*critical result*")
  HEAD REPORT
   cntr = 0
  DETAIL
   cnt = 1, cntr = (cntr+ 1), col 0,
   "Record:", cntr, bsize = size(trim(blobout)),
   col + 2, bsize, row + 1
   WHILE (cnt < bsize)
     line = substring(cnt,100,blobout), col 25, line,
     row + 1, cnt = (cnt+ 100)
   ENDWHILE
  WITH maxrec = 20, maxcol = 32000, noheading,
   format = variable
 ;end select
END GO
