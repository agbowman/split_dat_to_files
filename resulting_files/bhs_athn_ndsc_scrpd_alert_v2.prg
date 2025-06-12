CREATE PROGRAM bhs_athn_ndsc_scrpd_alert_v2
 FREE RECORD result
 RECORD result(
   1 ndsc_user = vc
   1 ndsc_pass = vc
   1 order_id = f8
   1 person_id = f8
   1 encntr_id = f8
   1 birth_dt_tm = vc
   1 sex_cd = f8
   1 prsnl_id = f8
   1 position_cd = f8
   1 catalog_type_cd = f8
   1 activity_type_cd = f8
   1 activity_subtype_cd = f8
   1 session_info_json = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD get_print_file_req
 RECORD get_print_file_req(
   1 file_dir = vc
   1 file_name = vc
   1 multi_node_ind = i2
 ) WITH protect
 FREE RECORD get_print_file_rep
 RECORD get_print_file_rep(
   1 sts = i4
   1 count = i4
   1 qual[*]
     2 line = vc
   1 info_line[*]
     2 new_line = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE callndsccreatesession(null) = i2
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE jdx = i4 WITH protect, noconstant(0)
 DECLARE kdx = i4 WITH protect, noconstant(0)
 DECLARE locidx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 IF (( $2 <= 0.0))
  CALL echo("INVALID ENCOUNTER ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $3 <= 0.0))
  CALL echo("INVALID PERSONNEL ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SET result->order_id =  $10
 FREE RECORD req_format_str
 RECORD req_format_str(
   1 param = vc
 ) WITH protect
 FREE RECORD rep_format_str
 RECORD rep_format_str(
   1 param = vc
 ) WITH protect
 IF (textlen(trim( $22,3)))
  SET req_format_str->param =  $22
  EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
   "REP_FORMAT_STR")
  SET result->ndsc_user = nullterm(trim(rep_format_str->param,3))
 ENDIF
 IF (textlen(trim( $23,3)))
  SET req_format_str->param =  $23
  EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
   "REP_FORMAT_STR")
  SET result->ndsc_pass = nullterm(trim(rep_format_str->param,3))
 ENDIF
 SET result->encntr_id =  $2
 IF (( $27 > 0.0))
  SET result->person_id =  $25
  SET result->birth_dt_tm =  $26
  SET result->sex_cd =  $27
 ELSE
  SELECT INTO "NL:"
   FROM person p
   PLAN (p
    WHERE (p.person_id= $25)
     AND p.active_ind=1
     AND p.beg_effective_dt_tm < sysdate
     AND p.end_effective_dt_tm > sysdate)
   ORDER BY p.person_id
   HEAD p.person_id
    result->person_id = p.person_id, result->birth_dt_tm = format(p.birth_dt_tm,
     "dd-MMM-yyyy HH:mm:ss"), result->sex_cd = p.sex_cd
   WITH nocounter, time = 30
  ;end select
 ENDIF
 IF ((((result->birth_dt_tm=" ")) OR ((result->person_id <= 0.0))) )
  CALL echo("INVALID PATIENT DETAILS...EXITING")
  GO TO exit_script
 ENDIF
 SET result->prsnl_id =  $3
 IF (( $28 > 0.0))
  SET result->position_cd =  $28
 ELSE
  SELECT INTO "NL:"
   FROM prsnl p
   PLAN (p
    WHERE (p.person_id=result->prsnl_id)
     AND p.active_ind=1
     AND p.beg_effective_dt_tm < sysdate
     AND p.end_effective_dt_tm > sysdate)
   ORDER BY p.person_id
   HEAD p.person_id
    result->position_cd = p.position_cd
   WITH nocounter, time = 30
  ;end select
 ENDIF
 IF ((result->position_cd <= 0.0))
  CALL echo("INVALID PERSONNEL DETAILS...EXITING")
  GO TO exit_script
 ENDIF
 IF (( $26 > 0.0))
  SET result->catalog_type_cd =  $29
  SET result->activity_type_cd =  $30
  SET result->activity_subtype_cd =  $31
 ELSE
  SELECT INTO "NL:"
   FROM order_catalog oc
   PLAN (oc
    WHERE (oc.catalog_cd= $9)
     AND oc.active_ind=1)
   HEAD oc.catalog_cd
    result->catalog_type_cd = oc.catalog_type_cd, result->activity_type_cd = oc.activity_type_cd,
    result->activity_subtype_cd = oc.activity_subtype_cd
   WITH nocounter, time = 30
  ;end select
 ENDIF
 CALL echo("PARSING ORDER ENTRY DETAILS PARAMETER")
 FREE RECORD req_oeparse
 RECORD req_oeparse(
   1 oe_params = vc
 ) WITH protect
 FREE RECORD rep_oeparse
 RECORD rep_oeparse(
   1 detaillist[*]
     2 oefieldid = f8
     2 oefieldvalue = f8
     2 oefielddisplayvalue = vc
     2 oefielddttmvalue = dq8
     2 oefieldmeaning = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 SET req_oeparse->oe_params = trim( $21,3)
 EXECUTE bhs_athn_parse_oe_details  WITH replace("REQUEST","REQ_OEPARSE"), replace("REPLY",
  "REP_OEPARSE")
 IF ((rep_oeparse->status_data.status != "S"))
  CALL echo("PARSE_OE_DETAILS FAILED...EXITING!")
  GO TO exit_script
 ENDIF
 SET stat = callndsccreatesession(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 CALL echorecord(result)
 CALL echojson(result, $1)
 FREE RECORD result
 FREE RECORD req_oeparse
 FREE RECORD rep_oeparse
 FREE RECORD dialoguerequest
 FREE RECORD dialoguereply
 FREE RECORD i_request
 FREE RECORD i_reply
 SUBROUTINE callndsccreatesession(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(3072000)
   DECLARE requestid = i4 WITH constant(3072006)
   DECLARE alertcnt = i4 WITH protect, noconstant(0)
   DECLARE ordercnt = i4 WITH protect, noconstant(0)
   DECLARE detailcnt = i4 WITH protect, noconstant(0)
   DECLARE overridecnt = i4 WITH protect, noconstant(0)
   DECLARE c_cps_add_scrp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",12600,
     "CPS_ADD_SCRP"))
   DECLARE c_order_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"ORDER"))
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
   EXECUTE bhs_athn_impersonate_user  WITH replace("REQUEST","I_REQUEST"), replace("REPLY","I_REPLY")
   IF ((i_reply->status_data.status != "S"))
    CALL echo("IMPERSONATE USER FAILED...EXITING!")
    RETURN(fail)
   ENDIF
   FREE RECORD dialoguerequest
   RECORD dialoguerequest(
     1 req_type_cd = f8
     1 passthru_ind = i2
     1 trigger_app = i4
     1 person_id = f8
     1 encntr_id = f8
     1 position_cd = f8
     1 sex_cd = f8
     1 birth_dt_tm = dq8
     1 weight = f8
     1 weight_unit_cd = f8
     1 height = f8
     1 height_unit_cd = f8
     1 orderlist[*]
       2 synonym_code = f8
       2 catalog_code = f8
       2 catalogtypecd = f8
       2 orderid = f8
       2 actiontypecd = f8
       2 activitytypecd = f8
       2 activitysubtypecd = f8
       2 dose = f8
       2 dose_unit = f8
       2 start_dt_tm = dq8
       2 end_dt_tm = dq8
       2 route = f8
       2 frequency = f8
       2 physician = f8
       2 rate = f8
       2 infuse_over = i4
       2 infuse_over_unit_cd = f8
       2 protocol_order_ind = i2
       2 dayoftreatment_order_ind = i2
       2 detaillist[*]
         3 oefieldid = f8
         3 oefieldvalue = f8
         3 oefielddisplayvalue = vc
         3 oefielddttmvalue = dq8
         3 oefieldmeaning = vc
       2 diagnosislist[*]
         3 dx = vc
       2 ingredientlist[*]
         3 catalogcd = f8
         3 synonymid = f8
         3 item_id = f8
         3 strengthdose = f8
         3 strengthunit = f8
         3 volumedose = f8
         3 volumeunit = f8
         3 bag_frequency_cd = f8
         3 freetextdose = vc
         3 dosequantity = f8
         3 dosequantityunit = f8
         3 ivseq = i4
         3 normalized_rate = f8
         3 normalized_rate_unit = f8
     1 alert_titlebar = vc
     1 commonreply_ind = i2
     1 freetextparam = vc
     1 expert_trigger = vc
   ) WITH protect
   SET dialoguerequest->req_type_cd = c_cps_add_scrp_cd
   SET dialoguerequest->person_id = result->person_id
   SET dialoguerequest->encntr_id = result->encntr_id
   SET dialoguerequest->sex_cd = result->sex_cd
   SET dialoguerequest->birth_dt_tm = cnvtdatetime(result->birth_dt_tm)
   SET dialoguerequest->height =  $4
   SET dialoguerequest->height_unit_cd =  $5
   SET dialoguerequest->weight =  $6
   SET dialoguerequest->weight_unit_cd =  $7
   SET dialoguerequest->commonreply_ind = 1
   SET dialoguerequest->passthru_ind = 0
   SET dialoguerequest->trigger_app = 0
   SET dialoguerequest->position_cd = result->position_cd
   SET stat = alterlist(dialoguerequest->orderlist,1)
   SET dialoguerequest->orderlist[1].synonym_code =  $8
   SET dialoguerequest->orderlist[1].catalog_code =  $9
   SET dialoguerequest->orderlist[1].catalogtypecd = result->catalog_type_cd
   SET dialoguerequest->orderlist[1].orderid = result->order_id
   SET dialoguerequest->orderlist[1].actiontypecd = c_order_cd
   SET dialoguerequest->orderlist[1].activitytypecd = result->activity_type_cd
   SET dialoguerequest->orderlist[1].activitysubtypecd = result->activity_subtype_cd
   SET dialoguerequest->orderlist[1].dose =  $11
   SET dialoguerequest->orderlist[1].dose_unit =  $12
   SET dialoguerequest->orderlist[1].start_dt_tm = cnvtdatetime( $13)
   SET dialoguerequest->orderlist[1].end_dt_tm = cnvtdatetime( $14)
   SET dialoguerequest->orderlist[1].route =  $15
   SET dialoguerequest->orderlist[1].frequency =  $16
   SET dialoguerequest->orderlist[1].physician =  $17
   SET dialoguerequest->orderlist[1].rate =  $18
   SET dialoguerequest->orderlist[1].infuse_over =  $19
   SET dialoguerequest->orderlist[1].infuse_over_unit_cd =  $20
   SET stat = alterlist(dialoguerequest->orderlist[1].detaillist,size(rep_oeparse->detaillist,5))
   FOR (idx = 1 TO size(rep_oeparse->detaillist,5))
     SET dialoguerequest->orderlist[1].detaillist[idx].oefieldid = rep_oeparse->detaillist[idx].
     oefieldid
     SET dialoguerequest->orderlist[1].detaillist[idx].oefieldvalue = rep_oeparse->detaillist[idx].
     oefieldvalue
     SET dialoguerequest->orderlist[1].detaillist[idx].oefielddisplayvalue = rep_oeparse->detaillist[
     idx].oefielddisplayvalue
     SET dialoguerequest->orderlist[1].detaillist[idx].oefielddttmvalue = rep_oeparse->detaillist[idx
     ].oefielddttmvalue
     SET dialoguerequest->orderlist[1].detaillist[idx].oefieldmeaning = rep_oeparse->detaillist[idx].
     oefieldmeaning
   ENDFOR
   CALL echorecord(dialoguerequest)
   DECLARE link_template = i4
   DECLARE link_personid = f8
   DECLARE link_encntrid = f8
   DECLARE link_orderid = f8
   DECLARE link_accessionid = f8
   DECLARE link_clineventid = f8
   DECLARE link_taskassaycd = f8
   DECLARE link_misc1 = vc
   DECLARE link_tname = vc
   DECLARE trigger_personid = f8
   DECLARE trigger_encntrid = f8
   DECLARE trigger_orderid = f8
   DECLARE trigger_accessionid = f8
   DECLARE log_personid = f8
   DECLARE log_encntrid = f8
   DECLARE log_orderid = f8
   DECLARE log_accessionid = f8
   DECLARE log_clineventid = f8
   DECLARE log_taskassaycd = f8
   DECLARE log_misc1 = vc
   DECLARE log_message = vc
   EXECUTE ndsc_create_session "MINE",  $24, result->ndsc_user,
   result->ndsc_pass, "" WITH replace("REQUEST","DIALOGUEREQUEST")
   CALL echorecord(careselectsessioncreationrequest)
   CALL echorecord(session_info)
   SET result->session_info_json = log_misc1
   RETURN(success)
 END ;Subroutine
END GO
