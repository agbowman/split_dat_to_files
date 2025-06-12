CREATE PROGRAM cv_util_cmp_response_nomen:dba
 SELECT
  response_string = r.a1, nomenclature_string = n.source_string, response_nomen_id = r
  .nomenclature_id,
  nomenclature_nomen_id = n.nomenclature_id
  FROM cv_response r,
   nomenclature n,
   alpha_responses ar,
   reference_range_factor rf,
   cv_xref x
  WHERE rf.task_assay_cd=x.task_assay_cd
   AND ar.reference_range_factor_id=rf.reference_range_factor_id
   AND n.nomenclature_id=ar.nomenclature_id
   AND r.xref_id=x.xref_id
   AND r.field_type="A"
   AND cnvtupper(trim(r.a1))=cnvtupper(trim(n.source_string))
  ORDER BY r.a1
 ;end select
END GO
