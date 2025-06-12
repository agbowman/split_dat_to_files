CREATE PROGRAM cqm_get_contributoralias:dba
 DECLARE program_modification = vc
 SET program_modification = "Mar-02-2000"
 CALL echo(program_modification)
 CALL echorecord(request)
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
 IF (tablename=" ")
  SET tablename = "CQM_CONTRIBUTOR_CONFIG"
 ENDIF
 SET request->contributor_alias = cnvtupper(request->contributor_alias)
 SET request->application_name = cnvtupper(request->application_name)
 CALL echo(build("tablename:",tablename))
 CALL echo(build("application_name:",request->application_name))
 CALL echo(build("contributor_alias:",request->contributor_alias))
 SELECT INTO "nl:"
  FROM (value(tablename) c)
  WHERE cnvtupper(c.application_name)=patstring(request->application_name)
   AND cnvtupper(c.contributor_alias)=patstring(request->contributor_alias)
   AND (c.contributor_id >= request->contributor_id)
   AND c.contributor_id > 0
  DETAIL
   count += 1, stat = alterlist(reply->list,count), col 0,
   c.application_name, reply->list[count].contributor_id = c.contributor_id, reply->list[count].
   application_name = c.application_name,
   reply->list[count].contributor_alias = c.contributor_alias, reply->list[count].target_priority = c
   .target_priority, reply->list[count].debug_ind = c.debug_ind,
   reply->list[count].verbosity_flag = c.verbosity_flag, reply->list[count].create_dt_tm =
   cnvtdatetime(c.create_dt_tm), reply->list[count].updt_dt_tm = cnvtdatetime(c.updt_dt_tm),
   reply->list[count].updt_task = c.updt_task, reply->list[count].updt_id = c.updt_id, reply->list[
   count].updt_applctx = c.updt_applctx
  WITH nocounter
 ;end select
 IF (count > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echo(build("count:",count))
 IF (count > 0)
  CALL echo(build("contributor_alias:",reply->list[1].contributor_alias))
  CALL echo(build("contributor_id:",reply->list[1].contributor_id))
 ENDIF
 SUBROUTINE change_name(name_to_change,name_size)
   FOR (i = 1 TO value(name_size))
    SET sstring = substring(i,1,name_to_change)
    IF (((sstring="%") OR (sstring="_")) )
     SET new_name = concat(new_name,"*")
    ELSE
     SET new_name = concat(new_name,sstring)
    ENDIF
   ENDFOR
 END ;Subroutine
END GO
