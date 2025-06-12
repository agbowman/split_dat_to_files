CREATE PROGRAM dcp_solcap_failed_plans
 SET modify = predeclare
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE lsolutioncapabilitycount = i4 WITH protect, noconstant(0)
 SET lsolutioncapabilitycount = (value(size(reply->solcap,5))+ 1)
 SET stat = alterlist(reply->solcap,lsolutioncapabilitycount)
 SET reply->solcap[lsolutioncapabilitycount].identifier = "2012.1.00106.6"
 SELECT INTO "nl:"
  ppa.pathway_id
  FROM pw_processing_action ppa
  PLAN (ppa
   WHERE ppa.updt_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
    end_dt_tm)
    AND ppa.pathway_id > 0.0
    AND  NOT ( EXISTS (
   (SELECT
    p.pathway_id
    FROM pathway p
    WHERE p.pathway_id=ppa.pathway_id))))
  HEAD REPORT
   dummy = 0
  DETAIL
   IF (ppa.processing_start_dt_tm <= cnvtdatetime(curdate,(curtime - 180)))
    reply->solcap[lsolutioncapabilitycount].degree_of_use_num += 1
   ENDIF
  FOOT REPORT
   dummy = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ppa.pathway_id
  FROM pw_processing_action ppa,
   pathway p
  PLAN (ppa
   WHERE ppa.updt_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
    end_dt_tm)
    AND ppa.pathway_id > 0.0)
   JOIN (p
   WHERE p.pathway_id=ppa.pathway_id)
  HEAD REPORT
   dummy = 0
  DETAIL
   IF (p.updt_cnt < ppa.processing_updt_cnt)
    IF (ppa.processing_start_dt_tm <= cnvtdatetime(curdate,(curtime - 180)))
     reply->solcap[lsolutioncapabilitycount].degree_of_use_num += 1
    ENDIF
   ENDIF
  FOOT REPORT
   dummy = 0
  WITH nocounter
 ;end select
 SET lsolutioncapabilitycount = (value(size(reply->solcap,5))+ 1)
 SET stat = alterlist(reply->solcap,lsolutioncapabilitycount)
 SET reply->solcap[lsolutioncapabilitycount].identifier = "2012.1.00106.7"
 DECLARE error_type_flag_phase_failure = i2 WITH protect, constant(1)
 SELECT INTO "nl:"
  pel.pw_group_nbr, pel.pathway_id
  FROM pp_error_log pel
  PLAN (pel
   WHERE pel.updt_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
    end_dt_tm)
    AND ((pel.pw_group_nbr > 0.0) OR (pel.pathway_id > 0.0))
    AND pel.error_type_flag=error_type_flag_phase_failure)
  ORDER BY pel.pw_group_nbr
  HEAD REPORT
   dummy = 0
  DETAIL
   reply->solcap[lsolutioncapabilitycount].degree_of_use_num += 1
  FOOT REPORT
   dummy = 0
  WITH nocounter
 ;end select
END GO
