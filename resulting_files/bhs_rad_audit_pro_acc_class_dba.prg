CREATE PROGRAM bhs_rad_audit_pro_acc_class:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT DISTINCT INTO  $1
  orderable = oc.description, accession_class = uar_get_code_display(ps.accession_class_cd),
  order_active_ind = oc.active_ind
  FROM order_catalog oc,
   procedure_specimen_type ps
  PLAN (oc
   WHERE oc.activity_type_cd=711)
   JOIN (ps
   WHERE ps.catalog_cd=oc.catalog_cd)
  ORDER BY orderable
  WITH nocounter, format
 ;end select
END GO
