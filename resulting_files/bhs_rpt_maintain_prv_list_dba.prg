CREATE PROGRAM bhs_rpt_maintain_prv_list:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "AHMP ADD Providers" = 0,
  "CHMP ADD Providers" = 0,
  "ADD ICU Provider" = 0,
  "Remove Providers from which list?" = "",
  "Remove provider" = 0
  WITH outdev, prompt1, prompt2,
  prompt4, s_remove_from, f_remove
 FREE RECORD temp
 RECORD temp(
   1 ahmp[*]
     2 pid = vc
     2 prsnlid = f8
     2 name = vc
     2 team = c4
     2 n_exists = i2
     2 l_active_ind = i4
   1 chmp[*]
     2 pid = vc
     2 prsnlid = f8
     2 name = vc
     2 team = c4
     2 n_exists = i2
     2 l_active_ind = i4
   1 icu[*]
     2 pid = vc
     2 prsnlid = f8
     2 name = vc
     2 team = c4
     2 n_exists = i2
     2 l_active_ind = i4
   1 remove[*]
     2 pid = vc
     2 prsnlid = f8
     2 name = vc
     2 team = c4
     2 n_exists = i2
 )
 SELECT INTO "nl:"
  FROM prsnl pr
  PLAN (pr
   WHERE (pr.person_id= $PROMPT1)
    AND pr.person_id > 0)
  HEAD REPORT
   cnt1 = 0
  DETAIL
   cnt1 = (cnt1+ 1), stat = alterlist(temp->ahmp,cnt1), temp->ahmp[cnt1].name = trim(pr
    .name_full_formatted),
   temp->ahmp[cnt1].prsnlid = pr.person_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(temp->ahmp,5))),
   bhs_physician_team b
  PLAN (d)
   JOIN (b
   WHERE (b.person_id=temp->ahmp[d.seq].prsnlid)
    AND b.team="AHMP")
  HEAD b.person_id
   temp->ahmp[d.seq].n_exists = 1, temp->ahmp[d.seq].l_active_ind = b.active_ind
  WITH nocounter
 ;end select
 FOR (x = 1 TO size(temp->ahmp,5))
   IF ((temp->ahmp[x].prsnlid > 0))
    IF ((temp->ahmp[x].n_exists=0))
     INSERT  FROM bhs_physician_team phy
      SET phy.active_ind = 1, phy.name = temp->ahmp[x].name, phy.person_id = temp->ahmp[x].prsnlid,
       phy.updt_dt_tm = sysdate, phy.updt_id = reqinfo->updt_id, phy.team = "AHMP"
      WITH nocounter
     ;end insert
    ELSEIF ((temp->ahmp[x].l_active_ind=0))
     UPDATE  FROM bhs_physician_team phy
      SET phy.active_ind = 1, phy.updt_dt_tm = sysdate, phy.updt_id = reqinfo->updt_id,
       phy.name = temp->ahmp[x].name
      WHERE (phy.person_id=temp->ahmp[x].prsnlid)
       AND phy.active_ind=0
       AND phy.team="AHMP"
      WITH nocounter
     ;end update
    ENDIF
    COMMIT
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM prsnl pr
  PLAN (pr
   WHERE (pr.person_id= $PROMPT2)
    AND pr.person_id > 0)
  HEAD REPORT
   cnt1 = 0
  DETAIL
   cnt1 = (cnt1+ 1), stat = alterlist(temp->chmp,cnt1), temp->chmp[cnt1].name = trim(pr
    .name_full_formatted),
   temp->chmp[cnt1].prsnlid = pr.person_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(temp->chmp,5))),
   bhs_physician_team b
  PLAN (d)
   JOIN (b
   WHERE (b.person_id=temp->chmp[d.seq].prsnlid)
    AND b.team="CHMP")
  HEAD b.person_id
   temp->chmp[d.seq].n_exists = 1, temp->chmp[d.seq].l_active_ind = b.active_ind
  WITH nocounter
 ;end select
 IF (size(temp->chmp,5) > 0)
  FOR (x = 1 TO size(temp->chmp,5))
    IF ((temp->chmp[x].prsnlid > 0))
     IF ((temp->chmp[x].n_exists=0))
      INSERT  FROM bhs_physician_team phy
       SET phy.active_ind = 1, phy.name = temp->chmp[x].name, phy.person_id = temp->chmp[x].prsnlid,
        phy.updt_dt_tm = sysdate, phy.updt_id = reqinfo->updt_id, phy.team = "CHMP"
       WITH nocounter
      ;end insert
     ELSEIF ((temp->chmp[x].l_active_ind=0))
      UPDATE  FROM bhs_physician_team phy
       SET phy.active_ind = 1, phy.updt_dt_tm = sysdate, phy.updt_id = reqinfo->updt_id,
        phy.name = temp->chmp[x].name
       WHERE (phy.person_id=temp->chmp[x].prsnlid)
        AND phy.active_ind=0
        AND phy.team="CHMP"
       WITH nocounter
      ;end update
     ENDIF
     COMMIT
    ENDIF
  ENDFOR
 ENDIF
 SELECT INTO "nl:"
  FROM prsnl pr
  PLAN (pr
   WHERE (pr.person_id= $PROMPT4)
    AND pr.person_id > 0)
  HEAD REPORT
   cnt1 = 0
  DETAIL
   cnt1 = (cnt1+ 1), stat = alterlist(temp->icu,cnt1), temp->icu[cnt1].name = trim(pr
    .name_full_formatted),
   temp->icu[cnt1].prsnlid = pr.person_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(temp->icu,5))),
   bhs_physician_team b
  PLAN (d)
   JOIN (b
   WHERE (b.person_id=temp->icu[d.seq].prsnlid)
    AND b.team="ICU")
  HEAD b.person_id
   temp->icu[d.seq].n_exists = 1, temp->icu[d.seq].l_active_ind = b.active_ind
  WITH nocounter
 ;end select
 IF (size(temp->icu,5) > 0)
  FOR (x = 1 TO size(temp->icu,5))
    IF ((temp->icu[x].prsnlid > 0))
     IF ((temp->icu[x].n_exists=0))
      INSERT  FROM bhs_physician_team phy
       SET phy.active_ind = 1, phy.name = temp->icu[x].name, phy.person_id = temp->icu[x].prsnlid,
        phy.updt_dt_tm = sysdate, phy.updt_id = reqinfo->updt_id, phy.team = "ICU"
       WITH nocounter
      ;end insert
     ELSEIF ((temp->icu[x].l_active_ind=0))
      UPDATE  FROM bhs_physician_team phy
       SET phy.active_ind = 1, phy.updt_dt_tm = sysdate, phy.updt_id = reqinfo->updt_id,
        phy.name = temp->icu[x].name
       WHERE (phy.person_id=temp->icu[x].prsnlid)
        AND phy.active_ind=0
        AND phy.team="ICU"
       WITH nocounter
      ;end update
     ENDIF
     COMMIT
    ENDIF
  ENDFOR
 ENDIF
 SELECT INTO "nl:"
  FROM prsnl pr
  PLAN (pr
   WHERE (pr.person_id= $F_REMOVE)
    AND pr.person_id > 0)
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   pl_cnt = (pl_cnt+ 1), stat = alterlist(temp->remove,pl_cnt), temp->remove[pl_cnt].name = trim(pr
    .name_full_formatted),
   temp->remove[pl_cnt].prsnlid = pr.person_id
  WITH nocounter
 ;end select
 IF (size(temp->remove,5) > 0)
  FOR (x = 1 TO size(temp->remove,5))
    IF ((temp->remove[x].prsnlid > 0))
     UPDATE  FROM bhs_physician_team phy
      SET phy.active_ind = 0, phy.updt_dt_tm = sysdate, phy.updt_id = reqinfo->updt_id
      WHERE (phy.person_id=temp->remove[x].prsnlid)
       AND (phy.team= $S_REMOVE_FROM)
      WITH nocounter
     ;end update
     COMMIT
    ENDIF
  ENDFOR
 ENDIF
 SELECT INTO  $1
  phy.team, phy.name, phy.active_ind,
  phy.person_id, phy.updt_dt_tm, phy.updt_id
  FROM bhs_physician_team phy
  PLAN (phy
   WHERE phy.updt_id > 0
    AND phy.active_ind=1)
  ORDER BY phy.team, phy.name
  WITH nocounter, format, separator = " "
 ;end select
END GO
