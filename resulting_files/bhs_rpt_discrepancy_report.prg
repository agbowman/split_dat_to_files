CREATE PROGRAM bhs_rpt_discrepancy_report
 SELECT INTO "wet_read.doc"
  d = r.updt_dt_tm"@SHORTDATETIME", i = i.acquired_dt_tm"@SHORTDATETIME", acc = trim(i.accession),
  ins = trim(i.institution_name), pid = i.patient_identifier, pname = replace(trim(i.patient_name),
   "^",", ",1),
  sname = i.station_name, r_activity_disp = trim(uar_get_code_display(r.activity_cd)), prname =
  substring(1,30,p.name_full_formatted),
  p_position_disp = trim(uar_get_code_display(p.position_cd)), t = trim(substring(1,100,r.read_text))
  FROM im_acquired_study i,
   rad_init_read r,
   prsnl p
  PLAN (i
   WHERE (i.acquired_dt_tm > (sysdate - 1))
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
   col 10, "Wet Read Discrepancy", row + 3,
   col 10, "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&", row + 1
  HEAD i.accession
   col 10, "Accession nbr: ", i.accession,
   col + 5, ins, row + 1,
   col 10, "Patient:", pname,
   row + 1
  DETAIL
   col 10, d, col + 1,
   prname, " ", r_activity_disp,
   row + 1, col 10, "-",
   t, row + 1
  FOOT  i.accession
   col 10, "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&", row + 1
  WITH nocounter, format, maxcol = 300
 ;end select
 IF (curqual > 0)
  SET spool "ccluserdir:wet_read.doc" "mlhdv1ed2"
  EXECUTE bhs_ma_email_file
  CALL emailfile(concat("wet_read",".doc"),"wetread.doc","naser.sanjar@bhs.org","Wet Read Audit",0)
 ENDIF
END GO
