CREATE PROGRAM acm_get_code_cdf_ext
 IF (validate(false,0)=0
  AND validate(false,1)=1)
  DECLARE false = i2 WITH public, constant(0)
 ENDIF
 IF (validate(true,0)=0
  AND validate(true,1)=1)
  DECLARE true = i2 WITH public, constant(1)
 ENDIF
 IF (validate(gen_nbr_error,0)=0
  AND validate(gen_nbr_error,1)=1)
  DECLARE gen_nbr_error = i2 WITH public, constant(3)
 ENDIF
 IF (validate(insert_error,0)=0
  AND validate(insert_error,1)=1)
  DECLARE insert_error = i2 WITH public, constant(4)
 ENDIF
 IF (validate(update_error,0)=0
  AND validate(update_error,1)=1)
  DECLARE update_error = i2 WITH public, constant(5)
 ENDIF
 IF (validate(replace_error,0)=0
  AND validate(replace_error,1)=1)
  DECLARE replace_error = i2 WITH public, constant(6)
 ENDIF
 IF (validate(delete_error,0)=0
  AND validate(delete_error,1)=1)
  DECLARE delete_error = i2 WITH public, constant(7)
 ENDIF
 IF (validate(undelete_error,0)=0
  AND validate(undelete_error,1)=1)
  DECLARE undelete_error = i2 WITH public, constant(8)
 ENDIF
 IF (validate(remove_error,0)=0
  AND validate(remove_error,1)=1)
  DECLARE remove_error = i2 WITH public, constant(9)
 ENDIF
 IF (validate(attribute_error,0)=0
  AND validate(attribute_error,1)=1)
  DECLARE attribute_error = i2 WITH public, constant(10)
 ENDIF
 IF (validate(lock_error,0)=0
  AND validate(lock_error,1)=1)
  DECLARE lock_error = i2 WITH public, constant(11)
 ENDIF
 IF (validate(none_found,0)=0
  AND validate(none_found,1)=1)
  DECLARE none_found = i2 WITH public, constant(12)
 ENDIF
 IF (validate(select_error,0)=0
  AND validate(select_error,1)=1)
  DECLARE select_error = i2 WITH public, constant(13)
 ENDIF
 IF (validate(update_cnt_error,0)=0
  AND validate(update_cnt_error,1)=1)
  DECLARE update_cnt_error = i2 WITH public, constant(14)
 ENDIF
 IF (validate(not_found,0)=0
  AND validate(not_found,1)=1)
  DECLARE not_found = i2 WITH public, constant(15)
 ENDIF
 IF (validate(inactivate_error,0)=0
  AND validate(inactivate_error,1)=1)
  DECLARE inactivate_error = i2 WITH public, constant(17)
 ENDIF
 IF (validate(activate_error,0)=0
  AND validate(activate_error,1)=1)
  DECLARE activate_error = i2 WITH public, constant(18)
 ENDIF
 IF (validate(uar_error,0)=0
  AND validate(uar_error,1)=1)
  DECLARE uar_error = i2 WITH public, constant(20)
 ENDIF
 IF (validate(duplicate_error,- (1)) != 21)
  DECLARE duplicate_error = i2 WITH protect, noconstant(21)
 ENDIF
 IF (validate(ccl_error,- (1)) != 22)
  DECLARE ccl_error = i2 WITH protect, noconstant(22)
 ENDIF
 IF (validate(execute_error,- (1)) != 23)
  DECLARE execute_error = i2 WITH protect, noconstant(23)
 ENDIF
 DECLARE failed = i2 WITH protect, noconstant(false)
 DECLARE table_name = vc WITH protect, noconstant(" ")
 DECLARE call_echo_ind = i2 WITH protect, noconstant(0)
 DECLARE pmhc_contributory_system_cd = f8 WITH protect, noconstant(0.0)
 FREE RECORD reply
 RECORD reply(
   1 qual_cnt = i4
   1 qual[*]
     2 code_set = i4
     2 cdf_ext_qual_cnt = i4
     2 cdf_ext_qual[*]
       3 cdf_meaning = c12
       3 field_name = vc
       3 field_value = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE t1 = i4 WITH protect, noconstant(0)
 DECLARE index = i4 WITH protect, noconstant(0)
 SET reply->qual_cnt = size(request->qual,5)
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->qual,reply->qual_cnt)
 FOR (index = 0 TO reply->qual_cnt)
   SET reply->qual[index].code_set = request->qual[index].code_set
 ENDFOR
 SELECT INTO "nl"
  FROM code_cdf_ext cce
  WHERE expand(t1,1,reply->qual_cnt,cce.code_set,request->qual[t1].code_set)
  ORDER BY cce.code_set
  HEAD cce.code_set
   t2 = locateval(t1,1,reply->qual_cnt,cce.code_set,request->qual[t1].code_set)
  DETAIL
   reply->qual[t2].cdf_ext_qual_cnt = (reply->qual[t2].cdf_ext_qual_cnt+ 1)
   IF (mod(reply->qual[t2].cdf_ext_qual_cnt,10)=1)
    stat = alterlist(reply->qual[t2].cdf_ext_qual,(reply->qual[t2].cdf_ext_qual_cnt+ 9))
   ENDIF
   t3 = reply->qual[t2].cdf_ext_qual_cnt, reply->qual[t2].cdf_ext_qual[t3].cdf_meaning = cce
   .cdf_meaning, reply->qual[t2].cdf_ext_qual[t3].field_name = trim(cce.field_name,3),
   reply->qual[t2].cdf_ext_qual[t3].field_value = trim(cce.field_value,3)
  FOOT  cce.code_set
   stat = alterlist(reply->qual[t2].cdf_ext_qual,reply->qual[t2].cdf_ext_qual_cnt)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
