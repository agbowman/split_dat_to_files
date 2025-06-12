CREATE PROGRAM ams_user_changes
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Title of users to audit" = "",
  "Lookback Date for Additions and Inactivations" = curdate,
  "" = "Select checkbox and privilege or restriction to audit",
  "Privledge or Restriction audit?" = 0,
  "Privledge or Restriction" = ""
  WITH outdev, title, date,
  text, priv, accts
 EXECUTE ams_define_toolkit_common
 DECLARE script_name = vc WITH protect, constant("AMS_USER_CHANGES")
 DECLARE dir_ind = i4
 SET priv =  $PRIV
 IF (isamsuser(reqinfo->updt_id)=false)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    row 3, col 20, "ERROR: You are not recognized as an approved associate. Operation Denied."
   WITH nocounter
  ;end select
 ENDIF
 CALL updtdminfo(script_name)
 IF (priv=0)
  SELECT DISTINCT INTO  $OUTDEV
   status = uar_get_code_display(p.active_status_cd), p.username, p.name_last,
   p.name_first, pn.name_title, position = uar_get_code_display(p.position_cd),
   p.email, directory_ind = evaluate(e.directory_ind,0,"Uses authview default, could be Y or N (0)",1,
    "Active Directory User (1)",
    - (1),"Not Directory User (-1)"), e.password_change_dt_tm,
   p.beg_effective_dt_tm"@SHORTDATE", p.end_effective_dt_tm"@SHORTDATE", p.updt_dt_tm"@SHORTDATETIME",
   p.person_id
   FROM prsnl p,
    person_name pn,
    ea_user e
   PLAN (p
    WHERE p.updt_dt_tm > cnvtdatetime(cnvtdate( $DATE),0))
    JOIN (pn
    WHERE p.person_id=pn.person_id
     AND pn.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND (pn.name_title= $TITLE))
    JOIN (e
    WHERE outerjoin(p.username)=e.username)
   ORDER BY status, p.username
   WITH nocounter, separator = " ", format
  ;end select
  IF (curqual=0)
   SELECT INTO  $OUTDEV
    FROM dummyt d
    HEAD REPORT
     row 3, col 20, "No users have been updated within the selected date lookback range"
    WITH nocounter
   ;end select
   GO TO exit_script
  ENDIF
 ENDIF
 IF (priv=1)
  SELECT DISTINCT INTO  $OUTDEV
   status = uar_get_code_display(p.active_status_cd), p.username, p.name_last,
   p.name_first, pn.name_title, position = uar_get_code_display(p.position_cd),
   p.email, ea.attribute_name
   FROM prsnl p,
    person_name pn,
    ea_user e,
    ea_user_attribute_reltn eu,
    ea_attribute ea
   PLAN (p)
    JOIN (pn
    WHERE p.person_id=pn.person_id
     AND (pn.name_title= $TITLE))
    JOIN (e
    WHERE p.username=e.username)
    JOIN (eu
    WHERE eu.ea_user_id=e.ea_user_id)
    JOIN (ea
    WHERE ea.ea_attribute_id=eu.ea_attribute_id
     AND ea.attribute_name IN ( $ACCTS))
   ORDER BY status, p.username
   WITH nocounter, separator = " ", format
  ;end select
  IF (curqual=0)
   SELECT INTO  $OUTDEV
    FROM dummyt d
    HEAD REPORT
     row 3, col 20, "No Users have this Privledge or Restriction at this time"
    WITH nocounter
   ;end select
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 SET script_ver = "004  09/28/2016   Added additional titles to audit"
END GO
