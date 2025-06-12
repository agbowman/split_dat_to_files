CREATE PROGRAM cmn_stw_test:dba
 PROMPT
  "output device:  " = mine,
  "bedrock meaning [VB_STWLABS]: " = "VB_STWLABS",
  "person id: " = 0.0,
  "encounter id: " = 0.0,
  "prsnl id: " = 0.0
  WITH outdev, bedrockid, personid,
  encntrid, prsnlid
 FREE RECORD request
 RECORD request(
   1 output_device = vc
   1 script_name = vc
   1 person_cnt = i4
   1 person[*]
     2 person_id = f8
   1 visit_cnt = i4
   1 visit[*]
     2 encntr_id = f8
   1 prsnl_cnt = i4
   1 prsnl[*]
     2 prsnl_id = f8
   1 nv_cnt = i4
   1 nv[*]
     2 pvc_name = vc
     2 pvc_value = vc
   1 batch_selection = vc
   1 print_pref = i2
 )
 RECORD reply(
   1 text = vc
   1 large_text_qual[*]
     2 text_segment = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE PUBLIC::showmessage(id_ten_t=vc) = null
 SUBROUTINE PUBLIC::showmessage(id_ten_t)
   SET reply->text = id_ten_t
   SELECT
    x = 0
    FROM dummyt
    DETAIL
     id_ten_t
    WITH nocounter
   ;end select
   CALL echo("")
   CALL echo("*******************************************************************************")
   CALL echo(id_ten_t)
   CALL echo("*******************************************************************************")
   CALL echo("")
   SET reply->status_data.status = "F"
   GO TO exit_script
 END ;Subroutine
 IF ((reqinfo->updt_id=0.0))
  CALL showmessage("The CCL session must be authenticated when running this script")
 ENDIF
 IF (( $PERSONID=0.0))
  CALL showmessage("A PERSON ID must be provided when running this script")
 ENDIF
 IF (( $PRSNLID=0.0))
  CALL showmessage("A PRSNL ID must be provided when running this script")
 ENDIF
 SET request->script_name = concat("smart_template_wizard__driver_", $BEDROCKID)
 SET request->person_cnt = 1
 SET stat = alterlist(request->person,1)
 SET request->person[1].person_id =  $PERSONID
 SET request->visit_cnt = 1
 SET stat = alterlist(request->visit,1)
 SET request->visit[1].encntr_id =  $ENCNTRID
 SET request->prsnl_cnt = 1
 SET stat = alterlist(request->prsnl,1)
 SET request->prsnl[1].prsnl_id =  $PRSNLID
 DECLARE debug_ind = i2 WITH protect, constant(1)
 EXECUTE dcp_rpt_driver
#exit_script
 IF (validate(_memory_reply_string)=true)
  SET _memory_reply_string = cnvtrectojson(reply)
 ENDIF
END GO
