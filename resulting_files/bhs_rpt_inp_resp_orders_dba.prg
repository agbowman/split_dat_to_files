CREATE PROGRAM bhs_rpt_inp_resp_orders:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Facility" = 0,
  "Unit" = value(0.0),
  "Start Order date" = "SYSDATE",
  "End Order Date" = "SYSDATE"
  WITH outdev, fname, f_unit,
  s_start_date, s_end_date
 DECLARE mf_cs16449_frequency = f8 WITH constant(uar_get_code_by("DISPLAYKEY",16449,"FREQUENCY")),
 protect
 DECLARE mf_cs106_nsgrespiratorytx = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,
   "NSGRESPIRATORYTX")), protect
 DECLARE mf_cs6000_respiratorytherapy = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6000,
   "RESPIRATORYTHERAPY")), protect
 DECLARE opr_var = vc WITH protect
 DECLARE mf_cs71_daystay = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DAYSTAY")), protect
 DECLARE mf_cs71_emergency = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EMERGENCY")), protect
 DECLARE mf_cs71_inpatient = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT")), protect
 DECLARE mf_cs71_observation = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"OBSERVATION")),
 protect
 DECLARE mf_cs6000_pharmacy = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY")),
 protect
 DECLARE mf_cs48_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE mf_cs319_mrn_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"MRN")), protect
 DECLARE mf_cs6004_completed = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"COMPLETED")),
 protect
 DECLARE mf_cs6004_ordered = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED")), protect
 DECLARE mf_cs6004_discontinued = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"DISCONTINUED")),
 protect
 DECLARE mf_cs6003_discontinue = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6003,"DISCONTINUE")),
 protect
 DECLARE mf_cs6003_order = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6003,"ORDER")), protect
 DECLARE mf_cs6003_complete = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6003,"COMPLETE")),
 protect
 DECLARE mf_cs4002_inhalationsuspension = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4002,
   "INHALATIONSUSPENSION")), protect
 DECLARE mf_cs4002_inhalationsolution = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4002,
   "INHALATIONSOLUTION")), protect
 DECLARE mf_cs16449_drugform = f8 WITH constant(uar_get_code_by("DISPLAYKEY",16449,"DRUG FORM")),
 protect
 DECLARE ms_start_date = vc WITH noconstant( $S_START_DATE), protect
 DECLARE ms_end_date = vc WITH noconstant( $S_END_DATE), protect
 DECLARE ml_num = i4 WITH protect
 DECLARE respiratory_order = vc WITH noconstant(
  "                                                                       "), protect
 SET lcheck = substring(1,1,reflect(parameter(parameter2( $F_UNIT),0)))
 FREE RECORD grec1
 RECORD grec1(
   1 list[*]
     2 cv = f8
     2 disp = c15
 )
 IF (lcheck="L")
  SET opr_var = "IN"
  WHILE (lcheck > " ")
    SET gcnt += 1
    SET lcheck = substring(1,1,reflect(parameter(parameter2( $F_UNIT),gcnt)))
    CALL echo(lcheck)
    IF (lcheck > " ")
     IF (mod(gcnt,5)=1)
      SET stat = alterlist(grec1->list,(gcnt+ 4))
     ENDIF
     SET grec1->list[gcnt].cv = cnvtint(parameter(parameter2( $F_UNIT),gcnt))
     SET grec1->list[gcnt].disp = uar_get_code_display(parameter(parameter2( $F_UNIT),gcnt))
    ENDIF
  ENDWHILE
  SET gcnt -= 1
  SET stat = alterlist(grec1->list,gcnt)
 ELSE
  SET stat = alterlist(grec1->list,1)
  SET gcnt = 1
  SET grec1->list[1].cv =  $F_UNIT
  IF ((grec1->list[1].cv=0.0))
   SET grec1->list[1].disp = "All Units"
   SET opr_var = "!="
  ELSE
   SET grec1->list[1].disp = uar_get_code_display(grec1->list[1].cv)
   SET opr_var = "="
  ENDIF
 ENDIF
 SELECT INTO  $OUTDEV
  patient_name = substring(1,100,p.name_full_formatted), mrn = substring(1,20,trim(mrn.alias,3)),
  facility = substring(1,100,uar_get_code_display(e.loc_facility_cd)),
  unit = substring(1,100,uar_get_code_display(e.loc_nurse_unit_cd)), room_bed = substring(1,100,
   concat(trim(uar_get_code_display(e.loc_room_cd),3),"-",trim(uar_get_code_display(e.loc_bed_cd),3))
   ), respiratory_order = substring(1,100,trim(o.ordered_as_mnemonic,3)),
  frequency = substring(1,100,od.oe_field_display_value), order_date = format(o.orig_order_dt_tm,
   "mm/dd/yyyy;;d"), order_status = trim(uar_get_code_display(o.order_status_cd),3)
  FROM orders o,
   encounter e,
   encntr_alias mrn,
   person p,
   code_value fac,
   code_value nurs,
   order_detail od,
   dummyt d1
  PLAN (o
   WHERE o.template_order_flag IN (0, 1)
    AND ((o.order_status_cd IN (mf_cs6004_ordered)
    AND o.orig_order_dt_tm <= cnvtdatetime(ms_start_date)) OR (((o.order_id IN (
   (SELECT
    oa1.order_id
    FROM order_action oa1
    WHERE oa1.order_id=o.order_id
     AND oa1.action_type_cd=mf_cs6003_order
     AND oa1.action_dt_tm BETWEEN cnvtdatetime(ms_start_date) AND cnvtdatetime(ms_end_date)))) OR (((
   o.order_id IN (
   (SELECT
    oa2.order_id
    FROM order_action oa2
    WHERE oa2.order_id=o.order_id
     AND oa2.action_type_cd=mf_cs6003_discontinue
     AND oa2.action_dt_tm BETWEEN cnvtdatetime(ms_start_date) AND cnvtdatetime(ms_end_date)))) OR (o
   .order_id IN (
   (SELECT
    oa3.order_id
    FROM order_action oa3
    WHERE oa3.order_id=o.order_id
     AND oa3.action_type_cd=mf_cs6003_complete
     AND oa3.action_dt_tm BETWEEN cnvtdatetime(ms_start_date) AND cnvtdatetime(ms_end_date))))) ))
   ))
    AND ((o.catalog_type_cd=mf_cs6000_respiratorytherapy) OR (((o.activity_type_cd=
   mf_cs106_nsgrespiratorytx) OR (o.order_id IN (
   (SELECT
    od.order_id
    FROM order_detail od
    WHERE od.order_id=o.order_id
     AND od.action_sequence=o.last_action_sequence
     AND od.oe_field_id=mf_cs16449_drugform
     AND od.oe_field_value IN (mf_cs4002_inhalationsuspension, mf_cs4002_inhalationsolution))))) )) )
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND e.active_status_cd=mf_cs48_active
    AND (e.loc_facility_cd= $FNAME)
    AND operator(e.loc_nurse_unit_cd,opr_var, $F_UNIT)
    AND e.encntr_type_cd IN (mf_cs71_daystay, mf_cs71_emergency, mf_cs71_inpatient,
   mf_cs71_observation))
   JOIN (fac
   WHERE fac.code_value=e.loc_facility_cd
    AND fac.code_set=220)
   JOIN (nurs
   WHERE nurs.code_value=e.loc_nurse_unit_cd
    AND nurs.code_set=220)
   JOIN (mrn
   WHERE mrn.encntr_id=e.encntr_id
    AND mrn.active_status_cd=mf_cs48_active
    AND mrn.encntr_alias_type_cd=mf_cs319_mrn_cd
    AND mrn.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND mrn.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND mrn.active_ind=1)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (d1)
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_id=mf_cs16449_frequency
    AND od.action_sequence IN (
   (SELECT
    max(od1.action_sequence)
    FROM order_detail od1
    WHERE od1.order_id=od.order_id
     AND od1.oe_field_meaning_id=od.oe_field_meaning_id
    GROUP BY od1.order_id)))
  ORDER BY fac.display, nurs.display
  WITH nocounter, format, separator = " ",
   outerjoin = d1
 ;end select
END GO
