CREATE PROGRAM bbt_transfer_devices:dba
 DECLARE next_pathnet_seq(pathnet_seq_dummy) = f8
 SUBROUTINE next_pathnet_seq(pathnet_seq_dummy)
   SET new_pathnet_seq = 0.0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)"###########################;rp0"
    FROM dual
    DETAIL
     new_pathnet_seq = cnvtint(seqn)
    WITH format, nocounter
   ;end select
   RETURN(new_pathnet_seq)
 END ;Subroutine
 RECORD reply(
   1 qual[*]
     2 bb_inv_device_id = f8
     2 description = c40
     2 device_type_cd = f8
     2 updt_cnt = i4
     2 updt_id = f8
     2 updt_task = i4
     2 updt_applctx = i4
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_prsnl_id = f8
     2 bb_inv_device_r_id = f8
     2 device_location_cd = f8
     2 device_invarea_cd = f8
     2 device_srvres_cd = f8
 )
 SET new_device_id = 0.0
 SET loop = 0
 SET qual_cnt = 0
 SET stat = alterlist(reply->qual,10)
 SELECT INTO "nl:"
  *
  FROM bb_device bd
  HEAD REPORT
   qual_cnt = 0
  DETAIL
   qual_cnt = (qual_cnt+ 1)
   IF (mod(qual_cnt,10)=1
    AND qual_cnt != 1)
    stat = alterlist(reply->qual,(qual_cnt+ 9))
   ENDIF
   reply->qual[qual_cnt].bb_inv_device_id = bd.device_id, reply->qual[qual_cnt].description = bd
   .description, reply->qual[qual_cnt].device_type_cd = bd.device_type_cd,
   reply->qual[qual_cnt].updt_cnt = bd.updt_cnt, reply->qual[qual_cnt].updt_id = bd.updt_id, reply->
   qual[qual_cnt].updt_task = bd.updt_task,
   reply->qual[qual_cnt].updt_applctx = bd.updt_applctx, reply->qual[qual_cnt].active_ind = bd
   .active_ind, reply->qual[qual_cnt].active_status_cd = bd.active_status_cd,
   reply->qual[qual_cnt].active_status_prsnl_id = bd.active_status_prsnl_id, reply->qual[qual_cnt].
   bb_inv_device_r_id = new_device_id, reply->qual[qual_cnt].device_location_cd = bd.location_cd,
   reply->qual[qual_cnt].device_invarea_cd = bd.inventory_area_cd, reply->qual[qual_cnt].
   device_srvres_cd = bd.service_resource_cd
  WITH counter, outerjoin(d_bdr)
 ;end select
 SET stat = alterlist(reply->qual,qual_cnt)
 FOR (loop = 1 TO qual_cnt)
   INSERT  FROM bb_inv_device bbd
    SET bbd.bb_inv_device_id = reply->qual[loop].bb_inv_device_id, bbd.device_type_cd = reply->qual[
     loop].device_type_cd, bbd.active_ind = reply->qual[loop].active_ind,
     bbd.updt_cnt = reply->qual[loop].updt_cnt, bbd.updt_dt_tm = cnvtdatetime(curdate,curtime3), bbd
     .updt_id = reply->qual[loop].updt_id,
     bbd.updt_task = reply->qual[loop].updt_task, bbd.updt_applctx = reply->qual[loop].updt_applctx,
     bbd.active_status_cd = reply->qual[loop].active_status_cd,
     bbd.active_status_dt_tm = cnvtdatetime(curdate,curtime3), bbd.active_status_prsnl_id = reply->
     qual[loop].active_status_prsnl_id, bbd.description = reply->qual[loop].description
   ;end insert
 ENDFOR
 FOR (loop = 1 TO qual_cnt)
   IF ((reply->qual[loop].device_location_cd > 0))
    SET new_device_id = next_pathnet_seq(0)
    INSERT  FROM bb_inv_device_r bdr
     SET bdr.bb_inv_device_r_id = new_device_id, bdr.bb_inv_device_id = reply->qual[loop].
      bb_inv_device_id, bdr.device_r_cd = reply->qual[loop].device_location_cd,
      bdr.device_r_type_cd = 8876237, bdr.updt_cnt = reply->qual[loop].updt_cnt, bdr.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      bdr.updt_id = reply->qual[loop].updt_id, bdr.updt_task = reply->qual[loop].updt_task, bdr
      .updt_applctx = reply->qual[loop].updt_applctx,
      bdr.active_ind = reply->qual[loop].active_ind, bdr.active_status_cd = reply->qual[loop].
      active_status_cd, bdr.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
      bdr.active_status_prsnl_id = reply->qual[loop].active_status_prsnl_id
    ;end insert
   ENDIF
 ENDFOR
 FOR (loop = 1 TO qual_cnt)
   IF ((reply->qual[loop].device_invarea_cd > 0))
    SET new_device_id = next_pathnet_seq(0)
    INSERT  FROM bb_inv_device_r bdr
     SET bdr.bb_inv_device_r_id = new_device_id, bdr.bb_inv_device_id = reply->qual[loop].
      bb_inv_device_id, bdr.device_r_cd = reply->qual[loop].device_invarea_cd,
      bdr.device_r_type_cd = 8876236, bdr.updt_cnt = reply->qual[loop].updt_cnt, bdr.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      bdr.updt_id = reply->qual[loop].updt_id, bdr.updt_task = reply->qual[loop].updt_task, bdr
      .updt_applctx = reply->qual[loop].updt_applctx,
      bdr.active_ind = reply->qual[loop].active_ind, bdr.active_status_cd = reply->qual[loop].
      active_status_cd, bdr.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
      bdr.active_status_prsnl_id = reply->qual[loop].active_status_prsnl_id
    ;end insert
   ENDIF
 ENDFOR
 FOR (loop = 1 TO qual_cnt)
   IF ((reply->qual[loop].device_srvres_cd > 0))
    SET new_device_id = next_pathnet_seq(0)
    INSERT  FROM bb_inv_device_r bdr
     SET bdr.bb_inv_device_r_id = new_device_id, bdr.bb_inv_device_id = reply->qual[loop].
      bb_inv_device_id, bdr.device_r_cd = reply->qual[loop].device_srvres_cd,
      bdr.device_r_type_cd = 8876238, bdr.updt_cnt = reply->qual[loop].updt_cnt, bdr.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      bdr.updt_id = reply->qual[loop].updt_id, bdr.updt_task = reply->qual[loop].updt_task, bdr
      .updt_applctx = reply->qual[loop].updt_applctx,
      bdr.active_ind = reply->qual[loop].active_ind, bdr.active_status_cd = reply->qual[loop].
      active_status_cd, bdr.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
      bdr.active_status_prsnl_id = reply->qual[loop].active_status_prsnl_id
    ;end insert
   ENDIF
 ENDFOR
 COMMIT
END GO
