CREATE PROGRAM dcp_add_comp_phase_reltn
 SET modify = predeclare
 DECLARE component_phase_reltn_count = i4 WITH protect, constant(value(size(request->
    compphasereltnlist,5)))
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE isubeventstatuscount = i4 WITH protect, noconstant(0)
 DECLARE isubeventstatussize = i4 WITH protect, noconstant(value(size(reply->status_data.
    subeventstatus,5)))
 DECLARE last_mod = c3 WITH protect, noconstant(fillstring(3,"000"))
 DECLARE mod_date = c30 WITH protect, noconstant(fillstring(30," "))
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errcnt = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant(" ")
 DECLARE set_script_status(cstatus=c1,soperationname=vc,coperationstatus=c1,stargetobjectname=vc,
  stargetobjectvalue=vc) = null
 SET reply->status_data.status = "S"
 IF (component_phase_reltn_count < 1)
  CALL set_script_status("Z","BEGIN","Z","dcp_add_comp_phase_reltn",
   "The compPhaseReltnList was empty.")
  GO TO exit_script
 ENDIF
 INSERT  FROM pw_comp_act_reltn pcar,
   (dummyt d  WITH seq = value(component_phase_reltn_count))
  SET pcar.pw_comp_act_reltn_id = seq(carenet_seq,nextval), pcar.act_pw_comp_id = request->
   compphasereltnlist[d.seq].act_pw_comp_id, pcar.pathway_id = request->compphasereltnlist[d.seq].
   pathway_id,
   pcar.type_mean = trim(request->compphasereltnlist[d.seq].type_mean), pcar.updt_applctx = reqinfo->
   updt_applctx, pcar.updt_cnt = 0,
   pcar.updt_dt_tm = cnvtdatetime(curdate,curtime3), pcar.updt_id = reqinfo->updt_id, pcar.updt_task
    = reqinfo->updt_task
  PLAN (d)
   JOIN (pcar)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  CALL set_script_status("F","INSERT","F","dcp_add_comp_phase_reltn",
   "Failed to insert rows into the pw_comp_act_reltn table.")
  GO TO exit_script
 ENDIF
 SUBROUTINE set_script_status(cstatus,soperationname,coperationstatus,stargetobjectname,
  stargetobjectvalue)
   IF ((reply->status_data.status="S"))
    SET reply->status_data.status = cstatus
   ELSEIF (cstatus="F")
    SET reply->status_data.status = cstatus
   ENDIF
   SET isubeventstatuscount = (isubeventstatuscount+ 1)
   IF (isubeventstatuscount > isubeventstatussize)
    SET isubeventstatussize = (isubeventstatussize+ 1)
    SET stat = alterlist(reply->status_data.subeventstatus,isubeventstatussize)
   ENDIF
   SET reply->status_data.subeventstatus[isubeventstatuscount].operationname = substring(1,25,trim(
     soperationname))
   SET reply->status_data.subeventstatus[isubeventstatuscount].operationstatus = trim(
    coperationstatus)
   SET reply->status_data.subeventstatus[isubeventstatuscount].targetobjectname = substring(1,25,trim
    (stargetobjectname))
   SET reply->status_data.subeventstatus[isubeventstatuscount].targetobjectvalue = trim(
    stargetobjectvalue)
 END ;Subroutine
#exit_script
 SET errcode = error(errmsg,0)
 WHILE (errcode != 0
  AND errcnt <= 50)
   SET errcnt = (errcnt+ 1)
   CALL set_script_status("F","CCL ERROR","F","dcp_add_comp_phase_reltn",errmsg)
   SET errcode = error(errmsg,0)
 ENDWHILE
 SET last_mod = "001"
 SET mod_date = "July 20, 2011"
END GO
