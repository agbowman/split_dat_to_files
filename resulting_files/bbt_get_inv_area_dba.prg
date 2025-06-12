CREATE PROGRAM bbt_get_inv_area:dba
 RECORD reply(
   1 ownerlist[*]
     2 location_cd = f8
     2 location_disp = c40
     2 location_desc = vc
     2 location_mean = c12
     2 invlist[*]
       3 location_cd = f8
       3 location_disp = c40
       3 location_desc = vc
       3 location_mean = c12
       3 devicelist[*]
         4 device_id = f8
         4 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET location_type_code_set = 222
 SET bb_inv_device_code_set = 17396
 SET inv_area_device_type_mean = "BBINVAREA"
 SET count1 = 0
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET location_group_type_cd = 0.0
 SET inv_area_device_type_cd = 0.0
 SET own_cnt = 0
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(location_type_code_set,request->location_group_type_mean,
  code_cnt,location_group_type_cd)
 SET stat = uar_get_meaning_by_codeset(bb_inv_device_code_set,inv_area_device_type_mean,code_cnt,
  inv_area_device_type_cd)
 SELECT INTO "nl:"
  lg.location_group_type_cd, lg.parent_loc_cd, lg.child_loc_cd,
  cv.cdf_meaning, bid.location_cd, bid.bb_inv_device_id,
  bid.description
  FROM location_group lg,
   code_value cv,
   (dummyt d_bid  WITH seq = 1),
   bb_inv_device_r bid_r,
   bb_inv_device bid
  PLAN (lg
   WHERE lg.location_group_type_cd=location_group_type_cd
    AND (((request->parent_loc_cd=0.0)) OR ((request->parent_loc_cd > 0.0)
    AND (lg.parent_loc_cd=request->parent_loc_cd)))
    AND lg.active_ind=1
    AND (lg.active_status_cd=reqdata->active_status_cd)
    AND lg.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND lg.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (cv
   WHERE cv.code_value=lg.child_loc_cd
    AND (cv.cdf_meaning=request->child_loc_mean)
    AND cv.active_ind=1
    AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (d_bid
   WHERE d_bid.seq=1)
   JOIN (bid_r
   WHERE bid_r.device_r_cd=lg.child_loc_cd
    AND bid_r.device_r_type_cd=inv_area_device_type_cd
    AND bid_r.active_ind=1)
   JOIN (bid
   WHERE bid.bb_inv_device_id=bid_r.bb_inv_device_id
    AND bid.active_ind=1)
  ORDER BY lg.parent_loc_cd, lg.child_loc_cd, bid.bb_inv_device_id
  HEAD REPORT
   own_cnt = 0, stat = alterlist(reply->ownerlist,5)
  HEAD lg.parent_loc_cd
   IF (lg.seq > 0)
    own_cnt = (own_cnt+ 1)
    IF (mod(own_cnt,5)=1
     AND own_cnt != 1)
     stat = alterlist(reply->ownerlist,(own_cnt+ 4))
    ENDIF
    inv_cnt = 0, stat = alterlist(reply->ownerlist[own_cnt].invlist,5), reply->ownerlist[own_cnt].
    location_cd = lg.parent_loc_cd
   ENDIF
  HEAD lg.child_loc_cd
   IF (lg.seq > 0)
    inv_cnt = (inv_cnt+ 1)
    IF (mod(inv_cnt,5)=1
     AND inv_cnt != 1)
     stat = alterlist(reply->ownerlist[own_cnt].invlist,(inv_cnt+ 4))
    ENDIF
    dev_cnt = 0, stat = alterlist(reply->ownerlist[own_cnt].invlist[inv_cnt].devicelist,10), reply->
    ownerlist[own_cnt].invlist[inv_cnt].location_cd = lg.child_loc_cd
   ENDIF
  HEAD bid.bb_inv_device_id
   IF (bid.seq > 0)
    dev_cnt = (dev_cnt+ 1)
    IF (mod(dev_cnt,10)=1
     AND dev_cnt != 1)
     stat = alterlist(reply->ownerlist[own_cnt].invlist[inv_cnt].devicelist,(dev_cnt+ 9))
    ENDIF
    reply->ownerlist[own_cnt].invlist[inv_cnt].devicelist[dev_cnt].device_id = bid.bb_inv_device_id,
    reply->ownerlist[own_cnt].invlist[inv_cnt].devicelist[dev_cnt].description = bid.description
   ENDIF
  FOOT  lg.child_loc_cd
   stat = alterlist(reply->ownerlist[own_cnt].invlist[inv_cnt].devicelist,dev_cnt)
  FOOT  lg.parent_loc_cd
   stat = alterlist(reply->ownerlist[own_cnt].invlist,inv_cnt)
  FOOT REPORT
   stat = alterlist(reply->ownerlist,own_cnt)
  WITH nocounter, outerjoin(d_bid)
 ;end select
 GO TO exit_script
#exit_script
 SET count1 = (count1+ 1)
 IF (count1 > 1)
  SET stat = alterlist(reply->status_data.subeventstatus,count1)
 ENDIF
 IF (failed != "T")
  IF (own_cnt > 0)
   SET reply->status_data.status = "S"
   SET reply->status_data.subeventstatus[count1].operationname = "get BBINVAREA's"
   SET reply->status_data.subeventstatus[count1].operationstatus = "S"
   SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_get_inv_area"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = "SUCCESS"
  ELSE
   SET reply->status_data.status = "Z"
   SET reply->status_data.subeventstatus[count1].operationname = "get BBINVAREA's"
   SET reply->status_data.subeventstatus[count1].operationstatus = "Z"
   SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_get_inv_area"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = "ZERO"
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 FOR (p = 1 TO own_cnt)
   CALL echo(reply->ownerlist[p].location_cd)
   SET c_cnt = cnvtint(size(reply->ownerlist[p].invlist,5))
   FOR (c = 1 TO c_cnt)
    CALL echo(build("-----",reply->ownerlist[p].invlist[c].location_cd))
    FOR (d = 1 TO cnvtint(size(reply->ownerlist[p].invlist[c].devicelist,5)))
      CALL echo(build("----------",reply->ownerlist[p].invlist[c].devicelist[d].device_id))
    ENDFOR
   ENDFOR
 ENDFOR
END GO
