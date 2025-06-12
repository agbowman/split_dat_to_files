CREATE PROGRAM bbt_chg_product_category:dba
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
 SET nbr_to_chg = size(request->qual,5)
 SET seqnbr = 0
 SET y = 0
 SET idx = 0
 SET failed = "F"
 SET cur_updt_cnt = 0
 SET cur_active_ind = 1
 SET cur_category_disp = fillstring(40," ")
 SET cur_category_desc = fillstring(60," ")
 FOR (idx = 1 TO nbr_to_chg)
   SELECT INTO "nl:"
    FROM code_value c
    WHERE (c.code_value=request->qual[idx].product_cat_cd)
     AND c.code_set=1605
    DETAIL
     cur_active_ind = c.active_ind, cur_category_disp = c.display, cur_category_desc = c.description
    WITH nocounter
   ;end select
   IF (((curqual=0) OR (cur_active_ind=0)) )
    SET y = (y+ 1)
    IF (y > 1)
     SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[y].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[y].sourceobjectvalue = "bbt_chg_prod_categ"
    SET reply->status_data.subeventstatus[y].operationname = "SELECT"
    SET reply->status_data.subeventstatus[y].operationstatus = "F"
    SET reply->status_data.subeventstatus[y].targetobjectname = "product_category"
    SET reply->status_data.subeventstatus[y].targetobjectvalue = "codeset"
    SET reply->status_data.subeventstatus[y].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[y].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    SET failed = "T"
    GO TO exit_program
   ENDIF
   IF ((((cur_category_disp != request->qual[idx].product_cat_disp)) OR ((cur_category_desc !=
   request->qual[idx].product_cat_desc))) )
    SET cur_active_ind = 1
    SELECT INTO "nl:"
     FROM code_value c
     WHERE (code_value=request->qual[idx].product_cat_cd)
      AND code_set=1605
     DETAIL
      cur_active_ind = c.active_ind
     WITH nocounter, forupdate(c)
    ;end select
    IF (((curqual=0) OR (cur_active_ind=0)) )
     SET y = (y+ 1)
     IF (y > 1)
      SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
     ENDIF
     SET reply->status_data.subeventstatus[y].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[y].sourceobjectvalue = "bbt_chg_prod_categ"
     SET reply->status_data.subeventstatus[y].operationname = "SELECT FOR UPDATE"
     SET reply->status_data.subeventstatus[y].operationstatus = "F"
     SET reply->status_data.subeventstatus[y].targetobjectname = "product_category"
     SET reply->status_data.subeventstatus[y].targetobjectvalue = "codeset"
     SET reply->status_data.subeventstatus[y].sourceobjectqual = 1
     SET reply->status_data.subeventstatus[y].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
     SET failed = "T"
     GO TO exit_program
    ENDIF
    UPDATE  FROM code_value
     SET display = request->qual[idx].product_cat_disp, display_key = cnvtupper(cnvtalphanum(request
        ->qual[idx].product_cat_disp)), description = request->qual[idx].product_cat_desc,
      definition = request->qual[idx].product_cat_desc, updt_cnt = (updt_cnt+ 1), updt_dt_tm =
      cnvtdatetime(curdate,curtime),
      updt_id = reqinfo->updt_id, updt_applctx = reqinfo->updt_applctx, updt_task = reqinfo->
      updt_task
     WHERE (code_value=request->qual[idx].product_cat_cd)
     WITH counter
    ;end update
    IF (curqual=0)
     SET y = (y+ 1)
     IF (y > 1)
      SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
     ENDIF
     SET reply->status_data.subeventstatus[y].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[y].sourceobjectvalue = "bbt_chg_prod_categ"
     SET reply->status_data.subeventstatus[y].operationname = "CHANGE"
     SET reply->status_data.subeventstatus[y].operationstatus = "F"
     SET reply->status_data.subeventstatus[y].targetobjectname = "code_value"
     SET reply->status_data.subeventstatus[y].targetobjectvalue = "codeset"
     SET reply->status_data.subeventstatus[y].sourceobjectqual = 1
     SET reply->status_data.subeventstatus[y].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
     SET failed = "T"
     GO TO exit_program
    ENDIF
   ENDIF
   SET cur_active_ind = 1
   SELECT INTO "nl:"
    FROM product_category p
    WHERE (p.product_cat_cd=request->qual[idx].product_cat_cd)
     AND (p.product_class_cd=request->qual[idx].product_class_cd)
    DETAIL
     cur_updt_cnt = p.updt_cnt, cur_active_ind = p.active_ind
    WITH nocounter, forupdate(product_category)
   ;end select
   IF (((curqual=0) OR (((cur_active_ind=0) OR ((cur_updt_cnt != request->qual[idx].
   product_cat_updt_cnt))) )) )
    SET y = (y+ 1)
    IF (y > 1)
     SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[y].operationname = "SELECT"
    SET reply->status_data.subeventstatus[y].operationstatus = "F"
    SET reply->status_data.subeventstatus[y].targetobjectname = "product_category"
    SET reply->status_data.subeventstatus[y].targetobjectvalue = "table"
    SET reply->status_data.subeventstatus[y].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    SET failed = "T"
    GO TO exit_program
   ENDIF
   UPDATE  FROM product_category p
    SET p.crossmatch_tag_ind = request->qual[idx].crossmatch_tag_ind, p.component_tag_ind = request->
     qual[idx].component_tag_ind, p.pilot_label_ind = request->qual[idx].pilot_label_ind,
     p.rh_required_ind = request->qual[idx].rh_required_ind, p.confirm_required_ind = request->qual[
     idx].confirm_required_ind, p.red_cell_product_ind = request->qual[idx].red_cell_product_ind,
     p.xmatch_required_ind = request->qual[idx].xmatch_required_ind, p.default_unit_measure_cd =
     request->qual[idx].default_unit_measure_cd, p.default_vis_insp_cd = request->qual[idx].
     default_vis_insp_cd,
     p.default_ship_cond_cd = request->qual[idx].default_ship_cond_cd, p.prompt_vol_ind = request->
     qual[idx].prompt_vol_ind, p.prompt_segment_ind = request->qual[idx].prompt_segment_ind,
     p.prompt_alternate_ind = request->qual[idx].prompt_alternate_ind, p.special_testing_ind =
     request->qual[idx].special_testing_ind, p.valid_aborh_compat_ind = request->qual[idx].
     valid_aborh_compat_ind,
     p.storage_temp_cd = request->qual[idx].storage_temp_cd, p.updt_dt_tm = cnvtdatetime(curdate,
      curtime3), p.updt_id = reqinfo->updt_id,
     p.updt_cnt = (p.updt_cnt+ 1), p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
     updt_applctx,
     p.donor_label_aborh_cnt = request->qual[idx].donor_label_aborh_cnt
    WHERE (p.product_class_cd=request->qual[idx].product_class_cd)
     AND (p.product_cat_cd=request->qual[idx].product_cat_cd)
    WITH counter
   ;end update
   IF (curqual=0)
    SET y = (y+ 1)
    IF (y > 1)
     SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[y].operationname = "change"
    SET reply->status_data.subeventstatus[y].operationstatus = "F"
    SET reply->status_data.subeventstatus[y].targetobjectname = "product_category"
    SET reply->status_data.subeventstatus[y].targetobjectvalue = request->qual[idx].product_cat_disp
    SET reply->status_data.subeventstatus[y].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    SET failed = "T"
    GO TO exit_program
   ENDIF
 ENDFOR
#exit_program
 IF (failed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
