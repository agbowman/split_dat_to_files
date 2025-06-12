CREATE PROGRAM agc_test_blob:dba
 SELECT
  FROM ce_blob ceb
  WHERE ceb.event_id=875718
  HEAD REPORT
   uncompressed = fillstring(3200," ")
  DETAIL
   outbuffer = ceb.blob_contents, outlen = ceb.blob_length,
   CALL echo(concat("Compressed size is: ",build(outlen))),
   inlen = outlen, iret = uar_ocf_uncompress(outbuffer,inlen,uncompressed,outlen,0), col 0,
   "original text len: ", outlen, row + 1,
   col 0, "Original text: ", uncompressed,
   row + 1
  WITH maxcol = 32010
 ;end select
END GO
