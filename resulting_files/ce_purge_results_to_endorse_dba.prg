CREATE PROGRAM ce_purge_results_to_endorse:dba
 PROMPT
  "Output to MINE:" = "MINE",
  "Select Start Date Time:" = "CURDATE",
  "Select End Date Time:" = "CURDATE",
  "Select Type of Purge:" = 0,
  "Select Providers:" = 0,
  "Select Pool Ids" = 0
  WITH outdev, startdttm, enddttm,
  type, provider, pool
 FREE RECORD prsnl
 RECORD prsnl(
   1 prsnl_list[*]
     2 prsnl_id = f8
 )
 FREE RECORD prsnl_group
 RECORD prsnl_group(
   1 prsnl_group_list[*]
     2 prsnl_group_id = f8
 )
 FREE RECORD temp_rec
 RECORD temp_rec(
   1 event_action[*]
     2 ce_event_action_id = f8
 )
 DECLARE prsnlcnt = i4 WITH noconstant(0)
 DECLARE prsnlsize = i4 WITH noconstant(0)
 DECLARE prsnlgroupcnt = i4 WITH noconstant(0)
 DECLARE prsnlgroupsize = i4 WITH noconstant(0)
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE ireturn = i4 WITH noconstant(0)
 DECLARE ce_emsg = vc WITH noconstant("")
 DECLARE ce_ecode = i4 WITH noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant(" ")
 DECLARE startdttm = q8 WITH noconstant(cnvtdatetimeutc("01-JAN-1800"))
 DECLARE enddttm = q8 WITH noconstant(cnvtdatetimeutc("01-JAN-1800"))
 DECLARE count = i4 WITH noconstant(0)
 DECLARE endorse = f8 WITH constant(uar_get_code_by("MEANING",4001982,"ENDORSE"))
 DECLARE paddedlistsize = i4 WITH noconstant(0)
 DECLARE tempidx = i4 WITH noconstant(0)
 DECLARE maxloopcnt = i4 WITH noconstant(0)
 DECLARE startexpandidx = i4 WITH noconstant(1)
 DECLARE expandidx = i4 WITH noconstant(0)
 DECLARE batch_size = i4 WITH constant(100)
 DECLARE writelogcriteria(null) = null
 IF (( $TYPE=1))
  CALL writeerror(0.0,"The purge by position_cd workflow is no longer supported.")
  GO TO exit_script
 ENDIF
 SET startdttm = cnvtdatetime( $STARTDTTM)
 SET enddttm = cnvtdatetime( $ENDDTTM)
 IF (startdttm > enddttm)
  CALL writeerror(0.0,"Start Date Time should be less than or equal to End Date Time")
 ENDIF
 IF (startdttm=enddttm)
  SET enddttm = datetimeadd(enddttm,1)
 ENDIF
 CASE ( $TYPE)
  OF 2:
   SELECT INTO "nl:"
    p.person_id
    FROM prsnl p
    PLAN (p
     WHERE (p.person_id= $PROVIDER))
    ORDER BY p.name_last_key
    DETAIL
     prsnlsize += 1
     IF (mod(prsnlsize,10)=1)
      stat = alterlist(prsnl->prsnl_list,(prsnlsize+ 9))
     ENDIF
     prsnl->prsnl_list[prsnlsize].prsnl_id = p.person_id
    WITH maxrec = 10
   ;end select
  OF 3:
   SELECT INTO "nl:"
    p.prsnl_group_id
    FROM prsnl_group p
    PLAN (p
     WHERE (p.prsnl_group_id= $POOL))
    ORDER BY p.prsnl_group_name
    DETAIL
     prsnlgroupsize += 1
     IF (mod(prsnlgroupsize,10)=1)
      stat = alterlist(prsnl_group->prsnl_group_list,(prsnlgroupsize+ 9))
     ENDIF
     prsnl_group->prsnl_group_list[prsnlgroupsize].prsnl_group_id = p.prsnl_group_id
    WITH nocounter
   ;end select
  ELSE
   SET donothing = 1
 ENDCASE
 CALL writelogcriteria(null)
 IF ( NOT (prsnlsize)
  AND  NOT (prsnlgroupsize))
  IF (( $TYPE=3))
   CALL writeloginfogroup(0.0,0)
  ELSE
   CALL writeloginfo(0.0,0)
  ENDIF
  GO TO exit_script
 ENDIF
 FOR (idx = 1 TO prsnlsize)
   SET numpurged = purgeresults(prsnl->prsnl_list[idx].prsnl_id)
   CALL writeloginfo(prsnl->prsnl_list[idx].prsnl_id,numpurged)
   COMMIT
 ENDFOR
 FOR (idx = 1 TO prsnlgroupsize)
   SET numpurged = purgeresultsgroup(prsnl_group->prsnl_group_list[idx].prsnl_group_id)
   CALL writeloginfogroup(prsnl_group->prsnl_group_list[idx].prsnl_group_id,numpurged)
   COMMIT
 ENDFOR
 SUBROUTINE (purgeresults(providerid=f8) =i4)
   SET stat = initrec(temp_rec)
   SET count = 0
   SET ireturn = 0
   SELECT INTO "nl:"
    FROM ce_event_action cea
    WHERE cea.action_prsnl_id=providerid
     AND cea.updt_dt_tm >= cnvtdatetime(startdttm)
     AND cea.updt_dt_tm < cnvtdatetime(enddttm)
     AND cea.ce_event_action_id > 0
    HEAD REPORT
     count = 0
    DETAIL
     count += 1
     IF (count > size(temp_rec->event_action,5))
      stat = alterlist(temp_rec->event_action,(count+ 5))
     ENDIF
     temp_rec->event_action[count].ce_event_action_id = cea.ce_event_action_id
    FOOT REPORT
     stat = alterlist(temp_rec->event_action,count)
    WITH nocounter
   ;end select
   IF (count > 0)
    SET paddedlistsize = (ceil((cnvtreal(count)/ batch_size)) * batch_size)
    SET stat = alterlist(temp_rec->event_action,paddedlistsize)
    SET maxloopcnt = (paddedlistsize/ batch_size)
    FOR (tempidx = (count+ 1) TO paddedlistsize)
      SET temp_rec->event_action[tempidx].ce_event_action_id = temp_rec->event_action[count].
      ce_event_action_id
    ENDFOR
    DELETE  FROM ce_prcs_queue cpq,
      (dummyt d  WITH seq = value(maxloopcnt))
     SET cpq.seq = 1
     PLAN (d
      WHERE initarray(startexpandidx,evaluate(d.seq,1,1,(startexpandidx+ batch_size))))
      JOIN (cpq
      WHERE expand(expandidx,startexpandidx,(startexpandidx+ (batch_size - 1)),cpq.ce_event_action_id,
       temp_rec->event_action[expandidx].ce_event_action_id)
       AND cpq.queue_type_cd=endorse)
     WITH nocounter
    ;end delete
    SET ce_ecode = error(ce_emsg,1)
    IF (ce_ecode != 0)
     ROLLBACK
     CALL writeerror(providerid,"Failed during purge to CE_PRCS_QUEUE row")
    ENDIF
    DELETE  FROM ce_rte_prsnl_reltn crpr,
      (dummyt d  WITH seq = value(maxloopcnt))
     SET crpr.seq = 1
     PLAN (d
      WHERE initarray(startexpandidx,evaluate(d.seq,1,1,(startexpandidx+ batch_size))))
      JOIN (crpr
      WHERE expand(expandidx,startexpandidx,(startexpandidx+ (batch_size - 1)),crpr
       .ce_event_action_id,temp_rec->event_action[expandidx].ce_event_action_id))
     WITH nocounter
    ;end delete
    SET ce_ecode = error(ce_emsg,1)
    IF (ce_ecode != 0)
     ROLLBACK
     CALL writeerror(providerid,"Failed during purge to CE_RTE_PRSNL_RELTN row")
    ENDIF
    DELETE  FROM ce_event_action cea,
      (dummyt d  WITH seq = value(maxloopcnt))
     SET cea.seq = 1
     PLAN (d
      WHERE initarray(startexpandidx,evaluate(d.seq,1,1,(startexpandidx+ batch_size))))
      JOIN (cea
      WHERE expand(expandidx,startexpandidx,(startexpandidx+ (batch_size - 1)),cea.ce_event_action_id,
       temp_rec->event_action[expandidx].ce_event_action_id))
     WITH nocounter
    ;end delete
    SET ireturn = curqual
    SET ce_ecode = error(ce_emsg,1)
    IF (ce_ecode != 0)
     ROLLBACK
     CALL writeerror(providerid,"Failed during purge to CE_EVENT_ACTION row")
    ENDIF
   ENDIF
   RETURN(ireturn)
 END ;Subroutine
 SUBROUTINE (purgeresultsgroup(providergroupid=f8) =i4)
   SET stat = initrec(temp_rec)
   SET count = 0
   SET ireturn = 0
   SELECT INTO "nl:"
    FROM ce_event_action cea
    WHERE cea.action_prsnl_group_id=providergroupid
     AND cea.updt_dt_tm >= cnvtdatetime(startdttm)
     AND cea.updt_dt_tm < cnvtdatetime(enddttm)
     AND cea.ce_event_action_id > 0
    HEAD REPORT
     count = 0
    DETAIL
     count += 1
     IF (count > size(temp_rec->event_action,5))
      stat = alterlist(temp_rec->event_action,(count+ 5))
     ENDIF
     temp_rec->event_action[count].ce_event_action_id = cea.ce_event_action_id
    FOOT REPORT
     stat = alterlist(temp_rec->event_action,count)
    WITH nocounter
   ;end select
   IF (count > 0)
    SET paddedlistsize = (ceil((cnvtreal(count)/ batch_size)) * batch_size)
    SET stat = alterlist(temp_rec->event_action,paddedlistsize)
    SET maxloopcnt = (paddedlistsize/ batch_size)
    FOR (tempidx = (count+ 1) TO paddedlistsize)
      SET temp_rec->event_action[tempidx].ce_event_action_id = temp_rec->event_action[count].
      ce_event_action_id
    ENDFOR
    DELETE  FROM ce_prcs_queue cpq,
      (dummyt d  WITH seq = value(maxloopcnt))
     SET cpq.seq = 1
     PLAN (d
      WHERE initarray(startexpandidx,evaluate(d.seq,1,1,(startexpandidx+ batch_size))))
      JOIN (cpq
      WHERE expand(expandidx,startexpandidx,(startexpandidx+ (batch_size - 1)),cpq.ce_event_action_id,
       temp_rec->event_action[expandidx].ce_event_action_id)
       AND cpq.queue_type_cd=endorse)
     WITH nocounter
    ;end delete
    SET ce_ecode = error(ce_emsg,1)
    IF (ce_ecode != 0)
     ROLLBACK
     CALL writeerrorgroup(providergroupid,"Failed during purge to CE_PRCS_QUEUE row")
    ENDIF
    DELETE  FROM ce_rte_prsnl_reltn crpr,
      (dummyt d  WITH seq = value(maxloopcnt))
     SET crpr.seq = 1
     PLAN (d
      WHERE initarray(startexpandidx,evaluate(d.seq,1,1,(startexpandidx+ batch_size))))
      JOIN (crpr
      WHERE expand(expandidx,startexpandidx,(startexpandidx+ (batch_size - 1)),crpr
       .ce_event_action_id,temp_rec->event_action[expandidx].ce_event_action_id))
     WITH nocounter
    ;end delete
    SET ce_ecode = error(ce_emsg,1)
    IF (ce_ecode != 0)
     ROLLBACK
     CALL writeerrorgroup(providergroupid,"Failed during purge to CE_RTE_PRSNL_RELTN row")
    ENDIF
    DELETE  FROM ce_event_action cea,
      (dummyt d  WITH seq = value(maxloopcnt))
     SET cea.seq = 1
     PLAN (d
      WHERE initarray(startexpandidx,evaluate(d.seq,1,1,(startexpandidx+ batch_size))))
      JOIN (cea
      WHERE expand(expandidx,startexpandidx,(startexpandidx+ (batch_size - 1)),cea.ce_event_action_id,
       temp_rec->event_action[expandidx].ce_event_action_id))
     WITH nocounter
    ;end delete
    SET ireturn = curqual
    SET ce_ecode = error(ce_emsg,1)
    IF (ce_ecode != 0)
     ROLLBACK
     CALL writeerrorgroup(providergroupid,"Failed during purge to CE_EVENT_ACTION row")
    ENDIF
   ENDIF
   RETURN(ireturn)
 END ;Subroutine
 SUBROUTINE (writeerror(providerid=f8,errordisplay=vc) =null)
   SELECT INTO  $OUTDEV
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
        estop += batchsize, errcnt -= batchsize, errmsg = substring(estart,batchsize,ce_emsg),
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
   SELECT INTO "ccluserdir:results_to_endorse_purge_log.out"
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
        estop += batchsize, errcnt -= batchsize, errmsg = substring(estart,batchsize,ce_emsg),
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
 SUBROUTINE (writeerrorgroup(providergroupid=f8,errordisplay=vc) =null)
   SELECT INTO  $OUTDEV
    FROM prsnl_group p
    WHERE p.prsnl_group_id=providergroupid
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
        estop += batchsize, errcnt -= batchsize, errmsg = substring(estart,batchsize,ce_emsg),
        col 0, errmsg, row + 1
      ENDWHILE
     ELSE
      errmsg = trim(ce_emsg), col 0, errmsg,
      row + 1
     ENDIF
     row + 1, col 0, errordisplay,
     row + 1, col 0, "PROVIDER GROUP ID: ",
     col 20, p.prsnl_group_id, row + 1,
     col 0, "PROVIDER GROUP NAME: ", nff = substring(1,50,p.prsnl_group_name),
     col 23, nff, row + 1,
     col 0, "***********************************************************************", row + 1
    WITH append
   ;end select
   SELECT INTO "ccluserdir:results_to_endorse_purge_log.out"
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
        estop += batchsize, errcnt -= batchsize, errmsg = substring(estart,batchsize,ce_emsg),
        col 0, errmsg, row + 1
      ENDWHILE
     ELSE
      errmsg = trim(ce_emsg), col 0, errmsg,
      row + 1
     ENDIF
     row + 1, col 0, errordisplay,
     row + 1, col 0, "PROVIDER GROUP ID: ",
     col 20, p.prsnl_group_id, row + 1,
     col 0, "PROVIDER GROUP NAME: ", nff = substring(1,50,p.prsnl_group_name),
     col 23, nff, row + 1,
     col 0, "***********************************************************************", row + 1
    WITH append
   ;end select
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE writelogcriteria(null)
   CASE ( $TYPE)
    OF 2:
     SET prsnlcnt = 0
     SELECT INTO  $OUTDEV
      p.person_id, p.name_full_formatted
      FROM prsnl p
      PLAN (p
       WHERE expand(prsnlcnt,1,prsnlsize,p.person_id,prsnl->prsnl_list[prsnlcnt].prsnl_id))
      ORDER BY p.name_last_key
      HEAD REPORT
       col 0, "******************************************************", row + 1,
       col 0, "Menu Options Selected", row + 1,
       startdttmstr = format(startdttm,";;Q"), col 5, "Start Date Time:",
       col 31, startdttmstr, row + 1,
       enddttmstr = format(enddttm,";;Q"), col 5, "End Date Time:",
       col 31, enddttmstr, row + 1,
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
     SET prsnlcnt = 0
     SELECT INTO "ccluserdir:results_to_endorse_purge_log.dat"
      p.person_id, p.name_full_formatted
      FROM prsnl p
      PLAN (p
       WHERE expand(prsnlcnt,1,prsnlsize,p.person_id,prsnl->prsnl_list[prsnlcnt].prsnl_id))
      ORDER BY p.name_last_key
      HEAD REPORT
       col 0, "******************************************************", row + 1,
       col 0, "Menu Options Selected", row + 1,
       startdttmstr = format(startdttm,";;Q"), col 5, "Start Date Time:",
       col 31, startdttmstr, row + 1,
       enddttmstr = format(enddttm,";;Q"), col 5, "End Date Time:",
       col 31, enddttmstr, row + 1,
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
    OF 3:
     SET prsnlgroupcnt = 0
     SELECT INTO  $OUTDEV
      p.prsnl_group_id, p.prsnl_group_name
      FROM prsnl_group p
      PLAN (p
       WHERE expand(prsnlgroupcnt,1,prsnlgroupsize,p.prsnl_group_id,prsnl_group->prsnl_group_list[
        prsnlgroupcnt].prsnl_group_id))
      ORDER BY p.prsnl_group_name_key
      HEAD REPORT
       col 0, "******************************************************", row + 1,
       col 0, "Menu Options Selected", row + 1,
       startdttmstr = format(startdttm,";;Q"), col 5, "Start Date Time:",
       col 31, startdttmstr, row + 1,
       enddttmstr = format(enddttm,";;Q"), col 5, "End Date Time:",
       col 31, enddttmstr, row + 1,
       col 5, "Provider Groups:", row + 1
      DETAIL
       col 10, p.prsnl_group_name, row + 1
      FOOT REPORT
       row + 1, col 0, "Provider Groups Successfully Updated Are Listed Below",
       row + 1, col 0, "******************************************************",
       row + 2, col 0, "CNT",
       col 10, "ROWS PURGED", col 25,
       "PROVIDER GROUP NAME", row + 1, col 0,
       "---", col 10, "-----------",
       col 25, "----------------------------", row + 1
      WITH append
     ;end select
     SET prsnlgroupcnt = 0
     SELECT INTO "ccluserdir:results_to_endorse_purge_log.dat"
      p.prsnl_group_id, p.prsnl_group_name
      FROM prsnl_group p
      PLAN (p
       WHERE expand(prsnlgroupcnt,1,prsnlgroupsize,p.prsnl_group_id,prsnl_group->prsnl_group_list[
        prsnlgroupcnt].prsnl_group_id))
      ORDER BY p.prsnl_group_name_key
      HEAD REPORT
       col 0, "******************************************************", row + 1,
       col 0, "Menu Options Selected", row + 1,
       startdttmstr = format(startdttm,";;Q"), col 5, "Start Date Time:",
       col 31, startdttmstr, row + 1,
       enddttmstr = format(enddttm,";;Q"), col 5, "End Date Time:",
       col 31, enddttmstr, row + 1,
       col 5, "Provider Groups:", row + 1
      DETAIL
       col 10, p.prsnl_group_name, row + 1
      FOOT REPORT
       row + 1, col 0, "Provider Groups Successfully Updated Are Listed Below",
       row + 1, col 0, "******************************************************",
       row + 2, col 0, "CNT",
       col 10, "ROWS PURGED", col 25,
       "PROVIDER GROUP NAME", row + 1, col 0,
       "---", col 10, "-----------",
       col 25, "----------------------------", row + 1
      WITH append
     ;end select
    ELSE
     SET donothing = 1
   ENDCASE
 END ;Subroutine
 SUBROUTINE (writeloginfo(providerid=f8,numpurged=i4) =null)
   IF ( NOT (providerid))
    SELECT INTO  $OUTDEV
     FROM dual
     DETAIL
      col 0, "******************************************************", row + 1,
      col 0, "No Providers Found.", row + 1,
      col 0, "******************************************************"
     WITH append
    ;end select
    SELECT INTO "ccluserdir:results_to_endorse_purge_log.dat"
     FROM dual
     DETAIL
      col 0, "******************************************************", row + 1,
      col 0, "No Providers Found.", row + 1,
      col 0, "******************************************************"
     WITH append
    ;end select
   ELSE
    SELECT INTO  $OUTDEV
     FROM prsnl p
     WHERE (p.person_id=prsnl->prsnl_list[idx].prsnl_id)
     DETAIL
      idxstr = trim(build(idx)), col 0, idxstr,
      numstr = trim(build(numpurged)), col 10, numstr,
      nffstr = substring(1,40,p.name_full_formatted), col 25, nffstr
     WITH append
    ;end select
    SELECT INTO "ccluserdir:results_to_endorse_purge_log.dat"
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
 SUBROUTINE (writeloginfogroup(providergroupid=f8,numpurged=i4) =null)
   IF ( NOT (providergroupid))
    SELECT INTO  $OUTDEV
     FROM dual
     DETAIL
      col 0, "******************************************************", row + 1,
      col 0, "No Provider Groups Found.", row + 1,
      col 0, "******************************************************"
     WITH append
    ;end select
    SELECT INTO "ccluserdir:results_to_endorse_purge_log.dat"
     FROM dual
     DETAIL
      col 0, "******************************************************", row + 1,
      col 0, "No Provider Groups Found.", row + 1,
      col 0, "******************************************************"
     WITH append
    ;end select
   ELSE
    SELECT INTO  $OUTDEV
     FROM prsnl_group p
     WHERE (p.prsnl_group_id=prsnl_group->prsnl_group_list[idx].prsnl_group_id)
     DETAIL
      idxstr = trim(build(idx)), col 0, idxstr,
      numstr = trim(build(numpurged)), col 10, numstr,
      nffstr = substring(1,40,p.prsnl_group_name), col 25, nffstr
     WITH append
    ;end select
    SELECT INTO "ccluserdir:results_to_endorse_purge_log.dat"
     FROM prsnl_group p
     WHERE (p.prsnl_group_id=prsnl_group->prsnl_group_list[idx].prsnl_group_id)
     DETAIL
      idxstr = trim(build(idx)), col 0, idxstr,
      numstr = trim(build(numpurged)), col 10, numstr,
      nffstr = substring(1,40,p.prsnl_group_name), col 25, nffstr
     WITH append
    ;end select
   ENDIF
 END ;Subroutine
#exit_script
END GO
