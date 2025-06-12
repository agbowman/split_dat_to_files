CREATE PROGRAM bhs_rad_chg_audit_for_sms:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT INTO  $OUTDEV
  b.ext_parent_entity_name, ext_parent_reference_id = uar_get_code_display(b.ext_parent_reference_id),
  b.ext_parent_reference_id,
  b.ext_short_desc, bi_bill_item_type_disp = uar_get_code_display(bi.bill_item_type_cd), bi.key6,
  bi.key7, key1 = uar_get_code_display(bi.key1_id), key2 = uar_get_code_display(bi.key2_id),
  key4 = uar_get_code_display(bi.key4_id)
  FROM bill_item b,
   bill_item_modifier bi
  PLAN (b
   WHERE b.ext_owner_cd=711
    AND b.active_ind=1
    AND b.ext_parent_reference_id > 0)
   JOIN (bi
   WHERE b.bill_item_id=bi.bill_item_id
    AND bi.active_ind=1
    AND bi.key6 != " ")
  ORDER BY bi.key6, b.ext_parent_entity_name, b.ext_parent_reference_id,
   b.ext_short_desc, bi_bill_item_type_disp
  WITH nocounter, separator = " ", format
 ;end select
END GO
