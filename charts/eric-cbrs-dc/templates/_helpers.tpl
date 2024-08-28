{{/* vim: set filetype=mustache: */}}

{{/*
The mainImage Path  (DR-D1121-067)
*/}}
{{- define "eric-cbrs-dc.mainImagePath" }}
    {{- $productInfo := fromYaml (.Files.Get "eric-product-info.yaml") -}}
    {{- $registryUrl := $productInfo.images.mainImage.registry -}}
    {{- $repoPath := $productInfo.images.mainImage.repoPath -}}
    {{- $name := $productInfo.images.mainImage.name -}}
    {{- $tag := $productInfo.images.mainImage.tag -}}
    {{- if .Values.imageCredentials -}}
        {{- if .Values.imageCredentials.mainImage -}}
            {{- if .Values.imageCredentials.mainImage.registry -}}
                {{- if .Values.imageCredentials.mainImage.registry.url -}}
                    {{- $registryUrl = .Values.imageCredentials.mainImage.registry.url -}}
                {{- end -}}
            {{- end -}}
            {{- if not (kindIs "invalid" .Values.imageCredentials.mainImage.tag) -}}
                {{- $tag = .Values.imageCredentials.mainImage.tag -}}
            {{- end -}}
            {{- if not (kindIs "invalid" .Values.imageCredentials.mainImage.repoPath) -}}
                {{- $repoPath = .Values.imageCredentials.mainImage.repoPath -}}
            {{- end -}}
        {{- end -}}
        {{- if not (kindIs "invalid" .Values.imageCredentials.repoPath) -}}
            {{- $repoPath = .Values.imageCredentials.repoPath -}}
        {{- end -}}
    {{- end -}}
    {{- if .Values.global -}}
        {{- if .Values.global.registry -}}
            {{- if .Values.global.registry.url -}}
                {{- $registryUrl = .Values.global.registry.url -}}
            {{- end -}}
            {{- if .Values.global.registry.repoPath -}}
                {{- $repoPath = .Values.global.registry.repoPath -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- if $repoPath -}}
        {{- $repoPath = printf "%s/" $repoPath -}}
    {{- end -}}
    {{- printf "%s/%s%s:%s" $registryUrl $repoPath $name $tag -}}
{{- end -}}

{{/*
The initImage Path  (DR-D1121-067)
*/}}
{{- define "eric-cbrs-dc.initImagePath" }}
    {{- $productInfo := fromYaml (.Files.Get "eric-product-info.yaml") -}}
    {{- $registryUrl := $productInfo.images.initImage.registry -}}
    {{- $repoPath := $productInfo.images.initImage.repoPath -}}
    {{- $name := $productInfo.images.initImage.name -}}
    {{- $tag := $productInfo.images.initImage.tag -}}
    {{- if .Values.imageCredentials -}}
        {{- if .Values.imageCredentials.initImage -}}
            {{- if .Values.imageCredentials.initImage.registry -}}
                {{- if .Values.imageCredentials.initImage.registry.url -}}
                    {{- $registryUrl = .Values.imageCredentials.initImage.registry.url -}}
                {{- end -}}
            {{- end -}}
            {{- if not (kindIs "invalid" .Values.imageCredentials.initImage.tag) -}}
                {{- $tag = .Values.imageCredentials.initImage.tag -}}
            {{- end -}}
            {{- if not (kindIs "invalid" .Values.imageCredentials.initImage.repoPath) -}}
                {{- $repoPath = .Values.imageCredentials.initImage.repoPath -}}
            {{- end -}}
        {{- end -}}
        {{- if not (kindIs "invalid" .Values.imageCredentials.repoPath) -}}
            {{- $repoPath = .Values.imageCredentials.repoPath -}}
        {{- end -}}
    {{- end -}}
    {{- if .Values.global -}}
        {{- if .Values.global.registry -}}
            {{- if .Values.global.registry.url -}}
                {{- $registryUrl = .Values.global.registry.url -}}
            {{- end -}}
            {{- if .Values.global.registry.repoPath -}}
                {{- $repoPath = .Values.global.registry.repoPath -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- if $repoPath -}}
        {{- $repoPath = printf "%s/" $repoPath -}}
    {{- end -}}
    {{- printf "%s/%s%s:%s" $registryUrl $repoPath $name $tag -}}
{{- end -}}

{{/*
The monitoringImage Path  (DR-D1121-067)
*/}}
{{- define "eric-cbrs-dc.monitoringImagePath" }}
    {{- $productInfo := fromYaml (.Files.Get "eric-product-info.yaml") -}}
    {{- $registryUrl := $productInfo.images.monitoringImage.registry -}}
    {{- $repoPath := $productInfo.images.monitoringImage.repoPath -}}
    {{- $name := $productInfo.images.monitoringImage.name -}}
    {{- $tag := $productInfo.images.monitoringImage.tag -}}
    {{- if .Values.imageCredentials -}}
        {{- if .Values.imageCredentials.monitoringImage -}}
            {{- if .Values.imageCredentials.monitoringImage.registry -}}
                {{- if .Values.imageCredentials.monitoringImage.registry.url -}}
                    {{- $registryUrl = .Values.imageCredentials.monitoringImage.registry.url -}}
                {{- end -}}
            {{- end -}}
            {{- if not (kindIs "invalid" .Values.imageCredentials.monitoringImage.tag) -}}
                {{- $tag = .Values.imageCredentials.monitoringImage.tag -}}
            {{- end -}}
            {{- if not (kindIs "invalid" .Values.imageCredentials.monitoringImage.repoPath) -}}
                {{- $repoPath = .Values.imageCredentials.monitoringImage.repoPath -}}
            {{- end -}}
        {{- end -}}
        {{- if not (kindIs "invalid" .Values.imageCredentials.repoPath) -}}
            {{- $repoPath = .Values.imageCredentials.repoPath -}}
        {{- end -}}
    {{- end -}}
    {{- if .Values.global -}}
        {{- if .Values.global.registry -}}
            {{- if .Values.global.registry.url -}}
                {{- $registryUrl = .Values.global.registry.url -}}
            {{- end -}}
            {{- if .Values.global.registry.repoPath -}}
                {{- $repoPath = .Values.global.registry.repoPath -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- if $repoPath -}}
        {{- $repoPath = printf "%s/" $repoPath -}}
    {{- end -}}
    {{- printf "%s/%s%s:%s" $registryUrl $repoPath $name $tag -}}
{{- end -}}

{{/*
Create a map from ".Values.global" with defaults if missing in values file.
This hides defaults from values file.
*/}}
{{ define "eric-cbrs-dc.global" }}
  {{- $globalDefaults := dict "security" (dict "tls" (dict "enabled" true)) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "nodeSelector" (dict)) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "registry" (dict "pullSecret" "eric-cbrs-dc-secret")) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "externalIPv4" (dict "enabled")) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "externalIPv6" (dict "enabled")) -}}
  {{ if .Values.global }}
    {{- mergeOverwrite $globalDefaults .Values.global | toJson -}}
  {{ else }}
    {{- $globalDefaults | toJson -}}
  {{ end }}
{{ end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "eric-cbrs-dc.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Used when "deploymentResources" refer to "sharedResources"
*/}}
{{- define "eric-cbrs-dc.sharedNameReference" -}}
    {{- if .Values.deploymentConfig.deploymentResources.sharedResourcesName -}}
        {{- .Values.deploymentConfig.deploymentResources.sharedResourcesName -}}
    {{- else -}}
        {{- include "eric-cbrs-dc.name" . -}}
    {{- end -}}
{{- end -}}

{{/*
Expand deployment name using sharedNameReference and nameSuffix
*/}}
{{- define "eric-cbrs-dc.deploymentName" -}}
    {{- $templateName := include "eric-cbrs-dc.sharedNameReference" . -}}
    {{- if .Values.deploymentConfig.deploymentResources.nameSuffix -}}
        {{- $stringSuffix := .Values.deploymentConfig.deploymentResources.nameSuffix | toString -}}
        {{/* adding 1 to cover the extra "-" */}}
        {{- $lenSuffix := add (len $stringSuffix) 1 -}}
        {{- $truncLen := (sub 63 $lenSuffix) | int -}}
        {{- printf "%s-%s" ($templateName | lower | trunc $truncLen | trimSuffix "-") $stringSuffix -}}
    {{- else -}}
        {{- $templateName -}}
    {{- end -}}
{{- end -}}

{{/*
External Service name with IPv4 or IPv6 suffix (if enabled).
*/}}
{{- define "eric-cbrs-dc.ext-service.name" -}}
    {{- if and (.Values.service.externalService.externalIPv4.enabled | quote) (.Values.service.externalService.externalIPv6.enabled | quote) -}}
        {{- fail "Both IPv6 and IPv4 can not be enabled at the same time" }}
    {{- end }}

    {{- $suffix := "external" -}}
    {{- if quote .Values.service.externalService.externalIPv4.enabled -}}
        {{- $suffix := "ipv4" -}}
    {{- else if quote .Values.service.externalService.externalIPv6.enabled -}}
        {{- $suffix := "ipv6" -}}
    {{- end -}}

    {{/* adding 1 to cover the extra "-" */}}
    {{- $truncLen := (sub 63 (add (len $suffix) 1)) | int -}}
    {{- $templateName := include "eric-cbrs-dc.name" . -}}
    {{- printf "%s-%s" ($templateName | lower | trunc $truncLen | trimSuffix "-") $suffix -}}
{{- end -}}

{{/*
Create chart version as used by the chart label.
*/}}
{{- define "eric-cbrs-dc.version" -}}
{{- printf "%s" .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "eric-cbrs-dc.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create image pull secrets
*/}}
{{- define "eric-cbrs-dc.pullSecrets" -}}
    {{- $globalPullSecret := "" -}}
    {{- if .Values.global -}}
        {{- if .Values.global.pullSecret -}}
            {{- $globalPullSecret = .Values.global.pullSecret -}}
        {{- end -}}
    {{- end -}}
    {{- if .Values.imageCredentials.pullSecret -}}
        {{- print .Values.imageCredentials.pullSecret -}}
    {{- else if $globalPullSecret -}}
        {{- print $globalPullSecret -}}
    {{- end -}}
{{- end -}}

{{/*
Create mainImage's registry imagePullPolicy
*/}}
{{- define "eric-cbrs-dc.mainImage.registryImagePullPolicy" -}}
    {{- $globalRegistryPullPolicy := "IfNotPresent" -}}
    {{- if .Values.global -}}
        {{- if .Values.global.registry -}}
            {{- if .Values.global.registry.imagePullPolicy -}}
                {{- $globalRegistryPullPolicy = .Values.global.registry.imagePullPolicy -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- if .Values.imageCredentials.mainImage.registry -}}
        {{- if .Values.imageCredentials.mainImage.registry.imagePullPolicy -}}
            {{- $globalRegistryPullPolicy = .Values.imageCredentials.mainImage.registry.imagePullPolicy -}}
        {{- end -}}
    {{- end -}}
    {{- print $globalRegistryPullPolicy -}}
{{- end -}}

{{/*
Create initImage's registry imagePullPolicy
*/}}
{{- define "eric-cbrs-dc.initImage.registryImagePullPolicy" -}}
    {{- $registryImagePullPolicy := "IfNotPresent" -}}
    {{- if .Values.global -}}
        {{- if .Values.global.registry -}}
            {{- if .Values.global.registry.imagePullPolicy -}}
                {{- $registryImagePullPolicy = .Values.global.registry.imagePullPolicy -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- if .Values.imageCredentials.initImage.registry -}}
        {{- if .Values.imageCredentials.initImage.registry.imagePullPolicy -}}
        {{- $registryImagePullPolicy = .Values.imageCredentials.initImage.registry.imagePullPolicy -}}
        {{- end -}}
    {{- end -}}
    {{- print $registryImagePullPolicy -}}
{{- end -}}

{{/*
Create monitoringImage's registry imagePullPolicy
*/}}
{{- define "eric-cbrs-dc.monitoringImage.registryImagePullPolicy" -}}
    {{- $registryImagePullPolicy := "IfNotPresent" -}}
    {{- if .Values.global -}}
        {{- if .Values.global.registry -}}
            {{- if .Values.global.registry.imagePullPolicy -}}
                {{- $registryImagePullPolicy = .Values.global.registry.imagePullPolicy -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- if .Values.imageCredentials.monitoringImage.registry -}}
        {{- if .Values.imageCredentials.monitoringImage.registry.imagePullPolicy -}}
        {{- $registryImagePullPolicy = .Values.imageCredentials.monitoringImage.registry.imagePullPolicy -}}
        {{- end -}}
    {{- end -}}
    {{- print $registryImagePullPolicy -}}
{{- end -}}


{{/*
Create annotation for the product information (DR-D1121-064, DR-D1121-067)
*/}}
{{- define "eric-cbrs-dc.product-info" }}
ericsson.com/product-name: {{ (fromYaml (.Files.Get "eric-product-info.yaml")).productName | quote }}
ericsson.com/product-number: {{ (fromYaml (.Files.Get "eric-product-info.yaml")).productNumber | quote }}
ericsson.com/product-revision: {{ regexReplaceAll "(.*)[+|-].*" .Chart.Version "${1}" | quote }}
{{- end}}

{{/*
Create a user defined annotation (DR-D1121-065, DR-D1121-060)
*/}}
{{ define "eric-cbrs-dc.config-annotations" }}
  {{- $global := (.Values.global).annotations -}}
  {{- $service := .Values.annotations -}}
  {{- include "eric-cbrs-dc.mergeAnnotations" (dict "location" .Template.Name "sources" (list $global $service)) }}
{{- end }}

{{/*
Merged annotations for Default, which includes productInfo and config
*/}}
{{- define "eric-cbrs-dc.annotations" -}}
  {{- $productInfo := include "eric-cbrs-dc.product-info" . | fromYaml -}}
  {{- $config := include "eric-cbrs-dc.config-annotations" . | fromYaml -}}
  {{- include "eric-cbrs-dc.mergeAnnotations" (dict "location" .Template.Name "sources" (list $productInfo $config)) | trim }}
{{- end -}}

{{/*
Create annotations for service, which includes prometheus and service specific values
*/}}
{{- define "eric-cbrs-dc.service-annotations" -}}
prometheus.io/scrape: "true"
prometheus.io/port: "9600"
prometheus.io/scrape-interval: "1m"
prometheus.io/scrape-role: "endpoints"
prometheus.io/path: "/metrics"

{{- if .Values.ingress.ingressClass }}
kubernetes.io/ingress.class: {{.Values.ingress.ingressClass }}
{{- end }}
{{- end -}}

{{/*
Merged annotations for service, which includes Default and service specific
*/}}
{{- define "eric-cbrs-dc.service-annotations-merged" -}}
  {{- $default := include "eric-cbrs-dc.annotations" . | fromYaml -}}
  {{- $service := include "eric-cbrs-dc.service-annotations" . | fromYaml -}}
  {{- include "eric-cbrs-dc.mergeAnnotations" (dict "location" .Template.Name "sources" (list $default $service)) | trim }}
{{- end -}}

{{/*
Create annotations for ingress, when TLS enabled
*/}}
{{- define "eric-cbrs-dc.ingress-tls-annotations" -}}
{{- if (((.Values.global).security).tls).enabled }}
nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
nginx.ingress.kubernetes.io/ssl-redirect: "true"
nginx.ingress.kubernetes.io/ssl-passthrough: "true"
{{- end }}
{{- end -}}

{{/*
Merged annotations for ingress, which includes Default and ingress tls specific
*/}}
{{- define "eric-cbrs-dc.ingress-tls-annotations-merged" -}}
  {{- $default := include "eric-cbrs-dc.annotations" . | fromYaml -}}
  {{- $ingress := include "eric-cbrs-dc.ingress-tls-annotations" . | fromYaml -}}
  {{- include "eric-cbrs-dc.mergeAnnotations" (dict "location" .Template.Name "sources" (list $default $ingress)) | trim }}
{{- end -}}

{{/*
Standard labels of Helm and Kubernetes
*/}}
{{- define "eric-cbrs-dc.standard-labels" -}}
app.kubernetes.io/name: {{ include "eric-cbrs-dc.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ include "eric-cbrs-dc.version" . }}
helm.sh/chart: {{ include "eric-cbrs-dc.chart" . }}
ericsson.com/eric-cbrs-dc: {{ include "eric-cbrs-dc.sharedNameReference" . }}
chart: {{ include "eric-cbrs-dc.chart" . }}
app: "dpcoordinator"
{{- end -}}

{{/*
Create a user defined label (DR-D1121-068, DR-D1121-060)
*/}}
{{ define "eric-cbrs-dc.config-labels" }}
  {{- $global := (.Values.global).labels -}}
  {{- $service := .Values.labels -}}
  {{- include "eric-cbrs-dc.mergeLabels" (dict "location" .Template.Name "sources" (list $global $service)) }}
{{- end }}

{{/*
Merged labels for Default, which includes Standard and Config
*/}}
{{- define "eric-cbrs-dc.labels" -}}
  {{- $standard := include "eric-cbrs-dc.standard-labels" . | fromYaml -}}
  {{- $config := include "eric-cbrs-dc.config-labels" . | fromYaml -}}
  {{- include "eric-cbrs-dc.mergeLabels" (dict "location" .Template.Name "sources" (list $standard $config)) | trim }}
{{- end -}}

{{/*
Create a network policy access label
*/}}
{{ define "eric-cbrs-dc.network-policy-labels" }}
{{- if .Values.networkPolicy.accessLabels -}}
{{- range $name, $config := .Values.networkPolicy.accessLabels }}
{{ tpl $config $ }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create a endpointslice label
*/}}
{{ define "eric-cbrs-dc.endpointslice-labels" }}
{{- if .Values.endpointSlice.labels -}}
{{- range $name, $config := .Values.endpointSlice.labels }}
{{ tpl $config $ }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Merged labels for headless svc, which includes Default and endpointslice
*/}}
{{- define "eric-cbrs-dc.headless-service-labels" -}}
  {{- $proxyLabels := dict -}}
  {{- $_ := set $proxyLabels "sidecar.istio.io/inject" "false" -}}
  {{- $default := include "eric-cbrs-dc.labels" . | fromYaml -}}
  {{- $endpointslice := include "eric-cbrs-dc.endpointslice-labels" . | fromYaml -}}
  {{- include "eric-cbrs-dc.mergeLabels" (dict "location" .Template.Name "sources" (list $default $endpointslice $proxyLabels)) | trim }}
{{- end -}}

{{/*
Merged labels for Deployment, which includes Default and Network policy
*/}}
{{- define "eric-cbrs-dc.deployment-labels" -}}
  {{- $proxyLabels := dict -}}
  {{- $_ := set $proxyLabels "sidecar.istio.io/inject" "false" -}}
  {{- $default := include "eric-cbrs-dc.labels" . | fromYaml -}}
  {{- $networkpolicy := include "eric-cbrs-dc.network-policy-labels" . | fromYaml -}}
  {{- include "eric-cbrs-dc.mergeLabels" (dict "location" .Template.Name "sources" (list $default $networkpolicy $proxyLabels)) | trim }}
{{- end -}}

{{/*
Create a merged set of nodeSelectors from global and service level.
*/}}
{{ define "eric-cbrs-dc.nodeSelector" }}
  {{- $g := fromJson (include "eric-cbrs-dc.global" .) -}}
  {{- $global := $g.nodeSelector -}}
  {{- $service := .Values.nodeSelector -}}
  {{- include "eric-cbrs-dc.aggregatedMerge" (dict "context" "nodeSelector" "location" .Template.Name "sources" (list $global $service)) }}
{{ end }}

{{/*
Create annotations for roleBinding.
*/}}
{{- define "eric-cbrs-dc.securityPolicy.annotations" }}
ericsson.com/security-policy.name: "restricted/default"
ericsson.com/security-policy.privileged: "false"
ericsson.com/security-policy.capabilities: "N/A"
{{- end -}}

{{/*
Create roleBinding reference.
*/}}
{{- define "eric-cbrs-dc.securityPolicy.reference" -}}
    {{- if .Values.global -}}
        {{- if .Values.global.security -}}
            {{- if .Values.global.security.policyReferenceMap -}}
              {{ $mapped := index .Values "global" "security" "policyReferenceMap" "default-restricted-security-policy" }}
              {{- if $mapped -}}
                {{ $mapped }}
              {{- else -}}
                {{ $mapped }}
              {{- end -}}
            {{- else -}}
              default-restricted-security-policy
            {{- end -}}
        {{- else -}}
          default-restricted-security-policy
        {{- end -}}
    {{- else -}}
      default-restricted-security-policy
    {{- end -}}
{{- end -}}
##new external ip handling
{{/*
Create IPv4 boolean service/global/<notset>
*/}}
{{- define "eric-cbrs-dc.ext-service.enabled-IPv4" -}}
{{- if .Values.service.externalService.externalIPv4.enabled | quote -}}
{{- .Values.service.externalService.externalIPv4.enabled -}}
{{- else -}}
{{- if .Values.global -}}
{{- if .Values.global.externalIPv4 -}}
{{- if .Values.global.externalIPv4.enabled | quote -}}
{{- .Values.global.externalIPv4.enabled -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create IPv6 boolean service/global/<notset>
*/}}
{{- define "eric-cbrs-dc.ext-service.enabled-IPv6" -}}
{{- if .Values.service.externalService.externalIPv6.enabled | quote -}}
{{- .Values.service.externalService.externalIPv6.enabled -}}
{{- else -}}
{{- if .Values.global -}}
{{- if .Values.global.externalIPv6 -}}
{{- if .Values.global.externalIPv6.enabled | quote -}}
{{- .Values.global.externalIPv6.enabled -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Merged annotations for IPv4
*/}}
{{- define "eric-cbrs-dc.ext-service.annotations-ipv4" -}}
  {{- $ipv4 := dict -}}
  {{- if .Values.service.externalService.externalIPv4.annotations.sharedVIPLabel }}
    {{- $_ := set $ipv4 "metallb.universe.tf/allow-shared-ip" (.Values.service.externalService.externalIPv4.annotations.sharedVIPLabel) -}}
  {{- end -}}
  {{- if .Values.service.externalService.externalIPv4.annotations.addressPoolName }}
    {{- $_ := set $ipv4 "metallb.universe.tf/address-pool" (.Values.service.externalService.externalIPv4.annotations.addressPoolName) -}}
  {{- end -}}
  {{- $cloudProviderLB := (.Values.service.externalService.externalIPv4.annotations.cloudProviderLB)  -}}

  {{- $default := include "eric-cbrs-dc.annotations" . | fromYaml -}}
  {{- include "eric-cbrs-dc.mergeAnnotations" (dict "location" .Template.Name "sources" (list $ipv4 $default)) | trim }}
{{- end -}}

{{/*
Merged annotations for IPv6
*/}}
{{- define "eric-cbrs-dc.ext-service.annotations-ipv6" -}}
  {{- $ipv6 := dict -}}
  {{- if .Values.service.externalService.externalIPv6.annotations.sharedVIPLabel }}
    {{- $_ := set $ipv6 "metallb.universe.tf/allow-shared-ip" (.Values.service.externalService.externalIPv6.annotations.sharedVIPLabel) -}}
  {{- end -}}
  {{- if .Values.service.externalService.externalIPv6.annotations.addressPoolName }}
    {{- $_ := set $ipv6 "metallb.universe.tf/address-pool" (.Values.service.externalService.externalIPv6.annotations.addressPoolName) -}}
  {{- end -}}
  {{- $cloudProviderLB := (.Values.service.externalService.externalIPv6.annotations.cloudProviderLB)  -}}

  {{- $default := include "eric-cbrs-dc.annotations" . | fromYaml -}}
  {{- include "eric-cbrs-dc.mergeAnnotations" (dict "location" .Template.Name "sources" (list $ipv6 $cloudProviderLB $default)) | trim }}
{{- end -}}

{{/*
Merged annotations for legacy
*/}}
{{- define "eric-cbrs-dc.ext-service.annotations" -}}
  {{- $legacy := dict -}}
  {{- if .Values.service.externalService.annotations.sharedVIPLabel }}
    {{- $_ := set $legacy "metallb.universe.tf/allow-shared-ip" (.Values.service.externalService.annotations.sharedVIPLabel) -}}
  {{- end -}}
  {{- if .Values.service.externalService.annotations.addressPoolName }}
    {{- $_ := set $legacy "metallb.universe.tf/address-pool" (.Values.service.externalService.annotations.addressPoolName) -}}
  {{- end -}}
  {{- $cloudProviderLB := (.Values.service.externalService.annotations.cloudProviderLB)  -}}

  {{- $default := include "eric-cbrs-dc.annotations" . | fromYaml -}}
  {{- include "eric-cbrs-dc.mergeAnnotations" (dict "location" .Template.Name "sources" (list $legacy $cloudProviderLB $default)) | trim }}
{{- end -}}

{{/*
Merged annotations for Ingress class
*/}}
{{- define "eric-cbrs-dc.ingress-class.annotations" -}}
  {{- $ingressClass := dict -}}
  {{- if .Values.ingress.ingressClass }}
    {{- $_ := set $ingressClass "kubernetes.io/ingress.class" (.Values.ingress.ingressClass) -}}
  {{- end -}}

  {{- $default := include "eric-cbrs-dc.annotations" . | fromYaml -}}
  {{- include "eric-cbrs-dc.mergeAnnotations" (dict "location" .Template.Name "sources" (list $ingressClass $default)) | trim }}
{{- end -}}

{{/*
adding TopologySpreadConstraints
*/}}
{{- define "eric-cbrs-dc.topologySpreadConstraints" }}
{{- if .Values.topologySpreadConstraints }}
{{- range $config, $values := .Values.topologySpreadConstraints }}
- topologyKey: {{ $values.topologyKey }}
  maxSkew: {{ $values.maxSkew | default 1 }}
  whenUnsatisfiable: {{ $values.whenUnsatisfiable | default "ScheduleAnyway" }}
  labelSelector:
    matchLabels:
      app: {{ template "eric-cbrs-dc.name" $ }}
{{- end }}
{{- end }}
{{- end }}

{{/*
definition of ports and selector for external service
*/}}
{{- define "eric-cbrs-dc.ext-service.ports" }}
  ports:
  - name: jboss
    protocol: TCP
    port: {{ .Values.service.jbossPort }}
    targetPort: jboss-port
{{- end -}}
{{- define "eric-cbrs-dc.ext-service.selector" }}
  selector:
    ericsson.com/eric-cbrs-dc: {{ template "eric-cbrs-dc.name" . }}
{{- end -}}

{{- define "eric-cbrs-dc.product-image-number" }}
    {{- print (fromYaml (.Files.Get "eric-product-info.yaml")).images.mainImage.productNumber | quote }}
{{- end}}

{{- define "eric-cbrs-dc.product-image-rState" }}
    {{- print (fromYaml (.Files.Get "eric-product-info.yaml")).images.mainImage.tag | quote }}
{{- end}}


{{/*
Create AppArmor annotations
*/}}
{{- define "eric-cbrs-dc.appArmorAnnotations" -}}
{{- if index .Values "appArmorProfile" -}}
{{- if index .Values "appArmorProfile" "eric-cbrs-dc" -}}
{{- if index .Values "appArmorProfile" "eric-cbrs-dc" "type" -}}
{{- $profileRef := index .Values "appArmorProfile" "eric-cbrs-dc" "type" -}}
{{- if eq index .Values "appArmorProfile" "eric-cbrs-dc" "type" "localhost" -}}
{{- $failureMessage := "If you set appArmorProfile.eric-cbrs-dc.type=localhost you are required to set appArmorProfile.eric-cbrs-dc.localhostProfile" -}}
{{- $profileRef = printf "localhost/%s" (required $failureMessage index .Values "appArmorProfile" "eric-cbrs-dc" "localhostProfile") -}}
{{- end -}}
container.apparmor.security.beta.kubernetes.io/eric-cbrs-dc: {{ $profileRef | quote }}
{{- end -}}
{{- end -}}
{{- if index .Values "appArmorProfile" "eric-cbrs-dc-monitoring"  -}}
{{- if index .Values "appArmorProfile" "eric-cbrs-dc-monitoring" "type" -}}
{{- $profileInitRef := index .Values "appArmorProfile" "eric-cbrs-dc-monitoring" "type" -}}
{{- if eq index .Values "appArmorProfile" "eric-cbrs-dc-monitoring" "type" "localhost" -}}
{{- $failureMessageInit := "If you set appArmorProfile.eric-cbrs-dc-monitoring.type=localhost you are required to set appArmorProfile.eric-cbrs-dc-monitoring.localhostProfile" -}}
{{- $profileInitRef = printf "localhost/%s" (required $failureMessageInit index  .Values "appArmorProfile" "eric-cbrs-dc-monitoring" "localhostProfile") -}}
{{- end }}
container.apparmor.security.beta.kubernetes.io/eric-cbrs-dc-monitoring: {{ $profileInitRef | quote }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}


{/*
Create seccomp config
*/}}
{{- define "eric-cbrs-dc.seccompProfile" -}}
{{- $container := . -}}
{{- if $container -}}
{{- if $container.type -}}
seccompProfile:
  type: {{ $container.type | quote }}
{{- if eq $container.type "Localhost" -}}
{{ $failureMessage := "If you set seccomp type 'Localhost' you are required to set the seccomp 'localhostProfile'" }}
  localhostProfile: {{ required $failureMessage $container.localhostProfile | quote }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
