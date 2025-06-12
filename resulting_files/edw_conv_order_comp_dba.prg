CREATE PROGRAM edw_conv_order_comp:dba
 DECLARE iord_ct = i4 WITH protect, noconstant(0)
 DECLARE time_zone = i4 WITH protect, noconstant(0)
 DECLARE iparent_cnt = i4 WITH protect, noconstant(0)
 DECLARE iparentencntr_cnt = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE scripterror_ind = i2 WITH protect, noconstant(0)
 SET parser_line = build("BUILD(",value(encounter_nk),")")
 DECLARE iexist = i2 WITH protect, constant(checkdic("ORDER_COMPLIANCE.ENCNTR_COMPLIANCE_STATUS_FLAG",
   "A",0))
 DECLARE temp_indx = i4 WITH noconstant(0)
 DECLARE keys_start = i4 WITH noconstant(0)
 DECLARE keys_end = i4 WITH noconstant(0)
 DECLARE keys_batch = i4 WITH constant(medium_batch_size)
 DECLARE in_buffer = vc WITH public, noconstant("")
 DECLARE in_buffer_len = i4 WITH public, noconstant(0)
 DECLARE out_buffer = c1000 WITH public, noconstant("")
 DECLARE out_buffer_len = i4 WITH public, noconstant(1000)
 DECLARE ret_buffer_len = i4 WITH public, noconstant(0)
 DECLARE lt_flag = i4 WITH protect, noconstant(0)
 DECLARE new_list_size = i4 WITH noconstant(0)
 DECLARE cur_list_size = i4 WITH noconstant(0)
 DECLARE batch_size = i4 WITH constant(60)
 DECLARE nstart = i4 WITH protect, noconstant(0)
 DECLARE loop_cnt = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 RECORD tmptext(
   1 qual[*]
     2 text = vc
 )
 DECLARE format = i2
 DECLARE line_len = i2
 DECLARE outbuffer = c32000
 DECLARE rtftext = c32000
 DECLARE nortftext = c32000
 SET format = 0
 SET line_len = 0
 SUBROUTINE rtf_to_text_context(rtftext,format,line_len,context)
   SET all_len = 0
   SET start = 0
   SET len = 0
   SET pos = 0
   SET linecnt = 0
   SET inbuffer = fillstring(32000," ")
   SET outbufferlen = 0
   SET bfl = 0
   SET bfl2 = 1
   SET outbuffer = fillstring(32000," ")
   SET nortftext = fillstring(32000," ")
   IF (substring(1,5,rtftext)=asis("{\rtf"))
    SET inbuffer = trim(rtftext)
    CALL uar_rtf2(inbuffer,size(inbuffer),outbuffer,size(outbuffer),outbufferlen,
     context)
   ELSE
    SET outbuffer = trim(rtftext)
   ENDIF
   SET nortftext = trim(outbuffer)
   SET stat = alterlist(tmptext->qual,0)
   SET crchar = concat(char(13),char(10))
   SET lfchar = char(10)
   SET ffchar = char(12)
   IF (format > 0)
    SET all_len = cnvtint(size(trim(outbuffer)))
    SET tot_len = 0
    SET start = 1
    SET bigfirst = "Y"
    SET crstart = start
    WHILE (all_len > tot_len)
      SET crpos = crstart
      SET crfirst = "Y"
      SET loaded = "N"
      WHILE ((crpos <= ((crstart+ line_len)+ 1))
       AND loaded="N"
       AND all_len > tot_len)
       IF ((crpos=((crstart+ line_len)+ 1))
        AND crfirst="N")
        SET start = crstart
        SET first = "Y"
        SET pos = ((start+ line_len) - 1)
        IF (bigfirst="Y"
         AND pos >= all_len)
         SET pos = start
        ENDIF
        SET bigfirst = "N"
        WHILE (pos >= start
         AND all_len > tot_len)
          IF (pos=start)
           SET pos = ((start+ line_len) - 1)
           SET linecnt = (linecnt+ 1)
           SET stat = alterlist(tmptext->qual,linecnt)
           SET len = ((pos - start)+ 1)
           SET tmptext->qual[linecnt].text = substring(start,len,outbuffer)
           SET start = (pos+ 1)
           SET crstart = (pos+ 1)
           SET pos = 0
           SET tot_len = ((tot_len+ len) - 1)
           SET loaded = "Y"
          ELSE
           IF (substring(pos,1,outbuffer)=" ")
            SET len = (pos - start)
            IF (cnvtint(size(trim(substring(start,len,outbuffer)))) > 0)
             SET linecnt = (linecnt+ 1)
             SET stat = alterlist(tmptext->qual,linecnt)
             SET tmptext->qual[linecnt].text = substring(start,len,outbuffer)
             SET loaded = "Y"
            ENDIF
            SET start = (pos+ 1)
            SET crstart = (pos+ 1)
            SET pos = 0
            SET tot_len = (tot_len+ len)
           ELSE
            IF (first="Y")
             SET first = "N"
             SET tot_len = (tot_len+ 1)
            ENDIF
            SET pos = (pos - 1)
           ENDIF
          ENDIF
        ENDWHILE
       ELSE
        SET crfirst = "N"
        IF (((substring(crpos,1,outbuffer)=crchar) OR (((substring(crpos,1,outbuffer)=lfchar) OR (
        substring(crpos,1,outbuffer)=ffchar)) )) )
         SET crlen = (crpos - crstart)
         SET linecnt = (linecnt+ 1)
         SET stat = alterlist(tmptext->qual,linecnt)
         SET tmptext->qual[linecnt].text = substring(crstart,crlen,outbuffer)
         SET loaded = "Y"
         IF (substring(crpos,1,outbuffer)=crchar)
          SET crstart = (crpos+ textlen(crchar))
         ELSEIF (substring(crpos,1,outbuffer)=lfchar)
          SET crstart = (crpos+ textlen(lfchar))
         ELSEIF (substring(crpos,1,outbuffer)=ffchar)
          SET crstart = (crpos+ textlen(ffchar))
         ENDIF
         SET tot_len = (tot_len+ crlen)
        ENDIF
       ENDIF
       SET crpos = (crpos+ 1)
      ENDWHILE
    ENDWHILE
   ENDIF
   SET rtftext = fillstring(32000," ")
   SET inbuffer = fillstring(32000," ")
 END ;Subroutine
 DECLARE outbufmaxsiz = i2
 DECLARE tblobin = c32000
 DECLARE tblobout = c32000
 DECLARE blobin = c32000
 DECLARE blobout = c32000
 SUBROUTINE decompress_text(tblobin)
   SET tblobout = fillstring(32000," ")
   SET blobout = fillstring(32000," ")
   SET outbufmaxsiz = 0
   SET blobin = trim(tblobin)
   CALL uar_ocf_uncompress(blobin,size(blobin),blobout,size(blobout),outbufmaxsiz)
   SET tblobout = blobout
   SET tblobin = fillstring(32000," ")
   SET blobin = fillstring(32000," ")
 END ;Subroutine
 SUBROUTINE rtf_to_text(rtftext,format,line_len)
   CALL rtf_to_text_context(rtftext,format,line_len,0)
 END ;Subroutine
 SELECT DISTINCT INTO "nl:"
  oc_id = oc.order_compliance_id, oc_detail_id = ocd.order_compliance_detail_id
  FROM order_compliance oc,
   order_compliance_detail ocd
  PLAN (oc)
   JOIN (ocd
   WHERE ocd.order_compliance_id=outerjoin(oc.order_compliance_id)
    AND ((ocd.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm)) OR (oc
   .updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm)))
    AND ((oc.order_compliance_id+ 0) > 0)
    AND nullind(ocd.order_compliance_detail_id)=1)
  DETAIL
   iord_ct = (iord_ct+ 1)
   IF (mod(iord_ct,100)=1)
    ifieldstat = alterlist(ord_comp_keys->qual,(iord_ct+ 99))
   ENDIF
   ord_comp_keys->qual[iord_ct].order_comp_detail_id = ocd.order_compliance_detail_id, ord_comp_keys
   ->qual[iord_ct].order_comp_id = oc.order_compliance_id
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  oc_detail_id = ocd.order_compliance_detail_id, oc_id = oc.order_compliance_id, loc_facility_cd =
  encounter.loc_facility_cd,
  encntr_id = encounter.encntr_id, enc_nk = parser(parser_line)
  FROM (dummyt d  WITH seq = value(iord_ct)),
   order_compliance_detail ocd,
   order_compliance oc,
   encounter encounter
  PLAN (d
   WHERE iord_ct > 0
    AND (ord_comp_keys->qual[d.seq].order_comp_id > 0))
   JOIN (oc
   WHERE (oc.order_compliance_id=ord_comp_keys->qual[d.seq].order_comp_id))
   JOIN (ocd
   WHERE outerjoin(oc.order_compliance_id)=ocd.order_compliance_id)
   JOIN (encounter
   WHERE encounter.encntr_id=oc.encntr_id
    AND parser(inst_filter)
    AND parser(org_filter))
  ORDER BY oc.encntr_id, ocd.order_nbr, oc.order_compliance_id,
   ocd.order_compliance_detail_id
  HEAD REPORT
   cnt = 0
  HEAD oc.encntr_id
   IF (oc.encntr_id > 0)
    iparentencntr_cnt = (iparentencntr_cnt+ 1)
    IF (mod(iparentencntr_cnt,100)=1)
     ifieldstat = alterlist(ord_comp_encntr_parents->qual,(iparentencntr_cnt+ 99))
    ENDIF
    ord_comp_encntr_parents->qual[iparentencntr_cnt].encntr_id = oc.encntr_id
   ENDIF
  HEAD ocd.order_nbr
   IF (ocd.order_nbr > 0)
    iparent_cnt = (iparent_cnt+ 1)
    IF (mod(iparent_cnt,100)=1)
     ifieldstat = alterlist(ord_comp_order_parents->qual,(iparent_cnt+ 99))
    ENDIF
    ord_comp_order_parents->qual[iparent_cnt].order_id = ocd.order_nbr
   ENDIF
  DETAIL
   cnt = (cnt+ 1), ord_comp_keys->qual[cnt].order_comp_detail_id = oc_detail_id, ord_comp_keys->qual[
   cnt].order_comp_id = oc_id,
   ord_comp_keys->qual[cnt].loc_facility_cd = loc_facility_cd, ord_comp_keys->qual[cnt].encntr_id =
   encntr_id, ord_comp_keys->qual[cnt].encntr_nk = enc_nk
  FOOT REPORT
   iord_ct = cnt, ifieldstat = alterlist(ord_comp_keys->qual,iord_ct)
  WITH nocounter
 ;end select
 IF (iord_ct <= 0)
  SET ifieldstat = alterlist(ord_comp_keys->qual,iord_ct)
  GO TO exit_script
 ENDIF
 SET keys_start = 1
 SET keys_end = minval(((keys_start+ keys_batch) - 1),iord_ct)
 CALL echo(build("keys_end:",keys_end))
 WHILE (keys_start <= keys_end)
   SET ifieldstat = alterlist(edw_order_comp->qual,keys_batch)
   IF (debug="Y")
    CALL echo(concat("Looping from keys_start = ",build(keys_start)," to keys_end = ",build(keys_end)
      ))
   ENDIF
   SET temp_indx = 0
   FOR (i = keys_start TO keys_end)
     SET temp_indx = (temp_indx+ 1)
     SET edw_order_comp->qual[temp_indx].order_comp_detail_id = ord_comp_keys->qual[i].
     order_comp_detail_id
     SET edw_order_comp->qual[temp_indx].order_comp_id = ord_comp_keys->qual[i].order_comp_id
     SET edw_order_comp->qual[temp_indx].loc_facility_cd = ord_comp_keys->qual[i].loc_facility_cd
     SET edw_order_comp->qual[temp_indx].encntr_id = ord_comp_keys->qual[i].encntr_id
     SET edw_order_comp->qual[temp_indx].encntr_nk = ord_comp_keys->qual[i].encntr_nk
   ENDFOR
   IF (temp_indx < keys_batch)
    SET cur_list_size = temp_indx
   ELSE
    SET cur_list_size = keys_batch
   ENDIF
   SELECT
    IF (iexist=2)
     n_encntr_comp_status_flag = nullind(oc.encntr_compliance_status_flag), status_flag = oc
     .encntr_compliance_status_flag, n_no_known_home_meds_ind = nullind(oc.no_known_home_meds_ind),
     n_unable_to_obtain_ind = nullind(oc.unable_to_obtain_ind), n_order_comp_detail_id = nullind(ocd
      .order_compliance_detail_id)
    ELSE
     n_encntr_comp_status_flag = 1, status_flag = 0, n_no_known_home_meds_ind = nullind(oc
      .no_known_home_meds_ind),
     n_unable_to_obtain_ind = nullind(oc.unable_to_obtain_ind), n_order_comp_detail_id = nullind(ocd
      .order_compliance_detail_id)
    ENDIF
    FROM (dummyt d  WITH seq = value(cur_list_size)),
     order_compliance_detail ocd,
     order_compliance oc
    PLAN (d
     WHERE cur_list_size > 0)
     JOIN (ocd
     WHERE ocd.order_compliance_detail_id=outerjoin(edw_order_comp->qual[d.seq].order_comp_detail_id)
     )
     JOIN (oc
     WHERE (oc.order_compliance_id=edw_order_comp->qual[d.seq].order_comp_id))
    DETAIL
     edw_order_comp->qual[d.seq].performed_prsnl_id = oc.performed_prsnl_id, edw_order_comp->qual[d
     .seq].performed_dt_tm = oc.performed_dt_tm, edw_order_comp->qual[d.seq].
     encntr_compliance_status_flag = nullcheck(build(status_flag)," ",n_encntr_comp_status_flag),
     edw_order_comp->qual[d.seq].no_known_home_meds_ind = nullcheck(build(oc.no_known_home_meds_ind),
      " ",n_no_known_home_meds_ind), edw_order_comp->qual[d.seq].unable_to_obtain_ind = nullcheck(
      build(oc.unable_to_obtain_ind)," ",n_unable_to_obtain_ind), edw_order_comp->qual[d.seq].updt_id
      = oc.updt_id
     IF ((edw_order_comp->qual[d.seq].order_comp_detail_id=0))
      edw_order_comp->qual[d.seq].order_comp_detail_id = - (1)
     ELSE
      edw_order_comp->qual[d.seq].order_nbr = ocd.order_nbr, edw_order_comp->qual[d.seq].
      compliance_capture_dt_tm = validate(ocd.compliance_capture_dt_tm,0), edw_order_comp->qual[d.seq
      ].last_occured_dt_tm = validate(ocd.last_occurred_dt_tm,0),
      edw_order_comp->qual[d.seq].updt_dt_tm = validate(ocd.updt_dt_tm,0), edw_order_comp->qual[d.seq
      ].compliance_status_cd = ocd.compliance_status_cd, edw_order_comp->qual[d.seq].
      information_source_cd = ocd.information_source_cd,
      edw_order_comp->qual[d.seq].long_text_id = ocd.long_text_id
     ENDIF
    WITH nocounter
   ;end select
   SET nstart = 1
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(cur_list_size)),
     long_text lt
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
     JOIN (lt
     WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),lt.long_text_id,edw_order_comp->qual[d.seq].
      long_text_id)
      AND lt.long_text_id > 0)
    DETAIL
     index = locateval(num,1,cur_list_size,lt.long_text_id,edw_order_comp->qual[d.seq].long_text_id)
     WHILE (index != 0)
       CALL rtf_to_text(trim(lt.long_text),0,0), edw_order_comp->qual[d.seq].long_text = substring(1,
        255,nortftext), index = locateval(num,(index+ 1),cur_list_size,lt.long_text_id,edw_order_comp
        ->qual[d.seq].long_text_id)
     ENDWHILE
    WITH nocounter
   ;end select
   FOR (i = 1 TO cur_list_size)
     SET timezone = gettimezone(edw_order_comp->qual[i].loc_facility_cd,edw_order_comp->qual[i].
      encntr_id)
     SET edw_order_comp->qual[i].performed_tm_zn = evaluate(edw_order_comp->qual[i].performed_tm_zn,0,
      cnvtint(timezone),edw_order_comp->qual[i].performed_tm_zn)
     SET edw_order_comp->qual[i].compliance_capture_tm_zn = evaluate(edw_order_comp->qual[i].
      compliance_capture_tm_zn,0,cnvtint(timezone),edw_order_comp->qual[i].compliance_capture_tm_zn)
     SET edw_order_comp->qual[i].last_occured_tm_zn = evaluate(edw_order_comp->qual[i].
      last_occured_tm_zn,0,cnvtint(timezone),edw_order_comp->qual[i].last_occured_tm_zn)
     SET edw_order_comp->qual[i].updt_tm_zn = evaluate(edw_order_comp->qual[i].updt_tm_zn,0,cnvtint(
       timezone),edw_order_comp->qual[i].updt_tm_zn)
   ENDFOR
   IF (error(err_msg,1) != 0)
    SET scripterror_ind = 1
   ENDIF
   EXECUTE edw_create_order_comp
   SET ifieldstat = alterlist(edw_order_comp->qual,0)
   SET keys_start = (keys_end+ 1)
   SET keys_end = minval(((keys_start+ keys_batch) - 1),iord_ct)
 ENDWHILE
#exit_script
 IF (iord_ct <= 0)
  SELECT INTO value(ord_comp_extractfile)
   FROM dummyt d
   WHERE iord_ct > 0
   WITH noheading, nocounter, format = lfstream,
    maxcol = 1999, maxrow = 1
  ;end select
 ENDIF
 FREE RECORD order_comp_keys
 FREE RECORD edw_order_comp
 CALL edwupdatescriptstatus("ORD_COMP",iord_ct,"0","0")
 CALL echo(build("ORD_COMP Count = ",iord_ct))
 IF (error(err_msg,1) != 0)
  SET scripterror_ind = 1
 ENDIF
 SET error_ind = scripterror_ind
 SET script_version = "000 07/22/11 RP019504"
END GO
