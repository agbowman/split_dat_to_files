CREATE PROGRAM cqm_get_listenerid:dba
 DECLARE program_modification = vc
 SET program_modification = "Mar-02-2000"
 CALL echo(program_modification)
 CALL echorecord(request)
 RECORD reply(
   1 list[*]
     2 listener_id = f8
     2 application_name = vc
     2 listener_alias = vc
     2 listener_trigger_table_ext = vc
     2 listener_image_name = vc
     2 listener_image_options = vc
     2 comm_params = vc
     2 create_dt_tm = dq8
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_cnt = i4
     2 updt_applctx = f8
   1 status_data
     2 status = c1
 )
 DECLARE count = i4
 DECLARE stat = i2
 DECLARE tablename = vc
 SET count = 0
 SET stat = 0
 SET tablename = cnvtupper(request->tablename)
 CALL echo(build("tablename:",tablename))
 CALL echo(build("listener_id:",request->listener_id))
 SELECT INTO "nl:"
  FROM (value(tablename) c)
  WHERE (c.listener_id=request->listener_id)
  DETAIL
   count += 1, stat = alterlist(reply->list,count), reply->list[count].listener_id = c.listener_id,
   reply->list[count].application_name = c.application_name, reply->list[count].listener_alias = c
   .listener_alias, reply->list[count].listener_trigger_table_ext = c.listener_trigger_table_ext,
   reply->list[count].listener_image_name = c.listener_image_name, reply->list[count].
   listener_image_options = c.listener_image_options, reply->list[count].comm_params = c.comm_params,
   reply->list[count].create_dt_tm = cnvtdatetime(c.create_dt_tm), reply->list[count].updt_dt_tm =
   cnvtdatetime(c.updt_dt_tm), reply->list[count].updt_task = c.updt_task,
   reply->list[count].updt_id = c.updt_id, reply->list[count].updt_applctx = c.updt_applctx
  WITH nocounter
 ;end select
 CALL echo(build("count:",count))
 IF (count > 0)
  CALL echo(build("listener_id:",reply->list[1].listener_id))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
END GO
