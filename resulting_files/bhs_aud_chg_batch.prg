CREATE PROGRAM bhs_aud_chg_batch
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "prompt2" = 0
  WITH outdev, bn
 DECLARE count = i4
 SELECT INTO  $OUTDEV
  FROM interface_charge ic
  PLAN (ic
   WHERE (ic.batch_num= $BN)
    AND ic.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND ic.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ic.interface_file_id IN (592027.00, 594283.00, 596247.00, 596663.00, 771304.00)
    AND ((ic.process_flg+ 0)=999))
  ORDER BY ic.service_dt_tm, ic.fin_nbr, ic.prim_cdm
  HEAD REPORT
   "CIS Daily Total Count", count = 0, row + 1
  HEAD ic.interface_charge_id
   count = (count+ 1), col 0,
   CALL print(count)
  WITH time = 300, nocounter
 ;end select
END GO
