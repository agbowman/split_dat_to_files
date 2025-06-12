CREATE PROGRAM bhs_rpt_resp_med_notdone:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Facility" = 0,
  "Unit" = value(0.0),
  "Start Med Admin date" = "SYSDATE",
  "End Med Admin Date" = "SYSDATE"
  WITH outdev, fname, f_unit,
  s_start_date, s_end_date
 DECLARE mf_cs72_dcpgenericcode = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!1302386")),
 protect
 DECLARE mf_cs6000_respiratorytherapy = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6000,
   "RESPIRATORYTHERAPY")), protect
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
 DECLARE mf_cs4000040_administered = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4000040,
   "ADMINISTERED")), protect
 DECLARE mf_cs4000040_notgiven = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4000040,"NOTGIVEN")),
 protect
 DECLARE mf_cs4000040_notadministeredtaskpurged = f8 WITH constant(uar_get_code_by("DISPLAYKEY",
   4000040,"NOTADMINISTEREDTASKPURGED")), protect
 DECLARE mf_cs4000040_notdone = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4000040,"NOTDONE")),
 protect
 DECLARE mf_cs8_altered_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED")), protect
 DECLARE mf_cs8_modified_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED")), protect
 DECLARE mf_cs8_auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
 DECLARE mf_cs8_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"ACTIVE")), protect
 DECLARE mf_cs8_notdone = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"NOTDONE")), protect
 DECLARE mf_cs53_txt = f8 WITH constant(uar_get_code_by("DISPLAYKEY",53,"TXT")), protect
 DECLARE mf_cs53_med = f8 WITH constant(uar_get_code_by("DISPLAYKEY",53,"MED")), protect
 DECLARE mf_cs24_root = f8 WITH constant(uar_get_code_by("MEANING",24,"ROOT")), protect
 DECLARE mf_cs24_child = f8 WITH constant(uar_get_code_by("MEANING",24,"CHILD")), protect
 DECLARE mf_cs4002_inhalationsuspension = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4002,
   "INHALATIONSUSPENSION")), protect
 DECLARE mf_cs4002_inhalationsolution = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4002,
   "INHALATIONSOLUTION")), protect
 DECLARE mf_cs16449_drugform = f8 WITH constant(uar_get_code_by("DISPLAYKEY",16449,"DRUG FORM")),
 protect
 DECLARE ms_start_date = vc WITH noconstant( $S_START_DATE), protect
 DECLARE ms_end_date = vc WITH noconstant( $S_END_DATE), protect
 DECLARE opr_var = vc WITH protect
 SET lcheck = substring(1,1,reflect(parameter(parameter2( $F_UNIT),0)))
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
  unit = substring(1,100,uar_get_code_display(elh.loc_nurse_unit_cd)), room_bed = substring(1,100,
   concat(trim(uar_get_code_display(elh.loc_room_cd),3),"-",trim(uar_get_code_display(elh.loc_bed_cd),
     3))), medication_order = substring(1,100,trim(o2.ordered_as_mnemonic,3)),
  date_not_given = format(o2.current_start_dt_tm,"dd-mmm-yyyy hh:mm;;d"), reason =
  IF (ce2.event_tag=null) "Not Charted"
  ELSE substring(1,100,trim(ce2.event_tag,3))
  ENDIF
  , performed_by = substring(1,100,trim(pr.name_full_formatted,3))
  FROM orders o,
   orders o2,
   clinical_event ce1,
   clinical_event ce2,
   encounter e,
   encntr_alias mrn,
   person p,
   prsnl pr,
   encntr_loc_hist elh
  PLAN (o2
   WHERE o2.current_start_dt_tm BETWEEN cnvtdatetime(ms_start_date) AND cnvtdatetime(ms_end_date)
    AND o2.template_order_id > 0
    AND o2.catalog_type_cd=mf_cs6000_pharmacy
    AND o2.order_id IN (
   (SELECT
    od.order_id
    FROM order_detail od
    WHERE od.order_id=o2.order_id
     AND od.oe_field_id=mf_cs16449_drugform
     AND od.oe_field_value IN (mf_cs4002_inhalationsolution, mf_cs4002_inhalationsuspension))))
   JOIN (o
   WHERE o.order_id=o2.template_order_id
    AND o.catalog_type_cd=mf_cs6000_pharmacy)
   JOIN (elh
   WHERE elh.encntr_id=o.encntr_id
    AND elh.active_ind=1
    AND o2.current_start_dt_tm BETWEEN elh.beg_effective_dt_tm AND elh.end_effective_dt_tm
    AND operator(elh.loc_nurse_unit_cd,opr_var, $F_UNIT)
    AND (elh.loc_facility_cd= $FNAME))
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND e.active_status_cd=mf_cs48_active
    AND (e.loc_facility_cd= $FNAME)
    AND e.encntr_type_cd IN (mf_cs71_daystay, mf_cs71_emergency, mf_cs71_inpatient,
   mf_cs71_observation))
   JOIN (mrn
   WHERE mrn.encntr_id=e.encntr_id
    AND mrn.active_status_cd=mf_cs48_active
    AND mrn.encntr_alias_type_cd=mf_cs319_mrn_cd
    AND mrn.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND mrn.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND mrn.active_ind=1)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ce1
   WHERE (ce1.order_id= Outerjoin(o2.order_id))
    AND (ce1.valid_from_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
    AND (ce1.valid_until_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
    AND (ce1.result_status_cd= Outerjoin(mf_cs8_auth_cd))
    AND (ce1.event_reltn_cd= Outerjoin(mf_cs24_root)) )
   JOIN (ce2
   WHERE (ce2.parent_event_id= Outerjoin(ce1.event_id))
    AND (ce2.valid_from_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
    AND (ce2.valid_until_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
    AND (ce2.result_status_cd= Outerjoin(mf_cs8_notdone))
    AND (ce2.event_reltn_cd= Outerjoin(mf_cs24_child)) )
   JOIN (pr
   WHERE (pr.person_id= Outerjoin(ce2.performed_prsnl_id)) )
  ORDER BY facility, unit, room_bed,
   o2.template_order_id, o2.current_start_dt_tm
  WITH nocounter, format, separator = " "
 ;end select
END GO
