CREATE PROGRAM bbt_solcap_2010h1_ctratio
 DECLARE dtlastendrpt = dq8
 DECLARE dtlastrpt = dq8
 DECLARE cntrpt = i4
 DECLARE no_run = vc WITH constant("Not Run")
 DECLARE last_ct_report = vc WITH constant("LAST_CT_REPORT_DT_TM")
 SET stat = alterlist(reply->solcap,1)
 SET reply->solcap[1].identifier = "2010.1.00091.1"
 FREE SET res_count
 DECLARE res_count = i4 WITH noconstant(0)
 DECLARE dm_domain = vc WITH constant("PATHNET_BBT")
 DECLARE dm_name = vc WITH constant("LAST_CT_REPORT_DT_TM")
 SELECT INTO "nl:"
  dm.info_date
  FROM dm_info dm
  PLAN (dm
   WHERE dm.info_domain=dm_domain
    AND dm.info_name=dm_name)
  DETAIL
   dtlastendrpt = dm.info_date, dtlastrpt = dm.updt_dt_tm, cntrpt = dm.updt_cnt
  FOOT REPORT
   IF (dtlastrpt != null)
    reply->solcap[1].degree_of_use_str = format(dtlastrpt,"@MEDIUMDATE")
   ELSE
    reply->solcap[1].degree_of_use_str = no_run
   ENDIF
 ;end select
 SET reply->solcap[1].degree_of_use_num = cntrpt WITH nocounter
END GO
