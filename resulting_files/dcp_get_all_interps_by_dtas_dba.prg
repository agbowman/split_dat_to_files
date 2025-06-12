CREATE PROGRAM dcp_get_all_interps_by_dtas:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 dtas[*]
      2 task_assay_cd = f8
      2 interpretations[*]
        3 sex_cd = f8
        3 age_from_minutes = f8
        3 age_to_minutes = f8
        3 service_resource_cd = f8
        3 interp_state[*]
          4 state = f8
          4 input_assay_cd = f8
          4 numeric_low = f8
          4 numeric_high = f8
          4 nomenclature_id = f8
          4 resulting_state = f8
          4 result_nomenclature_id = f8
          4 result_value = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET dta_request_count = size(request->dtas,5)
 SET stat = 0
 SET d_count = 0
 SET i_count = 0
 SET s_count = 0
 SELECT INTO "nl:"
  i.dcp_interp_id, ist.dcp_interp_state_id
  FROM (dummyt d1  WITH seq = value(dta_request_count)),
   dcp_interp i,
   dcp_interp_state ist
  PLAN (d1)
   JOIN (i
   WHERE (i.task_assay_cd=request->dtas[d1.seq].task_assay_cd))
   JOIN (ist
   WHERE ist.dcp_interp_id=i.dcp_interp_id)
  HEAD REPORT
   d_count = 0
  HEAD i.task_assay_cd
   d_count += 1
   IF (d_count > size(reply->dtas,5))
    stat = alterlist(reply->dtas,(d_count+ 5))
   ENDIF
   reply->dtas[d_count].task_assay_cd = i.task_assay_cd, i_count = 0
  HEAD i.dcp_interp_id
   i_count += 1
   IF (i_count > size(reply->dtas[d_count].interpretations,5))
    stat = alterlist(reply->dtas[d_count].interpretations,(i_count+ 5))
   ENDIF
   reply->dtas[d_count].interpretations[i_count].sex_cd = i.sex_cd, reply->dtas[d_count].
   interpretations[i_count].age_from_minutes = i.age_from_minutes, reply->dtas[d_count].
   interpretations[i_count].age_to_minutes = i.age_to_minutes,
   reply->dtas[d_count].interpretations[i_count].service_resource_cd = i.service_resource_cd, s_cnt
    = 0
  DETAIL
   s_cnt += 1
   IF (s_cnt > size(reply->dtas[d_count].interpretations[i_count].interp_state,5))
    stat = alterlist(reply->dtas[d_count].interpretations[i_count].interp_state,(s_cnt+ 5))
   ENDIF
   reply->dtas[d_count].interpretations[i_count].interp_state[s_cnt].state = ist.state, reply->dtas[
   d_count].interpretations[i_count].interp_state[s_cnt].input_assay_cd = ist.input_assay_cd, reply->
   dtas[d_count].interpretations[i_count].interp_state[s_cnt].numeric_low = ist.numeric_low,
   reply->dtas[d_count].interpretations[i_count].interp_state[s_cnt].numeric_high = ist.numeric_high,
   reply->dtas[d_count].interpretations[i_count].interp_state[s_cnt].nomenclature_id = ist
   .nomenclature_id, reply->dtas[d_count].interpretations[i_count].interp_state[s_cnt].
   resulting_state = ist.resulting_state,
   reply->dtas[d_count].interpretations[i_count].interp_state[s_cnt].result_nomenclature_id = ist
   .result_nomenclature_id, reply->dtas[d_count].interpretations[i_count].interp_state[s_cnt].
   result_value = ist.result_value
  FOOT  i.dcp_interp_id
   stat = alterlist(reply->dtas[d_count].interpretations[i_count].interp_state,s_cnt)
  FOOT  i.task_assay_cd
   stat = alterlist(reply->dtas[d_count].interpretations,i_count)
  FOOT REPORT
   stat = alterlist(reply->dtas,d_count)
  WITH nocounter
 ;end select
 IF (d_count != dta_request_count)
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET reqinfo->commit_ind = 1
END GO
