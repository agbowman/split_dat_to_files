CREATE PROGRAM bb_get_printer_info:dba
 RECORD reply(
   1 facilityprinterreltnlist[*]
     2 bb_facility_printer_r_id = f8
     2 bb_printer_id = f8
     2 organization_id = f8
     2 location_cd = f8
   1 printerlist[*]
     2 baud_rate_nbr = i4
     2 bb_printer_id = f8
     2 crc_ind = i2
     2 horizontal_offset_nbr = f8
     2 printer_addr = vc
     2 label_type_cd = f8
     2 model_cd = f8
     2 port_addr = vc
     2 printer_description_txt = vc
     2 printer_name = vc
     2 vertical_offset_nbr = f8
   1 serverlist[*]
     2 bb_print_server_id = f8
     2 ip_addr = vc
     2 port_addr = vc
     2 redun_parent_server_id = f8
     2 server_description_txt = vc
     2 server_name = vc
   1 serverprinterreltn[*]
     2 bb_print_server_id = f8
     2 bb_printer_id = f8
     2 bb_server_printer_r_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE lfacilitycount = i4 WITH protect, noconstant(0)
 DECLARE lprintercount = i4 WITH protect, noconstant(0)
 DECLARE lservercount = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
 DECLARE script_name = c19 WITH constant("bb_get_printer_info")
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE dloctypefac = f8 WITH protect, noconstant(0.0)
 SET modify = predeclare
 SET stat = uar_get_meaning_by_codeset(222,"FACILITY",1,dloctypefac)
 IF (stat=1)
  CALL errorhandler("F","uar call for facility",errmsg)
 ENDIF
 SET reply->status_data.status = "F"
 SELECT
  IF ((request->facility_cd > 0))
   PLAN (l
    WHERE (l.location_cd=request->facility_cd)
     AND l.active_ind=1)
    JOIN (fpr
    WHERE fpr.active_ind=1
     AND fpr.bb_organization_id=l.organization_id)
  ELSEIF (size(request->facilitylist,5) > 0)
   PLAN (fpr
    WHERE expand(lidx,1,size(request->facilitylist,5),fpr.bb_organization_id,request->facilitylist[
     lidx].organization_id)
     AND fpr.active_ind=1)
    JOIN (l
    WHERE l.organization_id=fpr.bb_organization_id
     AND l.location_type_cd=dloctypefac
     AND l.active_ind=1)
  ELSE
   PLAN (fpr
    WHERE fpr.active_ind=1)
    JOIN (l
    WHERE l.organization_id=fpr.bb_organization_id
     AND l.location_type_cd=dloctypefac
     AND l.active_ind=1)
  ENDIF
  INTO "nl:"
  fpr.*, l.*
  FROM bb_facility_printer_r fpr,
   location l
  ORDER BY fpr.bb_organization_id
  HEAD REPORT
   lfacilitycount = 0
  DETAIL
   IF (fpr.bb_facility_printer_r_id > 0.0)
    lfacilitycount += 1
    IF (mod(lfacilitycount,10)=1)
     stat = alterlist(reply->facilityprinterreltnlist,(lfacilitycount+ 9))
    ENDIF
   ENDIF
   reply->facilityprinterreltnlist[lfacilitycount].bb_facility_printer_r_id = fpr
   .bb_facility_printer_r_id, reply->facilityprinterreltnlist[lfacilitycount].bb_printer_id = fpr
   .bb_printer_id, reply->facilityprinterreltnlist[lfacilitycount].organization_id = fpr
   .bb_organization_id,
   reply->facilityprinterreltnlist[lfacilitycount].location_cd = l.location_cd
  FOOT REPORT
   stat = alterlist(reply->facilityprinterreltnlist,lfacilitycount)
  WITH nocounter
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("F","bb_facility_printer_r",errmsg)
 ENDIF
 SELECT
  IF (size(request->facilitylist,5) > 0)
   PLAN (p
    WHERE expand(lidx,1,size(reply->facilityprinterreltnlist,5),p.bb_printer_id,reply->
     facilityprinterreltnlist[lidx].bb_printer_id)
     AND p.active_ind=1)
  ELSE
   PLAN (p
    WHERE p.active_ind=1)
  ENDIF
  INTO "nl:"
  p.*
  FROM bb_printer p
  ORDER BY p.bb_printer_id
  HEAD REPORT
   lprintercount = 0
  HEAD p.bb_printer_id
   IF (p.bb_printer_id > 0.0)
    lprintercount += 1
    IF (mod(lprintercount,10)=1)
     stat = alterlist(reply->printerlist,(lprintercount+ 9))
    ENDIF
   ENDIF
  DETAIL
   reply->printerlist[lprintercount].baud_rate_nbr = p.baud_rate_nbr, reply->printerlist[
   lprintercount].bb_printer_id = p.bb_printer_id, reply->printerlist[lprintercount].crc_ind = p
   .crc_ind,
   reply->printerlist[lprintercount].horizontal_offset_nbr = p.horizontal_offset_nbr, reply->
   printerlist[lprintercount].printer_addr = p.printer_addr, reply->printerlist[lprintercount].
   label_type_cd = p.label_type_cd,
   reply->printerlist[lprintercount].model_cd = p.model_cd, reply->printerlist[lprintercount].
   port_addr = p.port_addr, reply->printerlist[lprintercount].printer_description_txt = p
   .printer_description_txt,
   reply->printerlist[lprintercount].printer_name = p.printer_name, reply->printerlist[lprintercount]
   .vertical_offset_nbr = p.vertical_offset_nbr
  FOOT  p.bb_printer_id
   row + 0
  FOOT REPORT
   stat = alterlist(reply->printerlist,lprintercount)
  WITH nocounter
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("F","bb_printer",errmsg)
 ENDIF
 SELECT
  IF (size(request->facilitylist,5) > 0)
   PLAN (spr
    WHERE expand(lidx,1,size(reply->facilityprinterreltnlist,5),spr.bb_printer_id,reply->
     facilityprinterreltnlist[lidx].bb_printer_id)
     AND spr.active_ind=1)
  ELSE
   PLAN (spr
    WHERE spr.active_ind=1)
  ENDIF
  INTO "nl:"
  spr.*
  FROM bb_server_printer_r spr
  ORDER BY spr.bb_print_server_id
  HEAD REPORT
   lservprintercount = 0
  DETAIL
   IF (spr.bb_server_printer_r_id > 0.0)
    lservprintercount += 1
    IF (mod(lservprintercount,10)=1)
     stat = alterlist(reply->serverprinterreltn,(lservprintercount+ 9))
    ENDIF
   ENDIF
   reply->serverprinterreltn[lservprintercount].bb_print_server_id = spr.bb_print_server_id, reply->
   serverprinterreltn[lservprintercount].bb_printer_id = spr.bb_printer_id, reply->
   serverprinterreltn[lservprintercount].bb_server_printer_r_id = spr.bb_server_printer_r_id
  FOOT REPORT
   stat = alterlist(reply->serverprinterreltn,lservprintercount)
  WITH nocounter
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("F","bb_print_server_r",errmsg)
 ENDIF
 SELECT
  IF (size(request->facilitylist,5) > 0)
   PLAN (ps
    WHERE expand(lidx,1,size(reply->serverprinterreltn,5),ps.bb_print_server_id,reply->
     serverprinterreltn[lidx].bb_print_server_id)
     AND ps.active_ind=1)
  ELSE
   PLAN (ps
    WHERE ps.active_ind=1)
  ENDIF
  INTO "nl:"
  ps.*
  FROM bb_print_server ps
  ORDER BY ps.bb_print_server_id
  HEAD REPORT
   lservercount = 0
  DETAIL
   IF (ps.bb_print_server_id > 0.0)
    lservercount += 1
    IF (mod(lservercount,10)=1)
     stat = alterlist(reply->serverlist,(lservercount+ 9))
    ENDIF
   ENDIF
   reply->serverlist[lservercount].bb_print_server_id = ps.bb_print_server_id, reply->serverlist[
   lservercount].ip_addr = ps.ip_addr, reply->serverlist[lservercount].port_addr = ps.port_addr,
   reply->serverlist[lservercount].redun_parent_server_id = ps.redun_parent_server_id, reply->
   serverlist[lservercount].server_description_txt = ps.server_description_txt, reply->serverlist[
   lservercount].server_name = ps.server_name
  FOOT REPORT
   stat = alterlist(reply->serverlist,lservercount)
  WITH nocounter
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("F","bb_print_server",errmsg)
 ENDIF
 SUBROUTINE (errorhandler(operationstatus=c1,targetobjectname=vc,targetobjectvalue=vc) =null)
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(reply->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (reply->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt += 1
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[error_cnt].operationname = script_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = targetobjectvalue
   GO TO exit_script
 END ;Subroutine
#set_status
 SET reply->status_data.status = "S"
#exit_script
 SET modify = nopredeclare
END GO
