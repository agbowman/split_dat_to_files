CREATE PROGRAM aps_load_specimen_protocol:dba
 RECORD default(
   1 task[*]
     2 catalog_cd = f8
     2 task_assay_cd = f8
     2 begin_section = i4
     2 begin_level = i4
     2 create_inventory_flag = i4
     2 stain_ind = i2
     2 t_no_charge_ind = i2
     2 task_type_flag = i2
     2 catalog_type_cd = f8
 )
 DECLARE default_catalog_type = f8 WITH protect
#script
 SET p_spec_cnt = size(protocol->spec,5)
 SET default_isgrp = 0
 SET default_protocol_id = 0.0
 SET add_default = 0
 SELECT INTO "nl:"
  d.seq, asp.protocol_id, specimen_cd = decode(asp.seq,asp.specimen_cd,0.0),
  prefix_cd = decode(asp.seq,asp.prefix_id,0.0), pathologist_id = decode(asp.seq,asp.pathologist_id,
   0.0)
  FROM (dummyt d  WITH seq = value(p_spec_cnt)),
   dummyt d2,
   ap_specimen_protocol asp
  PLAN (d)
   JOIN (d2)
   JOIN (asp
   WHERE (protocol->spec[d.seq].specimen_cd=asp.specimen_cd)
    AND ((asp.prefix_id=0.0
    AND asp.pathologist_id=0.0) OR (((parser(
    IF ((protocol->prefix_cd != 0.0))
     "protocol->prefix_cd = asp.prefix_id and asp.pathologist_id = 0.0"
    ELSE "0 != 0"
    ENDIF
    )) OR (((parser(
    IF ((protocol->pathologist_id != 0.0))
     "asp.prefix_id = 0.0 and protocol->pathologist_id = asp.pathologist_id"
    ELSE "0 != 0"
    ENDIF
    )) OR (parser(
    IF ((protocol->pathologist_id != 0.0)
     AND (protocol->prefix_cd != 0.0))
     "protocol->prefix_cd = asp.prefix_id and protocol->pathologist_id = asp.pathologist_id"
    ELSE "0 != 0"
    ENDIF
    ))) )) )) )
  ORDER BY d.seq, specimen_cd, pathologist_id,
   prefix_cd
  DETAIL
   IF (specimen_cd != 0.0)
    protocol->spec[d.seq].protocol_id = asp.protocol_id
   ENDIF
  WITH nocounter, outerjoin = d2
 ;end select
 FOR (x = 1 TO p_spec_cnt)
   IF ((protocol->spec[x].protocol_id=0.0))
    SELECT INTO "nl:"
     ap.default_proc_catalog_cd, isgrp = decode(cv.seq,1,0)
     FROM ap_prefix ap,
      (dummyt d  WITH seq = 1),
      code_value cv
     PLAN (ap
      WHERE (protocol->prefix_cd=ap.prefix_id))
      JOIN (d)
      JOIN (cv
      WHERE ap.default_proc_catalog_cd=cv.code_value
       AND 1310=cv.code_set)
     DETAIL
      default_isgrp = isgrp, default_protocol_id = ap.default_proc_catalog_cd
     WITH nocounter, outerjoin = d
    ;end select
    IF (default_protocol_id != 0.0)
     IF (default_isgrp=0)
      SELECT INTO "nl:"
       FROM order_catalog oc
       WHERE oc.catalog_cd=default_protocol_id
       DETAIL
        default_catalog_type = oc.catalog_type_cd
       WITH nocounter, maxqual(oc,1)
      ;end select
      SET stat = alterlist(default->task,1)
      SELECT INTO "nl:"
       ataa.task_assay_cd
       FROM profile_task_r ptr,
        ap_task_assay_addl ataa
       PLAN (ptr
        WHERE default_protocol_id=ptr.catalog_cd
         AND 1=ptr.active_ind
         AND cnvtdatetime(curdate,curtime3) BETWEEN ptr.beg_effective_dt_tm AND ptr
        .end_effective_dt_tm)
        JOIN (ataa
        WHERE ptr.task_assay_cd=ataa.task_assay_cd)
       HEAD REPORT
        add_default = 0, default->task[1].task_assay_cd = 0.0, default->task[1].begin_section = 0,
        default->task[1].begin_level = 0, default->task[1].create_inventory_flag = 0, default->task[1
        ].stain_ind = 0,
        default->task[1].task_type_flag = 0
       DETAIL
        CASE (ataa.create_inventory_flag)
         OF 0:
          IF (ataa.task_type_flag=4)
           add_default = 1, default->task[1].begin_section = 0, default->task[1].begin_level = 0
          ENDIF
         OF 1:
          add_default = 1,default->task[1].begin_section = 1,default->task[1].begin_level = 0
         OF 2:
          IF (ataa.slide_origin_flag=4)
           add_default = 1, default->task[1].begin_section = 0, default->task[1].begin_level = 0
          ENDIF
         OF 3:
          add_default = 1,default->task[1].begin_section = 1,default->task[1].begin_level = 1
        ENDCASE
        IF (add_default=1)
         default->task[1].catalog_cd = default_protocol_id, default->task[1].catalog_type_cd =
         default_catalog_type, default->task[1].task_assay_cd = ataa.task_assay_cd,
         default->task[1].create_inventory_flag = ataa.create_inventory_flag, default->task[1].
         stain_ind = ataa.stain_ind, default->task[1].t_no_charge_ind = 0,
         default->task[1].task_type_flag = ataa.task_type_flag
        ENDIF
       WITH nocounter, maxqual(ptr,1)
      ;end select
      IF (add_default != 1)
       SET stat = alterlist(default->task,0)
      ENDIF
     ELSE
      SELECT INTO "nl:"
       apgr.parent_entity_id
       FROM ap_processing_grp_r apgr
       PLAN (apgr
        WHERE default_protocol_id=apgr.parent_entity_id
         AND "AP_SPECIMEN_PROTOCOL"=apgr.parent_entity_name
         AND (- (1)=apgr.begin_section))
       DETAIL
        row + 0
       WITH nocounter, maxqual(apgr,1)
      ;end select
      IF (curqual=0)
       SELECT INTO "nl:"
        apgr.task_assay_cd, begin_section = apgr.begin_section, inventory_flag =
        IF (ataa.create_inventory_flag=2) 1
        ELSEIF (ataa.create_inventory_flag=1) 2
        ELSE ataa.create_inventory_flag
        ENDIF
        ,
        begin_level = apgr.begin_level
        FROM ap_processing_grp_r apgr,
         ap_task_assay_addl ataa,
         profile_task_r ptr
        PLAN (apgr
         WHERE default_protocol_id=apgr.parent_entity_id
          AND apgr.parent_entity_name="AP_SPECIMEN_PROTOCOL")
         JOIN (ptr
         WHERE ptr.task_assay_cd=apgr.task_assay_cd
          AND 1=ptr.active_ind
          AND cnvtdatetime(curdate,curtime3) BETWEEN ptr.beg_effective_dt_tm AND ptr
         .end_effective_dt_tm)
         JOIN (ataa
         WHERE ptr.task_assay_cd=ataa.task_assay_cd)
        ORDER BY begin_section, begin_level, inventory_flag DESC
        HEAD REPORT
         dtaskcnt = 0, stat = alterlist(default->task,5)
        DETAIL
         dtaskcnt = (dtaskcnt+ 1)
         IF (mod(dtaskcnt,5)=1
          AND dtaskcnt != 1)
          stat = alterlist(default->task,(dtaskcnt+ 4))
         ENDIF
         default->task[dtaskcnt].task_assay_cd = apgr.task_assay_cd, default->task[dtaskcnt].
         begin_section = apgr.begin_section, default->task[dtaskcnt].begin_level = apgr.begin_level,
         default->task[dtaskcnt].create_inventory_flag = ataa.create_inventory_flag, default->task[
         dtaskcnt].stain_ind = ataa.stain_ind, default->task[dtaskcnt].t_no_charge_ind = apgr
         .no_charge_ind,
         default->task[dtaskcnt].task_type_flag = ataa.task_type_flag
        FOOT REPORT
         IF (mod(dtaskcnt,5) != 0)
          stat = alterlist(default->task,dtaskcnt)
         ENDIF
        WITH nocounter
       ;end select
      ELSE
       SET stat = alterlist(default->task,0)
      ENDIF
     ENDIF
     SET x = 0
     IF (size(default->task,5) > 0)
      SET protocol->max_task_cnt = size(default->task,5)
      SELECT INTO "nl:"
       d.seq
       FROM (dummyt d  WITH seq = value(p_spec_cnt))
       PLAN (d
        WHERE (protocol->spec[d.seq].protocol_id=0.0))
       DETAIL
        stat = alterlist(protocol->spec[d.seq].task,protocol->max_task_cnt)
        FOR (x = 1 TO protocol->max_task_cnt)
          protocol->spec[d.seq].task[x].catalog_cd = default->task[x].catalog_cd, protocol->spec[d
          .seq].task[x].catalog_type_cd = default->task[x].catalog_type_cd, protocol->spec[d.seq].
          task[x].task_assay_cd = default->task[x].task_assay_cd,
          protocol->spec[d.seq].task[x].begin_section = default->task[x].begin_section, protocol->
          spec[d.seq].task[x].begin_level = default->task[x].begin_level, protocol->spec[d.seq].task[
          x].create_inventory_flag = default->task[x].create_inventory_flag,
          protocol->spec[d.seq].task[x].stain_ind = default->task[x].stain_ind, protocol->spec[d.seq]
          .task[x].t_no_charge_ind = default->task[x].t_no_charge_ind, protocol->spec[d.seq].task[x].
          task_type_flag = default->task[x].task_type_flag
        ENDFOR
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
    SET x = p_spec_cnt
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  d.seq, apgr.task_assay_cd, begin_section = apgr.begin_section,
  inventory_flag =
  IF (ataa.create_inventory_flag=2) 1
  ELSEIF (ataa.create_inventory_flag=1) 2
  ELSE ataa.create_inventory_flag
  ENDIF
  , begin_level = apgr.begin_level
  FROM (dummyt d  WITH seq = value(p_spec_cnt)),
   ap_processing_grp_r apgr,
   ap_task_assay_addl ataa,
   profile_task_r ptr
  PLAN (d)
   JOIN (apgr
   WHERE (protocol->spec[d.seq].protocol_id != 0.0)
    AND (protocol->spec[d.seq].protocol_id=apgr.parent_entity_id)
    AND apgr.parent_entity_name="AP_SPECIMEN_PROTOCOL")
   JOIN (ptr
   WHERE ptr.task_assay_cd=apgr.task_assay_cd
    AND 1=ptr.active_ind
    AND cnvtdatetime(curdate,curtime3) BETWEEN ptr.beg_effective_dt_tm AND ptr.end_effective_dt_tm)
   JOIN (ataa
   WHERE ptr.task_assay_cd=ataa.task_assay_cd)
  ORDER BY d.seq, begin_section, begin_level,
   inventory_flag DESC
  HEAD REPORT
   dtaskcnt = 0
  HEAD d.seq
   dtaskcnt = 0
  DETAIL
   dtaskcnt = (dtaskcnt+ 1)
   IF ((dtaskcnt > protocol->max_task_cnt))
    protocol->max_task_cnt = dtaskcnt
   ENDIF
   IF (dtaskcnt > size(protocol->spec[d.seq].task,5))
    stat = alterlist(protocol->spec[d.seq].task,dtaskcnt)
   ENDIF
   protocol->spec[d.seq].task[dtaskcnt].task_assay_cd = apgr.task_assay_cd, protocol->spec[d.seq].
   task[dtaskcnt].begin_section = apgr.begin_section, protocol->spec[d.seq].task[dtaskcnt].
   begin_level = apgr.begin_level,
   protocol->spec[d.seq].task[dtaskcnt].create_inventory_flag = ataa.create_inventory_flag, protocol
   ->spec[d.seq].task[dtaskcnt].stain_ind = ataa.stain_ind, protocol->spec[d.seq].task[dtaskcnt].
   t_no_charge_ind = apgr.no_charge_ind,
   protocol->spec[d.seq].task[dtaskcnt].task_type_flag = ataa.task_type_flag
  WITH nocounter
 ;end select
END GO
