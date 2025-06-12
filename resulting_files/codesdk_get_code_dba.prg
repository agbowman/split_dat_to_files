CREATE PROGRAM codesdk_get_code:dba
 RECORD reply(
   1 code_value = f8
   1 cdf_meaning = c12
   1 code_set = i4
   1 description = vc
   1 display = c40
   1 definition = vc
   1 collation_seq = i4
   1 cki = vc
   1 concept_cki = vc
   1 data_status_cd = f8
   1 data_status_disp = vc
   1 data_status_desc = vc
   1 data_status_mean = vc
   1 active_ind = i2
   1 begin_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "Z"
 IF ((request->by_value.value > 0.0))
  SELECT INTO "nl:"
   FROM code_value c
   WHERE (c.code_value=request->by_value.value)
   DETAIL
    reply->code_value = c.code_value, reply->cdf_meaning = c.cdf_meaning, reply->code_set = c
    .code_set,
    reply->description = c.description, reply->display = c.display, reply->definition = c.definition,
    reply->collation_seq = c.collation_seq, reply->cki = c.cki, reply->concept_cki = c.concept_cki,
    reply->data_status_cd = c.data_status_cd, reply->active_ind = c.active_ind, reply->
    begin_effective_dt_tm = c.begin_effective_dt_tm,
    reply->end_effective_dt_tm = c.end_effective_dt_tm
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ELSEIF ((request->by_cki.cki != ""))
  SELECT INTO "nl:"
   FROM code_value c
   WHERE (c.cki=request->by_cki.cki)
   ORDER BY c.active_ind DESC, c.collation_seq, c.code_value
   HEAD c.cki
    reply->code_value = c.code_value, reply->cdf_meaning = c.cdf_meaning, reply->code_set = c
    .code_set,
    reply->description = c.description, reply->display = c.display, reply->definition = c.definition,
    reply->collation_seq = c.collation_seq, reply->cki = c.cki, reply->concept_cki = c.concept_cki,
    reply->data_status_cd = c.data_status_cd, reply->active_ind = c.active_ind, reply->
    begin_effective_dt_tm = c.begin_effective_dt_tm,
    reply->end_effective_dt_tm = c.end_effective_dt_tm
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
END GO
