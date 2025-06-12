CREATE PROGRAM dcp_get_child_locations:dba
 RECORD reply(
   1 qual[*]
     2 level = i4
     2 parent_loc_cd = f8
     2 location_cd = f8
     2 location_disp = c40
     2 location_desc = c60
     2 location_mean = c12
     2 sequence = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE reportfailure(opname=vc,opstatus=vc,targetname=vc,targetvalue=vc) = null
 DECLARE fillsubeventstatus(opname=vc,opstatus=vc,objname=vc,objvalue=vc) = null
 SUBROUTINE reportfailure(opname,opstatus,targetname,targetvalue)
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus(opname,opstatus,targetname,targetvalue)
 END ;Subroutine
 SUBROUTINE fillsubeventstatus(opname,opstatus,objname,objvalue)
   DECLARE dcp_substatus_cnt = i4 WITH protect, noconstant(size(reply->status_data.subeventstatus,5))
   SET dcp_substatus_cnt = (dcp_substatus_cnt+ 1)
   IF (dcp_substatus_cnt != 1)
    SET stat = alter(reply->status_data.subeventstatus,dcp_substatus_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectname = trim(objname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectvalue = trim(objvalue)
 END ;Subroutine
 SET modify = predeclare
 DECLARE location_type = vc WITH protect, noconstant("")
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE seg_start = i4 WITH protect, noconstant(0)
 DECLARE seg_end = i4 WITH protect, noconstant(1)
 DECLARE level = i4 WITH protect, noconstant(0)
 DECLARE parent_cnt = i4 WITH protect, noconstant(1)
 DECLARE children_cnt = i4 WITH protect, noconstant(0)
 DECLARE child_index = i4 WITH protect, noconstant(0)
 DECLARE locationtypecnt = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE ierrorcode = i2 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 RECORD temp(
   1 templist[*]
     2 templocationcd = f8
 )
 DECLARE getlocationsbylocationcd(null) = null
 DECLARE getlocationsbylocationtypecd(null) = null
 SET location_type = uar_get_code_meaning(request->location_cd)
 SET stat = alterlist(reply->qual,1)
 SET reply->qual[1].level = 0
 SET reply->qual[1].parent_loc_cd = 0
 SET reply->qual[1].location_cd = request->location_cd
 CALL echo(build("locationType:",location_type))
 IF (location_type="SHFTASGNROOT")
  SELECT INTO "nl:"
   FROM location_group lg,
    code_value c
   PLAN (lg
    WHERE (lg.root_loc_cd=request->location_cd)
     AND lg.active_ind=1)
    JOIN (c
    WHERE c.code_value=lg.child_loc_cd
     AND c.active_ind=1)
   HEAD REPORT
    children_cnt = 0
   DETAIL
    children_cnt = (children_cnt+ 1)
    IF (mod(children_cnt,20)=1)
     stat = alterlist(reply->qual,(children_cnt+ 20))
    ENDIF
    child_index = children_cnt, reply->qual[child_index].level = - (1), reply->qual[child_index].
    parent_loc_cd = lg.parent_loc_cd,
    reply->qual[child_index].location_cd = lg.child_loc_cd, reply->qual[child_index].sequence = lg
    .sequence
   FOOT REPORT
    stat = alterlist(reply->qual,children_cnt)
   WITH nocounter
  ;end select
 ELSE
  IF (validate(request->location_type_list))
   SET locationtypecnt = size(request->location_type_list,5)
  ENDIF
  IF (locationtypecnt > 0)
   CALL getlocationsbylocationtypecd(null)
  ELSE
   CALL getlocationsbylocationcd(null)
  ENDIF
  SUBROUTINE getlocationsbylocationcd(null)
    WHILE (parent_cnt > 0
     AND (level < request->search_depth))
      SET level = (level+ 1)
      SELECT INTO "nl:"
       FROM location_group lg,
        code_value c,
        (dummyt d  WITH seq = value(parent_cnt))
       PLAN (d)
        JOIN (lg
        WHERE (lg.parent_loc_cd=reply->qual[(d.seq+ seg_start)].location_cd)
         AND ((lg.root_loc_cd+ 0)=validate(request->root_location_cd,0.0))
         AND lg.active_ind=1)
        JOIN (c
        WHERE c.code_value=lg.child_loc_cd
         AND c.active_ind=1)
       HEAD REPORT
        children_cnt = 0
       DETAIL
        children_cnt = (children_cnt+ 1)
        IF (mod(children_cnt,20)=1)
         stat = alterlist(reply->qual,((seg_end+ children_cnt)+ 19))
        ENDIF
        child_index = (seg_end+ children_cnt), reply->qual[child_index].level = level, reply->qual[
        child_index].parent_loc_cd = lg.parent_loc_cd,
        reply->qual[child_index].location_cd = lg.child_loc_cd, reply->qual[child_index].sequence =
        lg.sequence
       FOOT REPORT
        stat = alterlist(reply->qual,child_index)
       WITH nocounter
      ;end select
      SET seg_start = seg_end
      SET seg_end = (seg_end+ children_cnt)
      SET parent_cnt = children_cnt
      SET children_cnt = 0
    ENDWHILE
  END ;Subroutine
  SUBROUTINE getlocationsbylocationtypecd(null)
    WHILE (parent_cnt > 0
     AND (level < request->search_depth))
      SET level = (level+ 1)
      SELECT INTO "nl:"
       FROM location_group lg,
        code_value c,
        location l,
        (dummyt d  WITH seq = value(parent_cnt))
       PLAN (d)
        JOIN (lg
        WHERE (lg.parent_loc_cd=reply->qual[(d.seq+ seg_start)].location_cd)
         AND ((lg.root_loc_cd+ 0)=validate(request->root_location_cd,0.0))
         AND lg.active_ind=1)
        JOIN (l
        WHERE expand(num,1,locationtypecnt,(l.location_type_cd+ 0),request->location_type_list[num].
         location_type_cd)
         AND l.location_cd=lg.child_loc_cd
         AND l.active_ind=1)
        JOIN (c
        WHERE c.code_value=lg.child_loc_cd
         AND c.active_ind=1)
       HEAD REPORT
        children_cnt = 0
       DETAIL
        children_cnt = (children_cnt+ 1)
        IF (mod(children_cnt,20)=1)
         stat = alterlist(reply->qual,((seg_end+ children_cnt)+ 19))
        ENDIF
        child_index = (seg_end+ children_cnt), reply->qual[child_index].level = level, reply->qual[
        child_index].parent_loc_cd = lg.parent_loc_cd,
        reply->qual[child_index].location_cd = lg.child_loc_cd, reply->qual[child_index].sequence =
        lg.sequence
       FOOT REPORT
        stat = alterlist(reply->qual,child_index)
       WITH nocounter
      ;end select
      SET seg_start = seg_end
      SET seg_end = (seg_end+ children_cnt)
      SET parent_cnt = children_cnt
      SET children_cnt = 0
    ENDWHILE
  END ;Subroutine
 ENDIF
 SET ierrorcode = error(serrormsg,1)
 IF (ierrorcode != 0)
  CALL echo(build("ERROR CODE: ",ierrorcode))
  CALL echo(build("ERROR MESSAGE: ",serrormsg))
  CALL reportfailure("ERROR","F","dcp_get_child_locations",serrormsg)
 ELSE
  CALL echo("******** Success ********")
  SET reply->status_data.status = "S"
 ENDIF
 SET modify = nopredeclare
END GO
