CREATE PROGRAM bhs_rpt_ppid_detail_by_loc:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date Time:" = "SYSDATE",
  "End Date Time" = "SYSDATE",
  "Facility:" = 673936.00,
  "Nurse Unit" = value(*),
  "Alert Type:" = value(0.000000)
  WITH outdev, beg_time, end_time,
  facility, nurse_unit, alert_type
 DECLARE ms_any_status_ind = vc WITH protect, noconstant("")
 DECLARE ms_data_type = vc WITH protect, noconstant("")
 DECLARE ms_tmp_str = vc WITH protect, noconstant("")
 DECLARE ms_parser = vc WITH protect, noconstant("")
 DECLARE mn_out_of_range = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt2 = i4 WITH protect, noconstant(0)
 FREE RECORD aunit
 RECORD aunit(
   1 l_cnt = i4
   1 list[*]
     2 s_unit_display_key = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM dm_info au
  WHERE au.info_domain="BHS_AMBULATORY_UNIT"
  HEAD REPORT
   aunit->l_cnt = 0
  DETAIL
   aunit->l_cnt = (aunit->l_cnt+ 1), stat = alterlist(aunit->list,aunit->l_cnt), aunit->list[aunit->
   l_cnt].s_unit_display_key = au.info_name
  WITH nocounter
 ;end select
 SET ms_data_type = reflect(parameter(5,0))
 IF (substring(1,1,ms_data_type)="L")
  FOR (ml_cnt = 1 TO cnvtint(substring(2,(size(ms_data_type) - 1),ms_data_type)))
   SET ms_tmp_str = cnvtstring(parameter(5,ml_cnt),20)
   IF (ml_cnt=1)
    SET ms_parser = concat(" mad.nurse_unit_cd in (",trim(ms_tmp_str))
   ELSE
    SET ms_parser = concat(ms_parser,", ",trim(ms_tmp_str))
   ENDIF
  ENDFOR
  SET ms_parser = concat(ms_parser,")")
 ELSEIF (substring(1,2,ms_data_type)="C1")
  SET ms_parser = parameter(5,1)
  IF (trim(ms_parser)=char(42))
   SELECT INTO "nl:"
    FROM code_value cv,
     location_group lg1,
     location_group lg2
    PLAN (cv
     WHERE cv.code_set=220
      AND cv.active_ind=1
      AND cv.data_status_cd=25
      AND ((cv.cdf_meaning="NURSEUNIT") OR (((cv.cdf_meaning="AMBULATORY"
      AND ((expand(ml_cnt2,1,aunit->l_cnt,cv.display_key,aunit->list[ml_cnt2].s_unit_display_key))
      OR (cv.display_key IN ("BFMCONCOLOGY"))) ) OR (cv.cdf_meaning="ANCILSURG"
      AND cv.display IN ("MLH OR/PACU", "MLH Same Day"))) )) )
     JOIN (lg1
     WHERE lg1.child_loc_cd=cv.code_value
      AND lg1.root_loc_cd=0)
     JOIN (lg2
     WHERE lg2.child_loc_cd=lg1.parent_loc_cd
      AND lg2.root_loc_cd=0
      AND (lg2.parent_loc_cd= $FACILITY))
    ORDER BY cv.display
    HEAD REPORT
     ms_parser = " mad.nurse_unit_cd in ( ", ml_cnt = 0
    DETAIL
     ml_cnt = (ml_cnt+ 1)
     IF (ml_cnt=1)
      ms_parser = concat(ms_parser,trim(cnvtstring(cv.code_value)))
     ELSE
      ms_parser = concat(ms_parser,", ",trim(cnvtstring(cv.code_value)))
     ENDIF
    FOOT REPORT
     ms_parser = concat(ms_parser," )")
    WITH nocounter
   ;end select
  ENDIF
 ELSE
  SET ms_parser = cnvtstring(parameter(5,1),20)
  SET ms_parser = concat(" mad.nurse_unit_cd = ",trim(ms_parser))
 ENDIF
 IF (datetimediff(cnvtdatetime( $END_TIME),cnvtdatetime( $BEG_TIME)) > 31.0)
  SET mn_out_of_range = 1
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Your date range is Greater than 31 days .", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
  GO TO exit_prg
 ELSEIF (datetimediff(cnvtdatetime( $END_TIME),cnvtdatetime( $BEG_TIME)) < 0.0)
  SET mn_out_of_range = 1
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Your date range is Negative days .", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
  GO TO exit_prg
 ENDIF
 SET ms_any_status_ind = substring(1,1,reflect(parameter(6,0)))
 IF (ms_any_status_ind="C")
  SELECT INTO  $OUTDEV
   fin = ea.alias, o.order_id, o.order_mnemonic,
   o.order_detail_display_line, schedule_dt_tim = format(maa.scheduled_dt_tm,";;Q"), admin_date_time
    = format(maa.admin_dt_tm,";;Q"),
   elapsed_time_hrs = datetimediff(maa.admin_dt_tm,maa.scheduled_dt_tm,3), reason =
   uar_get_code_display(maa.reason_cd), alert = uar_get_code_display(mad.alert_type_cd),
   nurse_units = uar_get_code_display(mad.nurse_unit_cd)
   FROM med_admin_med_error maa,
    orders o,
    encntr_alias ea,
    med_admin_alert mad
   PLAN (maa
    WHERE maa.admin_dt_tm BETWEEN cnvtdatetime( $BEG_TIME) AND cnvtdatetime( $END_TIME))
    JOIN (ea
    WHERE ea.encntr_id=maa.encounter_id
     AND ea.encntr_alias_type_cd=1077)
    JOIN (o
    WHERE o.order_id=maa.order_id)
    JOIN (mad
    WHERE mad.med_admin_alert_id=maa.med_admin_alert_id
     AND parser(ms_parser))
   ORDER BY nurse_units
   WITH separator = " ", format, time = 300,
    maxrec = 100000
  ;end select
 ELSEIF (ms_any_status_ind != "C")
  SELECT INTO  $OUTDEV
   fin = ea.alias, o.order_id, o.order_mnemonic,
   o.order_detail_display_line, schedule_dt_tim = format(maa.scheduled_dt_tm,";;Q"), admin_date_time
    = format(maa.admin_dt_tm,";;Q"),
   elapsed_time_hrs = datetimediff(maa.admin_dt_tm,maa.scheduled_dt_tm,3), reason =
   uar_get_code_display(maa.reason_cd), alert = uar_get_code_display(mad.alert_type_cd),
   nurse_units = uar_get_code_display(mad.nurse_unit_cd)
   FROM med_admin_med_error maa,
    orders o,
    encntr_alias ea,
    med_admin_alert mad
   PLAN (maa
    WHERE maa.admin_dt_tm BETWEEN cnvtdatetime( $BEG_TIME) AND cnvtdatetime( $END_TIME))
    JOIN (ea
    WHERE ea.encntr_id=maa.encounter_id
     AND ea.encntr_alias_type_cd=1077)
    JOIN (o
    WHERE o.order_id=maa.order_id)
    JOIN (mad
    WHERE mad.med_admin_alert_id=maa.med_admin_alert_id
     AND parser(ms_parser)
     AND (mad.alert_type_cd= $ALERT_TYPE))
   ORDER BY nurse_units
   WITH separator = " ", format, time = 300,
    maxrec = 100000
  ;end select
 ENDIF
#exit_prg
 IF (curqual=0
  AND mn_out_of_range=0)
  SELECT INTO  $OUTDEV
   HEAD REPORT
    col 0, "{PS/792 0 translate 90 rotate/}", y_pos = 18,
    row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))),
    "No data qualified of for date range"
   WITH dio = 08, mine, time = 5
  ;end select
 ENDIF
END GO
