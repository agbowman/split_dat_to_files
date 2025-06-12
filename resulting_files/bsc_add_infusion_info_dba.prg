CREATE PROGRAM bsc_add_infusion_info:dba
 SET modify = predeclare
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE SET ib_event_struct
 RECORD ib_event_struct(
   1 infusion_billing_event_id = f8
   1 prev_infusion_billing_event_id = f8
   1 encntr_id = f8
   1 order_id = f8
   1 infuse_start_dt_tm = dq8
   1 infuse_start_tz = i4
   1 infuse_end_dt_tm = dq8
   1 infuse_end_tz = i4
   1 create_prsnl_id = f8
   1 comment_long_text_id = f8
   1 begin_effective_dt_tm = dq8
   1 updt_id = f8
   1 updt_cnt = i4
   1 updt_task = f8
   1 updt_applctx = f8
   1 infusion_duration_mins = i4
   1 infused_volume_value = f8
 )
 DECLARE new_infusion = i4 WITH protect, constant(1)
 DECLARE mod_infusion = i4 WITH protect, constant(2)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i2 WITH protect, noconstant(0)
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 DECLARE insertinfusions(null) = null
 DECLARE updateinfusions(null) = null
 DECLARE inactivateinfusions(null) = null
 DECLARE insertibclinevents(iinfusionactionflag=i4,dinfusionbillingeventid=f8,iinfusionidx=i4) = null
 DECLARE updateibclinevents(dprevibeventid=f8,dcurribeventid=f8,iinfusionidx=i4) = null
 DECLARE insertlongtext(dparententityid=f8,slongtext=vc,dlongtextid=f8(ref)) = null
 DECLARE updatelongtext(dprevlongtextid=f8,dprevparententityid=f8,dcurrparententityid=f8,slongtext=vc,
  dcurrlongtextid=f8(ref)) = null
 DECLARE resetibeventstruct(null) = null
 DECLARE checkforerrors(serrmsg=vc,bcheckcurqual=i2) = null
 SET reply->status_data.status = "F"
 CALL insertinfusions(null)
 CALL checkforerrors("Failure to insert new infusions",0)
 CALL updateinfusions(null)
 CALL checkforerrors("Failure to modify infusions",0)
 CALL inactivateinfusions(null)
 CALL checkforerrors("Failure to delete infusions",0)
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
 GO TO exit_script
 SUBROUTINE insertinfusions(null)
   IF ((request->debug_ind=1))
    CALL echo("********Entering InsertInfusions********")
   ENDIF
   DECLARE inewinfusecnt = i4 WITH protect, noconstant(0)
   DECLARE dnextibeventid = f8 WITH protect, noconstant(0)
   DECLARE dlongtextid = f8 WITH protect, noconstant(0)
   DECLARE i = i4 WITH protect, noconstant(0)
   SET inewinfusecnt = size(request->new_infusion_list,5)
   FOR (i = 1 TO inewinfusecnt)
     SELECT INTO "nl:"
      dnextseqnum = seq(medadmin_seq,nextval)
      FROM dual
      DETAIL
       dnextibeventid = dnextseqnum
      WITH nocounter
     ;end select
     CALL checkforerrors("Failed to create infusion_billing_event_id",1)
     IF ((request->debug_ind=1))
      CALL echo(build("********InsertInfusions -> Inserting infusion_billing_event_id : ",
        dnextibeventid))
     ENDIF
     SET dlongtextid = 0
     IF (textlen(trim(request->new_infusion_list[i].comment,3)) > 0)
      CALL insertlongtext(dnextibeventid,request->new_infusion_list[i].comment,dlongtextid)
     ENDIF
     INSERT  FROM infusion_billing_event ibe
      SET ibe.infusion_billing_event_id = dnextibeventid, ibe.prev_infusion_billing_event_id =
       dnextibeventid, ibe.encntr_id = request->new_infusion_list[i].encntr_id,
       ibe.order_id = request->new_infusion_list[i].order_id, ibe.infusion_start_dt_tm = cnvtdatetime
       (request->new_infusion_list[i].infuse_start_dt_tm), ibe.infusion_start_tz = request->
       new_infusion_list[i].infuse_start_tz,
       ibe.infusion_end_dt_tm = cnvtdatetime(request->new_infusion_list[i].infuse_end_dt_tm), ibe
       .infusion_end_tz = request->new_infusion_list[i].infuse_end_tz, ibe.create_prsnl_id = request
       ->new_infusion_list[i].prsnl_id,
       ibe.comment_long_text_id = dlongtextid, ibe.begin_effective_dt_tm = cnvtdatetime(curdate,
        curtime3), ibe.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"),
       ibe.active_ind = 1, ibe.updt_applctx = reqinfo->updt_applctx, ibe.updt_cnt = 0,
       ibe.updt_dt_tm = cnvtdatetime(curdate,curtime3), ibe.updt_id = reqinfo->updt_id, ibe.updt_task
        = reqinfo->updt_task,
       ibe.infusion_duration_mins = request->new_infusion_list[i].infusion_duration_mins, ibe
       .infused_volume_value = request->new_infusion_list[i].infused_volume_value
      WITH nocounter
     ;end insert
     CALL checkforerrors("Failed to insert infusion event",1)
     CALL insertibclinevents(new_infusion,dnextibeventid,i)
     IF ((request->debug_ind=1))
      CALL echo(build("********InsertInfusions -> Done inserting new IB event at index:",i))
     ENDIF
   ENDFOR
   IF ((request->debug_ind=1))
    CALL echo(build("********Exiting InsertInfusions******** iNewInfuseCnt = ",inewinfusecnt))
   ENDIF
 END ;Subroutine
 SUBROUTINE updateinfusions(null)
   IF ((request->debug_ind=1))
    CALL echo("********Entering UpdateInfusions********")
   ENDIF
   DECLARE imodifiedinfusecnt = i4 WITH protect, noconstant(0)
   DECLARE dnextibeventid = f8 WITH protect, noconstant(0)
   DECLARE dlongtextid = f8 WITH protect, noconstant(0)
   DECLARE i = i4 WITH protect, noconstant(0)
   SET imodifiedinfusecnt = size(request->modified_infusion_list,5)
   FOR (i = 1 TO imodifiedinfusecnt)
     SELECT INTO "nl:"
      dnextseqnum = seq(medadmin_seq,nextval)
      FROM dual
      DETAIL
       dnextibeventid = dnextseqnum
      WITH nocounter
     ;end select
     CALL checkforerrors("Failed to create infusion_billing_event_id",1)
     CALL resetibeventstruct(null)
     SELECT INTO "nl:"
      FROM infusion_billing_event ibe
      WHERE (ibe.infusion_billing_event_id=request->modified_infusion_list[i].
      infusion_billing_event_id)
      DETAIL
       ib_event_struct->infusion_billing_event_id = ibe.infusion_billing_event_id, ib_event_struct->
       prev_infusion_billing_event_id = ibe.prev_infusion_billing_event_id, ib_event_struct->
       encntr_id = ibe.encntr_id,
       ib_event_struct->order_id = ibe.order_id, ib_event_struct->infuse_start_dt_tm = ibe
       .infusion_start_dt_tm, ib_event_struct->infuse_start_tz = ibe.infusion_start_tz,
       ib_event_struct->infuse_end_dt_tm = ibe.infusion_end_dt_tm, ib_event_struct->infuse_end_tz =
       ibe.infusion_end_tz, ib_event_struct->create_prsnl_id = ibe.create_prsnl_id,
       ib_event_struct->comment_long_text_id = ibe.comment_long_text_id, ib_event_struct->
       begin_effective_dt_tm = ibe.begin_effective_dt_tm, ib_event_struct->updt_id = ibe.updt_id,
       ib_event_struct->updt_cnt = ibe.updt_cnt, ib_event_struct->updt_task = ibe.updt_task,
       ib_event_struct->updt_applctx = ibe.updt_applctx,
       ib_event_struct->infusion_duration_mins = ibe.infusion_duration_mins, ib_event_struct->
       infused_volume_value = ibe.infused_volume_value
      WITH nocounter
     ;end select
     CALL checkforerrors("i_b_event_id not found",1)
     IF ((request->debug_ind=1))
      CALL echo(build("********UpdateInfusions -> Inserting new infusion_billing_event_id : ",
        dnextibeventid))
     ENDIF
     INSERT  FROM infusion_billing_event ibe
      SET ibe.infusion_billing_event_id = dnextibeventid, ibe.prev_infusion_billing_event_id =
       ib_event_struct->prev_infusion_billing_event_id, ibe.encntr_id = ib_event_struct->encntr_id,
       ibe.order_id = ib_event_struct->order_id, ibe.infusion_start_dt_tm = cnvtdatetime(
        ib_event_struct->infuse_start_dt_tm), ibe.infusion_start_tz = ib_event_struct->
       infuse_start_tz,
       ibe.infusion_end_dt_tm = cnvtdatetime(ib_event_struct->infuse_end_dt_tm), ibe.infusion_end_tz
        = ib_event_struct->infuse_end_tz, ibe.create_prsnl_id = ib_event_struct->create_prsnl_id,
       ibe.comment_long_text_id = ib_event_struct->comment_long_text_id, ibe.begin_effective_dt_tm =
       cnvtdatetime(ib_event_struct->begin_effective_dt_tm), ibe.end_effective_dt_tm = cnvtdatetime(
        curdate,curtime3),
       ibe.active_ind = 0, ibe.updt_applctx = ib_event_struct->updt_applctx, ibe.updt_cnt = (
       ib_event_struct->updt_cnt+ 1),
       ibe.updt_dt_tm = cnvtdatetime(curdate,curtime3), ibe.updt_id = ib_event_struct->updt_id, ibe
       .updt_task = ib_event_struct->updt_task,
       ibe.infusion_duration_mins = ib_event_struct->infusion_duration_mins, ibe.infused_volume_value
        = ib_event_struct->infused_volume_value
      WITH nocounter
     ;end insert
     CALL checkforerrors("Failed to insert infusion event",1)
     SET dlongtextid = ib_event_struct->comment_long_text_id
     IF ((request->modified_infusion_list[i].comment_modified_ind=1))
      CALL updatelongtext(ib_event_struct->comment_long_text_id,dnextibeventid,ib_event_struct->
       infusion_billing_event_id,request->modified_infusion_list[i].comment,dlongtextid)
     ENDIF
     UPDATE  FROM infusion_billing_event ibe
      SET ibe.infusion_start_dt_tm = cnvtdatetime(request->modified_infusion_list[i].
        infuse_start_dt_tm), ibe.infusion_start_tz = request->modified_infusion_list[i].
       infuse_start_tz, ibe.infusion_end_dt_tm = cnvtdatetime(request->modified_infusion_list[i].
        infuse_end_dt_tm),
       ibe.infusion_end_tz = request->modified_infusion_list[i].infuse_end_tz, ibe.create_prsnl_id =
       request->modified_infusion_list[i].prsnl_id, ibe.comment_long_text_id = dlongtextid,
       ibe.begin_effective_dt_tm = cnvtdatetime(curdate,curtime3), ibe.end_effective_dt_tm =
       cnvtdatetime("31-DEC-2100 00:00:00"), ibe.active_ind = 1,
       ibe.updt_applctx = reqinfo->updt_applctx, ibe.updt_cnt = 0, ibe.updt_dt_tm = cnvtdatetime(
        curdate,curtime3),
       ibe.updt_id = reqinfo->updt_id, ibe.updt_task = reqinfo->updt_task, ibe.infusion_duration_mins
        = request->modified_infusion_list[i].infusion_duration_mins,
       ibe.infused_volume_value = request->modified_infusion_list[i].infused_volume_value
      WHERE (ibe.infusion_billing_event_id=ib_event_struct->infusion_billing_event_id)
      WITH nocounter
     ;end update
     CALL checkforerrors("Failed to update infusion event",1)
     CALL updateibclinevents(dnextibeventid,request->modified_infusion_list[i].
      infusion_billing_event_id,i)
     IF ((request->debug_ind=1))
      CALL echo(build("********UpdateInfusions -> Done updating IB id: ",request->
        modified_infusion_list[i].infusion_billing_event_id))
     ENDIF
   ENDFOR
   IF ((request->debug_ind=1))
    CALL echo(build("********Exiting UpdateInfusions******** iModifiedInfuseCnt = ",
      imodifiedinfusecnt))
   ENDIF
 END ;Subroutine
 SUBROUTINE inactivateinfusions(null)
   IF ((request->debug_ind=1))
    CALL echo("********Entering InactivateInfusions********")
   ENDIF
   DECLARE dnextibeventid = f8 WITH protect, noconstant(0)
   DECLARE dlongtextid = f8 WITH protect, noconstant(0)
   DECLARE iremoveinfusecnt = i4 WITH protect, noconstant(0)
   DECLARE i = i4 WITH protect, noconstant(0)
   SET iremoveinfusecnt = size(request->removed_infusion_list,5)
   FOR (i = 1 TO iremoveinfusecnt)
     IF ((request->debug_ind=1))
      CALL echo(build("********InactivateInfusions -> Inactivating infusion_billing_event_id: ",
        request->removed_infusion_list[i].infusion_billing_event_id))
     ENDIF
     SELECT INTO "nl:"
      dnextseqnum = seq(medadmin_seq,nextval)
      FROM dual
      DETAIL
       dnextibeventid = dnextseqnum
      WITH nocounter
     ;end select
     CALL checkforerrors("Failed to create infusion_billing_event_id",1)
     CALL resetibeventstruct(null)
     SELECT INTO "nl:"
      FROM infusion_billing_event ibe
      WHERE (ibe.infusion_billing_event_id=request->removed_infusion_list[i].
      infusion_billing_event_id)
      DETAIL
       ib_event_struct->infusion_billing_event_id = ibe.infusion_billing_event_id, ib_event_struct->
       prev_infusion_billing_event_id = ibe.prev_infusion_billing_event_id, ib_event_struct->
       encntr_id = ibe.encntr_id,
       ib_event_struct->order_id = ibe.order_id, ib_event_struct->infuse_start_dt_tm = ibe
       .infusion_start_dt_tm, ib_event_struct->infuse_start_tz = ibe.infusion_start_tz,
       ib_event_struct->infuse_end_dt_tm = ibe.infusion_end_dt_tm, ib_event_struct->infuse_end_tz =
       ibe.infusion_end_tz, ib_event_struct->create_prsnl_id = ibe.create_prsnl_id,
       ib_event_struct->comment_long_text_id = ibe.comment_long_text_id, ib_event_struct->
       begin_effective_dt_tm = ibe.begin_effective_dt_tm, ib_event_struct->updt_id = ibe.updt_id,
       ib_event_struct->updt_cnt = ibe.updt_cnt, ib_event_struct->updt_task = ibe.updt_task,
       ib_event_struct->updt_applctx = ibe.updt_applctx,
       ib_event_struct->infusion_duration_mins = ibe.infusion_duration_mins, ib_event_struct->
       infused_volume_value = ibe.infused_volume_value
      WITH nocounter
     ;end select
     CALL checkforerrors("i_b_event_id not found",1)
     IF ((request->debug_ind=1))
      CALL echo(build("********InactivateInfusions -> Inserting new infusion_billing_event_id : ",
        dnextibeventid))
     ENDIF
     INSERT  FROM infusion_billing_event ibe
      SET ibe.infusion_billing_event_id = dnextibeventid, ibe.prev_infusion_billing_event_id =
       ib_event_struct->prev_infusion_billing_event_id, ibe.encntr_id = ib_event_struct->encntr_id,
       ibe.order_id = ib_event_struct->order_id, ibe.infusion_start_dt_tm = cnvtdatetime(
        ib_event_struct->infuse_start_dt_tm), ibe.infusion_start_tz = ib_event_struct->
       infuse_start_tz,
       ibe.infusion_end_dt_tm = cnvtdatetime(ib_event_struct->infuse_end_dt_tm), ibe.infusion_end_tz
        = ib_event_struct->infuse_end_tz, ibe.create_prsnl_id = ib_event_struct->create_prsnl_id,
       ibe.comment_long_text_id = ib_event_struct->comment_long_text_id, ibe.begin_effective_dt_tm =
       cnvtdatetime(ib_event_struct->begin_effective_dt_tm), ibe.end_effective_dt_tm = cnvtdatetime(
        curdate,curtime3),
       ibe.active_ind = 0, ibe.updt_applctx = ib_event_struct->updt_applctx, ibe.updt_cnt = (
       ib_event_struct->updt_cnt+ 1),
       ibe.updt_dt_tm = cnvtdatetime(curdate,curtime3), ibe.updt_id = ib_event_struct->updt_id, ibe
       .updt_task = ib_event_struct->updt_task,
       ibe.infusion_duration_mins = ib_event_struct->infusion_duration_mins, ibe.infused_volume_value
        = ib_event_struct->infused_volume_value
      WITH nocounter
     ;end insert
     UPDATE  FROM infusion_billing_event ibe
      SET ibe.begin_effective_dt_tm = cnvtdatetime(curdate,curtime3), ibe.end_effective_dt_tm =
       cnvtdatetime(curdate,curtime3), ibe.active_ind = 0,
       ibe.updt_cnt = (ibe.updt_cnt+ 1), ibe.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WHERE (ibe.infusion_billing_event_id=request->removed_infusion_list[i].
      infusion_billing_event_id)
      WITH nocounter
     ;end update
     CALL checkforerrors("Failed to inactivate infusion event",1)
     IF ((request->debug_ind=1))
      CALL echo(build(
        "********InactivateInfusions -> Inactivating IB CE. infusion_billing_event_id: ",request->
        removed_infusion_list[i].infusion_billing_event_id))
     ENDIF
     UPDATE  FROM infusion_ce_reltn icr
      SET icr.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), icr.active_ind = 0, icr.updt_cnt
        = (icr.updt_cnt+ 1),
       icr.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WHERE (icr.infusion_billing_event_id=request->removed_infusion_list[i].
      infusion_billing_event_id)
      WITH nocounter
     ;end update
     SET dlongtextid = 0
     SELECT INTO "nl:"
      FROM infusion_billing_event ibe
      WHERE (ibe.infusion_billing_event_id=request->removed_infusion_list[i].
      infusion_billing_event_id)
      DETAIL
       dlongtextid = ibe.comment_long_text_id
      WITH nocounter
     ;end select
     IF (dlongtextid > 0)
      IF ((request->debug_ind=1))
       CALL echo(build("********InactivateInfusions -> Inactivating comment_long_text_id: ",
         dlongtextid))
      ENDIF
      UPDATE  FROM long_text lt
       SET lt.active_ind = 0, lt.active_status_cd = reqdata->inactive_status_cd, lt.updt_cnt = (lt
        .updt_cnt+ 1),
        lt.updt_dt_tm = cnvtdatetime(curdate,curtime3)
       WHERE lt.long_text_id=dlongtextid
       WITH nocounter
      ;end update
      CALL checkforerrors("Failed to inactivate long_text",1)
     ENDIF
   ENDFOR
   IF ((request->debug_ind=1))
    CALL echo(build("********Exiting InactivateInfusions******** iRemoveInfuseCnt = ",
      iremoveinfusecnt))
   ENDIF
 END ;Subroutine
 SUBROUTINE insertibclinevents(iinfusionactionflag,dinfusionbillingeventid,iinfusionidx)
   IF ((request->debug_ind=1))
    CALL echo("********Entering InsertIBClinEvents********")
    CALL echo(build("**iInfusionActionFlag     = ",iinfusionactionflag))
    CALL echo(build("**dInfusionBillingEventId = ",dinfusionbillingeventid))
    CALL echo(build("**iInfusionIdx            = ",iinfusionidx))
   ENDIF
   DECLARE iinfusioncnt = i4 WITH protect, noconstant(0)
   DECLARE ieventcnt = i4 WITH protect, noconstant(0)
   DECLARE dnextibcereltnid = f8 WITH protect, noconstant(0)
   DECLARE dclinicaleventid = f8 WITH protect, noconstant(0)
   DECLARE iclinicaleventseq = i4 WITH protect, noconstant(0)
   DECLARE i = i4 WITH protect, noconstant(0)
   IF (iinfusionactionflag=new_infusion)
    SET iinfusioncnt = size(request->new_infusion_list,5)
   ELSEIF (iinfusionactionflag=mod_infusion)
    SET iinfusioncnt = size(request->modified_infusion_list,5)
   ELSE
    RETURN
   ENDIF
   IF (((dinfusionbillingeventid <= 0) OR (((iinfusionidx <= 0) OR (iinfusionidx > iinfusioncnt)) ))
   )
    RETURN
   ENDIF
   IF (iinfusionactionflag=new_infusion)
    SET ieventcnt = size(request->new_infusion_list[iinfusionidx].event_list,5)
   ELSEIF (iinfusionactionflag=mod_infusion)
    SET ieventcnt = size(request->modified_infusion_list[iinfusionidx].event_list,5)
   ENDIF
   FOR (i = 1 TO ieventcnt)
     SELECT INTO "nl:"
      dnextseqnum = seq(medadmin_seq,nextval)
      FROM dual
      DETAIL
       dnextibcereltnid = dnextseqnum
      WITH nocounter
     ;end select
     CALL checkforerrors("Failed to create infusion_ce_reltn_id",1)
     IF ((request->debug_ind=1))
      CALL echo(build("********InsertIBClinEvents -> Inserting infusion_ce_reltn_id : ",
        dnextibeventid))
     ENDIF
     IF (iinfusionactionflag=new_infusion)
      SET dclinicaleventid = request->new_infusion_list[iinfusionidx].event_list[i].clinical_event_id
      SET iclinicaleventseq = request->new_infusion_list[iinfusionidx].event_list[i].
      clinical_event_seq
     ELSEIF (iinfusionactionflag=mod_infusion)
      SET dclinicaleventid = request->modified_infusion_list[iinfusionidx].event_list[i].
      clinical_event_id
      SET iclinicaleventseq = request->modified_infusion_list[iinfusionidx].event_list[i].
      clinical_event_seq
     ENDIF
     INSERT  FROM infusion_ce_reltn icr
      SET icr.infusion_ce_reltn_id = dnextibcereltnid, icr.prev_infusion_ce_reltn_id =
       dnextibcereltnid, icr.infusion_billing_event_id = dinfusionbillingeventid,
       icr.clinical_event_id = dclinicaleventid, icr.clinical_event_seq = iclinicaleventseq, icr
       .begin_effective_dt_tm = cnvtdatetime(curdate,curtime3),
       icr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"), icr.active_ind = 1, icr
       .updt_applctx = reqinfo->updt_applctx,
       icr.updt_cnt = 0, icr.updt_dt_tm = cnvtdatetime(curdate,curtime3), icr.updt_id = reqinfo->
       updt_id,
       icr.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     CALL checkforerrors("Failed to insert infusion_ce_reltn",1)
   ENDFOR
   IF ((request->debug_ind=1))
    CALL echo("********Exiting InsertIBClinEvents********")
   ENDIF
 END ;Subroutine
 SUBROUTINE updateibclinevents(dprevibeventid,dcurribeventid,iinfusionidx)
   IF ((request->debug_ind=1))
    CALL echo("********Entering InactivateIBClinEvents********")
    CALL echo(build("**dPrevIBEventId = ",dprevibeventid))
    CALL echo(build("**dCurrIBEventId = ",dcurribeventid))
    CALL echo(build("**iInfusionIdx   = ",iinfusionidx))
   ENDIF
   DECLARE iinfusecnt = i4 WITH protect, noconstant(0)
   DECLARE ieventcnt = i4 WITH protect, noconstant(0)
   DECLARE dnextibcereltnid = f8 WITH protect, noconstant(0)
   DECLARE iqualcnt = i4 WITH protect, noconstant(0)
   DECLARE iterator = i4 WITH protect, noconstant(0)
   DECLARE istat = i2 WITH protect, noconstant(0)
   DECLARE i = i4 WITH protect, noconstant(0)
   SET iinfusecnt = size(request->modified_infusion_list,5)
   IF (((dprevibeventid <= 0) OR (((dcurribeventid <= 0) OR (((iinfusionidx <= 0) OR (iinfusionidx >
   iinfusecnt)) )) )) )
    ROLLBACK
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus.targetobjectname = "UpdateIBClinEvents"
    SET reply->status_data.subeventstatus.targetobjectvalue =
    "InactivateIBClinEvents - Invalid parameters"
    GO TO exit_script
   ENDIF
   UPDATE  FROM infusion_ce_reltn icr
    SET icr.infusion_billing_event_id = dprevibeventid, icr.end_effective_dt_tm = cnvtdatetime(
      curdate,curtime3), icr.active_ind = 0,
     icr.updt_cnt = (icr.updt_cnt+ 1), icr.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE icr.infusion_billing_event_id=dcurribeventid
     AND icr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    WITH nocounter
   ;end update
   CALL checkforerrors("Failed to update infusion_ce_reltn",1)
   CALL insertibclinevents(mod_infusion,dcurribeventid,iinfusionidx)
   IF ((request->debug_ind=1))
    CALL echo("********Exiting UpdateIBClinEvents********")
   ENDIF
 END ;Subroutine
 SUBROUTINE insertlongtext(dparententityid,slongtext,dlongtextid)
   IF ((request->debug_ind=1))
    CALL echo("********Entering InsertLongText********")
    CALL echo(build("**dParentEntityId = ",dparententityid))
    CALL echo(build("**sLongText       = ",slongtext))
   ENDIF
   SET dlongtextid = 0
   IF (((dparententityid <= 0) OR (textlen(trim(slongtext,3)) <= 0)) )
    RETURN
   ENDIF
   SELECT INTO "nl:"
    dnextseqnum = seq(long_data_seq,nextval)
    FROM dual
    DETAIL
     dlongtextid = dnextseqnum
    WITH nocounter
   ;end select
   CALL checkforerrors("Failed to create long_text_id.",1)
   INSERT  FROM long_text lt
    SET lt.long_text_id = dlongtextid, lt.parent_entity_name = "INFUSION_BILLING_EVENT", lt
     .parent_entity_id = dparententityid,
     lt.long_text = slongtext, lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd,
     lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
     updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
     lt.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   CALL checkforerrors("Failed to insert long_text",1)
   IF ((request->debug_ind=1))
    CALL echo(build("********Exiting InsertLongText******** dLongTextId = ",dlongtextid))
   ENDIF
 END ;Subroutine
 SUBROUTINE updatelongtext(dprevlongtextid,dprevparententityid,dcurrparententityid,slongtext,
  dcurrlongtextid)
   IF ((request->debug_ind=1))
    CALL echo("********Entering UpdateLongText********")
    CALL echo(build("**dPrevLongTextId     = ",dprevlongtextid))
    CALL echo(build("**dPrevParentEntityId = ",dprevparententityid))
    CALL echo(build("**dCurrParentEntityId = ",dcurrparententityid))
    CALL echo(build("**sLongText           = ",slongtext))
   ENDIF
   IF (dprevlongtextid > 0)
    UPDATE  FROM long_text lt
     SET lt.parent_entity_id = dprevparententityid, lt.active_ind = 0, lt.active_status_cd = reqdata
      ->inactive_status_cd,
      lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WHERE lt.long_text_id=dprevlongtextid
     WITH nocounter
    ;end update
    CALL checkforerrors("Failed to update long_text",1)
   ENDIF
   CALL insertlongtext(dcurrparententityid,slongtext,dcurrlongtextid)
   IF ((request->debug_ind=1))
    CALL echo(build("********Exiting UpdateLongText******** dCurrLongTextId = ",dcurrlongtextid))
   ENDIF
 END ;Subroutine
 SUBROUTINE resetibeventstruct(null)
   SET ib_event_struct->infusion_billing_event_id = 0
   SET ib_event_struct->prev_infusion_billing_event_id = 0
   SET ib_event_struct->encntr_id = 0
   SET ib_event_struct->order_id = 0
   SET ib_event_struct->infuse_start_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ib_event_struct->infuse_start_tz = 0
   SET ib_event_struct->infuse_end_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ib_event_struct->infuse_end_tz = 0
   SET ib_event_struct->create_prsnl_id = 0
   SET ib_event_struct->comment_long_text_id = 0
   SET ib_event_struct->begin_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ib_event_struct->updt_cnt = 0
   SET ib_event_struct->infusion_duration_mins = 0
   SET ib_event_struct->infused_volume_value = 0
 END ;Subroutine
 SUBROUTINE checkforerrors(serrmsg,bcheckcurqual)
   SET errcode = error(errmsg,1)
   IF (errcode > 0)
    ROLLBACK
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus.targetobjectvalue = concat(serrmsg," - ",errmsg)
    GO TO exit_script
   ENDIF
   IF (bcheckcurqual=1
    AND curqual=0)
    ROLLBACK
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus.targetobjectvalue = serrmsg
    GO TO exit_script
   ENDIF
 END ;Subroutine
#exit_script
 IF ((request->debug_ind != 1))
  FREE SET ib_event_struct
  FREE SET ib_ce_reltn
 ENDIF
 SET last_mod = "001"
 SET mod_date = "11/20/2009"
 SET modify = nopredeclare
END GO
