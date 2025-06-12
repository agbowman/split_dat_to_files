CREATE PROGRAM bhs_rpt_charge_audit_exrad
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "CODE_SET" = value(0)
  WITH outdev, code
 SELECT INTO  $OUTDEV
  b_ext_owner_disp = uar_get_code_display(b.ext_owner_cd), b.ext_description, cis_tier =
  uar_get_code_display(bi.key1_id),
  cdm = bi.key6, description = bi.key7
  FROM bill_item b,
   bill_item_modifier bi
  PLAN (b
   WHERE b.ext_owner_cd >= 0
    AND b.active_ind=1)
   JOIN (bi
   WHERE b.bill_item_id=bi.bill_item_id
    AND bi.active_ind=1
    AND bi.key6 != " ")
  ORDER BY b.ext_description DESC
  WITH nocounter, separator = " ", format,
   maxre = 10000
 ;end select
END GO
