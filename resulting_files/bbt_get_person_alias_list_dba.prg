CREATE PROGRAM bbt_get_person_alias_list:dba
 IF ((request->called_from_script_ind != 1))
  RECORD reply(
    1 aliaslist[*]
      2 alias_type_cd = f8
      2 alias_type_disp = vc
      2 alias_type_mean = c12
      2 alias = vc
      2 alias_formatted = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET select_ok_ind = 0
 SET alias_cnt = 0
 SET stat = alterlist(reply->aliaslist,5)
 SELECT INTO "nl:"
  p.seq, new_alias = trim(cnvtalias(p.alias,p.alias_pool_cd))
  FROM person_alias p
  PLAN (p
   WHERE (p.person_id=request->person_id)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  DETAIL
   alias_cnt = (alias_cnt+ 1)
   IF (mod(alias_cnt,5)=1
    AND alias_cnt != 1)
    stat = alterlist(reply->aliaslist,(alias_cnt+ 4))
   ENDIF
   reply->aliaslist[alias_cnt].alias_type_cd = p.person_alias_type_cd, reply->aliaslist[alias_cnt].
   alias = p.alias, reply->aliaslist[alias_cnt].alias_formatted = new_alias
  FOOT REPORT
   stat = alterlist(reply->aliaslist,alias_cnt), select_ok_ind = 1
  WITH nocounter, nullreport
 ;end select
#exit_program
 IF (select_ok_ind=1)
  IF (alias_cnt > 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
END GO
