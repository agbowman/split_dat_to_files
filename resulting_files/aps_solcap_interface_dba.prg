CREATE PROGRAM aps_solcap_interface:dba
 SET stat = alterlist(reply->solcap,2)
 SET reply->solcap[1].identifier = "2012.1.00147.1"
 SET reply->solcap[1].degree_of_use_num = 0
 SET reply->solcap[1].degree_of_use_str = "NO"
 SET stat = alterlist(reply->solcap[1].other,1)
 SET reply->solcap[1].other[1].category_name =
 "Number of case prefixes defined to be interfaced as an indicator of interface use."
 SET stat = alterlist(reply->solcap[1].other[1].value,1)
 SET reply->solcap[1].other[1].value[1].display = "Prefixes"
 SET reply->solcap[1].other[1].value[1].value_num = 0
 SET reply->solcap[1].other[1].value[1].value_str = "NO"
 SELECT INTO "nl:"
  prefixcnt = count(ap.prefix_id)
  FROM ap_prefix ap
  WHERE ap.active_ind=1
   AND ap.interface_flag=1
  DETAIL
   reply->solcap[1].other[1].value[1].value_num = prefixcnt, reply->solcap[1].other[1].value[1].
   value_str = "YES"
  FOOT REPORT
   reply->solcap[1].degree_of_use_num = (reply->solcap[1].degree_of_use_num+ prefixcnt)
  WITH nocounter
 ;end select
 IF ((reply->solcap[1].degree_of_use_num > 0))
  SET reply->solcap[1].degree_of_use_str = "YES"
 ENDIF
 SET reply->solcap[2].identifier = "2014.1.00318.1"
 SET reply->solcap[2].degree_of_use_num = 0
 SET reply->solcap[2].degree_of_use_str = "NO"
 SET stat = alterlist(reply->solcap[2].other,1)
 SET reply->solcap[2].other[1].category_name =
 "Number of tracking events received from inbound interface as an indicator of interface use."
 SET stat = alterlist(reply->solcap[2].other[1].value,1)
 SET reply->solcap[2].other[1].value[1].display = "No of tracking events received"
 SET reply->solcap[2].other[1].value[1].value_num = 0
 SET reply->solcap[2].other[1].value[1].value_str = "NO"
 DECLARE station_cd = f8 WITH constant(uar_get_code_by("MEANING",29473,"INTERFACED")), protect
 IF (station_cd != 0.0)
  SELECT INTO "nl:"
   eventcnt = count(sce.storage_content_event_id)
   FROM storage_content_event sce
   WHERE sce.station_cd=station_cd
    AND sce.action_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
    end_dt_tm)
   DETAIL
    reply->solcap[2].other[1].value[1].value_num = eventcnt, reply->solcap[2].other[1].value[1].
    value_str = "YES"
   FOOT REPORT
    reply->solcap[2].degree_of_use_num = (reply->solcap[2].degree_of_use_num+ eventcnt)
   WITH nocounter
  ;end select
 ENDIF
 IF ((reply->solcap[2].degree_of_use_num > 0))
  SET reply->solcap[2].degree_of_use_str = "YES"
 ENDIF
END GO
