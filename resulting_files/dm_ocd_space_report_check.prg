CREATE PROGRAM dm_ocd_space_report_check
 FREE RECORD spc_rpt
 RECORD spc_rpt(
   1 report_seq = f8
   1 begin_date = dq8
   1 days_old = i4
   1 env_id = f8
 )
 SET spc_rpt->report_seq = 0
 SET spc_rpt->begin_date = cnvtdatetime("01-JAN-1900")
 SET spc_rpt->days_old = 0
 SET spc_rpt->env_id = 0
 IF (validate(env_id,- (1)) > 0)
  SET spc_rpt->env_id = env_id
 ELSE
  SELECT INTO "nl:"
   FROM dm_info d
   WHERE d.info_domain="DATA MANAGEMENT"
    AND d.info_name="DM_ENV_ID"
   DETAIL
    spc_rpt->env_id = d.info_number
   WITH nocounter
  ;end select
  IF ((spc_rpt->env_id=0))
   CALL echo("Environment ID not found!")
   IF (validate(docd_reply->status,"2") != "2")
    SET docd_reply->status = "F"
    SET docd_reply->err_msg = "Environment ID not found in DM_INFO"
   ENDIF
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  a.report_seq, a.begin_date
  FROM ref_report_log a,
   ref_report_parms_log b,
   ref_instance_id c
  WHERE a.report_seq=b.report_seq
   AND b.parm_cd=1
   AND a.report_cd=1
   AND a.end_date IS NOT null
   AND b.parm_value=cnvtstring(c.instance_cd)
   AND (c.environment_id=spc_rpt->env_id)
  ORDER BY a.begin_date DESC
  DETAIL
   IF (datetimediff(a.begin_date,spc_rpt->begin_date) > 0)
    spc_rpt->begin_date = a.begin_date, spc_rpt->report_seq = a.report_seq
   ENDIF
  WITH nocounter
 ;end select
 IF ((spc_rpt->report_seq > 0))
  SET spc_rpt->days_old = cnvtint(datetimediff(cnvtdatetime(curdate,curtime3),spc_rpt->begin_date))
 ENDIF
 IF ((((spc_rpt->report_seq=0)) OR ((spc_rpt->days_old > 30))) )
  EXECUTE dm_ocd_space_report_warning
 ELSE
  SET docd_reply->status = "S"
 ENDIF
END GO
