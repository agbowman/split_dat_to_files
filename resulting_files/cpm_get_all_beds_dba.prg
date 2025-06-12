CREATE PROGRAM cpm_get_all_beds:dba
 RECORD reply(
   1 facility[*]
     2 location_cd = f8
     2 location_disp = c40
     2 unit_cnt = i4
     2 unit[*]
       3 location_cd = f8
       3 location_disp = c40
       3 room_cnt = i4
       3 room[*]
         4 location_cd = f8
         4 location_disp = c40
         4 bed_cnt = i4
         4 bed[*]
           5 location_cd = f8
           5 location_disp = c40
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
 SET count3 = 0
 SET count4 = 0
 SET code_value = 0.0
 SET code_set = 222
 SET cdf_meaning = "FACILITY"
 EXECUTE cpm_get_cd_for_cdf
 SELECT
  IF ((request->facility_cd != 0)
   AND (request->nurse_unit_cd=0))
   PLAN (l
    WHERE (l.location_cd=request->facility_cd)
     AND l.location_type_cd=code_value
     AND l.active_ind=1
     AND l.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND l.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (n
    WHERE l.location_cd=n.loc_facility_cd
     AND n.active_ind=1
     AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (r
    WHERE n.location_cd=r.loc_nurse_unit_cd
     AND r.active_ind=1
     AND r.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND r.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (b
    WHERE r.location_cd=b.loc_room_cd
     AND b.active_ind=1
     AND b.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND b.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ELSEIF ((request->facility_cd=0)
   AND (request->nurse_unit_cd != 0))
   PLAN (l
    WHERE l.location_cd > 0
     AND l.location_type_cd=code_value
     AND l.active_ind=1
     AND l.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND l.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (n
    WHERE l.location_cd=n.loc_facility_cd
     AND (n.location_cd=request->nurse_unit_cd)
     AND n.active_ind=1
     AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (r
    WHERE n.location_cd=r.loc_nurse_unit_cd
     AND r.active_ind=1
     AND r.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND r.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (b
    WHERE r.location_cd=b.loc_room_cd
     AND b.active_ind=1
     AND b.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND b.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ELSEIF ((request->facility_cd != 0)
   AND (request->nurse_unit_cd != 0))
   PLAN (l
    WHERE (l.location_cd=request->facility_cd)
     AND l.location_type_cd=code_value
     AND l.active_ind=1
     AND l.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND l.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (n
    WHERE l.location_cd=n.loc_facility_cd
     AND (n.location_cd=request->nurse_unit_cd)
     AND n.active_ind=1
     AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (r
    WHERE n.location_cd=r.loc_nurse_unit_cd
     AND r.active_ind=1
     AND r.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND r.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (b
    WHERE r.location_cd=b.loc_room_cd
     AND b.active_ind=1
     AND b.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND b.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ELSE
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
    JOIN (r
    WHERE n.location_cd=r.loc_nurse_unit_cd
     AND r.active_ind=1
     AND r.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND r.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (b
    WHERE r.location_cd=b.loc_room_cd
     AND b.active_ind=1
     AND b.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND b.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ENDIF
  INTO "nl:"
  l.location_cd, n.location_cd, r.location_cd,
  b.location_cd
  FROM location l,
   nurse_unit n,
   room r,
   bed b
  ORDER BY l.location_cd, n.location_cd, r.location_cd,
   b.location_cd
  HEAD REPORT
   count1 = 0
  HEAD l.location_cd
   count2 = 0, count1 = (count1+ 1), stat = alterlist(reply->facility,count1),
   reply->facility[count1].location_cd = l.location_cd
  HEAD n.location_cd
   count3 = 0, count2 = (count2+ 1), stat = alterlist(reply->facility.unit,count2),
   reply->facility[count1].unit[count2].location_cd = n.location_cd
  HEAD r.location_cd
   count4 = 0, count3 = (count3+ 1), stat = alterlist(reply->facility.unit.room,count3),
   reply->facility[count1].unit[count2].room[count3].location_cd = r.location_cd
  HEAD b.location_cd
   count4 = (count4+ 1), stat = alterlist(reply->facility.unit.room.bed,count4), reply->facility[
   count1].unit[count2].room[count3].bed[count4].location_cd = b.location_cd
  FOOT  b.location_cd
   x = 0
  FOOT  r.location_cd
   reply->facility[count1].unit[count2].room[count3].bed_cnt = count4
  FOOT  n.location_cd
   reply->facility[count1].unit[count2].room_cnt = count3
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
