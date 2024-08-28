# CBRS Domain Coordinator

## EP5G

### Configuration

CBRS DC requires a running PostgreSQL database to start.
The init container init-sfwkdb will set up the required tables, this assumes the property 'postgresql01_admin_password' is set to 'postgresql01'

### CBRS DC Installation on Customer Premise Equipment (CPE)

1. Install Postgres used by Domain Coordinator
    ><code>helm install ic-postgres ic-postgres/  --set postgresql.password=postgresql01 --set resources.limits.hugepages-2Mi=null --set resources.requests.hugepages-2Mi=null --set fullnameOverride=eric-data-document-database-pg-dc --create-namespace -n dc</code>
                                                  
2. Docker images

Following images must be available on the CPE:
- armdocker.rnd.ericsson.se/proj-eric-cbrs-dc-drop/eric-cbrs-dc-init:latest
- armdocker.rnd.ericsson.se/proj-eric-cbrs-dc-drop/eric-cbrs-dc:latest
- armdocker.rnd.ericsson.se/proj-enm/eric-enm-sfwkdb-schemamgt:latest

Pull them locally and save to tar file and use sftp to get them to CPE
Example:
  ><code>docker save -o eric-cbrs-dc-init.tar armdocker.rnd.ericsson.se/proj-eric-cbrs-dc-drop/eric-cbrs-dc-init:latest</code>
>
  ><code>docker load -i eric-cbrs-dc-init.tar</code>
---
**NOTE:** CSAR is not ready yet so docker images must be used.

---

3. Copy the Helm chart to CPE using sftp

4. Install Helm chart
    ><code>helm install eric-cbrs-dc-chart charts/eric-cbrs-dc/ --values charts/eric-cbrs-dc/values.yaml --create-namespace -n dc</code>

### Installation on K3S locally


1. Build Init image using command:

   ><code>docker build --no-cache -t armdocker.rnd.ericsson.se/proj-enm/eric-enm-init-container:<version>-EP5G docker/eric-cbrs-dc-init/</code>

2. Build Domain Coordinator Main image using command:

   ><code>docker build --no-cache -t armdocker.rnd.ericsson.se/proj-enm/eric-cbrs-dc:<version>-EP5G docker/eric-cbrs-dc/</code>

3. Export the newly built images

   ><code>docker save -o eric-cbrs-dc-ep5g.tar armdocker.rnd.ericsson.se/proj-enm/eric-cbrs-dc:<version>-EP5G</code>

   ><code>docker save -o eric-enm-init-container-ep5g.tar armdocker.rnd.ericsson.se/proj-enm/eric-enm-init-container:1.22.0-15-EP5G</code>

4. Move the exported tar to host where K3S is running

5. Load exported images into K3S internal Docker cache

    ><code>sudo k3s ctr images import eric-cbrs-dc-ep5g.tar</code> 

    ><code>sudo k3s ctr images import eric-enm-init-container-ep5g.tar</code>

   To verify, list the images
    ><code>sudo k3s crictl images</code>

6. Update values.yaml

   Configure use of NodePort by setting service.externalService.type to NodePort
   Disable the init container, init-service, by setting resources.initcontainerService.enabled to false

7. Install Helm chart

   ><code>helm install eric-cbrs-dc-chart charts/eric-cbrs-dc/ --values charts/eric-cbrs-dc/values.yaml --create-namespace -n < any namespace > </code>

   ---
   **NOTE:** When CSAR is ready we will set the following tags --set tags.eric-cbrs-dc-common=false,tags.eric-cbrs-dc-mediation=true

   ---