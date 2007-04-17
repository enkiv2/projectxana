

// Copyright (c) 2002 by Digital Mars
// All Rights Reserved
// written by Walter Bright
// www.digitalmars.com
import object;
extern (C):

/********************************
 * Compiler helper for operator == for class objects.
 */

int _d_obj_eq(Object o1, Object o2)
{
    return o1 is o2 ;
}


/********************************
 * Compiler helper for operator <, <=, >, >= for class objects.
 */

int _d_obj_cmp(Object o1, Object o2)
{
    return o1 is o2;
}

