CREATE PROGRAM dcp_upd_plan_order_sent_rdm:dba
 SET modify = predeclare
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
 DECLARE count = i4 WITH protect, noconstant(0)
 DECLARE fieldvalueint = i4 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE x = i4 WITH protect, noconstant(0)
 DECLARE strengthdoseunitid = f8 WITH protect, noconstant(0.0)
 DECLARE volumedoseunitid = f8 WITH protect, noconstant(0.0)
 DECLARE stat = i2
 DECLARE errorcode = i4
 DECLARE errormsg = c132
 DECLARE berror = i2
 SET errormsg = fillstring(132," ")
 SET errorcode = 1
 SET berror = 0
 SET readme_data->status = "F"
 SET readme_data->message = "Failed - Starting DCP_UPD_PLAN_ORDER_SENT_RDM.PRG script"
 FREE RECORD needupdated
 RECORD needupdated(
   1 qual[*]
     2 order_sent_id = f8
     2 pathway_comp_id = f8
 )
 SELECT INTO "nl:"
  FROM oe_field_meaning ofm
  WHERE ofm.oe_field_meaning IN ("STRENGTHDOSEUNIT", "VOLUMEDOSEUNIT")
  DETAIL
   IF (ofm.oe_field_meaning="STRENGTHDOSEUNIT")
    strengthdoseunitid = ofm.oe_field_meaning_id
   ELSEIF (ofm.oe_field_meaning="VOLUMEDOSEUNIT")
    volumedoseunitid = ofm.oe_field_meaning_id
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM pw_comp_os_reltn pcor,
   order_sentence_detail osd,
   code_value_extension cve
  PLAN (pcor)
   JOIN (osd
   WHERE (osd.order_sentence_id=(pcor.order_sentence_id+ 0))
    AND ((osd.oe_field_meaning_id+ 0) IN (strengthdoseunitid, volumedoseunitid)))
   JOIN (cve
   WHERE (cve.code_value=(osd.default_parent_entity_id+ 0))
    AND trim(cve.field_name)="PHARM_UNIT"
    AND ((cve.code_set+ 0)=54))
  HEAD REPORT
   count = 0
  DETAIL
   fieldvalueint = cnvtint(cve.field_value)
   IF (band(fieldvalueint,32)=32)
    IF (pcor.normalized_dose_unit_ind=0)
     count = (count+ 1)
     IF (count > size(needupdated->qual,5))
      stat = alterlist(needupdated->qual,(count+ 10))
     ENDIF
     needupdated->qual[count].order_sent_id = pcor.order_sentence_id, needupdated->qual[count].
     pathway_comp_id = pcor.pathway_comp_id
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(needupdated->qual,count)
  WITH nocounter
 ;end select
 IF (count=0)
  GO TO exit_program
 ENDIF
 FOR (x = 1 TO count)
  UPDATE  FROM pw_comp_os_reltn pcor
   SET pcor.normalized_dose_unit_ind = 1, pcor.updt_task = reqinfo->updt_task
   WHERE (pcor.order_sentence_id=needupdated->qual[x].order_sent_id)
    AND (pcor.pathway_comp_id=needupdated->qual[x].pathway_comp_id)
   WITH nocounter
  ;end update
  IF (((mod(x,100)=0) OR (x=count)) )
   WHILE (errorcode != 0)
    SET errorcode = error(errormsg,0)
    IF (errorcode != 0)
     ROLLBACK
     SET berror = 1
     SET readme_data->status = "F"
     SET readme_data->message = concat("Failed - Error occurred while updating PW_COMP_OS_RELTN: ",
      trim(errormsg))
     GO TO exit_program
    ENDIF
   ENDWHILE
   SET errorcode = 1
   COMMIT
  ENDIF
 ENDFOR
#exit_program
 FREE RECORD needupdated
 IF (berror=0)
  CALL echo(build("Updated:",count," rows"))
  SET readme_data->status = "S"
  SET readme_data->message = "Success - All required pathway rows were updated successfully."
 ENDIF
 SET modify = nopredeclare
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
