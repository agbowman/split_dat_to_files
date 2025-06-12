CREATE PROGRAM bhs_athn_r_all_results_count
 RECORD orequest(
   1 query_mode = i4
   1 query_mode_ind = i2
   1 event_set_cd = f8
   1 person_id = f8
   1 order_id = f8
   1 encntr_id = f8
   1 encntr_financial_id = f8
   1 contributor_system_cd = f8
   1 accession_nbr = vc
   1 compress_flag = i2
   1 subtable_bit_map = i4
   1 subtable_bit_map_ind = i2
   1 small_subtable_bit_map = i4
   1 small_subtable_bit_map_ind = i2
   1 search_anchor_dt_tm = dq8
   1 search_anchor_dt_tm_ind = i2
   1 seconds_duration = f8
   1 direction_flag = i2
   1 events_to_fetch = i4
   1 date_flag = i2
   1 view_level = i4
   1 non_publish_flag = i2
   1 valid_from_dt_tm = dq8
   1 valid_from_dt_tm_ind = i2
   1 decode_flag = i2
   1 encntr_list[*]
     2 encntr_id = f8
   1 event_set_list[*]
     2 event_set_name = vc
   1 encntr_type_class_list[*]
     2 encntr_type_class_cd = f8
   1 order_id_list_ext[*]
     2 order_id = f8
   1 event_set_cd_list_ext[*]
     2 event_set_cd = f8
     2 event_set_name = vc
     2 fall_off_seconds_dur = f8
   1 ordering_provider_id = f8
   1 action_prsnl_id = f8
   1 query_mode2 = i4
   1 encntr_type_list[*]
     2 encntr_type_cd = f8
   1 end_of_day_tz = i4
   1 perform_prsnl_list[*]
     2 perform_prsnl_id = f8
   1 result_status_list[*]
     2 result_status_cd = f8
   1 search_begin_dt_tm = dq8
   1 search_end_dt_tm = dq8
   1 action_prsnl_group_id = f8
 )
 RECORD out_rec(
   1 results_count = i4
 )
 SET orequest->person_id =  $2
 DECLARE t_line = vc
 DECLARE t_line2 = vc
 DECLARE done = i2
 SET cnt = 0
 SET t_line =  $3
 IF (( $3=""))
  SELECT INTO "nl:"
   FROM encounter e
   PLAN (e
    WHERE (e.person_id= $2))
   ORDER BY e.encntr_id
   HEAD e.encntr_id
    cnt = (cnt+ 1), stat = alterlist(orequest->encntr_list,cnt), orequest->encntr_list[cnt].encntr_id
     = e.encntr_id
   WITH nocounter, time = 30
  ;end select
 ELSE
  WHILE (done=0)
    IF (findstring(",",t_line)=0)
     SET cnt = (cnt+ 1)
     SET stat = alterlist(orequest->encntr_list,cnt)
     SET orequest->encntr_list[cnt].encntr_id = cnvtreal(t_line)
     SET done = 1
    ELSE
     SET cnt = (cnt+ 1)
     SET t_line2 = substring(1,(findstring(",",t_line) - 1),t_line)
     SET stat = alterlist(orequest->encntr_list,cnt)
     SET orequest->encntr_list[cnt].encntr_id = cnvtreal(t_line2)
     SET t_line = substring((findstring(",",t_line)+ 1),textlen(t_line),t_line)
    ENDIF
  ENDWHILE
 ENDIF
 SET date_line = substring(1,10, $4)
 SET time_line = substring(12,8, $4)
 SET orequest->search_begin_dt_tm = cnvtdatetimeutc2(date_line,"YYYY-MM-DD",time_line,"HH;mm;ss",0)
 SET date_line = substring(1,10, $5)
 SET time_line = substring(12,8, $5)
 SET orequest->search_end_dt_tm = cnvtdatetimeutc2(date_line,"YYYY-MM-DD",time_line,"HH;mm;ss",0)
 SET orequest->event_set_cd = uar_get_code_by("DISPLAY",93, $6)
 SET orequest->query_mode2 = 3
 SET orequest->valid_from_dt_tm_ind = 1
 SET orequest->decode_flag = 1
 SET orequest->subtable_bit_map_ind = 1
 SET orequest->compress_flag = 1
 IF (( $7 > 0))
  SET orequest->events_to_fetch = cnvtint( $7)
 ELSE
  SET orequest->events_to_fetch = 300
 ENDIF
 SET stat = tdbexecute(3200000,3200200,1000001,"REC",orequest,
  "REC",oreply)
 IF (size(oreply->rb_list,5) > 0)
  SET out_rec->results_count = size(oreply->rb_list.event_list,5)
 ENDIF
 CALL echojson(out_rec, $1)
END GO
