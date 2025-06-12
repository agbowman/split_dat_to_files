CREATE PROGRAM cps_export_term
 SELECT INTO build("cps_imp_",trim( $1),"_term.csv")
  t.term_identifier, term_status_mean = c1.cdf_meaning, t.active_ind,
  active_status_mean = c2.cdf_meaning, t.active_status_dt_tm, data_status_mean = c3.cdf_meaning,
  concept_source_mean = c4.cdf_meaning, term_source_mean = c5.cdf_meaning
  FROM term t,
   code_value c1,
   code_value c2,
   code_value c3,
   code_value c4,
   code_value c5,
   concept c,
   nomenclature n,
   code_value cn,
   (dummyt d  WITH seq = 1)
  PLAN (t)
   JOIN (c1
   WHERE c1.code_value=t.term_status_cd)
   JOIN (c2
   WHERE c2.code_value=t.active_status_cd)
   JOIN (c3
   WHERE c3.code_value=t.data_status_cd)
   JOIN (c4
   WHERE c4.code_value=t.concept_source_cd)
   JOIN (c5
   WHERE c5.code_value=t.term_source_cd)
   JOIN (c
   WHERE t.concept_identifier=c.concept_identifier
    AND t.concept_source_cd=c.concept_source_cd)
   JOIN (d
   WHERE d.seq=1)
   JOIN (n
   WHERE n.concept_identifier=t.concept_identifier
    AND n.concept_source_cd=t.concept_source_cd
    AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (cn
   WHERE cn.code_value=n.source_vocabulary_cd
    AND cn.cdf_meaning IN ( $1))
  WITH format = pcformat, maxqual(n,1), nocounter
 ;end select
END GO
