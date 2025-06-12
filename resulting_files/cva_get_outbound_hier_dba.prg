CREATE PROGRAM cva_get_outbound_hier:dba
 RECORD reply(
   1 fac_cd = f8
   1 fac_disp = c40
   1 fac_desc = c60
   1 fac_mean = c12
   1 fac_alias = vc
   1 alias_ind = i2
   1 status_ind = i2
   1 loc_status_ind = i2
   1 updt_cnt = i4
   1 build_qual[*]
     2 build_cd = f8
     2 build_disp = c40
     2 build_desc = c60
     2 build_mean = c12
     2 build_alias = vc
     2 build_seq = i4
     2 alias_ind = i2
     2 status_ind = i2
     2 loc_status_ind = i2
     2 updt_cnt = i4
     2 nu_qual[*]
       3 nu_cd = f8
       3 nu_disp = c40
       3 nu_desc = c60
       3 nu_mean = c12
       3 nu_alias = vc
       3 nu_seq = i4
       3 alias_ind = i2
       3 status_ind = i2
       3 loc_status_ind = i2
       3 updt_cnt = i4
       3 room_qual[*]
         4 room_cd = f8
         4 room_disp = c40
         4 room_desc = c60
         4 room_mean = c12
         4 room_alias = vc
         4 room_seq = i4
         4 alias_ind = i2
         4 status_ind = i2
         4 loc_status_ind = i2
         4 updt_cnt = i4
         4 bed_qual[*]
           5 bed_cd = f8
           5 bed_disp = c40
           5 bed_desc = c60
           5 bed_mean = c12
           5 bed_alias = vc
           5 bed_seq = i4
           5 alias_ind = i2
           5 status_ind = i2
           5 loc_status_ind = i2
           5 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET request->cdf_meaning = trim(cnvtupper(request->cdf_meaning))
 SET lookup_cnt = size(request->qual,5)
 SET build_cnt = 0
 SET unit_cnt = 0
 SET unit_room_cnt = 0
 SET unit_bed_cnt = 0
 SET cdf_meaning = fillstring(12," ")
 SELECT INTO "nl:"
  cva.alias
  FROM code_value_outbound cva,
   location l,
   (dummyt d1  WITH seq = value(lookup_cnt)),
   (dummyt d2  WITH seq = 1)
  PLAN (d1)
   JOIN (l
   WHERE (l.location_cd=request->qual[d1.seq].location_cd))
   JOIN (d2)
   JOIN (cva
   WHERE cva.code_set=220
    AND (cva.code_value=request->qual[d1.seq].location_cd)
    AND cva.alias > " "
    AND (cva.contributor_source_cd=request->contributor_source_cd))
  DETAIL
   CASE (d1.seq)
    OF 1:
     IF (l.active_ind=1
      AND l.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
      AND l.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      reply->loc_status_ind = 1
     ELSE
      reply->loc_status_ind = 0
     ENDIF
     ,reply->fac_cd = l.location_cd,
     IF (cva.code_value > 0)
      reply->fac_alias = cva.alias, reply->updt_cnt = cva.updt_cnt, reply->alias_ind = 1
     ENDIF
    OF 2:
     stat = alterlist(reply->build_qual,1),
     IF (l.active_ind=1
      AND l.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
      AND l.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      reply->build_qual[1].loc_status_ind = 1
     ELSE
      reply->build_qual[1].loc_status_ind = 0
     ENDIF
     ,reply->build_qual[1].build_cd = l.location_cd,
     IF (cva.code_value > 0)
      reply->build_qual[1].build_alias = cva.alias, reply->build_qual[1].updt_cnt = cva.updt_cnt,
      reply->build_qual[1].alias_ind = 1
     ENDIF
    OF 3:
     stat = alterlist(reply->build_qual[1].nu_qual,1),
     IF (l.active_ind=1
      AND l.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
      AND l.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      reply->build_qual[1].nu_qual[1].loc_status_ind = 1
     ELSE
      reply->build_qual[1].nu_qual[1].loc_status_ind = 0
     ENDIF
     ,reply->build_qual[1].nu_qual[1].nu_cd = l.location_cd,
     IF (cva.code_value > 0)
      reply->build_qual[1].nu_qual[1].nu_alias = cva.alias, reply->build_qual[1].nu_qual[1].updt_cnt
       = cva.updt_cnt, reply->build_qual[1].nu_qual[1].alias_ind = 1
     ENDIF
    OF 4:
     stat = alterlist(reply->build_qual[1].nu_qual[1].room_qual,1),
     IF (l.active_ind=1
      AND l.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
      AND l.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      reply->build_qual[1].nu_qual[1].room_qual[1].loc_status_ind = 1
     ELSE
      reply->build_qual[1].nu_qual[1].room_qual[1].loc_status_ind = 0
     ENDIF
     ,reply->build_qual[1].nu_qual[1].room_qual[1].room_cd = l.location_cd,
     IF (cva.code_value > 0)
      reply->build_qual[1].nu_qual[1].room_qual[1].room_alias = cva.alias, reply->build_qual[1].
      nu_qual[1].room_qual[1].updt_cnt = cva.updt_cnt, reply->build_qual[1].nu_qual[1].room_qual[1].
      alias_ind = 1
     ENDIF
    OF 5:
     stat = alterlist(reply->build_qual[1].nu_qual[1].room_qual[1].bed_qual,1),
     IF (l.active_ind=1
      AND l.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
      AND l.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      reply->build_qual[1].nu_qual[1].room_qual[1].bed_qual[1].loc_status_ind = 1
     ELSE
      reply->build_qual[1].nu_qual[1].room_qual[1].bed_qual[1].loc_status_ind = 0
     ENDIF
     ,reply->build_qual[1].nu_qual[1].room_qual[1].bed_qual[1].bed_cd = l.location_cd,
     IF (cva.code_value > 0)
      reply->build_qual[1].nu_qual[1].room_qual[1].bed_qual[1].bed_alias = cva.alias, reply->
      build_qual[1].nu_qual[1].room_qual[1].bed_qual[1].updt_cnt = cva.updt_cnt, reply->build_qual[1]
      .nu_qual[1].room_qual[1].bed_qual[1].alias_ind = 1
     ENDIF
   ENDCASE
  WITH nocounter, outerjoin = d2
 ;end select
 CASE (request->cdf_meaning)
  OF "FACILITY":
   IF (lookup_cnt != 1)
    GO TO exit_script
   ENDIF
   EXECUTE FROM facility_lookup TO end_lookup
   SELECT
    IF ((request->get_all_flag=1))
     PLAN (lg1
      WHERE (lg1.parent_loc_cd=request->parent_loc_cd)
       AND lg1.location_group_type_cd=fac_cd
       AND lg1.root_loc_cd=0)
      JOIN (l1
      WHERE lg1.child_loc_cd=l1.location_cd)
      JOIN (d5)
      JOIN (cva1
      WHERE cva1.code_set=220
       AND cva1.code_value=lg1.child_loc_cd
       AND cva1.alias > " "
       AND (cva1.contributor_source_cd=request->contributor_source_cd))
      JOIN (d1)
      JOIN (lg2
      WHERE lg2.parent_loc_cd=lg1.child_loc_cd
       AND lg2.location_group_type_cd=build_cd
       AND lg2.root_loc_cd=0
       AND lg1.child_loc_cd > 0)
      JOIN (l2
      WHERE lg2.child_loc_cd=l2.location_cd)
      JOIN (d6)
      JOIN (cva2
      WHERE cva2.code_set=220
       AND cva2.code_value=lg2.child_loc_cd
       AND cva2.alias > " "
       AND (cva2.contributor_source_cd=request->contributor_source_cd))
      JOIN (d2)
      JOIN (((lg3
      WHERE lg3.parent_loc_cd=lg2.child_loc_cd
       AND lg3.location_group_type_cd=amb_cd
       AND lg3.root_loc_cd=0
       AND lg2.child_loc_cd > 0)
      JOIN (l3
      WHERE lg3.child_loc_cd=l3.location_cd)
      JOIN (d7)
      JOIN (cva3
      WHERE cva3.code_set=220
       AND cva3.code_value=lg3.child_loc_cd
       AND cva3.alias > " "
       AND (cva3.contributor_source_cd=request->contributor_source_cd))
      JOIN (d3)
      JOIN (lg4
      WHERE lg4.parent_loc_cd=lg3.child_loc_cd
       AND lg4.location_group_type_cd=room_cd
       AND lg4.root_loc_cd=0
       AND lg3.child_loc_cd > 0)
      JOIN (l4
      WHERE lg4.child_loc_cd=l4.location_cd)
      JOIN (d8)
      JOIN (cva4
      WHERE cva4.code_set=220
       AND cva4.code_value=lg4.child_loc_cd
       AND cva4.alias > " "
       AND (cva4.contributor_source_cd=request->contributor_source_cd))
      ) ORJOIN ((lg5
      WHERE lg5.parent_loc_cd=lg2.child_loc_cd
       AND lg5.location_group_type_cd=amb_cd
       AND lg5.root_loc_cd=0
       AND lg2.child_loc_cd > 0)
      JOIN (l5
      WHERE lg5.child_loc_cd=l5.location_cd)
      JOIN (d9)
      JOIN (cva5
      WHERE cva5.code_set=220
       AND cva5.code_value=lg5.child_loc_cd
       AND cva5.alias > " "
       AND (cva5.contributor_source_cd=request->contributor_source_cd))
      JOIN (d4)
      JOIN (lg6
      WHERE lg6.parent_loc_cd=lg5.child_loc_cd
       AND lg6.location_group_type_cd=room_cd
       AND lg6.root_loc_cd=0
       AND lg6.child_loc_cd > 0)
      JOIN (l6
      WHERE lg6.child_loc_cd=l6.location_cd)
      JOIN (d10)
      JOIN (cva6
      WHERE cva6.code_set=220
       AND cva6.code_value=lg6.child_loc_cd
       AND cva6.alias > " "
       AND (cva6.contributor_source_cd=request->contributor_source_cd))
      ))
    ELSEIF ((request->get_all_flag=0))
     PLAN (lg1
      WHERE (lg1.parent_loc_cd=request->parent_loc_cd)
       AND lg1.location_group_type_cd=fac_cd
       AND lg1.root_loc_cd=0
       AND lg1.active_ind=1
       AND lg1.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND lg1.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (l1
      WHERE lg1.child_loc_cd=l1.location_cd
       AND l1.active_ind=1
       AND l1.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND l1.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (d5)
      JOIN (cva1
      WHERE cva1.code_set=220
       AND cva1.code_value=lg1.child_loc_cd
       AND cva1.alias > " "
       AND (cva1.contributor_source_cd=request->contributor_source_cd))
      JOIN (d1)
      JOIN (lg2
      WHERE lg2.parent_loc_cd=lg1.child_loc_cd
       AND lg2.location_group_type_cd=build_cd
       AND lg2.root_loc_cd=0
       AND lg2.active_ind=1
       AND lg2.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND lg2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
       AND lg1.child_loc_cd > 0)
      JOIN (l2
      WHERE lg2.child_loc_cd=l2.location_cd
       AND l2.active_ind=1
       AND l2.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND l2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (d6)
      JOIN (cva2
      WHERE cva2.code_set=220
       AND cva2.code_value=lg2.child_loc_cd
       AND cva2.alias > " "
       AND (cva2.contributor_source_cd=request->contributor_source_cd))
      JOIN (d2)
      JOIN (((lg3
      WHERE lg3.parent_loc_cd=lg2.child_loc_cd
       AND lg3.location_group_type_cd=nu_cd
       AND lg3.root_loc_cd=0
       AND lg3.active_ind=1
       AND lg3.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND lg3.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
       AND lg2.child_loc_cd > 0)
      JOIN (l3
      WHERE lg3.child_loc_cd=l3.location_cd
       AND l3.active_ind=1
       AND l3.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND l3.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (d7)
      JOIN (cva3
      WHERE cva3.code_set=220
       AND cva3.code_value=lg3.child_loc_cd
       AND cva3.alias > " "
       AND (cva3.contributor_source_cd=request->contributor_source_cd))
      JOIN (d3)
      JOIN (lg4
      WHERE lg4.parent_loc_cd=lg3.child_loc_cd
       AND lg4.location_group_type_cd=room_cd
       AND lg4.root_loc_cd=0
       AND lg4.active_ind=1
       AND lg4.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND lg4.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
       AND lg3.child_loc_cd > 0)
      JOIN (l4
      WHERE lg4.child_loc_cd=l4.location_cd
       AND l4.active_ind=1
       AND l4.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND l4.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (d8)
      JOIN (cva4
      WHERE cva4.code_set=220
       AND cva4.code_value=lg4.child_loc_cd
       AND cva4.alias > " "
       AND (cva4.contributor_source_cd=request->contributor_source_cd))
      ) ORJOIN ((lg5
      WHERE lg5.parent_loc_cd=lg2.child_loc_cd
       AND lg5.location_group_type_cd=amb_cd
       AND lg5.root_loc_cd=0
       AND lg5.active_ind=1
       AND lg5.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND lg5.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
       AND lg2.child_loc_cd > 0)
      JOIN (l5
      WHERE lg5.child_loc_cd=l5.location_cd
       AND l5.active_ind=1
       AND l5.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND l5.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (d9)
      JOIN (cva5
      WHERE cva5.code_set=220
       AND cva5.code_value=lg5.child_loc_cd
       AND cva5.alias > " "
       AND (cva5.contributor_source_cd=request->contributor_source_cd))
      JOIN (d4)
      JOIN (lg6
      WHERE lg6.parent_loc_cd=lg5.child_loc_cd
       AND lg6.location_group_type_cd=room_cd
       AND lg6.root_loc_cd=0
       AND lg6.child_loc_cd > 0
       AND lg6.active_ind=1
       AND lg6.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND lg6.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (l6
      WHERE lg6.child_loc_cd=l6.location_cd
       AND l6.active_ind=1
       AND l6.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND l6.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (d10)
      JOIN (cva6
      WHERE cva6.code_set=220
       AND cva6.code_value=lg6.child_loc_cd
       AND cva6.alias > " "
       AND (cva6.contributor_source_cd=request->contributor_source_cd))
      ))
    ELSE
    ENDIF
    INTO "nl:"
    lg1.child_loc_cd, lg2.child_loc_cd, lg3.child_loc_cd,
    lg4.child_loc_cd, lg5.child_loc_cd, lg6.child_loc_cd
    FROM location_group lg1,
     location_group lg2,
     location_group lg3,
     location_group lg4,
     location_group lg5,
     location_group lg6,
     location l1,
     location l2,
     location l3,
     location l4,
     location l5,
     location l6,
     (dummyt d1  WITH seq = 1),
     (dummyt d2  WITH seq = 1),
     (dummyt d3  WITH seq = 1),
     (dummyt d4  WITH seq = 1),
     (dummyt d5  WITH seq = 1),
     (dummyt d6  WITH seq = 1),
     (dummyt d7  WITH seq = 1),
     (dummyt d8  WITH seq = 1),
     (dummyt d9  WITH seq = 1),
     (dummyt d10  WITH seq = 1),
     code_value_outbound cva1,
     code_value_outbound cva2,
     code_value_outbound cva3,
     code_value_outbound cva4,
     code_value_outbound cva5,
     code_value_outbound cva6
    HEAD REPORT
     build_cnt = 0
    HEAD lg1.child_loc_cd
     IF (lg1.child_loc_cd > 0)
      build_cnt = (build_cnt+ 1), stat = alterlist(reply->build_qual,build_cnt), reply->build_qual[
      build_cnt].build_cd = lg1.child_loc_cd,
      reply->build_qual[build_cnt].build_seq = lg1.sequence
      IF (cva1.code_value > 0)
       reply->build_qual[build_cnt].build_alias = cva1.alias, reply->build_qual[build_cnt].updt_cnt
        = cva1.updt_cnt, reply->build_qual[build_cnt].alias_ind = 1
      ENDIF
      IF (lg1.active_ind=1
       AND lg1.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND lg1.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       reply->build_qual[build_cnt].status_ind = 1
      ELSE
       reply->build_qual[build_cnt].status_ind = 0
      ENDIF
      IF (l1.active_ind=1
       AND l1.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND l1.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       reply->build_qual[build_cnt].loc_status_ind = 1
      ELSE
       reply->build_qual[build_cnt].loc_status_ind = 0
      ENDIF
      unit_cnt = 0, unit_room_cnt = 0, unit_bed_cnt = 0
     ENDIF
    HEAD lg2.child_loc_cd
     IF (lg2.child_loc_cd > 0)
      unit_cnt = (unit_cnt+ 1), stat = alterlist(reply->build_qual[build_cnt].nu_qual,unit_cnt),
      reply->build_qual[build_cnt].nu_qual[unit_cnt].nu_cd = lg2.child_loc_cd,
      reply->build_qual[build_cnt].nu_qual[unit_cnt].nu_seq = lg2.sequence
      IF (cva2.code_value > 0)
       reply->build_qual[build_cnt].nu_qual[unit_cnt].nu_alias = cva2.alias, reply->build_qual[
       build_cnt].nu_qual[unit_cnt].updt_cnt = cva2.updt_cnt, reply->build_qual[build_cnt].nu_qual[
       unit_cnt].alias_ind = 1
      ENDIF
      IF (lg2.active_ind=1
       AND lg2.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND lg2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       reply->build_qual[build_cnt].nu_qual[unit_cnt].status_ind = 1
      ELSE
       reply->build_qual[build_cnt].nu_qual[unit_cnt].status_ind = 0
      ENDIF
      IF (l2.active_ind=1
       AND l2.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND l2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       reply->build_qual[build_cnt].nu_qual[unit_cnt].loc_status_ind = 1
      ELSE
       reply->build_qual[build_cnt].nu_qual[unit_cnt].loc_status_ind = 0
      ENDIF
      unit_room_cnt = 0, unit_bed_cnt = 0
     ENDIF
    HEAD lg3.child_loc_cd
     IF (lg3.child_loc_cd > 0)
      unit_room_cnt = (unit_room_cnt+ 1), stat = alterlist(reply->build_qual[build_cnt].nu_qual[
       unit_cnt].room_qual,unit_room_cnt), reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[
      unit_room_cnt].room_cd = lg3.child_loc_cd,
      reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].room_seq = lg3.sequence
      IF (cva3.code_value > 0)
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].room_alias = cva3
       .alias, reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].updt_cnt =
       cva3.updt_cnt, reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].
       alias_ind = 1
      ENDIF
      IF (lg3.active_ind=1
       AND lg3.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND lg3.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].status_ind = 1
      ELSE
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].status_ind = 0
      ENDIF
      IF (l3.active_ind=1
       AND l3.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND l3.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].loc_status_ind = 1
      ELSE
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].loc_status_ind = 0
      ENDIF
      unit_bed_cnt = 0
     ENDIF
    HEAD lg4.child_loc_cd
     IF (lg4.child_loc_cd > 0)
      unit_bed_cnt = (unit_bed_cnt+ 1), stat = alterlist(reply->build_qual[build_cnt].nu_qual[
       unit_cnt].room_qual[unit_room_cnt].bed_qual,unit_bed_cnt), reply->build_qual[build_cnt].
      nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt].bed_cd = lg4.child_loc_cd,
      reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt].
      bed_seq = lg4.sequence
      IF (cva4.code_value > 0)
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt]
       .bed_alias = cva4.alias, reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[
       unit_room_cnt].bed_qual[unit_bed_cnt].updt_cnt = cva4.updt_cnt, reply->build_qual[build_cnt].
       nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt].alias_ind = 1
      ENDIF
      IF (lg4.active_ind=1
       AND lg4.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND lg4.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt]
       .status_ind = 1
      ELSE
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt]
       .status_ind = 0
      ENDIF
      IF (l4.active_ind=1
       AND l4.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND l4.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt]
       .loc_status_ind = 1
      ELSE
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt]
       .loc_status_ind = 0
      ENDIF
     ENDIF
    HEAD lg5.child_loc_cd
     IF (lg5.child_loc_cd > 0)
      unit_room_cnt = (unit_room_cnt+ 1), stat = alterlist(reply->build_qual[build_cnt].nu_qual[
       unit_cnt].room_qual,unit_room_cnt), reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[
      unit_room_cnt].room_cd = lg5.child_loc_cd,
      reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].room_seq = lg5.sequence
      IF (cva5.code_value > 0)
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].room_alias = cva5
       .alias, reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].updt_cnt =
       cva5.updt_cnt, reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].
       alias_ind = 1
      ENDIF
      IF (lg5.active_ind=1
       AND lg5.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND lg5.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].status_ind = 1
      ELSE
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].status_ind = 0
      ENDIF
      IF (l5.active_ind=1
       AND l5.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND l5.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].loc_status_ind = 1
      ELSE
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].loc_status_ind = 0
      ENDIF
      unit_bed_cnt = 0
     ENDIF
    HEAD lg6.child_loc_cd
     IF (lg6.child_loc_cd > 0)
      unit_bed_cnt = (unit_bed_cnt+ 1), stat = alterlist(reply->build_qual[build_cnt].nu_qual[
       unit_cnt].room_qual[unit_room_cnt].bed_qual,unit_bed_cnt), reply->build_qual[build_cnt].
      nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt].bed_cd = lg6.child_loc_cd,
      reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt].
      bed_seq = lg6.sequence
      IF (cva6.code_value > 0)
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt]
       .bed_alias = cva6.alias, reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[
       unit_room_cnt].bed_qual[unit_bed_cnt].updt_cnt = cva6.updt_cnt, reply->build_qual[build_cnt].
       nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt].alias_ind = 1
      ENDIF
      IF (lg6.active_ind=1
       AND lg6.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND lg6.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt]
       .status_ind = 1
      ELSE
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt]
       .status_ind = 0
      ENDIF
      IF (l6.active_ind=1
       AND l6.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND l6.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt]
       .loc_status_ind = 1
      ELSE
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt]
       .loc_status_ind = 0
      ENDIF
     ENDIF
    WITH nocounter, outerjoin = d1, outerjoin = d2,
     outerjoin = d3, outerjoin = d4, outerjoin = d5,
     outerjoin = d6, outerjoin = d7, outerjoin = d8,
     outerjoin = d9, outerjoin = d10, dontcare = cva1,
     dontcare = cva2, dontcare = cva3, dontcare = cva4,
     dontcare = cva5, dontcare = cva6
   ;end select
  OF "BUILDING":
   IF (lookup_cnt != 2)
    GO TO exit_script
   ENDIF
   EXECUTE FROM building_lookup TO end_lookup
   SELECT
    IF ((request->get_all_flag=1))
     PLAN (lg2
      WHERE (lg2.parent_loc_cd=request->parent_loc_cd)
       AND lg2.location_group_type_cd=build_cd
       AND lg2.root_loc_cd=0)
      JOIN (l2
      WHERE lg2.child_loc_cd=l2.location_cd)
      JOIN (d6)
      JOIN (cva2
      WHERE cva2.code_set=220
       AND cva2.code_value=lg2.child_loc_cd
       AND cva2.alias > " "
       AND (cva2.contributor_source_cd=request->contributor_source_cd))
      JOIN (d2)
      JOIN (((lg3
      WHERE lg3.parent_loc_cd=lg2.child_loc_cd
       AND lg3.location_group_type_cd=nu_cd
       AND lg3.root_loc_cd=0
       AND lg2.child_loc_cd > 0)
      JOIN (l3
      WHERE lg3.child_loc_cd=l3.location_cd)
      JOIN (d7)
      JOIN (cva3
      WHERE cva3.code_set=220
       AND cva3.code_value=lg3.child_loc_cd
       AND cva3.alias > " "
       AND (cva3.contributor_source_cd=request->contributor_source_cd))
      JOIN (d3)
      JOIN (lg4
      WHERE lg4.parent_loc_cd=lg3.child_loc_cd
       AND lg4.location_group_type_cd=room_cd
       AND lg4.root_loc_cd=0
       AND lg3.child_loc_cd > 0)
      JOIN (l4
      WHERE lg4.child_loc_cd=l4.location_cd)
      JOIN (d8)
      JOIN (cva4
      WHERE cva4.code_set=220
       AND cva4.code_value=lg4.child_loc_cd
       AND cva4.alias > " "
       AND (cva4.contributor_source_cd=request->contributor_source_cd))
      ) ORJOIN ((lg5
      WHERE lg5.parent_loc_cd=lg2.child_loc_cd
       AND lg5.location_group_type_cd=amb_cd
       AND lg5.root_loc_cd=0
       AND lg2.child_loc_cd > 0)
      JOIN (l5
      WHERE lg5.child_loc_cd=l5.location_cd)
      JOIN (d9)
      JOIN (cva5
      WHERE cva5.code_set=220
       AND cva5.code_value=lg5.child_loc_cd
       AND cva5.alias > " "
       AND (cva5.contributor_source_cd=request->contributor_source_cd))
      JOIN (d4)
      JOIN (lg6
      WHERE lg6.parent_loc_cd=lg5.child_loc_cd
       AND lg6.location_group_type_cd=room_cd
       AND lg6.root_loc_cd=0
       AND lg6.child_loc_cd > 0)
      JOIN (l6
      WHERE lg6.child_loc_cd=l6.location_cd)
      JOIN (d10)
      JOIN (cva6
      WHERE cva6.code_set=220
       AND cva6.code_value=lg6.child_loc_cd
       AND cva6.alias > " "
       AND (cva6.contributor_source_cd=request->contributor_source_cd))
      ))
    ELSEIF ((request->get_all_flag=0))
     PLAN (lg2
      WHERE (lg2.parent_loc_cd=request->parent_loc_cd)
       AND lg2.location_group_type_cd=build_cd
       AND lg2.root_loc_cd=0
       AND lg2.active_ind=1
       AND lg2.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND lg2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (l2
      WHERE lg2.child_loc_cd=l2.location_cd
       AND l2.active_ind=1
       AND l2.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND l2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (d6)
      JOIN (cva2
      WHERE cva2.code_set=220
       AND cva2.code_value=lg2.child_loc_cd
       AND cva2.alias > " "
       AND (cva2.contributor_source_cd=request->contributor_source_cd))
      JOIN (d2)
      JOIN (((lg3
      WHERE lg3.parent_loc_cd=lg2.child_loc_cd
       AND lg3.location_group_type_cd=nu_cd
       AND lg3.root_loc_cd=0
       AND lg3.active_ind=1
       AND lg3.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND lg3.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
       AND lg2.child_loc_cd > 0)
      JOIN (l3
      WHERE lg3.child_loc_cd=l3.location_cd
       AND l3.active_ind=1
       AND l3.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND l3.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (d7)
      JOIN (cva3
      WHERE cva3.code_set=220
       AND cva3.code_value=lg3.child_loc_cd
       AND cva3.alias > " "
       AND (cva3.contributor_source_cd=request->contributor_source_cd))
      JOIN (d3)
      JOIN (lg4
      WHERE lg4.parent_loc_cd=lg3.child_loc_cd
       AND lg4.location_group_type_cd=room_cd
       AND lg4.root_loc_cd=0
       AND lg4.active_ind=1
       AND lg4.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND lg4.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
       AND lg3.child_loc_cd > 0)
      JOIN (l4
      WHERE lg4.child_loc_cd=l4.location_cd
       AND l4.active_ind=1
       AND l4.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND l4.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (d8)
      JOIN (cva4
      WHERE cva4.code_set=220
       AND cva4.code_value=lg4.child_loc_cd
       AND cva4.alias > " "
       AND (cva4.contributor_source_cd=request->contributor_source_cd))
      ) ORJOIN ((lg5
      WHERE lg5.parent_loc_cd=lg2.child_loc_cd
       AND lg5.location_group_type_cd=amb_cd
       AND lg5.root_loc_cd=0
       AND lg5.active_ind=1
       AND lg5.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND lg5.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
       AND lg2.child_loc_cd > 0)
      JOIN (l5
      WHERE lg5.child_loc_cd=l5.location_cd
       AND l5.active_ind=1
       AND l5.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND l5.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (d9)
      JOIN (cva5
      WHERE cva5.code_set=220
       AND cva5.code_value=lg5.child_loc_cd
       AND cva5.alias > " "
       AND (cva5.contributor_source_cd=request->contributor_source_cd))
      JOIN (d4)
      JOIN (lg6
      WHERE lg6.parent_loc_cd=lg5.child_loc_cd
       AND lg6.location_group_type_cd=room_cd
       AND lg6.root_loc_cd=0
       AND lg6.child_loc_cd > 0
       AND lg6.active_ind=1
       AND lg6.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND lg6.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (l6
      WHERE lg6.child_loc_cd=l6.location_cd
       AND l6.active_ind=1
       AND l6.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND l6.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (d10)
      JOIN (cva6
      WHERE cva6.code_set=220
       AND cva6.code_value=lg6.child_loc_cd
       AND cva6.alias > " "
       AND (cva6.contributor_source_cd=request->contributor_source_cd))
      ))
    ELSE
    ENDIF
    INTO "nl:"
    lg2.child_loc_cd, lg3.child_loc_cd, lg4.child_loc_cd,
    lg5.child_loc_cd, lg6.child_loc_cd
    FROM location_group lg2,
     location_group lg3,
     location_group lg4,
     location_group lg5,
     location_group lg6,
     location l2,
     location l3,
     location l4,
     location l5,
     location l6,
     (dummyt d2  WITH seq = 1),
     (dummyt d3  WITH seq = 1),
     (dummyt d4  WITH seq = 1),
     (dummyt d6  WITH seq = 1),
     (dummyt d7  WITH seq = 1),
     (dummyt d8  WITH seq = 1),
     (dummyt d9  WITH seq = 1),
     (dummyt d10  WITH seq = 1),
     code_value_outbound cva2,
     code_value_outbound cva3,
     code_value_outbound cva4,
     code_value_outbound cva5,
     code_value_outbound cva6
    HEAD REPORT
     build_cnt = 1, unit_cnt = 0, unit_cnt = 0
    HEAD lg2.child_loc_cd
     IF (lg2.child_loc_cd > 0)
      unit_cnt = (unit_cnt+ 1), stat = alterlist(reply->build_qual[build_cnt].nu_qual,unit_cnt),
      reply->build_qual[build_cnt].nu_qual[unit_cnt].nu_cd = lg2.child_loc_cd,
      reply->build_qual[build_cnt].nu_qual[unit_cnt].nu_seq = lg2.sequence
      IF (cva2.code_value > 0)
       reply->build_qual[build_cnt].nu_qual[unit_cnt].nu_alias = cva2.alias, reply->build_qual[
       build_cnt].nu_qual[unit_cnt].updt_cnt = cva2.updt_cnt, reply->build_qual[build_cnt].nu_qual[
       unit_cnt].alias_ind = 1
      ENDIF
      IF (lg2.active_ind=1
       AND lg2.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND lg2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       reply->build_qual[build_cnt].nu_qual[unit_cnt].status_ind = 1
      ELSE
       reply->build_qual[build_cnt].nu_qual[unit_cnt].status_ind = 0
      ENDIF
      IF (l2.active_ind=1
       AND l2.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND l2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       reply->build_qual[build_cnt].nu_qual[unit_cnt].loc_status_ind = 1
      ELSE
       reply->build_qual[build_cnt].nu_qual[unit_cnt].loc_status_ind = 0
      ENDIF
      unit_room_cnt = 0, unit_bed_cnt = 0, unit_room_cnt = 0,
      unit_bed_cnt = 0
     ENDIF
    HEAD lg3.child_loc_cd
     IF (lg3.child_loc_cd > 0)
      unit_room_cnt = (unit_room_cnt+ 1), stat = alterlist(reply->build_qual[build_cnt].nu_qual[
       unit_cnt].room_qual,unit_room_cnt), reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[
      unit_room_cnt].room_cd = lg3.child_loc_cd,
      reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].room_seq = lg3.sequence
      IF (cva3.code_value > 0)
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].room_alias = cva3
       .alias, reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].updt_cnt =
       cva3.updt_cnt, reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].
       alias_ind = 1
      ENDIF
      IF (lg3.active_ind=1
       AND lg3.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND lg3.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].status_ind = 1
      ELSE
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].status_ind = 0
      ENDIF
      IF (l3.active_ind=1
       AND l3.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND l3.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].loc_status_ind = 1
      ELSE
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].loc_status_ind = 0
      ENDIF
      unit_bed_cnt = 0
     ENDIF
    HEAD lg4.child_loc_cd
     IF (lg4.child_loc_cd > 0)
      unit_bed_cnt = (unit_bed_cnt+ 1), stat = alterlist(reply->build_qual[build_cnt].nu_qual[
       unit_cnt].room_qual[unit_room_cnt].bed_qual,unit_bed_cnt), reply->build_qual[build_cnt].
      nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt].bed_cd = lg4.child_loc_cd,
      reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt].
      bed_seq = lg4.sequence
      IF (cva4.code_value > 0)
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt]
       .bed_alias = cva4.alias, reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[
       unit_room_cnt].bed_qual[unit_bed_cnt].updt_cnt = cva4.updt_cnt, reply->build_qual[build_cnt].
       nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt].alias_ind = 1
      ENDIF
      IF (lg4.active_ind=1
       AND lg4.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND lg4.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt]
       .status_ind = 1
      ELSE
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt]
       .status_ind = 0
      ENDIF
      IF (l4.active_ind=1
       AND l4.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND l4.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt]
       .loc_status_ind = 1
      ELSE
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt]
       .loc_status_ind = 0
      ENDIF
     ENDIF
    HEAD lg5.child_loc_cd
     IF (lg5.child_loc_cd > 0)
      unit_room_cnt = (unit_room_cnt+ 1), stat = alterlist(reply->build_qual[build_cnt].nu_qual[
       unit_cnt].room_qual,unit_room_cnt), reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[
      unit_room_cnt].room_cd = lg5.child_loc_cd,
      reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].room_seq = lg5.sequence
      IF (cva5.code_value > 0)
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].room_alias = cva5
       .alias, reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].updt_cnt =
       cva5.updt_cnt, reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].
       alias_ind = 1
      ENDIF
      IF (lg5.active_ind=1
       AND lg5.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND lg5.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].status_ind = 1
      ELSE
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].status_ind = 0
      ENDIF
      IF (l5.active_ind=1
       AND l5.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND l5.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].loc_status_ind = 1
      ELSE
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].loc_status_ind = 0
      ENDIF
      unit_bed_cnt = 0
     ENDIF
    HEAD lg6.child_loc_cd
     IF (lg6.child_loc_cd > 0)
      unit_bed_cnt = (unit_bed_cnt+ 1), stat = alterlist(reply->build_qual[build_cnt].nu_qual[
       unit_cnt].room_qual[unit_room_cnt].bed_qual,unit_bed_cnt), reply->build_qual[build_cnt].
      nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt].bed_cd = lg6.child_loc_cd,
      reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt].
      bed_seq = lg6.sequence
      IF (cva6.code_value > 0)
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt]
       .bed_alias = cva6.alias, reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[
       unit_room_cnt].bed_qual[unit_bed_cnt].updt_cnt = cva6.updt_cnt, reply->build_qual[build_cnt].
       nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt].alias_ind = 1
      ENDIF
      IF (lg6.active_ind=1
       AND lg6.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND lg6.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt]
       .status_ind = 1
      ELSE
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt]
       .status_ind = 0
      ENDIF
      IF (l6.active_ind=1
       AND l6.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND l6.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt]
       .loc_status_ind = 1
      ELSE
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt]
       .loc_status_ind = 0
      ENDIF
     ENDIF
    WITH nocounter, outerjoin = d2, outerjoin = d3,
     outerjoin = d4, outerjoin = d6, outerjoin = d7,
     outerjoin = d8, outerjoin = d9, outerjoin = d10,
     dontcare = cva2, dontcare = cva3, dontcare = cva4,
     dontcare = cva5, dontcare = cva6
   ;end select
  OF "NURSEUNIT":
   IF (lookup_cnt != 3)
    GO TO exit_script
   ENDIF
   EXECUTE FROM nu_lookup TO end_lookup
   SELECT
    IF ((request->get_all_flag=1))
     PLAN (lg3
      WHERE (lg3.parent_loc_cd=request->parent_loc_cd)
       AND lg3.location_group_type_cd=nu_cd
       AND lg3.root_loc_cd=0)
      JOIN (l3
      WHERE lg3.child_loc_cd=l3.location_cd)
      JOIN (d7)
      JOIN (cva3
      WHERE cva3.code_set=220
       AND cva3.code_value=lg3.child_loc_cd
       AND cva3.alias > " "
       AND (cva3.contributor_source_cd=request->contributor_source_cd))
      JOIN (d3)
      JOIN (lg4
      WHERE lg4.parent_loc_cd=lg3.child_loc_cd
       AND lg4.location_group_type_cd=room_cd
       AND lg4.root_loc_cd=0
       AND lg3.child_loc_cd > 0)
      JOIN (l4
      WHERE lg4.child_loc_cd=l4.location_cd)
      JOIN (d8)
      JOIN (cva4
      WHERE cva4.code_set=220
       AND cva4.code_value=lg4.child_loc_cd
       AND cva4.alias > " "
       AND (cva4.contributor_source_cd=request->contributor_source_cd))
    ELSEIF ((request->get_all_flag=0))
     PLAN (lg3
      WHERE (lg3.parent_loc_cd=request->parent_loc_cd)
       AND lg3.location_group_type_cd=nu_cd
       AND lg3.root_loc_cd=0
       AND lg3.active_ind=1
       AND lg3.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND lg3.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (l3
      WHERE lg3.child_loc_cd=l3.location_cd
       AND l3.active_ind=1
       AND l3.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND l3.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (d7)
      JOIN (cva3
      WHERE cva3.code_set=220
       AND cva3.code_value=lg3.child_loc_cd
       AND cva3.alias > " "
       AND (cva3.contributor_source_cd=request->contributor_source_cd))
      JOIN (d3)
      JOIN (lg4
      WHERE lg4.parent_loc_cd=lg3.child_loc_cd
       AND lg4.location_group_type_cd=room_cd
       AND lg4.root_loc_cd=0
       AND lg4.active_ind=1
       AND lg4.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND lg4.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
       AND lg3.child_loc_cd > 0)
      JOIN (l4
      WHERE lg4.child_loc_cd=l4.location_cd
       AND l4.active_ind=1
       AND l4.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND l4.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (d8)
      JOIN (cva4
      WHERE cva4.code_set=220
       AND cva4.code_value=lg4.child_loc_cd
       AND cva4.alias > " "
       AND (cva4.contributor_source_cd=request->contributor_source_cd))
    ELSE
    ENDIF
    INTO "nl:"
    lg3.child_loc_cd, lg4.child_loc_cd
    FROM location_group lg3,
     location_group lg4,
     location l3,
     location l4,
     (dummyt d3  WITH seq = 1),
     (dummyt d7  WITH seq = 1),
     (dummyt d8  WITH seq = 1),
     code_value_outbound cva3,
     code_value_outbound cva4
    HEAD REPORT
     build_cnt = 1, unit_cnt = 1, unit_room_cnt = 0,
     unit_bed_cnt = 0
    HEAD lg3.child_loc_cd
     IF (lg3.child_loc_cd > 0)
      unit_room_cnt = (unit_room_cnt+ 1), stat = alterlist(reply->build_qual[build_cnt].nu_qual[
       unit_cnt].room_qual,unit_room_cnt), reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[
      unit_room_cnt].room_cd = lg3.child_loc_cd,
      reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].room_seq = lg3.sequence
      IF (cva3.code_value > 0)
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].room_alias = cva3
       .alias, reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].updt_cnt =
       cva3.updt_cnt, reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].
       alias_ind = 1
      ENDIF
      IF (lg3.active_ind=1
       AND lg3.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND lg3.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].status_ind = 1
      ELSE
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].status_ind = 0
      ENDIF
      IF (l3.active_ind=1
       AND l3.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND l3.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].loc_status_ind = 1
      ELSE
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].loc_status_ind = 0
      ENDIF
      unit_bed_cnt = 0
     ENDIF
    HEAD lg4.child_loc_cd
     IF (lg4.child_loc_cd > 0)
      unit_bed_cnt = (unit_bed_cnt+ 1), stat = alterlist(reply->build_qual[build_cnt].nu_qual[
       unit_cnt].room_qual[unit_room_cnt].bed_qual,unit_bed_cnt), reply->build_qual[build_cnt].
      nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt].bed_cd = lg4.child_loc_cd,
      reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt].
      bed_seq = lg4.sequence
      IF (cva4.code_value > 0)
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt]
       .bed_alias = cva4.alias, reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[
       unit_room_cnt].bed_qual[unit_bed_cnt].updt_cnt = cva4.updt_cnt, reply->build_qual[build_cnt].
       nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt].alias_ind = 1
      ENDIF
      IF (lg4.active_ind=1
       AND lg4.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND lg4.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt]
       .status_ind = 1
      ELSE
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt]
       .status_ind = 0
      ENDIF
      IF (l4.active_ind=1
       AND l4.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND l4.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt]
       .loc_status_ind = 1
      ELSE
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt]
       .loc_status_ind = 0
      ENDIF
     ENDIF
    WITH nocounter, outerjoin = d3, outerjoin = d7,
     outerjoin = d8, dontcare = cva3, dontcare = cva4
   ;end select
  OF "AMBULATORY":
   IF (lookup_cnt != 3)
    GO TO exit_script
   ENDIF
   EXECUTE FROM amb_lookup TO end_lookup
   SELECT
    IF ((request->get_all_flag=1))
     PLAN (lg5
      WHERE (lg5.parent_loc_cd=request->parent_loc_cd)
       AND lg5.location_group_type_cd=amb_cd
       AND lg5.root_loc_cd=0)
      JOIN (l5
      WHERE lg5.child_loc_cd=l5.location_cd)
      JOIN (d9)
      JOIN (cva5
      WHERE cva5.code_set=220
       AND cva5.code_value=lg5.child_loc_cd
       AND cva5.alias > " "
       AND (cva5.contributor_source_cd=request->contributor_source_cd))
      JOIN (d4)
      JOIN (lg6
      WHERE lg6.parent_loc_cd=lg5.child_loc_cd
       AND lg6.location_group_type_cd=room_cd
       AND lg6.root_loc_cd=0
       AND lg6.child_loc_cd > 0)
      JOIN (l6
      WHERE lg6.child_loc_cd=l6.location_cd)
      JOIN (d10)
      JOIN (cva6
      WHERE cva6.code_set=220
       AND cva6.code_value=lg6.child_loc_cd
       AND cva6.alias > " "
       AND (cva6.contributor_source_cd=request->contributor_source_cd))
    ELSEIF ((request->get_all_flag=0))
     PLAN (lg5
      WHERE (lg5.parent_loc_cd=request->parent_loc_cd)
       AND lg5.location_group_type_cd=amb_cd
       AND lg5.root_loc_cd=0
       AND lg5.active_ind=1
       AND lg5.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND lg5.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (l5
      WHERE lg5.child_loc_cd=l5.location_cd
       AND l5.active_ind=1
       AND l5.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND l5.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (d9)
      JOIN (cva5
      WHERE cva5.code_set=220
       AND cva5.code_value=lg5.child_loc_cd
       AND cva5.alias > " "
       AND (cva5.contributor_source_cd=request->contributor_source_cd))
      JOIN (d4)
      JOIN (lg6
      WHERE lg6.parent_loc_cd=lg5.child_loc_cd
       AND lg6.location_group_type_cd=room_cd
       AND lg6.root_loc_cd=0
       AND lg6.child_loc_cd > 0
       AND lg6.active_ind=1
       AND lg6.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND lg6.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (l6
      WHERE lg6.child_loc_cd=l6.location_cd
       AND l6.active_ind=1
       AND l6.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND l6.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (d10)
      JOIN (cva6
      WHERE cva6.code_set=220
       AND cva6.code_value=lg6.child_loc_cd
       AND cva6.alias > " "
       AND (cva6.contributor_source_cd=request->contributor_source_cd))
    ELSE
    ENDIF
    INTO "nl:"
    lg5.child_loc_cd, lg6.child_loc_cd
    FROM location_group lg5,
     location_group lg6,
     location l5,
     location l6,
     (dummyt d4  WITH seq = 1),
     (dummyt d9  WITH seq = 1),
     (dummyt d10  WITH seq = 1),
     code_value_outbound cva5,
     code_value_outbound cva6
    HEAD REPORT
     build_cnt = 1, unit_cnt = 1, unit_room_cnt = 0,
     unit_bed_cnt = 0
    HEAD lg5.child_loc_cd
     IF (lg5.child_loc_cd > 0)
      unit_room_cnt = (unit_room_cnt+ 1), stat = alterlist(reply->build_qual[build_cnt].nu_qual[
       unit_cnt].room_qual,unit_room_cnt), reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[
      unit_room_cnt].room_cd = lg5.child_loc_cd,
      reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].room_seq = lg5.sequence
      IF (cva5.code_value > 0)
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].room_alias = cva5
       .alias, reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].updt_cnt =
       cva5.updt_cnt, reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].
       alias_ind = 1
      ENDIF
      IF (lg5.active_ind=1
       AND lg5.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND lg5.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].status_ind = 1
      ELSE
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].status_ind = 0
      ENDIF
      IF (l5.active_ind=1
       AND l5.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND l5.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].loc_status_ind = 1
      ELSE
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].loc_status_ind = 0
      ENDIF
      unit_bed_cnt = 0
     ENDIF
    HEAD lg6.child_loc_cd
     IF (lg6.child_loc_cd > 0)
      unit_bed_cnt = (unit_bed_cnt+ 1), stat = alterlist(reply->build_qual[build_cnt].nu_qual[
       unit_cnt].room_qual[unit_room_cnt].bed_qual,unit_bed_cnt), reply->build_qual[build_cnt].
      nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt].bed_cd = lg6.child_loc_cd,
      reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt].
      bed_seq = lg6.sequence
      IF (cva6.code_value > 0)
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt]
       .bed_alias = cva6.alias, reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[
       unit_room_cnt].bed_qual[unit_bed_cnt].updt_cnt = cva6.updt_cnt, reply->build_qual[build_cnt].
       nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt].alias_ind = 1
      ENDIF
      IF (lg6.active_ind=1
       AND lg6.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND lg6.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt]
       .status_ind = 1
      ELSE
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt]
       .status_ind = 0
      ENDIF
      IF (l6.active_ind=1
       AND l6.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND l6.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt]
       .loc_status_ind = 1
      ELSE
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt]
       .loc_status_ind = 0
      ENDIF
     ENDIF
    WITH nocounter, outerjoin = d4, outerjoin = d9,
     outerjoin = d10, dontcare = cva5, dontcare = cva6
   ;end select
  OF "ROOM":
   IF (lookup_cnt != 4)
    GO TO exit_script
   ENDIF
   EXECUTE FROM room_lookup TO end_lookup
   SELECT
    IF ((request->get_all_flag=1))
     PLAN (lg4
      WHERE (lg4.parent_loc_cd=request->parent_loc_cd)
       AND lg4.location_group_type_cd=room_cd
       AND lg4.root_loc_cd=0)
      JOIN (l4
      WHERE lg4.child_loc_cd=l4.location_cd)
      JOIN (d8)
      JOIN (cva4
      WHERE cva4.code_set=220
       AND cva4.code_value=lg4.child_loc_cd
       AND cva4.alias > " "
       AND (cva4.contributor_source_cd=request->contributor_source_cd))
    ELSEIF ((request->get_all_flag=0))
     PLAN (lg4
      WHERE (lg4.parent_loc_cd=request->parent_loc_cd)
       AND lg4.location_group_type_cd=room_cd
       AND lg4.root_loc_cd=0
       AND lg4.active_ind=1
       AND lg4.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND lg4.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (l4
      WHERE lg4.child_loc_cd=l4.location_cd
       AND l4.active_ind=1
       AND l4.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND l4.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (d8)
      JOIN (cva4
      WHERE cva4.code_set=220
       AND cva4.code_value=lg4.child_loc_cd
       AND cva4.alias > " "
       AND (cva4.contributor_source_cd=request->contributor_source_cd))
    ELSE
    ENDIF
    INTO "nl:"
    lg4.child_loc_cd
    FROM location_group lg4,
     location l4,
     code_value_outbound cva4,
     (dummyt d8  WITH seq = 1)
    HEAD REPORT
     build_cnt = 1, unit_cnt = 1, unit_room_cnt = 1,
     unit_bed_cnt = 0
    HEAD lg4.child_loc_cd
     IF (lg4.child_loc_cd > 0)
      unit_bed_cnt = (unit_bed_cnt+ 1), stat = alterlist(reply->build_qual[build_cnt].nu_qual[
       unit_cnt].room_qual[unit_room_cnt].bed_qual,unit_bed_cnt), reply->build_qual[build_cnt].
      nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt].bed_cd = lg4.child_loc_cd,
      reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt].
      bed_seq = lg4.sequence
      IF (cva4.code_value > 0)
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt]
       .bed_alias = cva4.alias, reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[
       unit_room_cnt].bed_qual[unit_bed_cnt].updt_cnt = cva4.updt_cnt, reply->build_qual[build_cnt].
       nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt].alias_ind = 1
      ENDIF
      IF (lg4.active_ind=1
       AND lg4.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND lg4.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt]
       .status_ind = 1
      ELSE
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt]
       .status_ind = 0
      ENDIF
      IF (l4.active_ind=1
       AND l4.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND l4.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt]
       .loc_status_ind = 1
      ELSE
       reply->build_qual[build_cnt].nu_qual[unit_cnt].room_qual[unit_room_cnt].bed_qual[unit_bed_cnt]
       .loc_status_ind = 0
      ENDIF
     ENDIF
    WITH nocounter, outerjoin = d8, dontcare = cva4
   ;end select
  OF "BED":
   SET x = 0
   SET x = (x+ 1)
  ELSE
   GO TO exit_script
 ENDCASE
 SET reply->status_data.status = "S"
 GO TO exit_script
#facility_lookup
 SET code_value = 0.0
 SET code_set = 222
 SET cdf_meaning = "FACILITY"
 EXECUTE cpm_get_cd_for_cdf
 SET fac_cd = code_value
#building_lookup
 SET code_value = 0.0
 SET code_set = 222
 SET cdf_meaning = "BUILDING"
 EXECUTE cpm_get_cd_for_cdf
 SET build_cd = code_value
#nu_lookup
 SET code_value = 0.0
 SET code_set = 222
 SET cdf_meaning = "NURSEUNIT"
 EXECUTE cpm_get_cd_for_cdf
 SET nu_cd = code_value
#amb_lookup
 SET code_value = 0.0
 SET code_set = 222
 SET cdf_meaning = "AMBULATORY"
 EXECUTE cpm_get_cd_for_cdf
 SET amb_cd = code_value
#room_lookup
 SET code_value = 0.0
 SET code_set = 222
 SET cdf_meaning = "ROOM"
 EXECUTE cpm_get_cd_for_cdf
 SET room_cd = code_value
#end_lookup
#exit_script
END GO
