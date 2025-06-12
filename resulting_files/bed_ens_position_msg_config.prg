CREATE PROGRAM bed_ens_position_msg_config
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD msg_ens_config_asnmnt_request(
   1 msg_config_asnmnt_id = f8
   1 msg_config_id = f8
   1 prsnl_group_id = f8
   1 prsnl_id = f8
   1 position_cd = f8
   1 application_number = i4
   1 delete_ind = i2
 )
 RECORD msg_ens_config_asnmnt_reply(
   1 msg_config_asnmnt_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD config_asnmnt_qry_request(
   1 msg_config_asnmnt_knt = i4
   1 msg_config_asnmnt_list[*]
     2 msg_config_pub_asnmnt_id = f8
   1 prsnl_id = f8
   1 position_cd = f8
   1 application_number = i4
   1 pool_id = f8
 )
 RECORD config_asnmnt_qry_reply(
   1 msg_config_asnmnt_knt = i4
   1 msg_config_asnmnt_list[*]
     2 msg_config_pub_asnmnt_id = f8
     2 prsnl_id = f8
     2 position_cd = f8
     2 application_number = i4
     2 pool_id = f8
     2 msg_config_id = f8
     2 msg_config_public_ind = i2
     2 msg_config_name = vc
     2 msg_config_desc = vc
     2 search_rng_value = f8
     2 search_rng_units = i4
     2 user_modify_ind = i2
     2 msg_category_knt = i4
     2 msg_category_list[*]
       3 msg_category_id = f8
       3 msg_category_type_cd = f8
       3 msg_category_public_ind = i2
       3 msg_category_name = vc
       3 msg_category_desc = vc
       3 msg_notify_category_cd = f8
       3 msg_notify_item_cd = f8
       3 prsnl_id = f8
       3 position_cd = f8
       3 application_number = i4
       3 pool_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD category_qry_request(
   1 msg_category_knt = i4
   1 msg_category_list[*]
     2 msg_category_id = f8
   1 query_all_public_ind = i2
   1 msg_category_type_cd = f8
   1 load_column_dtl = i2
   1 load_event_set_dtl = i2
   1 load_encntr_dtl = i2
   1 load_item_grp_dtl = i2
   1 load_item_type_dtl = i2
 )
 RECORD category_qry_reply(
   1 msg_category_knt = i4
   1 msg_category_list[*]
     2 msg_category_id = f8
     2 msg_category_public_ind = i2
     2 msg_category_name = vc
     2 msg_category_desc = vc
     2 msg_category_prsnl_id = f8
     2 msg_category_position_cd = f8
     2 msg_category_prsnl_group_id = f8
     2 msg_category_app_num = i4
     2 msg_notify_category_cd = f8
     2 msg_notify_item_cd = f8
     2 msg_category_type_cd = f8
     2 msg_column_grp_id = f8
     2 msg_column_grp_public_ind = i2
     2 msg_column_grp_name = vc
     2 msg_column_grp_desc = vc
     2 msg_column_grp_prsnl_id = f8
     2 msg_column_grp_position_cd = f8
     2 msg_column_grp_prsnl_group_id = f8
     2 msg_column_grp_app_num = i4
     2 msg_column_grp_dtl_knt = i4
     2 msg_column_grp_dtl_list[*]
       3 msg_column_type_cd = f8
     2 msg_column_grp_def_column_type = f8
     2 msg_column_grp_descend_ind = i2
     2 msg_item_grp_knt = i4
     2 msg_item_grp_list[*]
       3 msg_item_grp_id = f8
       3 msg_item_grp_public_ind = i2
       3 msg_item_grp_name = vc
       3 msg_item_grp_desc = vc
       3 msg_item_grp_prsnl_id = f8
       3 msg_item_grp_position_cd = f8
       3 msg_item_grp_prsnl_group_id = f8
       3 msg_item_grp_app_num = i4
       3 msg_notify_category_cd = f8
       3 msg_notify_item_cd = f8
       3 msg_item_grp_type_cd = f8
       3 msg_item_grp_dtl_knt = i4
       3 msg_item_grp_dtl_list[*]
         4 msg_item_type_cd = f8
     2 msg_event_set_grp_id = f8
     2 msg_event_filter_inc_ind = i2
     2 msg_event_set_grp_public_ind = i2
     2 msg_event_set_grp_name = vc
     2 msg_event_set_grp_desc = vc
     2 msg_event_set_grp_prsnl_id = f8
     2 msg_event_set_grp_position_cd = f8
     2 msg_event_set_grp_prsnl_group_id = f8
     2 msg_event_set_grp_app_num = i4
     2 msg_event_set_grp_dtl_knt = i4
     2 msg_event_set_grp_dtl_list[*]
       3 event_set_name = vc
     2 msg_encntr_grp_id = f8
     2 msg_encntr_grp_public_ind = i2
     2 msg_encntr_grp_name = vc
     2 msg_encntr_grp_desc = vc
     2 msg_encntr_grp_prsnl_id = f8
     2 msg_encntr_grp_position_cd = f8
     2 msg_encntr_grp_prsnl_group_id = f8
     2 msg_encntr_grp_app_num = i4
     2 msg_encntr_grp_dtl_knt = i4
     2 msg_encntr_grp_dtl_list[*]
       3 encntr_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD msg_ens_config_request(
   1 msg_config_id = f8
   1 delete_ind = i2
   1 public
     2 public_ind = i2
     2 name = c40
     2 desc = c40
     2 prsnl_grp_id = f8
     2 position_cd = f8
     2 prsnl_id = f8
     2 app = i4
   1 search_rng_value = i4
   1 search_rng_units = i4
   1 user_modify_ind = i2
   1 modify_category_ind = i2
   1 msg_category_knt = i4
   1 msg_category_list[*]
     2 msg_category_id = f8
     2 delete_ind = i2
     2 public
       3 public_ind = i2
       3 name = c40
       3 desc = c40
       3 prsnl_grp_id = f8
       3 position_cd = f8
       3 prsnl_id = f8
       3 app = i4
     2 msg_notify_category_cd = f8
     2 msg_notify_item_cd = f8
     2 msg_category_type_cd = f8
     2 modify_column_grp_ind = i2
     2 msg_column_grp
       3 msg_column_grp_id = f8
       3 delete_ind = i2
       3 public
         4 public_ind = i2
         4 name = c40
         4 desc = c40
         4 prsnl_grp_id = f8
         4 position_cd = f8
         4 prsnl_id = f8
         4 app = i4
       3 msg_category_type_cd = f8
       3 modify_ind = i2
       3 column_type_cd_knt = i4
       3 column_type_cd_list[*]
         4 column_type_cd = f8
       3 def_column_type_cd = f8
       3 descend_ind = i2
     2 modify_item_grp_ind = i2
     2 msg_item_grp_knt = i4
     2 msg_item_grp_list[*]
       3 msg_item_grp_id = f8
       3 delete_ind = i2
       3 public
         4 public_ind = i2
         4 name = c40
         4 desc = c40
         4 prsnl_grp_id = f8
         4 position_cd = f8
         4 prsnl_id = f8
         4 app = i4
       3 msg_notify_category_cd = f8
       3 msg_notify_item_cd = f8
       3 msg_category_type_cd = f8
       3 msg_item_grp_type_cd = f8
       3 modify_ind = i2
       3 item_type_cd_knt = i4
       3 item_type_cd_list[*]
         4 item_type_cd = f8
     2 modify_event_grp_ind = i2
     2 msg_event_grp
       3 filter_inclusive_ind = i2
       3 msg_event_grp_id = f8
       3 delete_ind = i2
       3 public
         4 public_ind = i2
         4 name = c40
         4 desc = c40
         4 prsnl_grp_id = f8
         4 position_cd = f8
         4 prsnl_id = f8
         4 app = i4
       3 msg_category_type_cd = f8
       3 modify_ind = i2
       3 event_set_name_knt = i4
       3 event_set_name_list[*]
         4 event_set_name = c40
     2 modify_encntr_grp_ind = i2
     2 msg_encntr_grp
       3 msg_encntr_grp_id = f8
       3 delete_ind = i2
       3 public
         4 public_ind = i2
         4 name = c40
         4 desc = c40
         4 prsnl_grp_id = f8
         4 position_cd = f8
         4 prsnl_id = f8
         4 app = i4
       3 msg_category_type_cd = f8
       3 modify_ind = i2
       3 encntr_type_cd_knt = i4
       3 encntr_type_cd_list[*]
         4 encntr_type_cd = f8
 )
 RECORD msg_ens_config_reply(
   1 msg_config_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD cps_get_detail_prefs_request(
   1 app_qual = i4
   1 app[*]
     2 app_number = i4
     2 group_qual = i4
     2 group[*]
       3 view_name = c12
       3 view_seq = i4
       3 comp_name = c12
       3 comp_seq = i4
   1 position_qual = i4
   1 position[*]
     2 app_number = i4
     2 position_cd = f8
     2 group_qual = i4
     2 group[*]
       3 view_name = c12
       3 view_seq = i4
       3 comp_name = c12
       3 comp_seq = i4
   1 prsnl_qual = i4
   1 prsnl[*]
     2 app_number = i4
     2 prsnl_id = f8
     2 group_qual = i4
     2 group[*]
       3 view_name = c12
       3 view_seq = i4
       3 comp_name = c12
       3 comp_seq = i4
 )
 RECORD cps_get_detail_prefs_reply(
   1 app_qual = i4
   1 app[*]
     2 app_number = i4
     2 group_qual = i4
     2 group[*]
       3 group_id = f8
       3 view_name = c12
       3 view_seq = i4
       3 comp_name = c12
       3 comp_seq = i4
       3 pref_qual = i4
       3 pref[*]
         4 pref_id = f8
         4 pref_name = c32
         4 pref_value = vc
         4 sequence = i4
         4 merge_id = f8
         4 merge_name = vc
         4 active_ind = i2
   1 position_qual = i4
   1 position[*]
     2 position_cd = f8
     2 app_number = i4
     2 group_qual = i4
     2 group[*]
       3 group_id = f8
       3 view_name = c12
       3 view_seq = i4
       3 comp_name = c12
       3 comp_seq = i4
       3 pref_qual = i4
       3 pref[*]
         4 pref_id = f8
         4 pref_name = c32
         4 pref_value = vc
         4 sequence = i4
         4 merge_id = f8
         4 merge_name = vc
         4 active_ind = i2
   1 prsnl_qual = i4
   1 prsnl[*]
     2 prsnl_id = f8
     2 app_number = i4
     2 group_qual = i4
     2 group[*]
       3 group_id = f8
       3 view_name = c12
       3 view_seq = i4
       3 comp_name = c12
       3 comp_seq = i4
       3 pref_qual = i4
       3 pref[*]
         4 pref_id = f8
         4 pref_name = c32
         4 pref_value = vc
         4 sequence = i4
         4 merge_id = f8
         4 merge_name = vc
         4 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD cps_upd_detail_prefs_request(
   1 app_qual = i4
   1 app[*]
     2 app_number = i4
     2 group_qual = i4
     2 group[*]
       3 group_id = f8
       3 view_name = c12
       3 view_seq = i4
       3 comp_name = c12
       3 comp_seq = i4
       3 pref_qual = i4
       3 pref[*]
         4 pref_id = f8
         4 pref_name = c32
         4 pref_value = vc
         4 sequence = i4
         4 merge_id = f8
         4 merge_name = vc
         4 active_ind = i2
   1 position_qual = i4
   1 position[*]
     2 position_cd = f8
     2 app_number = i4
     2 group_qual = i4
     2 group[*]
       3 group_id = f8
       3 view_name = c12
       3 view_seq = i4
       3 comp_name = c12
       3 comp_seq = i4
       3 pref_qual = i4
       3 pref[*]
         4 pref_id = f8
         4 pref_name = c32
         4 pref_value = vc
         4 sequence = i4
         4 merge_id = f8
         4 merge_name = vc
         4 active_ind = i2
   1 prsnl_qual = i4
   1 prsnl[*]
     2 prsnl_id = f8
     2 app_number = i4
     2 group_qual = i4
     2 group[*]
       3 group_id = f8
       3 view_name = c12
       3 view_seq = i4
       3 comp_name = c12
       3 comp_seq = i4
       3 pref_qual = i4
       3 pref[*]
         4 pref_id = f8
         4 pref_name = c32
         4 pref_value = vc
         4 sequence = i4
         4 merge_id = f8
         4 merge_name = vc
         4 active_ind = i2
 )
 RECORD cps_upd_detail_prefs_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD msg_ens_column_grp_request(
   1 msg_column_grp_id = f8
   1 delete_ind = i2
   1 public[1]
     2 public_ind = i2
     2 name = c40
     2 desc = c40
     2 prsnl_grp_id = f8
     2 position_cd = f8
     2 prsnl_id = f8
     2 app = i4
   1 msg_category_type_cd = f8
   1 modify_ind = i2
   1 column_type_cd_knt = i4
   1 column_type_cd_list[*]
     2 column_type_cd = f8
   1 def_column_type_cd = f8
   1 descend_ind = i2
 )
 RECORD msg_ens_column_grp_reply(
   1 msg_column_grp_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 DECLARE bed_ens_position_msg_config_asnmnt_qry(dummyvar=i2) = null
 SUBROUTINE bed_ens_position_msg_config_asnmnt_qry(dummyvar)
   CALL bedlogmessage("bed_ens_position_msg_config_asnmnt_qry","Entering...")
   SET serrmsg = fillstring(132," ")
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   DECLARE ms_select_statement = vc WITH protect, noconstant("")
   DECLARE ms_echo_line = vc WITH protect, noconstant(fillstring(80,"-"))
   DECLARE asnmnt_cnt = i4 WITH protect, noconstant(0)
   DECLARE expand_knt = i4 WITH protect, noconstant(0)
   IF (validate(mn_debug_flag)=0)
    DECLARE mn_debug_flag = i2 WITH protect, noconstant(0)
   ENDIF
   SET mn_debug_flag = 0
   SET asnmnt_cnt = size(config_asnmnt_qry_request->msg_config_asnmnt_list,5)
   IF (asnmnt_cnt=1
    AND (config_asnmnt_qry_request->msg_config_asnmnt_list[1].msg_config_pub_asnmnt_id=0))
    SET asnmnt_cnt = 0
   ENDIF
   IF (asnmnt_cnt=0
    AND (config_asnmnt_qry_request->prsnl_id=0)
    AND (config_asnmnt_qry_request->position_cd=0)
    AND (config_asnmnt_qry_request->pool_id=0))
    GO TO end_script
   ENDIF
   SET ierrcode = error(serrmsg,1)
   SET ms_select_statement = concat(" SELECT INTO 'nl:' ","   ma.msg_config_pub_asnmnt_id ",
    "   ,ma.prsnl_id ","   ,ma.position_cd ","   ,ma.application_number ",
    "   ,ma.prsnl_group_id ","   ,mc.msg_config_id ","   ,mc.public_ind ","   ,mc.config_name ",
    "   ,mc.config_desc ",
    "   ,mc.search_rng_value ","   ,mc.search_rng_units ","   ,mc.user_modify_ind ",
    "   ,mc.prsnl_id ","   ,mc.position_cd ",
    "   ,mc.application_number ","   ,mc.prsnl_group_id ","   ,mcat.msg_category_id ",
    "   ,mcat.msg_category_type_cd ","   ,mcat.public_ind ",
    "   ,mcat.category_name ","   ,mcat.category_desc ","   ,mcat.msg_notify_category_cd ",
    "   ,mcat.msg_notify_item_cd ","   ,mcat.prsnl_id ",
    "   ,mcat.position_cd ","   ,mcat.application_number ","   ,mcat.prsnl_group_id ")
   SET ms_select_statement = concat(ms_select_statement,"  FROM msg_config_pub_asnmnt ma ",
    "       ,msg_config mc ","       ,msg_cfg_cat_reltn mccr ","       ,msg_category mcat ",
    "  PLAN ma ")
   IF (asnmnt_cnt > 0)
    SET ms_select_statement = concat(ms_select_statement,
     "    WHERE expand(expand_knt,1,asnmnt_cnt,ma.msg_config_pub_asnmnt_id, ",
     "          config_asnmnt_qry_request->msg_config_asnmnt_list[expand_knt].msg_config_pub_asnmnt_id) "
     )
   ELSE
    SET ms_select_statement = concat(ms_select_statement,
     "    WHERE ma.position_cd = config_asnmnt_qry_request->position_cd ")
   ENDIF
   SET ms_select_statement = concat(ms_select_statement,"  JOIN mc ",
    "    WHERE ma.msg_config_id = mc.msg_config_id ","  JOIN mccr ",
    "    WHERE mc.msg_config_id = mccr.msg_config_id ",
    "  JOIN mcat ","    WHERE mccr.msg_category_id = mcat.msg_category_id ")
   IF (mn_debug_flag=1)
    CALL echo(ms_echo_line)
    CALL echo("JOIN SECTION")
    CALL echo(ms_echo_line)
    CALL echo(ms_select_statement)
    CALL echo(ms_echo_line)
   ENDIF
   SET ms_select_statement = concat(ms_select_statement,"  HEAD REPORT ","    cfg_asnmnt_cnt = 0 ",
    "  HEAD ma.msg_config_pub_asnmnt_id ","    cat_cnt = 0 ",
    "    mpgd_cnt = 0 ","    cfg_asnmnt_cnt = cfg_asnmnt_cnt + 1 ",
    "    if(mod(cfg_asnmnt_cnt,10) = 1) ",
    "      stat = alterlist(config_asnmnt_qry_reply->msg_config_asnmnt_list, cfg_asnmnt_cnt + 9) ",
    "    endif ",
    "    config_asnmnt_qry_reply->msg_config_asnmnt_list[cfg_asnmnt_cnt].msg_config_pub_asnmnt_id = ma.msg_config_pub_asnmnt_id ",
    "    config_asnmnt_qry_reply->msg_config_asnmnt_list[cfg_asnmnt_cnt].prsnl_id = mc.prsnl_id ",
    "    config_asnmnt_qry_reply->msg_config_asnmnt_list[cfg_asnmnt_cnt].position_cd = mc.position_cd ",
    "    config_asnmnt_qry_reply->msg_config_asnmnt_list[cfg_asnmnt_cnt].application_number = mc.application_number ",
    "    config_asnmnt_qry_reply->msg_config_asnmnt_list[cfg_asnmnt_cnt].pool_id = mc.prsnl_group_id ",
    "    config_asnmnt_qry_reply->msg_config_asnmnt_list[cfg_asnmnt_cnt].msg_config_id = mc.msg_config_id ",
    "    config_asnmnt_qry_reply->msg_config_asnmnt_list[cfg_asnmnt_cnt].msg_config_public_ind = mc.public_ind ",
    "    config_asnmnt_qry_reply->msg_config_asnmnt_list[cfg_asnmnt_cnt].msg_config_name = mc.config_name ",
    "    config_asnmnt_qry_reply->msg_config_asnmnt_list[cfg_asnmnt_cnt].msg_config_desc = mc.config_desc ",
    "    config_asnmnt_qry_reply->msg_config_asnmnt_list[cfg_asnmnt_cnt].search_rng_value = mc.search_rng_value ",
    "    config_asnmnt_qry_reply->msg_config_asnmnt_list[cfg_asnmnt_cnt].search_rng_units = mc.search_rng_units ",
    "    config_asnmnt_qry_reply->msg_config_asnmnt_list[cfg_asnmnt_cnt].user_modify_ind = mc.user_modify_ind ",
    "    HEAD mcat.msg_category_id ","      cat_cnt = cat_cnt + 1 ","      if(mod(cat_cnt, 10) = 1) ",
    "        stat = alterlist(config_asnmnt_qry_reply->msg_config_asnmnt_list[cfg_asnmnt_cnt]->msg_category_list, cat_cnt + 9) ",
    "      endif ","      config_asnmnt_qry_reply->msg_config_asnmnt_list[cfg_asnmnt_cnt]->",
    "         msg_category_list[cat_cnt].msg_category_id = mcat.msg_category_id ",
    "      config_asnmnt_qry_reply->msg_config_asnmnt_list[cfg_asnmnt_cnt]->msg_category_list[cat_cnt].msg_category_type_cd = ",
    "         mcat.msg_category_type_cd ",
    "      config_asnmnt_qry_reply->msg_config_asnmnt_list[cfg_asnmnt_cnt]->",
    "         msg_category_list[cat_cnt].msg_category_public_ind = mc.public_ind ",
    "      config_asnmnt_qry_reply->msg_config_asnmnt_list[cfg_asnmnt_cnt]->",
    "         msg_category_list[cat_cnt].msg_category_name = mcat.category_name ",
    "      config_asnmnt_qry_reply->msg_config_asnmnt_list[cfg_asnmnt_cnt]->",
    "         msg_category_list[cat_cnt].msg_category_desc = mcat.category_desc ",
    "      config_asnmnt_qry_reply->msg_config_asnmnt_list[cfg_asnmnt_cnt]->msg_category_list[cat_cnt].msg_notify_category_cd = ",
    "         mcat.msg_notify_category_cd ",
    "      config_asnmnt_qry_reply->msg_config_asnmnt_list[cfg_asnmnt_cnt]->msg_category_list[cat_cnt].msg_notify_item_cd = ",
    "         mcat.msg_notify_item_cd ",
    "      config_asnmnt_qry_reply->msg_config_asnmnt_list[cfg_asnmnt_cnt]->msg_category_list[cat_cnt].prsnl_id = mcat.prsnl_id ",
    "      config_asnmnt_qry_reply->msg_config_asnmnt_list[cfg_asnmnt_cnt]->",
    "         msg_category_list[cat_cnt].position_cd = mcat.position_cd ",
    "      config_asnmnt_qry_reply->msg_config_asnmnt_list[cfg_asnmnt_cnt]->msg_category_list[cat_cnt].application_number ",
    "         = mcat.application_number ",
    "      config_asnmnt_qry_reply->msg_config_asnmnt_list[cfg_asnmnt_cnt]->",
    "         msg_category_list[cat_cnt].pool_id = mcat.prsnl_group_id ")
   SET ms_select_statement = concat(ms_select_statement,"    FOOT ma.msg_config_pub_asnmnt_id ",
    "      config_asnmnt_qry_reply->msg_config_asnmnt_list[cfg_asnmnt_cnt]->msg_category_knt = cat_cnt ",
    "      stat = alterlist(config_asnmnt_qry_reply->msg_config_asnmnt_list[cfg_asnmnt_cnt]->msg_category_list, cat_cnt) ",
    "  FOOT REPORT ",
    "    config_asnmnt_qry_reply->msg_config_asnmnt_knt = cfg_asnmnt_cnt ",
    "    stat = alterlist(config_asnmnt_qry_reply->msg_config_asnmnt_list, cfg_asnmnt_cnt) ",
    "  WITH nocounter go")
   IF (mn_debug_flag=1)
    CALL echo(ms_echo_line)
    CALL echo("ENTIRE SELECT")
    CALL echo(ms_echo_line)
    CALL echo(ms_select_statement)
    CALL echo(ms_echo_line)
   ENDIF
   CALL parser(ms_select_statement)
   IF (mn_debug_flag=1)
    CALL echorecord(config_asnmnt_qry_reply)
   ENDIF
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET config_asnmnt_qry_reply->status_data.status = "F"
    SET stat = alterlist(config_asnmnt_qry_reply->status_data.subeventstatus,1)
    SET config_asnmnt_qry_reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET config_asnmnt_qry_reply->status_data.subeventstatus[1].operationstatus = "F"
    SET config_asnmnt_qry_reply->status_data.subeventstatus[1].targetobjectname = "CONFIG_ASNMNT_QRY"
    SET config_asnmnt_qry_reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    GO TO end_script
   ENDIF
   IF ((config_asnmnt_qry_reply->msg_config_asnmnt_knt > 0))
    SET config_asnmnt_qry_reply->status_data.status = "S"
   ELSE
    SET config_asnmnt_qry_reply->status_data.status = "Z"
   ENDIF
#end_script
   CALL bedlogmessage("bed_ens_position_msg_config_asnmnt_qry","Exiting...")
 END ;Subroutine
 DECLARE bed_ens_position_msg_config_category_qry(dummyvar=i2) = null
 SUBROUTINE bed_ens_position_msg_config_category_qry(dummyvar)
   CALL bedlogmessage("bed_ens_position_msg_config_category_qry","Entering...")
   SET serrmsg = fillstring(132," ")
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   DECLARE ms_select_statement = vc WITH protect, noconstant("")
   DECLARE ms_echo_line = vc WITH protect, noconstant(fillstring(80,"-"))
   DECLARE encntr_grp_cnt = i4 WITH protect, noconstant(0)
   DECLARE expand_knt = i4 WITH protect, noconstant(0)
   DECLARE grp_cnt = i4 WITH protect, noconstant(0)
   DECLARE type_cnt = i4 WITH protect, noconstant(0)
   IF (validate(mn_debug_flag)=0)
    DECLARE mn_debug_flag = i2 WITH protect, noconstant(0)
   ENDIF
   SET mn_debug_flag = 0
   SET category_cnt = size(category_qry_request->msg_category_list,5)
   IF (category_cnt=1
    AND (category_qry_request->msg_category_list[1].msg_category_id=0))
    SET category_cnt = 0
   ENDIF
   IF (category_cnt=0
    AND (category_qry_request->query_all_public_ind=0))
    RETURN
   ENDIF
   IF ((category_qry_request->load_item_type_dtl=1)
    AND (category_qry_request->load_item_grp_dtl=0))
    RETURN
   ENDIF
   SET ierrcode = error(serrmsg,1)
   SET ms_select_statement = concat(" SELECT INTO 'nl:' ","   mc.msg_category_id ",
    "   ,mc.public_ind ","   ,mc.category_name ","   ,mc.category_desc ",
    "   ,mc.application_number ","   ,mc.prsnl_id ","   ,mc.position_cd ","   ,mc.prsnl_group_id ",
    "   ,mc.msg_category_type_cd ",
    "   ,mc.msg_notify_category_cd ","   ,mc.msg_notify_item_cd ","   ,mcg.msg_column_grp_id ",
    "   ,mcg.public_ind ","   ,mcg.column_grp_name ",
    "   ,mcg.column_grp_desc ","   ,mcg.application_number ","   ,mcg.prsnl_id ",
    "   ,mcg.position_cd ","   ,mcg.prsnl_group_id ",
    "   ,mcg.def_column_type_cd ","   ,mcg.descend_ind ")
   IF ((category_qry_request->load_column_dtl=1))
    SET ms_select_statement = concat(ms_select_statement,"   ,mcgd.msg_column_grp_dtl_r_id ",
     "   ,mcgd.msg_column_type_cd ")
   ENDIF
   IF ((category_qry_request->load_item_grp_dtl=1))
    SET ms_select_statement = concat(ms_select_statement,"   ,mig.msg_item_grp_id ",
     "   ,mig.public_ind ","   ,mig.item_grp_name ","   ,mig.item_grp_desc ",
     "   ,mig.application_number ","   ,mig.prsnl_id ","   ,mig.position_cd ",
     "   ,mig.prsnl_group_id ","   ,mig.msg_item_group_type_cd ",
     "   ,mig.msg_notify_category_cd ","   ,mig.msg_notify_item_cd ")
   ENDIF
   IF ((category_qry_request->load_item_type_dtl=1)
    AND (category_qry_request->load_item_grp_dtl=1))
    SET ms_select_statement = concat(ms_select_statement,"   ,migd.msg_item_type_cd ")
   ENDIF
   SET ms_select_statement = concat(ms_select_statement,"   ,meg.msg_event_grp_id ",
    "   ,meg.filter_inclusive_ind ","   ,meg.public_ind ","   ,meg.event_grp_name ",
    "   ,meg.event_grp_desc ","   ,meg.application_number ","   ,meg.prsnl_id ",
    "   ,meg.position_cd ","   ,meg.prsnl_group_id ")
   IF ((category_qry_request->load_event_set_dtl=1))
    SET ms_select_statement = concat(ms_select_statement,"   ,megd.event_set_name ")
   ENDIF
   SET ms_select_statement = concat(ms_select_statement,"   ,me.msg_encntr_grp_id ",
    "   ,me.public_ind ","   ,me.encntr_grp_name ","   ,me.encntr_grp_desc ",
    "   ,me.application_number ","   ,me.prsnl_id ","   ,me.position_cd ","   ,me.prsnl_group_id ")
   IF ((category_qry_request->load_encntr_dtl=1))
    SET ms_select_statement = concat(ms_select_statement,"   ,med.encntr_type_cd ")
   ENDIF
   SET ms_select_statement = concat(ms_select_statement,"  FROM msg_category mc ",
    "    ,msg_column_grp mcg ","    ,msg_event_grp meg ","    ,msg_encntr_grp me ")
   IF ((category_qry_request->load_column_dtl=1))
    SET ms_select_statement = concat(ms_select_statement," ,msg_column_grp_dtl_reltn mcgd ")
   ENDIF
   IF ((category_qry_request->load_item_grp_dtl=1))
    SET ms_select_statement = concat(ms_select_statement,"  ,msg_itm_grp_cat_reltn migcr ",
     "  ,msg_item_grp mig ")
   ENDIF
   IF ((category_qry_request->load_item_type_dtl=1)
    AND (category_qry_request->load_item_grp_dtl=1))
    SET ms_select_statement = concat(ms_select_statement,"  ,msg_item_grp_dtl_reltn migd ")
   ENDIF
   IF ((category_qry_request->load_event_set_dtl=1))
    SET ms_select_statement = concat(ms_select_statement,"  ,msg_event_grp_dtl_reltn megd ")
   ENDIF
   IF ((category_qry_request->load_encntr_dtl=1))
    SET ms_select_statement = concat(ms_select_statement,"  ,msg_encntr_grp_dtl_reltn med ")
   ENDIF
   IF (mn_debug_flag=1)
    CALL echo(ms_echo_line)
    CALL echo("FIELD SELECT")
    CALL echo(ms_echo_line)
    CALL echo(ms_select_statement)
    CALL echo(ms_echo_line)
   ENDIF
   SET ms_select_statement = concat(ms_select_statement,"    PLAN mc ")
   IF ((category_qry_request->query_all_public_ind=1))
    SET ms_select_statement = concat(ms_select_statement," WHERE mc.public_ind = 1 ",
     " AND mc.msg_category_type_cd = category_qry_request->msg_category_type_cd ")
   ELSE
    SET ms_select_statement = concat(ms_select_statement,
     "      WHERE expand(expand_knt,1,category_cnt,mc.msg_category_id,category_qry_request->",
     "        msg_category_list[expand_knt].msg_category_id) ","        and mc.msg_category_id > 0")
   ENDIF
   SET ms_select_statement = concat(ms_select_statement,"    JOIN mcg ",
    "      WHERE mcg.msg_column_grp_id = outerjoin(mc.msg_column_grp_id) ")
   IF ((category_qry_request->load_column_dtl=1))
    SET ms_select_statement = concat(ms_select_statement,"           JOIN mcgd ",
     "             WHERE mcgd.msg_column_grp_id = outerjoin(mcg.msg_column_grp_id) ")
   ENDIF
   SET ms_select_statement = concat(ms_select_statement,"    JOIN meg ",
    "      WHERE mc.msg_event_grp_id = meg.msg_event_grp_id ")
   IF ((category_qry_request->load_event_set_dtl=1))
    SET ms_select_statement = concat(ms_select_statement,"           JOIN megd ",
     "             WHERE megd.msg_event_grp_id = outerjoin(meg.msg_event_grp_id) ")
   ENDIF
   SET ms_select_statement = concat(ms_select_statement,"    JOIN me ",
    "      WHERE me.msg_encntr_grp_id = outerjoin(mc.msg_encntr_grp_id) ")
   IF ((category_qry_request->load_encntr_dtl=1))
    SET ms_select_statement = concat(ms_select_statement,"           JOIN med ",
     "             WHERE med.msg_encntr_grp_id = outerjoin(me.msg_encntr_grp_id)")
   ENDIF
   IF ((category_qry_request->load_item_grp_dtl=1))
    SET ms_select_statement = concat(ms_select_statement,"    JOIN migcr ",
     "      WHERE migcr.msg_category_id = outerjoin(mc.msg_category_id) ","    JOIN mig ",
     "      WHERE mig.msg_item_grp_id = outerjoin(migcr.msg_item_grp_id) ")
    IF ((category_qry_request->load_item_type_dtl=1))
     SET ms_select_statement = concat(ms_select_statement,"           JOIN migd ",
      "             WHERE migd.msg_item_grp_id = outerjoin(mig.msg_item_grp_id) ")
    ENDIF
   ENDIF
   IF (mn_debug_flag=1)
    CALL echo(ms_echo_line)
    CALL echo("JOIN SELECT")
    CALL echo(ms_echo_line)
    CALL echo(ms_select_statement)
    CALL echo(ms_echo_line)
   ENDIF
   SET ms_select_statement = concat(ms_select_statement,"  ORDER BY mc.msg_category_id ",
    "          ,mc.msg_column_grp_id")
   IF ((category_qry_request->load_column_dtl=1))
    SET ms_select_statement = concat(ms_select_statement,"          ,mcgd.msg_column_type_cd")
   ENDIF
   SET ms_select_statement = concat(ms_select_statement,"          ,mc.msg_event_grp_id")
   IF ((category_qry_request->load_event_set_dtl=1))
    SET ms_select_statement = concat(ms_select_statement,"          ,megd.event_set_name")
   ENDIF
   SET ms_select_statement = concat(ms_select_statement,"          ,mc.msg_encntr_grp_id")
   IF ((category_qry_request->load_encntr_dtl=1))
    SET ms_select_statement = concat(ms_select_statement,"          ,med.encntr_type_cd")
   ENDIF
   IF ((category_qry_request->load_item_grp_dtl=1))
    SET ms_select_statement = concat(ms_select_statement,"          ,migcr.msg_item_grp_id")
   ENDIF
   IF ((category_qry_request->load_item_type_dtl=1))
    SET ms_select_statement = concat(ms_select_statement,"          ,migd.msg_item_type_cd")
   ENDIF
   SET ms_select_statement = concat(ms_select_statement,"  HEAD REPORT ","    cat_cnt = 0 ",
    "  HEAD mc.msg_category_id ","    cat_cnt = cat_cnt + 1 ",
    "    if(mod(cat_cnt,10) = 1) ",
    "      stat = alterlist(category_qry_reply->msg_category_list, cat_cnt + 9) ","    endif ",
    "    item_cnt = 0 ",
    "    category_qry_reply->msg_category_list[cat_cnt].msg_category_id = mc.msg_category_id ",
    "    category_qry_reply->msg_category_list[cat_cnt].msg_category_public_ind = mc.public_ind ",
    "    category_qry_reply->msg_category_list[cat_cnt].msg_category_name = mc.category_name ",
    "    category_qry_reply->msg_category_list[cat_cnt].msg_category_desc = mc.category_desc ",
    "    category_qry_reply->msg_category_list[cat_cnt].msg_category_app_num = mc.application_number ",
    "    category_qry_reply->msg_category_list[cat_cnt].msg_category_prsnl_id = mc.prsnl_id ",
    "    category_qry_reply->msg_category_list[cat_cnt].msg_category_position_cd = mc.position_cd ",
    "    category_qry_reply->msg_category_list[cat_cnt].msg_category_prsnl_group_id = mc.prsnl_group_id ",
    "    category_qry_reply->msg_category_list[cat_cnt].msg_notify_category_cd = mc.msg_notify_category_cd ",
    "    category_qry_reply->msg_category_list[cat_cnt].msg_notify_item_cd = mc.msg_notify_item_cd ",
    "    category_qry_reply->msg_category_list[cat_cnt].msg_category_type_cd = mc.msg_category_type_cd ",
    "    category_qry_reply->msg_category_list[cat_cnt].msg_column_grp_id = mcg.msg_column_grp_id ",
    "    category_qry_reply->msg_category_list[cat_cnt].msg_column_grp_public_ind = mcg.public_ind ",
    "    category_qry_reply->msg_category_list[cat_cnt].msg_column_grp_name = mcg.column_grp_name ",
    "    category_qry_reply->msg_category_list[cat_cnt].msg_column_grp_app_num = mcg.application_number ",
    "    category_qry_reply->msg_category_list[cat_cnt].msg_column_grp_prsnl_id = mcg.prsnl_id ",
    "    category_qry_reply->msg_category_list[cat_cnt].msg_column_grp_position_cd = mcg.position_cd ",
    "    category_qry_reply->msg_category_list[cat_cnt].msg_column_grp_prsnl_group_id = mcg.prsnl_group_id ",
    "    category_qry_reply->msg_category_list[cat_cnt].msg_column_grp_desc = mcg.column_grp_desc ",
    "    category_qry_reply->msg_category_list[cat_cnt].msg_column_grp_def_column_type = mcg.def_column_type_cd ",
    "    category_qry_reply->msg_category_list[cat_cnt].msg_column_grp_descend_ind = mcg.descend_ind "
    )
   IF ((category_qry_request->load_column_dtl=1))
    SET ms_select_statement = concat(ms_select_statement,"      HEAD mc.msg_column_grp_id ",
     "        column_dtl_cnt = 0 ","      HEAD mcgd.msg_column_type_cd ",
     "        column_dtl_cnt = column_dtl_cnt + 1 ",
     "        if(mod(column_dtl_cnt,10) = 1) ",
     "          stat = alterlist(category_qry_reply->msg_category_list[cat_cnt]->msg_column_grp_dtl_list, column_dtl_cnt + 9) ",
     "        endif ",
     "        category_qry_reply->msg_category_list[cat_cnt]->msg_column_grp_dtl_list[column_dtl_cnt].msg_column_type_cd = ",
     "                mcgd.msg_column_type_cd ")
   ENDIF
   SET ms_select_statement = concat(ms_select_statement,
    "    category_qry_reply->msg_category_list[cat_cnt].msg_event_set_grp_id = meg.msg_event_grp_id ",
    "    category_qry_reply->msg_category_list[cat_cnt].msg_event_filter_inc_ind = meg.filter_inclusive_ind ",
    "    category_qry_reply->msg_category_list[cat_cnt].msg_event_set_grp_public_ind = meg.public_ind ",
    "    category_qry_reply->msg_category_list[cat_cnt].msg_event_set_grp_name = meg.event_grp_name ",
    "    category_qry_reply->msg_category_list[cat_cnt].msg_event_set_grp_desc = meg.event_grp_desc ",
    "    category_qry_reply->msg_category_list[cat_cnt].msg_event_set_grp_app_num = meg.application_number ",
    "    category_qry_reply->msg_category_list[cat_cnt].msg_event_set_grp_prsnl_id = meg.prsnl_id ",
    "    category_qry_reply->msg_category_list[cat_cnt].msg_event_set_grp_position_cd = meg.position_cd ",
    "    category_qry_reply->msg_category_list[cat_cnt].msg_event_set_grp_prsnl_group_id = meg.prsnl_group_id "
    )
   IF ((category_qry_request->load_event_set_dtl=1))
    SET ms_select_statement = concat(ms_select_statement,"      HEAD mc.msg_event_grp_id ",
     "        event_cnt = 0 ","      HEAD megd.event_set_name ","        event_cnt = event_cnt + 1 ",
     "        if(mod(event_cnt, 10) = 1) ",
     "          stat = alterlist(category_qry_reply->msg_category_list[cat_cnt]->msg_event_set_grp_dtl_list, event_cnt + 9) ",
     "        endif ","        category_qry_reply->msg_category_list[cat_cnt]-> ",
     "          msg_event_set_grp_dtl_list[event_cnt].event_set_name = megd.event_set_name ")
   ENDIF
   SET ms_select_statement = concat(ms_select_statement,
    "    category_qry_reply->msg_category_list[cat_cnt].msg_encntr_grp_id = me.msg_encntr_grp_id ",
    "    category_qry_reply->msg_category_list[cat_cnt].msg_encntr_grp_public_ind = me.public_ind ",
    "    category_qry_reply->msg_category_list[cat_cnt].msg_encntr_grp_name = me.encntr_grp_name ",
    "    category_qry_reply->msg_category_list[cat_cnt].msg_encntr_grp_desc = me.encntr_grp_desc ",
    "    category_qry_reply->msg_category_list[cat_cnt].msg_encntr_grp_app_num = me.application_number ",
    "    category_qry_reply->msg_category_list[cat_cnt].msg_encntr_grp_prsnl_id = me.prsnl_id ",
    "    category_qry_reply->msg_category_list[cat_cnt].msg_encntr_grp_position_cd = me.position_cd ",
    "    category_qry_reply->msg_category_list[cat_cnt].msg_encntr_grp_prsnl_group_id = me.prsnl_group_id "
    )
   IF ((category_qry_request->load_encntr_dtl=1))
    SET ms_select_statement = concat(ms_select_statement,"      HEAD mc.msg_encntr_grp_id ",
     "        encntr_cnt = 0 ","      HEAD med.encntr_type_cd ",
     "        encntr_cnt = encntr_cnt + 1 ",
     "        if(mod(encntr_cnt, 10) = 1) ",
     "          stat = alterlist(category_qry_reply->msg_category_list[cat_cnt]->msg_encntr_grp_dtl_list, encntr_cnt + 9) ",
     "        endif ",
     "        category_qry_reply->msg_category_list[cat_cnt].msg_encntr_grp_dtl_list[encntr_cnt].encntr_type_cd = ",
     "          med.encntr_type_cd ")
   ENDIF
   IF ((category_qry_request->load_item_grp_dtl=1))
    SET ms_select_statement = concat(ms_select_statement,"  HEAD migcr.msg_item_grp_id ",
     "    item_dtl_cnt = 0 ","    item_cnt = item_cnt + 1 ","    if(mod(item_cnt,10) = 1) ",
     "      stat = alterlist(category_qry_reply->msg_category_list[cat_cnt]->msg_item_grp_list, item_cnt + 9) ",
     "    endif ",
     "    category_qry_reply->msg_category_list[cat_cnt]->msg_item_grp_list[item_cnt].msg_item_grp_id = mig.msg_item_grp_id ",
     "    category_qry_reply->msg_category_list[cat_cnt]->msg_item_grp_list[item_cnt].msg_item_grp_public_ind = mig.public_ind ",
     "    category_qry_reply->msg_category_list[cat_cnt]->msg_item_grp_list[item_cnt].msg_item_grp_name = mig.item_grp_name ",
     "    category_qry_reply->msg_category_list[cat_cnt]->msg_item_grp_list[item_cnt].msg_item_grp_desc = mig.item_grp_desc ",
     "    category_qry_reply->msg_category_list[cat_cnt]->msg_item_grp_list[item_cnt].msg_item_grp_app_num = ",
     "           mig.application_number ",
     "    category_qry_reply->msg_category_list[cat_cnt]->msg_item_grp_list[item_cnt].msg_item_grp_prsnl_id = mig.prsnl_id ",
     "    category_qry_reply->msg_category_list[cat_cnt]->msg_item_grp_list[item_cnt].msg_item_grp_position_cd = mig.position_cd ",
     "    category_qry_reply->msg_category_list[cat_cnt]-> ",
     "           msg_item_grp_list[item_cnt].msg_item_grp_prsnl_group_id = mig.prsnl_group_id ",
     "    category_qry_reply->msg_category_list[cat_cnt]-> ",
     "           msg_item_grp_list[item_cnt].msg_notify_category_cd = mig.msg_notify_category_cd ",
     "    category_qry_reply->msg_category_list[cat_cnt]->msg_item_grp_list[item_cnt].msg_notify_item_cd = mig.msg_notify_item_cd "
,
     "    category_qry_reply->msg_category_list[cat_cnt]-> ",
     "           msg_item_grp_list[item_cnt].msg_item_grp_type_cd = mig.msg_item_group_type_cd ")
    IF ((category_qry_request->load_item_type_dtl=1))
     SET ms_select_statement = concat(ms_select_statement,"      HEAD migd.msg_item_type_cd ",
      "        item_dtl_cnt = item_dtl_cnt + 1 ","        if(mod(item_dtl_cnt,10) = 1) ",
      "          stat = alterlist(category_qry_reply->msg_category_list[cat_cnt]->msg_item_grp_list[item_cnt]->",
      "                 msg_item_grp_dtl_list, ","                 item_dtl_cnt + 9 ) ",
      "        endif ",
      "        category_qry_reply->msg_category_list[cat_cnt]->msg_item_grp_list[item_cnt]-> ",
      "               msg_item_grp_dtl_list[item_dtl_cnt].msg_item_type_cd = migd.msg_item_type_cd ",
      "      FOOT migd.msg_item_type_cd ","        row +0")
    ENDIF
    SET ms_select_statement = concat(ms_select_statement,"  FOOT migcr.msg_item_grp_id ",
     "    category_qry_reply->msg_category_list[cat_cnt]->msg_item_grp_list[item_cnt].msg_item_grp_dtl_knt = item_dtl_cnt ",
     "    stat = alterlist(category_qry_reply->msg_category_list[cat_cnt]->msg_item_grp_list[item_cnt]->msg_item_grp_dtl_list, ",
     "            item_dtl_cnt) ")
   ENDIF
   IF ((category_qry_request->load_encntr_dtl=1))
    SET ms_select_statement = concat(ms_select_statement,"  FOOT mc.msg_encntr_grp_id ",
     "    category_qry_reply->msg_category_list[cat_cnt].msg_encntr_grp_dtl_knt = encntr_cnt ",
     "    stat = alterlist(category_qry_reply->msg_category_list[cat_cnt].msg_encntr_grp_dtl_list, encntr_cnt) "
     )
   ENDIF
   IF ((category_qry_request->load_event_set_dtl=1))
    SET ms_select_statement = concat(ms_select_statement,"  FOOT mc.msg_event_grp_id ",
     "    category_qry_reply->msg_category_list[cat_cnt].msg_event_set_grp_dtl_knt = event_cnt ",
     "    stat = alterlist(category_qry_reply->msg_category_list[cat_cnt]->msg_event_set_grp_dtl_list, event_cnt) "
     )
   ENDIF
   IF ((category_qry_request->load_column_dtl=1))
    SET ms_select_statement = concat(ms_select_statement,"  FOOT mc.msg_column_grp_id ",
     "    category_qry_reply->msg_category_list[cat_cnt].msg_column_grp_dtl_knt = column_dtl_cnt ",
     "    stat = alterlist(category_qry_reply->msg_category_list[cat_cnt]->msg_column_grp_dtl_list, column_dtl_cnt) "
     )
   ENDIF
   SET ms_select_statement = concat(ms_select_statement,"  foot mc.msg_category_id ",
    "    category_qry_reply->msg_category_list[cat_cnt]->msg_item_grp_knt = item_cnt ",
    "    stat = alterlist(category_qry_reply->msg_category_list[cat_cnt]->msg_item_grp_list, item_cnt) ",
    "  FOOT REPORT ",
    "    category_qry_reply->msg_category_knt = cat_cnt ",
    "    stat = alterlist(category_qry_reply->msg_category_list, cat_cnt) ","  WITH nocounter go")
   IF (mn_debug_flag=1)
    CALL echo(ms_echo_line)
    CALL echo("ENTIRE SELECT")
    CALL echo(ms_echo_line)
    CALL echo(ms_select_statement)
    CALL echo(ms_echo_line)
   ENDIF
   CALL parser(ms_select_statement)
   IF (mn_debug_flag=1)
    CALL echorecord(category_qry_reply)
   ENDIF
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET category_qry_reply->status_data.status = "F"
    SET stat = alterlist(category_qry_reply->status_data.subeventstatus,1)
    SET category_qry_reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET category_qry_reply->status_data.subeventstatus[1].operationstatus = "F"
    SET category_qry_reply->status_data.subeventstatus[1].targetobjectname = "MSG_COLUMN_GRP"
    SET category_qry_reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    RETURN
   ENDIF
   IF ((category_qry_reply->msg_category_knt > 0))
    SET category_qry_reply->status_data.status = "S"
   ELSE
    SET category_qry_reply->status_data.status = "Z"
   ENDIF
   CALL bedlogmessage("bed_ens_position_msg_config_category_qry","Exiting...")
 END ;Subroutine
 IF ( NOT (validate(error_flag)))
  DECLARE error_flag = vc WITH protect, noconstant("N")
 ENDIF
 IF ( NOT (validate(ierrcode)))
  DECLARE ierrcode = i4 WITH protect, noconstant(0)
 ENDIF
 IF ( NOT (validate(serrmsg)))
  DECLARE serrmsg = vc WITH protect, noconstant("")
 ENDIF
 IF ( NOT (validate(discerncurrentversion)))
  DECLARE discerncurrentversion = i4 WITH constant(cnvtint(build(format(currev,"##;P0"),format(
      currevminor,"##;P0"),format(currevminor2,"##;P0"))))
 ENDIF
 IF (validate(bedbeginscript,char(128))=char(128))
  DECLARE bedbeginscript(dummyvar=i2) = null
  SUBROUTINE bedbeginscript(dummyvar)
    SET reply->status_data.status = "F"
    SET serrmsg = fillstring(132," ")
    SET ierrcode = error(serrmsg,1)
    SET error_flag = "N"
  END ;Subroutine
 ENDIF
 IF (validate(bederror,char(128))=char(128))
  DECLARE bederror(errordescription=vc) = null
  SUBROUTINE bederror(errordescription)
    SET error_flag = "Y"
    SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
    GO TO exit_script
  END ;Subroutine
 ENDIF
 IF (validate(bedexitsuccess,char(128))=char(128))
  DECLARE bedexitsuccess(dummyvar=i2) = null
  SUBROUTINE bedexitsuccess(dummyvar)
   SET error_flag = "N"
   GO TO exit_script
  END ;Subroutine
 ENDIF
 IF (validate(bederrorcheck,char(128))=char(128))
  DECLARE bederrorcheck(errordescription=vc) = null
  SUBROUTINE bederrorcheck(errordescription)
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    CALL bederror(errordescription)
   ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(bedexitscript,char(128))=char(128))
  DECLARE bedexitscript(commitind=i2) = null
  SUBROUTINE bedexitscript(commitind)
   CALL bederrorcheck("Descriptive error message not provided.")
   IF (error_flag="N")
    SET reply->status_data.status = "S"
    IF (commitind)
     SET reqinfo->commit_ind = 1
    ENDIF
   ELSE
    SET reply->status_data.status = "F"
    IF (commitind)
     SET reqinfo->commit_ind = 0
    ENDIF
   ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(bedlogmessage,char(128))=char(128))
  DECLARE bedlogmessage(subroutinename=vc,message=vc) = null
  SUBROUTINE bedlogmessage(subroutinename,message)
    CALL echo("==================================================================")
    CALL echo(build2(curprog," : ",subroutinename,"() :",message))
    CALL echo("==================================================================")
  END ;Subroutine
 ENDIF
 IF (validate(bedgetlogicaldomain,char(128))=char(128))
  DECLARE bedgetlogicaldomain(dummyvar=i2) = f8
  SUBROUTINE bedgetlogicaldomain(dummyvar)
    DECLARE logicaldomainid = f8 WITH protect, noconstant(0)
    IF (validate(ld_concept_person)=0)
     DECLARE ld_concept_person = i2 WITH public, constant(1)
    ENDIF
    IF (validate(ld_concept_prsnl)=0)
     DECLARE ld_concept_prsnl = i2 WITH public, constant(2)
    ENDIF
    IF (validate(ld_concept_organization)=0)
     DECLARE ld_concept_organization = i2 WITH public, constant(3)
    ENDIF
    IF (validate(ld_concept_healthplan)=0)
     DECLARE ld_concept_healthplan = i2 WITH public, constant(4)
    ENDIF
    IF (validate(ld_concept_alias_pool)=0)
     DECLARE ld_concept_alias_pool = i2 WITH public, constant(5)
    ENDIF
    IF (validate(ld_concept_minvalue)=0)
     DECLARE ld_concept_minvalue = i2 WITH public, constant(1)
    ENDIF
    IF (validate(ld_concept_maxvalue)=0)
     DECLARE ld_concept_maxvalue = i2 WITH public, constant(5)
    ENDIF
    RECORD acm_get_curr_logical_domain_req(
      1 concept = i4
    )
    RECORD acm_get_curr_logical_domain_rep(
      1 logical_domain_id = f8
      1 status_block
        2 status_ind = i2
        2 error_code = i4
    )
    SET acm_get_curr_logical_domain_req->concept = ld_concept_prsnl
    EXECUTE acm_get_curr_logical_domain  WITH replace("REQUEST",acm_get_curr_logical_domain_req),
    replace("REPLY",acm_get_curr_logical_domain_rep)
    SET logicaldomainid = acm_get_curr_logical_domain_rep->logical_domain_id
    RETURN(logicaldomainid)
  END ;Subroutine
 ENDIF
 SUBROUTINE logdebugmessage(message_header,message)
  IF (validate(debug,0)=1)
   CALL bedlogmessage(message_header,message)
  ENDIF
  RETURN(true)
 END ;Subroutine
 IF (validate(bedgetexpandind,char(128))=char(128))
  DECLARE bedgetexpandind(_reccnt=i4(value),_bindcnt=i4(value,200)) = i2
  SUBROUTINE bedgetexpandind(_reccnt,_bindcnt)
    DECLARE nexpandval = i4 WITH noconstant(1)
    IF (discerncurrentversion >= 81002)
     SET nexpandval = 2
    ENDIF
    RETURN(evaluate(floor(((_reccnt - 1)/ _bindcnt)),0,0,nexpandval))
  END ;Subroutine
 ENDIF
 IF (validate(getfeaturetoggle,char(128))=char(128))
  DECLARE getfeaturetoggle(pfeaturetogglekey=vc,psystemidentifier=vc) = i2
  SUBROUTINE getfeaturetoggle(pfeaturetogglekey,psystemidentifier)
    DECLARE isfeatureenabled = i2 WITH noconstant(false)
    DECLARE syscheckfeaturetoggleexistind = i4 WITH noconstant(0)
    DECLARE pftgetdminfoexistind = i4 WITH noconstant(0)
    SET syscheckfeaturetoggleexistind = checkprg("SYS_CHECK_FEATURE_TOGGLE")
    SET pftgetdminfoexistind = checkprg("PFT_GET_DM_INFO")
    IF (syscheckfeaturetoggleexistind > 0
     AND pftgetdminfoexistind > 0)
     RECORD featuretogglerequest(
       1 togglename = vc
       1 username = vc
       1 positioncd = f8
       1 systemidentifier = vc
       1 solutionname = vc
     ) WITH protect
     RECORD featuretogglereply(
       1 togglename = vc
       1 isenabled = i2
       1 status_data
         2 status = c1
         2 subeventstatus[1]
           3 operationname = c25
           3 operationstatus = c1
           3 targetobjectname = c25
           3 targetobjectvalue = vc
     ) WITH protect
     SET featuretogglerequest->togglename = pfeaturetogglekey
     SET featuretogglerequest->systemidentifier = psystemidentifier
     EXECUTE sys_check_feature_toggle  WITH replace("REQUEST",featuretogglerequest), replace("REPLY",
      featuretogglereply)
     IF (validate(debug,false))
      CALL echorecord(featuretogglerequest)
      CALL echorecord(featuretogglereply)
     ENDIF
     IF ((featuretogglereply->status_data.status="S"))
      SET isfeatureenabled = featuretogglereply->isenabled
      CALL logdebugmessage("getFeatureToggle",build("Feature Toggle for Key - ",pfeaturetogglekey,
        " : ",isfeatureenabled))
     ELSE
      CALL logdebugmessage("getFeatureToggle","Call to sys_check_feature_toggle failed")
     ENDIF
    ELSE
     CALL logdebugmessage("getFeatureToggle",build2("sys_check_feature_toggle.prg and / or ",
       " pft_get_dm_info.prg do not exist in domain.",
       " Contact Patient Accounting Team for assistance."))
    ENDIF
    RETURN(isfeatureenabled)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(isfeaturetoggleenabled)))
  DECLARE isfeaturetoggleenabled(pparentfeaturekey=vc,pchildfeaturekey=vc,psystemidentifier=vc) = i2
  SUBROUTINE isfeaturetoggleenabled(pparentfeaturekey,pchildfeaturekey,psystemidentifier)
    DECLARE isparentfeatureenabled = i2 WITH noconstant(false)
    DECLARE ischildfeatureenabled = i2 WITH noconstant(false)
    SET isparentfeatureenabled = getfeaturetoggle(pparentfeaturekey,psystemidentifier)
    IF (isparentfeatureenabled)
     SET ischildfeatureenabled = getfeaturetoggle(pchildfeaturekey,psystemidentifier)
    ENDIF
    CALL logdebugmessage("isFeatureToggleEnabled",build2(" Parent Feature Toggle - ",
      pparentfeaturekey," value is = ",isparentfeatureenabled," and Child Feature Toggle - ",
      pchildfeaturekey," value is = ",ischildfeatureenabled))
    RETURN(ischildfeatureenabled)
  END ;Subroutine
 ENDIF
 DECLARE key_notification = f8 WITH protect, constant(uar_get_code_by("MEANING",3409,"KEYNOTIFICAT"))
 DECLARE priority_notification = f8 WITH protect, constant(uar_get_code_by("MEANING",3409,"PRIORITY")
  )
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE x = i4 WITH protect, noconstant(0)
 DECLARE app_number = f8 WITH protect, noconstant(0)
 DECLARE event_grp_id = f8 WITH protect, noconstant(0)
 DECLARE getmessagecenterconfiginfo(positioncdtocopyfrom=f8) = null
 DECLARE copymessagecenterconfiginfo(positioncdtocopyto=f8) = null
 DECLARE getdetailprefs(positioncdtocopyfrom=f8,appnumber=f8,name=vc) = null
 DECLARE copydetailprefs(positiontocopyto=f8,appnumber=f8,name=vc) = null
 DECLARE setprioritycategory(pos=i4,positioncdtocopyto=f8) = f8
 DECLARE copymessagecenterconfigevent(positioncdtocopyto=f8,new_msg_category_size=i4) = null
 CALL getmessagecenterconfiginfo(request->position_copy_from_cd)
 CALL getdetailprefs(request->position_copy_from_cd,app_number,"PVINBOX")
 FOR (x = 1 TO size(request->positions_copy_to,5))
  CALL copymessagecenterconfiginfo(request->positions_copy_to[x].position_cd)
  CALL copydetailprefs(request->positions_copy_to[x].position_cd,app_number,"PVINBOX")
 ENDFOR
 SUBROUTINE getmessagecenterconfiginfo(positioncdtocopyfrom)
   CALL bedlogmessage("getMessageCenterConfigInfo","Entering...")
   DECLARE y = i4 WITH protect, noconstant(0)
   DECLARE z = i4 WITH protect, noconstant(0)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   SET stat = initrec(config_asnmnt_qry_request)
   SET stat = initrec(config_asnmnt_qry_reply)
   SET stat = initrec(category_qry_request)
   SET stat = initrec(category_qry_reply)
   SET config_asnmnt_qry_request->position_cd = positioncdtocopyfrom
   IF (validate(debug,0)=1)
    CALL echorecord(config_asnmnt_qry_request)
   ENDIF
   CALL bed_ens_position_msg_config_asnmnt_qry(0)
   IF (validate(debug,0)=1)
    CALL echorecord(config_asnmnt_qry_reply)
   ENDIF
   IF ((config_asnmnt_qry_reply->status_data.status="F"))
    CALL bederror("Script call failed")
   ENDIF
   IF ((config_asnmnt_qry_reply->status_data.status="Z"))
    CALL bedlogmessage("getMessageCenterConfigInfo","Exiting...")
    CALL bedexitsuccess(null)
   ENDIF
   FOR (y = 1 TO size(config_asnmnt_qry_reply->msg_config_asnmnt_list,5))
     FOR (z = 1 TO size(config_asnmnt_qry_reply->msg_config_asnmnt_list[y].msg_category_list,5))
       SET cnt = (cnt+ 1)
       SET stat = alterlist(category_qry_request->msg_category_list,(size(category_qry_request->
         msg_category_list,5)+ 1))
       SET category_qry_request->msg_category_list[cnt].msg_category_id = config_asnmnt_qry_reply->
       msg_config_asnmnt_list[y].msg_category_list[z].msg_category_id
     ENDFOR
   ENDFOR
   SET category_qry_request->load_column_dtl = 1
   SET category_qry_request->load_event_set_dtl = 1
   SET category_qry_request->load_encntr_dtl = 1
   SET category_qry_request->load_item_grp_dtl = 1
   SET category_qry_request->load_item_type_dtl = 1
   IF (validate(debug,0)=1)
    CALL echorecord(category_qry_request)
   ENDIF
   CALL bed_ens_position_msg_config_category_qry(0)
   IF (validate(debug,0)=1)
    CALL echorecord(category_qry_reply)
   ENDIF
   IF (size(category_qry_reply->msg_category_list,5) > 0)
    SET app_number = category_qry_reply->msg_category_list[1].msg_category_app_num
   ENDIF
   IF ((category_qry_reply->status_data.status="F"))
    CALL bederror("Script call failed")
   ENDIF
   CALL bedlogmessage("getMessageCenterConfigInfo","Exiting...")
 END ;Subroutine
 SUBROUTINE getdetailprefs(positioncdtocopyfrom,appnumber,name)
   CALL bedlogmessage("getDetailPrefs","Entering...")
   DECLARE group_size = i4 WITH protect, noconstant(0)
   DECLARE group_cnt = i4 WITH protect, noconstant(0)
   DECLARE pref_size = i4 WITH protect, noconstant(0)
   DECLARE pref_cnt = i4 WITH protect, noconstant(0)
   SET cps_get_detail_prefs_request->position_qual = 1
   SET stat = alterlist(cps_get_detail_prefs_request->position,1)
   SET cps_get_detail_prefs_request->position[1].app_number = appnumber
   SET cps_get_detail_prefs_request->position[1].position_cd = positioncdtocopyfrom
   SET cps_get_detail_prefs_request->position[1].group_qual = 1
   SET stat = alterlist(cps_get_detail_prefs_request->position[1].group,1)
   SET cps_get_detail_prefs_request->position[1].group[1].view_name = name
   SET cps_get_detail_prefs_request->position[1].group[1].comp_name = name
   IF (validate(debug,0)=1)
    CALL echorecord(cps_get_detail_prefs_request)
   ENDIF
   SET trace = recpersist
   EXECUTE cps_get_detail_prefs  WITH replace("REQUEST",cps_get_detail_prefs_request), replace(
    "REPLY",cps_get_detail_prefs_reply)
   SET trace = norecpersist
   IF (validate(debug,0)=1)
    CALL echorecord(cps_get_detail_prefs_reply)
   ENDIF
   IF ((cps_get_detail_prefs_reply->status_data.status="F"))
    CALL bederror("Script call failed")
   ENDIF
   CALL bedlogmessage("getDetailPrefs","Exiting...")
 END ;Subroutine
 SUBROUTINE copydetailprefs(positioncdtocopyto,appnumber,name)
   CALL bedlogmessage("copyDetailPrefs","Entering...")
   SET cps_upd_detail_prefs_request->position_qual = 1
   SET stat = alterlist(cps_upd_detail_prefs_request->position,1)
   SET cps_upd_detail_prefs_request->position[1].app_number = appnumber
   SET cps_upd_detail_prefs_request->position[1].position_cd = positioncdtocopyto
   SET group_size = size(cps_get_detail_prefs_reply->position[1].group,5)
   SET cps_upd_detail_prefs_request->position[1].group_qual = group_size
   IF (group_size > 0)
    SET stat = alterlist(cps_upd_detail_prefs_request->position[1].group,group_size)
    FOR (group_cnt = 0 TO group_size)
      SET cps_upd_detail_prefs_request->position[1].group[group_cnt].group_id = 0
      SET cps_upd_detail_prefs_request->position[1].group[group_cnt].view_name =
      cps_get_detail_prefs_reply->position[1].group[group_cnt].view_name
      SET cps_upd_detail_prefs_request->position[1].group[group_cnt].view_seq =
      cps_get_detail_prefs_reply->position[1].group[group_cnt].view_seq
      SET cps_upd_detail_prefs_request->position[1].group[group_cnt].comp_name =
      cps_get_detail_prefs_reply->position[1].group[group_cnt].comp_name
      SET cps_upd_detail_prefs_request->position[1].group[group_cnt].comp_seq =
      cps_get_detail_prefs_reply->position[1].group[group_cnt].comp_seq
      SET cps_upd_detail_prefs_request->position[1].group[group_cnt].pref_qual =
      cps_get_detail_prefs_reply->position[1].group[group_cnt].pref_qual
      SET pref_size = size(cps_get_detail_prefs_reply->position[1].group[group_cnt].pref,5)
      SET stat = alterlist(cps_upd_detail_prefs_request->position[1].group[group_cnt].pref,pref_size)
      FOR (pref_cnt = 1 TO pref_size)
        SET cps_upd_detail_prefs_request->position[1].group[group_cnt].pref[pref_cnt].pref_name =
        cps_get_detail_prefs_reply->position[1].group[group_cnt].pref[pref_cnt].pref_name
        SET cps_upd_detail_prefs_request->position[1].group[group_cnt].pref[pref_cnt].pref_value =
        cps_get_detail_prefs_reply->position[1].group[group_cnt].pref[pref_cnt].pref_value
        SET cps_upd_detail_prefs_request->position[1].group[group_cnt].pref[pref_cnt].sequence =
        cps_get_detail_prefs_reply->position[1].group[group_cnt].pref[pref_cnt].sequence
        SET cps_upd_detail_prefs_request->position[1].group[group_cnt].pref[pref_cnt].merge_id =
        cps_get_detail_prefs_reply->position[1].group[group_cnt].pref[pref_cnt].merge_id
        SET cps_upd_detail_prefs_request->position[1].group[group_cnt].pref[pref_cnt].merge_name =
        cps_get_detail_prefs_reply->position[1].group[group_cnt].pref[pref_cnt].merge_name
        SET cps_upd_detail_prefs_request->position[1].group[group_cnt].pref[pref_cnt].active_ind =
        cps_get_detail_prefs_reply->position[1].group[group_cnt].pref[pref_cnt].active_ind
      ENDFOR
    ENDFOR
   ENDIF
   IF (validate(debug,0)=1)
    CALL echorecord(cps_upd_detail_prefs_request)
   ENDIF
   SET trace = recpersist
   EXECUTE cps_upd_detail_prefs  WITH replace("REQUEST",cps_upd_detail_prefs_request), replace(
    "REPLY",cps_upd_detail_prefs_reply)
   SET trace = norecpersist
   IF (validate(debug,0)=1)
    CALL echorecord(cps_upd_detail_prefs_reply)
   ENDIF
   IF ((cps_upd_detail_prefs_reply->status_data.status="F"))
    CALL bederror("Script call failed")
   ENDIF
   CALL bedlogmessage("copyDetailPrefs","Exiting...")
 END ;Subroutine
 SUBROUTINE copymessagecenterconfigevent(positioncdtocopyto,new_msg_category_size)
   CALL bedlogmessage("copyMessageCenterConfigEvent","Entering...")
   SELECT INTO "nl:"
    FROM msg_event_grp meg
    WHERE (meg.msg_category_type_cd=msg_ens_config_request->msg_category_list[new_msg_category_size].
    msg_event_grp.msg_category_type_cd)
     AND (meg.event_grp_name=msg_ens_config_request->msg_category_list[new_msg_category_size].
    msg_event_grp.public.name)
     AND (meg.event_grp_desc=msg_ens_config_request->msg_category_list[new_msg_category_size].
    msg_event_grp.public.desc)
     AND (meg.public_ind=msg_ens_config_request->msg_category_list[new_msg_category_size].
    msg_event_grp.public.public_ind)
     AND (meg.prsnl_group_id=msg_ens_config_request->msg_category_list[new_msg_category_size].
    msg_event_grp.public.prsnl_grp_id)
     AND (meg.prsnl_id=msg_ens_config_request->msg_category_list[new_msg_category_size].msg_event_grp
    .public.prsnl_id)
     AND (meg.application_number=msg_ens_config_request->msg_category_list[new_msg_category_size].
    msg_event_grp.public.app)
     AND meg.position_cd=positioncdtocopyto
    WITH nocounter
   ;end select
   CALL bederrorcheck("ERROR 001: select from MSG_EVENT_GRP table failed")
   IF (curqual=0)
    SELECT INTO "nl:"
     next_parent = seq(reference_seq,nextval)
     FROM dual
     DETAIL
      event_grp_id = next_parent
     WITH nocounter
    ;end select
    CALL bederrorcheck("ERROR 002: creating new event_grp_id failed")
    INSERT  FROM msg_event_grp meg
     SET meg.msg_event_grp_id = event_grp_id, meg.filter_inclusive_ind = msg_ens_config_request->
      msg_category_list[new_msg_category_size].msg_event_grp.filter_inclusive_ind, meg.event_grp_name
       = msg_ens_config_request->msg_category_list[new_msg_category_size].msg_event_grp.public.name,
      meg.event_grp_desc = msg_ens_config_request->msg_category_list[new_msg_category_size].
      msg_event_grp.public.desc, meg.public_ind = msg_ens_config_request->msg_category_list[
      new_msg_category_size].msg_event_grp.public.public_ind, meg.prsnl_group_id =
      msg_ens_config_request->msg_category_list[new_msg_category_size].msg_event_grp.public.
      prsnl_grp_id,
      meg.position_cd = positioncdtocopyto, meg.prsnl_id = msg_ens_config_request->msg_category_list[
      new_msg_category_size].msg_event_grp.public.prsnl_id, meg.application_number =
      msg_ens_config_request->msg_category_list[new_msg_category_size].msg_event_grp.public.app,
      meg.msg_category_type_cd = msg_ens_config_request->msg_category_list[new_msg_category_size].
      msg_event_grp.msg_category_type_cd, meg.create_dt_tm = cnvtdatetime(curdate,curtime3), meg
      .updt_id = reqinfo->updt_id,
      meg.updt_cnt = 0, meg.updt_applctx = reqinfo->updt_applctx, meg.updt_task = reqinfo->updt_task,
      meg.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    ;end insert
    CALL bederrorcheck("ERROR 003: inserting new msg_event_grp_id failed")
    FOR (ieventsetname = 1 TO msg_ens_config_request->msg_category_list[new_msg_category_size].
    msg_event_grp.event_set_name_knt)
     INSERT  FROM msg_event_grp_dtl_reltn megdr
      SET megdr.msg_event_grp_dtl_r_id = seq(reference_seq,nextval), megdr.event_set_name =
       msg_ens_config_request->msg_category_list[new_msg_category_size].msg_event_grp.
       event_set_name_list[ieventsetname].event_set_name, megdr.msg_event_grp_id = event_grp_id,
       megdr.updt_id = reqinfo->updt_id, megdr.updt_cnt = 0, megdr.updt_applctx = reqinfo->
       updt_applctx,
       megdr.updt_task = reqinfo->updt_task, megdr.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     ;end insert
     CALL bederrorcheck("ERROR 004: inserting new event_set_name failed")
    ENDFOR
    SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_event_grp.
    msg_event_grp_id = event_grp_id
   ENDIF
   CALL bedlogmessage("copyMessageCenterConfigEvent","Exiting...")
 END ;Subroutine
 SUBROUTINE copymessagecenterconfiginfo(positioncdtocopyto)
   CALL bedlogmessage("copyMessageCenterConfigInfo","Entering...")
   DECLARE msg_cfg_asnmnt_cnt = i4 WITH protect, noconstant(0)
   DECLARE msg_cfg_asnmnt_size = i4 WITH protect, noconstant(0)
   DECLARE msg_category_cnt = i4 WITH protect, noconstant(0)
   DECLARE msg_category_size = i4 WITH protect, noconstant(0)
   DECLARE new_msg_category_size = i4 WITH protect, noconstant(0)
   DECLARE category_pos = i4 WITH protect, noconstant(0)
   DECLARE temp_category_cntr = i4 WITH protect, noconstant(0)
   DECLARE column_cntr = i4 WITH protect, noconstant(0)
   DECLARE msg_column_grp_dtl_size = i4 WITH protect, noconstant(0)
   DECLARE new_msg_column_grp_dtl_size = i4 WITH protect, noconstant(0)
   DECLARE item_cntr = i4 WITH protect, noconstant(0)
   DECLARE item_grp_list_size = i4 WITH protect, noconstant(0)
   DECLARE new_item_grp_list_size = i4 WITH protect, noconstant(0)
   DECLARE already_included = i2 WITH protect, noconstant(0)
   DECLARE msg_item_grp_dtl_cntr = i4 WITH protect, noconstant(0)
   DECLARE msg_item_type_cd_size = i4 WITH protect, noconstant(0)
   DECLARE new_msg_item_type_cd_size = i4 WITH protect, noconstant(0)
   DECLARE item_detail_lists_match = i2 WITH protect, noconstant(0)
   DECLARE detail_item_already_included = i2 WITH protect, noconstant(0)
   DECLARE item_match_cnt = i4 WITH protect, noconstant(0)
   DECLARE msg_event_set_grp_dtl_cntr = i4 WITH protect, noconstant(0)
   DECLARE msg_event_set_size = i4 WITH protect, noconstant(0)
   DECLARE new_msg_event_set_size = i4 WITH protect, noconstant(0)
   DECLARE msg_encntr_grp_dtl_cntr = i4 WITH protect, noconstant(0)
   DECLARE msg_encntr_grp_size = i4 WITH protect, noconstant(0)
   DECLARE new_msg_encntr_grp_size = i4 WITH protect, noconstant(0)
   SET msg_cfg_asnmnt_size = size(config_asnmnt_qry_reply->msg_config_asnmnt_list,5)
   FOR (msg_cfg_asnmnt_cnt = 1 TO msg_cfg_asnmnt_size)
     SET msg_ens_config_request->msg_config_id = 0.0
     SET msg_ens_config_request->delete_ind = 0
     SET msg_ens_config_request->modify_category_ind = 1
     SET msg_ens_config_request->public.public_ind = config_asnmnt_qry_reply->msg_config_asnmnt_list[
     msg_cfg_asnmnt_cnt].msg_config_public_ind
     SET msg_ens_config_request->public.name = config_asnmnt_qry_reply->msg_config_asnmnt_list[
     msg_cfg_asnmnt_cnt].msg_config_name
     SET msg_ens_config_request->public.desc = config_asnmnt_qry_reply->msg_config_asnmnt_list[
     msg_cfg_asnmnt_cnt].msg_config_desc
     SET msg_ens_config_request->public.prsnl_grp_id = 0.0
     SET msg_ens_config_request->public.position_cd = positioncdtocopyto
     SET msg_ens_config_request->public.prsnl_id = config_asnmnt_qry_reply->msg_config_asnmnt_list[
     msg_cfg_asnmnt_cnt].prsnl_id
     SET msg_ens_config_request->public.app = config_asnmnt_qry_reply->msg_config_asnmnt_list[
     msg_cfg_asnmnt_cnt].application_number
     SET msg_ens_config_request->search_rng_value = config_asnmnt_qry_reply->msg_config_asnmnt_list[
     msg_cfg_asnmnt_cnt].search_rng_value
     SET msg_ens_config_request->search_rng_units = config_asnmnt_qry_reply->msg_config_asnmnt_list[
     msg_cfg_asnmnt_cnt].search_rng_units
     SET msg_ens_config_request->user_modify_ind = config_asnmnt_qry_reply->msg_config_asnmnt_list[
     msg_cfg_asnmnt_cnt].user_modify_ind
     SET msg_ens_config_request->msg_category_knt = config_asnmnt_qry_reply->msg_config_asnmnt_list[
     msg_cfg_asnmnt_cnt].msg_category_knt
     SET new_msg_category_size = 0
     SET stat = alterlist(msg_ens_config_request->msg_category_list,0)
     SET msg_category_size = size(config_asnmnt_qry_reply->msg_config_asnmnt_list[msg_cfg_asnmnt_cnt]
      .msg_category_list,5)
     FOR (msg_category_cnt = 1 TO msg_category_size)
      SET category_pos = locateval(i,0,size(category_qry_reply->msg_category_list,5),
       config_asnmnt_qry_reply->msg_config_asnmnt_list[msg_cfg_asnmnt_cnt].msg_category_list[
       msg_category_cnt].msg_category_id,category_qry_reply->msg_category_list[i].msg_category_id)
      IF (category_pos > 0)
       SET new_msg_category_size = (new_msg_category_size+ 1)
       SET stat = alterlist(msg_ens_config_request->msg_category_list,new_msg_category_size)
       SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_category_id = 0.0
       SET msg_ens_config_request->msg_category_list[new_msg_category_size].public.name =
       category_qry_reply->msg_category_list[category_pos].msg_category_name
       SET msg_ens_config_request->msg_category_list[new_msg_category_size].public.desc =
       category_qry_reply->msg_category_list[category_pos].msg_category_desc
       SET msg_ens_config_request->msg_category_list[new_msg_category_size].public.prsnl_grp_id =
       category_qry_reply->msg_category_list[category_pos].msg_category_prsnl_group_id
       SET msg_ens_config_request->msg_category_list[new_msg_category_size].public.position_cd =
       positioncdtocopyto
       SET msg_ens_config_request->msg_category_list[new_msg_category_size].public.prsnl_id =
       category_qry_reply->msg_category_list[category_pos].msg_category_prsnl_id
       SET msg_ens_config_request->msg_category_list[new_msg_category_size].public.app =
       category_qry_reply->msg_category_list[category_pos].msg_category_app_num
       SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_category_type_cd =
       category_qry_reply->msg_category_list[category_pos].msg_category_type_cd
       SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_notify_item_cd =
       category_qry_reply->msg_category_list[category_pos].msg_notify_item_cd
       SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_notify_category_cd =
       category_qry_reply->msg_category_list[category_pos].msg_notify_category_cd
       SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_column_grp.public.
       public_ind = category_qry_reply->msg_category_list[category_pos].msg_column_grp_public_ind
       SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_column_grp.public.
       name = category_qry_reply->msg_category_list[category_pos].msg_column_grp_name
       SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_column_grp.public.
       desc = category_qry_reply->msg_category_list[category_pos].msg_column_grp_desc
       SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_column_grp.public.
       prsnl_grp_id = category_qry_reply->msg_category_list[category_pos].
       msg_column_grp_prsnl_group_id
       SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_column_grp.public.
       position_cd = positioncdtocopyto
       SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_column_grp.public.
       prsnl_id = category_qry_reply->msg_category_list[category_pos].msg_column_grp_prsnl_id
       SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_column_grp.public.app
        = category_qry_reply->msg_category_list[category_pos].msg_category_app_num
       SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_column_grp.
       msg_category_type_cd = category_qry_reply->msg_category_list[category_pos].
       msg_category_type_cd
       SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_column_grp.
       column_type_cd_knt = category_qry_reply->msg_category_list[category_pos].
       msg_column_grp_dtl_knt
       SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_column_grp.
       def_column_type_cd = category_qry_reply->msg_category_list[category_pos].
       msg_column_grp_def_column_type
       SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_column_grp.
       descend_ind = category_qry_reply->msg_category_list[category_pos].msg_column_grp_descend_ind
       IF ((msg_ens_config_request->msg_category_list[new_msg_category_size].msg_notify_category_cd=
       priority_notification))
        SET new_column_grp_id = setprioritycategory(category_pos,positioncdtocopyto)
        SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_column_grp.
        msg_column_grp_id = new_column_grp_id
        FOR (temp_category_cntr = 1 TO size(msg_ens_config_request->msg_category_list,5))
          IF ((msg_ens_config_request->msg_category_list[temp_category_cntr].msg_category_type_cd=
          msg_ens_config_request->msg_category_list[new_msg_category_size].msg_category_type_cd))
           SET msg_ens_config_request->msg_category_list[temp_category_cntr].msg_column_grp.
           msg_column_grp_id = msg_ens_config_request->msg_category_list[new_msg_category_size].
           msg_column_grp.msg_column_grp_id
          ENDIF
        ENDFOR
       ELSEIF ((category_qry_reply->msg_category_list[category_pos].msg_notify_category_cd=
       key_notification))
        SET msg_ens_config_request->msg_category_list[new_msg_category_size].modify_column_grp_ind =
        0
       ELSE
        SET msg_ens_config_request->msg_category_list[new_msg_category_size].modify_column_grp_ind =
        1
       ENDIF
       SET msg_column_grp_dtl_size = size(category_qry_reply->msg_category_list[category_pos].
        msg_column_grp_dtl_list,5)
       SET new_msg_column_grp_dtl_size = 0
       FOR (column_cntr = 1 TO msg_column_grp_dtl_size)
         SET new_msg_column_grp_dtl_size = (new_msg_column_grp_dtl_size+ 1)
         SET stat = alterlist(msg_ens_config_request->msg_category_list[new_msg_category_size].
          msg_column_grp.column_type_cd_list,new_msg_column_grp_dtl_size)
         SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_column_grp.
         column_type_cd_list[new_msg_column_grp_dtl_size].column_type_cd = category_qry_reply->
         msg_category_list[category_pos].msg_column_grp_dtl_list[column_cntr].msg_column_type_cd
       ENDFOR
       SET msg_ens_config_request->msg_category_list[new_msg_category_size].modify_item_grp_ind = 1
       SET item_grp_list_size = size(category_qry_reply->msg_category_list[category_pos].
        msg_item_grp_list,5)
       SET new_item_grp_list_size = 0
       FOR (item_cntr = 1 TO item_grp_list_size)
         SET msg_item_type_cd_size = size(category_qry_reply->msg_category_list[category_pos].
          msg_item_grp_list[item_cntr].msg_item_grp_dtl_list,5)
         SET already_included = locateval(i,1,new_item_grp_list_size,category_qry_reply->
          msg_category_list[category_pos].msg_item_grp_list[item_cntr].msg_item_grp_type_cd,
          msg_ens_config_request->msg_category_list[new_msg_category_size].msg_item_grp_list[i].
          msg_item_grp_type_cd)
         IF (already_included=1)
          SET item_detail_lists_match = 1
          SET already_included_item_grp_dtl_list = size(msg_ens_config_request->msg_category_list[
           new_msg_category_size].msg_item_grp_list[already_included].item_type_cd_list,5)
          IF (msg_item_type_cd_size=already_included_item_grp_dtl_list)
           FOR (item_match_cnt = 1 TO already_included_item_grp_dtl_list)
            SET detail_item_already_included = locateval(i,1,msg_item_type_cd_size,
             msg_ens_config_request->msg_category_list[new_msg_category_size].msg_item_grp_list[
             already_included].item_type_cd_list[item_match_cnt].item_type_cd,category_qry_reply->
             msg_category_list[category_pos].msg_item_grp_list[item_cntr].msg_item_grp_dtl_list[i].
             msg_item_type_cd)
            IF (detail_item_already_included=0)
             SET item_detail_lists_match = 0
            ENDIF
           ENDFOR
          ELSE
           SET item_detail_lists_match = 0
          ENDIF
         ENDIF
         IF (((already_included=0) OR (item_detail_lists_match=0)) )
          SET new_item_grp_list_size = (new_item_grp_list_size+ 1)
          SET stat = alterlist(msg_ens_config_request->msg_category_list[new_msg_category_size].
           msg_item_grp_list,new_item_grp_list_size)
          SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_item_grp_list[
          new_item_grp_list_size].public.public_ind = category_qry_reply->msg_category_list[
          category_pos].msg_item_grp_list[item_cntr].msg_item_grp_public_ind
          SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_item_grp_list[
          new_item_grp_list_size].public.name = category_qry_reply->msg_category_list[category_pos].
          msg_item_grp_list[item_cntr].msg_item_grp_name
          SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_item_grp_list[
          new_item_grp_list_size].public.desc = category_qry_reply->msg_category_list[category_pos].
          msg_item_grp_list[item_cntr].msg_item_grp_desc
          SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_item_grp_list[
          new_item_grp_list_size].public.prsnl_grp_id = category_qry_reply->msg_category_list[
          category_pos].msg_item_grp_list[item_cntr].msg_item_grp_prsnl_id
          SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_item_grp_list[
          new_item_grp_list_size].public.position_cd = positioncdtocopyto
          SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_item_grp_list[
          new_item_grp_list_size].public.prsnl_id = category_qry_reply->msg_category_list[
          category_pos].msg_item_grp_list[item_cntr].msg_item_grp_prsnl_id
          SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_item_grp_list[
          new_item_grp_list_size].public.app = category_qry_reply->msg_category_list[category_pos].
          msg_item_grp_list[item_cntr].msg_item_grp_app_num
          SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_item_grp_list[
          new_item_grp_list_size].msg_notify_category_cd = category_qry_reply->msg_category_list[
          category_pos].msg_item_grp_list[item_cntr].msg_notify_category_cd
          SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_item_grp_list[
          new_item_grp_list_size].msg_notify_item_cd = category_qry_reply->msg_category_list[
          category_pos].msg_item_grp_list[item_cntr].msg_notify_item_cd
          SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_item_grp_list[
          new_item_grp_list_size].msg_category_type_cd = category_qry_reply->msg_category_list[
          category_pos].msg_category_type_cd
          SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_item_grp_list[
          new_item_grp_list_size].msg_item_grp_type_cd = category_qry_reply->msg_category_list[
          category_pos].msg_item_grp_list[item_cntr].msg_item_grp_type_cd
          SET new_msg_item_type_cd_size = 0
          FOR (msg_item_grp_dtl_cntr = 1 TO msg_item_type_cd_size)
            SET new_msg_item_type_cd_size = (new_msg_item_type_cd_size+ 1)
            SET stat = alterlist(msg_ens_config_request->msg_category_list[new_msg_category_size].
             msg_item_grp_list[new_item_grp_list_size].item_type_cd_list,new_msg_item_type_cd_size)
            SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_item_grp_list[
            new_item_grp_list_size].item_type_cd_list[new_msg_item_type_cd_size].item_type_cd =
            category_qry_reply->msg_category_list[category_pos].msg_item_grp_list[item_cntr].
            msg_item_grp_dtl_list[msg_item_grp_dtl_cntr].msg_item_type_cd
          ENDFOR
          SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_item_grp_list[
          new_item_grp_list_size].item_type_cd_knt = new_msg_item_type_cd_size
         ENDIF
         SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_item_grp_knt =
         new_item_grp_list_size
       ENDFOR
       SET msg_event_set_size = size(category_qry_reply->msg_category_list[category_pos].
        msg_event_set_grp_dtl_list,5)
       IF (((msg_event_set_size > 1) OR (trim(category_qry_reply->msg_category_list[category_pos].
        msg_event_set_grp_dtl_list[1].event_set_name,3) > "")) )
        SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_event_grp.
        filter_inclusive_ind = category_qry_reply->msg_category_list[category_pos].
        msg_event_filter_inc_ind
        SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_event_grp.
        msg_event_grp_id = category_qry_reply->msg_category_list[category_pos].msg_event_set_grp_id
        SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_event_grp.public.
        public_ind = category_qry_reply->msg_category_list[category_pos].msg_event_set_grp_public_ind
        SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_event_grp.public.
        name = category_qry_reply->msg_category_list[category_pos].msg_event_set_grp_name
        SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_event_grp.public.
        desc = category_qry_reply->msg_category_list[category_pos].msg_event_set_grp_desc
        SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_event_grp.public.
        prsnl_grp_id = category_qry_reply->msg_category_list[category_pos].
        msg_event_set_grp_prsnl_group_id
        SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_event_grp.public.
        position_cd = positioncdtocopyto
        SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_event_grp.public.
        prsnl_id = category_qry_reply->msg_category_list[category_pos].msg_event_set_grp_prsnl_id
        SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_event_grp.public.app
         = category_qry_reply->msg_category_list[category_pos].msg_event_set_grp_app_num
        SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_event_grp.
        msg_category_type_cd = category_qry_reply->msg_category_list[category_pos].
        msg_category_type_cd
        SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_event_grp.
        event_set_name_knt = category_qry_reply->msg_category_list[category_pos].
        msg_event_set_grp_dtl_knt
        SET msg_ens_config_request->msg_category_list[new_msg_category_size].modify_event_grp_ind = 1
        SET new_msg_event_set_size = 0
        FOR (msg_event_set_grp_dtl_cntr = 1 TO msg_event_set_size)
          SET new_msg_event_set_size = (new_msg_event_set_size+ 1)
          SET stat = alterlist(msg_ens_config_request->msg_category_list[new_msg_category_size].
           msg_event_grp.event_set_name_list,new_msg_event_set_size)
          SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_event_grp.
          event_set_name_list[new_msg_event_set_size].event_set_name = category_qry_reply->
          msg_category_list[category_pos].msg_event_set_grp_dtl_list[msg_event_set_grp_dtl_cntr].
          event_set_name
        ENDFOR
        IF (positioncdtocopyto > 0
         AND (msg_ens_config_request->msg_category_list[new_msg_category_size].msg_event_grp.
        msg_event_grp_id > 0))
         CALL copymessagecenterconfigevent(positioncdtocopyto,new_msg_category_size)
        ENDIF
       ENDIF
       SET msg_encntr_grp_size = size(category_qry_reply->msg_category_list[category_pos].
        msg_encntr_grp_dtl_list,5)
       IF (((msg_encntr_grp_size > 1) OR ((category_qry_reply->msg_category_list[category_pos].
       msg_encntr_grp_dtl_list[1].encntr_type_cd != 0.0))) )
        SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_encntr_grp.
        msg_encntr_grp_id = category_qry_reply->msg_category_list[category_pos].msg_encntr_grp_id
        SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_encntr_grp.public.
        public_ind = category_qry_reply->msg_category_list[category_pos].msg_encntr_grp_public_ind
        SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_encntr_grp.public.
        name = category_qry_reply->msg_category_list[category_pos].msg_encntr_grp_name
        SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_encntr_grp.public.
        desc = category_qry_reply->msg_category_list[category_pos].msg_encntr_grp_desc
        SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_encntr_grp.public.
        prsnl_grp_id = category_qry_reply->msg_category_list[category_pos].
        msg_encntr_grp_prsnl_group_id
        SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_encntr_grp.public.
        position_cd = positioncdtocopyto
        SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_encntr_grp.public.
        prsnl_id = category_qry_reply->msg_category_list[category_pos].msg_encntr_grp_prsnl_id
        SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_encntr_grp.public.
        app = category_qry_reply->msg_category_list[category_pos].msg_encntr_grp_app_num
        SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_encntr_grp.
        msg_category_type_cd = category_qry_reply->msg_category_list[category_pos].
        msg_category_type_cd
        SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_encntr_grp.
        encntr_type_cd_knt = category_qry_reply->msg_category_list[category_pos].
        msg_encntr_grp_dtl_knt
        SET msg_ens_config_request->msg_category_list[new_msg_category_size].modify_encntr_grp_ind =
        1
        SET new_msg_encntr_grp_size = 0
        FOR (msg_encntr_grp_dtl_cntr = 1 TO msg_encntr_grp_size)
          SET new_msg_encntr_grp_size = (new_msg_encntr_grp_size+ 1)
          SET stat = alterlist(msg_ens_config_request->msg_category_list[new_msg_category_size].
           msg_encntr_grp.encntr_type_cd_list,new_msg_encntr_grp_size)
          SET msg_ens_config_request->msg_category_list[new_msg_category_size].msg_encntr_grp.
          encntr_type_cd_list[new_msg_encntr_grp_size].encntr_type_cd = category_qry_reply->
          msg_category_list[category_pos].msg_encntr_grp_dtl_list[msg_encntr_grp_dtl_cntr].
          encntr_type_cd
        ENDFOR
       ENDIF
      ENDIF
     ENDFOR
     IF (validate(debug,0)=1)
      CALL echorecord(msg_ens_config_request)
     ENDIF
     EXECUTE msg_ens_config  WITH replace("REQUEST",msg_ens_config_request), replace("REPLY",
      msg_ens_config_reply)
     IF (validate(debug,0)=1)
      CALL echorecord(msg_ens_config_reply)
     ENDIF
     IF ((msg_ens_config_reply->status_data.status="F"))
      CALL bederror("Script call failed")
     ENDIF
     SET msg_ens_config_asnmnt_request->msg_config_asnmnt_id = 0.0
     SET msg_ens_config_asnmnt_request->msg_config_id = msg_ens_config_reply->msg_config_id
     SET msg_ens_config_asnmnt_request->position_cd = positioncdtocopyto
     SET msg_ens_config_asnmnt_request->application_number = config_asnmnt_qry_reply->
     msg_config_asnmnt_list[msg_cfg_asnmnt_cnt].application_number
     IF (validate(debug,0)=1)
      CALL echorecord(msg_ens_config_asnmnt_request)
     ENDIF
     EXECUTE msg_ens_config_asnmnt  WITH replace("REQUEST",msg_ens_config_asnmnt_request), replace(
      "REPLY",msg_ens_config_asnmnt_reply)
     IF (validate(debug,0)=1)
      CALL echorecord(msg_ens_config_asnmnt_reply)
     ENDIF
   ENDFOR
   CALL bedlogmessage("copyMessageCenterConfigInfo","Exiting...")
 END ;Subroutine
 SUBROUTINE setprioritycategory(pos,positioncdtocopyto)
   CALL bedlogmessage("setPriorityCategory","Entering...")
   SET msg_ens_column_grp_request->public.position_cd = positioncdtocopyto
   SET msg_ens_column_grp_request->public.app = category_qry_reply->msg_category_list[pos].
   msg_category_app_num
   SET msg_ens_column_grp_request->msg_category_type_cd = category_qry_reply->msg_category_list[pos].
   msg_category_type_cd
   SET msg_ens_column_grp_request->modify_ind = 1
   SET msg_ens_column_grp_request->column_type_cd_knt = category_qry_reply->msg_category_list[pos].
   msg_column_grp_dtl_knt
   SET msg_column_grp_dtl_size = size(category_qry_reply->msg_category_list[pos].
    msg_column_grp_dtl_list,5)
   SET new_msg_column_grp_dtl_size = 0
   FOR (column_cntr = 1 TO msg_column_grp_dtl_size)
     SET new_msg_column_grp_dtl_size = (new_msg_column_grp_dtl_size+ 1)
     SET stat = alterlist(msg_ens_column_grp_request->column_type_cd_list,new_msg_column_grp_dtl_size
      )
     SET msg_ens_column_grp_request->column_type_cd_list[new_msg_column_grp_dtl_size].column_type_cd
      = category_qry_reply->msg_category_list[category_pos].msg_column_grp_dtl_list[column_cntr].
     msg_column_type_cd
   ENDFOR
   IF (validate(debug,0)=1)
    CALL echorecord(msg_ens_column_grp_request)
   ENDIF
   EXECUTE msg_ens_column_grp  WITH replace("REQUEST",msg_ens_column_grp_request), replace("REPLY",
    msg_ens_column_grp_reply)
   IF (validate(debug,0)=1)
    CALL echorecord(msg_ens_column_grp_reply)
   ENDIF
   CALL bedlogmessage("setPriorityCategory","Exiting...")
   RETURN(msg_ens_column_grp_reply->msg_column_grp_id)
 END ;Subroutine
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
