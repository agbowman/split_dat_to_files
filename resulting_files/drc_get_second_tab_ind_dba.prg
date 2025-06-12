CREATE PROGRAM drc_get_second_tab_ind:dba
 FREE RECORD reply
 RECORD reply(
   1 display_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE script_version = vc WITH public, noconstant(" ")
 DECLARE failed = c1 WITH public, noconstant("F")
 DECLARE errmsg = c132 WITH public, noconstant(fillstring(132," "))
 SET reply->status_data.status = "F"
 IF ((((request->display_flag=1)) OR ((request->display_flag=2))) )
  UPDATE  FROM dm_info di
   SET di.info_number = evaluate(request->display_flag,1,1,2,0), di.updt_applctx = reqinfo->
    updt_applctx, di.updt_cnt = (di.updt_cnt+ 1),
    di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = reqinfo->updt_id, di.updt_task =
    reqinfo->updt_task
   WHERE di.info_domain="COREDRBUILDER"
    AND di.info_name="SECOND_TAB"
   WITH nocounter
  ;end update
  SET errorcode = error(errmsg,0)
  IF (errorcode != 0)
   SET failed = "T"
   SET reply->display_ind = false
   GO TO exit_script
  ELSE
   IF (curqual > 0)
    SET reply->display_ind = evaluate(request->display_flag,1,1,2,0)
    COMMIT
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  di.info_number
  FROM dm_info di
  PLAN (di
   WHERE di.info_domain="COREDRBUILDER"
    AND di.info_name="SECOND_TAB")
  DETAIL
   IF (di.info_number=1)
    reply->display_ind = true
   ELSE
    reply->display_ind = false
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual < 1)
  CALL echo("Adding row to DM_INFO table")
  INSERT  FROM dm_info di
   SET di.info_domain = "COREDRBUILDER", di.info_name = "SECOND_TAB", di.info_number = evaluate(
     request->display_flag,1,1,2,0,
     0),
    di.updt_applctx = reqinfo->updt_applctx, di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task
   WITH nocounter
  ;end insert
  SET errorcode = error(errmsg,0)
  IF (errorcode != 0)
   SET failed = "T"
   SET reply->display_ind = false
   ROLLBACK
   GO TO exit_script
  ELSE
   SET reply->display_ind = evaluate(request->display_flag,1,1,2,0,
    0)
   COMMIT
  ENDIF
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_version = "000 11/07/03 JF8275"
END GO
