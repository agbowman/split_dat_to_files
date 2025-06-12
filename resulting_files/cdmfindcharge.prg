CREATE PROGRAM cdmfindcharge
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter CDM number with wild card (* )" = ""
  WITH outdev, cdm
 SELECT INTO  $OUTDEV
  order_description = bi.ext_description, cdm = bim.key6, charge_description = bim.key7
  FROM bill_item bi,
   bill_item_modifier bim
  PLAN (bi
   WHERE bi.active_ind=1)
   JOIN (bim
   WHERE bi.bill_item_id=bim.bill_item_id
    AND bim.key6=value( $CDM))
  WITH time = 30, format
 ;end select
END GO
