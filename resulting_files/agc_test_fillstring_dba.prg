CREATE PROGRAM agc_test_fillstring:dba
 SELECT
  FROM ce_blob ce
  DETAIL
   y = ce.blob_length, blob_out_detail = fillstring(value(y)," "), blob_compressed_trimmed =
   fillstring(value(y)," "),
   blob_uncompressed = fillstring(value(y)," "), blob_rtf = fillstring(value(y)," "), blob_out_detail
    = fillstring(value(y)," "),
   blob_compressed_trimmed = trim(ce.blob_contents), blob_return_len = 0, blob_return_len2 = 0,
   CALL uar_ocf_uncompress(blob_compressed_trimmed,size(blob_compressed_trimmed),blob_uncompressed,
   size(blob_uncompressed),blob_return_len), i = 1
   WHILE (i <= blob_return_len)
    IF (ichar(substring(i,1,blob_uncompressed))=10)
     stat = movestring(" ",1,blob_uncompressed,i,1)
    ELSEIF (ichar(substring(i,1,blob_uncompressed))=13)
     stat = movestring(" ",1,blob_uncompressed,i,1)
    ELSEIF (((ichar(substring(i,1,blob_uncompressed)) < 32) OR (((ichar(substring(i,1,
      blob_uncompressed)) > 127) OR (ichar(substring(i,1,blob_uncompressed))=64)) )) )
     stat = movestring(" ",1,blob_uncompressed,i,1)
    ENDIF
    ,i = (i+ 1)
   ENDWHILE
   blob_out_detail = blob_uncompressed,
   CALL uar_rtf2(blob_uncompressed,blob_return_len,blob_rtf,size(blob_rtf),blob_return_len2,1),
   blob_out_detail = blob_rtf,
   rtf_size = size(blob_rtf), col 0, y"#####",
   col 10, rtf_size, row + 1
 ;end select
END GO
