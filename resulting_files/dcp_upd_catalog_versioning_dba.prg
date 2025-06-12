CREATE PROGRAM dcp_upd_catalog_versioning:dba
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
 SET readme_data->message = "FAIL:dcp_upd_catalog_versioning.prg failed"
 FREE RECORD pathway
 RECORD pathway(
   1 pathway[*]
     2 version_pw_cat_id = f8
 )
 FREE RECORD version
 RECORD versions(
   1 version[*]
     2 pathway_catalog_id = f8
     2 version_pw_cat_id = f8
 )
 DECLARE cstatus = c1 WITH protect, noconstant("Z")
 DECLARE stat = i2 WITH noconstant(0), protect
 DECLARE ipathwaycnt = i4 WITH noconstant(0), protect
 DECLARE iversioncnt = i4 WITH noconstant(0), protect
 DECLARE ccareplantypemean = c12 WITH constant("CAREPLAN"), protect
 DECLARE cpathwaytypemean = c12 WITH constant("PATHWAY"), protect
 DECLARE iindex = i4 WITH noconstant(0), protect
 DECLARE start = i4 WITH protect, noconstant(0)
 DECLARE batch_size = i4 WITH protect, constant(20)
 DECLARE dversioncatid = f8 WITH noconstant(0.0), protect
 DECLARE dpathwaycatid = f8 WITH noconstant(0.0), protect
 DECLARE pathway_size = i4 WITH protect, noconstant(0)
 DECLARE version_size = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 SELECT INTO "nl:"
  FROM pathway_catalog p
  WHERE ((p.type_mean=cpathwaytypemean) OR (p.type_mean=ccareplantypemean))
   AND p.version_pw_cat_id != p.pathway_catalog_id
   AND p.version=1
  HEAD REPORT
   ipathwaycnt = 0, stat = alterlist(pathway->pathway,batch_size), pathway_size = batch_size
  DETAIL
   ipathwaycnt = (ipathwaycnt+ 1)
   IF (ipathwaycnt > pathway_size)
    stat = alterlist(pathway->pathway,(ipathwaycnt+ (batch_size - 1))), pathway_size = (ipathwaycnt+
    (batch_size - 1))
   ENDIF
   pathway->pathway[ipathwaycnt].version_pw_cat_id = p.version_pw_cat_id
  FOOT REPORT
   stat = alterlist(pathway->pathway,ipathwaycnt), pathway_size = ipathwaycnt
  WITH nocounter
 ;end select
 IF (error(errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Fail:Failed to select version_pw_cat_id's from pathway_catalog",
   errmsg)
  GO TO exit_script
 ENDIF
 IF (pathway_size=0)
  SET readme_data->status = "S"
  SET readme_data->message =
  "dcp_upd_catalog_versioning.prg found no pathway_catalog records to update"
  GO TO exit_script
 ENDIF
 SET iindex = 0
 SET start = 1
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(ipathwaycnt)),
   pathway_catalog p
  PLAN (d1)
   JOIN (p
   WHERE (((p.version_pw_cat_id=pathway->pathway[d1.seq].version_pw_cat_id)) OR ((p
   .pathway_catalog_id=pathway->pathway[d1.seq].version_pw_cat_id))) )
  ORDER BY p.description_key, p.version
  HEAD REPORT
   iversioncnt = 0, stat = alterlist(versions->version,5), version_size = 5
  HEAD p.description_key
   dversioncatid = p.pathway_catalog_id
  DETAIL
   iversioncnt = (iversioncnt+ 1)
   IF (iversioncnt > version_size)
    stat = alterlist(versions->version,(iversioncnt+ 4)), version_size = (iversioncnt+ 4)
   ENDIF
   versions->version[iversioncnt].pathway_catalog_id = p.pathway_catalog_id, versions->version[
   iversioncnt].version_pw_cat_id = dversioncatid
  FOOT REPORT
   stat = alterlist(versions->version,iversioncnt), version_size = iversioncnt
  WITH nocounter
 ;end select
 IF (error(errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "FAIL:Fail:Failed to select pathway_catalog_id's and correct version_pw_cat_id's from pathway_catalog",
   errmsg)
  GO TO exit_script
 ENDIF
 IF (version_size=0)
  SET readme_data->status = "S"
  SET readme_data->message =
  "dcp_upd_catalog_versioning.prg not able to pair pathway_catalog_id's with correct version_pw_cat_id's"
  GO TO exit_script
 ENDIF
 UPDATE  FROM (dummyt d1  WITH seq = value(version_size)),
   pathway_catalog p
  SET p.version_pw_cat_id = versions->version[d1.seq].version_pw_cat_id, p.updt_dt_tm = cnvtdatetime(
    curdate,curtime3), p.updt_id = reqinfo->updt_id,
   p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = (p.updt_cnt
   + 1)
  PLAN (d1)
   JOIN (p
   WHERE (p.pathway_catalog_id=versions->version[d1.seq].pathway_catalog_id))
  WITH nocounter
 ;end update
 IF (error(errmsg,0) != 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to update PATHWAY_CATALOG table",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success:  Readme dcp_upd_catalog_versioning.prg completed successfully"
#exit_script
 FREE RECORD pathway
 FREE RECORD versions
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
