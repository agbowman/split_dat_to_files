CREATE PROGRAM cv_get_addresses:dba
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
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 addresses[*]
      2 address_id = f8
      2 parent_entity_name = c32
      2 parent_entity_id = f8
      2 address_type_cd = f8
      2 updt_cnt = i4
      2 updt_dt_tm = dq8
      2 updt_id = f8
      2 updt_task = i4
      2 updt_applctx = i4
      2 active_ind = i2
      2 active_status_cd = f8
      2 active_status_dt_tm = dq8
      2 active_status_prsnl_id = f8
      2 address_format_cd = f8
      2 beg_effective_dt_tm = dq8
      2 end_effective_dt_tm = dq8
      2 contact_name = c200
      2 residence_type_cd = f8
      2 comment_txt = c200
      2 street_addr = c100
      2 street_addr2 = c100
      2 street_addr3 = c100
      2 street_addr4 = c100
      2 city = c100
      2 state = c100
      2 state_cd = f8
      2 zipcode = c25
      2 zip_code_group_cd = f8
      2 postal_barcode_info = c100
      2 county = c100
      2 county_cd = f8
      2 country = c100
      2 country_cd = f8
      2 residence_cd = f8
      2 mail_stop = c100
      2 data_status_cd = f8
      2 data_status_dt_tm = dq8
      2 data_status_prsnl_id = f8
      2 address_type_seq = i4
      2 beg_effective_mm_dd = i4
      2 end_effective_mm_dd = i4
      2 contributor_system_cd = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET nbr_entity_names = size(request->parent_entity_name_qual,5)
 SET nbr_entity_ids = 0
 FOR (n = 1 TO nbr_entity_names)
   IF (nbr_entity_ids < size(request->parent_entity_name_qual[n].parent_entity_id_qual,5))
    SET nbr_entity_ids = size(request->parent_entity_name_qual[n].parent_entity_id_qual,5)
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM address a,
   (dummyt d1  WITH seq = value(nbr_entity_names)),
   (dummyt d2  WITH seq = value(nbr_entity_ids))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(request->parent_entity_name_qual[d1.seq].parent_entity_id_qual,5))
   JOIN (a
   WHERE (a.parent_entity_name=request->parent_entity_name_qual[d1.seq].parent_entity_name)
    AND (a.parent_entity_id=request->parent_entity_name_qual[d1.seq].parent_entity_id_qual[d2.seq].
   parent_entity_id)
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND a.end_effective_dt_tm >= cnvtdatetime(sysdate))
  HEAD REPORT
   count1 = 0, stat = alterlist(reply->addresses,10)
  DETAIL
   count1 += 1
   IF (mod(count1,10)=1
    AND count1 > 10)
    stat = alterlist(reply->addresses,(count1+ 9))
   ENDIF
   reply->addresses[count1].address_id = a.address_id, reply->addresses[count1].parent_entity_name =
   a.parent_entity_name, reply->addresses[count1].parent_entity_id = a.parent_entity_id,
   reply->addresses[count1].address_type_cd = a.address_type_cd, reply->addresses[count1].updt_cnt =
   a.updt_cnt, reply->addresses[count1].updt_dt_tm = a.updt_dt_tm,
   reply->addresses[count1].updt_id = a.updt_id, reply->addresses[count1].updt_task = a.updt_task,
   reply->addresses[count1].updt_applctx = a.updt_applctx,
   reply->addresses[count1].active_ind = a.active_ind, reply->addresses[count1].active_status_cd = a
   .active_status_cd, reply->addresses[count1].active_status_dt_tm = a.active_status_dt_tm,
   reply->addresses[count1].active_status_prsnl_id = a.active_status_prsnl_id, reply->addresses[
   count1].address_format_cd = a.address_format_cd, reply->addresses[count1].beg_effective_dt_tm = a
   .beg_effective_dt_tm,
   reply->addresses[count1].end_effective_dt_tm = a.end_effective_dt_tm, reply->addresses[count1].
   contact_name = a.contact_name, reply->addresses[count1].residence_type_cd = a.residence_type_cd,
   reply->addresses[count1].comment_txt = a.comment_txt, reply->addresses[count1].street_addr = a
   .street_addr, reply->addresses[count1].street_addr2 = a.street_addr2,
   reply->addresses[count1].street_addr3 = a.street_addr3, reply->addresses[count1].street_addr4 = a
   .street_addr4, reply->addresses[count1].city = a.city,
   reply->addresses[count1].state = a.state, reply->addresses[count1].state_cd = a.state_cd, reply->
   addresses[count1].zipcode = a.zipcode,
   reply->addresses[count1].zip_code_group_cd = a.zip_code_group_cd, reply->addresses[count1].
   postal_barcode_info = a.postal_barcode_info, reply->addresses[count1].county = a.county,
   reply->addresses[count1].county_cd = a.county_cd, reply->addresses[count1].country = a.country,
   reply->addresses[count1].country_cd = a.country_cd,
   reply->addresses[count1].residence_cd = a.residence_cd, reply->addresses[count1].mail_stop = a
   .mail_stop, reply->addresses[count1].data_status_cd = a.data_status_cd,
   reply->addresses[count1].data_status_dt_tm = a.data_status_dt_tm, reply->addresses[count1].
   data_status_prsnl_id = a.data_status_prsnl_id, reply->addresses[count1].address_type_seq = a
   .address_type_seq,
   reply->addresses[count1].beg_effective_mm_dd = a.beg_effective_mm_dd, reply->addresses[count1].
   end_effective_mm_dd = a.end_effective_mm_dd, reply->addresses[count1].contributor_system_cd = a
   .contributor_system_cd
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->addresses,count1)
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "ADDRESS"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
