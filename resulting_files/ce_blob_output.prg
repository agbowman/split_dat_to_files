CREATE PROGRAM ce_blob_output
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SET blob_out_detail = fillstring(64000," ")
 SET blob_compressed_trimmed = fillstring(64000," ")
 SET blob_uncompressed = fillstring(64000," ")
 SET blob_rtf = fillstring(64000," ")
 SET blob_out_detail = fillstring(64000," ")
 SET blob_compressed = fillstring(64000," ")
 SET blob_final = fillstring(64000," ")
 SET blob_return_len = 0
 SET blob_return_len2 = 0
 DECLARE ms_outfile = vc WITH protect, constant(concat("cauti_foley_",format(curdate,"YYYYMMDD;;D"),
   ".csv"))
 DECLARE ms_line = vc WITH protect, noconstant(" ")
 SELECT INTO value(ms_outfile)
  ce.event_id, ce.blob_seq_num
  FROM ce_blob ce
  WHERE ce.event_id=2288499858
   AND ce.valid_until_dt_tm > sysdate
  DETAIL
   blob_compressed_trimmed = trim(ce.blob_contents),
   CALL uar_ocf_uncompress(blob_compressed_trimmed,size(blob_compressed_trimmed),blob_uncompressed,
   size(blob_uncompressed),blob_return_len), blob_final = trim(blob_uncompressed),
   blob_final2 = substring(1,30000,blob_final), blob_final2 = replace(blob_final2,char(10),"<ch10>"),
   blob_final2 = replace(blob_final2,char(13),"<ch13>"),
   bobtextlen = textlen(blob_final2)
  WITH nocounter, formfeed = none, format = variable,
   maxcol = 2000, maxrow
 ;end select
END GO
