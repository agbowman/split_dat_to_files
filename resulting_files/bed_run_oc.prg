CREATE PROGRAM bed_run_oc
 SET filename = "CER_INSTALL:ps_oc.csv"
 SET scriptname = "bed_ens_oc_ps"
 DELETE  FROM br_auto_order_catalog b
  WHERE ((b.concept_cki="  *") OR (b.concept_cki=null))
  WITH nocounter
 ;end delete
 SELECT INTO "NL:"
  FROM br_auto_order_catalog b
  WHERE b.concept_cki="CERNER!ADN4jQEB/mnFuIYQn4waeg"
  WITH nocounter
 ;end select
 IF (curqual > 1)
  DELETE  FROM br_auto_order_catalog b
   WHERE b.concept_cki="CERNER!ADN4jQEB/mnFuIYQn4waeg"
   WITH nocounter
  ;end delete
 ENDIF
 SELECT INTO "NL:"
  FROM br_auto_order_catalog b
  WHERE b.concept_cki="CERNER!AHi9DQD9dnCFDJekn4waeg"
  WITH nocounter
 ;end select
 IF (curqual > 1)
  DELETE  FROM br_auto_order_catalog b
   WHERE b.concept_cki="CERNER!AHi9DQD9dnCFDJekn4waeg"
   WITH nocounter
  ;end delete
 ENDIF
 DELETE  FROM br_auto_oc_synonym b
  WHERE b.synonym_id > 0
  WITH nocounter
 ;end delete
 DELETE  FROM br_other_names
  WHERE ((parent_entity_name="CODE_VALUE") OR (parent_entity_name="BR_AUTO_ORDER_CATALOG"))
  WITH nocounter
 ;end delete
 DELETE  FROM br_auto_oc_dta
  WHERE task_assay_cd > 0
  WITH nocounter
 ;end delete
 EXECUTE bed_dm_dbimport filename, scriptname, 10000
END GO
