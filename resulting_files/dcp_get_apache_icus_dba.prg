CREATE PROGRAM dcp_get_apache_icus:dba
 RECORD reply(
   1 location_list[*]
     2 location_disp = vc
     2 location_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 EXECUTE FROM 1000_initialize TO 1099_initialize_exit
 EXECUTE FROM 2000_read TO 2099_read_exit
 GO TO 9999_exit_program
 SUBROUTINE meaning_code(mc_codeset,mc_meaning)
   SET mc_code = 0.0
   SET mc_text = fillstring(12," ")
   SET mc_text = mc_meaning
   SET mc_stat = uar_get_meaning_by_codeset(mc_codeset,nullterm(mc_text),1,mc_code)
   IF (mc_code > 0.0)
    RETURN(mc_code)
   ELSE
    RETURN(- (1.0))
   ENDIF
 END ;Subroutine
#1000_initialize
 SET reply->status_data.status = "F"
#1099_initialize_exit
#2000_read
 SET count = 0
 SELECT INTO "nl:"
  FROM risk_adjustment_ref rar,
   location l
  PLAN (rar
   WHERE ((rar.active_ind+ 0)=1))
   JOIN (l
   WHERE l.organization_id=rar.organization_id
    AND l.active_ind=1
    AND l.icu_ind=1)
  HEAD REPORT
   count = 0
  DETAIL
   IF (l.location_cd > 0)
    count = (count+ 1), stat = alterlist(reply->location_list,count), loc_disp = uar_get_code_display
    (l.location_cd),
    reply->location_list[count].location_disp = loc_disp, reply->location_list[count].location_cd = l
    .location_cd
   ENDIF
  WITH nocounter
 ;end select
 IF (count > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#2099_read_exit
#9999_exit_program
 CALL echorecord(reply)
END GO
