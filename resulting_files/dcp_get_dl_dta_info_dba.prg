CREATE PROGRAM dcp_get_dl_dta_info:dba
 RECORD reply(
   1 dta[*]
     2 task_assay_cd = f8
     2 active_ind = i2
     2 mnemonic = vc
     2 description = vc
     2 event_cd = f8
     2 activity_type_cd = f8
     2 activity_type_disp = vc
     2 activity_type_desc = vc
     2 activity_type_mean = vc
     2 default_result_type_cd = f8
     2 default_result_type_disp = c40
     2 default_result_type_desc = c60
     2 default_result_type_mean = vc
     2 code_set = i4
     2 ref_range_factor[*]
       3 species_cd = f8
       3 sex_cd = f8
       3 age_from_minutes = i4
       3 age_to_minutes = i4
       3 service_resource_cd = f8
       3 encntr_type_cd = f8
       3 specimen_type_cd = f8
       3 review_ind = i2
       3 review_low = f8
       3 review_high = f8
       3 sensitive_ind = i2
       3 sensitive_low = f8
       3 sensitive_high = f8
       3 normal_ind = i2
       3 normal_low = f8
       3 normal_high = f8
       3 critical_ind = i2
       3 critical_low = f8
       3 critical_high = f8
       3 feasible_ind = i2
       3 feasible_low = f8
       3 feasible_high = f8
       3 units_cd = f8
       3 units_disp = c40
       3 units_desc = c60
       3 code_set = i4
       3 minutes_back = i4
       3 def_result_ind = i2
       3 default_result = vc
       3 default_result_value = f8
       3 unknown_age_ind = i2
       3 alpha_response_ind = i2
       3 alpha_responses_cnt = i4
       3 alpha_responses[*]
         4 nomenclature_id = f8
         4 source_string = vc
         4 short_string = vc
         4 mnemonic = c25
         4 sequence = i4
         4 default_ind = i2
         4 description = vc
         4 result_value = f8
         4 multi_alpha_sort_order = i4
         4 concept_identifier = vc
       3 age_from = i4
       3 age_to = i4
       3 age_from_units_cd = f8
       3 age_to_units_cd = f8
       3 age_from_units_meaning = vc
       3 age_to_units_meaning = vc
       3 categories[*]
         4 category_id = f8
         4 expand_flag = i2
         4 category_name = vc
         4 sequence = i4
         4 alpha_responses[*]
           5 nomenclature_id = f8
           5 source_string = vc
           5 short_string = vc
           5 mnemonic = c25
           5 sequence = i4
           5 default_ind = i2
           5 description = vc
           5 result_value = f8
           5 multi_alpha_sort_order = i4
           5 concept_identifier = vc
     2 data_map[*]
       3 data_map_type_flag = i2
       3 result_entry_format = i4
       3 max_digits = i4
       3 min_digits = i4
       3 min_decimal_places = i4
       3 service_resource_cd = f8
     2 modifier_ind = i2
     2 single_select_ind = i2
     2 default_type_flag = i2
     2 version_number = f8
     2 io_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD flat_reply(
   1 qual[*]
     2 task_assay_cd = f8
     2 dta_idx = i4
     2 reference_range_factor_id = f8
     2 reference_range_idx = i4
 )
 RECORD expand_record(
   1 qual[*]
     2 id = f8
     2 index = i4
 )
 SET modify = predeclare
 DECLARE task_assay_cd = f8 WITH private, noconstant(0.0)
 DECLARE dta_cnt = i4 WITH protect, noconstant(0)
 DECLARE expand_index = i4 WITH protect, noconstant(0)
 DECLARE reply_dta_index = i4 WITH protect, noconstant(0)
 DECLARE rr_cnt = i4 WITH protect, noconstant(0)
 DECLARE flat_reply_cnt = i4 WITH protect, noconstant(0)
 DECLARE dtainx = i4 WITH protect, noconstant(0)
 DECLARE expand_blocks = i4 WITH protect, noconstant(0)
 DECLARE total_items = i4 WITH protect, noconstant(0)
 DECLARE expand_start = i4 WITH protect, noconstant(0)
 DECLARE expand_stop = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE expand_size = i4 WITH protect, constant(100)
 DECLARE getdtas(null) = null
 DECLARE getreferencerange(null) = null
 DECLARE getalpharesponses(null) = null
 DECLARE getparenteventcode(null) = null
 DECLARE getdatamap(null) = null
 DECLARE compute_age(age_minutes=i4,age_units=vc) = i4
 DECLARE getcategories(null) = null
 SET reply->status_data.status = "F"
 SET dta_cnt = size(request->dta,5)
 IF (dta_cnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  task_assay_cd = cnvtreal(request->dta[d1.seq].task_assay_cd)
  FROM (dummyt d1  WITH seq = value(dta_cnt))
  PLAN (d1
   WHERE (request->dta[d1.seq].task_assay_cd != 0))
  ORDER BY task_assay_cd
  HEAD REPORT
   dta_cnt = 0
  HEAD task_assay_cd
   dta_cnt = (dta_cnt+ 1)
   IF (dta_cnt > size(reply->dta,5))
    stat = alterlist(reply->dta,(dta_cnt+ 10))
   ENDIF
   reply->dta[dta_cnt].task_assay_cd = request->dta[d1.seq].task_assay_cd
  FOOT REPORT
   stat = alterlist(reply->dta,dta_cnt)
  WITH nocounter
 ;end select
 CALL getdtas(null)
 IF (dta_cnt=0)
  GO TO exit_script
 ENDIF
 CALL getreferencerange(null)
 CALL getalpharesponses(null)
 CALL getcategories(null)
 CALL getparenteventcode(null)
 CALL getdatamap(null)
#exit_script
 FREE RECORD flat_reply
 FREE RECORD expand_record
 IF (dta_cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SUBROUTINE getdtas(null)
   SET expand_blocks = ceil(((dta_cnt * 1.0)/ expand_size))
   SET total_items = (expand_blocks * expand_size)
   SET stat = alterlist(expand_record->qual,total_items)
   FOR (x = 1 TO total_items)
     IF (x > dta_cnt)
      SET expand_record->qual[x].id = expand_record->qual[dta_cnt].id
     ELSE
      SET expand_record->qual[x].id = reply->dta[x].task_assay_cd
     ENDIF
   ENDFOR
   SET expand_start = 0
   SET expand_stop = 0
   WHILE (expand_stop < dta_cnt)
     SET expand_start = (expand_stop+ 1)
     SET expand_stop = (expand_stop+ expand_size)
     SELECT INTO "nl:"
      FROM discrete_task_assay dta
      PLAN (dta
       WHERE expand(expand_index,expand_start,(expand_start+ (expand_size - 1)),dta.task_assay_cd,
        expand_record->qual[expand_index].id,
        expand_size)
        AND dta.active_ind=1
        AND ((dta.beg_effective_dt_tm=null) OR (dta.beg_effective_dt_tm != null
        AND dta.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND ((dta.end_effective_dt_tm=null) OR (dta.end_effective_dt_tm != null
        AND dta.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))) )) )
      ORDER BY dta.task_assay_cd
      HEAD dta.task_assay_cd
       reply_dta_index = (reply_dta_index+ 1), reply->dta[reply_dta_index].task_assay_cd = dta
       .task_assay_cd, reply->dta[reply_dta_index].mnemonic = dta.mnemonic,
       reply->dta[reply_dta_index].event_cd = dta.event_cd, reply->dta[reply_dta_index].description
        = dta.description, reply->dta[reply_dta_index].default_result_type_cd = dta
       .default_result_type_cd,
       reply->dta[reply_dta_index].activity_type_cd = dta.activity_type_cd, reply->dta[
       reply_dta_index].code_set = dta.code_set, reply->dta[reply_dta_index].active_ind = 1,
       reply->dta[reply_dta_index].modifier_ind = dta.modifier_ind, reply->dta[reply_dta_index].
       default_type_flag = dta.default_type_flag, reply->dta[reply_dta_index].single_select_ind = dta
       .single_select_ind,
       reply->dta[reply_dta_index].version_number = dta.version_number, reply->dta[reply_dta_index].
       io_flag = dta.io_flag
      WITH nocounter
     ;end select
   ENDWHILE
   SET dta_cnt = reply_dta_index
   SET stat = alterlist(reply->dta,dta_cnt)
 END ;Subroutine
 SUBROUTINE getreferencerange(null)
   SET expand_blocks = ceil(((dta_cnt * 1.0)/ expand_size))
   SET total_items = (expand_blocks * expand_size)
   SET stat = alterlist(expand_record->qual,total_items)
   FOR (x = 1 TO total_items)
     IF (x > dta_cnt)
      SET expand_record->qual[x].id = expand_record->qual[dta_cnt].id
      SET expand_record->qual[x].index = - (1)
     ELSE
      SET expand_record->qual[x].id = reply->dta[x].task_assay_cd
      SET expand_record->qual[x].index = x
     ENDIF
   ENDFOR
   SET expand_start = 0
   SET expand_stop = 0
   WHILE (expand_stop < dta_cnt)
     SET expand_start = (expand_stop+ 1)
     SET expand_stop = (expand_stop+ expand_size)
     IF (expand_stop > dta_cnt)
      SET expand_stop = dta_cnt
     ENDIF
     SELECT INTO "nl:"
      FROM reference_range_factor rrf
      WHERE expand(expand_index,expand_start,(expand_start+ (expand_size - 1)),rrf.task_assay_cd,
       expand_record->qual[expand_index].id,
       expand_size)
       AND rrf.active_ind=1
      ORDER BY rrf.task_assay_cd
      HEAD REPORT
       pos = 0, dta_index = 0
      HEAD rrf.task_assay_cd
       pos = locateval(pos,expand_start,expand_stop,rrf.task_assay_cd,expand_record->qual[pos].id),
       dta_index = expand_record->qual[pos].index, rr_cnt = 0
      DETAIL
       IF (rrf.task_assay_cd != 0
        AND rrf.reference_range_factor_id != 0)
        rr_cnt = (rr_cnt+ 1), stat = alterlist(reply->dta[dta_index].ref_range_factor,rr_cnt), reply
        ->dta[dta_index].ref_range_factor[rr_cnt].age_from_minutes = rrf.age_from_minutes,
        reply->dta[dta_index].ref_range_factor[rr_cnt].age_to_minutes = rrf.age_to_minutes, reply->
        dta[dta_index].ref_range_factor[rr_cnt].age_from_units_cd = rrf.age_from_units_cd, reply->
        dta[dta_index].ref_range_factor[rr_cnt].age_to_units_cd = rrf.age_to_units_cd,
        reply->dta[dta_index].ref_range_factor[rr_cnt].age_from_units_meaning = uar_get_code_meaning(
         rrf.age_from_units_cd), reply->dta[dta_index].ref_range_factor[rr_cnt].age_to_units_meaning
         = uar_get_code_meaning(rrf.age_to_units_cd), reply->dta[dta_index].ref_range_factor[rr_cnt].
        age_from = compute_age(rrf.age_from_minutes,uar_get_code_meaning(rrf.age_from_units_cd)),
        reply->dta[dta_index].ref_range_factor[rr_cnt].age_to = compute_age(rrf.age_to_minutes,
         uar_get_code_meaning(rrf.age_to_units_cd)), reply->dta[dta_index].ref_range_factor[rr_cnt].
        alpha_response_ind = rrf.alpha_response_ind, reply->dta[dta_index].ref_range_factor[rr_cnt].
        code_set = rrf.code_set,
        reply->dta[dta_index].ref_range_factor[rr_cnt].critical_high = rrf.critical_high, reply->dta[
        dta_index].ref_range_factor[rr_cnt].critical_ind = rrf.critical_ind, reply->dta[dta_index].
        ref_range_factor[rr_cnt].critical_low = rrf.critical_low,
        reply->dta[dta_index].ref_range_factor[rr_cnt].def_result_ind = rrf.def_result_ind, reply->
        dta[dta_index].ref_range_factor[rr_cnt].default_result = cnvtstring(rrf.default_result),
        reply->dta[dta_index].ref_range_factor[rr_cnt].default_result_value = rrf.default_result,
        reply->dta[dta_index].ref_range_factor[rr_cnt].encntr_type_cd = rrf.encntr_type_cd, reply->
        dta[dta_index].ref_range_factor[rr_cnt].feasible_high = rrf.feasible_high, reply->dta[
        dta_index].ref_range_factor[rr_cnt].feasible_ind = rrf.feasible_ind,
        reply->dta[dta_index].ref_range_factor[rr_cnt].feasible_low = rrf.feasible_low, reply->dta[
        dta_index].ref_range_factor[rr_cnt].minutes_back = rrf.mins_back, reply->dta[dta_index].
        ref_range_factor[rr_cnt].normal_high = rrf.normal_high,
        reply->dta[dta_index].ref_range_factor[rr_cnt].normal_ind = rrf.normal_ind, reply->dta[
        dta_index].ref_range_factor[rr_cnt].normal_low = rrf.normal_low, reply->dta[dta_index].
        ref_range_factor[rr_cnt].review_high = rrf.review_high,
        reply->dta[dta_index].ref_range_factor[rr_cnt].review_ind = rrf.review_ind, reply->dta[
        dta_index].ref_range_factor[rr_cnt].review_low = rrf.review_low, reply->dta[dta_index].
        ref_range_factor[rr_cnt].sensitive_high = rrf.sensitive_high,
        reply->dta[dta_index].ref_range_factor[rr_cnt].sensitive_ind = rrf.sensitive_ind, reply->dta[
        dta_index].ref_range_factor[rr_cnt].sensitive_low = rrf.sensitive_low, reply->dta[dta_index].
        ref_range_factor[rr_cnt].service_resource_cd = rrf.service_resource_cd,
        reply->dta[dta_index].ref_range_factor[rr_cnt].sex_cd = rrf.sex_cd, reply->dta[dta_index].
        ref_range_factor[rr_cnt].species_cd = rrf.species_cd, reply->dta[dta_index].ref_range_factor[
        rr_cnt].specimen_type_cd = rrf.specimen_type_cd,
        reply->dta[dta_index].ref_range_factor[rr_cnt].units_cd = rrf.units_cd, reply->dta[dta_index]
        .ref_range_factor[rr_cnt].unknown_age_ind = rrf.unknown_age_ind, flat_reply_cnt = (
        flat_reply_cnt+ 1)
        IF (mod(flat_reply_cnt,10)=1)
         stat = alterlist(flat_reply->qual,(flat_reply_cnt+ 9))
        ENDIF
        flat_reply->qual[flat_reply_cnt].reference_range_factor_id = rrf.reference_range_factor_id,
        flat_reply->qual[flat_reply_cnt].task_assay_cd = rrf.task_assay_cd, flat_reply->qual[
        flat_reply_cnt].dta_idx = dta_index,
        flat_reply->qual[flat_reply_cnt].reference_range_idx = rr_cnt
       ENDIF
      WITH nocounter
     ;end select
   ENDWHILE
   SET stat = alterlist(flat_reply->qual,flat_reply_cnt)
 END ;Subroutine
 SUBROUTINE getalpharesponses(null)
   SET expand_blocks = ceil(((flat_reply_cnt * 1.0)/ expand_size))
   SET total_items = (expand_blocks * expand_size)
   SET stat = alterlist(expand_record->qual,total_items)
   FOR (x = 1 TO total_items)
     IF (x > flat_reply_cnt)
      SET expand_record->qual[x].id = expand_record->qual[flat_reply_cnt].id
      SET expand_record->qual[x].index = - (1)
     ELSE
      SET expand_record->qual[x].id = flat_reply->qual[x].reference_range_factor_id
      SET expand_record->qual[x].index = x
     ENDIF
   ENDFOR
   SET expand_start = 0
   SET expand_stop = 0
   WHILE (expand_stop < flat_reply_cnt)
     SET expand_start = (expand_stop+ 1)
     SET expand_stop = (expand_stop+ expand_size)
     IF (expand_stop > flat_reply_cnt)
      SET expand_stop = flat_reply_cnt
     ENDIF
     SELECT INTO "nl:"
      FROM alpha_responses ar,
       nomenclature n
      PLAN (ar
       WHERE expand(expand_index,expand_start,(expand_start+ (expand_size - 1)),ar
        .reference_range_factor_id,expand_record->qual[expand_index].id,
        expand_size))
       JOIN (n
       WHERE n.nomenclature_id=ar.nomenclature_id
        AND n.active_ind=1
        AND ((n.beg_effective_dt_tm=null) OR (n.beg_effective_dt_tm != null
        AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND ((n.end_effective_dt_tm=null) OR (n.end_effective_dt_tm != null
        AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))) )) )
      ORDER BY ar.reference_range_factor_id, ar.sequence, ar.nomenclature_id
      HEAD REPORT
       flat_index = 0, pos = 0
      HEAD ar.reference_range_factor_id
       ar_cnt = 0, pos = locateval(pos,expand_start,expand_stop,ar.reference_range_factor_id,
        expand_record->qual[pos].id), flat_index = expand_record->qual[pos].index,
       dtainx = flat_reply->qual[flat_index].dta_idx, rr_cnt = flat_reply->qual[flat_index].
       reference_range_idx
      DETAIL
       ar_cnt = (ar_cnt+ 1)
       IF (ar_cnt > size(reply->dta[dtainx].ref_range_factor[rr_cnt].alpha_responses,5))
        stat = alterlist(reply->dta[dtainx].ref_range_factor[rr_cnt].alpha_responses,(ar_cnt+ 10))
       ENDIF
       reply->dta[dtainx].ref_range_factor[rr_cnt].alpha_responses[ar_cnt].default_ind = ar
       .default_ind, reply->dta[dtainx].ref_range_factor[rr_cnt].alpha_responses[ar_cnt].description
        = ar.description, reply->dta[dtainx].ref_range_factor[rr_cnt].alpha_responses[ar_cnt].
       multi_alpha_sort_order = ar.multi_alpha_sort_order,
       reply->dta[dtainx].ref_range_factor[rr_cnt].alpha_responses[ar_cnt].result_value = ar
       .result_value, reply->dta[dtainx].ref_range_factor[rr_cnt].alpha_responses[ar_cnt].sequence =
       ar.sequence, reply->dta[dtainx].ref_range_factor[rr_cnt].alpha_responses[ar_cnt].
       concept_identifier = n.concept_identifier,
       reply->dta[dtainx].ref_range_factor[rr_cnt].alpha_responses[ar_cnt].mnemonic = n.mnemonic,
       reply->dta[dtainx].ref_range_factor[rr_cnt].alpha_responses[ar_cnt].nomenclature_id = n
       .nomenclature_id, reply->dta[dtainx].ref_range_factor[rr_cnt].alpha_responses[ar_cnt].
       short_string = n.short_string,
       reply->dta[dtainx].ref_range_factor[rr_cnt].alpha_responses[ar_cnt].source_string = n
       .source_string
      FOOT  ar.reference_range_factor_id
       stat = alterlist(reply->dta[dtainx].ref_range_factor[rr_cnt].alpha_responses,ar_cnt), reply->
       dta[dtainx].ref_range_factor[rr_cnt].alpha_responses_cnt = ar_cnt
      WITH nocounter
     ;end select
   ENDWHILE
 END ;Subroutine
 SUBROUTINE getparenteventcode(null)
   SET expand_blocks = ceil(((dta_cnt * 1.0)/ expand_size))
   SET total_items = (expand_blocks * expand_size)
   SET stat = alterlist(expand_record->qual,total_items)
   FOR (x = 1 TO total_items)
     IF (x > dta_cnt)
      SET expand_record->qual[x].id = expand_record->qual[dta_cnt].id
      SET expand_record->qual[x].index = - (1)
     ELSE
      SET expand_record->qual[x].id = reply->dta[x].task_assay_cd
      SET expand_record->qual[x].index = x
     ENDIF
   ENDFOR
   SET expand_start = 0
   SET expand_stop = 0
   WHILE (expand_stop < dta_cnt)
     SET expand_start = (expand_stop+ 1)
     SET expand_stop = (expand_stop+ expand_size)
     IF (expand_stop > dta_cnt)
      SET expand_stop = dta_cnt
     ENDIF
     SELECT INTO "nl:"
      FROM code_value_event_r cver
      WHERE expand(expand_index,expand_start,(expand_start+ (expand_size - 1)),cver.parent_cd,
       expand_record->qual[expand_index].id,
       expand_size)
      HEAD REPORT
       pos = 0
      DETAIL
       pos = locateval(pos,expand_start,expand_stop,cver.parent_cd,expand_record->qual[pos].id),
       dta_index = expand_record->qual[pos].index
       IF ((reply->dta[dta_index].event_cd=0)
        AND cver.event_cd > 0)
        reply->dta[dta_index].event_cd = cver.event_cd
       ENDIF
      WITH nocounter
     ;end select
   ENDWHILE
 END ;Subroutine
 SUBROUTINE getdatamap(null)
   SET expand_blocks = ceil(((dta_cnt * 1.0)/ expand_size))
   SET total_items = (expand_blocks * expand_size)
   SET stat = alterlist(expand_record->qual,total_items)
   FOR (x = 1 TO total_items)
     IF (x > dta_cnt)
      SET expand_record->qual[x].id = expand_record->qual[dta_cnt].id
      SET expand_record->qual[x].index = - (1)
     ELSE
      SET expand_record->qual[x].id = reply->dta[x].task_assay_cd
      SET expand_record->qual[x].index = x
     ENDIF
   ENDFOR
   SET expand_start = 0
   SET expand_stop = 0
   WHILE (expand_stop < dta_cnt)
     SET expand_start = (expand_stop+ 1)
     SET expand_stop = (expand_stop+ expand_size)
     IF (expand_stop > dta_cnt)
      SET expand_stop = dta_cnt
     ENDIF
     SELECT INTO "nl:"
      dm.task_assay_cd
      FROM data_map dm
      WHERE expand(expand_index,expand_start,(expand_start+ (expand_size - 1)),dm.task_assay_cd,
       expand_record->qual[expand_index].id,
       expand_size)
       AND dm.active_ind=1
      ORDER BY dm.task_assay_cd
      HEAD REPORT
       pos = 0
      HEAD dm.task_assay_cd
       data_map_cnt = 0, pos = locateval(pos,expand_start,expand_stop,dm.task_assay_cd,expand_record
        ->qual[pos].id), dta_index = expand_record->qual[pos].index
      DETAIL
       data_map_cnt = (data_map_cnt+ 1)
       IF (mod(data_map_cnt,5)=1)
        stat = alterlist(reply->dta[dta_index].data_map,(data_map_cnt+ 4))
       ENDIF
       reply->dta[dta_index].data_map[data_map_cnt].data_map_type_flag = dm.data_map_type_flag, reply
       ->dta[dta_index].data_map[data_map_cnt].result_entry_format = dm.result_entry_format, reply->
       dta[dta_index].data_map[data_map_cnt].max_digits = dm.max_digits,
       reply->dta[dta_index].data_map[data_map_cnt].min_digits = dm.min_digits, reply->dta[dta_index]
       .data_map[data_map_cnt].min_decimal_places = dm.min_decimal_places, reply->dta[dta_index].
       data_map[data_map_cnt].service_resource_cd = dm.service_resource_cd
      FOOT  dm.task_assay_cd
       stat = alterlist(reply->dta[dta_index].data_map,data_map_cnt)
      WITH nocounter
     ;end select
   ENDWHILE
 END ;Subroutine
 SUBROUTINE compute_age(age_in_minutes,age_units_cd)
   DECLARE age = i4 WITH noconstant(0)
   IF (age_in_minutes=0)
    RETURN(age)
   ENDIF
   CASE (age_units_cd)
    OF "SECONDS":
     SET age = (age_in_minutes * 60)
    OF "MINUTES":
     SET age = age_in_minutes
    OF "HOURS":
     SET age = (age_in_minutes/ 60)
    OF "DAYS":
     SET age = ((age_in_minutes/ 60)/ 24)
    OF "WEEKS":
     SET age = (((age_in_minutes/ 60)/ 24)/ 7)
    OF "MONTHS":
     SET age = floor((((age_in_minutes/ 60)/ 24)/ 31))
    OF "YEARS":
     SET age = (((age_in_minutes/ 60)/ 24)/ 365)
    ELSE
     SET age = age_in_minutes
   ENDCASE
   RETURN(age)
 END ;Subroutine
 SUBROUTINE getcategories(null)
   SET expand_blocks = ceil(((flat_reply_cnt * 1.0)/ expand_size))
   SET total_items = (expand_blocks * expand_size)
   SET stat = alterlist(expand_record->qual,total_items)
   FOR (x = 1 TO total_items)
     IF (x > flat_reply_cnt)
      SET expand_record->qual[x].id = expand_record->qual[flat_reply_cnt].id
      SET expand_record->qual[x].index = - (1)
     ELSE
      SET expand_record->qual[x].id = flat_reply->qual[x].reference_range_factor_id
      SET expand_record->qual[x].index = x
     ENDIF
   ENDFOR
   SET expand_start = 0
   SET expand_stop = 0
   WHILE (expand_stop < flat_reply_cnt)
     SET expand_start = (expand_stop+ 1)
     SET expand_stop = (expand_stop+ expand_size)
     IF (expand_stop > flat_reply_cnt)
      SET expand_stop = flat_reply_cnt
     ENDIF
     SELECT INTO "nl:"
      FROM alpha_responses_category arc,
       alpha_responses ar,
       nomenclature n
      PLAN (arc
       WHERE expand(expand_index,expand_start,(expand_start+ (expand_size - 1)),arc
        .reference_range_factor_id,expand_record->qual[expand_index].id,
        expand_size))
       JOIN (ar
       WHERE ar.alpha_responses_category_id=arc.alpha_responses_category_id)
       JOIN (n
       WHERE n.nomenclature_id=ar.nomenclature_id
        AND n.active_ind=1
        AND ((n.beg_effective_dt_tm=null) OR (n.beg_effective_dt_tm != null
        AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND ((n.end_effective_dt_tm=null) OR (n.end_effective_dt_tm != null
        AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))) )) )
      ORDER BY arc.reference_range_factor_id, arc.display_seq, ar.sequence
      HEAD REPORT
       flat_index = 0, pos = 0
      HEAD arc.reference_range_factor_id
       arc_cnt = 0, pos = locateval(pos,expand_start,expand_stop,arc.reference_range_factor_id,
        expand_record->qual[pos].id), flat_index = expand_record->qual[pos].index,
       dtainx = flat_reply->qual[flat_index].dta_idx, rr_cnt = flat_reply->qual[flat_index].
       reference_range_idx
      HEAD arc.display_seq
       alpha_cnt = 0, arc_cnt = (arc_cnt+ 1)
       IF (mod(arc_cnt,10)=1)
        stat = alterlist(reply->dta[dtainx].ref_range_factor[rr_cnt].categories,(arc_cnt+ 10))
       ENDIF
       reply->dta[dtainx].ref_range_factor[rr_cnt].categories[arc_cnt].category_id = arc
       .alpha_responses_category_id, reply->dta[dtainx].ref_range_factor[rr_cnt].categories[arc_cnt].
       expand_flag = arc.expand_flag, reply->dta[dtainx].ref_range_factor[rr_cnt].categories[arc_cnt]
       .category_name = arc.category_name,
       reply->dta[dtainx].ref_range_factor[rr_cnt].categories[arc_cnt].sequence = arc.display_seq
      HEAD ar.sequence
       alpha_cnt = (alpha_cnt+ 1)
       IF (mod(alpha_cnt,10)=1)
        stat = alterlist(reply->dta[dtainx].ref_range_factor[rr_cnt].categories[arc_cnt].
         alpha_responses,(alpha_cnt+ 10))
       ENDIF
       reply->dta[dtainx].ref_range_factor[rr_cnt].categories[arc_cnt].alpha_responses[alpha_cnt].
       default_ind = ar.default_ind, reply->dta[dtainx].ref_range_factor[rr_cnt].categories[arc_cnt].
       alpha_responses[alpha_cnt].description = ar.description, reply->dta[dtainx].ref_range_factor[
       rr_cnt].categories[arc_cnt].alpha_responses[alpha_cnt].multi_alpha_sort_order = ar
       .multi_alpha_sort_order,
       reply->dta[dtainx].ref_range_factor[rr_cnt].categories[arc_cnt].alpha_responses[alpha_cnt].
       result_value = ar.result_value, reply->dta[dtainx].ref_range_factor[rr_cnt].categories[arc_cnt
       ].alpha_responses[alpha_cnt].sequence = ar.sequence, reply->dta[dtainx].ref_range_factor[
       rr_cnt].categories[arc_cnt].alpha_responses[alpha_cnt].concept_identifier = n
       .concept_identifier,
       reply->dta[dtainx].ref_range_factor[rr_cnt].categories[arc_cnt].alpha_responses[alpha_cnt].
       mnemonic = n.mnemonic, reply->dta[dtainx].ref_range_factor[rr_cnt].categories[arc_cnt].
       alpha_responses[alpha_cnt].nomenclature_id = n.nomenclature_id, reply->dta[dtainx].
       ref_range_factor[rr_cnt].categories[arc_cnt].alpha_responses[alpha_cnt].short_string = n
       .short_string,
       reply->dta[dtainx].ref_range_factor[rr_cnt].categories[arc_cnt].alpha_responses[alpha_cnt].
       source_string = n.source_string
      FOOT  arc.display_seq
       stat = alterlist(reply->dta[dtainx].ref_range_factor[rr_cnt].categories[arc_cnt].
        alpha_responses,alpha_cnt)
      FOOT  arc.reference_range_factor_id
       stat = alterlist(reply->dta[dtainx].ref_range_factor[rr_cnt].categories,arc_cnt)
      WITH nocounter
     ;end select
   ENDWHILE
 END ;Subroutine
END GO
