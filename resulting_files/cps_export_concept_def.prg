CREATE PROGRAM cps_export_concept_def
 SELECT INTO build("cps_imp_",trim( $1),"_con_def.csv")
  cd.definition, source_vocabulary_mean = c1.cdf_meaning, cd.active_ind,
  active_status_mean = c2.cdf_meaning, cd.concept_identifier, concept_source_mean = c3.cdf_meaning
  FROM concept_definition cd,
   code_value c1,
   code_value c2,
   code_value c3,
   concept c,
   (dummyt d  WITH seq = 1),
   nomenclature n,
   code_value cn
  PLAN (cd
   WHERE cd.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (c1
   WHERE c1.code_value=cd.source_vocabulary_cd)
   JOIN (c2
   WHERE c2.code_value=cd.active_status_cd)
   JOIN (c3
   WHERE c3.code_value=cd.concept_source_cd)
   JOIN (c
   WHERE c.concept_identifier=cd.concept_identifier
    AND c.concept_source_cd=cd.concept_source_cd)
   JOIN (d
   WHERE d.seq=1)
   JOIN (n
   WHERE n.concept_identifier=c.concept_identifier
    AND n.concept_source_cd=c.concept_source_cd
    AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (cn
   WHERE cn.code_value=n.source_vocabulary_cd
    AND cn.cdf_meaning IN ( $1))
  WITH format = pc_format, maxqual(n,1), nocounter
 ;end select
END GO
