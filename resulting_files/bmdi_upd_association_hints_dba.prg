CREATE PROGRAM bmdi_upd_association_hints:dba
 DECLARE readconfig(dummy) = i2
 IF (validate(info_domain,999)=999)
  DECLARE info_domain = vc WITH protect, noconstant("bmdi_upd_association_hints")
 ENDIF
 IF (validate(info_name,999)=999)
  DECLARE info_name = vc WITH protect, noconstant("LOG_MSGVIEW")
 ENDIF
 IF (validate(log_msgview,999)=999)
  DECLARE log_msgview = i2 WITH protect, noconstant(0)
 ENDIF
 IF (validate(execmsgrtl,999)=999)
  DECLARE execmsgrtl = i2 WITH protect, constant(1)
 ENDIF
 IF (validate(emsglog_commit,999)=999)
  DECLARE emsglog_commit = i4 WITH protect, constant(0)
 ENDIF
 IF (validate(emsglvl_debug,999)=999)
  DECLARE emsglvl_debug = i4 WITH protect, constant(4)
 ENDIF
 IF (validate(msg_debug,999)=999)
  DECLARE msg_debug = i4 WITH protect, noconstant(0)
 ENDIF
 IF (validate(msg_default,999)=999)
  DECLARE msg_default = i4 WITH protect, noconstant(0)
 ENDIF
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 CALL readconfig(0)
 DECLARE new_active_ind = i2
 DECLARE upd_hint_id = f8 WITH noconstant(0.0)
 DECLARE act_hint_processing_cd = f8 WITH noconstant(0.0)
 DECLARE defer_hint_processing_cd = f8 WITH noconstant(0.0)
 CALL msgwrite("Entering the update association hints..")
 SET act_hint_processing_cd = uar_get_code_by("MEANING",359576,"ACT")
 SET defer_hint_processing_cd = uar_get_code_by("MEANING",359576,"DEFER")
 SET reply->status_data.status = "F"
 SET sfailed = "S"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = 0
 CALL msgwrite(build2("request->hint_id= ",request->hint_id,"request->person_id= ",request->person_id,
   "request->location_cd= ",
   request->location_cd,"request->hint_processing_cd= ",request->hint_processing_cd))
 IF ((((request->hint_id=0.0)
  AND (request->person_id=0.0)
  AND (request->location_cd=0.0)) OR ((request->hint_processing_cd=0.0))) )
  CALL msgwrite("Request not populately correctly..")
  GO TO exit_script
 ENDIF
 SELECT
  IF ((request->hint_id > 0.0))
   WHERE (bah.hint_id=request->hint_id)
    AND bah.active_ind=1
  ELSEIF ((request->person_id > 0.0)
   AND (request->location_cd=0.0))
   WHERE (bah.person_id=request->person_id)
    AND bah.active_ind=1
  ELSEIF ((request->person_id > 0.0)
   AND (request->location_cd > 0.0))
   WHERE (bah.person_id=request->person_id)
    AND (bah.location_cd=request->location_cd)
    AND bah.active_ind=1
  ELSE
   WHERE (bah.location_cd=request->location_cd)
    AND bah.active_ind=1
  ENDIF
  INTO "nl:"
  FROM bmdi_association_hints bah
  DETAIL
   upd_hint_id = bah.hint_id
  WITH forupdate(bah), nocounter
 ;end select
 IF (curqual < 1)
  SET reply->status_data.status = "Z"
  CALL msgwrite("Zero rows were updated")
  GO TO exit_script
 ELSEIF (curqual > 1)
  SET reply->status_data.status = "F"
  CALL msgwrite("Too many rows qualified - script failure")
  GO TO exit_script
 ELSE
  IF ((request->hint_processing_cd != defer_hint_processing_cd)
   AND (request->hint_processing_cd != act_hint_processing_cd))
   SET new_active_ind = 0
  ELSE
   SET new_active_ind = 1
  ENDIF
  UPDATE  FROM bmdi_association_hints bah
   SET bah.hint_processing_cd = request->hint_processing_cd, bah.active_ind = new_active_ind, bah
    .updt_dt_tm = cnvtdatetime(sysdate),
    bah.updt_id = reqinfo->updt_id, bah.updt_task = reqinfo->updt_task, bah.updt_applctx = reqinfo->
    updt_applctx,
    bah.updt_cnt = (bah.updt_cnt+ 1), bah.upd_prsnl_id = request->upd_prsnl_id
   WHERE bah.hint_id=upd_hint_id
   WITH nocounter
  ;end update
  IF (curqual=1)
   SET reply->status_data.status = "S"
   CALL msgwrite("Hint updated successfully")
   CALL msgwrite(build2("hint_id= ",upd_hint_id,"hint_processing_cd= ",request->hint_processing_cd,
     "active_ind= ",
     new_active_ind,"updt_id= ",reqinfo->updt_id,"updt_task= ",reqinfo->updt_task,
     "updt_applctx= ",reqinfo->updt_applctx,"upd_prsnl_id= ",request->upd_prsnl_id))
  ENDIF
 ENDIF
#exit_script
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = reply->status_data.status
  SET reply->status_data.subeventstatus[1].targetobjectname = "bmdi_upd_association_hint"
  IF ((reply->status_data.status="Z"))
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "No Records Found"
  ELSE
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Script Failed"
  ENDIF
  SET reqinfo->commit_ind = 0
 ENDIF
 SUBROUTINE readconfig(null)
   IF (validate(execmsgrtl,999)=999)
    EXECUTE msgrtl
   ENDIF
   SET msg_default = uar_msgdefhandle()
   SET msg_debug = uar_msgopen("bmdi_upd_association_hint")
   CALL uar_msgsetlevel(msg_debug,emsglvl_debug)
   DECLARE msgout = vc
   SELECT INTO "nl:"
    FROM dm_info di
    PLAN (di
     WHERE di.info_domain=info_domain
      AND di.info_name=info_name)
    DETAIL
     log_msgview = cnvtint(di.info_number)
    WITH nocounter
   ;end select
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (msgwrite(msg=vc) =i2)
  SET log_msgview = 1
  IF (log_msgview=1)
   CALL uar_msgwrite(msg_debug,emsglog_commit,nullterm("BMDI"),emsglvl_debug,nullterm(msg))
  ENDIF
 END ;Subroutine
END GO
