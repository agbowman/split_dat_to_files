CREATE PROGRAM bhs_athn_stand_dose_range
 RECORD out_rec(
   1 ranges[*]
     2 range_operator = vc
     2 range1 = vc
     2 range2 = vc
     2 dose_unit = vc
     2 dose_unit_disp = vc
     2 standardized_dose = vc
     2 standardized_dose_unit = vc
     2 standardized_dose_unit_disp = vc
 )
 DECLARE r_cnt = i4
 SELECT INTO "nl:"
  FROM standardized_order_dose sod
  PLAN (sod
   WHERE (sod.synonym_id= $2)
    AND sod.active_ind=1)
  HEAD sod.standardized_order_dose_id
   r_cnt += 1
   IF (mod(r_cnt,100)=1)
    stat = alterlist(out_rec->ranges,(r_cnt+ 99))
   ENDIF
   IF (sod.relational_operator_flag=0)
    out_rec->ranges[r_cnt].range_operator = "="
   ELSEIF (sod.relational_operator_flag=1)
    out_rec->ranges[r_cnt].range_operator = "<"
   ELSEIF (sod.relational_operator_flag=2)
    out_rec->ranges[r_cnt].range_operator = ">"
   ELSEIF (sod.relational_operator_flag=3)
    out_rec->ranges[r_cnt].range_operator = "<="
   ELSEIF (sod.relational_operator_flag=4)
    out_rec->ranges[r_cnt].range_operator = ">="
   ELSEIF (sod.relational_operator_flag=5)
    out_rec->ranges[r_cnt].range_operator = "!="
   ELSEIF (sod.relational_operator_flag=6)
    out_rec->ranges[r_cnt].range_operator = "Between"
   ELSEIF (sod.relational_operator_flag=7)
    out_rec->ranges[r_cnt].range_operator = "Outside or not between  (inclusive)"
   ELSEIF (sod.relational_operator_flag=8)
    out_rec->ranges[r_cnt].range_operator = "In"
   ELSEIF (sod.relational_operator_flag=9)
    out_rec->ranges[r_cnt].range_operator = "Not In"
   ENDIF
   out_rec->ranges[r_cnt].range1 = cnvtstring(sod.compare_value1,10,4), out_rec->ranges[r_cnt].range2
    = cnvtstring(sod.compare_value2,10,4), out_rec->ranges[r_cnt].dose_unit = cnvtstring(sod
    .compare_unit_cd),
   out_rec->ranges[r_cnt].dose_unit_disp = uar_get_code_display(sod.compare_unit_cd), out_rec->
   ranges[r_cnt].standardized_dose = cnvtstring(sod.std_dose_value,10,4), out_rec->ranges[r_cnt].
   standardized_dose_unit = cnvtstring(sod.std_dose_unit_cd),
   out_rec->ranges[r_cnt].standardized_dose_unit_disp = uar_get_code_display(sod.std_dose_unit_cd)
  FOOT REPORT
   stat = alterlist(out_rec->ranges,r_cnt)
  WITH nocounter, time = 30
 ;end select
 CALL echojson(out_rec, $1)
END GO
