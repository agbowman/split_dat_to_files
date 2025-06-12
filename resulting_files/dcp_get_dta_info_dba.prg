CREATE PROGRAM dcp_get_dta_info:dba
 RECORD reply(
   1 dta_cnt = i4
   1 dta[*]
     2 task_assay_cd = f8
     2 active_ind = i2
     2 reference_range_factor_id = f8
     2 mnemonic = vc
     2 description = vc
     2 event_cd = f8
     2 activity_type_cd = f8
     2 default_result_type_cd = f8
     2 default_result_type_disp = c40
     2 default_result_type_desc = c60
     2 default_result_type_mean = vc
     2 default_type_flag = i2
     2 single_select_ind = i2
     2 verson_number = f8
     2 equation_id = f8
     2 equation_description = vc
     2 equation_postfix = vc
     2 script = vc
     2 e_comp_cnt = i4
     2 e_comp[*]
       3 constant_value = f8
       3 default_value = f8
       3 units_cd = f8
       3 included_assay_cd = f8
       3 name = vc
       3 result_req_flag = i2
       3 look_time_direction_flag = i2
       3 time_window_minutes = i4
       3 time_window_back_minutes = i4
       3 event_cd = f8
     2 review_ind = i2
     2 review_low = f8
     2 review_high = f8
     2 sensitive_ind = i2
     2 sensitive_low = f8
     2 sensitive_high = f8
     2 normal_ind = i2
     2 normal_low = f8
     2 normal_high = f8
     2 critical_ind = i2
     2 critical_low = f8
     2 critical_high = f8
     2 feasible_ind = i2
     2 feasible_low = f8
     2 feasible_high = f8
     2 units_cd = f8
     2 units_disp = c40
     2 units_desc = c60
     2 code_set = i4
     2 minutes_back = i4
     2 def_result_ind = i2
     2 default_result = vc
     2 default_result_value = f8
     2 alpha_responses_cnt = i4
     2 alpha_responses[*]
       3 nomenclature_id = f8
       3 source_string = vc
       3 short_string = vc
       3 mnemonic = c25
       3 sequence = i4
       3 default_ind = i2
       3 description = vc
       3 result_value = f8
       3 multi_alpha_sort_order = i4
       3 concept_identifier = vc
     2 data_map_type_flag = i2
     2 result_entry_format = i4
     2 max_digits = i4
     2 min_digits = i4
     2 min_decimal_places = i4
     2 io_flag = i2
     2 io_total_definition_id = f8
     2 template_script_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD flat_reply(
   1 dta[*]
     2 task_assay_cd = f8
     2 reference_range_factor_id = f8
     2 dta_index = i4
 )
 RECORD expand_record(
   1 qual[*]
     2 id = f8
     2 index = i4
 )
 SET modify = predeclare
 DECLARE dta_cnt = i4 WITH protect, noconstant(size(request->dta,5))
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE tot_value = i4 WITH protect, noconstant(0)
 DECLARE highest_tot_value = i4 WITH protect, noconstant(- (1))
 DECLARE active_dtas = i4 WITH protect, noconstant(0)
 DECLARE expand_cnt = i4 WITH protect, noconstant(0)
 DECLARE abc = vc WITH protect
 DECLARE decdigit = i4 WITH protect, noconstant(0)
 DECLARE maxdigit = i4 WITH protect, noconstant(0)
 DECLARE expand_blocks = i4 WITH protect, noconstant(0)
 DECLARE total_items = i4 WITH protect, noconstant(0)
 DECLARE expand_start = i4 WITH protect, noconstant(0)
 DECLARE expand_stop = i4 WITH protect, noconstant(0)
 DECLARE species_value = i4 WITH public, constant(32)
 DECLARE speciman_type_value = i4 WITH public, constant(16)
 DECLARE sex_value = i4 WITH public, constant(8)
 DECLARE age_value = i4 WITH public, constant(4)
 DECLARE resource_ts_value = i4 WITH public, constant(2)
 DECLARE resource_ts_group_value = i4 WITH public, constant(1)
 DECLARE pat_cond_value = i4 WITH public, constant(0)
 DECLARE expand_size = i4 WITH protect, constant(100)
 DECLARE getdtas(null) = null
 DECLARE getreferencerange(null) = null
 DECLARE getalpharesponses(null) = null
 DECLARE getdatamap(null) = null
 DECLARE getequations(null) = null
 DECLARE getiototaldefinition(null) = null
 SET reply->status_data.status = "F"
 SET reply->dta_cnt = dta_cnt
 SET stat = alterlist(reply->dta,dta_cnt)
 IF (dta_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(dta_cnt))
   ORDER BY request->dta[d.seq].task_assay_cd
   HEAD REPORT
    cnt = 0
   HEAD d.seq
    cnt = (cnt+ 1), reply->dta[cnt].task_assay_cd = request->dta[d.seq].task_assay_cd
   WITH nocounter
  ;end select
 ELSE
  GO TO exit_script
 ENDIF
 CALL getdtas(null)
 IF (active_dtas=0)
  GO TO exit_script
 ENDIF
 CALL getreferencerange(null)
 CALL getequations(null)
 CALL getalpharesponses(null)
 CALL getdatamap(null)
 CALL getiototaldefinition(null)
 FOR (x = 1 TO reply->dta_cnt)
   IF ((reply->dta[x].def_result_ind > 0)
    AND (reply->dta[x].min_decimal_places > 0))
    SET decdigit = reply->dta[x].min_decimal_places
    SET maxdigit = (reply->dta[x].max_digits+ 1)
    SET reply->dta[x].default_result = cnvtstring(reply->dta[x].default_result_value,value(maxdigit),
     value(decdigit),r)
   ENDIF
   SET abc = " "
   SET abc = substring(1,1,reply->dta[x].default_result)
   WHILE (abc="0")
    SET reply->dta[x].default_result = substring(2,100,reply->dta[x].default_result)
    SET abc = substring(1,1,reply->dta[x].default_result)
   ENDWHILE
 ENDFOR
#exit_script
 IF (active_dtas=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 FREE RECORD flat_reply
 FREE RECORD expand_record
 SUBROUTINE getdtas(null)
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
      FROM discrete_task_assay dta
      PLAN (dta
       WHERE expand(expand_cnt,expand_start,(expand_start+ (expand_size - 1)),dta.task_assay_cd,
        expand_record->qual[expand_cnt].id,
        expand_size)
        AND dta.active_ind=1
        AND ((dta.beg_effective_dt_tm=null) OR (dta.beg_effective_dt_tm != null
        AND dta.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND ((dta.end_effective_dt_tm=null) OR (dta.end_effective_dt_tm != null
        AND dta.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))) )) )
      ORDER BY dta.task_assay_cd
      HEAD REPORT
       pos = 0, index = 0
      HEAD dta.task_assay_cd
       pos = locateval(pos,expand_start,expand_stop,dta.task_assay_cd,expand_record->qual[pos].id),
       index = expand_record->qual[pos].index, reply->dta[index].mnemonic = dta.mnemonic,
       reply->dta[index].event_cd = dta.event_cd, reply->dta[index].description = dta.description,
       reply->dta[index].active_ind = 1,
       reply->dta[index].default_result_type_cd = dta.default_result_type_cd, reply->dta[index].
       default_type_flag = dta.default_type_flag, reply->dta[index].single_select_ind = dta
       .single_select_ind,
       reply->dta[index].activity_type_cd = dta.activity_type_cd, reply->dta[index].code_set = dta
       .code_set, reply->dta[index].verson_number = dta.version_number,
       reply->dta[index].io_flag = dta.io_flag, reply->dta[index].template_script_cd = validate(dta
        .template_script_cd,0.0), active_dtas = (active_dtas+ 1)
       IF (mod(active_dtas,10)=1)
        stat = alterlist(flat_reply->dta,(active_dtas+ 9))
       ENDIF
       flat_reply->dta[active_dtas].task_assay_cd = dta.task_assay_cd, flat_reply->dta[active_dtas].
       dta_index = index
      FOOT REPORT
       stat = alterlist(flat_reply->dta,active_dtas)
      WITH nocounter
     ;end select
   ENDWHILE
 END ;Subroutine
 SUBROUTINE getreferencerange(null)
   SET expand_blocks = ceil(((active_dtas * 1.0)/ expand_size))
   SET total_items = (expand_blocks * expand_size)
   SET stat = alterlist(expand_record->qual,total_items)
   FOR (x = 1 TO total_items)
     IF (x > active_dtas)
      SET expand_record->qual[x].id = expand_record->qual[active_dtas].id
      SET expand_record->qual[x].index = - (1)
     ELSE
      SET expand_record->qual[x].id = flat_reply->dta[x].task_assay_cd
      SET expand_record->qual[x].index = x
     ENDIF
   ENDFOR
   SET expand_start = 0
   SET expand_stop = 0
   WHILE (expand_stop < active_dtas)
     SET expand_start = (expand_stop+ 1)
     SET expand_stop = (expand_stop+ expand_size)
     IF (expand_stop > active_dtas)
      SET expand_stop = active_dtas
     ENDIF
     SELECT INTO "nl:"
      FROM reference_range_factor rr
      WHERE expand(expand_cnt,expand_start,(expand_start+ (expand_size - 1)),rr.task_assay_cd,
       expand_record->qual[expand_cnt].id,
       expand_size)
       AND rr.active_ind=1
      ORDER BY rr.task_assay_cd
      HEAD REPORT
       index = 0, dta_index = 0, pos = 0
      HEAD rr.task_assay_cd
       pos = locateval(pos,expand_start,expand_stop,rr.task_assay_cd,expand_record->qual[pos].id),
       index = expand_record->qual[pos].index, dta_index = flat_reply->dta[index].dta_index,
       highest_tot_value = 0
      DETAIL
       tot_value = 0
       IF ((rr.species_cd=request->species_cd))
        tot_value = (tot_value+ species_value)
       ENDIF
       IF ((rr.sex_cd=request->sex_cd))
        tot_value = (tot_value+ sex_value)
       ENDIF
       IF ((rr.age_from_minutes <= request->age_in_min)
        AND (rr.age_to_minutes >= request->age_in_min))
        tot_value = (tot_value+ age_value)
       ENDIF
       IF ((rr.service_resource_cd=request->service_resource_cd))
        tot_value = (tot_value+ resource_ts_value)
       ENDIF
       IF (tot_value > highest_tot_value)
        highest_tot_value = tot_value, reply->dta[dta_index].reference_range_factor_id = rr
        .reference_range_factor_id, flat_reply->dta[pos].reference_range_factor_id = rr
        .reference_range_factor_id
        IF (abs(rr.default_result) > 0)
         reply->dta[dta_index].default_result_value = rr.default_result, reply->dta[dta_index].
         default_result = cnvtstring(rr.default_result), reply->dta[dta_index].def_result_ind = 1
        ELSE
         reply->dta[dta_index].def_result_ind = 0
        ENDIF
        reply->dta[dta_index].minutes_back = rr.mins_back, reply->dta[dta_index].review_ind = rr
        .review_ind, reply->dta[dta_index].review_low = rr.review_low,
        reply->dta[dta_index].review_high = rr.review_high, reply->dta[dta_index].sensitive_ind = rr
        .sensitive_ind, reply->dta[dta_index].sensitive_low = rr.sensitive_low,
        reply->dta[dta_index].sensitive_high = rr.sensitive_high, reply->dta[dta_index].normal_ind =
        rr.normal_ind, reply->dta[dta_index].normal_low = rr.normal_low,
        reply->dta[dta_index].normal_high = rr.normal_high, reply->dta[dta_index].critical_ind = rr
        .critical_ind, reply->dta[dta_index].critical_low = rr.critical_low,
        reply->dta[dta_index].critical_high = rr.critical_high, reply->dta[dta_index].feasible_ind =
        rr.feasible_ind, reply->dta[dta_index].feasible_low = rr.feasible_low,
        reply->dta[dta_index].feasible_high = rr.feasible_high, reply->dta[dta_index].units_cd = rr
        .units_cd, reply->dta[dta_index].code_set = rr.code_set
       ENDIF
      WITH nocounter
     ;end select
   ENDWHILE
 END ;Subroutine
 SUBROUTINE getequations(null)
   SET expand_blocks = ceil(((active_dtas * 1.0)/ expand_size))
   SET total_items = (expand_blocks * expand_size)
   SET stat = alterlist(expand_record->qual,total_items)
   FOR (x = 1 TO total_items)
     IF (x > active_dtas)
      SET expand_record->qual[x].id = expand_record->qual[active_dtas].id
      SET expand_record->qual[x].index = - (1)
     ELSE
      SET expand_record->qual[x].id = flat_reply->dta[x].task_assay_cd
      SET expand_record->qual[x].index = x
     ENDIF
   ENDFOR
   SET expand_start = 0
   SET expand_stop = 0
   WHILE (expand_stop < active_dtas)
     SET expand_start = (expand_stop+ 1)
     SET expand_stop = (expand_stop+ expand_size)
     IF (expand_stop > active_dtas)
      SET expand_stop = active_dtas
     ENDIF
     SELECT INTO "nl:"
      FROM equation e,
       equation_component ec,
       discrete_task_assay dta_ec
      PLAN (e
       WHERE expand(expand_cnt,expand_start,(expand_start+ (expand_size - 1)),e.task_assay_cd,
        expand_record->qual[expand_cnt].id,
        expand_size)
        AND e.active_ind=1)
       JOIN (ec
       WHERE ec.equation_id=e.equation_id)
       JOIN (dta_ec
       WHERE ec.included_assay_cd=dta_ec.task_assay_cd)
      ORDER BY e.task_assay_cd, e.equation_id
      HEAD REPORT
       dta_index = 0, index = 0, pos = 0,
       e_cnt = 0, load_components = "N"
      HEAD e.task_assay_cd
       pos = locateval(pos,expand_start,expand_stop,e.task_assay_cd,expand_record->qual[pos].id),
       index = expand_record->qual[pos].index, dta_index = flat_reply->dta[index].dta_index,
       highest_tot_value = 0
      HEAD e.equation_id
       e_cnt = 0, tot_value = 0
       IF ((e.species_cd=request->species_cd))
        tot_value = (tot_value+ species_value)
       ENDIF
       IF ((e.sex_cd=request->sex_cd))
        tot_value = (tot_value+ sex_value)
       ENDIF
       IF ((e.age_from_minutes <= request->age_in_min)
        AND (e.age_to_minutes >= request->age_in_min))
        tot_value = (tot_value+ age_value)
       ENDIF
       IF ((e.service_resource_cd=request->service_resource_cd))
        tot_value = (tot_value+ resource_ts_value)
       ENDIF
       IF (tot_value > highest_tot_value)
        highest_tot_value = tot_value, reply->dta[dta_index].equation_id = e.equation_id, reply->dta[
        dta_index].equation_description = e.equation_description,
        reply->dta[dta_index].equation_postfix = e.equation_postfix, reply->dta[dta_index].script = e
        .script, reply->dta[dta_index].e_comp_cnt = 0,
        load_components = "Y"
       ENDIF
      DETAIL
       IF (load_components="Y")
        e_cnt = (e_cnt+ 1), stat = alterlist(reply->dta[dta_index].e_comp,e_cnt), reply->dta[
        dta_index].e_comp[e_cnt].constant_value = ec.constant_value,
        reply->dta[dta_index].e_comp[e_cnt].default_value = ec.default_value, reply->dta[dta_index].
        e_comp[e_cnt].included_assay_cd = ec.included_assay_cd, reply->dta[dta_index].e_comp[e_cnt].
        name = ec.name,
        reply->dta[dta_index].e_comp[e_cnt].result_req_flag = ec.result_req_flag, reply->dta[
        dta_index].e_comp[e_cnt].units_cd = ec.units_cd, reply->dta[dta_index].e_comp[e_cnt].
        look_time_direction_flag = ec.look_time_direction_flag,
        reply->dta[dta_index].e_comp[e_cnt].time_window_minutes = ec.time_window_minutes, reply->dta[
        dta_index].e_comp[e_cnt].time_window_back_minutes = ec.time_window_back_minutes, reply->dta[
        dta_index].e_comp[e_cnt].event_cd = dta_ec.event_cd,
        reply->dta[dta_index].e_comp_cnt = e_cnt
       ENDIF
      FOOT  e.equation_id
       load_components = "N"
      WITH nocounter
     ;end select
   ENDWHILE
 END ;Subroutine
 SUBROUTINE getalpharesponses(null)
   SET expand_blocks = ceil(((active_dtas * 1.0)/ expand_size))
   SET total_items = (expand_blocks * expand_size)
   SET stat = alterlist(expand_record->qual,total_items)
   FOR (x = 1 TO total_items)
     IF (x > active_dtas)
      SET expand_record->qual[x].id = expand_record->qual[dta_cnt].id
      SET expand_record->qual[x].index = - (1)
     ELSE
      SET expand_record->qual[x].id = flat_reply->dta[x].reference_range_factor_id
      SET expand_record->qual[x].index = x
     ENDIF
   ENDFOR
   SET expand_start = 0
   SET expand_stop = 0
   WHILE (expand_stop < active_dtas)
     SET expand_start = (expand_stop+ 1)
     SET expand_stop = (expand_stop+ expand_size)
     IF (expand_stop > active_dtas)
      SET expand_stop = active_dtas
     ENDIF
     SELECT INTO "nl:"
      FROM alpha_responses ar,
       nomenclature n
      PLAN (ar
       WHERE expand(expand_cnt,expand_start,(expand_start+ (expand_size - 1)),ar
        .reference_range_factor_id,expand_record->qual[expand_cnt].id,
        expand_size)
        AND ar.active_ind=1)
       JOIN (n
       WHERE n.nomenclature_id=ar.nomenclature_id
        AND n.active_ind=1
        AND ((n.beg_effective_dt_tm=null) OR (n.beg_effective_dt_tm != null
        AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND ((n.end_effective_dt_tm=null) OR (n.end_effective_dt_tm != null
        AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))) )) )
      ORDER BY ar.reference_range_factor_id, ar.sequence, ar.nomenclature_id
      HEAD REPORT
       pos = 0, pos_detail = 0, pos_foot = 0,
       dta_index = 0, index = 0, a_cnt = 0
      HEAD ar.reference_range_factor_id
       pos = locateval(pos,expand_start,expand_stop,ar.reference_range_factor_id,expand_record->qual[
        pos].id), pos_detail = pos, pos_foot = pos,
       a_cnt = 0
      DETAIL
       IF (textlen(trim(n.source_string)) > 0)
        a_cnt = (a_cnt+ 1), pos = pos_detail
        WHILE (pos != 0)
          index = expand_record->qual[pos].index, dta_index = flat_reply->dta[index].dta_index
          IF (mod(a_cnt,5)=1)
           stat = alterlist(reply->dta[dta_index].alpha_responses,(a_cnt+ 4))
          ENDIF
          reply->dta[dta_index].alpha_responses_cnt = a_cnt, reply->dta[dta_index].alpha_responses[
          a_cnt].nomenclature_id = n.nomenclature_id, reply->dta[dta_index].alpha_responses[a_cnt].
          source_string = n.source_string,
          reply->dta[dta_index].alpha_responses[a_cnt].short_string = n.short_string, reply->dta[
          dta_index].alpha_responses[a_cnt].mnemonic = n.mnemonic, reply->dta[dta_index].
          alpha_responses[a_cnt].sequence = ar.sequence,
          reply->dta[dta_index].alpha_responses[a_cnt].default_ind = ar.default_ind, reply->dta[
          dta_index].alpha_responses[a_cnt].description = ar.description, reply->dta[dta_index].
          alpha_responses[a_cnt].result_value = ar.result_value,
          reply->dta[dta_index].alpha_responses[a_cnt].multi_alpha_sort_order = ar
          .multi_alpha_sort_order, reply->dta[dta_index].alpha_responses[a_cnt].concept_identifier =
          n.concept_identifier, pos = locateval(pos,(pos+ 1),expand_stop,ar.reference_range_factor_id,
           expand_record->qual[pos].id)
        ENDWHILE
       ENDIF
      FOOT  ar.reference_range_factor_id
       WHILE (pos_foot != 0)
         index = expand_record->qual[pos_foot].index, dta_index = flat_reply->dta[index].dta_index,
         stat = alterlist(reply->dta[dta_index].alpha_responses,a_cnt),
         pos_foot = locateval(pos_foot,(pos_foot+ 1),expand_stop,ar.reference_range_factor_id,
          expand_record->qual[pos_foot].id)
       ENDWHILE
      WITH nocounter
     ;end select
   ENDWHILE
 END ;Subroutine
 SUBROUTINE getdatamap(null)
   SET expand_blocks = ceil(((active_dtas * 1.0)/ expand_size))
   SET total_items = (expand_blocks * expand_size)
   SET stat = alterlist(expand_record->qual,total_items)
   FOR (x = 1 TO total_items)
     IF (x > active_dtas)
      SET expand_record->qual[x].id = expand_record->qual[active_dtas].id
      SET expand_record->qual[x].index = - (1)
     ELSE
      SET expand_record->qual[x].id = flat_reply->dta[x].task_assay_cd
      SET expand_record->qual[x].index = x
     ENDIF
   ENDFOR
   SET expand_start = 0
   SET expand_stop = 0
   WHILE (expand_stop < active_dtas)
     SET expand_start = (expand_stop+ 1)
     SET expand_stop = (expand_stop+ expand_size)
     IF (expand_stop > active_dtas)
      SET expand_stop = active_dtas
     ENDIF
     SELECT INTO "nl:"
      FROM data_map dm
      WHERE expand(expand_cnt,expand_start,(expand_start+ (expand_size - 1)),dm.task_assay_cd,
       expand_record->qual[expand_cnt].id)
       AND (dm.service_resource_cd=request->service_resource_cd)
       AND dm.active_ind=1
      HEAD REPORT
       index = 0, pos = 0, dta_index = 0
      HEAD dm.task_assay_cd
       pos = locateval(pos,expand_start,expand_stop,dm.task_assay_cd,expand_record->qual[pos].id),
       index = expand_record->qual[pos].index, dta_index = flat_reply->dta[index].dta_index
      DETAIL
       reply->dta[dta_index].data_map_type_flag = dm.data_map_type_flag, reply->dta[dta_index].
       result_entry_format = dm.result_entry_format, reply->dta[dta_index].max_digits = dm.max_digits,
       reply->dta[dta_index].min_digits = dm.min_digits, reply->dta[dta_index].min_decimal_places =
       dm.min_decimal_places
      WITH nocounter
     ;end select
   ENDWHILE
 END ;Subroutine
 SUBROUTINE getiototaldefinition(null)
   SET expand_blocks = ceil(((active_dtas * 1.0)/ expand_size))
   SET total_items = (expand_blocks * expand_size)
   SET stat = alterlist(expand_record->qual,total_items)
   FOR (x = 1 TO total_items)
     IF (x > active_dtas)
      SET expand_record->qual[x].id = expand_record->qual[dta_cnt].id
      SET expand_record->qual[x].index = - (1)
     ELSE
      SET expand_record->qual[x].id = flat_reply->dta[x].task_assay_cd
      SET expand_record->qual[x].index = x
     ENDIF
   ENDFOR
   SET expand_start = 0
   SET expand_stop = 0
   WHILE (expand_stop < active_dtas)
     SET expand_start = (expand_stop+ 1)
     SET expand_stop = (expand_stop+ expand_size)
     IF (expand_stop > active_dtas)
      SET expand_stop = active_dtas
     ENDIF
     SELECT INTO "nl:"
      FROM io_total_definition i
      WHERE expand(expand_cnt,expand_start,(expand_start+ (expand_size - 1)),i.task_assay_cd,
       expand_record->qual[expand_cnt].id,
       expand_size)
       AND i.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
      HEAD REPORT
       pos = 0
      DETAIL
       pos = locateval(pos,expand_start,expand_stop,i.task_assay_cd,expand_record->qual[pos].id),
       dta_index = expand_record->qual[pos].index, reply->dta[dta_index].io_total_definition_id = i
       .io_total_definition_id
      WITH nocounter
     ;end select
   ENDWHILE
 END ;Subroutine
END GO
