CREATE PROGRAM camm_dms_get_filters
 RECORD reply(
   1 filters[*]
     2 filter_id = f8
     2 filter_display = vc
     2 filter_key = vc
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
  d.ref_group, d.display, d.active_ind,
  d.ref_key, d.dms_ref_id
  FROM dms_ref d
  WHERE d.active_ind=1
   AND cnvtupper(d.ref_group)="FILTER"
  HEAD REPORT
   filter_cnt = 0
  DETAIL
   filter_cnt = (filter_cnt+ 1)
   IF (mod(filter_cnt,10)=1)
    stat = alterlist(reply->filters,(filter_cnt+ 9))
   ENDIF
   reply->filters[filter_cnt].filter_display = d.display, reply->filters[filter_cnt].filter_key = d
   .ref_key, reply->filters[filter_cnt].filter_id = d.dms_ref_id
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
