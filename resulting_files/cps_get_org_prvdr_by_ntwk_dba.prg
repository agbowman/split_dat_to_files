CREATE PROGRAM cps_get_org_prvdr_by_ntwk:dba
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
   1 org_ntwk_prvdr[*]
     2 org_ntwk_prvdr_id = f8
     2 updt_cnt = i4
     2 organization_id = f8
     2 network_id = f8
     2 specialty_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
   1 organization[*]
     2 organization_id = f8
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
 EXECUTE cps_get_org_prvdr_by_ntwk_sub parser(
  IF ((request->network_id=0.0)) "0=0"
  ELSE "P.network_id=request->network_id "
  ENDIF
  ), parser(
  IF ((request->specialty_cd=0.0)) "0=0"
  ELSE "P.specialty_cd=request->specialty_cd"
  ENDIF
  )
END GO
