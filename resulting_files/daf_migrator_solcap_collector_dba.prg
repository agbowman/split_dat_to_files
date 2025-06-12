CREATE PROGRAM daf_migrator_solcap_collector:dba
 SET stat = alterlist(reply->solcap,1)
 SET reply->solcap[1].identifier = "2011.1.00103.4"
 DECLARE rowcnt = i4 WITH public, noconstant(0)
 DECLARE usercnt = i4 WITH public, noconstant(0)
 FREE RECORD dmsc_users
 RECORD dmsc_users(
   1 user_list[*]
     2 user_id = f8
 )
 DECLARE finduserid(userid=f8) = i2
 SELECT INTO "nl:"
  FROM dm_script_migration_stage dsms
  WHERE dsms.updt_dt_tm >= cnvtdatetime(request->start_dt_tm)
   AND dsms.updt_dt_tm <= cnvtdatetime(request->end_dt_tm)
   AND dsms.active_ind=0
  DETAIL
   rowcnt = (rowcnt+ 1)
   IF (finduserid(dsms.commit_updt_id)=0)
    usercnt = (usercnt+ 1), stat = alterlist(dmsc_users->user_list,usercnt), dmsc_users->user_list[
    usercnt].user_id = dsms.commit_updt_id
   ENDIF
   IF (finduserid(dsms.migration_updt_id)=0)
    usercnt = (usercnt+ 1), stat = alterlist(dmsc_users->user_list,usercnt), dmsc_users->user_list[
    usercnt].user_id = dsms.migration_updt_id
   ENDIF
   IF (finduserid(dsms.updt_id)=0)
    usercnt = (usercnt+ 1), stat = alterlist(dmsc_users->user_list,usercnt), dmsc_users->user_list[
    usercnt].user_id = dsms.updt_id
   ENDIF
  WITH nocounter
 ;end select
 SET reply->solcap[1].degree_of_use_num = rowcnt
 SET reply->solcap[1].distinct_user_count = usercnt
 FREE RECORD dmsc_users
 SUBROUTINE finduserid(userid)
   DECLARE iloop = i4 WITH public, noconstant(0)
   IF (usercnt=0)
    RETURN(0)
   ELSE
    FOR (iloop = 1 TO usercnt)
      IF ((dmsc_users->user_list[iloop].user_id=userid))
       RETURN(1)
      ENDIF
    ENDFOR
   ENDIF
   RETURN(0)
 END ;Subroutine
END GO
