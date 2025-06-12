CREATE PROGRAM crm_get_appbar_application:dba
 DECLARE num = i4
 DECLARE grp_num = i4
 DECLARE app_num = i4
 SET grp_num = 0
 SET app_num = 0
 SET batch_size = 100
 SET loop_cnt = 0
 SET new_grp_size = 0
 SET nstart = 1
 RECORD reply(
   1 groups[*]
     2 app_group_cd = f8
     2 app_group_disp = c40
   1 applications[*]
     2 number = i4
     2 description = vc
     2 object_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT DISTINCT INTO "nl:"
  appgr.position_cd, appgr.app_group_cd
  FROM application_group appgr,
   code_value cdval
  PLAN (appgr
   WHERE (((reqinfo->position_cd=0)
    AND appgr.position_cd > 0) OR ((reqinfo->position_cd > 0)
    AND (reqinfo->position_cd=appgr.position_cd)))
    AND appgr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND appgr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (cdval
   WHERE appgr.app_group_cd=cdval.code_value
    AND cdval.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cdval.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  HEAD REPORT
   stat = alterlist(reply->groups,10)
  DETAIL
   grp_num = (grp_num+ 1)
   IF (mod(grp_num,10)=1
    AND grp_num != 1)
    stat = alterlist(reply->groups,(grp_num+ 9))
   ENDIF
   reply->groups[grp_num].app_group_cd = appgr.app_group_cd
  FOOT REPORT
   stat = alterlist(reply->groups,grp_num), loop_cnt = ceil((cnvtreal(grp_num)/ batch_size)),
   new_grp_size = (loop_cnt * batch_size),
   stat = alterlist(reply->groups,new_grp_size)
   FOR (idx = (grp_num+ 1) TO new_grp_size)
     reply->groups[idx].app_group_cd = reply->groups[grp_num].app_group_cd
   ENDFOR
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  GO TO end_script
 ENDIF
 SELECT DISTINCT INTO "nl:"
  app.application_number, app.object_name, app.description
  FROM application app,
   (dummyt d  WITH seq = value(loop_cnt))
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
   JOIN (app
   WHERE app.application_number > 0
    AND app.active_ind=1
    AND app.direct_access_ind=1
    AND app.object_name > " "
    AND  EXISTS (
   (SELECT
    aa.application_number
    FROM application_access aa
    WHERE expand(num,nstart,(nstart+ (batch_size - 1)),aa.app_group_cd,reply->groups[num].
     app_group_cd)
     AND aa.application_number=app.application_number
     AND aa.active_ind=1)))
  HEAD REPORT
   stat = alterlist(reply->applications,10)
  DETAIL
   app_num = (app_num+ 1)
   IF (mod(app_num,10)=1
    AND app_num != 1)
    stat = alterlist(reply->applications,(app_num+ 9))
   ENDIF
   reply->applications[app_num].number = app.application_number, reply->applications[app_num].
   description = app.description, reply->applications[app_num].object_name = app.object_name
  FOOT REPORT
   stat = alterlist(reply->applications,app_num), reply->status_data.status = "S", stat = alterlist(
    reply->groups,grp_num)
  WITH nocounter
 ;end select
#end_script
END GO
