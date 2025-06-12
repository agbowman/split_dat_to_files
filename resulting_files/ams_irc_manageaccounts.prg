CREATE PROGRAM ams_irc_manageaccounts
 EXECUTE ams_define_toolkit_common
 DECLARE script_name = vc WITH protect, constant("AMS_IRC_ACCOUNTMANAGEMENT")
 CALL updtdminfo(script_name)
 SELECT DISTINCT INTO "securityresource.csv"
  p.username, p.name_first, p.name_last,
  p.person_id, status = uar_get_code_display(p.active_status_cd), pn.name_title,
  position = uar_get_code_display(p.position_cd), p.email
  FROM prsnl p,
   person_name pn
  PLAN (p
   WHERE p.active_ind=1)
   JOIN (pn
   WHERE p.person_id=pn.person_id
    AND pn.name_title IN ("Cerner IRC"))
  ORDER BY status, p.username
  WITH nocounter, separator = " ", format
 ;end select
 SET script_ver = "002  09/27/2016  SB8469 Distinct sort fix"
END GO
