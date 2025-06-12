CREATE PROGRAM dcp_get_parent_locations:dba
 RECORD reply(
   1 locationlistcnt = i2
   1 locationlist[*]
     2 location_cd = f8
     2 location_disp = vc
     2 location_desc = vc
     2 location_mean = vc
     2 parentlistcnt = i2
     2 parentlist[*]
       3 parent_loc_cd = f8
       3 parent_loc_disp = vc
       3 parent_loc_desc = vc
       3 parent_loc_mean = vc
       3 location_group_type_cd = f8
       3 location_group_type_disp = vc
       3 location_group_type_desc = vc
       3 location_group_type_mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET modify = predeclare
 DECLARE locationcd = f8 WITH noconstant(0.0)
 DECLARE loccnt = i2 WITH noconstant(0)
 DECLARE parentexits = i2 WITH noconstant(0)
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE exitwhile = i2 WITH noconstant(0)
 DECLARE seg_end = i2 WITH noconstant(0)
 DECLARE tmp_parent_cnt = i2 WITH noconstant(0)
 DECLARE parent_cnt = i2 WITH noconstant(0)
 DECLARE loclistsize = i2 WITH constant(value(size(request->locationlist,5)))
 DECLARE facilitytypecd = f8 WITH constant(uar_get_code_by("MEANING",222,"FACILITY"))
 DECLARE buildingtypecd = f8 WITH constant(uar_get_code_by("MEANING",222,"BUILDING"))
 DECLARE unittypecd = f8 WITH constant(uar_get_code_by("MEANING",222,"NURSEUNIT"))
 DECLARE ambulatorytypecd = f8 WITH constant(uar_get_code_by("MEANING",222,"AMBULATORY"))
 DECLARE script_version = c30 WITH public, noconstant(fillstring(30," "))
 SET reply->status_data.status = "F"
 FOR (loccnt = 1 TO loclistsize)
   IF (mod(loccnt,10)=1)
    SET stat = alterlist(reply->locationlist,(loccnt+ 9))
   ENDIF
   SET locationcd = request->locationlist[loccnt].location_cd
   SET reply->locationlist[loccnt].location_cd = locationcd
   SET exitwhile = 0
   WHILE (exitwhile=0)
    SELECT INTO "nl:"
     FROM location_group lg
     WHERE lg.child_loc_cd=locationcd
      AND lg.location_group_type_cd IN (facilitytypecd, buildingtypecd, unittypecd, ambulatorytypecd)
      AND ((lg.root_loc_cd+ 0)=0.0)
      AND lg.active_ind=1
     HEAD REPORT
      tmp_parent_cnt = 0
     DETAIL
      tmp_parent_cnt = (tmp_parent_cnt+ 1)
      IF (mod(tmp_parent_cnt,10)=1)
       stat = alterlist(reply->locationlist[loccnt].parentlist,(tmp_parent_cnt+ 9))
      ENDIF
      parent_cnt = (seg_end+ tmp_parent_cnt), reply->locationlist[loccnt].parentlist[parent_cnt].
      parent_loc_cd = lg.parent_loc_cd, reply->locationlist[loccnt].parentlist[parent_cnt].
      location_group_type_cd = lg.location_group_type_cd
     FOOT REPORT
      stat = alterlist(reply->locationlist[loccnt].parentlist,parent_cnt), reply->locationlist[loccnt
      ].parentlistcnt = parent_cnt, parent_cnt = 0,
      seg_end = (seg_end+ tmp_parent_cnt), locationcd = lg.parent_loc_cd
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET exitwhile = 1
    ELSE
     SET parentexits = 1
    ENDIF
   ENDWHILE
   SET seg_end = 0
 ENDFOR
 SET stat = alterlist(reply->locationlist,loclistsize)
 SET reply->locationlistcnt = loclistsize
 IF (parentexits=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
 SET script_version = "001 10/18/04 RR4690"
END GO
