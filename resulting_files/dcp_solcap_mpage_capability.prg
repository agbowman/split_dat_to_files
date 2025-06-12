CREATE PROGRAM dcp_solcap_mpage_capability
 SET stat = alterlist(reply->solcap,3)
 SET reply->solcap[1].identifier = "2010.1.00040.1"
 DECLARE nmpadddiagnosiscount = i4 WITH protect, noconstant(0)
 DECLARE nmpadddiagnosisusercount = i4 WITH protect, noconstant(0)
 SET reply->solcap[2].identifier = "2010.2.00098.1"
 DECLARE nmpaddproblemcount = i4 WITH protect, noconstant(0)
 DECLARE nmpaddproblemusercount = i4 WITH protect, noconstant(0)
 SET reply->solcap[3].identifier = "2010.2.00098.4"
 DECLARE nmpaddconditionproblemdiagnosiscount = i4 WITH protect, noconstant(0)
 DECLARE nmpaddconditionproblemdiagnosisusercount = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  cra.object_name, cra.updt_id
  FROM ccl_report_audit cra
  WHERE cra.object_name IN ("MP_PE_ADD_DIAGNOSIS", "MP_PE_ADD_PROBLEM")
   AND cra.updt_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->end_dt_tm)
  ORDER BY cra.object_name, cra.updt_id
  HEAD REPORT
   nmpadddiagnosiscount = 0, nmpadddiagnosisusercount = 0, nmpaddproblemcount = 0,
   nmpaddproblemusercount = 0
  HEAD cra.updt_id
   IF (cra.object_name="MP_PE_ADD_DIAGNOSIS")
    nmpadddiagnosisusercount += 1
   ELSEIF (cra.object_name="MP_PE_ADD_PROBLEM")
    nmpaddproblemusercount += 1
   ENDIF
  DETAIL
   IF (cra.object_name="MP_PE_ADD_DIAGNOSIS")
    nmpadddiagnosiscount += 1
   ELSEIF (cra.object_name="MP_PE_ADD_PROBLEM")
    nmpaddproblemcount += 1
   ENDIF
  FOOT REPORT
   reply->solcap[1].degree_of_use_num = nmpadddiagnosiscount, reply->solcap[1].distinct_user_count =
   nmpadddiagnosisusercount, reply->solcap[1].degree_of_use_str = "",
   reply->solcap[2].degree_of_use_num = nmpaddproblemcount, reply->solcap[2].distinct_user_count =
   nmpaddproblemusercount, reply->solcap[2].degree_of_use_str = ""
  WITH nocounter, nullreport
 ;end select
 SELECT INTO "nl:"
  cra.object_name, cra.updt_id
  FROM ccl_report_audit cra
  WHERE cra.object_name IN ("MP_PE_ADD_CONDITION")
   AND cra.updt_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->end_dt_tm)
  ORDER BY cra.updt_id
  HEAD REPORT
   nmpaddconditionproblemdiagnosiscount = 0, nmpaddconditionproblemdiagnosisusercount = 0
  HEAD cra.updt_id
   nmpaddconditionproblemdiagnosisusercount += 1
  DETAIL
   nmpaddconditionproblemdiagnosiscount += 1
  FOOT REPORT
   reply->solcap[3].degree_of_use_num = nmpaddconditionproblemdiagnosiscount, reply->solcap[3].
   distinct_user_count = nmpaddconditionproblemdiagnosisusercount, reply->solcap[3].degree_of_use_str
    = ""
  WITH nocounter, nullreport
 ;end select
END GO
