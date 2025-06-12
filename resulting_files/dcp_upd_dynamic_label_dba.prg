CREATE PROGRAM dcp_upd_dynamic_label:dba
 RECORD reply(
   1 dta_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD version_request(
   1 task_assay_cd = f8
 )
 RECORD version_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD dta_request(
   1 label_id = f8
 )
 RECORD dta_reply(
   1 dta_cnt = i4
   1 label_id = f8
   1 dta_list[*]
     2 task_assay_cd = f8
     2 are_part_of_input = i4
     2 ver_chg_flag = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET modify = predeclare
 DECLARE newlabelid = f8 WITH noconstant(0.0)
 DECLARE dtacnt = i4 WITH noconstant(0)
 DECLARE dta_count = i4 WITH noconstant(0)
 DECLARE located = i4 WITH noconstant(0)
 DECLARE labelnum = i4 WITH noconstant(0), public
 DECLARE addnew = i2
 DECLARE failed = vc
 SUBROUTINE createdtaversion(dtacnt,newlabelid,newind)
  IF (newind=1)
   FOR (tempvar = 1 TO dtacnt)
     SET version_request->task_assay_cd = request->dta_name_code[tempvar].task_assay_cd
     EXECUTE dcp_add_dta_version  WITH replace("REQUEST","VERSION_REQUEST"), replace("REPLY",
      "VERSION_REPLY")
     UPDATE  FROM discrete_task_assay dta
      SET dta.label_template_id = newlabelid
      WHERE (dta.task_assay_cd=request->dta_name_code[tempvar].task_assay_cd)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = "T"
      GO TO exit_script
     ENDIF
   ENDFOR
  ELSE
   FOR (tempvar = 1 TO dtacnt)
    IF ((dta_reply->dta_list[tempvar].ver_chg_flag=1))
     SET version_request->task_assay_cd = dta_reply->dta_list[tempvar].task_assay_cd
     EXECUTE dcp_add_dta_version  WITH replace("REQUEST","VERSION_REQUEST"), replace("REPLY",
      "VERSION_REPLY")
    ENDIF
    IF ((dta_reply->dta_list[tempvar].are_part_of_input=0))
     UPDATE  FROM discrete_task_assay dta
      SET dta.label_template_id = 0
      WHERE (dta.task_assay_cd=dta_reply->dta_list[tempvar].task_assay_cd)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = "T"
      GO TO exit_script
     ENDIF
    ELSEIF ((dta_reply->dta_list[tempvar].ver_chg_flag=1)
     AND (dta_reply->dta_list[tempvar].are_part_of_input=1))
     UPDATE  FROM discrete_task_assay dta
      SET dta.label_template_id = request->label_id
      WHERE (dta.task_assay_cd=dta_reply->dta_list[tempvar].task_assay_cd)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = "T"
      GO TO exit_script
     ENDIF
    ENDIF
   ENDFOR
  ENDIF
  SET failed = "F"
 END ;Subroutine
 SET dtacnt = size(request->dta_name_code,5)
 SET failed = "T"
 IF ((request->doc_set_ref_id=0.0))
  SET failed = "T"
  GO TO exit_script
 ENDIF
 IF (dtacnt=0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 IF ((request->label_id=0))
  SELECT INTO "nl:"
   tempj = seq(reference_seq,nextval)
   FROM dual
   DETAIL
    newlabelid = cnvtreal(tempj)
   WITH format, nocounter
  ;end select
  INSERT  FROM dynamic_label_template dlt
   SET dlt.label_template_id = newlabelid, dlt.doc_set_ref_id = request->doc_set_ref_id, dlt.updt_cnt
     = 0,
    dlt.updt_id = reqinfo->updt_id, dlt.updt_task = reqinfo->updt_task, dlt.updt_applctx = reqinfo->
    updt_applctx,
    dlt.updt_dt_tm = cnvtdatetime(curdate,curtime3), dlt.encounter_specific_ind = request->
    encounter_specific_ind
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   GO TO exit_script
  ENDIF
  SET addnew = 1
  CALL createdtaversion(dtacnt,newlabelid,addnew)
 ELSE
  UPDATE  FROM dynamic_label_template dlt
   SET dlt.updt_cnt = (dlt.updt_cnt+ 1), dlt.updt_id = reqinfo->updt_id, dlt.updt_task = reqinfo->
    updt_task,
    dlt.updt_applctx = reqinfo->updt_applctx, dlt.updt_dt_tm = cnvtdatetime(curdate,curtime3), dlt
    .encounter_specific_ind = request->encounter_specific_ind
   WHERE (dlt.label_template_id=request->label_id)
   WITH nocounter
  ;end update
  SET dta_request->label_id = request->label_id
  SELECT INTO "nl:"
   FROM discrete_task_assay dta
   WHERE (dta.label_template_id=dta_request->label_id)
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1)
    IF (mod(count1,10)=1)
     stat = alterlist(dta_reply->dta_list,(count1+ 9))
    ENDIF
    dta_reply->dta_list[count1].task_assay_cd = dta.task_assay_cd, dta_reply->dta_list[count1].
    are_part_of_input = 0, dta_reply->dta_list[count1].ver_chg_flag = 0
   FOOT REPORT
    stat = alterlist(dta_reply->dta_list,count1), dta_reply->dta_cnt = count1, dta_reply->label_id =
    dta_request->label_id
   WITH counter
  ;end select
  SET dta_count = dta_reply->dta_cnt
  DECLARE increment = i4
  DECLARE stat1 = i4
  FOR (tempvar = 1 TO dtacnt)
    SET located = 0
    IF (dta_count > 0)
     SET located = locateval(labelnum,1,dta_count,request->dta_name_code[tempvar].task_assay_cd,
      dta_reply->dta_list[labelnum].task_assay_cd)
    ENDIF
    IF (located != 0)
     SET dta_reply->dta_list[located].are_part_of_input = 1
     SET dta_reply->dta_list[located].ver_chg_flag = 0
    ELSE
     SET increment = (size(dta_reply->dta_list,5)+ 1)
     SET stat1 = alterlist(dta_reply->dta_list,increment)
     SET dta_reply->dta_list[increment].task_assay_cd = request->dta_name_code[tempvar].task_assay_cd
     SET dta_reply->dta_list[increment].are_part_of_input = 1
     SET dta_reply->dta_list[increment].ver_chg_flag = 1
    ENDIF
  ENDFOR
  SET addnew = 0
  SET dtacnt = size(dta_reply->dta_list,5)
  CALL createdtaversion(dtacnt,newlabelid,addnew)
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
