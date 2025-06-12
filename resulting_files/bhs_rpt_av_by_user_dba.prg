CREATE PROGRAM bhs_rpt_av_by_user:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "From Order Review Date" = "CURDATE",
  "Thru Order Review Date" = "CURDATE",
  "Location" = 673936.00,
  "Primaries Option:" = 0,
  "Select primary mnemonic(s):" = 0
  WITH outdev, prompt1, prompt2,
  facility_cd, l_prim_ind, f_catalog_cd
 RECORD temp1(
   1 qual[*]
     2 oid = f8
     2 med = vc
     2 s_synonym = vc
     2 s_order_detail = vc
     2 s_primary = vc
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
     2 dispense_cat = vc
 )
 RECORD m_rec(
   1 qual[*]
     2 f_catalog_cd = f8
     2 c_primary_mnemonic = vc
 )
 DECLARE f_mrn = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"MRN")), protect
 DECLARE f_fin = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR")), protect
 DECLARE mf_route_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "ROUTEOFADMINISTRATION"))
 DECLARE mf_priority_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "PHARMACY ORDER PRIORITY"))
 DECLARE mf_cd16449_dispensecategory = f8 WITH constant(uar_get_code_by("DISPLAYKEY",16449,
   "DISPENSE CATEGORY")), protect
 DECLARE mf_order_action_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6003,"ORDER"))
 DECLARE mf_pharmacy = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE mf_facility_cd = f8 WITH protect, noconstant( $FACILITY_CD)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 IF (findstring("@", $1,1,0) > 0)
  SET email_ind = 1
  SET email_list =  $1
 ELSE
  SET email_ind = 0
 ENDIF
 IF (( $L_PRIM_IND=0))
  SELECT INTO "nl:"
   FROM order_catalog oc
   PLAN (oc
    WHERE oc.catalog_type_cd=mf_pharmacy
     AND oc.active_ind=1)
   ORDER BY cnvtupper(oc.primary_mnemonic)
   HEAD REPORT
    ml_cnt = 0
   DETAIL
    ml_cnt += 1, stat = alterlist(m_rec->qual,ml_cnt), m_rec->qual[ml_cnt].f_catalog_cd = oc
    .catalog_cd,
    m_rec->qual[ml_cnt].c_primary_mnemonic = trim(oc.primary_mnemonic,3)
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM order_catalog oc
   PLAN (oc
    WHERE (oc.catalog_cd= $F_CATALOG_CD)
     AND oc.active_ind=1)
   ORDER BY cnvtupper(oc.primary_mnemonic)
   HEAD REPORT
    ml_cnt = 0
   DETAIL
    ml_cnt += 1, stat = alterlist(m_rec->qual,ml_cnt), m_rec->qual[ml_cnt].f_catalog_cd = oc
    .catalog_cd,
    m_rec->qual[ml_cnt].c_primary_mnemonic = trim(oc.primary_mnemonic,3)
   WITH nocounter
  ;end select
 ENDIF
 SELECT DISTINCT INTO "nl:"
  o.order_id, pr.person_id, o.orig_order_dt_tm,
  o.order_status_cd, ea.alias, ea1.alias
  FROM order_review orr,
   orders o,
   order_catalog_synonym ocs,
   order_action oa,
   prsnl pr,
   encounter e,
   encntr_alias ea,
   encntr_alias ea1
  PLAN (orr
   WHERE orr.updt_dt_tm BETWEEN cnvtdatetime(concat( $PROMPT1," 00:00:00")) AND cnvtdatetime(concat(
      $PROMPT2," 23:59:59"))
    AND orr.review_type_flag=3.0
    AND orr.reviewed_status_flag=1.0)
   JOIN (o
   WHERE o.order_id=orr.order_id
    AND expand(ml_idx,1,size(m_rec->qual,5),o.catalog_cd,m_rec->qual[ml_idx].f_catalog_cd))
   JOIN (ocs
   WHERE ocs.synonym_id=o.synonym_id)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_type_cd=mf_order_action_cd)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND (e.loc_facility_cd= $FACILITY_CD))
   JOIN (pr
   WHERE pr.person_id=orr.review_personnel_id)
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(e.encntr_id))
    AND (ea.encntr_alias_type_cd= Outerjoin(f_fin))
    AND (ea.active_ind= Outerjoin(1)) )
   JOIN (ea1
   WHERE (ea1.encntr_id= Outerjoin(e.encntr_id))
    AND (ea1.encntr_alias_type_cd= Outerjoin(f_mrn))
    AND (ea1.active_ind= Outerjoin(1)) )
  ORDER BY o.orig_order_dt_tm
  HEAD REPORT
   cnt = 0, stat = alterlist(temp1->qual,10)
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(temp1->qual,(cnt+ 9))
   ENDIF
   temp1->qual[cnt].oid = o.order_id, temp1->qual[cnt].med = trim(o.ordered_as_mnemonic), temp1->
   qual[cnt].s_synonym = trim(ocs.mnemonic,3),
   temp1->qual[cnt].s_primary = trim(uar_get_code_display(o.catalog_cd)), temp1->qual[cnt].odate =
   format(o.orig_order_dt_tm,"mm/dd/yy hh:mm;;q"), temp1->qual[cnt].rdate = format(orr.review_dt_tm,
    "mm/dd/yy hh:mm;;q"),
   temp1->qual[cnt].rprsnl = trim(pr.name_full_formatted), temp1->qual[cnt].loc =
   uar_get_code_display(e.loc_nurse_unit_cd), temp1->qual[cnt].tatformatted = format(datetimediff(orr
     .review_dt_tm,o.orig_order_dt_tm),"DD days HH:MM:SS;;Z"),
   temp1->qual[cnt].rtat = cnvtstring(datetimediff(orr.review_dt_tm,o.orig_order_dt_tm,5)), temp1->
   qual[cnt].failed = "", temp1->qual[cnt].s_hna_mnemonic = trim(o.hna_order_mnemonic),
   temp1->qual[cnt].s_tat_mins = cnvtstring(datetimediff(orr.review_dt_tm,o.orig_order_dt_tm,4)),
   temp1->qual[cnt].fin = substring(1,15,ea.alias), temp1->qual[cnt].mrn = substring(1,15,ea1.alias),
   temp1->qual[cnt].s_order_detail = replace(replace(trim(o.order_detail_display_line,3),char(013),
     " "),char(010)," ")
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
  SELECT INTO "nl:"
   qual_s_primary = substring(1,30,temp1->qual[d1.seq].s_primary)
   FROM (dummyt d1  WITH seq = size(temp1->qual,5)),
    order_detail disp
   PLAN (d1)
    JOIN (disp
    WHERE (disp.order_id=temp1->qual[d1.seq].oid)
     AND disp.oe_field_id=mf_cd16449_dispensecategory
     AND disp.action_sequence IN (
    (SELECT
     max(disp1.action_sequence)
     FROM order_detail disp1
     WHERE disp1.order_id=disp.order_id
      AND disp1.oe_field_id=disp.oe_field_id
      AND disp1.oe_field_meaning_id=disp.oe_field_meaning_id
     GROUP BY disp1.order_id)))
   DETAIL
    temp1->qual[d1.seq].dispense_cat = trim(disp.oe_field_display_value,3)
   WITH nocounter
  ;end select
  SELECT INTO  $1
   primary = trim(substring(1,150,temp1->qual[d.seq].s_primary),3), synonym = trim(substring(1,150,
     temp1->qual[d.seq].s_synonym),3), order_detail = trim(substring(1,250,temp1->qual[d.seq].
     s_order_detail),3),
   priority = trim(substring(1,200,temp1->qual[d.seq].s_priority),3), route = trim(substring(1,200,
     temp1->qual[d.seq].s_route),3), dispense_category = trim(substring(1,50,temp1->qual[d.seq].
     dispense_cat),3),
   order_date = trim(substring(1,50,temp1->qual[d.seq].odate),3), pat_loc = trim(substring(1,50,temp1
     ->qual[d.seq].loc),3), fin = trim(substring(1,50,temp1->qual[d.seq].fin),3),
   mrn = trim(substring(1,50,temp1->qual[d.seq].mrn),3), verify_date = trim(substring(1,50,temp1->
     qual[d.seq].rdate),3), verify_by = trim(substring(1,200,temp1->qual[d.seq].rprsnl),3),
   tat = trim(substring(1,50,temp1->qual[d.seq].tatformatted),3), tat_in_mins = trim(substring(1,50,
     temp1->qual[d.seq].s_tat_mins),3)
   FROM (dummyt d  WITH seq = value(size(temp1->qual,5)))
   PLAN (d
    WHERE d.seq > 0)
   WITH separator = " ", format, nocounter
  ;end select
  SET last_mod = "002  07/05/2017    AP046987    SR#416257072- Added inpt psych to prompt"
 ELSE
  SELECT INTO  $1
   report_result = "No records found."
   WITH format, nocounter
  ;end select
 ENDIF
END GO
