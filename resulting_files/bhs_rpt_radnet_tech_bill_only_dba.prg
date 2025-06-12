CREATE PROGRAM bhs_rpt_radnet_tech_bill_only:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Batch Number" = 0
  WITH outdev, batch_num
 SELECT INTO  $OUTDEV
  batch_number = ic.batch_num, fin_number = ic.fin_nbr, patient_name = p.name_full_formatted,
  service_date = c.service_dt_tm, accession_number = ord.accession, c.charge_description,
  cdm_number = ic.prim_cdm, c.item_quantity
  FROM interface_file ifi,
   interface_charge ic,
   charge c,
   order_radiology ord,
   person p,
   code_value cv
  PLAN (ifi
   WHERE ifi.description="BHS_RAD_FILE001"
    AND ifi.active_ind=1)
   JOIN (ic
   WHERE ic.interface_file_id=ifi.interface_file_id
    AND ic.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND ic.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND (ic.batch_num= $BATCH_NUM))
   JOIN (c
   WHERE c.charge_item_id=ic.charge_item_id)
   JOIN (ord
   WHERE ord.order_id=c.order_id)
   JOIN (p
   WHERE p.person_id=ic.person_id)
   JOIN (cv
   WHERE ic.department_cd=cv.code_value
    AND cv.code_set=221
    AND cv.display_key != "*MAMMO*"
    AND cv.display_key != "*COMPBREAST*")
  ORDER BY p.name_last_key, c.service_dt_tm, c.charge_description
  WITH format, separator = " "
 ;end select
END GO
