CREATE PROGRAM dcp_load_code_sets:dba
 RECORD reply(
   1 code_cnt = i2
   1 code_list[*]
     2 code_value = f8
     2 code_set = i4
     2 display = c40
     2 display_key = c40
     2 description = c60
     2 definition = c100
     2 cdf_meaning = c12
     2 collation_seq = i4
     2 active_ind = i2
     2 updt_cnt = i2
     2 concept_cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->code_cnt = 0
 SET reply->status_data.status = "F"
 SET code_cnt = 0
 SET code_set_nbr = cnvtint(size(request->code_set_list,5))
 DECLARE indx = i4 WITH public, noconstant(0)
 SELECT INTO "nl:"
  0
  FROM code_value c
  PLAN (c
   WHERE expand(indx,1,size(request->code_set_list,5),c.code_set,request->code_set_list[indx].
    code_set))
  DETAIL
   code_cnt = (code_cnt+ 1), stat = alterlist(reply->code_list,code_cnt), reply->code_list[code_cnt].
   code_value = c.code_value,
   reply->code_list[code_cnt].code_set = c.code_set, reply->code_list[code_cnt].display = c.display,
   reply->code_list[code_cnt].display_key = c.display_key,
   reply->code_list[code_cnt].description = c.description, reply->code_list[code_cnt].definition = c
   .definition, reply->code_list[code_cnt].cdf_meaning = c.cdf_meaning,
   reply->code_list[code_cnt].collation_seq = c.collation_seq, reply->code_list[code_cnt].active_ind
    = c.active_ind, reply->code_list[code_cnt].updt_cnt = c.updt_cnt,
   reply->code_list[code_cnt].concept_cki = c.concept_cki
  WITH counter
 ;end select
 SET reply->code_cnt = code_cnt
 SET stat = alterlist(reply->code_list,code_cnt)
 IF (curqual < 0)
  GO TO fail_script
 ELSE
  GO TO success_script
 ENDIF
#fail_script
 SET reply->status_data.subeventstatus[1].operationname = "select"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE"
 GO TO end_script
#success_script
 IF (code_cnt=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
 ELSE
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
 ENDIF
#end_script
END GO
