CREATE PROGRAM bed_ens_bbt_tc_assay_dtls:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET tot_cnt = 0
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET active_code = 0.0
 SET inactive_code = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning IN ("ACTIVE", "INACTIVE")
   AND cv.active_ind=1
  DETAIL
   CASE (cv.cdf_meaning)
    OF "ACTIVE":
     active_code = cv.code_value
    OF "INACTIVE":
     inactive_code = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 SET req_cnt = size(request->assays,5)
 SET t_committee_id = 0.0
 SET t_committee_id = chk_trans_committee(request->owner_area_code_value,request->
  inventory_area_code_value,request->product_code_value)
 IF (t_committee_id=0)
  SET t_committee_id = add_trans_committee(request->owner_area_code_value,request->
   inventory_area_code_value,request->product_code_value)
 ELSE
  SET upd_ind = 0
  SELECT INTO "nl:"
   FROM transfusion_committee t
   WHERE t.trans_commit_id=t_committee_id
   DETAIL
    IF ((request->active_ind != t.active_ind))
     upd_ind = 1
    ENDIF
   WITH nocounter
  ;end select
  IF (upd_ind=1)
   UPDATE  FROM transfusion_committee tc
    SET tc.active_ind = request->active_ind, tc.active_status_cd =
     IF ((request->active_ind=1)) active_code
     ELSE inactive_code
     ENDIF
     , tc.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
     tc.active_status_prsnl_id = reqinfo->updt_id, tc.updt_applctx = reqinfo->updt_applctx, tc
     .updt_cnt = (tc.updt_cnt+ 1),
     tc.updt_dt_tm = cnvtdatetime(curdate,curtime3), tc.updt_id = reqinfo->updt_id, tc.updt_task =
     reqinfo->updt_task
    WHERE tc.trans_commit_id=t_committee_id
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = "Insert into transfusion_committee faild."
   ENDIF
  ENDIF
 ENDIF
 IF (req_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(req_cnt)),
    trans_commit_assay tca
   PLAN (d
    WHERE (request->assays[d.seq].action_flag=1))
    JOIN (tca
    WHERE tca.trans_commit_id=t_committee_id
     AND (tca.task_assay_cd=request->assays[d.seq].assay_code_value))
   ORDER BY d.seq
   HEAD d.seq
    request->assays[d.seq].action_flag = 4
   WITH nocounter
  ;end select
  SET ierrcode = 0
  UPDATE  FROM trans_commit_assay tca,
    (dummyt d  WITH seq = value(req_cnt))
   SET tca.pre_hours = request->assays[d.seq].pre_hours, tca.post_hours = request->assays[d.seq].
    post_hours, tca.active_ind = 1,
    tca.active_status_cd = active_code, tca.active_status_dt_tm = cnvtdatetime(curdate,curtime3), tca
    .active_status_prsnl_id = reqinfo->updt_id,
    tca.updt_cnt = (tca.updt_cnt+ 1), tca.updt_dt_tm = cnvtdatetime(curdate,curtime3), tca.updt_id =
    reqinfo->updt_id,
    tca.updt_task = reqinfo->updt_task, tca.updt_applctx = reqinfo->updt_applctx
   PLAN (d
    WHERE (request->assays[d.seq].action_flag=4))
    JOIN (tca
    WHERE tca.trans_commit_id=t_committee_id
     AND (tca.task_assay_cd=request->assays[d.seq].assay_code_value))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET error_msg = concat("Error updating trans_commit_assay >> ",serrmsg)
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  INSERT  FROM trans_commit_assay tca,
    (dummyt d  WITH seq = value(req_cnt))
   SET tca.trans_commit_assay_id = seq(pathnet_seq,nextval), tca.trans_commit_id = t_committee_id,
    tca.task_assay_cd = request->assays[d.seq].assay_code_value,
    tca.pre_hours = request->assays[d.seq].pre_hours, tca.post_hours = request->assays[d.seq].
    post_hours, tca.all_results_ind = 0,
    tca.active_ind = 1, tca.active_status_cd = active_code, tca.active_status_dt_tm = cnvtdatetime(
     curdate,curtime3),
    tca.active_status_prsnl_id = reqinfo->updt_id, tca.updt_cnt = 0, tca.updt_dt_tm = cnvtdatetime(
     curdate,curtime3),
    tca.updt_id = reqinfo->updt_id, tca.updt_task = reqinfo->updt_task, tca.updt_applctx = reqinfo->
    updt_applctx
   PLAN (d
    WHERE (request->assays[d.seq].action_flag=1))
    JOIN (tca)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET error_msg = concat("Error inserting trans_commit_assay >> ",serrmsg)
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  UPDATE  FROM trans_commit_assay tca,
    (dummyt d  WITH seq = value(req_cnt))
   SET tca.pre_hours = request->assays[d.seq].pre_hours, tca.post_hours = request->assays[d.seq].
    post_hours, tca.updt_cnt = (tca.updt_cnt+ 1),
    tca.updt_dt_tm = cnvtdatetime(curdate,curtime3), tca.updt_id = reqinfo->updt_id, tca.updt_task =
    reqinfo->updt_task,
    tca.updt_applctx = reqinfo->updt_applctx
   PLAN (d
    WHERE (request->assays[d.seq].action_flag=2))
    JOIN (tca
    WHERE tca.trans_commit_id=t_committee_id
     AND (tca.task_assay_cd=request->assays[d.seq].assay_code_value))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET error_msg = concat("Error updating trans_commit_assay >> ",serrmsg)
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  UPDATE  FROM trans_commit_assay tca,
    (dummyt d  WITH seq = value(req_cnt))
   SET tca.pre_hours = request->assays[d.seq].pre_hours, tca.post_hours = request->assays[d.seq].
    post_hours, tca.all_results_ind = 0,
    tca.active_ind = 0, tca.active_status_cd = inactive_code, tca.active_status_dt_tm = cnvtdatetime(
     curdate,curtime3),
    tca.active_status_prsnl_id = reqinfo->updt_id, tca.updt_cnt = (tca.updt_cnt+ 1), tca.updt_dt_tm
     = cnvtdatetime(curdate,curtime3),
    tca.updt_id = reqinfo->updt_id, tca.updt_task = reqinfo->updt_task, tca.updt_applctx = reqinfo->
    updt_applctx
   PLAN (d
    WHERE (request->assays[d.seq].action_flag=3))
    JOIN (tca
    WHERE tca.trans_commit_id=t_committee_id
     AND (tca.task_assay_cd=request->assays[d.seq].assay_code_value))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET error_msg = concat("Error inactivating trans_commit_assay >> ",serrmsg)
   GO TO exit_script
  ENDIF
 ENDIF
 SET cpy_oa_size = size(request->copy_to.owner_areas,5)
 SET pro_size = size(request->copy_to.products,5)
 SET cpy_from_id = t_committee_id
 IF (cpy_oa_size > 0)
  FOR (x = 1 TO cpy_oa_size)
   SET inv_size = size(request->copy_to.owner_areas[x].inventory_areas,5)
   IF (inv_size > 0)
    FOR (y = 1 TO inv_size)
      FOR (z = 1 TO pro_size)
        SET t_committee_id = 0
        SET t_committee_id = chk_trans_committee(request->copy_to.owner_areas[x].
         owner_area_code_value,request->copy_to.owner_areas[x].inventory_areas[y].
         inventory_area_code_value,request->copy_to.products[z].product_code_value)
        IF (t_committee_id=0)
         SET t_committee_id = add_trans_committee(request->copy_to.owner_areas[x].
          owner_area_code_value,request->copy_to.owner_areas[x].inventory_areas[y].
          inventory_area_code_value,request->copy_to.products[z].product_code_value)
         SET stat = add_all_assays(t_committee_id)
        ELSE
         IF (cpy_from_id != t_committee_id)
          SET stat = del_all_assays(t_committee_id)
          SET stat = add_all_assays(t_committee_id)
          SET stat = upd_trans_committee(t_committee_id)
         ENDIF
        ENDIF
      ENDFOR
    ENDFOR
   ELSE
    FOR (y = 1 TO pro_size)
      SET t_committee_id = 0
      SET t_committee_id = chk_trans_committee(request->copy_to.owner_areas[x].owner_area_code_value,
       0,request->copy_to.products[y].product_code_value)
      IF (t_committee_id=0)
       SET t_committee_id = add_trans_committee(request->copy_to.owner_areas[x].owner_area_code_value,
        0,request->copy_to.products[y].product_code_value)
       SET stat = add_all_assays(t_committee_id)
      ELSE
       IF (cpy_from_id != t_committee_id)
        SET stat = del_all_assays(t_committee_id)
        SET stat = add_all_assays(t_committee_id)
        SET stat = upd_trans_committee(t_committee_id)
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
  ENDFOR
 ELSE
  FOR (x = 1 TO pro_size)
    SET t_committee_id = 0
    SET t_committee_id = chk_trans_committee(0,0,request->copy_to.products[x].product_code_value)
    IF (t_committee_id=0)
     SET t_committee_id = add_trans_committee(0,0,request->copy_to.products[x].product_code_value)
     SET stat = add_all_assays(t_committee_id)
    ELSE
     IF (cpy_from_id != t_committee_id)
      SET stat = del_all_assays(t_committee_id)
      SET stat = add_all_assays(t_committee_id)
      SET stat = upd_trans_committee(t_committee_id)
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 SUBROUTINE chk_trans_committee(oa_code,inv_code,prod_code)
   DECLARE tc_parse = vc
   IF (oa_code=0)
    SET tc_parse = concat(tc_parse," tc.owner_cd IN (0,null) and ")
   ELSE
    SET tc_parse = concat(tc_parse," tc.owner_cd = oa_code and ")
   ENDIF
   IF (inv_code=0)
    SET tc_parse = concat(tc_parse," tc.inv_area_cd IN (0, null) and ")
   ELSE
    SET tc_parse = concat(tc_parse," tc.inv_area_cd = inv_code and ")
   ENDIF
   SET tc_parse = concat(tc_parse," tc.product_cd = prod_code ")
   SET tc_id = 0.0
   SELECT INTO "nl:"
    FROM transfusion_committee tc
    PLAN (tc
     WHERE parser(tc_parse))
    DETAIL
     tc_id = tc.trans_commit_id
    WITH nocounter
   ;end select
   RETURN(tc_id)
 END ;Subroutine
 SUBROUTINE add_trans_committee(oa_code,inv_code,prod_code)
   SET tc_id = 0.0
   SELECT INTO "NL:"
    j = seq(pathnet_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     tc_id = cnvtreal(j)
    WITH format, counter
   ;end select
   IF (curqual=0)
    SET error_flag = "Y"
    SET reply->error_msg = concat("Unable to retrieve next code value in PATHNET_SEQ.")
   ENDIF
   INSERT  FROM transfusion_committee tc
    SET tc.trans_commit_id = tc_id, tc.owner_cd = oa_code, tc.inv_area_cd = inv_code,
     tc.product_cd = prod_code, tc.single_hours = 0, tc.single_post_hours = 0,
     tc.single_pre_hours = 0, tc.single_trans_ind = 0, tc.active_ind = request->active_ind,
     tc.active_status_cd =
     IF ((request->active_ind=1)) active_code
     ELSE inactive_code
     ENDIF
     , tc.active_status_dt_tm = cnvtdatetime(curdate,curtime3), tc.active_status_prsnl_id = reqinfo->
     updt_id,
     tc.updt_applctx = reqinfo->updt_applctx, tc.updt_cnt = 0, tc.updt_dt_tm = cnvtdatetime(curdate,
      curtime3),
     tc.updt_id = reqinfo->updt_id, tc.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = "Insert into transfusion_committee faild."
   ENDIF
   RETURN(tc_id)
 END ;Subroutine
 SUBROUTINE add_all_assays(tc_id)
   SET ierrcode = 0
   INSERT  FROM trans_commit_assay tca
    (tca.trans_commit_assay_id, tca.trans_commit_id, tca.task_assay_cd,
    tca.pre_hours, tca.post_hours, tca.all_results_ind,
    tca.active_ind, tca.active_status_cd, tca.active_status_dt_tm,
    tca.active_status_prsnl_id, tca.updt_cnt, tca.updt_dt_tm,
    tca.updt_id, tca.updt_task, tca.updt_applctx)(SELECT
     seq(pathnet_seq,nextval), tc_id, tca2.task_assay_cd,
     tca2.pre_hours, tca2.post_hours, tca2.all_results_ind,
     1, active_code, cnvtdatetime(curdate,curtime3),
     reqinfo->updt_id, 0, cnvtdatetime(curdate,curtime3),
     reqinfo->updt_id, reqinfo->updt_task, reqinfo->updt_applctx
     FROM trans_commit_assay tca2
     WHERE tca2.trans_commit_id=cpy_from_id
      AND tca2.active_ind=1)
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET error_flag = "Y"
    SET error_msg = concat("Error inserting trans_commit_assay >> ",serrmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE del_all_assays(tc_id)
   DELETE  FROM trans_commit_assay tca
    WHERE tca.trans_commit_id=tc_id
    WITH nocounter
   ;end delete
 END ;Subroutine
 SUBROUTINE upd_trans_committee(tc_id)
   UPDATE  FROM transfusion_committee tc
    SET tc.active_ind = request->active_ind, tc.active_status_cd =
     IF ((request->active_ind=1)) active_code
     ELSE inactive_code
     ENDIF
     , tc.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
     tc.active_status_prsnl_id = reqinfo->updt_id, tc.updt_applctx = reqinfo->updt_applctx, tc
     .updt_cnt = (tc.updt_cnt+ 1),
     tc.updt_dt_tm = cnvtdatetime(curdate,curtime3), tc.updt_id = reqinfo->updt_id, tc.updt_task =
     reqinfo->updt_task
    WHERE tc.trans_commit_id=tc_id
     AND (tc.active_ind != request->active_ind)
    WITH nocounter
   ;end update
 END ;Subroutine
#exit_script
 IF (error_flag="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO
