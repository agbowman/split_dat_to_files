CREATE PROGRAM bhs_gvw_followup:dba
 DECLARE ms_rhead = vc WITH protect, constant(
  "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss MS Sans Serif;}}\plain \f0 \fs18 ")
 DECLARE ms_reol = vc WITH protect, constant("\par ")
 DECLARE ms_reop = vc WITH protect, constant("\pard ")
 DECLARE ms_rh2r = vc WITH protect, constant("\pard\plain\f0\fs18 ")
 DECLARE ms_rh2b = vc WITH protect, constant("\pard\plain\f0\fs18\b ")
 DECLARE ms_rh2bu = vc WITH protect, constant("\pard\plain\f0\fs18\b\ul ")
 DECLARE ms_rh2u = vc WITH protect, constant("\pard\plain\f0\fs18\u ")
 DECLARE ms_rh2i = vc WITH protect, constant("\pard\plain\f0\fs18\i ")
 DECLARE ms_rtab = vc WITH protect, constant("\tab ")
 DECLARE ms_rbopt = vc WITH protect, constant(
  "\pard \tx1200\tx1900\tx2650\tx3325\tx3800\tx4400\tx5050\tx5750\tx6500 ")
 DECLARE ms_wr = vc WITH protect, constant("\plain\f0\fs18 ")
 DECLARE ms_wb = vc WITH protect, constant("\plain\f0\fs18\b ")
 DECLARE ms_wu = vc WITH protect, constant("\plain\f0\fs18 \ul\b ")
 DECLARE ms_wbi = vc WITH protect, constant("\plain\f0\fs18\b\i ")
 DECLARE ms_ws = vc WITH protect, constant("\plain\f0\fs18\strike ")
 DECLARE ms_hi = vc WITH protect, constant("\pard\fi-2340\li2340 ")
 DECLARE ms_rtfeof = vc WITH protect, constant("}")
 SET reply->text = ms_rhead
 SELECT INTO "nl:"
  physician_name2 = trim(pedf.provider_name), comment = trim(cmmt.long_text), followup_in = pedf
  .fol_within_days,
  followup_by = format(pedf.fol_within_dt_tm,"MM/DD/YYYY HH:MM"), followup_by_len = size(trim(format(
     pedf.fol_within_dt_tm,"MM/DD/YYYY HH:MM"))), days_or_weeks = pedf.days_or_weeks,
  followup_within = trim(pedf.fol_within_range), only_if_needed = pedf.followup_needed_ind
  FROM pat_ed_document ped,
   pat_ed_doc_followup pedf,
   prsnl p,
   long_text addr,
   long_text cmmt,
   prsnl_group_reltn pgr,
   prsnl_group pg
  PLAN (ped
   WHERE (ped.encntr_id=request->visit[1].encntr_id))
   JOIN (pedf
   WHERE pedf.pat_ed_doc_id=ped.pat_ed_document_id
    AND pedf.active_ind=1
    AND pedf.pat_ed_doc_followup_id > 0.00)
   JOIN (p
   WHERE (p.person_id= Outerjoin(pedf.provider_id)) )
   JOIN (addr
   WHERE (addr.long_text_id= Outerjoin(pedf.add_long_text_id)) )
   JOIN (cmmt
   WHERE (cmmt.long_text_id= Outerjoin(pedf.cmt_long_text_id)) )
   JOIN (pgr
   WHERE (pgr.person_id= Outerjoin(p.person_id))
    AND (pgr.active_ind= Outerjoin(1)) )
   JOIN (pg
   WHERE (pg.prsnl_group_id= Outerjoin(pgr.prsnl_group_id))
    AND (pg.prsnl_group_class_cd= Outerjoin(678635))
    AND (pg.active_ind= Outerjoin(1)) )
  ORDER BY pedf.updt_dt_tm DESC, pedf.pat_ed_doc_followup_id DESC
  HEAD REPORT
   reply->text = concat(reply->text,ms_rh2b,"\tx4000\tx7000\tx4000\tx10000"), reply->text = concat(
    reply->text,ms_wb,"{Added Follow Up} ",ms_rtab,ms_wb,
    "{Time Frame} ",ms_rtab,ms_wb,"{Comments} ",ms_rtab), reply->text = concat(reply->text,ms_reol)
  HEAD pedf.pat_ed_doc_followup_id
   IF (size(comment) > 0)
    provider_comment = comment
   ELSE
    provider_comment = ""
   ENDIF
   CALL echo(build2("provider_comment: ",provider_comment))
   IF (followup_within > " ")
    provider_when = trim(followup_within)
   ELSEIF (followup_in > 0)
    IF (days_or_weeks=3)
     provider_when = concat(cnvtstring(followup_in,3)," Years")
    ELSEIF (days_or_weeks=2)
     provider_when = concat(cnvtstring(followup_in,3)," Months")
    ELSEIF (days_or_weeks=1)
     provider_when = concat(cnvtstring(followup_in,3)," Weeks")
    ELSEIF (days_or_weeks <= 0)
     provider_when = concat(cnvtstring(followup_in,3)," Days")
    ENDIF
   ELSEIF (findstring("/",trim(followup_by)) > 0)
    IF (followup_by_len <= 11)
     provider_when = trim(followup_by)
    ELSE
     provider_when = trim(followup_by)
    ENDIF
   ELSE
    provider_when = " "
   ENDIF
   IF (only_if_needed != 0
    AND provider_when > " ")
    provider_when = concat(provider_when," Only if Needed.")
   ELSEIF (only_if_needed != 0)
    provider_when = "Only if Needed."
   ENDIF
   reply->text = concat(reply->text,ms_rh2b,"\tx4000\tx7000\tx4000\tx10000"), reply->text = concat(
    reply->text,ms_wr,"{",trim(physician_name2),"}",
    ms_rtab,ms_wr,"{",trim(provider_when),"}",
    ms_rtab,ms_wr,"{",trim(provider_comment),"}",
    ms_rtab), reply->text = concat(reply->text,ms_reol)
  WITH nocounter
 ;end select
 SET reply->text = concat(reply->text,ms_rtfeof)
 CALL echo(reply->text)
#exit_script
 SET reply->status_data.status = "S"
END GO
