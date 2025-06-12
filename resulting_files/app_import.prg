CREATE PROGRAM app_import
 SET message = information
 SET trace = echoinput
 RECORD status(
   1 qual[*]
     2 app_action = i1
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 sub_status[*]
       3 item_number = i2
       3 error_msg = vc
 )
 SET count1 = 0
 SET cnt = size(requestin->list_0,5)
 CALL echo(concat("Rows Received: ",cnvtstring(cnt)))
 SET stat = alterlist(status->qual,cnt)
 SELECT INTO "nl:"
  a.application_number
  FROM application a,
   (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  PLAN (d)
   JOIN (a
   WHERE a.application_number=cnvtint(requestin->list_0[d.seq].application_number))
  DETAIL
   IF (a.application_number > 0)
    status->qual[d.seq].app_action = 1
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
 FOR (x = 2 TO cnt)
   IF (cnvtint(requestin->list_0[x].application_number)=cnvtint(requestin->list_0[(x - 1)].
    application_number))
    SET status->qual[x].app_action = 2
   ENDIF
 ENDFOR
 INSERT  FROM application a,
   (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  SET a.application_number = cnvtint(requestin->list_0[d.seq].application_number), a.owner =
   substring(1,20,requestin->list_0[d.seq].owner), a.description = substring(1,200,requestin->list_0[
    d.seq].app_description),
   a.active_dt_tm = cnvtdatetime(curdate,curtime3), a.active_ind =
   IF ((requestin->list_0[d.seq].app_active_ind=" ")) 1
   ELSE cnvtint(requestin->list_0[d.seq].app_active_ind)
   ENDIF
   , a.last_localized_dt_tm = cnvtdatetime(curdate,curtime3),
   a.text = requestin->list_0[d.seq].app_text, a.inactive_dt_tm = cnvtdatetime(curdate,curtime3), a
   .log_access_ind = cnvtint(requestin->list_0[d.seq].log_access_ind),
   a.application_ini_ind = cnvtint(requestin->list_0[d.seq].application_ini_ind), a.object_name =
   requestin->list_0[d.seq].object_name, a.direct_access_ind = cnvtint(requestin->list_0[d.seq].
    direct_access_ind),
   a.log_level = cnvtint(requestin->list_0[d.seq].log_level), a.request_log_level = cnvtint(requestin
    ->list_0[d.seq].request_log_level), a.min_version_required = requestin->list_0[d.seq].
   min_version_required,
   a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_id = 0, a.updt_task = 94903,
   a.updt_applctx = 0, a.updt_cnt = 0
  PLAN (d
   WHERE (status->qual[d.seq].app_action=0))
   JOIN (a
   WHERE a.application_number=cnvtint(requestin->list_0[d.seq].application_number))
  WITH nocounter, outerjoin = d
 ;end insert
 UPDATE  FROM application a,
   (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  SET a.application_number = cnvtint(requestin->list_0[d.seq].application_number), a.owner =
   substring(1,20,requestin->list_0[d.seq].owner), a.description = substring(1,200,requestin->list_0[
    d.seq].app_description),
   a.active_dt_tm = cnvtdatetime(curdate,curtime3), a.active_ind =
   IF ((requestin->list_0[d.seq].app_active_ind=" ")) 1
   ELSE cnvtint(requestin->list_0[d.seq].app_active_ind)
   ENDIF
   , a.last_localized_dt_tm = cnvtdatetime(curdate,curtime3),
   a.text = requestin->list_0[d.seq].app_text, a.inactive_dt_tm = cnvtdatetime(curdate,curtime3), a
   .application_ini_ind = cnvtint(requestin->list_0[d.seq].application_ini_ind),
   a.object_name = requestin->list_0[d.seq].object_name, a.direct_access_ind = cnvtint(requestin->
    list_0[d.seq].direct_access_ind), a.min_version_required = requestin->list_0[d.seq].
   min_version_required,
   a.log_access_ind = cnvtint(requestin->list_0[d.seq].log_access_ind), a.log_level = cnvtint(
    requestin->list_0[d.seq].log_level), a.request_log_level = cnvtint(requestin->list_0[d.seq].
    request_log_level),
   a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_id = 0, a.updt_task = 94903,
   a.updt_applctx = 0, a.updt_cnt = (a.updt_cnt+ 1)
  PLAN (d
   WHERE (status->qual[d.seq].app_action=1))
   JOIN (a
   WHERE a.application_number=cnvtint(requestin->list_0[d.seq].application_number))
  WITH nocounter, outerjoin = d
 ;end update
 SET reqinfo->commit_ind = 1
END GO
