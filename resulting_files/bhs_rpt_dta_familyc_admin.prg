CREATE PROGRAM bhs_rpt_dta_familyc_admin
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE mf_picu_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",220,"PICU")), protect
 DECLARE mf_pic_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",220,"PIC")), protect
 DECLARE pcp1 = vc
 DECLARE status1 = vc
 DECLARE pcp_cd = f8 WITH constant(uar_get_code_by("meaning",333,"PCP")), protect
 DECLARE attend_cd = f8 WITH constant(uar_get_code_by("meaning",333,"ATTENDDOC")), protect
 SET famcr = uar_get_code_by("DISPLAYKEY",14003,"FAMILYCENTEREDROUNDS")
 SELECT INTO "familycenter.dat"
  unit = uar_get_code_display(e.loc_facility_cd), nurse_unit = uar_get_code_display(e
   .loc_nurse_unit_cd), room = uar_get_code_display(e.loc_room_cd),
  p.name_full_formatted, dr_relation = uar_get_code_display(epr.encntr_prsnl_r_cd), pcp = pn1
  .name_full_formatted,
  attending = pn.name_full_formatted, ea.alias, e.disch_dt_tm,
  ce2.event_cd, ce2.event_title_text, ce2.result_val,
  ce2.event_tag
  FROM dcp_forms_ref d,
   dcp_forms_activity df,
   dcp_forms_activity_comp dfac,
   clinical_event ce,
   clinical_event ce2,
   person p,
   encntr_prsnl_reltn epr,
   encntr_prsnl_reltn epr1,
   prsnl pn,
   prsnl pn1,
   encounter e,
   encntr_alias ea
  PLAN (d
   WHERE d.dcp_forms_ref_id IN (1153761.00, 96853429, 642600, 96769184.00, 1249183.00)
    AND d.active_ind=1)
   JOIN (df
   WHERE df.dcp_forms_ref_id=d.dcp_forms_ref_id
    AND df.form_dt_tm BETWEEN cnvtdatetime((curdate - 1),curtime3) AND cnvtdatetime(curdate,curtime3)
   )
   JOIN (e
   WHERE e.encntr_id=df.encntr_id
    AND ((e.disch_dt_tm+ 0)=null)
    AND ((e.loc_facility_cd+ 0)=673936.00)
    AND  NOT (((e.loc_nurse_unit_cd+ 0) IN (mf_picu_cd, mf_pic_cd))))
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=1079)
   JOIN (dfac
   WHERE dfac.dcp_forms_activity_id=df.dcp_forms_activity_id
    AND dfac.component_cd=10891.00)
   JOIN (ce
   WHERE ce.parent_event_id=dfac.parent_entity_id
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (ce2
   WHERE ce.event_id=ce2.parent_event_id
    AND ce2.result_status_cd IN (25.00, 34.00, 35.00)
    AND ((ce2.task_assay_cd+ 0)=famcr)
    AND ce2.result_val IN ("Yes, family wants to participate", "No, family will not participate"))
   JOIN (p
   WHERE p.person_id=ce2.person_id)
   JOIN (epr
   WHERE epr.encntr_id=ce2.encntr_id
    AND ((epr.encntr_prsnl_r_cd+ 0)=pcp_cd))
   JOIN (epr1
   WHERE epr1.encntr_id=ce2.encntr_id
    AND ((epr1.encntr_prsnl_r_cd+ 0)=attend_cd))
   JOIN (pn
   WHERE pn.person_id=epr.prsnl_person_id)
   JOIN (pn1
   WHERE pn1.person_id=epr1.prsnl_person_id)
  ORDER BY unit, nurse_unit, room
  HEAD REPORT
   row + 1, line = fillstring(130,"-"), col 50,
   "Family Centered Rounds Report", row + 1, col 55,
   curdate"MM/DD/YYYY ;;D", row + 2, count = 0
  HEAD PAGE
   row + 1, col 6, "Unit",
   col 13, "Room", col 20,
   "Bed", col 28, "Patient Name",
   col 55, "MRN", col 65,
   "Attending Physician", col 90, "PCP",
   col 110, "Participate", row + 1,
   col 0, line
  HEAD ce.event_id
   count = (count+ 1)
   IF (trim(ce2.result_val,3)="Yes, family wants to participate")
    status1 = "Y"
   ELSEIF (trim(ce2.result_val,3)="No, family will not participate")
    status1 = "N"
   ENDIF
   facility = substring(1,30,uar_get_code_display(e.loc_nurse_unit_cd)), room = uar_get_code_display(
    e.loc_room_cd), bed = uar_get_code_display(e.loc_bed_cd),
   name = substring(1,20,p.name_full_formatted), mrn = substring(1,10,ea.alias), attend = substring(1,
    20,pn1.name_full_formatted),
   pcp1 = substring(1,20,pn.name_full_formatted), row + 1, col 6,
   facility, col 13, room,
   col 20, bed, col 28,
   name, col 55, mrn,
   col 65, attend, col 90,
   pcp1, col 115, status1
   IF (((row+ 1) > 54))
    BREAK
   ENDIF
  FOOT REPORT
   row + 1, col 10, "Page#:",
   col 15, curpage, col 60,
   "TOTAL # OF PATIENT:", col 80, count
  WITH nocounter, separator = " ", format
 ;end select
 SET spool "familycenter.dat" bmccn4apedi1 WITH copy = 3, deleted
END GO
