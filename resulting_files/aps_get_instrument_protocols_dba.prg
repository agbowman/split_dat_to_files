CREATE PROGRAM aps_get_instrument_protocols:dba
 RECORD reply(
   1 instrument_type_list[*]
     2 instrument_type_cd = f8
     2 instrument_type_disp = c40
     2 instrument_protocol_list[*]
       3 instrument_protocol_id = f8
       3 instrument_type_cd = f8
       3 instrument_type_disp = c40
       3 protocol_name = vc
       3 universal_service_ident = vc
       3 placer_field_1 = vc
       3 supp_service_info = vc
       3 procedure_code = vc
       3 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE ninstrcount = i2 WITH protect, noconstant(0)
 DECLARE ncount = i2 WITH protect, noconstant(0)
 DECLARE nprotcount = i2 WITH protect, noconstant(0)
 DECLARE npos = i2 WITH protect, noconstant(0)
 DECLARE ncodevaluefailed = i2 WITH protect, noconstant(0)
 DECLARE nstart = i2 WITH protect, constant(1)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=2074
  DETAIL
   ninstrcount = (ninstrcount+ 1)
   IF (mod(ninstrcount,10)=1)
    stat = alterlist(reply->instrument_type_list,(ninstrcount+ 9))
   ENDIF
   reply->instrument_type_list[ninstrcount].instrument_type_cd = cv.code_value, reply->
   instrument_type_list[ninstrcount].instrument_type_disp = cv.display
  FOOT REPORT
   stat = alterlist(reply->instrument_type_list,ninstrcount)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET ncodevaluefailed = 1
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM instrument_protocol ip
  PLAN (ip
   WHERE expand(ncount,nstart,ninstrcount,ip.instrument_type_cd,reply->instrument_type_list[ncount].
    instrument_type_cd))
  ORDER BY ip.instrument_type_cd
  HEAD ip.instrument_type_cd
   nprotcount = 0, npos = locateval(ncount,nstart,ninstrcount,ip.instrument_type_cd,reply->
    instrument_type_list[ncount].instrument_type_cd)
  DETAIL
   nprotcount = (nprotcount+ 1)
   IF (nprotcount > size(reply->instrument_type_list[npos].instrument_protocol_list,5))
    stat = alterlist(reply->instrument_type_list[npos].instrument_protocol_list,(nprotcount+ 9))
   ENDIF
   reply->instrument_type_list[npos].instrument_protocol_list[nprotcount].instrument_protocol_id = ip
   .instrument_protocol_id, reply->instrument_type_list[npos].instrument_protocol_list[nprotcount].
   instrument_type_cd = ip.instrument_type_cd, reply->instrument_type_list[npos].
   instrument_protocol_list[nprotcount].protocol_name = ip.protocol_name,
   reply->instrument_type_list[npos].instrument_protocol_list[nprotcount].universal_service_ident =
   ip.universal_service_ident, reply->instrument_type_list[npos].instrument_protocol_list[nprotcount]
   .placer_field_1 = ip.placer_field_1, reply->instrument_type_list[npos].instrument_protocol_list[
   nprotcount].supp_service_info = ip.suplmtl_serv_info_txt,
   reply->instrument_type_list[npos].instrument_protocol_list[nprotcount].procedure_code = ip
   .proc_code_txt, reply->instrument_type_list[npos].instrument_protocol_list[nprotcount].active_ind
    = ip.active_ind
  FOOT  ip.instrument_type_cd
   stat = alterlist(reply->instrument_type_list[npos].instrument_protocol_list,nprotcount)
  WITH nocounter
 ;end select
#exit_script
 IF (ncodevaluefailed=1)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE"
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
