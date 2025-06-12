CREATE PROGRAM column_grp_qry:dba
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 DECLARE ms_select_statement = vc WITH protect, noconstant("")
 DECLARE ms_echo_line = vc WITH protect, noconstant(fillstring(80,"-"))
 DECLARE column_grp_cnt = i4 WITH protect, noconstant(0)
 DECLARE expand_knt = i4 WITH protect, noconstant(0)
 DECLARE grp_cnt = i4 WITH protect, noconstant(0)
 DECLARE type_cnt = i4 WITH protect, noconstant(0)
 IF (validate(mn_debug_flag)=0)
  DECLARE mn_debug_flag = i2 WITH protect, noconstant(0)
 ENDIF
 SET mn_debug_flag = 0
 IF (validate(reply,"-1")="-1")
  RECORD reply(
    1 msg_column_grp_knt = i4
    1 msg_column_grp_list[*]
      2 msg_column_grp_id = f8
      2 name = vc
      2 desc = vc
      2 public_ind = i2
      2 create_dt_tm = dq8
      2 msg_category_type_cd = f8
      2 column_cd_list[*]
        3 column_type_cd = f8
      2 prsnl_id = f8
      2 position_cd = f8
      2 prsnl_group_id = f8
      2 app_num = i4
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
 IF ((request->msg_category_type_cd=0)
  AND (request->query_all_public_ind=1))
  GO TO end_script
 ENDIF
 SET column_grp_cnt = size(request->msg_column_grp_list,5)
 IF (column_grp_cnt=1
  AND (request->msg_column_grp_list[1].msg_column_grp_id=0))
  SET column_grp_cnt = 0
 ENDIF
 IF (column_grp_cnt=0
  AND (request->query_all_public_ind=0))
  GO TO end_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ms_select_statement = concat(" SELECT INTO 'nl:' ","   mc.msg_column_grp_id ",
  "   ,mc.column_grp_name ","   ,mc.column_grp_desc ","   ,mc.public_ind ",
  "   ,mc.create_dt_tm ","   ,mc.msg_category_type_cd ","   ,mc.application_number","   ,mc.prsnl_id",
  "   ,mc.position_cd",
  "   ,mc.prsnl_group_id","   ,mcd.msg_column_type_cd "," FROM msg_column_grp mc ",
  "    ,msg_column_grp_dtl_reltn mcd "," PLAN mc ")
 IF ((request->query_all_public_ind=1))
  SET ms_select_statement = concat(ms_select_statement,
   " WHERE mc.msg_category_type_cd = request->msg_category_type_cd "," AND mc.public_ind = 1 ")
 ELSE
  SET ms_select_statement = concat(ms_select_statement,
   "   WHERE expand(expand_knt,1,column_grp_cnt,mc.msg_column_grp_id, ",
   "     request->msg_column_grp_list[expand_knt].msg_column_grp_id) ")
 ENDIF
 SET ms_select_statement = concat(ms_select_statement," JOIN mcd ",
  "   WHERE mc.msg_column_grp_id = mcd.msg_column_grp_id "," HEAD report ","   grp_cnt = 0 ",
  " HEAD mc.msg_column_grp_id ","   type_cnt = 0 ","   grp_cnt = grp_cnt + 1 ",
  "   if (grp_cnt > size(reply->msg_column_grp_list,5)) ",
  "     stat = alterlist(reply->msg_column_grp_list,grp_cnt + 9) ",
  "   endif ","   reply->msg_column_grp_list[grp_cnt].msg_column_grp_id = mc.msg_column_grp_id ",
  "   reply->msg_column_grp_list[grp_cnt].name = mc.column_grp_name ",
  "   reply->msg_column_grp_list[grp_cnt].desc = mc.column_grp_desc ",
  "   reply->msg_column_grp_list[grp_cnt].public_ind = mc.public_ind ",
  "   reply->msg_column_grp_list[grp_cnt].create_dt_tm = mc.create_dt_tm ",
  "   reply->msg_column_grp_list[grp_cnt].msg_category_type_cd = mc.msg_category_type_cd ",
  "   reply->msg_column_grp_list[grp_cnt].app_num = mc.application_number",
  "   reply->msg_column_grp_list[grp_cnt].prsnl_id = mc.prsnl_id",
  "   reply->msg_column_grp_list[grp_cnt].position_cd = mc.position_cd",
  "   reply->msg_column_grp_list[grp_cnt].prsnl_group_id = mc.prsnl_group_id",
  " HEAD mcd.msg_column_type_cd ","   type_cnt = type_cnt + 1 ",
  "   if(type_cnt > size(reply->msg_column_grp_list[grp_cnt]->column_cd_list,5)) ",
  "     stat = alterlist(reply->msg_column_grp_list[grp_cnt]->column_cd_list,type_cnt + 9) ",
  "   endif ",
  "   reply->msg_column_grp_list[grp_cnt]->column_cd_list[type_cnt].column_type_cd = mcd.msg_column_type_cd ",
  " FOOT mcd.msg_column_type_cd ",
  "   stat = alterlist(reply->msg_column_grp_list[grp_cnt]->column_cd_list,type_cnt) ",
  " FOOT report ",
  "    reply->msg_column_grp_knt = grp_cnt ",
  "    stat = alterlist(reply->msg_column_grp_list,grp_cnt) "," WITH nocounter go")
 IF (mn_debug_flag=1)
  CALL echo(ms_echo_line)
  CALL echo(ms_select_statement)
  CALL echo(ms_echo_line)
 ENDIF
 CALL parser(ms_select_statement)
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
 IF ((reply->msg_column_grp_knt > 0))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#end_script
END GO
