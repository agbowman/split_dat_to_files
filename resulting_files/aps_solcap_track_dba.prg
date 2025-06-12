CREATE PROGRAM aps_solcap_track:dba
 DECLARE levent_type_cs = i4 WITH protect, constant(2061)
 DECLARE ltrack_station_cs = i4 WITH protect, constant(29473)
 DECLARE dtrackedcd = f8 WITH protect, noconstant(0.0)
 DECLARE dplacedincd = f8 WITH protect, noconstant(0.0)
 DECLARE dstoredcd = f8 WITH protect, noconstant(0.0)
 DECLARE dcheckedincd = f8 WITH protect, noconstant(0.0)
 DECLARE dcheckedoutcd = f8 WITH protect, noconstant(0.0)
 DECLARE dremovedfromcd = f8 WITH protect, noconstant(0.0)
 DECLARE ddiscardedcd = f8 WITH protect, noconstant(0.0)
 DECLARE dmatchedcd = f8 WITH protect, noconstant(0.0)
 DECLARE dmismatchedcd = f8 WITH protect, noconstant(0.0)
 DECLARE dunmatchedcd = f8 WITH protect, noconstant(0.0)
 DECLARE dqualitycd = f8 WITH protect, noconstant(0.0)
 DECLARE dtrackstationcd = f8 WITH protect, noconstant(0.0)
 DECLARE dplacestationcd = f8 WITH protect, noconstant(0.0)
 DECLARE dstorestationcd = f8 WITH protect, noconstant(0.0)
 DECLARE dcheckoutstationcd = f8 WITH protect, noconstant(0.0)
 DECLARE dreturnstationcd = f8 WITH protect, noconstant(0.0)
 DECLARE dremovestationcd = f8 WITH protect, noconstant(0.0)
 DECLARE ddisposestationcd = f8 WITH protect, noconstant(0.0)
 DECLARE dmatchbl2spstationcd = f8 WITH protect, noconstant(0.0)
 DECLARE dmatchsl2spstationcd = f8 WITH protect, noconstant(0.0)
 DECLARE dmatchsl2blstationcd = f8 WITH protect, noconstant(0.0)
 DECLARE dptoestationcd = f8 WITH protect, noconstant(0.0)
 DECLARE dqastationcd = f8 WITH protect, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(levent_type_cs,"TRACKED",1,dtrackedcd)
 SET stat = uar_get_meaning_by_codeset(levent_type_cs,"PLACED IN",1,dplacedincd)
 SET stat = uar_get_meaning_by_codeset(levent_type_cs,"STORED",1,dstoredcd)
 SET stat = uar_get_meaning_by_codeset(levent_type_cs,"CHECKED IN",1,dcheckedincd)
 SET stat = uar_get_meaning_by_codeset(levent_type_cs,"CHECKED OUT",1,dcheckedoutcd)
 SET stat = uar_get_meaning_by_codeset(levent_type_cs,"REMOVED FROM",1,dremovedfromcd)
 SET stat = uar_get_meaning_by_codeset(levent_type_cs,"DISCARDED",1,ddiscardedcd)
 SET stat = uar_get_meaning_by_codeset(levent_type_cs,"MATCHED",1,dmatchedcd)
 SET stat = uar_get_meaning_by_codeset(levent_type_cs,"MISMATCHED",1,dmismatchedcd)
 SET stat = uar_get_meaning_by_codeset(levent_type_cs,"UNMATCHED",1,dunmatchedcd)
 SET stat = uar_get_meaning_by_codeset(levent_type_cs,"QUALITY",1,dqualitycd)
 SET stat = uar_get_meaning_by_codeset(ltrack_station_cs,"TRACK",1,dtrackstationcd)
 SET stat = uar_get_meaning_by_codeset(ltrack_station_cs,"PLACE",1,dplacestationcd)
 SET stat = uar_get_meaning_by_codeset(ltrack_station_cs,"STORE",1,dstorestationcd)
 SET stat = uar_get_meaning_by_codeset(ltrack_station_cs,"CHECKOUT",1,dcheckoutstationcd)
 SET stat = uar_get_meaning_by_codeset(ltrack_station_cs,"RETURN",1,dreturnstationcd)
 SET stat = uar_get_meaning_by_codeset(ltrack_station_cs,"REMOVE",1,dremovestationcd)
 SET stat = uar_get_meaning_by_codeset(ltrack_station_cs,"DISPOSE",1,ddisposestationcd)
 SET stat = uar_get_meaning_by_codeset(ltrack_station_cs,"MATCH_BL2SP",1,dmatchbl2spstationcd)
 SET stat = uar_get_meaning_by_codeset(ltrack_station_cs,"MATCH_SL2SP",1,dmatchsl2spstationcd)
 SET stat = uar_get_meaning_by_codeset(ltrack_station_cs,"MATCH_SL2BL",1,dmatchsl2blstationcd)
 SET stat = uar_get_meaning_by_codeset(ltrack_station_cs,"PTOE",1,dptoestationcd)
 SET stat = uar_get_meaning_by_codeset(ltrack_station_cs,"QA_INVENTORY",1,dqastationcd)
 SET stat = alterlist(reply->solcap,2)
 SET reply->solcap[1].identifier = "2010.1.00090.1"
 SET reply->solcap[1].degree_of_use_num = 0
 SET reply->solcap[1].degree_of_use_str = "NO"
 SET stat = alterlist(reply->solcap[1].other,7)
 SET reply->solcap[1].other[1].category_name =
 "Number of events recorded in the Track Inventory station, grouped by event type"
 SET stat = alterlist(reply->solcap[1].other[1].value,1)
 SET reply->solcap[1].other[1].value[1].display = "TRACKED"
 SET reply->solcap[1].other[1].value[1].value_num = 0
 SET reply->solcap[1].other[1].value[1].value_str = "NO"
 SET reply->solcap[1].other[2].category_name =
 "Number of events recorded in the Place Inventory station, grouped by event type"
 SET stat = alterlist(reply->solcap[1].other[2].value,3)
 SET reply->solcap[1].other[2].value[1].display = "PLACED IN"
 SET reply->solcap[1].other[2].value[1].value_num = 0
 SET reply->solcap[1].other[2].value[1].value_str = "NO"
 SET reply->solcap[1].other[2].value[2].display = "STORED"
 SET reply->solcap[1].other[2].value[2].value_num = 0
 SET reply->solcap[1].other[2].value[2].value_str = "NO"
 SET reply->solcap[1].other[2].value[3].display = "CHECKED IN"
 SET reply->solcap[1].other[2].value[3].value_num = 0
 SET reply->solcap[1].other[2].value[3].value_str = "NO"
 SET reply->solcap[1].other[3].category_name =
 "Number of events recorded in the Store Inventory station, grouped by event type"
 SET stat = alterlist(reply->solcap[1].other[3].value,2)
 SET reply->solcap[1].other[3].value[1].display = "STORED"
 SET reply->solcap[1].other[3].value[1].value_num = 0
 SET reply->solcap[1].other[3].value[1].value_str = "NO"
 SET reply->solcap[1].other[3].value[2].display = "CHECKED IN"
 SET reply->solcap[1].other[3].value[2].value_num = 0
 SET reply->solcap[1].other[3].value[2].value_str = "NO"
 SET reply->solcap[1].other[4].category_name =
 "Number of events recorded in the Check Out Inventory station, grouped by event type"
 SET stat = alterlist(reply->solcap[1].other[4].value,1)
 SET reply->solcap[1].other[4].value[1].display = "CHECKED OUT"
 SET reply->solcap[1].other[4].value[1].value_num = 0
 SET reply->solcap[1].other[4].value[1].value_str = "NO"
 SET reply->solcap[1].other[5].category_name =
 "Number of events recorded in the Return Inventory station, grouped by event type"
 SET stat = alterlist(reply->solcap[1].other[5].value,1)
 SET reply->solcap[1].other[5].value[1].display = "CHECKED IN"
 SET reply->solcap[1].other[5].value[1].value_num = 0
 SET reply->solcap[1].other[5].value[1].value_str = "NO"
 SET reply->solcap[1].other[6].category_name =
 "Number of events recorded in the Remove Inventory station, grouped by event type"
 SET stat = alterlist(reply->solcap[1].other[6].value,1)
 SET reply->solcap[1].other[6].value[1].display = "REMOVED FROM"
 SET reply->solcap[1].other[6].value[1].value_num = 0
 SET reply->solcap[1].other[6].value[1].value_str = "NO"
 SET reply->solcap[1].other[7].category_name =
 "Number of events recorded in the Dispose Inventory station, grouped by event type"
 SET stat = alterlist(reply->solcap[1].other[7].value,1)
 SET reply->solcap[1].other[7].value[1].display = "DISCARDED"
 SET reply->solcap[1].other[7].value[1].value_num = 0
 SET reply->solcap[1].other[7].value[1].value_str = "NO"
 SET reply->solcap[2].identifier = "2010.2.00073.1"
 SET reply->solcap[2].degree_of_use_num = 0
 SET reply->solcap[2].degree_of_use_str = "NO"
 SET stat = alterlist(reply->solcap[2].other,5)
 SET reply->solcap[2].other[1].category_name =
 "Number of events recorded in the Match Block To Specimen station, grouped by event type"
 SET stat = alterlist(reply->solcap[2].other[1].value,4)
 SET reply->solcap[2].other[1].value[1].display = "MATCHED"
 SET reply->solcap[2].other[1].value[1].value_num = 0
 SET reply->solcap[2].other[1].value[1].value_str = "NO"
 SET reply->solcap[2].other[1].value[2].display = "MISMATCHED"
 SET reply->solcap[2].other[1].value[2].value_num = 0
 SET reply->solcap[2].other[1].value[2].value_str = "NO"
 SET reply->solcap[2].other[1].value[3].display = "UNMATCHED"
 SET reply->solcap[2].other[1].value[3].value_num = 0
 SET reply->solcap[2].other[1].value[3].value_str = "NO"
 SET reply->solcap[2].other[1].value[4].display = "TRACKED"
 SET reply->solcap[2].other[1].value[4].value_num = 0
 SET reply->solcap[2].other[1].value[4].value_str = "NO"
 SET reply->solcap[2].other[2].category_name =
 "Number of events recorded in the Match Slide To Specimen station, grouped by event type"
 SET stat = alterlist(reply->solcap[2].other[2].value,4)
 SET reply->solcap[2].other[2].value[1].display = "MATCHED"
 SET reply->solcap[2].other[2].value[1].value_num = 0
 SET reply->solcap[2].other[2].value[1].value_str = "NO"
 SET reply->solcap[2].other[2].value[2].display = "MISMATCHED"
 SET reply->solcap[2].other[2].value[2].value_num = 0
 SET reply->solcap[2].other[2].value[2].value_str = "NO"
 SET reply->solcap[2].other[2].value[3].display = "UNMATCHED"
 SET reply->solcap[2].other[2].value[3].value_num = 0
 SET reply->solcap[2].other[2].value[3].value_str = "NO"
 SET reply->solcap[2].other[2].value[4].display = "TRACKED"
 SET reply->solcap[2].other[2].value[4].value_num = 0
 SET reply->solcap[2].other[2].value[4].value_str = "NO"
 SET reply->solcap[2].other[3].category_name =
 "Number of events recorded in the Match Slide To Block station, grouped by event type"
 SET stat = alterlist(reply->solcap[2].other[3].value,4)
 SET reply->solcap[2].other[3].value[1].display = "MATCHED"
 SET reply->solcap[2].other[3].value[1].value_num = 0
 SET reply->solcap[2].other[3].value[1].value_str = "NO"
 SET reply->solcap[2].other[3].value[2].display = "MISMATCHED"
 SET reply->solcap[2].other[3].value[2].value_num = 0
 SET reply->solcap[2].other[3].value[2].value_str = "NO"
 SET reply->solcap[2].other[3].value[3].display = "UNMATCHED"
 SET reply->solcap[2].other[3].value[3].value_num = 0
 SET reply->solcap[2].other[3].value[3].value_str = "NO"
 SET reply->solcap[2].other[3].value[4].display = "TRACKED"
 SET reply->solcap[2].other[3].value[4].value_num = 0
 SET reply->solcap[2].other[3].value[4].value_str = "NO"
 SET reply->solcap[2].other[4].category_name =
 "Number of events recorded in the PTOE station, grouped by event type"
 SET stat = alterlist(reply->solcap[2].other[4].value,1)
 SET reply->solcap[2].other[4].value[1].display = "TRACKED"
 SET reply->solcap[2].other[4].value[1].value_num = 0
 SET reply->solcap[2].other[4].value[1].value_str = "NO"
 SET reply->solcap[2].other[5].category_name =
 "Number of events recorded in the QA Inventory station, grouped by event type"
 SET stat = alterlist(reply->solcap[2].other[5].value,1)
 SET reply->solcap[2].other[5].value[1].display = "QUALITY"
 SET reply->solcap[2].other[5].value[1].value_num = 0
 SET reply->solcap[2].other[5].value[1].value_str = "NO"
 IF (dtrackstationcd > 0
  AND dtrackedcd > 0)
  SELECT INTO "nl:"
   sce.action_cd, trackcnt = count(sce.station_cd)
   FROM storage_content_event sce
   PLAN (sce
    WHERE sce.station_cd=dtrackstationcd
     AND sce.action_cd=dtrackedcd
     AND sce.action_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
     end_dt_tm))
   GROUP BY sce.action_cd
   DETAIL
    reply->solcap[1].other[1].value[1].value_num = trackcnt, reply->solcap[1].other[1].value[1].
    value_str = "YES", reply->solcap[1].degree_of_use_num = (reply->solcap[1].degree_of_use_num+
    trackcnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (dplacestationcd > 0
  AND ((dplacedincd > 0) OR (((dstoredcd > 0) OR (dcheckedincd > 0)) )) )
  SELECT INTO "nl:"
   sce.action_cd, placecnt = count(sce.station_cd)
   FROM storage_content_event sce
   PLAN (sce
    WHERE sce.station_cd=dplacestationcd
     AND sce.action_cd IN (dplacedincd, dstoredcd, dcheckedincd)
     AND sce.action_cd > 0
     AND sce.action_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
     end_dt_tm))
   GROUP BY sce.action_cd
   DETAIL
    CASE (sce.action_cd)
     OF dplacedincd:
      reply->solcap[1].other[2].value[1].value_num = placecnt,reply->solcap[1].other[2].value[1].
      value_str = "YES"
     OF dstoredcd:
      reply->solcap[1].other[2].value[2].value_num = placecnt,reply->solcap[1].other[2].value[2].
      value_str = "YES"
     OF dcheckedincd:
      reply->solcap[1].other[2].value[3].value_num = placecnt,reply->solcap[1].other[2].value[3].
      value_str = "YES"
    ENDCASE
    reply->solcap[1].degree_of_use_num = (reply->solcap[1].degree_of_use_num+ placecnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (dstorestationcd > 0
  AND ((dstoredcd > 0) OR (dcheckedincd > 0)) )
  SELECT INTO "nl:"
   sce.action_cd, storecnt = count(sce.station_cd)
   FROM storage_content_event sce
   PLAN (sce
    WHERE sce.station_cd=dstorestationcd
     AND sce.action_cd IN (dstoredcd, dcheckedincd)
     AND sce.action_cd > 0
     AND sce.action_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
     end_dt_tm))
   GROUP BY sce.action_cd
   DETAIL
    CASE (sce.action_cd)
     OF dstoredcd:
      reply->solcap[1].other[3].value[1].value_num = storecnt,reply->solcap[1].other[3].value[1].
      value_str = "YES"
     OF dcheckedincd:
      reply->solcap[1].other[3].value[2].value_num = storecnt,reply->solcap[1].other[3].value[2].
      value_str = "YES"
    ENDCASE
    reply->solcap[1].degree_of_use_num = (reply->solcap[1].degree_of_use_num+ storecnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (dcheckoutstationcd > 0
  AND dcheckedoutcd > 0)
  SELECT INTO "nl:"
   sce.action_cd, checkoutcnt = count(sce.station_cd)
   FROM storage_content_event sce
   PLAN (sce
    WHERE sce.station_cd=dcheckoutstationcd
     AND sce.action_cd=dcheckedoutcd
     AND sce.action_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
     end_dt_tm))
   GROUP BY sce.action_cd
   DETAIL
    reply->solcap[1].other[4].value[1].value_num = checkoutcnt, reply->solcap[1].other[4].value[1].
    value_str = "YES", reply->solcap[1].degree_of_use_num = (reply->solcap[1].degree_of_use_num+
    checkoutcnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (dreturnstationcd > 0
  AND dcheckedincd > 0)
  SELECT INTO "nl:"
   sce.action_cd, returncnt = count(sce.station_cd)
   FROM storage_content_event sce
   PLAN (sce
    WHERE sce.station_cd=dreturnstationcd
     AND sce.action_cd=dcheckedincd
     AND sce.action_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
     end_dt_tm))
   GROUP BY sce.action_cd
   DETAIL
    reply->solcap[1].other[5].value[1].value_num = returncnt, reply->solcap[1].other[5].value[1].
    value_str = "YES", reply->solcap[1].degree_of_use_num = (reply->solcap[1].degree_of_use_num+
    returncnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (dremovestationcd > 0
  AND dremovedfromcd > 0)
  SELECT INTO "nl:"
   sce.action_cd, removecnt = count(sce.station_cd)
   FROM storage_content_event sce
   PLAN (sce
    WHERE sce.station_cd=dremovestationcd
     AND sce.action_cd=dremovedfromcd
     AND sce.action_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
     end_dt_tm))
   GROUP BY sce.action_cd
   DETAIL
    reply->solcap[1].other[6].value[1].value_num = removecnt, reply->solcap[1].other[6].value[1].
    value_str = "YES", reply->solcap[1].degree_of_use_num = (reply->solcap[1].degree_of_use_num+
    removecnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (ddisposestationcd > 0
  AND ddiscardedcd > 0)
  SELECT INTO "nl:"
   sce.action_cd, disposecnt = count(sce.station_cd)
   FROM storage_content_event sce
   PLAN (sce
    WHERE sce.station_cd=ddisposestationcd
     AND sce.action_cd=ddiscardedcd
     AND sce.action_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
     end_dt_tm))
   GROUP BY sce.action_cd
   DETAIL
    reply->solcap[1].other[7].value[1].value_num = disposecnt, reply->solcap[1].other[7].value[1].
    value_str = "YES", reply->solcap[1].degree_of_use_num = (reply->solcap[1].degree_of_use_num+
    disposecnt)
   WITH nocounter
  ;end select
 ENDIF
 IF ((reply->solcap[1].degree_of_use_num > 0))
  SET reply->solcap[1].degree_of_use_str = "YES"
 ENDIF
 IF (dmatchbl2spstationcd > 0
  AND ((dmatchedcd > 0) OR (((dmismatchedcd > 0) OR (((dunmatchedcd > 0) OR (dtrackedcd > 0)) )) )) )
  SELECT INTO "nl:"
   sce.action_cd, matchcnt = count(sce.station_cd)
   FROM storage_content_event sce
   PLAN (sce
    WHERE sce.station_cd=dmatchbl2spstationcd
     AND sce.action_cd IN (dmatchedcd, dmismatchedcd, dunmatchedcd, dtrackedcd)
     AND sce.action_cd > 0
     AND sce.action_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
     end_dt_tm))
   GROUP BY sce.action_cd
   DETAIL
    CASE (sce.action_cd)
     OF dmatchedcd:
      reply->solcap[2].other[1].value[1].value_num = matchcnt,reply->solcap[2].other[1].value[1].
      value_str = "YES"
     OF dmismatchedcd:
      reply->solcap[2].other[1].value[2].value_num = matchcnt,reply->solcap[2].other[1].value[2].
      value_str = "YES"
     OF dunmatchedcd:
      reply->solcap[2].other[1].value[3].value_num = matchcnt,reply->solcap[2].other[1].value[3].
      value_str = "YES"
     OF dtrackedcd:
      reply->solcap[2].other[1].value[4].value_num = matchcnt,reply->solcap[2].other[1].value[4].
      value_str = "YES"
    ENDCASE
    reply->solcap[2].degree_of_use_num = (reply->solcap[2].degree_of_use_num+ matchcnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (dmatchsl2spstationcd > 0
  AND ((dmatchedcd > 0) OR (((dmismatchedcd > 0) OR (((dunmatchedcd > 0) OR (dtrackedcd > 0)) )) )) )
  SELECT INTO "nl:"
   sce.action_cd, matchcnt = count(sce.station_cd)
   FROM storage_content_event sce
   PLAN (sce
    WHERE sce.station_cd=dmatchsl2spstationcd
     AND sce.action_cd IN (dmatchedcd, dmismatchedcd, dunmatchedcd, dtrackedcd)
     AND sce.action_cd > 0
     AND sce.action_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
     end_dt_tm))
   GROUP BY sce.action_cd
   DETAIL
    CASE (sce.action_cd)
     OF dmatchedcd:
      reply->solcap[2].other[2].value[1].value_num = matchcnt,reply->solcap[2].other[2].value[1].
      value_str = "YES"
     OF dmismatchedcd:
      reply->solcap[2].other[2].value[2].value_num = matchcnt,reply->solcap[2].other[2].value[2].
      value_str = "YES"
     OF dunmatchedcd:
      reply->solcap[2].other[2].value[3].value_num = matchcnt,reply->solcap[2].other[2].value[3].
      value_str = "YES"
     OF dtrackedcd:
      reply->solcap[2].other[2].value[4].value_num = matchcnt,reply->solcap[2].other[2].value[4].
      value_str = "YES"
    ENDCASE
    reply->solcap[2].degree_of_use_num = (reply->solcap[2].degree_of_use_num+ matchcnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (dmatchsl2blstationcd > 0
  AND ((dmatchedcd > 0) OR (((dmismatchedcd > 0) OR (((dunmatchedcd > 0) OR (dtrackedcd > 0)) )) )) )
  SELECT INTO "nl:"
   sce.action_cd, matchcnt = count(sce.station_cd)
   FROM storage_content_event sce
   PLAN (sce
    WHERE sce.station_cd=dmatchsl2blstationcd
     AND sce.action_cd IN (dmatchedcd, dmismatchedcd, dunmatchedcd, dtrackedcd)
     AND sce.action_cd > 0
     AND sce.action_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
     end_dt_tm))
   GROUP BY sce.action_cd
   DETAIL
    CASE (sce.action_cd)
     OF dmatchedcd:
      reply->solcap[2].other[3].value[1].value_num = matchcnt,reply->solcap[2].other[3].value[1].
      value_str = "YES"
     OF dmismatchedcd:
      reply->solcap[2].other[3].value[2].value_num = matchcnt,reply->solcap[2].other[3].value[2].
      value_str = "YES"
     OF dunmatchedcd:
      reply->solcap[2].other[3].value[3].value_num = matchcnt,reply->solcap[2].other[3].value[3].
      value_str = "YES"
     OF dtrackedcd:
      reply->solcap[2].other[3].value[4].value_num = matchcnt,reply->solcap[2].other[3].value[4].
      value_str = "YES"
    ENDCASE
    reply->solcap[2].degree_of_use_num = (reply->solcap[2].degree_of_use_num+ matchcnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (dptoestationcd > 0
  AND dtrackedcd > 0)
  SELECT INTO "nl:"
   sce.action_cd, trackcnt = count(sce.station_cd)
   FROM storage_content_event sce
   PLAN (sce
    WHERE sce.station_cd=dptoestationcd
     AND sce.action_cd=dtrackedcd
     AND sce.action_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
     end_dt_tm))
   GROUP BY sce.action_cd
   DETAIL
    reply->solcap[2].other[4].value[1].value_num = trackcnt, reply->solcap[2].other[4].value[1].
    value_str = "YES", reply->solcap[2].degree_of_use_num = (reply->solcap[2].degree_of_use_num+
    trackcnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (dqastationcd > 0
  AND dqualitycd > 0)
  SELECT INTO "nl:"
   sce.action_cd, qualitycnt = count(sce.station_cd)
   FROM storage_content_event sce
   PLAN (sce
    WHERE sce.station_cd=dqastationcd
     AND sce.action_cd=dqualitycd
     AND sce.action_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
     end_dt_tm))
   GROUP BY sce.action_cd
   DETAIL
    reply->solcap[2].other[5].value[1].value_num = qualitycnt, reply->solcap[2].other[5].value[1].
    value_str = "YES", reply->solcap[2].degree_of_use_num = (reply->solcap[2].degree_of_use_num+
    qualitycnt)
   WITH nocounter
  ;end select
 ENDIF
 IF ((reply->solcap[2].degree_of_use_num > 0))
  SET reply->solcap[2].degree_of_use_str = "YES"
 ENDIF
END GO
