CREATE PROGRAM ccl_menu
 SELECT
  e.menu_id, e.menu_parent_id, e.item_desc,
  e.item_type, e.item_name, e.person_id
  FROM explorer_menu e
  ORDER BY e.menu_id
 ;end select
END GO
