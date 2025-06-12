CREATE PROGRAM cps_get_hp_all_networks:dba
 CALL echo("*****PM_HEADER_CCL.inc - 668615****")
 IF ((validate(gen_nbr_error,- (9))=- (9)))
  DECLARE gen_nbr_error = i2 WITH constant(3)
 ENDIF
 IF ((validate(insert_error,- (9))=- (9)))
  DECLARE insert_error = i2 WITH constant(4)
 ENDIF
 IF ((validate(update_error,- (9))=- (9)))
  DECLARE update_error = i2 WITH constant(5)
 ENDIF
 IF ((validate(replace_error,- (9))=- (9)))
  DECLARE replace_error = i2 WITH constant(6)
 ENDIF
 IF ((validate(delete_error,- (9))=- (9)))
  DECLARE delete_error = i2 WITH constant(7)
 ENDIF
 IF ((validate(undelete_error,- (9))=- (9)))
  DECLARE undelete_error = i2 WITH constant(8)
 ENDIF
 IF ((validate(remove_error,- (9))=- (9)))
  DECLARE remove_error = i2 WITH constant(9)
 ENDIF
 IF ((validate(attribute_error,- (9))=- (9)))
  DECLARE attribute_error = i2 WITH constant(10)
 ENDIF
 IF ((validate(lock_error,- (9))=- (9)))
  DECLARE lock_error = i2 WITH constant(11)
 ENDIF
 IF ((validate(none_found,- (9))=- (9)))
  DECLARE none_found = i2 WITH constant(12)
 ENDIF
 IF ((validate(select_error,- (9))=- (9)))
  DECLARE select_error = i2 WITH constant(13)
 ENDIF
 IF ((validate(add_history_error,- (9))=- (9)))
  DECLARE add_history_error = i2 WITH constant(14)
 ENDIF
 IF ((validate(transaction_error,- (9))=- (9)))
  DECLARE transaction_error = i2 WITH constant(15)
 ENDIF
 IF ((validate(none_found_ft,- (9))=- (9)))
  DECLARE none_found_ft = i2 WITH constant(16)
 ENDIF
 IF ((validate(failed,- (9))=- (9)))
  DECLARE failed = i2 WITH noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH noconstant("")
  SET table_name = fillstring(50," ")
 ENDIF
 RECORD reply(
   1 network_qual = i4
   1 network[*]
     2 network_id = f8
     2 carrier_id = f8
     2 network_description = vc
     2 network_name = vc
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 IF ((request->carrier_id=0))
  SELECT INTO "nl:"
   FROM network n
   WHERE n.active_ind=true
    AND n.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND n.end_effective_dt_tm >= cnvtdatetime(sysdate)
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 += 1, stat = alterlist(reply->network,count1), reply->network[count1].network_id = n
    .network_id,
    reply->network[count1].carrier_id = n.carrier_id, reply->network[count1].network_name = n
    .network_name, reply->network[count1].network_description = n.network_description,
    reply->network[count1].beg_effective_dt_tm = n.beg_effective_dt_tm, reply->network[count1].
    end_effective_dt_tm = n.end_effective_dt_tm
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM network n
   WHERE n.active_ind=true
    AND (n.carrier_id=request->carrier_id)
    AND n.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND n.end_effective_dt_tm >= cnvtdatetime(sysdate)
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 += 1, stat = alterlist(reply->network,count1), reply->network[count1].network_id = n
    .network_id,
    reply->network[count1].carrier_id = n.carrier_id, reply->network[count1].network_name = n
    .network_name, reply->network[count1].network_description = n.network_description,
    reply->network[count1].beg_effective_dt_tm = n.beg_effective_dt_tm, reply->network[count1].
    end_effective_dt_tm = n.end_effective_dt_tm
   WITH nocounter
  ;end select
 ENDIF
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ENDIF
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "network"
 ELSE
  SET reply->status_data.status = "S"
  SET stat = alterlist(reply->network,count1)
 ENDIF
 SET reply->network_qual = count1
#9999_end
END GO
