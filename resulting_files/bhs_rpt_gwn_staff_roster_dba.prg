CREATE PROGRAM bhs_rpt_gwn_staff_roster:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE mf_cs88_reference = f8 WITH protect, noconstant(uar_get_code_by("DISPLAYKEY",88,
   "REFERENCEPHYSICIAN"))
 SELECT INTO value( $OUTDEV)
  staff_first_name = substring(1,75,pr.name_first), staff_last_name = substring(1,75,pr.name_last),
  staff_degree = "",
  staff_position = substring(1,75,uar_get_code_display(pr.position_cd)), staff_username = substring(1,
   20,pr.username), staff_username_numeric = substring(3,18,pr.username),
  pn.name_suffix, pn.person_name_id
  FROM prsnl pr,
   person_name pn
  PLAN (pr
   WHERE pr.active_ind=1
    AND pr.end_effective_dt_tm > sysdate
    AND textlen(trim(pr.username,3)) > 0
    AND  NOT (trim(pr.username,3) IN (null, "", " "))
    AND trim(pr.username,3) > " "
    AND trim(pr.username,3) != "TERM*"
    AND  NOT (pr.position_cd IN (mf_cs88_reference)))
   JOIN (pn
   WHERE pn.person_id=pr.person_id)
  ORDER BY pr.name_last
  WITH nocounter, format, separator = " ",
   maxrow = 1
 ;end select
#exit_script
END GO
