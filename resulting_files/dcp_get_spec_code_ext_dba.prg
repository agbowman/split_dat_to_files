CREATE PROGRAM dcp_get_spec_code_ext:dba
 SET count1 = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  ce.code_value
  FROM code_value_extension ce
  PLAN (ce
   WHERE ce.code_set IN (6000, 6027, 14281)
    AND ((ce.field_name="Complete Order") OR (ce.field_name="DCP_ALLOW_CANCEL_IND"))
    AND ce.field_value="1")
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 += 1
   IF (count1 > size(reply->get_list,5))
    stat = alterlist(reply->get_list,(count1+ 10))
   ENDIF
   reply->get_list[count1].code_set = ce.code_set, reply->get_list[count1].code_value = ce.code_value
  FOOT REPORT
   stat = alterlist(reply->get_list,count1)
  WITH check
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
