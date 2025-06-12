CREATE PROGRAM afc_srv_get_codeset:dba
 RECORD reply(
   1 qual[*]
     2 value_cd = f8
     2 code_disp = c50
     2 code_descr = c100
     2 meaning = c12
     2 code_set = i4
     2 denominator = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c15
       3 sourceobjectqual = i4
       3 sourceobjectvalue = c50
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c50
       3 sub_event_dt_tm = di8
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT INTO "nl:"
  c.code_value, c.display, c.description,
  c.cdf_meaning, c.code_set
  FROM code_value c
  WHERE (c.code_set=request->code_set)
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  ORDER BY c.code_set, c.collation_seq, c.display_key
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 += 1, stat = alterlist(reply->qual,count1), reply->qual[count1].value_cd = c.code_value,
   reply->qual[count1].code_disp = c.display, reply->qual[count1].code_descr = c.description, reply->
   qual[count1].meaning = c.cdf_meaning,
   reply->qual[count1].code_set = c.code_set
  WITH nocounter
 ;end select
 IF ((request->code_set=14276))
  SELECT INTO "nl:"
   c.code_value, c.display, c.description,
   c.cdf_meaning, c.code_set, cve.field_value
   FROM (dummyt d  WITH seq = value(size(reply->qual,5))),
    code_value_extension cve
   PLAN (d)
    JOIN (cve
    WHERE (cve.code_set=reply->qual[d.seq].code_set)
     AND (cve.code_value=reply->qual[d.seq].value_cd)
     AND cve.field_name="DENOMINATOR")
   DETAIL
    reply->qual[d.seq].denominator = cnvtreal(cve.field_value)
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
