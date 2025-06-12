CREATE PROGRAM dummy_mpages_for_roles:dba
 FREE RECORD reply
 RECORD reply(
   1 tab[*]
     2 tab_name = vc
   1 role[*]
     2 role_cd = f8
     2 role_name = vc
     2 tab_name = vc
     2 group_id = f8
   1 mpage_group[*]
     2 group_id = f8
     2 group_name = vc
     2 mpage[*]
       3 mpage_id = f8
       3 mpage_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persistscript
 DECLARE stat = i4 WITH protect, noconstant(0)
 CALL echorecord(request)
 IF (size(request->role,5)=1)
  IF ((request->role[1].role_cd=0.0))
   SET stat = alterlist(reply->tab,0)
  ELSEIF ((request->role[1].role_cd < 0.0))
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Error loading mpage groups"
  ENDIF
 ELSE
  SET stat = alterlist(reply->tab,3)
  SET reply->tab[1].tab_name = "FN B Chart MP Two"
  SET reply->tab[2].tab_name = "PC A Chart MP Three"
  SET reply->tab[3].tab_name = "PC C Chart MP One"
  SET stat = alterlist(reply->role,5)
  SET reply->role[1].role_cd = 111.0
  SET reply->role[1].role_name = "Role One"
  SET reply->role[1].tab_name = "FN B Chart MP Two"
  SET reply->role[1].group_id = 11.0
  SET reply->role[2].role_cd = 222.0
  SET reply->role[2].role_name = "Role Two"
  SET reply->role[2].tab_name = "PC A Chart MP Three"
  SET reply->role[2].group_id = 22.0
  SET reply->role[3].role_cd = 333.0
  SET reply->role[3].role_name = "Role Three"
  SET reply->role[3].tab_name = "PC C Chart MP One"
  SET reply->role[3].group_id = 33.0
  SET reply->role[4].role_cd = 444.0
  SET reply->role[4].role_name = "Role Four"
  SET reply->role[4].tab_name = "PC C Chart MP One"
  SET reply->role[4].group_id = 44.0
  SET reply->role[5].role_cd = 555.0
  SET reply->role[5].role_name = "Role Five"
  SET reply->role[5].tab_name = "PC A Chart MP Three"
  SET reply->role[5].group_id = 33.0
  SET stat = alterlist(reply->mpage_group,3)
  SET reply->mpage_group[1].group_id = 11.0
  SET reply->mpage_group[1].group_name = "MPage Group A"
  SET stat = alterlist(reply->mpage_group[1].mpage,1)
  SET reply->mpage_group[1].mpage[1].mpage_id = 1.0
  SET reply->mpage_group[1].mpage[1].mpage_name = "MPage A"
  SET reply->mpage_group[2].group_id = 22.0
  SET reply->mpage_group[2].group_name = "MPage Group B"
  SET stat = alterlist(reply->mpage_group[2].mpage,1)
  SET reply->mpage_group[2].mpage[1].mpage_id = 2.0
  SET reply->mpage_group[2].mpage[1].mpage_name = "MPage B"
  SET reply->mpage_group[3].group_id = 33.0
  SET reply->mpage_group[3].group_name = "MPage Group C"
  SET stat = alterlist(reply->mpage_group[3].mpage,2)
  SET reply->mpage_group[3].mpage[1].mpage_id = 2.0
  SET reply->mpage_group[3].mpage[1].mpage_name = "MPage B"
  SET reply->mpage_group[3].mpage[2].mpage_id = 3.0
  SET reply->mpage_group[3].mpage[2].mpage_name = "MPage C"
 ENDIF
#exit_script
 CALL echo("dummy_mpages_for_roles returning")
END GO
