CREATE PROGRAM ct_rn_ops_run:dba
 RECORD status_rec(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE run_group_id = f8 WITH protect, noconstant(0.0)
 SUBROUTINE (nextsequence(x=i2) =f8)
   DECLARE nsequence = f8 WITH protect
   SELECT INTO "nl:"
    nextseqnum = seq(protocol_def_seq,nextval)
    FROM dual
    DETAIL
     nsequence = nextseqnum
    WITH nocounter
   ;end select
   RETURN(nsequence)
 END ;Subroutine
 SET run_group_id = nextsequence(0)
 CALL echo(build("ct_rn_ops_run:run_group_id = ",run_group_id))
 EXECUTE ct_rn_ops_prerun value(run_group_id) WITH replace("STATUS_REPLY","STATUS_REC")
 EXECUTE ct_run_prescreen_ops value(run_group_id) WITH replace("STATUS_REPLY","STATUS_REC")
 EXECUTE ct_rn_ops_data_extract value(run_group_id) WITH replace("STATUS_REPLY","STATUS_REC")
 EXECUTE ct_rn_gather_data value(run_group_id) WITH replace("REPLY","STATUS_REC")
 EXECUTE ct_rn_send_data value(run_group_id) WITH replace("REPLY","STATUS_REC")
 EXECUTE ct_rn_ops_postrun value(run_group_id) WITH replace("REPLY","STATUS_REC")
 SET last_mod = "001"
 SET mod_date = "July 21, 2009"
END GO
