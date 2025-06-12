CREATE PROGRAM cv_utl_get_nomen:dba
 SET xref_id = 0.0
 SET xref_id = cnvtint( $1)
 SELECT
  *
  FROM cv_xref x,
   reference_range_factor rrf,
   alpha_responses ar,
   nomenclature n
  WHERE x.xref_id=xref_id
   AND rrf.task_assay_cd=x.task_assay_cd
   AND ar.reference_range_factor_id=rrf.reference_range_factor_id
   AND n.nomenclature_id=ar.nomenclature_id
 ;end select
END GO
