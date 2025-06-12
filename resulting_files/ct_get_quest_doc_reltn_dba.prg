CREATE PROGRAM ct_get_quest_doc_reltn:dba
 RECORD reply(
   1 reltnqual[*]
     2 questionnaire_doc_id = f8
     2 prot_questionnaire_id = f8
     2 ct_document_id = f8
     2 active_ind = i2
     2 updt_cnt = i4
   1 no_docs_needed = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ( NOT (validate(domain_reply)))
  RECORD domain_reply(
    1 logical_domain_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 EXECUTE ct_get_logical_domain_id  WITH replace("REPLY",domain_reply)
 SET reply->status_data.status = "F"
 DECLARE count = i2 WITH protect, noconstant(0)
 DECLARE doc_needed_ind = i2 WITH protect, noconstant(0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE consent_doc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17906,"CONSENTDOC"))
 SELECT INTO "nl:"
  pm.collab_site_org_id
  FROM prot_amendment pa,
   prot_master pm,
   prot_questionnaire pq,
   ct_prot_type_config cfg
  PLAN (pq
   WHERE (pq.prot_questionnaire_id=request->prot_questionnaire_id))
   JOIN (pa
   WHERE pa.prot_amendment_id=pq.prot_amendment_id)
   JOIN (pm
   WHERE pm.prot_master_id=pa.prot_master_id)
   JOIN (cfg
   WHERE cfg.protocol_type_cd=pa.participation_type_cd
    AND cfg.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND cfg.item_cd=consent_doc_cd
    AND (cfg.logical_domain_id=domain_reply->logical_domain_id))
  DETAIL
   CALL echo(pm.collab_site_org_id)
   IF (((pm.collab_site_org_id > 0) OR (uar_get_code_meaning(cfg.config_value_cd) != "REQUIRED")) )
    doc_needed_ind = 1
   ELSE
    doc_needed_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(request->prot_questionnaire_id)
 SELECT INTO "nl:"
  qd.*
  FROM questionnaire_doc_reltn qd
  WHERE (qd.prot_questionnaire_id=request->prot_questionnaire_id)
   AND qd.active_ind=1
  DETAIL
   count += 1, stat = alterlist(reply->reltnqual,count), reply->reltnqual[count].questionnaire_doc_id
    = qd.questionnaire_doc_id,
   reply->reltnqual[count].prot_questionnaire_id = qd.prot_questionnaire_id, reply->reltnqual[count].
   ct_document_id = qd.ct_document_id, reply->reltnqual[count].active_ind = qd.active_ind,
   reply->reltnqual[count].updt_cnt = qd.updt_cnt
  WITH nocounter
 ;end select
 IF (count=0
  AND doc_needed_ind=0)
  SET reply->status_data.status = "Z"
 ELSE
  IF (count=0
   AND doc_needed_ind=1)
   SET reply->no_docs_needed = 1
  ELSE
   SET reply->no_docs_needed = 0
  ENDIF
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 CALL echo(build("status:",reply->status_data.status))
 SET last_mod = "005"
 SET mod_date = "Oct 1, 2019"
END GO
