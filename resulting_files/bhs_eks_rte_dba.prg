CREATE PROGRAM bhs_eks_rte:dba
 DECLARE eid = f8 WITH noconstant(0)
 DECLARE oid = f8 WITH noconstant(0)
 DECLARE cid = f8 WITH noconstant(0)
 DECLARE csc = f8 WITH noconstant(0)
 DECLARE aid = f8 WITH noconstant(0)
 DECLARE fin = vc
 DECLARE entityid = vc
 DECLARE entityname = vc
 DECLARE accession = vc
 SET eid = link_encntrid
 SET oid = link_orderid
 SET cid = link_clineventid
 SET aid = link_accessionid
 SET pid = link_personid
 SET retval = 0
 SET nextseq = 0
 SELECT INTO "nl:"
  next_id = seq(bhs_rte_seq,nextval)
  FROM dual
  DETAIL
   nextseq = next_id
  WITH nocounter
 ;end select
 CALL echo(build("nextseq:",nextseq))
 IF (cid > 0)
  SELECT INTO "nl:"
   FROM clinical_event ce
   WHERE ce.clinical_event_id=cid
    AND ce.valid_until_dt_tm > sysdate
    AND ce.view_level=1
   DETAIL
    accession = trim(ce.series_ref_nbr), csc = ce.contributor_system_cd
   WITH nocounter
  ;end select
  CALL echo(build("accession:",accession))
  INSERT  FROM bhs_rte_hold brh
   SET brh.rec_id = nextseq, brh.cont_sys = csc, brh.encntr_id = eid,
    brh.parent_entity_id = accession, brh.parent_entity_name = "SERIES_REF_NBR", brh.insert_dt_tm =
    cnvtdatetime(curdate,curtime3),
    brh.updt_dt_tm = cnvtdatetime(curdate,curtime3), brh.process_flag = 0, brh.updt_cnt = 0
   WITH nocounter
  ;end insert
  COMMIT
  SET retval = 100
  CALL echo(build("cid:",cid))
 ELSEIF (oid > 0)
  SELECT INTO "nl:"
   FROM clinical_event ce
   WHERE ce.order_id=oid
    AND ce.encntr_id=eid
   DETAIL
    csc = ce.contributor_system_cd
   WITH nocounter
  ;end select
  INSERT  FROM bhs_rte_hold brh
   SET brh.rec_id = nextseq, brh.cont_sys = csc, brh.encntr_id = eid,
    brh.parent_entity_id = cnvtstring(oid), brh.parent_entity_name = "ORDER_ID", brh.insert_dt_tm =
    cnvtdatetime(curdate,curtime3),
    brh.updt_dt_tm = cnvtdatetime(curdate,curtime3), brh.process_flag = 0, brh.updt_cnt = 0
   WITH nocounter
  ;end insert
  COMMIT
  SET retval = 100
  CALL echo(build("oid:",oid))
 ENDIF
 SET log_orderid = oid
 SET log_clineventid = cid
 SET log_personid = pid
 SET log_encntrid = eid
 SET log_message = build("oid:",oid,"eid:",eid,"cid:",
  cid,"retval:",retval)
 CALL echo(log_message)
END GO
