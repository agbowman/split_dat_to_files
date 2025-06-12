CREATE PROGRAM dcp_add_cust_interaction:dba
 FREE SET reply
 RECORD reply(
   1 error_string = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE failed = c1 WITH public, noconstant("F")
 DECLARE count1 = i4 WITH public, noconstant(0)
 IF (validate(dcp_entity_reltn_id)=0)
  DECLARE dcp_entity_reltn_id = f8 WITH public, noconstant(0.0)
 ENDIF
 IF (validate(old_dcp_entity_reltn_id)=0)
  DECLARE old_dcp_entity_reltn_id = f8 WITH public, noconstant(0.0)
 ENDIF
 DECLARE long_text_id = f8 WITH public, noconstant(0.0)
 DECLARE old_dcp_entity_reltn_id = f8 WITH public, noconstant(0.0)
 DECLARE entity1_id = f8 WITH public, noconstant(0.0)
 DECLARE entity2_id = f8 WITH public, noconstant(0.0)
 DECLARE entity1_name = c32 WITH public, noconstant("")
 DECLARE entity2_name = c32 WITH public, noconstant("")
 DECLARE tmp_long_text = vc
 SET reply->status_data.status = "F"
 SET errmsg = fillstring(132," ")
 IF ((request->entity_reltn_mean != "ALGCAT/DRUG"))
  IF ((request->entity1_id < request->entity2_id))
   SET entity1_id = request->entity1_id
   SET entity1_display = trim(request->entity1_display)
   SET entity2_id = request->entity2_id
   SET entity2_display = trim(request->entity2_display)
  ELSE
   SET entity1_id = request->entity2_id
   SET entity1_display = trim(request->entity2_display)
   SET entity2_id = request->entity1_id
   SET entity2_display = trim(request->entity1_display)
  ENDIF
  CALL echo(build("The value of entity1_id after reordering:",entity1_id))
  CALL echo(build("The value of entity1_display after reordering:",entity1_display))
  CALL echo(build("The value of entity2_id after reordering:",entity2_id))
  CALL echo(build("The value of entity2_display after reordering:",entity2_display))
 ELSE
  SET entity1_id = request->entity1_id
  SET entity1_display = trim(request->entity1_display)
  SET entity2_id = request->entity2_id
  SET entity2_display = trim(request->entity2_display)
  CALL echo("ALGCAT/DRUG - no reordering needed")
 ENDIF
 IF ((((request->entity_reltn_mean="DRUG/DRUG")) OR ((request->entity_reltn_mean="DRUG/ALLERGY"))) )
  SET entity1_name = request->entity1_name
  SET entity2_name = "DRUG"
 ELSEIF ((request->entity_reltn_mean="DRUG/FOOD"))
  SET entity1_name = "FOOD"
  SET entity2_name = "DRUG"
 ELSEIF ((request->entity_reltn_mean="TDC/SUPP"))
  SET entity1_name = "SUPP"
  SET entity2_name = "DRUG"
 ELSEIF ((request->entity_reltn_mean="DRUG/TEXT"))
  SET entity1_name = "TEXT"
  SET entity2_name = "DRUG"
 ELSEIF ((request->entity_reltn_mean="ALGCAT/DRUG"))
  SET entity1_name = "ALGCAT"
  SET entity2_name = "DRUG"
 ELSEIF ((request->entity_reltn_mean="DRUG/RULE"))
  SET entity1_name = "RULE"
  SET entity2_name = "DRUG"
 ELSE
  SET entity1_name = ""
  SET entity2_name = ""
 ENDIF
 SELECT INTO "nl:"
  d.dcp_entity_reltn_id, d.entity_reltn_mean, d.entity1_id,
  d.entity2_id, d.active_ind
  FROM dcp_entity_reltn d
  WHERE d.entity1_id=entity1_id
   AND d.entity2_id=entity2_id
   AND d.active_ind=1
   AND d.entity_reltn_mean=trim(request->entity_reltn_mean)
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1), old_dcp_entity_reltn_id = d.dcp_entity_reltn_id
  WITH nocounter
 ;end select
 IF (count1=0)
  CALL echo("No customization exists to update")
 ELSEIF (count1 > 1)
  SET failed = "T"
  CALL echo("More than one customization already exists")
  GO TO exit_script
 ELSE
  CALL echo(build("Deleting DRUG_CLASS_INT_CSTM_ENTITY_R row: ",cnvtstring(old_dcp_entity_reltn_id)))
  SELECT INTO "nl:"
   dc.dcp_entity_reltn_id
   FROM drug_class_int_cstm_entity_r dc
   WHERE dc.dcp_entity_reltn_id=old_dcp_entity_reltn_id
   WITH nocounter
  ;end select
  IF (curqual > 0)
   DELETE  FROM drug_class_int_cstm_entity_r dcer
    WHERE dcer.dcp_entity_reltn_id=old_dcp_entity_reltn_id
    WITH nocounter
   ;end delete
   SET errorcode = error(errmsg,0)
   IF (errorcode != 0)
    SET failed = "T"
    SET reply->error_string = "Could not delete from DRUG_CLASS_INT_CSTM_ENTITY_R table"
    SET reply->status_data.subeventstatus[1].operationname = "Delete"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "ErrorMessage"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
    GO TO exit_script
   ENDIF
  ENDIF
  CALL echo(build("Updating into DCP_ENTITY_RELTN table:",old_dcp_entity_reltn_id))
  UPDATE  FROM dcp_entity_reltn d
   SET d.active_ind = 0, d.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    d.updt_cnt = (d.updt_cnt+ 1), d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task,
    d.updt_applctx = reqinfo->updt_applctx
   WHERE d.dcp_entity_reltn_id=old_dcp_entity_reltn_id
  ;end update
  SET errorcode = error(errmsg,0)
  IF (errorcode != 0)
   SET failed = "T"
   SET reply->error_string = "Could not update into DCP_ENTITY_RELTN table"
   SET reply->status_data.subeventstatus[1].operationname = "Update"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "ErrorMessage"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
   GO TO exit_script
  ENDIF
  UPDATE  FROM long_text b
   SET b.active_ind = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_cnt = (b.updt_cnt+ 1),
    b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
    updt_applctx
   WHERE b.parent_entity_id=old_dcp_entity_reltn_id
    AND b.parent_entity_name="DCP_ENTITY_RELTN"
  ;end update
  IF (curqual=0)
   CALL echo(build("No message found to update on LONG_TEXT table for parent_id:",
     old_dcp_entity_reltn_id))
  ELSE
   CALL echo(build("Updating into LONG_TEXT table for parent_id:",old_dcp_entity_reltn_id))
  ENDIF
 ENDIF
 IF ((request->activate=false))
  CALL echo(build("Customization has been deleted because activate = false"))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  nextseqnum = seq(carenet_seq,nextval)"######################;rp0"
  FROM dual
  DETAIL
   dcp_entity_reltn_id = cnvtreal(nextseqnum)
  WITH format, nocounter
 ;end select
 IF (curqual=0)
  SET failed = "T"
  CALL echo("Could not get dcp_entity_reltn_id")
  GO TO exit_script
 ENDIF
 CALL echo(build("Inserting into DCP_ENTITY_RELTN table:",dcp_entity_reltn_id))
 INSERT  FROM dcp_entity_reltn d
  SET d.dcp_entity_reltn_id = dcp_entity_reltn_id, d.entity_reltn_mean = trim(request->
    entity_reltn_mean), d.entity1_id = entity1_id,
   d.entity1_display = entity1_display, d.entity2_id = entity2_id, d.entity2_display =
   entity2_display,
   d.rank_sequence = request->rank_sequence, d.active_ind = 1, d.begin_effective_dt_tm = cnvtdatetime
   (curdate,curtime3),
   d.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"), d.updt_dt_tm = cnvtdatetime(
    curdate,curtime3), d.updt_id = reqinfo->updt_id,
   d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->updt_applctx, d.updt_cnt = 0,
   d.entity1_name = entity1_name, d.entity2_name = entity2_name
  WITH nocounter
 ;end insert
 SET errorcode = error(errmsg,0)
 IF (errorcode != 0)
  SET failed = "T"
  SET reply->error_string = "Could not insert into DCP_ENTITY_RELTN table"
  SET reply->status_data.subeventstatus[1].operationname = "Insert"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ErrorMessage"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
  GO TO exit_script
 ENDIF
 IF ((request->rank_sequence=0))
  CALL echo(build("No message for customization because rank_sequence equal to zero"))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  nextseqnum = seq(long_data_seq,nextval)"######################;rp0"
  FROM dual
  DETAIL
   long_text_id = cnvtreal(nextseqnum)
  WITH format, nocounter
 ;end select
 IF (curqual=0)
  SET failed = "T"
  CALL echo("Could not get long_text_id")
  GO TO exit_script
 ENDIF
 IF ((request->long_text > " "))
  SET tmp_long_text = trim(request->long_text)
 ELSE
  SET tmp_long_text = " "
 ENDIF
 CALL echo(build("Inserting into LONG_TEXT table:",long_text_id))
 INSERT  FROM long_text l
  SET l.active_ind = 1, l.active_status_cd = reqdata->active_status_cd, l.active_status_dt_tm =
   cnvtdatetime(curdate,curtime3),
   l.active_status_prsnl_id = reqinfo->updt_id, l.long_text = tmp_long_text, l.long_text_id =
   long_text_id,
   l.parent_entity_name = "DCP_ENTITY_RELTN", l.parent_entity_id = dcp_entity_reltn_id, l.updt_dt_tm
    = cnvtdatetime(curdate,curtime3),
   l.updt_id = reqinfo->updt_id, l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->
   updt_applctx,
   l.updt_cnt = 0
  WITH nocounter
 ;end insert
 SET errorcode = error(errmsg,0)
 IF (errorcode != 0)
  SET failed = "T"
  SET reply->error_string = "Could not insert into LONG_TEXT table"
  SET reply->status_data.subeventstatus[1].operationname = "Insert"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ErrorMessage"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
