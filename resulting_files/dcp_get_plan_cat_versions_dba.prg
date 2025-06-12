CREATE PROGRAM dcp_get_plan_cat_versions:dba
 SET modify = predeclare
 RECORD reply(
   1 qual[*]
     2 description = vc
     2 version = i4
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 pathway_catalog_id = f8
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE replycnt = i4 WITH noconstant(0)
 SET reply->status_data.status = "F"
 SELECT
  *
  FROM pathway_catalog pwc1,
   pathway_catalog pwc2
  PLAN (pwc1
   WHERE (pwc1.pathway_catalog_id=request->pathway_catalog_id))
   JOIN (pwc2
   WHERE pwc1.version_pw_cat_id=pwc2.version_pw_cat_id)
  ORDER BY pwc2.version DESC
  HEAD REPORT
   replycnt = 0
  DETAIL
   replycnt = (replycnt+ 1)
   IF (replycnt > size(reply->qual,5))
    stat = alterlist(reply->qual,(replycnt+ 10))
   ENDIF
   reply->qual[replycnt].description = pwc2.description, reply->qual[replycnt].version = pwc2.version,
   reply->qual[replycnt].beg_effective_dt_tm = pwc2.beg_effective_dt_tm,
   reply->qual[replycnt].end_effective_dt_tm = pwc2.end_effective_dt_tm, reply->qual[replycnt].
   active_ind = pwc2.active_ind, reply->qual[replycnt].pathway_catalog_id = pwc2.pathway_catalog_id,
   reply->qual[replycnt].updt_cnt = pwc2.updt_cnt
  FOOT REPORT
   stat = alterlist(reply->qual,replycnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
