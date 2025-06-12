CREATE PROGRAM bhs_saved_pf_audit_ops:dba
 SET start_dt = datetimefind(cnvtdatetime((curdate - 3),0),"W","B","B")
 SET end_dt = datetimefind(cnvtdatetime((curdate - 3),0),"W","E","E")
 DECLARE display_line = vc
 SELECT INTO "saved_forms.csv"
  personnel_name = trim(replace(p1.name_full_formatted,","," ",0),3), personnel_position = trim(
   uar_get_code_display(p2.position_cd),3), patient_name = trim(replace(p.name_full_formatted,","," ",
    0),3),
  fin_nbr = trim(ea.alias,3), from_time = trim(format(fa.form_dt_tm,"mm/dd/yyyy hh:mm;;q"),3),
  description = trim(fa.description,3),
  form_status = trim(uar_get_code_display(fa.form_status_cd),3), facility = trim(uar_get_code_display
   (e.loc_facility_cd),3), patient_building = trim(uar_get_code_display(e.loc_building_cd),3),
  patient_nurseunit = trim(uar_get_code_display(e.loc_nurse_unit_cd),3), patient_room = trim(
   uar_get_code_display(e.loc_room_cd),3)
  FROM dcp_forms_activity fa,
   encntr_alias ea,
   encounter e,
   person p,
   person p1,
   prsnl p2,
   dummyt d,
   dummyt d1,
   dummyt d2
  PLAN (fa
   WHERE fa.updt_dt_tm BETWEEN cnvtdatetime(start_dt) AND cnvtdatetime(end_dt)
    AND fa.form_status_cd IN (33, 39))
   JOIN (e
   WHERE e.encntr_id=fa.encntr_id)
   JOIN (ea
   WHERE fa.encntr_id=ea.encntr_id
    AND ea.active_ind=1
    AND ea.encntr_alias_type_cd=1077)
   JOIN (d)
   JOIN (p
   WHERE p.active_ind=1
    AND p.person_id=fa.person_id)
   JOIN (d1)
   JOIN (p1
   WHERE p1.active_ind=1
    AND p1.person_id=fa.updt_id)
   JOIN (d2)
   JOIN (p2
   WHERE p2.active_ind=1
    AND p2.person_id=p1.person_id)
  ORDER BY p.name_full_formatted, ea.alias, fa.form_dt_tm
  HEAD REPORT
   display_line = " ", display_line = build2("User Name",",","Position",",","Patient Name",
    ",","Fin#",",","Form Date",",",
    "Description",",","Status",",","Facility",
    ",","Patient Location",","), col 0,
   display_line, row + 1, display_line = " "
  DETAIL
   IF ( NOT (patient_room IN ("", null)))
    patient_location = build(patient_nurseunit,";",patient_room)
   ELSEIF ( NOT (patient_nurseunit IN ("", null)))
    patient_location = patient_nurseunit
   ELSE
    patient_location = patient_building
   ENDIF
   display_line = build2(personnel_name,",",personnel_position,",",patient_name,
    ",",fin_nbr,",",from_time,",",
    description,",",form_status,",",facility,
    ",",patient_location,","), col 0, display_line,
   row + 1
  WITH nocounter, maxcol = 5000
 ;end select
 EXECUTE bhs_ma_email_file
 CALL emailfile("saved_forms.csv","saved_forms.csv","cisard@bhs.org","Saved Forms",1)
END GO
