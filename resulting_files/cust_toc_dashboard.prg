CREATE PROGRAM cust_toc_dashboard
 PROMPT
  "Please enter the output format" = "MINE"
 DECLARE external_referral_cd = f8 WITH noconstant(uar_get_code_by("DISPLAYKEY",106,
   "EXTERNALREFERRAL"))
 DECLARE fin_nbr_cd = f8 WITH noconstant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE lf = vc
 SET lf = char(10)
 DECLARE cr = vc
 SET cr = char(13)
 DECLARE tab = vc
 SET tab = char(9)
 SELECT INTO  $1
  fin = substring(1,10,ea.alias), disch_dt_tm = format(e.disch_dt_tm,"MM/DD/YYYY;;D"),
  ordering_provider = substring(1,45,p.name_full_formatted),
  field = od.oe_field_meaning, field_value = od.oe_field_display_value, referring_to_prsnl_id =
  cnvtstring(od.oe_field_value)
  FROM orders o,
   order_detail od,
   prsnl p,
   encounter e,
   encntr_alias ea
  PLAN (o
   WHERE o.updt_dt_tm BETWEEN cnvtdatetime("01-JAN-2025 00:00:00") AND cnvtdatetime(curdate,235959)
    AND o.activity_type_cd=external_referral_cd
    AND o.active_ind=1)
   JOIN (od
   WHERE od.order_id=o.order_id)
   JOIN (p
   WHERE p.person_id=o.active_status_prsnl_id)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=fin_nbr_cd)
  ORDER BY e.disch_dt_tm
  HEAD REPORT
   col 0, "FIN", tab,
   col + 1, "Disch Date", tab,
   col + 1, "Ordering Provider", tab,
   col + 1, "OE Field Header", tab,
   col + 1, "OE Field Value", tab,
   col + 1, "Referring Person_Id", row + 1
  DETAIL
   oe_field_disp_val = replace(field_value,cr,""), oe_field_disp_val = replace(field_value,lf,""),
   col 0,
   fin, col + 1, tab,
   col + 1, disch_dt_tm, col + 1,
   tab, col + 1, ordering_provider,
   col + 1, tab, col + 1,
   field, col + 1, tab,
   col + 1, oe_field_disp_val, col + 1,
   tab, col + 1, referring_to_prsnl_id,
   row + 1
  WITH nocounter, maxcol = 600, noformfeed
 ;end select
END GO
