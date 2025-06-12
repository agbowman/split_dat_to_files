CREATE PROGRAM aps_test_write_tweets:dba
 PROMPT
  "Tweet Count to Add" = 0,
  "Lookback" = 0,
  "Remove Tweets" = 0
  WITH tweet_cnt, lookback, remove_ind
 DECLARE location_name = vc WITH public, constant("TST TESTING LOCAL")
 IF (( $REMOVE_IND > 0))
  CALL removetweets(null)
  GO TO exit_script
 ENDIF
 CALL writetweets( $TWEET_CNT, $LOOKBACK)
 DECLARE writetweets(ntweetcount=i4,lookback=i4) = null
 SUBROUTINE writetweets(ntweetcount,lookback)
   DECLARE tweet_id = f8 WITH protect, noconstant(0.0)
   DECLARE lab_sys = vc WITH protect, noconstant("")
   FOR (i = 1 TO ntweetcount)
     SELECT INTO "nl:"
      next_seq_nbr = seq(assembly_seq,nextval)
      FROM dual
      DETAIL
       tweet_id = next_seq_nbr
      WITH nocounter, format
     ;end select
     SET lab_sys = build("TESTLAB",cnvtstring(tweet_id))
     INSERT  FROM assembly_tweet at
      SET assembly_tweet_id = tweet_id, action_location_name = location_name, action_location_cd = 0,
       action_flag = 0, issued_dt_tm = cnvtdatetime((curdate - lookback),curtime3),
       from_lab_system_name = lab_sys,
       action_directional_flag = 0, action_user_name = "TESTUSER", effective_dt_tm = cnvtdatetime(
        curdate,curtime3),
       active_ind = 0, updt_id = 0, updt_dt_tm = cnvtdatetime(curdate,curtime3),
       updt_task = 0, updt_applctx = 0, updt_cnt = 0
      WITH nocounter
     ;end insert
   ENDFOR
 END ;Subroutine
 DECLARE removetweets(null) = null
 SUBROUTINE removetweets(null)
   DELETE  FROM assembly_tweet at
    WHERE at.action_location_name=location_name
   ;end delete
 END ;Subroutine
#exit_script
END GO
