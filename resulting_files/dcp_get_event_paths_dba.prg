CREATE PROGRAM dcp_get_event_paths:dba
 FREE RECORD reply
 RECORD reply(
   1 start_cd = f8
   1 start_desc = c60
   1 start_disp = c40
   1 type_flag = i2
   1 event_set_name = vc
   1 path_cnt = i4
   1 paths[*]
     2 complete_ind = i2
     2 link_cnt = i4
     2 links[*]
       3 event_set_cd = f8
       3 event_set_desc = c60
       3 event_set_disp = c40
       3 type_flag = i2
       3 event_set_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD parents
 RECORD parents(
   1 par_cnt = i4
   1 par[*]
     2 event_set_cd = f8
     2 event_set_disp = c40
     2 event_set_desc = c60
     2 event_set_name = vc
 )
 DECLARE event_set = i2 WITH public, constant(0)
 DECLARE prim_event_set = i2 WITH public, constant(1)
 DECLARE event_code = i2 WITH public, constant(2)
 DECLARE orphan = i2 WITH public, constant(3)
 DECLARE non_chartable = i2 WITH public, constant(4)
 DECLARE adopted = i2 WITH public, constant(9)
 DECLARE complete = i2 WITH public, constant(1)
 DECLARE incomplete = i2 WITH public, constant(0)
 DECLARE script_version = vc WITH public, noconstant(" ")
 DECLARE failed = c1 WITH public, noconstant("F")
 DECLARE continue_ind = i2 WITH public, noconstant(1)
 DECLARE orphan_ind = i2 WITH public, noconstant(0)
 DECLARE nonchart_ind = i2 WITH public, noconstant(0)
 DECLARE adopted_ind = i2 WITH public, noconstant(0)
 DECLARE name_key = vc WITH public, noconstant(" ")
 SET reply->status_data.status = "F"
 SET failed = "F"
 IF ((request->start_cd <= 0.0))
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SET continue_ind = true
 SET orphan_ind = false
 SET nonchart_ind = false
 SET adopted_ind = false
 SET parse_str = ""
 SET reply->start_cd = request->start_cd
 SET reply->path_cnt = 0
 IF ((request->type_ind=event_set))
  SELECT INTO "nl:"
   vesc.event_set_cd_descr, vesc.event_set_cd_disp
   FROM v500_event_set_code vesc
   WHERE (vesc.event_set_cd=request->start_cd)
   DETAIL
    reply->start_disp = vesc.event_set_cd_disp, reply->start_desc = vesc.event_set_cd_descr, reply->
    event_set_name = vesc.event_set_name
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   vesc.parent_event_set_cd
   FROM v500_event_set_canon vesc
   WHERE (vesc.parent_event_set_cd=request->start_cd)
   WITH nocounter
  ;end select
  IF (curqual < 1)
   SET reply->type_flag = prim_event_set
  ELSE
   SET reply->type_flag = event_set
  ENDIF
  SELECT INTO "nl:"
   vesn.parent_event_set_cd
   FROM v500_event_set_canon vesn,
    v500_event_set_code vesc
   PLAN (vesn
    WHERE (vesn.event_set_cd=request->start_cd))
    JOIN (vesc
    WHERE vesc.event_set_cd=vesn.parent_event_set_cd)
   HEAD REPORT
    parents->par_cnt = 0
   DETAIL
    parents->par_cnt = (parents->par_cnt+ 1)
    IF (mod(parents->par_cnt,10)=1)
     stat = alterlist(parents->par,(parents->par_cnt+ 9))
    ENDIF
    parents->par[parents->par_cnt].event_set_cd = vesn.parent_event_set_cd, parents->par[parents->
    par_cnt].event_set_disp = vesc.event_set_cd_disp, parents->par[parents->par_cnt].event_set_desc
     = vesc.event_set_cd_descr,
    parents->par[parents->par_cnt].event_set_name = vesc.event_set_name
   FOOT REPORT
    stat = alterlist(parents->par,parents->par_cnt)
   WITH nocounter, nullreport
  ;end select
  IF ((parents->par_cnt > 0))
   FOR (x = 1 TO parents->par_cnt)
     SET reply->path_cnt = (reply->path_cnt+ 1)
     SET stat = alterlist(reply->paths,reply->path_cnt)
     SET reply->paths[reply->path_cnt].link_cnt = (reply->paths[reply->path_cnt].link_cnt+ 1)
     SET stat = alterlist(reply->paths[reply->path_cnt].links,reply->paths[reply->path_cnt].link_cnt)
     SET reply->paths[reply->path_cnt].links[reply->paths[reply->path_cnt].link_cnt].event_set_cd =
     parents->par[x].event_set_cd
     SET reply->paths[reply->path_cnt].links[reply->paths[reply->path_cnt].link_cnt].event_set_disp
      = parents->par[x].event_set_disp
     SET reply->paths[reply->path_cnt].links[reply->paths[reply->path_cnt].link_cnt].event_set_desc
      = parents->par[x].event_set_desc
     SET reply->paths[reply->path_cnt].links[reply->paths[reply->path_cnt].link_cnt].event_set_name
      = parents->par[x].event_set_name
     SET reply->paths[reply->path_cnt].links[reply->paths[reply->path_cnt].link_cnt].type_flag =
     event_set
   ENDFOR
  ELSE
   RETURN(true)
  ENDIF
 ELSE
  SELECT INTO "nl:"
   vec.event_cd_descr, vec.event_cd_disp, vesc_status = decode(vesc.seq,"VESC","NONE"),
   vesn_ind = nullind(vesn.parent_event_set_cd), vese_ind = nullind(vese.event_set_cd)
   FROM v500_event_code vec,
    v500_event_set_code vesc,
    v500_event_set_canon vesn,
    v500_event_set_explode vese,
    (dummyt d  WITH seq = 1)
   PLAN (vec
    WHERE (vec.event_cd=request->start_cd))
    JOIN (d
    WHERE assign(name_key,cnvtalphanum(cnvtupper(vec.event_set_name))))
    JOIN (vesc
    WHERE vesc.event_set_name_key=name_key
     AND cnvtupper(vesc.event_set_name)=cnvtupper(vec.event_set_name)
     AND (vesc.code_status_cd=reqdata->active_status_cd))
    JOIN (vesn
    WHERE vesn.parent_event_set_cd=outerjoin(vesc.event_set_cd))
    JOIN (vese
    WHERE vese.event_set_cd=outerjoin(vesc.event_set_cd))
   DETAIL
    reply->start_disp = vec.event_cd_disp, reply->start_desc = vec.event_cd_descr
    IF (((vesc_status="NONE") OR (vese_ind=1)) )
     orphan_ind = true
    ELSE
     IF ( NOT (vesn_ind))
      adopted_ind = true
     ENDIF
    ENDIF
    IF (((vec.event_set_name <= " ") OR (vec.event_set_name=null)) )
     nonchart_ind = true
    ENDIF
   WITH nocounter, outerjoin = d
  ;end select
  SET reply->type_flag = event_code
  IF (((nonchart_ind) OR (((orphan_ind) OR (adopted_ind)) )) )
   SET reply->path_cnt = (reply->path_cnt+ 1)
   SET stat = alterlist(reply->paths,reply->path_cnt)
   SET reply->paths[reply->path_cnt].link_cnt = (reply->paths[reply->path_cnt].link_cnt+ 1)
   SET stat = alterlist(reply->paths[reply->path_cnt].links,reply->paths[reply->path_cnt].link_cnt)
   IF (orphan_ind)
    SET reply->paths[reply->path_cnt].links[reply->paths[reply->path_cnt].link_cnt].type_flag =
    orphan
    SET reply->paths[reply->path_cnt].links[reply->paths[reply->path_cnt].link_cnt].event_set_disp =
    "Event Codes with non-existent parents"
   ENDIF
   IF (nonchart_ind)
    SET reply->paths[reply->path_cnt].links[reply->paths[reply->path_cnt].link_cnt].type_flag =
    non_chartable
    SET reply->paths[reply->path_cnt].links[reply->paths[reply->path_cnt].link_cnt].event_set_disp =
    "Event Codes with no parents"
   ENDIF
   IF (adopted_ind)
    SET reply->paths[reply->path_cnt].links[reply->paths[reply->path_cnt].link_cnt].type_flag =
    adopted
    SET reply->paths[reply->path_cnt].links[reply->paths[reply->path_cnt].link_cnt].event_set_disp =
    "Event Codes with non-primitive parents"
   ENDIF
   RETURN(true)
  ENDIF
  SELECT INTO "nl:"
   vesc.event_set_cd, vesn_ind = nullind(vesn.parent_event_set_cd)
   FROM v500_event_code vec,
    v500_event_set_explode vese,
    v500_event_set_code vesc,
    v500_event_set_canon vesn
   PLAN (vec
    WHERE (vec.event_cd=request->start_cd))
    JOIN (vese
    WHERE vese.event_cd=vec.event_cd)
    JOIN (vesc
    WHERE vesc.event_set_cd=vese.event_set_cd
     AND  NOT ( EXISTS (
    (SELECT
     vesn2.parent_event_set_cd
     FROM v500_event_set_canon vesn2
     WHERE vesn2.parent_event_set_cd=vesc.event_set_cd))))
    JOIN (vesn
    WHERE vesn.parent_event_set_cd=outerjoin(vesc.event_set_cd))
   ORDER BY vec.event_cd
   HEAD vec.event_cd
    reply->path_cnt = (reply->path_cnt+ 1), stat = alterlist(reply->paths,reply->path_cnt), reply->
    paths[reply->path_cnt].link_cnt = (reply->paths[reply->path_cnt].link_cnt+ 1),
    stat = alterlist(reply->paths[reply->path_cnt].links,reply->paths[reply->path_cnt].link_cnt),
    reply->paths[reply->path_cnt].links[reply->paths[reply->path_cnt].link_cnt].event_set_cd = vesc
    .event_set_cd, reply->paths[reply->path_cnt].links[reply->paths[reply->path_cnt].link_cnt].
    event_set_disp = vesc.event_set_cd_disp,
    reply->paths[reply->path_cnt].links[reply->paths[reply->path_cnt].link_cnt].event_set_desc = vesc
    .event_set_cd_descr, reply->paths[reply->path_cnt].links[reply->paths[reply->path_cnt].link_cnt].
    event_set_name = vesc.event_set_name
    IF (vesn_ind=0)
     reply->paths[reply->path_cnt].links[reply->paths[reply->path_cnt].link_cnt].type_flag =
     event_set
    ELSE
     reply->paths[reply->path_cnt].links[reply->paths[reply->path_cnt].link_cnt].type_flag =
     prim_event_set
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual < 1)
   RETURN(false)
  ENDIF
 ENDIF
 IF ((reply->path_cnt < 1))
  RETURN(false)
 ENDIF
 WHILE (continue_ind=true)
   FOR (x = 1 TO reply->path_cnt)
     IF ((reply->paths[x].complete_ind=incomplete))
      SELECT INTO "nl:"
       vesn.parent_event_set_cd
       FROM v500_event_set_canon vesn,
        v500_event_set_code vesc
       PLAN (vesn
        WHERE (vesn.event_set_cd=reply->paths[x].links[reply->paths[x].link_cnt].event_set_cd))
        JOIN (vesc
        WHERE vesc.event_set_cd=vesn.parent_event_set_cd)
       HEAD REPORT
        parents->par_cnt = 0
       DETAIL
        parents->par_cnt = (parents->par_cnt+ 1)
        IF (mod(parents->par_cnt,10)=1)
         stat = alterlist(parents->par,(parents->par_cnt+ 9))
        ENDIF
        parents->par[parents->par_cnt].event_set_cd = vesn.parent_event_set_cd, parents->par[parents
        ->par_cnt].event_set_disp = vesc.event_set_cd_disp, parents->par[parents->par_cnt].
        event_set_desc = vesc.event_set_cd_descr,
        parents->par[parents->par_cnt].event_set_name = vesc.event_set_name
       FOOT REPORT
        stat = alterlist(parents->par,parents->par_cnt)
       WITH nocounter, nullreport
      ;end select
      IF ((parents->par_cnt < 1))
       SET reply->paths[x].complete_ind = complete
      ELSEIF ((parents->par_cnt=1))
       SET reply->paths[x].link_cnt = (reply->paths[x].link_cnt+ 1)
       SET stat = alterlist(reply->paths[x].links,reply->paths[x].link_cnt)
       SET reply->paths[x].links[reply->paths[x].link_cnt].event_set_cd = parents->par[1].
       event_set_cd
       SET reply->paths[x].links[reply->paths[x].link_cnt].event_set_disp = parents->par[1].
       event_set_disp
       SET reply->paths[x].links[reply->paths[x].link_cnt].event_set_desc = parents->par[1].
       event_set_desc
       SET reply->paths[x].links[reply->paths[x].link_cnt].event_set_name = parents->par[1].
       event_set_name
       SET reply->paths[x].links[reply->paths[x].link_cnt].type_flag = event_set
      ELSE
       SET reply->paths[x].link_cnt = (reply->paths[x].link_cnt+ 1)
       SET stat = alterlist(reply->paths[x].links,reply->paths[x].link_cnt)
       SET reply->paths[x].links[reply->paths[x].link_cnt].event_set_cd = parents->par[1].
       event_set_cd
       SET reply->paths[x].links[reply->paths[x].link_cnt].event_set_disp = parents->par[1].
       event_set_disp
       SET reply->paths[x].links[reply->paths[x].link_cnt].event_set_desc = parents->par[1].
       event_set_desc
       SET reply->paths[x].links[reply->paths[x].link_cnt].event_set_name = parents->par[1].
       event_set_name
       SET reply->paths[x].links[reply->paths[x].link_cnt].type_flag = event_set
       FOR (y = 2 TO parents->par_cnt)
         SET reply->path_cnt = (reply->path_cnt+ 1)
         SET stat = alterlist(reply->paths,reply->path_cnt)
         SET reply->paths[reply->path_cnt].link_cnt = reply->paths[x].link_cnt
         SET stat = alterlist(reply->paths[reply->path_cnt].links,reply->paths[reply->path_cnt].
          link_cnt)
         FOR (z = 1 TO reply->paths[reply->path_cnt].link_cnt)
           SET reply->paths[reply->path_cnt].links[z].event_set_cd = reply->paths[x].links[z].
           event_set_cd
           SET reply->paths[reply->path_cnt].links[z].event_set_disp = reply->paths[x].links[z].
           event_set_disp
           SET reply->paths[reply->path_cnt].links[z].event_set_desc = reply->paths[x].links[z].
           event_set_desc
           SET reply->paths[reply->path_cnt].links[z].event_set_name = reply->paths[x].links[z].
           event_set_name
           SET reply->paths[reply->path_cnt].links[z].type_flag = reply->paths[x].links[z].type_flag
         ENDFOR
         SET reply->paths[reply->path_cnt].links[reply->paths[reply->path_cnt].link_cnt].event_set_cd
          = parents->par[y].event_set_cd
         SET reply->paths[reply->path_cnt].links[reply->paths[reply->path_cnt].link_cnt].
         event_set_disp = parents->par[y].event_set_disp
         SET reply->paths[reply->path_cnt].links[reply->paths[reply->path_cnt].link_cnt].
         event_set_desc = parents->par[y].event_set_desc
         SET reply->paths[reply->path_cnt].links[reply->paths[reply->path_cnt].link_cnt].
         event_set_name = parents->par[y].event_set_name
         SET reply->paths[reply->path_cnt].links[reply->paths[reply->path_cnt].link_cnt].type_flag =
         event_set
       ENDFOR
      ENDIF
     ENDIF
   ENDFOR
   SELECT INTO "nl:"
    reply->paths[d.seq].complete_ind
    FROM (dummyt d  WITH seq = value(reply->path_cnt))
    WHERE (reply->paths[d.seq].complete_ind=incomplete)
    WITH nocounter
   ;end select
   IF (curqual < 1)
    SET continue_ind = false
   ENDIF
 ENDWHILE
 IF ( NOT (stat))
  SET failed = "T"
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
 SET script_version = "000 03/07/07 MH015940"
END GO
