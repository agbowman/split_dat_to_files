CREATE PROGRAM bhs_aud_chg_batch_rad_de
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "prompt2" = 0
  WITH outdev, bn
 DECLARE count = i4
 SELECT INTO  $OUTDEV
  c.order_id, ord.accession, c.charge_description,
  c.item_quantity, c.service_dt_tm
  FROM interface_charge ic,
   charge c,
   bill_item bi,
   order_radiology ord
  PLAN (ic
   WHERE (ic.batch_num= $BN)
    AND ic.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND ic.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ic.interface_file_id=771304.00)
   JOIN (c
   WHERE c.charge_item_id=ic.charge_item_id)
   JOIN (bi
   WHERE bi.bill_item_id=c.bill_item_id
    AND bi.ext_parent_contributor_cd != 0)
   JOIN (ord
   WHERE ord.order_id=c.order_id)
  ORDER BY ic.service_dt_tm, ic.fin_nbr, ic.prim_cdm
  WITH format, separator = " "
 ;end select
END GO
