CREATE PROGRAM bhs_prax_mark_allergyrev
 FREE RECORD result
 RECORD result(
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
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req963006
 RECORD req963006(
   1 person_id = f8
 ) WITH protect
 FREE RECORD rep963006
 RECORD rep963006(
   1 person_org_sec_on = i2
   1 allergy_qual = i4
   1 allergy[*]
     2 allergy_id = f8
     2 allergy_instance_id = f8
     2 encntr_id = f8
     2 organization_id = f8
     2 source_string = vc
     2 substance_nom_id = f8
     2 substance_ftdesc = vc
     2 substance_type_cd = f8
     2 substance_type_disp = c40
     2 substance_type_mean = c12
     2 reaction_class_cd = f8
     2 reaction_class_disp = c40
     2 reaction_class_mean = c12
     2 severity_cd = f8
     2 severity_disp = c40
     2 severity_mean = c12
     2 source_of_info_cd = f8
     2 source_of_info_disp = c40
     2 source_of_info_mean = c12
     2 onset_dt_tm = dq8
     2 onset_tz = i4
     2 onset_precision_cd = f8
     2 onset_precision_disp = c40
     2 onset_precision_flag = i2
     2 reaction_status_cd = f8
     2 reaction_status_disp = c40
     2 reaction_status_mean = c12
     2 reaction_status_dt_tm = dq8
     2 created_dt_tm = dq8
     2 created_prsnl_id = f8
     2 created_prsnl_name = vc
     2 reviewed_dt_tm = dq8
     2 reviewed_tz = i4
     2 reviewed_prsnl_id = f8
     2 reviewed_prsnl_name = vc
     2 cancel_reason_cd = f8
     2 cancel_reason_disp = c40
     2 active_ind = i2
     2 orig_prsnl_id = f8
     2 orig_prsnl_name = vc
     2 updt_id = f8
     2 updt_name = vc
     2 updt_dt_tm = dq8
     2 cki = vc
     2 concept_source_cd = f8
     2 concept_source_disp = c40
     2 concept_source_mean = c12
     2 concept_identifier = vc
     2 cancel_dt_tm = dq8
     2 cancel_prsnl_id = f8
     2 cancel_prsnl_name = vc
     2 beg_effective_dt_tm = dq8
     2 beg_effective_tz = i4
     2 end_effective_dt_tm = dq8
     2 data_status_cd = f8
     2 data_status_dt_tm = dq8
     2 data_status_prsnl_id = f8
     2 contributor_system_cd = f8
     2 source_of_info_ft = vc
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 rec_src_identifier = vc
     2 rec_src_string = vc
     2 rec_src_vocab_cd = f8
     2 verified_status_flag = i2
     2 reaction_qual = i4
     2 cmb_instance_id = f8
     2 cmb_flag = i2
     2 cmb_prsnl_id = f8
     2 cmb_prsnl_name = vc
     2 cmb_person_id = f8
     2 cmb_person_name = vc
     2 cmb_dt_tm = dq8
     2 cmb_tz = i4
     2 reaction[*]
       3 allergy_instance_id = f8
       3 reaction_id = f8
       3 reaction_nom_id = f8
       3 source_string = vc
       3 reaction_ftdesc = vc
       3 beg_effective_dt_tm = dq8
       3 active_ind = i2
       3 end_effective_dt_tm = dq8
       3 data_status_cd = f8
       3 data_status_dt_tm = dq8
       3 data_status_prsnl_id = f8
       3 contributor_system_cd = f8
       3 active_status_cd = f8
       3 active_status_dt_tm = dq8
       3 active_status_prsnl_id = f8
       3 cmb_reaction_id = f8
       3 cmb_flag = i2
       3 cmb_prsnl_id = f8
       3 cmb_prsnl_name = vc
       3 cmb_person_id = f8
       3 cmb_person_name = vc
       3 cmb_dt_tm = dq8
       3 cmb_tz = i4
     2 comment_qual = i4
     2 comment[*]
       3 allergy_comment_id = f8
       3 allergy_instance_id = f8
       3 organization_id = f8
       3 comment_dt_tm = dq8
       3 comment_tz = i4
       3 comment_prsnl_id = f8
       3 comment_prsnl_name = vc
       3 allergy_comment = vc
       3 beg_effective_dt_tm = dq8
       3 beg_effective_tz = i4
       3 active_ind = i4
       3 end_effective_dt_tm = dq8
       3 data_status_cd = f8
       3 data_status_dt_tm = dq8
       3 data_status_prsnl_id = f8
       3 contributor_system_cd = f8
       3 active_status_cd = f8
       3 active_status_dt_tm = dq8
       3 active_status_prsnl_id = f8
       3 cmb_comment_id = f8
       3 cmb_flag = i2
       3 cmb_prsnl_id = f8
       3 cmb_prsnl_name = vc
       3 cmb_person_id = f8
       3 cmb_person_name = vc
       3 cmb_dt_tm = dq8
       3 cmb_tz = i4
     2 sub_concept_cki = vc
     2 source_vocab_cd = f8
     2 primary_vterm_ind = i2
     2 active_status_prsnl_name = vc
   1 adr_knt = i4
   1 adr[*]
     2 activity_data_reltn_id = f8
     2 person_id = f8
     2 activity_entity_name = vc
     2 activity_entity_id = f8
     2 activity_entity_inst_id = f8
     2 reltn_entity_name = vc
     2 reltn_entity_id = f8
     2 reltn_entity_all_ind = i2
   1 display_allergy_mode = vc
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
     2 cmb_tz = i2
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
       3 cmb_tz = i2
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
       3 cmb_tz = i2
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
     2 allergy_comment_cnt = i4
     2 allergy_comment[*]
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE callgetallergyserver(null) = i4
 DECLARE findallergydetails(null) = i4
 DECLARE callallergyensureserver(null) = i4
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE locidx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 SET result->status_data.status = "F"
 DECLARE app_tz = i4 WITH protect, constant(evaluate(curutc,1,curtimezoneapp,0))
 IF (( $2 <= 0.0))
  CALL echo("INVALID PERSON ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $3 <= 0.0))
  CALL echo("INVALID PERSONNEL ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SET stat = callgetallergyserver(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET stat = findallergydetails(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET stat = callallergyensureserver(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 DECLARE v1 = vc WITH protect, noconstant("")
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
    v1, row + 1, col + 1,
    "</ReplyMessage>", row + 1
   WITH maxcol = 32000, nocounter, nullreport,
    formfeed = none, format = variable, time = 30
  ;end select
 ENDIF
 FREE RECORD result
 FREE RECORD req963006
 FREE RECORD rep963006
 FREE RECORD req101706
 FREE RECORD rep101706
 FREE RECORD i_request
 FREE RECORD i_reply
 SUBROUTINE callgetallergyserver(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(963006)
   DECLARE requestid = i4 WITH constant(963006)
   SET req963006->person_id =  $2
   CALL echorecord(req963006)
   CALL echo(build("TDBEXECUTE FOR ",requestid))
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req963006,
    "REC",rep963006,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep963006)
   IF ((rep963006->status_data.status != "F"))
    SET result->allergy_cnt = size(rep963006->allergy,5)
    SET stat = alterlist(result->allergy,result->allergy_cnt)
    FOR (idx = 1 TO result->allergy_cnt)
      SET result->allergy[idx].allergy_id = rep963006->allergy[idx].allergy_id
    ENDFOR
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
 SUBROUTINE findallergydetails(null)
  IF ((result->allergy_cnt <= 0))
   CALL echo("ALLERGY_CNT IS ZERO...EXITING!")
   RETURN(fail)
  ENDIF
  SELECT INTO "NL:"
   FROM allergy a
   PLAN (a
    WHERE expand(idx,1,result->allergy_cnt,a.allergy_id,result->allergy[idx].allergy_id)
     AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY a.allergy_id, a.beg_effective_dt_tm DESC
   HEAD a.allergy_id
    pos = locateval(locidx,1,result->allergy_cnt,a.allergy_id,result->allergy[locidx].allergy_id)
    IF (pos > 0)
     result->allergy[pos].allergy_instance_id = a.allergy_instance_id, result->allergy[pos].person_id
      = a.person_id, result->allergy[pos].encntr_id = a.encntr_id,
     result->allergy[pos].substance_nom_id = a.substance_nom_id, result->allergy[pos].
     substance_ftdesc = a.substance_ftdesc, result->allergy[pos].substance_type_cd = a
     .substance_type_cd,
     result->allergy[pos].reaction_class_cd = a.reaction_class_cd, result->allergy[pos].severity_cd
      = a.severity_cd, result->allergy[pos].source_of_info_cd = a.source_of_info_cd,
     result->allergy[pos].source_of_info_ft = a.source_of_info_ft, result->allergy[pos].onset_dt_tm
      = a.onset_dt_tm, result->allergy[pos].onset_tz = a.onset_tz,
     result->allergy[pos].onset_precision_cd = a.onset_precision_cd, result->allergy[pos].
     onset_precision_flag = a.onset_precision_flag, result->allergy[pos].reaction_status_cd = a
     .reaction_status_cd,
     result->allergy[pos].active_ind = a.active_ind
    ENDIF
   WITH nocounter, time = 30
  ;end select
 END ;Subroutine
 SUBROUTINE callallergyensureserver(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(961706)
   DECLARE requestid = i4 WITH constant(101706)
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
   SET req101706->allergy_cnt = result->allergy_cnt
   SET req101706->disable_inactive_person_ens = 1
   SET stat = alterlist(req101706->allergy,req101706->allergy_cnt)
   FOR (idx = 1 TO req101706->allergy_cnt)
     SET req101706->allergy[idx].allergy_instance_id = result->allergy[idx].allergy_instance_id
     SET req101706->allergy[idx].allergy_id = result->allergy[idx].allergy_id
     SET req101706->allergy[idx].person_id = result->allergy[idx].person_id
     SET req101706->allergy[idx].encntr_id = result->allergy[idx].encntr_id
     SET req101706->allergy[idx].substance_nom_id = result->allergy[idx].substance_nom_id
     SET req101706->allergy[idx].substance_ftdesc = result->allergy[idx].substance_ftdesc
     SET req101706->allergy[idx].substance_type_cd = result->allergy[idx].substance_type_cd
     SET req101706->allergy[idx].reaction_class_cd = result->allergy[idx].reaction_class_cd
     SET req101706->allergy[idx].severity_cd = result->allergy[idx].severity_cd
     SET req101706->allergy[idx].source_of_info_cd = result->allergy[idx].source_of_info_cd
     SET req101706->allergy[idx].source_of_info_ft = result->allergy[idx].source_of_info_ft
     SET req101706->allergy[idx].onset_dt_tm = result->allergy[idx].onset_dt_tm
     SET req101706->allergy[idx].onset_tz = result->allergy[idx].onset_tz
     SET req101706->allergy[idx].onset_precision_cd = result->allergy[idx].onset_precision_cd
     SET req101706->allergy[idx].onset_precision_flag = result->allergy[idx].onset_precision_flag
     SET req101706->allergy[idx].reaction_status_cd = result->allergy[idx].reaction_status_cd
     SET req101706->allergy[idx].active_ind = result->allergy[idx].active_ind
     SET req101706->allergy[idx].severity_cd = result->allergy[idx].severity_cd
     SET req101706->allergy[idx].severity_cd = result->allergy[idx].severity_cd
     SET req101706->allergy[idx].severity_cd = result->allergy[idx].severity_cd
     SET req101706->allergy[idx].reviewed_prsnl_id =  $3
     SET req101706->allergy[idx].reviewed_dt_tm = cnvtdatetime( $4)
     SET req101706->allergy[idx].reviewed_tz = app_tz
   ENDFOR
   CALL echorecord(req101706)
   CALL echo(build("TDBEXECUTE FOR ",requestid))
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req101706,
    "REC",rep101706,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep101706)
   IF ((rep101706->status_data.status != "F"))
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
END GO
