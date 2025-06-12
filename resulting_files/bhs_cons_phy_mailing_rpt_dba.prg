CREATE PROGRAM bhs_cons_phy_mailing_rpt:dba
 PROMPT
  "Output to File/Printer/MINE:" = "MINE",
  "Recipient email(s):" = "",
  "Consulting Physician:" = 0,
  "Facility:" = "",
  "Begin dt/tm:" = "SYSDATE",
  "End dt/tm:" = "SYSDATE"
  WITH outdev, ms_emails, mf_cnslt_phys_id,
  mf_facility, ms_bdate, ms_edate
 EXECUTE bhs_sys_stand_subroutine
 DECLARE ms_recipient_emails = vc WITH protect, constant(trim( $MS_EMAILS))
 DECLARE ms_outfile = vc WITH protect, constant(concat("phy_mailing",format(curdate,"YYYYMMDD;;D"),
   ".csv"))
 DECLARE mf_cons_phy = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",333,
   "CONSULTINGPHYSICIAN"))
 DECLARE mf_auto_fax_code = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",3000,"FAX"))
 DECLARE mf_order = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6003,"ORDER"))
 DECLARE mf_ordered = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE mf_mrn = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE mf_completed = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14192,"COMPLETED"))
 DECLARE mf_ord_completed = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"COMPLETED"))
 DECLARE mf_org_number = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",263,"BHSORGNUMBER"))
 DECLARE mf_org_doctor = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",320,
   "ORGANIZATIONDOCTOR"))
 DECLARE mf_oa_complete = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6003,"COMPLETE"))
 DECLARE mf_outpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"OUTPATIENT"))
 DECLARE mf_outpat_one_time = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "OUTPATIENTONETIME"))
 DECLARE mf_one_time_op = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"ONETIMEOP"))
 DECLARE ms_line = vc WITH protect, noconstant(" ")
 DECLARE ms_status = vc WITH protect, noconstant(" ")
 DECLARE ms_error = vc WITH protect, noconstant(" ")
 DECLARE ms_output = vc WITH protect, noconstant(trim( $OUTDEV))
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_email_ind = i4 WITH protect, noconstant(0)
 DECLARE ml_tmp_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_ndx = i4 WITH protect, noconstant(0)
 DECLARE ml_ndx2 = i4 WITH protect, noconstant(0)
 DECLARE ml_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_provider_cnt = i4 WITH protect, noconstant(3000)
 DECLARE ms_facility_clause = vc WITH protect, noconstant(" ")
 DECLARE ms_beg_date = vc WITH protect, noconstant( $MS_BDATE)
 DECLARE ms_end_date = vc WITH protect, noconstant( $MS_EDATE)
 DECLARE ms_search_date = vc WITH protect, noconstant(concat(format(cnvtdatetime( $MS_BDATE),
    "MM/DD/YY HH:MM;;D")," to ",format(cnvtdatetime( $MS_EDATE),"MM/DD/YY HH:MM;;D")))
 DECLARE ms_subject = vc WITH protect, constant(concat("PHYSICIAN MAILING REPORT FOR RADIOLOGY - ",
   format(sysdate,"DD-MMM-YYYY;;q")))
 FREE RECORD temp
 RECORD temp(
   1 qual[*]
     2 s_patient_name = vc
     2 s_mrn = vc
     2 s_accession = vc
     2 s_facility = vc
     2 s_patient_loc = vc
     2 s_consult_phy = vc
     2 s_patient_type = vc
     2 s_order_description = vc
 ) WITH protect
 FREE RECORD providers
 RECORD providers(
   1 list[*]
     2 id = f8
     2 person_id = f8
 ) WITH protect
 IF (ms_output="OPS")
  SET ms_beg_date = trim(format(cnvtlookbehind("1,D",sysdate),"dd-mmm-yyyy hh:mm:ss;;d"))
  SET ms_end_date = trim(format(sysdate,"dd-mmm-yyyy hh:mm:ss;;d"))
  SET ms_search_date = concat(ms_beg_date," to ",ms_end_date)
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
 IF (((textlen(trim(ms_beg_date))=0) OR (textlen(trim(ms_end_date))=0)) )
  SET ms_status = "ERROR"
  SET ms_error = concat(ms_error,"Begin Date and End Date are required.")
  GO TO exit_script
 ELSEIF (cnvtdatetime(ms_beg_date) > cnvtdatetime(ms_end_date))
  SET ms_status = "ERROR"
  SET ms_error = concat(ms_error,"Begin Date must be earlier than End Date")
  GO TO exit_script
 ENDIF
 IF (( $MF_FACILITY="ALL"))
  SET ms_facility_clause = "e.loc_facility_cd > 0"
 ELSE
  SET ms_facility_clause = build("e.loc_facility_cd = ",cnvtreal( $MF_FACILITY))
 ENDIF
 IF (( $MF_CNSLT_PHYS_ID > 0))
  SET ml_provider_cnt = 1
  SET stat = alterlist(providers->list,ml_provider_cnt)
  SET providers->list[1].person_id =  $MF_CNSLT_PHYS_ID
 ELSE
  SET stat = alterlist(providers->list,ml_provider_cnt)
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 335.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 2598.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5690.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 8259.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 2351.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 181.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 2500.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 6030.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 8293.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5976.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 448.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 867.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 94276.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 9093.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 4902.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 4900.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 3416.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 2642.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5502.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5497.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 30116.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 98373.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 90906.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 99016.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 95653.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 30125.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 8456.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 92392.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5261.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5269.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5986.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 90464.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 98129.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 90264.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 8867.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5240.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5259.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 8444.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 99176.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 4896.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 8724.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 642.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 2342.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5770.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5674.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 8797.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 3301.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 9503.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 97656.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5746.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 6324.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 8551.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 6331.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 3307.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 504.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 791.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5435.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5856.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5111.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5001.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5178.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 2198.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 8316.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 22744.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 95065.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 40038.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 920.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 9143.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 9898.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 30020.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 30270.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 99255.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 94051.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 30122.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5636.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 134.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 533.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 2644.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5730.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 9505.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 6727.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 92604.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 9095.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 99799.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 6294.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 6102.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5070.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5332.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5121.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 36.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 390.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 50.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5696.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 177.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 738.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 8728.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 8945.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 2364.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 20617.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 20302.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 2467.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 20861.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 20734.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 98900.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 20702.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 91.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 93375.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5917.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5099.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 8812.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5621.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 90043.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 2187.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 93528.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 1950.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 9108.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 98664.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 9926.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 40170.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 6486.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 98957.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 98663.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 2499.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 8754.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 8609.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 8850.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5430.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 8668.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 90367.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 8155.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 745.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 8825.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 3932.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 2410.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 34.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5735.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 20688.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 93265.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 99256.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 40449.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 98515.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 22725.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 9374.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 40198.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 9968.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 1391.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 30414.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 3893.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 4015.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 98620.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 96821.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 97770.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 20878.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 91304.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 92509.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 30074.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 95839.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 98106.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 499.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5078.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5189.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 705.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 564.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5434.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5910.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5676.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 6423.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 225.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 6389.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 6271.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 6088.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 6042.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5783.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 92761.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 2395.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 9525.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 7988.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 99938.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 2438.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 2440.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 4942.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 4941.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 8669.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 2533.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 2625.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 2361.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 2360.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 90785.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 2612.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 2181.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 2496.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 4960.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 2225.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 2702.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 9504.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 282.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 9112.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 2285.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 312.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 2434.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 6107.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 9150.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 9279.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 122.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 98813.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 3030.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5594.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 92878.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5403.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 453.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 30021.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 30002.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 270.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 729.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 8748.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 8015.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 3433.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 3426.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 3087.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5604.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 93003.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 93003.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 8117.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 8542.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 149.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 2396.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 9361.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 93946.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 96932.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 95226.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 6723.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 8792.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 95869.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5112.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 1703.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 2510.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5231.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 114.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 114.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 90376.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 7921.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 99236.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 2581.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 9271.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5432.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5504.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5511.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5925.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5846.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 6570.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5089.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5906.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 5104.00
  SET ml_tmp_cnt = (ml_tmp_cnt+ 1)
  SET providers->list[ml_tmp_cnt].id = 43397.00
  SELECT INTO "nl:"
   FROM prsnl_alias pa
   WHERE pa.prsnl_alias_type_cd=mf_org_doctor
    AND pa.alias_pool_cd=mf_org_number
    AND expand(ml_ndx,1,ml_provider_cnt,pa.alias,cnvtstring(providers->list[ml_ndx].id))
   DETAIL
    ml_pos = 0, ml_pos = locateval(ml_ndx2,1,ml_provider_cnt,pa.alias,cnvtstring(providers->list[
      ml_ndx2].id))
    IF (ml_pos > 0)
     providers->list[ml_pos].person_id = pa.person_id
    ENDIF
   WITH nocounter, expand = 1
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM order_radiology rad,
   encntr_alias ea,
   encounter e,
   person p,
   encntr_prsnl_reltn epr,
   rad_report rr,
   order_action oa,
   prsnl pr2,
   orders o
  PLAN (rr
   WHERE rr.final_dt_tm BETWEEN cnvtdatetime(ms_beg_date) AND cnvtdatetime(ms_end_date))
   JOIN (rad
   WHERE rad.order_id=rr.order_id
    AND rad.exam_status_cd=mf_completed)
   JOIN (e
   WHERE e.encntr_id=rad.encntr_id
    AND parser(ms_facility_clause)
    AND e.encntr_type_cd IN (mf_outpat_one_time, mf_one_time_op))
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate
    AND ea.encntr_alias_type_cd=mf_mrn)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (oa
   WHERE oa.order_id=rad.order_id
    AND oa.order_status_cd=mf_ord_completed
    AND oa.action_type_cd=mf_oa_complete)
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.encntr_prsnl_r_cd=mf_cons_phy
    AND expand(ml_ndx,1,ml_provider_cnt,epr.prsnl_person_id,providers->list[ml_ndx].person_id))
   JOIN (pr2
   WHERE pr2.person_id=epr.prsnl_person_id)
   JOIN (o
   WHERE o.order_id=rad.order_id
    AND o.active_ind=1)
  ORDER BY rr.final_dt_tm
  DETAIL
   ml_cnt = (ml_cnt+ 1)
   IF (mod(ml_cnt,100)=1)
    CALL alterlist(temp->qual,(ml_cnt+ 99))
   ENDIF
   temp->qual[ml_cnt].s_patient_name = p.name_full_formatted, temp->qual[ml_cnt].s_mrn = ea.alias,
   temp->qual[ml_cnt].s_accession = rad.accession,
   temp->qual[ml_cnt].s_facility = uar_get_code_display(e.loc_facility_cd), temp->qual[ml_cnt].
   s_patient_loc = uar_get_code_display(e.loc_nurse_unit_cd), temp->qual[ml_cnt].s_consult_phy = pr2
   .name_full_formatted,
   temp->qual[ml_cnt].s_patient_type = uar_get_code_display(e.encntr_type_cd), temp->qual[ml_cnt].
   s_order_description = o.order_mnemonic
  FOOT REPORT
   CALL alterlist(temp->qual,ml_cnt)
  WITH nocounter, expand = 1
 ;end select
 IF (ml_cnt=0)
  SET ms_status = "ERROR"
  SET ms_error = concat(ms_error,"No Data found for this date range: ",ms_search_date)
  GO TO exit_script
 ENDIF
 SELECT INTO value(ms_output)
  FROM (dummyt d  WITH seq = value(size(temp->qual,5)))
  HEAD REPORT
   ms_line = concat("Physician Mailing report for Radiology ",ms_search_date), row 0, col 0,
   ms_line, ms_line = concat("Patient Name, Patient MRN, Accession, Facility, Patient Location",
    ", Consulting Physician, Patient Type, Order Description"), row + 1,
   col 0, ms_line
  DETAIL
   ms_line = build('"',temp->qual[d.seq].s_patient_name,'","',temp->qual[d.seq].s_mrn,'","',
    temp->qual[d.seq].s_accession,'","',temp->qual[d.seq].s_facility,'","',temp->qual[d.seq].
    s_patient_loc,
    '","',temp->qual[d.seq].s_consult_phy,'","',temp->qual[d.seq].s_patient_type,'","',
    temp->qual[d.seq].s_order_description,'",'), row + 1, col 0,
   ms_line
  WITH nocounter, maxrow = 1, maxcol = 30000,
   format = variable, formfeed = none
 ;end select
 IF (ml_email_ind=1)
  CALL emailfile(ms_outfile,ms_outfile,ms_recipient_emails,ms_subject,1)
  SET ms_status = "SUCCESS - EMAIL"
  SET ms_error = concat(ms_error,"File has been emailed to: ",ms_recipient_emails)
  GO TO exit_script
 ENDIF
 IF (((ms_status != "ERROR") OR (ms_status != "SUCCESS - EMAIL")) )
  SET ms_status = "SUCCESS"
 ENDIF
#exit_script
 IF (ms_status != "SUCCESS"
  AND ms_output != "OPS")
  SELECT INTO value(ms_output)
   FROM dummyt
   HEAD REPORT
    col 0, "{PS/792 0 translate 90 rotate/}", "{F/1}{CPI/7}",
    CALL print(calcpos(10,10)), "Physician Mailing report for Radiology", "{F/1}{CPI/14}",
    CALL print(calcpos(10,30)), ms_error
   WITH dio = postscript, maxrow = 300, maxcol = 300
  ;end select
 ENDIF
END GO
