CREATE PROGRAM cqm_get_contributorid:dba
 DECLARE program_modification = vc
 SET program_modification = "Mar-02-2000"
 CALL echo(program_modification)
 RECORD reply(
   1 list[*]
     2 contributor_id = f8
     2 application_name = vc
     2 contributor_alias = vc
     2 target_priority = i4
     2 debug_ind = i2
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
 CALL echo(tablename)
 CALL echo(request->contributor_id)
 SELECT INTO "nl:"
  FROM (value(tablename) c)
  WHERE (c.contributor_id=request->contributor_id)
  DETAIL
   count += 1, stat = alterlist(reply->list,count), reply->list[count].contributor_id = c
   .contributor_id,
   reply->list[count].application_name = c.application_name, reply->list[count].contributor_alias = c
   .contributor_alias, reply->list[count].target_priority = c.target_priority,
   reply->list[count].debug_ind = c.debug_ind, reply->list[count].verbosity_flag = c.verbosity_flag,
   reply->list[count].create_dt_tm = cnvtdatetime(c.create_dt_tm),
   reply->list[count].updt_dt_tm = cnvtdatetime(c.updt_dt_tm), reply->list[count].updt_task = c
   .updt_task, reply->list[count].updt_id = c.updt_id,
   reply->list[count].updt_applctx = c.updt_applctx
  WITH nocounter
 ;end select
 CALL echo(build("count:",count))
 IF (count > 0)
  CALL echo(build("contributor_id:",reply->list[1].contributor_id))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
END GO
