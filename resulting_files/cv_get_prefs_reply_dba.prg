CREATE PROGRAM cv_get_prefs_reply:dba
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 IF ( NOT (validate(reply)))
  RECORD reply(
    1 group[*]
      2 groupname = vc
      2 subgroupname = vc
      2 entry[*]
        3 entryname = vc
        3 values[*]
          4 value = vc
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH persistscript
 ENDIF
 SET last_mod = "000"
END GO
