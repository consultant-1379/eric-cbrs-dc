#! /bin/bash
#
# COPYRIGHT Ericsson 2024
#
# The copyright to the computer program(s) herein is the property of
# Ericsson Inc. The programs may be used and/or copied only with written
# permission from Ericsson Inc. or in accordance with the terms and
# conditions stipulated in the agreement/contract under which the
# program(s) have been supplied.
CBRS="eric-cbrs-dc"
PGDC="eric-data-document-database-pg"
PASS=0
FAIL=0

DC_POD=$(kubectl get pods -n $K8_NAMESPACE | grep ${CBRS} | awk '{print $1 }' | head -1)
DC_IPS=$(kubectl get pods -n $K8_NAMESPACE -o wide | grep ${CBRS} | awk '{print $6 }')
PG_POD=$(kubectl get pods -n $K8_NAMESPACE | grep ${PGDC} | awk '{print $1 }' | head -1)

DATABASE_PG_INGRESS_CLOSED_PORTS=(8443 8558 9600 2500)
PM_SERVER_INGRESS_OPEN_PORT=(9600)
AKKA_PROBING_PORT=25520
DATABASE_PG_EGRESS_OPEN_PORT=(5432)
DATABASE_PG_EGRESS_CLOSED_PORTS=(5024 53 6443 6513 43340)

######################################################################################################################
# Test to check DC to DC communication for AKKA
# Check the server.log within the DC pods to confirm that the AKKA cluster is running
# and all instances of DC are connected.
# ref TMS https://taftm.seli.wh.rnd.internal.ericsson.com/#tm/viewTC/CBRS_TORF-554976_Epic8_Ingress_Ports/version/0.1
######################################################################################################################
Test_DcToDcAkkaConnection() {
  echo "Test: DC Cluster to DC AKKA connections"
  for ip in $DC_IPS; do
    RESULT=$(kubectl exec -i -n $K8_NAMESPACE $DC_POD -c ${CBRS} -- cat /ericsson/3pp/jboss/standalone/log/server.log | grep "$ip:$AKKA_PROBING_PORT, status = Up" | wc -l)
    if [[ $RESULT -gt 0 ]]; then
      ((PASS++))
      echo "Member up event for IP: $ip"
    else
      ((FAIL++))
      echo "No member up event for IP: $ip"
      return 1
    fi
  done
}

######################################################################################################################
# Test to check ingress ports that must be closed for postgres db pod as per network policies defined
# Test will be performed on ports 8443 8558 9600 2500
# ref TMS https://taftm.seli.wh.rnd.internal.ericsson.com/#tm/viewTC/CBRS_TORF-554976_Epic8_Ingress_Ports/version/0.1
######################################################################################################################

Test_ForIngressClosedPortsForPostgresDbPod() {
  echo "Test: Checking INGRESS ports that should be closed to postgres db pod."
  for port in ${DATABASE_PG_INGRESS_CLOSED_PORTS[@]}; do
    RESULT=$(kubectl exec -i -n $K8_NAMESPACE $PG_POD -c $PGDC -- bash -c "if timeout 1 bash -c '</dev/tcp/$CBRS/$port &>/dev/null'; then echo Open; else echo Closed; fi")
    if [[ $RESULT == "Closed" ]]; then
      ((PASS++))
      echo "Pass, Port: $port Closed"
    elif [[ $RESULT == "Open" ]]; then
      ((FAIL++))
      echo "Fail, Port: $port Open"
    else
      ((FAIL++))
      echo "Fail, $RESULT"
    fi
  done
}

######################################################################################################################
# Test to check ingress port that must be open for pm server pod as per network policies defined.
#
# Test will be performed on port 9600.
# In this test we first make changes to postgres db pod to act as pm server,
# then perform port testing.
######################################################################################################################

Test_ForIngressOpenPortForPmServer() {
  RESULT=Closed
  IP_OF_DC_POD=$(echo "$DC_IPS" | head -n 1)
  URL="$IP_OF_DC_POD:$PM_SERVER_INGRESS_OPEN_PORT/metrics"
  echo "The URL of metrics for eric-cbrs-dc: $URL"
  EXPECTED_CONTAINED_STRING="jboss_dh"

  echo "=== Changing app.kubernetes.io/name label Postgres POD to act as eric-pm-server. ===="
  LabelChangeJob=$(kubectl -n $K8_NAMESPACE label --overwrite pods $PG_POD app.kubernetes.io/name=eric-pm-server)
  echo $LabelChangeJob

  OUTPUT=$(kubectl exec -i $PG_POD -n $K8_NAMESPACE -c $PGDC -- curl $URL)
  echo "Retrieved Metric of eric-cbrs-dc pod:"
  echo $OUTPUT

  if [[ "$OUTPUT" == *"$EXPECTED_CONTAINED_STRING"* ]]; then
    RESULT=Open
  else
    RESULT=Closed
  fi

  if [[ $RESULT == "Open" ]]; then
    ((PASS++))
    echo "Pass, Port: $PM_SERVER_INGRESS_OPEN_PORT Open"
  elif [[ $RESULT == "Closed" ]]; then
    ((FAIL++))
    echo "Fail, Port: $PM_SERVER_INGRESS_OPEN_PORT Closed"
  else
    ((FAIL++))
    echo "Fail, $RESULT"
  fi

  echo "=== Change app.kubernetes.io/name label Postgres POD again to eric-data-document-database-pg. ==="
  LabelRevertJob=$(kubectl -n $K8_NAMESPACE label --overwrite pods $PG_POD app.kubernetes.io/name=$PGDC)
  echo $LabelRevertJob
}

######################################################################################################################
# Test to check egress ports that must be open for postgres db pod as per network policies defined.
#
# Test will be performed on port 5432.
######################################################################################################################

Test_ForEgressOpenPortToPostgresDbPod() {
  echo "Test: Checking EGRESS port 5432 that should be open to postgres db pod."
  for port in ${DATABASE_PG_EGRESS_OPEN_PORT[@]}; do
    RESULT=$(kubectl exec -i -n $K8_NAMESPACE $DC_POD -c ${CBRS} -- bash -c "if timeout 1 bash -c '</dev/tcp/$PGDC/$port &>/dev/null'; then echo Open; else echo Closed; fi")
    if [[ $RESULT == "Open" ]]; then
      ((PASS++))
      echo "Pass, Port: $port Open"
    elif [[ $RESULT == "Closed" ]]; then
      ((FAIL++))
      echo "Fail, Port: $port Closed"
    else
      ((FAIL++))
      echo "Fail, $RESULT"
    fi
  done
}

######################################################################################################################
# Test to check egress ports that must be closed to postgres db pod as per network policies defined
# Test will be performed on ports 5024 53 6443 6513 43340
######################################################################################################################

Test_ForEgressClosedPortsForPostgresDbPod() {
  echo "Test: Checking EGRESS ports that should be closed to postgres db pod."
  for port in ${DATABASE_PG_EGRESS_CLOSED_PORTS[@]}; do
    RESULT=$(kubectl exec -i -n $K8_NAMESPACE $DC_POD -c ${CBRS} -- bash -c "if timeout 1 bash -c '</dev/tcp/$PGDC/$port &>/dev/null'; then echo Open; else echo Closed; fi")
    if [[ $RESULT == "Closed" ]]; then
      ((PASS++))
      echo "Pass, Port: $port Closed"
    elif [[ $RESULT == "Open" ]]; then
      ((FAIL++))
      echo "Fail, Port: $port Open"
    else
      ((FAIL++))
      echo "Fail, $RESULT"
    fi
  done
}

echo "========== Start of Network policy ingress/egress port test. =========="

# Ingress port tests
Test_ForIngressClosedPortsForPostgresDbPod
Test_ForIngressOpenPortForPmServer

# Egress port tests
Test_ForEgressOpenPortToPostgresDbPod
Test_ForEgressClosedPortsForPostgresDbPod

# Test AKKA cluster members
sleep 30
Test_DcToDcAkkaConnection

echo "========== Network policy ingress/egress port test completed =========="

echo "NetworkCheck Test Results: Number of Test Failed : $FAIL , Number of Test Passed : $PASS ."

if [[ $FAIL -gt 0 ]]; then
  exit 1
else
  exit 0
fi
