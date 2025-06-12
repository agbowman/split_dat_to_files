CREATE PROGRAM dcp_get_inet_virtual_privacy:dba
 SET modify = predeclare
 RECORD reply(
   1 qual[*]
     2 person_id = f8
     2 privacy_cd = f8
     2 privacy_comment_cd = f8
     2 freetext_comment = vc
     2 temporary_ind = i2
     2 audio_override_ind = i2
     2 video_override_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 updt_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE privacycnt = i4 WITH noconstant(0)
 DECLARE err_status = i4 WITH private, noconstant(0)
 DECLARE err_msg = vc WITH private, noconstant(fillstring(132,""))
 SELECT INTO "nl:"
  FROM dcp_virtual_privacy vp
  WHERE (vp.person_id=request->person_id)
   AND vp.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND vp.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   privacycnt = (privacycnt+ 1), stat = alterlist(reply->qual,(privacycnt+ 1)), reply->qual[
   privacycnt].person_id = vp.person_id,
   reply->qual[privacycnt].privacy_cd = vp.privacy_cd, reply->qual[privacycnt].privacy_comment_cd =
   vp.privacy_comment_cd, reply->qual[privacycnt].freetext_comment = vp.freetext_comment,
   reply->qual[privacycnt].temporary_ind = vp.temporary_ind, reply->qual[privacycnt].
   audio_override_ind = vp.audio_override_ind, reply->qual[privacycnt].video_override_ind = vp
   .video_override_ind,
   reply->qual[privacycnt].beg_effective_dt_tm = vp.beg_effective_dt_tm, reply->qual[privacycnt].
   end_effective_dt_tm = vp.end_effective_dt_tm, reply->qual[privacycnt].updt_id = vp.updt_id
  FOOT REPORT
   IF (privacycnt > 0)
    stat = alterlist(reply->qual[privacycnt],privacycnt)
   ENDIF
  WITH nocounter
 ;end select
 IF (privacycnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
