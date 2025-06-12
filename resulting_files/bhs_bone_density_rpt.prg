CREATE PROGRAM bhs_bone_density_rpt
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Recipient email(s)" = "",
  "Facility:" = 0,
  "Begin dt/tm:" = "SYSDATE",
  "End dt/tm" = "SYSDATE"
  WITH outdev, recipient_emails, facility,
  bdate, edate
 DECLARE ms_recipient_emails = vc WITH protect, constant( $RECIPIENT_EMAILS)
 DECLARE ms_outfile = vc WITH protect, constant(concat("bone_density",format(curdate,"YYYYMMDD;;D"),
   ".csv"))
 DECLARE exam_status = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14192,"COMPLETED"))
 DECLARE bone_assessment = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "DXA1ORMORESITESVERTFXASSESSMENT"))
 DECLARE bone_axial = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "DEXABONEDENSITYAXIAL"))
 DECLARE bone_appendicular = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "DEXABONEDENSITYAPPENDICULAR"))
 DECLARE fin_nbr = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE order_status = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE action_type = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6003,"ORDER"))
 DECLARE ms_line = vc WITH protect, noconstant(" ")
 DECLARE order_phy = vc WITH protect, noconstant(" ")
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 FREE RECORD temp
 RECORD temp(
   1 qual[*]
     2 s_phy_name = vc
     2 s_patient_name = vc
     2 s_acct_num = vc
     2 s_accession_number = vc
     2 d_order_dt_tm = dq8
     2 s_order_name = vc
 )
 IF (findstring("@",ms_recipient_emails)=0)
  CALL echo("###########################################")
  CALL echo(build("Invalid email recipients list"))
  CALL echo("###########################################")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM orders r,
   order_radiology rad,
   encntr_alias fin,
   encounter e,
   order_action oa,
   prsnl pr,
   person p
  PLAN (r
   WHERE r.catalog_cd IN (bone_assessment, bone_axial, bone_appendicular)
    AND r.orig_order_dt_tm BETWEEN cnvtdatetime( $BDATE) AND cnvtdatetime( $EDATE))
   JOIN (rad
   WHERE rad.order_id=r.order_id
    AND ((rad.exam_status_cd+ 0)=exam_status))
   JOIN (e
   WHERE e.encntr_id=rad.encntr_id
    AND (e.loc_facility_cd= $FACILITY))
   JOIN (fin
   WHERE fin.encntr_id=e.encntr_id
    AND fin.active_ind=1
    AND fin.end_effective_dt_tm > sysdate
    AND fin.encntr_alias_type_cd=fin_nbr)
   JOIN (p
   WHERE p.person_id=r.person_id)
   JOIN (oa
   WHERE oa.order_id=r.order_id
    AND oa.order_status_cd=order_status
    AND oa.action_type_cd=action_type)
   JOIN (pr
   WHERE pr.person_id=oa.order_provider_id
    AND pr.username="RF*")
  DETAIL
   ml_cnt = (ml_cnt+ 1), stat = alterlist(temp->qual,ml_cnt), temp->qual[ml_cnt].s_phy_name = pr
   .name_full_formatted,
   temp->qual[ml_cnt].s_patient_name = p.name_full_formatted, temp->qual[ml_cnt].s_acct_num = fin
   .alias, temp->qual[ml_cnt].s_accession_number = rad.accession,
   temp->qual[ml_cnt].d_order_dt_tm = r.orig_order_dt_tm, temp->qual[ml_cnt].s_order_name = r
   .order_mnemonic
  WITH nocounter
 ;end select
 SELECT INTO value(ms_outfile)
  FROM (dummyt d  WITH seq = 1)
  DETAIL
   ms_line = concat("Bone D Ref Phy With No-CIS Access-",format(cnvtdatetime( $BDATE),
     "MM/DD/YY HH:MM;;D")," to ",format(cnvtdatetime( $EDATE),"MM/DD/YY HH:MM;;D")), row 0, col 0,
   ms_line, ms_line = concat('"Phy_Name","Patient_Name","Acct_Number","Accession_Number"',
    ',"Order_Dt_Tm","Order_Name"'), row + 1,
   row + 1, col 0, ms_line
   FOR (ml_cnt = 1 TO value(size(temp->qual,5)))
     ms_line = build('"',temp->qual[ml_cnt].s_phy_name,'","',temp->qual[ml_cnt].s_patient_name,'","',
      temp->qual[ml_cnt].s_acct_num,'","',temp->qual[ml_cnt].s_accession_number,'","',format(temp->
       qual[ml_cnt].d_order_dt_tm,"YYYY/MM/DD HH:MM:SS;;D"),
      '","',temp->qual[ml_cnt].s_order_name,'"'), row + 1, col 0,
     ms_line
   ENDFOR
  WITH nocounter, maxrow = 1, maxcol = 30000,
   format = variable, formfeed = none
 ;end select
 EXECUTE bhs_sys_stand_subroutine
 CALL emailfile(ms_outfile,ms_outfile,ms_recipient_emails,concat(
   "Bone Density Referring Physicians with no CIS Access",format(cnvtdatetime( $BDATE),
    "MM/DD/YY HH:MM;;D")," to ",format(cnvtdatetime( $EDATE),"MM/DD/YY HH:MM;;D")),0)
END GO
