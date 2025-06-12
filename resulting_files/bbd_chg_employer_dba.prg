CREATE PROGRAM bbd_chg_employer:dba
 RECORD reply(
   1 qual[*]
     2 organization_id = f8
     2 org_name = vc
     2 employer_item_data = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c30
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c30
       3 targetobjectvalue = vc
       3 sourceobjectqual = i4
 )
 SET modify = predeclare
 DECLARE sub_org_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE cdf_meaning = c12 WITH protect, noconstant(fillstring(12," "))
 DECLARE code_value = f8 WITH protect, noconstant(0.0)
 DECLARE code_set = i4 WITH protect, noconstant(278)
 DECLARE code_cnt = i4 WITH protect, noconstant(1)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE y = i4 WITH protect, noconstant(0)
 DECLARE failed = c1 WITH protect, noconstant("F")
 SET cdf_meaning = "EMPLOYER"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,sub_org_type_cd)
 SET reply->status_data.status = "F"
 FOR (y = 1 TO request->employer_cnt)
   SET new_org_seq = 0.0
   SELECT INTO "nl:"
    seqn = seq(organization_seq,nextval)
    FROM dual
    DETAIL
     new_org_seq = seqn
    WITH format, nocounter
   ;end select
   INSERT  FROM organization o
    SET o.organization_id = new_org_seq, o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id =
     reqinfo->updt_id,
     o.updt_cnt = 0, o.updt_task = reqinfo->updt_task, o.updt_applctx = reqinfo->updt_applctx,
     o.active_ind = 1, o.active_status_cd = reqdata->active_status_cd, o.active_status_dt_tm =
     cnvtdatetime(curdate,curtime3),
     o.active_status_prsnl_id = reqinfo->updt_id, o.beg_effective_dt_tm = cnvtdatetime(curdate,
      curtime3), o.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 23:59:59:99"),
     o.data_status_cd = reqdata->data_status_cd, o.data_status_dt_tm = cnvtdatetime(curdate,curtime3),
     o.data_status_prsnl_id = reqinfo->updt_id,
     o.contributor_system_cd = 0, o.org_name = request->qual[y].org_name, o.org_name_key = null,
     o.federal_tax_id_nbr = null, o.org_status_cd = 0, o.ft_entity_id = 0,
     o.ft_entity_name = null, o.org_class_cd = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = "T"
    SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_chg_employer.prg"
    SET reply->status_data.subeventstatus[1].operationname = "Insert"
    SET reply->status_data.subeventstatus[1].targetobjectname = "organization"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Error on organization id insert."
    SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
    GO TO exit_script
   ELSE
    SET stat = alterlist(reply->qual,y)
    SET reply->qual[y].organization_id = new_org_seq
    SET reply->qual[y].org_name = request->qual[y].org_name
    SET reply->qual[y].employer_item_data = request->qual[y].employer_item_data
   ENDIF
   INSERT  FROM org_type_reltn otr
    SET otr.organization_id = new_org_seq, otr.org_type_cd = sub_org_type_cd, otr.updt_cnt = 0,
     otr.updt_dt_tm = cnvtdatetime(curdate,curtime3), otr.updt_id = reqinfo->updt_id, otr.updt_task
      = reqinfo->updt_task,
     otr.updt_applctx = reqinfo->updt_applctx, otr.active_ind = 1, otr.active_status_cd = reqdata->
     active_status_cd,
     otr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), otr.active_status_prsnl_id = reqinfo->
     updt_id, otr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
     otr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 23:59:59:99")
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = "T"
    SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_chg_employer.prg"
    SET reply->status_data.subeventstatus[1].operationname = "Insert"
    SET reply->status_data.subeventstatus[1].targetobjectname = "org_type_reltn"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Error on org_type_reltn_id insert."
    SET reply->status_data.subeventstatus[1].sourceobjectqual = 2
    GO TO exit_script
   ELSE
    SET stat = alterlist(reply->qual,y)
    SET reply->qual[y].organization_id = new_org_seq
    SET reply->qual[y].org_name = request->qual[y].org_name
    SET reply->qual[y].employer_item_data = request->qual[y].employer_item_data
   ENDIF
 ENDFOR
#exit_script
 IF (failed="T")
  ROLLBACK
  SET reply->status_data.status = "F"
 ELSE
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
END GO
