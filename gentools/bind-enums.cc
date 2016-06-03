#include <stdio.h>

#include "gcc-plugin.h"
#include "tree.h"

int plugin_is_GPL_compatible;

static void
dump_enum_type (tree enum_type, tree enum_name)
{
  printf ("\"%s\":\n", IDENTIFIER_POINTER (enum_name));

  /* Process all its enumerators.  */
  for (tree v = TYPE_VALUES (enum_type); v != NULL; v = TREE_CHAIN (v))
  {
    /* Get its value if it's a convenient integer, give up otherwise.  */
    char buffer[128] = "\"<big integer>\"";
    if (tree_fits_shwi_p (TREE_VALUE (v)))
      {
	long l = tree_to_shwi (TREE_VALUE (v));
	snprintf (buffer, 128, "%li", l);
      }

    printf ("  \"%s\": %s\n",
	    IDENTIFIER_POINTER (TREE_PURPOSE (v)),
	    buffer);
  }
}

static void
handle_finish_type (void *gcc_data, void *user_data)
{
  (void) user_data;
  tree t = (tree) gcc_data;

  /* Skip everything that is not a named enumeration type.  */
  if (TREE_CODE (t) != ENUMERAL_TYPE
      || TYPE_NAME (t) == NULL)
    return;

  dump_enum_type (t, TYPE_NAME (t));
}

static void
handle_finish_decl (void *gcc_data, void *user_data)
{
  (void) user_data;
  tree t = (tree) gcc_data;
  tree type = TREE_TYPE (t);

  /* Skip everything that is not a typedef for an enumeration type.  */
  if (TREE_CODE (t) != TYPE_DECL
      || TREE_CODE (type) != ENUMERAL_TYPE)
    return;

  dump_enum_type (type, DECL_NAME (t));
}

int
plugin_init (struct plugin_name_args *plugin_info,
	     struct plugin_gcc_version *version)
{
  const char *plugin_name = plugin_info->base_name;
  struct plugin_info pi = { "0.1", "Enum binder plugin" };

  (void) version;

  register_callback (plugin_name, PLUGIN_INFO, NULL, &pi);
  register_callback (plugin_name, PLUGIN_FINISH_TYPE,
		     &handle_finish_type, NULL);
  register_callback (plugin_name, PLUGIN_FINISH_DECL,
		     &handle_finish_decl, NULL);

  return 0;
}
