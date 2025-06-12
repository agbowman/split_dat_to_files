CREATE PROGRAM drc_get_flex
 RECORD reply(
   1 facility_qual[*]
     2 facility_display = vc
     2 facility_cd = f8
     2 dose_range_check_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE failed = c1 WITH public, noconstant("F")
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  disp = uar_get_code_display(dfr.facility_cd)
  FROM drc_facility_r dfr
  WHERE (dfr.drc_group_id=request->drc_group_id)
   AND dfr.active_ind=1
  ORDER BY disp
  HEAD REPORT
   facility_cnt = 0
  DETAIL
   facility_cnt = (facility_cnt+ 1)
   IF (mod(facility_cnt,10)=1)
    stat = alterlist(reply->facility_qual,(facility_cnt+ 9))
   ENDIF
   IF (dfr.facility_cd=0)
    reply->facility_qual[facility_cnt].facility_display = "Default", reply->facility_qual[
    facility_cnt].facility_cd = 0
   ELSE
    reply->facility_qual[facility_cnt].facility_display = uar_get_code_display(dfr.facility_cd),
    reply->facility_qual[facility_cnt].facility_cd = dfr.facility_cd
   ENDIF
   reply->facility_qual[facility_cnt].dose_range_check_id = dfr.dose_range_check_id
  FOOT REPORT
   stat = alterlist(reply->facility_qual,facility_cnt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET failed = "T"
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
