CREATE PROGRAM bhs_lab_inprocess_post_dc
 PROMPT
  "Output to File/Printer/MINE" = mine
 DECLARE recurring_op_cd = f8
 SET recurring_op_cd = uar_get_code_by("DISPLAY",71,"Recurring OP")
 DECLARE fin_nbr_type_cd = f8
 SET fin_nbr_type_cd = uar_get_code_by("MEANING",319,"FIN NBR")
 DECLARE radiology_activity_type_cd = f8
 SET radiology_activity_type_cd = uar_get_code_by("MEANING",106,"RADIOLOGY")
 CALL echo(recurring_op_cd)
 CALL echo(fin_nbr_type_cd)
 CALL echo(radiology_activity_type_cd)
 SELECT INTO  $1
  fin = substring(1,15,cnvtalias(ea.alias,ea.alias_pool_cd)), name = substring(1,30,p
   .name_full_formatted), disch_date = substring(1,15,format(e.disch_dt_tm,"MM/DD/YYYY;;D")),
  enc_type = substring(1,20,uar_get_code_display(e.encntr_type_cd)), order_status = substring(1,15,
   uar_get_code_display(o.order_status_cd)), dept_status = substring(1,15,uar_get_code_display(o
    .dept_status_cd)),
  o.order_mnemonic, o.order_id, o.orig_order_dt_tm
  FROM orders o,
   encounter e,
   person p,
   encntr_alias ea
  PLAN (o
   WHERE o.dept_status_cd=9324
    AND o.activity_type_cd=692
    AND o.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND ((e.disch_dt_tm > cnvtdate("11012005")) OR (e.encntr_type_cd=recurring_op_cd)) )
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.encntr_alias_type_cd=fin_nbr_type_cd
    AND cnvtdatetime(curdate,curtime3) BETWEEN ea.beg_effective_dt_tm AND ea.end_effective_dt_tm)
  WITH format, seperator = " "
 ;end select
END GO
