{{- /*
Returns the chart name
*/ -}}
{{- define "mathpix-ocr.name" -}}
{{- default .Chart.Name .Values.nameOverride -}}
{{- end }}

{{- /*
Create a “full name” for every K8s resource in this chart, truncated to 63 chars.
*/ -}}
{{- define "mathpix-ocr.fullname" -}}
{{- $name := include "mathpix-ocr.name" . -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- /*
Standard labels
*/ -}}
{{- define "mathpix-ocr.labels" -}}
app.kubernetes.io/name: {{ include "mathpix-ocr.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/managed-by: Helm
{{- end }}
