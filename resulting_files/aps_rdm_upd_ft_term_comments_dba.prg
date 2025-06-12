CREATE PROGRAM aps_rdm_upd_ft_term_comments:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 DECLARE serrormessage = vc WITH protect, noconstant("")
 DECLARE lerrorcode = i4 WITH protect, noconstant(0)
 DECLARE lfinished = i4 WITH protect, noconstant(0)
 DECLARE lprocrate = i4 WITH protect, noconstant(0)
 DECLARE lselectedrecords = i4 WITH protect, noconstant(0)
 DECLARE dselectstarttime = f8 WITH protect, noconstant(0.0)
 DECLARE lstartat = i4 WITH protect, noconstant(0)
 DECLARE lfailedat = i4 WITH protect, noconstant(0)
 DECLARE lendat = i4 WITH protect, noconstant(0)
 DECLARE lfailed = i4 WITH protect, noconstant(0)
 DECLARE lfailurecount = i4 WITH protect, noconstant(0)
 DECLARE ltotalrecords = i4 WITH protect, noconstant(0)
 DECLARE lcount = i4 WITH protect, noconstant(0)
 RECORD seq_number(
   1 qual[*]
     2 old_long_text_id = f8
     2 new_long_text_id = f8
     2 followup_event_id = f8
 )
 RECORD long_text(
   1 qual[*]
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 long_text = vc
     2 long_text_id = f8
     2 parent_entity_id = f8
     2 parent_entity_name = c32
     2 updt_applctx = i4
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
 )
 SET readme_data->status = "F"
 SET readme_data->message = "Failed to execute table update"
 SET dselectstarttime = cnvtdatetime(curdate,curtime3)
 SELECT INTO "nl:"
  di.info_domain
  FROM dm_info di
  WHERE di.info_domain="ANATOMIC PATHOLOGY"
   AND di.info_name="TERM COMMENTS UPDATED"
   AND di.info_number=1
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET readme_data->status = "S"
  SET readme_data->message = "Update already completed."
  GO TO exit_script
 ENDIF
 WHILE (lfinished=0)
   SET lprocrate = 1000
   SELECT INTO "nl:"
    ap.term_long_text_id
    FROM long_text lt,
     ap_ft_event ap
    PLAN (ap
     WHERE ((ap.term_id=0) OR (ap.term_id = null))
      AND  NOT (ap.term_dt_tm = null)
      AND ap.term_long_text_id > 0
      AND ap.updt_dt_tm < cnvtdatetime(dselectstarttime))
     JOIN (lt
     WHERE ap.term_long_text_id=lt.long_text_id)
    HEAD REPORT
     stat = alterlist(seq_number->qual,0), stat = alterlist(long_text->qual,0), lselectedrecords = 0
    DETAIL
     lselectedrecords = (lselectedrecords+ 1)
     IF (mod(lselectedrecords,10)=1)
      stat = alterlist(seq_number->qual,(lselectedrecords+ 9)), stat = alterlist(long_text->qual,(
       lselectedrecords+ 9))
     ENDIF
     long_text->qual[lselectedrecords].active_ind = lt.active_ind, long_text->qual[lselectedrecords].
     active_status_cd = lt.active_status_cd, long_text->qual[lselectedrecords].active_status_dt_tm =
     lt.active_status_dt_tm,
     long_text->qual[lselectedrecords].active_status_prsnl_id = lt.active_status_prsnl_id, long_text
     ->qual[lselectedrecords].long_text = lt.long_text, long_text->qual[lselectedrecords].
     long_text_id = lt.long_text_id,
     long_text->qual[lselectedrecords].parent_entity_id = lt.parent_entity_id, long_text->qual[
     lselectedrecords].parent_entity_name = lt.parent_entity_name, long_text->qual[lselectedrecords].
     updt_applctx = lt.updt_applctx,
     long_text->qual[lselectedrecords].updt_cnt = lt.updt_cnt, long_text->qual[lselectedrecords].
     updt_dt_tm = lt.updt_dt_tm, long_text->qual[lselectedrecords].updt_id = lt.updt_id,
     long_text->qual[lselectedrecords].updt_task = lt.updt_task, seq_number->qual[lselectedrecords].
     old_long_text_id = ap.term_long_text_id, seq_number->qual[lselectedrecords].followup_event_id =
     ap.followup_event_id
    FOOT REPORT
     stat = alterlist(seq_number->qual,lselectedrecords), stat = alterlist(long_text->qual,
      lselectedrecords)
    WITH nocounter, maxqual(ap,1000)
   ;end select
   IF (lselectedrecords < 1000)
    SET lfinished = 1
   ENDIF
   IF (curqual=0)
    SET readme_data->status = "S"
    SET readme_data->message = "No rows to update."
    GO TO exit_script
   ENDIF
   SET lprocrate = lselectedrecords
   SET lstartat = 1
   SET lfailedat = 0
   SET lfailed = 0
   WHILE (lstartat <= lselectedrecords)
     SET lfailed = 0
     SET lendat = ((lstartat+ lprocrate) - 1)
     IF (lendat > lselectedrecords)
      SET lendat = lselectedrecords
     ENDIF
     SET lcount = 0
     SELECT INTO "nl:"
      FROM ap_ft_event ap,
       (dummyt d  WITH seq = value(lselectedrecords))
      PLAN (d
       WHERE d.seq >= lstartat
        AND d.seq <= lendat)
       JOIN (ap
       WHERE (ap.followup_event_id=seq_number->qual[d.seq].followup_event_id))
      DETAIL
       lcount = (lcount+ 1)
      WITH nocounter, forupdate(ap)
     ;end select
     IF ((lcount < ((lendat - lstartat)+ 1)))
      SET lfailed = 1
     ENDIF
     IF (lfailed=0)
      SET lcount = 0
      SELECT INTO "nl:"
       FROM long_text lt,
        (dummyt d  WITH seq = value(lselectedrecords))
       PLAN (d
        WHERE d.seq >= lstartat
         AND d.seq <= lendat)
        JOIN (lt
        WHERE (lt.long_text_id=seq_number->qual[d.seq].old_long_text_id))
       DETAIL
        lcount = (lcount+ 1)
       WITH nocounter, forupdate(lt)
      ;end select
      IF ((lcount < ((lendat - lstartat)+ 1)))
       SET lfailed = 1
      ENDIF
     ENDIF
     IF (lfailed=0)
      FOR (nextseqloop = lstartat TO value(lendat))
       SELECT INTO "nl:"
        seq_nbr = seq(long_data_seq,nextval)"##################;rp0"
        FROM dual
        DETAIL
         seq_number->qual[nextseqloop].new_long_text_id = seq_nbr
        WITH nocounter
       ;end select
       IF (curqual=0)
        SET readme_data->status = "F"
        SET readme_data->message = "Failure to retrieve sequence number."
        GO TO exit_script
       ENDIF
      ENDFOR
      UPDATE  FROM ap_ft_event ap,
        (dummyt d  WITH seq = value(lselectedrecords))
       SET ap.term_long_text_id = seq_number->qual[d.seq].new_long_text_id, ap.updt_dt_tm =
        cnvtdatetime(curdate,curtime3)
       PLAN (d
        WHERE d.seq >= lstartat
         AND d.seq <= lendat)
        JOIN (ap
        WHERE (ap.followup_event_id=seq_number->qual[d.seq].followup_event_id))
       WITH nocounter
      ;end update
      IF ((curqual < ((lendat - lstartat)+ 1)))
       SET readme_data->status = "F"
       SET readme_data->message = "Failed to update AP_FT_EVENT table."
       GO TO exit_script
      ENDIF
      INSERT  FROM long_text lt,
        (dummyt d  WITH seq = value(lselectedrecords))
       SET lt.long_text_id = seq_number->qual[d.seq].new_long_text_id, lt.updt_dt_tm = cnvtdatetime(
         curdate,curtime3), lt.active_ind = long_text->qual[d.seq].active_ind,
        lt.active_status_cd = long_text->qual[d.seq].active_status_cd, lt.active_status_dt_tm =
        cnvtdatetime(long_text->qual[d.seq].active_status_dt_tm), lt.active_status_prsnl_id =
        long_text->qual[d.seq].active_status_prsnl_id,
        lt.long_text = long_text->qual[d.seq].long_text, lt.parent_entity_id = long_text->qual[d.seq]
        .parent_entity_id, lt.parent_entity_name = long_text->qual[d.seq].parent_entity_name,
        lt.updt_applctx = long_text->qual[d.seq].updt_applctx, lt.updt_cnt = long_text->qual[d.seq].
        updt_cnt, lt.updt_id = long_text->qual[d.seq].updt_id,
        lt.updt_task = long_text->qual[d.seq].updt_task
       PLAN (d
        WHERE d.seq >= lstartat
         AND d.seq <= lendat)
        JOIN (lt
        WHERE (lt.long_text_id=seq_number->qual[d.seq].old_long_text_id))
       WITH nocounter
      ;end insert
      SET lerrorcode = error(serrormessage,0)
      IF ((curqual < ((lendat - lstartat)+ 1)))
       ROLLBACK
       CALL logmsg("Error inserting into LONG_TEXT.",((e_rdmstatus+ e_dispmsg)+ e_logtofile))
       CALL logmsg(serrormessage,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
       SET readme_data->status = "F"
       SET readme_data->message = serrormessage
       GO TO exit_script
      ENDIF
      DELETE  FROM long_text lt,
        (dummyt d  WITH seq = value(lselectedrecords))
       SET lt.seq = 1
       PLAN (d
        WHERE d.seq >= lstartat
         AND d.seq <= lendat)
        JOIN (lt
        WHERE (lt.long_text_id=seq_number->qual[d.seq].old_long_text_id))
       WITH nocounter
      ;end delete
      COMMIT
     ENDIF
     IF (lfailed=1)
      IF (lprocrate=1)
       SET lstartat = (lstartat+ lprocrate)
       SET lfailurecount = (lfailurecount+ 1)
       IF (lfailurecount > 10)
        SET readme_data->status = "F"
        SET readme_data->message = "More than 10 rows failed to be locked for update"
        GO TO exit_script
       ENDIF
      ELSE
       SET lfailedat = lendat
       SET lprocrate = (lprocrate/ 10)
      ENDIF
     ELSE
      SET lstartat = (lendat+ 1)
      IF (lprocrate < 1000
       AND ((lendat >= lfailedat) OR (lfailedat=0)) )
       SET lprocrate = (lprocrate * 10)
       SET lfailedat = 0
      ENDIF
     ENDIF
   ENDWHILE
   SET ltotalrecords = (ltotalrecords+ lselectedrecords)
 ENDWHILE
 INSERT  FROM dm_info di
  SET di.info_domain = "ANATOMIC PATHOLOGY", di.info_name = "TERM COMMENTS UPDATED", di.info_number
    = 1,
   di.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  WITH nocounter
 ;end insert
 SET lerrorcode = error(serrormessage,0)
 IF (lerrorcode != 0)
  CALL logmsg("Error inserting into dm_info.",((e_rdmstatus+ e_dispmsg)+ e_logtofile))
  CALL logmsg(serrormessage,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
  SET readme_data->status = "F"
  SET readme_data->message = serrormessage
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = build2("*********Success.  ",lfailurecount," of ",ltotalrecords,
  " rows failed to update.")
#exit_script
 CALL echo(readme_data->message)
 EXECUTE dm_readme_status
END GO
