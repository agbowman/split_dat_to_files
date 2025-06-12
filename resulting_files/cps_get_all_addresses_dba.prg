CREATE PROGRAM cps_get_all_addresses:dba
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
 IF ((validate(failed,- (9))=- (9)))
  DECLARE failed = i2 WITH noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH noconstant("")
  SET table_name = fillstring(50," ")
 ENDIF
 RECORD reply(
   1 address_qual = i4
   1 address[*]
     2 address_id = f8
     2 parent_entity_id = f8
     2 parent_entity_name = c32
     2 active_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 updt_cnt = i4
     2 street_addr = c100
     2 street_addr2 = c100
     2 city = c100
     2 state = c100
     2 zipcode = c25
     2 county = c100
     2 country = c100
     2 address_type_cd = f8
     2 address_type_seq = i4
     2 operation_hours = vc
     2 comment_txt = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET cd_for_cdf_mean = 0
 SELECT INTO "NL:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=212
   AND (c.cdf_meaning=request->address_type_cdf_mean)
  DETAIL
   cd_for_cdf_mean = c.code_value
  WITH nocounter
 ;end select
 EXECUTE cps_get_all_addresses_sub parser(
  IF (trim(request->address_type_cdf_mean)="") "0=0"
  ELSE "a.address_type_cd = cd_for_cdf_mean"
  ENDIF
  ), parser(
  IF ((request->address_type_seq=0.0)) "0=0"
  ELSE "a.address_type_seq = request->address_type_seq"
  ENDIF
  )
END GO
