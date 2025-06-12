CREATE PROGRAM bhs_rpt_active_isolation_order:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date" = "SYSDATE",
  "End Date" = "SYSDATE",
  "Select Facility" = 673936.00,
  "Select Nursing Unit or Any(*) for All :" = 0
  WITH outdev, s_start_date, s_end_date,
  f_fname, f_nunit
 DECLARE mf_cs6004_discontinued_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,
   "DISCONTINUED")), protect
 DECLARE mf_cs6004_ordered_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED")),
 protect
 DECLARE mf_cs319_mrn_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"MRN")), protect
 DECLARE mf_cs200_isolationcovid_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "ISOLATIONCOVID")), protect
 DECLARE mf_cs200_isolation_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"ISOLATION")),
 protect
 DECLARE mf_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE mc_opr_var = vc WITH noconstant("  "), protect
 DECLARE ml_gcnt = i4 WITH noconstant(0), protect
 DECLARE admit_date = vc WITH noconstant("                          "), protect
 DECLARE order_date = vc WITH noconstant("                          "), protect
 DECLARE isolation_orders = vc WITH noconstant("                          "), protect
 DECLARE unit = vc WITH noconstant("                          "), protect
 DECLARE mrn = vc WITH noconstant("                          "), protect
 DECLARE patient_first_name = vc WITH noconstant("                          "), protect
 DECLARE patient_last_name = vc WITH noconstant("                          "), protect
 DECLARE facility = vc WITH noconstant("                          "), protect
 SET lcheck = substring(1,1,reflect(parameter(parameter2( $F_NUNIT),0)))
 RECORD grec1(
   1 list[*]
     2 cv = f8
     2 disp = c15
 )
 IF (lcheck="L")
  SET mc_opr_var = "IN"
  WHILE (lcheck > " ")
    SET ml_gcnt += 1
    SET lcheck = substring(1,1,reflect(parameter(parameter2( $F_NUNIT),ml_gcnt)))
    IF (lcheck > " ")
     IF (mod(ml_gcnt,5)=1)
      SET stat = alterlist(grec1->list,(ml_gcnt+ 4))
     ENDIF
     SET grec1->list[ml_gcnt].cv = parameter(parameter2( $F_NUNIT),ml_gcnt)
     SET grec1->list[ml_gcnt].disp = uar_get_code_display(parameter(parameter2( $F_NUNIT),ml_gcnt))
    ENDIF
  ENDWHILE
  SET ml_gcnt -= 1
  SET stat = alterlist(grec1->list,ml_gcnt)
 ELSE
  SET stat = alterlist(grec1->list,1)
  SET ml_gcnt = 1
  SET grec1->list[1].cv =  $F_NUNIT
  IF ((grec1->list[1].cv=0.0))
   SET grec1->list[1].disp = "All facilites"
   SET mc_opr_var = "!="
  ELSE
   SET grec1->list[1].disp = uar_get_code_display(grec1->list[1].cv)
   SET mc_opr_var = "="
  ENDIF
 ENDIF
 SELECT INTO  $OUTDEV
  patient_last_name = substring(1,70,trim(pat.name_last,3)), patient_first_name = substring(1,70,trim
   (pat.name_first,3)), mrn = substring(1,20,trim(mrn.alias,3)),
  facility = substring(1,20,trim(uar_get_code_display(enc.loc_facility_cd),3)), unit = substring(1,20,
   trim(uar_get_code_display(enc.loc_nurse_unit_cd),3)), room_bed = substring(1,70,concat(trim(
     uar_get_code_display(enc.loc_room_cd),3)," - ",trim(uar_get_code_display(enc.loc_bed_cd),3))),
  admit_date = substring(1,20,format(enc.reg_dt_tm,"MM/dd/yyyy HH:mm;;d")), discharge_date =
  substring(1,20,format(enc.disch_dt_tm,"MM/dd/yyyy HH:mm;;d")), isolation_order = substring(1,60,
   trim(uar_get_code_display(o.catalog_cd),3)),
  isolation_type = substring(1,60,od.oe_field_display_value), order_date = substring(1,20,format(o
    .orig_order_dt_tm,"MM/dd/yyyy HH:mm;;d")), discontinue_date = substring(1,20,format(o
    .discontinue_effective_dt_tm,"MM/dd/yyyy HH:mm;;d"))
  FROM encounter enc,
   orders o,
   order_detail od,
   person pat,
   encntr_alias mrn
  PLAN (o
   WHERE o.catalog_cd IN (mf_cs200_isolationcovid_cd, mf_cs200_isolation_cd)
    AND o.active_ind=1
    AND ((o.orig_order_dt_tm BETWEEN cnvtdatetime( $S_START_DATE) AND cnvtdatetime( $S_END_DATE)) OR
   (((o.orig_order_dt_tm < cnvtdatetime( $S_START_DATE)
    AND o.discontinue_effective_dt_tm > cnvtdatetime( $S_START_DATE)) OR (o
   .discontinue_effective_dt_tm=null)) ))
    AND o.order_status_cd IN (mf_cs6004_discontinued_cd, mf_cs6004_ordered_cd))
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_meaning="ISOLATIONCODE"
    AND cnvtupper(trim(od.oe_field_display_value,3)) != "NEUTROPENIC"
    AND od.action_sequence IN (
   (SELECT
    max(od1.action_sequence)
    FROM order_detail od1
    WHERE od1.order_id=od.order_id
     AND od1.oe_field_meaning_id=od.oe_field_meaning_id
    GROUP BY od1.order_id)))
   JOIN (pat
   WHERE pat.person_id=o.person_id
    AND pat.active_ind=1
    AND pat.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
    AND pat.end_effective_dt_tm >= cnvtdatetime(curdate,curtime))
   JOIN (enc
   WHERE enc.encntr_id=o.encntr_id
    AND enc.person_id=o.person_id
    AND enc.active_ind=1
    AND enc.active_status_cd=mf_active
    AND (enc.loc_facility_cd= $F_FNAME)
    AND operator(enc.loc_nurse_unit_cd,mc_opr_var, $F_NUNIT)
    AND ((enc.disch_dt_tm >= cnvtdatetime( $S_START_DATE)) OR (enc.disch_dt_tm=null)) )
   JOIN (mrn
   WHERE mrn.encntr_id=enc.encntr_id
    AND mrn.active_ind=1
    AND mrn.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
    AND mrn.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
    AND mrn.encntr_alias_type_cd=mf_cs319_mrn_cd)
  ORDER BY unit, room_bed
  WITH nocounter, format, separator = " "
 ;end select
END GO
