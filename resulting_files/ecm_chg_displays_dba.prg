CREATE PROGRAM ecm_chg_displays:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET nbr_to_chg = size(request->qual,5)
 SELECT INTO "nl:"
  v.*
  FROM v500_event_code v,
   (dummyt d  WITH seq = value(nbr_to_chg))
  PLAN (d)
   JOIN (v
   WHERE (request->qual[d.seq].event_cd=v.event_cd))
  WITH nocounter, forupdate(v)
 ;end select
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].operationname = "ecm_chg_displays"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "LOCK"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Failed to lock all v500_event_code rows"
  GO TO exit_script
 ENDIF
 UPDATE  FROM v500_event_code v,
   (dummyt d  WITH seq = value(nbr_to_chg))
  SET v.seq = 1, v.event_cd_disp = request->qual[d.seq].event_cd_disp, v.event_cd_disp_key =
   cnvtupper(cnvtalphanum(request->qual[d.seq].event_cd_disp)),
   v.updt_cnt = (v.updt_cnt+ 1), v.updt_dt_tm = cnvtdatetime(curdate,curtime3), v.updt_id = reqinfo->
   updt_id,
   v.updt_task = reqinfo->updt_task, v.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (v
   WHERE (request->qual[d.seq].event_cd=v.event_cd))
  WITH nocounter
 ;end update
 IF (curqual != nbr_to_chg)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].operationname = "ecm_chg_displays"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "UPDATE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Failed to update all v500_event_code rows"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  v.*
  FROM code_value v,
   (dummyt d  WITH seq = value(nbr_to_chg))
  PLAN (d)
   JOIN (v
   WHERE (request->qual[d.seq].event_cd=v.code_value))
  WITH nocounter, forupdate(v)
 ;end select
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].operationname = "ecm_chg_displays"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "LOCK"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Failed to lock all code_value rows"
  GO TO exit_script
 ENDIF
 UPDATE  FROM code_value v,
   (dummyt d  WITH seq = value(nbr_to_chg))
  SET v.seq = 1, v.display = request->qual[d.seq].event_cd_disp, v.display_key = cnvtupper(
    cnvtalphanum(request->qual[d.seq].event_cd_disp)),
   v.updt_cnt = (v.updt_cnt+ 1), v.updt_dt_tm = cnvtdatetime(curdate,curtime3), v.updt_id = reqinfo->
   updt_id,
   v.updt_task = reqinfo->updt_task, v.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (v
   WHERE (request->qual[d.seq].event_cd=v.code_value))
  WITH nocounter
 ;end update
 IF (curqual != nbr_to_chg)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].operationname = "ecm_chg_displays"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "UPDATE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Failed to update all code_value rows"
  GO TO exit_script
 ENDIF
 UPDATE  FROM v500_event_set_code esc
  SET esc.updt_cnt =
   (SELECT
    (esc2.updt_cnt+ 1)
    FROM v500_event_set_code esc2
    WHERE esc2.event_set_name="ALL OCF EVENT SETS")
  WHERE esc.event_set_name="ALL OCF EVENT SETS"
  WITH nocounter
 ;end update
 IF (curqual != 1)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].operationname = "ecm_chg_displays"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "UPDATE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Failed to update updt_cnt on 'ALL OCF EVENT SETS' row on the v500_event_set_code table"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 COMMIT
END GO
