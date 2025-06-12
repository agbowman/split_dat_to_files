CREATE PROGRAM bed_run_mos_ord_sent
 SET filename = "cer_install:br_order_sentences.csv"
 SET scriptname = "bed_imp_mos_ord_sent"
 DELETE  FROM br_ordsent b
  WHERE b.br_ordsent_id > 0
  WITH nocounter
 ;end delete
 DELETE  FROM br_ordsent_detail b
  WHERE b.br_ordsent_id > 0
  WITH nocounter
 ;end delete
 EXECUTE dm_dbimport filename, scriptname, 5000
END GO
