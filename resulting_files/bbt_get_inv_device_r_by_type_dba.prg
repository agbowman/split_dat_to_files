CREATE PROGRAM bbt_get_inv_device_r_by_type:dba
 RECORD reply(
   1 r_list[*]
     2 device_r_type_cd = f8
     2 device_r_type_disp = vc
     2 device_r_type_mean = c12
     2 device_r_cd = f8
     2 device_r_disp = vc
     2 devicelist[*]
       3 device_type_cd = f8
       3 device_type_disp = vc
       3 device_type_mean = c12
       3 bb_inv_device_id = f8
       3 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE num = i4
 SET reply->status_data.status = "F"
 SET r_cnt = 0
 SET device_cnt = 0
 SET inv_device_code_set = 17396
 SET device_type_code_set = 14203
 SET stat = alterlist(reply->r_list,10)
 SELECT INTO "nl:"
  cv.code_value
  FROM (dummyt d  WITH seq = value(size(request->typelist,5))),
   code_value cv
  PLAN (d)
   JOIN (cv
   WHERE cv.code_set=device_type_code_set
    AND (cv.cdf_meaning=request->typelist[d.seq].device_type_mean)
    AND cv.active_ind=1
    AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  DETAIL
   request->typelist[d.seq].device_type_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (trim(request->device_r_type_mean) > "")
  SET device_r_type_cd = get_code_value(inv_device_code_set,request->device_r_type_mean)
 ELSE
  SET device_r_type_cd = 0.0
 ENDIF
 IF (validate(request->locationlist)=0)
  CALL get_devices_all(null)
  GO TO exit_script
 ENDIF
 SET locationsize = size(request->locationlist,5)
 IF (locationsize=0)
  CALL get_devices_all(null)
 ELSE
  SELECT INTO "nl:"
   bid_r.device_r_cd, bid_r.device_r_type_cd, bid.bb_inv_device_id,
   bid.device_type_cd, bid.description, device_r_type = uar_get_code_display(bid_r.device_r_type_cd),
   device_r = uar_get_code_display(bid_r.device_r_cd), device_r_type = uar_get_code_display(bid_r
    .device_r_type_cd), device_type = uar_get_code_display(bid.device_type_cd)
   FROM (dummyt d  WITH seq = value(size(request->typelist,5))),
    bb_inv_device bid,
    (dummyt d1  WITH seq = 1),
    bb_inv_device_r bid_r
   PLAN (d
    WHERE d.seq <= size(request->typelist,5))
    JOIN (bid
    WHERE (bid.device_type_cd=request->typelist[d.seq].device_type_cd)
     AND bid.active_ind=1)
    JOIN (d1
    WHERE d1.seq=1)
    JOIN (bid_r
    WHERE expand(num,1,locationsize,bid_r.device_r_cd,request->locationlist[num].location_cd)
     AND bid_r.bb_inv_device_id=bid.bb_inv_device_id
     AND device_r_type_cd > 0.0
     AND bid_r.device_r_type_cd=device_r_type_cd
     AND bid_r.active_ind=1)
   ORDER BY bid_r.device_r_cd, bid.bb_inv_device_id
   HEAD REPORT
    r_cnt = 0
   HEAD bid_r.device_r_cd
    CALL addlocation(bid_r.device_r_cd,bid_r.device_r_type_cd)
   HEAD bid.bb_inv_device_id
    CALL adddevice(bid.bb_inv_device_id,bid.device_type_cd,bid_r.device_r_cd,bid.description)
   FOOT  bid_r.device_r_cd
    IF ((((request->want_all_devices_ind=1)) OR (bid_r.device_r_cd > 0.0)) )
     stat = alterlist(reply->r_list[r_cnt].devicelist,device_cnt)
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->r_list,r_cnt)
   WITH nocounter
  ;end select
  IF ((request->want_all_devices_ind=1))
   CALL get_device_with_no_associations(null)
   CALL get_all_devices_with_associations(null)
  ENDIF
  GO TO exit_script
 ENDIF
 DECLARE get_devices_all(null) = null
 SUBROUTINE get_devices_all(null)
   SELECT INTO "nl:"
    bid_r.device_r_cd, bid_r.device_r_type_cd, bid.bb_inv_device_id,
    bid.device_type_cd, bid.description, device_r_type = uar_get_code_display(bid_r.device_r_type_cd),
    device_r = uar_get_code_display(bid_r.device_r_cd), device_r_type = uar_get_code_display(bid_r
     .device_r_type_cd), device_type = uar_get_code_display(bid.device_type_cd)
    FROM (dummyt d  WITH seq = value(size(request->typelist,5))),
     bb_inv_device bid,
     (dummyt d1  WITH seq = 1),
     bb_inv_device_r bid_r
    PLAN (d
     WHERE d.seq <= size(request->typelist,5))
     JOIN (bid
     WHERE (bid.device_type_cd=request->typelist[d.seq].device_type_cd)
      AND bid.active_ind=1)
     JOIN (d1
     WHERE d1.seq=1)
     JOIN (bid_r
     WHERE bid_r.bb_inv_device_id=bid.bb_inv_device_id
      AND ((device_r_type_cd=0.0) OR (device_r_type_cd > 0.0
      AND bid_r.device_r_type_cd=device_r_type_cd
      AND bid_r.active_ind=1)) )
    ORDER BY bid_r.device_r_cd, bid.bb_inv_device_id
    HEAD REPORT
     r_cnt = 0
    HEAD bid_r.device_r_cd
     CALL addlocation(bid_r.device_r_cd,bid_r.device_r_type_cd)
    HEAD bid.bb_inv_device_id
     CALL adddevice(bid.bb_inv_device_id,bid.device_type_cd,bid_r.device_r_cd,bid.description)
    FOOT  bid_r.device_r_cd
     IF ((((request->want_all_devices_ind=1)) OR (bid_r.device_r_cd > 0.0)) )
      stat = alterlist(reply->r_list[r_cnt].devicelist,device_cnt)
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->r_list,r_cnt)
    WITH nocounter, outerjoin = d1
   ;end select
 END ;Subroutine
 DECLARE get_device_with_no_associations(null) = null
 SUBROUTINE get_device_with_no_associations(null)
   SELECT
    bid.bb_inv_device_id, bid.device_type_cd, bid.description
    FROM bb_inv_device bid
    PLAN (bid
     WHERE  NOT ( EXISTS (
     (SELECT
      bid_r.bb_inv_device_id
      FROM bb_inv_device_r bid_r
      WHERE bid.bb_inv_device_id=bid_r.bb_inv_device_id
       AND bid_r.active_ind=1)))
      AND bid.active_ind=1)
    ORDER BY bid.bb_inv_device_id
    HEAD REPORT
     r_cnt = (r_cnt+ 1), stat = alterlist(reply->r_list,r_cnt), device_cnt = 0,
     stat = alterlist(reply->r_list[r_cnt].devicelist,(device_cnt+ 4))
    HEAD bid.bb_inv_device_id
     CALL adddevice(bid.bb_inv_device_id,bid.device_type_cd,0.0,bid.description)
    FOOT REPORT
     stat = alterlist(reply->r_list[r_cnt].devicelist,device_cnt)
   ;end select
 END ;Subroutine
 DECLARE get_code_value(sub_code_set,sub_cdf_meaning) = f8
 SUBROUTINE get_code_value(sub_code_set,sub_cdf_meaning)
   SET gsub_code_value = 0.0
   SET stat = uar_get_meaning_by_codeset(sub_code_set,sub_cdf_meaning,1,gsub_code_value)
   RETURN(gsub_code_value)
 END ;Subroutine
#exit_script
 SET stat = alterlist(reply->r_list,r_cnt)
 IF (r_cnt != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 DECLARE addlocation(device_r_cd=f8(value),device_r_type_cd=f8(value)) = null
 SUBROUTINE addlocation(device_r_cd,device_r_type_cd)
   IF ((((request->want_all_devices_ind=1)) OR (device_r_cd > 0.0)) )
    SET r_cnt = (r_cnt+ 1)
    IF (mod(r_cnt,10)=0
     AND r_cnt != 1)
     SET stat = alterlist(reply->r_list,(r_cnt+ 9))
    ENDIF
    SET reply->r_list[r_cnt].device_r_cd = device_r_cd
    SET reply->r_list[r_cnt].device_r_type_cd = device_r_type_cd
    SET device_cnt = 0
    SET stat = alterlist(reply->r_list[r_cnt].devicelist,5)
   ENDIF
 END ;Subroutine
 DECLARE addddevice(bb_inv_device_id=f8(value),device_type_cd=f8(value),device_r_cd=f8(value),
  description=vc(value)) = null
 SUBROUTINE adddevice(bb_inv_device_id,device_type_cd,device_r_cd,description)
   IF ((((request->want_all_devices_ind=1)) OR (device_r_cd > 0.0)) )
    SET device_cnt = (device_cnt+ 1)
    IF (mod(device_cnt,5)=0
     AND device_cnt != 1)
     SET stat = alterlist(reply->r_list[r_cnt].devicelist,(device_cnt+ 4))
    ENDIF
    SET reply->r_list[r_cnt].devicelist[device_cnt].bb_inv_device_id = bb_inv_device_id
    SET reply->r_list[r_cnt].devicelist[device_cnt].device_type_cd = device_type_cd
    SET reply->r_list[r_cnt].devicelist[device_cnt].description = description
   ENDIF
 END ;Subroutine
 DECLARE get_all_devices_with_associations(null) = null
 SUBROUTINE get_all_devices_with_associations(null)
   SELECT INTO "nl:"
    bid_r.device_r_cd, bid_r.device_r_type_cd, bid.bb_inv_device_id,
    bid.device_type_cd, bid.description, device_r_type = uar_get_code_display(bid_r.device_r_type_cd),
    device_r = uar_get_code_display(bid_r.device_r_cd), device_r_type = uar_get_code_display(bid_r
     .device_r_type_cd), device_type = uar_get_code_display(bid.device_type_cd)
    FROM (dummyt d  WITH seq = value(size(request->typelist,5))),
     bb_inv_device bid,
     (dummyt d1  WITH seq = 1),
     bb_inv_device_r bid_r
    PLAN (d
     WHERE d.seq <= size(request->typelist,5))
     JOIN (bid
     WHERE (bid.device_type_cd=request->typelist[d.seq].device_type_cd)
      AND bid.active_ind=1)
     JOIN (d1
     WHERE d1.seq=1)
     JOIN (bid_r
     WHERE bid_r.bb_inv_device_id=bid.bb_inv_device_id
      AND bid_r.active_ind=1)
    ORDER BY bid.bb_inv_device_id
    HEAD REPORT
     r_cnt = (r_cnt+ 1), stat = alterlist(reply->r_list,r_cnt), device_cnt = 0,
     reply->r_list[r_cnt].device_r_cd = - (1), stat = alterlist(reply->r_list[r_cnt].devicelist,(
      device_cnt+ 4))
    HEAD bid.bb_inv_device_id
     CALL adddevice(bid.bb_inv_device_id,bid.device_type_cd,bid_r.device_r_cd,bid.description)
    FOOT REPORT
     stat = alterlist(reply->r_list,r_cnt)
    WITH counter, maxqual(bid_r,1)
   ;end select
 END ;Subroutine
END GO
