CREATE PROGRAM ch_get_facility_children:dba
 RECORD reply(
   1 qual[*]
     2 child_loc_cd = f8
     2 child_loc_disp = c40
     2 child_loc_desc = c60
     2 child_loc_mean = c12
     2 collation_seq = i4
     2 child_ind = i2
     2 sequence = i4
     2 location_type_mean = c12
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
 SET code_set = 222
 SET code_value = 0.0
 SET cdf_meaning = trim(cnvtupper(request->cdf_meaning))
 EXECUTE cpm_get_cd_for_cdf
 SELECT INTO "nl:"
  lg1.child_loc_cd, c.code_value
  FROM location_group lg1,
   location_group lg2,
   code_value c,
   (dummyt d  WITH seq = 1)
  PLAN (lg1
   WHERE (lg1.parent_loc_cd=request->location_cd)
    AND lg1.location_group_type_cd=code_value
    AND lg1.active_ind=1
    AND lg1.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND lg1.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ((lg1.root_loc_cd+ 0)=0))
   JOIN (c
   WHERE c.code_value=lg1.child_loc_cd
    AND c.code_set=220
    AND c.active_ind=1
    AND c.cdf_meaning IN ("BUILDING", "AMBULATORY", "CLINIC", "NURSEUNIT", "ROOM",
   "WAITROOM", "CHECKOUT", "BED")
    AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (d
   WHERE d.seq=1)
   JOIN (lg2
   WHERE lg1.child_loc_cd=lg2.parent_loc_cd
    AND lg2.active_ind=1
    AND lg2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND lg2.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ((lg2.root_loc_cd+ 0)=0))
  ORDER BY lg1.child_loc_cd
  HEAD REPORT
   count1 = 0
  HEAD lg1.child_loc_cd
   count1 = (count1+ 1)
   IF (mod(count1,10)=1)
    stat = alterlist(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].child_loc_cd = lg1.child_loc_cd, reply->qual[count1].child_loc_desc = c
   .display, reply->qual[count1].child_loc_mean = c.cdf_meaning
  DETAIL
   IF (lg2.parent_loc_cd > 0)
    reply->qual[count1].child_ind = 1
   ENDIF
  WITH outerjoin = d, nocounter
 ;end select
 IF (count1 != 0)
  SET stat = alterlist(reply->qual,count1)
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
