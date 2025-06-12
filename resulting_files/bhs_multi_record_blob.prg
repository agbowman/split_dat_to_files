CREATE PROGRAM bhs_multi_record_blob
 DECLARE outbuf = c32768
 DECLARE retlen = i4
 DECLARE offset = i4
 DECLARE finlen = i4
 DECLARE xlen = i4
 SET tempevent_id =  $1
 CALL echo(build("$1 tempevent_id= ",tempevent_id))
 SELECT INTO "nl:"
  cb.event_id, cb.blob_seq_num, cb.blob_length,
  cb.valid_from_dt_tm, cb.valid_until_dt_tm
  FROM ce_blob cb
  WHERE (cb.event_id= $1)
   AND cb.valid_from_dt_tm < cnvtdatetime(curdate,curtime3)
   AND cb.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
  ORDER BY cb.event_id, cb.blob_seq_num
  HEAD cb.event_id
   FOR (x1 = 1 TO (cb.blob_length/ 32768))
    blobout_big = notrim(concat(notrim(blobout_big),notrim(fillstring(32768," ")))),
    CALL echo("blobout_big =",size(blobout_big))
   ENDFOR
   finlen = mod(cb.blob_length,32768), blobout_big = notrim(concat(notrim(blobout_big),notrim(
      substring(1,finlen,fillstring(32768," ")))))
  DETAIL
   retlen = 1, offset = 0
   WHILE (retlen > 0)
     retlen = blobget(outbuf,offset,cb.blob_contents), offset = (offset+ retlen),
     CALL echo(build("offset >>> ",offset)),
     CALL echo(build("retlen >>> ",retlen))
     IF (retlen != 0)
      xlen = (findstring("ocf_blob",outbuf,1) - 1)
      IF (xlen < 1)
       xlen = retlen
      ENDIF
      good_blob = notrim(concat(notrim(good_blob),notrim(substring(1,xlen,outbuf))))
     ENDIF
   ENDWHILE
  FOOT  cb.event_id
   good_blob = concat(notrim(good_blob),"ocf_blob"),
   CALL echo(build("good_blob% %%%% ",size(good_blob)))
  WITH maxcol = 32100, rdbarrayfetch = 1, format = undefined
 ;end select
END GO
