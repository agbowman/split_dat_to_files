CREATE PROGRAM ce_ins_code_value:dba
 IF (validate(reply,"-999")="-999")
  FREE RECORD reply
  RECORD reply(
    1 num_inserted = i4
    1 error_code = f8
    1 error_msg = vc
  )
 ENDIF
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 DECLARE insertintocodevaluesnp(null) = null
 DECLARE insertintocodevalue(null) = null
 IF ((request->use_snapshot_tables_ind=1))
  CALL insertintocodevaluesnp(null)
 ELSE
  CALL insertintocodevalue(null)
 ENDIF
 SUBROUTINE insertintocodevalue(null)
   INSERT  FROM code_value t,
     (dummyt d  WITH seq = value(size(request->request_list,5)))
    SET t.code_value = request->request_list[d.seq].code_value, t.code_set = request->request_list[d
     .seq].code_set, t.cdf_meaning = trim(request->request_list[d.seq].cdf_meaning),
     t.display = trim(request->request_list[d.seq].display), t.display_key = trim(request->
      request_list[d.seq].display_key), t.description = trim(request->request_list[d.seq].description
      ),
     t.definition = trim(request->request_list[d.seq].definition), t.cki =
     IF ((request->request_list[d.seq].cki != "")) request->request_list[d.seq].cki
     ELSE null
     ENDIF
     , t.display_key_nls = request->request_list[d.seq].display_key_nls,
     t.collation_seq = request->request_list[d.seq].collation_seq, t.active_type_cd =
     IF ((request->request_list[d.seq].active_type_cd=- (1))) 0
     ELSE request->request_list[d.seq].active_type_cd
     ENDIF
     , t.active_ind = request->request_list[d.seq].active_ind,
     t.active_dt_tm = cnvtdatetimeutc(request->request_list[d.seq].active_dt_tm), t.inactive_dt_tm =
     cnvtdatetimeutc(request->request_list[d.seq].inactive_dt_tm), t.begin_effective_dt_tm =
     cnvtdatetimeutc(request->request_list[d.seq].begin_effective_dt_tm),
     t.end_effective_dt_tm = cnvtdatetimeutc(request->request_list[d.seq].end_effective_dt_tm), t
     .data_status_cd =
     IF ((request->request_list[d.seq].data_status_cd=- (1))) 0
     ELSE request->request_list[d.seq].data_status_cd
     ENDIF
     , t.data_status_dt_tm = cnvtdatetimeutc(request->request_list[d.seq].data_status_dt_tm),
     t.data_status_prsnl_id =
     IF ((request->request_list[d.seq].data_status_prsnl_id=- (1))) 0
     ELSE request->request_list[d.seq].data_status_prsnl_id
     ENDIF
     , t.active_status_prsnl_id =
     IF ((request->request_list[d.seq].active_status_prsnl_id=- (1))) 0
     ELSE request->request_list[d.seq].active_status_prsnl_id
     ENDIF
     , t.updt_dt_tm = cnvtdatetimeutc(request->request_list[d.seq].updt_dt_tm),
     t.updt_id = request->request_list[d.seq].updt_id, t.updt_cnt = request->request_list[d.seq].
     updt_cnt, t.updt_task = request->request_list[d.seq].updt_task,
     t.updt_applctx = request->request_list[d.seq].updt_applctx, t.concept_cki =
     IF ((request->request_list[d.seq].concept_cki != "")) request->request_list[d.seq].concept_cki
     ELSE null
     ENDIF
    PLAN (d)
     JOIN (t)
    WITH counter
   ;end insert
 END ;Subroutine
 SUBROUTINE insertintocodevaluesnp(null)
   INSERT  FROM kia_event_set_code_value_snp t,
     (dummyt d  WITH seq = value(size(request->request_list,5)))
    SET t.code_value = request->request_list[d.seq].code_value, t.code_set = request->request_list[d
     .seq].code_set, t.cdf_meaning = trim(request->request_list[d.seq].cdf_meaning),
     t.display = trim(request->request_list[d.seq].display), t.display_key = trim(request->
      request_list[d.seq].display_key), t.description = trim(request->request_list[d.seq].description
      ),
     t.definition = trim(request->request_list[d.seq].definition), t.cki =
     IF ((request->request_list[d.seq].cki != "")) request->request_list[d.seq].cki
     ELSE null
     ENDIF
     , t.display_key_nls = request->request_list[d.seq].display_key_nls,
     t.collation_seq = request->request_list[d.seq].collation_seq, t.active_type_cd =
     IF ((request->request_list[d.seq].active_type_cd=- (1))) 0
     ELSE request->request_list[d.seq].active_type_cd
     ENDIF
     , t.active_ind = request->request_list[d.seq].active_ind,
     t.active_dt_tm = cnvtdatetimeutc(request->request_list[d.seq].active_dt_tm), t.inactive_dt_tm =
     cnvtdatetimeutc(request->request_list[d.seq].inactive_dt_tm), t.begin_effective_dt_tm =
     cnvtdatetimeutc(request->request_list[d.seq].begin_effective_dt_tm),
     t.end_effective_dt_tm = cnvtdatetimeutc(request->request_list[d.seq].end_effective_dt_tm), t
     .data_status_cd =
     IF ((request->request_list[d.seq].data_status_cd=- (1))) 0
     ELSE request->request_list[d.seq].data_status_cd
     ENDIF
     , t.data_status_dt_tm = cnvtdatetimeutc(request->request_list[d.seq].data_status_dt_tm),
     t.data_status_prsnl_id =
     IF ((request->request_list[d.seq].data_status_prsnl_id=- (1))) 0
     ELSE request->request_list[d.seq].data_status_prsnl_id
     ENDIF
     , t.active_status_prsnl_id =
     IF ((request->request_list[d.seq].active_status_prsnl_id=- (1))) 0
     ELSE request->request_list[d.seq].active_status_prsnl_id
     ENDIF
     , t.updt_dt_tm = cnvtdatetimeutc(request->request_list[d.seq].updt_dt_tm),
     t.updt_id = request->request_list[d.seq].updt_id, t.updt_cnt = request->request_list[d.seq].
     updt_cnt, t.updt_task = request->request_list[d.seq].updt_task,
     t.updt_applctx = request->request_list[d.seq].updt_applctx, t.concept_cki =
     IF ((request->request_list[d.seq].concept_cki != "")) request->request_list[d.seq].concept_cki
     ELSE null
     ENDIF
    PLAN (d)
     JOIN (t)
    WITH counter
   ;end insert
 END ;Subroutine
 SET error_code = error(error_msg,0)
 SET reply->num_inserted = curqual
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
 SET stat = assign(validate(reqinfo->commit_ind),1)
END GO
