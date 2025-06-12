CREATE PROGRAM 724_downtime_audit_purge
 RECORD reply(
   1 failed = i2
 )
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 IF ((request->only_audit > 0))
  GO TO audit_logging
 ENDIF
 SET trace hipaa off
 DECLARE site_id = f8 WITH public, noconstant(0.0)
 DECLARE next_code = f8 WITH public, noconstant(0.0)
 DECLARE user_tz = i4 WITH public, noconstant(0)
 DECLARE sys_tz = i4 WITH public, noconstant(0)
 IF (curutc > 0)
  SET user_tz = curtimezoneapp
  SET sys_tz = curtimezonesys
 ELSE
  SET user_tz = 0
  SET sys_tz = 0
 ENDIF
 IF ((request->event_dt_tm=""))
  SET request->event_dt_tm = "1-JAN-1900"
 ENDIF
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
  SET reply->failed = 1
  GO TO exit_program
 ENDIF
 INSERT  FROM person_prsnl_activity ppa
  SET ppa.ppa_id = next_code, ppa.person_id = request->person_id, ppa.prsnl_id = request->prsnl_id,
   ppa.ppa_type_cd = request->ppa_type_cd, ppa.ppa_first_dt_tm = cnvtdatetime(request->event_dt_tm),
   ppa.ppa_first_tz =
   IF ((request->event_tz > 0)) request->event_tz
   ELSE user_tz
   ENDIF
   ,
   ppa.ppa_last_dt_tm = cnvtdatetime(request->event_dt_tm), ppa.ppa_last_tz =
   IF ((request->event_tz > 0)) request->event_tz
   ELSE user_tz
   ENDIF
   , ppa.ppr_cd = request->ppr_cd,
   ppa.view_caption = request->view_caption, ppa.comp_caption = request->comp_caption, ppa
   .computer_name = request->computer_name,
   ppa.ppa_comment = request->ppa_comment, ppa.active_status_cd = request->active_status_cd, ppa
   .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
   ppa.active_status_prsnl_id = request->ppa_type_cd, ppa.active_ind = 1, ppa.updt_dt_tm =
   cnvtdatetime(curdate,curtime3),
   ppa.updt_cnt = 1, ppa.updt_id = reqinfo->updt_id, ppa.updt_applctx = reqinfo->updt_applctx,
   ppa.updt_task = reqinfo->updt_task
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET reply->failed = 1
  ROLLBACK
  GO TO exit_program
 ELSE
  COMMIT
 ENDIF
#audit_logging
 DECLARE type = vc
 DECLARE rolecd = vc
 DECLARE idtype = vc
 IF ((request->person_id=0))
  SET type = "System"
  SET rolecd = "Resource"
  SET idtype = ""
 ELSE
  SET type = "Person"
  SET rolecd = "Patient"
  SET idtype = "person id"
 ENDIF
 SET modify = hipaa
 SET cclaud->isaudit = 0
 SET cclaud->stat = uar_srv_isauditable("724AccessDTV","DowntimeDataAccess",cclaud->isaudit)
 IF ((cclaud->isaudit=0))
  RETURN
 ENDIF
 SET cclaud->happ = uar_srv_createauditset(1)
 IF ((cclaud->happ=0))
  RETURN
 ENDIF
 SET cclaud->stat = uar_srvsetulong(cclaud->happ,"audit_version",1)
 SET cclaud->datetime.event_dt_tm = cnvtdatetime(request->event_dt_tm)
 SET cclaud->stat = uar_srvsetdate2(cclaud->happ,"event_dt_tm",cclaud->datetime)
 SET cclaud->stat = uar_srvsetstring(cclaud->happ,"enterprise_site",request->computer_name)
 SET cclaud->stat = uar_srvsetstring(cclaud->happ,"network_acc_id",request->comp_caption)
 SET cclaud->hevent = uar_srvadditem(cclaud->happ,"event_list")
 SET cclaud->stat = uar_srvsetstring(cclaud->hevent,"event_name","724AccessDTV")
 SET cclaud->stat = uar_srvsetstring(cclaud->hevent,"event_type","DowntimeDataAccess")
 SET cclaud->hpar = uar_srvadditem(cclaud->hevent,"participants")
 SET cclaud->stat = uar_srvsetstring(cclaud->hpar,"participant_type",type)
 SET cclaud->stat = uar_srvsetstring(cclaud->hpar,"participant_role_cd",rolecd)
 SET cclaud->stat = uar_srvsetstring(cclaud->hpar,"participant_id_type",idtype)
 SET cclaud->stat = uar_srvsetdouble(cclaud->hpar,"participant_id",request->person_id)
 SET cclaud->stat = uar_srvsetstring(cclaud->hpar,"participant_name",request->view_caption)
 SET cclaud->stat = uar_srvsetstring(cclaud->hpar,"data_life_cycle",request->ppa_comment)
 SET cclaud->stat = uar_srvsetstring(cclaud->hpar,"external_source","724Access Downtime Viewer")
 SET cclaud->stat = uar_srv_audit(cclaud->happ)
 CALL uar_srvdestroyinstance(cclaud->happ)
 SET cclaud->isaudit = 0
 SET reply->failed = 0
#exit_program
END GO
