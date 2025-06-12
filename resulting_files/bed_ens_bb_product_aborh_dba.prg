CREATE PROGRAM bed_ens_bb_product_aborh:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET active_cd = 0.0
 SET inactive_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=48
    AND cv.cdf_meaning="ACTIVE"
    AND cv.active_ind=1)
  DETAIL
   active_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=48
    AND cv.cdf_meaning="INACTIVE"
    AND cv.active_ind=1)
  DETAIL
   inactive_cd = cv.code_value
  WITH nocounter
 ;end select
 FOR (d = 1 TO size(request->dlist,5))
  IF ((request->dlist[d].action_flag=1))
   FOR (q = 1 TO size(request->dlist[d].prod_list,5))
     SET inactive_row_found = "N"
     SET pa_seq = 0
     SELECT INTO "nl:"
      FROM product_aborh pa
      PLAN (pa
       WHERE (pa.product_cd=request->dlist[d].prod_list[q].product_code_value)
        AND (pa.product_aborh_cd=request->dlist[d].group_type_code_value)
        AND pa.active_ind=0)
      ORDER BY pa.sequence_nbr
      DETAIL
       pa_seq = pa.sequence_nbr, inactive_row_found = "Y"
      WITH nocounter
     ;end select
     IF (inactive_row_found="Y")
      SET ierrcode = 0
      UPDATE  FROM product_aborh pa
       SET pa.seq = 1, pa.no_gt_on_prsn_flag = request->dlist[d].crossmatch_dispense_flag, pa
        .no_gt_autodir_prsn_flag = request->dlist[d].auto_direct_flag,
        pa.disp_no_curraborh_prsn_flag = request->dlist[d].dispense_curr_aborh_flag, pa
        .aborh_option_flag = request->dlist[d].aborh_ind, pa.active_ind = 1,
        pa.active_status_cd = active_cd, pa.active_status_prsnl_id = reqinfo->updt_id, pa
        .active_status_dt_tm = cnvtdatetime(curdate,curtime),
        pa.updt_id = reqinfo->updt_id, pa.updt_cnt = (pa.updt_cnt+ 1), pa.updt_dt_tm = cnvtdatetime(
         curdate,curtime),
        pa.updt_task = reqinfo->updt_task, pa.updt_applctx = reqinfo->updt_applctx
       PLAN (pa
        WHERE (pa.product_cd=request->dlist[d].prod_list[q].product_code_value)
         AND (pa.product_aborh_cd=request->dlist[d].group_type_code_value)
         AND pa.sequence_nbr=pa_seq)
       WITH nocounter
      ;end update
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = "Y"
       GO TO exit_script
      ENDIF
     ELSE
      SET ierrcode = 0
      INSERT  FROM product_aborh pa
       SET pa.seq = 1, pa.product_cd = request->dlist[d].prod_list[q].product_code_value, pa
        .product_aborh_cd = request->dlist[d].group_type_code_value,
        pa.sequence_nbr = 1, pa.no_gt_on_prsn_flag = request->dlist[d].crossmatch_dispense_flag, pa
        .no_gt_autodir_prsn_flag = request->dlist[d].auto_direct_flag,
        pa.disp_no_curraborh_prsn_flag = request->dlist[d].dispense_curr_aborh_flag, pa
        .aborh_option_flag = request->dlist[d].aborh_ind, pa.active_ind = 1,
        pa.active_status_cd = active_cd, pa.active_status_prsnl_id = reqinfo->updt_id, pa
        .active_status_dt_tm = null,
        pa.updt_id = reqinfo->updt_id, pa.updt_cnt = 0, pa.updt_dt_tm = cnvtdatetime(curdate,curtime),
        pa.updt_task = reqinfo->updt_task, pa.updt_applctx = reqinfo->updt_applctx
       PLAN (pa)
       WITH nocounter
      ;end insert
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = "Y"
       GO TO exit_script
      ENDIF
     ENDIF
   ENDFOR
  ELSEIF ((request->dlist[d].action_flag=2))
   IF (size(request->dlist[d].prod_list,5) > 0)
    SET ierrcode = 0
    UPDATE  FROM product_aborh pa,
      (dummyt d  WITH seq = value(size(request->dlist[d].prod_list,5)))
     SET pa.seq = 1, pa.no_gt_on_prsn_flag = request->dlist[d].crossmatch_dispense_flag, pa
      .no_gt_autodir_prsn_flag = request->dlist[d].auto_direct_flag,
      pa.disp_no_curraborh_prsn_flag = request->dlist[d].dispense_curr_aborh_flag, pa
      .aborh_option_flag = request->dlist[d].aborh_ind, pa.updt_id = reqinfo->updt_id,
      pa.updt_cnt = (pa.updt_cnt+ 1), pa.updt_dt_tm = cnvtdatetime(curdate,curtime), pa.updt_task =
      reqinfo->updt_task,
      pa.updt_applctx = reqinfo->updt_applctx
     PLAN (d)
      JOIN (pa
      WHERE (pa.product_cd=request->dlist[d].prod_list[d.seq].product_code_value)
       AND (pa.product_aborh_cd=request->dlist[d].group_type_code_value))
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = "Y"
     GO TO exit_script
    ENDIF
   ENDIF
  ELSEIF ((request->dlist[d].action_flag=3))
   IF (size(request->dlist[d].prod_list,5) > 0)
    SET ierrcode = 0
    UPDATE  FROM product_aborh pa,
      (dummyt d  WITH seq = value(size(request->dlist[d].prod_list,5)))
     SET pa.seq = 1, pa.active_ind = 0, pa.active_status_cd = inactive_cd,
      pa.active_status_dt_tm = cnvtdatetime(curdate,curtime), pa.active_status_prsnl_id = reqinfo->
      updt_id, pa.updt_id = reqinfo->updt_id,
      pa.updt_cnt = (pa.updt_cnt+ 1), pa.updt_dt_tm = cnvtdatetime(curdate,curtime), pa.updt_task =
      reqinfo->updt_task,
      pa.updt_applctx = reqinfo->updt_applctx
     PLAN (d)
      JOIN (pa
      WHERE (pa.product_cd=request->dlist[d].prod_list[d.seq].product_code_value)
       AND (pa.product_aborh_cd=request->dlist[d].group_type_code_value))
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = "Y"
     GO TO exit_script
    ENDIF
   ENDIF
  ENDIF
  FOR (x = 1 TO size(request->dlist[d].prsn_list,5))
    IF ((request->dlist[d].prsn_list[x].action_flag=1))
     FOR (q = 1 TO size(request->dlist[d].prod_list,5))
       IF ((request->dlist[d].prsn_list[x].aborh_flag=0))
        SET failed = "Y"
        GO TO exit_script
       ENDIF
       SET ppa_seq = 0
       SELECT INTO "nl:"
        FROM product_patient_aborh ppa
        PLAN (ppa
         WHERE (ppa.product_cd=request->dlist[d].prod_list[q].product_code_value)
          AND (ppa.prod_aborh_cd=request->dlist[d].group_type_code_value)
          AND (ppa.prsn_aborh_cd=request->dlist[d].prsn_list[x].prsn_group_type_code_value))
        ORDER BY ppa.sequence_nbr
        DETAIL
         ppa_seq = ppa.sequence_nbr
        WITH nocounter
       ;end select
       SET ppa_seq = (ppa_seq+ 1)
       SET ierrcode = 0
       INSERT  FROM product_patient_aborh ppa
        SET ppa.seq = 1, ppa.product_cd = request->dlist[d].prod_list[q].product_code_value, ppa
         .prod_aborh_cd = request->dlist[d].group_type_code_value,
         ppa.prsn_aborh_cd = request->dlist[d].prsn_list[x].prsn_group_type_code_value, ppa
         .sequence_nbr = ppa_seq, ppa.warn_ind =
         IF ((request->dlist[d].prsn_list[x].aborh_flag=1)) 0
         ELSEIF ((request->dlist[d].prsn_list[x].aborh_flag=2)) 1
         ENDIF
         ,
         ppa.active_ind = 1, ppa.active_status_cd = active_cd, ppa.active_status_prsnl_id = reqinfo->
         updt_id,
         ppa.active_status_dt_tm = null, ppa.updt_id = reqinfo->updt_id, ppa.updt_cnt = 0,
         ppa.updt_dt_tm = cnvtdatetime(curdate,curtime), ppa.updt_task = reqinfo->updt_task, ppa
         .updt_applctx = reqinfo->updt_applctx
        PLAN (ppa)
        WITH nocounter
       ;end insert
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET failed = "Y"
        GO TO exit_script
       ENDIF
     ENDFOR
    ELSEIF ((request->dlist[d].prsn_list[x].action_flag=2))
     IF ((request->dlist[d].prsn_list[x].aborh_flag=0))
      SET failed = "Y"
      GO TO exit_script
     ENDIF
     IF (size(request->dlist[d].prod_list,5) > 0)
      SET ierrcode = 0
      UPDATE  FROM product_patient_aborh ppa,
        (dummyt d  WITH seq = value(size(request->dlist[d].prod_list,5)))
       SET ppa.seq = 1, ppa.warn_ind =
        IF ((request->dlist[d].prsn_list[x].aborh_flag=1)) 0
        ELSEIF ((request->dlist[d].prsn_list[x].aborh_flag=2)) 1
        ENDIF
        , ppa.updt_id = reqinfo->updt_id,
        ppa.updt_cnt = (ppa.updt_cnt+ 1), ppa.updt_dt_tm = cnvtdatetime(curdate,curtime), ppa
        .updt_task = reqinfo->updt_task,
        ppa.updt_applctx = reqinfo->updt_applctx
       PLAN (d)
        JOIN (ppa
        WHERE (ppa.product_cd=request->dlist[d].prod_list[d.seq].product_code_value)
         AND (ppa.prod_aborh_cd=request->dlist[d].group_type_code_value)
         AND (ppa.prsn_aborh_cd=request->dlist[d].prsn_list[x].prsn_group_type_code_value))
       WITH nocounter
      ;end update
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = "Y"
       GO TO exit_script
      ENDIF
     ENDIF
    ELSEIF ((request->dlist[d].prsn_list[x].action_flag=3))
     IF (size(request->dlist[d].prod_list,5) > 0)
      SET ierrcode = 0
      UPDATE  FROM product_patient_aborh ppa,
        (dummyt d  WITH seq = value(size(request->dlist[d].prod_list,5)))
       SET ppa.seq = 1, ppa.active_ind = 0, ppa.active_status_cd = inactive_cd,
        ppa.active_status_dt_tm = cnvtdatetime(curdate,curtime), ppa.active_status_prsnl_id = reqinfo
        ->updt_id, ppa.updt_id = reqinfo->updt_id,
        ppa.updt_cnt = (ppa.updt_cnt+ 1), ppa.updt_dt_tm = cnvtdatetime(curdate,curtime), ppa
        .updt_task = reqinfo->updt_task,
        ppa.updt_applctx = reqinfo->updt_applctx
       PLAN (d)
        JOIN (ppa
        WHERE (ppa.product_cd=request->dlist[d].prod_list[d.seq].product_code_value)
         AND (ppa.prod_aborh_cd=request->dlist[d].group_type_code_value)
         AND (ppa.prsn_aborh_cd=request->dlist[d].prsn_list[x].prsn_group_type_code_value))
       WITH nocounter
      ;end update
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = "Y"
       GO TO exit_script
      ENDIF
     ENDIF
    ENDIF
  ENDFOR
 ENDFOR
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
