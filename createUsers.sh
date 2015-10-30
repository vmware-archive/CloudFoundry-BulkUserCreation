#!/bin/bash

# Author: Aaron Fortenr
# Email: afortener@pivotal.io

# this will to create a new user org and space using a generic email address
# you need to be logged in as your UAA admin user

# upon completion you will end up with N number of orgs (group1), each with one
# space (development) and a user (user1@client.com) with the defined password
# and each will have one user

ORGPREFIX=group # if this is set to group it will be group1 and so on
CLIENTEMAILDOMAIN=client.com
SPACENAME=development
USERPREFIX=user # user<x>@domain
PASSWORD=password
NUMBEROFUSERS=1 # number of users to create

function createUser {
  cf create-user $1 $2
}

function creatOrgAndSpace {
  cf create-org $1
  cf create-space $SPACENAME -o $1
}

function addUserToOrgRoles {
  cf set-org-role $1 $2 OrgManager
  cf set-org-role $1 $2 OrgAuditor
  cf set-org-role $1 $2 BillingManager
}

function addUserToSpaceRoles {
  cf set-space-role $1 $2 $3 SpaceManager
  cf set-space-role $1 $2 $3 SpaceDeveloper
  cf set-space-role $1 $2 $3 SpaceAuditor
}

# no one probably wants to be named group0, using 1 based index

echo creating $NUMBEROFUSERS users...
COUNTER=1
         while [  $COUNTER -le $NUMBEROFUSERS ]; do
		         #create the user
             USERNAME=$USERPREFIX$COUNTER@$CLIENTEMAILDOMAIN
             createUser $USERNAME $PASSWORD

             #create an org with a development space
             ORGNAME=$ORGPREFIX$COUNTER
             creatOrgAndSpace $ORGNAME

              # add user as org roles
              addUserToOrgRoles $USERNAME $ORGNAME

              # add user to space roles
              addUserToSpaceRoles $USERNAME $ORGNAME $SPACENAME

              #increment counter
             let COUNTER=COUNTER+1
         done

echo done...you are welcome.
