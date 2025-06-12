CREATE PROGRAM ams_sch_inact_resource_roles:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Choose Order Roles or Resource Lists" = "OrderRoles",
  "Order Roles" = 0,
  "Resource Lists" = ""
  WITH outdev, option, orderroles,
  resourcelists
 DECLARE cvreslist = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",16151,"RESOURCELIST"))
 DECLARE cvrole = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",16151,"SINGLEROLE"))
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET script_failed = false
 SET table_name = fillstring(50," ")
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET script_failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 FREE SET temp_request
 RECORD temp_request(
   1 call_echo_ind = i2
   1 role_type_cd = f8
   1 role_type_meaning = c12
   1 allow_partial_ind = i2
   1 qual[*]
     2 res_list_id = f8
     2 info_sch_text_id = f8
     2 info_sch_text_updt_cnt = i4
     2 updt_cnt = i4
     2 force_updt_ind = i2
     2 active_status_cd = f8
     2 version_dt_tm = di8
     2 version_ind = i2
     2 role_partial_ind = i2
     2 role_qual[*]
       3 info_sch_text_id = f8
       3 info_sch_text_updt_cnt = i4
       3 list_role_id = f8
       3 updt_cnt = i4
       3 force_updt_ind = i2
       3 active_status_cd = f8
       3 version_dt_tm = di8
       3 version_ind = i2
       3 res_partial_ind = i2
       3 res_qual[*]
         4 resource_cd = f8
         4 updt_cnt = i4
         4 force_updt_ind = i2
         4 active_status_cd = f8
         4 version_dt_tm = di8
         4 version_ind = i2
         4 slot_partial_ind = i2
         4 slot_qual[*]
           5 slot_type_id = f8
           5 updt_cnt = i4
           5 force_updt_ind = i2
           5 active_status_cd = f8
           5 version_dt_tm = di8
           5 version_ind = i2
         4 loc_partial_ind = i2
         4 loc_qual[*]
           5 location_type_cd = f8
           5 location_cd = f8
           5 updt_cnt = i4
           5 force_updt_ind = i2
           5 active_status_cd = f8
           5 version_dt_tm = di8
           5 version_ind = i2
 )
 IF (( $OPTION="OrderRoles"))
  SET temp_request->role_type_cd = cvrole
  SET temp_request->role_type_meaning = "SINGLE"
  SET temp_request->call_echo_ind = true
  SET temp_request->allow_partial_ind = false
  SET t_index = 1
  SET stat = alterlist(temp_request->qual,t_index)
  SET t_index2 = 0
  CALL echo(build2("Selected Order Roles:", $ORDERROLES))
  IF (( $ORDERROLES=- (1)))
   SELECT INTO "nl:"
    FROM sch_list_role t
    PLAN (t
     WHERE  NOT ( EXISTS (
     (SELECT
      sor.list_role_id
      FROM sch_order_role sor
      WHERE sor.list_role_id=t.list_role_id)))
      AND t.role_type_meaning="SINGLE"
      AND t.active_ind=1
      AND t.updt_dt_tm > cnvtdatetime("01-JAN-2007 00:00")
      AND t.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    DETAIL
     t_index2 = (t_index2+ 1), stat = alterlist(temp_request->qual[t_index].role_qual,t_index2),
     temp_request->qual[t_index].role_qual[t_index2].list_role_id = t.list_role_id,
     temp_request->qual[t_index].role_qual[t_index2].updt_cnt = t.updt_cnt, temp_request->qual[
     t_index].role_qual[t_index2].force_updt_ind = false, temp_request->qual[t_index].role_qual[
     t_index2].res_partial_ind = false,
     temp_request->qual[t_index].role_qual[t_index2].active_status_cd = 0, temp_request->qual[t_index
     ].role_qual[t_index2].version_ind = false
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    FROM sch_list_role t
    PLAN (t
     WHERE t.list_role_id IN ( $ORDERROLES)
      AND t.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    DETAIL
     t_index2 = (t_index2+ 1), stat = alterlist(temp_request->qual[t_index].role_qual,t_index2),
     temp_request->qual[t_index].role_qual[t_index2].list_role_id = t.list_role_id,
     temp_request->qual[t_index].role_qual[t_index2].updt_cnt = t.updt_cnt, temp_request->qual[
     t_index].role_qual[t_index2].force_updt_ind = false, temp_request->qual[t_index].role_qual[
     t_index2].res_partial_ind = false,
     temp_request->qual[t_index].role_qual[t_index2].active_status_cd = 0, temp_request->qual[t_index
     ].role_qual[t_index2].version_ind = false
    WITH nocounter
   ;end select
  ENDIF
  CALL echo("OrderRoles_request1:")
  CALL echorecord(temp_request)
  SET t_index3 = 0
  SET inum = 0
  SELECT INTO "nl:"
   FROM sch_list_res s
   WHERE expand(inum,1,size(temp_request->qual[t_index].role_qual,5),s.list_role_id,temp_request->
    qual[t_index].role_qual[inum].list_role_id)
   HEAD s.list_role_id
    t_index3 = 0
   HEAD s.resource_cd
    t_index3 = (t_index3+ 1), ipos = 0, ilocidx = 0,
    ipos = locateval(ilocidx,1,size(temp_request->qual[t_index].role_qual,5),s.list_role_id,
     temp_request->qual[t_index].role_qual[ilocidx].list_role_id), stat = alterlist(temp_request->
     qual[t_index].role_qual[ipos].res_qual,t_index3), temp_request->qual[t_index].role_qual[ilocidx]
    .res_qual[t_index3].resource_cd = s.resource_cd,
    temp_request->qual[t_index].role_qual[ilocidx].res_qual[t_index3].updt_cnt = s.updt_cnt,
    temp_request->qual[t_index].role_qual[ilocidx].res_qual[t_index3].force_updt_ind = false,
    temp_request->qual[t_index].role_qual[ilocidx].res_qual[t_index3].slot_partial_ind = false,
    temp_request->qual[t_index].role_qual[ilocidx].res_qual[t_index3].active_status_cd = 0,
    temp_request->qual[t_index].role_qual[ilocidx].res_qual[t_index3].version_ind = false
   WITH nocounter
  ;end select
  CALL echo("OrderRoles_request2:")
  CALL echorecord(temp_request)
  SET t_index4 = 0
  SELECT INTO "nl:"
   FROM sch_list_slot s,
    (dummyt d1  WITH seq = value(size(temp_request->qual[t_index].role_qual,5))),
    (dummyt d2  WITH seq = 1)
   PLAN (d1
    WHERE maxrec(d2,size(temp_request->qual[t_index].role_qual[d1.seq].res_qual,5)))
    JOIN (d2)
    JOIN (s
    WHERE (s.list_role_id=temp_request->qual[t_index].role_qual[d1.seq].list_role_id)
     AND (s.resource_cd=temp_request->qual[t_index].role_qual[d1.seq].res_qual[d2.seq].resource_cd))
   HEAD s.resource_cd
    t_index4 = 0
   HEAD s.candidate_id
    t_index4 = (t_index4+ 1), stat = alterlist(temp_request->qual[t_index].role_qual[d1.seq].
     res_qual[d2.seq].slot_qual,t_index4), temp_request->qual[t_index].role_qual[d1.seq].res_qual[d2
    .seq].slot_qual[t_index4].slot_type_id = s.slot_type_id,
    temp_request->qual[t_index].role_qual[d1.seq].res_qual[d2.seq].slot_qual[t_index4].updt_cnt = 2,
    temp_request->qual[t_index].role_qual[d1.seq].res_qual[d2.seq].slot_qual[t_index4].force_updt_ind
     = false, temp_request->qual[t_index].role_qual[d1.seq].res_qual[d2.seq].slot_qual[t_index4].
    active_status_cd = 0,
    temp_request->qual[t_index].role_qual[d1.seq].res_qual[d2.seq].slot_qual[t_index4].version_ind =
    false
   WITH nocounter
  ;end select
  CALL echo("OrderRoles_request3:")
  CALL echorecord(temp_request)
 ELSE
  SET temp_request->role_type_cd = cvreslist
  SET temp_request->role_type_meaning = "RESLIST"
  SET temp_request->call_echo_ind = true
  SET temp_request->allow_partial_ind = false
  SET t_index = 0
  CALL echo(build2("Selected Resource Lists:", $RESOURCELISTS))
  IF (( $RESOURCELISTS=- (1)))
   SELECT INTO "nl:"
    FROM sch_resource_list srl,
     long_text_reference t2
    PLAN (srl
     WHERE  NOT ( EXISTS (
     (SELECT
      sal.res_list_id, sal.grp_res_list_id
      FROM sch_appt_loc sal
      WHERE ((srl.res_list_id=sal.res_list_id) OR (srl.res_list_id=sal.grp_res_list_id)) )))
      AND srl.active_ind=1
      AND srl.updt_dt_tm > cnvtdatetime("01-JAN-2007 00:00")
      AND srl.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
     JOIN (t2
     WHERE t2.long_text_id=t.info_sch_text_id)
    DETAIL
     t_index = (t_index+ 1), stat = alterlist(temp_request->qual,t_index), temp_request->qual[t_index
     ].res_list_id = t.res_list_id,
     temp_request->qual[t_index].info_sch_text_id = t.info_sch_text_id, temp_request->qual[t_index].
     info_sch_text_updt_cnt = t2.updt_cnt, temp_request->qual[t_index].updt_cnt = t.updt_cnt,
     temp_request->qual[t_index].force_updt_ind = false, temp_request->qual[t_index].role_partial_ind
      = false, temp_request->qual[t_index].active_status_cd = 0,
     temp_request->qual[t_index].version_ind = false
    WITH nocounter
   ;end select
  ELSE
   CALL echo(build2("inside else od resource ists:", $RESOURCELISTS))
   SELECT INTO "nl:"
    FROM sch_resource_list t,
     long_text_reference t2
    PLAN (t
     WHERE t.res_list_id IN ( $RESOURCELISTS)
      AND t.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
     JOIN (t2
     WHERE t2.long_text_id=t.info_sch_text_id)
    DETAIL
     t_index = (t_index+ 1), stat = alterlist(temp_request->qual,t_index), temp_request->qual[t_index
     ].res_list_id = t.res_list_id,
     temp_request->qual[t_index].info_sch_text_id = t.info_sch_text_id, temp_request->qual[t_index].
     info_sch_text_updt_cnt = t2.updt_cnt, temp_request->qual[t_index].updt_cnt = t.updt_cnt,
     temp_request->qual[t_index].force_updt_ind = false, temp_request->qual[t_index].role_partial_ind
      = false, temp_request->qual[t_index].active_status_cd = 0,
     temp_request->qual[t_index].version_ind = false
    WITH nocounter
   ;end select
  ENDIF
  CALL echo("ResourceLists_request1:")
  CALL echorecord(temp_request)
  SET t_index2 = 0
  SELECT INTO "nl:"
   t.updt_cnt
   FROM sch_list_role t
   PLAN (t
    WHERE (t.res_list_id=temp_request->qual[t_index].res_list_id)
     AND t.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   DETAIL
    t_index2 = (t_index2+ 1), stat = alterlist(temp_request->qual[t_index].role_qual,t_index2),
    temp_request->qual[t_index].role_qual[t_index2].list_role_id = t.list_role_id,
    temp_request->qual[t_index].role_qual[t_index2].updt_cnt = t.updt_cnt, temp_request->qual[t_index
    ].role_qual[t_index2].force_updt_ind = false, temp_request->qual[t_index].role_qual[t_index2].
    res_partial_ind = false,
    temp_request->qual[t_index].role_qual[t_index2].active_status_cd = 0, temp_request->qual[t_index]
    .role_qual[t_index2].version_ind = false
   WITH nocounter
  ;end select
  CALL echo("ResourceLists_request2:")
  CALL echorecord(temp_request)
  SET t_index3 = 0
  SET inum = 0
  SELECT INTO "nl:"
   FROM sch_list_res s
   WHERE expand(inum,1,size(temp_request->qual[t_index].role_qual,5),s.list_role_id,temp_request->
    qual[t_index].role_qual[inum].list_role_id)
   HEAD s.list_role_id
    t_index3 = 0
   HEAD s.resource_cd
    t_index3 = (t_index3+ 1), ipos = 0, ilocidx = 0,
    ipos = locateval(ilocidx,1,size(temp_request->qual[t_index].role_qual,5),s.list_role_id,
     temp_request->qual[t_index].role_qual[ilocidx].list_role_id), stat = alterlist(temp_request->
     qual[t_index].role_qual[ipos].res_qual,t_index3), temp_request->qual[t_index].role_qual[ilocidx]
    .res_qual[t_index3].resource_cd = s.resource_cd,
    temp_request->qual[t_index].role_qual[ilocidx].res_qual[t_index3].updt_cnt = s.updt_cnt,
    temp_request->qual[t_index].role_qual[ilocidx].res_qual[t_index3].force_updt_ind = false,
    temp_request->qual[t_index].role_qual[ilocidx].res_qual[t_index3].slot_partial_ind = false,
    temp_request->qual[t_index].role_qual[ilocidx].res_qual[t_index3].active_status_cd = 0,
    temp_request->qual[t_index].role_qual[ilocidx].res_qual[t_index3].version_ind = false
   WITH nocounter
  ;end select
  CALL echo("ResourceLists_request3:")
  CALL echorecord(temp_request)
  SET t_index4 = 0
  SELECT INTO "nl:"
   FROM sch_list_slot s,
    (dummyt d1  WITH seq = value(size(temp_request->qual[t_index].role_qual,5))),
    (dummyt d2  WITH seq = 1)
   PLAN (d1
    WHERE maxrec(d2,size(temp_request->qual[t_index].role_qual[d1.seq].res_qual,5)))
    JOIN (d2)
    JOIN (s
    WHERE (s.list_role_id=temp_request->qual[t_index].role_qual[d1.seq].list_role_id)
     AND (s.resource_cd=temp_request->qual[t_index].role_qual[d1.seq].res_qual[d2.seq].resource_cd))
   HEAD s.resource_cd
    t_index4 = 0
   HEAD s.candidate_id
    t_index4 = (t_index4+ 1), stat = alterlist(temp_request->qual[t_index].role_qual[d1.seq].
     res_qual[d2.seq].slot_qual,t_index4), temp_request->qual[t_index].role_qual[d1.seq].res_qual[d2
    .seq].slot_qual[t_index4].slot_type_id = s.slot_type_id,
    temp_request->qual[t_index].role_qual[d1.seq].res_qual[d2.seq].slot_qual[t_index4].updt_cnt = 2,
    temp_request->qual[t_index].role_qual[d1.seq].res_qual[d2.seq].slot_qual[t_index4].force_updt_ind
     = false, temp_request->qual[t_index].role_qual[d1.seq].res_qual[d2.seq].slot_qual[t_index4].
    active_status_cd = 0,
    temp_request->qual[t_index].role_qual[d1.seq].res_qual[d2.seq].slot_qual[t_index4].version_ind =
    false
   WITH nocounter
  ;end select
  CALL echo("ResourceLists_request4:")
  CALL echorecord(temp_request)
 ENDIF
 EXECUTE sch_inaw_resource_list  WITH replace("REQUEST",temp_request)
 SELECT INTO value( $OUTDEV)
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD REPORT
   col 5, "Script executed successfully."
  WITH nocounter
 ;end select
#exit_script
 IF (script_failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF (script_failed != exe_error)
  CALL updtdminfo(trim(cnvtupper(curprog),3))
 ENDIF
 SET last_mod = "001 05/29/14 ZA030646  Initial Release"
END GO
