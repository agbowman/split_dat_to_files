CREATE PROGRAM ams_get_freq_orders_local:dba
 PROMPT
  "" = "MINE",
  "Frequency Name" = 0,
  "Activity Type" = 0,
  "Facility" = 0,
  "Applies To:" = 0,
  "Detail" = 0,
  "Updated By" = 0
  WITH outdev, freqcd, freqactivity,
  freqfacility, freqapplysto, freqapplydetail,
  freqschedid
 DECLARE errormsg = vc WITH protect
 DECLARE errormsg = vc WITH protect
 DECLARE statusstr = vc WITH protect
 DECLARE status = vc WITH protect
 DECLARE freqid = f8 WITH protect
 DECLARE orderdtypecd = f8 WITH constant(uar_get_code_by("MEANING",6004,"ORDERED")), protect
 DECLARE inprocesstypecd = f8 WITH constant(uar_get_code_by("MEANING",6004,"INPROCESS")), protect
 DECLARE futuretypecd = f8 WITH constant(uar_get_code_by("MEANING",6004,"FUTURE")), protect
 DECLARE incompletetypecd = f8 WITH constant(uar_get_code_by("MEANING",6004,"INCOMPLETE")), protect
 DECLARE suspendedtypecd = f8 WITH constant(uar_get_code_by("MEANING",6004,"SUSPENDED")), protect
 DECLARE medstudenttypecd = f8 WITH constant(uar_get_code_by("MEANING",6004,"MEDSTUDENT")), protect
 DECLARE activitytypecd = f8 WITH constant(uar_get_code_by("MEANING",106,"PHARMACY")), protect
 DECLARE cattypecd = f8 WITH constant(uar_get_code_by("MEANING",6000,"PHARMACY")), protect
 DECLARE finnbr = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR")), protect
 DECLARE last_mod = vc WITH protect
 SET statusstr = null
 SET freqid = cnvtint( $FREQAPPLYDETAIL)
 SELECT INTO  $OUTDEV
  fin = substring(1,25,ea.alias), facility = uar_get_code_display(e.loc_facility_cd), nurse_unit =
  uar_get_code_display(e.loc_nurse_unit_cd),
  o.order_id, order_status = uar_get_code_display(o.order_status_cd), dept_misc = o.dept_misc_line,
  o.current_start_dt_tm, o.projected_stop_dt_tm, stop_type = uar_get_code_display(o.stop_type_cd)
  FROM orders o,
   encntr_alias ea,
   encounter e
  PLAN (o
   WHERE o.order_status_cd IN (orderdtypecd, inprocesstypecd, futuretypecd, incompletetypecd,
   suspendedtypecd,
   medstudenttypecd)
    AND o.activity_type_cd=activitytypecd
    AND o.catalog_type_cd=cattypecd
    AND o.template_order_id=0
    AND o.orig_ord_as_flag=0
    AND o.frequency_id=freqid)
   JOIN (ea
   WHERE o.encntr_id=ea.encntr_id
    AND ea.encntr_alias_type_cd=finnbr)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id)
  ORDER BY o.projected_stop_dt_tm DESC
  WITH nocounter, separator = " ", format,
   format(date,";;q")
 ;end select
 IF (((curqual=0) OR (error(errormsg,0) != 0)) )
  SET status = "F"
  SET statusstr = "No orders qualified for your filters."
  GO TO exit_script
 ENDIF
#exit_script
 IF (status="F")
  SELECT INTO  $OUTDEV
   DETAIL
    row + 1, statusstr, row + 1,
    errormsg
  ;end select
 ELSEIF (status="S")
  SELECT INTO  $OUTDEV
   DETAIL
    row + 1, statusstr
  ;end select
 ENDIF
 SET last_mod = "000"
END GO
