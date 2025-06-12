CREATE PROGRAM dts_add_upd_trans_queue:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET value = 0
 DECLARE code_value = f8 WITH public, noconstant(0.0)
 SET cdf_meaning = fillstring(12," ")
 DECLARE default_cd = f8 WITH public, noconstant(0.0)
 DECLARE contributor_system_cd = f8 WITH public, noconstant(0.0)
 DECLARE queue_id = f8 WITH public, noconstant(0.0)
 CALL echo("Just entered dealias contributor system...")
 SET code_set = 73
 SET cdf_meaning = "DEFAULT"
 EXECUTE cpm_get_cd_for_cdf
 SET default_cd = code_value
 CALL echo(build("code value of DEFAULT _",default_cd))
 IF ((request->contributor_system > " "))
  SET code_set = 89
  SELECT INTO "nl:"
   ca.code_value
   FROM code_value_alias ca
   WHERE ca.code_set=code_set
    AND ca.contributor_source_cd=default_cd
    AND (ca.alias=request->contributor_system)
    AND ca.code_value >= 0
   DETAIL
    contributor_system_cd = ca.code_value
   WITH nocounter
  ;end select
  CALL echo(build("Found contributor system cd _",contributor_system_cd))
  SELECT INTO "nl:"
   cs.contributor_source_cd
   FROM contributor_system cs
   WHERE cs.contributor_system_cd=contributor_system_cd
   DETAIL
    request->contributor_source_cd = cs.contributor_source_cd
   WITH nocounter
  ;end select
  CALL echo(build("Found contributor source cd _",request->contributor_source_cd))
 ENDIF
 CALL echo("Just entered check for insert or update...")
 SELECT INTO "nl:"
  dts.trans_name
  FROM dts_trans_queue dts
  WHERE (dts.trans_name=request->trans_name)
  DETAIL
   value = 1
  WITH nocounter
 ;end select
 IF (value=0)
  CALL echo("Just entered INSERT...")
  SET queue_id = 0
  SELECT INTO "nl:"
   nextseqnum = seq(dts_seq,nextval)"#################;rp0"
   FROM dual
   DETAIL
    queue_id = cnvtreal(nextseqnum)
   WITH format, counter
  ;end select
  CALL echo(build("queue_id = ",queue_id))
  IF (curqual=0)
   SET failed = "T"
   GO TO exit_script
  ENDIF
  INSERT  FROM dts_trans_queue d
   SET d.queue_id = queue_id, d.trans_name = request->trans_name, d.author_name = request->
    author_name,
    d.cosign_name = request->cosign_name, d.doc_type_alias = request->doc_type_alias, d
    .contributor_source_cd = request->contributor_source_cd,
    d.accession_nbr = request->accession_nbr, d.order_id = request->order_id, d.patient_info =
    request->patient_info,
    d.dictation_dt_tm = cnvtdatetime(request->dictation_dt_tm), d.dictation_tz = request->
    dictation_tz, d.dictation_length = request->dictation_length,
    d.job_nbr = request->job_nbr, d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_id = reqinfo
    ->updt_id,
    d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->updt_applctx, d.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ELSE
  CALL echo("Just entered UPDATE...")
  UPDATE  FROM dts_trans_queue d
   SET d.trans_name = request->trans_name, d.author_name = request->author_name, d.cosign_name =
    request->cosign_name,
    d.doc_type_alias = request->doc_type_alias, d.contributor_source_cd = request->
    contributor_source_cd, d.accession_nbr = request->accession_nbr,
    d.order_id = request->order_id, d.patient_info = request->patient_info, d.dictation_dt_tm =
    cnvtdatetime(request->dictation_dt_tm),
    d.dictation_length = request->dictation_length, d.dictation_tz = request->dictation_tz, d.job_nbr
     = request->job_nbr,
    d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_id = reqinfo->updt_id, d.updt_task =
    reqinfo->updt_task,
    d.updt_applctx = reqinfo->updt_applctx, d.updt_cnt = (d.updt_cnt+ 1)
   WHERE (d.trans_name=request->trans_name)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failed="T")
  SET reqinfo->commit_ind = 0
  CALL echo("ERROR OCCURRED!")
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
  CALL echo("INSERT/UPDATE SUCCESSFUL...")
 ENDIF
END GO
