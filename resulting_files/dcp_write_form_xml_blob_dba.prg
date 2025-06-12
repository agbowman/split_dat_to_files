CREATE PROGRAM dcp_write_form_xml_blob:dba
 SET modify = predeclare
 SET modify maxvarlen 20971520
 DECLARE reportfailure(opname=vc,opstatus=vc,targetname=vc,targetvalue=vc) = null
 DECLARE fillsubeventstatus(opname=vc,opstatus=vc,objname=vc,objvalue=vc) = null
 SUBROUTINE reportfailure(opname,opstatus,targetname,targetvalue)
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus(opname,opstatus,targetname,targetvalue)
 END ;Subroutine
 SUBROUTINE fillsubeventstatus(opname,opstatus,objname,objvalue)
   DECLARE dcp_substatus_cnt = i4 WITH protect, noconstant(size(reply->status_data.subeventstatus,5))
   SET dcp_substatus_cnt = (dcp_substatus_cnt+ 1)
   IF (dcp_substatus_cnt != 1)
    SET stat = alter(reply->status_data.subeventstatus,dcp_substatus_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectname = trim(objname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectvalue = trim(objvalue)
 END ;Subroutine
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE formid = f8 WITH noconstant(0)
 SET formid = request->dcp_forms_activity_id
 IF (formid=0)
  SET failed = "T"
  CALL fillsubeventstatus("INSERT","F","dcp_write_form_xml_blob",
   "Failed to insert a row relavent tables.")
  GO TO exit_script
 ENDIF
 DECLARE blobcd = f8 WITH noconstant(uar_get_code_by("MEANING",18189,nullterm("FORMXML")))
 DECLARE blobid = f8 WITH noconstant(0)
 DECLARE new_long_blob_id = f8 WITH noconstant(0)
 DECLARE commit_ind = i2 WITH public, noconstant(0)
 DECLARE failed = c1 WITH public, noconstant("F")
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE ierrorcode = i2 WITH protect, noconstant(0)
 DECLARE datatocompress = vc WITH noconstant(request->long_blob)
 DECLARE inlen = i4 WITH noconstant(size(datatocompress))
 DECLARE outbuffer = vc WITH noconstant(" ")
 SET outbuffer = datatocompress
 DECLARE outlen = i4 WITH noconstant(0)
 DECLARE iret = i4 WITH noconstant(0)
 DECLARE script_version = vc WITH protect, noconstant("")
 SET iret = uar_ocf_compress(datatocompress,size(datatocompress),outbuffer,size(outbuffer),outlen)
 SET outbuffer = substring(1,outlen,outbuffer)
 DECLARE writeformxml() = null
 DECLARE update_blob() = null
 DECLARE update_comp() = null
 DECLARE insert_blob() = null
 DECLARE insert_comp() = null
 CALL writeformxml(null)
 SUBROUTINE writeformxml(dummyvar)
  SELECT INTO "nl:"
   FROM dcp_forms_activity_comp comp
   WHERE (comp.dcp_forms_activity_id=request->dcp_forms_activity_id)
    AND comp.component_cd=blobcd
   DETAIL
    blobid = comp.parent_entity_id
   WITH nocounter
  ;end select
  IF (curqual > 0)
   CALL update_blob(null)
   CALL update_comp(null)
  ELSE
   CALL insert_blob(null)
   CALL insert_comp(null)
  ENDIF
 END ;Subroutine
 SUBROUTINE insert_blob(dummyvar)
   SELECT INTO "nl:"
    nextseqnum = seq(long_data_seq,nextval)
    FROM dual
    DETAIL
     new_long_blob_id = cnvtreal(nextseqnum)
    WITH nocounter
   ;end select
   INSERT  FROM long_blob lb
    SET lb.long_blob_id = new_long_blob_id, lb.long_blob = outbuffer, lb.active_ind = 1,
     lb.updt_dt_tm = cnvtdatetime(curdate,curtime3), lb.updt_id = reqinfo->updt_id, lb.updt_task =
     reqinfo->updt_task,
     lb.updt_applctx = reqinfo->updt_applctx, lb.updt_cnt = 0, lb.parent_entity_name =
     "DCP_FORMS_ACTIVITY_COMP"
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = "T"
    CALL fillsubeventstatus("INSERT","F","dcp_write_form_xml_blob",
     "Failed to insert a row into long_blob table.")
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE insert_comp(dummyvar)
  INSERT  FROM dcp_forms_activity_comp ac
   SET ac.dcp_forms_activity_comp_id = seq(carenet_seq,nextval), ac.parent_entity_id =
    new_long_blob_id, ac.parent_entity_name = "LONG_BLOB",
    ac.dcp_forms_activity_id = request->dcp_forms_activity_id, ac.component_cd = blobcd, ac
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    ac.updt_id = reqinfo->updt_id, ac.updt_task = reqinfo->updt_task, ac.updt_applctx = reqinfo->
    updt_applctx,
    ac.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   CALL fillsubeventstatus("INSERT","F","dcp_write_form_xml_blob",
    "Failed to insert a row into dcp_form_activity_comp table.")
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE update_blob(dummyvar)
  UPDATE  FROM long_blob lb
   SET lb.long_blob = outbuffer, lb.updt_dt_tm = cnvtdatetime(curdate,curtime3), lb.updt_id = reqinfo
    ->updt_id,
    lb.updt_task = reqinfo->updt_task, lb.updt_applctx = reqinfo->updt_applctx, lb.updt_cnt = (
    updt_cnt+ 1),
    lb.parent_entity_name = "DCP_FORMS_ACTIVITY_COMP"
   WHERE lb.long_blob_id=blobid
    AND lb.active_ind=1
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   CALL fillsubeventstatus("UPDATE","F","dcp_write_form_xml_blob",
    "Failed to update a row into long_blob.")
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE update_comp(dummyvar)
  UPDATE  FROM dcp_forms_activity_comp ac
   SET ac.updt_dt_tm = cnvtdatetime(curdate,curtime3), ac.updt_id = reqinfo->updt_id, ac.updt_task =
    reqinfo->updt_task,
    ac.updt_applctx = reqinfo->updt_applctx, ac.updt_cnt = (updt_cnt+ 1)
   WHERE ac.parent_entity_id=blobid
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   CALL fillsubeventstatus("UPDATE","F","dcp_write_form_xml_blob",
    "Failed to update a row into dcp_forms_activity_comp.")
   GO TO exit_script
  ENDIF
 END ;Subroutine
#exit_script
 SET ierrorcode = error(serrormsg,1)
 IF (ierrorcode != 0)
  CALL echo(build("ERROR CODE: ",ierrorcode))
  CALL echo(build("ERROR MESSAGE: ",serrormsg))
  CALL reportfailure("ERROR","F","dcp_write_form_xml_blob",serrormsg)
  SET reqinfo->commit_ind = 0
 ELSEIF (failed="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 SET script_version = "Ver.2"
 CALL echo(build("Last Modified = ",script_version))
 SET modify = nopredeclare
END GO
