CREATE PROGRAM ct_get_config_prot_types:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 configured[*]
      2 protocol_type_cd = f8
      2 protocol_type_disp = c40
      2 protocol_type_desc = c60
      2 protocol_type_mean = c12
    1 not_configured[*]
      2 protocol_type_cd = f8
      2 protocol_type_disp = c40
      2 protocol_type_desc = c60
      2 protocol_type_mean = c12
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
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
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE ncfg_cnt = i4 WITH protect, noconstant(0)
 DECLARE cfg_cnt = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  cv.display, cfg.protocol_type_cd, cfg.ct_prot_type_config_id
  FROM code_value cv,
   ct_prot_type_config cfg
  PLAN (cv
   WHERE cv.code_set=17344
    AND cv.active_ind=1)
   JOIN (cfg
   WHERE (cfg.protocol_type_cd= Outerjoin(cv.code_value))
    AND (cfg.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
    AND (cfg.logical_domain_id=domain_reply->logical_domain_id))
  HEAD REPORT
   cfg_cnt = 0, ncfg_cnt = 0
  HEAD cv.code_value
   IF (cfg.ct_prot_type_config_id > 0.0)
    cfg_cnt += 1
    IF (mod(cfg_cnt,10)=1)
     stat = alterlist(reply->configured[cfg_cnt],(cfg_cnt+ 9))
    ENDIF
    reply->configured[cfg_cnt].protocol_type_cd = cv.code_value
   ELSE
    ncfg_cnt += 1
    IF (mod(ncfg_cnt,10)=1)
     stat = alterlist(reply->not_configured,(ncfg_cnt+ 9))
    ENDIF
    reply->not_configured[ncfg_cnt].protocol_type_cd = cv.code_value
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->configured,cfg_cnt), stat = alterlist(reply->not_configured,ncfg_cnt)
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 SET last_mod = "001"
 SET mod_date = "July 23, 2019"
END GO
