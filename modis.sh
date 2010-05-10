#!/bin/bash
# http://rapidfire.sci.gsfc.nasa.gov/subsets/?subset=Spain.2010130.terra.250m.jpg&vectors=fires+coast+borders
HOST="http://rapidfire.sci.gsfc.nasa.gov/subsets/?subset="
CAPA="Spain"
FECHA=$(date +%Y%j)
SAT="terra"
RES="250m"
VECTORS="&vectors=fires+coast+borders"
URL="${HOST}${CAPA}.${FECHA}.${SAT}.${RES}.jpg${VECTORS}"
echo $URL
