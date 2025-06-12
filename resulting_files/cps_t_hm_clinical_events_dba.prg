CREATE PROGRAM cps_t_hm_clinical_events:dba
 FREE RECORD normalcylist
 RECORD normalcylist(
   1 cnt = i4
   1 qual[*]
     2 value = vc
     2 display = vc
     2 normalcy_cd = f8
 ) WITH protect
 FREE RECORD event_set_namelist
 RECORD event_set_namelist(
   1 cnt = i4
   1 qual[*]
     2 value = vc
     2 display = vc
 ) WITH protect
 FREE RECORD event_set_nameresolved
 RECORD event_set_nameresolved(
   1 cnt = i4
   1 qual[*]
     2 value = vc
     2 display = vc
 ) WITH protect
 FREE RECORD event_value_strlist
 RECORD event_value_strlist(
   1 cnt = i4
   1 qual[*]
     2 value = vc
     2 display = vc
 ) WITH protect
 FREE RECORD event_qualifies
 RECORD event_qualifies(
   1 qualifies[*]
     2 qual_ind = i2
 ) WITH protect
 DECLARE ml_num_to_qualify = i4 WITH protect, noconstant(0)
 DECLARE ml_num_to_eval = i4 WITH protect, noconstant(0)
 DECLARE ml_time_num = i4 WITH protect, noconstant(0)
 DECLARE ml_time_option = i4 WITH protect, noconstant(0)
 DECLARE ms_value_relop = vc WITH protect, noconstant("")
 DECLARE mf_event_value_1 = f8 WITH protect, noconstant(0.0)
 DECLARE mf_event_value_2 = f8 WITH protect, noconstant(0.0)
 DECLARE ml_count_qualified = i4 WITH protect, noconstant(0)
 DECLARE ml_count_evaluated = i4 WITH protect, noconstant(0)
 DECLARE mn_any_event_set_name = i2 WITH protect, noconstant(0)
 DECLARE mn_any_normalcy = i2 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE qualify_until_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime(null))
 DECLARE earliest_event_end_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime(null))
 IF (validate(num_to_qualify,"0")="0")
  CALL echo("NUM_TO_QUALIFY not defined")
  SET ml_num_to_qualify = 1
 ELSEIF (isnumeric(num_to_qualify))
  SET ml_num_to_qualify = cnvtreal(num_to_qualify)
 ELSE
  SET ml_num_to_qualify = 1
 ENDIF
 IF (validate(num_to_eval,"0")="0")
  CALL echo("NUM_TO_EVAL not defined")
  SET ml_num_to_eval = 0
 ELSEIF (isnumeric(num_to_eval))
  SET ml_num_to_eval = cnvtreal(num_to_eval)
 ELSE
  CALL echo("NUM_TO_EVAL not numeric")
  SET ml_num_to_eval = 0
 ENDIF
 IF (validate(time_num,"0")="0")
  CALL echo("TIME_NUM not defined")
  SET ml_time_num = 0
 ELSEIF (isnumeric(time_num))
  SET ml_time_num = cnvtreal(time_num)
 ELSE
  CALL echo("TIME_NUM not numeric")
  SET ml_time_num = 0
 ENDIF
 IF (validate(time_unit,"Z")="Z")
  CALL echo("TIME_UNIT not defined")
 ELSE
  IF (cnvtupper(time_unit)="HOURS")
   SET ml_time_option = 3
  ELSEIF (cnvtupper(time_unit)="DAYS")
   SET ml_time_option = 1
  ELSEIF (cnvtupper(time_unit)="WEEKS")
   SET ml_time_option = 2
  ENDIF
 ENDIF
 IF (validate(event_set_name,"Z")="Z"
  AND validate(event_set_name,"Y")="Y")
  CALL echo("EVENT_SET_NAME not defined.")
  SET retval = - (1)
  GO TO exit_program
 ELSEIF (findstring(char(6),event_set_name))
  SET orig_param = event_set_name
  EXECUTE eks_t_parse_list  WITH replace(reply,event_set_namelist)
  FREE SET orig_param
  IF ((event_set_namelist->cnt=0))
   SET retval = - (1)
   GO TO exit_program
  ENDIF
 ELSEIF (trim(event_set_name) > " "
  AND trim(cnvtupper(event_set_name)) != "<UNDEFINED>")
  SET stat = alterlist(event_set_namelist->qual,1)
  SET event_set_namelist->qual[1].value = event_set_name
  SET event_set_namelist->qual[1].display = event_set_name
  SET event_set_namelist->cnt = 1
 ELSE
  CALL echo("EVENT_SET_NAME not defined.")
  SET retval = - (1)
  GO TO exit_program
 ENDIF
 DECLARE actual_size = i4 WITH protect, noconstant(size(event_set_namelist->qual,5))
 DECLARE expand_size = i2 WITH protect, constant(20)
 DECLARE expand_start = i4 WITH protect, noconstant(1)
 DECLARE expand_total = i4 WITH protect, noconstant((actual_size+ (expand_size - mod(actual_size,
   expand_size))))
 DECLARE num = i4 WITH protect, noconstant(0)
 SET stat = alterlist(event_set_namelist->qual,expand_total)
 FOR (idx = (actual_size+ 1) TO expand_total)
   SET event_set_namelist->qual[idx].display = event_set_namelist->qual[actual_size].display
 ENDFOR
 SELECT INTO "nl:"
  vesc2.event_set_name
  FROM v500_event_set_code vesc1,
   v500_event_set_explode vese1,
   v500_event_set_explode vese2,
   v500_event_set_code vesc2,
   (dummyt d1  WITH seq = value((expand_total/ expand_size)))
  PLAN (d1
   WHERE initarray(expand_start,evaluate(d1.seq,1,1,(expand_start+ expand_size))))
   JOIN (vesc1
   WHERE expand(num,expand_start,(expand_start+ (expand_size - 1)),vesc1.event_set_name,
    event_set_namelist->qual[num].display))
   JOIN (vese1
   WHERE vese1.event_set_cd=vesc1.event_set_cd
    AND vese1.event_set_level > 0)
   JOIN (vese2
   WHERE vese2.event_cd=vese1.event_cd
    AND vese2.event_set_level=0)
   JOIN (vesc2
   WHERE vese2.event_set_cd=vesc2.event_set_cd)
  DETAIL
   IF (locateval(ml_idx,1,event_set_nameresolved->cnt,vesc2.event_set_name,event_set_nameresolved->
    qual[ml_idx].display)=0)
    event_set_nameresolved->cnt = (event_set_nameresolved->cnt+ 1)
    IF (mod(event_set_nameresolved->cnt,25)=1)
     stat = alterlist(event_set_nameresolved->qual,(event_set_nameresolved->cnt+ 24))
    ENDIF
    event_set_nameresolved->qual[event_set_nameresolved->cnt].display = vesc2.event_set_name,
    event_set_nameresolved->qual[event_set_nameresolved->cnt].value = vesc2.event_set_name
   ENDIF
  WITH nocounter
 ;end select
 FOR (idx = 1 TO event_set_namelist->cnt)
   SET event_set_nameresolved->cnt = (event_set_nameresolved->cnt+ 1)
   IF (mod(event_set_nameresolved->cnt,25)=1)
    SET stat = alterlist(event_set_nameresolved->qual,(event_set_nameresolved->cnt+ 24))
   ENDIF
   SET event_set_nameresolved->qual[event_set_nameresolved->cnt].display = event_set_namelist->qual[
   idx].display
   SET event_set_nameresolved->qual[event_set_nameresolved->cnt].value = event_set_namelist->qual[idx
   ].value
 ENDFOR
 SET stat = alterlist(event_set_nameresolved->qual,event_set_nameresolved->cnt)
 IF (validate(normalcy,"Z")="Z"
  AND validate(normalcy,"Y")="Y")
  CALL echo("NORMALCY not defined")
 ELSE
  SET orig_param = normalcy
  EXECUTE eks_t_parse_list  WITH replace(reply,normalcylist)
  FREE SET orig_param
 ENDIF
 IF ((normalcylist->cnt > 0))
  FOR (ml_counter = 0 TO normalcylist->cnt)
    IF (isnumeric(normalcylist->qual[ml_counter].value))
     SET normalcylist->qual[ml_counter].normalcy_cd = cnvtreal(normalcylist->qual[ml_counter].value)
    ENDIF
  ENDFOR
 ENDIF
 IF (validate(event_value_str,"Z")="Z"
  AND validate(event_value_str,"Y")="Y")
  CALL echo("EVENT_VALUE_STR not defined")
 ELSE
  SET orig_param = event_value_str
  EXECUTE eks_t_parse_list  WITH replace(reply,event_value_strlist)
  FREE SET orig_param
 ENDIF
 IF (validate(value_relop,"Z")="Z")
  CALL echo("VALUE_RELOP not defined")
 ELSE
  SET ms_value_relop = cnvtupper(value_relop)
 ENDIF
 IF (validate(event_value_1,"Z")="Z")
  CALL echo("EVENT_VALUE_1 not defined")
  SET mf_event_value_1 = 0.0
 ELSEIF (isnumeric(event_value_1))
  SET mf_event_value_1 = cnvtreal(event_value_1)
 ELSE
  CALL echo("EVENT_VALUE_1 not numeric")
  SET mf_event_value_1 = 0.0
 ENDIF
 IF (validate(event_value_2,"Z")="Z")
  CALL echo("EVENT_VALUE_2 not defined")
  SET mf_event_value_2 = 0.0
 ELSEIF (isnumeric(event_value_2))
  SET mf_event_value_2 = cnvtreal(event_value_2)
 ELSE
  CALL echo("EVENT_VALUE_2 not numeric")
  SET mf_event_value_2 = 0.0
 ENDIF
 IF (locateval(ml_idx,1,event_set_nameresolved->cnt,"*ANY_EVENT_SET_NAME",event_set_nameresolved->
  qual[ml_idx].display))
  SET mn_any_event_set_name = 1
 ENDIF
 IF (locateval(ml_idx,1,normalcylist->cnt,"*ANY NORMALCY",normalcylist->qual[ml_idx].display))
  SET mn_any_normalcy = 1
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(request->clinical_event,5)))
  PLAN (d
   WHERE expand(ml_idx,1,event_set_nameresolved->cnt,request->clinical_event[d.seq].event_set_name,
    event_set_nameresolved->qual[ml_idx].display))
  ORDER BY request->clinical_event[d.seq].event_end_dt_tm DESC
  HEAD REPORT
   mn_past_date_range = 0
  DETAIL
   ml_count_evaluated = (ml_count_evaluated+ 1), mn_date_qualifies = 0, mn_normalcy_qualifies = 0,
   mn_value_qualifies = 0
   IF (ml_time_num > 0)
    IF (mn_past_date_range=0)
     IF (datetimediff(sysdate,request->clinical_event[d.seq].event_end_dt_tm,ml_time_option) <=
     ml_time_num)
      mn_date_qualifies = 1
     ELSE
      mn_past_date_range = 1
     ENDIF
    ENDIF
   ELSE
    mn_date_qualifies = 1
   ENDIF
   IF (mn_any_normalcy=1)
    mn_normalcy_qualifies = 1
   ELSEIF ((normalcylist->cnt > 0))
    IF (expand(ml_idx,1,normalcylist->cnt,request->clinical_event[d.seq].normalcy_cd,normalcylist->
     qual[ml_idx].normalcy_cd))
     mn_normalcy_qualifies = 1
    ENDIF
   ELSE
    mn_normalcy_qualifies = 1
   ENDIF
   IF (mn_any_event_set_name=1)
    mn_value_qualifies = 1
   ELSEIF ((event_value_strlist->cnt > 0))
    IF (expand(ml_idx,1,event_value_strlist->cnt,request->clinical_event[d.seq].event_value_alpha,
     event_value_strlist->qual[ml_idx].display))
     mn_value_qualifies = 1
    ENDIF
   ELSEIF (ms_value_relop > "")
    IF (ms_value_relop="EQUAL TO")
     IF ((request->clinical_event[d.seq].event_value=mf_event_value_1))
      mn_value_qualifies = 1
     ENDIF
    ELSEIF (ms_value_relop="GREATER THAN")
     IF ((request->clinical_event[d.seq].event_value > mf_event_value_1))
      mn_value_qualifies = 1
     ENDIF
    ELSEIF (ms_value_relop="LESS THAN")
     IF ((request->clinical_event[d.seq].event_value < mf_event_value_1))
      mn_value_qualifies = 1
     ENDIF
    ELSEIF (ms_value_relop="GREATER THAN OR EQUAL TO")
     IF ((request->clinical_event[d.seq].event_value >= mf_event_value_1))
      mn_value_qualifies = 1
     ENDIF
    ELSEIF (ms_value_relop="LESS THAN OR EQUAL TO")
     IF ((request->clinical_event[d.seq].event_value <= mf_event_value_1))
      mn_value_qualifies = 1
     ENDIF
    ELSEIF (ms_value_relop="BETWEEN")
     IF (mf_event_value_1 < mf_event_value_2)
      IF ((request->clinical_event[d.seq].event_value > mf_event_value_1)
       AND (request->clinical_event[d.seq].event_value < mf_event_value_2))
       mn_value_qualifies = 1
      ENDIF
     ELSE
      IF ((request->clinical_event[d.seq].event_value < mf_event_value_1)
       AND (request->clinical_event[d.seq].event_value > mf_event_value_2))
       mn_value_qualifies = 1
      ENDIF
     ENDIF
    ELSEIF (ms_value_relop="OUTSIDE")
     IF (mf_event_value_1 < mf_event_value_2)
      IF ((request->clinical_event[d.seq].event_value < mf_event_value_1)
       AND (request->clinical_event[d.seq].event_value > mf_event_value_2))
       mn_value_qualifies = 1
      ENDIF
     ELSE
      IF ((request->clinical_event[d.seq].event_value > mf_event_value_1)
       AND (request->clinical_event[d.seq].event_value < mf_event_value_2))
       mn_value_qualifies = 1
      ENDIF
     ENDIF
    ENDIF
   ELSE
    mn_value_qualifies = 1
   ENDIF
   IF (mn_date_qualifies=1
    AND mn_normalcy_qualifies=1
    AND mn_value_qualifies=1
    AND ((ml_num_to_eval > 0
    AND ml_count_evaluated <= ml_num_to_eval) OR (ml_num_to_eval=0)) )
    IF (earliest_event_end_dt_tm=null)
     earliest_event_end_dt_tm = request->clinical_event[d.seq].event_end_dt_tm
    ELSEIF ((earliest_event_end_dt_tm < request->clinical_event[d.seq].event_end_dt_tm))
     earliest_event_end_dt_tm = request->clinical_event[d.seq].event_end_dt_tm
    ENDIF
    ml_count_qualified = (ml_count_qualified+ 1)
   ENDIF
  WITH nocounter
 ;end select
 IF (ml_count_qualified >= ml_num_to_qualify)
  CALL echo("Rule evaluated to TRUE")
  SET retval = 100
 ELSE
  CALL echo("Rule evaluated to FALSE")
  SET retval = 0
 ENDIF
#exit_program
 IF (retval=100
  AND ml_time_option > 0
  AND ml_time_num > 0
  AND earliest_event_end_dt_tm != null)
  IF (ml_time_option=1)
   SET look_ahead = build2(ml_time_num,",D")
  ELSEIF (ml_time_option=2)
   SET look_ahead = build2(ml_time_num,",W")
  ELSEIF (ml_time_option=3)
   SET look_ahead = build2(ml_time_num,",H")
  ENDIF
  SET cur_series_index = size(reply->expectation_series,5)
  SET qualify_until_dt_tm = cnvtlookahead(look_ahead,earliest_event_end_dt_tm)
  IF ((reply->expectation_series[cur_series_index].qualify_until_dt_tm=null))
   SET reply->expectation_series[cur_series_index].qualify_until_dt_tm = qualify_until_dt_tm
  ELSEIF ((reply->expectation_series[cur_series_index].qualify_until_dt_tm != null)
   AND (reply->expectation_series[cur_series_index].qualify_until_dt_tm < qualify_until_dt_tm))
   SET reply->expectation_series[cur_series_index].qualify_until_dt_tm = qualify_until_dt_tm
  ENDIF
 ENDIF
 FREE RECORD normalcylist
 FREE RECORD event_set_namelist
 FREE RECORD event_set_nameresolved
 FREE RECORD event_value_strlist
 FREE RECORD event_qualifies
END GO
