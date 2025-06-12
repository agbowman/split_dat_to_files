CREATE PROGRAM bbd_add_new_org:dba
 RECORD reply(
   1 organization_id = f8
   1 phone_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET modify = predeclare
 SET reply->status_data.status = "F"
 DECLARE failed = c1 WITH protect, noconstant("F")
 DECLARE org_id = f8 WITH protect, noconstant(0.0)
 DECLARE ph_id = f8 WITH protect, noconstant(0.0)
 DECLARE new_organization_seq = f8 WITH protect, noconstant(0.0)
 DECLARE donorgroup_cd = f8 WITH protect, noconstant(0.0)
 DECLARE business_cd = f8 WITH protect, noconstant(0.0)
 DECLARE code_set = i4 WITH protect, noconstant(0)
 DECLARE cdf_meaning = c12 WITH protect, noconstant(fillstring(12," "))
 DECLARE code_cnt = i4 WITH protect, noconstant(0)
 DECLARE status = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  seqn = seq(organization_seq,nextval)
  FROM dual
  DETAIL
   new_organization_seq = seqn, org_id = new_organization_seq
  WITH format, nocounter
 ;end select
 INSERT  FROM organization o
  SET o.organization_id = org_id, o.updt_cnt = 0, o.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   o.updt_id = reqinfo->updt_id, o.updt_task = reqinfo->updt_task, o.updt_applctx = reqinfo->
   updt_applctx,
   o.active_ind = 1, o.active_status_cd = reqdata->active_status_cd, o.active_status_dt_tm =
   cnvtdatetime(curdate,curtime3),
   o.active_status_prsnl_id = reqinfo->updt_id, o.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3
    ), o.end_effective_dt_tm = cnvtdatetime("01-dec-2100"),
   o.data_status_cd = reqdata->data_status_cd, o.data_status_dt_tm = cnvtdatetime(curdate,curtime3),
   o.data_status_prsnl_id = reqinfo->updt_id,
   o.contributor_system_cd = 0, o.org_name = request->org_name, o.org_name_key = cnvtupper(request->
    org_name),
   o.org_status_cd = 0, o.ft_entity_id = 0, o.ft_entity_name = null,
   o.org_class_cd = 0
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_add_new_org"
  SET reply->status_data.subeventstatus[1].operationname = "insert"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ORGANIZATION"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "ORGANIZATION insert"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ELSE
  SET reply->organization_id = org_id
 ENDIF
 SET code_set = 278
 SET cdf_meaning = "DONORGROUP"
 SET code_cnt = 1
 SET status = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,donorgroup_cd)
 INSERT  FROM org_type_reltn ot
  SET ot.organization_id = org_id, ot.org_type_cd = donorgroup_cd, ot.updt_cnt = 0,
   ot.updt_dt_tm = cnvtdatetime(curdate,curtime3), ot.updt_id = reqinfo->updt_id, ot.updt_task =
   reqinfo->updt_task,
   ot.updt_applctx = reqinfo->updt_applctx, ot.active_ind = 1, ot.active_status_cd = reqdata->
   active_status_cd,
   ot.active_status_dt_tm = cnvtdatetime(curdate,curtime3), ot.active_status_prsnl_id = reqinfo->
   updt_id, ot.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
   ot.end_effective_dt_tm = cnvtdatetime("01-dec-2100")
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_add_new_org"
  SET reply->status_data.subeventstatus[1].operationname = "insert"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ORG_TYPE_RELTN"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "ORG_TYPE_RELTN insert"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ELSE
  SET reply->organization_id = org_id
 ENDIF
 SET code_set = 43
 SET cdf_meaning = "BUSINESS"
 SET code_cnt = 1
 SET status = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,business_cd)
 SELECT INTO "nl:"
  seqn = seq(phone_seq,nextval)
  FROM dual
  DETAIL
   ph_id = seqn
  WITH format, nocounter
 ;end select
 IF ((request->phone_num > "")
  AND (request->phone_num != "(___) ___-____"))
  INSERT  FROM phone p
   SET p.phone_id = ph_id, p.parent_entity_name = "ORGANIZATION", p.parent_entity_id = org_id,
    p.phone_type_cd = business_cd, p.updt_cnt = 0, p.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
    updt_applctx,
    p.active_ind = 1, p.active_status_cd = reqdata->active_status_cd, p.active_status_dt_tm =
    cnvtdatetime(curdate,curtime3),
    p.active_status_prsnl_id = reqinfo->updt_id, p.phone_format_cd = 0, p.phone_num = request->
    phone_num,
    p.phone_type_seq = 1, p.description = "", p.contact = request->contact,
    p.call_instruction = "", p.modem_capability_cd = 0, p.extension = request->extension,
    p.paging_code = "", p.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.end_effective_dt_tm
     = cnvtdatetime("01-dec-2100"),
    p.data_status_cd = reqdata->data_status_cd, p.data_status_dt_tm = cnvtdatetime(curdate,curtime3),
    p.data_status_prsnl_id = reqinfo->updt_id,
    p.beg_effective_mm_dd = null, p.end_effective_mm_dd = null, p.contributor_system_cd = 0,
    p.operation_hours = ""
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_add_new_org"
   SET reply->status_data.subeventstatus[1].operationname = "insert"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "phone"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "phone insert"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  ELSE
   SET reply->phone_id = ph_id
  ENDIF
 ENDIF
#exit_script
 IF (failed="T")
  ROLLBACK
  SET reply->status_data.status = "F"
 ELSE
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
END GO
