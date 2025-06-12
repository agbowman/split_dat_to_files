CREATE PROGRAM bhs_rad_chg_audit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT INTO  $OUTDEV
  b.ext_parent_entity_name, b.ext_parent_reference_id, b.ext_child_entity_name,
  b.ext_child_reference_id, b.ext_description, b_ext_owner_disp = uar_get_code_display(b.ext_owner_cd
   ),
  b_ext_parent_contributor_disp = uar_get_code_display(b.ext_parent_contributor_cd), b.ext_short_desc,
  bi_bill_item_type_disp = uar_get_code_display(bi.bill_item_type_cd),
  bi.key1, bi.key1_entity_name, bi.key2,
  bi.key2_entity_name, bi.key4, bi.key4_entity_name,
  bi.key5, bi.key5_entity_name, bi.key5_id,
  bi.key6, bi.key7, key1 = uar_get_code_display(bi.key1_id),
  key2 = uar_get_code_display(bi.key2_id), key4 = uar_get_code_display(bi.key4_id)
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
