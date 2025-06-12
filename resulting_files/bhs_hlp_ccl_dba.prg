CREATE PROGRAM bhs_hlp_ccl:dba
 IF (validate(ul_exists)=0)
  DECLARE ul_exists = i2 WITH persistscript, constant(1)
  RECORD u_bhs_hlp_ccl(
    1 log[*]
      2 f_log_id = f8
      2 f_det_seq = i4
      2 s_curprog = vc
      2 f_session_id = f8
      2 s_object_type = vc
  ) WITH persistscript
  IF (validate(u_bhs_hlp_ccl_reply)=0)
   RECORD u_bhs_hlp_ccl_reply(
     1 status[1]
       2 s_detail = vc
       2 n_status = c1
   ) WITH persistscript
  ENDIF
 ENDIF
 SUBROUTINE (bhs_sbr_log(s_log_type=vc,s_params=vc,l_detail_group=i4,s_parent_entity_name=vc,
  f_parent_entity_id=f8,s_desc=vc,s_msg=vc,s_status=vc) =i2 WITH persistscript)
   DECLARE pl_currec = i4 WITH protect, noconstant(0.0)
   DECLARE pl_cnt = i4 WITH private, noconstant(0)
   DECLARE pl_size = i4 WITH private, noconstant(0)
   IF (size(u_bhs_hlp_ccl->log,5)=0)
    SET stat = alterlist(u_bhs_hlp_ccl->log,1)
    SET u_bhs_hlp_ccl->log[1].s_curprog = trim(cnvtupper(curprog))
    SET pl_currec = 1
   ELSE
    SET pl_size = size(u_bhs_hlp_ccl->log,5)
    IF (locateval(pl_cnt,1,pl_size,trim(cnvtupper(curprog)),u_bhs_hlp_ccl->log[pl_cnt].s_curprog) > 0
    )
     SET pl_currec = locateval(pl_cnt,1,pl_size,trim(cnvtupper(curprog)),u_bhs_hlp_ccl->log[pl_cnt].
      s_curprog)
    ELSE
     SET pl_size += 1
     SET stat = alterlist(u_bhs_hlp_ccl->log,pl_size)
     SET u_bhs_hlp_ccl->log[pl_size].s_curprog = trim(cnvtupper(curprog))
     SET pl_currec = pl_size
    ENDIF
   ENDIF
   IF ((((u_bhs_hlp_ccl->log[pl_currec].f_log_id=0)) OR (s_log_type="start")) )
    SELECT INTO "nl:"
     FROM v$mystat v
     HEAD REPORT
      u_bhs_hlp_ccl->log[pl_currec].f_session_id = v.sid
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM dprotect d
     PLAN (d
      WHERE (d.object_name=u_bhs_hlp_ccl->log[pl_currec].s_curprog))
     HEAD REPORT
      u_bhs_hlp_ccl->log[pl_currec].s_object_type = d.object
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     pf_seq = seq(bhs_log_seq,nextval)
     FROM code_value cv
     WHERE cv.code_value >= 0
     DETAIL
      u_bhs_hlp_ccl->log[pl_currec].f_log_id = pf_seq
     WITH maxqual(cv,1)
    ;end select
    INSERT  FROM bhs_log b
     SET b.bhs_log_id = u_bhs_hlp_ccl->log[pl_currec].f_log_id, b.description = "Start Script", b.msg
       = s_msg,
      b.object_name = u_bhs_hlp_ccl->log[pl_currec].s_curprog, b.object_type = u_bhs_hlp_ccl->log[
      pl_currec].s_object_type, b.parameters = s_params,
      b.session_id = u_bhs_hlp_ccl->log[pl_currec].f_session_id, b.start_dt_tm = sysdate, b.status =
      s_status,
      b.updt_dt_tm = sysdate, b.updt_id = reqinfo->updt_id
     WITH nocounter
    ;end insert
    COMMIT
   ELSEIF (s_log_type="stop")
    UPDATE  FROM bhs_log b
     SET b.stop_dt_tm = sysdate, b.updt_dt_tm = sysdate, b.status = s_status,
      b.msg = s_msg
     WHERE (b.bhs_log_id=u_bhs_hlp_ccl->log[pl_currec].f_log_id)
     WITH nocounter
    ;end update
    COMMIT
   ELSE
    SET u_bhs_hlp_ccl->log[pl_currec].f_det_seq += 1
    INSERT  FROM bhs_log_detail b
     SET b.bhs_log_detail_id = seq(bhs_log_seq,nextval), b.bhs_log_id = u_bhs_hlp_ccl->log[pl_currec]
      .f_log_id, b.description = s_desc,
      b.msg = s_msg, b.detail_group = l_detail_group, b.detail_seq = u_bhs_hlp_ccl->log[pl_currec].
      f_det_seq,
      b.log_type = s_log_type, b.parent_entity_id = f_parent_entity_id, b.parent_entity_name =
      s_parent_entity_name,
      b.updt_dt_tm = sysdate, b.updt_id = reqinfo->updt_id, b.status = s_status
     WITH nocounter
    ;end insert
    COMMIT
   ENDIF
 END ;Subroutine
 SUBROUTINE (bhs_sbr_get_dm_info_dt(s_info_domain=vc,s_info_name=vc) =vc WITH persistscript)
   DECLARE ms_tmp_dt_tm = vc WITH protect, noconstant(" ")
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain=s_info_domain
     AND d.info_name=s_info_name
    DETAIL
     ms_tmp_dt_tm = trim(format(d.info_date,"dd-mmm-yyyy hh:mm:ss;;d"))
    WITH nocounter
   ;end select
   RETURN(ms_tmp_dt_tm)
 END ;Subroutine
 SUBROUTINE (bhs_sbr_upd_dm_info_dt(s_info_domain=vc,s_info_name=vc,s_info_date=vc) =i2 WITH
  persistscript)
   UPDATE  FROM dm_info d
    SET d.info_date = cnvtdatetime(s_info_date), d.updt_dt_tm = sysdate, d.updt_id = reqinfo->updt_id
    WHERE d.info_domain=s_info_domain
     AND d.info_name=s_info_name
    WITH nocounter
   ;end update
   COMMIT
   IF (curqual > 0)
    CALL echo("dm_info row updated")
    RETURN(1)
   ELSE
    CALL echo("dm_info update failed")
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bhs_sbr_put_camm_obj(f_person_id=f8,f_encntr_id=f8,s_file_name=vc,s_file_disp=vc,
  s_content_type=vc,s_media_type=vc) =i2 WITH persistscript)
   DECLARE pc_status = c1 WITH private, noconstant("F")
   DECLARE ps_detail = vc WITH private, noconstant(" ")
   IF (textlen(trim(s_file_name))=0)
    SET ps_detail = "Filename is required"
   ENDIF
   IF (textlen(trim(s_content_type))=0)
    SET ps_detail = "Content type is required"
   ENDIF
   IF (textlen(trim(s_media_type))=0)
    SET ps_detail = "Media type is required"
   ENDIF
   IF (textlen(trim(s_file_disp))=0)
    SET ps_detail = "Name is required"
   ENDIF
   IF (f_person_id=0.0)
    SET ps_detail = "Person ID is required"
   ENDIF
   IF (textlen(ps_detail)=0)
    FREE RECORD u_bhs_camm_reply
    RECORD u_bhs_camm_reply(
      1 identifier = vc
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    ) WITH persist
    FREE RECORD u_bhs_camm_request
    RECORD u_bhs_camm_request(
      1 filename = vc
      1 contenttype = vc
      1 mediatype = vc
      1 name = vc
      1 personid = f8
      1 encounterid = f8
    ) WITH protect
    SET u_bhs_camm_request->filename = s_file_name
    SET u_bhs_camm_request->contenttype = s_content_type
    SET u_bhs_camm_request->mediatype = s_media_type
    SET u_bhs_camm_request->name = s_file_disp
    SET u_bhs_camm_request->personid = f_person_id
    SET u_bhs_camm_request->encounterid = f_encntr_id
    EXECUTE bhs_mmf_store_object_with_xref  WITH replace(request,u_bhs_camm_request), replace(reply,
     u_bhs_camm_reply)
    SET pc_status = u_bhs_camm_reply->status_data.status
    IF (pc_status != "S")
     SET ps_detail = u_bhs_camm_reply->status_data.subeventstatus[1].operationname
    ENDIF
   ENDIF
   SET u_bhs_hlp_ccl_reply->status[1].n_status = pc_status
   SET u_bhs_hlp_ccl_reply->status[1].s_detail = ps_detail
 END ;Subroutine
 SUBROUTINE (bhs_sbr_get_blob(f_event_id=f8,n_rm_rtf_ind=i2) =vc WITH persistscript)
   DECLARE mf_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",120,"OCFCOMP"))
   DECLARE ms_comp_blob = vc WITH protect, noconstant(" ")
   DECLARE ms_uncomp_blob = vc WITH protect, noconstant(" ")
   DECLARE ms_return_blob = vc WITH protect, noconstant(" ")
   DECLARE mc_outbuf = c32768 WITH protect, noconstant(" ")
   DECLARE ml_retlen = i4 WITH protect, noconstant(0)
   DECLARE ml_offset = i4 WITH protect, noconstant(0)
   DECLARE ml_newsize = i4 WITH protect, noconstant(0)
   DECLARE ml_finlen = i4 WITH protect, noconstant(0)
   DECLARE ml_ocf_pos = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM ce_blob cb
    WHERE cb.event_id=f_event_id
     AND cb.valid_from_dt_tm < cnvtdatetime(sysdate)
     AND cb.valid_until_dt_tm > cnvtdatetime(sysdate)
    ORDER BY cb.event_id, cb.blob_seq_num
    HEAD REPORT
     pl_len_loop = 0, pl_pos = 0, pl_beg = 0,
     pl_end = 0, pl_cnt = 0, pl_loop1 = 0,
     pl_loop2 = 0, pl_opos = 0, pl_cpos = 0
    HEAD cb.event_id
     FOR (pl_len_loop = 1 TO (cb.blob_length/ 32768))
       ms_uncomp_blob = notrim(concat(notrim(ms_uncomp_blob),notrim(fillstring(32768," "))))
     ENDFOR
     ml_finlen = mod(cb.blob_length,32768), ms_uncomp_blob = notrim(concat(notrim(ms_uncomp_blob),
       notrim(substring(1,ml_finlen,fillstring(32768," "))))), ms_return_blob = " "
    DETAIL
     ml_retlen = 1, ml_offset = 0
     WHILE (ml_retlen > 0)
       ml_retlen = blobget(mc_outbuf,ml_offset,cb.blob_contents), ml_offset += ml_retlen
       IF (ml_retlen != 0)
        ml_ocf_pos = (findstring("ocf_blob",mc_outbuf,1) - 1)
        IF (ml_ocf_pos < 1)
         ml_ocf_pos = ml_retlen
        ENDIF
        ms_comp_blob = notrim(concat(notrim(ms_comp_blob),notrim(substring(1,ml_ocf_pos,mc_outbuf))))
       ENDIF
     ENDWHILE
    FOOT  cb.event_id
     IF (cb.compression_cd=mf_comp_cd)
      ml_newsize = 0, ms_comp_blob = concat(notrim(ms_comp_blob),"ocf_blob"),
      CALL uar_ocf_uncompress(ms_comp_blob,size(ms_comp_blob),ms_uncomp_blob,size(ms_uncomp_blob),
      ml_newsize)
     ELSE
      ms_uncomp_blob = ms_comp_blob
      IF (findstring("ocf_blob",ms_uncomp_blob) > 0)
       ms_uncomp_blob = replace(ms_uncomp_blob,"ocf_blob","",0)
      ENDIF
     ENDIF
     IF (n_rm_rtf_ind=1)
      pl_beg = findstring("{\pict",ms_uncomp_blob,1), pl_pos = pl_beg
      WHILE (pl_pos > 0)
        pl_pos += 1, pl_cnt = 1, pl_loop1 += 1,
        ml_end = 0, pl_loop2 = 0
        WHILE (pl_cnt > 0)
          pl_loop2 += 1, pl_opos = findstring("{",ms_uncomp_blob,pl_pos), pl_cpos = findstring("}",
           ms_uncomp_blob,pl_pos)
          IF (pl_opos < pl_cpos
           AND pl_opos > 0)
           pl_cnt += 1, pl_pos = pl_opos
          ELSE
           pl_cnt -= 1, pl_pos = pl_cpos
          ENDIF
          IF (pl_cnt=0)
           ml_end = pl_pos
          ELSE
           pl_pos += 1
          ENDIF
          IF (pl_loop2 > 1000)
           pl_cnt = 0
          ENDIF
        ENDWHILE
        ms_uncomp_blob = concat(substring(1,(pl_beg - 1),ms_uncomp_blob),substring((ml_end+ 1),(
          textlen(ms_uncomp_blob) - ml_end),ms_uncomp_blob)), pl_pos = findstring("{\pict",
         ms_uncomp_blob,1,1), pl_beg = pl_pos
        IF (pl_loop1 > 1000)
         pl_pos = 0
        ENDIF
      ENDWHILE
      ms_uncomp_blob = trim(ms_uncomp_blob,3), stat = memrealloc(ms_return_blob,1,build("C",
        ml_newsize)),
      CALL uar_rtf2(ms_uncomp_blob,textlen(ms_uncomp_blob),ms_return_blob,size(ms_return_blob),
      ml_newsize,1)
     ELSE
      ms_return_blob = ms_uncomp_blob, ms_return_blob = replace(ms_return_blob,"\par\fi",
       "\par\pard\fi",0), ms_return_blob = replace(ms_return_blob,"\par\li","\par\pard\li",0)
     ENDIF
    WITH maxcol = 32100, rdbarrayfetch = 1, format = undefined
   ;end select
   FREE SET ms_comp_blob
   FREE SET ms_uncomp_blob
   FREE SET mc_outbuf
   RETURN(ms_return_blob)
 END ;Subroutine
END GO
