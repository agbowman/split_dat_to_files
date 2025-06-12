CREATE PROGRAM bbd_upd_recruiting_rslts:dba
 RECORD reply(
   1 list_id = f8
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
 RECORD current(
   1 system_dt_tm = dq8
 )
 SET current->system_dt_tm = cnvtdatetime(curdate,curtime3)
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET acount = size(request->antigen,5)
 SET zcount = size(request->zipcode,5)
 SET new_pathnet_seq = 0.0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)"###########################;rp0"
  FROM dual
  DETAIL
   new_pathnet_seq = cnvtint(seqn)
  WITH format, nocounter
 ;end select
 SET new_list_id = new_pathnet_seq
 SET reply->list_id = new_list_id
 INSERT  FROM bbd_recruiting_list l
  SET l.list_id = new_list_id, l.from_dt_tm = cnvtdatetime(request->from_dt_tm), l.to_dt_tm =
   cnvtdatetime(request->to_dt_tm),
   l.rare_type_cd = request->rare_type_cd, l.donation_procedure_cd = request->donation_procedure_cd,
   l.special_interest_cd = request->special_interest_cd,
   l.abo_cd = request->abo_cd, l.rh_cd = request->rh_cd, l.completed_ind = 0,
   l.last_person_id = 0, l.race_cd = request->race_cd, l.organization_id = request->organization_id,
   l.active_ind = 1, l.active_status_cd = reqdata->active_status_cd, l.active_status_dt_tm =
   cnvtdatetime(current->system_dt_tm),
   l.active_status_prsnl_id = reqinfo->updt_id, l.updt_applctx = reqinfo->updt_applctx, l.updt_task
    = reqinfo->updt_task,
   l.updt_cnt = 0, l.updt_id = reqinfo->updt_id, l.updt_dt_tm = cnvtdatetime(current->system_dt_tm)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failed = "T"
  SET reply->status = "S"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_recruiting_rslts.prg"
  SET reply->status_data.subeventstatus[1].operationname = "Insert"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bbd_recruiting_list"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Error on inserting a new recruiting list."
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO acount)
   SET new_pathnet_seq = 0.0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)"###########################;rp0"
    FROM dual
    DETAIL
     new_pathnet_seq = cnvtint(seqn)
    WITH format, nocounter
   ;end select
   INSERT  FROM bbd_recruiting_antigen a
    SET a.recruit_antigen_id = new_pathnet_seq, a.list_id = new_list_id, a.antigen_cd = request->
     antigen[x].antigen_cd,
     a.active_ind = 1, a.active_status_cd = reqdata->active_status_cd, a.active_status_dt_tm =
     cnvtdatetime(current->system_dt_tm),
     a.active_status_prsnl_id = reqinfo->updt_id, a.updt_applctx = reqinfo->updt_applctx, a
     .updt_dt_tm = cnvtdatetime(current->system_dt_tm),
     a.updt_id = reqinfo->updt_id, a.updt_task = reqinfo->updt_task, a.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = "T"
    SET reply->status = "S"
    SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_recruiting_rslts.prg"
    SET reply->status_data.subeventstatus[1].operationname = "Insert"
    SET reply->status_data.subeventstatus[1].targetobjectname = "bbd_recruiting_antigen"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Error on inserting new antigens."
    SET reply->status_data.subeventstatus[1].sourceobjectqual = 2
    GO TO exit_script
   ENDIF
 ENDFOR
 FOR (y = 1 TO zcount)
   SET new_pathnet_seq = 0.0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)"###########################;rp0"
    FROM dual
    DETAIL
     new_pathnet_seq = cnvtint(seqn)
    WITH format, nocounter
   ;end select
   INSERT  FROM bbd_recruiting_zipcode z
    SET z.zip_code_id = new_pathnet_seq, z.list_id = new_list_id, z.zip_code = request->zipcode[y].
     zip_code,
     z.active_ind = 1, z.active_status_cd = reqdata->active_status_cd, z.active_status_dt_tm =
     cnvtdatetime(current->system_dt_tm),
     z.active_status_prsnl_id = reqinfo->updt_id, z.updt_applctx = reqinfo->updt_applctx, z
     .updt_dt_tm = cnvtdatetime(current->system_dt_tm),
     z.updt_id = reqinfo->updt_id, z.updt_task = reqinfo->updt_task, z.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = "T"
    SET reply->status = "S"
    SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_recruiting_rslts.prg"
    SET reply->status_data.subeventstatus[1].operationname = "Insert"
    SET reply->status_data.subeventstatus[1].targetobjectname = "bbd_recruiting_zipcode"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Error on inserting new zip codes."
    SET reply->status_data.subeventstatus[1].sourceobjectqual = 3
    GO TO exit_script
   ENDIF
 ENDFOR
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  ROLLBACK
 ELSE
  SET reply->status_data.status = "S"
  COMMIT
 ENDIF
END GO
