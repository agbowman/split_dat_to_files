CREATE PROGRAM bbd_imp_reports:dba
 DECLARE module_cd = f8 WITH protect, noconstant(0.0)
 DECLARE categ_cd = f8 WITH protect, noconstant(0.0)
 DECLARE new_module_categ_id = f8 WITH protect, noconstant(0.0)
 DECLARE new_report_id = f8 WITH protect, noconstant(0.0)
 DECLARE new_categ_report_rel_id = f8 WITH protect, noconstant(0.0)
 DECLARE module_cat_found_id = f8 WITH protect, noconstant(0.0)
 SET max_list = size(requestin->list_0,5)
 SET x = 1
#start_loop
 FOR (x = x TO size(requestin->list_0,5))
   CALL echo("X = ",x)
   IF (x > max_list)
    GO TO exit_script
   ENDIF
   SET report_found_id = 0
   SET report_found = 0
   SELECT INTO "nl:"
    r.report_id
    FROM bb_report_management r
    WHERE r.active_ind=1
     AND r.report_id > 0
     AND cnvtreal(requestin->list_0[x].task_nbr)=r.task_nbr
     AND cnvtreal(requestin->list_0[x].request_nbr)=r.request_nbr
    DETAIL
     report_found_id = r.report_id, report_found = (report_found+ 1)
    WITH nocounter
   ;end select
   SET module_cd = 0
   SET categ_cd = 0
   SET new_report_id = 0
   SET new_module_categ_id = 0
   SET new_categ_report_rel_id = 0
   SELECT INTO "nl:"
    FROM code_value c
    WHERE c.code_set=16049
     AND (c.cdf_meaning=requestin->list_0[x].module_cdf_meaning)
     AND c.active_ind=1
    DETAIL
     module_cd = c.code_value
    WITH counter
   ;end select
   IF (curqual=0)
    SET success = 0
    GO TO next_item
   ENDIF
   SELECT INTO "nl:"
    FROM code_value c
    WHERE c.code_set=16069
     AND (c.cdf_meaning=requestin->list_0[x].categ_cdf_meaning)
     AND c.active_ind=1
    DETAIL
     categ_cd = c.code_value
    WITH counter
   ;end select
   IF (curqual=0)
    SET success = 0
    GO TO next_item
   ENDIF
   SET module_cat_found = 0
   SET module_cat_found_id = 0
   SELECT INTO "nl:"
    m.module_categ_id
    FROM bb_report_mod_cat_r m
    WHERE m.report_module_cd=module_cd
     AND m.report_category_cd=categ_cd
     AND m.active_ind=1
    DETAIL
     module_cat_found = 1, module_cat_found_id = m.module_categ_id
    WITH nocounter
   ;end select
   IF (report_found=0)
    IF (module_cat_found=0)
     SELECT INTO "NL:"
      nextseqnum = seq(pathnet_seq,nextval)
      FROM dual
      DETAIL
       new_module_categ_id = nextseqnum
      WITH format
     ;end select
     IF (new_module_categ_id=0)
      GO TO next_item
     ENDIF
     INSERT  FROM bb_report_mod_cat_r m
      SET m.module_categ_id = new_module_categ_id, m.report_module_cd = module_cd, m
       .report_category_cd = categ_cd,
       m.active_ind = 1, m.active_status_cd = 0, m.active_status_dt_tm = cnvtdatetime(curdate,
        curtime3),
       m.active_status_prsnl_id = 0, m.updt_dt_tm = cnvtdatetime(curdate,curtime3), m.updt_cnt = 0,
       m.updt_task = 0, m.updt_applctx = 0, m.create_dt_tm = cnvtdatetime(curdate,curtime3)
      WITH counter
     ;end insert
     IF (curqual=0)
      SET success = 0
      GO TO next_item
     ENDIF
    ENDIF
    SELECT INTO "NL:"
     nextseqnum = seq(pathnet_seq,nextval)
     FROM dual
     DETAIL
      new_report_id = nextseqnum
     WITH format, counter
    ;end select
    IF (new_report_id=0)
     GO TO next_item
    ENDIF
    INSERT  FROM bb_report_management r
     SET r.report_id = new_report_id, r.report_name = requestin->list_0[x].report_name, r.description
       = requestin->list_0[x].description,
      r.task_nbr = cnvtreal(requestin->list_0[x].task_nbr), r.request_nbr = cnvtreal(requestin->
       list_0[x].request_nbr), r.product_ind = cnvtreal(requestin->list_0[x].product_ind),
      r.patient_ind = cnvtreal(requestin->list_0[x].patient_ind), r.donor_ind = cnvtreal(requestin->
       list_0[x].donor_ind), r.include_donors_ind = cnvtreal(requestin->list_0[x].include_donors_ind),
      r.date_range_ind = cnvtreal(requestin->list_0[x].date_range_ind), r.donatn_level_range_ind =
      cnvtreal(requestin->list_0[x].donation_level_range_ind), r.all_organization_ind = cnvtreal(
       requestin->list_0[x].all_organization_ind),
      r.owner_area_ind = cnvtreal(requestin->list_0[x].owner_area_ind), r.inventory_area_ind =
      cnvtreal(requestin->list_0[x].inventory_area_ind), r.deferral_ind = cnvtreal(requestin->list_0[
       x].deferral_ind),
      r.draw_station_ind = cnvtreal(requestin->list_0[x].draw_station_ind), r.organization_ind =
      cnvtreal(requestin->list_0[x].organization_ind), r.by_organization_ind = cnvtreal(requestin->
       list_0[x].by_organization_ind),
      r.mobile_pref_month_ind = cnvtreal(requestin->list_0[x].mobile_pref_month_ind), r
      .all_location_ind = cnvtreal(requestin->list_0[x].all_location_ind), r.deferral_reasons_ind =
      cnvtreal(requestin->list_0[x].deferral_reasons_ind),
      r.assays_ind = cnvtreal(requestin->list_0[x].assays_ind), r.reinstate_ind = cnvtreal(requestin
       ->list_0[x].reinstate_ind), r.exception_ind = cnvtreal(requestin->list_0[x].exception_ind),
      r.recruit_type_ind = cnvtreal(requestin->list_0[x].recruit_type_ind), r.aborh_ind = cnvtreal(
       requestin->list_0[x].aborh_ind), r.procedure_ind = cnvtreal(requestin->list_0[x].procedure_ind
       ),
      r.antigens_ind = cnvtreal(requestin->list_0[x].antigens_ind), r.recruit_list_ind = cnvtreal(
       requestin->list_0[x].recruit_list_ind), r.race_ind = cnvtreal(requestin->list_0[x].race_ind),
      r.rare_type_ind = cnvtreal(requestin->list_0[x].rare_type_ind), r.special_interest_ind =
      cnvtreal(requestin->list_0[x].special_interest_ind), r.zip_code_ind = cnvtreal(requestin->
       list_0[x].zip_code_ind),
      r.active_ind = 1, r.active_status_dt_tm = cnvtdatetime(curdate,curtime3), r.active_status_cd =
      0,
      r.active_status_prsnl_id = 0, r.updt_cnt = 0, r.updt_task = 0,
      r.updt_applctx = 0, r.updt_dt_tm = cnvtdatetime(curdate,curtime3), r.create_dt_tm =
      cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET success = 0
     GO TO next_item
    ENDIF
    IF (module_cat_found=1)
     SET new_module_categ_id = module_cat_found_id
    ENDIF
    SELECT INTO "NL:"
     nextseqnum = seq(pathnet_seq,nextval)
     FROM dual
     DETAIL
      new_categ_report_rel_id = nextseqnum
     WITH format
    ;end select
    IF (new_categ_report_rel_id=0)
     SET success = 0
     GO TO next_item
    ENDIF
    INSERT  FROM bb_categ_report_r c
     SET c.categ_report_rel_id = new_categ_report_rel_id, c.module_categ_id = new_module_categ_id, c
      .report_id = new_report_id,
      c.active_ind = 1, c.active_status_cd = 0, c.active_status_dt_tm = cnvtdatetime(curdate,curtime3
       ),
      c.active_status_prsnl_id = 0, c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_cnt = 0,
      c.updt_task = 0, c.updt_applctx = 0, c.create_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH counter
    ;end insert
    IF (curqual=0)
     SET success = 0
     GO TO next_item
    ENDIF
   ELSE
    UPDATE  FROM bb_report_management r
     SET r.report_name = requestin->list_0[x].report_name, r.description = requestin->list_0[x].
      description, r.product_ind = cnvtreal(requestin->list_0[x].product_ind),
      r.patient_ind = cnvtreal(requestin->list_0[x].patient_ind), r.donor_ind = cnvtreal(requestin->
       list_0[x].donor_ind), r.include_donors_ind = cnvtreal(requestin->list_0[x].include_donors_ind),
      r.date_range_ind = cnvtreal(requestin->list_0[x].date_range_ind), r.donatn_level_range_ind =
      cnvtreal(requestin->list_0[x].donation_level_range_ind), r.all_organization_ind = cnvtreal(
       requestin->list_0[x].all_organization_ind),
      r.owner_area_ind = cnvtreal(requestin->list_0[x].owner_area_ind), r.inventory_area_ind =
      cnvtreal(requestin->list_0[x].inventory_area_ind), r.deferral_ind = cnvtreal(requestin->list_0[
       x].deferral_ind),
      r.draw_station_ind = cnvtreal(requestin->list_0[x].draw_station_ind), r.organization_ind =
      cnvtreal(requestin->list_0[x].organization_ind), r.by_organization_ind = cnvtreal(requestin->
       list_0[x].by_organization_ind),
      r.mobile_pref_month_ind = cnvtreal(requestin->list_0[x].mobile_pref_month_ind), r
      .all_location_ind = cnvtreal(requestin->list_0[x].all_location_ind), r.deferral_reasons_ind =
      cnvtreal(requestin->list_0[x].deferral_reasons_ind),
      r.assays_ind = cnvtreal(requestin->list_0[x].assays_ind), r.reinstate_ind = cnvtreal(requestin
       ->list_0[x].reinstate_ind), r.exception_ind = cnvtreal(requestin->list_0[x].exception_ind),
      r.recruit_type_ind = cnvtreal(requestin->list_0[x].recruit_type_ind), r.aborh_ind = cnvtreal(
       requestin->list_0[x].aborh_ind), r.procedure_ind = cnvtreal(requestin->list_0[x].procedure_ind
       ),
      r.antigens_ind = cnvtreal(requestin->list_0[x].antigens_ind), r.recruit_list_ind = cnvtreal(
       requestin->list_0[x].recruit_list_ind), r.race_ind = cnvtreal(requestin->list_0[x].race_ind),
      r.rare_type_ind = cnvtreal(requestin->list_0[x].rare_type_ind), r.special_interest_ind =
      cnvtreal(requestin->list_0[x].special_interest_ind), r.zip_code_ind = cnvtreal(requestin->
       list_0[x].zip_code_ind),
      r.active_ind = 1, r.active_status_dt_tm = cnvtdatetime(curdate,curtime3), r.active_status_cd =
      0,
      r.active_status_prsnl_id = 0, r.updt_cnt = (r.updt_cnt+ 1), r.updt_task = 0,
      r.updt_applctx = 0, r.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WHERE r.active_ind=1
      AND report_found_id=r.report_id
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET success = 0
     GO TO next_item
    ENDIF
    IF (module_cat_found=0)
     SELECT INTO "NL:"
      nextseqnum = seq(pathnet_seq,nextval)
      FROM dual
      DETAIL
       module_cat_found_id = nextseqnum
      WITH format
     ;end select
     IF (module_cat_found_id=0)
      GO TO next_item
     ENDIF
     INSERT  FROM bb_report_mod_cat_r m
      SET m.module_categ_id = module_cat_found_id, m.report_module_cd = module_cd, m
       .report_category_cd = categ_cd,
       m.active_ind = 1, m.active_status_cd = 0, m.active_status_dt_tm = cnvtdatetime(curdate,
        curtime3),
       m.active_status_prsnl_id = 0, m.updt_dt_tm = cnvtdatetime(curdate,curtime3), m.updt_cnt = 0,
       m.updt_task = 0, m.updt_applctx = 0, m.create_dt_tm = cnvtdatetime(curdate,curtime3)
      WITH counter
     ;end insert
     IF (curqual=0)
      SET success = 0
      GO TO next_item
     ENDIF
    ENDIF
    SET relation_found = 0
    SELECT INTO "nl:"
     FROM bb_categ_report_r c
     WHERE c.active_ind=1
      AND c.report_id=report_found_id
      AND c.module_categ_id=module_cat_found_id
     DETAIL
      relation_found = 1
     WITH nocounter
    ;end select
    IF (relation_found=0)
     SELECT INTO "NL:"
      nextseqnum = seq(pathnet_seq,nextval)
      FROM dual
      DETAIL
       new_categ_report_rel_id = nextseqnum
      WITH format
     ;end select
     IF (new_categ_report_rel_id=0)
      SET success = 0
      GO TO next_item
     ENDIF
     INSERT  FROM bb_categ_report_r c
      SET c.categ_report_rel_id = new_categ_report_rel_id, c.module_categ_id = module_cat_found_id, c
       .report_id = report_found_id,
       c.active_ind = 1, c.active_status_cd = 0, c.active_status_dt_tm = cnvtdatetime(curdate,
        curtime3),
       c.active_status_prsnl_id = 0, c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_cnt = 0,
       c.updt_task = 0, c.updt_applctx = 0, c.create_dt_tm = cnvtdatetime(curdate,curtime3)
      WITH counter
     ;end insert
     IF (curqual=0)
      SET success = 0
      GO TO next_item
     ENDIF
    ENDIF
   ENDIF
   COMMIT
 ENDFOR
 GO TO exit_script
#next_item
 ROLLBACK
 SET x = (x+ 1)
 GO TO start_loop
#exit_script
END GO
