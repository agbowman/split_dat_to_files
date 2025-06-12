CREATE PROGRAM cqm_get_reglistapp:dba
 DECLARE program_modification = vc
 SET program_modification = "MAR-02-2000"
 CALL echo(program_modification)
 CALL echorecord(request)
 RECORD reply(
   1 list[*]
     2 registry_id = f8
     2 listener_id = f8
     2 class = vc
     2 ttype = vc
     2 subtype = vc
     2 subtype_detail = vc
     2 debug_ind = i2
     2 target_priority = i4
     2 verbosity_flag = i2
     2 create_dt_tm = dq8
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_cnt = i4
     2 updt_applctx = f8
     2 application_name = vc
     2 listener_alias = vc
     2 listener_trigger_table_ext = vc
     2 image_name = vc
     2 image_options = vc
     2 comm_params = vc
   1 status_data
     2 status = c1
 )
 DECLARE count = i4
 DECLARE stat = i2
 SET count = 0
 SET stat = 0
 SET request->application_name = cnvtupper(request->application_name)
 SET request->class = cnvtupper(request->class)
 SET request->ttype = cnvtupper(request->ttype)
 SET request->subtype = cnvtupper(request->subtype)
 SET request->subtype_detail = cnvtupper(request->subtype_detail)
 CALL echo(build("class:",request->class))
 SELECT INTO "nl:"
  FROM cqm_listener_registry c,
   cqm_listener_config cl
  PLAN (c
   WHERE ((c.class=patstring(request->class)) OR (c.class = null))
    AND ((c.type=patstring(request->ttype)) OR (c.type = null))
    AND ((c.subtype=patstring(request->subtype)) OR (c.subtype = null))
    AND ((c.subtype_detail=patstring(request->subtype_detail)) OR (c.subtype_detail = null))
    AND c.registry_id > 0)
   JOIN (cl
   WHERE cl.listener_id=c.listener_id
    AND cl.application_name=patstring(request->application_name))
  DETAIL
   count += 1, stat = alterlist(reply->list,count), reply->list[count].registry_id = c.registry_id,
   reply->list[count].listener_id = c.listener_id, reply->list[count].class = c.class, reply->list[
   count].ttype = c.type,
   reply->list[count].subtype = c.subtype, reply->list[count].subtype_detail = c.subtype_detail,
   reply->list[count].debug_ind = c.debug_ind,
   reply->list[count].verbosity_flag = c.verbosity_flag, reply->list[count].create_dt_tm =
   cnvtdatetime(c.create_dt_tm), reply->list[count].listener_alias = cl.listener_alias,
   reply->list[count].listener_trigger_table_ext = cl.listener_trigger_table_ext, reply->list[count].
   image_name = cl.listener_image_name, reply->list[count].image_options = cl.listener_image_options,
   reply->list[count].comm_params = cl.comm_params, reply->list[count].application_name = request->
   application_name, reply->list[count].updt_dt_tm = cnvtdatetime(c.updt_dt_tm),
   reply->list[count].updt_task = c.updt_task, reply->list[count].updt_id = c.updt_id, reply->list[
   count].updt_applctx = c.updt_applctx
  WITH nocounter
 ;end select
 CALL echo(build("count:",count))
 IF (count > 0)
  CALL echo(build("registry_id:",reply->list[1].registry_id))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
END GO
