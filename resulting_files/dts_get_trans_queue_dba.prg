CREATE PROGRAM dts_get_trans_queue:dba
 RECORD reply(
   1 trans_name = c100
   1 author_name = c100
   1 cosign_name = c100
   1 doc_type_cd = f8
   1 doc_type_alias = c255
   1 contributor_source_cd = f8
   1 accession_nbr = c20
   1 order_id = f8
   1 patient_info = c200
   1 dictation_dt_tm = dq8
   1 dictation_tz = i4
   1 dictation_length = i4
   1 job_nbr = c100
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD name(
   1 qual[*]
     2 trans_name = c200
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 CALL echo("Just entered GET PRSNL ALIAS...")
 SELECT INTO "nl:"
  pa.alias
  FROM prsnl_alias pa
  WHERE (pa.person_id=request->trans_id)
   AND pa.active_ind=1
  HEAD REPORT
   stat = alterlist(name->qual,10)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1
    AND cnt != 1)
    stat = alterlist(name->qual,(cnt+ 9))
   ENDIF
   name->qual[cnt].trans_name = trim(pa.alias),
   CALL echo(build("trans_name = ",name->qual[cnt].trans_name))
  FOOT REPORT
   stat = alterlist(name->qual,cnt),
   CALL echo(build("size of structure = ",size(name->qual,5)))
  WITH nocounter
 ;end select
 CALL echo("Just entered SELECT...")
 SELECT INTO "nl:"
  dt.trans_name, dt.author_name, dt.cosign_name,
  dt.doc_type_alias, dt.contributor_source_cd, dt.accession_nbr,
  dt.order_id, dt.patient_info, dt.dictation_dt_tm,
  dt.dictation_length, dt.job_nbr
  FROM dts_trans_queue dt,
   (dummyt d  WITH seq = value(size(name->qual,5)))
  PLAN (d)
   JOIN (dt
   WHERE (dt.trans_name=name->qual[d.seq].trans_name))
  DETAIL
   reply->trans_name = trim(dt.trans_name), reply->author_name = dt.author_name, reply->cosign_name
    = dt.cosign_name,
   reply->doc_type_alias = dt.doc_type_alias, reply->contributor_source_cd = dt.contributor_source_cd,
   reply->accession_nbr = dt.accession_nbr,
   reply->order_id = dt.order_id, reply->patient_info = dt.patient_info, reply->dictation_dt_tm = dt
   .dictation_dt_tm,
   reply->dictation_tz = dt.dictation_tz, reply->dictation_length = dt.dictation_length, reply->
   job_nbr = dt.job_nbr
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo("Just entered dealias document type code...")
 SET code_set = 72
 IF ((reply->doc_type_alias > " "))
  SELECT INTO "nl:"
   ca.code_value
   FROM code_value_alias ca
   WHERE ca.code_set=code_set
    AND (ca.contributor_source_cd=reply->contributor_source_cd)
    AND (ca.alias=reply->doc_type_alias)
    AND ca.code_value > 0
   DETAIL
    reply->doc_type_cd = ca.code_value
   WITH nocounter
  ;end select
 ENDIF
 CALL echo(build("Status _",reply->status_data.status))
 CALL echo(build("Transcription Alias _",reply->trans_name))
 CALL echo(build("Author Alias _",reply->author_name))
 CALL echo(build("Cosigner Alias _",reply->cosign_name))
 CALL echo(build("Document Type Alias _",reply->doc_type_alias))
 CALL echo(build("Document Type Cd _",reply->doc_type_cd))
 CALL echo(build("Contributor Cd _",reply->contributor_source_cd))
 CALL echo(build("Accession Number _",reply->accession_nbr))
 CALL echo(build("Order Id _",reply->order_id))
 CALL echo(build("Patient Info _",reply->patient_info))
 CALL echo(build("Dictation Dt/Tm _",reply->dictation_dt_tm))
 CALL echo(build("Dictation Length _",reply->dictation_length))
 CALL echo(build("Job Number _",reply->job_nbr))
END GO
