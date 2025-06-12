CREATE PROGRAM bbt_add_code:dba
 RECORD internal(
   1 qual[1]
     2 field_name = c32
     2 field_type = i4
 )
 RECORD reply(
   1 qual[1]
     2 code_value = f8
     2 display_key = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 SET number_to_add = size(request->qual,5)
 SET number_of_ext = 0
 SET number_of_csext = 0
 SET failures = 0
 SET count1 = 0
 SET code_value = 0.0
 SET y = 1
 SET next_code = 0.0
#start_loop
 FOR (y = y TO number_to_add)
   INSERT  FROM common_data_foundation c
    SET c.seq = 1, c.code_set = request->qual[y].code_set, c.cdf_meaning = trim(cnvtupper(request->
       qual[y].cdf_meaning)),
     c.display = substring(1,40,request->qual[y].display), c.definition = substring(1,100,request->
      qual[y].definition), c.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task, c.updt_cnt = 0,
     c.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   EXECUTE cpm_next_code
   SET v_display_key = trim(cnvtupper(cnvtalphanum(request->qual[y].display)))
   INSERT  FROM code_value c
    SET c.code_value = next_code, c.code_set = request->qual[y].code_set, c.cdf_meaning =
     IF ((request->qual[y].cdf_meaning > " ")) request->qual[y].cdf_meaning
     ELSE null
     ENDIF
     ,
     c.display = request->qual[y].display, c.display_key = cnvtupper(v_display_key), c.description =
     request->qual[y].description,
     c.definition = request->qual[y].definition, c.collation_seq = request->qual[y].collation_seq, c
     .active_type_cd = 0.0,
     c.active_ind = 1, c.active_dt_tm = cnvtdatetime(curdate,curtime3), c.inactive_dt_tm = null,
     c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = reqinfo->updt_id, c.updt_cnt = 0,
     c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    GO TO get_next_code
   ELSE
    SET count1 = (count1+ 1)
    SET stat = alter(reply->qual,count1)
    SET reply->qual[count1].code_value = next_code
    SET reply->qual[count1].display_key = request->qual[y].display_key
   ENDIF
 ENDFOR
 GO TO exit_script
#get_next_code
 SET failures = (failures+ 1)
 IF (failures > 1)
  SET stat = alter(reply->status_data.subeventstatus,failures)
 ENDIF
 SET reply->status_data.subeventstatus[failures].operationstatus = "F"
 SET reply->status_data.subeventstatus[failures].targetobjectvalue = request->qual[y].display
 SET reply->qual[count1].code_value = 0.0
 SET reply->qual[count1].display_key = request->qual[y].display_key
 ROLLBACK
 SET y = (y+ 1)
 GO TO start_loop
#exit_script
 IF (failures=0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
