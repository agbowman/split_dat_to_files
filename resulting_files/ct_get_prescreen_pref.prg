CREATE PROGRAM ct_get_prescreen_pref
 RECORD reply(
   1 pref_value = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ( NOT (validate(domain_reply)))
  RECORD domain_reply(
    1 logical_domain_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 EXECUTE ct_get_logical_domain_id  WITH replace("REPLY",domain_reply)
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 SET last_mod = "001"
 SET mod_date = "May 12, 2020"
 RECORD prefrequest(
   1 write_ind = i2
   1 pref[1]
     2 contexts[2]
       3 context = vc
       3 context_id = vc
     2 section = vc
     2 section_id = vc
     2 entries[*]
       3 entry = vc
       3 values[*]
         4 value = vc
 )
 IF ( NOT (validate(prefreply,0)))
  RECORD prefreply(
    1 pref[*]
      2 section = vc
      2 section_id = vc
      2 entries[*]
        3 pref_exists_ind = i2
        3 entry = vc
        3 values[*]
          4 value = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET prefrequest->write_ind = 0
 SET prefrequest->pref[1].contexts[1].context = "logical domain"
 SET prefrequest->pref[1].contexts[1].context_id = cnvtstringchk(domain_reply->logical_domain_id,31,2
  )
 SET prefrequest->pref[1].contexts[2].context = "default"
 SET prefrequest->pref[1].contexts[2].context_id = "system"
 SET prefrequest->pref[1].section = "application"
 SET prefrequest->pref[1].section_id = "powertrials"
 SET stat = alterlist(prefrequest->pref[1].entries,1)
 SET prefrequest->pref[1].entries[1].entry = "screener_pref"
 EXECUTE logical
 EXECUTE prefrtl
 EXECUTE ppr_preferences  WITH replace("REQUEST","PREFREQUEST"), replace("REPLY","PREFREPLY")
 SET reply->pref_value = cnvtint(prefreply->pref[1].entries[1].values[1].value)
#exit_script
 IF ((prefreply->status_data.status="S"))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
END GO
