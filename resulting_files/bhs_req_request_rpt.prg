CREATE PROGRAM bhs_req_request_rpt
 PROMPT
  "Output to File/Printer/MINE " = mine,
  "Beginning Date: " = "11012005",
  "Ending Date: " = "11302005"
 SELECT INTO  $1
  brrh.req_request_hx_id, o.order_mnemonic, brrh.execute_dt_tm,
  fin = substring(1,12,ea.alias), pat_name = substring(1,30,p.name_full_formatted), script = cv
  .definition
  FROM bhs_req_request_hx brrh,
   bhs_req_request_ord_hx brroh,
   orders o,
   order_catalog oc,
   code_value cv,
   person p,
   encounter e,
   encntr_alias ea,
   prsnl pr
  PLAN (brrh
   WHERE brrh.execute_dt_tm BETWEEN cnvtdatetime(cnvtdate( $2),0) AND cnvtdatetime(cnvtdate( $3),
    235959))
   JOIN (brroh
   WHERE brroh.req_request_hx_id=brrh.req_request_hx_id)
   JOIN (o
   WHERE o.order_id=brroh.order_id)
   JOIN (oc
   WHERE oc.catalog_cd=o.catalog_cd)
   JOIN (cv
   WHERE cv.code_value=oc.requisition_format_cd)
   JOIN (pr
   WHERE pr.person_id=brrh.print_prnl_id)
   JOIN (e
   WHERE e.encntr_id=outerjoin(brroh.encntr_id))
   JOIN (ea
   WHERE ea.encntr_id=outerjoin(e.encntr_id)
    AND ea.encntr_alias_type_cd=outerjoin(1077)
    AND ea.active_ind=outerjoin(1)
    AND ea.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (p
   WHERE p.person_id=brrh.person_id)
  WITH format, separator = " "
 ;end select
END GO
