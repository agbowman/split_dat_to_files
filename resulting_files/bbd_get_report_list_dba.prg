CREATE PROGRAM bbd_get_report_list:dba
 RECORD reply(
   1 module_list[*]
     2 report_module_disp = vc
     2 report_module_cd = f8
     2 category_list[*]
       3 report_id = f8
       3 report_module_cd = f8
       3 report_category_cd = f8
       3 report_category_active_ind = i2
       3 report_category_display = vc
       3 categ_report_rel_id = f8
       3 updt_cnt = i4
       3 module_categ_id = f8
       3 report_list[*]
         4 report_id = f8
         4 active_ind = i2
         4 date_range_ind = i2
         4 description = vc
         4 draw_station_ind = i2
         4 donor_ind = i2
         4 include_donors_ind = i2
         4 inventory_area_ind = i2
         4 owner_area_ind = i2
         4 patient_ind = i2
         4 deferral_ind = i2
         4 product_ind = i2
         4 donation_level_range_ind = i2
         4 organization_ind = i2
         4 by_organization_ind = i2
         4 all_organization_ind = i2
         4 mobile_pref_month_ind = i2
         4 report_name = vc
         4 request_nbr = f8
         4 task_nbr = f8
         4 report_category_cd = f8
         4 updt_cnt = i4
         4 all_location_ind = i2
         4 reinstate_ind = i2
         4 assays_ind = i2
         4 deferral_reasons_ind = i2
         4 exception_ind = i2
         4 aborh_ind = i2
         4 procedure_ind = i2
         4 antigens_ind = i2
         4 recruit_list_ind = i2
         4 race_ind = i2
         4 rare_type_ind = i2
         4 special_interest_ind = i2
         4 zip_code_ind = i2
         4 recruit_type_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET module_count = 0
 SET categ_count = 0
 SET report_count = 0
 SELECT INTO "nl:"
  m.report_module_cd, module_disp = cv.display, m.module_categ_id,
  m.report_category_cd, category_disp = uar_get_code_display(m.report_category_cd), c
  .categ_report_rel_id,
  cv.code_value
  FROM bb_report_management r,
   bb_categ_report_r c,
   bb_report_mod_cat_r m,
   code_value cv,
   dummyt d1,
   dummyt d2,
   dummyt d3
  PLAN (cv
   WHERE cv.code_set=16049
    AND cv.active_ind=1)
   JOIN (d1)
   JOIN (m
   WHERE m.report_module_cd > 0
    AND m.report_category_cd > 0
    AND m.report_module_cd=cv.code_value)
   JOIN (d2)
   JOIN (c
   WHERE c.module_categ_id=m.module_categ_id)
   JOIN (d3)
   JOIN (r
   WHERE r.report_id=c.report_id)
  ORDER BY cv.code_value, m.report_category_cd, c.report_id
  HEAD cv.code_value
   module_count = (module_count+ 1), stat = alterlist(reply->module_list,module_count), reply->
   module_list[module_count].report_module_cd = cv.code_value,
   CALL echo(build("Module code:  ",cv.code_value)), reply->module_list[module_count].
   report_module_disp = module_disp,
   CALL echo(build("Module display:  ",module_disp)),
   categ_count = 0
  HEAD m.report_category_cd
   IF (m.report_category_cd > 0)
    categ_count = (categ_count+ 1), stat = alterlist(reply->module_list[module_count].category_list,
     categ_count), reply->module_list[module_count].category_list[categ_count].report_id = c
    .report_id,
    reply->module_list[module_count].category_list[categ_count].report_module_cd = m.report_module_cd,
    reply->module_list[module_count].category_list[categ_count].report_category_cd = m
    .report_category_cd, reply->module_list[module_count].category_list[categ_count].
    report_category_active_ind = m.active_ind,
    reply->module_list[module_count].category_list[categ_count].report_category_display =
    category_disp,
    CALL echo(build("Category display:  ",category_disp)), reply->module_list[module_count].
    category_list[categ_count].categ_report_rel_id = c.categ_report_rel_id,
    reply->module_list[module_count].category_list[categ_count].updt_cnt = c.updt_cnt, reply->
    module_list[module_count].category_list[categ_count].module_categ_id = m.module_categ_id,
    report_count = 0
   ENDIF
  DETAIL
   IF (r.report_id > 0)
    report_count = (report_count+ 1), stat = alterlist(reply->module_list[module_count].
     category_list[categ_count].report_list,report_count), reply->module_list[module_count].
    category_list[categ_count].report_list[report_count].report_id = r.report_id,
    reply->module_list[module_count].category_list[categ_count].report_list[report_count].active_ind
     = r.active_ind, reply->module_list[module_count].category_list[categ_count].report_list[
    report_count].date_range_ind = r.date_range_ind, reply->module_list[module_count].category_list[
    categ_count].report_list[report_count].description = r.description,
    CALL echo(build("Report description:  ",r.description)), reply->module_list[module_count].
    category_list[categ_count].report_list[report_count].draw_station_ind = r.draw_station_ind, reply
    ->module_list[module_count].category_list[categ_count].report_list[report_count].donor_ind = r
    .donor_ind,
    reply->module_list[module_count].category_list[categ_count].report_list[report_count].
    include_donors_ind = r.include_donors_ind, reply->module_list[module_count].category_list[
    categ_count].report_list[report_count].inventory_area_ind = r.inventory_area_ind, reply->
    module_list[module_count].category_list[categ_count].report_list[report_count].owner_area_ind = r
    .owner_area_ind,
    reply->module_list[module_count].category_list[categ_count].report_list[report_count].patient_ind
     = r.patient_ind, reply->module_list[module_count].category_list[categ_count].report_list[
    report_count].product_ind = r.product_ind, reply->module_list[module_count].category_list[
    categ_count].report_list[report_count].deferral_ind = r.deferral_ind,
    reply->module_list[module_count].category_list[categ_count].report_list[report_count].
    organization_ind = r.organization_ind, reply->module_list[module_count].category_list[categ_count
    ].report_list[report_count].by_organization_ind = r.by_organization_ind, reply->module_list[
    module_count].category_list[categ_count].report_list[report_count].all_organization_ind = r
    .all_organization_ind,
    reply->module_list[module_count].category_list[categ_count].report_list[report_count].
    mobile_pref_month_ind = r.mobile_pref_month_ind, reply->module_list[module_count].category_list[
    categ_count].report_list[report_count].donation_level_range_ind = r.donatn_level_range_ind, reply
    ->module_list[module_count].category_list[categ_count].report_list[report_count].all_location_ind
     = r.all_location_ind,
    reply->module_list[module_count].category_list[categ_count].report_list[report_count].
    reinstate_ind = r.reinstate_ind, reply->module_list[module_count].category_list[categ_count].
    report_list[report_count].deferral_reasons_ind = r.deferral_reasons_ind, reply->module_list[
    module_count].category_list[categ_count].report_list[report_count].assays_ind = r.assays_ind,
    reply->module_list[module_count].category_list[categ_count].report_list[report_count].
    exception_ind = r.exception_ind, reply->module_list[module_count].category_list[categ_count].
    report_list[report_count].aborh_ind = r.aborh_ind, reply->module_list[module_count].
    category_list[categ_count].report_list[report_count].procedure_ind = r.procedure_ind,
    reply->module_list[module_count].category_list[categ_count].report_list[report_count].
    antigens_ind = r.antigens_ind, reply->module_list[module_count].category_list[categ_count].
    report_list[report_count].recruit_list_ind = r.recruit_list_ind, reply->module_list[module_count]
    .category_list[categ_count].report_list[report_count].race_ind = r.race_ind,
    reply->module_list[module_count].category_list[categ_count].report_list[report_count].
    rare_type_ind = r.rare_type_ind, reply->module_list[module_count].category_list[categ_count].
    report_list[report_count].special_interest_ind = r.special_interest_ind, reply->module_list[
    module_count].category_list[categ_count].report_list[report_count].zip_code_ind = r.zip_code_ind,
    reply->module_list[module_count].category_list[categ_count].report_list[report_count].
    recruit_type_ind = r.recruit_type_ind, reply->module_list[module_count].category_list[categ_count
    ].report_list[report_count].report_name = r.report_name, reply->module_list[module_count].
    category_list[categ_count].report_list[report_count].request_nbr = r.request_nbr,
    reply->module_list[module_count].category_list[categ_count].report_list[report_count].task_nbr =
    r.task_nbr, reply->module_list[module_count].category_list[categ_count].report_list[report_count]
    .updt_cnt = r.updt_cnt, reply->module_list[module_count].category_list[categ_count].report_list[
    report_count].report_category_cd = m.report_category_cd
   ENDIF
  FOOT  m.report_module_cd
   row + 0
  FOOT  m.report_category_cd
   row + 0
  WITH nocounter, outerjoin = d1, outerjoin = d2,
   outerjoin = d3
 ;end select
#exit_script
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
