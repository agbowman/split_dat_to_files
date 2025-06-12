CREATE PROGRAM category_qry:dba
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
 IF (validate(reply,"-1")="-1")
  RECORD reply(
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
 ENDIF
 SET reply->status_data.status = "F"
 SET category_cnt = size(request->msg_category_list,5)
 IF (category_cnt=1
  AND (request->msg_category_list[1].msg_category_id=0))
  SET category_cnt = 0
 ENDIF
 IF (category_cnt=0
  AND (request->query_all_public_ind=0))
  GO TO end_script
 ENDIF
 IF ((request->load_item_type_dtl=1)
  AND (request->load_item_grp_dtl=0))
  GO TO end_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ms_select_statement = concat(" SELECT INTO 'nl:' ","   mc.msg_category_id ","   ,mc.public_ind ",
  "   ,mc.category_name ","   ,mc.category_desc ",
  "   ,mc.application_number ","   ,mc.prsnl_id ","   ,mc.position_cd ","   ,mc.prsnl_group_id ",
  "   ,mc.msg_category_type_cd ",
  "   ,mc.msg_notify_category_cd ","   ,mc.msg_notify_item_cd ","   ,mcg.msg_column_grp_id ",
  "   ,mcg.public_ind ","   ,mcg.column_grp_name ",
  "   ,mcg.column_grp_desc ","   ,mcg.application_number ","   ,mcg.prsnl_id ","   ,mcg.position_cd ",
  "   ,mcg.prsnl_group_id ",
  "   ,mcg.def_column_type_cd ","   ,mcg.descend_ind ")
 IF ((request->load_column_dtl=1))
  SET ms_select_statement = concat(ms_select_statement,"   ,mcgd.msg_column_grp_dtl_r_id ",
   "   ,mcgd.msg_column_type_cd ")
 ENDIF
 IF ((request->load_item_grp_dtl=1))
  SET ms_select_statement = concat(ms_select_statement,"   ,mig.msg_item_grp_id ",
   "   ,mig.public_ind ","   ,mig.item_grp_name ","   ,mig.item_grp_desc ",
   "   ,mig.application_number ","   ,mig.prsnl_id ","   ,mig.position_cd ","   ,mig.prsnl_group_id ",
   "   ,mig.msg_item_group_type_cd ",
   "   ,mig.msg_notify_category_cd ","   ,mig.msg_notify_item_cd ")
 ENDIF
 IF ((request->load_item_type_dtl=1)
  AND (request->load_item_grp_dtl=1))
  SET ms_select_statement = concat(ms_select_statement,"   ,migd.msg_item_type_cd ")
 ENDIF
 SET ms_select_statement = concat(ms_select_statement,"   ,meg.msg_event_grp_id ",
  "   ,meg.filter_inclusive_ind ","   ,meg.public_ind ","   ,meg.event_grp_name ",
  "   ,meg.event_grp_desc ","   ,meg.application_number ","   ,meg.prsnl_id ","   ,meg.position_cd ",
  "   ,meg.prsnl_group_id ")
 IF ((request->load_event_set_dtl=1))
  SET ms_select_statement = concat(ms_select_statement,"   ,megd.event_set_name ")
 ENDIF
 SET ms_select_statement = concat(ms_select_statement,"   ,me.msg_encntr_grp_id ",
  "   ,me.public_ind ","   ,me.encntr_grp_name ","   ,me.encntr_grp_desc ",
  "   ,me.application_number ","   ,me.prsnl_id ","   ,me.position_cd ","   ,me.prsnl_group_id ")
 IF ((request->load_encntr_dtl=1))
  SET ms_select_statement = concat(ms_select_statement,"   ,med.encntr_type_cd ")
 ENDIF
 SET ms_select_statement = concat(ms_select_statement,"  FROM msg_category mc ",
  "    ,msg_column_grp mcg ","    ,msg_event_grp meg ","    ,msg_encntr_grp me ")
 IF ((request->load_column_dtl=1))
  SET ms_select_statement = concat(ms_select_statement," ,msg_column_grp_dtl_reltn mcgd ")
 ENDIF
 IF ((request->load_item_grp_dtl=1))
  SET ms_select_statement = concat(ms_select_statement,"  ,msg_itm_grp_cat_reltn migcr ",
   "  ,msg_item_grp mig ")
 ENDIF
 IF ((request->load_item_type_dtl=1)
  AND (request->load_item_grp_dtl=1))
  SET ms_select_statement = concat(ms_select_statement,"  ,msg_item_grp_dtl_reltn migd ")
 ENDIF
 IF ((request->load_event_set_dtl=1))
  SET ms_select_statement = concat(ms_select_statement,"  ,msg_event_grp_dtl_reltn megd ")
 ENDIF
 IF ((request->load_encntr_dtl=1))
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
 IF ((request->query_all_public_ind=1))
  SET ms_select_statement = concat(ms_select_statement," WHERE mc.public_ind = 1 ",
   " AND mc.msg_category_type_cd = request->msg_category_type_cd ")
 ELSE
  SET ms_select_statement = concat(ms_select_statement,
   "      WHERE expand(expand_knt,1,category_cnt,mc.msg_category_id,request->msg_category_list[expand_knt].msg_category_id) ",
   "        and mc.msg_category_id > 0")
 ENDIF
 SET ms_select_statement = concat(ms_select_statement,"    JOIN mcg ",
  "      WHERE mcg.msg_column_grp_id = outerjoin(mc.msg_column_grp_id) ")
 IF ((request->load_column_dtl=1))
  SET ms_select_statement = concat(ms_select_statement,"           JOIN mcgd ",
   "             WHERE mcgd.msg_column_grp_id = outerjoin(mcg.msg_column_grp_id) ")
 ENDIF
 SET ms_select_statement = concat(ms_select_statement,"    JOIN meg ",
  "      WHERE mc.msg_event_grp_id = meg.msg_event_grp_id ")
 IF ((request->load_event_set_dtl=1))
  SET ms_select_statement = concat(ms_select_statement,"           JOIN megd ",
   "             WHERE megd.msg_event_grp_id = outerjoin(meg.msg_event_grp_id) ")
 ENDIF
 SET ms_select_statement = concat(ms_select_statement,"    JOIN me ",
  "      WHERE me.msg_encntr_grp_id = outerjoin(mc.msg_encntr_grp_id) ")
 IF ((request->load_encntr_dtl=1))
  SET ms_select_statement = concat(ms_select_statement,"           JOIN med ",
   "             WHERE med.msg_encntr_grp_id = outerjoin(me.msg_encntr_grp_id)")
 ENDIF
 IF ((request->load_item_grp_dtl=1))
  SET ms_select_statement = concat(ms_select_statement,"    JOIN migcr ",
   "      WHERE migcr.msg_category_id = outerjoin(mc.msg_category_id) ","    JOIN mig ",
   "      WHERE mig.msg_item_grp_id = outerjoin(migcr.msg_item_grp_id) ")
  IF ((request->load_item_type_dtl=1))
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
 IF ((request->load_column_dtl=1))
  SET ms_select_statement = concat(ms_select_statement,"          ,mcgd.msg_column_type_cd")
 ENDIF
 SET ms_select_statement = concat(ms_select_statement,"          ,mc.msg_event_grp_id")
 IF ((request->load_event_set_dtl=1))
  SET ms_select_statement = concat(ms_select_statement,"          ,megd.event_set_name")
 ENDIF
 SET ms_select_statement = concat(ms_select_statement,"          ,mc.msg_encntr_grp_id")
 IF ((request->load_encntr_dtl=1))
  SET ms_select_statement = concat(ms_select_statement,"          ,med.encntr_type_cd")
 ENDIF
 IF ((request->load_item_grp_dtl=1))
  SET ms_select_statement = concat(ms_select_statement,"          ,migcr.msg_item_grp_id")
 ENDIF
 IF ((request->load_item_type_dtl=1))
  SET ms_select_statement = concat(ms_select_statement,"          ,migd.msg_item_type_cd")
 ENDIF
 SET ms_select_statement = concat(ms_select_statement,"  HEAD REPORT ","    cat_cnt = 0 ",
  "  HEAD mc.msg_category_id ","    cat_cnt = cat_cnt + 1 ",
  "    if(mod(cat_cnt,10) = 1) ","      stat = alterlist(reply->msg_category_list, cat_cnt + 9) ",
  "    endif ","    item_cnt = 0 ",
  "    reply->msg_category_list[cat_cnt].msg_category_id = mc.msg_category_id ",
  "    reply->msg_category_list[cat_cnt].msg_category_public_ind = mc.public_ind ",
  "    reply->msg_category_list[cat_cnt].msg_category_name = mc.category_name ",
  "    reply->msg_category_list[cat_cnt].msg_category_desc = mc.category_desc ",
  "    reply->msg_category_list[cat_cnt].msg_category_app_num = mc.application_number ",
  "    reply->msg_category_list[cat_cnt].msg_category_prsnl_id = mc.prsnl_id ",
  "    reply->msg_category_list[cat_cnt].msg_category_position_cd = mc.position_cd ",
  "    reply->msg_category_list[cat_cnt].msg_category_prsnl_group_id = mc.prsnl_group_id ",
  "    reply->msg_category_list[cat_cnt].msg_notify_category_cd = mc.msg_notify_category_cd ",
  "    reply->msg_category_list[cat_cnt].msg_notify_item_cd = mc.msg_notify_item_cd ",
  "    reply->msg_category_list[cat_cnt].msg_category_type_cd = mc.msg_category_type_cd ",
  "    reply->msg_category_list[cat_cnt].msg_column_grp_id = mcg.msg_column_grp_id ",
  "    reply->msg_category_list[cat_cnt].msg_column_grp_public_ind = mcg.public_ind ",
  "    reply->msg_category_list[cat_cnt].msg_column_grp_name = mcg.column_grp_name ",
  "    reply->msg_category_list[cat_cnt].msg_column_grp_app_num = mcg.application_number ",
  "    reply->msg_category_list[cat_cnt].msg_column_grp_prsnl_id = mcg.prsnl_id ",
  "    reply->msg_category_list[cat_cnt].msg_column_grp_position_cd = mcg.position_cd ",
  "    reply->msg_category_list[cat_cnt].msg_column_grp_prsnl_group_id = mcg.prsnl_group_id ",
  "    reply->msg_category_list[cat_cnt].msg_column_grp_desc = mcg.column_grp_desc ",
  "    reply->msg_category_list[cat_cnt].msg_column_grp_def_column_type = mcg.def_column_type_cd ",
  "    reply->msg_category_list[cat_cnt].msg_column_grp_descend_ind = mcg.descend_ind ")
 IF ((request->load_column_dtl=1))
  SET ms_select_statement = concat(ms_select_statement,"      HEAD mc.msg_column_grp_id ",
   "        column_dtl_cnt = 0 ","      HEAD mcgd.msg_column_type_cd ",
   "        column_dtl_cnt = column_dtl_cnt + 1 ",
   "        if(mod(column_dtl_cnt,10) = 1) ",
   "          stat = alterlist(reply->msg_category_list[cat_cnt]->msg_column_grp_dtl_list, column_dtl_cnt + 9) ",
   "        endif ",
   "        reply->msg_category_list[cat_cnt]->msg_column_grp_dtl_list[column_dtl_cnt].msg_column_type_cd = ",
   "                mcgd.msg_column_type_cd ")
 ENDIF
 SET ms_select_statement = concat(ms_select_statement,
  "    reply->msg_category_list[cat_cnt].msg_event_set_grp_id = meg.msg_event_grp_id ",
  "    reply->msg_category_list[cat_cnt].msg_event_filter_inc_ind = meg.filter_inclusive_ind ",
  "    reply->msg_category_list[cat_cnt].msg_event_set_grp_public_ind = meg.public_ind ",
  "    reply->msg_category_list[cat_cnt].msg_event_set_grp_name = meg.event_grp_name ",
  "    reply->msg_category_list[cat_cnt].msg_event_set_grp_desc = meg.event_grp_desc ",
  "    reply->msg_category_list[cat_cnt].msg_event_set_grp_app_num = meg.application_number ",
  "    reply->msg_category_list[cat_cnt].msg_event_set_grp_prsnl_id = meg.prsnl_id ",
  "    reply->msg_category_list[cat_cnt].msg_event_set_grp_position_cd = meg.position_cd ",
  "    reply->msg_category_list[cat_cnt].msg_event_set_grp_prsnl_group_id = meg.prsnl_group_id ")
 IF ((request->load_event_set_dtl=1))
  SET ms_select_statement = concat(ms_select_statement,"      HEAD mc.msg_event_grp_id ",
   "        event_cnt = 0 ","      HEAD megd.event_set_name ","        event_cnt = event_cnt + 1 ",
   "        if(mod(event_cnt, 10) = 1) ",
   "          stat = alterlist(reply->msg_category_list[cat_cnt]->msg_event_set_grp_dtl_list, event_cnt + 9) ",
   "        endif ",
   "        reply->msg_category_list[cat_cnt]->msg_event_set_grp_dtl_list[event_cnt].event_set_name = megd.event_set_name "
   )
 ENDIF
 SET ms_select_statement = concat(ms_select_statement,
  "    reply->msg_category_list[cat_cnt].msg_encntr_grp_id = me.msg_encntr_grp_id ",
  "    reply->msg_category_list[cat_cnt].msg_encntr_grp_public_ind = me.public_ind ",
  "    reply->msg_category_list[cat_cnt].msg_encntr_grp_name = me.encntr_grp_name ",
  "    reply->msg_category_list[cat_cnt].msg_encntr_grp_desc = me.encntr_grp_desc ",
  "    reply->msg_category_list[cat_cnt].msg_encntr_grp_app_num = me.application_number ",
  "    reply->msg_category_list[cat_cnt].msg_encntr_grp_prsnl_id = me.prsnl_id ",
  "    reply->msg_category_list[cat_cnt].msg_encntr_grp_position_cd = me.position_cd ",
  "    reply->msg_category_list[cat_cnt].msg_encntr_grp_prsnl_group_id = me.prsnl_group_id ")
 IF ((request->load_encntr_dtl=1))
  SET ms_select_statement = concat(ms_select_statement,"      HEAD mc.msg_encntr_grp_id ",
   "        encntr_cnt = 0 ","      HEAD med.encntr_type_cd ","        encntr_cnt = encntr_cnt + 1 ",
   "        if(mod(encntr_cnt, 10) = 1) ",
   "          stat = alterlist(reply->msg_category_list[cat_cnt]->msg_encntr_grp_dtl_list, encntr_cnt + 9) ",
   "        endif ",
   "        reply->msg_category_list[cat_cnt].msg_encntr_grp_dtl_list[encntr_cnt].encntr_type_cd = med.encntr_type_cd "
   )
 ENDIF
 IF ((request->load_item_grp_dtl=1))
  SET ms_select_statement = concat(ms_select_statement,"  HEAD migcr.msg_item_grp_id ",
   "    item_dtl_cnt = 0 ","    item_cnt = item_cnt + 1 ","    if(mod(item_cnt,10) = 1) ",
   "      stat = alterlist(reply->msg_category_list[cat_cnt]->msg_item_grp_list, item_cnt + 9) ",
   "    endif ",
   "    reply->msg_category_list[cat_cnt]->msg_item_grp_list[item_cnt].msg_item_grp_id = mig.msg_item_grp_id ",
   "    reply->msg_category_list[cat_cnt]->msg_item_grp_list[item_cnt].msg_item_grp_public_ind = mig.public_ind ",
   "    reply->msg_category_list[cat_cnt]->msg_item_grp_list[item_cnt].msg_item_grp_name = mig.item_grp_name ",
   "    reply->msg_category_list[cat_cnt]->msg_item_grp_list[item_cnt].msg_item_grp_desc = mig.item_grp_desc ",
   "    reply->msg_category_list[cat_cnt]->msg_item_grp_list[item_cnt].msg_item_grp_app_num = mig.application_number ",
   "    reply->msg_category_list[cat_cnt]->msg_item_grp_list[item_cnt].msg_item_grp_prsnl_id = mig.prsnl_id ",
   "    reply->msg_category_list[cat_cnt]->msg_item_grp_list[item_cnt].msg_item_grp_position_cd = mig.position_cd ",
   "    reply->msg_category_list[cat_cnt]->msg_item_grp_list[item_cnt].msg_item_grp_prsnl_group_id = mig.prsnl_group_id ",
   "    reply->msg_category_list[cat_cnt]->msg_item_grp_list[item_cnt].msg_notify_category_cd = mig.msg_notify_category_cd ",
   "    reply->msg_category_list[cat_cnt]->msg_item_grp_list[item_cnt].msg_notify_item_cd = mig.msg_notify_item_cd ",
   "    reply->msg_category_list[cat_cnt]->msg_item_grp_list[item_cnt].msg_item_grp_type_cd = mig.msg_item_group_type_cd "
   )
  IF ((request->load_item_type_dtl=1))
   SET ms_select_statement = concat(ms_select_statement,"      HEAD migd.msg_item_type_cd ",
    "        item_dtl_cnt = item_dtl_cnt + 1 ","        if(mod(item_dtl_cnt,10) = 1) ",
    "          stat = alterlist(reply->msg_category_list[cat_cnt]->msg_item_grp_list[item_cnt]->msg_item_grp_dtl_list, ",
    "                 item_dtl_cnt + 9 ) ","        endif ",
    "        reply->msg_category_list[cat_cnt]->msg_item_grp_list[item_cnt]-> ",
    "               msg_item_grp_dtl_list[item_dtl_cnt].msg_item_type_cd = migd.msg_item_type_cd ",
    "      FOOT migd.msg_item_type_cd ",
    "        row +0")
  ENDIF
  SET ms_select_statement = concat(ms_select_statement,"  FOOT migcr.msg_item_grp_id ",
   "    reply->msg_category_list[cat_cnt]->msg_item_grp_list[item_cnt].msg_item_grp_dtl_knt = item_dtl_cnt ",
   "    stat = alterlist(reply->msg_category_list[cat_cnt]->msg_item_grp_list[item_cnt]->msg_item_grp_dtl_list, ",
   "            item_dtl_cnt) ")
 ENDIF
 IF ((request->load_encntr_dtl=1))
  SET ms_select_statement = concat(ms_select_statement,"  FOOT mc.msg_encntr_grp_id ",
   "    reply->msg_category_list[cat_cnt].msg_encntr_grp_dtl_knt = encntr_cnt ",
   "    stat = alterlist(reply->msg_category_list[cat_cnt].msg_encntr_grp_dtl_list, encntr_cnt) ")
 ENDIF
 IF ((request->load_event_set_dtl=1))
  SET ms_select_statement = concat(ms_select_statement,"  FOOT mc.msg_event_grp_id ",
   "    reply->msg_category_list[cat_cnt].msg_event_set_grp_dtl_knt = event_cnt ",
   "    stat = alterlist(reply->msg_category_list[cat_cnt]->msg_event_set_grp_dtl_list, event_cnt) ")
 ENDIF
 IF ((request->load_column_dtl=1))
  SET ms_select_statement = concat(ms_select_statement,"  FOOT mc.msg_column_grp_id ",
   "    reply->msg_category_list[cat_cnt].msg_column_grp_dtl_knt = column_dtl_cnt ",
   "    stat = alterlist(reply->msg_category_list[cat_cnt]->msg_column_grp_dtl_list, column_dtl_cnt) "
   )
 ENDIF
 SET ms_select_statement = concat(ms_select_statement,"  foot mc.msg_category_id ",
  "    reply->msg_category_list[cat_cnt]->msg_item_grp_knt = item_cnt ",
  "    stat = alterlist(reply->msg_category_list[cat_cnt]->msg_item_grp_list, item_cnt) ",
  "  FOOT REPORT ",
  "    reply->msg_category_knt = cat_cnt ","    stat = alterlist(reply->msg_category_list, cat_cnt) ",
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
  CALL echorecord(reply)
 ENDIF
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET reply->status_data.status = "F"
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "MSG_COLUMN_GRP"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO end_script
 ENDIF
 IF ((reply->msg_category_knt > 0))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#end_script
END GO
