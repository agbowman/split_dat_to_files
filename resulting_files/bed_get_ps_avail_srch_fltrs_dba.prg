CREATE PROGRAM bed_get_ps_avail_srch_fltrs:dba
 FREE SET reply
 RECORD reply(
   1 filters[*]
     2 name = vc
     2 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET fcnt = 0
 SELECT INTO "nl:"
  FROM br_person_search_settings b
  PLAN (b
   WHERE b.setting_mean="SEARCH_FILTERS")
  ORDER BY b.display
  DETAIL
   fcnt = (fcnt+ 1), stat = alterlist(reply->filters,fcnt), reply->filters[fcnt].display = b.display,
   reply->filters[fcnt].name = b.description
  WITH nocounter
 ;end select
 CALL echorecord(reply)
#exit_script
 IF (fcnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
