CREATE PROGRAM aps_rdm_add_inv_retention:dba
 RECORD data(
   1 qual[*]
     2 inventory_type_cd = f8
     2 retention_tm_value = f8
     2 retention_units_cd = f8
   1 qual_cnt = i4
 )
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
 DECLARE mnstorage_content_type_cnt = i2 WITH protect, constant(3)
 DECLARE mlstorage_content_types_cs = i4 WITH protect, constant(2072)
 DECLARE msspecimen_mean = vc WITH protect, constant("CASESPECIMEN")
 DECLARE msblock_mean = vc WITH protect, constant("CASSETTE")
 DECLARE msslide_mean = vc WITH protect, constant("SLIDE")
 DECLARE msdays_mean = vc WITH protect, constant("DAYS")
 DECLARE msyears_mean = vc WITH protect, constant("YEARS")
 DECLARE mlunits_of_measure_cs = i4 WITH protect, constant(54)
 DECLARE mddaysunitcd = f8 WITH protect, noconstant(0.0)
 DECLARE mdyearsunitcd = f8 WITH protect, noconstant(0.0)
 DECLARE mlstat = i4 WITH protect, noconstant(0)
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE mcrdmerrmsg = c132 WITH protect, noconstant(" ")
 DECLARE mlerrcode = i4 WITH protect, noconstant(0)
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed:  Starting script aps_rdm_add_inv_retention"
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cdf_meaning IN (msdays_mean, msyears_mean)
   AND cv.active_ind=1
   AND cv.code_set=mlunits_of_measure_cs
   AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
  DETAIL
   CASE (cv.cdf_meaning)
    OF msdays_mean:
     mddaysunitcd = cv.code_value
    OF msyears_mean:
     mdyearsunitcd = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 IF (((mddaysunitcd=0.0) OR (mdyearsunitcd=0.0)) )
  SET readme_data->message = "Readme Failed: Code values missing for years and days in code set 54"
  GO TO end_script
 ENDIF
 SET mlstat = alterlist(data->qual,mnstorage_content_type_cnt)
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cdf_meaning IN (msspecimen_mean, msblock_mean, msslide_mean)
   AND cv.active_ind=1
   AND cv.code_set=mlstorage_content_types_cs
   AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
  HEAD REPORT
   nqualcnt = 0
  DETAIL
   nqualcnt = (nqualcnt+ 1), data->qual[nqualcnt].inventory_type_cd = cv.code_value
   CASE (cv.cdf_meaning)
    OF msspecimen_mean:
     data->qual[nqualcnt].retention_tm_value = 90,data->qual[nqualcnt].retention_units_cd =
     mddaysunitcd
    OF msblock_mean:
     data->qual[nqualcnt].retention_tm_value = 10,data->qual[nqualcnt].retention_units_cd =
     mdyearsunitcd
    OF msslide_mean:
     data->qual[nqualcnt].retention_tm_value = 20,data->qual[nqualcnt].retention_units_cd =
     mdyearsunitcd
   ENDCASE
  FOOT REPORT
   mlstat = alterlist(data->qual,nqualcnt), data->qual_cnt = nqualcnt
  WITH nocounter
 ;end select
 IF ((data->qual_cnt != mnstorage_content_type_cnt))
  SET readme_data->message =
  "Readme Failed: Code values missing for specimen, block, and slide in code set 2072"
  GO TO end_script
 ENDIF
 SELECT INTO "nl:"
  FROM ap_inv_retention air
  WHERE expand(i,1,mnstorage_content_type_cnt,air.inventory_type_cd,data->qual[i].inventory_type_cd)
   AND air.normalcy_cd=0.0
   AND air.prefix_id=0.0
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET readme_data->status = "S"
  SET readme_data->message = "Readme Success:  Defaults are already in the system"
  GO TO end_script
 ENDIF
 INSERT  FROM ap_inv_retention air,
   (dummyt d  WITH seq = value(mnstorage_content_type_cnt))
  SET air.ap_inv_retention_id = seq(netting_seq,nextval), air.inventory_type_cd = data->qual[d.seq].
   inventory_type_cd, air.normalcy_cd = 0.0,
   air.prefix_id = 0.0, air.retention_tm_value = data->qual[d.seq].retention_tm_value, air
   .retention_units_cd = data->qual[d.seq].retention_units_cd,
   air.updt_applctx = reqinfo->updt_applctx, air.updt_cnt = 0, air.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   air.updt_id = reqinfo->updt_id, air.updt_task = reqinfo->updt_task
  PLAN (d)
   JOIN (air)
  WITH nocounter
 ;end insert
 SET mlerrcode = error(mcrdmerrmsg,0)
 IF (mlerrcode != 0)
  ROLLBACK
  SET readme_data->message = mcrdmerrmsg
  GO TO end_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Success:  aps_rdm_add_inv_retention completed successfully"
 COMMIT
#end_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
