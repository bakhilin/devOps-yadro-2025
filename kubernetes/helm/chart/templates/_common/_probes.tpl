{{- define "common.probes" -}}

{{/* Default values for probe configurations */}}
{{- $defaultInitialDelaySeconds := 10 -}}
{{- $defaultPeriodSeconds := 5 -}}
{{- $defaultTimeoutSeconds := 1 -}}
{{- $defaultFailureThreshold := 3 -}}
{{- $defaultSuccessThreshold := 1 -}}

{{- if .Values.probes.liveness }}
livenessProbe:
  {{- if .Values.probes.liveness.httpGet }}
  httpGet:
    path: {{ .Values.probes.liveness.httpGet.path }}
    port: {{ .Values.probes.liveness.httpGet.port }}
  {{- end }}
  {{- if .Values.probes.liveness.tcpSocket }}
  tcpSocket:
    port: {{ .Values.probes.liveness.tcpSocket.port }}
  {{- end }}
  {{- if .Values.probes.liveness.exec }}
  exec:
    command: {{ toJson .Values.probes.liveness.exec.command }}
  {{- end }}
  initialDelaySeconds: {{ default $defaultInitialDelaySeconds .Values.probes.liveness.initialDelaySeconds }}
  periodSeconds: {{ default $defaultPeriodSeconds .Values.probes.liveness.periodSeconds }}
  timeoutSeconds: {{ default $defaultTimeoutSeconds .Values.probes.liveness.timeoutSeconds }}
  failureThreshold: {{ default $defaultFailureThreshold .Values.probes.liveness.failureThreshold }}
  successThreshold: {{ default $defaultSuccessThreshold .Values.probes.liveness.successThreshold }}
{{- end }}

{{- if .Values.probes.readiness }}
readinessProbe:
  {{- if .Values.probes.readiness.httpGet }}
  httpGet:
    path: {{ .Values.probes.readiness.httpGet.path }}
    port: {{ .Values.probes.readiness.httpGet.port }}
  {{- end }}
  {{- if .Values.probes.readiness.tcpSocket }}
  tcpSocket:
    port: {{ .Values.probes.readiness.tcpSocket.port }}
  {{- end }}
  {{- if .Values.probes.readiness.exec }}
  exec:
    command: {{ toJson .Values.probes.readiness.exec.command }}
  {{- end }}
  initialDelaySeconds: {{ default $defaultInitialDelaySeconds .Values.probes.readiness.initialDelaySeconds }}
  periodSeconds: {{ default $defaultPeriodSeconds .Values.probes.readiness.periodSeconds }}
  timeoutSeconds: {{ default $defaultTimeoutSeconds .Values.probes.readiness.timeoutSeconds }}
  failureThreshold: {{ default $defaultFailureThreshold .Values.probes.readiness.failureThreshold }}
  successThreshold: {{ default $defaultSuccessThreshold .Values.probes.readiness.successThreshold }}
{{- end }}

{{- if .Values.probes.startup }}
startupProbe:
  {{- if .Values.probes.startup.httpGet }}
  httpGet:
    path: {{ .Values.probes.startup.httpGet.path }}
    port: {{ .Values.probes.startup.httpGet.port }}
  {{- end }}
  {{- if .Values.probes.startup.tcpSocket }}
  tcpSocket:
    port: {{ .Values.probes.startup.tcpSocket.port }}
  {{- end }}
  {{- if .Values.probes.startup.exec }}
  exec:
    command: {{ toJson .Values.probes.startup.exec.command }}
  {{- end }}
  initialDelaySeconds: {{ default $defaultInitialDelaySeconds .Values.probes.startup.initialDelaySeconds }}
  periodSeconds: {{ default $defaultPeriodSeconds .Values.probes.startup.periodSeconds }}
  timeoutSeconds: {{ default $defaultTimeoutSeconds .Values.probes.startup.timeoutSeconds }}
  failureThreshold: {{ default $defaultFailureThreshold .Values.probes.startup.failureThreshold }}
  successThreshold: {{ default $defaultSuccessThreshold .Values.probes.startup.successThreshold }}
{{- end }}

{{- end }}

{{/* Validate probe configurations */}}
{{- if .Values.probes.startup }}
  {{- if not (or .Values.probes.startup.httpGet .Values.probes.startup.tcpSocket .Values.probes.startup.exec) }}
  {{- fail "Startup probe is defined but does not contain a valid configuration (httpGet, tcpSocket, or exec)." }}
  {{- end }}
{{- end }}

{{- if .Values.probes.readiness }}
  {{- if not (or .Values.probes.readiness.httpGet .Values.probes.readiness.tcpSocket .Values.probes.readiness.exec) }}
  {{- fail "Readiness probe is defined but does not contain a valid configuration (httpGet, tcpSocket, or exec)." }}
  {{- end }}
{{- end }}

{{- if .Values.probes.liveness }}
  {{- if not (or .Values.probes.liveness.httpGet .Values.probes.liveness.tcpSocket .Values.probes.liveness.exec) }}
  {{- fail "Liveness probe is defined but does not contain a valid configuration (httpGet, tcpSocket, or exec)." }}
  {{- end }}
{{- end }}


