CREATE PROGRAM cpm_get_loc_list_for_parent:dba
 RECORD reply(
   1 qual[1]
     2 location_cd = f8
     2 location_disp = c40
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
 CASE (cnvtupper(request->location_type_mean))
  OF "FACILITY":
   SELECT INTO "nl:"
    c.code_value
    FROM code_value c
    WHERE c.code_set=220
     AND c.cdf_meaning="FACILITY"
     AND c.active_ind=1
    HEAD REPORT
     count1 = 0
    DETAIL
     count1 = (count1+ 1)
     IF (mod(count1,10)=2)
      stat = alter(reply->qual,(count1+ 9))
     ENDIF
     reply->qual[count1].location_cd = c.code_value
    WITH nocounter
   ;end select
  OF "BUILDING":
   SELECT INTO "nl:"
    c.code_value
    FROM code_value c
    WHERE c.code_set=220
     AND c.cdf_meaning="BUILDING"
     AND c.active_ind=1
    HEAD REPORT
     count1 = 0
    DETAIL
     count1 = (count1+ 1)
     IF (mod(count1,10)=2)
      stat = alter(reply->qual,(count1+ 9))
     ENDIF
     reply->qual[count1].location_cd = c.code_value
    WITH nocounter
   ;end select
  OF "NURSEUNIT":
   SELECT INTO "nl:"
    n.location_cd
    FROM nurse_unit n
    WHERE (n.loc_facility_cd=request->location_cd)
     AND n.active_ind=1
     AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    HEAD REPORT
     count1 = 0
    DETAIL
     count1 = (count1+ 1)
     IF (mod(count1,10)=2)
      stat = alter(reply->qual,(count1+ 9))
     ENDIF
     reply->qual[count1].location_cd = n.location_cd
    WITH nocounter
   ;end select
  OF "ROOM":
   SELECT INTO "nl:"
    r.location_cd
    FROM room r
    WHERE (r.loc_nurse_unit_cd=request->location_cd)
     AND r.active_ind=1
     AND r.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND r.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    HEAD REPORT
     count1 = 0
    DETAIL
     count1 = (count1+ 1)
     IF (mod(count1,10)=2)
      stat = alter(reply->qual,(count1+ 9))
     ENDIF
     reply->qual[count1].location_cd = r.location_cd
    WITH nocounter
   ;end select
  OF "BED":
   SELECT INTO "nl:"
    b.location_cd
    FROM bed b
    WHERE (b.loc_room_cd=request->location_cd)
     AND b.active_ind=1
     AND b.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND b.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    HEAD REPORT
     count1 = 0
    DETAIL
     count1 = (count1+ 1)
     IF (mod(count1,10)=2)
      stat = alter(reply->qual,(count1+ 9))
     ENDIF
     reply->qual[count1].location_cd = b.location_cd
    WITH nocounter
   ;end select
 ENDCASE
 SET stat = alter(reply->qual,count1)
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
