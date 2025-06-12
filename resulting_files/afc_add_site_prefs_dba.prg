CREATE PROGRAM afc_add_site_prefs:dba
 SET exist_flag = 0
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="CHARGE SERVICES"
   AND di.info_name="MAX QUANTITY"
  DETAIL
   exist_flag = 1
  WITH nocounter
 ;end select
 IF (exist_flag=0)
  INSERT  FROM dm_info di
   SET di.info_domain = "CHARGE SERVICES", di.info_name = "MAX QUANTITY", di.info_long_id = 0,
    di.updt_cnt = 1, di.updt_applctx = 0, di.updt_task = 0,
    di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = 0
   WITH nocounter
  ;end insert
 ENDIF
 SET exist_flag = 0
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="CHARGE SERVICES"
   AND di.info_name="CHECK SERVICE DATE DISCHARGE"
  DETAIL
   exist_flag = 1
  WITH nocounter
 ;end select
 IF (exist_flag=0)
  INSERT  FROM dm_info di
   SET di.info_domain = "CHARGE SERVICES", di.info_name = "CHECK SERVICE DATE DISCHARGE", di
    .info_long_id = 0,
    di.updt_cnt = 1, di.updt_applctx = 0, di.updt_task = 0,
    di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = 0
   WITH nocounter
  ;end insert
 ENDIF
 SET exist_flag = 0
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="CHARGE SERVICES"
   AND di.info_name="ALLOW SERVICE DATE < ADMIT DATE"
  DETAIL
   exist_flag = 1
  WITH nocounter
 ;end select
 IF (exist_flag=0)
  INSERT  FROM dm_info di
   SET di.info_domain = "CHARGE SERVICES", di.info_name = "ALLOW SERVICE DATE < ADMIT DATE", di
    .info_long_id = 0,
    di.updt_cnt = 1, di.updt_applctx = 0, di.updt_task = 0,
    di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = 0
   WITH nocounter
  ;end insert
 ENDIF
 SET exist_flag = 0
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="CHARGE SERVICES"
   AND di.info_name="ENCOUNTER ACCESS"
  DETAIL
   exist_flag = 1
  WITH nocounter
 ;end select
 IF (exist_flag=0)
  INSERT  FROM dm_info di
   SET di.info_domain = "CHARGE SERVICES", di.info_name = "ENCOUNTER ACCESS", di.info_long_id = 0,
    di.updt_cnt = 1, di.updt_applctx = 0, di.updt_task = 0,
    di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = 0
   WITH nocounter
  ;end insert
 ENDIF
 SET exist_flag = 0
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="CHARGE SERVICES"
   AND di.info_name="MIN QUANTITY"
  DETAIL
   exist_flag = 1
  WITH nocounter
 ;end select
 IF (exist_flag=0)
  INSERT  FROM dm_info di
   SET di.info_domain = "CHARGE SERVICES", di.info_name = "MIN QUANTITY", di.info_long_id = 0,
    di.updt_cnt = 1, di.updt_applctx = 0, di.updt_task = 0,
    di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = 0
   WITH nocounter
  ;end insert
 ENDIF
 SET exist_flag = 0
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="CHARGE SERVICES"
   AND di.info_name="TAB INDEX SERVICE DATE"
  DETAIL
   exist_flag = 1
  WITH nocounter
 ;end select
 IF (exist_flag=0)
  INSERT  FROM dm_info di
   SET di.info_domain = "CHARGE SERVICES", di.info_name = "TAB INDEX SERVICE DATE", di.info_long_id
     = 0,
    di.updt_cnt = 1, di.updt_applctx = 0, di.updt_task = 0,
    di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = 0
   WITH nocounter
  ;end insert
 ENDIF
 SET exist_flag = 0
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="CHARGE SERVICES"
   AND di.info_name="TAB INDEX SERVICE TIME"
  DETAIL
   exist_flag = 1
  WITH nocounter
 ;end select
 IF (exist_flag=0)
  INSERT  FROM dm_info di
   SET di.info_domain = "CHARGE SERVICES", di.info_name = "TAB INDEX SERVICE TIME", di.info_long_id
     = 0,
    di.updt_cnt = 1, di.updt_applctx = 0, di.updt_task = 0,
    di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = 0
   WITH nocounter
  ;end insert
 ENDIF
 SET exist_flag = 0
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="CHARGE SERVICES"
   AND di.info_name="TAB INDEX ORDERING PHYSICIAN"
  DETAIL
   exist_flag = 1
  WITH nocounter
 ;end select
 IF (exist_flag=0)
  INSERT  FROM dm_info di
   SET di.info_domain = "CHARGE SERVICES", di.info_name = "TAB INDEX ORDERING PHYSICIAN", di
    .info_long_id = 0,
    di.updt_cnt = 1, di.updt_applctx = 0, di.updt_task = 0,
    di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = 0
   WITH nocounter
  ;end insert
 ENDIF
 SET exist_flag = 0
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="CHARGE SERVICES"
   AND di.info_name="TAB INDEX RENDERING PHYSICIAN"
  DETAIL
   exist_flag = 1
  WITH nocounter
 ;end select
 IF (exist_flag=0)
  INSERT  FROM dm_info di
   SET di.info_domain = "CHARGE SERVICES", di.info_name = "TAB INDEX RENDERING PHYSICIAN", di
    .info_long_id = 0,
    di.updt_cnt = 1, di.updt_applctx = 0, di.updt_task = 0,
    di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = 0
   WITH nocounter
  ;end insert
 ENDIF
 SET exist_flag = 0
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="CHARGE SERVICES"
   AND di.info_name="TAB INDEX PERFORMING LOCATION"
  DETAIL
   exist_flag = 1
  WITH nocounter
 ;end select
 IF (exist_flag=0)
  INSERT  FROM dm_info di
   SET di.info_domain = "CHARGE SERVICES", di.info_name = "TAB INDEX PERFORMING LOCATION", di
    .info_long_id = 0,
    di.updt_cnt = 1, di.updt_applctx = 0, di.updt_task = 0,
    di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = 0
   WITH nocounter
  ;end insert
 ENDIF
 SET exist_flag = 0
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="CHARGE SERVICES"
   AND di.info_name="TAB INDEX USER DEFINED FIELD"
  DETAIL
   exist_flag = 1
  WITH nocounter
 ;end select
 IF (exist_flag=0)
  INSERT  FROM dm_info di
   SET di.info_domain = "CHARGE SERVICES", di.info_name = "TAB INDEX USER DEFINED FIELD", di
    .info_long_id = 0,
    di.updt_cnt = 1, di.updt_applctx = 0, di.updt_task = 0,
    di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = 0
   WITH nocounter
  ;end insert
 ENDIF
 SET exist_flag = 0
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="CHARGE SERVICES"
   AND di.info_name="TAB INDEX CPT4 MODIFIER"
  DETAIL
   exist_flag = 1
  WITH nocounter
 ;end select
 IF (exist_flag=0)
  INSERT  FROM dm_info di
   SET di.info_domain = "CHARGE SERVICES", di.info_name = "TAB INDEX CPT4 MODIFIER", di.info_long_id
     = 0,
    di.updt_cnt = 1, di.updt_applctx = 0, di.updt_task = 0,
    di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = 0
   WITH nocounter
  ;end insert
 ENDIF
 SET exist_flag = 0
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="CHARGE SERVICES"
   AND di.info_name="TAB INDEX ICD9"
  DETAIL
   exist_flag = 1
  WITH nocounter
 ;end select
 IF (exist_flag=0)
  INSERT  FROM dm_info di
   SET di.info_domain = "CHARGE SERVICES", di.info_name = "TAB INDEX ICD9", di.info_long_id = 0,
    di.updt_cnt = 1, di.updt_applctx = 0, di.updt_task = 0,
    di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = 0
   WITH nocounter
  ;end insert
 ENDIF
 SET exist_flag = 0
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="CHARGE SERVICES"
   AND di.info_name="TAB INDEX QUANTITY"
  DETAIL
   exist_flag = 1
  WITH nocounter
 ;end select
 IF (exist_flag=0)
  INSERT  FROM dm_info di
   SET di.info_domain = "CHARGE SERVICES", di.info_name = "TAB INDEX SERVICE QUANTITY", di
    .info_long_id = 0,
    di.updt_cnt = 1, di.updt_applctx = 0, di.updt_task = 0,
    di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = 0
   WITH nocounter
  ;end insert
 ENDIF
 SET exist_flag = 0
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="CHARGE SERVICES"
   AND di.info_name="TAB INDEX SPREAD"
  DETAIL
   exist_flag = 1
  WITH nocounter
 ;end select
 IF (exist_flag=0)
  INSERT  FROM dm_info di
   SET di.info_domain = "CHARGE SERVICES", di.info_name = "TAB INDEX SPREAD", di.info_long_id = 0,
    di.updt_cnt = 1, di.updt_applctx = 0, di.updt_task = 0,
    di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = 0
   WITH nocounter
  ;end insert
 ENDIF
 SET exist_flag = 0
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="CHARGE SERVICES"
   AND di.info_name="TAB INDEX BILL ITEMS"
  DETAIL
   exist_flag = 1
  WITH nocounter
 ;end select
 IF (exist_flag=0)
  INSERT  FROM dm_info di
   SET di.info_domain = "CHARGE SERVICES", di.info_name = "TAB INDEX BILL ITEMS", di.info_long_id = 0,
    di.updt_cnt = 1, di.updt_applctx = 0, di.updt_task = 0,
    di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = 0
   WITH nocounter
  ;end insert
 ENDIF
 SET exist_flag = 0
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="CHARGE SERVICES"
   AND di.info_name="DO YOU WANT TO SEE ORDERING PHYSICIANS ONLY"
  DETAIL
   exist_flag = 1
  WITH nocounter
 ;end select
 IF (exist_flag=0)
  INSERT  FROM dm_info di
   SET di.info_domain = "CHARGE SERVICES", di.info_name =
    "DO YOU WANT TO SEE ORDERING PHYSICIANS ONLY", di.info_long_id = 0,
    di.updt_cnt = 1, di.updt_applctx = 0, di.updt_task = 0,
    di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = 0
   WITH nocounter
  ;end insert
 ENDIF
 SET exist_flag = 0
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="CHARGE SERVICES"
   AND di.info_name="DO YOU WANT TO SEE RENDERING PHYSICIANS ONLY"
  DETAIL
   exist_flag = 1
  WITH nocounter
 ;end select
 IF (exist_flag=0)
  INSERT  FROM dm_info di
   SET di.info_domain = "CHARGE SERVICES", di.info_name =
    "DO YOU WANT TO SEE RENDERING PHYSICIANS ONLY", di.info_long_id = 0,
    di.updt_cnt = 1, di.updt_applctx = 0, di.updt_task = 0,
    di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = 0
   WITH nocounter
  ;end insert
 ENDIF
 SET exist_flag = 0
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="CHARGE SERVICES"
   AND di.info_name="DEFAULT ORDERING PHYSICIAN WITH ATTENDING PHYSICIAN"
  DETAIL
   exist_flag = 1
  WITH nocounter
 ;end select
 IF (exist_flag=0)
  INSERT  FROM dm_info di
   SET di.info_domain = "CHARGE SERVICES", di.info_name =
    "DEFAULT ORDERING PHYSICIAN WITH ATTENDING PHYSICIAN", di.info_long_id = 0,
    di.updt_cnt = 1, di.updt_applctx = 0, di.updt_task = 0,
    di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = 0
   WITH nocounter
  ;end insert
 ENDIF
 COMMIT
END GO
