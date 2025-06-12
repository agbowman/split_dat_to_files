CREATE PROGRAM bhs_rpt_fut_ord_by_phys:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Physician Last Name" = "",
  "Select Physician" = 0
  WITH outdev, s_phys_search, f_phys_prsnl_id
 DECLARE mf_prov_id = f8 WITH protect, constant(cnvtreal( $F_PHYS_PRSNL_ID))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE mf_future_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"FUTURE"))
 IF (mf_prov_id <= 0.0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    col 0, "Provider is required"
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 SELECT DISTINCT INTO value( $OUTDEV)
  patient_name = trim(p.name_full_formatted,3), dob = trim(format(p.birth_dt_tm,"mm/dd/yyyy;;d"),3),
  order_name = trim(uar_get_code_display(o.catalog_cd),3),
  ordering_provider = trim(pr.name_full_formatted,3), ordering_location = uar_get_code_display(o
   .future_location_facility_cd)
  FROM orders o,
   prsnl pr,
   person p
  PLAN (o
   WHERE o.encntr_id=0.0
    AND o.order_status_cd=mf_future_cd
    AND o.active_ind=1
    AND o.last_update_provider_id=mf_prov_id)
   JOIN (pr
   WHERE pr.person_id=o.last_update_provider_id)
   JOIN (p
   WHERE p.person_id=o.person_id)
  ORDER BY p.name_full_formatted
  WITH nocounter, format, separator = " ",
   maxrow = 1
 ;end select
#exit_script
END GO
