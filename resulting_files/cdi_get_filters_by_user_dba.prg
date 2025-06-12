CREATE PROGRAM cdi_get_filters_by_user:dba
 RECORD reply(
   1 filters[*]
     2 cdi_user_filter_id = f8
     2 filter_name = vc
     2 begin_dt_tm = dq8
     2 end_dt_tm = dq8
     2 document_count = i4
     2 date_range = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE filter_cnt = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  f.cdi_user_filter_id, f.filter_name, f.begin_dt_tm,
  f.end_dt_tm, f.document_count, f.date_range
  FROM cdi_user_filter f
  WHERE (f.person_id=request->person_id)
  HEAD REPORT
   filter_cnt = 0
  DETAIL
   filter_cnt = (filter_cnt+ 1)
   IF (mod(filter_cnt,10)=1)
    stat = alterlist(reply->filters,(filter_cnt+ 9))
   ENDIF
   reply->filters[filter_cnt].cdi_user_filter_id = f.cdi_user_filter_id, reply->filters[filter_cnt].
   filter_name = f.filter_name, reply->filters[filter_cnt].begin_dt_tm = f.begin_dt_tm,
   reply->filters[filter_cnt].end_dt_tm = f.end_dt_tm, reply->filters[filter_cnt].document_count = f
   .document_count, reply->filters[filter_cnt].date_range = f.date_range_months
  FOOT REPORT
   stat = alterlist(reply->filters,filter_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
