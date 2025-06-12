CREATE PROGRAM cv_omf_disch_test:dba
 SELECT
  nom.source_string
  FROM cv_case_abstr_data cs,
   nomenclature nom,
   code_value cv,
   cv_xref ref
  WHERE cs.cv_case_id=666120.0
   AND cs.event_cd=ref.event_cd
   AND ref.task_assay_cd=cv.code_value
   AND cv.code_set=14003
   AND cv.cdf_meaning="ACC020AFCAD"
   AND cv.active_ind=1
   AND cs.nomenclature_id=nom.nomenclature_id
 ;end select
END GO
