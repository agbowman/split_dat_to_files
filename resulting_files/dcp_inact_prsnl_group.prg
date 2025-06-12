CREATE PROGRAM dcp_inact_prsnl_group
 RECORD groups(
   1 data[*]
     2 group_id = f8
 )
 RECORD reltns(
   1 data[*]
     2 prsnl_group_reltn_id = f8
 )
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET modify = predeclare
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE failed = i2 WITH protect, noconstant(0)
 DECLARE select_error = i2 WITH protect, constant(7)
 DECLARE update_error = i2 WITH protect, constant(8)
 DECLARE table_name = vc WITH protect, noconstant(fillstring(50," "))
 DECLARE serrmsg = vc WITH protect, noconstant(fillstring(132," "))
 DECLARE x = i4 WITH protect, noconstant(0)
 DECLARE code_value = f8 WITH public, noconstant(0.0)
 DECLARE cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE code_set = i4 WITH public, noconstant(0)
 SET modify = nopredeclare
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=19189
   AND cv.cdf_meaning="DCPTEAM"
   AND cv.active_ind=1
  DETAIL
   code_value = cv.code_value
  WITH nocounter
 ;end select
 SET modify = predeclare
 DECLARE group_cd = f8 WITH protect, constant(code_value)
 IF (group_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = "Failed to find the code_value for cdf_meaning DCPTEAM from code_set 19189"
  GO TO exit_script
 ENDIF
 DECLARE findgroups(null) = null
 DECLARE findreltns(null) = null
 DECLARE endreltns(null) = null
 DECLARE endgroups(null) = null
 CALL findgroups(null)
 IF (size(groups->data,5)=0)
  GO TO exit_script
 ENDIF
 CALL findreltns(null)
 IF (size(reltns->data,5) > 0)
  CALL endreltns(null)
 ENDIF
 CALL endgroups(null)
#exit_script
 SET modify = nopredeclare
 IF (failed=0)
  SET readme_data->status = "S"
  IF (size(groups->data,5)=0)
   SET readme_data->message = "No records qualified to inactivate."
  ELSE
   SET readme_data->message = "Records have been successfully inactivated"
  ENDIF
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = serrmsg
 ENDIF
 EXECUTE dm_readme_status
 SUBROUTINE findgroups(null)
   SELECT INTO "nl:"
    FROM prsnl_group pg
    PLAN (pg
     WHERE pg.prsnl_group_class_cd=group_cd
      AND pg.active_ind=1
      AND pg.prsnl_group_type_cd=0
      AND pg.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
      AND pg.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1)
     IF (mod(cnt,10)=1)
      stat = alterlist(groups->data,(cnt+ 9))
     ENDIF
     groups->data[cnt].group_id = pg.prsnl_group_id
    FOOT REPORT
     stat = alterlist(groups->data,cnt)
    WITH nocounter
   ;end select
   CALL echorecord(groups)
   SELECT INTO "nl:"
    pg.prsnl_group_type_cd
    FROM prsnl_group pg,
     dummyt d,
     code_value cv
    PLAN (pg
     WHERE pg.prsnl_group_class_cd=group_cd
      AND pg.active_ind=1
      AND pg.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
      AND pg.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (d)
     JOIN (cv
     WHERE cv.code_value=outerjoin(pg.prsnl_group_type_cd))
    HEAD REPORT
     cnt = size(groups->data,5), stat = alterlist(groups->data,(cnt+ 9))
    DETAIL
     cnt = (cnt+ 1)
     IF (mod(cnt,10)=1)
      stat = alterlist(groups->data,(cnt+ 9))
     ENDIF
     groups->data[cnt].group_id = pg.prsnl_group_id
    FOOT REPORT
     stat = alterlist(groups->data,cnt)
    WITH outerjoin = d, dontexist, nocounter
   ;end select
   CALL echorecord(groups)
 END ;Subroutine
 SUBROUTINE findreltns(null)
  SELECT INTO "nl"
   FROM (dummyt d  WITH seq = size(groups->data,5)),
    prsnl_group_reltn pgr
   PLAN (d)
    JOIN (pgr
    WHERE (pgr.prsnl_group_id=groups->data[d.seq].group_id)
     AND pgr.active_ind=1)
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(reltns->data,(cnt+ 9))
    ENDIF
    reltns->data[cnt].prsnl_group_reltn_id = pgr.prsnl_group_reltn_id
   FOOT REPORT
    stat = alterlist(reltns->data,cnt)
   WITH nocounter
  ;end select
  CALL echorecord(reltns)
 END ;Subroutine
 SUBROUTINE endreltns(null)
   DECLARE reltn_cnt = i4 WITH noconstant(size(reltns->data,5))
   CALL echo(build("There will be ",reltn_cnt," members inactivated"))
   FOR (x = 1 TO reltn_cnt)
    UPDATE  FROM prsnl_group_reltn pgr
     SET pgr.active_ind = 0, pgr.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), pgr.updt_cnt
       = (pgr.updt_cnt+ 1),
      pgr.updt_dt_tm = cnvtdatetime(curdate,curtime3), pgr.updt_id = reqinfo->updt_id, pgr
      .updt_applctx = reqinfo->updt_applctx,
      pgr.updt_task = reqinfo->updt_task
     WHERE (pgr.prsnl_group_reltn_id=reltns->data[x].prsnl_group_reltn_id)
      AND pgr.active_ind=1
    ;end update
    IF (curqual=0)
     SET serrmsg = concat("Failed to inactivate reltn_id ",reltns->data[x].prsnl_group_reltn_id)
     SET failed = update_error
     ROLLBACK
    ELSE
     COMMIT
    ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE endgroups(null)
   DECLARE group_cnt = i4 WITH noconstant(size(groups->data,5))
   CALL echo(build("There will be ",group_cnt," groups inactivated"))
   FOR (x = 1 TO group_cnt)
    UPDATE  FROM prsnl_group pg
     SET pg.active_ind = 0, pg.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), pg.updt_cnt = (
      pg.updt_cnt+ 1),
      pg.updt_dt_tm = cnvtdatetime(curdate,curtime3), pg.updt_id = reqinfo->updt_id, pg.updt_applctx
       = reqinfo->updt_applctx,
      pg.updt_task = reqinfo->updt_task
     WHERE (pg.prsnl_group_id=groups->data[x].group_id)
      AND pg.active_ind=1
    ;end update
    IF (curqual=0)
     SET serrmsg = concat("Failed to inactivate group_id ",groups->data[x].group_id)
     SET failed = update_error
     ROLLBACK
    ELSE
     COMMIT
    ENDIF
   ENDFOR
 END ;Subroutine
END GO
