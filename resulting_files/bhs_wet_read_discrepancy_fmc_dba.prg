CREATE PROGRAM bhs_wet_read_discrepancy_fmc:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT INTO  $1
  d = r.updt_dt_tm"@SHORTDATETIME", i = i.acquired_dt_tm"@SHORTDATETIME", acc = trim(i.accession),
  ins = trim(i.institution_name), pid = i.patient_identifier, pname = replace(trim(i.patient_name),
   "^",", ",1),
  sname = i.station_name, r_activity_disp = trim(uar_get_code_display(r.activity_cd)), prname =
  substring(1,30,p.name_full_formatted),
  p_position_disp = substring(1,10,trim(uar_get_code_display(p.position_cd))), te = substring(1,50,
   trim(r.read_text,3))
  FROM im_acquired_study i,
   rad_init_read r,
   prsnl p
  PLAN (i
   WHERE (i.acquired_dt_tm > (sysdate - 1))
    AND i.institution_name="Franklin Medical Center"
    AND  EXISTS (
   (SELECT
    r2.parent_entity_id
    FROM rad_init_read r2
    WHERE r2.parent_entity_id=i.im_acquired_study_id
     AND r2.activity_cd=64087868.00)))
   JOIN (r
   WHERE r.parent_entity_id=i.im_acquired_study_id)
   JOIN (p
   WHERE p.person_id=r.updt_id)
  ORDER BY i.accession, r.updt_dt_tm
  HEAD REPORT
   col 10, "Wet Read Discrepancy", row + 3
  HEAD i.accession
   col 10, "Accession nbr: ", i.accession,
   col + 5, ins, row + 1,
   col 10, "Patient:", pname,
   row + 1
  DETAIL
   col 10, d, col + 1,
   prname, " ", r_activity_disp,
   row + 1, col 30, "- ",
   te, row + 1
  FOOT  i.accession
   col 10, "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&", row + 1
  WITH nocounter, separator = " ", format,
   maxcol = 300, maxrow = 600
 ;end select
END GO
