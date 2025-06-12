CREATE PROGRAM bb_add_isbt_attributes:dba
 DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
 SET serrormsg = fillstring(255," ")
 SET nerrorstatus = error(serrormsg,1)
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "K+", label_display = "K+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "K-", label_display = "K-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "C+", label_display = "C+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "C-", label_display = "C-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "c+", label_display = "c+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "c-", label_display = "c-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "E+", label_display = "E+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "E-", label_display = "E-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "e+", label_display = "e+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "e-", label_display = "e-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "MiIII+", label_display = "MiIII+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "MiIII-", label_display = "MiIII-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "A1", label_display = "A1",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "A2", label_display = "A2",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "A203", label_display = "A203",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "A210", label_display = "A210",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "A3", label_display = "A3",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "A9", label_display = "A9",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "A10", label_display = "A10",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "A11", label_display = "A11",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "A19", label_display = "A19",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "A23", label_display = "A23",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "A24", label_display = "A24",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "A24", label_display = "A24",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "A2403", label_display = "A2403",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "A25", label_display = "A25",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "A26", label_display = "A26",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "A28", label_display = "A28",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "A29", label_display = "A29",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "A30", label_display = "A30",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "A32", label_display = "A32",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "A33", label_display = "A33",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "A34", label_display = "A34",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "A36", label_display = "A36",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "A43", label_display = "A43",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "A66", label_display = "A66",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "A68", label_display = "A68",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "A69", label_display = "A69",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "A74", label_display = "A74",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "A80", label_display = "A80",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B5", label_display = "B5",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B7", label_display = "B7",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B703", label_display = "B703",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B8", label_display = "B8",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B12", label_display = "B12",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B13", label_display = "B13",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B14", label_display = "B14",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B14", label_display = "B14",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B15", label_display = "B15",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B16", label_display = "B16",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B17", label_display = "B17",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B18", label_display = "B18",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B21", label_display = "B21",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B22", label_display = "B22",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B27", label_display = "B27",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B2708", label_display = "B2708",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B35", label_display = "B35",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B37", label_display = "B37",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B38", label_display = "B38",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B39", label_display = "B39",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B40", label_display = "B40",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B4005", label_display = "B4005",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B41", label_display = "B41",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B42", label_display = "B42",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B44", label_display = "B44",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B45", label_display = "B45",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B46", label_display = "B46",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B47", label_display = "B47",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B48", label_display = "B48",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B49", label_display = "B49",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B50", label_display = "B50",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B51", label_display = "B51",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B5102", label_display = "B5102",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B52", label_display = "B52",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B53", label_display = "B53",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B54", label_display = "B54",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B55", label_display = "B55",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B56", label_display = "B56",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B57", label_display = "B57",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B58", label_display = "B58",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B59", label_display = "B59",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B60", label_display = "B60",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B61", label_display = "B61",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B62", label_display = "B62",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B63", label_display = "B63",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B64", label_display = "B64",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B65", label_display = "B65",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B67", label_display = "B67",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B70", label_display = "B70",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B71", label_display = "B71",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B72", label_display = "B72",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B73", label_display = "B73",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B74", label_display = "B74",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B75", label_display = "B75",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B76", label_display = "B76",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B77", label_display = "B77",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B78", label_display = "B78",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "B81", label_display = "B81",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "HPA1a-", label_display = "HPA1a-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "HPA1a+", label_display = "HPA1a+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "HPA2a-", label_display = "HPA2a-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "HPA2a+", label_display = "HPA2a+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "HPA3a-", label_display = "HPA3a-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "HPA3a+", label_display = "HPA3a+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "HPA4a-", label_display = "HPA4a-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "HPA4a+", label_display = "HPA4a+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "HPA5a-", label_display = "HPA5a-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "HPA5a+", label_display = "HPA5a+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "HPA6a-", label_display = "HPA6a-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "HPA6a+", label_display = "HPA6a+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "HPA7a-", label_display = "HPA7a-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "HPA7a+", label_display = "HPA7a+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "HPA1b-", label_display = "HPA1b-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "HPA1b+", label_display = "HPA1b+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "HPA2b-", label_display = "HPA2b-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "HPA2b+", label_display = "HPA2b+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "HPA3b-", label_display = "HPA3b-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "HPA3b+", label_display = "HPA3b+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "HPA4b-", label_display = "HPA4b-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "HPA4b+", label_display = "HPA4b+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "HPA5b-", label_display = "HPA5b-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "HPA5b+", label_display = "HPA5b+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "HPA6b-", label_display = "HPA6b-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "HPA6b+", label_display = "HPA6b+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "HPA7b-", label_display = "HPA7b-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "HPA7b+", label_display = "HPA7b+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "IgA-", label_display = "IgA-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "IgA+", label_display = "IgA+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "CMV-", label_display = "CMV-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "CMV+", label_display = "CMV+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Cw-", label_display = "Cw-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Cw+", label_display = "Cw+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "VS/V-", label_display = "VS/V-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "VS/V+", label_display = "VS/V+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "RBCA1+", label_display = "RBCA1-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "RBCA1+", label_display = "RBCA1+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "M-", label_display = "M-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "M+", label_display = "M+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "N-", label_display = "N-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "N+", label_display = "N+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "S-", label_display = "S-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "S+", label_display = "S+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "s-", label_display = "s-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "U-", label_display = "U-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "U+", label_display = "U+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "P1-", label_display = "P1-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "P1+", label_display = "P1+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Lua-", label_display = "Lua-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Lua+", label_display = "Lua+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Kpa-", label_display = "Kpa-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Kpa+", label_display = "Kpa+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Jsa-", label_display = "Jsa-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Jsa+", label_display = "Jsa+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Wra-", label_display = "Wra-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Wra+", label_display = "Wra+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Lea-", label_display = "Lea-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Lea+", label_display = "Lea+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Leb-", label_display = "Leb-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Leb+", label_display = "Leb+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Fya-", label_display = "Fya-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Fya+", label_display = "Fya+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Fyb-", label_display = "Fyb-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Fyb+", label_display = "Fyb+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Jka-", label_display = "Jka-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Jka+", label_display = "Jka+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Jkb-", label_display = "Jkb-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Jkb+", label_display = "Jkb+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Dia-", label_display = "Dia-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Dia+", label_display = "Dia+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Dib-", label_display = "Dib-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Dib+", label_display = "Dib+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Doa-", label_display = "Doa-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Doa+", label_display = "Doa+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Dob-", label_display = "Dob-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Dob+", label_display = "Dob+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Coa-", label_display = "Coa-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Coa+", label_display = "Coa+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Cob-", label_display = "Cob-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Cob+", label_display = "Cob+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Ina-", label_display = "Ina-",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Ina+", label_display = "Ina+",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Not for tx or mnf", label_display
    = "Not for tx or mnf",
   attribute_group = "Intended Use", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "For mnf:injectable", label_display
    = "For mnf:injectable",
   attribute_group = "Intended Use", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "For mnf:noninjectable",
   label_display = "For mnf:noninjectable",
   attribute_group = "Intended Use", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Open", label_display = "Open",
   attribute_group = "System Integrity", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Irradiated", label_display =
   "Irradiated",
   attribute_group = "Irradiation", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "ResLeu:<1.2log9", label_display =
   "ResLeu:<1.2log9",
   attribute_group = "Residual Leukocyte Content", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "ResLeu:<2log5", label_display =
   "ResLeu:<2log5",
   attribute_group = "Residual Leukocyte Content", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "ResLeu:<2log5", label_display =
   "ResLeu:<2log5",
   attribute_group = "Residual Leukocyte Content", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "ResLeu:<5log5", label_display =
   "ResLeu:<5log5",
   attribute_group = "Residual Leukocyte Content", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "ResLeu:<8.3log5", label_display =
   "ResLeu:<8.3log5",
   attribute_group = "Residual Leukocyte Content", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "ResLeu:<1log6", label_display =
   "ResLeu:<1log6",
   attribute_group = "Residual Leukocyte Content", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "ResLeu:<5log6", label_display =
   "ResLeu:<5log6",
   attribute_group = "Residual Leukocyte Content", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "ResLeu:<5log8", label_display =
   "ResLeu:<5log8",
   attribute_group = "Residual Leukocyte Content", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "ResLeu:NS", label_display =
   "ResLeu:NS",
   attribute_group = "Residual Leukocyte Content", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Supernat reduced", label_display =
   "Supernat reduced",
   attribute_group = "Altered", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Plts/Cryo reduced", label_display
    = "Plts/Cryo reduced",
   attribute_group = "Altered", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Supernat rem/Plasma added",
   label_display = "Supernat rem/Plasma added",
   attribute_group = "Altered", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Supernat rem", label_display =
   "Supernat rem",
   attribute_group = "Altered", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Plts reduced", label_display =
   "Plts reduced",
   attribute_group = "Altered", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Plasma reduced", label_display =
   "Plasma reduced",
   attribute_group = "Altered", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Plasma added", label_display =
   "Plasma added",
   attribute_group = "Altered", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Cryo reduced", label_display =
   "Cryo reduced",
   attribute_group = "Altered", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Albumin added", label_display =
   "Albumin added",
   attribute_group = "Altered", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = ">=600mL", label_display = ">=600mL",
   attribute_group = "Final Content", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = ">=400mL<600mL", label_display =
   ">=400mL<600mL",
   attribute_group = "Final Content", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = ">=200 mL<400mL", label_display =
   ">=200 mL<400mL",
   attribute_group = "Final Content", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "<200 mL", label_display = "<200 mL",
   attribute_group = "Final Content", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Low volume", label_display =
   "Low volume",
   attribute_group = "Final Content", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Fin Con:NS", label_display =
   "Fin Con:NS",
   attribute_group = "Final Content", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Frozen >24h", label_display =
   "Frozen >24h",
   attribute_group = "Preparation:Additional Info", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Frozen <=24h", label_display =
   "Frozen <=24h",
   attribute_group = "Preparation:Additional Info", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Frozen <=18h", label_display =
   "Frozen <=18h",
   attribute_group = "Preparation:Additional Info", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Frozen <=15h", label_display =
   "Frozen <=15h",
   attribute_group = "Preparation:Additional Info", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Frozen <=6h", label_display =
   "Frozen <=6h",
   attribute_group = "Preparation:Additional Info", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Granulocytes prep: HES",
   label_display = "Granulocytes prep: HES",
   attribute_group = "Preparation:Additional Info", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Buffy coat plts prep",
   label_display = "Buffy coat plts prep",
   attribute_group = "Preparation:Additional Info", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Aphr not automated", label_display
    = "Aphr not automated",
   attribute_group = "Apheresis:Additional Info", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "2nd container:not auto",
   label_display = "2nd container:not auto",
   attribute_group = "Apheresis:Additional Info", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "1st container:not auto",
   label_display = "1st container:not auto",
   attribute_group = "Apheresis:Additional Info", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "4th container", label_display =
   "4th container",
   attribute_group = "Apheresis:Additional Info", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "3rd container", label_display =
   "3rd container",
   attribute_group = "Apheresis:Additional Info", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "2nd container", label_display =
   "2nd container",
   attribute_group = "Apheresis:Additional Info", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "1st container", label_display =
   "1st container",
   attribute_group = "Apheresis:Additional Info", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Quar:>=112d/retested",
   label_display = "Quar:>=112d/retested",
   attribute_group = "Quarantine:Additional Info", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Quar:>=4m/retested", label_display
    = "Quar:>=4m/retested",
   attribute_group = "Quarantine:Additional Info", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Quar:>=6m/retested", label_display
    = "Quar:>=6m/retested",
   attribute_group = "Quarantine:Additional Info", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "From 8 donors", label_display =
   "From 8 donors",
   attribute_group = "Pools:Additional Info", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "From 7 donors", label_display =
   "From 7 donors",
   attribute_group = "Pools:Additional Info", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "From 6 donors", label_display =
   "From 6 donors",
   attribute_group = "Pools:Additional Info", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "From 5 donors", label_display =
   "From 5 donors",
   attribute_group = "Pools:Additional Info", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "From 4 donors", label_display =
   "From 4 donors",
   attribute_group = "Pools:Additional Info", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "From 3 donors", label_display =
   "From 3 donors",
   attribute_group = "Pools:Additional Info", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "From 2 donors", label_display =
   "From 2 donors",
   attribute_group = "Pools:Additional Info", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Approx 540 log9 plts",
   label_display = "Approx 540 log9 plts",
   attribute_group = "Pools:Additional Info", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "From 9 donors", label_display =
   "From 9 donors",
   attribute_group = "Pools:Additional Info", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Approx 480 log9 plts",
   label_display = "Approx 480 log9 plts",
   attribute_group = "Pools:Additional Info", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Approx 420 log9 plts",
   label_display = "Approx 420 log9 plts",
   attribute_group = "Pools:Additional Info", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Approx 360 log9 plts",
   label_display = "Approx 360 log9 plts",
   attribute_group = "Pools:Additional Info", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Approx 300 log9 plts",
   label_display = "Approx 300 log9 plts",
   attribute_group = "Pools:Additional Info", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Approx 240 log9 plts",
   label_display = "Approx 240 log9 plts",
   attribute_group = "Pools:Additional Info", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Approx 180 log9 plts",
   label_display = "Approx 180 log9 plts",
   attribute_group = "Pools:Additional Info", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Approx 120 log9 plts",
   label_display = "Approx 120 log9 plts",
   attribute_group = "Pools:Additional Info", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Psoralen-treated", label_display =
   "Psoralen-treated",
   attribute_group = "Method of Treatment", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Solvent detergent-treated",
   label_display = "Solvent detergent-treated",
   attribute_group = "Method of Treatment", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Methylene blue-treated",
   label_display = "Methylene blue-treated",
   attribute_group = "Method of Treatment", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Heat-treated", label_display =
   "Heat-treated",
   attribute_group = "Method of Treatment", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Washed", label_display = "Washed",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Frozen", label_display = "Frozen",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Frozen Rejuvenated", label_display
    = "Frozen Rejuvenated",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Deglycerolized", label_display =
   "Deglycerolized",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Deglycerolized Rejuvenated",
   label_display = "Deglycerolized Rejuvenated",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Rejuvenated", label_display =
   "Rejuvenated",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Thawed", label_display = "Thawed",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 INSERT  FROM bb_isbt_attribute
  SET bb_isbt_attribute_id = new_pathnet_seq, standard_display = "Liquid", label_display = "Liquid",
   attribute_group = "NONE", active_ind = 1, active_status_cd = 58,
   active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = 10629, updt_cnt = 0,
   updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 10629, updt_task = 0,
   updt_applctx = 0
  WITH nocounter
 ;end insert
 UPDATE  FROM common_data_foundation
  SET display = "Modifier/Attribute"
  WHERE code_set=1612
   AND cdf_meaning="SPTYP"
  WITH nocounter
 ;end update
 SET nerrorstatus = error(serrormsg,0)
 IF (nerrorstatus=0)
  CALL echo("Success")
 ELSE
  CALL echo("Script failed")
 ENDIF
END GO
