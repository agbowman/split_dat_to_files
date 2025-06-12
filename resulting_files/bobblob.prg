CREATE PROGRAM bobblob
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
 SELECT INTO value("rad_Blob_contents.csv")
  ce.blob_contents, ce.event_id, ce.compression_cd
  FROM ce_blob ce
  WHERE ce.event_id=461433807
  HEAD REPORT
   blob_compressed = ce.blob_contents
  WITH nocounter
 ;end select
 SET blob_compressed_trimmed = trim(blob_compressed)
 SET blob_return_len = 0
 SET blob_return_len2 = 0
 CALL uar_ocf_uncompress(blob_compressed_trimmed,size(blob_compressed_trimmed),blob_uncompressed,size
  (blob_uncompressed),blob_return_len)
 SET blob_final = trim(blob_uncompressed)
 CALL echo(blob_final)
 SET var_output = "rad_Blob_contents.csv"
 EXECUTE jrwblob
 CALL emailfile("rad_Blob_contents.csv","rad_Blob_contents.csv","upendra.aemul@bhs.org",
  "Rad Report Blob Contents",0)
END GO
