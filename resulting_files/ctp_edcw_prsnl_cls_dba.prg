CREATE PROGRAM ctp_edcw_prsnl_cls:dba
 SUBROUTINE (PRSNL::getcodeset(code_set=i4,reply_record=vc(ref),filter_list=vc(value," "),exclude_ind
  =i2(value,0),active_ind=i2(value,1)) =i2 WITH protect, copy)
   DECLARE not_found = vc WITH protect, constant("%NOTFOUND%")
   DECLARE sep = c1 WITH protect, constant(char(26))
   DECLARE dynamic_filter = vc WITH protect, noconstant("1=1")
   DECLARE field = vc WITH protect, noconstant(" ")
   DECLARE cnt = i4 WITH protect, noconstant(0)
   SET stat = initrec(reply_record)
   IF (size(trim(filter_list)) > 0)
    SET dynamic_filter = " "
    SET cnt = 1
    SET field = piece(filter_list,"|",cnt,not_found)
    WHILE (field != not_found)
      SET dynamic_filter = build(dynamic_filter,sep,"'",field,"'")
      SET cnt += 1
      SET field = piece(filter_list,"|",cnt,not_found)
    ENDWHILE
    SET dynamic_filter = replace(trim(dynamic_filter,2),sep,",")
    IF (exclude_ind)
     SET dynamic_filter = build("cv.cdf_meaning not in (",dynamic_filter,")")
     SET dynamic_filter = build("(",dynamic_filter,"or cv.cdf_meaning = NULL",")")
    ELSE
     SET dynamic_filter = build("cv.cdf_meaning in (",dynamic_filter,")")
    ENDIF
   ENDIF
   SET reply_record->code_set = code_set
   SELECT
    IF (active_ind)
     PLAN (cv
      WHERE cv.code_set=code_set
       AND cv.active_ind=1
       AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
       AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
       AND parser(dynamic_filter))
    ELSE
     PLAN (cv
      WHERE cv.code_set=code_set
       AND parser(dynamic_filter))
    ENDIF
    INTO "nl:"
    FROM code_value cv
    ORDER BY cv.code_value
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt += 1
     IF (mod(cnt,1000)=1)
      stat = alterlist(reply_record->list,(cnt+ 999))
     ENDIF
     reply_record->list[cnt].code = cv.code_value, reply_record->list[cnt].display = cv.display,
     reply_record->list[cnt].description = cv.description,
     reply_record->list[cnt].meaning = cv.cdf_meaning
     IF (cv.active_ind
      AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
      AND cv.end_effective_dt_tm > cnvtdatetime(sysdate))
      reply_record->list[cnt].active_ind = true
     ENDIF
    FOOT REPORT
     stat = alterlist(reply_record->list,cnt)
    WITH nocounter
   ;end select
   IF (size(reply_record->list,5) > 0)
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 CREATE CLASS uzr_add_prsnl FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 person_id = f8
   1 person_mod_ind = i2
   1 prsnl_type_meaning = c12
   1 username = vc
   1 active_ind = i2
   1 physician_ind = i2
   1 email = vc
   1 position_cd = f8
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 prim_assign_loc_cd = f8
   1 name_last = vc
   1 name_first = c100
   1 name_middle = vc
   1 name_initials = vc
   1 name_full = vc
   1 name_original = vc
   1 name_degree = vc
   1 name_title = vc
   1 name_suffix = vc
   1 person_name_type_meaning = c12
   1 person_name_last = vc
   1 person_name_first = c100
   1 person_name_middle = vc
   1 person_name_initials = vc
   1 person_name_full = vc
   1 person_name_original = vc
   1 person_name_degree = vc
   1 person_name_title = vc
   1 person_name_suffix = vc
   1 person_person_name_type_meaning = c12
   1 birth_dt_tm = dq8
   1 sex_cd = f8
   1 logical_domain_id = f8
   1 logical_domain_enabled = i2
   1 external_ind_ind = i2
   1 external_ind = i2
 )
 RECORD _::reply(
   1 person_id = f8
   1 prsnl_alias_id = f8
   1 alias = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("uzr_add_prsnl"))
 DECLARE PRIVATE::commit_ind_check = i2 WITH constant(1)
 END; class scope:init
 WITH copy = 1
 CREATE CLASS uzr_chg_prsnl FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 person_id = f8
   1 prsnl_type_cd = f8
   1 username = c50
   1 active_ind = i2
   1 email = vc
   1 physician_ind = i2
   1 position_cd = f8
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 prim_assign_loc_cd = f8
   1 prsnl_updt_cnt = i4
   1 person_name_id = f8
   1 name_last = vc
   1 name_first = c100
   1 name_middle = vc
   1 name_original = vc
   1 name_full = vc
   1 name_initials = vc
   1 name_degree = vc
   1 name_title = vc
   1 name_suffix = vc
   1 name_type_cd = f8
   1 person_name_updt_cnt = i4
   1 person_person_name_id = f8
   1 person_name_last = vc
   1 person_name_first = c100
   1 person_name_middle = vc
   1 person_name_original = vc
   1 person_name_full = vc
   1 person_name_initials = vc
   1 person_name_degree = vc
   1 person_name_title = vc
   1 person_name_suffix = vc
   1 person_name_type_cd = f8
   1 person_person_name_updt_cnt = i4
   1 birth_dt_tm = dq8
   1 birth_tz = i4
   1 sex_cd = f8
   1 person_updt_cnt = i4
   1 person_active_ind = i2
   1 person_beg_effective_dt_tm = dq8
   1 person_end_effective_dt_tm = dq8
   1 external_ind_ind = i2
   1 external_ind = i2
 )
 RECORD _::reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("uzr_chg_prsnl"))
 DECLARE PRIVATE::commit_ind_check = i2 WITH constant(1)
 END; class scope:init
 WITH copy = 1
 CREATE CLASS uzr_get_prsnl_by_username FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 username = vc
   1 view_flag = i2
   1 hnauser_mode = i2
   1 logical_domain_id = f8
   1 logical_domain_enabled = i2
 )
 RECORD _::reply(
   1 qual[*]
     2 person_id = f8
     2 name_full_formatted = vc
     2 username = c50
     2 active_ind = i2
     2 status_ind = i2
     2 authorized_ind = i2
     2 suspended_ind = i2
     2 updt_cnt = i4
     2 combined_ind = i2
     2 contributor_system_cd = f8
     2 logical_domain_id = f8
     2 logical_domain_name = vc
     2 email = vc
     2 position_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("uzr_get_prsnl_by_username"))
 END; class scope:init
 WITH copy = 1
 CREATE CLASS get_logical_domain_service FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 logical_domain_concept = i4
 )
 RECORD _::reply(
   1 logical_domain_enabled = i2
   1 logical_domain_id = f8
   1 logical_domain_name = vc
   1 error_code = i2
   1 check_enabled_status = i4
   1 get_curr_ld_status = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("get_logical_domain_service"))
 DECLARE _::perform(null) = i2
 SUBROUTINE _::perform(null)
   DECLARE status = i2 WITH protect, noconstant(0)
   SET status = PRIVATE::performwrapper(0)
   IF ((_::reply->error_code != 0))
    SET PRIVATE::err_msg = build2(PRIVATE::object_name," returned error code ",_::reply->error_code)
    SET status = 0
   ENDIF
   RETURN(status)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS bed_get_personnel_list_b FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 physician_only_ind = i2
   1 position_list[*]
     2 position_cd = f8
   1 name_first = vc
   1 name_last = vc
   1 username = vc
   1 inc_inactive_ind = i2
   1 inc_unauth_ind = i2
   1 max_reply = i4
   1 submit_by = vc
   1 load
     2 get_bus_address_ind = i2
     2 get_bus_phone_ind = i2
     2 get_specialties_ind = i2
     2 get_org_cnt_ind = i2
     2 get_specialty_cnt_ind = i2
     2 get_org_ind = i2
   1 person_id = f8
   1 username_only_ind = i2
   1 organizations[*]
     2 id = f8
   1 organization_groups[*]
     2 id = f8
   1 load_orgs_and_groups_ind = i2
   1 external_ind = i2
 )
 RECORD _::reply(
   1 prsnl_list[*]
     2 person_id = f8
     2 org_cnt = i2
     2 org_ind = i2
     2 specialty_cnt = i2
     2 name_full_formatted = vc
     2 username = vc
     2 active_ind = i2
     2 auth_ind = i2
     2 slist[*]
       3 specialty_id = f8
       3 specialty_value = vc
       3 specialty_name = vc
     2 address_list[*]
       3 address_id = f8
       3 address_type_code_value = f8
       3 address_type_disp = vc
       3 address_type_mean = vc
       3 address_type_seq = i4
       3 street_addr = vc
       3 street_addr2 = vc
       3 street_addr3 = vc
       3 street_addr4 = vc
       3 city = vc
       3 state = vc
       3 state_code_value = f8
       3 state_disp = vc
       3 zipcode = vc
       3 country_code_value = f8
       3 country_disp = vc
       3 county_code_value = f8
       3 county_disp = vc
       3 contact_name = vc
       3 residence_type_code_value = f8
       3 residence_type_disp = vc
       3 residence_type_mean = vc
       3 comment_txt = vc
       3 active_ind = i2
     2 phone_list[*]
       3 phone_id = f8
       3 phone_type_code_value = f8
       3 phone_type_disp = vc
       3 phone_type_mean = vc
       3 phone_format_code_value = f8
       3 phone_format_disp = vc
       3 phone_format_mean = vc
       3 sequence = i4
       3 phone_num = vc
       3 phone_formatted = vc
       3 description = vc
       3 contact = vc
       3 call_instruction = vc
       3 extension = vc
       3 paging_code = vc
       3 operation_hours = vc
       3 active_ind = i2
     2 position_code_value = f8
     2 position_display = vc
     2 position_mean = vc
     2 organizations[*]
       3 id = f8
       3 name = vc
     2 organization_groups[*]
       3 id = f8
       3 name = vc
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 external_ind = i2
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 too_many_results_ind = i2
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("bed_get_personnel_list_b"))
 DECLARE _::perform(null) = i2
 SUBROUTINE _::perform(null)
   DECLARE status = i2 WITH protect, noconstant(0)
   SET _::request->max_reply = 1000000
   SET status = PRIVATE::performwrapper(0)
   IF (status
    AND _::reply->too_many_results_ind)
    SET PRIVATE::err_msg = concat(PRIVATE::object_name," returned too many results")
    SET status = 0
   ENDIF
   RETURN(status)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS uzr_get_prsnl FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 person_id = f8
   1 name_type_meaning = c12
   1 person_name_type_meaning = c12
   1 associate_alias_type_meaning = c12
   1 fill_missing_data_ind = i2
 )
 RECORD _::reply(
   1 person_id = f8
   1 prsnl_type_cd = f8
   1 active_ind = i2
   1 active_status_mean = c12
   1 active_status_disp = vc
   1 password = vc
   1 email = vc
   1 physician_ind = i2
   1 position_cd = f8
   1 username = c50
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 prim_assign_loc_cd = f8
   1 status_ind = i2
   1 data_status_cd = f8
   1 prsnl_updt_cnt = i4
   1 external_ind = i2
   1 person_name_id = f8
   1 name_last = vc
   1 name_first = vc
   1 name_middle = vc
   1 name_original = vc
   1 name_full = vc
   1 name_initials = vc
   1 name_degree = vc
   1 name_title = vc
   1 name_suffix = vc
   1 name_type_cd = f8
   1 person_name_updt_cnt = i4
   1 person_person_name_id = f8
   1 person_name_last = vc
   1 person_name_first = vc
   1 person_name_middle = vc
   1 person_name_original = vc
   1 person_name_full = vc
   1 person_name_initials = vc
   1 person_name_degree = vc
   1 person_name_title = vc
   1 person_name_suffix = vc
   1 person_name_type_cd = f8
   1 person_person_name_updt_cnt = i4
   1 birth_dt_tm = dq8
   1 birth_tz = i4
   1 sex_cd = f8
   1 person_updt_cnt = i4
   1 person_active_ind = i2
   1 person_beg_effective_dt_tm = dq8
   1 person_end_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("uzr_get_prsnl"))
 END; class scope:init
 WITH copy = 1
 CREATE CLASS loc_get_all_loc_for_cdf FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 code_set = i4
   1 cdf_meaning = c12
   1 get_all_flag = i2
   1 get_view_flag = i2
   1 get_master_flag = i2
   1 get_facility_flag = i2
   1 skip_loc_group_ind = i2
   1 get_prsnl_org_flag = i2
 )
 RECORD _::reply(
   1 qual[*]
     2 code_value = f8
     2 cdf_meaning = c12
     2 description = c200
     2 display = c40
     2 active_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 status_ind = i2
     2 child_ind = i2
     2 collation_seq = i4
     2 updt_cnt = i4
     2 root_loc_cd = f8
     2 data_status_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("loc_get_all_loc_for_cdf"))
 END; class scope:init
 WITH copy = 1
 CREATE CLASS acm_get_logical_domains FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 concept = i4
 )
 RECORD _::reply(
   1 logical_domains[*]
     2 logical_domain_id = f8
     2 mnemonic = vc
   1 status_block
     2 status_ind = i2
     2 status_code = i4
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("acm_get_logical_domains"))
 DECLARE _::perform(null) = i2
 SUBROUTINE _::perform(null)
   DECLARE status = i2 WITH protect, noconstant(0)
   FREE SET cnt
   SET status = PRIVATE::performwrapper(PRIVATE::free_reply)
   RETURN(status)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS uzr_get_person_alias FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 person_id = f8
   1 get_all_flag = i2
   1 end_effect_flag = i2
   1 get_org_flag = i2
 )
 RECORD _::reply(
   1 qual[*]
     2 person_alias_id = f8
     2 alias = c50
     2 alias_formatted = c50
     2 person_alias_type_cd = f8
     2 person_alias_sub_type_cd = f8
     2 person_alias_type_disp = vc
     2 alias_pool_cd = f8
     2 active_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 status_ind = i2
     2 updt_cnt = i4
     2 orgqual[*]
       3 org_id = f8
       3 org_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("uzr_get_person_alias"))
 END; class scope:init
 WITH copy = 1
 CREATE CLASS uzr_get_prsnl_alias FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 person_id = f8
   1 get_all_flag = i2
   1 end_effect_flag = i2
   1 get_org_flag = i2
 )
 RECORD _::reply(
   1 qual[*]
     2 prsnl_alias_id = f8
     2 alias = c50
     2 alias_formatted = c50
     2 prsnl_alias_type_cd = f8
     2 prsnl_alias_sub_type_cd = f8
     2 prsnl_alias_type_disp = vc
     2 alias_pool_cd = f8
     2 active_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 status_ind = i2
     2 updt_cnt = i4
     2 orgqual[*]
       3 org_id = f8
       3 org_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("uzr_get_prsnl_alias"))
 END; class scope:init
 WITH copy = 1
 CREATE CLASS uzr_get_prsnl_grp_for_prsnl FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 person_id = f8
 )
 RECORD _::reply(
   1 qual[*]
     2 prsnl_group_id = f8
     2 prsnl_group_reltn_id = f8
     2 prsnl_group_name = vc
     2 prsnl_group_type_cd = f8
     2 prsnl_group_type_disp = c40
     2 prsnl_group_type_desc = c60
     2 prsnl_group_type_mean = c12
     2 prsnl_group_class_cd = f8
     2 prsnl_group_class_disp = c40
     2 prsnl_group_class_desc = c60
     2 prsnl_group_class_mean = c12
     2 service_resource_cd = f8
     2 service_resource_disp = c40
     2 service_resource_desc = c60
     2 service_resource_mean = c12
     2 primary_ind = i2
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("uzr_get_prsnl_grp_for_prsnl"))
 END; class scope:init
 WITH copy = 1
 CREATE CLASS uzr_get_prsnl_grp FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 get_all_flag = i2
 )
 RECORD _::reply(
   1 qual[*]
     2 prsnl_group_id = f8
     2 prsnl_group_name = vc
     2 prsnl_group_desc = vc
     2 active_ind = i2
     2 prsnl_group_type_cd = f8
     2 prsnl_group_type_disp = c40
     2 prsnl_group_type_desc = c60
     2 prsnl_group_type_mean = c12
     2 prsnl_group_class_cd = f8
     2 prsnl_group_class_disp = c40
     2 prsnl_group_class_desc = c60
     2 prsnl_group_class_mean = c12
     2 service_resource_cd = f8
     2 service_resource_disp = c40
     2 service_resource_desc = c60
     2 service_resource_mean = c12
     2 status_ind = i2
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("uzr_get_prsnl_grp"))
 END; class scope:init
 WITH copy = 1
 CREATE CLASS pm_prsnl_org_set FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 action_flag = i2
   1 mode = i2
   1 options = vc
   1 prsnl_id = f8
   1 org_set_type_cd = f8
   1 org_set[*]
     2 subaction_flag = i2
     2 org_set_id = f8
     2 org_set_type_cd = f8
     2 orgs[*]
       3 subaction_flag = i2
       3 org_id = f8
 )
 RECORD _::reply(
   1 org_sets[*]
     2 org_set_id = f8
     2 org_set_name = vc
     2 org_set_type = f8
     2 prsnl_org_rel_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("pm_prsnl_org_set"))
 DECLARE _::perform(null) = i2
 SUBROUTINE _::perform(null)
   DECLARE status = i2 WITH protect, noconstant(0)
   SET _::request->action_flag = 1
   SET _::request->mode = 1
   SET status = PRIVATE::performwrapper(PRIVATE::free_reply)
   RETURN(status)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS pm_org_set FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 action_flag = i2
   1 mode = i2
   1 options = vc
   1 org_set_type_cd = f8
   1 org_set_types[*]
     2 org_set_type_cd = f8
   1 org_set[*]
     2 subaction_flag = i2
     2 org_set_id = f8
     2 name = vc
     2 description = vc
     2 attr_bit = i4
     2 org_set_type[*]
       3 subaction_flag = i2
       3 org_set_id = f8
       3 org_set_type_cd = f8
     2 org_set_reltn[*]
       3 subaction_flag = i2
       3 org_set_org_r_id = f8
       3 org_set_id = f8
       3 org_id = f8
   1 org[*]
     2 org_id = f8
     2 org_group[*]
       3 subaction_flag = i2
       3 org_set_id = f8
   1 org_type[*]
     2 org_type_cd = f8
   1 logical_domain_id = f8
   1 logical_domain_enabled = i2
 )
 RECORD _::reply(
   1 org_sets[*]
     2 org_set_id = f8
     2 org_set_name = vc
     2 org_set_description = vc
     2 org_set_attr_bit = i4
     2 org_set_types[*]
       3 org_set_type_cd = f8
       3 org_set_type_disp = c40
       3 org_set_type_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("pm_org_set"))
 DECLARE PRIVATE::skip_commit_ind_check = i2 WITH constant(1)
 DECLARE _::perform(null) = i2
 SUBROUTINE _::perform(null)
   DECLARE status = i2 WITH protect, noconstant(0)
   SET _::request->action_flag = 1
   SET _::request->mode = 3
   SET status = PRIVATE::performwrapper(PRIVATE::free_reply)
   SET modify = nopredeclare
   RETURN(status)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS uzr_get_prsnl_org_reltn FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 person_id = f8
   1 filter_dir_ind = i2
   1 orgtype_pref = i2
   1 org_type[*]
     2 org_type_cd = f8
   1 auth_only_ind = i2
   1 return_types_ind = i2
 )
 RECORD _::reply(
   1 qual[*]
     2 prsnl_org_reltn_id = f8
     2 organization_id = f8
     2 org_name = vc
     2 person_id = f8
     2 name_full_formatted = vc
     2 confid_level_cd = f8
     2 confid_level_disp = c40
     2 confid_level_desc = c60
     2 service_resource_mean = c12
     2 active_ind = i2
     2 updt_cnt = i4
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 org_types[*]
       3 org_type_cd = f8
       3 org_type_disp = c40
       3 org_type_desc = vc
       3 org_type_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("uzr_get_prsnl_org_reltn"))
 END; class scope:init
 WITH copy = 1
 CREATE CLASS pm_get_address FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 read_not_active_ind = i2
   1 read_not_effective_ind = i2
   1 entity[*]
     2 parent_entity_name = c32
     2 parent_entity_id = f8
     2 meaning = c12
 )
 RECORD _::reply(
   1 address[*]
     2 address_id = f8
     2 parent_entity_name = c32
     2 parent_entity_id = f8
     2 address_type_cd = f8
     2 address_type_disp = vc
     2 address_type_desc = vc
     2 address_type_mean = c200
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_applctx = i4
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 address_format_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 contact_name = c200
     2 residence_type_cd = f8
     2 residence_type_disp = vc
     2 residence_type_desc = vc
     2 residence_type_mean = vc
     2 comment_txt = c200
     2 street_addr = c100
     2 street_addr2 = c100
     2 street_addr3 = c100
     2 street_addr4 = c100
     2 city = c100
     2 state = c100
     2 state_cd = f8
     2 state_disp = vc
     2 state_desc = vc
     2 state_mean = vc
     2 zipcode = c25
     2 zip_code_group_cd = f8
     2 zip_code_group_disp = vc
     2 zip_code_group_desc = vc
     2 zip_code_group_mean = vc
     2 postal_barcode_info = c100
     2 county = c100
     2 county_cd = f8
     2 county_disp = vc
     2 county_desc = vc
     2 county_mean = vc
     2 country = c100
     2 country_cd = f8
     2 country_disp = vc
     2 country_desc = vc
     2 country_mean = vc
     2 residence_cd = f8
     2 residence_disp = vc
     2 residence_desc = vc
     2 residence_mean = vc
     2 mail_stop = c100
     2 data_status_cd = f8
     2 data_status_dt_tm = dq8
     2 data_status_prsnl_id = f8
     2 address_type_seq = i4
     2 beg_effective_mm_dd = i4
     2 end_effective_mm_dd = i4
     2 contributor_system_cd = f8
     2 contributor_system_disp = vc
     2 contributor_system_desc = vc
     2 contributor_system_mean = vc
     2 address_info_status_cd = f8
     2 primary_care_cd = f8
     2 primary_care_disp = vc
     2 primary_care_desc = vc
     2 primary_care_mean = vc
     2 district_health_cd = f8
     2 district_health_disp = vc
     2 district_health_desc = vc
     2 district_health_mean = vc
     2 city_cd = f8
     2 city_disp = vc
     2 city_desc = vc
     2 city_mean = vc
     2 addr_key = vc
     2 source_identifier = vc
     2 operation_hours = vc
     2 validation_expire_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[2]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("pm_get_address"))
 DECLARE PRIVATE::success_status = vc WITH constant("S|Z|F")
 END; class scope:init
 WITH copy = 1
 CREATE CLASS uzr_get_phone FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 parent_entity_name = c32
   1 parent_entity_id = f8
 )
 RECORD _::reply(
   1 qual[*]
     2 parent_entity_name = c32
     2 parent_entity_id = f8
     2 phone_type_cd = f8
     2 phone_type_mean = c12
     2 phone_id = f8
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_applctx = i4
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 phone_format_cd = f8
     2 phone_num = c100
     2 sequence = i4
     2 description = vc
     2 contact = vc
     2 call_instruction = vc
     2 modem_capability_cd = f8
     2 extension = vc
     2 paging_code = vc
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("uzr_get_phone"))
 END; class scope:init
 WITH copy = 1
 CREATE CLASS pm_get_prsnl_prsnl_reltn FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 person_id = f8
   1 prsnl_prsnl_reltn_cd = f8
   1 organization_id = f8
   1 effective_dt_tm = dq8
 )
 RECORD _::reply(
   1 person_id = f8
   1 related_ind = i2
   1 prsnl_prsnl_reltn[*]
     2 related_person_id = f8
     2 related_person_name = vc
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 contributor_system_cd = f8
     2 organization_id = f8
     2 organization_name = vc
     2 prsnl_prsnl_reltn_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("pm_get_prsnl_prsnl_reltn"))
 END; class scope:init
 WITH copy = 1
 CREATE CLASS uzr_get_cred FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 view_inact = i2
   1 view_ended = i2
   1 person_list[*]
     2 person_id = f8
 )
 RECORD _::reply(
   1 renewal_time_cd = f8
   1 separator = vc
   1 person_list[*]
     2 person_id = f8
     2 name_last = vc
     2 name_first = vc
     2 name_full_formatted = vc
     2 name_original = vc
     2 name_degree = vc
     2 name_title = vc
     2 name_suffix = vc
     2 name_middle = vc
     2 name_prefix = vc
     2 name_initials = vc
     2 credential_string = vc
     2 person_name_id = f8
     2 physician_ind = i2
     2 person_active_ind = i2
     2 cred_list[*]
       3 credential_id = f8
       3 parent_entity_id = f8
       3 parent_entity_name = vc
       3 notify_type_cd = f8
       3 notify_prsnl_id = f8
       3 display_seq = i4
       3 credential_cd = f8
       3 credential_disp = vc
       3 credential_desc = vc
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 credential_type_cd = f8
       3 credential_type_disp = vc
       3 state_cd = f8
       3 state_disp = vc
       3 id_number = c50
       3 renewal_dt_tm = dq8
       3 valid_for_cd = f8
       3 notified_dt_tm = dq8
       3 active_ind = i2
       3 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("uzr_get_cred"))
 END; class scope:init
 WITH copy = 1
 CREATE CLASS pm_get_phone FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 parent_entity_name = c32
   1 parent_entity_id = f8
   1 meaning = c12
 )
 RECORD _::reply(
   1 phone[*]
     2 phone_id = f8
     2 parent_entity_name = c32
     2 parent_entity_id = f8
     2 phone_type_cd = f8
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_applctx = i4
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 phone_format_cd = f8
     2 phone_num = c100
     2 phone_formatted = c100
     2 phone_type_seq = i4
     2 description = c100
     2 contact = c100
     2 call_instruction = c100
     2 modem_capability_cd = f8
     2 extension = c100
     2 paging_code = c100
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 data_status_cd = f8
     2 data_status_dt_tm = dq8
     2 data_status_prsnl_id = dq8
     2 beg_effective_mm_dd = i4
     2 end_effective_mm_dd = i4
     2 contributor_system_cd = f8
     2 contact_method_cd = f8
     2 source_identifier = vc
     2 operation_hours = vc
     2 texting_permission_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[2]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("pm_get_phone"))
 END; class scope:init
 WITH copy = 1
 CREATE CLASS eem_get_taxon_by_prvdr_id FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 call_echo_ind = i2
   1 qual[*]
     2 provider_id = f8
     2 provider_type = vc
 )
 RECORD _::reply(
   1 prov_qual_cnt = i4
   1 prov_qual[*]
     2 provider_id = f8
     2 prov_name = vc
     2 resource_type_cd = f8
     2 prov_tax_qual_cnt = i4
     2 prov_tax_qual[*]
       3 eem_prov_tax_reltn_id = f8
       3 parent_entity_name = vc
       3 parent_entity_id = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 long_text_id = f8
       3 updt_cnt = i4
       3 lt_long_text = vc
       3 lt_updt_cnt = i4
       3 taxonomy_id = f8
       3 taxonomy = c10
       3 description = vc
       3 tax_beg_effective_dt_tm = dq8
       3 tax_end_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("eem_get_taxon_by_prvdr_id"))
 DECLARE PRIVATE::success_status = vc WITH constant("S|Z|P")
 END; class scope:init
 WITH copy = 1
 CREATE CLASS uzr_get_organization FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 get_all_flag = i2
   1 facilities_only_ind = i2
   1 orgtype_pref = i2
   1 filter_dir_ind = i2
   1 org_type[*]
     2 org_type_cd = f8
   1 auth_only_ind = i2
   1 return_types_ind = i2
   1 logical_domain_id = f8
   1 logical_domain_enabled = i2
 )
 RECORD _::reply(
   1 qual[*]
     2 organization_id = f8
     2 org_name = vc
     2 org_types[*]
       3 org_type_cd = f8
       3 org_type_disp = c40
       3 org_type_desc = vc
       3 org_type_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("uzr_get_organization"))
 DECLARE PRIVATE::free_reply = i2 WITH constant(1)
 END; class scope:init
 WITH copy = 1
 CREATE CLASS uzr_get_prsnl_grp FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 get_all_flag = i2
 )
 RECORD _::reply(
   1 qual[*]
     2 prsnl_group_id = f8
     2 prsnl_group_name = vc
     2 prsnl_group_desc = vc
     2 active_ind = i2
     2 prsnl_group_type_cd = f8
     2 prsnl_group_type_disp = c40
     2 prsnl_group_type_desc = c60
     2 prsnl_group_type_mean = c12
     2 prsnl_group_class_cd = f8
     2 prsnl_group_class_disp = c40
     2 prsnl_group_class_desc = c60
     2 prsnl_group_class_mean = c12
     2 service_resource_cd = f8
     2 service_resource_disp = c40
     2 service_resource_desc = c60
     2 service_resource_mean = c12
     2 status_ind = i2
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("uzr_get_prsnl_grp"))
 END; class scope:init
 WITH copy = 1
 CREATE CLASS prsnl_org_reltn
 init
 RECORD _::data(
   1 list[*]
     2 id = f8
     2 org_reltn[*]
       3 prsnl_org_reltn_id = f8
       3 org_name = vc
       3 confid_level_cd = f8
 )
 DECLARE _::get(null) = null
 SUBROUTINE _::get(null)
   DECLARE 28881_security_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2989580")
    )
   DECLARE 396_freetext_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2950"))
   DECLARE 278_facility_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4977"))
   DECLARE idx = i4 WITH protect, noconstant(0)
   RECORD index(
     1 list[*]
       2 id = f8
       2 ptr = i4
   ) WITH protect
   IF (size(_::data->list,5)=0)
    RETURN(1)
   ENDIF
   SELECT INTO "nl:"
    key_id = _::data->list[d.seq].id
    FROM (dummyt d  WITH seq = size(_::data->list,5))
    ORDER BY key_id
    HEAD REPORT
     stat = alterlist(index->list,size(_::data->list,5)), cnt = 0
    HEAD key_id
     cnt += 1, index->list[cnt].id = key_id, index->list[cnt].ptr = d.seq
    FOOT REPORT
     stat = alterlist(index->list,cnt)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM prsnl_org_reltn por,
     organization o,
     org_type_reltn otr
    PLAN (por
     WHERE expand(idx,1,size(index->list,5),por.person_id,index->list[idx].id)
      AND por.active_ind=1
      AND por.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ((por.end_effective_dt_tm=null) OR (por.end_effective_dt_tm > cnvtdatetime(sysdate))) )
     JOIN (o
     WHERE o.organization_id=por.organization_id
      AND o.organization_id != 0
      AND o.org_class_cd != 396_freetext_cd)
     JOIN (otr
     WHERE otr.organization_id=o.organization_id
      AND otr.org_type_cd=278_facility_cd
      AND  NOT ( EXISTS (
     (SELECT
      1
      FROM org_set_prsnl_r ospr,
       org_set_org_r osor
      WHERE ospr.prsnl_id=por.person_id
       AND ospr.active_ind=1
       AND ospr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND ((ospr.end_effective_dt_tm=null) OR (ospr.end_effective_dt_tm > cnvtdatetime(sysdate)))
       AND ospr.org_set_type_cd=28881_security_cd
       AND osor.org_set_id=ospr.org_set_id
       AND osor.organization_id=otr.organization_id
       AND osor.active_ind=1
       AND osor.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND osor.end_effective_dt_tm > cnvtdatetime(sysdate)))))
    ORDER BY por.person_id, por.prsnl_org_reltn_id
    HEAD por.person_id
     pos = locatevalsort(idx,1,size(index->list,5),por.person_id,index->list[idx].id), idx = index->
     list[pos].ptr, cnt = 0
    HEAD por.prsnl_org_reltn_id
     IF (pos > 0)
      cnt += 1
      IF (cnt > size(_::data->list[idx].org_reltn,5))
       stat = alterlist(_::data->list[idx].org_reltn,(cnt+ 10000))
      ENDIF
      _::data->list[idx].org_reltn[cnt].prsnl_org_reltn_id = por.prsnl_org_reltn_id, _::data->list[
      idx].org_reltn[cnt].org_name = o.org_name, _::data->list[idx].org_reltn[cnt].confid_level_cd =
      por.confid_level_cd
     ENDIF
    FOOT  por.prsnl_org_reltn_id
     null
    FOOT  por.person_id
     stat = alterlist(_::data->list[idx].org_reltn,cnt)
    WITH expand = 2
   ;end select
   RETURN(1)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS provider_taxonomy
 init
 RECORD _::data(
   1 list[*]
     2 id = f8
     2 provider_type_cd = f8
     2 classification_cd = f8
     2 specialization_cd = f8
     2 taxonomy = vc
 )
 DECLARE _::get(null) = null
 SUBROUTINE _::get(null)
   DECLARE idx = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM provider_taxonomy pt
    PLAN (pt
     WHERE pt.taxonomy_id != 0
      AND pt.active_ind=1
      AND pt.end_effective_dt_tm > cnvtdatetime(sysdate))
    HEAD REPORT
     cnt = 0
    DETAIL
     meaning = cnvtint(uar_get_code_meaning(pt.provider_type_cd))
     IF (((meaning BETWEEN 10 AND 24) OR (((meaning BETWEEN 35 AND 37) OR (40)) )) )
      cnt += 1
      IF (cnt > size(_::data->list,5))
       stat = alterlist(_::data->list,(cnt+ 10000))
      ENDIF
      _::data->list[cnt].id = pt.taxonomy_id, _::data->list[cnt].provider_type_cd = pt
      .provider_type_cd, _::data->list[cnt].classification_cd = pt.classification_cd,
      _::data->list[cnt].specialization_cd = pt.specialization_cd, _::data->list[cnt].taxonomy = pt
      .taxonomy
     ENDIF
    FOOT REPORT
     stat = alterlist(_::data->list,cnt)
    WITH nocounter
   ;end select
   RETURN(1)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS prsnl_usernames_unique
 init
 RECORD _::data(
   1 list[*]
     2 username = vc
     2 id = f8
 )
 DECLARE _::get(null) = null
 SUBROUTINE _::get(null)
  SELECT INTO "nl:"
   name_key = cnvtupper(trim(check(p.username),3))
   FROM prsnl p
   PLAN (p
    WHERE p.person_id != 0
     AND textlen(trim(check(p.username),3)) > 0)
   ORDER BY name_key
   HEAD REPORT
    cnt = 0
   HEAD name_key
    cnt += 1
    IF (cnt > size(_::data->list,5))
     stat = alterlist(_::data->list,(cnt+ 100000))
    ENDIF
    _::data->list[cnt].username = p.username, _::data->list[cnt].id = p.person_id
   FOOT REPORT
    stat = alterlist(_::data->list,cnt)
   WITH nocounter
  ;end select
  RETURN(1)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS prsnl_usernames_all
 init
 RECORD _::data(
   1 list[*]
     2 username = vc
     2 id = f8
 )
 DECLARE _::get(null) = null
 SUBROUTINE _::get(null)
  SELECT INTO "nl:"
   FROM prsnl p
   PLAN (p
    WHERE p.person_id != 0
     AND textlen(trim(check(p.username),3)) > 0)
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt += 1
    IF (cnt > size(_::data->list,5))
     stat = alterlist(_::data->list,(cnt+ 100000))
    ENDIF
    _::data->list[cnt].username = p.username, _::data->list[cnt].id = p.person_id
   FOOT REPORT
    stat = alterlist(_::data->list,cnt)
   WITH nocounter
  ;end select
  RETURN(1)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS prsnl_usernames_diff
 init
 RECORD _::data(
   1 list[*]
     2 username = vc
 )
 DECLARE _::get(null) = null
 SUBROUTINE _::get(null)
   DECLARE idx = i4 WITH protect, noconstant(0)
   IF (size(_::data->list,5)=0)
    RETURN(1)
   ENDIF
   SET stat = copyrec(_::data,temp_record)
   SELECT INTO "nl:"
    name_key = substring(1,50,cnvtupper(trim(check(_::data->list[d.seq].username),3)))
    FROM (dummyt d  WITH seq = size(_::data->list,5))
    ORDER BY name_key
    HEAD REPORT
     stat = alterlist(temp_record->list,size(_::data->list,5)), cnt = 0
    DETAIL
     cnt += 1, temp_record->list[cnt].username = name_key
    WITH nocounter
   ;end select
   SET stat = initrec(_::data)
   SELECT INTO "nl:"
    name_key = cnvtupper(trim(check(p.username),3))
    FROM prsnl p
    PLAN (p
     WHERE p.person_id != 0
      AND textlen(trim(check(p.username),3)) > 0)
    HEAD REPORT
     cnt = 0
    DETAIL
     pos = locatevalsort(idx,1,size(temp_record->list,5),name_key,trim(temp_record->list[idx].
       username))
     IF (pos <= 0)
      cnt += 1
      IF (cnt > size(_::data->list,5))
       stat = alterlist(_::data->list,(cnt+ 100000))
      ENDIF
      _::data->list[cnt].username = p.username
     ENDIF
    FOOT REPORT
     stat = alterlist(_::data->list,cnt)
    WITH nocounter
   ;end select
   RETURN(1)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS sec_auth_rtl
 init
 DECLARE _::adduser = i4 WITH constant(0)
 DECLARE _::modifyuser = i4 WITH constant(1)
 DECLARE _::removeuser = i4 WITH constant(2)
 DECLARE _::enumuser = i4 WITH constant(3)
 DECLARE _::queryuser = i4 WITH constant(4)
 DECLARE _::success = i4 WITH constant(1)
 DECLARE _::fail = i4 WITH constant(0)
 DECLARE _::authok = i2 WITH constant(0)
 DECLARE _::authinvalid = i2 WITH constant(1)
 DECLARE _::authexists = i2 WITH constant(2)
 DECLARE _::authfailure = i2 WITH constant(3)
 DECLARE _::authnoaccess = i2 WITH constant(4)
 DECLARE _::authdoesnotexist = i2 WITH constant(5)
 DECLARE _::error = i4 WITH constant(6)
 DECLARE _::hrequest = i4 WITH noconstant(0)
 DECLARE _::hreply = i4 WITH noconstant(0)
 DECLARE PRIVATE::hauth = i4 WITH noconstant(0)
 DECLARE PRIVATE::hmsg = i4 WITH noconstant(0)
 SUBROUTINE (_::beginauth(action=i4) =i4)
   SET PRIVATE::hauth = uar_authcreate()
   IF ((PRIVATE::hauth=0))
    RETURN(_::fail)
   ENDIF
   SET PRIVATE::hmsg = uar_authselect(PRIVATE::hauth,action)
   IF ((PRIVATE::hmsg=0))
    CALL uar_authdestroy(PRIVATE::hauth)
    RETURN(_::fail)
   ENDIF
   SET _::hrequest = uar_srvcreaterequest(PRIVATE::hmsg)
   IF ((_::hrequest=0))
    CALL uar_authdestroy(PRIVATE::hauth)
    RETURN(_::fail)
   ENDIF
   SET _::hreply = uar_srvcreatereply(PRIVATE::hmsg)
   IF ((_::hreply=0))
    CALL uar_srvdestroyinstance(_::hrequest)
    CALL uar_authdestroy(PRIVATE::hauth)
    RETURN(_::fail)
   ENDIF
   RETURN(_::success)
 END ;Subroutine
 DECLARE _::endauth(null) = null
 SUBROUTINE _::endauth(null)
   IF ((PRIVATE::hmsg != 0))
    CALL uar_srvdestroyinstance(PRIVATE::hmsg)
   ENDIF
   IF ((_::hreply != 0))
    CALL uar_srvdestroyinstance(_::hreply)
   ENDIF
   IF ((_::hrequest != 0))
    CALL uar_srvdestroyinstance(_::hrequest)
   ENDIF
   IF ((PRIVATE::hauth != 0))
    CALL uar_authdestroy(PRIVATE::hauth)
   ENDIF
   SET PRIVATE::hmsg = 0
   SET PRIVATE::hauth = 0
   SET _::hrequest = 0
   SET _::hreply = 0
 END ;Subroutine
 DECLARE _::performauth(null) = i4
 SUBROUTINE _::performauth(null)
   DECLARE status = i2 WITH protect, noconstant(0)
   SET status = uar_srvexecute(PRIVATE::hmsg,_::hrequest,_::hreply)
   IF (status=0)
    RETURN(_::success)
   ELSE
    CALL _::endauth(null)
    RETURN(_::fail)
   ENDIF
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS edcw_updt_prsnl
 init
 DECLARE PRIVATE::field_list = vc WITH noconstant(" ")
 DECLARE PRIVATE::table_name = vc WITH noconstant(" ")
 DECLARE PRIVATE::err_msg = vc WITH noconstant(" ")
 SUBROUTINE (_::settable(table_name=vc,reverse_ind=i2(value,0),exclude_field=vc(value," "),
  exclude_index=vc(value," ")) =i2)
   DECLARE not_found = vc WITH protect, constant("%NOTFOUND%")
   DECLARE sub = c1 WITH protect, constant(char(26))
   DECLARE field = vc WITH protect, noconstant(" ")
   DECLARE column_exclusion = vc WITH protect, noconstant(" ")
   DECLARE index_exclusion = vc WITH protect, noconstant(" ")
   DECLARE cnt = i4 WITH protect, noconstant(0)
   SET PRIVATE::table_name = cnvtupper(trim(table_name,3))
   IF (size(trim(exclude_field)) > 0)
    SET cnt = 1
    SET field = piece(exclude_field,"|",cnt,not_found)
    WHILE (field != not_found)
      SET column_exclusion = build(column_exclusion,sub,'"',field,'"')
      SET cnt += 1
      SET field = piece(exclude_field,"|",cnt,not_found)
    ENDWHILE
    SET column_exclusion = replace(trim(column_exclusion,3),sub,",")
    SET column_exclusion = build("dic.column_name NOT IN (",cnvtupper(trim(column_exclusion,3)),")")
   ELSE
    SET column_exclusion = "1=1"
   ENDIF
   IF (size(trim(exclude_index)) > 0)
    SET cnt = 1
    SET field = piece(exclude_index,"|",cnt,not_found)
    WHILE (field != not_found)
      SET index_exclusion = build(index_exclusion,sub,'"',field,'"')
      SET cnt += 1
      SET field = piece(exclude_index,"|",cnt,not_found)
    ENDWHILE
    SET index_exclusion = replace(trim(index_exclusion,3),sub,",")
    SET index_exclusion = build("di.index_name NOT IN (",cnvtupper(trim(index_exclusion,3)),")")
   ELSE
    SET index_exclusion = "1=1"
   ENDIF
   SET cnt = 0
   SELECT
    IF (reverse_ind)
     ORDER BY di.index_name, dic.column_position DESC
    ELSE
     ORDER BY di.index_name, dic.column_position
    ENDIF
    INTO "nl:"
    FROM dba_indexes di,
     dba_ind_columns dic
    PLAN (di
     WHERE (di.table_name=PRIVATE::table_name)
      AND di.table_owner="V500"
      AND di.uniqueness="UNIQUE"
      AND di.index_name="XPK*"
      AND parser(index_exclusion))
     JOIN (dic
     WHERE dic.index_name=di.index_name
      AND dic.table_name=di.table_name
      AND dic.table_owner=di.table_owner
      AND parser(column_exclusion))
    ORDER BY di.index_name, dic.column_position
    HEAD REPORT
     null
    HEAD di.index_name
     cnt += 1
    DETAIL
     PRIVATE::field_list = trim(build(PRIVATE::field_list,sub,dic.column_name),3)
    FOOT  di.index_name
     null
    FOOT REPORT
     PRIVATE::field_list = replace(PRIVATE::field_list,sub,"|")
    WITH nocounter
   ;end select
   IF (cnt > 1)
    SET PRIVATE::error_msg = build("Duplicate XPK:",PRIVATE::table_name)
    RETURN(0)
   ENDIF
   IF (size(trim(PRIVATE::field_list))=0)
    SET PRIVATE::error_msg = build("Could not find XPK:",PRIVATE::table_name)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (_::querytable(in_record=vc(ref),list_items=vc,out_record=vc(ref)) =i2)
   RECORD query_rec(
     1 lvl[*]
       2 name = vc
       2 item[*]
         3 name = vc
     1 for_loop = vc
     1 minimum_data_ind = i2
     1 select_list = vc
     1 from_list = vc
     1 plan_join = vc
     1 order_list = vc
     1 save_list = vc
   ) WITH protect
   DECLARE lf = c1 WITH protect, constant(char(10))
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE field_list = vc WITH protect, noconstant(" ")
   DECLARE query_str = vc WITH protect, noconstant(" ")
   CALL PRIVATE::parsereclist(list_items,query_rec)
   IF (PRIVATE::isrecempty(query_rec))
    RETURN(1)
   ENDIF
   CALL PRIVATE::buildselectlist(query_rec)
   CALL PRIVATE::buildfromlist(query_rec)
   CALL PRIVATE::buildplanjoinlist(query_rec)
   CALL PRIVATE::buildorderlist(query_rec)
   CALL PRIVATE::buildsavelist(query_rec)
   SET query_str = concat("SELECT INTO 'NL:'",lf,query_rec->select_list,lf,"FROM",
    lf,query_rec->from_list,lf,query_rec->plan_join,lf,
    "ORDER",lf,query_rec->order_list,lf,"HEAD REPORT",
    lf,"cnt = 0",lf,"DETAIL",lf,
    "cnt = cnt + 1",lf,"if(mod(cnt, 10000) = 1)",lf,"stat = alterlist(out_record->list, cnt + 9999)",
    lf,"endif",lf,query_rec->save_list,lf,
    "FOOT REPORT",lf,"stat = alterlist(out_record->list, cnt)",lf,"WITH NOCOUNTER GO")
   CALL parser(query_str)
   IF (size(out_record->list,5)=0)
    RETURN(true)
   ENDIF
   IF ( NOT (PRIVATE::performupdtprsnlquery(out_record)))
    RETURN(false)
   ENDIF
   FOR (idx = 1 TO size(out_record->list,5))
     SET out_record->list[idx].updt_username = PRIVATE::formatusername(out_record->list[idx].
      updt_username,out_record->list[idx].updt_id,out_record->list[idx].updt_dt_tm)
   ENDFOR
   RETURN(true)
 END ;Subroutine
 DECLARE _::geterror(null) = vc
 SUBROUTINE _::geterror(null)
  IF (size(trim(PRIVATE::err_msg))=0)
   SET PRIVATE::err_msg = concat("UpdatePrsnl(",PRIVATE::table_name,") unknown error")
  ENDIF
  RETURN(PRIVATE::err_msg)
 END ;Subroutine
 SUBROUTINE (PRIVATE::isrecempty(query=vc(ref)) =i2)
   DECLARE lf = c1 WITH protect, constant(char(10))
   DECLARE lvl_idx = i4 WITH protect, noconstant(0)
   DECLARE record_path = vc WITH protect, noconstant(" ")
   DECLARE for_struct = vc WITH protect, noconstant(" ")
   FOR (lvl_idx = 1 TO size(query->lvl,5))
    IF (lvl_idx=1)
     SET record_path = query->lvl[lvl_idx].name
    ELSE
     SET record_path = build(record_path,"[idx_",(lvl_idx - 1),"].",query->lvl[lvl_idx].name)
    ENDIF
    SET for_struct = trim(build(for_struct,lf,"for(idx_",lvl_idx,"= 1 to size(in_record->",
      record_path,",5))"),3)
   ENDFOR
   SET for_struct = build(for_struct,lf,"query->minimum_data_ind = TRUE")
   FOR (lvl_idx = 1 TO size(query->lvl,5))
     SET for_struct = build(for_struct,lf,"endfor")
   ENDFOR
   SET for_struct = concat("SELECT INTO 'NL:'",lf,"FROM DUMMYT",lf,"detail",
    lf,for_struct," WITH NOCOUNTER GO")
   SET query->for_loop = for_struct
   CALL parser(query->for_loop)
   RETURN(negate(query->minimum_data_ind))
 END ;Subroutine
 SUBROUTINE (PRIVATE::parsereclist(list=vc,query=vc(ref)) =null)
   DECLARE level_delim = c1 WITH protect, constant("|")
   DECLARE begin_item_delim = c1 WITH protect, constant(";")
   DECLARE level_cnt = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   DECLARE remainder = vc WITH protect, noconstant(" ")
   DECLARE level = vc WITH protect, noconstant(" ")
   DECLARE item_list = vc WITH protect, noconstant(" ")
   DECLARE list_part = vc WITH protect, noconstant(list)
   SET pos = findstring(level_delim,list)
   IF (pos > 0)
    SET list_part = substring(1,(pos - 1),list)
    SET remainder = substring((pos+ 1),size(list),list)
   ENDIF
   SET pos = findstring(begin_item_delim,list_part)
   IF (pos > 0)
    SET level = substring(1,(pos - 1),list_part)
    SET item_list = substring((pos+ 1),size(list_part),list_part)
   ELSE
    SET level = list_part
   ENDIF
   SET level_cnt = (size(query->lvl,5)+ 1)
   SET stat = alterlist(query->lvl,level_cnt)
   SET query->lvl[level_cnt].name = level
   CALL PRIVATE::parserecitems(item_list,query)
   IF (size(trim(remainder)) > 0)
    CALL PRIVATE::parsereclist(remainder,query)
   ELSE
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE (PRIVATE::parserecitems(list=vc,query=vc(ref)) =null)
   DECLARE item_delim = c1 WITH protect, constant(",")
   DECLARE item_cnt = i4 WITH protect, noconstant(0)
   DECLARE level_cnt = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   DECLARE remainder = vc WITH protect, noconstant(" ")
   DECLARE item = vc WITH protect, noconstant(list)
   SET pos = findstring(item_delim,list)
   IF (pos > 0)
    SET item = substring(1,(pos - 1),list)
    SET remainder = substring((pos+ 1),size(list),list)
   ENDIF
   IF (size(trim(item)) > 0)
    SET level_cnt = size(query->lvl,5)
    SET item_cnt = (size(query->lvl[level_cnt].item,5)+ 1)
    SET stat = alterlist(query->lvl[level_cnt].item,item_cnt)
    SET query->lvl[level_cnt].item[item_cnt].name = item
   ENDIF
   IF (size(trim(remainder)) > 0)
    CALL PRIVATE::parserecitems(remainder,query)
   ELSE
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE (PRIVATE::buildselectlist(query=vc(ref)) =null)
   DECLARE lfc = c2 WITH protect, constant(concat(char(10),","))
   DECLARE sub = c1 WITH protect, constant(char(26))
   DECLARE record_path = vc WITH protect, noconstant(" ")
   DECLARE select_var = vc WITH protect, noconstant(" ")
   DECLARE lvl_idx = i4 WITH protect, noconstant(0)
   DECLARE item_idx = i4 WITH protect, noconstant(0)
   DECLARE select_cnt = i4 WITH protect, noconstant(0)
   FOR (lvl_idx = 1 TO size(query->lvl,5))
    SET record_path = trim(build(record_path,sub,query->lvl[lvl_idx].name,"[d",lvl_idx,
      ".seq]"),3)
    FOR (item_idx = 1 TO size(query->lvl[lvl_idx].item,5))
      SET select_cnt += 1
      SET select_var = build("id_",select_cnt,"= in_record->",record_path,".",
       query->lvl[lvl_idx].item[item_idx].name)
      SET select_var = replace(select_var,sub,".")
      SET query->select_list = trim(build(query->select_list,sub,select_var),3)
    ENDFOR
   ENDFOR
   SET query->select_list = replace(query->select_list,sub,lfc)
 END ;Subroutine
 SUBROUTINE (PRIVATE::buildfromlist(query=vc(ref)) =null)
   DECLARE lfc = c2 WITH protect, constant(concat(char(10),","))
   DECLARE sub = c1 WITH protect, constant(char(26))
   DECLARE lvl_idx = i4 WITH protect, noconstant(0)
   FOR (lvl_idx = 1 TO size(query->lvl,5))
     SET query->from_list = trim(build(query->from_list,sub,"(dummyt d",lvl_idx),3)
     IF (lvl_idx=1)
      SET query->from_list = concat(query->from_list," with seq = value(size(in_record->",query->lvl[
       lvl_idx].name,",5))")
     ENDIF
     SET query->from_list = build(query->from_list,")")
   ENDFOR
   SET query->from_list = replace(query->from_list,sub,lfc)
 END ;Subroutine
 SUBROUTINE (PRIVATE::buildplanjoinlist(query=vc(ref)) =null)
   DECLARE lf = c1 WITH protect, constant(char(10))
   DECLARE sub = c1 WITH protect, constant(char(26))
   DECLARE tmp_path = vc WITH protect, noconstant(" ")
   DECLARE tbl = vc WITH protect, noconstant(" ")
   DECLARE record_path = vc WITH protect, noconstant(" ")
   DECLARE lvl_idx = i4 WITH protect, noconstant(0)
   FOR (lvl_idx = 1 TO size(query->lvl,5))
     SET record_path = trim(build(record_path,sub,query->lvl[lvl_idx].name,"[d",lvl_idx,
       ".seq]"),3)
     SET record_path = replace(record_path,sub,".")
     IF (lvl_idx < size(query->lvl,5))
      SET tmp_path = build(record_path,".",query->lvl[(lvl_idx+ 1)].name)
     ENDIF
     IF (lvl_idx=1)
      SET tbl = "PLAN"
     ELSE
      SET tbl = "JOIN"
     ENDIF
     SET tbl = concat(tbl," d",build(lvl_idx))
     IF (lvl_idx < size(query->lvl,5))
      SET tbl = concat(tbl," where maxrec(d",build((lvl_idx+ 1)),", size(in_record->",tmp_path,
       ",5))")
     ENDIF
     SET query->plan_join = build(query->plan_join,sub,tbl)
   ENDFOR
   SET query->plan_join = replace(query->plan_join,sub,lf)
 END ;Subroutine
 SUBROUTINE (PRIVATE::buildorderlist(query=vc(ref)) =null)
   DECLARE lfc = c2 WITH protect, constant(concat(char(10),","))
   DECLARE sub = c1 WITH protect, constant(char(26))
   DECLARE order_cnt = i4 WITH protect, noconstant(0)
   DECLARE lvl_idx = i4 WITH protect, noconstant(0)
   FOR (lvl_idx = 1 TO size(query->lvl,5))
     FOR (item_idx = 1 TO size(query->lvl[lvl_idx].item,5))
      SET order_cnt += 1
      SET query->order_list = trim(build(query->order_list,sub,"id_",order_cnt),3)
     ENDFOR
   ENDFOR
   SET query->order_list = replace(query->order_list,sub,lfc)
 END ;Subroutine
 SUBROUTINE (PRIVATE::buildsavelist(query=vc(ref)) =null)
   DECLARE lf = c1 WITH protect, constant(char(10))
   DECLARE sub = c1 WITH protect, constant(char(26))
   DECLARE item_idx = i4 WITH protect, noconstant(0)
   DECLARE lvl_idx = i4 WITH protect, noconstant(0)
   DECLARE save_cnt = i4 WITH protect, noconstant(0)
   FOR (lvl_idx = 1 TO size(query->lvl,5))
     FOR (item_idx = 1 TO size(query->lvl[lvl_idx].item,5))
      SET save_cnt += 1
      SET query->save_list = trim(build(query->save_list,sub,"out_record->list[cnt].id_",save_cnt,
        " = id_",
        save_cnt),3)
     ENDFOR
   ENDFOR
   SET query->save_list = replace(query->save_list,sub,lf)
 END ;Subroutine
 SUBROUTINE (PRIVATE::performupdtprsnlquery(out_record=vc(ref)) =i2)
   RECORD fields_rec(
     1 list[*]
       2 name = vc
   ) WITH protect
   DECLARE not_found = vc WITH protect, constant("%NOTFOUND%")
   DECLARE lf = c1 WITH protect, constant(char(10))
   DECLARE table_alias = vc WITH protect, constant("edcw_tmp_tbl")
   DECLARE function_parameters = vc WITH protect, noconstant(" ")
   DECLARE query_str = vc WITH protect, noconstant(" ")
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE field = vc WITH protect, noconstant(" ")
   DECLARE cnt = i4 WITH protect, noconstant(0)
   SET cnt = 1
   SET field = piece(PRIVATE::field_list,"|",cnt,not_found)
   WHILE (field != not_found)
     SET stat = alterlist(fields_rec->list,cnt)
     SET fields_rec->list[cnt].name = field
     SET cnt += 1
     SET field = piece(PRIVATE::field_list,"|",cnt,not_found)
   ENDWHILE
   SET function_parameters = build("(idx, 1, size(out_record->list,5)")
   FOR (cnt = 1 TO size(fields_rec->list,5))
     SET function_parameters = build(function_parameters,lf,",",table_alias,".",
      fields_rec->list[cnt].name,", out_record->list[idx].id_",cnt)
   ENDFOR
   SET function_parameters = build(function_parameters,")")
   SET query_str = concat('SELECT INTO "NL:"',lf,"FROM",lf,PRIVATE::table_name,
    " ",table_alias,lf,", PRSNL p",lf,
    "PLAN ",table_alias,lf,"WHERE expand",function_parameters,
    lf,"JOIN p",lf,"WHERE p.person_id = outerjoin(",table_alias,
    ".updt_id)",lf,"ORDER BY",lf,table_alias,
    ".updt_dt_tm ASC",lf,"DETAIL",lf,"pos = locatevalsort",
    function_parameters,lf,"if(pos > 0)",lf,"out_record->list[pos].updt_dt_tm = ",
    table_alias,".updt_dt_tm",lf,"out_record->list[pos].updt_username = p.username",lf,
    "out_record->list[pos].updt_id = ",table_alias,".updt_id",lf,"endif",
    lf,"WITH EXPAND = 2 GO")
   CALL parser(query_str)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (PRIVATE::formatusername(username=vc,person_id=f8(value,0.0),dt_tm=vc(value,0.0)) =vc)
   IF (size(trim(username)) > 0)
    RETURN(username)
   ELSEIF (dt_tm <= 0.0)
    RETURN(" ")
   ELSE
    RETURN(concat("(N/A) - ID: ",cnvtstring(person_id,17,0)))
   ENDIF
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
END GO
