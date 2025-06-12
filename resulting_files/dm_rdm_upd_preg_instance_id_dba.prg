CREATE PROGRAM dm_rdm_upd_preg_instance_id:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 FREE RECORD preg_data
 RECORD preg_data(
   1 qual[*]
     2 table_key = f8
     2 pregnancy_instance_id = f8
     2 pregnancy_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
 )
 FREE RECORD pregs
 RECORD pregs(
   1 preg[*]
     2 pregnancy_id = f8
     2 pregnancy_instance_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
 )
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failed: starting script dm_rdm_upd_preg_instance_id..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE qual_cnt = i4 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE j = i4 WITH protect, noconstant(0)
 DECLARE preg_cnt = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM pregnancy_instance p
  PLAN (p
   WHERE  EXISTS (
   (SELECT
    "x"
    FROM pregnancy_instance pi
    WHERE pi.pregnancy_id=p.pregnancy_id
     AND pi.pregnancy_instance_id != p.pregnancy_instance_id
     AND pi.beg_effective_dt_tm=p.beg_effective_dt_tm)))
  ORDER BY p.pregnancy_id, p.beg_effective_dt_tm, p.end_effective_dt_tm
  HEAD REPORT
   qual_cnt = 0
  DETAIL
   qual_cnt = (qual_cnt+ 1)
   IF (mod(qual_cnt,10)=1)
    stat = alterlist(pregs->preg,(qual_cnt+ 9))
   ENDIF
   pregs->preg[qual_cnt].pregnancy_id = p.pregnancy_id, pregs->preg[qual_cnt].pregnancy_instance_id
    = p.pregnancy_instance_id, pregs->preg[qual_cnt].beg_effective_dt_tm = p.beg_effective_dt_tm,
   pregs->preg[qual_cnt].end_effective_dt_tm = p.end_effective_dt_tm
  FOOT REPORT
   stat = alterlist(pregs->preg,qual_cnt)
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->message = concat("Failed to find pregnancy rows to update: ",errmsg)
  GO TO exit_script
 ENDIF
 SET preg_cnt = size(pregs->preg,5)
 SET qual_cnt = 0
 FOR (i = 1 TO preg_cnt)
   FOR (j = (i+ 1) TO preg_cnt)
     IF ((pregs->preg[i].pregnancy_id=pregs->preg[j].pregnancy_id)
      AND (pregs->preg[i].beg_effective_dt_tm=pregs->preg[j].beg_effective_dt_tm))
      SET qual_cnt = (qual_cnt+ 1)
      IF (mod(qual_cnt,10)=1)
       SET stat = alterlist(preg_data->qual,(qual_cnt+ 9))
      ENDIF
      SET preg_data->qual[qual_cnt].pregnancy_instance_id = pregs->preg[j].pregnancy_instance_id
      SET preg_data->qual[qual_cnt].pregnancy_id = pregs->preg[j].pregnancy_id
      SET preg_data->qual[qual_cnt].end_effective_dt_tm = pregs->preg[j].end_effective_dt_tm
      SET preg_data->qual[qual_cnt].beg_effective_dt_tm = pregs->preg[i].end_effective_dt_tm
     ENDIF
   ENDFOR
 ENDFOR
 IF (curqual=0)
  CALL echo("[trace]: No Pregnancy Instance Rows to Update")
  GO TO pregnancy_action
 ELSE
  SET stat = alterlist(preg_data->qual,qual_cnt)
 ENDIF
 UPDATE  FROM pregnancy_instance pi,
   (dummyt d1  WITH seq = qual_cnt)
  SET pi.beg_effective_dt_tm = cnvtdatetime(preg_data->qual[d1.seq].beg_effective_dt_tm), pi.updt_cnt
    = (pi.updt_cnt+ 1), pi.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   pi.updt_task = reqinfo->updt_task, pi.updt_applctx = reqinfo->updt_applctx, pi.updt_id = reqinfo->
   updt_id
  PLAN (d1)
   JOIN (pi
   WHERE (pi.pregnancy_instance_id=preg_data->qual[d1.seq].pregnancy_instance_id))
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->message = concat("Failed to update pregnancy instance rows: ",errmsg)
  GO TO exit_script
 ENDIF
#pregnancy_action
 SET stat = alterlist(preg_data->qual,0)
 SELECT INTO "nl:"
  FROM pregnancy_action pa,
   pregnancy_instance pi
  PLAN (pa
   WHERE pa.pregnancy_instance_id=0)
   JOIN (pi
   WHERE pi.pregnancy_id=pa.pregnancy_id
    AND pi.beg_effective_dt_tm=pa.action_dt_tm)
  ORDER BY pa.pregnancy_id, pa.pregnancy_action_id
  HEAD REPORT
   qual_cnt = 0
  DETAIL
   qual_cnt = (qual_cnt+ 1)
   IF (mod(qual_cnt,10)=1)
    stat = alterlist(preg_data->qual,(qual_cnt+ 9))
   ENDIF
   preg_data->qual[qual_cnt].table_key = pa.pregnancy_action_id, preg_data->qual[qual_cnt].
   pregnancy_instance_id = pi.pregnancy_instance_id
  FOOT REPORT
   stat = alterlist(preg_data->qual,qual_cnt)
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->message = concat("Failed to find action rows to update: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  CALL echo("[trace]: No Pregnancy Action Rows to Update")
  GO TO pregnancy_entity_r
 ENDIF
 UPDATE  FROM pregnancy_action pa,
   (dummyt d1  WITH seq = value(size(preg_data->qual,5)))
  SET pa.pregnancy_instance_id = preg_data->qual[d1.seq].pregnancy_instance_id, pa.updt_cnt = (pa
   .updt_cnt+ 1), pa.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   pa.updt_task = reqinfo->updt_task, pa.updt_applctx = reqinfo->updt_applctx, pa.updt_id = reqinfo->
   updt_id
  PLAN (d1)
   JOIN (pa
   WHERE (pa.pregnancy_action_id=preg_data->qual[d1.seq].table_key))
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->message = concat("Failed to update action rows: ",errmsg)
  GO TO exit_script
 ENDIF
#pregnancy_entity_r
 SET stat = alterlist(preg_data->qual,0)
 SELECT INTO "nl:"
  FROM pregnancy_entity_r per,
   pregnancy_instance pi
  PLAN (per
   WHERE per.pregnancy_instance_id=0)
   JOIN (pi
   WHERE pi.pregnancy_id=per.pregnancy_id
    AND pi.beg_effective_dt_tm=per.beg_effective_dt_tm)
  ORDER BY per.pregnancy_id, per.pregnancy_entity_id
  HEAD REPORT
   qual_cnt = 0
  DETAIL
   qual_cnt = (qual_cnt+ 1)
   IF (mod(qual_cnt,10)=1)
    stat = alterlist(preg_data->qual,(qual_cnt+ 9))
   ENDIF
   preg_data->qual[qual_cnt].table_key = per.pregnancy_entity_id, preg_data->qual[qual_cnt].
   pregnancy_instance_id = pi.pregnancy_instance_id
  FOOT REPORT
   stat = alterlist(preg_data->qual,qual_cnt)
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->message = concat("Failed to find entity rows to update: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  CALL echo("[trace]: No Pregnancy Entity Rows to Update")
  GO TO pregnancy_children
 ENDIF
 UPDATE  FROM pregnancy_entity_r per,
   (dummyt d1  WITH seq = value(size(preg_data->qual,5)))
  SET per.pregnancy_instance_id = preg_data->qual[d1.seq].pregnancy_instance_id, per.updt_cnt = (per
   .updt_cnt+ 1), per.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   per.updt_task = reqinfo->updt_task, per.updt_applctx = reqinfo->updt_applctx, per.updt_id =
   reqinfo->updt_id
  PLAN (d1)
   JOIN (per
   WHERE (per.pregnancy_entity_id=preg_data->qual[d1.seq].table_key))
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->message = concat("Failed to update entity rows: ",errmsg)
  GO TO exit_script
 ENDIF
#pregnancy_children
 SET stat = alterlist(preg_data->qual,0)
 SELECT INTO "nl:"
  FROM pregnancy_child pc,
   pregnancy_instance pi
  PLAN (pc
   WHERE pc.pregnancy_instance_id=0)
   JOIN (pi
   WHERE pi.pregnancy_id=pc.pregnancy_id
    AND pi.beg_effective_dt_tm=pc.beg_effective_dt_tm)
  ORDER BY pc.pregnancy_id, pc.pregnancy_child_id
  HEAD REPORT
   qual_cnt = 0
  DETAIL
   qual_cnt = (qual_cnt+ 1)
   IF (mod(qual_cnt,10)=1)
    stat = alterlist(preg_data->qual,(qual_cnt+ 9))
   ENDIF
   preg_data->qual[qual_cnt].table_key = pc.pregnancy_child_id, preg_data->qual[qual_cnt].
   pregnancy_instance_id = pi.pregnancy_instance_id
  FOOT REPORT
   stat = alterlist(preg_data->qual,qual_cnt)
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->message = concat("Failed to find child rows to update: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  CALL echo("[trace]: No Pregnancy Child Rows to Update")
  SET readme_data->status = "S"
  SET readme_data->message = "Success: Readme performed all required tasks"
  COMMIT
  GO TO exit_script
 ENDIF
 UPDATE  FROM pregnancy_child pc,
   (dummyt d1  WITH seq = value(size(preg_data->qual,5)))
  SET pc.pregnancy_instance_id = preg_data->qual[d1.seq].pregnancy_instance_id, pc.updt_cnt = (pc
   .updt_cnt+ 1), pc.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   pc.updt_task = reqinfo->updt_task, pc.updt_applctx = reqinfo->updt_applctx, pc.updt_id = reqinfo->
   updt_id
  PLAN (d1)
   JOIN (pc
   WHERE (pc.pregnancy_child_id=preg_data->qual[d1.seq].table_key))
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->message = concat("Failed to update child rows: ",errmsg)
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "Success: Readme performed all required tasks"
  COMMIT
 ENDIF
#exit_script
 FREE RECORD preg_data
 FREE RECORD pregs
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
