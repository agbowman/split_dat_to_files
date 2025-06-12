CREATE PROGRAM atr_extract
 SELECT INTO "cclsource:atr_import.csv"
  x = build(a.application_number,",",'"',a.owner,'"',
   ",",'"',a.description,'"',",",
   format(a.active_dt_tm,";;q"),",",a.active_ind,",",format(a.last_localized_dt_tm,";;q"),
   ",",'"',a.text,'"',",",
   format(a.inactive_dt_tm,";;q"),",",a.log_access_ind,",",a.application_ini_ind,
   ",",a.object_name,",",a.direct_access_ind,",",
   a.log_level,",",a.request_log_level,",",a.min_version_required)
  FROM application a
  HEAD REPORT
   y = build("application_number, ","owner, ","app_description, ","app_active_dt_tm, ",
    "app_active_ind, ",
    "last_localized_dt_tm, ","app_text, ","app_inactive_dt_tm, ","log_access_ind, ",
    "application_ini_ind, ",
    "object_name, ","direct_access_ind, ","log_level, ","request_log_level, ","min_version_required"),
   col 0, y
  DETAIL
   row + 1, col 0, x
  WITH maxcol = 1000, noformfeed, maxrow = 1
 ;end select
END GO
