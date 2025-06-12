CREATE PROGRAM bhs_prax_save_allergy
 FREE RECORD result
 RECORD result(
   1 modify_ind = i2
   1 encntr_id = f8
   1 person_id = f8
   1 performed_dt_tm = dq8
   1 allergy_id = f8
   1 allergy_instance_id = f8
   1 comment = vc
   1 reactions[*]
     2 reaction_id = f8
     2 reaction_nom_id = f8
     2 reaction_ftdesc = vc
     2 active_ind = i2
     2 modify_ind = i2
   1 modify_data
     2 reactions[*]
       3 reaction_id = f8
       3 allergy_instance_id = f8
       3 reaction_nom_id = f8
       3 reaction_ftdesc = vc
       3 active_ind = i2
       3 beg_effective_dt_tm = dq8
     2 comments[*]
       3 allergy_comment_id = f8
       3 allergy_instance_id = f8
       3 comment_dt_tm = dq8
       3 comment_tz = i4
       3 comment_prsnl_id = f8
       3 allergy_comment = vc
       3 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req101706
 RECORD req101706(
   1 allergy_cnt = i4
   1 allergy[*]
     2 allergy_instance_id = f8
     2 allergy_id = f8
     2 person_id = f8
     2 encntr_id = f8
     2 substance_nom_id = f8
     2 substance_ftdesc = vc
     2 substance_type_cd = f8
     2 reaction_class_cd = f8
     2 severity_cd = f8
     2 source_of_info_cd = f8
     2 source_of_info_ft = vc
     2 onset_dt_tm = dq8
     2 onset_tz = i4
     2 onset_precision_cd = f8
     2 onset_precision_flag = i2
     2 reaction_status_cd = f8
     2 cancel_reason_cd = f8
     2 cancel_dt_tm = dq8
     2 cancel_prsnl_id = f8
     2 created_prsnl_id = f8
     2 reviewed_dt_tm = dq8
     2 reviewed_tz = i4
     2 reviewed_prsnl_id = f8
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 beg_effective_tz = i4
     2 end_effective_dt_tm = dq8
     2 contributor_system_cd = f8
     2 data_status_cd = f8
     2 data_status_dt_tm = dq8
     2 data_status_prsnl_id = f8
     2 verified_status_flag = i2
     2 rec_src_vocab_cd = f8
     2 rec_src_identifier = vc
     2 rec_src_string = vc
     2 cmb_instance_id = f8
     2 cmb_flag = i2
     2 cmb_prsnl_id = f8
     2 cmb_person_id = f8
     2 cmb_dt_tm = dq8
     2 cmb_tz = i4
     2 updt_id = f8
     2 reaction_status_dt_tm = dq8
     2 created_dt_tm = dq8
     2 orig_prsnl_id = f8
     2 reaction_cnt = i4
     2 reaction[*]
       3 reaction_id = f8
       3 allergy_instance_id = f8
       3 allergy_id = f8
       3 reaction_nom_id = f8
       3 reaction_ftdesc = vc
       3 active_ind = i2
       3 active_status_cd = f8
       3 active_status_dt_tm = dq8
       3 active_status_prsnl_id = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 contributor_system_cd = f8
       3 data_status_cd = f8
       3 data_status_dt_tm = dq8
       3 data_status_prsnl_id = f8
       3 cmb_reaction_id = f8
       3 cmb_flag = i2
       3 cmb_prsnl_id = f8
       3 cmb_person_id = f8
       3 cmb_dt_tm = dq8
       3 cmb_tz = i4
       3 updt_id = f8
       3 updt_dt_tm = dq8
     2 allergy_comment_cnt = i4
     2 allergy_comment[*]
       3 allergy_comment_id = f8
       3 allergy_instance_id = f8
       3 allergy_id = f8
       3 comment_dt_tm = dq8
       3 comment_tz = i4
       3 comment_prsnl_id = f8
       3 allergy_comment = vc
       3 active_ind = i2
       3 active_status_cd = f8
       3 active_status_dt_tm = dq8
       3 active_status_prsnl_id = f8
       3 beg_effective_dt_tm = dq8
       3 beg_effective_tz = i4
       3 end_effective_dt_tm = dq8
       3 contributor_system_cd = f8
       3 data_status_cd = f8
       3 data_status_dt_tm = dq8
       3 data_status_prsnl_id = f8
       3 cmb_comment_id = f8
       3 cmb_flag = i2
       3 cmb_prsnl_id = f8
       3 cmb_person_id = f8
       3 cmb_dt_tm = dq8
       3 cmb_tz = i4
       3 updt_id = f8
       3 updt_dt_tm = dq8
     2 sub_concept_cki = vc
     2 pre_generated_id = f8
   1 disable_inactive_person_ens = i2
   1 fail_on_duplicate = i2
 ) WITH protect
 FREE RECORD rep101706
 RECORD rep101706(
   1 person_org_sec_on = i2
   1 allergy_cnt = i4
   1 allergy[*]
     2 allergy_instance_id = f8
     2 allergy_id = f8
     2 adr_added_ind = i2
     2 status_flag = i2
     2 reaction_cnt = i4
     2 reaction[*]
       3 reaction_id = f8
       3 status_flag = i2
     2 allergy_comment_cnt = i4
     2 allergy_comment[*]
       3 allergy_comment_id = f8
       3 status_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE callallergyensureserver(null) = i4
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE locidx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE rcnt = i4 WITH protect, noconstant(0)
 DECLARE ccnt = i4 WITH protect, noconstant(0)
 DECLARE startpos = i4 WITH protect, noconstant(0)
 DECLARE endpos = i4 WITH protect, noconstant(0)
 DECLARE param = vc WITH protect, noconstant("")
 DECLARE crlf = vc WITH protect, constant(concat(char(13),char(10)))
 SET result->status_data.status = "F"
 DECLARE app_tz = i4 WITH protect, constant(evaluate(curutc,1,curtimezoneapp,0))
 SET result->modify_ind = evaluate( $20,0.0,0,1)
 IF (textlen(trim( $18,3)) > 0
  AND cnvtdatetime( $18) > 0.0)
  SET result->performed_dt_tm = cnvtdatetime( $18)
 ELSE
  SET result->performed_dt_tm = cnvtdatetime(curdate,curtime3)
 ENDIF
 CALL echo(build("PERFORMED_DT_TM: ",format(result->performed_dt_tm,";;Q")))
 IF (( $2 <= 0.0))
  CALL echo("INVALID ENCOUNTER ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $3 <= 0.0))
  CALL echo("INVALID PERSONNEL ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $4 <= 0.0))
  CALL echo("INVALID SUBSTANCE NOMENCLATURE ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SET result->encntr_id =  $2
 SELECT INTO "NL:"
  FROM encounter e
  PLAN (e
   WHERE (e.encntr_id=result->encntr_id)
    AND e.active_ind=1
    AND e.beg_effective_dt_tm < sysdate
    AND e.end_effective_dt_tm > sysdate)
  ORDER BY e.person_id
  HEAD e.person_id
   result->person_id = e.person_id
  WITH nocounter, time = 30
 ;end select
 IF ((result->modify_ind=1))
  SET result->allergy_id =  $20
  SELECT INTO "NL:"
   FROM allergy a
   PLAN (a
    WHERE (a.allergy_id=result->allergy_id)
     AND a.active_ind=1
     AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY a.allergy_id, a.beg_effective_dt_tm DESC
   HEAD a.allergy_id
    result->allergy_instance_id = a.allergy_instance_id
   WITH nocounter, time = 30
  ;end select
  IF ((result->allergy_instance_id <= 0))
   CALL echo("INVALID ALLERGY ID PARAMETER...EXITING")
   GO TO exit_script
  ENDIF
  SELECT INTO "NL:"
   FROM reaction r
   PLAN (r
    WHERE (r.allergy_id=result->allergy_id)
     AND r.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND r.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY r.reaction_id
   HEAD r.reaction_id
    rcnt = (rcnt+ 1), stat = alterlist(result->modify_data.reactions,rcnt), result->modify_data.
    reactions[rcnt].allergy_instance_id = r.allergy_instance_id,
    result->modify_data.reactions[rcnt].reaction_id = r.reaction_id, result->modify_data.reactions[
    rcnt].reaction_nom_id = r.reaction_nom_id, result->modify_data.reactions[rcnt].reaction_ftdesc =
    r.reaction_ftdesc,
    result->modify_data.reactions[rcnt].active_ind = r.active_ind, result->modify_data.reactions[rcnt
    ].beg_effective_dt_tm = r.beg_effective_dt_tm
   WITH nocounter, time = 30
  ;end select
  SELECT INTO "NL:"
   FROM allergy_comment ac
   PLAN (ac
    WHERE (ac.allergy_id=result->allergy_id)
     AND ac.active_ind=1
     AND ac.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ac.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY ac.allergy_comment_id
   HEAD ac.allergy_comment_id
    ccnt = (ccnt+ 1), stat = alterlist(result->modify_data.comments,ccnt), result->modify_data.
    comments[ccnt].allergy_instance_id = ac.allergy_instance_id,
    result->modify_data.comments[ccnt].allergy_comment_id = ac.allergy_comment_id, result->
    modify_data.comments[ccnt].comment_dt_tm = ac.comment_dt_tm, result->modify_data.comments[ccnt].
    comment_tz = ac.comment_tz,
    result->modify_data.comments[ccnt].comment_prsnl_id = ac.comment_prsnl_id, result->modify_data.
    comments[ccnt].allergy_comment = ac.allergy_comment, result->modify_data.comments[ccnt].
    active_ind = ac.active_ind
   WITH nocounter, time = 30
  ;end select
 ENDIF
 FREE RECORD req_format_str
 RECORD req_format_str(
   1 param = vc
 ) WITH protect
 FREE RECORD rep_format_str
 RECORD rep_format_str(
   1 param = vc
 ) WITH protect
 IF (textlen(trim( $19,3)))
  SET req_format_str->param =  $19
  EXECUTE bhs_prax_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
   "REP_FORMAT_STR")
  SET result->comment = nullterm(trim(rep_format_str->param,3))
 ENDIF
 DECLARE reactionidparam = vc WITH protect, noconstant("")
 DECLARE reactioncnt = i4 WITH protect, noconstant(0)
 SET startpos = 1
 SET reactionidparam = trim( $16,3)
 CALL echo(build2("REACTIONIDPARAM IS: ",reactionidparam))
 WHILE (size(reactionidparam) > 0)
   SET endpos = (findstring(";",reactionidparam,1) - 1)
   IF (endpos <= 0)
    SET endpos = size(reactionidparam)
   ENDIF
   CALL echo(build("ENDPOS:",endpos))
   IF (startpos < endpos)
    SET param = substring(1,endpos,reactionidparam)
    CALL echo(build("PARAM:",param))
    SET reactioncnt = (reactioncnt+ 1)
    SET stat = alterlist(result->reactions,reactioncnt)
    SET result->reactions[reactioncnt].reaction_nom_id = cnvtreal(param)
    SET result->reactions[reactioncnt].active_ind = 1
   ENDIF
   SET reactionidparam = substring((endpos+ 2),(size(reactionidparam) - endpos),reactionidparam)
   CALL echo(build("REACTIONIDPARAM:",reactionidparam))
   CALL echo(build("SIZE(REACTIONIDPARAM):",size(reactionidparam)))
 ENDWHILE
 DECLARE reactionidinactiveparam = vc WITH protect, noconstant("")
 SET startpos = 1
 SET reactionidinactiveparam = trim( $17,3)
 CALL echo(build2("REACTIONIDINACTIVEPARAM IS: ",reactionidinactiveparam))
 WHILE (size(reactionidinactiveparam) > 0)
   SET endpos = (findstring(";",reactionidinactiveparam,1) - 1)
   IF (endpos <= 0)
    SET endpos = size(reactionidinactiveparam)
   ENDIF
   CALL echo(build("ENDPOS:",endpos))
   IF (startpos < endpos)
    SET param = substring(1,endpos,reactionidinactiveparam)
    CALL echo(build("PARAM:",param))
    SET reactioncnt = (reactioncnt+ 1)
    SET stat = alterlist(result->reactions,reactioncnt)
    SET result->reactions[reactioncnt].reaction_nom_id = cnvtreal(param)
    SET result->reactions[reactioncnt].active_ind = 0
   ENDIF
   SET reactionidinactiveparam = substring((endpos+ 2),(size(reactionidinactiveparam) - endpos),
    reactionidinactiveparam)
   CALL echo(build("REACTIONIDINACTIVEPARAM:",reactionidinactiveparam))
   CALL echo(build("SIZE(REACTIONIDINACTIVEPARAM):",size(reactionidinactiveparam)))
 ENDWHILE
 DECLARE newfreetextreactionparam = vc WITH protect, noconstant("")
 SET startpos = 1
 SET newfreetextreactionparam = trim( $21,3)
 CALL echo(build2("NEWFREETEXTREACTIONPARAM IS: ",newfreetextreactionparam))
 WHILE (size(newfreetextreactionparam) > 0)
   SET endpos = (findstring("|",newfreetextreactionparam,1) - 1)
   IF (endpos <= 0)
    SET endpos = size(newfreetextreactionparam)
   ENDIF
   CALL echo(build("ENDPOS:",endpos))
   IF (startpos < endpos)
    SET param = substring(1,endpos,newfreetextreactionparam)
    CALL echo(build("PARAM:",param))
    SET reactioncnt = (reactioncnt+ 1)
    SET stat = alterlist(result->reactions,reactioncnt)
    SET result->reactions[reactioncnt].reaction_ftdesc = trim(param,3)
    SET result->reactions[reactioncnt].active_ind = 1
   ENDIF
   SET newfreetextreactionparam = substring((endpos+ 2),(size(newfreetextreactionparam) - endpos),
    newfreetextreactionparam)
   CALL echo(build("NEWFREETEXTREACTIONPARAM:",newfreetextreactionparam))
   CALL echo(build("SIZE(NEWFREETEXTREACTIONPARAM):",size(newfreetextreactionparam)))
 ENDWHILE
 DECLARE freetxtreactionidactiveparam = vc WITH protect, noconstant("")
 SET startpos = 1
 SET freetxtreactionidactiveparam = trim( $22,3)
 CALL echo(build2("FREETXTREACTIONIDACTIVEPARAM IS: ",freetxtreactionidactiveparam))
 WHILE (size(freetxtreactionidactiveparam) > 0)
   SET endpos = (findstring(";",freetxtreactionidactiveparam,1) - 1)
   IF (endpos <= 0)
    SET endpos = size(freetxtreactionidactiveparam)
   ENDIF
   CALL echo(build("ENDPOS:",endpos))
   IF (startpos < endpos)
    SET param = substring(1,endpos,freetxtreactionidactiveparam)
    CALL echo(build("PARAM:",param))
    SET reactioncnt = (reactioncnt+ 1)
    SET stat = alterlist(result->reactions,reactioncnt)
    SET result->reactions[reactioncnt].reaction_id = cnvtreal(param)
    SET result->reactions[reactioncnt].active_ind = 1
   ENDIF
   SET freetxtreactionidactiveparam = substring((endpos+ 2),(size(freetxtreactionidactiveparam) -
    endpos),freetxtreactionidactiveparam)
   CALL echo(build("FREETXTREACTIONIDACTIVEPARAM:",freetxtreactionidactiveparam))
   CALL echo(build("SIZE(FREETXTREACTIONIDACTIVEPARAM):",size(freetxtreactionidactiveparam)))
 ENDWHILE
 DECLARE freetxtreactionidinactiveparam = vc WITH protect, noconstant("")
 SET startpos = 1
 SET freetxtreactionidinactiveparam = trim( $23,3)
 CALL echo(build2("FREETXTREACTIONIDINACTIVEPARAM IS: ",freetxtreactionidinactiveparam))
 WHILE (size(freetxtreactionidinactiveparam) > 0)
   SET endpos = (findstring(";",freetxtreactionidinactiveparam,1) - 1)
   IF (endpos <= 0)
    SET endpos = size(freetxtreactionidinactiveparam)
   ENDIF
   CALL echo(build("ENDPOS:",endpos))
   IF (startpos < endpos)
    SET param = substring(1,endpos,freetxtreactionidinactiveparam)
    CALL echo(build("PARAM:",param))
    SET reactioncnt = (reactioncnt+ 1)
    SET stat = alterlist(result->reactions,reactioncnt)
    SET result->reactions[reactioncnt].reaction_id = cnvtreal(param)
    SET result->reactions[reactioncnt].active_ind = 0
   ENDIF
   SET freetxtreactionidinactiveparam = substring((endpos+ 2),(size(freetxtreactionidinactiveparam)
     - endpos),freetxtreactionidinactiveparam)
   CALL echo(build("FREETXTREACTIONIDINACTIVEPARAM:",freetxtreactionidinactiveparam))
   CALL echo(build("SIZE(FREETXTREACTIONIDINACTIVEPARAM):",size(freetxtreactionidinactiveparam)))
 ENDWHILE
 SET stat = callallergyensureserver(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 DECLARE v1 = vc WITH protect, noconstant("")
 DECLARE v2 = vc WITH protect, noconstant("")
 DECLARE v3 = vc WITH protect, noconstant("")
 CALL echorecord(result)
 IF (size(trim(moutputdevice,3)) > 0)
  SELECT INTO value(moutputdevice)
   FROM dummyt d
   PLAN (d
    WHERE d.seq > 0)
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1, v1 = build("<Status>",result->status_data.status,"</Status>"), col + 1,
    v1, row + 1, v2 = build("<AllergyID>",cnvtint(result->allergy_id),"</AllergyID>"),
    col + 1, v2, row + 1,
    v3 = build("<AllergyInstanceID>",cnvtint(result->allergy_instance_id),"</AllergyInstanceID>"),
    col + 1, v3,
    row + 1, col + 1, "</ReplyMessage>",
    row + 1
   WITH maxcol = 32000, nocounter, nullreport,
    formfeed = none, format = variable, time = 30
  ;end select
 ENDIF
 FREE RECORD result
 FREE RECORD req101706
 FREE RECORD rep101706
 FREE RECORD i_request
 FREE RECORD i_reply
 FREE RECORD req_format_str
 FREE RECORD rep_format_str
 SUBROUTINE callallergyensureserver(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(961706)
   DECLARE requestid = i4 WITH constant(101706)
   DECLARE errmsg = vc WITH protect, noconstant("")
   FREE RECORD i_request
   RECORD i_request(
     1 prsnl_id = f8
   ) WITH protect
   FREE RECORD i_reply
   RECORD i_reply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   SET i_request->prsnl_id =  $3
   CALL echorecord(i_request)
   EXECUTE bhs_prax_impersonate_user  WITH replace("REQUEST","I_REQUEST"), replace("REPLY","I_REPLY")
   IF ((i_reply->status_data.status != "S"))
    CALL echo("IMPERSONATE USER FAILED...EXITING!")
    RETURN(fail)
   ENDIF
   SET req101706->allergy_cnt = 1
   SET stat = alterlist(req101706->allergy,1)
   IF ((result->modify_ind=1))
    SET req101706->allergy[1].allergy_instance_id = result->allergy_instance_id
    SET req101706->allergy[1].allergy_id = result->allergy_id
   ENDIF
   SET req101706->allergy[1].encntr_id = result->encntr_id
   SET req101706->allergy[1].person_id = result->person_id
   SET req101706->allergy[1].substance_nom_id =  $4
   SET req101706->allergy[1].substance_type_cd =  $5
   SET req101706->allergy[1].reaction_class_cd =  $6
   SET req101706->allergy[1].severity_cd =  $7
   SET req101706->allergy[1].source_of_info_cd =  $8
   IF (textlen(trim( $9,3)) > 0
    AND cnvtdatetime( $9) > 0.0)
    SET req101706->allergy[1].onset_dt_tm = cnvtdatetime( $9)
   ENDIF
   SET req101706->allergy[1].onset_tz = app_tz
   SET req101706->allergy[1].onset_precision_cd =  $10
   SET req101706->allergy[1].onset_precision_flag =  $11
   SET req101706->allergy[1].reaction_status_cd =  $12
   SET req101706->allergy[1].cancel_reason_cd =  $13
   SET req101706->allergy[1].created_prsnl_id =  $14
   IF (textlen(trim( $15,3)) > 0
    AND cnvtdatetime( $15) > 0.0)
    SET req101706->allergy[1].reviewed_dt_tm = cnvtdatetime( $15)
    SET req101706->allergy[1].reviewed_tz = app_tz
    SET req101706->allergy[1].reviewed_prsnl_id =  $3
   ENDIF
   SET req101706->allergy[1].active_ind = 1
   SET rcnt = size(result->modify_data.reactions,5)
   IF (rcnt > 0)
    SET stat = alterlist(req101706->allergy[1].reaction,rcnt)
    FOR (idx = 1 TO rcnt)
      SET pos = 0.0
      IF ((result->modify_data.reactions[idx].reaction_nom_id > 0.0))
       SET pos = locateval(locidx,1,size(result->reactions,5),result->modify_data.reactions[idx].
        reaction_nom_id,result->reactions[locidx].reaction_nom_id)
      ENDIF
      IF (pos=0
       AND (result->modify_data.reactions[idx].reaction_id > 0.0))
       SET pos = locateval(locidx,1,size(result->reactions,5),result->modify_data.reactions[idx].
        reaction_id,result->reactions[locidx].reaction_id)
      ENDIF
      IF (pos > 0)
       SET result->modify_data.reactions[idx].active_ind = result->reactions[pos].active_ind
       SET result->modify_data.reactions[idx].allergy_instance_id = result->allergy_instance_id
       SET result->modify_data.reactions[idx].beg_effective_dt_tm = result->performed_dt_tm
       SET result->reactions[pos].modify_ind = 1
      ENDIF
      SET req101706->allergy[1].reaction[idx].reaction_id = result->modify_data.reactions[idx].
      reaction_id
      SET req101706->allergy[1].reaction[idx].allergy_instance_id = result->modify_data.reactions[idx
      ].allergy_instance_id
      SET req101706->allergy[1].reaction[idx].allergy_id = result->allergy_id
      SET req101706->allergy[1].reaction[idx].reaction_nom_id = result->modify_data.reactions[idx].
      reaction_nom_id
      SET req101706->allergy[1].reaction[idx].reaction_ftdesc = result->modify_data.reactions[idx].
      reaction_ftdesc
      SET req101706->allergy[1].reaction[idx].active_ind = result->modify_data.reactions[idx].
      active_ind
      SET req101706->allergy[1].reaction[idx].beg_effective_dt_tm = result->modify_data.reactions[idx
      ].beg_effective_dt_tm
    ENDFOR
   ENDIF
   FOR (idx = 1 TO size(result->reactions,5))
     IF ((result->reactions[idx].modify_ind=0)
      AND (((result->reactions[idx].reaction_nom_id > 0.0)) OR (textlen(trim(result->reactions[idx].
       reaction_ftdesc,3)) > 0)) )
      SET rcnt = (rcnt+ 1)
      SET stat = alterlist(req101706->allergy[1].reaction,rcnt)
      IF ((result->modify_ind=1))
       SET req101706->allergy[1].reaction[rcnt].allergy_instance_id = result->allergy_instance_id
       SET req101706->allergy[1].reaction[rcnt].allergy_id = result->allergy_id
      ENDIF
      SET req101706->allergy[1].reaction[rcnt].reaction_nom_id = result->reactions[idx].
      reaction_nom_id
      SET req101706->allergy[1].reaction[rcnt].reaction_ftdesc = result->reactions[idx].
      reaction_ftdesc
      SET req101706->allergy[1].reaction[rcnt].active_ind = result->reactions[idx].active_ind
      SET req101706->allergy[1].reaction[rcnt].beg_effective_dt_tm = result->performed_dt_tm
     ENDIF
   ENDFOR
   SET req101706->allergy[1].reaction_cnt = size(req101706->allergy[1].reaction,5)
   SET ccnt = size(result->modify_data.comments,5)
   IF (ccnt > 0)
    SET stat = alterlist(req101706->allergy[1].allergy_comment,ccnt)
    FOR (idx = 1 TO ccnt)
      SET req101706->allergy[1].allergy_comment[idx].allergy_id = result->allergy_id
      SET req101706->allergy[1].allergy_comment[idx].allergy_instance_id = result->modify_data.
      comments[idx].allergy_instance_id
      SET req101706->allergy[1].allergy_comment[idx].allergy_comment_id = result->modify_data.
      comments[idx].allergy_comment_id
      SET req101706->allergy[1].allergy_comment[idx].comment_dt_tm = result->modify_data.comments[idx
      ].comment_dt_tm
      SET req101706->allergy[1].allergy_comment[idx].comment_tz = result->modify_data.comments[idx].
      comment_tz
      SET req101706->allergy[1].allergy_comment[idx].comment_prsnl_id = result->modify_data.comments[
      idx].comment_prsnl_id
      SET req101706->allergy[1].allergy_comment[idx].allergy_comment = result->modify_data.comments[
      idx].allergy_comment
      SET req101706->allergy[1].allergy_comment[idx].active_ind = result->modify_data.comments[idx].
      active_ind
    ENDFOR
   ENDIF
   IF (textlen(trim(result->comment,3)) > 0)
    SET ccnt = (ccnt+ 1)
    SET stat = alterlist(req101706->allergy[1].allergy_comment,ccnt)
    IF ((result->modify_ind=1))
     SET req101706->allergy[1].allergy_comment[ccnt].allergy_instance_id = result->
     allergy_instance_id
     SET req101706->allergy[1].allergy_comment[ccnt].allergy_id = result->allergy_id
    ENDIF
    SET req101706->allergy[1].allergy_comment[ccnt].comment_dt_tm = result->performed_dt_tm
    SET req101706->allergy[1].allergy_comment[ccnt].comment_prsnl_id =  $3
    SET req101706->allergy[1].allergy_comment[ccnt].allergy_comment = result->comment
    SET req101706->allergy[1].allergy_comment[ccnt].active_ind = 1
   ENDIF
   SET req101706->allergy[1].allergy_comment_cnt = size(req101706->allergy[1].allergy_comment,5)
   SET req101706->disable_inactive_person_ens = 1
   CALL echorecord(req101706)
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req101706,
    "REC",rep101706,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep101706)
   IF ((rep101706->status_data.status="S"))
    IF (size(rep101706->allergy,5) > 0)
     SET result->allergy_id = rep101706->allergy[1].allergy_id
     SET result->allergy_instance_id = rep101706->allergy[1].allergy_instance_id
    ENDIF
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
END GO
