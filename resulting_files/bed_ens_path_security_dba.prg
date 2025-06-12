CREATE PROGRAM bed_ens_path_security:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 RECORD tempinsertwizardsecurity(
   1 wizard_security[*]
     2 person_id = f8
     2 wizard_meaning = vc
 ) WITH protect
 RECORD tempdeletewizardsecurity(
   1 wizard_security[*]
     2 person_id = f8
     2 wizard_meaning = vc
 ) WITH protect
 RECORD tempinsertpathsecurity(
   1 path_security[*]
     2 person_id = f8
     2 path_meaning = vc
 ) WITH protect
 RECORD tempdeletepathsecurity(
   1 path_security[*]
     2 person_id = f8
     2 path_meaning = vc
 ) WITH protect
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 DECLARE insertwizardseccount = i4 WITH protect, noconstant(0)
 DECLARE deletewizardseccount = i4 WITH protect, noconstant(0)
 DECLARE insertpathseccount = i4 WITH protect, noconstant(0)
 DECLARE deletepathseccount = i4 WITH protect, noconstant(0)
 DECLARE personnelcount = i4 WITH protect, noconstant(0)
 DECLARE wizardcount = i4 WITH protect, noconstant(0)
 DECLARE pathcount = i4 WITH protect, noconstant(0)
 SET insertwizardseccount = 0
 SET deletewizardseccount = 0
 SET insertpathseccount = 0
 SET deletepathseccount = 0
 SET personnelcount = size(request->personnel,5)
 IF (personnelcount=0)
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO personnelcount)
   SET wizardcount = size(request->personnel[i].wizards,5)
   IF (wizardcount > 0)
    FOR (j = 1 TO wizardcount)
      IF ((request->personnel[i].wizards[j].action_flag=1))
       SET insertwizardseccount = (insertwizardseccount+ 1)
       SET stat = alterlist(tempinsertwizardsecurity->wizard_security,insertwizardseccount)
       SET tempinsertwizardsecurity->wizard_security[insertwizardseccount].wizard_meaning = request->
       personnel[i].wizards[j].wizard_meaning
       SET tempinsertwizardsecurity->wizard_security[insertwizardseccount].person_id = request->
       personnel[i].person_id
      ELSEIF ((request->personnel[i].wizards[j].action_flag=3))
       SET deletewizardseccount = (deletewizardseccount+ 1)
       SET stat = alterlist(tempdeletewizardsecurity->wizard_security,deletewizardseccount)
       SET tempdeletewizardsecurity->wizard_security[deletewizardseccount].wizard_meaning = request->
       personnel[i].wizards[j].wizard_meaning
       SET tempdeletewizardsecurity->wizard_security[deletewizardseccount].person_id = request->
       personnel[i].person_id
      ENDIF
    ENDFOR
   ENDIF
   SET pathcount = size(request->personnel[i].paths,5)
   IF (pathcount > 0)
    FOR (j = 1 TO pathcount)
      IF ((request->personnel[i].paths[j].action_flag=1))
       SET insertpathseccount = (insertpathseccount+ 1)
       SET stat = alterlist(tempinsertpathsecurity->path_security,insertpathseccount)
       SET tempinsertpathsecurity->path_security[insertpathseccount].path_meaning = request->
       personnel[i].paths[j].path_meaning
       SET tempinsertpathsecurity->path_security[insertpathseccount].person_id = request->personnel[i
       ].person_id
      ELSEIF ((request->personnel[i].paths[j].action_flag=3))
       SET deletepathseccount = (deletepathseccount+ 1)
       SET stat = alterlist(tempdeletepathsecurity->path_security,deletepathseccount)
       SET tempdeletepathsecurity->path_security[deletepathseccount].path_meaning = request->
       personnel[i].paths[j].path_meaning
       SET tempdeletepathsecurity->path_security[deletepathseccount].person_id = request->personnel[i
       ].person_id
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 IF (deletewizardseccount > 0)
  DELETE  FROM br_name_value bnv,
    (dummyt d  WITH seq = deletewizardseccount)
   SET bnv.seq = 1
   PLAN (d)
    JOIN (bnv
    WHERE bnv.br_nv_key1="WIZARDSECURITY"
     AND bnv.br_name=cnvtstring(tempdeletewizardsecurity->wizard_security[d.seq].person_id)
     AND (bnv.br_value=tempdeletewizardsecurity->wizard_security[d.seq].wizard_meaning))
   WITH nocounter
  ;end delete
  CALL bederrorcheck("Error deleting wizard security")
 ENDIF
 IF (deletepathseccount > 0)
  DELETE  FROM br_name_value bnv,
    (dummyt d  WITH seq = deletepathseccount)
   SET bnv.seq = 1
   PLAN (d)
    JOIN (bnv
    WHERE bnv.br_nv_key1="PATHSECURITY"
     AND bnv.br_name=cnvtstring(tempdeletepathsecurity->path_security[d.seq].person_id)
     AND (bnv.br_value=tempdeletepathsecurity->path_security[d.seq].path_meaning))
   WITH nocounter
  ;end delete
  CALL bederrorcheck("Error deleting path security")
 ENDIF
 IF (insertwizardseccount > 0)
  INSERT  FROM br_name_value bnv,
    (dummyt d  WITH seq = insertwizardseccount)
   SET bnv.br_name_value_id = seq(bedrock_seq,nextval), bnv.br_nv_key1 = "WIZARDSECURITY", bnv
    .br_name = cnvtstring(tempinsertwizardsecurity->wizard_security[d.seq].person_id,20),
    bnv.br_value = tempinsertwizardsecurity->wizard_security[d.seq].wizard_meaning, bnv.updt_cnt = 0,
    bnv.updt_applctx = reqinfo->updt_applctx,
    bnv.updt_dt_tm = cnvtdatetime(curdate,curtime3), bnv.updt_id = reqinfo->updt_id, bnv.updt_task =
    reqinfo->updt_task
   PLAN (d)
    JOIN (bnv)
   WITH nocounter
  ;end insert
  CALL bederrorcheck("Error inserting wizard security")
 ENDIF
 IF (insertpathseccount > 0)
  INSERT  FROM br_name_value bnv,
    (dummyt d  WITH seq = insertpathseccount)
   SET bnv.br_name_value_id = seq(bedrock_seq,nextval), bnv.br_nv_key1 = "PATHSECURITY", bnv.br_name
     = cnvtstring(tempinsertpathsecurity->path_security[d.seq].person_id,20),
    bnv.br_value = tempinsertpathsecurity->path_security[d.seq].path_meaning, bnv.updt_cnt = 0, bnv
    .updt_applctx = reqinfo->updt_applctx,
    bnv.updt_dt_tm = cnvtdatetime(curdate,curtime3), bnv.updt_id = reqinfo->updt_id, bnv.updt_task =
    reqinfo->updt_task
   PLAN (d)
    JOIN (bnv)
   WITH nocounter
  ;end insert
  CALL bederrorcheck("Error inserting path security")
 ENDIF
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
