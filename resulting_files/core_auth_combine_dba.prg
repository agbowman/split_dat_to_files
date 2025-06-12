CREATE PROGRAM core_auth_combine:dba
 FREE RECORD trequest
 RECORD trequest(
   1 action_type_flag = i2
   1 qual[*]
     2 code_set = i4
     2 from_cv = f8
     2 to_cv = f8
 )
 RECORD reply(
   1 sql[*]
     2 line = vc
   1 errmsg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE authenticate(aidx=i4) = null
 DECLARE combine(aidx=i4) = null
 DECLARE script_version = vc WITH public, noconstant(" ")
 DECLARE failed = c1 WITH public, noconstant("F")
 DECLARE req_cnt = i4 WITH public, noconstant(size(request->qual,5))
 DECLARE errmsg = c132 WITH public, noconstant(fillstring(132," "))
 DECLARE active = f8 WITH protected, noconstant(0.0)
 DECLARE inactive = f8 WITH protected, noconstant(0.0)
 DECLARE auth = f8 WITH protected, noconstant(0.0)
 IF ((reqdata->active_status_cd < 1))
  SELECT INTO "nl:"
   cv.code_value
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set=48
     AND cv.cdf_meaning="ACTIVE"
     AND cv.active_ind=1
     AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   DETAIL
    active = cv.code_value
   WITH nocounter
  ;end select
 ELSE
  SET active = reqdata->active_status_cd
 ENDIF
 IF ((reqdata->inactive_status_cd < 1))
  SELECT INTO "nl:"
   cv.code_value
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set=48
     AND cv.cdf_meaning="INACTIVE"
     AND cv.active_ind=1
     AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   DETAIL
    inactive = cv.code_value
   WITH nocounter
  ;end select
 ELSE
  SET inactive = reqdata->inactive_status_cd
 ENDIF
 IF ((reqdata->data_status_cd < 1))
  SELECT INTO "nl:"
   cv.code_value
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set=8
     AND cv.cdf_meaning="AUTH"
     AND cv.active_ind=1
     AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   DETAIL
    auth = cv.code_value
   WITH nocounter
  ;end select
 ELSE
  SET auth = reqdata->data_status_cd
 ENDIF
 IF (req_cnt <= 0)
  SET failed = "T"
  SET reply->errmsg = "There where no items selected for action."
  GO TO exit_script
 ENDIF
 SET stat = alterlist(trequest->qual,req_cnt)
 SET trequest->action_type_flag = request->action_type_flag
 FOR (zvar = 1 TO req_cnt)
   SET trequest->qual[zvar].code_set = request->qual[zvar].code_set
   SET trequest->qual[zvar].from_cv = request->qual[zvar].from_cv
   SET trequest->qual[zvar].to_cv = request->qual[zvar].to_cv
 ENDFOR
 IF ((trequest->action_type_flag=0))
  FOR (xvar = 1 TO req_cnt)
    CALL authenticate(xvar)
  ENDFOR
 ELSEIF ((trequest->action_type_flag=1))
  FOR (xvar = 1 TO req_cnt)
    CALL combine(xvar)
  ENDFOR
 ELSE
  SET reply->errmsg = build("Could not recognize the given action_type_flag:",trequest->
   action_type_flag,".")
 ENDIF
 GO TO exit_script
 SUBROUTINE authenticate(aidx)
   FREE RECORD request
   RECORD request(
     1 current_user_id = f8
     1 active_cd = f8
     1 auth_cd = f8
     1 code_value = f8
   )
   SET request->current_user_id = reqinfo->updt_id
   SET request->active_cd = active
   SET request->auth_cd = auth
   SET request->code_value = trequest->qual[aidx].from_cv
   SET trace = recpersist
   EXECUTE dm_authentication  WITH replace(reply,reply2)
   CALL echorecord(reply2)
   IF ((reply2->status_data.status != "S"))
    SET failed = "T"
    SET cv_disp = uar_get_code_display(trequest->qual[aidx].from_cv)
    SET reply->errmsg = concat("Unable to authenticate the code value (",trim(cv_disp),
     ") with the authentication child program.")
    GO TO exit_script
   ENDIF
   FREE RECORD reply2
   SET trace = norecpersist
 END ;Subroutine
 SUBROUTINE combine(aidx)
   FREE RECORD request
   RECORD request(
     1 auth_cd = f8
     1 code_value = f8
     1 from_cv = f8
     1 to_cv = f8
     1 current_user_id = f8
     1 inactive_cd = f8
   )
   SET request->auth_cd = auth
   SET request->code_value = trequest->qual[aidx].from_cv
   SET request->from_cv = trequest->qual[aidx].from_cv
   SET request->to_cv = trequest->qual[aidx].to_cv
   SET request->current_user_id = reqinfo->updt_id
   SET request->inactive_cd = inactive
   EXECUTE kia_combine_code_value
   IF ((reply->status_data.status != "S"))
    SET failed = "T"
    SET from_disp = uar_get_code_display(trequest->qual[aidx].from_cv)
    SET to_disp = uar_get_code_display(trequest->qual[aidx].to_cv)
    SET reply->errmsg = concat("Unable to combine the code value (",trim(from_disp),
     ") to the authenticated code value (",trim(to_disp),") with the combine child program.")
    GO TO exit_script
   ENDIF
 END ;Subroutine
#exit_script
 SET errorcode = error(errmsg,0)
 IF (errorcode != 0)
  SET failed = "T"
  SET reply->status_data.targetobjectname = "ErrorMessage"
  SET reply->status_data.targetobjectvalue = errmsg
 ENDIF
 IF (failed="T")
  SET reply->status_data.status = "Z"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 SET script_version = "001 10/20/03 JF8275"
 CALL echorecord(reply)
END GO
