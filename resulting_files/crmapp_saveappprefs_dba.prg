CREATE PROGRAM crmapp_saveappprefs:dba
 RECORD reply(
   1 exception_data[1]
     2 section = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "S"
 IF (cnvtupper( $1)="NORDBMS")
  GO TO exit_point
 ENDIF
 DECLARE errmsg = vc
 DECLARE errcode = i4 WITH noconstant(1)
 SET errcode = error(errmsg,1)
 DECLARE actionidx = i4 WITH noconstant(0), public
 DECLARE actioncnt = i4 WITH noconstant(0), public
 DECLARE action_none = i2 WITH constant(0), protect
 DECLARE action_insert = i2 WITH constant(1), protect
 DECLARE action_update = i2 WITH constant(2), protect
 DECLARE action_delete = i2 WITH constant(3), protect
 RECORD actionlist(
   1 qual[*]
     2 section = vc
     2 action = i2
 )
 CALL echo(build("save prefs, appnbr:",request->app_id,", user id:",request->updt_id))
 SET actioncnt = size(request->qual,5)
 CALL alterlist(actionlist->qual,actioncnt)
 FOR (actionidx = 1 TO actioncnt)
  SET actionlist->qual[actionidx].section = request->qual[actionidx].section
  SET actionlist->qual[actionidx].action = action_insert
 ENDFOR
 SELECT INTO "nl:"
  FROM application_ini a
  WHERE (a.application_number=request->app_id)
   AND (a.person_id=request->updt_id)
  DETAIL
   actionidx = 0, pos = locateval(actionidx,1,actioncnt,a.section,actionlist->qual[actionidx].section
    )
   IF (pos > 0)
    IF ((request->qual[pos].parameter_data=a.parameter_data))
     actionlist->qual[pos].action = action_none
    ELSE
     actionlist->qual[pos].action = action_update
    ENDIF
   ELSE
    actioncnt += 1,
    CALL alterlist(actionlist->qual,actioncnt), actionlist->qual[actioncnt].section = a.section,
    actionlist->qual[actioncnt].action = action_delete
   ENDIF
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode != 0)
  SET reply->status_data.status = "F"
  WHILE (errcode != 0)
    CALL echo("Select Error")
    CALL echo(build("Error number: ",errcode,"Error message: ",errmsg))
    SET errcode = error(errmsg,0)
  ENDWHILE
  GO TO exit_point
 ENDIF
 SET actionidx = 0
 IF (locateval(actionidx,1,actioncnt,2,actionlist->qual[actionidx].action) > 0)
  CALL echo("Updating Existing Sections")
  UPDATE  FROM application_ini a,
    (dummyt d  WITH seq = value(actioncnt))
   SET a.parameter_data = request->qual[d.seq].parameter_data, a.updt_dt_tm = cnvtdatetime(curdate,
     curtime), a.updt_id = request->updt_id,
    a.updt_cnt = (a.updt_cnt+ 1)
   PLAN (d
    WHERE (actionlist->qual[d.seq].action=action_update))
    JOIN (a
    WHERE (a.application_number=request->app_id)
     AND (a.person_id=request->updt_id)
     AND (actionlist->qual[d.seq].section=a.section))
   WITH nocounter
  ;end update
  SET errcode = error(errmsg,0)
  IF (errcode != 0)
   SET reply->status_data.status = "F"
   WHILE (errcode != 0)
     CALL echo("Update Error")
     CALL echo(build("Error number: ",errcode,"Error message: ",errmsg))
     SET errcode = error(errmsg,0)
   ENDWHILE
  ENDIF
 ENDIF
 SET actionidx = 0
 IF (locateval(actionidx,1,actioncnt,1,actionlist->qual[actionidx].action) > 0)
  CALL echo("Inserting new sections")
  INSERT  FROM application_ini a,
    (dummyt d  WITH seq = value(actioncnt))
   SET a.seq = 1, a.application_number = request->app_id, a.person_id = request->updt_id,
    a.section =
    IF (textlen(request->qual[d.seq].section) > 50) trim(substring(1,50,request->qual[d.seq].section)
      )
    ELSE request->qual[d.seq].section
    ENDIF
    , a.parameter_data = request->qual[d.seq].parameter_data, a.updt_dt_tm = cnvtdatetime(curdate,
     curtime),
    a.updt_id = request->updt_id, a.updt_task = 6092, a.updt_cnt = 0,
    a.updt_applctx = 0
   PLAN (d
    WHERE (actionlist->qual[d.seq].action=action_insert))
    JOIN (a)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode != 0)
   SET reply->status_data.status = "F"
   WHILE (errcode != 0)
     CALL echo("Insert Error")
     CALL echo(build("Error number: ",errcode,"Error message: ",errmsg))
     SET errcode = error(errmsg,0)
   ENDWHILE
  ENDIF
 ENDIF
 SET actionidx = 0
 IF (locateval(actionidx,1,actioncnt,3,actionlist->qual[actionidx].action) > 0)
  CALL echo("deleting old sections")
  DELETE  FROM application_ini a,
    (dummyt d  WITH seq = value(actioncnt))
   SET a.seq = 1
   PLAN (d
    WHERE (actionlist->qual[d.seq].action=action_delete))
    JOIN (a
    WHERE (a.application_number=request->app_id)
     AND (a.person_id=request->updt_id)
     AND (a.section=actionlist->qual[d.seq].section))
   WITH nocounter
  ;end delete
  SET errcode = error(errmsg,0)
  IF (errcode != 0)
   SET reply->status_data.status = "F"
   WHILE (errcode != 0)
     CALL echo("Delete Error")
     CALL echo(build("Error number: ",errcode,"Error message: ",errmsg))
     SET errcode = error(errmsg,0)
   ENDWHILE
  ENDIF
 ENDIF
 COMMIT
#exit_point
END GO
