CREATE PROGRAM cp_get_assays_for_catalog:dba
 RECORD reply(
   1 rb_list[*]
     2 task_assay_cd = f8
     2 task_assay_disp = c40
     2 sequence = i4
     2 event_cd = f8
     2 suppressed = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM profile_task_r p,
   code_value_event_r cver,
   chart_grp_evnt_suppress cges
  PLAN (p
   WHERE (p.catalog_cd=request->catalog_cd)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (cver
   WHERE cver.parent_cd=p.task_assay_cd)
   JOIN (cges
   WHERE cges.chart_group_id=outerjoin(request->chart_group_id)
    AND cges.order_catalog_cd=outerjoin(request->catalog_cd)
    AND cges.task_assay_cd=outerjoin(p.task_assay_cd))
  ORDER BY p.sequence
  HEAD REPORT
   count = 0
  DETAIL
   count = (count+ 1)
   IF (mod(count,10)=1)
    stat = alterlist(reply->rb_list,(count+ 9))
   ENDIF
   reply->rb_list[count].task_assay_cd = p.task_assay_cd, reply->rb_list[count].task_assay_disp =
   uar_get_code_display(p.task_assay_cd), reply->rb_list[count].sequence = p.sequence,
   reply->rb_list[count].event_cd = cver.event_cd
   IF (cges.task_assay_cd > 0)
    reply->rb_list[count].suppressed = 1
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->rb_list,count)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
