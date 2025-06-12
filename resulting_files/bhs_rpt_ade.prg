CREATE PROGRAM bhs_rpt_ade
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "begdate" = "SYSDATE",
  "enddate" = "SYSDATE",
  "runType" = 0,
  "Location" = 0
  WITH outdev, begdate, enddate,
  runtype, f_facility
 DECLARE mf_facility_cd = f8 WITH protect, constant(cnvtreal( $F_FACILITY))
 DECLARE mf_protamine_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"PROTAMINE")), protect
 DECLARE mf_naloxone_var1 = f8 WITH constant(uar_get_code_by("description",200,"Naloxone")), protect
 DECLARE mf_naloxone_var2 = f8 WITH constant(uar_get_code_by("description",200,
   "NalOXONE  0.2mg in NaCl 0.9% 50mL (Pedi Standard Dosing) TP")), protect
 DECLARE mf_naloxone_var3 = f8 WITH constant(uar_get_code_by("description",200,
   "NalOXONE  0.2mg in NaCl 0.9% 50mL (Pedi Standard Dosing) TO")), protect
 DECLARE mf_naloxone_var4 = f8 WITH constant(uar_get_code_by("description",200,
   "NalOXONE  0.4mg in NaCl 0.9% 100mL (Pedi Standard Dosing) TP")), protect
 DECLARE mf_naloxone_var5 = f8 WITH constant(uar_get_code_by("description",200,
   "NalOXONE  0.4mg in NaCl 0.9%  100mL (Pedi Standard Dosing) T")), protect
 DECLARE mf_naloxone_var6 = f8 WITH constant(uar_get_code_by("description",200,
   "NalOXONE  0.4mg in NaCl 0.9% 100mL (Pedi Standard Dosing) TO")), protect
 DECLARE mf_naloxone_var7 = f8 WITH constant(uar_get_code_by("description",200,
   "NalOXONE  1mg in NaCl 0.9% 250mL (Pedi Standard Dosing) TO")), protect
 DECLARE mf_naloxone_var8 = f8 WITH constant(uar_get_code_by("description",200,
   "NalOXONE  2 mg in D5%W 500 mL")), protect
 DECLARE mf_naloxone_var9 = f8 WITH constant(uar_get_code_by("description",200,
   "NalOXONE  2 mg in NaCl 0.9% 500 mL")), protect
 DECLARE mf_heparin_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"HEPARIN")), protect
 DECLARE mf_glucagon_var2 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "GLUCAGON20MGIND5W250ML")), protect
 DECLARE mf_glucagon_var1 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"GLUCAGON")), protect
 DECLARE mf_dextrose50inwater_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "DEXTROSE50INWATER")), protect
 DECLARE mf_atropine_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"ATROPINE")), protect
 DECLARE mf_phytonadione_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"PHYTONADIONE")),
 protect
 DECLARE mf_inpt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"INPATIENT"))
 DECLARE mf_pharmacy_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_ordered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE mf_cdispensabledrugnames_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6011,
   "CDISPENSABLEDRUGNAMES")), protect
 DECLARE mf_med_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",53,"MED")), protect
 DECLARE mf_altered = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_modified = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_auth = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt1 = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt2 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE ml_for1 = i4 WITH protect, noconstant(0)
 DECLARE ml_for2 = i4 WITH protect, noconstant(0)
 DECLARE ml_for3 = i4 WITH protect, noconstant(0)
 DECLARE mn_email_ind = i2 WITH protect, noconstant(0)
 DECLARE ms_str1 = vc WITH protect, noconstant(" ")
 DECLARE ms_str2 = vc WITH protect, noconstant(" ")
 DECLARE ms_output_line = vc WITH protect, noconstant(" ")
 DECLARE ms_output_line1 = vc WITH protect, noconstant(" ")
 DECLARE ms_output_dest = vc WITH protect, noconstant(" ")
 DECLARE ms_filename_in = vc WITH protect, noconstant(" ")
 DECLARE ms_filename_out = vc WITH protect, noconstant(" ")
 DECLARE ms_subject_line = vc WITH protect, noconstant(" ")
 DECLARE ms_beg_date_disp = vc WITH protect, noconstant(" ")
 DECLARE ms_end_date_disp = vc WITH protect, noconstant(" ")
 DECLARE mf_beg_date_qual = f8 WITH protect, noconstant(0.0)
 DECLARE mf_end_date_qual = f8 WITH protect, noconstant(0.0)
 DECLARE mf_s_date = f8 WITH protect, noconstant(0.0)
 DECLARE mf_e_date = f8 WITH protect, noconstant(0.0)
 FREE RECORD med
 RECORD med(
   1 syn[*]
     2 f_catalog_cd = f8
     2 ms_catalog_disp = vc
     2 f_synonym_id = f8
     2 ms_synonym_disp = vc
 )
 FREE RECORD adm
 RECORD adm(
   1 d_beg_dt_tm = dq8
   1 d_end_dt_tm = dq8
   1 s_rpt_title = vc
   1 nurs[*]
     2 f_nurse_unit_cd = f8
     2 s_disp = vc
   1 qual[*]
     2 f_person_id = f8
     2 s_pat_name = vc
     2 f_encntr_id = f8
     2 ms_reg_dt_tm = vc
     2 s_fin = vc
     2 s_pat_loc = vc
     2 s_age = vc
     2 med[*]
       3 f_event_id = f8
       3 ms_adm_dt_tm = vc
       3 ms_adm_rn = vc
       3 f_trigger_ord_id = f8
       3 ms_trigger_ord_dose = vc
       3 ms_trigger_ord_rte = vc
       3 ms_ord_info = vc
       3 mf_cat_cd = f8
       3 ord[*]
         4 f_ade_ord_id = f8
         4 f_ade_event_id = f8
         4 ms_ade_ord_info = vc
         4 ms_ade_adm_dttm = vc
         4 ms_ade_adm_dose = vc
         4 ms_ade_ord_rte = vc
 )
 IF (findstring("@", $OUTDEV) > 0)
  SET mn_email_ind = 1
  SET ms_output_dest = trim(concat(trim(cnvtlower(curprog)),format(cnvtdatetime(curdate,curtime3),
     "MMDDYYYYHHMMSS;;D")))
 ELSE
  SET mn_email_ind = 0
  SET ms_output_dest =  $OUTDEV
 ENDIF
 IF (cnvtupper( $BEGDATE) IN ("BEGOFWEEKLY", "BOW"))
  SET mf_beg_date_qual = datetimefind(cnvtdatetime((curdate - 6),0000),"W","B","B")
 ELSE
  SET mf_beg_date_qual = cnvtdatetime(build(trim( $BEGDATE)," 00:00:00"))
 ENDIF
 IF (cnvtupper( $ENDDATE) IN ("ENDOFWEEKLY", "EOW"))
  SET mf_end_date_qual = datetimefind(cnvtdatetime((curdate - 6),235959),"W","E","E")
 ELSE
  SET mf_end_date_qual = cnvtdatetime(build(trim( $ENDDATE)," 23:59:59"))
 ENDIF
 SET ms_beg_date_disp = format(mf_beg_date_qual,";;q")
 SET ms_end_date_disp = format(mf_end_date_qual,";;q")
 CALL echo(ms_beg_date_disp)
 CALL echo(ms_end_date_disp)
 SET mf_s_date = mf_beg_date_qual
 SET mf_e_date = datetimeadd(mf_s_date,7)
 IF (mf_e_date >= mf_end_date_qual)
  SET mf_e_date = mf_end_date_qual
 ENDIF
 IF (( $RUNTYPE=0))
  SET adm->d_beg_dt_tm = cnvtdatetime( $BEGDATE)
  SET adm->d_end_dt_tm = cnvtdatetime( $ENDDATE)
  SET adm->s_rpt_title = "ADE Report"
 ELSE
  SET adm->d_beg_dt_tm = mf_s_date
  SET adm->d_end_dt_tm = mf_e_date
  SET adm->s_rpt_title = "ADE Report Generated by System"
 ENDIF
 IF (( $RUNTYPE=0))
  IF (datetimediff(mf_end_date_qual,mf_beg_date_qual) > 10)
   CALL echo("Date range > 31")
   SELECT INTO  $OUTDEV
    FROM dummyt
    HEAD REPORT
     msg1 = "Your date range is larger than 10 days.", msg2 = "  Please retry.", col 0,
     "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
     "{F/1}{CPI/7}",
     CALL print(calcpos(36,(y_pos+ 0))), msg1,
     row + 2, msg2
    WITH dio = 08, mine, time = 5
   ;end select
   GO TO exit_script
  ELSEIF (datetimediff(mf_end_date_qual,mf_beg_date_qual) < 0)
   CALL echo("Date range < 0")
   SELECT INTO  $OUTDEV
    FROM dummyt
    HEAD REPORT
     msg1 = "Your date range is incorrect", msg2 = "  Please retry.", col 0,
     "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
     "{F/1}{CPI/7}",
     CALL print(calcpos(36,(y_pos+ 0))), msg1,
     row + 2, msg2
    WITH dio = 08
   ;end select
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM order_catalog_synonym ocs
  PLAN (ocs
   WHERE ocs.mnemonic_key_cap IN ("AQUAMEPHYTON 10 MG/ML INJ", "ATROPINE INJ", "D50%W",
   "DEXTROSE 50% INJ", "DEXTROSE 50% INJ SYRINGE (25GM)",
   "EPINEPHRINE 1MG/ML  INJ (ANAPHYLAXIS)", "EPINEPHRINE CONT IV", "EPINEPHRINE INJ",
   "FLUMAZENIL INJ", "GLUCAGON 20MG IN D5W 250ML",
   "GLUCAGON CONT IV", "GLUCAGON INJ", "GLYCOPYRROLATE (PEDI) INJ", "GLYCOPYRROLATE INJ",
   "HEPARIN 25,000 UNITS/250 ML D5W",
   "KAYEXALATE POWDER", "NALOXONE  0.2MG IN NACL 0.9% 50ML (PEDI STANDARD DOSING) TP",
   "NALOXONE  0.4MG IN NACL 0.9% 100ML (PEDI STANDARD DOSING) TO",
   "NALOXONE  1MG IN NACL 0.9% 250ML (PEDI STANDARD DOSING) TO", "NALOXONE  2 MG IN D5%W 500 ML",
   "NALOXONE 0.2MG IN NACL 0.9% 50ML (PEDI STANDARD DOSING) TO",
   "NALOXONE 0.4MG IN NACL 0.9%  100ML (PEDI STANDARD DOSING) TP",
   "NALOXONE 0.4MG IN NACL 0.9% 100ML (PEDI STANDARD DOSING) TP",
   "NALOXONE 2 MG IN NACL 0.9% 500 ML", "NALOXONE CONT IV",
   "NALOXONE INJ", "NARCAN CONT IV", "NARCAN INJ", "PHYTONADIONE 10 MG/ML INJ",
   "PHYTONADIONE CONT IV",
   "PROTAMINE INJ", "ROBINUL (PEDI) INJ", "ROBINUL INJ", "ROMAZICON INJ", "VITAMIN K 10 MG/ML INJ",
   "VITAMIN K IVPB", "VITAMIN K INJ FOR ORAL USE", "VITAMIN K TABLET")
    AND ocs.active_ind=1)
  ORDER BY ocs.catalog_cd, ocs.synonym_id
  HEAD REPORT
   mn_cnt = 0
  HEAD ocs.synonym_id
   mn_cnt = (mn_cnt+ 1), stat = alterlist(med->syn,mn_cnt), med->syn[mn_cnt].f_catalog_cd = ocs
   .catalog_cd,
   med->syn[mn_cnt].ms_catalog_disp = uar_get_code_display(ocs.catalog_cd), med->syn[mn_cnt].
   f_synonym_id = ocs.synonym_id, med->syn[mn_cnt].ms_synonym_disp = ocs.mnemonic
  WITH nocounter
 ;end select
 CALL echo(format(sysdate,";;q"))
 SELECT INTO "nl:"
  FROM encounter e,
   clinical_event ce,
   orders o
  PLAN (ce
   WHERE ce.performed_dt_tm BETWEEN cnvtdatetime(adm->d_beg_dt_tm) AND cnvtdatetime(adm->d_end_dt_tm)
    AND expand(ml_cnt1,1,size(med->syn,5),ce.catalog_cd,med->syn[ml_cnt1].f_catalog_cd)
    AND ((ce.valid_until_dt_tm - 0) > sysdate)
    AND ce.view_level=1
    AND ce.result_status_cd IN (mf_altered, mf_modified, mf_auth)
    AND ce.event_tag != "In Error")
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id
    AND e.loc_facility_cd=mf_facility_cd
    AND e.encntr_type_class_cd=mf_inpt_cd
    AND e.active_ind=1)
   JOIN (o
   WHERE o.order_id=ce.order_id
    AND expand(ml_cnt2,1,size(med->syn,5),o.synonym_id,med->syn[ml_cnt2].f_synonym_id)
    AND o.catalog_type_cd=mf_pharmacy_cd
    AND o.template_order_id=0
    AND o.active_ind=1)
  ORDER BY e.encntr_id, o.order_id, ce.performed_dt_tm
  HEAD REPORT
   pl_cnt = 0
  HEAD e.encntr_id
   ml_cnt = 0, pl_cnt = (pl_cnt+ 1), stat = alterlist(adm->qual,pl_cnt),
   adm->qual[pl_cnt].f_person_id = ce.person_id, adm->qual[pl_cnt].f_encntr_id = ce.encntr_id, adm->
   qual[pl_cnt].s_pat_loc = uar_get_code_display(e.loc_nurse_unit_cd)
  HEAD o.order_id
   ml_cnt = (ml_cnt+ 1), stat = alterlist(adm->qual[pl_cnt].med,ml_cnt), adm->qual[pl_cnt].med[ml_cnt
   ].f_event_id = ce.event_id,
   adm->qual[pl_cnt].med[ml_cnt].ms_adm_dt_tm = format(ce.performed_dt_tm,";;q"), adm->qual[pl_cnt].
   med[ml_cnt].f_trigger_ord_id = o.order_id, adm->qual[pl_cnt].med[ml_cnt].ms_trigger_ord_dose = ce
   .event_tag,
   ml_syn_pos = locateval(ml_idx2,1,size(med->syn,5),o.synonym_id,med->syn[ml_idx2].f_synonym_id),
   adm->qual[pl_cnt].med[ml_cnt].ms_ord_info = uar_get_code_display(o.catalog_cd), adm->qual[pl_cnt].
   med[ml_cnt].mf_cat_cd = o.catalog_cd
  WITH nocounter
 ;end select
 CALL echo(format(sysdate,";;q"))
 IF (curqual < 1)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(adm->qual,5))),
   person p
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=adm->qual[d.seq].f_person_id))
  DETAIL
   adm->qual[d.seq].s_pat_name = p.name_full_formatted, adm->qual[d.seq].s_age = cnvtage(p
    .birth_dt_tm)
  WITH nocounter
 ;end select
 CALL echo(format(sysdate,";;q"))
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(adm->qual,5))),
   encntr_alias ea1
  PLAN (d)
   JOIN (ea1
   WHERE ea1.encntr_id=outerjoin(adm->qual[d.seq].f_encntr_id)
    AND ea1.active_ind=outerjoin(1)
    AND ea1.encntr_alias_type_cd=outerjoin(mf_fin_cd))
  DETAIL
   adm->qual[d.seq].s_fin = trim(ea1.alias)
  WITH nocounter
 ;end select
 CALL echo(format(sysdate,";;q"))
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(adm->qual,5))),
   (dummyt d2  WITH seq = 1),
   order_detail od
  PLAN (d1
   WHERE maxrec(d2,size(adm->qual[d1.seq].med,5)))
   JOIN (d2)
   JOIN (od
   WHERE (od.order_id=adm->qual[d1.seq].med[d2.seq].f_trigger_ord_id)
    AND od.oe_field_meaning="RXROUTE")
  DETAIL
   adm->qual[d1.seq].med[d2.seq].ms_trigger_ord_rte = trim(od.oe_field_display_value)
  WITH nocounter
 ;end select
 CALL echo(format(sysdate,";;q"))
 SELECT INTO "nl:"
  f_event_id = adm->qual[d1.seq].med[d2.seq].f_event_id, f_encntr_id = adm->qual[d1.seq].f_encntr_id
  FROM (dummyt d1  WITH seq = value(size(adm->qual,5))),
   (dummyt d2  WITH seq = 1),
   clinical_event ce,
   orders o,
   order_detail od,
   order_action oa
  PLAN (d1
   WHERE maxrec(d2,size(adm->qual[d1.seq].med,5)))
   JOIN (d2)
   JOIN (ce
   WHERE (ce.person_id=adm->qual[d1.seq].f_person_id)
    AND (ce.encntr_id=adm->qual[d1.seq].f_encntr_id)
    AND ce.event_class_cd=mf_med_var
    AND ce.performed_dt_tm >= cnvtdatetime(datetimeadd(cnvtdatetime(adm->qual[d1.seq].med[d2.seq].
      ms_adm_dt_tm),- (3)))
    AND ce.performed_dt_tm <= cnvtdatetime(adm->qual[d1.seq].med[d2.seq].ms_adm_dt_tm)
    AND (ce.order_id != adm->qual[d1.seq].med[d2.seq].f_trigger_ord_id)
    AND ce.result_status_cd IN (mf_altered, mf_modified, mf_auth)
    AND ce.valid_until_dt_tm > sysdate
    AND ce.event_tag != "In Error"
    AND ce.catalog_cd != 0)
   JOIN (o
   WHERE o.order_id=ce.order_id)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.core_ind=1)
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_meaning="RXROUTE")
  ORDER BY f_encntr_id, f_event_id, ce.event_end_dt_tm DESC
  HEAD f_encntr_id
   al_cnt = 0
  HEAD f_event_id
   al_cnt = 0
  HEAD ce.event_id
   al_cnt = (al_cnt+ 1), stat = alterlist(adm->qual[d1.seq].med[d2.seq].ord,al_cnt), adm->qual[d1.seq
   ].med[d2.seq].ord[al_cnt].f_ade_ord_id = ce.order_id,
   adm->qual[d1.seq].med[d2.seq].ord[al_cnt].f_ade_event_id = ce.event_id, adm->qual[d1.seq].med[d2
   .seq].ord[al_cnt].ms_ade_ord_info = uar_get_code_display(o.catalog_cd), adm->qual[d1.seq].med[d2
   .seq].ord[al_cnt].ms_ade_adm_dttm = format(ce.event_end_dt_tm,";;q"),
   adm->qual[d1.seq].med[d2.seq].ord[al_cnt].ms_ade_adm_dose = ce.event_tag
  DETAIL
   IF (od.oe_field_meaning="RXROUTE")
    adm->qual[d1.seq].med[d2.seq].ord[al_cnt].ms_ade_ord_rte = trim(od.oe_field_display_value)
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(format(sysdate,";;q"))
 SELECT INTO value(ms_output_dest)
  pt_name = adm->qual[d1.seq].s_pat_name
  FROM (dummyt d1  WITH seq = 1)
  PLAN (d1)
  ORDER BY pt_name
  HEAD REPORT
   ms_output_line1 = concat(trim(uar_get_code_description(mf_facility_cd))," ",trim(substring(1,50,
      adm->s_rpt_title))," Beginning Date: ",format(cnvtdatetime(adm->d_beg_dt_tm),"MM/DD/YYYY;;q"),
    " Ending Date: ",format(cnvtdatetime(adm->d_end_dt_tm),"MM/DD/YYYY;;q")), ms_output_line = build(
    ',"',"Patient Name",'","',"FIN",'","',
    "Patient Loc",'","',"Patient age",'","',"Trigger drug name",
    '","',"Trigger drug admin dose",'","',"Trigger drug route",'","',
    "Trigger drug Admin Dt Tm",'","',"ADE Medication",'","',"ADE Med dt tm",
    '","',"ADE Med dose",'","',"ADE Med route",'",'), col 1,
   ms_output_line1, row + 1, col 1,
   ms_output_line, row + 1
  DETAIL
   ms_str1 = "", ms_str2 = "", ms_output_line1 = "",
   CALL echo("HERE"),
   CALL echo(size(adm->qual,5))
   FOR (ml_for1 = 1 TO size(adm->qual,5))
    ms_str1 = build(',"',substring(1,50,adm->qual[ml_for1].s_pat_name),'","',substring(1,15,adm->
      qual[ml_for1].s_fin),'","',
     substring(1,30,adm->qual[ml_for1].s_pat_loc),'","',adm->qual[ml_for1].s_age),
    IF (size(adm->qual[ml_for1].med,5)=0)
     col 1, ms_str1, row + 1
    ELSE
     FOR (ml_for2 = 1 TO size(adm->qual[ml_for1].med,5))
      ms_str2 = build(ms_str1,'","',substring(1,100,adm->qual[ml_for1].med[ml_for2].ms_ord_info),
       '","',substring(1,20,adm->qual[ml_for1].med[ml_for2].ms_trigger_ord_dose),
       '","',substring(1,30,adm->qual[ml_for1].med[ml_for2].ms_trigger_ord_rte),'","',substring(1,30,
        adm->qual[ml_for1].med[ml_for2].ms_adm_dt_tm)),
      IF (size(adm->qual[ml_for1].med[ml_for2].ord,5)=0)
       col 1, ms_str2, row + 1
      ELSE
       FOR (ml_for3 = 1 TO size(adm->qual[ml_for1].med[ml_for2].ord,5))
         ms_output_line1 = build(ms_str2,'","',substring(1,100,adm->qual[ml_for1].med[ml_for2].ord[
           ml_for3].ms_ade_ord_info),'","',substring(1,30,adm->qual[ml_for1].med[ml_for2].ord[ml_for3
           ].ms_ade_adm_dttm),
          '","',substring(1,20,adm->qual[ml_for1].med[ml_for2].ord[ml_for3].ms_ade_adm_dose),'","',
          substring(1,30,adm->qual[ml_for1].med[ml_for2].ord[ml_for3].ms_ade_ord_rte),'",'), col 1,
         ms_output_line1,
         row + 1
       ENDFOR
      ENDIF
     ENDFOR
    ENDIF
   ENDFOR
  WITH maxcol = 20000, formfeed = none, maxrow = 1,
   format = variable
 ;end select
 CALL echo(format(sysdate,";;q"))
 IF (( $RUNTYPE=1))
  SET ms_filename_in = concat(trim(ms_output_dest),".dat")
  SET ms_filename_out = concat(format(curdate,"MMDDYYYY;;D"),".csv")
  SET ms_subject_line = concat(curprog," - ADE Rpt ",ms_beg_date_disp," to ",ms_end_date_disp)
  EXECUTE bhs_ma_email_file
  CALL emailfile(ms_filename_in,ms_filename_out, $1,ms_subject_line,1)
 ENDIF
 CALL echorecord(adm)
#exit_script
END GO
