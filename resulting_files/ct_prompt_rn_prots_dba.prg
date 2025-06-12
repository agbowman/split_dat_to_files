CREATE PROGRAM ct_prompt_rn_prots:dba
 EXECUTE ccl_prompt_api_dataset "autoset"
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE concept_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17274,"CONCEPT"))
 IF (( $1=0))
  SELECT DISTINCT
   pm.prot_master_id, pm.primary_mnemonic, pa.prot_title
   FROM ct_rn_prot_config rpc,
    prot_master pm,
    code_value cv,
    prot_amendment pa
   PLAN (rpc
    WHERE rpc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND rpc.ct_rn_prot_config_id > 0)
    JOIN (pm
    WHERE pm.prot_master_id=rpc.prot_master_id
     AND pm.network_flag=2)
    JOIN (cv
    WHERE cv.code_value=rpc.rn_protocol_cd
     AND cv.active_ind=0
     AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (pa
    WHERE pa.prot_master_id=pm.prot_master_id
     AND pa.amendment_status_cd=pm.prot_status_cd)
   ORDER BY cnvtlower(pm.primary_mnemonic)
   HEAD REPORT
    stat = makedataset(20)
   DETAIL
    stat = writerecord(0)
   FOOT REPORT
    stat = closedataset(0)
   WITH nocounter, reporthelp, check
  ;end select
 ELSEIF (( $1=1))
  SELECT DISTINCT
   pm.prot_master_id, pm.primary_mnemonic, pa.prot_title
   FROM ct_rn_prot_config rpc,
    prot_master pm,
    code_value cv,
    prot_amendment pa
   PLAN (rpc
    WHERE rpc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND rpc.ct_rn_prot_config_id > 0)
    JOIN (pm
    WHERE pm.prot_master_id=rpc.prot_master_id
     AND pm.network_flag=2)
    JOIN (cv
    WHERE cv.code_value=rpc.rn_protocol_cd
     AND cv.active_ind=1
     AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (pa
    WHERE pa.prot_master_id=pm.prot_master_id
     AND pa.amendment_status_cd=pm.prot_status_cd)
   ORDER BY cnvtlower(pm.primary_mnemonic)
   HEAD REPORT
    stat = makedataset(20)
   DETAIL
    stat = writerecord(0)
   FOOT REPORT
    stat = closedataset(0)
   WITH nocounter, reporthelp, check
  ;end select
 ELSEIF (( $1=2))
  SELECT DISTINCT
   pm.prot_master_id, pm.primary_mnemonic, pa.prot_title
   FROM ct_rn_prot_config rpc,
    prot_master pm,
    code_value cv,
    prot_amendment pa
   PLAN (rpc
    WHERE rpc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND rpc.ct_rn_prot_config_id > 0)
    JOIN (pm
    WHERE pm.prot_master_id=rpc.prot_master_id
     AND pm.network_flag=2)
    JOIN (cv
    WHERE cv.code_value=rpc.rn_protocol_cd
     AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (pa
    WHERE pa.prot_master_id=pm.prot_master_id
     AND pa.amendment_status_cd=pm.prot_status_cd)
   ORDER BY cnvtlower(pm.primary_mnemonic)
   HEAD REPORT
    stat = makedataset(20)
   DETAIL
    stat = writerecord(0)
   FOOT REPORT
    stat = closedataset(0)
   WITH nocounter, reporthelp, check
  ;end select
 ELSEIF (( $1=3))
  SELECT DISTINCT
   pm.prot_master_id, pm.primary_mnemonic, pa.prot_title
   FROM ct_rn_prot_config rpc,
    prot_master pm,
    prot_amendment pa
   PLAN (rpc
    WHERE rpc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND rpc.ct_rn_prot_config_id > 0)
    JOIN (pm
    WHERE pm.prot_master_id=rpc.prot_master_id
     AND pm.network_flag=1
     AND pm.prot_status_cd=concept_cd)
    JOIN (pa
    WHERE pa.prot_master_id=pm.prot_master_id
     AND pa.amendment_status_cd=pm.prot_status_cd)
   ORDER BY cnvtlower(pm.primary_mnemonic)
   HEAD REPORT
    stat = makedataset(20)
   DETAIL
    stat = writerecord(0)
   FOOT REPORT
    stat = closedataset(0)
   WITH nocounter, reporthelp, check
  ;end select
 ELSEIF (( $1=4))
  SELECT DISTINCT
   pm.prot_master_id, pm.primary_mnemonic, pa.prot_title
   FROM ct_rn_prot_config rpc,
    prot_master pm,
    code_value cv,
    prot_amendment pa
   PLAN (rpc
    WHERE rpc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND rpc.ct_rn_prot_config_id > 0
     AND rpc.data_extract_cap_flag > 0
     AND rpc.stop_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (pm
    WHERE pm.prot_master_id=rpc.prot_master_id
     AND pm.network_flag=2)
    JOIN (cv
    WHERE cv.code_value=rpc.rn_protocol_cd
     AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (pa
    WHERE pa.prot_master_id=pm.prot_master_id
     AND pa.amendment_status_cd=pm.prot_status_cd)
   ORDER BY cnvtlower(pm.primary_mnemonic)
   HEAD REPORT
    stat = makedataset(20)
   DETAIL
    IF (cv.cdf_meaning != "DATAEXTR")
     stat = writerecord(0)
    ENDIF
   FOOT REPORT
    stat = closedataset(0)
   WITH nocounter, reporthelp, check
  ;end select
 ELSEIF (( $1=5))
  SELECT DISTINCT
   pm.prot_master_id, pm.primary_mnemonic, pa.prot_title
   FROM ct_rn_prot_config rpc,
    prot_master pm,
    code_value cv,
    prot_amendment pa
   PLAN (rpc
    WHERE rpc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND rpc.ct_rn_prot_config_id > 0
     AND rpc.stop_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (pm
    WHERE pm.prot_master_id=rpc.prot_master_id
     AND pm.network_flag=2)
    JOIN (cv
    WHERE cv.code_value=rpc.rn_protocol_cd
     AND cv.cdf_meaning="DATAEXTR"
     AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (pa
    WHERE pa.prot_master_id=pm.prot_master_id
     AND pa.amendment_status_cd=pm.prot_status_cd)
   ORDER BY cnvtlower(pm.primary_mnemonic)
   HEAD REPORT
    stat = makedataset(20)
   DETAIL
    stat = writerecord(0)
   FOOT REPORT
    stat = closedataset(0)
   WITH nocounter, reporthelp, check
  ;end select
 ENDIF
 SET last_mod = "000"
 SET mod_date = "July 21, 2009"
END GO
