CREATE PROGRAM bhs_rpt_ccl_data:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Compiled by - Last Name" = "",
  "s_username" = value(0.0),
  "Include bhscust?" = 0,
  "Include cclprod folder?" = 0
  WITH outdev, s_name_last, f_user_id,
  n_bhscust, n_cclprod
 FREE RECORD m_rec
 RECORD m_rec(
   1 ccl[*]
     2 s_object_name = vc
     2 s_path = vc
     2 s_username = vc
     2 s_date = vc
     2 n_group = i2
     2 s_nodes = vc
     2 s_drop = vc
   1 users[*]
     2 s_username = vc
 ) WITH protect
 DECLARE ms_name_last = vc WITH protect, constant(trim(cnvtupper( $S_NAME_LAST),3))
 DECLARE mn_bhscust = i2 WITH protect, constant(cnvtint( $N_BHSCUST))
 DECLARE mn_cclprod = i2 WITH protect, constant(cnvtint( $N_CCLPROD))
 DECLARE ms_output = vc WITH protect, noconstant(value( $OUTDEV))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_exp = i4 WITH protect, noconstant(0)
 DECLARE ms_parse = vc WITH protect, noconstant(" ")
 IF (( $F_USER_ID=0.0)
  AND textlen(trim(ms_name_last,3)) > 0)
  CALL echo("here 1")
  SELECT INTO "nl:"
   FROM prsnl pr
   WHERE pr.name_last_key=ms_name_last
    AND  NOT (pr.username IN ("", " ", null))
   ORDER BY pr.person_id
   HEAD REPORT
    pl_cnt = 0
   HEAD pr.person_id
    pl_cnt += 1,
    CALL alterlist(m_rec->users,pl_cnt), m_rec->users[pl_cnt].s_username = trim(pr.username,3)
    IF (((pr.username="TERM*") OR (textlen(trim(pr.username,3)) > 8)) )
     IF (pr.username="TERMHR*")
      ms_tmp = substring(7,8,replace(pr.username,"_",""))
     ELSEIF (pr.username="TERM*")
      ms_tmp = substring(5,8,replace(pr.username,"_",""))
     ELSE
      ms_tmp = replace(substring(1,8,trim(pr.username,3)),"_","")
     ENDIF
     pl_cnt += 1,
     CALL alterlist(m_rec->users,pl_cnt), m_rec->users[pl_cnt].s_username = ms_tmp
    ENDIF
   WITH nocounter
  ;end select
 ELSEIF (textlen(trim(ms_name_last,3)) > 0)
  CALL echo("here 2")
  SELECT INTO "nl:"
   FROM prsnl pr
   WHERE (pr.person_id= $F_USER_ID)
   ORDER BY pr.person_id
   HEAD REPORT
    pl_cnt = 0
   HEAD pr.person_id
    pl_cnt += 1,
    CALL alterlist(m_rec->users,pl_cnt), m_rec->users[pl_cnt].s_username = trim(pr.username,3)
    IF (((pr.username="TERM*") OR (textlen(trim(pr.username,3)) > 8)) )
     IF (pr.username="TERMHR*")
      ms_tmp = trim(substring(7,8,replace(pr.username,"_","")),3)
     ELSEIF (pr.username="TERM*")
      ms_tmp = trim(substring(5,8,replace(pr.username,"_","")),3)
     ELSE
      ms_tmp = trim(replace(substring(1,8,trim(pr.username,3)),"_",""),3)
     ENDIF
     pl_cnt += 1,
     CALL alterlist(m_rec->users,pl_cnt), m_rec->users[pl_cnt].s_username = ms_tmp
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 CALL echorecord(m_rec->users)
 IF (((mn_bhscust=0) OR (mn_cclprod=0)) )
  IF (mn_bhscust=0)
   SET ms_parse = ' cnvtlower(d.source_name) != "*bhscust*" '
  ENDIF
  IF (mn_cclprod=0)
   IF (mn_bhscust=0)
    SET ms_parse = concat(ms_parse," and ")
   ENDIF
   SET ms_parse = concat(ms_parse,' cnvtlower(d.source_name) != "*cclprod*"')
  ENDIF
 ELSE
  SET ms_parse = " 1=1"
 ENDIF
 CALL echo(build2("ms_parse: ",ms_parse))
 SELECT
  IF (textlen(trim(ms_name_last,3))=0)
   PLAN (d
    WHERE d.object="P"
     AND textlen(trim(d.source_name,3)) > 0)
    JOIN (d1)
    JOIN (p
    WHERE operator(p.username,"LIKE",patstring(d.user_name,1)))
  ELSE
  ENDIF
  INTO "nl:"
  p.name_last, d.user_name, d.object_name,
  d.source_name
  FROM dprotect d,
   dummyt d1,
   prsnl p
  PLAN (d
   WHERE d.object="P"
    AND textlen(trim(d.source_name,3)) > 0
    AND parser(ms_parse)
    AND expand(ml_exp,1,size(m_rec->users,5),d.user_name,m_rec->users[ml_exp].s_username))
   JOIN (d1)
   JOIN (p
   WHERE operator(p.username,"LIKE",patstring(d.user_name,1)))
  ORDER BY p.name_last, d.datestamp DESC, d.object_name
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   ms_tmp = trim(d.source_name), pl_cnt += 1
   IF (pl_cnt > size(m_rec->ccl,5))
    stat = alterlist(m_rec->ccl,(pl_cnt+ 25))
   ENDIF
   m_rec->ccl[pl_cnt].n_group = d.group, m_rec->ccl[pl_cnt].s_date = trim(format(d.datestamp,
     "mm/dd/yyyy;;d")), m_rec->ccl[pl_cnt].s_object_name = trim(cnvtlower(d.object_name),3),
   m_rec->ccl[pl_cnt].s_path = trim(d.source_name), m_rec->ccl[pl_cnt].s_username = trim(d.user_name),
   m_rec->ccl[pl_cnt].s_drop = concat("drop program ",trim(d.object_name,3))
   IF (d.group=0)
    m_rec->ccl[pl_cnt].s_drop = concat(m_rec->ccl[pl_cnt].s_drop,":dba go")
   ELSE
    m_rec->ccl[pl_cnt].s_drop = concat(m_rec->ccl[pl_cnt].s_drop," go")
   ENDIF
  FOOT REPORT
   stat = alterlist(m_rec->ccl,pl_cnt)
  WITH nocounter, outerjoin = d1, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_rec->ccl,5))),
   dm_info di
  PLAN (d)
   JOIN (di
   WHERE di.info_domain="BHS_OPS_CCL_AUDIT"
    AND di.info_name=concat(m_rec->ccl[d.seq].s_object_name,":",trim(cnvtstring(m_rec->ccl[d.seq].
      n_group),3)))
  ORDER BY d.seq
  HEAD d.seq
   m_rec->ccl[d.seq].s_nodes = trim(di.info_char,3)
  WITH nocounter
 ;end select
 SELECT INTO value( $OUTDEV)
  username = substring(1,10,m_rec->ccl[d.seq].s_username), script = substring(1,35,m_rec->ccl[d.seq].
   s_object_name), date = m_rec->ccl[d.seq].s_date,
  group = m_rec->ccl[d.seq].n_group, nodes = substring(1,5,m_rec->ccl[d.seq].s_nodes), path =
  substring(1,250,m_rec->ccl[d.seq].s_path),
  drop_command = substring(1,150,m_rec->ccl[d.seq].s_drop)
  FROM (dummyt d  WITH seq = value(size(m_rec->ccl,5)))
  PLAN (d)
  ORDER BY script
  WITH nocounter, format, separator = " ",
   maxrow = 1
 ;end select
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
