CREATE PROGRAM cps_ens_concept:dba
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
   1 conceptcnt = i2
   1 concept[*]
     2 concept_identifier = c18
     2 concept_source_cd = f8
     2 concept_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[2]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 SET add = 1
 SET upt = 2
 SET qual = request->conceptcnt
 SET reply->conceptcnt = request->conceptcnt
 SET stat = alterlist(reply->concept,(reply->conceptcnt+ 1))
 SET dhtable_name = fillstring(100," ")
 SET serrmsg_error = fillstring(100," ")
 IF (trim(request->action) != " ")
  IF (cnvtupper(request->action)="ADD")
   SET k = 1
   EXECUTE cps_add_concept
  ELSE
   SET k = 1
   EXECUTE cps_upt_concept
  ENDIF
 ELSE
  FOR (k = 1 TO qual)
    IF ((request->concept[k].concept_action_ind=add))
     EXECUTE cps_add_concept
    ELSE
     EXECUTE cps_upt_concept
    ENDIF
  ENDFOR
 ENDIF
END GO
