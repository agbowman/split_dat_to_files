CREATE PROGRAM cclaudit:dba
 IF (((currev < 8) OR ((cclaud->enable=0))) )
  RETURN
 ENDIF
 IF ((cclaud->debugmode=1))
  CALL echo("Begin debug cclaudit")
  CALL echo(build("$1=", $1))
  CALL echo(build("$2=", $2))
  CALL echo(build("$3=", $3))
  CALL echo(build("$4=", $4))
  CALL echo(build("$5=", $5))
  CALL echo(build("$6=", $6))
  CALL echo(build("$7=", $7))
  CALL echo(build("$8=", $8))
  CALL echo(build("$9=", $9))
  CALL echorecord(request)
  CALL echo("End debug cclaudit")
 ENDIF
 IF (( $1 IN (0, 1)))
  SET cclaud->isaudit = 0
  SET cclaud->stat = uar_srv_isauditable(nullterm( $2),nullterm( $3),cclaud->isaudit)
  IF ((cclaud->isaudit=0))
   RETURN
  ENDIF
  SET cclaud->happ = uar_srv_createauditset(1)
  IF ((cclaud->happ=0))
   RETURN
  ENDIF
  SET cclaud->stat = uar_srvsetulong(cclaud->happ,"audit_version",1)
  SET cclaud->datetime.event_dt_tm = cnvtdatetime(sysdate)
  SET cclaud->stat = uar_srvsetdate2(cclaud->happ,"event_dt_tm",cclaud->datetime)
  IF (validate(reply->status_data.status)=0)
   SET cclaud->stat = uar_srvsetshort(cclaud->happ,"outcome_ind",0)
  ELSEIF (isnumeric(reply->status_data.status))
   SET cclaud->stat = uar_srvsetshort(cclaud->happ,"outcome_ind",reply->status_data.status)
  ELSE
   SET cclaud->stat = uar_srvsetshort(cclaud->happ,"outcome_ind",evaluate(reply->status_data.status,
     "F",1,0))
  ENDIF
  SET cclaud->stat = uar_srvsetstring(cclaud->happ,"user_name",nullterm(curuser))
  SET cclaud->stat = uar_srvsetdouble(cclaud->happ,"prsnl_id",reqinfo->updt_id)
  SET cclaud->stat = uar_srvsetdouble(cclaud->happ,"role_cd",reqinfo->position_cd)
  SET cclaud->stat = uar_srvsetstring(cclaud->happ,"enterprise_site","HNAM")
  SET cclaud->stat = uar_srvsetstring(cclaud->happ,"audit_source",nullterm(reqdata->domain))
  SET cclaud->stat = uar_srvsetulong(cclaud->happ,"audit_source_type",reqinfo->updt_app)
  SET cclaud->stat = uar_srvsetulong(cclaud->happ,"network_acc_type",1)
  IF (size(reqinfo) > 100)
   SET cclaud->stat = uar_srvsetstring(cclaud->happ,"network_acc_id",reqinfo->client_node_name)
   SET cclaud->misc = build(reqinfo->updt_applctx,"|",reqinfo->updt_app,"|",reqinfo->updt_task,
    "|",reqinfo->updt_req,"|",reqinfo->perform_cnt,"|")
  ENDIF
  SET cclaud->stat = uar_srvsetasis(cclaud->happ,"context",cclaud->misc,size(cclaud->misc))
  SET cclaud->hevent = uar_srvadditem(cclaud->happ,"event_list")
  SET cclaud->stat = uar_srvsetstring(cclaud->hevent,"event_name",nullterm( $2))
  SET cclaud->stat = uar_srvsetstring(cclaud->hevent,"event_type",nullterm( $3))
 ELSEIF ((cclaud->isaudit=0))
  RETURN
 ENDIF
 IF (( $1 != 4))
  SET cclaud->hpar = uar_srvadditem(cclaud->hevent,"participants")
  SET cclaud->stat = uar_srvsetstring(cclaud->hpar,"participant_type",nullterm( $4))
  SET cclaud->stat = uar_srvsetstring(cclaud->hpar,"participant_role_cd",nullterm( $5))
  SET cclaud->stat = uar_srvsetstring(cclaud->hpar,"participant_id_type",nullterm( $6))
  SET cclaud->stat = uar_srvsetstring(cclaud->hpar,"data_life_cycle",nullterm( $7))
  SET cclaud->stat = uar_srvsetdouble(cclaud->hpar,"participant_id",cnvtreal( $8))
  SET cclaud->stat = uar_srvsetstring(cclaud->hpar,"participant_name",nullterm( $9))
 ENDIF
 CASE ( $1)
  OF 0:
  OF 3:
  OF 4:
   SET cclaud->stat = uar_srv_audit(cclaud->happ)
   CALL uar_srvdestroyinstance(cclaud->happ)
   SET cclaud->isaudit = 0
 ENDCASE
END GO
