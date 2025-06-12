CREATE PROGRAM cls_0001
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "prompt2" = ""
  WITH outdev, cdmsched
 SELECT INTO  $1
  b.bill_item_id, b.key1_id, b.key7
  FROM bill_item_modifier b
  WHERE b.key1_id=782118
 ;end select
END GO
