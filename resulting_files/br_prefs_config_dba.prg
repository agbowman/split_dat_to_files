CREATE PROGRAM br_prefs_config:dba
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
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting <br_prefs_config.prg> script"
 FREE SET tprefs
 RECORD tprefs(
   1 prefs[*]
     2 id = f8
     2 parent_id = f8
     2 pvc_name = vc
     2 bedrock_name = vc
     2 default_value = vc
     2 code_level = vc
     2 codeset = i4
     2 view_name = vc
     2 type_flag = i4
 )
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 SET req_cnt = size(requestin->list_0,5)
 IF (req_cnt=0)
  SET readme_data->status = "F"
  SET readme_data->message = "Readme failed: br_prefs.csv has zero rows"
  GO TO exit_script
 ENDIF
 SET stat = alterlist(tprefs->prefs,req_cnt)
 SET parent_id = 0.0
 DELETE  FROM br_prefs b
  WHERE b.seq=1
  WITH nocounter
 ;end delete
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: Delete from br_prefs: ",errmsg)
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO req_cnt)
   SELECT INTO "NL:"
    j = seq(bedrock_seq,nextval)"##################;rp0"
    FROM dual du
    PLAN (du)
    DETAIL
     tprefs->prefs[x].id = cnvtreal(j)
    WITH format, counter
   ;end select
   SET tprefs->prefs[x].bedrock_name = requestin->list_0[x].bedrock_name
   SET tprefs->prefs[x].code_level = requestin->list_0[x].code_level
   SET tprefs->prefs[x].default_value = requestin->list_0[x].default_value
   SET tprefs->prefs[x].type_flag = cnvtint(requestin->list_0[x].type_flag)
   SET tprefs->prefs[x].view_name = requestin->list_0[x].view_name
   IF ((requestin->list_0[x].parent_pvc_name > " "))
    SET tprefs->prefs[x].pvc_name = requestin->list_0[x].parent_pvc_name
    SET parent_id = tprefs->prefs[x].id
   ENDIF
   IF (parent_id > 0
    AND (requestin->list_0[x].child_pvc_name > " "))
    SET tprefs->prefs[x].pvc_name = requestin->list_0[x].child_pvc_name
    SET tprefs->prefs[x].parent_id = parent_id
   ENDIF
 ENDFOR
 INSERT  FROM br_prefs b,
   (dummyt d  WITH seq = value(req_cnt))
  SET b.br_prefs_id = tprefs->prefs[d.seq].id, b.br_name = tprefs->prefs[d.seq].bedrock_name, b
   .code_level = tprefs->prefs[d.seq].code_level,
   b.default_value = tprefs->prefs[d.seq].default_value, b.parent_prefs_id = tprefs->prefs[d.seq].
   parent_id, b.pvc_name = tprefs->prefs[d.seq].pvc_name,
   b.type_flag = tprefs->prefs[d.seq].type_flag, b.view_name = tprefs->prefs[d.seq].view_name, b
   .updt_cnt = 0,
   b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_applctx =
   reqinfo->updt_applctx,
   b.updt_task = reqinfo->updt_task
  PLAN (d)
   JOIN (b)
  WITH nocounter
 ;end insert
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: Insert into br_prefs: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_prefs_config.prg> script"
#exit_script
 FREE RECORD tprefs
END GO
