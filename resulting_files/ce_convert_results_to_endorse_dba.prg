CREATE PROGRAM ce_convert_results_to_endorse:dba
 PROMPT
  "Output to File/Printer/MINE:" = "MINE",
  "Select Type of Conversion:" = 0,
  "Select Position Codes:" = 0,
  "Select Providers:" = 0
  WITH outdev, type, position,
  provider
 FREE RECORD prsnl
 RECORD prsnl(
   1 prsnl_list[*]
     2 prsnl_id = f8
 )
 DECLARE prsnlcnt = i4 WITH noconstant(0)
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE rowcnt = i4 WITH noconstant(0)
 DECLARE firstrow = i4 WITH noconstant(0)
 DECLARE action_status_completed = f8 WITH noconstant(0.0)
 DECLARE action_status_refused = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(103,"COMPLETED",1,action_status_completed)
 SET stat = uar_get_meaning_by_codeset(103,"REFUSED",1,action_status_refused)
 DECLARE action_type_order = f8 WITH noconstant(0.0)
 DECLARE action_type_sign = f8 WITH noconstant(0.0)
 DECLARE action_type_review = f8 WITH noconstant(0.0)
 DECLARE action_type_endorse = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(21,"ORDER",1,action_type_order)
 SET stat = uar_get_meaning_by_codeset(21,"SIGN",1,action_type_sign)
 SET stat = uar_get_meaning_by_codeset(21,"REVIEW",1,action_type_review)
 SET stat = uar_get_meaning_by_codeset(21,"ENDORSE",1,action_type_endorse)
 DECLARE event_class_placeholder = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(53,"PLACEHOLDER",1,event_class_placeholder)
 DECLARE event_class_grp = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(53,"GRP",1,event_class_grp)
 DECLARE event_class_med = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(53,"MED",1,event_class_med)
 DECLARE event_class_immun = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(53,"IMMUN",1,event_class_immun)
 DECLARE prsnlcnt = i4 WITH noconstant(0)
 DECLARE ea_done = i4 WITH noconstant(0)
 DECLARE ce_emsg = vc WITH noconstant("")
 DECLARE ce_ecode = i4 WITH noconstant(0)
 DECLARE removeprsnlnotify(providerid=f8) = null
 CASE ( $TYPE)
  OF 1:
   SELECT INTO "nl:"
    p.person_id
    FROM prsnl p,
     prsnl_notify pn
    PLAN (p
     WHERE p.physician_ind=1)
     JOIN (pn
     WHERE pn.person_id=p.person_id
      AND pn.query_ind=1)
    ORDER BY p.person_id
    DETAIL
     prsnlcnt += 1
     IF (mod(prsnlcnt,10)=1)
      stat = alterlist(prsnl->prsnl_list,(prsnlcnt+ 9))
     ENDIF
     prsnl->prsnl_list[prsnlcnt].prsnl_id = p.person_id
    WITH nocounter
   ;end select
  OF 2:
   SELECT INTO "nl:"
    p.person_id
    FROM prsnl p,
     prsnl_notify pn
    PLAN (p
     WHERE (p.position_cd= $POSITION))
     JOIN (pn
     WHERE pn.person_id=p.person_id
      AND pn.query_ind=1)
    ORDER BY p.person_id
    DETAIL
     prsnlcnt += 1
     IF (mod(prsnlcnt,10)=1)
      stat = alterlist(prsnl->prsnl_list,(prsnlcnt+ 9))
     ENDIF
     prsnl->prsnl_list[prsnlcnt].prsnl_id = p.person_id
    WITH nocounter
   ;end select
  OF 3:
   SELECT INTO "nl:"
    p.person_id
    FROM prsnl p,
     prsnl_notify pn
    PLAN (p
     WHERE (p.person_id= $PROVIDER))
     JOIN (pn
     WHERE pn.person_id=p.person_id
      AND pn.query_ind=1)
    ORDER BY p.person_id
    DETAIL
     prsnlcnt += 1
     IF (mod(prsnlcnt,10)=1)
      stat = alterlist(prsnl->prsnl_list,(prsnlcnt+ 9))
     ENDIF
     prsnl->prsnl_list[prsnlcnt].prsnl_id = p.person_id
    WITH nocounter
   ;end select
  ELSE
   SET donothing = 1
 ENDCASE
 IF ( NOT (prsnlcnt))
  CALL writeloginfo(0.0)
 ENDIF
 FOR (idx = 1 TO prsnlcnt)
   CALL convertresults(prsnl->prsnl_list[idx].prsnl_id)
   CALL deleteprsnlnotify(prsnl->prsnl_list[idx].prsnl_id)
   CALL writeloginfo(prsnl->prsnl_list[idx].prsnl_id)
   COMMIT
 ENDFOR
 SUBROUTINE (convertresults(providerid=f8) =null)
   INSERT  FROM ce_event_action cea
    (cea.ce_event_action_id, cea.event_id, cea.action_prsnl_id,
    cea.action_type_cd, cea.action_dt_tm, cea.updt_id,
    cea.updt_dt_tm, cea.updt_task, cea.updt_applctx,
    cea.updt_cnt, cea.person_id, cea.encntr_id,
    cea.event_class_cd, cea.event_tag, cea.result_status_cd,
    cea.clinsig_updt_dt_tm, cea.event_cd, cea.normalcy_cd,
    cea.event_title_text, cea.parent_event_id, cea.parent_event_class_cd)(SELECT
     seq(ocf_seq,nextval), ce.event_id, cep.action_prsnl_id,
     cep.action_type_cd, cep.action_dt_tm, cep.updt_id,
     cep.updt_dt_tm, cep.updt_task, cep.updt_applctx,
     cep.updt_cnt, ce.person_id, ce.encntr_id,
     ce.event_class_cd, ce.event_tag, ce.result_status_cd,
     ce.clinsig_updt_dt_tm, ce.event_cd, ce.normalcy_cd,
     ce.event_title_text, ce.parent_event_id, ce2.event_class_cd
     FROM ce_event_prsnl cep,
      person p,
      clinical_event ce,
      clinical_event ce2
     WHERE cep.action_prsnl_id=providerid
      AND cep.action_dt_tm > cnvtdatetime((curdate - 366),curtime3)
      AND cep.person_id > 0
      AND cep.valid_until_dt_tm=cnvtdatetime("31-Dec-2100")
      AND cep.action_type_cd=action_type_order
      AND ((cep.action_status_cd+ 0)=action_status_completed)
      AND ce.event_id=cep.event_id
      AND ce.verified_prsnl_id != cep.action_prsnl_id
      AND ce.valid_until_dt_tm=cnvtdatetimeutc("31-dec-2100")
      AND  NOT ( EXISTS (
     (SELECT
      "x"
      FROM ce_event_action cea
      WHERE cea.event_id=ce.event_id
       AND cea.action_prsnl_id=cep.action_prsnl_id
       AND cea.action_type_cd=cep.action_type_cd)))
      AND  NOT ( EXISTS (
     (SELECT
      "x"
      FROM ce_event_prsnl cep2
      WHERE ce.clinsig_updt_dt_tm <= cep2.updt_dt_tm
       AND ((cep2.action_status_cd+ 0) IN (action_status_completed, action_status_refused))
       AND cep2.valid_until_dt_tm=cnvtdatetimeutc("31-dec-2100")
       AND ((cep2.action_prsnl_id+ 0)=cep.action_prsnl_id)
       AND ((cep2.action_type_cd+ 0) IN (action_type_sign, action_type_review, action_type_endorse))
       AND cep2.event_id=ce.event_id)))
      AND ce.view_level > 0
      AND ce.publish_flag=1
      AND ce.event_class_cd != event_class_med
      AND ce.event_class_cd != event_class_immun
      AND p.person_id=cep.person_id
      AND p.active_ind=1
      AND ce2.event_id=ce.parent_event_id
      AND ce2.valid_until_dt_tm=ce.valid_until_dt_tm)
    WITH nocounter
   ;end insert
   SET ce_ecode = error(ce_emsg,1)
   IF (ce_ecode != 0)
    ROLLBACK
    CALL writeerror(providerid,"Failed during write to CE_EVENT_ACTION row")
   ENDIF
   INSERT  FROM ce_event_action cea
    (cea.ce_event_action_id, cea.event_id, cea.action_prsnl_id,
    cea.action_type_cd, cea.action_dt_tm, cea.updt_id,
    cea.updt_dt_tm, cea.updt_task, cea.updt_applctx,
    cea.updt_cnt, cea.person_id, cea.encntr_id,
    cea.event_class_cd, cea.event_tag, cea.result_status_cd,
    cea.clinsig_updt_dt_tm, cea.event_cd, cea.normalcy_cd,
    cea.event_title_text, cea.parent_event_id, cea.parent_event_class_cd)(SELECT
     seq(ocf_seq,nextval), ce.event_id, cep.action_prsnl_id,
     cep.action_type_cd, cep.action_dt_tm, cep.updt_id,
     cep.updt_dt_tm, cep.updt_task, cep.updt_applctx,
     cep.updt_cnt, ce.person_id, ce.encntr_id,
     ce.event_class_cd, ce.event_tag, ce.result_status_cd,
     ce.clinsig_updt_dt_tm, ce.event_cd, ce.normalcy_cd,
     ce.event_title_text, ce.parent_event_id, ce2.event_class_cd
     FROM ce_event_prsnl cep,
      person p,
      clinical_event ce,
      clinical_event ce2
     WHERE cep.action_prsnl_id=providerid
      AND cep.action_dt_tm > cnvtdatetime((curdate - 366),curtime3)
      AND cep.person_id > 0
      AND cep.valid_until_dt_tm=cnvtdatetime("31-Dec-2100")
      AND cep.action_type_cd=action_type_order
      AND ((cep.action_status_cd+ 0)=action_status_completed)
      AND ce.parent_event_id=cep.event_id
      AND ce.event_id != ce.parent_event_id
      AND ce.verified_prsnl_id != cep.action_prsnl_id
      AND ce.valid_until_dt_tm=cnvtdatetimeutc("31-dec-2100")
      AND  NOT ( EXISTS (
     (SELECT
      "x"
      FROM ce_event_action cea
      WHERE cea.event_id=ce.event_id
       AND cea.action_prsnl_id=cep.action_prsnl_id
       AND cea.action_type_cd=cep.action_type_cd)))
      AND  NOT ( EXISTS (
     (SELECT
      "x"
      FROM ce_event_prsnl cep2
      WHERE ce.clinsig_updt_dt_tm <= cep2.updt_dt_tm
       AND ((cep2.action_status_cd+ 0) IN (action_status_completed, action_status_refused))
       AND cep2.valid_until_dt_tm=cnvtdatetimeutc("31-dec-2100")
       AND ((cep2.action_prsnl_id+ 0)=cep.action_prsnl_id)
       AND ((cep2.action_type_cd+ 0) IN (action_type_sign, action_type_review, action_type_endorse))
       AND cep2.event_id=ce.event_id)))
      AND ce.view_level > 0
      AND ce.publish_flag=1
      AND ce.event_class_cd != event_class_placeholder
      AND ce.event_class_cd != event_class_grp
      AND ce.event_class_cd != event_class_med
      AND ce.event_class_cd != event_class_immun
      AND p.person_id=cep.person_id
      AND p.active_ind=1
      AND ce2.event_id=ce.parent_event_id
      AND ce2.valid_until_dt_tm=ce.valid_until_dt_tm)
    WITH nocounter
   ;end insert
   SET ce_ecode = error(ce_emsg,1)
   IF (ce_ecode != 0)
    ROLLBACK
    CALL writeerror(providerid,"Failed during write to CE_EVENT_ACTION row")
   ENDIF
 END ;Subroutine
 SUBROUTINE deleteprsnlnotify(providerid)
   DELETE  FROM prsnl_notify pn
    WHERE pn.query_ind=1
     AND pn.person_id=providerid
    WITH nocounter
   ;end delete
   SET ce_ecode = error(ce_emsg,1)
   IF (ce_ecode != 0)
    ROLLBACK
    CALL writeerror(providerid,"Failed to Write Prsnl_Notify row on provider:")
   ENDIF
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
   SELECT INTO "ccluserdir:results_to_endorse_log.err"
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
 SUBROUTINE (writeloginfo(providerid=f8) =null)
   IF ( NOT (providerid))
    SELECT INTO  $OUTDEV
     FROM dual
     DETAIL
      col 0, "******************************************************", row + 1,
      col 0, "No Providers Eligible For Update.", row + 1,
      col 0, "All Selected Providers Have Been Updated.", row + 1,
      col 0, "******************************************************"
     WITH append
    ;end select
   ELSE
    SELECT INTO  $OUTDEV
     FROM prsnl p
     WHERE (p.person_id=prsnl->prsnl_list[idx].prsnl_id)
     HEAD REPORT
      IF (firstrow=0)
       firstrow = 1, col 0, "******************************************************",
       row + 1, col 0, "Providers Eligible For Update:",
       col 31, prsnlcnt, row + 1,
       col 0, "Providers Successfully Updated Are Listed Below", row + 1,
       col 0, "******************************************************", row + 2,
       col 0, "CNT", col 10,
       "PROVIDER ID", col 25, "PROVIDER NAME",
       row + 1, col 0, "---",
       col 10, "-----------", col 25,
       "----------------------------", row + 1
      ENDIF
     DETAIL
      idxstr = trim(build(idx)), col 0, idxstr,
      personstr = trim(build(p.person_id)), col 10, personstr,
      nffstr = substring(1,40,p.name_full_formatted), col 25, nffstr
     WITH append
    ;end select
   ENDIF
 END ;Subroutine
#exit_script
END GO
