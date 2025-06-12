CREATE PROGRAM dcp_upd_inet_virtual_privacy:dba
 SET modify = predeclare
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "Z"
 DECLARE failstatus = i4 WITH noconstant(0)
 DECLARE updcnt = i4 WITH noconstant(0)
 DECLARE reqcnt = i4 WITH constant(cnvtint(size(request->qual,5)))
 FOR (indx = 1 TO reqcnt)
   SET failstatus = 0
   SELECT INTO "nl:"
    FROM dcp_virtual_privacy ivp
    WHERE (ivp.person_id=request->qual[indx].person_id)
     AND (ivp.privacy_cd=request->qual[indx].privacy_cd)
     AND ivp.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    WITH nocounter, forupdate(ivp)
   ;end select
   IF (curqual > 0)
    SET updcnt = curqual
    UPDATE  FROM dcp_virtual_privacy ivp
     SET ivp.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), ivp.updt_applctx = reqinfo->
      updt_applctx, ivp.updt_cnt = (ivp.updt_cnt+ 1),
      ivp.updt_dt_tm = cnvtdatetime(curdate,curtime3), ivp.updt_id = reqinfo->updt_id, ivp.updt_task
       = reqinfo->updt_task
     WHERE (ivp.person_id=request->qual[indx].person_id)
      AND (ivp.privacy_cd=request->qual[indx].privacy_cd)
      AND ivp.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end update
    IF (curqual != updcnt)
     SET failstatus = 1
     SET reply->status_data.subeventstatus[1].targetobjectname = "DCP_VIRTUAL_PRIVACY"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "UNABLE TO UPDATE ROW"
     GO TO end_of_script
    ENDIF
   ENDIF
   IF ((request->qual[indx].beg_effective_dt_tm > 0))
    INSERT  FROM dcp_virtual_privacy ivp
     SET ivp.dcp_virtual_privacy_id = seq(carenet_seq,nextval), ivp.person_id = request->qual[indx].
      person_id, ivp.privacy_cd = request->qual[indx].privacy_cd,
      ivp.privacy_comment_cd = request->qual[indx].privacy_comment_cd, ivp.freetext_comment =
      substring(1,254,request->qual[indx].freetext_comment), ivp.temporary_ind = request->qual[indx].
      temporary_ind,
      ivp.audio_override_ind = request->qual[indx].audio_override_ind, ivp.video_override_ind =
      request->qual[indx].video_override_ind, ivp.beg_effective_dt_tm = cnvtdatetime(request->qual[
       indx].beg_effective_dt_tm),
      ivp.end_effective_dt_tm = cnvtdatetime(request->qual[indx].end_effective_dt_tm), ivp.updt_cnt
       = 1, ivp.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      ivp.updt_id = reqinfo->updt_id, ivp.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET failstatus = 1
     SET reply->status_data.subeventstatus[1].targetobjectname = "DCP_VIRTUAL_PRIVACY"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].operationname = "INSERT"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "UNABLE TO INSERT ROW"
     GO TO end_of_script
    ENDIF
   ENDIF
 ENDFOR
#end_of_script
 IF (failstatus=1)
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
