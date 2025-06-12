CREATE PROGRAM config_qry:dba
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 DECLARE ms_select_statement = vc WITH protect, noconstant("")
 DECLARE ms_echo_line = vc WITH protect, noconstant(fillstring(80,"-"))
 DECLARE config_cnt = i4 WITH protect, noconstant(0)
 DECLARE expand_knt = i4 WITH protect, noconstant(0)
 IF (validate(mn_debug_flag)=0)
  DECLARE mn_debug_flag = i2 WITH protect, noconstant(0)
 ENDIF
 SET mn_debug_flag = 0
 IF (validate(reply,"-1")="-1")
  RECORD reply(
    1 msg_config_knt = i4
    1 msg_config_list[*]
      2 msg_config_id = f8
      2 msg_config_public_ind = i2
      2 msg_config_name = vc
      2 msg_config_desc = vc
      2 search_rng_value = f8
      2 search_rng_units = i2
      2 user_modify_ind = i2
      2 prsnl_id = f8
      2 position_cd = f8
      2 application_number = i4
      2 pool_id = f8
      2 msg_category_knt = i4
      2 msg_category_list[*]
        3 msg_category_id = f8
        3 msg_category_type_cd = f8
        3 msg_category_public_ind = i2
        3 msg_category_name = vc
        3 msg_category_desc = vc
        3 prsnl_id = f8
        3 position_cd = f8
        3 application_number = i4
        3 pool_id = f8
        3 msg_notify_category_cd = f8
        3 msg_notify_item_cd = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET config_cnt = size(request->msg_config_list,5)
 IF (config_cnt=1
  AND (request->msg_config_list[1].msg_config_id=0))
  SET config_cnt = 0
 ENDIF
 IF (config_cnt=0
  AND (request->query_all_public_ind=0))
  GO TO end_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ms_select_statement = concat(" SELECT INTO 'nl:' ","   mc.msg_config_id ","   ,mc.public_ind ",
  "   ,mc.config_name ","   ,mc.config_desc ",
  "   ,mc.search_rng_value ","   ,mc.search_rng_units ","   ,mc.user_modify_ind ","   ,mc.prsnl_id ",
  "   ,mc.position_cd ",
  "   ,mc.application_number ","   ,mc.prsnl_group_id ","   ,mcat.msg_category_id ",
  "   ,mcat.msg_category_type_cd ","   ,mcat.public_ind ",
  "   ,mcat.category_name ","   ,mcat.category_desc ","   ,mcat.prsnl_id ","   ,mcat.position_cd ",
  "   ,mcat.application_number ",
  "   ,mcat.prsnl_group_id ","   ,mcat.msg_notify_category_cd ","   ,mcat.msg_notify_item_cd ",
  "  FROM msg_config mc ","    ,msg_cfg_cat_reltn mccr ",
  "    ,msg_category mcat ","  PLAN mc ")
 IF ((request->query_all_public_ind=1))
  SET ms_select_statement = concat(ms_select_statement,"    WHERE mc.public_ind = 1 ")
 ELSE
  SET ms_select_statement = concat(ms_select_statement,
   "    WHERE expand(expand_knt,1,config_cnt,mc.msg_config_id,request->msg_config_list[expand_knt].msg_config_id) "
   )
 ENDIF
 SET ms_select_statement = concat(ms_select_statement,"  JOIN mccr ",
  "    WHERE mc.msg_config_id = mccr.msg_config_id ","  JOIN mcat ",
  "    WHERE mccr.msg_category_id = mcat.msg_category_id ")
 IF ((request->query_all_public_ind=1))
  SET ms_select_statement = concat(ms_select_statement,"      AND mcat.public_ind = 1 ")
 ENDIF
 SET ms_select_statement = concat(ms_select_statement,"  HEAD REPORT ","    cfg_cnt = 0 ",
  "  HEAD mc.msg_config_id ","    cat_cnt = 0 ",
  "    cfg_cnt = cfg_cnt + 1 ","    if(mod(cfg_cnt, 10) = 1) ",
  "      stat = alterlist(reply->msg_config_list, cfg_cnt + 9) ","    endif ",
  "    reply->msg_config_list[cfg_cnt].msg_config_id = mc.msg_config_id ",
  "    reply->msg_config_list[cfg_cnt].msg_config_public_ind = mc.public_ind ",
  "    reply->msg_config_list[cfg_cnt].msg_config_name = mc.config_name ",
  "    reply->msg_config_list[cfg_cnt].msg_config_desc = mc.config_desc ",
  "    reply->msg_config_list[cfg_cnt].search_rng_value = mc.search_rng_value ",
  "    reply->msg_config_list[cfg_cnt].search_rng_units = mc.search_rng_units ",
  "    reply->msg_config_list[cfg_cnt].user_modify_ind = mc.user_modify_ind ",
  "    reply->msg_config_list[cfg_cnt].prsnl_id = mc.prsnl_id ",
  "    reply->msg_config_list[cfg_cnt].position_cd = mc.position_cd ",
  "    reply->msg_config_list[cfg_cnt].application_number = mc.application_number ",
  "    reply->msg_config_list[cfg_cnt].pool_id = mc.prsnl_group_id ",
  "    HEAD mcat.msg_category_id ","      cat_cnt = cat_cnt + 1 ","      if(mod(cat_cnt, 10) = 1) ",
  "        stat = alterlist(reply->msg_config_list[cfg_cnt].msg_category_list, cat_cnt + 9) ",
  "      endif ",
  "      reply->msg_config_list[cfg_cnt].msg_category_list[cat_cnt].msg_category_id = mcat.msg_category_id ",
  "      reply->msg_config_list[cfg_cnt].msg_category_list[cat_cnt].msg_category_type_cd = mcat.msg_category_type_cd ",
  "      reply->msg_config_list[cfg_cnt].msg_category_list[cat_cnt].msg_category_public_ind = mcat.public_ind ",
  "      reply->msg_config_list[cfg_cnt].msg_category_list[cat_cnt].msg_category_name = mcat.category_name ",
  "      reply->msg_config_list[cfg_cnt].msg_category_list[cat_cnt].msg_category_desc = mcat.category_desc ",
  "      reply->msg_config_list[cfg_cnt].msg_category_list[cat_cnt].prsnl_id = mcat.prsnl_id ",
  "      reply->msg_config_list[cfg_cnt].msg_category_list[cat_cnt].position_cd = mcat.position_cd ",
  "      reply->msg_config_list[cfg_cnt].msg_category_list[cat_cnt].application_number = mcat.application_number ",
  "      reply->msg_config_list[cfg_cnt].msg_category_list[cat_cnt].pool_id = mcat.prsnl_group_id ",
  "      reply->msg_config_list[cfg_cnt].msg_category_list[cat_cnt].msg_notify_category_cd = mcat.msg_notify_category_cd ",
  "      reply->msg_config_list[cfg_cnt].msg_category_list[cat_cnt].msg_notify_item_cd = mcat.msg_notify_item_cd ",
  "    FOOT mcat.msg_category_id ",
  "      reply->msg_config_list[cfg_cnt].msg_category_knt = cat_cnt ","  FOOT mc.msg_config_id ",
  "      stat = alterlist(reply->msg_config_list[cfg_cnt].msg_category_list, cat_cnt) ",
  "  FOOT REPORT ","    reply->msg_config_knt = cfg_cnt ",
  "    stat = alterlist(reply->msg_config_list, cfg_cnt) ","  WITH nocounter go")
 IF (mn_debug_flag=1)
  CALL echo(ms_echo_line)
  CALL echo("ENTIRE SELECT")
  CALL echo(ms_echo_line)
  CALL echo(ms_select_statement)
  CALL echo(ms_echo_line)
 ENDIF
 CALL parser(ms_select_statement)
 IF (mn_debug_flag=1)
  CALL echorecord(reply)
 ENDIF
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET reply->status_data.status = "F"
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "MSG_CONFIG"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO end_script
 ENDIF
 IF ((reply->msg_config_knt > 0))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#end_script
END GO
