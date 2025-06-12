CREATE PROGRAM cv_response_maint
 PAINT
 SET width = 132
#begin
 CALL text(3,4,"Select a response from the help:")
 SET help =
 SELECT
  c.response_id, c.response_internal_name, c.a2
  FROM cv_response c
  WHERE c.field_type="A"
   AND c.a1 != "<blank>"
   AND c.nomenclature_id=0
  ORDER BY c.response_internal_name
  WITH nocounter
 ;end select
 CALL text(4,1,"Response_id:")
 CALL accept(4,25,"9(11);df")
 SET upd_response_id = curaccept
 CALL text(4,25,cnvtstring(upd_response_id))
 IF (upd_response_id=0)
  GO TO exit_script
 ENDIF
 SET accept = nochange
 SET help =
 SELECT
  format(ar.nomenclature_id,"99999999999;I"), ar.description
  FROM cv_response cr,
   cv_xref x,
   reference_range_factor r,
   alpha_responses ar
  PLAN (cr
   WHERE cr.response_id=upd_response_id)
   JOIN (x
   WHERE x.xref_id=cr.xref_id)
   JOIN (r
   WHERE r.task_assay_cd=x.task_assay_cd)
   JOIN (ar
   WHERE ar.reference_range_factor_id=r.reference_range_factor_id)
  ORDER BY ar.description
  WITH nocounter
 ;end select
 CALL text(5,1,"nomenclature_id:")
 CALL accept(5,25,"9(11);df")
 SET upd_nomenclature_id = curaccept
 CALL text(5,25,cnvtstring(upd_nomenclature_id))
 SET help = off
 UPDATE  FROM cv_response t
  SET t.nomenclature_id = upd_nomenclature_id
  WHERE t.response_id=upd_response_id
  WITH nocounter
 ;end update
 COMMIT
 GO TO begin
#exit_script
END GO
