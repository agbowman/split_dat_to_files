CREATE PROGRAM bb_rme_add_event_cds_chk:dba
 SET request->setup_proc[1].process_id = 450
 SET request->setup_proc[1].success_ind = 1
 SET request->setup_proc[1].error_msg = ""
 DECLARE nfoundlab = i2
 DECLARE nfoundreturninv = i2
 DECLARE nfoundtransfused = i2
 DECLARE nfoundbbproduct = i2
 DECLARE nfoundbbproductag = i2
 SET nfoundlab = 0
 SET nfoundreturninv = 0
 SET nfoundtransfused = 0
 SET nfoundbbproduct = 0
 SET nfoundbbproductag = 0
 SELECT INTO "nl:"
  v.event_cd_disp_key
  FROM v500_event_code v
  WHERE v.event_cd_disp_key="LAB"
  DETAIL
   nfoundlab = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  v.event_cd_disp_key
  FROM v500_event_code v
  WHERE v.event_cd_disp_key="RETURNINV"
  DETAIL
   nfoundreturninv = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  v.event_cd_disp_key
  FROM v500_event_code v
  WHERE v.event_cd_disp_key="TRANSFUSED"
  DETAIL
   nfoundtransfused = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  v.event_cd_disp_key
  FROM v500_event_code v
  WHERE v.event_cd_disp_key="BBPRODUCT"
  DETAIL
   nfoundbbproduct = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  v.event_cd_disp_key
  FROM v500_event_code v
  WHERE v.event_cd_disp_key="BBPRODUCTAG"
  DETAIL
   nfoundbbproductag = 1
  WITH nocounter
 ;end select
 IF (nfoundlab=0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "LAB event code not found."
 ENDIF
 IF (nfoundreturninv=0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = concat(request->setup_proc[1].error_msg,
   " RETURNINV event code not found.")
 ENDIF
 IF (nfoundtransfused=0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = concat(request->setup_proc[1].error_msg,
   " TRANSFUSED event code not found.")
 ENDIF
 IF (nfoundbbproduct=0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = concat(request->setup_proc[1].error_msg,
   " BBPRODUCT event code not found.")
 ENDIF
 IF (nfoundbbproductag=0)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = concat(request->setup_proc[1].error_msg,
   " BBPRODUCTAG event code not found.")
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
