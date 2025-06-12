CREATE PROGRAM aps_get_institutions:dba
 RECORD reply(
   1 qual[*]
     2 resource_cd = f8
     2 institution_cd = f8
     2 institution_disp = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET resource_idx = 0
 SET code_set = 0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET find_parent_resource_cnt = 0
 SET institution_group_type_cd = 0.0
 SET institution_cnt = 0
 SET resource_cnt = size(request->qual,5)
 FOR (resource_idx = 1 TO resource_cnt)
  SET request->qual[resource_idx].find_parent_resource_cd = request->qual[resource_idx].resource_cd
  SET find_parent_resource_cnt = (find_parent_resource_cnt+ 1)
 ENDFOR
 SET code_set = 223
 SET cdf_meaning = "INSTITUTION"
 EXECUTE cpm_get_cd_for_cdf
 SET institution_group_type_cd = code_value
 WHILE (find_parent_resource_cnt > 0)
   SELECT INTO "nl:"
    rg.parent_service_resource_cd
    FROM resource_group rg,
     (dummyt d  WITH seq = value(resource_cnt))
    PLAN (d)
     JOIN (rg
     WHERE (rg.child_service_resource_cd=request->qual[d.seq].find_parent_resource_cd)
      AND rg.child_service_resource_cd > 0
      AND rg.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND rg.root_service_resource_cd=0
      AND rg.active_ind=1)
    HEAD REPORT
     find_parent_resource_cnt = 0
    HEAD d.seq
     request->qual[d.seq].find_parent_resource_cd = 0.0
    DETAIL
     IF (rg.resource_group_type_cd=institution_group_type_cd)
      institution_cnt = (institution_cnt+ 1), stat = alterlist(reply->qual,institution_cnt), reply->
      qual[institution_cnt].resource_cd = request->qual[d.seq].resource_cd,
      reply->qual[institution_cnt].institution_cd = rg.parent_service_resource_cd
     ELSEIF (rg.parent_service_resource_cd != 0.0)
      find_parent_resource_cnt = (find_parent_resource_cnt+ 1), request->qual[d.seq].
      find_parent_resource_cd = rg.parent_service_resource_cd
     ENDIF
    WITH nocounter, nullreport
   ;end select
 ENDWHILE
 IF (institution_cnt=resource_cnt)
  SET reply->status_data.status = "S"
 ELSEIF (institution_cnt > 0)
  SET reply->status_data.status = "P"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
