CREATE PROGRAM bhs_rad_audit_chg:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT INTO  $OUTDEV
  b.bill_item_id, clinical_description = b.ext_description, bi.beg_effective_dt_tm,
  bi_bill_item_type_disp = uar_get_code_display(bi.bill_item_type_cd), bi.end_effective_dt_tm,
  cdm_cpt = bi.key6,
  charge_description = bi.key7
  FROM bill_item b,
   bill_item_modifier bi
  PLAN (b
   WHERE b.ext_owner_cd=711
    AND b.active_ind=1
    AND b.ext_parent_reference_id > 0)
   JOIN (bi
   WHERE b.bill_item_id=bi.bill_item_id
    AND bi.active_ind=1)
  ORDER BY b.ext_parent_entity_name, b.ext_parent_reference_id, b.ext_short_desc,
   bi_bill_item_type_disp
  WITH nocounter, separator = " ", format
 ;end select
END GO
