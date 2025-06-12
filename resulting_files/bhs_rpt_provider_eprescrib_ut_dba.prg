CREATE PROGRAM bhs_rpt_provider_eprescrib_ut:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date" = "CURDATE",
  "End Date" = "CURDATE",
  "Eprescribed, printed, or both:" = "",
  "Schedule:" = "",
  "Select Ordering Provider(search last name)" = 0
  WITH outdev, s_beg_dt_tm, s_end_dt_tm,
  s_eprescribe, s_csa_schedule, f_provider
 DECLARE mf_cs48_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE mf_cs319_mrn = f8 WITH constant(uar_get_code_by("MEANING",319,"MRN")), protect
 DECLARE mf_cs319_finnbr = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR")), protect
 DECLARE mf_cs6004_ordered = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED")), protect
 DECLARE mf_cs6000_pharmacy = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY")),
 protect
 DECLARE ms_beg_dt_tm = vc WITH protect
 DECLARE ms_end_dt_tm = vc WITH protect
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_csa_parser = vc WITH protect, noconstant(" ")
 DECLARE ms_eprescribe_parser = vc WITH protect, noconstant(" ")
 DECLARE ms_output_dest = vc WITH protect, noconstant(" ")
 DECLARE ms_filename_out = vc WITH protect, noconstant(" ")
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
  patient_name = substring(1,100,trim(p.name_full_formatted,3)), mrn = substring(1,25,mrn.alias), dob
   = datebirthformat(p.birth_dt_tm,p.birth_tz,p.birth_prec_flag,"@SHORTDATE4YR"),
  order_id = o.order_id, ordered_as_mnemonic = trim(substring(1,100,o.ordered_as_mnemonic),3),
  order_date_time = format(oa.order_dt_tm,"mm/dd/yyyy hh:mm;;d"),
  routing_type = trim(substring(1,255,od.oe_field_display_value),3), csa_schedule = mmdc.csa_schedule,
  order_status = uar_get_code_display(o.order_status_cd),
  ordering_provider = trim(substring(1,100,pr.name_full_formatted),3)
  FROM orders o,
   order_detail od,
   order_catalog oc,
   mltm_ndc_main_drug_code mmdc,
   encounter e,
   encntr_alias ea,
   encntr_alias mrn,
   order_action oa,
   prsnl pr,
   person p
  PLAN (o
   WHERE o.orig_order_dt_tm >= cnvtdatetime(ms_beg_dt_tm)
    AND o.orig_order_dt_tm < cnvtdatetime(ms_end_dt_tm)
    AND o.catalog_type_cd=mf_cs6000_pharmacy
    AND o.orig_ord_as_flag=1
    AND o.order_status_cd=mf_cs6004_ordered
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
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mf_cs319_finnbr
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (mrn
   WHERE mrn.encntr_id=e.encntr_id
    AND mrn.encntr_alias_type_cd=mf_cs319_mrn
    AND mrn.active_ind=1
    AND mrn.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (oa
   WHERE oa.order_id=o.order_id)
   JOIN (pr
   WHERE pr.person_id=oa.order_provider_id
    AND (pr.person_id= $F_PROVIDER))
   JOIN (p
   WHERE p.person_id=o.person_id
    AND p.active_ind=1
    AND p.active_status_cd=mf_cs48_active)
  ORDER BY ordering_provider, p.name_full_formatted, o.ordered_as_mnemonic,
   o.orig_order_dt_tm
  WITH format, separator = " ", nocounter
 ;end select
#exit_script
END GO
