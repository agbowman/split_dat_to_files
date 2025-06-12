CREATE PROGRAM bhs_costcenter_charge_audit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "7 digit costcenter #; use (*) for wildcard" = "*",
  "Activity Type" = 0
  WITH outdev, costcenter, activity
 SELECT INTO  $OUTDEV
  b.ext_child_reference_id, b.ext_description, b_ext_owner_disp = uar_get_code_display(b.ext_owner_cd
   ),
  b_ext_parent_contributor_disp = uar_get_code_display(b.ext_parent_contributor_cd), b.ext_short_desc,
  bi_bill_item_type_disp = uar_get_code_display(bi.bill_item_type_cd),
  bi.key6, bi.key7, bi.end_effective_dt_tm
  FROM bill_item b,
   bill_item_modifier bi
  PLAN (b
   WHERE (b.ext_owner_cd= $3)
    AND b.active_ind=1)
   JOIN (bi
   WHERE b.bill_item_id=bi.bill_item_id
    AND bi.active_ind=1
    AND bi.end_effective_dt_tm > cnvtdatetime(curdate,curtime)
    AND bi.key6=patstring( $2))
  ORDER BY b.ext_parent_entity_name, b.ext_parent_reference_id, b.ext_short_desc,
   bi_bill_item_type_disp DESC
  WITH nocounter, separator = " ", format
 ;end select
END GO
