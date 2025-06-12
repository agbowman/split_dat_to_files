CREATE PROGRAM bhs_sn_non_invas_card_rpt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date" = "CURDATE",
  "End Date" = "CURDATE"
  WITH outdev, startdate, enddate
 DECLARE ms_start_date = vc WITH protect, constant(concat(trim( $STARTDATE)," 00:00:00"))
 DECLARE ms_end_date = vc WITH protect, constant(concat(trim( $ENDDATE)," 23:59:59"))
 DECLARE mf_non_invas_card_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,
   "NONINVASIVECARDIOLOGYTXPROCEDURES"))
 DECLARE mf_reason_for_exam_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "NICREASONFOREXAM"))
 DECLARE mf_other_reason_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "OTHERREASON"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_diag_working_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",17,"WORKING"))
 DECLARE mf_inpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"))
 DECLARE mf_cardiac_inpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "SNCARDIACINPATIENT"))
 DECLARE mf_tavr_inpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "SNTAVRINPATIENT"))
 DECLARE mf_vasc_inpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "SNVASCULARINPATIENT"))
 DECLARE mf_obs_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"OBSERVATION"))
 DECLARE mf_ed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EMERGENCY"))
 DECLARE mf_echo_2dw_cont_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "ECHO2DWCONTRAST"))
 DECLARE mf_echo_comp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"ECHOCOMPLETE")
  )
 DECLARE mf_echo_comp_pedi_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "ECHOCOMPLETEPEDI"))
 DECLARE mf_echo_stress_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"ECHOSTRESS")
  )
 DECLARE mf_echo_sress_wdobut_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "ECHOSTRESSWDOBUTAMINE"))
 DECLARE mf_echo_trans_esoph_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "ECHOTRANSESOPHAGEAL"))
 DECLARE ms_fmt_start_date = vc WITH protect, noconstant(format(cnvtdatetime( $STARTDATE),";;q"))
 DECLARE ms_fmt_end_date = vc WITH protect, noconstant(format(cnvtdatetime( $ENDDATE),";;q"))
 IF (cnvtdatetime(ms_start_date) > cnvtdatetime(ms_end_date))
  SELECT INTO  $OUTDEV
   FROM dual
   DETAIL
    col 0, 'Start Date "', col + 1,
    ms_fmt_start_date, col + 1, '" must be a date prior to End Date "',
    col + 1, ms_fmt_end_date, col + 1,
    '"'
   WITH nocounter
  ;end select
  GO TO exit_program
 ENDIF
 IF (datetimediff(cnvtdatetime(ms_end_date),cnvtdatetime(ms_start_date)) > 30)
  SELECT INTO  $OUTDEV
   FROM dual
   DETAIL
    col 0, 'Start "', col + 1,
    ms_fmt_start_date, col + 1, '" and End Date "',
    col + 1, ms_fmt_end_date, col + 1,
    '" can not be more than one 30 days apart'
   WITH nocounter
  ;end select
  GO TO exit_program
 ENDIF
 SELECT INTO  $OUTDEV
  order_id = o.order_id, order_date = format(o.orig_order_dt_tm,";;q"), fin = ea.alias,
  mrn = ea2.alias, patient_name = p.name_full_formatted, patient_status = uar_get_code_display(e
   .encntr_type_cd),
  catalog_cd = oc.primary_mnemonic, order_status = uar_get_code_display(o.order_status_cd),
  ordering_provider = p2.name_full_formatted,
  exam_reason = od.oe_field_display_value, other_reason_for_exam = od2.oe_field_display_value
  FROM orders o,
   (left JOIN order_detail od ON od.order_id=o.order_id
    AND od.oe_field_id=mf_reason_for_exam_cd
    AND (od.action_sequence=
   (SELECT
    max(od2.action_sequence)
    FROM order_detail od2
    WHERE od2.order_id=od.order_id
     AND od2.oe_field_id=mf_reason_for_exam_cd
    GROUP BY od2.order_id, od2.oe_field_id))),
   (left JOIN order_detail od2 ON od2.order_id=o.order_id
    AND od2.oe_field_id=mf_other_reason_cd
    AND (od2.action_sequence=
   (SELECT
    max(od3.action_sequence)
    FROM order_detail od3
    WHERE od3.order_id=od2.order_id
     AND od3.oe_field_id=mf_other_reason_cd
    GROUP BY od3.order_id, od3.oe_field_id))),
   encounter e,
   order_catalog oc,
   person p,
   person p2,
   encntr_alias ea,
   encntr_alias ea2
  PLAN (o
   WHERE o.activity_type_cd=mf_non_invas_card_cd
    AND o.catalog_cd IN (mf_echo_2dw_cont_cd, mf_echo_comp_cd, mf_echo_comp_pedi_cd,
   mf_echo_stress_cd, mf_echo_sress_wdobut_cd,
   mf_echo_trans_esoph_cd)
    AND o.orig_order_dt_tm BETWEEN cnvtdatetime(ms_start_date) AND cnvtdatetime(ms_end_date))
   JOIN (od)
   JOIN (od2)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND e.encntr_type_cd IN (mf_inpatient_cd, mf_cardiac_inpatient_cd, mf_tavr_inpatient_cd,
   mf_vasc_inpatient_cd, mf_obs_cd,
   mf_ed_cd))
   JOIN (oc
   WHERE oc.catalog_cd=o.catalog_cd)
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (p2
   WHERE p2.person_id=o.last_update_provider_id)
   JOIN (ea
   WHERE ea.encntr_id=o.encntr_id
    AND ea.encntr_alias_type_cd=mf_fin_cd)
   JOIN (ea2
   WHERE ea2.encntr_id=o.encntr_id
    AND ea2.encntr_alias_type_cd=mf_mrn_cd)
  ORDER BY patient_name, order_date, catalog_cd,
   order_status
  WITH format, separator = " "
 ;end select
#exit_program
END GO
