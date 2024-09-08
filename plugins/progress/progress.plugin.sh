#! bash oh-my-bash.module
############################---Description---###################################
#                                                                              #
# Summary       : Show a progress bar GUI on terminal platform                 #
# Support       : destro.nnt@gmail.com                                         #
# Created date  : Aug 12,2014                                                  #
# Latest Modified date : Aug 13,2014                                           #
#                                                                              #
################################################################################

############################---Usage---#########################################

# Copy below functions (delay and progress fuctions) into your shell script directly
# Then invoke progress function to show progress bar

# In other way, you could import source indirectly then using. Nothing different

################################################################################


#
# Description : delay executing script
#
function delay()
{
  sleep 0.2;
}

#
# Description : print out executing progress
#
CURRENT_PROGRESS=0
function progress()
{
  PARAM_PROGRESS=$1;
  PARAM_STATUS=$2;

  if [ $CURRENT_PROGRESS -le 0 -a $PARAM_PROGRESS -ge 0 ]  ; then printf "[..........................] (0%)  %s \r" "$PARAM_PHASE" ; delay; fi;
  if [ $CURRENT_PROGRESS -le 5 -a $PARAM_PROGRESS -ge 5 ]  ; then printf "[#.........................] (5%)  %s \r" "$PARAM_PHASE" ; delay; fi;
  if [ $CURRENT_PROGRESS -le 10 -a $PARAM_PROGRESS -ge 10 ]; then printf "[##........................] (10%) %s \r" "$PARAM_PHASE" ; delay; fi;
  if [ $CURRENT_PROGRESS -le 15 -a $PARAM_PROGRESS -ge 15 ]; then printf "[###.......................] (15%) %s \r" "$PARAM_PHASE" ; delay; fi;
  if [ $CURRENT_PROGRESS -le 20 -a $PARAM_PROGRESS -ge 20 ]; then printf "[####......................] (20%) %s \r" "$PARAM_PHASE" ; delay; fi;
  if [ $CURRENT_PROGRESS -le 25 -a $PARAM_PROGRESS -ge 25 ]; then printf "[#####.....................] (25%) %s \r" "$PARAM_PHASE" ; delay; fi;
  if [ $CURRENT_PROGRESS -le 30 -a $PARAM_PROGRESS -ge 30 ]; then printf "[######....................] (30%) %s \r" "$PARAM_PHASE" ; delay; fi;
  if [ $CURRENT_PROGRESS -le 35 -a $PARAM_PROGRESS -ge 35 ]; then printf "[#######...................] (35%) %s \r" "$PARAM_PHASE" ; delay; fi;
  if [ $CURRENT_PROGRESS -le 40 -a $PARAM_PROGRESS -ge 40 ]; then printf "[########..................] (40%) %s \r" "$PARAM_PHASE" ; delay; fi;
  if [ $CURRENT_PROGRESS -le 45 -a $PARAM_PROGRESS -ge 45 ]; then printf "[#########.................] (45%) %s \r" "$PARAM_PHASE" ; delay; fi;
  if [ $CURRENT_PROGRESS -le 50 -a $PARAM_PROGRESS -ge 50 ]; then printf "[##########................] (50%) %s \r" "$PARAM_PHASE" ; delay; fi;
  if [ $CURRENT_PROGRESS -le 55 -a $PARAM_PROGRESS -ge 55 ]; then printf "[###########...............] (55%) %s \r" "$PARAM_PHASE" ; delay; fi;
  if [ $CURRENT_PROGRESS -le 60 -a $PARAM_PROGRESS -ge 60 ]; then printf "[############..............] (60%) %s \r" "$PARAM_PHASE" ; delay; fi;
  if [ $CURRENT_PROGRESS -le 65 -a $PARAM_PROGRESS -ge 65 ]; then printf "[#############.............] (65%) %s \r" "$PARAM_PHASE" ; delay; fi;
  if [ $CURRENT_PROGRESS -le 70 -a $PARAM_PROGRESS -ge 70 ]; then printf "[###############...........] (70%) %s \r" "$PARAM_PHASE" ; delay; fi;
  if [ $CURRENT_PROGRESS -le 75 -a $PARAM_PROGRESS -ge 75 ]; then printf "[#################.........] (75%) %s \r" "$PARAM_PHASE" ; delay; fi;
  if [ $CURRENT_PROGRESS -le 80 -a $PARAM_PROGRESS -ge 80 ]; then printf "[####################......] (80%) %s \r" "$PARAM_PHASE" ; delay; fi;
  if [ $CURRENT_PROGRESS -le 85 -a $PARAM_PROGRESS -ge 85 ]; then printf "[#######################...] (90%) %s \r" "$PARAM_PHASE" ; delay; fi;
  if [ $CURRENT_PROGRESS -le 90 -a $PARAM_PROGRESS -ge 90 ]; then printf "[##########################] (100%) %s \r" "$PARAM_PHASE"; delay; fi;
  if [ $CURRENT_PROGRESS -le 100 -a $PARAM_PROGRESS -ge 100 ];then printf 'Done!                                            \n' ; delay; fi;

  CURRENT_PROGRESS=$PARAM_PROGRESS;
}
