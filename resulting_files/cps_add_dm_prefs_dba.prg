CREATE PROGRAM cps_add_dm_prefs:dba
 RECORD reply(
   1 pref_id = f8
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
 SET next_code = 0.0
 SET count1 = 0
 SELECT INTO "NL:"
  nextseq = seq(dm_seq,nextval)
  FROM dual
  DETAIL
   next_code = nextseq
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "NEXT_SEQ"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CPSADDDMPREF"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  dp.pref_id
  FROM dm_prefs dp
  WHERE dp.application_nbr=961000
   AND dp.pref_domain="PCO-EASYSCRIPT"
   AND dp.pref_section="ADDITIONAL_REFILL"
   AND dp.pref_name="ZEROBASED"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.subeventstatus[1].operationname = "PREFERENCE ALREADY EXISTS"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "DM_PREFS"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 INSERT  FROM dm_prefs dp
  SET dp.pref_id = next_code, dp.application_nbr = 961000, dp.parent_entity_id = 0,
   dp.parent_entity_name = "", dp.person_id = reqinfo->updt_id, dp.pref_cd = 0,
   dp.pref_domain = "PCO-EASYSCRIPT", dp.pref_dt_tm = cnvtdatetime(curdate,curtime3), dp.pref_name =
   "ZEROBASED",
   dp.pref_nbr = 0, dp.pref_str = "", dp.pref_section = "ADDITIONAL_REFILL",
   dp.reference_ind = 0, dp.updt_cnt = 0, dp.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   dp.updt_id = reqinfo->updt_id, dp.updt_task = reqinfo->updt_task, dp.updt_applctx = reqinfo->
   updt_applctx
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "INSERT PREFS1"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "DM_PREFS1"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SET reply->pref_id = next_code
#exit_script
 IF (failed="T")
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
  SET reply->pref_id = next_code
 ENDIF
 SET last_mod = "000"
END GO
