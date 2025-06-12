CREATE PROGRAM aps_solcap_syn_usage:dba
 DECLARE stat = i4 WITH protect, noconstant(0)
 SET stat = alterlist(reply->solcap,1)
 SET reply->solcap[1].identifier = "2015.1.00006.2"
 SET reply->solcap[1].degree_of_use_num = 0
 SET reply->solcap[1].degree_of_use_str = "NO"
 SET stat = alterlist(reply->solcap[1].other,1)
 SET reply->solcap[1].other[1].category_name =
 "Number of synoptic worksheets completed, grouped by worksheet type"
 SET stat = alterlist(reply->solcap[1].other[1].value,2)
 SET reply->solcap[1].other[1].value[1].display = "PowerNote Synoptic Worksheet"
 SET reply->solcap[1].other[1].value[1].value_num = 0
 SET reply->solcap[1].other[1].value[1].value_str = "NO"
 SET reply->solcap[1].other[1].value[2].display = "mTuitive Synoptic Worksheet"
 SET reply->solcap[1].other[1].value[2].value_num = 0
 SET reply->solcap[1].other[1].value[2].value_str = "NO"
 SELECT INTO "nl:"
  acsw.foreign_ws_ident, acsw.status_flag
  FROM ap_case_synoptic_ws acsw
  WHERE acsw.status_flag=2
   AND acsw.updt_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->end_dt_tm
   )
  DETAIL
   IF (size(trim(acsw.foreign_ws_ident,1),1) > 0)
    reply->solcap[1].other[1].value[2].value_num = (reply->solcap[1].other[1].value[2].value_num+ 1)
   ELSE
    reply->solcap[1].other[1].value[1].value_num = (reply->solcap[1].other[1].value[1].value_num+ 1)
   ENDIF
  WITH nocounter
 ;end select
 IF ((reply->solcap[1].other[1].value[1].value_num > 0))
  SET reply->solcap[1].other[1].value[1].value_str = "YES"
  SET reply->solcap[1].degree_of_use_num = (reply->solcap[1].degree_of_use_num+ reply->solcap[1].
  other[1].value[1].value_num)
 ENDIF
 IF ((reply->solcap[1].other[1].value[2].value_num > 0))
  SET reply->solcap[1].other[1].value[2].value_str = "YES"
  SET reply->solcap[1].degree_of_use_num = (reply->solcap[1].degree_of_use_num+ reply->solcap[1].
  other[1].value[2].value_num)
 ENDIF
 IF ((reply->solcap[1].degree_of_use_num > 0))
  SET reply->solcap[1].degree_of_use_str = "YES"
 ENDIF
END GO
