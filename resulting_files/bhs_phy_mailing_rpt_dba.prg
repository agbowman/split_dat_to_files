CREATE PROGRAM bhs_phy_mailing_rpt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Recipient email(s)" = "",
  "Physician" = 0,
  "Facility:" = 0,
  "Begin dt/tm:" = "SYSDATE",
  "End dt/tm" = "SYSDATE"
  WITH outdev, ms_emails, mf_phys_id,
  mf_facility, ms_bdate, ms_edate
 EXECUTE bhs_sys_stand_subroutine
 DECLARE ms_search_date = vc WITH protect, constant(concat(format(cnvtdatetime( $MS_BDATE),
    "MM/DD/YY HH:MM;;D")," to ",format(cnvtdatetime( $MS_EDATE),"MM/DD/YY HH:MM;;D")))
 DECLARE ms_recipient_emails = vc WITH protect, constant(trim( $MS_EMAILS))
 DECLARE ms_outfile = vc WITH protect, constant(concat("phy_mailing",format(curdate,"YYYYMMDD;;D"),
   ".csv"))
 DECLARE ms_subject = vc WITH protect, constant(concat("PHYSICIAN MAILING REPORT FOR RADIOLOGY ",
   ms_search_date))
 DECLARE mf_cons_phy = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "CONSULTING PHYSICIAN"))
 DECLARE mf_auto_fax_code = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",3000,"FAX"))
 DECLARE mf_order = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6003,"ORDER"))
 DECLARE mf_ordered = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE mf_fin = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_mrn = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE mf_completed = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14192,"COMPLETED"))
 DECLARE mf_oa_completed = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"COMPLETED"))
 DECLARE mf_oa_future = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"FUTURE"))
 DECLARE mf_oa_complete = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6003,"COMPLETE"))
 DECLARE mf_resident_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",88,"BHSRESIDENT"))
 DECLARE ms_line = vc WITH protect, noconstant(" ")
 DECLARE ms_order_phy = vc WITH protect, noconstant("1=1")
 DECLARE ms_status = vc WITH protect, noconstant(" ")
 DECLARE ms_error = vc WITH protect, noconstant(" ")
 DECLARE ms_output = vc WITH protect, noconstant(trim( $OUTDEV))
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_email_ind = i4 WITH protect, noconstant(0)
 FREE RECORD temp
 RECORD temp(
   1 qual[*]
     2 s_patient_name = vc
     2 s_mrn = vc
     2 s_fin = vc
     2 s_accession = vc
     2 d_final_dt_tm = dq8
     2 s_facility = vc
     2 s_patient_loc = vc
     2 s_order_phy = vc
     2 f_order_phy_id = f8
     2 n_order_phys_autofax_ind = i2
     2 s_consult_phy = vc
     2 f_consult_phy_id = f8
     2 n_consult_phys_autofax_ind = i2
     2 s_patient_type = vc
     2 s_cons_phys_autofax_ind = vc
     2 s_ord_phys_autofax_ind = vc
     2 s_order_description = vc
     2 s_financial_class = vc
     2 s_consult_phys_type = vc
     2 s_order_phys_type = vc
 ) WITH protect
 IF (( $MF_PHYS_ID > 0))
  SET ms_order_phy = concat("pr.person_id = ",cnvtstring( $MF_PHYS_ID))
 ENDIF
 IF (size(ms_recipient_emails) > 0)
  IF (findstring("@",ms_recipient_emails)=0)
   SET ms_status = "ERROR"
   SET ms_error = concat(ms_error,
    'Invalid email recipients list. Email should contain at least one "@" character.')
   GO TO exit_script
  ELSE
   SET ml_email_ind = 1
   SET ms_output = ms_outfile
  ENDIF
 ENDIF
 IF (((textlen(trim( $MS_BDATE))=0) OR (textlen(trim( $MS_EDATE))=0)) )
  SET ms_status = "ERROR"
  SET ms_error = concat(ms_error,"Begin Date and End Date are required.")
  GO TO exit_script
 ELSEIF (cnvtdatetime( $MS_BDATE) > cnvtdatetime( $MS_EDATE))
  SET ms_status = "ERROR"
  SET ms_error = concat(ms_error,"Begin Date must be earlier than End Date")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM order_radiology rad,
   encntr_alias ea,
   encntr_alias fin,
   encounter e,
   person p,
   order_detail ord,
   rad_report rr,
   order_action oa,
   prsnl pr,
   orders o
  PLAN (rr
   WHERE rr.final_dt_tm BETWEEN cnvtdatetime( $MS_BDATE) AND cnvtdatetime( $MS_EDATE))
   JOIN (rad
   WHERE rad.order_id=rr.order_id
    AND rad.exam_status_cd=mf_completed)
   JOIN (e
   WHERE e.encntr_id=rad.encntr_id
    AND (e.loc_facility_cd= $MF_FACILITY))
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate
    AND ea.encntr_alias_type_cd=mf_mrn)
   JOIN (fin
   WHERE fin.encntr_id=e.encntr_id
    AND fin.active_ind=1
    AND fin.end_effective_dt_tm > sysdate
    AND fin.encntr_alias_type_cd=mf_fin)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (oa
   WHERE oa.order_id=rad.order_id
    AND oa.order_status_cd=mf_ordered
    AND oa.action_type_cd=mf_order)
   JOIN (pr
   WHERE pr.person_id=oa.order_provider_id
    AND pr.position_cd != mf_resident_cd
    AND parser(ms_order_phy))
   JOIN (ord
   WHERE (ord.order_id= Outerjoin(rad.order_id))
    AND (ord.oe_field_id= Outerjoin(mf_cons_phy)) )
   JOIN (o
   WHERE o.order_id=rad.order_id
    AND o.active_ind=1)
  ORDER BY rr.final_dt_tm
  DETAIL
   ml_cnt += 1
   IF (mod(ml_cnt,100)=1)
    CALL alterlist(temp->qual,(ml_cnt+ 99))
   ENDIF
   temp->qual[ml_cnt].s_patient_name = p.name_full_formatted, temp->qual[ml_cnt].s_mrn = ea.alias,
   temp->qual[ml_cnt].s_fin = fin.alias,
   temp->qual[ml_cnt].s_accession = rad.accession, temp->qual[ml_cnt].d_final_dt_tm = rr.final_dt_tm,
   temp->qual[ml_cnt].s_facility = uar_get_code_display(e.loc_facility_cd),
   temp->qual[ml_cnt].s_patient_loc = uar_get_code_display(e.loc_nurse_unit_cd), temp->qual[ml_cnt].
   s_order_phy = pr.name_full_formatted, temp->qual[ml_cnt].f_order_phy_id = pr.person_id,
   temp->qual[ml_cnt].s_consult_phy = ord.oe_field_display_value, temp->qual[ml_cnt].f_consult_phy_id
    = ord.oe_field_value, temp->qual[ml_cnt].s_patient_type = uar_get_code_display(e.encntr_type_cd),
   temp->qual[ml_cnt].s_order_description = o.order_mnemonic, temp->qual[ml_cnt].s_financial_class =
   uar_get_code_display(e.financial_class_cd)
  FOOT REPORT
   CALL alterlist(temp->qual,ml_cnt)
  WITH nocounter
 ;end select
 IF (ml_cnt=0)
  SET ms_status = "ERROR"
  SET ms_error = concat(ms_error,"No Data found for this date range: ",ms_search_date)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(temp->qual,5))),
   prsnl p
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=temp->qual[d.seq].f_order_phy_id)
    AND p.person_id > 0)
  DETAIL
   IF (substring(1,2,trim(p.username,3)) IN ("EN", "PN", "RF"))
    temp->qual[d.seq].s_order_phys_type = substring(1,2,trim(p.username,3))
   ELSE
    temp->qual[d.seq].s_order_phys_type = "OTHER"
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(temp->qual,5))),
   prsnl p
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=temp->qual[d.seq].f_consult_phy_id)
    AND p.person_id > 0)
  DETAIL
   IF (substring(1,2,trim(p.username,3)) IN ("EN", "PN", "RF"))
    temp->qual[d.seq].s_consult_phys_type = substring(1,2,trim(p.username,3))
   ELSE
    temp->qual[d.seq].s_consult_phys_type = "OTHER"
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(temp->qual,5))),
   device_xref dx,
   remote_device rd
  PLAN (d)
   JOIN (dx
   WHERE (dx.parent_entity_id=temp->qual[d.seq].f_order_phy_id)
    AND dx.parent_entity_name="PRSNL"
    AND dx.usage_type_cd=mf_auto_fax_code)
   JOIN (rd
   WHERE rd.device_cd=dx.device_cd
    AND  NOT (rd.phone_suffix IN ("", " ", null)))
  DETAIL
   temp->qual[d.seq].n_order_phys_autofax_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(temp->qual,5))),
   device_xref dx,
   remote_device rd
  PLAN (d)
   JOIN (dx
   WHERE (dx.parent_entity_id=temp->qual[d.seq].f_consult_phy_id)
    AND dx.parent_entity_name="PRSNL"
    AND dx.usage_type_cd=mf_auto_fax_code)
   JOIN (rd
   WHERE rd.device_cd=dx.device_cd
    AND  NOT (rd.phone_suffix IN ("", " ", null)))
  DETAIL
   temp->qual[d.seq].n_consult_phys_autofax_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO value(ms_output)
  FROM (dummyt d  WITH seq = value(size(temp->qual,5)))
  HEAD REPORT
   ms_line = concat("Physician Mailing report for Radiology ",ms_search_date), row 0, col 0,
   ms_line, ms_line = concat("Patient Name, MRN, FIN, Accession",
    ", Final Date, Facility, Patient Location",
    ", Ordering Physician, Ordering Physician AutoFax, Ordering Employee Type, Consulting Physician",
    ", Consulting Physician Autofax, Consulting Employee Type, Patient Type, Order Description, Financial Class"
    ), row + 1,
   col 0, ms_line
  DETAIL
   ms_line = build('"',temp->qual[d.seq].s_patient_name,'","',temp->qual[d.seq].s_mrn,'","',
    temp->qual[d.seq].s_fin,'","',temp->qual[d.seq].s_accession,'","',format(temp->qual[d.seq].
     d_final_dt_tm,"YYYY/MM/DD HH:MM:SS;;D"),
    '","',temp->qual[d.seq].s_facility,'","',temp->qual[d.seq].s_patient_loc,'","',
    temp->qual[d.seq].s_order_phy,'","',evaluate(temp->qual[d.seq].n_order_phys_autofax_ind,1,"Yes",
     "No"),'","',temp->qual[d.seq].s_order_phys_type,
    '","',temp->qual[d.seq].s_consult_phy,'","',evaluate(temp->qual[d.seq].n_consult_phys_autofax_ind,
     1,"Yes","No"),'","',
    temp->qual[d.seq].s_consult_phys_type,'","',temp->qual[d.seq].s_patient_type,'","',temp->qual[d
    .seq].s_order_description,
    '","',temp->qual[d.seq].s_financial_class,'"'), row + 1, col 0,
   ms_line
  WITH nocounter, maxrow = 1, maxcol = 30000,
   format = variable, formfeed = none
 ;end select
 IF (ml_email_ind=1)
  CALL emailfile(ms_outfile,ms_outfile,ms_recipient_emails,ms_subject,0)
  SET ms_status = "SUCCESS - EMAIL"
  SET ms_error = concat(ms_error,"File has been emailed to: ",ms_recipient_emails)
  GO TO exit_script
 ENDIF
 IF (((ms_status != "ERROR") OR (ms_status != "SUCCESS - EMAIL")) )
  SET ms_status = "SUCCESS"
 ENDIF
#exit_script
 IF (ms_status != "SUCCESS")
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    col 0, "{PS/792 0 translate 90 rotate/}", "{F/1}{CPI/7}",
    CALL print(calcpos(10,10)), "Physician Mailing report for Radiology", "{F/1}{CPI/14}",
    CALL print(calcpos(10,30)), ms_error
   WITH dio = postscript, maxrow = 300, maxcol = 300
  ;end select
 ENDIF
END GO
