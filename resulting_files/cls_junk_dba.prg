CREATE PROGRAM cls_junk:dba
 SELECT
  sn.sticky_note_type_cd, sn.sticky_note_text, sn.parent_entity_id,
  pr.name_full_formatted
  FROM sticky_note sn,
   prsnl pr
  PLAN (sn
   WHERE 947957=sn.parent_entity_id
    AND sn.sticky_note_type_cd=3963)
   JOIN (pr
   WHERE sn.updt_id=pr.person_id)
  ORDER BY sn.sticky_note_id
 ;end select
END GO
