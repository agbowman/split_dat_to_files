CREATE PROGRAM dcp_del_clin_equation:dba
 RECORD internal(
   1 comp_ids[*]
     2 comp_id = f8
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET failed = "F"
 SET comp_cnt = 0
 SELECT INTO "nl:"
  d.dcp_equation_id
  FROM dcp_equa_component d
  WHERE (d.dcp_equation_id=request->dcp_equation_id)
  DETAIL
   comp_cnt = (comp_cnt+ 1)
   IF (comp_cnt > size(internal->comp_ids,5))
    stat = alterlist(internal->comp_ids,(comp_cnt+ 10))
   ENDIF
   internal->comp_ids[comp_cnt].comp_id = d.dcp_component_id
  WITH nocounter
 ;end select
 SET stat = alterlist(internal->comp_ids,comp_cnt)
 DELETE  FROM dcp_unit_measure d,
   (dummyt d1  WITH seq = value(comp_cnt))
  SET d.seq = 1
  PLAN (d1)
   JOIN (d
   WHERE (d.dcp_component_id=internal->comp_ids[d1.seq].comp_id)
    AND (d.dcp_equation_id=request->dcp_equation_id))
  WITH nocounter
 ;end delete
 DELETE  FROM dcp_equa_component d,
   (dummyt d1  WITH seq = value(comp_cnt))
  SET d.seq = 1
  PLAN (d1)
   JOIN (d
   WHERE (d.dcp_component_id=internal->comp_ids[d1.seq].comp_id))
  WITH nocounter
 ;end delete
 DELETE  FROM dcp_equa_position d
  WHERE (d.dcp_equation_id=request->dcp_equation_id)
  WITH nocounter
 ;end delete
 DELETE  FROM dcp_equation d
  WHERE (d.dcp_equation_id=request->dcp_equation_id)
  WITH nocounter
 ;end delete
#exit_script
 IF (failed="F")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
END GO
