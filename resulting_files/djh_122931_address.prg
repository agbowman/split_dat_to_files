CREATE PROGRAM djh_122931_address
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 SET _separator = ""
 IF (validate(isodbc,0)=0)
  SET _separator = " "
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 15
 ENDIF
 SELECT INTO  $OUTDEV
  a.active_ind, a.active_status_cd, a_active_status_disp = uar_get_code_display(a.active_status_cd),
  a.active_status_dt_tm, a.active_status_prsnl_id, a.address_format_cd,
  a_address_format_disp = uar_get_code_display(a.address_format_cd), a.address_id, a
  .address_info_status_cd,
  a_address_info_status_disp = uar_get_code_display(a.address_info_status_cd), a.address_type_cd,
  a_address_type_disp = uar_get_code_display(a.address_type_cd),
  a.address_type_seq, a.beg_effective_dt_tm, a.beg_effective_mm_dd,
  a.city, a.comment_txt, a.contact_name,
  a.contributor_system_cd, a_contributor_system_disp = uar_get_code_display(a.contributor_system_cd),
  a.country,
  a.country_cd, a_country_disp = uar_get_code_display(a.country_cd), a.county,
  a.county_cd, a_county_disp = uar_get_code_display(a.county_cd), a.data_status_cd,
  a_data_status_disp = uar_get_code_display(a.data_status_cd), a.data_status_dt_tm, a
  .data_status_prsnl_id,
  a.district_health_cd, a_district_health_disp = uar_get_code_display(a.district_health_cd), a
  .end_effective_dt_tm,
  a.end_effective_mm_dd, a.long_text_id, a.mail_stop,
  a.operation_hours, a.parent_entity_id, a.parent_entity_name,
  a.postal_barcode_info, a.postal_identifier, a.postal_identifier_key,
  a.primary_care_cd, a_primary_care_disp = uar_get_code_display(a.primary_care_cd), a.residence_cd,
  a_residence_disp = uar_get_code_display(a.residence_cd), a.residence_type_cd, a_residence_type_disp
   = uar_get_code_display(a.residence_type_cd),
  a.source_identifier, a.state, a.state_cd,
  a_state_disp = uar_get_code_display(a.state_cd), a.street_addr, a.street_addr2,
  a.street_addr3, a.street_addr4, a.updt_applctx,
  a.updt_cnt, a.updt_dt_tm, a.updt_id,
  a.updt_task, a.zipcode, a.zipcode_key,
  a.zip_code_group_cd, a_zip_code_group_disp = uar_get_code_display(a.zip_code_group_cd)
  FROM address a
  PLAN (a
   WHERE a.active_status_cd=188
    AND ((a.parent_entity_id=6082011) OR (((a.parent_entity_id=10178567) OR (a.parent_entity_id=
   10178870)) )) )
  WITH maxrec = 100, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
