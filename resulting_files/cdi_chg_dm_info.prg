CREATE PROGRAM cdi_chg_dm_info
 RECORD reply(
   1 prefs[*]
     2 updt_cnt = i4
     2 info_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE updt_count_ind = i4 WITH public, noconstant(0)
 DECLARE pref_cnt = i4 WITH public, noconstant(0)
 DECLARE g_cdi_domain = vc WITH public, constant("IMAGING DOCUMENT")
 SET reply->status_data.status = "F"
 SET pref_cnt = size(request->prefs,5)
 SET stat = alterlist(reply->prefs,pref_cnt)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(pref_cnt)),
   dm_info di
  PLAN (d)
   JOIN (di
   WHERE di.info_domain=g_cdi_domain
    AND (di.info_name=request->prefs[d.seq].info_name))
  DETAIL
   reply->prefs[d.seq].updt_cnt = (di.updt_cnt+ 1), reply->prefs[d.seq].info_name = di.info_name
   IF ((di.updt_cnt != request->prefs[d.seq].updt_cnt))
    updt_count_ind = 1
   ENDIF
  WITH nocounter, forupdate(di)
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ELSEIF (updt_count_ind != 0)
  SET reply->status_data.status = "C"
  GO TO exit_script
 ENDIF
 UPDATE  FROM (dummyt d  WITH seq = value(pref_cnt)),
   dm_info di
  SET di.info_number = request->prefs[d.seq].info_number, di.info_char = request->prefs[d.seq].
   info_char, di.info_date = cnvtdatetime(request->prefs[d.seq].info_date),
   di.updt_applctx = reqinfo->updt_applctx, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di
   .updt_id = reqinfo->updt_id,
   di.updt_task = reqinfo->updt_task, di.updt_cnt = (di.updt_cnt+ 1)
  PLAN (d)
   JOIN (di
   WHERE di.info_domain=g_cdi_domain
    AND (di.info_name=request->prefs[d.seq].info_name))
  WITH nocounter
 ;end update
 IF (curqual=pref_cnt)
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 IF ((reply->status_data.status="F"))
  SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_chg_dm_info"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Failed to update CDI Preference rows."
  SET reqinfo->commit_ind = 0
 ELSEIF ((reply->status_data.status="Z"))
  SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_chg_dm_info"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "No rows found for update."
  SET reqinfo->commit_ind = 0
 ELSEIF ((reply->status_data.status="C"))
  SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  SET reply->status_data.subeventstatus[1].operationstatus = "C"
  SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_chg_dm_info"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Updt_cnt did not match."
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_chg_dm_info"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Update success."
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
