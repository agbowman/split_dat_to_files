CREATE PROGRAM bhs_athn_add_plan_comment
 DECLARE variance_type = f8 WITH constant(uar_get_code_by("DISPLAY_KEY",24929,"PLANCOMMENT"))
 FREE RECORD orequest
 RECORD orequest(
   1 variancelist[*]
     2 action_meaning = vc
     2 variance_reltn_id = f8
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 event_id = f8
     2 variance_type_cd = f8
     2 action_cd = f8
     2 action_text = vc
     2 action_text_id = f8
     2 action_text_updt_cnt = i4
     2 reason_cd = f8
     2 reason_text = vc
     2 reason_text_id = f8
     2 reason_text_updt_cnt = i4
     2 updt_cnt = i4
     2 active_ind = i2
     2 note_text_id = f8
     2 note_text = vc
     2 note_text_updt_cnt = i4
     2 pathway_id = f8
 )
 FREE RECORD oreply
 RECORD oreply(
   1 variancelist[*]
     2 variance_reltn_id = f8
     2 event_id = f8
     2 parent_entity_id = f8
     2 status_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET oreply->status_data.status = "F"
 IF (((( $2 <= 0)) OR (((( $3 <= 0)) OR (textlen(trim( $4,3)) <= 0)) )) )
  GO TO exit_script
 ENDIF
 FREE RECORD req_format_str
 RECORD req_format_str(
   1 param = vc
 ) WITH protect
 FREE RECORD rep_format_str
 RECORD rep_format_str(
   1 param = vc
 ) WITH protect
 IF (textlen(trim( $4,3)))
  SET req_format_str->param = trim( $4,3)
  EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
   "REP_FORMAT_STR")
 ENDIF
 SET stat = alterlist(orequest->variancelist,1)
 SET orequest->variancelist[1].pathway_id =  $2
 SET orequest->variancelist[1].parent_entity_id =  $2
 SET orequest->variancelist[1].parent_entity_name = "PATHWAY"
 SET orequest->variancelist[1].variance_type_cd = variance_type
 SET orequest->variancelist[1].note_text = rep_format_str->param
 SET orequest->variancelist[1].action_meaning = "CREATE"
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
  CALL echo("impersonate user failed...exiting!")
  SET oreply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SET stat = tdbexecute(600005,601500,601030,"REC",orequest,
  "REC",oreply)
#exit_script
 SET _memory_reply_string = cnvtrectojson(oreply)
END GO
