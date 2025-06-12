CREATE PROGRAM aps_solcap_rfid_track:dba
 DECLARE solcap_cnt = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 SET solcap_cnt = (solcap_cnt+ 1)
 SET stat = alterlist(reply->solcap,solcap_cnt)
 SET reply->solcap[solcap_cnt].identifier = "2014.1.00312.1"
 SET reply->solcap[solcap_cnt].degree_of_use_num = 0
 SET reply->solcap[solcap_cnt].degree_of_use_str = "No"
 SET reply->solcap[solcap_cnt].distinct_user_count = 0
 SELECT
  at.assembly_tweet_id
  FROM assembly_tweet at
  WHERE at.issued_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
   end_dt_tm)
  FOOT REPORT
   reply->solcap[solcap_cnt].degree_of_use_num = count(at.assembly_tweet_id)
   IF ((reply->solcap[solcap_cnt].degree_of_use_num > 0))
    reply->solcap[solcap_cnt].degree_of_use_str = "Yes"
   ENDIF
  WITH nocounter
 ;end select
END GO
