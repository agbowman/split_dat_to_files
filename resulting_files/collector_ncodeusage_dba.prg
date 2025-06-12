CREATE PROGRAM collector_ncodeusage:dba
 RECORD reply(
   1 solcap[*]
     2 identifier = vc
     2 degree_of_use_num = i4
     2 degree_of_use_str = vc
     2 distinct_user_count = i4
     2 position[*]
       3 display = vc
       3 value_num = i4
       3 value_str = vc
     2 facility[*]
       3 display = vc
       3 value_num = i4
       3 value_str = vc
     2 other[*]
       3 category_name = vc
       3 value[*]
         4 display = vc
         4 value_num = i4
         4 value_str = vc
 )
 DECLARE dmpgetprereqcount = i4 WITH protect, noconstant(0)
 DECLARE nmpgetprerequsercount = i4 WITH protect, noconstant(0)
 DECLARE dmpgetncodeinfocount = i4 WITH protect, noconstant(0)
 DECLARE nmpgetncodeinfousercount = i4 WITH protect, noconstant(0)
 DECLARE dmphcsnomedproblemscount = i4 WITH protect, noconstant(0)
 DECLARE nmphcsnomedproblemsusercount = i4 WITH protect, noconstant(0)
 SET stat = alterlist(reply->solcap,3)
 SET reply->solcap[1].identifier = "2010.1.00110.1"
 SET reply->solcap[2].identifier = "2010.1.00110.2"
 SET reply->solcap[3].identifier = "2011.1.00371.1"
 SELECT INTO "nl:"
  cra.object_name, cra.updt_id
  FROM ccl_report_audit cra
  WHERE cra.object_name IN ("MP_GET_PRE_REQ", "MP_GET_NCODE_INFO", "MP_HC_GET_SNOMED_PROBLEMS")
   AND cra.updt_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->end_dt_tm)
  ORDER BY cra.updt_id, cra.object_name
  HEAD REPORT
   dmpgetprereqcount = 0, nmpgetprerequsercount = 0, dmpgetncodeinfocount = 0,
   nmpgetncodeinfousercount = 0, dmphcsnomedproblemscount = 0, nmphcsnomedproblemsusercount = 0
  HEAD cra.object_name
   IF (cra.object_name="MP_GET_PRE_REQ")
    nmpgetprerequsercount = (nmpgetprerequsercount+ 1)
   ELSEIF (cra.object_name="MP_GET_NCODE_INFO")
    nmpgetncodeinfousercount = (nmpgetncodeinfousercount+ 1)
   ELSEIF (cra.object_name="MP_HC_GET_SNOMED_PROBLEMS")
    nmphcsnomedproblemsusercount = (nmphcsnomedproblemsusercount+ 1)
   ENDIF
  DETAIL
   IF (cra.object_name="MP_GET_PRE_REQ")
    dmpgetprereqcount = (dmpgetprereqcount+ 1)
   ELSEIF (cra.object_name="MP_GET_NCODE_INFO")
    dmpgetncodeinfocount = (dmpgetncodeinfocount+ 1)
   ELSEIF (cra.object_name="MP_HC_GET_SNOMED_PROBLEMS")
    dmphcsnomedproblemscount = (dmphcsnomedproblemscount+ 1)
   ENDIF
  FOOT REPORT
   reply->solcap[1].degree_of_use_num = dmpgetprereqcount, reply->solcap[1].distinct_user_count =
   nmpgetprerequsercount, reply->solcap[1].degree_of_use_str = "",
   reply->solcap[2].degree_of_use_num = dmpgetncodeinfocount, reply->solcap[2].distinct_user_count =
   nmpgetncodeinfousercount, reply->solcap[2].degree_of_use_str = "",
   reply->solcap[3].degree_of_use_num = dmphcsnomedproblemscount, reply->solcap[3].
   distinct_user_count = nmphcsnomedproblemsusercount, reply->solcap[3].degree_of_use_str = ""
  WITH nocounter
 ;end select
END GO
