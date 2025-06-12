CREATE PROGRAM aa_get_prsnl_for_servres:dba
 RECORD reply(
   1 section_ind = i2
   1 parent_cd = f8
   1 prsnl_list[*]
     2 prsnl_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE department_cd = f8
 SET reply->status = "F"
 CALL uar_get_meaning_by_codeset(223,nullterm("DEPARTMENT"),1,department_cd)
 SELECT INTO "nl:"
  FROM resource_group rg,
   service_resource sr
  PLAN (rg
   WHERE (rg.child_service_resource_cd=request->service_resource_cd)
    AND rg.root_service_resource_cd=0
    AND rg.active_ind=1
    AND rg.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND rg.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (sr
   WHERE sr.service_resource_cd=rg.parent_service_resource_cd
    AND sr.active_ind=1
    AND sr.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND sr.end_effective_dt_tm >= cnvtdatetime(sysdate))
  DETAIL
   IF (sr.service_resource_type_cd=department_cd)
    reply->section_ind = 1
   ELSE
    reply->section_ind = 0
   ENDIF
   reply->parent_cd = rg.parent_service_resource_cd
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM prsnl_service_resource_reltn psr
  WHERE (psr.service_resource_cd=request->service_resource_cd)
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 += 1
   IF (mod(count1,10)=1)
    stat = alterlist(reply->prsnl_list,(count1+ 9))
   ENDIF
   reply->prsnl_list[count1].prsnl_id = psr.prsnl_id
  FOOT REPORT
   stat = alterlist(reply->prsnl_list,count1)
  WITH nocounter
 ;end select
 SET reply->status = "S"
 CALL echorecord(reply)
END GO
