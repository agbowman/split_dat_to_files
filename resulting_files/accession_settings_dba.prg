CREATE PROGRAM accession_settings:dba
 IF ((acc_settings->acc_settings_loaded=1))
  GO TO exit_script
 ENDIF
 SET acc_settings->default_site_cd = 0
 SET acc_settings->default_site_prefix = fillstring(5,"0")
 SELECT INTO "nl:"
  a.default_site_cd
  FROM accession_setup a
  PLAN (a
   WHERE a.accession_setup_id=72696.00)
  HEAD REPORT
   an_display = fillstring(40," ")
  DETAIL
   acc_settings->site_code_length = a.site_code_length, acc_settings->julian_sequence_length = a
   .julian_sequence_length, acc_settings->alpha_sequence_length = a.alpha_sequence_length,
   acc_settings->year_display_length = a.year_display_length, acc_settings->default_site_cd = a
   .default_site_cd, acc_settings->acc_settings_loaded = 1
   IF (a.assign_future_days > 0)
    acc_settings->assignment_days = a.assign_future_days
   ELSE
    acc_settings->assignment_days = 1825
   ENDIF
   acc_settings->assignment_dt_tm = datetimeadd(sysdate,acc_settings->assignment_days)
  WITH nocounter
 ;end select
 IF ((acc_settings->default_site_cd > 0))
  SET acc_site_prefix_cd = acc_settings->default_site_cd
  EXECUTE accession_site_code
  SET acc_settings->default_site_prefix = acc_site_prefix
 ENDIF
#exit_script
END GO
