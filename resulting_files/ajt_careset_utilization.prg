CREATE PROGRAM ajt_careset_utilization
 PROMPT
  "Output to File/Printer/MINE " = mine,
  "Beginning Date: " = "01012005",
  "Ending Date: " = "01312005"
 SELECT INTO  $1
  phys_name = substring(1,30,p.name_full_formatted), care_set = substring(1,30,o.order_mnemonic)
  FROM orders o,
   order_action oa,
   prsnl p
  PLAN (oa
   WHERE oa.action_type_cd=2534
    AND oa.action_dt_tm BETWEEN cnvtdatetime(cnvtdate( $2),0) AND cnvtdatetime(cnvtdate( $3),235959))
   JOIN (o
   WHERE o.order_id=oa.order_id
    AND o.orderable_type_flag=6
    AND o.active_ind=1)
   JOIN (p
   WHERE p.person_id=oa.order_provider_id)
  ORDER BY phys_name, care_set
  HEAD PAGE
   col 1, curprog, col 50,
   "Baystate Health System", row + 1, col 50,
   "Physician Careset Utilization", row + 1, col 1,
   "Physician", col 35, "Care Set",
   col 70, "Count", row + 1
  HEAD phys_name
   col 1, phys_name
  HEAD care_set
   col 35, care_set
  DETAIL
   row + 0
  FOOT  care_set
   cs_count = count(care_set), col 70, cs_count"####",
   row + 1
  FOOT  phys_name
   col 35, "Total:", phys_count = count(care_set),
   col 70, phys_count"####", row + 2
 ;end select
END GO
