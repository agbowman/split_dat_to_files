CREATE PROGRAM cps_export_concept
 SELECT INTO build("cps_imp_",trim( $1),"_concept.csv")
  c.concept_identifier, concept_source_mean = c1.cdf_meaning, c.concept_name,
  review_status_mean = c2.cdf_meaning, active_status_mean = c3.cdf_meaning, data_status_mean = c4
  .cdf_meaning
  FROM concept c,
   code_value c1,
   code_value c2,
   code_value c3,
   code_value c4,
   nomenclature n,
   code_value cn,
   (dummyt d  WITH seq = 1)
  PLAN (c)
   JOIN (c1
   WHERE c1.code_value=c.concept_source_cd)
   JOIN (c2
   WHERE c2.code_value=c.review_status_cd)
   JOIN (c3
   WHERE c3.code_value=c.active_status_cd)
   JOIN (c4
   WHERE c4.code_value=c.data_status_cd)
   JOIN (d
   WHERE d.seq=1)
   JOIN (n
   WHERE n.concept_identifier=c.concept_identifier
    AND n.concept_source_cd=c.concept_source_cd
    AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (cn
   WHERE cn.code_value=n.source_vocabulary_cd
    AND cn.cdf_meaning IN ( $1))
  WITH format = pcformat, maxqual(n,1), nocounter
 ;end select
END GO
