CREATE PROGRAM bhs_prax_get_normalcy
 DECLARE high = f8 WITH protect, constant(uar_get_code_by("MEANING",52,"HIGH"))
 DECLARE low = f8 WITH protect, constant(uar_get_code_by("MEANING",52,"LOW"))
 DECLARE crit = f8 WITH protect, constant(uar_get_code_by("MEANING",52,"CRITICAL"))
 DECLARE rcnt = i4
 SET age_mins =  $2
 SET where_params = build("D.EVENT_CD IN"," ", $3)
 DECLARE json = vc WITH protect, noconstant("")
 FREE RECORD get_normalcy
 RECORD get_normalcy(
   1 qual[*]
     2 reference_range_factor_id = f8
     2 normalcy_cd = f8
     2 normalcy_disp = vc
     2 sex_cd = f8
     2 sex_display = vc
 )
 SELECT DISTINCT INTO  $1
  task_assay_type = uar_get_code_display(d.default_result_type_cd), d.mnemonic, d.description,
  d_activity_type_disp = uar_get_code_display(d.activity_type_cd), event_desc = uar_get_code_display(
   d.event_cd), d.event_cd,
  task_assay_desc = uar_get_code_display(d.task_assay_cd), d.task_assay_cd, r
  .reference_range_factor_id,
  r_species_disp = uar_get_code_display(r.species_cd), species_cd = r.species_cd, age_from_min = r
  .age_from_minutes,
  r_age_from_units_disp = uar_get_code_display(r.age_from_units_cd), r.age_from_units_cd, r
  .age_to_minutes,
  r_age_to_units_disp = uar_get_code_display(r.age_to_units_cd), r.age_to_units_cd, res_units_disp =
  uar_get_code_display(r.units_cd),
  r.units_cd, r.normal_high, r.normal_ind,
  r.normal_low, r.critical_high, r.critical_ind,
  r.critical_low, sex_disp = uar_get_code_display(r.sex_cd)
  FROM discrete_task_assay d,
   reference_range_factor r
  PLAN (d
   WHERE parser(where_params)
    AND d.active_ind=1)
   JOIN (r
   WHERE r.task_assay_cd=d.task_assay_cd
    AND r.active_ind=1
    AND r.age_from_minutes <= age_mins
    AND r.age_to_minutes > age_mins)
  ORDER BY d.event_cd
  HEAD REPORT
   rcnt = 0
  DETAIL
   rcnt = (rcnt+ 1), stat = alterlist(get_normalcy->qual,rcnt), get_normalcy->qual[rcnt].
   reference_range_factor_id = r.reference_range_factor_id,
   get_normalcy->qual[rcnt].sex_cd = r.sex_cd, get_normalcy->qual[rcnt].sex_display =
   uar_get_code_display(r.sex_cd)
   IF (r.normal_ind=1)
    IF (( $4 <= r.normal_low))
     get_normalcy->qual[rcnt].normalcy_cd = low, get_normalcy->qual[rcnt].normalcy_disp =
     uar_get_code_display(low)
    ENDIF
   ELSEIF (r.normal_ind=2)
    IF (( $4 >= r.normal_high))
     get_normalcy->qual[rcnt].normalcy_cd = high, get_normalcy->qual[rcnt].normalcy_disp =
     uar_get_code_display(high)
    ENDIF
   ELSEIF (r.normal_ind=3)
    IF (( $4 <= r.normal_low))
     get_normalcy->qual[rcnt].normalcy_cd = low, get_normalcy->qual[rcnt].normalcy_disp =
     uar_get_code_display(low)
    ENDIF
    IF (( $4 >= r.normal_high))
     get_normalcy->qual[rcnt].normalcy_cd = high, get_normalcy->qual[rcnt].normalcy_disp =
     uar_get_code_display(high)
    ENDIF
   ENDIF
   IF (r.critical_ind=1)
    IF (( $4 <= r.critical_low))
     get_normalcy->qual[rcnt].normalcy_cd = crit, get_normalcy->qual[rcnt].normalcy_disp =
     uar_get_code_display(crit)
    ENDIF
   ELSEIF (r.critical_ind=2)
    IF (( $4 >= r.critical_high))
     get_normalcy->qual[rcnt].normalcy_cd = crit, get_normalcy->qual[rcnt].normalcy_disp =
     uar_get_code_display(crit)
    ENDIF
   ELSEIF (r.critical_ind=3)
    IF (( $4 <= r.critical_low))
     get_normalcy->qual[rcnt].normalcy_cd = crit, get_normalcy->qual[rcnt].normalcy_disp =
     uar_get_code_display(crit)
    ENDIF
    IF (( $4 >= r.critical_high))
     get_normalcy->qual[rcnt].normalcy_cd = crit, get_normalcy->qual[rcnt].normalcy_disp =
     uar_get_code_display(crit)
    ENDIF
   ENDIF
  FOOT REPORT
   json = cnvtrectojson(get_normalcy), col + 1, json
  WITH nocounter, nullreport, maxcol = 8000,
   maxrow = 0, time = 30
 ;end select
 FREE RECORD get_normalcy
END GO
