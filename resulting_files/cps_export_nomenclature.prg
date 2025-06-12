CREATE PROGRAM cps_export_nomenclature
 SELECT INTO build("cps_imp_",trim( $1),"_nomen.csv")
  principle_type_mean = c1.cdf_meaning, active_status_mean = c2.cdf_meaning, contributor_system_mean
   = c3.cdf_meaning,
  n.source_string, n.source_identifier, n.string_identifier,
  string_status_mean = c4.cdf_meaning, t.term_identifier, term_source_mean = c5.cdf_meaning,
  language_mean = c6.cdf_meaning, source_vocabulary_mean = c7.cdf_meaning, data_status_mean = c8
  .cdf_meaning,
  n.short_string, n.mnemonic, n.concept_identifier,
  concept_source_mean = c9.cdf_meaning, string_source_mean = c10.cdf_meaning
  FROM nomenclature n,
   code_value c1,
   code_value c2,
   code_value c3,
   code_value c4,
   term t,
   code_value c5,
   code_value c6,
   code_value c7,
   code_value c8,
   code_value c9,
   code_value c10
  PLAN (n
   WHERE n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (c1
   WHERE c1.code_value=n.principle_type_cd)
   JOIN (c2
   WHERE c2.code_value=n.active_status_cd)
   JOIN (c3
   WHERE c3.code_value=n.contributor_system_cd)
   JOIN (c4
   WHERE c4.code_value=n.string_status_cd)
   JOIN (t
   WHERE n.term_id=t.term_id)
   JOIN (c5
   WHERE c5.code_value=t.term_source_cd)
   JOIN (c6
   WHERE c6.code_value=n.language_cd)
   JOIN (c7
   WHERE c7.code_value=n.source_vocabulary_cd
    AND c7.cdf_meaning IN ( $1))
   JOIN (c8
   WHERE c8.code_value=n.data_status_cd)
   JOIN (c9
   WHERE c9.code_value=n.concept_source_cd)
   JOIN (c10
   WHERE c10.code_value=n.string_source_cd)
  WITH format = pcformat, nocounter
 ;end select
END GO
