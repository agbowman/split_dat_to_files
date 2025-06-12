CREATE PROGRAM ct_eval_pt_with_he:dba
 DECLARE hmsg = i4
 DECLARE hrequest = i4
 DECLARE hreply = i4
 DECLARE hparam = i4
 DECLARE hvalue = i4
 DECLARE iret = i4
 DECLARE hitem = i4
 DECLARE hstatus = i4
 DECLARE status = vc WITH protect
 DECLARE status_size = i4 WITH protect
 DECLARE status_idx = i4 WITH protect
 DECLARE batch_size = i4 WITH protect, constant(50)
 DECLARE person_cnt = i4 WITH protect, constant(size(request->persons,5))
 DECLARE idx = i4 WITH protect, noconstant(1)
 DECLARE loop_cnt = i4 WITH protect, constant(ceil((cnvtreal(person_cnt)/ batch_size)))
 DECLARE person_idx = i4 WITH protect, noconstant(1)
 DECLARE end_idx = i4 WITH protect, noconstant(0)
 DECLARE axises_cnt = i4 WITH protect, noconstant(0)
 DECLARE current_cnt = i4 WITH protect, noconstant(0)
 DECLARE total_cnt = i4 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE flag = vc WITH protect, noconstant("")
 DECLARE err_msg = vc WITH protect, noconstant("")
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 RECORD he_server_response(
   1 protocol_id = f8
   1 screener_id = f8
   1 job_id = f8
   1 prescreened_patients[*]
     2 person_id = f8
     2 consequents[*]
       3 what_inferred = vc
       3 absent = i4
 )
 CALL echo(build("The job id is:",request->job_id))
 CALL echorecord(request)
 SET flag = ""
 FOR (idx = 1 TO loop_cnt)
   SET current_cnt = 0
   SET hmsg = uar_srvselectmessage(966700)
   SET end_idx = minval(((person_idx+ batch_size) - 1),person_cnt)
   IF (hmsg=null)
    CALL echo("Error in handles creation")
    SET flag = "F"
    SET err_msg = concat(err_msg,"Error in handles creation;")
    CALL echo(err_msg)
    CALL uar_srvdestroyinstance(hreply)
    CALL uar_srvdestroyinstance(hrequest)
    SET total_cnt = (((total_cnt+ end_idx) - person_idx)+ 1)
    SET person_idx = (end_idx+ 1)
   ELSE
    SET hrequest = uar_srvcreaterequest(hmsg)
    SET hreply = uar_srvcreatereply(hmsg)
    IF (((hrequest=null) OR (hreply=null)) )
     CALL echo("Error in handles creation")
     SET flag = "F"
     SET err_msg = concat(err_msg,"Error in handles creation;")
     CALL echo(err_msg)
     CALL uar_srvdestroyinstance(hreply)
     CALL uar_srvdestroyinstance(hrequest)
     SET total_cnt = (((total_cnt+ end_idx) - person_idx)+ 1)
     SET person_idx = (end_idx+ 1)
    ELSE
     SET iret = uar_srvsetstring(hrequest,"knowledge_base_name","CLINTRIALS")
     SET iret = uar_srvsetstring(hrequest,"rule_engine","Drools")
     SET iret = uar_srvsetshort(hrequest,"use_stateful_session",0)
     SET iret = uar_srvsetshort(hrequest,"publish_consequents_flag",0)
     WHILE (person_idx <= end_idx)
       SET hitem = uar_srvadditem(hrequest,"axises")
       SET iret = uar_srvsetstring(hitem,"name","PERSON")
       SET iret = uar_srvsetstring(hitem,"value",nullterm(trim(cnvtstring(request->persons[person_idx
           ].person_id))))
       SET person_idx += 1
       SET current_cnt += 1
     ENDWHILE
     CALL echo("batch done")
     SET stat = uar_srvexecute(hmsg,hrequest,hreply)
     CALL echo(build2("Health Expert: SRV Perform, Status:",stat))
     IF (stat > 0)
      CALL echo("F didn't execute")
      SET flag = "F"
      SET err_msg = concat(";HE server call didnt execute-",err_msg)
      CALL echo(err_msg)
      SET total_cnt += current_cnt
     ELSE
      SET hstatus = uar_srvgetstruct(hreply,"status_data")
      SET status = uar_srvgetstringptr(hstatus,"status")
      SET status_size = uar_srvgetitemcount(hstatus,"subeventstatus")
      CALL echo(build2("status: ",status))
      CALL echo(build2("status size: ",status_size))
      DECLARE heresponse = vc WITH protect, noconstant("")
      FOR (status_idx = 0 TO (status_size - 1))
        SET hsubevent = uar_srvgetitem(hstatus,"subeventstatus",status_idx)
        SET stargetobjectname = uar_srvgetstringptr(hsubevent,"TargetObjectName")
        SET stargetobjectvalue = uar_srvgetstringptr(hsubevent,"TargetObjectValue")
        SET heresponse = concat(heresponse,build2(stargetobjectvalue,";"))
        SET soperationname = uar_srvgetstringptr(hsubevent,"OperationName")
        SET soperationstatus = uar_srvgetstringptr(hsubevent,"OperationStatus")
        CALL echo(build("HEResponse:",heresponse))
        CALL echo(build2("Target Object Name: ",stargetobjectname))
        CALL echo(build2("Target Object Value: ",stargetobjectvalue))
        CALL echo(build2("Operation Name: ",soperationname))
        CALL echo(build2("Operation Status: ",soperationstatus))
      ENDFOR
      IF (status="F")
       CALL echo("Transaction Failed")
       SET flag = "F"
       SET err_msg = concat(err_msg,build2(";Transaction failed-",heresponse))
       CALL uar_srvdestroyinstance(hreply)
       CALL uar_srvdestroyinstance(hrequest)
       SET total_cnt += current_cnt
      ELSE
       SET he_server_response->protocol_id = request->protocol_id
       SET nbrpersonentries = uar_srvgetitemcount(hreply,"axises")
       SET stat = alterlist(he_server_response->prescreened_patients,nbrpersonentries)
       FOR (i = 0 TO (nbrpersonentries - 1))
         SET hitem = uar_srvgetitem(hreply,"axises",i)
         SET spersonid = uar_srvgetstringptr(hitem,"value")
         SET he_server_response->prescreened_patients[(i+ 1)].person_id = cnvtreal(spersonid)
         SET nbrconsentries = uar_srvgetitemcount(hitem,"consequents")
         SET stat = alterlist(he_server_response->prescreened_patients[(i+ 1)].consequents,
          nbrconsentries)
         FOR (j = 0 TO (nbrconsentries - 1))
           SET hconsitem = uar_srvgetitem(hitem,"consequents",j)
           SET sconsqname = uar_srvgetstringptr(hconsitem,"name")
           SET swhtinf = uar_srvgetstringptr(hconsitem,"what_inferred")
           SET sabsent = uar_srvgetstringptr(hconsitem,"absent")
           SET he_server_response->prescreened_patients[(i+ 1)].consequents[(j+ 1)].what_inferred =
           swhtinf
           SET he_server_response->prescreened_patients[(i+ 1)].consequents[(j+ 1)].absent = cnvtint(
            sabsent)
         ENDFOR
       ENDFOR
       SET he_server_response->screener_id = request->screener_id
       SET he_server_response->job_id = request->job_id
       CALL echorecord(he_server_response)
       SET stat = tdbexecute(4150006,4150039,4150070,"REC",he_server_response,
        "REC",reply_out)
       CALL echo(build("status of call: ",stat))
      ENDIF
     ENDIF
     SET axises_cnt = uar_srvgetitemcount(hreply,"axises")
     CALL echo(build("Axes count: ",axises_cnt))
    ENDIF
   ENDIF
   CALL uar_srvdestroyinstance(hmsg)
   CALL uar_srvdestroyinstance(hreply)
   CALL uar_srvdestroyinstance(hrequest)
 ENDFOR
 CALL echo(build("Total failed patients count:",total_cnt))
 IF ((request->job_id > 0))
  DECLARE failed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17917,"FAILED"))
  DECLARE job_end_ind = i2 WITH protect, noconstant(0)
  IF (flag="F")
   SUBROUTINE (nextlongtextsequence(x=i2) =f8)
     DECLARE nsequence = f8 WITH protect
     SELECT INTO "nl:"
      nextseqnum = seq(long_data_seq,nextval)
      FROM dual
      DETAIL
       nsequence = nextseqnum
      WITH nocounter
     ;end select
     RETURN(nsequence)
   END ;Subroutine
   SUBROUTINE (insert_long_text(long_text_id=f8,text=vc,parent_name=vc,parent_id=f8) =i2)
    INSERT  FROM long_text lt
     SET lt.long_text_id =
      IF (long_text_id > 0) long_text_id
      ELSE seq(long_data_seq,nextval)
      ENDIF
      , lt.long_text = text, lt.parent_entity_name = parent_name,
      lt.parent_entity_id = parent_id, lt.updt_dt_tm = cnvtdatetime(sysdate), lt.updt_id = reqinfo->
      updt_id,
      lt.updt_applctx = reqinfo->updt_applctx, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
      lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm =
      cnvtdatetime(sysdate),
      lt.active_status_prsnl_id = reqinfo->updt_id
     WITH nocounter
    ;end insert
    IF (curqual=0)
     RETURN(false)
    ELSE
     RETURN(true)
    ENDIF
   END ;Subroutine
   DECLARE long_text_id = f8 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM long_text l
    WHERE (l.parent_entity_id=request->job_id)
    DETAIL
     long_text_id = l.long_text_id, err_msg = build2(err_msg,l.long_text)
    WITH nocounter
   ;end select
   IF (long_text_id > 0)
    SELECT INTO "nl:"
     FROM long_text l
     WHERE l.long_text_id=long_text_id
     WITH nocounter, forupdatewait(l)
    ;end select
    UPDATE  FROM long_text l
     SET l.long_text = err_msg
     WHERE l.long_text_id=long_text_id
    ;end update
   ELSE
    SET long_text_id = nextlongtextsequence(0)
    CALL insert_long_text(long_text_id,err_msg,"ct_eval_pt_with_he",request->job_id)
   ENDIF
   SELECT INTO "nl:"
    FROM ct_prescreen_job cj
    WHERE (cj.ct_prescreen_job_id=request->job_id)
    WITH nocounter, forupdatewait(cj)
   ;end select
   UPDATE  FROM ct_prescreen_job cj
    SET cj.job_status_cd = failed_cd, cj.job_end_dt_tm = cnvtdatetime(sysdate)
    WHERE (cj.ct_prescreen_job_id=request->job_id)
   ;end update
   SELECT INTO "nl:"
    FROM ct_prot_prescreen_job_info cji
    WHERE (cji.ct_prescreen_job_id=request->job_id)
    WITH nocounter, forupdatewait(cji)
   ;end select
   UPDATE  FROM ct_prot_prescreen_job_info cji
    SET cji.curr_eval_pat_cnt = (cji.curr_eval_pat_cnt+ total_cnt), cji.updt_dt_tm = cnvtdatetime(
      sysdate), cji.updt_cnt = (cji.updt_cnt+ 1)
    WHERE (cji.ct_prescreen_job_id=request->job_id)
   ;end update
   SELECT INTO "nl:"
    FROM ct_prot_prescreen_job_info cji
    WHERE (cji.ct_prescreen_job_id=request->job_id)
    DETAIL
     IF (cji.total_eval_pat_cnt=cji.curr_eval_pat_cnt)
      job_end_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (job_end_ind=1)
    UPDATE  FROM ct_prot_prescreen_job_info cji
     SET cji.completed_flag = 1
     WHERE (cji.ct_prescreen_job_id=request->job_id)
    ;end update
   ENDIF
  ENDIF
 ENDIF
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  CALL echo("Transaction error, changes rolled back")
 ELSE
  COMMIT
 ENDIF
 CALL echo("Suceess")
END GO
