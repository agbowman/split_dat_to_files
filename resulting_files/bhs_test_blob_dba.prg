CREATE PROGRAM bhs_test_blob:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE good_blob = vc
 DECLARE print_blob = vc
 DECLARE outbuf = c32768
 DECLARE blobout = vc
 DECLARE retlen = i4
 DECLARE offset = i4
 DECLARE newsize = i4
 DECLARE finlen = i4
 DECLARE xlen = i4
 SELECT INTO  $1
  cb.*
  FROM ce_blob cb
  WHERE cb.event_id=1041572583
   AND cb.valid_until_dt_tm > cnvtdatetime(sysdate)
  ORDER BY cb.event_id, cb.blob_seq_num
  HEAD cb.event_id
   FOR (x = 1 TO (cb.blob_length/ 32768))
    blobout = notrim(concat(notrim(blobout),notrim(fillstring(32768," ")))),
    CALL echo(build("blobout =",blobout))
   ENDFOR
   finlen = mod(cb.blob_length,32768), blobout = notrim(concat(notrim(blobout),notrim(substring(1,
       finlen,fillstring(32768," ")))))
  DETAIL
   retlen = 1, offset = 0, retlen = blobget(outbuf,offset,cb.blob_contents),
   offset = (offset+ retlen)
   IF (retlen != 0)
    xlen = (findstring("ocf_blob",outbuf,1) - 1)
    IF (xlen < 1)
     xlen = retlen
    ENDIF
    good_blob = notrim(concat(notrim(good_blob),notrim(substring(1,xlen,outbuf))))
   ENDIF
  FOOT  cb.event_id
   newsize = 0, good_blob = concat(notrim(good_blob),"ocf_blob"), blob_un = uar_ocf_uncompress(
    good_blob,size(good_blob),blobout,size(blobout),newsize),
   CALL echo(build("blobout = ",blobout)), offset = 0
   WHILE (offset < size(blobout))
     print_blob = trim(substring(offset,32000,blobout))
     IF (size(print_blob) > 0)
      col 0, print_blob, row + 1
     ENDIF
     offset = (offset+ 32000)
   ENDWHILE
  WITH rdbarrayfetch = 1, format = undefined, maxcol = 32100,
   time = 360
 ;end select
END GO
