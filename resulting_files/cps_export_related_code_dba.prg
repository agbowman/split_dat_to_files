CREATE PROGRAM cps_export_related_code:dba
 SELECT INTO "cps_imp_related_code.csv"
  source_vocab_mean = c1.cdf_meaning, source_identifier = v.source_identifier, related_vocab_mean =
  c2.cdf_meaning,
  related_identifier = v.related_identifier
  FROM vocab_related_code v,
   code_value c1,
   code_value c2
  PLAN (v)
   JOIN (c1
   WHERE c1.code_set=400
    AND c1.code_value=v.source_vocab_cd)
   JOIN (c2
   WHERE c2.code_set=400
    AND c2.code_value=v.related_vocab_cd)
  ORDER BY v.source_identifier
  WITH nocounter, format = pcformat
 ;end select
END GO
