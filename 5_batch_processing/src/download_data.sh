#!/bin/bash

for TAXI_TYPE in yellow green
do
    for YEAR in 2020 2021
    do
        for MONTH in {1..12}
        do
            FMONTH="$(printf "%02d" ${MONTH})"
            echo "processing ${COLOUR}_${YEAR}_${FMONTH}"

            LOCAL_FILE="${TAXI_TYPE}_tripdata_${YEAR}-${FMONTH}.parquet"
            URL=https://d37ci6vzurychx.cloudfront.net/trip-data/${LOCAL_FILE}
            LOCAL_PATH=~/tmp/data/raw/${TAXI_TYPE}/${YEAR}/${FMONTH}    
            mkdir -p ${LOCAL_PATH}
            wget ${URL} -O ${LOCAL_PATH}/${LOCAL_FILE}
        done
    done
done

