CREATE PROGRAM bhs_prt_large_blob:dba
 PROMPT
  "Enter Blob" = default,
  "Enter Blob Length" = 0
 DECLARE good_blob = vc WITH public
 DECLARE outbuf = c32768
 DECLARE blobout = vc WITH public
 DECLARE retlen = i4
 DECLARE offset = i4
 DECLARE newsize = i4
 DECLARE finlen = i4
 DECLARE xlen = i4
 SELECT INTO "nl:"
  FROM dummyt d
  HEAD REPORT
   FOR (x = 1 TO ( $2/ 32768))
    blobout = notrim(concat(notrim(blobout),notrim(fillstring(32768," ")))),
    CALL echo(build("blobout =",blobout))
   ENDFOR
   finlen = mod( $2,32768), blobout = notrim(concat(notrim(blobout),notrim(substring(1,finlen,
       fillstring(32768," ")))))
  DETAIL
   retlen = 1, offset = 0, retlen = blobget(outbuf,offset, $1),
   offset = (offset+ retlen)
   IF (retlen != 0)
    xlen = (findstring("ocf_blob",outbuf,1) - 1)
    IF (xlen < 1)
     xlen = retlen
    ENDIF
    good_blob = notrim(concat(notrim(good_blob),notrim(substring(1,xlen,outbuf))))
   ENDIF
  FOOT  cb.event_id
   newsize = 0, good_blob = concat(notrim(good_blob),"ocf_blob")
  WITH rdbarrayfetch = 1, time = 360, nocounter
 ;end select
END GO
