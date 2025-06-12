CREATE PROGRAM ec_hm_sat_check_id:dba
 DECLARE num = i4 WITH noconstant(0), protect
 DECLARE found = i2 WITH noconstant(0), protect
 DECLARE days = i4 WITH noconstant(0), protect
 SET retval = - (1)
 IF (reflect(parameter(2,0))="I*")
  SET days = parameter(2,0)
 ELSE
  SET days = 0
 ENDIF
 FREE RECORD rpt
 RECORD rpt(
   1 sat_cnt = i4
   1 satisfiers[*]
     2 satisfier_id = f8
 )
 SELECT INTO "nl:"
  FROM hm_expect_sat hes
  WHERE (hes.expect_sat_id= $1)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (rpt->sat_cnt+ 1), rpt->sat_cnt = cnt, stat = alterlist(rpt->satisfiers,cnt),
   rpt->satisfiers[cnt].satisfier_id = hes.expect_sat_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM hm_expect_mod hem
  WHERE hem.person_id=trigger_personid
   AND expand(num,1,rpt->sat_cnt,hem.expect_sat_id,rpt->satisfiers[num].satisfier_id)
  DETAIL
   IF (days > 0)
    IF (hem.modifier_dt_tm > cnvtdatetime((curdate - days),curtime3))
     found = 1
    ENDIF
   ELSE
    found = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM hm_recommendation hr,
   hm_recommendation_action hra
  PLAN (hr
   WHERE hr.person_id=trigger_personid)
   JOIN (hra
   WHERE hra.recommendation_id=hr.recommendation_id
    AND expand(num,1,rpt->sat_cnt,hra.expect_sat_id,rpt->satisfiers[num].satisfier_id))
  DETAIL
   IF (days > 0)
    IF (hra.qualified_dt_tm > cnvtdatetime((curdate - days),curtime3))
     found = 1
    ENDIF
   ELSE
    found = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (found=1)
  SET retval = 100
  SET log_message = build2("Success. Satisfiers found.")
 ELSE
  SET retval = 0
  SET log_message = build2("Failure. Satisfiers not found.")
 ENDIF
 CALL echo(log_message)
#exit_script
END GO
