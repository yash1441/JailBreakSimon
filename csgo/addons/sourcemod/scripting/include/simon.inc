#if defined _simon_included
  #endinput
#endif
#define _simon_included

/*********************************************************
 * Checks if any simon exist
 *
 * @true on match , false if not
 *********************************************************/
native simon_exist();

/*********************************************************
 * returns if client is simon
 *
 * @param client		The client to run the check on
 * @true on match, false if not		
 *********************************************************/
native simon_issimon(client);

/*********************************************************
 * Set a client as simon
 *
 * @param client		The client to set as simon
 * @NoReturn
 *********************************************************/
native simon_set(client);

/*********************************************************
 * Removes the current simon if he exists
 *
 * @param client		The simon client to remove
 * @NoReturn	
 *********************************************************/
native simon_remove(client);