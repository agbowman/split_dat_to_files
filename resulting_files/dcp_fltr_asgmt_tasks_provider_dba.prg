CREATE PROGRAM dcp_fltr_asgmt_tasks_provider:dba
 DECLARE tskcnt = i4 WITH noconstant(0)
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE tsk_cnt = i4 WITH noconstant(0)
 DECLARE loc_cnt = i4 WITH noconstant(0)
 DECLARE dactionstarttime = dq8 WITH protect, noconstant(0)
 DECLARE delapsedtime = f8 WITH protect, noconstant(0.0)
 DECLARE id_cnt = i4 WITH noconstant(0)
 DECLARE pidx = i4 WITH constant(0)
 DECLARE failed = i2 WITH noconstant(0)
 DECLARE select_error = i2 WITH constant(7)
 DECLARE serrmsg = vc WITH noconstant(fillstring(132," "))
 DECLARE getassgmtlocations(null) = null
 DECLARE getlocationtask(null) = null
 DECLARE getupdtid(null) = null
 FREE RECORD reply
 RECORD reply(
   1 qual_tasks[*]
     2 task_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET serrmsg = "No row qualified"
 FREE RECORD locations
 RECORD locations(
   1 qual[*]
     2 loc_cd = f8
 )
 FREE RECORD personnelids
 RECORD personnelids(
   1 prsnl_list[*]
     2 prsnl_id = f8
 )
 IF (validate(request->patient_list))
  CALL getupdtid(null)
 ELSE
  SET size_prsnl = size(request->prsnl_list,5)
  SET stat = alterlist(personnelids->prsnl_list,size_prsnl)
  FOR (ind = 1 TO size_prsnl)
    SET personnelids->prsnl_list[ind].prsnl_id = request->prsnl_list[ind].prsnl_id
  ENDFOR
 ENDIF
 CALL getassgmtlocations(null)
 CALL getlocationtask(null)
 SUBROUTINE getupdtid(null)
   SET dactionstarttime = cnvtdatetime(sysdate)
   SELECT DISTINCT INTO "n1:"
    FROM dcp_pl_reltn plr
    WHERE expand(pidx,1,size(request->patient_list,5),plr.patient_list_id,request->patient_list[pidx]
     .patient_list_id)
    HEAD REPORT
     id_cnt = 0
    DETAIL
     id_cnt += 1
     IF (mod(id_cnt,10)=1)
      stat = alterlist(personnelids->prsnl_list,(id_cnt+ 9))
     ENDIF
     IF (plr.updt_id > 0)
      personnelids->prsnl_list[id_cnt].prsnl_id = plr.updt_id
     ENDIF
     CALL echo("*******************************************************"),
     CALL echo("GetUpdtID=",personnelids->prsnl_list[id_cnt].prsnl_id),
     CALL echo("*******************************************************")
    FOOT REPORT
     stat = alterlist(personnelids->prsnl_list,id_cnt)
    WITH nocounter
   ;end select
   SET delapsedtime = datetimediff(cnvtdatetime(sysdate),dactionstarttime,5)
   CALL echo("*******************************************************")
   CALL echo(build("select from GetUpdtID ",delapsedtime))
   CALL echo("*******************************************************")
   IF (curqual=0)
    SET size_prsnl = size(request->prsnl_list,5)
    SET stat = alterlist(personnelids->prsnl_list,size_prsnl)
    FOR (ind = 1 TO size_prsnl)
      SET personnelids->prsnl_list[ind].prsnl_id = request->prsnl_list[ind].prsnl_id
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE getassgmtlocations(null)
   SET dactionstarttime = cnvtdatetime(sysdate)
   SELECT DISTINCT INTO "nl:"
    FROM dcp_shift_assignment sa
    WHERE expand(idx,1,size(personnelids->prsnl_list,5),sa.prsnl_id,personnelids->prsnl_list[idx].
     prsnl_id)
     AND sa.active_ind=1
     AND ((sa.beg_effective_dt_tm >= cnvtdatetime(curdate,0)) OR (sa.end_effective_dt_tm <=
    cnvtdatetime(curdate,235959)))
    HEAD REPORT
     loccnt = 0
    DETAIL
     loccnt += 1
     IF (mod(loccnt,10)=1)
      stat = alterlist(locations->qual,(loccnt+ 9))
     ENDIF
     locations->qual[loccnt].loc_cd = sa.loc_unit_cd
    FOOT REPORT
     stat = alterlist(locations->qual,loccnt)
    WITH nocounter
   ;end select
   SET delapsedtime = datetimediff(cnvtdatetime(sysdate),dactionstarttime,5)
   CALL echo("*******************************************************")
   CALL echo(build("select from GetAssgmtLocations = ",delapsedtime))
   CALL echo("*******************************************************")
   IF (curqual=0)
    SET failed = select_error
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE getlocationtask(null)
   SET dactionstarttime = cnvtdatetime(sysdate)
   SELECT DISTINCT INTO "n1:"
    FROM task_activity t
    WHERE expand(cnt,1,size(locations->qual,5),t.location_cd,locations->qual[cnt].loc_cd)
     AND expand(tsk_cnt,1,size(request->task_list,5),t.task_id,request->task_list[tsk_cnt].task_id)
    HEAD REPORT
     tskcnt = 0
    DETAIL
     tskcnt += 1
     IF (mod(tskcnt,10)=1)
      stat = alterlist(reply->qual_tasks,(tskcnt+ 9))
     ENDIF
     reply->qual_tasks[tskcnt].task_id = t.task_id
    FOOT REPORT
     stat = alterlist(reply->qual_tasks[tskcnt],tskcnt)
    WITH nocounter
   ;end select
   SET delapsedtime = datetimediff(cnvtdatetime(sysdate),dactionstarttime,5)
   CALL echo("*******************************************************")
   CALL echo(build("select from GetLocationTask = ",delapsedtime))
   CALL echo("*******************************************************")
 END ;Subroutine
#exit_script
 CALL echo("exit script")
 IF (tskcnt=0)
  IF (failed != 0)
   SET reply->status_data.subeventstatus[1].operationname = "GetAssgmtLocations"
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "GetLocationTask"
  ENDIF
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
