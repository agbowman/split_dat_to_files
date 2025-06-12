CREATE PROGRAM bbt_solcap_2010h1_ptc
 DECLARE dtmax = q8
 DECLARE no_run = vc WITH constant("Not Run")
 SET stat = alterlist(reply->solcap,1)
 SET reply->solcap[1].identifier = "2010.1.00091.4"
 FREE SET res_count
 DECLARE res_count = i4 WITH noconstant(0)
 SELECT
  dm.info_date, cv.code_value, cv.display
  FROM dm_info dm,
   code_value cv
  PLAN (dm
   WHERE dm.info_domain="PATHNET_BBT"
    AND dm.info_name="LAST_PTC_XML_DT_TM*")
   JOIN (cv
   WHERE cv.code_value=dm.info_number)
  ORDER BY cv.display
  DETAIL
   res_count = (res_count+ 1)
   IF (dtmax < dm.info_date)
    dtmax = dm.info_date
   ENDIF
   IF (mod(res_count,10)=1)
    stat = alterlist(reply->solcap[1].facility,(res_count+ 9))
   ENDIF
   reply->solcap[1].facility[res_count].display = cv.display, reply->solcap[1].facility[res_count].
   value_str = format(dm.info_date,"@MEDIUMDATE")
  FOOT REPORT
   IF (dtmax != null)
    reply->solcap[1].degree_of_use_str = format(dtmax,"@MEDIUMDATE")
   ELSE
    reply->solcap[1].degree_of_use_str = no_run
   ENDIF
   stat = alterlist(reply->solcap[1].facility,res_count)
  WITH nocounter
 ;end select
END GO
