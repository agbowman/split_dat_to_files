CREATE PROGRAM bhs_inprocess_labs
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "How many days back do you want to look?" = 5
  WITH outdev, daysback
 SELECT INTO  $OUTDEV
  pat_name = substring(1,30,p.name_full_formatted), acct_num = substring(1,15,ea.alias), ordered_as
   = substring(1,30,o.ordered_as_mnemonic),
  order_status = substring(1,20,uar_get_code_display(o.order_status_cd)), dept_status = substring(1,
   20,uar_get_code_display(o.dept_status_cd)), ordered_date = format(oa.action_dt_tm,"MM/DD/YYYY;;D"),
  o.order_id, o.template_order_flag
  FROM order_action oa,
   orders o,
   encounter e,
   person p,
   encntr_alias ea
  PLAN (oa
   WHERE oa.action_dt_tm > cnvtdatetime((curdate -  $DAYSBACK),0)
    AND oa.action_type_cd=2534)
   JOIN (o
   WHERE o.order_id=oa.order_id
    AND ((o.order_status_cd+ 0)=2548)
    AND ((o.catalog_cd+ 0) IN (877936, 786914, 786907, 786909, 786911,
   907793, 880695, 790869, 790871, 907790,
   2316180, 885181, 949957, 790867, 2316182,
   2440575, 885184)))
   JOIN (e
   WHERE e.encntr_id=o.encntr_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND cnvtdatetime(curdate,curtime3) BETWEEN ea.beg_effective_dt_tm AND ea.end_effective_dt_tm
    AND ea.active_ind=1
    AND ea.encntr_alias_type_cd=1077)
   JOIN (p
   WHERE p.person_id=e.person_id)
  WITH format, separator = " "
 ;end select
END GO
