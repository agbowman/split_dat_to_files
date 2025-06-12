CREATE PROGRAM ct_get_protocol_config:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 item_list[*]
      2 ct_prot_config_value_id = f8
      2 item_cd = f8
      2 item_disp = c40
      2 item_desc = c60
      2 item_mean = c12
      2 value_cd = f8
      2 value_disp = c40
      2 value_desc = c60
      2 value_mean = c12
    1 prot_type_list[*]
      2 item_cd = f8
      2 item_disp = c40
      2 item_desc = c60
      2 item_mean = c12
      2 value_cd = f8
      2 value_disp = c40
      2 value_desc = c60
      2 value_mean = c12
    1 stratification_type_cd = f8
    1 stratification_type_disp = c40
    1 stratification_type_desc = c60
    1 stratification_type_mean = c12
    1 manual_enroll_id_ind = i2
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
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE consentenroll_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",17906,
   "CONSENTENROL"))
 DECLARE batchenroll_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",17906,"BATCHENROLL"))
 SET reply->status_data.status = "S"
 SELECT INTO "nl:"
  FROM ct_prot_config_value pcv
  PLAN (pcv
   WHERE (pcv.prot_master_id=request->prot_master_id)
    AND pcv.end_effective_dt_tm > cnvtdatetime(sysdate))
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->item_list,(cnt+ 9))
   ENDIF
   reply->item_list[cnt].ct_prot_config_value_id = pcv.ct_prot_config_value_id, reply->item_list[cnt]
   .item_cd = pcv.item_cd, reply->item_list[cnt].value_cd = pcv.config_value_cd
  FOOT REPORT
   stat = alterlist(reply->item_list,cnt)
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
   "Failed to select prot config values: ",errmsg)
  GO TO exit_script
 ENDIF
 IF ((request->prot_type_cd > 0.00))
  SELECT INTO "nl:"
   FROM ct_prot_type_config cfg
   WHERE (cfg.protocol_type_cd=request->prot_type_cd)
    AND cfg.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND (cfg.logical_domain_id=domain_reply->logical_domain_id)
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt += 1
    IF (mod(cnt,10)=1)
     stat = alterlist(reply->prot_type_list,(cnt+ 9))
    ENDIF
    reply->prot_type_list[cnt].item_cd = cfg.item_cd, reply->prot_type_list[cnt].value_cd = cfg
    .config_value_cd
   FOOT REPORT
    stat = alterlist(reply->prot_type_list,cnt)
   WITH nocounter
  ;end select
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
    "Failed to select prot config values: ",errmsg)
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM prot_master pm,
   prot_amendment pa
  PLAN (pm
   WHERE (pm.prot_master_id=request->prot_master_id))
   JOIN (pa
   WHERE pa.prot_master_id=pm.prot_master_id
    AND pa.amendment_status_cd=pm.prot_status_cd)
  ORDER BY pa.amendment_nbr, pa.revision_seq
  HEAD pm.prot_master_id
   IF (pm.accession_nbr_sig_dig < 0)
    reply->manual_enroll_id_ind = 1
   ELSE
    reply->manual_enroll_id_ind = 0
   ENDIF
  DETAIL
   reply->stratification_type_cd = pa.enroll_stratification_type_cd
  WITH nocounter
 ;end select
#exit_script
 SET last_mod = "002"
 SET mod_date = "August 1, 2019"
END GO
