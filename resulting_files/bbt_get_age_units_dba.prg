CREATE PROGRAM bbt_get_age_units:dba
 RECORD reply(
   1 codesetlist[*]
     2 unit_cd = f8
     2 unit_disp = c50
     2 unit_mean = c20
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c15
       3 sourceobjectqual = i4
       3 sourceobjectvalue = c50
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c50
       3 sub_event_dt_tm = di8
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET stat = alterlist(reply->codesetlist,6)
 SET code_cnt = 1
 SET code_value = 0.0
 SET stat = uar_get_meaning_by_codeset(340,"DAYS",code_cnt,code_value)
 IF (code_value=0.0)
  SET reply->status = "Z"
  GO TO exit_script
 ENDIF
 SET reply->codesetlist[1].unit_cd = code_value
 SET code_cnt = 1
 SET code_value = 0.0
 SET stat = uar_get_meaning_by_codeset(340,"HOURS",code_cnt,code_value)
 IF (code_value=0.0)
  SET reply->status = "Z"
  GO TO exit_script
 ENDIF
 SET reply->codesetlist[2].unit_cd = code_value
 SET code_cnt = 1
 SET code_value = 0.0
 SET stat = uar_get_meaning_by_codeset(340,"MINUTES",code_cnt,code_value)
 IF (code_value=0.0)
  SET reply->status = "Z"
  GO TO exit_script
 ENDIF
 SET reply->codesetlist[3].unit_cd = code_value
 SET code_cnt = 1
 SET code_value = 0.0
 SET stat = uar_get_meaning_by_codeset(340,"MONTHS",code_cnt,code_value)
 IF (code_value=0.0)
  SET reply->status = "Z"
  GO TO exit_script
 ENDIF
 SET reply->codesetlist[4].unit_cd = code_value
 SET code_cnt = 1
 SET code_value = 0.0
 SET stat = uar_get_meaning_by_codeset(340,"WEEKS",code_cnt,code_value)
 IF (code_value=0.0)
  SET reply->status = "Z"
  GO TO exit_script
 ENDIF
 SET reply->codesetlist[5].unit_cd = code_value
 SET code_cnt = 1
 SET code_value = 0.0
 SET stat = uar_get_meaning_by_codeset(340,"YEARS",code_cnt,code_value)
 IF (code_value=0.0)
  SET reply->status = "Z"
  GO TO exit_script
 ENDIF
 SET reply->codesetlist[6].unit_cd = code_value
 SET reply->status = "S"
#exit_script
END GO
