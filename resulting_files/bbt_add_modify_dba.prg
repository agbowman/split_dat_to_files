CREATE PROGRAM bbt_add_modify:dba
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
 SET nbr_to_add = size(request->qual,5)
 SET y = 0
 SET idx = 0
 SET failed = "F"
 SET option_id_save = 0
 SET index = 0
 SET nbr_add_device = size(request->add_device_qual,5)
 SET next_code = 0.0
 EXECUTE cpm_next_code
 SET option_id_save = next_code
 INSERT  FROM modify_option m
  SET m.option_id = next_code, m.orig_product_cd = request->orig_product_cd, m.description = request
   ->description,
   m.bag_type_cd = request->bag_type_cd, m.dispose_orig_ind = request->dispose_orig_ind, m
   .orig_nbr_days_exp = request->orig_nbr_days_exp,
   m.orig_nbr_hrs_exp = request->orig_nbr_hrs_exp, m.validate_vol_ind = request->validate_vol_ind, m
   .allow_extend_exp_ind = request->allow_extend_exp_ind,
   m.calc_exp_drawn_ind = request->calc_exp_drawn_ind, m.chg_orig_exp_dt_ind = request->
   chg_orig_exp_dt_ind, m.bag_type_valid_ind = request->bag_type_valid_ind,
   m.division_type_flag = request->division_type_flag, m.crossover_reason_cd = request->
   crossover_reason_cd, m.active_ind = request->active_ind,
   m.active_status_cd = 0, m.active_status_dt_tm = cnvtdatetime(curdate,curtime3), m
   .active_status_prsnl_id = reqinfo->updt_id,
   m.updt_cnt = 0, m.updt_dt_tm = cnvtdatetime(curdate,curtime3), m.updt_id = reqinfo->updt_id,
   m.updt_task = reqinfo->updt_task, m.updt_applctx = reqinfo->updt_applctx
  WITH counter
 ;end insert
 IF (curqual=0)
  SET failed = "T"
 ENDIF
 IF (failed="T")
  SET reply->status_data.status = "Z"
  SET reply->status_data.operationname = "add"
  SET reply->status_data.operationstatus = "F"
  SET reply->status_data.targetobjectname = "modify_option"
  SET reply->status_data.targetobjectvalue = "modify option not added"
  ROLLBACK
  GO TO end_script
 ENDIF
 FOR (idx = 1 TO nbr_to_add)
   IF ((request->division_type_flag=3))
    SET next_code = 0.0
    EXECUTE cpm_next_code
    INSERT  FROM modify_option_testing o
     SET o.option_id = option_id_save, o.modify_option_tst_id = next_code, o.new_product_cd = request
      ->qual[idx].new_product_cd,
      o.default_exp_days = request->qual[idx].default_exp_days, o.default_exp_hrs = request->qual[idx
      ].default_exp_hrs, o.max_prep_hrs = request->qual[idx].max_prep_hrs,
      o.special_testing_cd = request->qual[idx].special_testing_cd, o.calc_exp_drawn_ind = request->
      qual[idx].calc_exp_drawn_ind, o.active_ind = request->qual[idx].active_ind,
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
    INSERT  FROM new_product n
     SET n.option_id = option_id_save, n.new_product_cd = request->qual[idx].new_product_cd, n
      .default_exp_days = request->qual[idx].default_exp_days,
      n.default_exp_hrs = request->qual[idx].default_exp_hrs, n.sub_prod_id_flag = request->qual[idx]
      .sub_prod_id_flag, n.max_prep_hrs = request->qual[idx].max_prep_hrs,
      n.synonym_id = request->qual[idx].synonym_id, n.quantity = request->qual[idx].quantity, n
      .default_volume = request->qual[idx].default_volume,
      n.default_unit_measure_cd = request->qual[idx].default_unit_measure_cd, n.default_volume_ind =
      request->qual[idx].default_volume_ind, n.default_measure_ind = request->qual[idx].
      default_unit_measure_ind,
      n.dflt_orig_volume_ind = request->qual[idx].dflt_orig_volume_ind, n.active_ind = request->qual[
      idx].active_ind, n.active_status_cd = 0,
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
    SET m.option_device_id = new_pathnet_seq, m.option_id = option_id_save, m.device_type_cd =
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
#row_failed
 IF (failed="T")
  SET reply->status_data.status = "Z"
  SET reply->status_data.operationname = "add"
  SET reply->status_data.operationstatus = "F"
  SET reply->status_data.targetobjectname = "new_product or modify_option_testing"
  SET reply->status_data.targetobjectvalue = "row not added"
  ROLLBACK
  GO TO end_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 COMMIT
#end_script
END GO
