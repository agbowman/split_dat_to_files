CREATE PROGRAM dm_ppr_get_loc_cmb_schema:dba
 DECLARE loop_max_cnt = i4
 SET loop_max_cnt = 5
 DECLARE loop_cnt = i4
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE nbr_of_tables = i2
 SET nbr_of_tables = 6
 DECLARE nbr_of_heirarchy_levels = i2
 SET nbr_of_heirarchy_levels = 5
 IF (size(reply->heirarchy,5)=0)
  SET rcvheirarchy->facility_type_cd = uar_get_code_by(nullterm(rcvheirarchy->smeaning),222,
   "FACILITY")
  SET rcvheirarchy->bed_cd = uar_get_code_by(nullterm(rcvheirarchy->smeaning),222,"BED")
  SET rcvheirarchy->room_cd = uar_get_code_by(nullterm(rcvheirarchy->smeaning),222,"ROOM")
  SET rcvheirarchy->building_cd = uar_get_code_by(nullterm(rcvheirarchy->smeaning),222,"BUILDING")
  SET rcvheirarchy->nurse_unit_cd = uar_get_code_by(nullterm(rcvheirarchy->smeaning),222,"NURSEUNIT")
  SET rcvheirarchy->ambulatory_cd = uar_get_code_by(nullterm(rcvheirarchy->smeaning),222,"AMBULATORY"
   )
  SET rcvheirarchy->clinic_cd = uar_get_code_by(nullterm(rcvheirarchy->smeaning),222,"CLINIC")
  SET stat = alterlist(reply->heirarchy,nbr_of_heirarchy_levels)
  SET reply->heirarchy[1].loc_type_mean = "FACILITY"
  SET reply->heirarchy[2].loc_type_mean = "BUILDING"
  SET reply->heirarchy[3].loc_type_mean = "NURSEUNIT"
  SET reply->heirarchy[4].loc_type_mean = "ROOM"
  SET reply->heirarchy[5].loc_type_mean = "BED"
  SET stat = alterlist(reply->tableinfo,nbr_of_tables)
  SET reply->tableinfo[1].table_name = "ENCNTR_LOC_HIST0735DRR"
  SET reply->tableinfo[2].table_name = "ENCOUNTER0077DRR"
  SET reply->tableinfo[3].table_name = "ENCNTR_PENDING5939DRR"
  SET reply->tableinfo[4].table_name = "ENCNTR_PENDING_HIS5940DRR"
  SET reply->tableinfo[5].table_name = "DCP_SHIFT_ASSIGNME5819DRR"
  SET reply->tableinfo[1].field_location_name = "LOCATION_CD"
  SET reply->tableinfo[1].field_primary_name = "ENCNTR_LOC_HIST_ID"
  SET reply->tableinfo[1].field_bed_name = "LOC_BED_CD"
  SET reply->tableinfo[1].field_room_name = "LOC_ROOM_CD"
  SET reply->tableinfo[1].field_nurseunit_name = "LOC_NURSE_UNIT_CD"
  SET reply->tableinfo[1].field_bldg_name = "LOC_BUILDING_CD"
  SET reply->tableinfo[1].field_facility_name = "LOC_FACILITY_CD"
  SET reply->tableinfo[1].parent_present_flag = 0
  SET reply->tableinfo[1].active_fields_flag = 1
  SET reply->tableinfo[1].orgid_field_flag = 1
  SET reply->tableinfo[2].field_location_name = "LOCATION_CD"
  SET reply->tableinfo[2].field_primary_name = "ENCNTR_ID"
  SET reply->tableinfo[2].field_bed_name = "LOC_BED_CD"
  SET reply->tableinfo[2].field_room_name = "LOC_ROOM_CD"
  SET reply->tableinfo[2].field_nurseunit_name = "LOC_NURSE_UNIT_CD"
  SET reply->tableinfo[2].field_bldg_name = "LOC_BUILDING_CD"
  SET reply->tableinfo[2].field_facility_name = "LOC_FACILITY_CD"
  SET reply->tableinfo[2].parent_present_flag = 1
  SET reply->tableinfo[2].active_fields_flag = 1
  SET reply->tableinfo[2].orgid_field_flag = 1
  SET reply->tableinfo[3].parent_table_name = "ENCOUNTER0077DRR"
  SET reply->tableinfo[3].field_parent_name = "ENCNTR_ID"
  SET reply->tableinfo[3].field_location_name = "LOCATION_CD"
  SET reply->tableinfo[3].field_primary_name = "ENCNTR_ID"
  SET reply->tableinfo[3].field_bed_name = "LOC_BED_CD"
  SET reply->tableinfo[3].field_room_name = "LOC_ROOM_CD"
  SET reply->tableinfo[3].field_nurseunit_name = "LOC_NURSE_UNIT_CD"
  SET reply->tableinfo[3].field_bldg_name = "LOC_BUILDING_CD"
  SET reply->tableinfo[3].field_facility_name = "LOC_FACILITY_CD"
  SET reply->tableinfo[3].parent_present_flag = 3
  SET reply->tableinfo[3].active_fields_flag = 1
  SET reply->tableinfo[3].orgid_field_flag = 0
  SET reply->tableinfo[4].field_primary_name = "ENCNTR_PENDING_ID"
  SET reply->tableinfo[4].field_bed_name = "PEND_BED_CD"
  SET reply->tableinfo[4].field_room_name = "PEND_ROOM_CD"
  SET reply->tableinfo[4].field_nurseunit_name = "PEND_NURSE_UNIT_CD"
  SET reply->tableinfo[4].field_bldg_name = "PEND_BUILDING_CD"
  SET reply->tableinfo[4].field_facility_name = "PEND_FACILITY_CD"
  SET reply->tableinfo[4].parent_present_flag = 2
  SET reply->tableinfo[4].active_fields_flag = 1
  SET reply->tableinfo[4].orgid_field_flag = 0
  SET reply->tableinfo[5].field_primary_name = "ENCNTR_PENDING_HIST_ID"
  SET reply->tableinfo[5].field_bed_name = "PEND_BED_CD"
  SET reply->tableinfo[5].field_room_name = "PEND_ROOM_CD"
  SET reply->tableinfo[5].field_nurseunit_name = "PEND_NURSE_UNIT_CD"
  SET reply->tableinfo[5].field_bldg_name = "PEND_BUILDING_CD"
  SET reply->tableinfo[5].field_facility_name = "PEND_FACILITY_CD"
  SET reply->tableinfo[5].parent_present_flag = 2
  SET reply->tableinfo[5].active_fields_flag = 1
  SET reply->tableinfo[5].orgid_field_flag = 0
  SET reply->tableinfo[6].field_primary_name = "ASSIGNMENT_ID"
  SET reply->tableinfo[6].field_bed_name = "LOC_BED_CD"
  SET reply->tableinfo[6].field_room_name = "LOC_ROOM_CD"
  SET reply->tableinfo[6].field_nurseunit_name = "LOC_UNIT_CD"
  SET reply->tableinfo[6].field_bldg_name = "LOC_BUILDING_CD"
  SET reply->tableinfo[6].field_facility_name = "LOC_FACILITY_CD"
  SET reply->tableinfo[6].parent_present_flag = 2
  SET reply->tableinfo[6].active_fields_flag = 0
  SET reply->tableinfo[6].orgid_field_flag = 0
  SET reply->nbr_of_tables = nbr_of_tables
 ENDIF
 CALL to_hierarchy(cmb_dummy)
 SET reply->nbr_table_index = 0
 CALL echo("request->table_name=")
 CALL echo(request->table_name)
 FOR (i = 1 TO nbr_of_tables)
   IF ((request->table_name=reply->tableinfo[i].table_name))
    SET reply->nbr_table_index = i
    SET i = (nbr_of_tables+ 1)
   ENDIF
 ENDFOR
#exit_sub
 SUBROUTINE to_hierarchy(dummy)
   DECLARE to_loc_cd = f8
   CALL echo("dbl_to_id = ")
   CALL echo(dbl_to_id)
   SELECT INTO "nl:"
    lg.location_type_cd
    FROM location l
    WHERE l.location_cd=dbl_to_id
     AND l.location_type_cd IN (rcvheirarchy->facility_type_cd, rcvheirarchy->bed_cd, rcvheirarchy->
    room_cd, rcvheirarchy->building_cd, rcvheirarchy->nurse_unit_cd,
    rcvheirarchy->ambulatory_cd, rcvheirarchy->clinic_cd)
     AND l.active_ind=1
     AND l.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND l.end_effective_dt_tm >= cnvtdatetime(sysdate)
    DETAIL
     rtoheirarchy->to_type_cd = l.location_type_cd, rtoheirarchy->to_org_id = l.organization_id
     IF ((l.location_type_cd=rcvheirarchy->facility_type_cd))
      rtoheirarchy->facility_cd = dbl_to_id
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL echo("exiting NO_TO_LOCATION_FOUND")
    GO TO exit_sub
   ENDIF
   SET to_loc_cd = dbl_to_id
   CALL echo(build("to_loc_cd:",to_loc_cd))
   WHILE (loop_cnt <= loop_max_cnt)
     SET loop_cnt += 1
     SELECT INTO "nl:"
      lg.root_loc_cd
      FROM location_group lg
      WHERE lg.child_loc_cd=to_loc_cd
       AND lg.location_group_type_cd IN (rcvheirarchy->facility_type_cd, rcvheirarchy->bed_cd,
      rcvheirarchy->room_cd, rcvheirarchy->building_cd, rcvheirarchy->nurse_unit_cd,
      rcvheirarchy->ambulatory_cd, rcvheirarchy->clinic_cd)
       AND lg.root_loc_cd=0.0
      DETAIL
       IF ((lg.location_group_type_cd=rcvheirarchy->facility_type_cd))
        rtoheirarchy->bldg_cd = lg.child_loc_cd
       ELSE
        IF ((lg.location_group_type_cd=rcvheirarchy->building_cd))
         rtoheirarchy->nurseunit_cd = lg.child_loc_cd
        ELSE
         IF (lg.location_group_type_cd IN (rcvheirarchy->nurse_unit_cd, rcvheirarchy->ambulatory_cd,
         rcvheirarchy->clinic_cd))
          rtoheirarchy->room_cd = lg.child_loc_cd
         ELSE
          IF ((lg.location_group_type_cd=rcvheirarchy->room_cd))
           rtoheirarchy->bed_cd = lg.child_loc_cd
          ENDIF
         ENDIF
        ENDIF
       ENDIF
       to_loc_cd = lg.parent_loc_cd
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET loop_cnt = (loop_max_cnt+ 1)
      SET rtoheirarchy->facility_cd = to_loc_cd
     ENDIF
   ENDWHILE
   CALL echo("to heirarchy:")
   CALL echorecord(rtoheirarchy)
 END ;Subroutine
END GO
