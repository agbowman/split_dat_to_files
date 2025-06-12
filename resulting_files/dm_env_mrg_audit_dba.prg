CREATE PROGRAM dm_env_mrg_audit:dba
 RECORD reply(
   1 qual_list = i4
   1 qual[*]
     2 mrg_dt_tm = dq8
     2 action = c8
     2 err_num = i4
     2 err_mess = c60
     2 transl_errs = c255
     2 statement = c255
   1 status_data
     2 status = c1
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 IF ((request->option="R"))
  SELECT INTO "nl:"
   a.table_name, a.mrg_dt_tm, a.sequence,
   a.action, a.err_num, a.err_mess,
   a.translate_errs, a.statement
   FROM dm_env_mrg_audit a
   WHERE (a.table_name=request->entity_name)
    AND a.mrg_dt_tm=cnvtdatetime(request->merge_dt_tm)
   ORDER BY a.table_name, a.mrg_dt_tm, a.sequence
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(reply->qual,cnt), reply->qual[cnt].mrg_dt_tm = a.mrg_dt_tm,
    reply->qual[cnt].action = a.action, reply->qual[cnt].err_num = a.err_num, reply->qual[cnt].
    err_mess = a.err_mess,
    reply->qual[cnt].transl_errs = a.translate_errs, reply->qual[cnt].statement = a.statement
   WITH nocounter
  ;end select
 ELSE
  SELECT DISTINCT INTO "nl:"
   a.table_name, a.mrg_dt_tm
   FROM dm_env_mrg_audit a
   WHERE (a.table_name=request->entity_name)
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(reply->qual,cnt), reply->qual[cnt].mrg_dt_tm = a.mrg_dt_tm
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
 SET reply->qual_list = cnt
END GO
