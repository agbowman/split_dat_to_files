CREATE PROGRAM edw_enc_hist:dba
 DECLARE parser_line = vc WITH constant(build("BUILD(",value(encounter_nk),")"))
 DECLARE enc_hist_cnt = i4
 DECLARE scripterror_ind = i2 WITH protect, noconstant(0)
 DECLARE new_list_size = i4
 DECLARE cur_list_size = i4
 DECLARE batch_size = i4 WITH constant(100)
 DECLARE nstart = i4
 DECLARE loop_cnt = i4
 DECLARE idx = i4
 DECLARE num = i4
 DECLARE temp_indx = i4 WITH noconstant(0)
 DECLARE keys_start = i4 WITH noconstant(0)
 DECLARE keys_end = i4 WITH noconstant(0)
 DECLARE keys_batch = i4 WITH constant(medium_batch_size)
 DECLARE parent_key_cnt = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM encntr_loc_hist elh
  WHERE elh.updt_dt_tm >= cnvtdatetime(act_from_dt_tm)
   AND elh.updt_dt_tm < cnvtdatetime(act_to_dt_tm)
  HEAD REPORT
   enc_hist_cnt = 0
  DETAIL
   enc_hist_cnt = (enc_hist_cnt+ 1)
   IF (mod(enc_hist_cnt,10)=1)
    stat = alterlist(enc_hist_keys->qual,(enc_hist_cnt+ 9))
   ENDIF
   enc_hist_keys->qual[enc_hist_cnt].encntr_loc_hist_id = elh.encntr_loc_hist_id
  WITH nocounter
 ;end select
 SET keys_start = 1
 SET keys_end = minval(((keys_start+ keys_batch) - 1),enc_hist_cnt)
 WHILE (keys_start <= keys_end)
   SET stat = alterlist(enc_hist->qual,keys_batch)
   IF (debug="Y")
    CALL echo(concat("Looping from keys_start = ",build(keys_start)," to keys_end = ",build(keys_end)
      ))
   ENDIF
   SET temp_indx = 0
   FOR (i = keys_start TO keys_end)
    SET temp_indx = (temp_indx+ 1)
    SET enc_hist->qual[temp_indx].enc_history_sk = enc_hist_keys->qual[i].encntr_loc_hist_id
   ENDFOR
   IF (temp_indx < keys_batch)
    SET cur_list_size = temp_indx
    SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
    SET new_list_size = (loop_cnt * batch_size)
    SET stat = alterlist(enc_hist->qual,new_list_size)
    FOR (i = temp_indx TO new_list_size)
      SET enc_hist->qual[i].enc_history_sk = enc_hist->qual[temp_indx].enc_history_sk
    ENDFOR
   ELSE
    SET cur_list_size = keys_batch
    SET loop_cnt = (cnvtreal(keys_batch)/ batch_size)
   ENDIF
   SET nstart = 1
   SELECT INTO "nl:"
    enc_nk = parser(parser_line)
    FROM (dummyt d  WITH seq = value(cur_list_size)),
     encounter,
     encntr_loc_hist elh
    PLAN (d)
     JOIN (elh
     WHERE (elh.encntr_loc_hist_id=enc_hist->qual[d.seq].enc_history_sk))
     JOIN (encounter
     WHERE encounter.encntr_id=elh.encntr_id)
    DETAIL
     parent_key_cnt = (parent_key_cnt+ 1)
     IF (mod(parent_key_cnt,10)=1)
      stat = alterlist(enc_hist_parent_keys->qual,(parent_key_cnt+ 9))
     ENDIF
     enc_hist_parent_keys->qual[parent_key_cnt].encntr_sk = encounter.encntr_id, enc_hist->qual[d.seq
     ].encounter_nk = enc_nk, enc_hist->qual[d.seq].encounter_sk = encounter.encntr_id,
     enc_hist->qual[d.seq].enc_history_sk = elh.encntr_loc_hist_id, enc_hist->qual[d.seq].
     encntr_type_ref = elh.encntr_type_cd, enc_hist->qual[d.seq].encntr_class_type_ref = elh
     .encntr_type_class_cd,
     enc_hist->qual[d.seq].organiztion_sk = elh.organization_id, enc_hist->qual[d.seq].
     loc_facility_ref = elh.loc_facility_cd, enc_hist->qual[d.seq].loc_building_ref = elh
     .loc_building_cd,
     enc_hist->qual[d.seq].loc_nurse_unit_ref = elh.loc_nurse_unit_cd, enc_hist->qual[d.seq].
     loc_room_ref = elh.loc_room_cd, enc_hist->qual[d.seq].loc_bed_ref = elh.loc_bed_cd,
     enc_hist->qual[d.seq].transfer_reason_ref = elh.transfer_reason_cd, enc_hist->qual[d.seq].
     arrive_dt_tm = elh.arrive_dt_tm, enc_hist->qual[d.seq].depart_dt_tm = elh.depart_dt_tm,
     enc_hist->qual[d.seq].depart_prsnl = elh.depart_prsnl_id, enc_hist->qual[d.seq].admit_type_ref
      = elh.admit_type_cd, enc_hist->qual[d.seq].isolation_ref = elh.isolation_cd,
     enc_hist->qual[d.seq].accommodation_ref = elh.accommodation_cd, enc_hist->qual[d.seq].
     accommodation_reason_ref = elh.accommodation_reason_cd, enc_hist->qual[d.seq].
     medical_service_ref = elh.med_service_cd,
     enc_hist->qual[d.seq].service_category_ref = elh.service_category_cd, enc_hist->qual[d.seq].
     specialty_unit_ref = elh.specialty_unit_cd, enc_hist->qual[d.seq].alternate_level_of_care_ref =
     elh.alt_lvl_care_cd,
     enc_hist->qual[d.seq].alternate_lvl_of_care_dt_tm = elh.alt_lvl_care_dt_tm, enc_hist->qual[d.seq
     ].transaction_dt_tm = elh.transaction_dt_tm, enc_hist->qual[d.seq].active_ind = elh.active_ind,
     enc_hist->qual[d.seq].activity_dt_tm = elh.activity_dt_tm, enc_hist->qual[d.seq].
     active_status_prsnl = elh.active_status_prsnl_id, enc_hist->qual[d.seq].beg_effective_dt_tm =
     elh.beg_effective_dt_tm,
     enc_hist->qual[d.seq].end_effective_dt_tm = elh.end_effective_dt_tm
    WITH nocounter
   ;end select
   FOR (zone_cnt = 1 TO cur_list_size)
     SET timezone = gettimezone(enc_hist->qual[zone_cnt].loc_facility_ref,enc_hist->qual[zone_cnt].
      encounter_sk)
     SET enc_hist->qual[zone_cnt].arrive_tm_zn = timezone
     SET enc_hist->qual[zone_cnt].depart_tm_zn = timezone
     SET enc_hist->qual[zone_cnt].alternate_lvl_of_care_tm_zn = timezone
     SET enc_hist->qual[zone_cnt].transaction_tm_zn = timezone
     IF (encounter_nk != default_encounter_nk)
      SET enc_hist->qual[zone_cnt].encounter_nk = get_encounter_nk(enc_hist->qual[zone_cnt].
       encounter_sk)
     ENDIF
   ENDFOR
   SELECT INTO value(enc_hist_extractfile)
    FROM (dummyt d  WITH seq = value(cur_list_size))
    DETAIL
     col 0,
     CALL print(trim(health_system_id)), v_bar,
     CALL print(trim(health_system_source_id)), v_bar,
     CALL print(trim(replace(enc_hist->qual[d.seq].encounter_nk,str_find,str_replace,3),3)),
     v_bar,
     CALL print(trim(cnvtstring(enc_hist->qual[d.seq].encounter_sk,16))), v_bar,
     CALL print(trim(cnvtstring(enc_hist->qual[d.seq].enc_history_sk,16))), v_bar,
     CALL print(trim(cnvtstring(enc_hist->qual[d.seq].encntr_type_ref,16))),
     v_bar,
     CALL print(trim(cnvtstring(enc_hist->qual[d.seq].encntr_class_type_ref,16))), v_bar,
     CALL print(trim(cnvtstring(enc_hist->qual[d.seq].organiztion_sk,16))), v_bar,
     CALL print(trim(cnvtstring(enc_hist->qual[d.seq].loc_facility_ref,16))),
     v_bar,
     CALL print(trim(cnvtstring(enc_hist->qual[d.seq].loc_building_ref,16))), v_bar,
     CALL print(trim(cnvtstring(enc_hist->qual[d.seq].loc_nurse_unit_ref,16))), v_bar,
     CALL print(trim(cnvtstring(enc_hist->qual[d.seq].loc_room_ref,16))),
     v_bar,
     CALL print(trim(cnvtstring(enc_hist->qual[d.seq].loc_bed_ref,16))), v_bar,
     CALL print(trim(cnvtstring(enc_hist->qual[d.seq].transfer_reason_ref,16))), v_bar,
     CALL print(trim(datetimezoneformat(evaluate(curutc,1,enc_hist->qual[d.seq].arrive_dt_tm,0,
        cnvtdatetimeutc(enc_hist->qual[d.seq].arrive_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm")
      )),
     v_bar,
     CALL print(trim(cnvtstring(enc_hist->qual[d.seq].arrive_tm_zn))), v_bar,
     CALL print(evaluate(datetimezoneformat(enc_hist->qual[d.seq].arrive_dt_tm,cnvtint(enc_hist->
        qual[d.seq].arrive_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
      "1")), v_bar,
     CALL print(trim(datetimezoneformat(evaluate(curutc,1,enc_hist->qual[d.seq].depart_dt_tm,0,
        cnvtdatetimeutc(enc_hist->qual[d.seq].depart_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm")
      )),
     v_bar,
     CALL print(trim(cnvtstring(enc_hist->qual[d.seq].depart_tm_zn))), v_bar,
     CALL print(evaluate(datetimezoneformat(enc_hist->qual[d.seq].depart_dt_tm,cnvtint(enc_hist->
        qual[d.seq].depart_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
      "1")), v_bar,
     CALL print(trim(cnvtstring(enc_hist->qual[d.seq].depart_prsnl,16))),
     v_bar,
     CALL print(trim(cnvtstring(enc_hist->qual[d.seq].admit_type_ref,16))), v_bar,
     CALL print(trim(cnvtstring(enc_hist->qual[d.seq].isolation_ref,16))), v_bar,
     CALL print(trim(cnvtstring(enc_hist->qual[d.seq].accommodation_ref,16))),
     v_bar,
     CALL print(trim(cnvtstring(enc_hist->qual[d.seq].accommodation_reason_ref,16))), v_bar,
     CALL print(trim(cnvtstring(enc_hist->qual[d.seq].medical_service_ref,16))), v_bar,
     CALL print(trim(cnvtstring(enc_hist->qual[d.seq].service_category_ref,16))),
     v_bar,
     CALL print(trim(cnvtstring(enc_hist->qual[d.seq].specialty_unit_ref,16))), v_bar,
     CALL print(trim(cnvtstring(enc_hist->qual[d.seq].alternate_level_of_care_ref,16))), v_bar,
     CALL print(trim(datetimezoneformat(evaluate(curutc,1,enc_hist->qual[d.seq].
        alternate_lvl_of_care_dt_tm,0,cnvtdatetimeutc(enc_hist->qual[d.seq].
         alternate_lvl_of_care_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm"))),
     v_bar,
     CALL print(trim(cnvtstring(enc_hist->qual[d.seq].alternate_lvl_of_care_tm_zn))), v_bar,
     CALL print(evaluate(datetimezoneformat(enc_hist->qual[d.seq].alternate_lvl_of_care_dt_tm,cnvtint
       (enc_hist->qual[d.seq].alternate_lvl_of_care_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
      "1")), v_bar,
     CALL print(trim(datetimezoneformat(evaluate(curutc,1,enc_hist->qual[d.seq].transaction_dt_tm,0,
        cnvtdatetimeutc(enc_hist->qual[d.seq].transaction_dt_tm,3)),utc_timezone_index,
       "MM/DD/YYYY HH:mm"))),
     v_bar,
     CALL print(trim(cnvtstring(enc_hist->qual[d.seq].transaction_tm_zn))), v_bar,
     CALL print(evaluate(datetimezoneformat(enc_hist->qual[d.seq].transaction_dt_tm,cnvtint(enc_hist
        ->qual[d.seq].transaction_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
      "1")), v_bar, "3",
     v_bar,
     CALL print(trim(extract_dt_tm_fmt)), v_bar,
     CALL print(build(enc_hist->qual[d.seq].active_ind)), v_bar,
     CALL print(trim(evaluate(enc_hist->qual[d.seq].loc_bed_ref,0.0,evaluate(enc_hist->qual[d.seq].
        loc_room_ref,0.0,evaluate(enc_hist->qual[d.seq].loc_nurse_unit_ref,0.0,evaluate(enc_hist->
          qual[d.seq].loc_building_ref,0.0,evaluate(enc_hist->qual[d.seq].loc_facility_ref,0.0,"0",
           cnvtstring(enc_hist->qual[d.seq].loc_facility_ref,16)),cnvtstring(enc_hist->qual[d.seq].
           loc_building_ref,16)),cnvtstring(enc_hist->qual[d.seq].loc_nurse_unit_ref,16)),cnvtstring(
         enc_hist->qual[d.seq].loc_room_ref,16)),cnvtstring(enc_hist->qual[d.seq].loc_bed_ref,16)))),
     v_bar,
     CALL print(trim(datetimezoneformat(evaluate(curutc,1,enc_hist->qual[d.seq].activity_dt_tm,0,
        cnvtdatetimeutc(enc_hist->qual[d.seq].activity_dt_tm,3)),utc_timezone_index,
       "MM/DD/YYYY HH:mm"))), v_bar,
     CALL print(trim(cnvtstring(enc_hist->qual[d.seq].active_status_prsnl,100))), v_bar,
     CALL print(trim(datetimezoneformat(evaluate(curutc,1,enc_hist->qual[d.seq].beg_effective_dt_tm,0,
        cnvtdatetimeutc(enc_hist->qual[d.seq].beg_effective_dt_tm,3)),utc_timezone_index,
       "MM/DD/YYYY HH:mm"))),
     v_bar,
     CALL print(trim(datetimezoneformat(evaluate(curutc,1,enc_hist->qual[d.seq].end_effective_dt_tm,0,
        cnvtdatetimeutc(enc_hist->qual[d.seq].end_effective_dt_tm,3)),utc_timezone_index,
       "MM/DD/YYYY HH:mm"))), v_bar,
     row + 1
    WITH check, noheading, nocounter,
     format = lfstream, maxcol = 1999, maxrow = 1,
     append
   ;end select
   SET stat = alterlist(enc_hist->qual,0)
   SET keys_start = (keys_end+ 1)
   SET keys_end = minval(((keys_start+ keys_batch) - 1),enc_hist_cnt)
 ENDWHILE
 IF (enc_hist_cnt=0)
  SELECT INTO value(enc_hist_extractfile)
   FROM dummyt
   WHERE enc_hist_cnt > 0
   WITH noheading, nocounter, format = lfstream,
    maxcol = 1999, maxrow = 1
  ;end select
 ENDIF
 FREE RECORD enc_hist
 FREE RECORD enc_hist_keys
 CALL echo(build("ENC_HIST Count = ",enc_hist_cnt))
 CALL edwupdatescriptstatus("ENC_HIST",enc_hist_cnt,"10","10")
 IF (error(err_msg,1) != 0)
  SET scripterror_ind = 1
 ENDIF
 SET error_ind = scripterror_ind
 SET script_version = "010 04/07/16 MF025696"
END GO
