CREATE PROGRAM bhs_rpt_med_active_by_locale:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start date" = "CURDATE",
  "End Date" = "CURDATE",
  "Location Type" = 0,
  "Select Facility" = 0,
  "Unit" = value(0.0),
  "Select Theraputic Class" = value(632575.00,137263126.00),
  "Select Medication" = 0,
  "Order Status" = value(2550.00),
  "Select Encounter Type" = 0
  WITH outdev, s_start_date, s_end_date,
  f_location_type, f_facility, f_unit,
  ther_class, f_meds, f_ord_stat,
  f_encntr_type
 DECLARE mf_cs319_fin_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR")), protect
 DECLARE mf_cs319_mrn_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"MRN")), protect
 DECLARE mf_cs48_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE ms_start_date = vc WITH noconstant( $S_START_DATE), protect
 DECLARE ms_end_date = vc WITH noconstant( $S_END_DATE), protect
 DECLARE md_start_date = dq8 WITH noconstant(cnvtdatetime(cnvtdate2(ms_start_date,"DD-MMM-YYYY"),0)),
 protect
 DECLARE md_end_date = dq8 WITH noconstant(cnvtdatetime(cnvtdate2(ms_end_date,"DD-MMM-YYYY"),235959)),
 protect
 SELECT INTO  $OUTDEV
  facility = uar_get_code_display(e.loc_facility_cd), unit = uar_get_code_display(e.loc_nurse_unit_cd
   ), encounter_type = uar_get_code_display(e.encntr_type_cd),
  patient_name = substring(1,100,p.name_full_formatted), dob = datebirthformat(p.birth_dt_tm,p
   .birth_tz,p.birth_prec_flag,"@SHORTDATE4YR"), mrn = substring(1,100,mrn.alias),
  order_mnemonic = substring(1,100,o.order_mnemonic), ordered_as_mnemonic = substring(1,100,o
   .ordered_as_mnemonic), stop_date = substring(1,50,std.oe_field_display_value),
  stop_type = substring(1,50,stt.oe_field_display_value)
  FROM encounter e,
   orders o,
   person p,
   encntr_alias mrn,
   encntr_alias fin,
   dummyt d1,
   order_detail std,
   order_detail stt
  PLAN (e
   WHERE e.active_status_cd=mf_cs48_active
    AND (e.loc_nurse_unit_cd= $F_UNIT)
    AND e.active_ind=1
    AND (e.encntr_type_cd= $F_ENCNTR_TYPE))
   JOIN (o
   WHERE o.template_order_flag IN (1, 0)
    AND o.person_id=e.person_id
    AND o.encntr_id=e.encntr_id
    AND (o.catalog_cd= $F_MEDS)
    AND o.orig_order_dt_tm BETWEEN cnvtdatetime(md_start_date) AND cnvtdatetime(md_end_date)
    AND (o.order_status_cd= $F_ORD_STAT))
   JOIN (fin
   WHERE fin.encntr_id=o.encntr_id
    AND fin.active_ind=1
    AND fin.encntr_alias_type_cd=mf_cs319_fin_cd
    AND sysdate BETWEEN fin.beg_effective_dt_tm AND fin.end_effective_dt_tm)
   JOIN (mrn
   WHERE mrn.encntr_id=o.encntr_id
    AND mrn.active_ind=1
    AND mrn.encntr_alias_type_cd=mf_cs319_mrn_cd
    AND sysdate BETWEEN mrn.beg_effective_dt_tm AND mrn.end_effective_dt_tm)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_status_cd=mf_cs48_active)
   JOIN (d1)
   JOIN (std
   WHERE std.order_id=o.order_id
    AND std.action_sequence IN (
   (SELECT
    max(odi2.action_sequence)
    FROM order_detail odi2
    WHERE odi2.order_id=std.order_id
     AND odi2.oe_field_meaning_id=std.oe_field_meaning_id
     AND odi2.oe_field_meaning="STOPDTTM"
     AND odi2.oe_field_dt_tm_value >= sysdate
    GROUP BY odi2.order_id)))
   JOIN (stt
   WHERE stt.order_id=o.order_id
    AND stt.action_sequence IN (
   (SELECT
    max(odi2.action_sequence)
    FROM order_detail odi2
    WHERE odi2.order_id=stt.order_id
     AND odi2.oe_field_meaning_id=stt.oe_field_meaning_id
     AND odi2.oe_field_meaning="STOPTYPE"
    GROUP BY odi2.order_id)))
  WITH nocounter, format, separator = " ",
   outjoin(d1)
 ;end select
END GO
