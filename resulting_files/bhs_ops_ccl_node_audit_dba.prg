CREATE PROGRAM bhs_ops_ccl_node_audit:dba
 FREE RECORD m_rec
 RECORD m_rec(
   1 obj[*]
     2 s_object_name = vc
     2 s_info_char = vc
     2 n_upd_char = i2
     2 n_insert = i2
     2 n_delete = i2
     2 n_nochange = i2
 ) WITH protect
 DECLARE ms_curdomain = vc WITH protect, constant(cnvtlower(trim(curdomain,3)))
 DECLARE ms_curnode_num = c1 WITH protect, constant(trim(cnvtstring(cnvtalphanum(curnode,1)),3))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_info_char = vc WITH protect, noconstant(" ")
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 IF ( NOT (curdomain IN ("PROD", "P627", "CP627")))
  CALL echo("this script only executes in Prod")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="BHS_OPS_CCL_NODE_AUDIT"
  ORDER BY di.info_name
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   pl_cnt += 1
   IF (pl_cnt > size(m_rec->obj,5))
    CALL alterlist(m_rec->obj,(pl_cnt+ 1000))
   ENDIF
   m_rec->obj[pl_cnt].s_object_name = trim(cnvtlower(di.info_name),3), m_rec->obj[pl_cnt].s_info_char
    = trim(di.info_char,3)
  FOOT REPORT
   CALL alterlist(m_rec->obj,pl_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dprotect dp
  PLAN (dp
   WHERE dp.object="P")
  HEAD REPORT
   pl_cnt = size(m_rec->obj,5), pl_rec = 0
  DETAIL
   pl_rec = 0, ml_idx = locateval(ml_loc,1,size(m_rec->obj,5),concat(trim(cnvtlower(dp.object_name),3
      ),":",trim(cnvtstring(dp.group),3)),m_rec->obj[ml_loc].s_object_name)
   IF (ml_idx=0)
    pl_cnt += 1,
    CALL alterlist(m_rec->obj,pl_cnt), m_rec->obj[pl_cnt].s_object_name = concat(trim(cnvtlower(dp
       .object_name),3),":",trim(cnvtstring(dp.group),3)),
    m_rec->obj[pl_cnt].s_info_char = ms_curnode_num, m_rec->obj[pl_cnt].n_insert = 1
   ELSE
    ms_info_char = trim(m_rec->obj[ml_idx].s_info_char,3)
    IF (ms_info_char != concat("*",ms_curnode_num,"*"))
     m_rec->obj[ml_idx].n_upd_char = 1
     FOR (ml_loop = 1 TO textlen(ms_info_char))
       IF (cnvtint(substring(ml_loop,1,ms_info_char)) > cnvtint(ms_curnode_num))
        IF (ml_loop=1)
         ms_tmp = concat(ms_curnode_num,ms_info_char)
        ELSEIF (ml_loop <= textlen(ms_info_char))
         ms_tmp = concat(substring(1,(ml_loop - 1),ms_info_char)), ms_tmp = concat(ms_tmp,
          ms_curnode_num), ms_tmp = concat(ms_tmp,substring(ml_loop,((textlen(ms_info_char) - ml_loop
           )+ 1),ms_info_char))
        ENDIF
       ELSEIF (ml_loop=textlen(ms_info_char))
        ms_tmp = concat(ms_info_char,ms_curnode_num)
       ENDIF
     ENDFOR
     m_rec->obj[ml_idx].s_info_char = ms_tmp
    ELSE
     m_rec->obj[ml_idx].n_nochange = 1
    ENDIF
   ENDIF
  FOOT REPORT
   FOR (ml_loop = 1 TO size(m_rec->obj,5))
     IF ((((m_rec->obj[ml_loop].n_insert+ m_rec->obj[ml_loop].n_upd_char)+ m_rec->obj[ml_loop].
     n_nochange)=0))
      ms_tmp = m_rec->obj[ml_loop].s_info_char
      IF (ms_tmp=ms_curnode_num)
       m_rec->obj[ml_loop].n_delete = 1
      ELSEIF (ms_tmp=concat("*",ms_curnode_num,"*"))
       m_rec->obj[ml_loop].s_info_char = replace(m_rec->obj[ml_loop].s_info_char,ms_curnode_num,""),
       m_rec->obj[ml_loop].n_upd_char = 1
      ELSE
       m_rec->obj[ml_loop].n_nochange = 1
      ENDIF
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
 INSERT  FROM dm_info di,
   (dummyt d  WITH seq = value(size(m_rec->obj,5)))
  SET di.info_domain = "BHS_OPS_CCL_NODE_AUDIT", di.info_name = m_rec->obj[d.seq].s_object_name, di
   .info_char = m_rec->obj[d.seq].s_info_char,
   di.updt_dt_tm = sysdate, di.updt_id = reqinfo->updt_id
  PLAN (d
   WHERE (m_rec->obj[d.seq].n_insert=1))
   JOIN (di)
  WITH nocounter
 ;end insert
 UPDATE  FROM dm_info di,
   (dummyt d  WITH seq = value(size(m_rec->obj,5)))
  SET di.info_char = m_rec->obj[d.seq].s_info_char, di.updt_dt_tm = sysdate, di.updt_id = reqinfo->
   updt_id,
   di.updt_cnt = (di.updt_cnt+ 1)
  PLAN (d
   WHERE (m_rec->obj[d.seq].n_upd_char=1))
   JOIN (di
   WHERE di.info_domain="BHS_OPS_CCL_NODE_AUDIT"
    AND (di.info_name=m_rec->obj[d.seq].s_object_name)
    AND (di.info_char != m_rec->obj[d.seq].s_info_char))
  WITH nocounter
 ;end update
 DELETE  FROM dm_info di,
   (dummyt d  WITH seq = value(size(m_rec->obj,5)))
  SET di.seq = 1
  PLAN (d
   WHERE (m_rec->obj[d.seq].n_delete=1))
   JOIN (di
   WHERE di.info_domain="BHS_OPS_CCL_NODE_AUDIT"
    AND (di.info_name=m_rec->obj[d.seq].s_object_name))
  WITH nocounter
 ;end delete
 COMMIT
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
