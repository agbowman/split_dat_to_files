CREATE PROGRAM aps_get_prefix_reports:dba
 RECORD reply(
   1 report_qual[*]
     2 catalog_cd = f8
     2 catalog_disp = c40
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
  prr.catalog_cd
  FROM prefix_report_r prr
  PLAN (prr
   WHERE (prr.prefix_id=request->prefix_id))
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->report_qual,10)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1
    AND cnt != 1)
    stat = alterlist(reply->report_qual,(cnt+ 9))
   ENDIF
   reply->report_qual[cnt].catalog_cd = prr.catalog_cd
  FOOT REPORT
   stat = alterlist(reply->report_qual,cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PREFIX_REPORT_R"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
