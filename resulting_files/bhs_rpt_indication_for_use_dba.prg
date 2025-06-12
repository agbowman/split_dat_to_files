CREATE PROGRAM bhs_rpt_indication_for_use:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date" = "CURDATE",
  "End Date" = "CURDATE",
  "Provider" = "",
  "Location" = ""
  WITH outdev, ms_start_date, ms_end_date,
  ms_provider, ms_facility
 DECLARE mf_antibiotic_inications_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "ANTIBIOTICINDICATIONS"))
 DECLARE mf_strength_dose_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "STRENGTHDOSE"))
 DECLARE mf_strength_dose_unit_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "STRENGTHDOSEUNIT"))
 DECLARE mf_rx_route_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "ROUTEOFADMINISTRATION"))
 DECLARE mf_pharmacy_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"PHARMACY"))
 DECLARE mf_pharmacy_cat_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY")
  )
 DECLARE ms_startdate = vc WITH protect, constant(concat(trim( $MS_START_DATE)," 00:00:00"))
 DECLARE ms_enddate = vc WITH protect, constant(concat(trim( $MS_END_DATE)," 23:59:59"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE ms_facility_clause = vc WITH protect, noconstant("")
 DECLARE ms_provider_clause = vc WITH protect, noconstant("")
 DECLARE mf_bmc_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_bfmc_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_bwh_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_bmlh_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mc_list_check = c1 WITH protect, noconstant(" ")
 DECLARE ml_fac_cnt = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=220
   AND c.cdf_meaning="FACILITY"
   AND c.display_key IN ("BMC", "BFMC", "BWH", "BMLH", "BNH")
  DETAIL
   CASE (c.display_key)
    OF "BMC":
     mf_bmc_cd = c.code_value
    OF "BFMC":
     mf_bfmc_cd = c.code_value
    OF "BWH":
     mf_bwh_cd = c.code_value
    OF "BMLH":
     mf_bmlh_cd = c.code_value
   ENDCASE
  WITH nocounter
 ;end select
 SET mc_list_check = substring(1,1,reflect(parameter(5,0)))
 IF (mc_list_check="L")
  SET ms_facility_clause = " e.loc_facility_cd in ( "
  WHILE (mc_list_check > " ")
    SET ml_fac_cnt = (ml_fac_cnt+ 1)
    SET mc_list_check = substring(1,1,reflect(parameter(5,ml_fac_cnt)))
    IF (mc_list_check > " ")
     SET ms_facility_clause = build(ms_facility_clause,cnvtreal(parameter(5,ml_fac_cnt)),",")
    ENDIF
  ENDWHILE
  SET ms_facility_clause = concat(ms_facility_clause,"0.0)")
 ELSEIF (mc_list_check="C")
  IF (( $MS_FACILITY="ALL"))
   SET ms_facility_clause = " e.loc_facility_cd in (mf_bmc_cd, mf_bfmc_cd, mf_bwh_cd, mf_bmlh_cd)"
  ELSE
   SET ms_facility_clause = build(" e.loc_facility_cd = ",cnvtreal( $MS_FACILITY))
  ENDIF
 ENDIF
 IF (textlen( $MS_PROVIDER) > 1)
  IF (( $MS_PROVIDER="ALL"))
   SET ms_provider_clause = " p2.person_id = o.last_update_provider_id"
  ELSE
   SET ms_provider_clause = build(" p2.person_id = ",cnvtreal( $MS_PROVIDER),
    " and p2.person_id = o.last_update_provider_id")
  ENDIF
 ELSE
  SET ms_provider_clause = " p2.person_id = o.last_update_provider_id"
 ENDIF
 SELECT INTO  $OUTDEV
  patient_name = trim(p.name_full_formatted,3), drug = trim(o.ordered_as_mnemonic,3), dose = concat(
   trim(od2.oe_field_display_value,3)," ",trim(od3.oe_field_display_value,3)),
  route = trim(od4.oe_field_display_value,3), indication = trim(od.oe_field_display_value,3), fin =
  ea.alias,
  mrn = ea2.alias, provider = trim(p2.name_full_formatted,3), facility = trim(uar_get_code_display(e
    .loc_facility_cd),3),
  nurse_unit = trim(uar_get_code_display(e.loc_nurse_unit_cd),3), date = format(o.orig_order_dt_tm,
   ";;q"), count = count(*)
  FROM orders o,
   (left JOIN order_detail od2 ON od2.order_id=o.order_id
    AND od2.oe_field_id=mf_strength_dose_cd
    AND (od2.action_sequence=
   (SELECT
    max(odx2.action_sequence)
    FROM order_detail odx2
    WHERE odx2.order_id=od2.order_id
     AND odx2.oe_field_id=mf_strength_dose_cd
    GROUP BY odx2.order_id, odx2.oe_field_id))),
   (left JOIN order_detail od3 ON od3.order_id=od2.order_id
    AND od3.oe_field_id=mf_strength_dose_unit_cd
    AND (od3.action_sequence=
   (SELECT
    max(odx3.action_sequence)
    FROM order_detail odx3
    WHERE odx3.order_id=od3.order_id
     AND odx3.oe_field_id=mf_strength_dose_unit_cd
    GROUP BY odx3.order_id, odx3.oe_field_id))),
   (left JOIN order_detail od4 ON od4.order_id=od3.order_id
    AND od4.oe_field_id=mf_rx_route_cd
    AND (od4.action_sequence=
   (SELECT
    max(odx4.action_sequence)
    FROM order_detail odx4
    WHERE odx4.order_id=od4.order_id
     AND odx4.oe_field_id=mf_rx_route_cd
    GROUP BY odx4.order_id, odx4.oe_field_id))),
   order_detail od,
   encounter e,
   order_catalog oc,
   person p,
   person p2,
   encntr_alias ea,
   encntr_alias ea2
  PLAN (o
   WHERE o.activity_type_cd=mf_pharmacy_cd
    AND o.catalog_type_cd=mf_pharmacy_cat_cd
    AND o.orig_order_dt_tm BETWEEN cnvtdatetime(ms_startdate) AND cnvtdatetime(ms_enddate))
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_id=mf_antibiotic_inications_cd
    AND (od.action_sequence=
   (SELECT
    max(odx.action_sequence)
    FROM order_detail odx
    WHERE odx.order_id=od.order_id
     AND odx.oe_field_id=mf_antibiotic_inications_cd
    GROUP BY odx.order_id, odx.oe_field_id)))
   JOIN (od2)
   JOIN (od3)
   JOIN (od4)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND parser(ms_facility_clause))
   JOIN (oc
   WHERE oc.catalog_cd=o.catalog_cd)
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (p2
   WHERE parser(ms_provider_clause))
   JOIN (ea
   WHERE ea.encntr_id=o.encntr_id
    AND ea.encntr_alias_type_cd=mf_fin_cd)
   JOIN (ea2
   WHERE ea2.encntr_id=o.encntr_id
    AND ea2.encntr_alias_type_cd=mf_mrn_cd)
  GROUP BY p.name_full_formatted, o.ordered_as_mnemonic, od2.oe_field_display_value,
   od3.oe_field_display_value, od4.oe_field_display_value, od.oe_field_display_value,
   ea.alias, ea2.alias, p2.name_full_formatted,
   e.loc_facility_cd, e.loc_nurse_unit_cd, o.orig_order_dt_tm
  ORDER BY patient_name, drug, indication
  WITH format, separator = " "
 ;end select
#exit_script
END GO
