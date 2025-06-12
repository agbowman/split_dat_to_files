CREATE PROGRAM edw_enc_grp:dba
 DECLARE enc_grp_cnt = i4 WITH protect, noconstant(size(enc_grp_keys->qual,5))
 DECLARE encntr_slice_exist = i4
 DECLARE whereclause = vc WITH protect, noconstant
 DECLARE new_list_size = i4
 DECLARE cur_list_size = i4
 DECLARE batch_size = i4 WITH constant(50)
 DECLARE nstart = i4
 DECLARE loop_cnt = i4
 DECLARE idx = i4
 DECLARE num = i4
 DECLARE parser_line_g = vc WITH protect, constant(build("BUILD(",value(encounter_nk),")"))
 DECLARE inst_where_clause = vc WITH protect, noconstant("1 = 1")
 DECLARE scripterror_ind = i2 WITH protect, noconstant(0)
 DECLARE temp_indx = i4 WITH noconstant(0)
 DECLARE keys_start = i4 WITH noconstant(0)
 DECLARE keys_end = i4 WITH noconstant(0)
 DECLARE keys_batch = i4 WITH constant(medium_batch_size)
 DECLARE parent_key_cnt = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM dtableattr d,
   dtableattrl dl
  WHERE d.table_name="DRG_ENCNTR_EXTENSION"
   AND dl.attr_name="ENCNTR_SLICE_ID"
  DETAIL
   encntr_slice_exist = 1
  WITH nocounter
 ;end select
 IF (encntr_slice_exist=1)
  SET whereclause = "de.encntr_slice_id = dr.encntr_slice_id"
 ELSE
  SET whereclause = "1 = 1"
 ENDIF
 IF (validate(pca_filter,0)=0)
  SELECT INTO "nl:"
   FROM drg dr
   WHERE ((dr.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm)) OR (dr
   .active_status_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm)))
   HEAD REPORT
    enc_grp_cnt = 0
   DETAIL
    enc_grp_cnt = (enc_grp_cnt+ 1)
    IF (mod(enc_grp_cnt,10)=1)
     stat = alterlist(enc_grp_keys->qual,(enc_grp_cnt+ 9))
    ENDIF
    enc_grp_keys->qual[enc_grp_cnt].drg_id = dr.drg_id
   WITH nocounter
  ;end select
  IF (drg_enc_ext_ind="Y")
   SELECT DISTINCT INTO "nl:"
    dr.drg_id
    FROM drg_encntr_extension de,
     drg dr
    PLAN (de
     WHERE de.updt_dt_tm >= cnvtdatetime(act_from_dt_tm)
      AND de.updt_dt_tm < cnvtdatetime(act_to_dt_tm))
     JOIN (dr
     WHERE dr.encntr_id=de.encntr_id
      AND dr.svc_cat_hist_id=de.svc_cat_hist_id
      AND dr.active_ind=1
      AND parser(whereclause))
    ORDER BY dr.drg_id
    DETAIL
     enc_grp_cnt = (enc_grp_cnt+ 1)
     IF (mod(enc_grp_cnt,10)=1)
      stat = alterlist(enc_grp_keys->qual,(enc_grp_cnt+ 9))
     ENDIF
     enc_grp_keys->qual[enc_grp_cnt].drg_id = dr.drg_id
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF (encntr_slice_exist=1)
  SET whereclause = "de.encntr_slice_id = enc_grp->qual[d.seq].encntr_slice_id"
 ELSE
  SET whereclause = "1 = 1"
 ENDIF
 IF (enc_grp_cnt > 0)
  SELECT DISTINCT INTO "nl:"
   enc_nk = parser(parser_line_g), drg_id = enc_grp_keys->qual[d.seq].drg_id
   FROM (dummyt d  WITH seq = value(enc_grp_cnt)),
    drg dr,
    encounter
   PLAN (d
    WHERE enc_grp_cnt > 0)
    JOIN (dr
    WHERE (dr.drg_id=enc_grp_keys->qual[d.seq].drg_id))
    JOIN (encounter
    WHERE encounter.encntr_id=dr.encntr_id
     AND parser(inst_filter)
     AND parser(org_filter))
   ORDER BY enc_nk, drg_id
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1), enc_grp_keys->qual[cnt].drg_id = drg_id
    IF (encounter_nk != default_encounter_nk)
     enc_grp_keys->qual[cnt].encounter_id = dr.encntr_id
    ELSE
     enc_grp_keys->qual[cnt].enc_nk = enc_nk
    ENDIF
   FOOT REPORT
    enc_grp_cnt = cnt, stat = alterlist(enc_grp_keys->qual,cnt)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET enc_grp_cnt = 0
   SET stat = alterlist(enc_grp_keys->qual,cnt)
  ENDIF
 ENDIF
 SET keys_start = 1
 SET keys_end = minval(((keys_start+ keys_batch) - 1),enc_grp_cnt)
 WHILE (keys_start <= keys_end)
   SET stat = alterlist(enc_grp->qual,keys_batch)
   IF (debug="Y")
    CALL echo(concat("Looping from keys_start = ",build(keys_start)," to keys_end = ",build(keys_end)
      ))
   ENDIF
   SET temp_indx = 0
   FOR (i = keys_start TO keys_end)
     SET temp_indx = (temp_indx+ 1)
     SET enc_grp->qual[temp_indx].drg_id = enc_grp_keys->qual[i].drg_id
     IF (encounter_nk != default_encounter_nk)
      SET enc_grp->qual[temp_indx].encounter_nk = get_encounter_nk(enc_grp_keys->qual[i].encounter_id
       )
     ELSE
      SET enc_grp->qual[temp_indx].encounter_nk = enc_grp_keys->qual[i].enc_nk
     ENDIF
   ENDFOR
   IF (temp_indx < keys_batch)
    SET cur_list_size = temp_indx
    SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
    SET new_list_size = (loop_cnt * batch_size)
    SET stat = alterlist(enc_grp->qual,new_list_size)
    FOR (i = temp_indx TO new_list_size)
      SET enc_grp->qual[i].drg_id = enc_grp->qual[temp_indx].drg_id
    ENDFOR
   ELSE
    SET cur_list_size = keys_batch
    SET loop_cnt = (cnvtreal(keys_batch)/ batch_size)
   ENDIF
   SET nstart = 1
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(loop_cnt)),
     drg dr,
     nomenclature n
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
     JOIN (dr
     WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),dr.drg_id,enc_grp->qual[idx].drg_id))
     JOIN (n
     WHERE n.nomenclature_id=dr.nomenclature_id)
    DETAIL
     parent_key_cnt = (parent_key_cnt+ 1)
     IF (mod(parent_key_cnt,10)=1)
      stat = alterlist(enc_grp_parent_keys->qual,(parent_key_cnt+ 9))
     ENDIF
     enc_grp_parent_keys->qual[parent_key_cnt].encntr_slice_sk = validate(dr.encntr_slice_id,0),
     enc_grp_parent_keys->qual[parent_key_cnt].encntr_id = dr.encntr_id, enc_grp_parent_keys->qual[
     parent_key_cnt].encntr_id = dr.encntr_id,
     index = locateval(num,1,cur_list_size,dr.drg_id,enc_grp->qual[num].drg_id), enc_grp->qual[index]
     .drg_id = dr.drg_id, enc_grp->qual[index].nomenclature_id = dr.nomenclature_id,
     enc_grp->qual[index].encntr_slice_id = validate(dr.encntr_slice_id,0), enc_grp->qual[index].
     svc_cat_hist = dr.svc_cat_hist_id, enc_grp->qual[index].encntr_id = dr.encntr_id,
     enc_grp->qual[index].comorbidity_cd = dr.comorbidity_cd, enc_grp->qual[index].drg_payment = dr
     .drg_payment, enc_grp->qual[index].drg_payor_cd = dr.drg_payor_cd,
     enc_grp->qual[index].drg_priority = dr.drg_priority, enc_grp->qual[index].mdc_apr_cd = dr
     .mdc_apr_cd, enc_grp->qual[index].mdc_cd = dr.mdc_cd,
     enc_grp->qual[index].outlier_cost = dr.outlier_cost, enc_grp->qual[index].outlier_days = dr
     .outlier_days, enc_grp->qual[index].outlier_reimbursement_cost = dr.outlier_reimbursement_cost,
     enc_grp->qual[index].risk_of_mortality_cd = dr.risk_of_mortality_cd, enc_grp->qual[index].
     severity_of_illness_cd = dr.severity_of_illness_cd, enc_grp->qual[index].source_vocabulary_cd =
     dr.source_vocabulary_cd,
     enc_grp->qual[index].active_ind = dr.active_ind, enc_grp->qual[index].source_vocabulary_cd = n
     .source_vocabulary_cd, enc_grp->qual[index].source_identifier = n.source_identifier,
     enc_grp->qual[index].contributor_system_cd = dr.contributor_system_cd
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(cur_list_size)),
     drg_encntr_extension de
    PLAN (d)
     JOIN (de
     WHERE (de.source_identifier=enc_grp->qual[d.seq].source_identifier)
      AND (de.source_vocabulary_cd=enc_grp->qual[d.seq].source_vocabulary_cd)
      AND (de.encntr_id=enc_grp->qual[d.seq].encntr_id)
      AND (de.svc_cat_hist_id=enc_grp->qual[d.seq].svc_cat_hist)
      AND de.active_ind=1
      AND parser(whereclause))
    DETAIL
     enc_grp->qual[d.seq].alos = de.alos, enc_grp->qual[d.seq].case_resource_weight = de
     .case_resource_weight, enc_grp->qual[d.seq].complexity_overlay = de.complexity_overlay,
     enc_grp->qual[d.seq].day_threshold = de.day_threshold, enc_grp->qual[d.seq].elos = de.elos,
     enc_grp->qual[d.seq].hospital_base_rate = de.hospital_base_rate,
     enc_grp->qual[d.seq].mcc = de.mcc, enc_grp->qual[d.seq].mcc_text = de.mcc_text, enc_grp->qual[d
     .seq].ontario_case_weight = de.ontario_case_weight,
     enc_grp->qual[d.seq].patient_status_cd = de.patient_status_cd, enc_grp->qual[d.seq].perdiem = de
     .perdiem, enc_grp->qual[d.seq].total_est_reimb = de.total_est_reimb,
     enc_grp->qual[d.seq].total_reimb_value = de.total_reimb_value, enc_grp->qual[d.seq].
     high_trim_value = de.high_trim_value, enc_grp->qual[d.seq].low_trim_value = de.low_trim_value,
     enc_grp->qual[d.seq].wies_weight_value = de.wies_weight_value
    WITH nocounter
   ;end select
   SELECT INTO value(enc_grp_extractfile)
    FROM (dummyt d  WITH seq = value(cur_list_size))
    DETAIL
     col 0, health_system_id, v_bar,
     health_system_source_id, v_bar,
     CALL print(trim(replace(enc_grp->qual[d.seq].encounter_nk,str_find,str_replace,3),3)),
     v_bar,
     CALL print(trim(cnvtstring(enc_grp->qual[d.seq].drg_id,16))), v_bar,
     CALL print(trim(cnvtstring(enc_grp->qual[d.seq].nomenclature_id,16))), v_bar,
     CALL print(trim(cnvtstring(enc_grp->qual[d.seq].encntr_slice_id,16))),
     v_bar,
     CALL print(trim(cnvtstring(enc_grp->qual[d.seq].svc_cat_hist,16))), v_bar,
     CALL print(trim(cnvtstring(enc_grp->qual[d.seq].encntr_id,16))), v_bar,
     CALL print(trim(cnvtstring(enc_grp->qual[d.seq].comorbidity_cd,16))),
     v_bar,
     CALL print(trim(evaluate(enc_grp->qual[d.seq].drg_payment,0,blank_field,cnvtstring(enc_grp->
        qual[d.seq].drg_payment)))), v_bar,
     CALL print(trim(cnvtstring(enc_grp->qual[d.seq].drg_payor_cd,16))), v_bar,
     CALL print(trim(evaluate(enc_grp->qual[d.seq].drg_priority,0,blank_field,cnvtstring(enc_grp->
        qual[d.seq].drg_priority)))),
     v_bar,
     CALL print(trim(cnvtstring(enc_grp->qual[d.seq].mdc_apr_cd,16))), v_bar,
     CALL print(trim(cnvtstring(enc_grp->qual[d.seq].mdc_cd,16))), v_bar,
     CALL print(trim(evaluate(enc_grp->qual[d.seq].outlier_cost,0,blank_field,cnvtstring(enc_grp->
        qual[d.seq].outlier_cost)))),
     v_bar,
     CALL print(trim(evaluate(enc_grp->qual[d.seq].outlier_days,0,blank_field,cnvtstring(enc_grp->
        qual[d.seq].outlier_days)))), v_bar,
     CALL print(trim(evaluate(enc_grp->qual[d.seq].outlier_reimbursement_cost,0,blank_field,
       cnvtstring(enc_grp->qual[d.seq].outlier_reimbursement_cost)))), v_bar,
     CALL print(trim(cnvtstring(enc_grp->qual[d.seq].risk_of_mortality_cd,16))),
     v_bar,
     CALL print(trim(cnvtstring(enc_grp->qual[d.seq].severity_of_illness_cd,16))), v_bar,
     CALL print(trim(cnvtstring(enc_grp->qual[d.seq].source_vocabulary_cd,16))), v_bar,
     CALL print(trim(evaluate(enc_grp->qual[d.seq].alos,0.0,blank_field,build(enc_grp->qual[d.seq].
        alos)))),
     v_bar,
     CALL print(trim(evaluate(enc_grp->qual[d.seq].case_resource_weight,0,blank_field,cnvtstring(
        enc_grp->qual[d.seq].case_resource_weight)))), v_bar,
     CALL print(trim(evaluate(enc_grp->qual[d.seq].complexity_overlay,0,blank_field,cnvtstring(
        enc_grp->qual[d.seq].complexity_overlay)))), v_bar,
     CALL print(trim(evaluate(enc_grp->qual[d.seq].day_threshold,0,blank_field,cnvtstring(enc_grp->
        qual[d.seq].day_threshold)))),
     v_bar,
     CALL print(trim(evaluate(enc_grp->qual[d.seq].elos,0.0,blank_field,build(enc_grp->qual[d.seq].
        elos)))), v_bar,
     CALL print(trim(evaluate(enc_grp->qual[d.seq].hospital_base_rate,0,blank_field,cnvtstring(
        enc_grp->qual[d.seq].hospital_base_rate)))), v_bar,
     CALL print(trim(evaluate(enc_grp->qual[d.seq].mcc,0,blank_field,cnvtstring(enc_grp->qual[d.seq].
        mcc)))),
     v_bar,
     CALL print(trim(replace(enc_grp->qual[d.seq].mcc_text,str_find,str_replace,3),3)), v_bar,
     CALL print(trim(evaluate(enc_grp->qual[d.seq].ontario_case_weight,0.0,blank_field,cnvtstring(
        cnvtint(enc_grp->qual[d.seq].ontario_case_weight))))), v_bar,
     CALL print(trim(cnvtstring(enc_grp->qual[d.seq].patient_status_cd,16))),
     v_bar,
     CALL print(trim(evaluate(enc_grp->qual[d.seq].perdiem,0.0,blank_field,cnvtstring(cnvtint(enc_grp
         ->qual[d.seq].perdiem))))), v_bar,
     CALL print(trim(evaluate(enc_grp->qual[d.seq].total_est_reimb,0,blank_field,cnvtstring(cnvtint(
         enc_grp->qual[d.seq].total_est_reimb))))), v_bar,
     CALL print(trim(evaluate(enc_grp->qual[d.seq].total_reimb_value,0.0,blank_field,cnvtstring(
        cnvtint(enc_grp->qual[d.seq].total_reimb_value))))),
     v_bar, "3", v_bar,
     extract_dt_tm_fmt, v_bar,
     CALL print(build(enc_grp->qual[d.seq].active_ind)),
     v_bar,
     CALL print(trim(evaluate(enc_grp->qual[d.seq].high_trim_value,0.0,blank_field,cnvtstring(enc_grp
        ->qual[d.seq].high_trim_value,16,4)))), v_bar,
     CALL print(trim(evaluate(enc_grp->qual[d.seq].low_trim_value,0.0,blank_field,cnvtstring(enc_grp
        ->qual[d.seq].low_trim_value,16,4)))), v_bar,
     CALL print(trim(evaluate(enc_grp->qual[d.seq].wies_weight_value,0.0,blank_field,cnvtstring(
        enc_grp->qual[d.seq].wies_weight_value,16,4)))),
     v_bar,
     CALL print(trim(cnvtstring(enc_grp->qual[d.seq].contributor_system_cd,16))), v_bar,
     row + 1
    WITH check, noheading, nocounter,
     format = lfstream, maxcol = 1999, maxrow = 1,
     append
   ;end select
   SET stat = alterlist(enc_grp->qual,0)
   SET keys_start = (keys_end+ 1)
   SET keys_end = minval(((keys_start+ keys_batch) - 1),enc_grp_cnt)
 ENDWHILE
 IF (enc_grp_cnt=0)
  SELECT INTO value(enc_grp_extractfile)
   FROM dummyt
   WHERE enc_grp_cnt > 0
   WITH check, noheading, nocounter,
    format = lfstream, maxcol = 1999, maxrow = 1
  ;end select
 ENDIF
 FREE RECORD enc_grp
 FREE RECORD enc_grp_keys
 CALL edwupdatescriptstatus("ENC_GRP",enc_grp_cnt,"19","19")
 CALL echo(build("ENC_GRP Count = ",enc_grp_cnt))
 IF (error(err_msg,1) != 0)
  SET scripterror_ind = 1
 ENDIF
 SET error_ind = scripterror_ind
 SET script_version = "019 05/11/2016 mf025696"
END GO
