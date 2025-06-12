CREATE PROGRAM carry_forward_pref
 PROMPT
  "Output to File/Printer/MINE " = mine
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 15
 ENDIF
 SELECT INTO  $1
  n.active_ind, n.pvc_name, n.pvc_value,
  n.parent_entity_id, a.app_prefs_id, a.prsnl_id,
  position_cdf = uar_get_code_meaning(a.position_cd), position_disp = uar_get_code_display(a
   .position_cd), p.name_full_formatted,
  a.application_number
  FROM name_value_prefs n,
   app_prefs a,
   person p
  PLAN (n)
   JOIN (a
   WHERE n.pvc_name="CARRY*"
    AND a.active_ind=1
    AND n.parent_entity_id=a.app_prefs_id)
   JOIN (p
   WHERE a.prsnl_id=p.person_id)
  ORDER BY a.application_number DESC, a.prsnl_id
  HEAD PAGE
   row + 1, col 2, "Application",
   col 16, "Position", col 38,
   "Name", col 59, "Person ID",
   col 78, "Value/Preference", row + 2
  DETAIL
   name_full_formatted1 = substring(1,20,p.name_full_formatted), pvc_value1 = substring(1,3,n
    .pvc_value), pvc_name1 = substring(1,30,n.pvc_name),
   position_disp1 = substring(1,15,position_disp), col 1, a.application_number,
   col 16, position_disp1, col 32,
   name_full_formatted1, col 56, a.prsnl_id,
   col 76, pvc_value1, col 81,
   pvc_name1, row + 1
  WITH maxrec = 100, format, time = value(maxsecs),
   skipreport = 1
 ;end select
END GO
