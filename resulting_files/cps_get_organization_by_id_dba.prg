CREATE PROGRAM cps_get_organization_by_id:dba
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
   1 organization_qual = i4
   1 organization[*]
     2 organization_id = f8
     2 updt_cnt = i4
     2 org_name = c100
     2 org_name_key = c100
     2 federal_tax_id_nbr = c100
     2 org_status_cd = f8
     2 org_class_cd = f8
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
 SET nbr_id_rows = size(request->qual,5)
 SELECT INTO "nl:"
  FROM organization o,
   (dummyt d  WITH seq = value(nbr_id_rows))
  PLAN (d)
   JOIN (o
   WHERE (request->qual[d.seq].organization_id=o.organization_id))
  DETAIL
   count1 += 1
   IF (mod(count1,100)=1)
    stat = alterlist(reply->organization,(count1+ 100))
   ENDIF
   reply->organization[count1].organization_id = o.organization_id, reply->organization[count1].
   updt_cnt = o.updt_cnt, reply->organization[count1].org_name = o.org_name,
   reply->organization[count1].org_name_key = o.org_name_key, reply->organization[count1].
   federal_tax_id_nbr = o.federal_tax_id_nbr, reply->organization[count1].org_status_cd = o
   .org_status_cd,
   reply->organization[count1].org_class_cd = o.org_class_cd, reply->organization[count1].
   beg_effective_dt_tm = cnvtdatetime(o.beg_effective_dt_tm), reply->organization[count1].
   end_effective_dt_tm = cnvtdatetime(o.end_effective_dt_tm)
  WITH nocounter
 ;end select
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alterlist(reply->organization,count1)
 SET reply->organization_qual = count1
END GO
