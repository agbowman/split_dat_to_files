CREATE PROGRAM edw_crss_map:dba
 DECLARE scripterror_ind = i2 WITH protect, noconstant(0)
 DECLARE crss_map_cnt = i4 WITH noconstant(0)
 DECLARE last_utc_ts_exists = i4 WITH noconstant(0)
 RECORD crss_map_keys(
   1 qual[*]
     2 crss_map_sk = f8
     2 active_ind = i2
 )
 SELECT INTO "NL:"
  FROM cmt_cross_map cm
  WHERE cm.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm)
   AND cm.cmt_cross_map_id > 0
  DETAIL
   crss_map_cnt = (crss_map_cnt+ 1)
   IF (mod(crss_map_cnt,100)=1)
    stat = alterlist(crss_map_keys->qual,(crss_map_cnt+ 99))
   ENDIF
   crss_map_keys->qual[crss_map_cnt].crss_map_sk = cm.cmt_cross_map_id, crss_map_keys->qual[
   crss_map_cnt].active_ind = cm.active_ind
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM cmt_cross_map cm
  WHERE cm.active_status_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm)
   AND cm.cmt_cross_map_id > 0
  DETAIL
   crss_map_cnt = (crss_map_cnt+ 1)
   IF (mod(crss_map_cnt,100)=1)
    stat = alterlist(crss_map_keys->qual,(crss_map_cnt+ 99))
   ENDIF
   crss_map_keys->qual[crss_map_cnt].crss_map_sk = cm.cmt_cross_map_id, crss_map_keys->qual[
   crss_map_cnt].active_ind = cm.active_ind
  WITH nocounter
 ;end select
 SELECT
  last_utc_ts_exists = u.data_length
  FROM user_tab_columns u
  WHERE u.table_name="CMT_CROSS_MAP"
   AND u.column_name="LAST_UTC_TS"
  WITH nocounter
 ;end select
 IF (last_utc_ts_exists > 0)
  SELECT INTO "NL:"
   FROM cmt_cross_map cm
   WHERE cm.last_utc_ts BETWEEN cnvttimestamp(cnvtdatetime(act_from_dt_tm)) AND cnvttimestamp(
    cnvtdatetime(act_to_dt_tm))
    AND cm.cmt_cross_map_id > 0
   DETAIL
    crss_map_cnt = (crss_map_cnt+ 1)
    IF (mod(crss_map_cnt,100)=1)
     stat = alterlist(crss_map_keys->qual,(crss_map_cnt+ 99))
    ENDIF
    crss_map_keys->qual[crss_map_cnt].crss_map_sk = cm.cmt_cross_map_id, crss_map_keys->qual[
    crss_map_cnt].active_ind = cm.active_ind
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "NL:"
  FROM dm_refchg_invalid_xlat dr
  WHERE dr.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm)
   AND dr.parent_entity_name="CMT_CROSS_MAP"
  DETAIL
   crss_map_cnt = (crss_map_cnt+ 1)
   IF (mod(crss_map_cnt,100)=1)
    stat = alterlist(crss_map_keys->qual,(crss_map_cnt+ 99))
   ENDIF
   crss_map_keys->qual[crss_map_cnt].crss_map_sk = dr.parent_entity_id, crss_map_keys->qual[
   crss_map_cnt].active_ind = 0
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  crss_map_id = crss_map_keys->qual[d.seq].crss_map_sk, active_ind = crss_map_keys->qual[d.seq].
  active_ind
  FROM (dummyt d  WITH seq = value(crss_map_cnt))
  WHERE crss_map_cnt > 0
  ORDER BY crss_map_id
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), crss_map_keys->qual[cnt].crss_map_sk = crss_map_id, crss_map_keys->qual[cnt].
   active_ind = active_ind
  FOOT REPORT
   crss_map_cnt = cnt, stat = alterlist(crss_map_keys->qual,cnt)
  WITH nocounter
 ;end select
 SELECT INTO value(crss_map_extractfile)
  n_group_sequence = nullind(c.group_sequence)
  FROM (dummyt d  WITH seq = value(crss_map_cnt)),
   cmt_cross_map c
  PLAN (d
   WHERE crss_map_cnt > 0)
   JOIN (c
   WHERE (c.cmt_cross_map_id=crss_map_keys->qual[d.seq].crss_map_sk))
  DETAIL
   mapcross = validate(c.map_type_flag,0), active_ind = crss_map_keys->qual[d.seq].active_ind, col 0,
   health_system_source_id, v_bar,
   CALL print(trim(cnvtstring(crss_map_keys->qual[d.seq].crss_map_sk,16))),
   v_bar,
   CALL print(trim(replace(c.concept_cki,str_find,str_replace,3))), v_bar,
   CALL print(trim(evaluate(mapcross,0,blank_field,build(mapcross)))), v_bar,
   CALL print(trim(cnvtstring(c.map_type_cd,16))),
   v_bar,
   CALL print(trim(replace(validate(c.target_concept_cki,blank_field),str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(replace(evaluate(n_group_sequence,0,build(c.group_sequence),blank_field),str_find,
     str_replace,3),3)), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,c.beg_effective_dt_tm,0,cnvtdatetimeutc(c
       .beg_effective_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,c.end_effective_dt_tm,0,cnvtdatetimeutc(c
       .end_effective_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(active_ind,16))), v_bar, extract_dt_tm_fmt,
   v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, outerjoin = d
 ;end select
 FREE RECORD crss_map_keys
 CALL echo(build("CRSS_MAP Count = ",curqual))
 CALL edwupdatescriptstatus("CRSS_MAP",curqual,"4","4")
 IF (error(err_msg,1) != 0)
  SET scripterror_ind = 1
 ENDIF
 SET error_ind = scripterror_ind
 SET script_version = "004 08/21/17 SB026554"
END GO
