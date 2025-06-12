CREATE PROGRAM aps_upd_instrument_protocols:dba
 DECLARE subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value))
  = null WITH protect
 SUBROUTINE subevent_add(op_name,op_status,obj_name,obj_value)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
 DECLARE determineexpandtotal(lactualsize=i4,lexpandsize=i4) = i4 WITH protect, noconstant(0)
 DECLARE determineexpandsize(lrecordsize=i4,lmaximumsize=i4) = i4 WITH protect, noconstant(0)
 SUBROUTINE determineexpandtotal(lactualsize,lexpandsize)
   RETURN((ceil((cnvtreal(lactualsize)/ lexpandsize)) * lexpandsize))
 END ;Subroutine
 SUBROUTINE determineexpandsize(lrecordsize,lmaximumsize)
   DECLARE lreturn = i4 WITH protect, noconstant(0)
   IF (lrecordsize <= 1)
    SET lreturn = 1
   ELSEIF (lrecordsize <= 10)
    SET lreturn = 10
   ELSEIF (lrecordsize <= 500)
    SET lreturn = 50
   ELSE
    SET lreturn = 100
   ENDIF
   IF (lmaximumsize < lreturn)
    SET lreturn = lmaximumsize
   ENDIF
   RETURN(lreturn)
 END ;Subroutine
 RECORD reply(
   1 instrument_protocol_list[*]
     2 object_key = i4
     2 instrument_protocol_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD m_dm2_seq_stat(
   1 n_status = i4
   1 s_error_msg = vc
 ) WITH protect
 RECORD unique_vals(
   1 qual[*]
     2 id = f8
 )
 DECLARE nnone_action = i2 WITH protect, constant(0)
 DECLARE nadd_action = i2 WITH protect, constant(1)
 DECLARE nupdate_action = i2 WITH protect, constant(2)
 DECLARE nnbrprotocols = i2 WITH protect, noconstant(0)
 DECLARE ccclerror = vc WITH protect, noconstant(" ")
 DECLARE ninstrumentcount = i2 WITH protect, noconstant(0)
 DECLARE nindex = i2 WITH protect, noconstant(0)
 DECLARE naddcount = i2 WITH protect, noconstant(0)
 DECLARE i_idx = i4 WITH protect, noconstant(0)
 DECLARE actualsize = i4 WITH protect, noconstant(0)
 DECLARE expandsize = i4 WITH protect, noconstant(0)
 DECLARE expandtotal = i4 WITH protect, noconstant(0)
 DECLARE expandstart = i4 WITH protect, noconstant(1)
 SET reply->status_data.status = "F"
 SET nnbrprotocols = size(request->instrument_protocol_list,5)
 IF (nnbrprotocols=0)
  CALL subevent_add(build("Set number of protocols"),"F",build("nNbrProtocols"),
   "nNbrProtocols is zero")
  GO TO exit_script
 ENDIF
 SET expandstart = 1
 SET actualsize = size(request->instrument_protocol_list,5)
 SET expandsize = determineexpandsize(actualsize,100)
 SET expandtotal = determineexpandtotal(actualsize,expandsize)
 SET stat = alterlist(request->instrument_protocol_list,expandtotal)
 FOR (i_idx = (actualsize+ 1) TO expandtotal)
   SET request->instrument_protocol_list[i_idx].action_flag = request->instrument_protocol_list[
   actualsize].action_flag
   SET request->instrument_protocol_list[i_idx].protocol_name = request->instrument_protocol_list[
   actualsize].protocol_name
   SET request->instrument_protocol_list[i_idx].instrument_type_cd = request->
   instrument_protocol_list[actualsize].instrument_type_cd
 ENDFOR
 SELECT INTO "nl:"
  locatestart = expandstart
  FROM (dummyt d  WITH seq = value((expandtotal/ expandsize))),
   instrument_protocol ip
  PLAN (d
   WHERE assign(expandstart,evaluate(d.seq,1,1,(expandstart+ expandsize))))
   JOIN (ip
   WHERE expand(i_idx,expandstart,((expandstart+ expandsize) - 1),ip.protocol_name,request->
    instrument_protocol_list[i_idx].protocol_name,
    ip.instrument_type_cd,request->instrument_protocol_list[i_idx].instrument_type_cd))
  DETAIL
   instrumentprotocollistindex = locateval(i_idx,locatestart,((locatestart+ expandsize) - 1),ip
    .protocol_name,request->instrument_protocol_list[i_idx].protocol_name,
    ip.instrument_type_cd,request->instrument_protocol_list[i_idx].instrument_type_cd)
   IF ((request->instrument_protocol_list[d.seq].action_flag=nadd_action))
    request->instrument_protocol_list[d.seq].action_flag = nupdate_action, request->
    instrument_protocol_list[d.seq].instrument_protocol_id = ip.instrument_protocol_id
   ENDIF
  WITH nocounter
 ;end select
 IF (logcclerror("SELECT","INSTRUMENT_PROTOCOL")=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(request->instrument_protocol_list,actualsize)
 SET naddcount = 0
 FOR (nindex = 1 TO nnbrprotocols)
   IF ((request->instrument_protocol_list[nindex].action_flag=nadd_action))
    SET naddcount = (naddcount+ 1)
   ENDIF
 ENDFOR
 IF (naddcount > 0)
  SET stat = alterlist(unique_vals->qual,naddcount)
  EXECUTE dm2_dar_get_bulk_seq "unique_vals->qual", naddcount, "ID",
  1, "pathnet_seq"
  IF ((m_dm2_seq_stat->n_status != 1))
   CALL subevent_add(build("Bulk seq script call"),"F",build("dm2_dar_get_bulk_seq"),m_dm2_seq_stat->
    s_error_msg)
   GO TO exit_script
  ENDIF
  SET stat = alterlist(reply->instrument_protocol_list,naddcount)
  SET ninstrumentcount = 0
  FOR (nindex = 1 TO nnbrprotocols)
    IF ((request->instrument_protocol_list[nindex].action_flag=nadd_action))
     SET ninstrumentcount = (ninstrumentcount+ 1)
     SET reply->instrument_protocol_list[ninstrumentcount].object_key = request->
     instrument_protocol_list[nindex].object_key
     SET reply->instrument_protocol_list[ninstrumentcount].instrument_protocol_id = unique_vals->
     qual[ninstrumentcount].id
     SET request->instrument_protocol_list[nindex].instrument_protocol_id = unique_vals->qual[
     ninstrumentcount].id
    ENDIF
  ENDFOR
 ENDIF
 FREE SET unique_vals
 FREE SET m_dm2_seq_stat
 IF (naddcount > 0)
  INSERT  FROM (dummyt d  WITH seq = nnbrprotocols),
    instrument_protocol ip
   SET ip.active_ind = request->instrument_protocol_list[d.seq].active_ind, ip.instrument_protocol_id
     = request->instrument_protocol_list[d.seq].instrument_protocol_id, ip.instrument_type_cd =
    request->instrument_protocol_list[d.seq].instrument_type_cd,
    ip.placer_field_1 = request->instrument_protocol_list[d.seq].placer_field_1, ip.protocol_name =
    request->instrument_protocol_list[d.seq].protocol_name, ip.suplmtl_serv_info_txt = request->
    instrument_protocol_list[d.seq].supp_service_info,
    ip.universal_service_ident = request->instrument_protocol_list[d.seq].universal_service_ident, ip
    .proc_code_txt = request->instrument_protocol_list[d.seq].procedure_code, ip.updt_id = reqinfo->
    updt_id,
    ip.updt_task = reqinfo->updt_task, ip.updt_applctx = reqinfo->updt_applctx, ip.updt_dt_tm =
    cnvtdatetime(curdate,curtime)
   PLAN (d
    WHERE (request->instrument_protocol_list[d.seq].action_flag=nadd_action))
    JOIN (ip)
   WITH nocounter
  ;end insert
  IF (logcclerror("INSERT","INSTRUMENT_PROTOCOL")=0)
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = nnbrprotocols),
   instrument_protocol ip
  PLAN (d)
   JOIN (ip
   WHERE (ip.instrument_protocol_id=request->instrument_protocol_list[d.seq].instrument_protocol_id)
    AND (nupdate_action=request->instrument_protocol_list[d.seq].action_flag))
  WITH nocounter, forupdate(ip)
 ;end select
 IF (logcclerror("LOCK","INSTRUMENT_PROTOCOL")=0)
  GO TO exit_script
 ENDIF
 IF (curqual > 0)
  UPDATE  FROM (dummyt d  WITH seq = nnbrprotocols),
    instrument_protocol ip
   SET ip.active_ind = request->instrument_protocol_list[d.seq].active_ind, ip.placer_field_1 =
    request->instrument_protocol_list[d.seq].placer_field_1, ip.protocol_name = request->
    instrument_protocol_list[d.seq].protocol_name,
    ip.suplmtl_serv_info_txt = request->instrument_protocol_list[d.seq].supp_service_info, ip
    .universal_service_ident = request->instrument_protocol_list[d.seq].universal_service_ident, ip
    .proc_code_txt = request->instrument_protocol_list[d.seq].procedure_code,
    ip.updt_cnt = (ip.updt_cnt+ 1), ip.updt_id = reqinfo->updt_id, ip.updt_task = reqinfo->updt_task,
    ip.updt_applctx = reqinfo->updt_applctx, ip.updt_dt_tm = cnvtdatetime(curdate,curtime)
   PLAN (d)
    JOIN (ip
    WHERE (ip.instrument_protocol_id=request->instrument_protocol_list[d.seq].instrument_protocol_id)
     AND (nupdate_action=request->instrument_protocol_list[d.seq].action_flag))
   WITH nocounter
  ;end update
  IF (logcclerror("UPDATE","INSTRUMENT_PROTOCOL")=0)
   GO TO exit_script
  ENDIF
 ENDIF
 IF (nnbrprotocols=0)
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
 SUBROUTINE logcclerror(soperation,stablename)
  IF (error(ccclerror,1) != 0)
   CALL subevent_add(build(soperation),"F",build(stablename),ccclerror)
   RETURN(0)
  ENDIF
  RETURN(1)
 END ;Subroutine
END GO
