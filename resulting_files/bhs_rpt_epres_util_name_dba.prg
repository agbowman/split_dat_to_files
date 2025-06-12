CREATE PROGRAM bhs_rpt_epres_util_name:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date" = "CURDATE",
  "End Date" = "CURDATE",
  "Eprescribed, printed, or both:" = "",
  "Schedule:" = ""
  WITH outdev, s_beg_dt_tm, s_end_dt_tm,
  s_eprescribe, s_csa_schedule
 DECLARE ms_beg_dt_tm = vc WITH protect
 DECLARE ms_end_dt_tm = vc WITH protect
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_csa_parser = vc WITH protect, noconstant(" ")
 DECLARE ms_eprescribe_parser = vc WITH protect, noconstant(" ")
 DECLARE mn_email_ind = i2 WITH protect, noconstant(0)
 DECLARE ms_output_dest = vc WITH protect, noconstant(" ")
 DECLARE ms_filename_out = vc WITH protect, noconstant(" ")
 DECLARE ms_address_list = vc WITH protect, noconstant(" ")
 SET ms_beg_dt_tm = concat( $S_BEG_DT_TM," 00:00:00")
 SET ms_end_dt_tm = format(cnvtlookahead("1 D",cnvtdatetime(concat( $S_END_DT_TM," 00:00:00"))),
  "DD-MMM-YYYY HH:mm:ss;;D")
 SET mn_email_ind = 0
 SET ms_output_dest =  $OUTDEV
 CASE ( $S_CSA_SCHEDULE)
  OF "0":
   SET ms_csa_parser = 'mmdc.csa_schedule = "0"'
  OF "1":
   SET ms_csa_parser = 'mmdc.csa_schedule != "0"'
  OF "2":
   SET ms_csa_parser = 'mmdc.csa_schedule >= "0"'
 ENDCASE
 CASE ( $S_EPRESCRIBE)
  OF "0":
   SET ms_eprescribe_parser = 'od.oe_field_display_value = "Route to Pharmacy Electronically"'
  OF "1":
   SET ms_eprescribe_parser = 'od.oe_field_display_value != "Route to Pharmacy Electronically"'
  OF "2":
   SET ms_eprescribe_parser = 'od.oe_field_display_value >= " "'
 ENDCASE
 SELECT DISTINCT INTO value(ms_output_dest)
  patient_name = trim(substring(1,100,p.name_full_formatted),3), o.order_id, ordered_as_mnemonic =
  trim(substring(1,100,o.ordered_as_mnemonic),3),
  order_dt_tm = format(oa.order_dt_tm,"mm/dd/yyyy hh:mm;;d"), mmdc.csa_schedule, order_status =
  uar_get_code_display(o.order_status_cd),
  location = trim(substring(1,100,build2(trim(uar_get_code_display(e.loc_facility_cd),3),"/",trim(
      uar_get_code_display(e.loc_nurse_unit_cd),3))),3), encntr_type = trim(uar_get_code_display(e
    .encntr_type_cd),3), acc# = ea.alias,
  ordering_provider = trim(substring(1,100,pr.name_full_formatted),3)
  FROM orders o,
   order_detail od,
   order_catalog oc,
   mltm_ndc_main_drug_code mmdc,
   encounter e,
   encntr_alias ea,
   order_action oa,
   person p,
   prsnl pr
  PLAN (o
   WHERE o.orig_order_dt_tm >= cnvtdatetime(ms_beg_dt_tm)
    AND o.orig_order_dt_tm < cnvtdatetime(ms_end_dt_tm)
    AND o.catalog_type_cd=value(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY"))
    AND o.orig_ord_as_flag=1
    AND o.order_status_cd=value(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
    AND o.active_ind=1)
   JOIN (od
   WHERE o.order_id=od.order_id
    AND od.oe_field_meaning="REQROUTINGTYPE"
    AND parser(ms_eprescribe_parser))
   JOIN (oc
   WHERE oc.catalog_cd=o.catalog_cd)
   JOIN (mmdc
   WHERE concat("MUL.ORD!",trim(cnvtstring(mmdc.drug_identifier)))=oc.cki
    AND parser(ms_csa_parser))
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND e.active_ind=1
    AND e.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=value(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (oa
   WHERE oa.order_id=o.order_id)
   JOIN (pr
   WHERE pr.person_id=oa.order_provider_id)
  ORDER BY o.ordered_as_mnemonic, order_dt_tm
  WITH format, separator = " ", nocounter
 ;end select
#exit_script
END GO
