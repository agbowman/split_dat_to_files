CREATE PROGRAM edw_diagnosis:dba
 DECLARE diag_cnt = i4
 DECLARE zone_cnt = i4
 DECLARE parser_line_d = vc WITH protect, constant(build("BUILD(",value(encounter_nk),")"))
 DECLARE scripterror_ind = i2 WITH protect, noconstant(0)
 DECLARE new_list_size = i4
 DECLARE cur_list_size = i4
 DECLARE batch_size = i4 WITH constant(50)
 DECLARE nstart = i4
 DECLARE loop_cnt = i4
 DECLARE idx = i4
 DECLARE num = i4
 DECLARE temp_indx = i4 WITH noconstant(0)
 DECLARE keys_start = i4 WITH noconstant(0)
 DECLARE keys_end = i4 WITH noconstant(0)
 DECLARE keys_batch = i4 WITH constant(medium_batch_size)
 DECLARE parent_key_cnt = i4 WITH noconstant(0)
 IF (validate(pca_filter,0)=0)
  SELECT INTO "nl:"
   FROM diagnosis di
   PLAN (di
    WHERE di.updt_dt_tm >= cnvtdatetime(act_from_dt_tm)
     AND di.updt_dt_tm < cnvtdatetime(act_to_dt_tm)
     AND di.diagnosis_id > 0)
   HEAD REPORT
    diag_cnt = 0
   DETAIL
    diag_cnt = (diag_cnt+ 1)
    IF (mod(diag_cnt,10)=1)
     stat = alterlist(diag_keys->qual,(diag_cnt+ 9))
    ENDIF
    diag_keys->qual[diag_cnt].diagnosis_id = di.diagnosis_id
   WITH nocounter
  ;end select
  IF (d_encounter="Y")
   SELECT INTO "nl:"
    FROM encounter,
     diagnosis di
    PLAN (encounter
     WHERE encounter.updt_dt_tm >= cnvtdatetime(act_from_dt_tm)
      AND encounter.updt_dt_tm < cnvtdatetime(act_to_dt_tm)
      AND encounter.encntr_id > 0)
     JOIN (di
     WHERE di.encntr_id=encounter.encntr_id
      AND di.diagnosis_id != 0)
    DETAIL
     diag_cnt = (diag_cnt+ 1)
     IF (mod(diag_cnt,10)=1)
      stat = alterlist(diag_keys->qual,(diag_cnt+ 9))
     ENDIF
     diag_keys->qual[diag_cnt].diagnosis_id = di.diagnosis_id
    WITH nocounter
   ;end select
  ENDIF
 ELSE
  SET diag_cnt = size(diag_keys->qual,5)
 ENDIF
 IF (diag_cnt > 0)
  SELECT DISTINCT INTO "nl:"
   FROM (dummyt d  WITH seq = value(diag_cnt)),
    diagnosis diag
   PLAN (d)
    JOIN (diag
    WHERE (diag_keys->qual[d.seq].diagnosis_id=diag.diagnosis_id)
     AND diag.diagnosis_id != 0)
   ORDER BY diag.diagnosis_group, diag.end_effective_dt_tm DESC, diag.diagnosis_id
   HEAD REPORT
    cnt = 0
   HEAD diag.diagnosis_group
    IF (diag.diagnosis_group > 0)
     cnt = (cnt+ 1), diag_keys->qual[cnt].diagnosis_id = diag.diagnosis_id
    ENDIF
   DETAIL
    IF (diag.diagnosis_group=0)
     cnt = (cnt+ 1), diag_keys->qual[cnt].diagnosis_id = diag.diagnosis_id
    ENDIF
   FOOT REPORT
    diag_cnt = cnt, stat = alterlist(diag_keys->qual,cnt)
   WITH nocounter
  ;end select
 ENDIF
 SET keys_start = 1
 SET keys_end = minval(((keys_start+ keys_batch) - 1),diag_cnt)
 WHILE (keys_start <= keys_end)
   SET stat = alterlist(diag->qual,keys_batch)
   IF (debug="Y")
    CALL echo(concat("Looping from keys_start = ",build(keys_start)," to keys_end = ",build(keys_end)
      ))
   ENDIF
   SET temp_indx = 0
   FOR (i = keys_start TO keys_end)
    SET temp_indx = (temp_indx+ 1)
    SET diag->qual[temp_indx].diagnosis_id = diag_keys->qual[i].diagnosis_id
   ENDFOR
   IF (temp_indx < keys_batch)
    SET cur_list_size = temp_indx
    SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
    SET new_list_size = (loop_cnt * batch_size)
    SET stat = alterlist(diag->qual,new_list_size)
    FOR (i = temp_indx TO new_list_size)
      SET diag->qual[i].diagnosis_id = diag->qual[temp_indx].diagnosis_id
    ENDFOR
   ELSE
    SET cur_list_size = keys_batch
    SET loop_cnt = (cnvtreal(keys_batch)/ batch_size)
   ENDIF
   SET nstart = 1
   SELECT INTO "nl:"
    enc_nk = parser(parser_line_d)
    FROM (dummyt d  WITH seq = value(loop_cnt)),
     diagnosis di,
     (left JOIN encounter ON encounter.encntr_id=di.encntr_id)
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
     JOIN (di
     WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),di.diagnosis_id,diag->qual[idx].diagnosis_id)
     )
     JOIN (encounter)
    DETAIL
     parent_key_cnt = (parent_key_cnt+ 1)
     IF (mod(parent_key_cnt,10)=1)
      stat = alterlist(diag_parent_keys->qual,(parent_key_cnt+ 9))
     ENDIF
     diag_parent_keys->qual[parent_key_cnt].encntr_slice_sk = validate(di.encntr_slice_id,0),
     diag_parent_keys->qual[parent_key_cnt].encounter_sk = encounter.encntr_id, index = locateval(num,
      1,cur_list_size,di.diagnosis_id,diag->qual[num].diagnosis_id),
     diag->qual[index].encounter_nk = enc_nk, diag->qual[index].loc_facility_cd = encounter
     .loc_facility_cd, diag->qual[index].encounter_sk = encounter.encntr_id,
     diag->qual[index].nomenclature_id = di.nomenclature_id, diag->qual[index].encntr_slice_id =
     validate(di.encntr_slice_id,0), diag->qual[index].diag_priority = di.diag_priority,
     diag->qual[index].clinical_diag_priority = di.clinical_diag_priority, diag->qual[index].
     diag_type_cd = di.diag_type_cd, diag->qual[index].attestation_dt_tm = di.attestation_dt_tm,
     diag->qual[index].certainty_cd = di.certainty_cd, diag->qual[index].classification_cd = di
     .classification_cd, diag->qual[index].clinical_service_cd = di.clinical_service_cd,
     diag->qual[index].confirmation_status_cd = di.confirmation_status_cd, diag->qual[index].
     diagnosis_display = di.diagnosis_display, diag->qual[index].diag_ftdesc = di.diag_ftdesc,
     diag->qual[index].diagnostic_category_cd = di.diagnostic_category_cd, diag->qual[index].
     diag_class_cd = di.diag_class_cd, diag->qual[index].diag_dt_tm = di.diag_dt_tm,
     diag->qual[index].diag_note = di.diag_note, diag->qual[index].diag_prsnl_id = di.diag_prsnl_id,
     diag->qual[index].diag_prsnl_name = di.diag_prsnl_name,
     diag->qual[index].probability = di.probability, diag->qual[index].ranking_cd = di.ranking_cd,
     diag->qual[index].severity_cd = di.severity_cd,
     diag->qual[index].severity_class_cd = di.severity_class_cd, diag->qual[index].severity_ftdesc =
     di.severity_ftdesc, diag->qual[index].svc_cat_hist_id = di.svc_cat_hist_id,
     diag->qual[index].active_ind = di.active_ind, diag->qual[index].present_on_admit = cnvtstring(di
      .present_on_admit_cd,16), diag->qual[index].updt_id = di.updt_id,
     diag->qual[index].create_dt_tm = di.beg_effective_dt_tm, diag->qual[index].contributor_system_cd
      = di.contributor_system_cd, diag->qual[index].src_updt_dt_tm = di.updt_dt_tm
     IF (di.diagnosis_group != 0
      AND di.diagnosis_group != null)
      diag->qual[index].diagnosis_sk = di.diagnosis_group
     ELSE
      diag->qual[index].diagnosis_sk = di.diagnosis_id
     ENDIF
    WITH nocounter
   ;end select
   FOR (zone_cnt = 1 TO cur_list_size)
     SET time_zone = gettimezone(diag->qual[zone_cnt].loc_facility_cd,diag->qual[zone_cnt].
      encounter_sk)
     SET diag->qual[zone_cnt].attestation_tm_zn = time_zone
     SET diag->qual[zone_cnt].diag_tm_zn = time_zone
     SET diag->qual[zone_cnt].create_tm_zn = time_zone
     IF (encounter_nk != default_encounter_nk)
      SET diag->qual[zone_cnt].encounter_nk = get_encounter_nk(diag->qual[zone_cnt].encounter_sk)
     ENDIF
   ENDFOR
   SELECT INTO value(diag_extractfile)
    FROM (dummyt d  WITH seq = value(cur_list_size))
    DETAIL
     col 0, health_system_id, v_bar,
     health_system_source_id, v_bar, v_bar,
     "0", v_bar,
     CALL print(trim(cnvtstring(cnvtint(diag->qual[d.seq].encounter_sk)))),
     v_bar,
     CALL print(trim(replace(diag->qual[d.seq].encounter_nk,str_find,str_replace,3),3)), v_bar,
     CALL print(trim(cnvtstring(cnvtint(diag->qual[d.seq].encntr_slice_id)))), v_bar,
     CALL print(trim(cnvtstring(cnvtint(diag->qual[d.seq].svc_cat_hist_id)))),
     v_bar,
     CALL print(trim(cnvtstring(cnvtint(diag->qual[d.seq].diagnosis_sk)))), v_bar,
     CALL print(trim(cnvtstring(cnvtint(diag->qual[d.seq].nomenclature_id)))), v_bar, v_bar,
     CALL print(build(diag->qual[d.seq].diag_priority)), v_bar,
     CALL print(build(diag->qual[d.seq].clinical_diag_priority)),
     v_bar,
     CALL print(trim(cnvtstring(cnvtint(diag->qual[d.seq].diag_type_cd)))), v_bar,
     CALL print(trim(datetimezoneformat(evaluate(curutc,1,diag->qual[d.seq].attestation_dt_tm,0,
        cnvtdatetimeutc(diag->qual[d.seq].attestation_dt_tm,3)),utc_timezone_index,
       "MM/DD/YYYY HH:mm:ss"))), v_bar,
     CALL print(trim(cnvtstring(diag->qual[d.seq].attestation_tm_zn))),
     v_bar,
     CALL print(evaluate(datetimezoneformat(diag->qual[d.seq].attestation_dt_tm,cnvtint(diag->qual[d
        .seq].attestation_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
      "1")), v_bar,
     CALL print(trim(cnvtstring(cnvtint(diag->qual[d.seq].certainty_cd)))), v_bar,
     CALL print(trim(cnvtstring(cnvtint(diag->qual[d.seq].classification_cd)))),
     v_bar,
     CALL print(trim(cnvtstring(cnvtint(diag->qual[d.seq].clinical_service_cd)))), v_bar,
     CALL print(trim(cnvtstring(cnvtint(diag->qual[d.seq].confirmation_status_cd)))), v_bar,
     CALL print(trim(replace(diag->qual[d.seq].diagnosis_display,str_find,str_replace,3),3)),
     v_bar,
     CALL print(trim(replace(diag->qual[d.seq].diag_ftdesc,str_find,str_replace,3),3)), v_bar,
     v_bar,
     CALL print(trim(cnvtstring(cnvtint(diag->qual[d.seq].diagnostic_category_cd)))), v_bar,
     CALL print(trim(cnvtstring(cnvtint(diag->qual[d.seq].diag_class_cd)))), v_bar,
     CALL print(trim(datetimezoneformat(evaluate(curutc,1,diag->qual[d.seq].diag_dt_tm,0,
        cnvtdatetimeutc(diag->qual[d.seq].diag_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))),
     v_bar,
     CALL print(trim(cnvtstring(diag->qual[d.seq].diag_tm_zn))), v_bar,
     CALL print(evaluate(datetimezoneformat(diag->qual[d.seq].diag_dt_tm,cnvtint(diag->qual[d.seq].
        diag_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
      "1")), v_bar,
     CALL print(trim(replace(diag->qual[d.seq].diag_note,str_find,str_replace,3),3)),
     v_bar,
     CALL print(trim(cnvtstring(cnvtint(diag->qual[d.seq].diag_prsnl_id)))), v_bar,
     CALL print(trim(replace(diag->qual[d.seq].diag_prsnl_name,str_find,str_replace,3),3)), v_bar,
     CALL print(build(diag->qual[d.seq].probability)),
     v_bar,
     CALL print(trim(cnvtstring(cnvtint(diag->qual[d.seq].ranking_cd)))), v_bar,
     CALL print(trim(cnvtstring(cnvtint(diag->qual[d.seq].severity_cd)))), v_bar,
     CALL print(trim(cnvtstring(cnvtint(diag->qual[d.seq].severity_class_cd)))),
     v_bar,
     CALL print(trim(replace(diag->qual[d.seq].severity_ftdesc,str_find,str_replace,3),3)), v_bar,
     "0", v_bar, "2",
     v_bar, "3", v_bar,
     extract_dt_tm_fmt, v_bar,
     CALL print(build(diag->qual[d.seq].active_ind)),
     v_bar,
     CALL print(trim(diag->qual[d.seq].present_on_admit)), v_bar,
     CALL print(trim(cnvtstring(cnvtint(diag->qual[d.seq].updt_id)))), v_bar,
     CALL print(trim(datetimezoneformat(evaluate(curutc,1,diag->qual[d.seq].create_dt_tm,0,
        cnvtdatetimeutc(diag->qual[d.seq].create_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))
     ),
     v_bar,
     CALL print(trim(cnvtstring(diag->qual[d.seq].create_tm_zn))), v_bar,
     CALL print(evaluate(datetimezoneformat(diag->qual[d.seq].create_dt_tm,cnvtint(diag->qual[d.seq].
        create_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
      "1")), v_bar,
     CALL print(trim(cnvtstring(diag->qual[d.seq].contributor_system_cd,16))),
     v_bar,
     CALL print(trim(datetimezoneformat(evaluate(curutc,1,diag->qual[d.seq].src_updt_dt_tm,0,
        cnvtdatetimeutc(diag->qual[d.seq].src_updt_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm:ss"
       ))), v_bar,
     row + 1
    WITH noheading, nocounter, format = lfstream,
     maxcol = 1999, maxrow = 1, append
   ;end select
   IF (validate(pca_filter,0)=1)
    CALL parser(pca_getref)
   ENDIF
   SET stat = alterlist(diag->qual,0)
   SET keys_start = (keys_end+ 1)
   SET keys_end = minval(((keys_start+ keys_batch) - 1),diag_cnt)
 ENDWHILE
 IF (diag_cnt=0)
  SELECT INTO value(diag_extractfile)
   FROM dummyt
   WHERE diag_cnt > 0
   WITH noheading, nocounter, format = lfstream,
    maxcol = 1999, maxrow = 1
  ;end select
 ENDIF
 FREE RECORD diag
 FREE RECORD diag_keys
 CALL echo(build("DIAG Count = ",diag_cnt))
 CALL edwupdatescriptstatus("DIAG",diag_cnt,"22","22")
 IF (error(err_msg,1) != 0)
  SET scripterror_ind = 1
 ENDIF
 SET error_ind = scripterror_ind
#end_program
 SET script_version = "022 10/09/20 BS074648"
END GO
