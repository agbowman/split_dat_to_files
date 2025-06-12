CREATE PROGRAM cps_next_nom_seq
 SELECT INTO "nl:"
  nextseqnum = seq(nomenclature_seq,nextval)"#################;rp0"
  FROM dual
  DETAIL
   next_code = cnvtreal(nextseqnum)
  WITH format
 ;end select
END GO
