CREATE PROGRAM cv_get_omf_nomen_src_str_list:dba
 SET reply->status_data.status = "F"
 SET v_cv_count = 0
 IF ((request->val2="STS"))
  SELECT DISTINCT INTO "nl:"
   n.nomenclature_id
   FROM cv_xref x,
    reference_range_factor rrf,
    alpha_responses ar,
    nomenclature n
   PLAN (x
    WHERE x.xref_internal_name IN (concat("ST02_",request->val3), concat("STS03_",request->val3)))
    JOIN (rrf
    WHERE rrf.task_assay_cd=x.task_assay_cd)
    JOIN (ar
    WHERE ar.reference_range_factor_id=rrf.reference_range_factor_id)
    JOIN (n
    WHERE n.nomenclature_id=ar.nomenclature_id)
   ORDER BY n.source_string, n.nomenclature_id
   DETAIL
    v_cv_count = (v_cv_count+ 1), stat = alterlist(reply->datacoll,v_cv_count), reply->datacoll[
    v_cv_count].description = trim(n.source_string),
    reply->datacoll[v_cv_count].currcv = cnvtstring(n.nomenclature_id)
   WITH nocounter
  ;end select
  SET reply->status_data.status = "S"
 ELSE
  SELECT DISTINCT INTO "nl:"
   n.nomenclature_id
   FROM cv_omf_indicator coi,
    reference_range_factor rrf,
    alpha_responses ar,
    nomenclature n
   PLAN (coi
    WHERE (coi.indicator_cd=request->indicator_cd))
    JOIN (rrf
    WHERE rrf.task_assay_cd=coi.task_assay_cd)
    JOIN (ar
    WHERE ar.reference_range_factor_id=rrf.reference_range_factor_id)
    JOIN (n
    WHERE n.nomenclature_id=ar.nomenclature_id)
   ORDER BY n.source_string
   DETAIL
    v_cv_count = (v_cv_count+ 1), stat = alterlist(reply->datacoll,v_cv_count), reply->datacoll[
    v_cv_count].description = trim(n.source_string),
    reply->datacoll[v_cv_count].currcv = cnvtstring(n.nomenclature_id)
   WITH nocounter
  ;end select
  SET reply->status_data.status = "S"
 ENDIF
 SET cv_get_omf_nomen_src_str_list_version = "MOD 002 06/18/04 IH6582"
END GO
