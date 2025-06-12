CREATE PROGRAM bbt_chg_modify:dba
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
 SET nbr_to_chg = size(request->qual,5)
 SET y = 0
 SET idx = 0
 SET failed = "F"
 SET mod_updt_cnt = 0
 SET mod_active_ind = 0
 SET mod_active_dt_tm = cnvtdatetime(curdate,curtime3)
 SET mod_inactive_dt_tm = cnvtdatetime(curdate,curtime3)
 SET prod_updt_cnt = 0
 SET prod_active_ind = 0
 SET prod_active_dt_tm = cnvtdatetime(curdate,curtime3)
 SET prod_inactive_dt_tm = cnvtdatetime(curdate,curtime3)
 SET nbr_add_device = size(request->add_device_qual,5)
 SET nbr_updt_device = size(request->update_device_qual,5)
 SET index = 0
 SET active_status_cd = 0
 SET mod2_updt_cnt = 0
 IF ((request->option_changed=1))
  SELECT INTO "nl:"
   m.option_id
   FROM modify_option m
   WHERE (m.option_id=request->option_id)
   DETAIL
    mod_active_ind = m.active_ind, mod_updt_cnt = m.updt_cnt, mod_active_dt_tm = m
    .active_status_dt_tm
   WITH nocounter, forupdate(m)
  ;end select
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.operationname = "lock"
   SET reply->status_data.operationstatus = "F"
   SET reply->status_data.targetobjectname = "Modify Option"
   SET reply->status_data.targetobjectvalue = "Lock failed"
  ENDIF
  IF ((request->updt_cnt != mod_updt_cnt))
   SET failed = "T"
   SET reply->status_data.operationname = "change"
   SET reply->status_data.operationstatus = "F"
   SET reply->status_data.targetobjectname = "Modify Option"
   SET reply->status_data.targetobjectvalue = "Update count mismatch"
  ELSE
   UPDATE  FROM modify_option m
    SET m.orig_product_cd = request->orig_product_cd, m.bag_type_cd = request->bag_type_cd, m
     .dispose_orig_ind = request->dispose_orig_ind,
     m.orig_nbr_days_exp = request->orig_nbr_days_exp, m.orig_nbr_hrs_exp = request->orig_nbr_hrs_exp,
     m.validate_vol_ind = request->validate_vol_ind,
     m.allow_extend_exp_ind = request->allow_extend_exp_ind, m.calc_exp_drawn_ind = request->
     calc_exp_drawn_ind, m.chg_orig_exp_dt_ind = request->chg_orig_exp_dt_ind,
     m.bag_type_valid_ind = request->bag_type_valid_ind, m.division_type_flag = request->
     division_type_flag, m.crossover_reason_cd = request->crossover_reason_cd,
     m.active_ind = request->active_ind, m.active_status_cd = 0, m.active_status_dt_tm = cnvtdatetime
     (curdate,curtime3),
     m.active_status_prsnl_id = reqinfo->updt_id, m.updt_cnt = (m.updt_cnt+ 1), m.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     m.updt_id = reqinfo->updt_id, m.updt_task = reqinfo->updt_task, m.updt_applctx = reqinfo->
     updt_applctx
    WHERE (m.option_id=request->option_id)
    WITH counter
   ;end update
   IF (curqual=0)
    SET failed = "T"
   ENDIF
   IF (failed="T")
    SET reply->status_data.status = "Z"
    SET reply->status_data.operationname = "change"
    SET reply->status_data.operationstatus = "F"
    SET reply->status_data.targetobjectname = "modify_option"
    SET reply->status_data.targetobjectvalue = "update failed"
    ROLLBACK
    GO TO end_script
   ENDIF
  ENDIF
 ENDIF
 FOR (idx = 1 TO nbr_to_chg)
   IF ((request->qual[idx].product_changed=1))
    IF ((request->division_type_flag=3))
     IF ((request->qual[idx].add_product=1))
      SET next_code = 0.0
      EXECUTE cpm_next_code
      INSERT  FROM modify_option_testing o
       SET o.option_id = request->option_id, o.modify_option_tst_id = next_code, o.new_product_cd =
        request->qual[idx].new_product_cd,
        o.default_exp_days = request->qual[idx].default_exp_days, o.default_exp_hrs = request->qual[
        idx].default_exp_hrs, o.max_prep_hrs = request->qual[idx].max_prep_hrs,
        o.calc_exp_drawn_ind = request->qual[idx].calc_exp_drawn_ind, o.special_testing_cd = request
        ->qual[idx].special_testing_cd, o.active_ind = request->qual[idx].active_ind,
        o.active_status_cd = 0, o.active_status_dt_tm = cnvtdatetime(curdate,curtime3), o
        .active_status_prsnl_id = reqinfo->updt_id,
        o.updt_cnt = 0, o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id,
        o.updt_task = reqinfo->updt_task, o.updt_applctx = reqinfo->updt_applctx
       WITH counter
      ;end insert
      IF (curqual=0)
       SET y = (y+ 1)
       IF (y > 1)
        SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
       ENDIF
       SET reply->status_data.subeventstatus[y].operationname = "insert"
       SET reply->status_data.subeventstatus[y].operationstatus = "F"
       SET reply->status_data.subeventstatus[y].targetobjectname = "modify_option_testing"
       SET reply->status_data.subeventstatus[y].targetobjectvalue = request->qual[idx].
       special_testing_cd
       SET failed = "T"
       GO TO row_failed
      ENDIF
     ELSE
      SELECT INTO "nl:"
       o.option_id, o.new_product_cd
       FROM modify_option_testing o
       WHERE (o.option_id=request->option_id)
        AND (o.special_testing_cd=request->qual[idx].special_testing_cd)
       DETAIL
        prod_active_ind = o.active_ind, prod_updt_cnt = o.updt_cnt, prod_active_dt_tm = o
        .active_status_dt_tm
       WITH nocounter, forupdate(o)
      ;end select
      IF (curqual=0)
       SET failed = "T"
       SET y = (y+ 1)
       IF (y > 1)
        SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
       ENDIF
       SET reply->status_data.subeventstatus[y].operationname = "lock"
       SET reply->status_data.subeventstatus[y].operationstatus = "F"
       SET reply->status_data.subeventstatus[y].targetobjectname = "MODIFY OPTION TESTING"
       SET reply->status_data.subeventstatus[y].targetobjectvalue = "Lock failed"
      ENDIF
      IF ((request->qual[idx].updt_cnt != prod_updt_cnt))
       SET failed = "T"
       SET reply->status_data.operationname = "change"
       SET reply->status_data.operationstatus = "F"
       SET reply->status_data.targetobjectname = "Modify Option Testing"
       SET reply->status_data.targetobjectvalue = "Update count mismatch"
      ELSE
       UPDATE  FROM modify_option_testing o
        SET o.default_exp_days = request->qual[idx].default_exp_days, o.default_exp_hrs = request->
         qual[idx].default_exp_hrs, o.max_prep_hrs = request->qual[idx].max_prep_hrs,
         o.active_ind = request->qual[idx].active_ind, o.calc_exp_drawn_ind = request->qual[idx].
         calc_exp_drawn_ind, o.special_testing_cd = request->qual[idx].special_testing_cd,
         o.active_status_cd = 0, o.active_status_dt_tm = cnvtdatetime(curdate,curtime3), o
         .active_status_prsnl_id = reqinfo->updt_id,
         o.updt_cnt = (o.updt_cnt+ 1), o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id =
         reqinfo->updt_id,
         o.updt_task = reqinfo->updt_task, o.updt_applctx = reqinfo->updt_applctx
        WHERE (o.special_testing_cd=request->qual[idx].special_testing_cd)
         AND (o.option_id=request->option_id)
        WITH counter
       ;end update
       IF (curqual=0)
        SET y = (y+ 1)
        IF (y > 1)
         SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
        ENDIF
        SET reply->status_data.subeventstatus[y].operationname = "change"
        SET reply->status_data.subeventstatus[y].operationstatus = "F"
        SET reply->status_data.subeventstatus[y].targetobjectname = "modify option testing"
        SET reply->status_data.subeventstatus[y].targetobjectvalue = request->qual[idx].
        special_testing_cd
        SET failed = "T"
        GO TO row_failed
       ENDIF
      ENDIF
     ENDIF
    ELSE
     IF ((request->qual[idx].add_product=1))
      INSERT  FROM new_product n
       SET n.option_id = request->option_id, n.new_product_cd = request->qual[idx].new_product_cd, n
        .default_exp_days = request->qual[idx].default_exp_days,
        n.default_exp_hrs = request->qual[idx].default_exp_hrs, n.sub_prod_id_flag = request->qual[
        idx].sub_prod_id_flag, n.max_prep_hrs = request->qual[idx].max_prep_hrs,
        n.synonym_id = request->qual[idx].synonym_id, n.quantity = request->qual[idx].quantity, n
        .default_volume = request->qual[idx].default_volume,
        n.default_volume_ind = request->qual[idx].default_volume_ind, n.default_measure_ind = request
        ->qual[idx].default_unit_measure_ind, n.default_unit_measure_cd = request->qual[idx].
        default_unit_measure_cd,
        n.dflt_orig_volume_ind = request->qual[idx].dflt_orig_volume_ind, n.active_ind = request->
        qual[idx].active_ind, n.active_status_cd = 0,
        n.active_status_dt_tm = cnvtdatetime(curdate,curtime3), n.active_status_prsnl_id = reqinfo->
        updt_id, n.updt_cnt = 0,
        n.updt_dt_tm = cnvtdatetime(curdate,curtime3), n.updt_id = reqinfo->updt_id, n.updt_task =
        reqinfo->updt_task,
        n.updt_applctx = reqinfo->updt_applctx
       WITH counter
      ;end insert
      IF (curqual=0)
       SET y = (y+ 1)
       IF (y > 1)
        SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
       ENDIF
       SET reply->status_data.subeventstatus[y].operationname = "insert"
       SET reply->status_data.subeventstatus[y].operationstatus = "F"
       SET reply->status_data.subeventstatus[y].targetobjectname = "new_product"
       SET reply->status_data.subeventstatus[y].targetobjectvalue = request->qual[idx].new_product_cd
       SET failed = "T"
       GO TO row_failed
      ENDIF
     ELSE
      SELECT INTO "nl:"
       p.option_id, p.new_product_cd
       FROM new_product p
       WHERE (p.option_id=request->option_id)
        AND (p.new_product_cd=request->qual[idx].new_product_cd)
       DETAIL
        prod_active_ind = p.active_ind, prod_updt_cnt = p.updt_cnt, prod_active_dt_tm = p
        .active_status_dt_tm
       WITH nocounter, forupdate(p)
      ;end select
      IF (curqual=0)
       SET failed = "T"
       SET y = (y+ 1)
       IF (y > 1)
        SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
       ENDIF
       SET reply->status_data.subeventstatus[y].operationname = "lock"
       SET reply->status_data.subeventstatus[y].operationstatus = "F"
       SET reply->status_data.subeventstatus[y].targetobjectname = "New Product"
       SET reply->status_data.subeventstatus[y].targetobjectvalue = "Lock failed"
      ENDIF
      IF ((request->qual[idx].updt_cnt != prod_updt_cnt))
       SET failed = "T"
       SET reply->status_data.operationname = "change"
       SET reply->status_data.operationstatus = "F"
       SET reply->status_data.targetobjectname = "New Product"
       SET reply->status_data.targetobjectvalue = "Update count mismatch"
      ELSE
       UPDATE  FROM new_product n
        SET n.default_exp_days = request->qual[idx].default_exp_days, n.default_exp_hrs = request->
         qual[idx].default_exp_hrs, n.sub_prod_id_flag = request->qual[idx].sub_prod_id_flag,
         n.max_prep_hrs = request->qual[idx].max_prep_hrs, n.synonym_id = request->qual[idx].
         synonym_id, n.active_ind = request->qual[idx].active_ind,
         n.quantity = request->qual[idx].quantity, n.default_volume = request->qual[idx].
         default_volume, n.default_volume_ind = request->qual[idx].default_volume_ind,
         n.default_measure_ind = request->qual[idx].default_unit_measure_ind, n
         .default_unit_measure_cd = request->qual[idx].default_unit_measure_cd, n
         .dflt_orig_volume_ind = request->qual[idx].dflt_orig_volume_ind,
         n.active_status_cd = 0, n.active_status_dt_tm = cnvtdatetime(curdate,curtime3), n
         .active_status_prsnl_id = reqinfo->updt_id,
         n.updt_cnt = (n.updt_cnt+ 1), n.updt_dt_tm = cnvtdatetime(curdate,curtime3), n.updt_id =
         reqinfo->updt_id,
         n.updt_task = reqinfo->updt_task, n.updt_applctx = reqinfo->updt_applctx
        WHERE (n.new_product_cd=request->qual[idx].new_product_cd)
         AND (n.option_id=request->option_id)
        WITH counter
       ;end update
       IF (curqual=0)
        SET y = (y+ 1)
        IF (y > 1)
         SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
        ENDIF
        SET reply->status_data.subeventstatus[y].operationname = "change"
        SET reply->status_data.subeventstatus[y].operationstatus = "F"
        SET reply->status_data.subeventstatus[y].targetobjectname = "new_product"
        SET reply->status_data.subeventstatus[y].targetobjectvalue = request->qual[idx].
        new_product_cd
        SET failed = "T"
        GO TO row_failed
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 FOR (index = 1 TO nbr_add_device)
   DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
   SET new_pathnet_seq = 0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   INSERT  FROM modify_option_device m
    SET m.option_device_id = new_pathnet_seq, m.option_id = request->option_id, m.device_type_cd =
     request->add_device_qual[index].device_type_cd,
     m.active_ind = 1, m.active_status_cd = 0, m.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
     m.active_status_prsnl_id = reqinfo->updt_id, m.updt_cnt = 0, m.updt_dt_tm = cnvtdatetime(curdate,
      curtime3),
     m.updt_id = reqinfo->updt_id, m.updt_task = reqinfo->updt_task, m.updt_applctx = reqinfo->
     updt_applctx,
     m.nbr_of_device = request->add_device_qual[index].nbr_of_device, m.create_dt_tm = cnvtdatetime(
      curdate,curtime3)
    WITH counter
   ;end insert
   IF (curqual=0)
    SET failed = "T"
    SET reply->status_data.status = "F"
    SET reply->status_data.operationname = "insert"
    SET reply->status_data.operationstatus = "F"
    SET reply->status_data.targetobjectname = "table"
    SET reply->status_data.targetobjectvalue = "insert into Modify_Option_Device failed"
    ROLLBACK
    GO TO end_script
   ENDIF
 ENDFOR
 FOR (index = 1 TO nbr_updt_device)
   SELECT INTO "nl:"
    m.option_device_id
    FROM modify_option_device m
    WHERE (m.option_device_id=request->update_device_qual[index].option_device_id)
    DETAIL
     mod2_updt_cnt = m.updt_cnt
    WITH nocounter, forupdate(m)
   ;end select
   IF (curqual=0)
    SET failed = "T"
    SET reply->status_data.status = "F"
    SET reply->status_data.operationname = "lock"
    SET reply->status_data.operationstatus = "F"
    SET reply->status_data.targetobjectname = "table"
    SET reply->status_data.targetobjectvalue = "failed to lock row on MODIFY_OPTION_DEVICE"
    ROLLBACK
    GO TO end_script
   ENDIF
   UPDATE  FROM modify_option_device m
    SET m.nbr_of_device = request->update_device_qual[index].nbr_of_device, m.updt_cnt = (m.updt_cnt
     + 1), m.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     m.updt_id = reqinfo->updt_id, m.updt_task = reqinfo->updt_task, m.updt_applctx = reqinfo->
     updt_applctx
    WHERE (m.option_device_id=request->update_device_qual[index].option_device_id)
    WITH counter
   ;end update
   IF (curqual=0)
    SET failed = "T"
    SET reply->status_data.status = "F"
    SET reply->status_data.operationname = "update"
    SET reply->status_data.operationstatus = "F"
    SET reply->status_data.targetobjectname = "table"
    SET reply->status_data.targetobjectvalue = "failed to add row to MODIFY_OPTON_DEVICE"
    ROLLBACK
    GO TO end_script
   ENDIF
 ENDFOR
#row_failed
 IF (failed="T")
  SET reply->status_data.status = "Z"
  SET reply->status_data.operationname = "change"
  SET reply->status_data.operationstatus = "F"
  SET reply->status_data.targetobjectname = "table"
  SET reply->status_data.targetobjectvalue = "new_product or modify_option_testing"
  ROLLBACK
  GO TO end_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 COMMIT
#end_script
END GO
