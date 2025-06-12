CREATE PROGRAM cpm_next_code
 SET site_id = (cnvtreal(logical("SITE_ID")) * 0.1)
 SELECT INTO "nl:"
  nextseqnum = seq(reference_seq,nextval)"#################;rp0"
  FROM dual
  DETAIL
   next_code = (cnvtreal(nextseqnum)+ site_id)
  WITH format
 ;end select
END GO
