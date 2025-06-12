CREATE PROGRAM dcp_get_dcp_interp:dba
 RECORD reply(
   1 dcp_interp_id = f8
   1 task_assay_cd = f8
   1 sex_cd = f8
   1 age_from_minutes = f8
   1 age_to_minutes = f8
   1 service_resource_cd = f8
   1 interp_comp[*]
     2 dcp_interp_component_id = f8
     2 component_assay_cd = f8
     2 component_sequence = i4
     2 description = vc
     2 flags = i4
   1 interp_state[*]
     2 dcp_interp_state_id = f8
     2 state = f8
     2 input_assay_cd = f8
     2 flags = i4
     2 numeric_low = f8
     2 numeric_high = f8
     2 nomenclature_id = f8
     2 resulting_state = f8
     2 result_nomenclature_id = f8
     2 result_value = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET comp_cnt = 0
 SET state_cnt = 0
 SET stat = 0
 SELECT INTO "nl:"
  i.dcp_interp_id, ic.dcp_interp_component_id, ist.dcp_interp_state_id,
  check = decode(ist.seq,"ist",ic.seq,"ic",i.seq,
   "i","z")
  FROM dcp_interp i,
   (dummyt d1  WITH seq = 1),
   dcp_interp_component ic,
   (dummyt d2  WITH seq = 1),
   dcp_interp_state ist
  PLAN (i
   WHERE (i.dcp_interp_id=request->dcp_interp_id))
   JOIN (d1)
   JOIN (((ic
   WHERE ic.dcp_interp_id=i.dcp_interp_id)
   ) ORJOIN ((d2)
   JOIN (ist
   WHERE ist.dcp_interp_id=i.dcp_interp_id)
   ))
  ORDER BY ic.component_sequence
  HEAD i.dcp_interp_id
   comp_cnt = 0, state_cnt = 0, reply->dcp_interp_id = i.dcp_interp_id,
   reply->task_assay_cd = i.task_assay_cd, reply->sex_cd = i.sex_cd, reply->age_from_minutes = i
   .age_from_minutes,
   reply->age_to_minutes = i.age_to_minutes, reply->service_resource_cd = i.service_resource_cd
  DETAIL
   CASE (check)
    OF "ist":
     state_cnt = (state_cnt+ 1),
     IF (state_cnt > size(reply->interp_state,5))
      stat = alterlist(reply->interp_state,(state_cnt+ 5))
     ENDIF
     ,reply->interp_state[state_cnt].dcp_interp_state_id = ist.dcp_interp_state_id,reply->
     interp_state[state_cnt].input_assay_cd = ist.input_assay_cd,reply->interp_state[state_cnt].state
      = ist.state,
     reply->interp_state[state_cnt].nomenclature_id = ist.nomenclature_id,reply->interp_state[
     state_cnt].flags = ist.flags,reply->interp_state[state_cnt].numeric_low = ist.numeric_low,
     reply->interp_state[state_cnt].numeric_high = ist.numeric_high,reply->interp_state[state_cnt].
     resulting_state = ist.resulting_state,reply->interp_state[state_cnt].result_nomenclature_id =
     ist.result_nomenclature_id,
     reply->interp_state[state_cnt].result_value = ist.result_value,
     CALL echo(build("comp_id:",ist.dcp_interp_state_id))
    OF "ic":
     comp_cnt = (comp_cnt+ 1),
     IF (comp_cnt > size(reply->interp_comp,5))
      stat = alterlist(reply->interp_comp,(comp_cnt+ 5))
     ENDIF
     ,reply->interp_comp[comp_cnt].dcp_interp_component_id = ic.dcp_interp_component_id,reply->
     interp_comp[comp_cnt].component_assay_cd = ic.component_assay_cd,reply->interp_comp[comp_cnt].
     component_sequence = ic.component_sequence,
     reply->interp_comp[comp_cnt].description = ic.description,reply->interp_comp[comp_cnt].flags =
     ic.flags,
     CALL echo(build("comp_assay:",ic.dcp_interp_component_id))
    OF "z":
     CALL echo(" cannot find which category it belongs too")
   ENDCASE
  FOOT  i.dcp_interp_id
   stat = alterlist(reply->interp_state,state_cnt), stat = alterlist(reply->interp_comp,comp_cnt)
  WITH nocounter, outerjoin = d1, dontcare = ic,
   outerjoin = d2, dontcare = ist
 ;end select
 IF ((reply->dcp_interp_id=0))
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET reqinfo->commit_ind = 1
END GO
