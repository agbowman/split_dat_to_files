CREATE PROGRAM cqm_get_reglisttype:dba
 CALL echorecord(request)
 DECLARE program_modification = vc
 SET program_modification = "MAR-02-2000"
 CALL echo(program_modification)
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
   1 status_data
     2 status = c1
 )
 DECLARE count = i4
 DECLARE stat = i2
 DECLARE tablename = vc
 SET count = 0
 SET stat = 0
 SET tablename = cnvtupper(request->tablename)
 SET request->class = cnvtupper(request->class)
 SET request->ttype = cnvtupper(request->ttype)
 SET request->subtype = cnvtupper(request->subtype)
 SET request->subtype_detail = cnvtupper(request->subtype_detail)
 CALL echo(build("tablename:",tablename))
 CALL echo(build("class:",request->class))
 SELECT INTO "nl:"
  FROM (value(tablename) c)
  WHERE ((c.class=patstring(request->class)) OR (c.class = null))
   AND ((c.type=patstring(request->ttype)) OR (c.type = null))
   AND ((c.subtype=patstring(request->subtype)) OR (c.subtype = null))
   AND ((c.subtype_detail=patstring(request->subtype_detail)) OR (c.subtype_detail = null))
   AND c.registry_id > 0
  DETAIL
   count += 1, stat = alterlist(reply->list,count), reply->list[count].registry_id = c.registry_id,
   reply->list[count].listener_id = c.listener_id, reply->list[count].class = c.class, reply->list[
   count].ttype = c.type,
   reply->list[count].subtype = c.subtype, reply->list[count].subtype_detail = c.subtype_detail,
   reply->list[count].debug_ind = c.debug_ind,
   reply->list[count].verbosity_flag = c.verbosity_flag, reply->list[count].create_dt_tm =
   cnvtdatetime(c.create_dt_tm), reply->list[count].updt_dt_tm = cnvtdatetime(c.updt_dt_tm),
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
