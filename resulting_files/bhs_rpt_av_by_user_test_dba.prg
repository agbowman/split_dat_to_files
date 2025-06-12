CREATE PROGRAM bhs_rpt_av_by_user_test:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "From Order Review Date" = "CURDATE",
  "Thru Order Review Date" = "CURDATE",
  "Location" = "BMC"
  WITH outdev, prompt1, prompt2,
  prompt3
 DECLARE mrn_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"MRN")), protect
 DECLARE fin_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR")), protect
 IF (findstring("@", $1,1,0) > 0)
  SET email_ind = 1
  SET email_list =  $1
  DECLARE dclcom = vc
 ELSE
  SET email_ind = 0
 ENDIF
 DECLARE mf_route_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "ROUTEOFADMINISTRATION"))
 DECLARE mf_priority_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "PHARMACY ORDER PRIORITY"))
 DECLARE mf_order_action_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6003,"ORDER"))
 DECLARE mf_facility_cd = f8 WITH protect, noconstant(0)
 DECLARE num = i4 WITH noconstant(0), public
 DECLARE start = i4 WITH noconstant(1), public
 DECLARE displine = vc
 RECORD temp1(
   1 qual[*]
     2 oid = f8
     2 med = vc
     2 odate = vc
     2 loc = vc
     2 rdate = vc
     2 rprsnl = vc
     2 rtat = vc
     2 failed = vc
     2 tatformatted = vc
     2 s_priority = vc
     2 s_hna_mnemonic = vc
     2 s_route = vc
     2 s_tat_mins = vc
     2 fin = vc
     2 mrn = vc
 )
 RECORD temp2(
   1 qual[*]
     2 tech = vc
     2 tav = c10
     2 tat = c10
 )
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=220
   AND c.cdf_meaning="FACILITY"
   AND (c.display_key= $PROMPT3)
   AND c.active_ind=1
  DETAIL
   mf_facility_cd = c.code_value,
   CALL echo(mf_facility_cd)
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  o.order_id, pr.person_id, o.orig_order_dt_tm,
  o.order_status_cd, ea.alias, ea1.alias
  FROM orders o,
   order_review orr,
   order_action oa,
   prsnl pr,
   encounter e,
   encntr_alias ea,
   encntr_alias ea1
  PLAN (o)
   JOIN (orr
   WHERE orr.order_id=o.order_id
    AND orr.review_dt_tm BETWEEN cnvtdatetime(concat( $PROMPT1," 00:00:00")) AND cnvtdatetime(concat(
      $PROMPT2," 23:59:59"))
    AND orr.review_type_flag=3.0
    AND orr.reviewed_status_flag=1.0)
   JOIN (oa
   WHERE oa.order_id=orr.order_id
    AND oa.action_type_cd=mf_order_action_cd)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND e.loc_facility_cd=mf_facility_cd)
   JOIN (pr
   WHERE pr.person_id=orr.review_personnel_id)
   JOIN (ea
   WHERE ea.encntr_id=outerjoin(e.encntr_id)
    AND ea.encntr_alias_type_cd=outerjoin(fin_var)
    AND ea.active_ind=outerjoin(1))
   JOIN (ea1
   WHERE ea1.encntr_id=outerjoin(e.encntr_id)
    AND ea1.encntr_alias_type_cd=outerjoin(mrn_var)
    AND ea1.active_ind=outerjoin(1))
  ORDER BY o.orig_order_dt_tm
  HEAD REPORT
   cnt = 0, stat = alterlist(temp1->qual,10)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(temp1->qual,(cnt+ 9))
   ENDIF
   temp1->qual[cnt].oid = o.order_id, temp1->qual[cnt].med = trim(o.ordered_as_mnemonic), temp1->
   qual[cnt].odate = format(o.orig_order_dt_tm,"mm/dd/yy hh:mm;;q"),
   temp1->qual[cnt].rdate = format(orr.review_dt_tm,"mm/dd/yy hh:mm;;q"), temp1->qual[cnt].rprsnl =
   trim(pr.name_full_formatted), temp1->qual[cnt].loc = uar_get_code_display(e.loc_nurse_unit_cd),
   temp1->qual[cnt].tatformatted = format(datetimediff(orr.review_dt_tm,o.orig_order_dt_tm),
    "DD days HH:MM:SS;;Z"), temp1->qual[cnt].rtat = cnvtstring(datetimediff(orr.review_dt_tm,o
     .orig_order_dt_tm,5)), temp1->qual[cnt].failed = "",
   temp1->qual[cnt].s_hna_mnemonic = trim(o.hna_order_mnemonic), temp1->qual[cnt].s_tat_mins =
   cnvtstring(datetimediff(orr.review_dt_tm,o.orig_order_dt_tm,4)), temp1->qual[cnt].fin = substring(
    1,15,ea.alias),
   temp1->qual[cnt].mrn = substring(1,15,ea1.alias)
  FOOT REPORT
   stat = alterlist(temp1->qual,cnt)
  WITH nocounter
 ;end select
 IF (size(temp1->qual,5) > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(temp1->qual,5))),
    order_detail od
   PLAN (d
    WHERE d.seq > 0)
    JOIN (od
    WHERE (od.order_id=temp1->qual[d.seq].oid)
     AND od.oe_field_id IN (mf_priority_cd, mf_route_cd))
   ORDER BY od.order_id
   DETAIL
    IF (od.oe_field_id=mf_priority_cd)
     temp1->qual[d.seq].s_priority = trim(od.oe_field_display_value)
    ELSEIF (od.oe_field_id=mf_route_cd)
     temp1->qual[d.seq].s_route = trim(od.oe_field_display_value)
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO  $1
   med = temp1->qual[d.seq].s_hna_mnemonic, priority = temp1->qual[d.seq].s_priority, route = temp1->
   qual[d.seq].s_route,
   order_date = temp1->qual[d.seq].odate, pat_loc = temp1->qual[d.seq].loc, fin = temp1->qual[d.seq].
   fin,
   mrn = temp1->qual[d.seq].mrn, verify_date = temp1->qual[d.seq].rdate, verify_by = temp1->qual[d
   .seq].rprsnl,
   tat = temp1->qual[d.seq].tatformatted, tat_in_mins = temp1->qual[d.seq].s_tat_mins
   FROM (dummyt d  WITH seq = value(size(temp1->qual,5)))
   PLAN (d
    WHERE d.seq > 0)
   WITH nocounter, separator = " ", format
  ;end select
  SET last_mod = "002  07/05/2017    AP046987    SR#416257072- Added inpt psych to prompt"
 ELSE
  SELECT INTO  $1
   report_result = "No records found."
   WITH nocounter, format
  ;end select
 ENDIF
END GO
