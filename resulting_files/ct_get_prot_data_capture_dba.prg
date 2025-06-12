CREATE PROGRAM ct_get_prot_data_capture:dba
 RECORD reply(
   1 long_text = vc
   1 long_text_id = f8
   1 orgs[*]
     2 org_id = f8
     2 org_name = c100
   1 ct_domain_id = f8
   1 url_one_text = c255
   1 url_two_text = c255
   1 data_script_cd = f8
   1 data_script_disp = c40
   1 data_script_desc = c60
   1 data_script_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD ct_get_domain_info_request(
   1 ct_domain_id = f8
 )
 RECORD ct_get_domain_info_reply(
   1 domains[*]
     2 ct_domain_id = f8
     2 domain_name = c255
     2 domain_identifier = c255
     2 url_one_text = c255
     2 url_two_text = c255
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE failed = c1 WITH protect, noconstant("S")
 DECLARE cnt = i2 WITH protect, noconstant(0)
 DECLARE organizational_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",17296,
   "INSTITUTION"))
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM long_text_reference ltr
  WHERE (ltr.parent_entity_id=request->prot_amendment_id)
   AND ltr.parent_entity_name="PROT_AMENDMENT"
   AND ltr.active_ind=1
  DETAIL
   reply->long_text = ltr.long_text, reply->long_text_id = ltr.long_text_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL report_failure("SELECT","Z","ct_get_prot_data_capture","No data capture information.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM prot_amendment pa
  WHERE (pa.prot_amendment_id=request->prot_amendment_id)
  DETAIL
   ct_get_domain_info_request->ct_domain_id = pa.ct_domain_info_id, reply->data_script_cd = pa
   .data_script_cd
  WITH nocounter
 ;end select
 IF ((ct_get_domain_info_request->ct_domain_id > 0))
  EXECUTE ct_get_domain_info  WITH replace("REQUEST","CT_GET_DOMAIN_INFO_REQUEST"), replace("REPLY",
   "CT_GET_DOMAIN_INFO_REPLY")
  IF ((ct_get_domain_info_reply->status_data.status="F"))
   CALL report_failure("EXECUTE","F","ct_get_domain_info","Failure retrieving domain information.")
   GO TO exit_script
  ELSE
   SET reply->ct_domain_id = ct_get_domain_info_request->ct_domain_id
   SET reply->url_one_text = ct_get_domain_info_reply->domains[1].url_one_text
   SET reply->url_two_text = ct_get_domain_info_reply->domains[1].url_two_text
  ENDIF
 ENDIF
 IF (curqual=0)
  CALL report_failure("SELECT","Z","ct_get_prot_data_capture","No data capture information.")
  GO TO exit_script
 ENDIF
 IF ((request->get_amd_orgs_ind=1)
  AND (reply->long_text_id > 0))
  SELECT INTO "nl:"
   FROM prot_role pr,
    organization org
   PLAN (pr
    WHERE (pr.prot_amendment_id=request->prot_amendment_id)
     AND pr.prot_role_type_cd=organizational_cd
     AND pr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (org
    WHERE org.organization_id=pr.organization_id)
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(reply->orgs,(cnt+ 9))
    ENDIF
    reply->orgs[cnt].org_id = org.organization_id, reply->orgs[cnt].org_name = org.org_name
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->orgs,cnt)
 ENDIF
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   IF (opstatus != "S")
    SET failed = opstatus
   ENDIF
   SET reply->status_data.subeventstatus[1].operationname = trim(opname)
   SET reply->status_data.subeventstatus[1].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[1].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = trim(targetvalue)
   SET reply->error = trim(targetvalue)
 END ;Subroutine
#exit_script
 IF (failed != "S")
  SET reply->status_data.status = failed
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "002"
 SET mod_date = "Nov 07, 2008"
END GO
