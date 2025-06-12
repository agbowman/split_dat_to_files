CREATE PROGRAM cpm_get_all_units:dba
 RECORD reply(
   1 facility[*]
     2 location_cd = f8
     2 location_disp = c40
     2 unit_cnt = i4
     2 unit[*]
       3 location_cd = f8
       3 location_disp = c40
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
 SET count2 = 0
 SET code_set = 222
 SET code_value = 0.0
 SET cdf_meaning = "FACILITY"
 SELECT INTO "nl:"
  l.location_cd
  FROM location l,
   nurse_unit n
  PLAN (l
   WHERE l.location_type_cd=code_value
    AND l.active_ind=1
    AND l.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND l.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (n
   WHERE l.location_cd=n.loc_facility_cd
    AND n.active_ind=1
    AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY l.location_cd, n.location_cd
  HEAD REPORT
   count1 = 0
  HEAD l.location_cd
   count2 = 0, count1 = (count1+ 1), stat = alterlist(reply->facility,count1),
   reply->facility[count1].location_cd = l.location_cd
  DETAIL
   count2 = (count2+ 1), stat = alterlist(reply->facility.unit,count2), reply->facility[count1].unit[
   count2].location_cd = n.location_cd
  FOOT  l.location_cd
   reply->facility[count1].unit_cnt = count2
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
