CREATE PROGRAM dcp_get_plan_by_subphase
 SET modify = predeclare
 RECORD reply(
   1 planlist[*]
     2 plan_description = vc
     2 phase_description = vc
     2 type_mean = c12
     2 version = i4
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE replycnt = i4 WITH noconstant(0)
 DECLARE end_date_string = c20 WITH constant("31-DEC-2100 00:00:00")
 SET reply->status_data.status = "F"
 SELECT DISTINCT INTO "nl:"
  pc.pathway_catalog_id, pwc1.pathway_catalog_id, pcr.pw_cat_s_id,
  pwc2.pathway_catalog_id
  FROM pathway_comp pc,
   pathway_catalog pwc1,
   pw_cat_reltn pcr,
   pathway_catalog pwc2
  PLAN (pc
   WHERE (pc.parent_entity_id=request->pathway_catalog_id)
    AND pc.parent_entity_name="PATHWAY_CATALOG"
    AND pc.active_ind=1)
   JOIN (pwc1
   WHERE pwc1.pathway_catalog_id=pc.pathway_catalog_id
    AND pwc1.end_effective_dt_tm=cnvtdatetime(end_date_string)
    AND ((pwc1.type_mean="CAREPLAN") OR (pwc1.type_mean="PHASE"
    AND pwc1.active_ind=1)) )
   JOIN (pcr
   WHERE pcr.pw_cat_t_id=outerjoin(pwc1.pathway_catalog_id)
    AND pcr.type_mean=outerjoin("GROUP"))
   JOIN (pwc2
   WHERE pwc2.pathway_catalog_id=outerjoin(pcr.pw_cat_s_id)
    AND pwc2.pathway_catalog_id > outerjoin(0)
    AND pwc2.end_effective_dt_tm=outerjoin(cnvtdatetime(end_date_string)))
  ORDER BY pc.pathway_catalog_id, pwc1.pathway_catalog_id
  HEAD REPORT
   replycnt = 0
  HEAD pc.pathway_catalog_id
   IF (pwc1.type_mean="PHASE")
    IF ((((request->active_ind=1)
     AND pwc2.active_ind=1) OR ((request->active_ind=0))) )
     replycnt = (replycnt+ 1)
     IF (replycnt > size(reply->planlist,5))
      stat = alterlist(reply->planlist,(replycnt+ 10))
     ENDIF
     reply->planlist[replycnt].plan_description = pwc2.description, reply->planlist[replycnt].
     phase_description = pwc1.description, reply->planlist[replycnt].type_mean = pwc2.type_mean,
     reply->planlist[replycnt].version = pwc2.version, reply->planlist[replycnt].beg_effective_dt_tm
      = pwc2.beg_effective_dt_tm, reply->planlist[replycnt].end_effective_dt_tm = pwc2
     .end_effective_dt_tm,
     reply->planlist[replycnt].active_ind = pwc2.active_ind
    ENDIF
   ELSEIF (pwc1.type_mean="CAREPLAN")
    IF ((((request->active_ind=1)
     AND pwc1.active_ind=1) OR ((request->active_ind=0))) )
     replycnt = (replycnt+ 1)
     IF (replycnt > size(reply->planlist,5))
      stat = alterlist(reply->planlist,(replycnt+ 10))
     ENDIF
     reply->planlist[replycnt].plan_description = pwc1.description, reply->planlist[replycnt].
     type_mean = pwc1.type_mean, reply->planlist[replycnt].version = pwc1.version,
     reply->planlist[replycnt].beg_effective_dt_tm = pwc1.beg_effective_dt_tm, reply->planlist[
     replycnt].end_effective_dt_tm = pwc1.end_effective_dt_tm, reply->planlist[replycnt].active_ind
      = pwc1.active_ind
    ENDIF
   ENDIF
  FOOT REPORT
   IF (replycnt > 0)
    stat = alterlist(reply->planlist,replycnt)
   ENDIF
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
END GO
