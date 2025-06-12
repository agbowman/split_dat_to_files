CREATE PROGRAM dcp_chk_cust_col_import:dba
 RECORD pcv(
   1 pcv_cnt = i2
   1 pcv_list[*]
     2 code_value = f8
     2 cdf_mean = vc
 )
 RECORD ccv(
   1 ccv_cnt = i2
   1 ccv_list[*]
     2 code_value = f8
     2 cdf_mean = vc
 )
 SET pcv->pcv_cnt = 0
 SET ccv->ccv_cnt = 0
 SET count = 0
 SET failed = "F"
 SET nbr_parent_code_values = 0
 SET nbr_child_code_values = 0
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=6022
   AND c.active_ind=1
  DETAIL
   count = (count+ 1), stat = alterlist(pcv->pcv_list,count), pcv->pcv_list[count].code_value = c
   .code_value,
   pcv->pcv_list[count].cdf_mean = c.cdf_meaning
  WITH check
 ;end select
 SET nbr_parent_code_values = count
 IF (nbr_parent_code_values <= 0)
  SET readme_data->status = "F"
  SET readme_data->message = build("PVReadMe 1099:No spread types in code set 6022.")
  EXECUTE dm_readme_status
  COMMIT
  SET failed = "T"
  GO TO exit_script
 ELSE
  SET readme_data->message = build("PVReadMe 1099:Total valid spread types = ",nbr_parent_code_values
   )
  EXECUTE dm_readme_status
  COMMIT
 ENDIF
 SET count = 0
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=6023
   AND c.active_ind=1
  DETAIL
   count = (count+ 1)
  WITH check
 ;end select
 SET nbr_child_code_values = count
 IF (nbr_child_code_values <= 0)
  SET readme_data->status = "F"
  SET readme_data->message = build("PVReadMe 1099:No column types in code set 6023.")
  EXECUTE dm_readme_status
  COMMIT
  SET failed = "T"
  GO TO exit_script
 ELSE
  SET readme_data->message = build("PVReadMe 1099:Total valid column types  = ",nbr_child_code_values
   )
  EXECUTE dm_readme_status
  COMMIT
 ENDIF
 SET x = 0
 SET child = 0
 SET count = 0
 FOR (x = 0 TO nbr_parent_code_values)
   CALL echo("**********************************")
   CALL echo(build("Spread type: ",pcv->pcv_list[x].cdf_mean))
   SELECT INTO "nl:"
    cvg.parent_code_value
    FROM code_value_group cvg
    WHERE (cvg.parent_code_value=pcv->pcv_list[x].code_value)
    DETAIL
     child = (child+ 1)
    WITH nocounter
   ;end select
   CALL echo(build("Number Columns Assoc for spread type: ",child))
   IF (child=0)
    SET readme_data->message = build("PVReadMe 1099:No associations made for spread ",pcv->pcv_list[x
     ].cdf_mean)
    EXECUTE dm_readme_status
    COMMIT
    SET failed = "T"
   ENDIF
   SET child = 0
 ENDFOR
 IF (failed="T")
  SET readme_data->status = "F"
  SET readme_data->message = build(
   "PVReadMe 1099:No code_value_gruop associations made for one or more spread types.")
  EXECUTE dm_readme_status
  COMMIT
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = build("PVReadMe 1099:Code value group associations successfull.")
  EXECUTE dm_readme_status
  COMMIT
 ENDIF
#exit_script
END GO
