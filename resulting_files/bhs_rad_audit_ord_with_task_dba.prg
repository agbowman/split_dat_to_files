CREATE PROGRAM bhs_rad_audit_ord_with_task:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT INTO  $OUTDEV
  activity_type = uar_get_code_display(o.activity_type_cd), activity_sub_type = uar_get_code_display(
   o.activity_subtype_cd), p.catalog_cd,
  procedure = uar_get_code_display(p.catalog_cd), catalog_code = p.catalog_cd, task_assay =
  uar_get_code_display(p.task_assay_cd),
  d.mnemonic, d.mnemonic_key_cap, d.strt_assay_id,
  d_task_assay_disp = uar_get_code_display(d.task_assay_cd)
  FROM profile_task_r p,
   order_catalog o,
   discrete_task_assay d
  PLAN (o
   WHERE o.activity_type_cd=711
    AND o.active_ind=1)
   JOIN (p
   WHERE p.catalog_cd=o.catalog_cd
    AND p.catalog_cd != 117223637.00)
   JOIN (d
   WHERE d.task_assay_cd=p.task_assay_cd)
  ORDER BY activity_sub_type
  WITH nocounter, separator = " ", format
 ;end select
END GO
