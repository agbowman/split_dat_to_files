CREATE PROGRAM category_qry_by_owner:dba
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SET reply->status_data.status = "F"
 DECLARE ms_select_statement = vc WITH protect, noconstant("")
 DECLARE ms_echo_line = vc WITH protect, noconstant(fillstring(80,"-"))
 DECLARE cat_cnt = i4 WITH protect, noconstant(0)
 IF (validate(mn_debug_flag)=0)
  DECLARE mn_debug_flag = i2 WITH protect, noconstant(0)
 ENDIF
 SET mn_debug_flag = 0
 IF (validate(reply,"-1")="-1")
  RECORD reply(
    1 msg_category_knt = i4
    1 msg_category_list[*]
      2 msg_category_id = f8
      2 name = vc
      2 create_dt_tm = dq8
      2 msg_category_type_cd = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET ms_select_statement = concat(" SELECT INTO 'nl:' ","   mc.msg_category_id ",
  "   ,mc.category_name ","   ,mc.create_dt_tm ","   ,mc.msg_category_type_cd ",
  " FROM msg_category mc ","   WHERE mc.owner_id = request->owner_id ",
  "     AND mc.create_dt_tm between cnvtdatetime(request->start_create_dt_tm) ",
  "         and cnvtdatetime(request->end_create_dt_tm) "," HEAD report ",
  "   cat_cnt = 0 "," DETAIL ","   type_cnt = 0 ","   cat_cnt = cat_cnt + 1 ",
  "   if (mod(cat_cnt,10) = 1) ",
  "     stat = alterlist(reply->msg_category_list,cat_cnt + 9) ","   endif ",
  "   reply->msg_category_list[cat_cnt].msg_category_id = mc.msg_category_id ",
  "   reply->msg_category_list[cat_cnt].name = mc.category_name ",
  "   reply->msg_category_list[cat_cnt].create_dt_tm = mc.create_dt_tm ",
  "   reply->msg_category_list[cat_cnt].msg_category_type_cd = mc.msg_category_type_cd ",
  " FOOT report ","    reply->msg_category_knt = cat_cnt ",
  "    stat = alterlist(reply->msg_category_list,cat_cnt) "," WITH nocounter go")
 IF (mn_debug_flag=1)
  CALL echo(ms_echo_line)
  CALL echo(ms_select_statement)
  CALL echo(ms_echo_line)
 ENDIF
 CALL parser(ms_select_statement)
 IF (mn_debug_flag=1)
  CALL echorecord(reply)
 ENDIF
 IF (curqual < 1)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed =
   SELECT
    error
   ;end select
   SET reply->status_data.status = "F"
   SET stat = alterlist(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "MSG_CATEGORY"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
  GO TO end_script
 ENDIF
 SET reply->status_data.status = "S"
#end_script
END GO
