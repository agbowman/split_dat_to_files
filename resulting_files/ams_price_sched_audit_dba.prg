CREATE PROGRAM ams_price_sched_audit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Audit All" = 0,
  "Select a price schedule" = 0
  WITH outdev, allind, selectpriceschedule
 EXECUTE ams_define_toolkit_common
 DECLARE script_name = c26 WITH constant("AMS_PRICE_SCHED_AUDIT")
 DECLARE dba_position_cd = f8 WITH constant(uar_get_code_by("MEANING",88,"DBA")), protect
 DECLARE name_type_cd = f8 WITH constant(uar_get_code_by("MEANING",213,"PRSNL")), protect
 DECLARE incrementcount = f8 WITH protect
 SET incrementcount = 1
 CALL updtdminfo(script_name,cnvtreal(incrementcount))
 SELECT INTO  $OUTDEV
  organization = o.org_name, price_schedule = ps.price_sched_desc, cost_basis =
  uar_get_code_description(ps.cost_basis_cd),
  formula_flag =
  IF (ps.formula_type_flg=1) "INGREDIENT"
  ELSEIF (ps.formula_type_flg=0) "ORDER"
  ENDIF
  , markup_level =
  IF (ps.markup_level_flg=1) "INGREDIENT"
  ELSEIF (ps.markup_level_flg=0) "ORDER"
  ENDIF
  , apply_markup_to =
  IF (ps.apply_markup_to_flag=1) "PRODUCT UNIT"
  ELSEIF (ps.apply_markup_to_flag=0) "DOSE"
  ENDIF
  ,
  from_cost = format(pr.from_cost,"###############.##;,$RI"), to_cost = format(pr.to_cost,
   "###############.##;,$RI"), mark_up = build2(pr.mark_up,"%"),
  service_fee = format(pr.service_fee,"###############.##;,$RI"), admin_fee = format(pr.admin_fee,
   "###############.##;,$RI"), round_up = format(pr.round_up,"###############.##;,$RI"),
  min_price = format(pr.min_price,"###############.##;,$RI")
  FROM cs_org_reltn pss,
   price_sched ps,
   price_range pr,
   prsnl p,
   organization o,
   prsnl_org_reltn por
  PLAN (p
   WHERE (p.person_id=reqinfo->updt_id))
   JOIN (o
   WHERE p.logical_domain_id=o.logical_domain_id
    AND o.active_ind=1
    AND o.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND o.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3))
   JOIN (por
   WHERE o.organization_id=por.organization_id
    AND por.person_id=p.person_id
    AND por.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND por.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3))
   JOIN (pss
   WHERE pss.organization_id=o.organization_id
    AND pss.active_ind=1
    AND pss.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND pss.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3))
   JOIN (ps
   WHERE pss.key1_id=ps.price_sched_id
    AND (((ps.price_sched_id= $SELECTPRICESCHEDULE)) OR (( $ALLIND=1)))
    AND ps.pharm_type_cd=value(uar_get_code_by("MEANING",4500,"INPATIENT"))
    AND ps.active_ind=1
    AND ps.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ps.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3))
   JOIN (pr
   WHERE ps.price_sched_id=pr.price_sched_id)
  ORDER BY trim(cnvtupper(o.org_name),7), ps.price_sched_desc, pr.from_cost
  WITH nocounter, separator = " ", format
 ;end select
 SET last_mod = "000"
END GO
