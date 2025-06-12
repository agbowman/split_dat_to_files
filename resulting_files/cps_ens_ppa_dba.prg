CREATE PROGRAM cps_ens_ppa:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 RECORD reply(
   1 ppa_id = f8
   1 swarnmsg = c100
   1 status_data
     2 status = c1
     2 subeventstatus[2]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET trace hipaa off
 IF ((request->cancel_logging > 0))
  GO TO exit_script
 ENDIF
 DECLARE ppa_id = f8 WITH public, noconstant(0.0)
 DECLARE chart_access_cd = f8 WITH public, noconstant(0.0)
 DECLARE view_access_cd = f8 WITH public, noconstant(0.0)
 DECLARE priv_access_cd = f8 WITH public, noconstant(0.0)
 DECLARE audio_access_cd = f8 WITH public, noconstant(0.0)
 DECLARE video_access_cd = f8 WITH public, noconstant(0.0)
 DECLARE chart_stamp_cd = f8 WITH public, noconstant(0.0)
 DECLARE next_code = f8 WITH public, noconstant(0.0)
 DECLARE downtimeview_access_cd = f8 WITH public, noconstant(0.0)
 DECLARE user_tz = i4 WITH public, noconstant(0)
 DECLARE sys_tz = i4 WITH public, noconstant(0)
 DECLARE dambulatory_admin_cd = f8 WITH private, constant(uar_get_code_by("MEANING",104,
   "AMBADMINTOOL"))
 DECLARE ddtv_admin_cd = f8 WITH private, constant(uar_get_code_by("MEANING",104,"DTVADMINTOOL"))
 IF (curutc > 0)
  SET user_tz = curtimezoneapp
  SET sys_tz = curtimezonesys
 ELSE
  SET user_tz = 0
  SET sys_tz = 0
 ENDIF
 CALL echo("***")
 CALL echo("***   Validate last_dt_tm Value")
 CALL echo("***")
 IF ((request->last_dt_tm=cnvtdatetime("")))
  SET request->last_dt_tm = cnvtdatetime("1-JAN-1900")
 ENDIF
 CALL echo("***")
 CALL echo("***   Get Code Values")
 CALL echo("***")
 SET chart_access_cd = uar_get_code_by("MEANING",104,"CHARTACCESS")
 SET view_access_cd = uar_get_code_by("MEANING",104,"VIEWACCESS")
 SET priv_access_cd = uar_get_code_by("MEANING",104,"PRIV ACCESS")
 SET audio_access_cd = uar_get_code_by("MEANING",104,"AUDIOACCESS")
 SET video_access_cd = uar_get_code_by("MEANING",104,"VIDEOACCESS")
 SET chart_stamp_cd = uar_get_code_by("MEANING",104,"CHARTSTAMPED")
 SET downtimeview_access_cd = uar_get_code_by("MEANING",104,"DOWNTIMEVIEW")
 IF ((((request->ppa_type_cd=chart_access_cd)) OR ((((request->ppa_type_cd=view_access_cd)) OR ((((
 request->ppa_type_cd=priv_access_cd)) OR ((((request->ppa_type_cd=audio_access_cd)) OR ((((request->
 ppa_type_cd=video_access_cd)) OR ((((request->ppa_type_cd=chart_stamp_cd)) OR ((((request->
 ppa_type_cd=downtimeview_access_cd)) OR ((((request->ppa_type_cd=dambulatory_admin_cd)) OR ((request
 ->ppa_type_cd=ddtv_admin_cd))) )) )) )) )) )) )) )) )
  CALL echo("***")
  CALL echo("***   Add New Row if Not RESULT REVIE PPA_TYPE_CD")
  CALL echo("***")
  SET next_code = 0.0
  SET site_id = (cnvtreal(logical("SITE_ID")) * 0.1)
  SELECT INTO "nl:"
   nextseqnum = seq(person_prsnl_activity_seq,nextval)"#################;rp0"
   FROM dual
   DETAIL
    next_code = (cnvtreal(nextseqnum)+ site_id)
   WITH format
  ;end select
  IF (next_code <= 1)
   SET ierrcode = error(serrmsg,1)
   SET failed = gen_nbr_error
   SET table_name = "CPS_ENS_PPA"
   GO TO exit_script
  ENDIF
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  INSERT  FROM person_prsnl_activity ppa
   SET ppa.ppa_id = next_code, ppa.person_id = request->person_id, ppa.prsnl_id = request->prsnl_id,
    ppa.ppa_type_cd = request->ppa_type_cd, ppa.ppa_first_dt_tm = cnvtdatetime(request->last_dt_tm),
    ppa.ppa_first_tz =
    IF ((request->last_tz > 0)) request->last_tz
    ELSE user_tz
    ENDIF
    ,
    ppa.ppa_last_dt_tm = cnvtdatetime(request->last_dt_tm), ppa.ppa_last_tz =
    IF ((request->last_tz > 0)) request->last_tz
    ELSE user_tz
    ENDIF
    , ppa.ppr_cd = request->ppr_cd,
    ppa.view_caption = request->view_caption, ppa.comp_caption = request->comp_caption, ppa
    .computer_name = request->computer_name,
    ppa.ppa_comment = request->ppa_comment, ppa.active_status_cd = 0, ppa.active_status_dt_tm =
    cnvtdatetime(sysdate),
    ppa.active_status_prsnl_id = reqinfo->updt_id, ppa.active_ind = 1, ppa.updt_dt_tm = cnvtdatetime(
     sysdate),
    ppa.updt_cnt = 0, ppa.updt_id = reqinfo->updt_id, ppa.updt_applctx = reqinfo->updt_applctx,
    ppa.updt_task = reqinfo->updt_task
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = insert_error
   SET table_name = "PERSON_PRSNL_ACTIVITY"
   GO TO exit_script
  ELSE
   SET reply->ppa_id = next_code
  ENDIF
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   Handle Bookmark")
 CALL echo("***")
 SET ppa_id = 0.0
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM person_prsnl_activity ppa
  PLAN (ppa
   WHERE (ppa.ppa_id=
   (SELECT
    max(ppa2.ppa_id)
    FROM person_prsnl_activity ppa2
    WHERE ((ppa2.prsnl_id+ 0)=request->prsnl_id)
     AND (ppa2.person_id=request->person_id)
     AND (ppa2.ppa_type_cd=request->ppa_type_cd)
     AND ((ppa2.active_ind+ 0)=1))))
  ORDER BY ppa.ppa_last_dt_tm DESC
  HEAD REPORT
   ppa_id = ppa.ppa_id
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "PERSON_PRSNL_ACTIVITY"
  GO TO exit_script
 ENDIF
 IF (ppa_id > 0)
  CALL echo("***")
  CALL echo(build("***   Update Existing Entry  ppa_id :",ppa_id))
  CALL echo("***")
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  UPDATE  FROM person_prsnl_activity ppa
   SET ppa.ppa_last_dt_tm = cnvtdatetime(request->last_dt_tm), ppa.ppa_last_tz =
    IF ((request->last_tz > 0)) request->last_tz
    ELSE user_tz
    ENDIF
    , ppa.updt_dt_tm = cnvtdatetime(sysdate),
    ppa.updt_cnt = (ppa.updt_cnt+ 1), ppa.updt_id = reqinfo->updt_id, ppa.updt_applctx = reqinfo->
    updt_applctx,
    ppa.updt_task = reqinfo->updt_task
   PLAN (ppa
    WHERE ppa.ppa_id=ppa_id
     AND ppa.ppa_last_dt_tm < cnvtdatetime(request->last_dt_tm))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = update_error
   SET table_name = "PERSON_PRSNL_ACTIVITY"
   GO TO exit_script
  ENDIF
  SET reply->ppa_id = ppa_id
 ELSE
  CALL echo("***")
  CALL echo("***   Insert New Results Reviewed Row")
  CALL echo("***")
  SET next_code = 0.0
  SET site_id = (cnvtreal(logical("SITE_ID")) * 0.1)
  SELECT INTO "nl:"
   nextseqnum = seq(person_prsnl_activity_seq,nextval)"#################;rp0"
   FROM dual
   DETAIL
    next_code = (cnvtreal(nextseqnum)+ site_id)
   WITH format
  ;end select
  IF (next_code < 1)
   SET ierrcode = error(serrmsg,1)
   SET failed = gen_nbr_error
   SET table_name = "CPS_ENS_PPA"
   GO TO exit_script
  ENDIF
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  INSERT  FROM person_prsnl_activity ppa
   SET ppa.ppa_id = next_code, ppa.person_id = request->person_id, ppa.prsnl_id = request->prsnl_id,
    ppa.ppa_type_cd = request->ppa_type_cd, ppa.ppa_first_dt_tm = cnvtdatetime(request->last_dt_tm),
    ppa.ppa_first_tz =
    IF ((request->last_tz > 0)) request->last_tz
    ELSE user_tz
    ENDIF
    ,
    ppa.ppa_last_dt_tm = cnvtdatetime(request->last_dt_tm), ppa.ppa_last_tz =
    IF ((request->last_tz > 0)) request->last_tz
    ELSE user_tz
    ENDIF
    , ppa.ppr_cd = request->ppr_cd,
    ppa.view_caption = request->view_caption, ppa.comp_caption = request->comp_caption, ppa
    .computer_name = request->computer_name,
    ppa.ppa_comment = request->ppa_comment, ppa.active_status_cd = 0, ppa.active_status_dt_tm =
    cnvtdatetime(sysdate),
    ppa.active_status_prsnl_id = reqinfo->updt_id, ppa.active_ind = 1, ppa.updt_dt_tm = cnvtdatetime(
     sysdate),
    ppa.updt_cnt = 0, ppa.updt_id = reqinfo->updt_id, ppa.updt_applctx = reqinfo->updt_applctx,
    ppa.updt_task = reqinfo->updt_task
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = insert_error
   SET table_name = "PERSON_PRSNL_ACTIVITY"
   GO TO exit_script
  ELSE
   SET reply->ppa_id = next_code
  ENDIF
 ENDIF
#exit_script
 CALL echo("***")
 CALL echo("***   Exit Script")
 CALL echo("***")
 IF (failed=false)
  SET reqinfo->commit_ind = true
  SET reply->status_data.status = "S"
 ELSE
  SET reqinfo->commit_ind = false
  SET reply->status_data.status = "F"
  CASE (failed)
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   OF gen_nbr_error:
    SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   OF select_error:
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  SET reply->swarnmsg = serrmsg
 ENDIF
 SET modify = hipaa
 EXECUTE cclaudit 1, "Maintain Person", "Chart Access Log",
 "Person", "Patient", "Patient",
 "Access/Use", request->person_id, ""
 EXECUTE cclaudit 3, "Maintain Person", "Chart Access Log",
 "System Object", "Report", "",
 "Access/Use", "", request->view_caption
 SET script_version = "MOD 015 09/11/06 MS5566"
END GO
