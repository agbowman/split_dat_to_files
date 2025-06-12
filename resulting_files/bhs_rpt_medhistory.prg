CREATE PROGRAM bhs_rpt_medhistory
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin date/time" = "SYSDATE",
  "End date/time" = "SYSDATE"
  WITH outdev, begin_date, end_date
 SELECT INTO  $OUTDEV
  system = uar_get_code_display(gmc.contributor_system_cd), patient = p.name_full_formatted,
  created_date = format(gmc.create_dt_tm,"MM/DD/YYYY HH:MM;;d"),
  ext_service_date = format(gmc.service_dt_tm,"MM/DD/YYYY HH:MM;;d"), ext_written_date = format(gmc
   .written_dt_tm,"MM/DD/YYYY HH:MM;;d"), pwx_formulation = oc.primary_mnemonic,
  pwx_product = ocs.mnemonic, ext_product_description = gmc.product_description, ext_sig = gmc
  .dosage_instructions,
  ext_dispense = gmc.dispense_qty, ext_refill_nbr = gmc.refill_nbr, ext_last_fill_date = format(gmc
   .last_fill_dt_tm,"MM/DD/YYYY HH:MM;;d"),
  ext_orig_refills = gmc.original_refills_txt, ext_days_supply = gmc.days_supply_qty,
  ext_prescriber_name = gmc.prescriber_name,
  pwx_prescriber_name = prsnl.name_full_formatted, ext_prescriber_id = gmc.ext_prescriber_ident,
  ext_prescriber_type = uar_get_code_display(gmc.ext_prescriber_ident_type_cd),
  ext_pharmacy_name = gmc.pharmacy_name, ext_pharmacy_ident = gmc.ext_pharmacy_ident,
  ext_pharmacy_ident_type = uar_get_code_display(gmc.ext_pharmacy_ident_type_cd),
  health_plan = hp.plan_name, updated_version = gmc.version_nbr, product_ident = gmc
  .ext_product_ident,
  product_ident_type = uar_get_code_display(gmc.ext_product_ident_type_cd), catalog_cd = gmc
  .catalog_cd, product_synonym_id = gmc.product_synonym_id,
  prescriber_id = gmc.prescriber_id, pharmacy_identifier = gmc.pharmacy_identifier, gs_med_claim_id
   = gmc.gs_med_claim_id,
  orig_gs_med_claim_id = gmc.orig_gs_med_claim_id
  FROM gs_med_claim gmc,
   person p,
   prsnl prsnl,
   order_catalog_synonym ocs,
   order_catalog oc,
   health_plan hp,
   dummyt d1,
   dummyt d2,
   dummyt d3,
   dummyt d4
  PLAN (gmc
   WHERE gmc.active_ind=1
    AND gmc.updt_dt_tm > cnvtdatetime( $BEGIN_DATE)
    AND gmc.updt_dt_tm < cnvtdatetime( $END_DATE))
   JOIN (p
   WHERE p.person_id=gmc.person_id)
   JOIN (d1)
   JOIN (ocs
   WHERE gmc.product_synonym_id=ocs.synonym_id)
   JOIN (d2)
   JOIN (oc
   WHERE oc.catalog_cd=gmc.catalog_cd)
   JOIN (d3)
   JOIN (prsnl
   WHERE gmc.prescriber_id=prsnl.person_id)
   JOIN (d4)
   JOIN (hp
   WHERE gmc.prescription_health_plan_id=hp.health_plan_id)
  ORDER BY patient, gmc.catalog_cd
  WITH dontcare = d1, dontcare = d2, dontcare = d3,
   dontcare = d4, nocounter, format,
   separator = " "
 ;end select
END GO
