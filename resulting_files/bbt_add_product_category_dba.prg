CREATE PROGRAM bbt_add_product_category:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c15
       3 sourceobjectqual = i4
       3 sourceobjectvalue = c50
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c50
       3 sub_event_dt_tm = di8
 )
 SET reply->status_data.status = "F"
 SET nbr_to_add = size(request->qual,5)
 SET seqnbr = 0
 SET y = 0
 SET idx = 0
 SET failed = "F"
 SET auth_data_status_cd = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=8
   AND cv.cdf_meaning="AUTH"
   AND cv.active_ind=1
   AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   auth_data_status_cd = cv.code_value
  WITH nocounter
 ;end select
 FOR (idx = 1 TO nbr_to_add)
   SET next_code = 0.0
   EXECUTE cpm_next_code
   INSERT  FROM code_value c
    SET c.code_value = next_code, c.code_set = 1605, c.display = request->qual[idx].product_cat_disp,
     c.display_key = cnvtupper(cnvtalphanum(request->qual[idx].product_cat_disp)), c.description =
     request->qual[idx].product_cat_desc, c.definition = request->qual[idx].product_cat_desc,
     c.active_ind = request->qual[idx].active_ind, c.active_type_cd = reqdata->active_status_cd, c
     .active_dt_tm = cnvtdatetime(curdate,curtime3),
     c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = reqinfo->updt_id,
     c.updt_applctx = reqinfo->updt_applctx, c.updt_task = reqinfo->updt_task, c
     .begin_effective_dt_tm = cnvtdatetime(curdate,curtime3),
     c.end_effective_dt_tm = cnvtdatetime("31-DEC-2100:00:00:00.00"), c.data_status_cd =
     auth_data_status_cd, c.data_status_dt_tm = cnvtdatetime(curdate,curtime3),
     c.data_status_prsnl_id = reqinfo->updt_id, c.active_status_prsnl_id = reqinfo->updt_id
    WITH counter
   ;end insert
   IF (curqual=0)
    SET y = (y+ 1)
    IF (y > 1)
     SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[y].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[y].sourceobjectvalue = "bbt_add_prod_categ"
    SET reply->status_data.subeventstatus[y].operationname = "insert"
    SET reply->status_data.subeventstatus[y].operationstatus = "F"
    SET reply->status_data.subeventstatus[y].targetobjectname = "product_category"
    SET reply->status_data.subeventstatus[y].targetobjectvalue = "codeset"
    SET reply->status_data.subeventstatus[y].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[y].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    SET failed = "T"
   ELSE
    INSERT  FROM product_category p
     SET p.product_class_cd = request->qual[idx].product_class_cd, p.product_cat_cd = next_code, p
      .crossmatch_tag_ind = request->qual[idx].crossmatch_tag_ind,
      p.component_tag_ind = request->qual[idx].component_tag_ind, p.pilot_label_ind = request->qual[
      idx].pilot_label_ind, p.rh_required_ind = request->qual[idx].rh_required_ind,
      p.confirm_required_ind = request->qual[idx].confirm_required_ind, p.red_cell_product_ind =
      request->qual[idx].red_cell_product_ind, p.xmatch_required_ind = request->qual[idx].
      xmatch_required_ind,
      p.default_unit_measure_cd = request->qual[idx].default_unit_measure_cd, p.default_vis_insp_cd
       = request->qual[idx].default_vis_insp_cd, p.default_ship_cond_cd = request->qual[idx].
      default_ship_cond_cd,
      p.prompt_vol_ind = request->qual[idx].prompt_vol_ind, p.prompt_segment_ind = request->qual[idx]
      .prompt_segment_ind, p.prompt_alternate_ind = request->qual[idx].prompt_alternate_ind,
      p.special_testing_ind = request->qual[idx].special_testing_ind, p.valid_aborh_compat_ind =
      request->qual[idx].valid_aborh_compat_ind, p.active_ind = request->qual[idx].active_ind,
      p.active_status_cd = reqdata->active_status_cd, p.active_status_dt_tm = cnvtdatetime(curdate,
       curtime3), p.active_status_prsnl_id = reqinfo->updt_id,
      p.updt_cnt = 0, p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id,
      p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->updt_task, p
      .donor_label_aborh_cnt = request->qual[idx].donor_label_aborh_cnt
     WITH counter
    ;end insert
    IF (curqual=0)
     SET y = (y+ 1)
     IF (y > 1)
      SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
     ENDIF
     SET reply->status_data.subeventstatus[y].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[y].sourceobjectvalue = "bbt_add_product_category"
     SET reply->status_data.subeventstatus[y].operationname = "insert"
     SET reply->status_data.subeventstatus[y].operationstatus = "F"
     SET reply->status_data.subeventstatus[y].targetobjectname = "product_category"
     SET reply->status_data.subeventstatus[y].targetobjectvalue = request->qual[idx].product_cat_disp
     SET reply->status_data.subeventstatus[y].sourceobjectqual = 1
     SET reply->status_data.subeventstatus[y].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
     SET failed = "T"
    ENDIF
   ENDIF
 ENDFOR
 IF (failed="T")
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "Z"
  SET reply->status_data.operationname = "read"
  SET reply->status_data.operationstatus = "F"
  SET reply->status_data.targetobjectname = "table"
  SET reply->status_data.targetobjectvalue = "product_category"
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
