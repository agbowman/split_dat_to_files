CREATE PROGRAM bb_rme_add_event_cds:dba
 FREE SET dm_post_event_code
 RECORD dm_post_event_code(
   1 event_set_name = c40
   1 event_cd_disp = c40
   1 event_cd_descr = c60
   1 event_cd_definition = c100
   1 status = c12
   1 format = c12
   1 storage = c12
   1 event_class = c12
   1 event_confid_level = c12
   1 event_subclass = c12
   1 event_code_status = c12
   1 event_cd = f8
   1 parent_cd = f8
   1 flex1_cd = f8
   1 flex2_cd = f8
   1 flex3_cd = f8
   1 flex4_cd = f8
   1 flex5_cd = f8
 )
 DECLARE dlabsourcecd = f8
 DECLARE dbbtsourcecd = f8
 DECLARE nfoundlab = i2
 DECLARE nfoundreturninv = i2
 DECLARE nfoundtransfused = i2
 DECLARE nfoundbbproduct = i2
 DECLARE nfoundbbproductag = i2
 SET dlabsourcecd = 0
 SET dbbtsourcecd = 0
 SET nfoundlab = 0
 SET nfoundreturninv = 0
 SET nfoundtransfused = 0
 SET nfoundbbproduct = 0
 SET nfoundbbproductag = 0
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=73
   AND c.cdf_meaning="LAB"
  DETAIL
   dlabsourcecd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=73
   AND c.cdf_meaning="BBT"
  DETAIL
   dbbtsourcecd = c.code_value
  WITH nocounter
 ;end select
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
  SET dm_post_event_code->event_set_name = fillstring(40," ")
  SET dm_post_event_code->event_cd_disp = "LAB"
  SET dm_post_event_code->event_cd_descr = "LAB"
  SET dm_post_event_code->event_cd_definition = "LAB"
  SET dm_post_event_code->status = "ACTIVE"
  SET dm_post_event_code->format = "UNKNOWN"
  SET dm_post_event_code->storage = "UNKNOWN"
  SET dm_post_event_code->event_class = "UNKNOWN"
  SET dm_post_event_code->event_confid_level = "ROUTCLINICAL"
  SET dm_post_event_code->event_subclass = "UNKNOWN"
  SET dm_post_event_code->event_code_status = "AUTH"
  SET dm_post_event_code->event_cd = 0.0
  SET dm_post_event_code->parent_cd = dlabsourcecd
  SET dm_post_event_code->flex1_cd = 0.0
  SET dm_post_event_code->flex2_cd = 0.0
  SET dm_post_event_code->flex3_cd = 0.0
  SET dm_post_event_code->flex4_cd = 0.0
  SET dm_post_event_code->flex5_cd = 0.0
  EXECUTE dm_post_event_code
 ENDIF
 IF (nfoundreturninv=0)
  SET dm_post_event_code->event_set_name = "RETURNINV"
  SET dm_post_event_code->event_cd_disp = "RETURNINV"
  SET dm_post_event_code->event_cd_descr = "RETURNINV"
  SET dm_post_event_code->event_cd_definition = "RETURNINV"
  SET dm_post_event_code->status = "ACTIVE"
  SET dm_post_event_code->format = "UNKNOWN"
  SET dm_post_event_code->storage = "UNKNOWN"
  SET dm_post_event_code->event_class = "UNKNOWN"
  SET dm_post_event_code->event_confid_level = "ROUTCLINICAL"
  SET dm_post_event_code->event_subclass = "UNKNOWN"
  SET dm_post_event_code->event_code_status = "AUTH"
  SET dm_post_event_code->event_cd = 0.0
  SET dm_post_event_code->parent_cd = 0.0
  SET dm_post_event_code->flex1_cd = 0.0
  SET dm_post_event_code->flex2_cd = 0.0
  SET dm_post_event_code->flex3_cd = dbbtsourcecd
  SET dm_post_event_code->flex4_cd = 0.0
  SET dm_post_event_code->flex5_cd = 0.0
  EXECUTE dm_post_event_code
 ENDIF
 IF (nfoundtransfused=0)
  SET dm_post_event_code->event_set_name = "TRANSFUSED"
  SET dm_post_event_code->event_cd_disp = "TRANSFUSED"
  SET dm_post_event_code->event_cd_descr = "TRANSFUSED"
  SET dm_post_event_code->event_cd_definition = "TRANSFUSED"
  SET dm_post_event_code->status = "ACTIVE"
  SET dm_post_event_code->format = "UNKNOWN"
  SET dm_post_event_code->storage = "UNKNOWN"
  SET dm_post_event_code->event_class = "UNKNOWN"
  SET dm_post_event_code->event_confid_level = "ROUTCLINICAL"
  SET dm_post_event_code->event_subclass = "UNKNOWN"
  SET dm_post_event_code->event_code_status = "AUTH"
  SET dm_post_event_code->event_cd = 0.0
  SET dm_post_event_code->parent_cd = dbbtsourcecd
  SET dm_post_event_code->flex1_cd = 0.0
  SET dm_post_event_code->flex2_cd = 0.0
  SET dm_post_event_code->flex3_cd = 0.0
  SET dm_post_event_code->flex4_cd = 0.0
  SET dm_post_event_code->flex5_cd = 0.0
  EXECUTE dm_post_event_code
 ENDIF
 IF (nfoundbbproduct=0)
  SET dm_post_event_code->event_set_name = "BBPRODUCT"
  SET dm_post_event_code->event_cd_disp = "BBPRODUCT"
  SET dm_post_event_code->event_cd_descr = "BBPRODUCT"
  SET dm_post_event_code->event_cd_definition = "BBPRODUCT"
  SET dm_post_event_code->status = "ACTIVE"
  SET dm_post_event_code->format = "UNKNOWN"
  SET dm_post_event_code->storage = "UNKNOWN"
  SET dm_post_event_code->event_class = "UNKNOWN"
  SET dm_post_event_code->event_confid_level = "ROUTCLINICAL"
  SET dm_post_event_code->event_subclass = "UNKNOWN"
  SET dm_post_event_code->event_code_status = "AUTH"
  SET dm_post_event_code->event_cd = 0.0
  SET dm_post_event_code->parent_cd = 0.0
  SET dm_post_event_code->flex1_cd = dbbtsourcecd
  SET dm_post_event_code->flex2_cd = 0.0
  SET dm_post_event_code->flex3_cd = 0.0
  SET dm_post_event_code->flex4_cd = 0.0
  SET dm_post_event_code->flex5_cd = 0.0
  EXECUTE dm_post_event_code
 ENDIF
 IF (nfoundbbproductag=0)
  SET dm_post_event_code->event_set_name = "BBPRODUCTAG"
  SET dm_post_event_code->event_cd_disp = "BBPRODUCTAG"
  SET dm_post_event_code->event_cd_descr = "BBPRODUCTAG"
  SET dm_post_event_code->event_cd_definition = "BBPRODUCTAG"
  SET dm_post_event_code->status = "ACTIVE"
  SET dm_post_event_code->format = "UNKNOWN"
  SET dm_post_event_code->storage = "UNKNOWN"
  SET dm_post_event_code->event_class = "UNKNOWN"
  SET dm_post_event_code->event_confid_level = "ROUTCLINICAL"
  SET dm_post_event_code->event_subclass = "UNKNOWN"
  SET dm_post_event_code->event_code_status = "AUTH"
  SET dm_post_event_code->event_cd = 0.0
  SET dm_post_event_code->parent_cd = 0.0
  SET dm_post_event_code->flex1_cd = 0.0
  SET dm_post_event_code->flex2_cd = dbbtsourcecd
  SET dm_post_event_code->flex3_cd = 0.0
  SET dm_post_event_code->flex4_cd = 0.0
  SET dm_post_event_code->flex5_cd = 0.0
  EXECUTE dm_post_event_code
 ENDIF
END GO
