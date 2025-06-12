CREATE PROGRAM dcp_get_apache_events:dba
 RECORD reply(
   1 selist[*]
     2 risk_adjustment_event_id = f8
     2 sentinel_event_category_cd = f8
     2 sentinel_event_category_disp = vc
     2 sentinel_event_category_desc = vc
     2 sentinel_event_category_mean = vc
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 sentinel_event_code_cd = f8
     2 sentinel_event_code_disp = vc
     2 sentinel_event_code_desc = vc
     2 sentinel_event_code_mean = vc
     2 sentinel_event_unit = f8
     2 preventable_ind = i2
     2 consequential_ind = i2
     2 sentinel_event_comment = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 DECLARE meaning_code(p1,p2) = f8
 EXECUTE FROM 1000_initialize TO 1099_initialize_exit
 EXECUTE FROM 2000_read TO 2099_read_exit
 GO TO 9999_exit_program
 SUBROUTINE meaning_code(mc_codeset,mc_meaning)
   SET mc_code = 0.0
   SET mc_text = fillstring(12," ")
   SET mc_text = mc_meaning
   SET mc_stat = uar_get_meaning_by_codeset(mc_codeset,nullterm(mc_text),1,mc_code)
   IF (mc_code > 0.0)
    RETURN(mc_code)
   ELSE
    RETURN(- (1.0))
   ENDIF
 END ;Subroutine
#1000_initialize
 SET reply->status_data.status = "F"
#1099_initialize_exit
#2000_read
 SELECT INTO "nl:"
  FROM risk_adjustment_event rae
  PLAN (rae
   WHERE (rae.risk_adjustment_id=request->risk_adjustment_id)
    AND rae.active_ind=1)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->selist,cnt), reply->selist[cnt].risk_adjustment_event_id
    = rae.risk_adjustment_event_id,
   reply->selist[cnt].sentinel_event_category_cd = rae.sentinel_event_category_cd, reply->selist[cnt]
   .beg_effective_dt_tm = rae.beg_effective_dt_tm, reply->selist[cnt].end_effective_dt_tm = rae
   .end_effective_dt_tm,
   reply->selist[cnt].sentinel_event_code_cd = rae.sentinel_event_code_cd, reply->selist[cnt].
   sentinel_event_unit = rae.sentinel_event_unit, reply->selist[cnt].preventable_ind = rae
   .preventable_ind,
   reply->selist[cnt].consequential_ind = rae.consequential_ind, reply->selist[cnt].
   sentinel_event_comment = rae.sentinel_event_comment
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#2099_read_exit
#9999_exit_program
 CALL echorecord(reply)
END GO
