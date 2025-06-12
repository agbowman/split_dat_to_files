CREATE PROGRAM afc_srv_get_tier:dba
 CALL echo(
  "##############################################################################################")
 RECORD reply(
   1 tier_qual = i2
   1 tier[*]
     2 tier_group_cd = f8
     2 tier_col_num = i4
     2 tier_row_num = i4
     2 tier_cell_type_cd = f8
     2 tier_cell_value = f8
     2 tier_cell_string = c50
     2 srv_res_level_flg = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 CALL echo(" ")
 CALL echo(build("tier_id: ",request->tier_id))
 SET count1 = 0
 SELECT DISTINCT INTO "nl"
  tm.tier_group_cd, tm.tier_col_num, tm.tier_row_num,
  tm.tier_cell_type_cd, tm.tier_cell_value, tm.tier_cell_string,
  tm.tier_cell_value_id
  FROM tier_matrix tm
  WHERE (tm.tier_group_cd=request->tier_id)
   AND tm.active_ind=1
   AND tm.beg_effective_dt_tm <= cnvtdatetime(sysdate)
   AND ((tm.end_effective_dt_tm=null) OR (tm.end_effective_dt_tm >= cnvtdatetime(sysdate)))
  ORDER BY tm.tier_row_num, tm.tier_col_num
  DETAIL
   CALL echo(build("    tier_cell_id: ",tm.tier_cell_id," tier_cell_string: ",tm.tier_cell_string,
    " tier_cell_value_id: ",
    tm.tier_cell_value_id," ",uar_get_code_display(tm.tier_cell_type_cd))), count1 += 1, stat =
   alterlist(reply->tier,count1),
   reply->tier_qual = count1, reply->tier[count1].tier_group_cd = tm.tier_group_cd, reply->tier[
   count1].tier_col_num = tm.tier_col_num,
   reply->tier[count1].tier_row_num = tm.tier_row_num, reply->tier[count1].tier_cell_type_cd = tm
   .tier_cell_type_cd, reply->tier[count1].tier_cell_value =
   IF ((reply->tier[count1].tier_cell_type_cd=code_val->13036_discount)) tm.tier_cell_value
   ELSEIF ((reply->tier[count1].tier_cell_type_cd=code_val->13036_diagreqd)) tm.tier_cell_value
   ELSEIF ((reply->tier[count1].tier_cell_type_cd=code_val->13036_physreqd)) tm.tier_cell_value
   ELSE tm.tier_cell_value_id
   ENDIF
   ,
   reply->tier[count1].tier_cell_string = tm.tier_cell_string
   IF ((reply->tier[count1].tier_cell_type_cd=code_val->13036_servres))
    CALL echo(concat("serv res meaning -",trim(uar_get_code_meaning(tm.tier_cell_value_id)),"-"))
    CASE (trim(uar_get_code_meaning(tm.tier_cell_value_id)))
     OF "INSTITUTION":
      reply->tier[count1].srv_res_level_flg = 1
     OF "DEPARTMENT":
      reply->tier[count1].srv_res_level_flg = 2
     OF "SECTION":
      reply->tier[count1].srv_res_level_flg = 3
     OF "SURGAREA":
      reply->tier[count1].srv_res_level_flg = 3
     OF "SUBSECTION":
      reply->tier[count1].srv_res_level_flg = 4
     OF "SURGSTAGE":
      reply->tier[count1].srv_res_level_flg = 4
     ELSE
      reply->tier[count1].srv_res_level_flg = 5
    ENDCASE
    CALL echo(build("serv res level flg = ",reply->tier[count1].srv_res_level_flg))
   ENDIF
  WITH nocounter
 ;end select
 SET reply->tier_qual = count1
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo(
  "##############################################################################################")
END GO
