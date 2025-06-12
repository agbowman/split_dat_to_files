CREATE PROGRAM edw_enc_prsnl:dba
 SET activefilterflag = validate(pca_filter,0)
 DECLARE counter = i4
 SET parser_line = build("BUILD(",value(encounter_nk),")")
 DECLARE scripterror_ind = i2 WITH protect, noconstant(0)
 DECLARE cur_list_size = i4 WITH noconstant(0)
 DECLARE total_list_size = i4 WITH noconstant(0)
 DECLARE temp_indx = i4 WITH noconstant(0)
 DECLARE keys_start = i4 WITH noconstant(0)
 DECLARE keys_end = i4 WITH noconstant(0)
 DECLARE keys_batch = i4 WITH constant(large_batch_size)
 DECLARE parent_key_cnt = i4 WITH noconstant(0)
 DECLARE total_cnt = i4 WITH noconstant(0)
 IF (activefilterflag=0)
  SELECT INTO "nl:"
   FROM encounter,
    encntr_prsnl_reltn epr
   PLAN (epr
    WHERE epr.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm))
    JOIN (encounter
    WHERE encounter.encntr_id=epr.encntr_id
     AND parser(inst_filter)
     AND parser(org_filter))
   HEAD REPORT
    parent_key_cnt = 0
   DETAIL
    parent_key_cnt = (parent_key_cnt+ 1)
    IF (mod(parent_key_cnt,10)=1)
     stat = alterlist(enc_prsnl_keys->qual,(parent_key_cnt+ 9))
    ENDIF
    enc_prsnl_keys->qual[parent_key_cnt].enc_prsnl_reltn_id = epr.encntr_prsnl_reltn_id,
    enc_prsnl_keys->qual[parent_key_cnt].personnel_type_ref = build(cnvtstring(epr.encntr_prsnl_r_cd,
      16))
   WITH nocounter
  ;end select
  SELECT DISTINCT INTO "nl:"
   FROM coding cd,
    encounter
   PLAN (cd
    WHERE cd.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm)
     AND cd.active_ind=1
     AND cd.create_prsnl_id > 0)
    JOIN (encounter
    WHERE encounter.encntr_id=cd.encntr_id
     AND parser(inst_filter)
     AND parser(org_filter))
   DETAIL
    parent_key_cnt = (parent_key_cnt+ 1)
    IF (mod(parent_key_cnt,10)=1)
     stat = alterlist(enc_prsnl_keys->qual,(parent_key_cnt+ 9))
    ENDIF
    enc_prsnl_keys->qual[parent_key_cnt].enc_prsnl_reltn_id = cd.coding_id, enc_prsnl_keys->qual[
    parent_key_cnt].personnel_type_ref = "CV_CODING"
   WITH nocounter
  ;end select
  SET stat = alterlist(enc_prsnl_keys->qual,parent_key_cnt)
 ENDIF
 SET total_cnt = size(enc_prsnl_keys->qual,5)
 SET keys_start = 1
 SET keys_end = minval(((keys_start+ keys_batch) - 1),total_cnt)
 WHILE (keys_start <= keys_end)
   SET stat = alterlist(enc_prsnl->qual,keys_batch)
   SET temp_indx = 0
   FOR (i = keys_start TO keys_end)
     SET temp_indx = (temp_indx+ 1)
     SET enc_prsnl->qual[temp_indx].enc_prsnl_reltn_id = enc_prsnl_keys->qual[i].enc_prsnl_reltn_id
     SET enc_prsnl->qual[temp_indx].personnel_type_ref = enc_prsnl_keys->qual[i].personnel_type_ref
   ENDFOR
   SET cur_list_size = minval(temp_indx,keys_batch)
   SET stat = alterlist(enc_prsnl->qual,cur_list_size)
   SELECT INTO "nl:"
    enc_nk = parser(parser_line)
    FROM (dummyt d  WITH seq = value(cur_list_size)),
     encounter,
     encntr_prsnl_reltn epr
    PLAN (d
     WHERE (enc_prsnl->qual[d.seq].personnel_type_ref != "CV_CODING"))
     JOIN (epr
     WHERE (epr.encntr_prsnl_reltn_id=enc_prsnl->qual[d.seq].enc_prsnl_reltn_id))
     JOIN (encounter
     WHERE encounter.encntr_id=epr.encntr_id)
    DETAIL
     enc_prsnl->qual[d.seq].encounter_nk = enc_nk, enc_prsnl->qual[d.seq].encntr_sk = encounter
     .encntr_id, enc_prsnl->qual[d.seq].enc_prsnl_reltn_sk = build(cnvtstring(enc_prsnl->qual[d.seq].
       enc_prsnl_reltn_id,16)),
     enc_prsnl->qual[d.seq].encounter_prsnl = epr.prsnl_person_id, enc_prsnl->qual[d.seq].
     personnel_free_text_name = epr.ft_prsnl_name, enc_prsnl->qual[d.seq].personnel_internal_seq =
     epr.internal_seq,
     enc_prsnl->qual[d.seq].beg_prsnl_activity_dt_tm = epr.beg_effective_dt_tm, enc_prsnl->qual[d.seq
     ].loc_facility_cd = encounter.loc_facility_cd, enc_prsnl->qual[d.seq].active_ind = epr
     .active_ind,
     enc_prsnl->qual[d.seq].beg_effective_dt_tm = epr.beg_effective_dt_tm, enc_prsnl->qual[d.seq].
     end_effective_dt_tm = epr.end_effective_dt_tm, enc_prsnl->qual[d.seq].expiration_ind = epr
     .expiration_ind,
     enc_prsnl->qual[d.seq].expire_dt_tm = epr.expire_dt_tm, enc_prsnl->qual[d.seq].manual_create_ind
      = epr.manual_create_ind, enc_prsnl->qual[d.seq].manual_create_by_sk = epr.manual_create_by_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(cur_list_size)),
     prsnl_reltn pr,
     prsnl_reltn_activity pra
    PLAN (d
     WHERE cur_list_size > 0
      AND (enc_prsnl->qual[d.seq].personnel_type_ref != "CV_CODING"))
     JOIN (pra
     WHERE (pra.parent_entity_id=enc_prsnl->qual[d.seq].enc_prsnl_reltn_id)
      AND pra.parent_entity_name="ENCNTR_PRSNL_RELTN")
     JOIN (pr
     WHERE pr.prsnl_reltn_id=pra.prsnl_reltn_id
      AND pr.parent_entity_name="ORGANIZATION")
    DETAIL
     enc_prsnl->qual[d.seq].practice_org = pr.parent_entity_id
    WITH nocounter
   ;end select
   SELECT DISTINCT INTO "nl:"
    enc_nk = parser(parser_line)
    FROM (dummyt d  WITH seq = value(cur_list_size)),
     coding cd,
     encounter
    PLAN (d
     WHERE (enc_prsnl->qual[d.seq].personnel_type_ref="CV_CODING"))
     JOIN (cd
     WHERE (cd.coding_id=enc_prsnl->qual[d.seq].enc_prsnl_reltn_id))
     JOIN (encounter
     WHERE encounter.encntr_id=cd.encntr_id)
    DETAIL
     enc_prsnl->qual[d.seq].encounter_nk = enc_nk, enc_prsnl->qual[d.seq].encntr_sk = encounter
     .encntr_id, enc_prsnl->qual[d.seq].enc_prsnl_reltn_sk = build("CD_",cnvtstring(cd.coding_id,16)),
     enc_prsnl->qual[d.seq].loc_facility_cd = encounter.loc_facility_cd, enc_prsnl->qual[d.seq].
     encounter_prsnl = cd.create_prsnl_id, enc_prsnl->qual[d.seq].active_ind = cd.active_ind
    WITH nocounter
   ;end select
   IF (cur_list_size > 0)
    FOR (counter = 0 TO cur_list_size)
      SET enc_prsnl->qual[counter].beg_prsnl_activity_tm_zn = gettimezone(enc_prsnl->qual[counter].
       loc_facility_cd,enc_prsnl->qual[counter].encntr_sk)
      SET enc_prsnl->qual[counter].beg_effective_tm_zn = gettimezone(enc_prsnl->qual[counter].
       loc_facility_cd,enc_prsnl->qual[counter].encntr_sk)
      SET enc_prsnl->qual[counter].end_effective_tm_zn = gettimezone(enc_prsnl->qual[counter].
       loc_facility_cd,enc_prsnl->qual[counter].encntr_sk)
      SET enc_prsnl->qual[counter].enc_prsnl_reltn_tm_zn = gettimezone(enc_prsnl->qual[counter].
       loc_facility_cd,enc_prsnl->qual[counter].encntr_sk)
      IF (encounter_nk != default_encounter_nk)
       SET enc_prsnl->qual[counter].encounter_nk = get_encounter_nk(enc_prsnl->qual[counter].
        encntr_sk)
      ENDIF
    ENDFOR
    SELECT INTO value(enc_prsnl_extractfile)
     FROM (dummyt d  WITH seq = cur_list_size)
     DETAIL
      col 0,
      CALL print(trim(health_system_id)), v_bar,
      CALL print(trim(health_system_source_id)), v_bar,
      CALL print(trim(replace(enc_prsnl->qual[d.seq].encounter_nk,str_find,str_replace,3))),
      v_bar,
      CALL print(trim(cnvtstring(enc_prsnl->qual[d.seq].encntr_sk,16))), v_bar,
      CALL print(trim(replace(enc_prsnl->qual[d.seq].enc_prsnl_reltn_sk,str_find,str_replace,3))),
      v_bar,
      CALL print(trim(cnvtstring(enc_prsnl->qual[d.seq].encounter_prsnl,16))),
      v_bar,
      CALL print(trim(replace(enc_prsnl->qual[d.seq].personnel_free_text_name,str_find,str_replace,3)
       )), v_bar,
      CALL print(trim(replace(enc_prsnl->qual[d.seq].personnel_type_ref,str_find,str_replace,3))),
      v_bar,
      CALL print(trim(cnvtstring(enc_prsnl->qual[d.seq].personnel_internal_seq,16))),
      v_bar,
      CALL print(trim(datetimezoneformat(evaluate(curutc,1,enc_prsnl->qual[d.seq].
         beg_prsnl_activity_dt_tm,0,cnvtdatetimeutc(enc_prsnl->qual[d.seq].beg_prsnl_activity_dt_tm,3
          )),utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
      CALL print(trim(cnvtstring(enc_prsnl->qual[d.seq].beg_prsnl_activity_tm_zn,16))), v_bar,
      CALL print(evaluate(datetimezoneformat(enc_prsnl->qual[d.seq].beg_prsnl_activity_dt_tm,cnvtint(
         enc_prsnl->qual[d.seq].beg_prsnl_activity_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
       "1")),
      v_bar, "3", v_bar,
      extract_dt_tm_fmt, v_bar,
      CALL print(trim(cnvtstring(enc_prsnl->qual[d.seq].active_ind,16))),
      v_bar,
      CALL print(trim(cnvtstring(enc_prsnl->qual[d.seq].practice_org,16))), v_bar,
      CALL print(trim(datetimezoneformat(evaluate(curutc,1,enc_prsnl->qual[d.seq].beg_effective_dt_tm,
         0,cnvtdatetimeutc(enc_prsnl->qual[d.seq].beg_effective_dt_tm,3)),utc_timezone_index,
        "MM/DD/YYYY HH:mm:ss"))), v_bar,
      CALL print(trim(cnvtstring(enc_prsnl->qual[d.seq].beg_effective_tm_zn,16))),
      v_bar,
      CALL print(evaluate(datetimezoneformat(enc_prsnl->qual[d.seq].beg_effective_dt_tm,cnvtint(
         enc_prsnl->qual[d.seq].beg_effective_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
       "1")), v_bar,
      CALL print(trim(datetimezoneformat(evaluate(curutc,1,enc_prsnl->qual[d.seq].end_effective_dt_tm,
         0,cnvtdatetimeutc(enc_prsnl->qual[d.seq].end_effective_dt_tm,3)),utc_timezone_index,
        "MM/DD/YYYY HH:mm:ss"))), v_bar,
      CALL print(trim(cnvtstring(enc_prsnl->qual[d.seq].end_effective_tm_zn,16))),
      v_bar,
      CALL print(evaluate(datetimezoneformat(enc_prsnl->qual[d.seq].end_effective_dt_tm,cnvtint(
         enc_prsnl->qual[d.seq].end_effective_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
       "1")), v_bar,
      CALL print(trim(cnvtstring(enc_prsnl->qual[d.seq].expiration_ind,16))), v_bar,
      CALL print(trim(cnvtstring(enc_prsnl->qual[d.seq].enc_prsnl_reltn_tm_zn,16))),
      v_bar,
      CALL print(trim(datetimezoneformat(evaluate(curutc,1,enc_prsnl->qual[d.seq].expire_dt_tm,0,
         cnvtdatetimeutc(enc_prsnl->qual[d.seq].expire_dt_tm,3)),utc_timezone_index,
        "MM/DD/YYYY HH:mm:ss"))), v_bar,
      CALL print(trim(datetimezoneformat(evaluate(curutc,1,enc_prsnl->qual[d.seq].expire_dt_tm,0,
         cnvtdatetimeutc(enc_prsnl->qual[d.seq].expire_dt_tm,2)),enc_prsnl->qual[d.seq].
        enc_prsnl_reltn_tm_zn,"MM/DD/YYYY HH:mm:ss"))), v_bar,
      CALL print(trim(cnvtstring(enc_prsnl->qual[d.seq].manual_create_ind,16))),
      v_bar,
      CALL print(trim(cnvtstring(enc_prsnl->qual[d.seq].manual_create_by_sk,16))), v_bar,
      row + 1
     WITH check, noheading, nocounter,
      format = lfstream, maxcol = 1999, maxrow = 1,
      append
    ;end select
    IF (activefilterflag=1)
     IF (error(err_msg,1) != 0)
      SET scripterror_ind = 1
     ENDIF
    ENDIF
   ENDIF
   SET stat = alterlist(enc_prsnl->qual,0)
   SET keys_start = (keys_end+ 1)
   SET keys_end = minval(((keys_start+ keys_batch) - 1),total_cnt)
   SET total_list_size = (total_list_size+ cur_list_size)
 ENDWHILE
 IF (total_list_size=0)
  SELECT INTO value(enc_prsnl_extractfile)
   FROM dummyt
   WHERE total_list_size > 0
   WITH noheading, nocounter, format = lfstream,
    maxcol = 1999, maxrow = 1, append
  ;end select
 ENDIF
 CALL edwupdatescriptstatus("ENC_PSNL",total_list_size,"20","20")
 CALL echo(build("ENC_PSNL Count = ",total_list_size))
 IF (error(err_msg,1) != 0)
  SET scripterror_ind = 1
 ENDIF
 SET error_ind = scripterror_ind
 SET script_version = "020 03/13/15 sb026554"
END GO
