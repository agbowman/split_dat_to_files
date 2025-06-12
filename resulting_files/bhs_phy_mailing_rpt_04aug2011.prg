CREATE PROGRAM bhs_phy_mailing_rpt_04aug2011
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Recipient email(s)" = "",
  "Physician" = 0,
  "Facility:" = 0,
  "Begin dt/tm:" = "SYSDATE",
  "End dt/tm" = "SYSDATE"
  WITH outdev, recipient_emails, phys_id,
  facility, bdate, edate
 DECLARE ms_outfile = vc WITH protect, constant(concat("phy_mailing",format(curdate,"YYYYMMDD;;D"),
   ".csv"))
 DECLARE ms_line = vc WITH protect, noconstant(" ")
 DECLARE ms_recipient_emails = vc WITH protect, constant( $RECIPIENT_EMAILS)
 DECLARE order_phy = vc WITH protect, noconstant(" ")
 DECLARE cons_phy = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "CONSULTING PHYSICIAN"))
 SET order_phy = "1=1"
 IF (( $PHYS_ID > 0))
  SET order_phy = concat("pr.person_id = ",cnvtstring( $PHYS_ID))
 ENDIF
 IF (findstring("@",ms_recipient_emails)=0)
  CALL echo("###########################################")
  CALL echo(build("Invalid email recipients list"))
  CALL echo("###########################################")
  GO TO exit_script
 ENDIF
 SELECT INTO value(ms_outfile)
  patient_name = p.name_full_formatted, mrn = ea.alias, fin = fin.alias,
  rad.accession, final.final_dt_tm, facility = uar_get_code_display(e.loc_facility_cd),
  ordering_physician = pr.name_full_formatted, patient_location = uar_get_code_display(e
   .loc_nurse_unit_cd), consulting_physician = ord.oe_field_display_value,
  patient_type = uar_get_code_display(e.encntr_type_cd)
  FROM order_radiology rad,
   encntr_alias ea,
   clinical_event ce,
   ce_event_prsnl cep,
   prsnl pr,
   encntr_alias fin,
   encounter e,
   person p,
   order_detail ord,
   rad_report final
  WHERE final.order_id=rad.order_id
   AND ord.order_id=outerjoin(rad.order_id)
   AND ord.oe_field_id=outerjoin(cons_phy)
   AND p.person_id=e.person_id
   AND e.encntr_id=ea.encntr_id
   AND cep.action_prsnl_id=pr.person_id
   AND ce.accession_nbr=rad.accession
   AND ce.view_level=1
   AND ce.valid_until_dt_tm > sysdate
   AND cep.event_id=ce.event_id
   AND ce.encntr_id=rad.encntr_id
   AND rad.encntr_id=ea.encntr_id
   AND ea.active_ind=1
   AND ea.end_effective_dt_tm > sysdate
   AND ea.encntr_alias_type_cd=1079
   AND rad.exam_status_cd=4224
   AND cep.action_dt_tm IS NOT null
   AND cep.action_type_cd=103
   AND fin.encntr_alias_type_cd=1077
   AND fin.encntr_id=e.encntr_id
   AND (final.updt_applctx=
  (SELECT
   max(final.updt_applctx)
   FROM rad_report final
   WHERE order_id=rad.order_id))
   AND final.final_dt_tm BETWEEN cnvtdatetime( $BDATE) AND cnvtdatetime( $EDATE)
   AND parser(order_phy)
   AND (e.loc_facility_cd= $FACILITY)
  ORDER BY final.final_dt_tm
  HEAD REPORT
   ms_line = concat("Physician Mailing report for Radiology ",format(cnvtdatetime( $BDATE),
     "MM/DD/YY HH:MM;;D")," to ",format(cnvtdatetime( $EDATE),"MM/DD/YY HH:MM;;D")), col 0, ms_line,
   row + 1, row + 1, ms_line = concat('"Patient Name","MRN","FIN","Accession"',
    ',"Final_Dt_tm","Facility","Patient_Location"',
    ',"Ordering Physician","Consulting Physician", Patient_Type'),
   col 0, ms_line
  DETAIL
   row + 1, ms_line = build('"',patient_name,'","',mrn,'","',
    fin,'","',rad.accession,'","',format(final.final_dt_tm,"MM/DD/YY HH:MM;;D"),
    '","',facility,'","',patient_location,'","',
    ordering_physician,'","',consulting_physician,'","',patient_type,
    '"'), col 0,
   ms_line,
   CALL echo(build("PATIENT_LOCATION",patient_location)),
   CALL echo(ms_line)
  FOOT REPORT
   row + 1
  WITH nocounter, format = variable, maxcol = 20000
 ;end select
 EXECUTE bhs_sys_stand_subroutine
 CALL emailfile(ms_outfile,ms_outfile,ms_recipient_emails,concat(
   "PHYSICIAN MAILING REPORT FOR RADIOLOGY ",format(cnvtdatetime( $BDATE),"MM/DD/YY HH:MM;;D")," to ",
   format(cnvtdatetime( $EDATE),"MM/DD/YY HH:MM;;D")),0)
END GO
