CREATE PROGRAM ch_get_chart_format:dba
 RECORD reply(
   1 qual[10]
     2 chart_format_desc = vc
     2 chart_format_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT INTO "nl:"
  cf.chart_format_id
  FROM chart_format cf
  WHERE cf.chart_format_id > 0
   AND cf.active_ind=1
  ORDER BY cnvtupper(cf.chart_format_desc)
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (count1 != 1
    AND mod(count1,10)=1)
    stat = alter(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].chart_format_desc = cf.chart_format_desc, reply->qual[count1].chart_format_id
    = cf.chart_format_id
  WITH nocounter
 ;end select
 SET stat = alter(reply->qual,count1)
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
