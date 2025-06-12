CREATE PROGRAM bbt_get_device_reltns:dba
 RECORD reply(
   1 bb_inv_device_id = f8
   1 active_ind = i2
   1 updt_cnt = i4
   1 qual[*]
     2 bb_inv_device_r_id = f8
     2 device_r_cd = f8
     2 device_r_cd_disp = c40
     2 active_ind = i2
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET qual_cnt = 0
 SET stat = alterlist(reply->qual,10)
 SET locn_cd = 0.0
 SET invarea_cd = 0.0
 SET srvres_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(17396,"BBPATLOCN",1,locn_cd)
 SET stat = uar_get_meaning_by_codeset(17396,"BBINVAREA",1,invarea_cd)
 SET stat = uar_get_meaning_by_codeset(17396,"BBSRVRESRC",1,srvres_cd)
 SELECT INTO "nl:"
  bbd.bb_inv_device_id, bbd.active_ind, bdr.bb_inv_device_r_id,
  device_r_type_mean = uar_get_code_meaning(bdr.device_r_type_cd), bdr.device_r_cd, y =
  uar_get_code_display(bdr.device_r_cd),
  bdr.active_ind
  FROM bb_inv_device bbd,
   (dummyt d_bdr  WITH seq = 1),
   bb_inv_device_r bdr
  PLAN (bbd
   WHERE (bbd.bb_inv_device_id=request->bb_inv_device_id)
    AND (((request->return_inactive_ind != 1)
    AND bbd.active_ind=1) OR ((request->return_inactive_ind=1))) )
   JOIN (d_bdr
   WHERE d_bdr.seq=1)
   JOIN (bdr
   WHERE bbd.bb_inv_device_id=bdr.bb_inv_device_id
    AND (((request->device_r_type_mean="BBSRVRESRC")
    AND bdr.device_r_type_cd=srvres_cd) OR ((((request->device_r_type_mean="BBPATLOCN")
    AND bdr.device_r_type_cd=locn_cd) OR ((request->device_r_type_mean="BBINVAREA")
    AND bdr.device_r_type_cd=invarea_cd)) ))
    AND bdr.active_ind=1)
  ORDER BY bbd.bb_inv_device_id, bdr.bb_inv_device_r_id
  HEAD REPORT
   qual_cnt = 0, reply->bb_inv_device_id = bbd.bb_inv_device_id, reply->active_ind = bbd.active_ind,
   reply->updt_cnt = bbd.updt_cnt
  DETAIL
   qual_cnt = (qual_cnt+ 1)
   IF (mod(qual_cnt,10)=1
    AND qual_cnt != 1)
    stat = alterlist(reply->qual,(qual_cnt+ 9))
   ENDIF
   reply->qual[qual_cnt].bb_inv_device_r_id = bdr.bb_inv_device_r_id, reply->qual[qual_cnt].
   device_r_cd = bdr.device_r_cd, reply->qual[qual_cnt].device_r_cd_disp = y,
   reply->qual[qual_cnt].active_ind = bdr.active_ind, reply->qual[qual_cnt].updt_cnt = bdr.updt_cnt
  WITH counter, outerjoin(d_bdr)
 ;end select
 SET stat = alterlist(reply->qual,qual_cnt)
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
