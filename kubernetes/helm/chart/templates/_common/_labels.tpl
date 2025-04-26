{{- define "common.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/name: {{ .Release.Name }}
meta.helm.sh/release-name: "{{ .Release.Name }}"
{{- end }}


{{/*
Selector labels
*/}}
{{- define "common.selectorLabels" -}}
app.kubernetes.io/name: {{ .Release.Name }}
{{- end }}


{{- define "common.labels.defaultIngressLabels" -}}
nginx.ingress.kubernetes.io/force-ssl-redirect: 'true'
nginx.ingress.kubernetes.io/ssl-redirect: 'true'
nginx.ingress.kubernetes.io/proxy-connect-timeout: '50'
nginx.ingress.kubernetes.io/proxy-read-timeout: '3600'
nginx.ingress.kubernetes.io/proxy-send-timeout: '3600'
{{- end }}
