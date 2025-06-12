CREATE PROGRAM bed_get_alias_pool_by_cds:dba
 FREE SET reply
 RECORD reply(
   1 alias_pool_list[*]
     2 alias_pool_cd = f8
     2 display = vc
     2 description = vc
     2 active_ind = i2
     2 unique_ind = i2
     2 format_mask = vc
     2 check_digit_code_value = f8
     2 check_digit_disp = vc
     2 check_digit_mean = vc
     2 dup_allowed_flag = i2
     2 sys_assign_flag = i2
     2 cmb_inactive_ind = i2
     2 alias_method_code_value = f8
     2 alias_method_disp = vc
     2 alias_method_mean = vc
     2 alias_pool_ext_code_value = f8
     2 alias_pool_ext_disp = vc
     2 alias_pool_ext_mean = vc
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE error_msg = vc
 SET error_flag = "F"
 SET reply->status_data.status = "F"
 SET found_alias_pool = "F"
 SET acnt = size(request->alias_pool_cd_list,5)
 SET x = 0
 IF (acnt > 0)
  FOR (i = 1 TO acnt)
    SELECT INTO "nl:"
     disp2 = decode(c2.seq,c2.display," "), mean2 = decode(c2.seq,c2.cdf_meaning," "), disp3 = decode
     (c3.seq,c3.display," "),
     mean3 = decode(c3.seq,c3.cdf_meaning," "), disp4 = decode(c4.seq,c4.display," "), mean4 = decode
     (c4.seq,c4.cdf_meaning," ")
     FROM alias_pool a,
      code_value c,
      code_value c2,
      code_value c3,
      code_value c4,
      dummyt d1,
      dummyt d2,
      dummyt d3
     PLAN (a
      WHERE (a.alias_pool_cd=request->alias_pool_cd_list[i].alias_pool_cd))
      JOIN (c
      WHERE c.code_value=a.alias_pool_cd)
      JOIN (d1)
      JOIN (c2
      WHERE c2.code_value=a.check_digit_cd)
      JOIN (d2)
      JOIN (c3
      WHERE c3.code_value=a.alias_method_cd)
      JOIN (d3)
      JOIN (c4
      WHERE c4.code_value=a.alias_pool_ext_cd)
     ORDER BY a.alias_pool_cd
     HEAD a.alias_pool_cd
      found_alias_pool = "T", x = (x+ 1), stat = alterlist(reply->alias_pool_list,x),
      reply->alias_pool_list[x].alias_pool_cd = a.alias_pool_cd, reply->alias_pool_list[x].display =
      c.display, reply->alias_pool_list[x].description = c.description,
      reply->alias_pool_list[x].active_ind = a.active_ind, reply->alias_pool_list[x].unique_ind = a
      .unique_ind, reply->alias_pool_list[x].format_mask = a.format_mask,
      reply->alias_pool_list[x].check_digit_code_value = a.check_digit_cd, reply->alias_pool_list[x].
      check_digit_disp = disp2, reply->alias_pool_list[x].check_digit_mean = mean2,
      reply->alias_pool_list[x].dup_allowed_flag = a.dup_allowed_flag, reply->alias_pool_list[x].
      sys_assign_flag = a.sys_assign_flag, reply->alias_pool_list[x].cmb_inactive_ind = a
      .cmb_inactive_ind,
      reply->alias_pool_list[x].alias_method_code_value = a.alias_method_cd, reply->alias_pool_list[x
      ].alias_method_disp = disp3, reply->alias_pool_list[x].alias_method_mean = mean3,
      reply->alias_pool_list[x].alias_pool_ext_code_value = a.alias_pool_ext_cd, reply->
      alias_pool_list[x].alias_pool_ext_disp = disp4, reply->alias_pool_list[x].alias_pool_ext_mean
       = mean4
     WITH dontcare = c2, dontcare = c3, dontcare = c4,
      nocounter
    ;end select
  ENDFOR
 ENDIF
#exit_script
 IF (error_flag="T")
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat(" >> PROGRAM NAME: BED_GET_ALIAS_POOL_BY_CDS  >> ERROR MESSAGE: ",
   error_msg)
 ELSE
  IF (found_alias_pool="T")
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ENDIF
 CALL echorecord(reply)
END GO
