#! /bin/sh
#
#
# This script completes the constants.c_pre file with the
# the list of defines needed to build the adasockets constant
# package.
#
# This file is part of Adasockets for RTEMS.
#

if [ $# -ne 2 ] ; then
  echo $0: constantsFile outputFile
  exit 1
fi

constantListFile=$1
outputFile=$2

cat >${outputFile} <<EOF
/*
 * This is an incomplete C program preamble aimed to extract
 * constants' values. The complete source is generated by 
 * create_constants_c.sh.
 *
 * NOTE: THIS CODE IS SPECIFIC TO RTEMS
 *
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <ctype.h>
#include <sys/fcntl.h>
#include <sys/ioccom.h>
#include <sys/filio.h>

#include <netdb.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <net/if.h>


static char *
capitalize (char *name)
{
  int  beginning = 1;
  char *result   = (char *) malloc (strlen (name) + 1);
  char *ptr;
  for (ptr = result; *name; ptr++, name++) {
    *ptr = *name;
    if (beginning) {
      beginning = 0;
    } else if (*ptr == '_') {
      beginning = 1;
    } else if (isupper(*ptr)) {
      *ptr = tolower(*ptr);
    }
  }
  *ptr = '\0';
  return result;
}

static void
output (char *name, int value)
{
  char *capitalized = capitalize (name);
  if (value != -1) {
    printf ("   %-20s : constant := 16#%04X#;\n", capitalized, value);
  } else {
    printf ("   %-20s : constant := %d;\n", capitalized, value);
  }
}

void print_body(void);

void print_socket_constants_ads( void )
{
  printf(
    "--  This file has been generated automatically by\n"
    "--  the constants.c file generated by create_constants_c.sh.\n"
    "--\n"
    "--  This file is part of adasockets port to RTEMS.\n"
    "--\n"
    "\n"
    "package sockets.constants is\n"
  );
  print_body();
  printf( "end sockets.constants;\n");
}

void print_body()
{
EOF

#
#  Now generate the body of the function that acr
#
while read line 
do
  echo "#ifdef ${line}"
  echo "  output( \"${line}\", ${line});"
  echo "#else"
  echo "  output( \"${line}\", -1);"
  echo "#endif"
done < ${constantListFile} >>${outputFile}

echo "}" >>${outputFile}
exit 0