CREATE PROGRAM dcp_get_apache_outcomes:dba
 RECORD reply(
   1 outcome_list[*]
     2 equation_name = vc
     2 outcome_value = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 EXECUTE FROM 1000_initialize TO 1999_initialize_exit
 EXECUTE FROM 2000_read TO 2999_read_exit
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
 SET cnt = 0
#1999_initialize_exit
#2000_read
 SELECT INTO "nl:"
  FROM risk_adjustment_outcomes rao
  PLAN (rao
   WHERE (rao.risk_adjustment_day_id=request->risk_adjustment_day_id)
    AND rao.active_ind=1)
  ORDER BY rao.equation_name
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->outcome_list,cnt), reply->outcome_list[cnt].equation_name
    = rao.equation_name
   IF (((rao.equation_name="*LOS*") OR (rao.equation_name="*TISS*")) )
    reply->outcome_list[cnt].outcome_value = rao.outcome_value
   ELSE
    reply->outcome_list[cnt].outcome_value = (rao.outcome_value * 100)
   ENDIF
  WITH nocounter
 ;end select
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#2999_read_exit
#9999_exit_program
 CALL echorecord(reply)
END GO
