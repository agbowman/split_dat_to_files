CREATE PROGRAM bed_get_res_ord_role_duration:dba
 FREE SET reply
 RECORD reply(
   1 ord_roles[*]
     2 ord_role_id = f8
     2 duration = i4
     2 duration_unit_code_value = f8
     2 setup_duration = i4
     2 setup_unit_code_value = f8
     2 cleanup_duration = i4
     2 cleanup_unit_code_value = f8
     2 offset = i4
     2 offset_unit_code_value = f8
     2 seq_nbr = i4
     2 mnemonic = vc
     2 override_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET temp_roles
 RECORD temp_roles(
   1 ord_roles[*]
     2 ord_role_id = f8
     2 mnemonic = vc
     2 seq_nbr = i4
 )
 SET reply->status_data.status = "F"
 SET tot_cnt = 0
 SELECT INTO "nl:"
  FROM sch_order_role sor,
   sch_list_role slr
  PLAN (sor
   WHERE (sor.catalog_cd=request->catalog_code_value)
    AND (sor.location_cd=request->dept_code_value)
    AND sor.active_ind=1)
   JOIN (slr
   WHERE slr.list_role_id=sor.list_role_id
    AND slr.active_ind=1)
  HEAD REPORT
   cnt = 0, tot_cnt = 0, stat = alterlist(temp_roles->ord_roles,10)
  DETAIL
   cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
   IF (cnt > 10)
    stat = alterlist(temp_roles->ord_roles,(tot_cnt+ 10)), cnt = 1
   ENDIF
   temp_roles->ord_roles[tot_cnt].ord_role_id = slr.list_role_id, temp_roles->ord_roles[tot_cnt].
   mnemonic = slr.mnemonic, temp_roles->ord_roles[tot_cnt].seq_nbr = sor.seq_nbr
  FOOT REPORT
   stat = alterlist(temp_roles->ord_roles,tot_cnt)
  WITH nocounter
 ;end select
 IF (tot_cnt > 0)
  SET override_code = 0.0
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=23001
    AND cv.cdf_meaning="OVERRIDE"
    AND cv.active_ind=1
   DETAIL
    override_code = cv.code_value
   WITH nocounter
  ;end select
  SET req_cnt = size(temp_roles->ord_roles,5)
  SET stat = alterlist(reply->ord_roles,req_cnt)
  FOR (x = 1 TO req_cnt)
    SET reply->ord_roles[x].ord_role_id = temp_roles->ord_roles[x].ord_role_id
    SET reply->ord_roles[x].seq_nbr = temp_roles->ord_roles[x].seq_nbr
    SET reply->ord_roles[x].mnemonic = temp_roles->ord_roles[x].mnemonic
    SET flex_ind = 0
    SELECT INTO "nl:"
     FROM sch_order_role sor,
      sch_order_duration sod
     PLAN (sor
      WHERE (sor.catalog_cd=request->catalog_code_value)
       AND (sor.location_cd=request->dept_code_value)
       AND (sor.seq_nbr=temp_roles->ord_roles[x].seq_nbr)
       AND (sor.list_role_id=temp_roles->ord_roles[x].ord_role_id))
      JOIN (sod
      WHERE sod.catalog_cd=sor.catalog_cd
       AND sod.location_cd=sor.location_cd
       AND sod.seq_nbr=sor.seq_nbr
       AND sod.sch_flex_id=0)
     DETAIL
      reply->ord_roles[x].duration = sod.duration_units, reply->ord_roles[x].duration_unit_code_value
       = sod.duration_units_cd, reply->ord_roles[x].setup_duration = sod.setup_units,
      reply->ord_roles[x].setup_unit_code_value = sod.setup_units_cd, reply->ord_roles[x].
      cleanup_duration = sod.cleanup_units, reply->ord_roles[x].cleanup_unit_code_value = sod
      .cleanup_units_cd,
      reply->ord_roles[x].offset = sod.offset_beg_units, reply->ord_roles[x].offset_unit_code_value
       = sod.offset_beg_units_cd, flex_ind = 1
      IF (sod.offset_type_cd=override_code)
       reply->ord_roles[x].override_ind = 1
      ENDIF
     WITH nocounter
    ;end select
  ENDFOR
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
