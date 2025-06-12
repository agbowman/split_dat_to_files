CREATE PROGRAM aps_get_diag_word_cache:dba
 RECORD reply(
   1 source_vocabulary_cd = f8
   1 word_qual[*]
     2 word1 = vc
     2 singular_form_of_word1 = vc
     2 word_frequency = i4
     2 cache_ranking = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE nwordidx = i2 WITH noconstant(0)
 DECLARE nwordcount = i2 WITH noconstant(0)
 DECLARE dsourcevocabcd = f8 WITH noconstant(0.0)
 DECLARE ndminfoindicator = i2 WITH noconstant(0)
 DECLARE sdiagwhere = vc
 DECLARE sdatestring = vc
 SET reply->status_data.status = "F"
 SET sdiagwhere = fillstring(100," ")
 SET sdatestring = fillstring(100," ")
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="ANATOMIC PATHOLOGY"
   AND di.info_name="SNOMED CACHE RANKED"
   AND di.info_number=1
  DETAIL
   ndminfoindicator = 1
  WITH nocounter
 ;end select
 IF ((request->source_vocabulary_cd > 0))
  SET sdiagwhere = build("adwc.source_vocabulary_cd = ",request->source_vocabulary_cd)
 ELSE
  SET sdiagwhere = "1 = 1"
 ENDIF
 IF ((request->last_cache_dt_tm > 0))
  SET sdatestring = build("adwc.updt_dt_tm > cnvtdatetime(request->last_cache_dt_tm)")
 ELSE
  SET sdatestring = "1 = 1"
 ENDIF
 SELECT
  IF (ndminfoindicator=1)
   ORDER BY adwc.cache_ranking DESC
  ELSE
  ENDIF
  INTO "nl:"
  adwc.source_vocabulary_cd, adwc.word_frequency, adwc.cache_ranking
  FROM ap_diag_word_cache adwc
  WHERE parser(sdiagwhere)
   AND parser(sdatestring)
  ORDER BY adwc.cache_ranking
  HEAD REPORT
   nwordidx = 0, nwordcount = 0, stat = alterlist(reply->word_qual,10),
   dsourcevocabcd = adwc.source_vocabulary_cd
  DETAIL
   IF ((nwordcount < request->max_words))
    IF (adwc.source_vocabulary_cd=dsourcevocabcd)
     nwordcount = (nwordcount+ 1), nwordidx = (nwordidx+ 1)
     IF (mod(nwordidx,10)=1
      AND nwordidx != 1)
      stat = alterlist(reply->word_qual,(nwordidx+ 9))
     ENDIF
     reply->word_qual[nwordidx].word1 = adwc.diagnostic_word, reply->word_qual[nwordidx].
     singular_form_of_word1 = adwc.snglr_diagnostic_word, reply->word_qual[nwordidx].word_frequency
      = adwc.word_frequency,
     reply->word_qual[nwordidx].cache_ranking = nwordcount, reply->source_vocabulary_cd = adwc
     .source_vocabulary_cd
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->word_qual,nwordidx)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
