CREATE PROGRAM dcp_get_genview_announcement:dba
 SET position_cd = cnvtreal(request->nv[1].pvc_value)
 CALL echo(build("Position is:",position_cd))
 FREE SET request
 RECORD request(
   1 position_cd = f8
   1 dcp_type = f8
   1 application_number = i4
 )
 SET request->position_cd = position_cd
 SET request->dcp_type = 0
 SET request->application_number = 600005
 EXECUTE value("DCP_GET_ANNOUNCEMENT")
 CALL echo(build("Announcement is:",reply->text))
END GO
