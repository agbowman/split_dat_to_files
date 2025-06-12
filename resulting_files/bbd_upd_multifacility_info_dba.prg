CREATE PROGRAM bbd_upd_multifacility_info:dba
 RECORD reply(
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
 SET reply->status = "S"
 SET code_cnt = 1
 SET active_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(48,"ACTIVE",code_cnt,active_cd)
 IF (active_cd=0)
  SET status = "F"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  *
  FROM prsnl_current_loc
  WHERE (person_id=request->person_id)
   AND (cerner_product_cd=request->cerner_product_cd)
   AND active_ind=1
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO go_add_procedure
 ENDIF
 SET updt_cnt = 0
 SELECT INTO "nl:"
  *
  FROM prsnl_current_loc p
  WHERE (p.person_id=request->person_id)
   AND (p.cerner_product_cd=request->cerner_product_cd)
  DETAIL
   updt_cnt = p.updt_cnt
  WITH nocounter, forupdate(p)
 ;end select
 UPDATE  FROM prsnl_current_loc p
  SET p.active_ind = 1, p.active_status_dt_tm = cnvtdatetime(curdate,curtime), p.location_cd =
   request->location_cd,
   p.location_type_cd = request->location_type_cd, p.root_loc_cd = request->root_cd, p.updt_applctx
    = reqinfo->updt_applctx,
   p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(curdate,curtime), p.updt_task = reqinfo
   ->updt_task
  WHERE (p.person_id=request->person_id)
   AND (p.cerner_product_cd=request->cerner_product_cd)
   AND p.updt_cnt=updt_cnt
  WITH nocounter
 ;end update
 IF ((request->debug_ind=1))
  CALL echo(build("UPDATE...",curqual))
 ENDIF
 IF (curqual=0)
  SET reply->status = "F"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_multifacility_info.prg"
  SET reply->status_data.subeventstatus[1].operationname = "Update"
  SET reply->status_data.subeventstatus[1].targetobjectname = "prsnl_current_loc"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Error on updating current location."
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
 ENDIF
 GO TO exit_script
#go_add_procedure
 SET new_id = 0.0
 DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 SET new_id = new_pathnet_seq
 INSERT  FROM prsnl_current_loc p
  SET p.person_id = request->person_id, p.location_cd = request->location_cd, p.location_type_cd =
   request->location_type_cd,
   p.root_loc_cd = request->root_cd, p.current_loc_id = new_id, p.cerner_product_cd = request->
   cerner_product_cd,
   p.updt_cnt = 0, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx,
   p.updt_dt_tm = cnvtdatetime(curdate,curtime), p.updt_id = request->person_id, p.active_ind = 1,
   p.active_status_cd = active_cd, p.active_status_dt_tm = cnvtdatetime(curdate,curtime), p
   .active_status_prsnl_id = request->person_id
  WITH nocounter
 ;end insert
 IF ((request->debug_ind=1))
  CALL echo(build("INSERT...",curqual))
 ENDIF
 IF (curqual=0)
  SET reply->status = "F"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_multifacility_info.prg"
  SET reply->status_data.subeventstatus[1].operationname = "ADD"
  SET reply->status_data.subeventstatus[1].targetobjectname = "prsnl_current_loc"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Error on adding a current location."
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
 ENDIF
#exit_script
 IF ((reply->status="F"))
  SET reply->status_data.status = "F"
  ROLLBACK
 ELSE
  SET reply->status_data.status = "S"
  COMMIT
 ENDIF
END GO
