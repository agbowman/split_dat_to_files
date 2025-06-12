CREATE PROGRAM bhs_rpt_pha_virt_view_audit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select primary mnemonic: " = 0
  WITH outdev, f_catalog_cd
 SELECT INTO  $OUTDEV
  domain = curdomain, primary_order_name = uar_get_code_display(ocs.catalog_cd), ocs.active_ind,
  order_synonym_name = ocs.mnemonic, mnemonic_type = uar_get_code_display(ocs.mnemonic_type_cd),
  facilities_on_to = uar_get_code_display(ofr.facility_cd),
  update_date = format(ofr.updt_dt_tm,"mm/dd/yy HH:mm;;D"), vv_update_person = p.name_full_formatted
  FROM order_catalog_synonym ocs,
   ocs_facility_r ofr,
   prsnl p
  PLAN (ocs
   WHERE (ocs.catalog_cd= $F_CATALOG_CD)
    AND ocs.active_ind=1)
   JOIN (ofr
   WHERE (ocs.synonym_id= Outerjoin(ofr.synonym_id)) )
   JOIN (p
   WHERE (p.person_id= Outerjoin(ofr.updt_id)) )
  ORDER BY primary_order_name, ocs.mnemonic, facilities_on_to
  WITH format, separator = " ", nocounter
 ;end select
#exit_script
END GO
