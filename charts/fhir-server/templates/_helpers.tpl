{{/* vim: set filetype=mustache: */}}
{{/*
The name of the chart, truncated to 63 chars. Override via nameOverride.
*/}}
{{- define "fhir.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
A fully qualified app name for uniquely identifying resources from this chart
for a particular release. Override via fullnameOverride.
We truncate at 63 chars because some Kubernetes name fields are limited to this
(by the DNS naming spec).
*/}}
{{- define "fhir.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "fhir.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "fhir.labels" -}}
helm.sh/chart: {{ include "fhir.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ include "fhir.matchLabels" . }}
{{- if .Values.extraLabels }}
    {{- toYaml .Values.extraLabels }}
{{- end }}
{{- end -}}

{{/*
Labels to use on deploy.spec.selector.matchLabels and svc.spec.selector
*/}}
{{- define "fhir.matchLabels" -}}
app.kubernetes.io/name: {{ include "fhir.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create a default fully qualified PostgreSQL name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
NOTE: we should be able to replace this approach once https://github.com/helm/helm/pull/9957 is available in Helm
*/}}
{{- define "fhir.postgresql.fullname" -}}
{{- $name := default "postgresql" .Values.postgresql.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Get the database server hostname
*/}}
{{- define "fhir.database.host" -}}
{{- ternary (include "fhir.postgresql.fullname" .) .Values.db.host .Values.postgresql.enabled -}}
{{- end -}}

{{/*
Get the admin user to connect to the database server
*/}}
{{- define "fhir.database.adminUser" -}}
{{- ternary "postgres" .Values.db.adminUser .Values.postgresql.enabled -}}
{{- end -}}

{{/*
Get the user to connect to the database server
*/}}
{{- define "fhir.database.user" -}}
{{- ternary .Values.postgresql.auth.username .Values.db.user .Values.postgresql.enabled -}}
{{- end -}}

{{/*
Get the name of the database
*/}}
{{- define "fhir.database.name" -}}
{{- ternary .Values.postgresql.auth.database .Values.db.name .Values.postgresql.enabled -}}
{{- end -}}

{{/*
Get the database server port
*/}}
{{- define "fhir.database.port" -}}
{{- ternary "5432" .Values.db.port .Values.postgresql.enabled -}}
{{- end -}}

{{/*
Get the database credentials secret name.
*/}}
{{- define "fhir.database.secretName" -}}
{{- if and (.Values.postgresql.enabled) (not .Values.postgresql.existingSecret) -}}
    {{- printf "%s" (include "fhir.postgresql.fullname" .) -}}
{{- else if and (.Values.postgresql.enabled) (.Values.postgresql.existingSecret) -}}
    {{- printf "%s" .Values.postgresql.existingSecret -}}
{{- else if .Values.db.dbSecret -}}
    {{- printf "%s" .Values.db.dbSecret -}}
{{- else -}}
    {{- printf "%s-%s" (include "fhir.fullname" .) "db-secret" -}}
{{- end -}}
{{- end -}}

{{/*
Get the database credentials password secret key.
*/}}
{{- define "fhir.database.adminPasswordKey" -}}
{{- if .Values.postgresql.enabled }}
    {{- include "postgresql.adminPasswordKey" .Subcharts.postgresql }}
{{- else if (.Values.db.dbSecret) -}}
    {{- printf "%s" .Values.db.adminPasswordKey -}}
{{- else }}
    {{- printf "password" -}}
{{- end -}}
{{- end -}}

{{/*
Get the database credentials password secret key.
*/}}
{{- define "fhir.database.userPasswordKey" -}}
{{- if .Values.postgresql.enabled }}
    {{- include "postgresql.userPasswordKey" .Subcharts.postgresql }}
{{- else if (.Values.db.dbSecret) -}}
    {{- printf "%s" .Values.db.userPasswordKey -}}
{{- else }}
    {{- printf "password" -}}
{{- end -}}
{{- end -}}

{{/*
Get the database credentials apiKey secret key.
*/}}
{{- define "fhir.database.apiKeySecretKey" -}}
{{- if (.Values.db.dbSecret) -}}
    {{- printf "%s" .Values.db.apiKeySecretKey -}}
{{- else }}
    {{- printf "apiKey" -}}
{{- end -}}
{{- end -}}

{{/*
Image used for the PostgreSQL readiness init containers
If using Helm 3.7+, we could use `include "postgresql.image" .Subcharts.postgresql` instead
*/}}
{{- define "fhir.postgresql.waitForDB.image" -}}
{{- printf "%s/%s:%s" .Values.postgresql.image.registry .Values.postgresql.image.repository .Values.postgresql.image.tag }}
{{- end -}}

{{/*
Helper method for constructing a list of OAuth 2.0 scopes
from the flags and resource scopes under .Values.security.oauth
*/}}
{{- define "scopeList" -}}
  {{- $scopes := $.Values.security.oauth.smart.resourceScopes }}
  {{- if $.Values.security.oauth.smart.launchPatientScopeEnabled }}
    {{- $scopes = prepend $scopes "launch/patient" }}
  {{- end }}
  {{- if $.Values.security.oauth.smart.fhirUserScopeEnabled }}
    {{- $scopes = prepend $scopes "fhirUser" }}
  {{- end }}
  {{- if $.Values.security.oauth.profileScopeEnabled }}
    {{- $scopes = prepend $scopes "profile" }}
  {{- end }}
  {{- if $.Values.security.oauth.offlineAccessScopeEnabled }}
    {{- $scopes = prepend $scopes "offline_access" }}
  {{- end }}
  {{- if $.Values.security.oauth.offlineAccessScopeEnabled }}
    {{- $scopes = prepend $scopes "online_access" }}
  {{- end }}
  {{- toJson $scopes }}
{{- end -}}

{{/*
Override the keycloak.postgresql.fullname template defined by the codecentric keycloak chart.
https://github.com/codecentric/helm-charts/issues/648
*/}}
{{- define "keycloak.postgresql.fullname" -}}
{{- $postgresContext := dict "Values" .Values.postgresql "Release" .Release "Chart" (dict "Name" "postgresql") -}}
{{ include "postgresql.primary.fullname" $postgresContext }}
{{- end }}