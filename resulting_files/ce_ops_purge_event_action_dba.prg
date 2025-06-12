CREATE PROGRAM ce_ops_purge_event_action:dba
 RECORD reply(
   1 ops_event = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD prsnl
 RECORD prsnl(
   1 prsnl_list[*]
     2 prsnl_id = f8
     2 records_purged = i4
     2 event_action[*]
       3 ce_event_action_id = f8
 )
 DECLARE purgeresults(null) = null
 DECLARE writeerror(providerid=f8,errordisplay=vc) = null
 DECLARE writeloginfo(providerid=f8,numpurged=i4) = null
 DECLARE writelogcriteria(null) = null
 DECLARE prepareprsnllist(null) = null
 DECLARE now = f8 WITH constant(cnvtdatetime(curdate,curtime3))
 DECLARE begin_dt_tm = f8
 DECLARE days_back = i4 WITH noconstant(0)
 DECLARE prsnl_cnt = i4 WITH noconstant(0)
 DECLARE prsnl_record_cnt = i4 WITH noconstant(0)
 DECLARE prsnlcnt = i4 WITH noconstant(0)
 DECLARE prsnlsize = i4 WITH noconstant(0)
 DECLARE endorse = f8 WITH constant(uar_get_code_by("MEANING",4001982,"ENDORSE"))
 DECLARE failed_ind = i2 WITH noconstant(0)
 DECLARE ce_emsg = vc WITH noconstant("")
 DECLARE ce_ecode = i4 WITH noconstant(0)
 DECLARE prsnllistidx = i4 WITH noconstant(1)
 DECLARE where1 = c132 WITH protect, noconstant("1 = 0")
 DECLARE months_back = i4 WITH noconstant(0)
 DECLARE purgemonth = i4 WITH noconstant(0)
 DECLARE purgeyear = i4 WITH noconstant(0)
 DECLARE purgeday = i4 WITH noconstant(0)
 DECLARE purgemonth_str = vc WITH protect, noconstant(" ")
 DECLARE purgeday_str = vc WITH protect, noconstant(" ")
 DECLARE errmsg = vc WITH protect, noconstant(" ")
 DECLARE days = vc WITH protect, constant("DAYS")
 DECLARE months = vc WITH protect, constant("MONTHS")
 DECLARE txops1 = i4 WITH protect, noconstant(0)
 DECLARE txops_batch = vc WITH protect, noconstant(" ")
 DECLARE txops_value = vc WITH protect, noconstant(" ")
 DECLARE txops_unit = vc WITH protect, noconstant(" ")
 DECLARE batch_size = i4 WITH constant(100)
 DECLARE nstart = i4 WITH noconstant(0)
 DECLARE loop_cnt = i4 WITH noconstant(0)
 DECLARE eventactionsize = i4 WITH noconstant(0)
 DECLARE paddedlistsize = i4 WITH noconstant(0)
 DECLARE tempidx = i4 WITH noconstant(0)
 DECLARE maxloopcnt = i4 WITH noconstant(0)
 DECLARE startexpandidx = i4 WITH noconstant(1)
 DECLARE expandidx = i4 WITH noconstant(0)
 SET txops_batch = trim(request->batch_selection,3)
 SET txops1 = findstring(",",txops_batch,1)
 IF (txops1 > 0)
  SET txops_value = trim(cnvtupper(substring(1,(txops1 - 1),txops_batch)))
 ELSE
  SET reply->ops_event = "Invalid parameter string.  Format: VALUE,UNIT.  Example: 5,MONTHS"
  SET failed_ind = 1
  GO TO exit_script
 ENDIF
 SET txops_unit = trim(cnvtupper(substring((txops1+ 1),size(txops_batch,1),txops_batch)))
 IF (txops_unit=days)
  SET days_back = cnvtint(txops_value)
  IF (days_back=0)
   SET reply->ops_event = "Invalid parameter string: 0 is not an allowed value; Must be a digit > 0"
   SET failed_ind = 1
   GO TO exit_script
  ENDIF
  SET begin_dt_tm = datetimeadd(now,- (days_back))
 ELSEIF (txops_unit=months)
  SET months_back = cnvtint(txops_value)
  IF (months_back=0)
   SET reply->ops_event = "Invalid parameter string: 0 is not an allowed value; Must be a digit > 0"
   SET failed_ind = 1
   GO TO exit_script
  ENDIF
  SET purgemonth = month(curdate)
  SET purgeyear = year(curdate)
  SET purgeday = day(curdate)
  IF (months_back > 12)
   SET purgeyear = (purgeyear - ceil((months_back/ 12)))
   SET months_back = (months_back - (12 * ceil((months_back/ 12))))
  ENDIF
  IF (purgemonth <= months_back)
   SET purgemonth = (purgemonth+ 12)
   SET purgemonth = (purgemonth - months_back)
   SET purgeyear = (purgeyear - 1)
  ELSE
   SET purgemonth = (purgemonth - months_back)
  ENDIF
  IF (purgemonth=2
   AND purgeday > 28)
   SET purgeday = 28
  ELSEIF (purgeday > 30)
   SET purgeday = 30
  ENDIF
  IF (purgemonth < 10)
   SET purgemonth_str = build("0",cnvtstring(purgemonth))
  ELSE
   SET purgemonth_str = cnvtstring(purgemonth)
  ENDIF
  IF (purgeday < 10)
   SET purgeday_str = build("0",cnvtstring(purgeday))
  ELSE
   SET purgeday_str = cnvtstring(purgeday)
  ENDIF
  SET b_dt = concat(trim(purgemonth_str),trim(purgeday_str),trim(cnvtstring(purgeyear)))
  SET begin_dt_tm = cnvtdatetime(cnvtdate(b_dt),0)
 ELSE
  SET reply->ops_event = "Invalid unit parameter.  Accepted values: "
  SET reply->ops_event = build(reply->ops_event,days)
  SET reply->ops_event = build(reply->ops_event,",")
  SET reply->ops_event = build(reply->ops_event,months)
  SET failed_ind = 1
  GO TO exit_script
 ENDIF
 IF (trim(request->output_dist) != "")
  SET failed_ind = 0
  SET reply->ops_event = concat("Purge report written successfully to file ",request->output_dist)
 ELSE
  SET reply->ops_event =
  "Purge report failed because there was not a file chosen.  Purge did NOT occur."
  SET failed_ind = 1
  GO TO exit_script
 ENDIF
 CALL purgeresults(null)
 COMMIT
 SUBROUTINE purgeresults(null)
   SELECT INTO "nl:"
    FROM ce_event_action cea
    WHERE cea.updt_dt_tm < cnvtdatetime(begin_dt_tm)
     AND cea.ce_event_action_id > 0
    ORDER BY cea.action_prsnl_id
    HEAD REPORT
     prsnl_cnt = 0
    HEAD cea.action_prsnl_id
     prsnl_record_cnt = 0, prsnl_cnt = (prsnl_cnt+ 1)
     IF (prsnl_cnt > size(prsnl->prsnl_list,5))
      stat = alterlist(prsnl->prsnl_list,(prsnl_cnt+ 5))
     ENDIF
     prsnl->prsnl_list[prsnl_cnt].prsnl_id = cea.action_prsnl_id
    DETAIL
     prsnl_record_cnt = (prsnl_record_cnt+ 1)
     IF (prsnl_record_cnt > size(prsnl->prsnl_list[prsnl_cnt].event_action,5))
      stat = alterlist(prsnl->prsnl_list[prsnl_cnt].event_action,(prsnl_record_cnt+ 5))
     ENDIF
     prsnl->prsnl_list[prsnl_cnt].event_action[prsnl_record_cnt].ce_event_action_id = cea
     .ce_event_action_id
    FOOT  cea.action_prsnl_id
     prsnl->prsnl_list[prsnl_cnt].records_purged = prsnl_record_cnt, stat = alterlist(prsnl->
      prsnl_list[prsnl_cnt].event_action,prsnl_record_cnt)
    FOOT REPORT
     stat = alterlist(prsnl->prsnl_list,prsnl_cnt)
    WITH nocounter
   ;end select
   SET prsnlsize = prsnl_cnt
   CALL prepareprsnllist(null)
   CALL writelogcriteria(null)
   FOR (idx = 1 TO prsnl_cnt)
     SET eventactionsize = size(prsnl->prsnl_list[idx].event_action,5)
     SET paddedlistsize = (ceil((cnvtreal(eventactionsize)/ batch_size)) * batch_size)
     SET stat = alterlist(prsnl->prsnl_list[idx].event_action,paddedlistsize)
     SET maxloopcnt = (paddedlistsize/ batch_size)
     FOR (tempidx = (eventactionsize+ 1) TO paddedlistsize)
       SET prsnl->prsnl_list[idx].event_action[tempidx].ce_event_action_id = prsnl->prsnl_list[idx].
       event_action[eventactionsize].ce_event_action_id
     ENDFOR
     DELETE  FROM ce_prcs_queue cpq,
       (dummyt d  WITH seq = value(maxloopcnt))
      SET cpq.seq = 1
      PLAN (d
       WHERE initarray(startexpandidx,evaluate(d.seq,1,1,(startexpandidx+ batch_size))))
       JOIN (cpq
       WHERE expand(expandidx,startexpandidx,(startexpandidx+ (batch_size - 1)),cpq
        .ce_event_action_id,prsnl->prsnl_list[idx].event_action[expandidx].ce_event_action_id)
        AND cpq.queue_type_cd=endorse)
      WITH nocounter
     ;end delete
     SET ce_ecode = error(ce_emsg,1)
     IF (ce_ecode != 0)
      ROLLBACK
      SET reply->ops_event = "Failed during purge to CE_PRCS_QUEUE row"
      SET failed_ind = 1
      CALL writeerror(prsnl->prsnl_list[idx].prsnl_id,"Failed during purge to CE_PRCS_QUEUE row")
     ENDIF
     DELETE  FROM ce_rte_prsnl_reltn crpr,
       (dummyt d  WITH seq = value(maxloopcnt))
      SET crpr.seq = 1
      PLAN (d
       WHERE initarray(startexpandidx,evaluate(d.seq,1,1,(startexpandidx+ batch_size))))
       JOIN (crpr
       WHERE expand(expandidx,startexpandidx,(startexpandidx+ (batch_size - 1)),crpr
        .ce_event_action_id,prsnl->prsnl_list[idx].event_action[expandidx].ce_event_action_id))
      WITH nocounter
     ;end delete
     SET ce_ecode = error(ce_emsg,1)
     IF (ce_ecode != 0)
      ROLLBACK
      SET reply->ops_event = "Failed during purge to CE_RTE_PRSNL_RELTN row"
      SET failed_ind = 1
      CALL writeerror(prsnl->prsnl_list[idx].prsnl_id,"Failed during purge to CE_RTE_PRSNL_RELTN row"
       )
     ENDIF
     DELETE  FROM ce_event_action cea,
       (dummyt d  WITH seq = value(maxloopcnt))
      SET cea.seq = 1
      PLAN (d
       WHERE initarray(startexpandidx,evaluate(d.seq,1,1,(startexpandidx+ batch_size))))
       JOIN (cea
       WHERE expand(expandidx,startexpandidx,(startexpandidx+ (batch_size - 1)),cea
        .ce_event_action_id,prsnl->prsnl_list[idx].event_action[expandidx].ce_event_action_id))
      WITH nocounter
     ;end delete
     SET ce_ecode = error(ce_emsg,1)
     IF (ce_ecode != 0)
      ROLLBACK
      SET reply->ops_event = "Failed during purge to CE_EVENT_ACTION row"
      SET failed_ind = 1
      CALL writeerror(prsnl->prsnl_list[idx].prsnl_id,"Failed during purge to CE_EVENT_ACTION row")
     ELSE
      CALL writeloginfo(prsnl->prsnl_list[idx].prsnl_id,prsnl->prsnl_list[idx].records_purged)
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE prepareprsnllist(null)
   DECLARE idx = i4 WITH noconstant(0)
   DECLARE new_list_size = i4 WITH noconstant(0)
   SET nstart = 1
   SET loop_cnt = ceil((cnvtreal(prsnlsize)/ batch_size))
   SET new_list_size = (loop_cnt * batch_size)
   SET stat = alterlist(prsnl->prsnl_list,new_list_size)
   IF (new_list_size > prsnlsize)
    FOR (idx = (prsnlsize+ 1) TO new_list_size)
      SET prsnl->prsnl_list[idx].prsnl_id = prsnl->prsnl_list[prsnlsize].prsnl_id
    ENDFOR
   ENDIF
   IF (loop_cnt=0)
    SET loop_cnt = 1
   ELSE
    SET where1 = "expand(prsnlListIdx, nstart, nstart+(batch_size-1),p.person_id,"
    SET where1 = build(where1," prsnl->prsnl_list[prsnlListIdx]->prsnl_id)")
   ENDIF
 END ;Subroutine
 SUBROUTINE writeerror(providerid,errordisplay)
  SELECT INTO request->output_dist
   FROM prsnl p
   WHERE p.person_id=providerid
   DETAIL
    row + 1, col 0, "***********************************************************************",
    row + 1, col 0, "ERROR:",
    row + 1, errsize = size(ce_emsg,1), errcnt = errsize,
    estart = 0, estop = 0, batchsize = 75
    IF (errsize > batchsize)
     WHILE (errcnt > 0)
       estart = (estop+ 1)
       IF (errcnt < batchsize)
        batchsize = errcnt
       ENDIF
       estop = (estop+ batchsize), errcnt = (errcnt - batchsize), errmsg = substring(estart,batchsize,
        ce_emsg),
       col 0, errmsg, row + 1
     ENDWHILE
    ELSE
     errmsg = trim(ce_emsg), col 0, errmsg,
     row + 1
    ENDIF
    row + 1, col 0, errordisplay,
    row + 1, col 0, "PROVIDER ID: ",
    col 13, p.person_id, row + 1,
    col 0, "PROVIDER NAME: ", nff = substring(1,50,p.name_full_formatted),
    col 16, nff, row + 1,
    col 0, "***********************************************************************", row + 1
   WITH append
  ;end select
  GO TO exit_script
 END ;Subroutine
 SUBROUTINE writelogcriteria(null)
  SET prsnlcnt = 0
  SELECT INTO request->output_dist
   p.person_id, p.name_full_formatted
   FROM (dummyt d  WITH seq = value(loop_cnt)),
    prsnl p
   PLAN (d
    WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
    JOIN (p
    WHERE parser(where1))
   ORDER BY p.name_last_key
   HEAD REPORT
    col 0, "*************************************************************", row + 1,
    col 0,
    "  CE EVENT ACTION, CE_PRCS_QUEUE and CE_RTE_PRSNL_RELTN Rows older than the Start Date will be purged",
    row + 1,
    startdttmstr = format(begin_dt_tm,";;Q"), col 5, "Start Date Time:",
    col 31, startdttmstr, row + 1,
    col 5, "Providers:", row + 1
   DETAIL
    col 10, p.name_full_formatted, row + 1
   FOOT REPORT
    row + 1, col 0, "Providers Successfully Updated Are Listed Below",
    row + 1, col 0, "******************************************************",
    row + 2, col 0, "CNT",
    col 10, "ROWS PURGED", col 25,
    "PROVIDER NAME", row + 1, col 0,
    "---", col 10, "-----------",
    col 25, "----------------------------", row + 1
   WITH append
  ;end select
 END ;Subroutine
 SUBROUTINE writeloginfo(providerid,numpurged)
   IF ( NOT (providerid))
    SELECT INTO request->output_dist
     FROM dual
     DETAIL
      col 0, "******************************************************", row + 1,
      col 0, "No Providers Found.", row + 1,
      col 0, "******************************************************"
     WITH append
    ;end select
   ELSE
    SELECT INTO request->output_dist
     FROM prsnl p
     WHERE (p.person_id=prsnl->prsnl_list[idx].prsnl_id)
     DETAIL
      idxstr = trim(build(idx)), col 0, idxstr,
      numstr = trim(build(numpurged)), col 10, numstr,
      nffstr = substring(1,40,p.name_full_formatted), col 25, nffstr
     WITH append
    ;end select
   ENDIF
 END ;Subroutine
#exit_script
 IF (failed_ind=0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
END GO
