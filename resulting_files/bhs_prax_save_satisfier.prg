CREATE PROGRAM bhs_prax_save_satisfier
 FREE RECORD result
 RECORD result(
   1 encntr_id = f8
   1 person_id = f8
   1 organization_id = f8
   1 modifier_type_cd = f8
   1 modifier_type_disp = vc
   1 comment = vc
   1 expect_mod_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE callensureprogram(null) = i2
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 SET result->status_data.status = "F"
 IF (( $2 <= 0.0))
  CALL echo("INVALID ENCOUNTER ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $3 <= 0.0))
  CALL echo("INVALID PERSONNEL ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $11 <= 0.0))
  CALL echo("INVALID RECOMMENDATION ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $13=1)
  AND ( $12 <= 0.0))
  CALL echo("INVALID RECOMMENDATION ACTION ID PARAMETER...EXITING")
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
   result->person_id = e.person_id, result->organization_id = e.organization_id
  WITH nocounter, time = 30
 ;end select
 DECLARE c_mod_expire_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",30281,"EXPIRE"))
 DECLARE c_mod_postpone_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",30281,"POSTPONE")
  )
 DECLARE c_mod_refuse_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",30281,"REFUSE"))
 DECLARE c_mod_satisfy_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",30281,"SATISFY"))
 DECLARE c_entry_expire_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",30280,"EXPIRE"))
 DECLARE c_entry_postpone_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",30280,"POSTPONE"))
 DECLARE c_entry_refuse_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",30280,"REFUSE"))
 DECLARE c_entry_manual_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",30280,"MANUAL"))
 CALL echo(build("ENTRY TYPE=",uar_get_code_display(cnvtreal( $5))))
 SET result->modifier_type_cd = evaluate(cnvtreal( $5),c_entry_expire_cd,c_mod_expire_cd,
  c_entry_postpone_cd,c_mod_postpone_cd,
  c_entry_refuse_cd,c_mod_refuse_cd,c_entry_manual_cd,c_mod_satisfy_cd,0.0)
 SET result->modifier_type_disp = uar_get_code_display(result->modifier_type_cd)
 CALL echo(build("RESULT->MODIFIER_TYPE_CD=",result->modifier_type_cd))
 CALL echo(build("RESULT->MODIFIER_TYPE_DISP=",result->modifier_type_disp))
 FREE RECORD req_format_str
 RECORD req_format_str(
   1 param = vc
 ) WITH protect
 FREE RECORD rep_format_str
 RECORD rep_format_str(
   1 param = vc
 ) WITH protect
 SET req_format_str->param =  $8
 EXECUTE bhs_prax_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
  "REP_FORMAT_STR")
 SET result->comment = rep_format_str->param
 SET stat = callensureprogram(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 CALL echorecord(result)
 IF (size(trim(moutputdevice,3)) > 0)
  DECLARE v1 = vc WITH protect, noconstant("")
  DECLARE v2 = vc WITH protect, noconstant("")
  SELECT INTO value(moutputdevice)
   FROM dummyt d
   PLAN (d
    WHERE d.seq > 0)
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1, v1 = build("<Status>",result->status_data.status,"</Status>"), col + 1,
    v1, row + 1, v2 = build("<ExpectModId>",cnvtint(result->expect_mod_id),"</ExpectModId>"),
    col + 1, v2, row + 1,
    col + 1, "</ReplyMessage>", row + 1
   WITH maxcol = 32000, nocounter, nullreport,
    formfeed = none, format = variable, time = 30
  ;end select
 ENDIF
 FREE RECORD result
 FREE RECORD req966321
 FREE RECORD rep966321
 SUBROUTINE callensureprogram(null)
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
   FREE RECORD req966321
   RECORD req966321(
     1 qual[*]
       2 expect_mod_id = f8
       2 person_id = f8
       2 series_id = f8
       2 expectation_id = f8
       2 step_id = f8
       2 sat_prsnl_id = f8
       2 modifier_type_cd = f8
       2 modifier_reason_cd = f8
       2 modifier_dt_tm = dq8
       2 status_ind = i2
       2 long_text_id = f8
       2 comment = vc
       2 organization_id = f8
       2 expect_sat_id = f8
       2 recommendation_id = f8
       2 force_insert_ind = i2
       2 recommendation_action_id = f8
       2 encounter_id = f8
     1 allow_recommendation_server_ind = i2
   ) WITH protect
   FREE RECORD rep966321
   RECORD rep966321(
     1 qual[*]
       2 expect_mod_id = f8
       2 person_id = f8
       2 series_id = f8
       2 expectation_id = f8
       2 step_id = f8
       2 sat_prsnl_id = f8
       2 modifier_type_cd = f8
       2 modifier_reason_cd = f8
       2 modifier_dt_tm = dq8
       2 modifier_type_changed = i2
       2 status_ind = i2
       2 long_text_id = f8
       2 comment = vc
       2 last_action_seq = i4
       2 new_comment_ind = i2
       2 action_flag = i2
       2 error_message = vc
       2 organization_id = f8
       2 expect_sat_id = f8
     1 status_data
       2 status = c1
       2 status_value = i4
       2 subeventstatus[*]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   SET stat = alterlist(req966321->qual,1)
   SET req966321->qual[1].person_id = result->person_id
   SET req966321->qual[1].series_id =  $4
   SET req966321->qual[1].modifier_type_cd = result->modifier_type_cd
   SET req966321->qual[1].modifier_reason_cd =  $6
   IF (size(trim( $7,3)) > 0)
    SET req966321->qual[1].modifier_dt_tm = cnvtdatetime( $7)
   ELSE
    SET req966321->qual[1].modifier_dt_tm = cnvtdatetime(curdate,curtime3)
   ENDIF
   IF (( $13=1))
    SET req966321->qual[1].status_ind = 0
   ELSE
    SET req966321->qual[1].status_ind = 1
   ENDIF
   SET req966321->qual[1].comment = result->comment
   SET req966321->qual[1].organization_id = result->organization_id
   SET req966321->qual[1].expect_sat_id =  $9
   SET req966321->qual[1].sat_prsnl_id =  $10
   SET req966321->qual[1].recommendation_id =  $11
   SET req966321->qual[1].recommendation_action_id =  $12
   SET req966321->allow_recommendation_server_ind = 1
   CALL echorecord(req966321)
   EXECUTE pco_hm_ens_recommendation  WITH replace("REQUEST","REQ966321"), replace("REPLY",
    "REP966321")
   CALL echorecord(rep966321)
   IF ((rep966321->status_data.status="S"))
    IF (size(rep966321->qual,5) > 0)
     SET result->expect_mod_id = rep966321->qual[1].expect_mod_id
    ENDIF
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
END GO
