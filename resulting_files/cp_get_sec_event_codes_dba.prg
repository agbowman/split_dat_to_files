CREATE PROGRAM cp_get_sec_event_codes:dba
 RECORD reply(
   1 qual[*]
     2 event_cd = f8
     2 chart_format_id = f8
     2 chart_section_id = f8
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
  FROM chart_form_sects cfs,
   chart_group cg,
   chart_grp_evnt_set cges,
   v500_event_set_code esc,
   v500_event_set_explode ese,
   (dummyt d  WITH seq = value(size(request->section_qual,5)))
  PLAN (d)
   JOIN (cfs
   WHERE (cfs.chart_section_id=request->section_qual[d.seq].section_id))
   JOIN (cg
   WHERE cg.chart_section_id=cfs.chart_section_id)
   JOIN (cges
   WHERE cges.chart_group_id=cg.chart_group_id)
   JOIN (esc
   WHERE esc.event_set_name=cges.event_set_name)
   JOIN (ese
   WHERE ese.event_set_cd=esc.event_set_cd)
  ORDER BY cfs.chart_format_id, cfs.chart_section_id
  HEAD REPORT
   count = 0
  DETAIL
   count = (count+ 1)
   IF (mod(count,10)=1)
    stat = alterlist(reply->qual,(count+ 9))
   ENDIF
   reply->qual[count].event_cd = ese.event_cd, reply->qual[count].chart_format_id = cfs
   .chart_format_id, reply->qual[count].chart_section_id = cfs.chart_section_id
  FOOT REPORT
   stat = alterlist(reply->qual,count)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
